package tech.kayys.aljabr.backend.metal;

import org.jboss.logging.Logger;
import tech.kayys.aljabr.metal.binding.MetalBinding;
import tech.kayys.aljabr.core.backend.ComputeBackend;
import tech.kayys.aljabr.core.tensor.*;
import tech.kayys.aljabr.core.memory.CpuBuffer;
import tech.kayys.aljabr.backend.cpu.CpuBackend;

import java.lang.foreign.MemorySegment;
import java.util.List;

/**
 * Metal hardware-accelerated computation backend.
 */
public class MetalComputeBackend implements ComputeBackend {

    private static final Logger LOG = Logger.getLogger(MetalComputeBackend.class);
    private static final String FORCE_CPU_PROPERTY = "aljabr.kernel.force.cpu";

    private final MetalBinding metalBinding;
    private final CpuBackend cpuFallback;
    private final boolean isNative;
    private final boolean forceCpu;

    public MetalComputeBackend() {
        this.forceCpu = Boolean.parseBoolean(System.getProperty(FORCE_CPU_PROPERTY, "false"));

        if (forceCpu) {
            LOG.info("MetalComputeBackend forced into CPU mode by system properties.");
            MetalBinding.initializeFallback();
            this.metalBinding = MetalBinding.getInstance();
            this.isNative = false;
            this.cpuFallback = new CpuBackend();
            return;
        }

        boolean loaded = MetalBinding.initialize();
        if (!loaded) {
            LOG.warn("Failed to initialize MetalBinding. MetalComputeBackend will operate in CPU fallback mode.");
            MetalBinding.initializeFallback();
        }

        this.metalBinding = MetalBinding.getInstance();
        this.metalBinding.init();
        this.isNative = metalBinding.isRuntimeActive();
        this.cpuFallback = new CpuBackend();
        
        LOG.infof("Initialized MetalComputeBackend [Device: %s, Unified Memory: %s]", 
                metalBinding.deviceName(), metalBinding.isUnifiedMemory());
    }

    private DefaultTensor asDefault(Tensor t) {
        if (t instanceof DefaultTensor dt) {
            return dt;
        }
        throw new IllegalArgumentException("MetalComputeBackend only supports DefaultTensor");
    }

    private long byteSize(DType dtype) {
        return switch (dtype) {
            case F32, I32 -> 4;
            case F16, BF16 -> 2;
            case I8, INT8, Q8_0 -> 1;
            case Q4_K, Q4_0 -> 0; 
        };
    }

    private CpuBuffer allocate(long sizeBytes) {
        return new CpuBuffer(sizeBytes);
    }

    @Override
    public Tensor add(Tensor a, Tensor b) { return cpuFallback.add(a, b); }

    @Override
    public Tensor sub(Tensor a, Tensor b) { return cpuFallback.sub(a, b); }

    @Override
    public Tensor mul(Tensor a, float scalar) { return cpuFallback.mul(a, scalar); }

    @Override
    public Tensor mul(Tensor a, Tensor b) { return cpuFallback.mul(a, b); }

    @Override
    public Tensor div(Tensor a, float scalar) { return cpuFallback.div(a, scalar); }

    @Override
    public Tensor div(Tensor a, Tensor b) { return cpuFallback.div(a, b); }

    @Override
    public Tensor addScalar(Tensor a, float scalar) { return cpuFallback.addScalar(a, scalar); }

    @Override
    public Tensor matmul(Tensor a, Tensor b) {
        if (!isNative) return cpuFallback.matmul(a, b);
        
        DefaultTensor da = asDefault(a);
        DefaultTensor db = asDefault(b);
        
        int M = (int) a.shape().dim(a.shape().rank() - 2);
        int K = (int) a.shape().dim(a.shape().rank() - 1);
        int N = (int) b.shape().dim(b.shape().rank() - 1);
        
        Shape shapeC = new Shape(M, N);
        long sizeBytes = shapeC.numel() * byteSize(a.dtype());
        
        CpuBuffer bufferC = allocate(sizeBytes);
        int status = metalBinding.matmul(bufferC.segment(), da.buffer().segment(), db.buffer().segment(), M, K, N, 1.0f, 0.0f);
        if (status != 0) {
            return cpuFallback.matmul(a, b);
        }
        
        return new DefaultTensor(shapeC, a.dtype(), a.device(), bufferC, this);
    }

    @Override
    public Tensor reshape(Tensor a, long... newShape) { return cpuFallback.reshape(a, newShape); }

    @Override
    public Tensor attention(Tensor Q, Tensor K, Tensor V) {
        if (!isNative) return cpuFallback.attention(Q, K, V);
        
        DefaultTensor dQ = asDefault(Q);
        DefaultTensor dK = asDefault(K);
        DefaultTensor dV = asDefault(V);

        int B = (int) Q.shape().dim(0);
        int T = (int) Q.shape().dim(1);
        int H = (int) Q.shape().dim(2);
        int Hkv = (int) K.shape().dim(2);
        int D = (int) Q.shape().dim(3);

        Shape shapeOut = Q.shape();
        long sizeBytes = shapeOut.numel() * byteSize(Q.dtype());
        CpuBuffer bufferOut = allocate(sizeBytes);

        MemorySegment empty = MemorySegment.NULL;
        int status;
        if (H == Hkv) {
            status = metalBinding.attention(bufferOut.segment(), dQ.buffer().segment(), dK.buffer().segment(), dV.buffer().segment(),
                    empty, empty, B, T, H, D, 16, 1024, (float)(1.0/Math.sqrt(D)), 1, 0.0f);
        } else {
            status = metalBinding.attentionGqa(bufferOut.segment(), dQ.buffer().segment(), dK.buffer().segment(), dV.buffer().segment(),
                    empty, empty, B, T, H, Hkv, D, 16, 1024, (float)(1.0/Math.sqrt(D)), 1, 0.0f);
        }

        if (status != 0) {
            return cpuFallback.attention(Q, K, V);
        }

        return new DefaultTensor(shapeOut, Q.dtype(), Q.device(), bufferOut, this);
    }

    @Override
    public Tensor softmax(Tensor a) {
        if (!isNative || a.dtype() != DType.F32) return cpuFallback.softmax(a);
        
        DefaultTensor da = asDefault(a);
        Shape shape = a.shape();
        int n = (int) shape.numel();
        CpuBuffer bufferOut = allocate(n * 4);
        
        int status = metalBinding.softmax(bufferOut.segment(), da.buffer().segment(), n);
        if (status != 0) {
            return cpuFallback.softmax(a);
        }
        
        return new DefaultTensor(shape, a.dtype(), a.device(), bufferOut, this);
    }

    @Override
    public Tensor slice(Tensor a, long[] offsets, long[] sizes) { return cpuFallback.slice(a, offsets, sizes); }

    @Override
    public List<Tensor> split(Tensor a, int axis, int parts) { return cpuFallback.split(a, axis, parts); }

    @Override
    public Tensor pow(Tensor a, float exponent) { return cpuFallback.pow(a, exponent); }

    @Override
    public Tensor mean(Tensor a) { return cpuFallback.mean(a); }

    @Override
    public Tensor abs(Tensor a) { return cpuFallback.abs(a); }

    @Override
    public Tensor crossEntropy(Tensor pred, Tensor target) { return cpuFallback.crossEntropy(pred, target); }

    @Override
    public Tensor binaryCrossEntropy(Tensor pred, Tensor target) { return cpuFallback.binaryCrossEntropy(pred, target); }

    @Override
    public Tensor cast(Tensor a, tech.kayys.aljabr.core.tensor.DType dtype) { return cpuFallback.cast(a, dtype); }

    @Override
    public Tensor to(Tensor a, tech.kayys.aljabr.core.tensor.DeviceType device) {
        if (device == DeviceType.METAL || device == DeviceType.CPU) {
            return a;
        }
        return cpuFallback.to(a, device);
    }

    @Override
    public Tensor zerosLike(Tensor a) {
        Shape shape = a.shape();
        long sizeBytes = shape.numel() * byteSize(a.dtype());
        CpuBuffer buffer = allocate(sizeBytes);
        return new DefaultTensor(shape, a.dtype(), a.device(), buffer, this);
    }

    @Override
    public Tensor sqrt(Tensor a) { return cpuFallback.sqrt(a); }

    @Override
    public Tensor relu(Tensor a) { return cpuFallback.relu(a); }

    @Override
    public Tensor sigmoid(Tensor a) { return cpuFallback.sigmoid(a); }

    @Override
    public Tensor tanh(Tensor a) { return cpuFallback.tanh(a); }

    @Override
    public Tensor log(Tensor a) { return cpuFallback.log(a); }

    @Override
    public Tensor exp(Tensor a) { return cpuFallback.exp(a); }

    @Override
    public Tensor silu(Tensor a) {
        if (!isNative || a.dtype() != DType.F32) return cpuFallback.silu(a);
        
        DefaultTensor da = asDefault(a);
        Shape shape = a.shape();
        int n = (int) shape.numel();
        CpuBuffer bufferOut = allocate(n * 4);
        
        int status = metalBinding.silu(bufferOut.segment(), da.buffer().segment(), n);
        if (status != 0) {
            return cpuFallback.silu(a);
        }
        
        return new DefaultTensor(shape, a.dtype(), a.device(), bufferOut, this);
    }

    @Override
    public Tensor flatten(Tensor a) { return cpuFallback.flatten(a); }

    @Override
    public Tensor unsqueeze(Tensor a, int dim) { return cpuFallback.unsqueeze(a, dim); }

    @Override
    public Tensor squeeze(Tensor a) { return cpuFallback.squeeze(a); }

    @Override
    public Tensor transpose(Tensor a) { return cpuFallback.transpose(a); }

    @Override
    public Tensor transpose(Tensor a, int d0, int d1) { return cpuFallback.transpose(a, d0, d1); }

    @Override
    public Tensor gelu(Tensor a) {
        if (!isNative || a.dtype() != DType.F32) return cpuFallback.gelu(a);
        
        DefaultTensor da = asDefault(a);
        Shape shape = a.shape();
        int n = (int) shape.numel();
        CpuBuffer bufferOut = allocate(n * 4);
        
        int status = metalBinding.gelu(bufferOut.segment(), da.buffer().segment(), n);
        if (status != 0) {
            return cpuFallback.gelu(a);
        }
        
        return new DefaultTensor(shape, a.dtype(), a.device(), bufferOut, this);
    }

    @Override
    public Tensor softmax(Tensor a, int dim) {
        if (!isNative || a.dtype() != DType.F32) return cpuFallback.softmax(a, dim);
        
        if (dim == a.shape().rank() - 1) {
            int rows = 1;
            for (int i = 0; i < dim; i++) {
                rows *= a.shape().dim(i);
            }
            int cols = (int) a.shape().dim(dim);
            
            DefaultTensor da = asDefault(a);
            CpuBuffer bufferOut = allocate(rows * cols * 4);
            int status = metalBinding.softmaxRows(bufferOut.segment(), da.buffer().segment(), rows, cols);
            if (status == 0) {
                return new DefaultTensor(a.shape(), a.dtype(), a.device(), bufferOut, this);
            }
        }
        return cpuFallback.softmax(a, dim);
    }

    @Override
    public Tensor logSoftmax(Tensor a, int dim) { return cpuFallback.logSoftmax(a, dim); }

    @Override
    public Tensor mean(Tensor a, int dim, boolean keepDim) { return cpuFallback.mean(a, dim, keepDim); }

    @Override
    public Tensor sum(Tensor a) { return cpuFallback.sum(a); }

    @Override
    public Tensor sum(Tensor a, int dim, boolean keepDim) { return cpuFallback.sum(a, dim, keepDim); }

    @Override
    public Tensor max(Tensor a) { return cpuFallback.max(a); }

    @Override
    public Tensor layerNorm(Tensor input, long[] normalizedShape, Tensor weight, Tensor bias, float eps) {
        if (!isNative || input.dtype() != DType.F32) return cpuFallback.layerNorm(input, normalizedShape, weight, bias, eps);

        DefaultTensor dInput = asDefault(input);
        DefaultTensor dWeight = weight != null ? asDefault(weight) : null;
        DefaultTensor dBias = bias != null ? asDefault(bias) : null;

        Shape shape = input.shape();
        long sizeBytes = shape.numel() * byteSize(input.dtype());
        CpuBuffer bufferOut = allocate(sizeBytes);
        
        int n = 1;
        for (long s : normalizedShape) {
            n *= s;
        }
        int rows = (int) (shape.numel() / n);

        int status;
        if (rows == 1) {
            status = metalBinding.layerNorm(bufferOut.segment(), dInput.buffer().segment(),
                    dWeight != null ? dWeight.buffer().segment() : MemorySegment.NULL,
                    dBias != null ? dBias.buffer().segment() : MemorySegment.NULL,
                    n, eps);
        } else {
            status = metalBinding.layerNormRows(bufferOut.segment(), dInput.buffer().segment(),
                    dWeight != null ? dWeight.buffer().segment() : MemorySegment.NULL,
                    dBias != null ? dBias.buffer().segment() : MemorySegment.NULL,
                    rows, n, eps);
        }

        if (status != 0) {
            return cpuFallback.layerNorm(input, normalizedShape, weight, bias, eps);
        }

        return new DefaultTensor(shape, input.dtype(), input.device(), bufferOut, this);
    }

    @Override
    public Tensor rmsNorm(Tensor input, Tensor weight, float eps) {
        if (!isNative || input.dtype() != DType.F32) return cpuFallback.rmsNorm(input, weight, eps);
        
        DefaultTensor dInput = asDefault(input);
        DefaultTensor dWeight = asDefault(weight);
        
        Shape shape = input.shape();
        int n = (int) shape.dim(shape.rank() - 1);
        int rows = 1;
        for (int i = 0; i < shape.rank() - 1; i++) {
            rows *= shape.dim(i);
        }
        
        CpuBuffer bufferOut = allocate(rows * n * 4);
        int status;
        if (rows == 1) {
            status = metalBinding.rmsNorm(bufferOut.segment(), dInput.buffer().segment(), dWeight.buffer().segment(), n, eps, false);
        } else {
            status = metalBinding.rmsNormRows(bufferOut.segment(), dInput.buffer().segment(), dWeight.buffer().segment(), rows, n, eps, false);
        }
        
        if (status != 0) {
            return cpuFallback.rmsNorm(input, weight, eps);
        }
        
        return new DefaultTensor(shape, input.dtype(), input.device(), bufferOut, this);
    }

    @Override
    public Tensor batchNorm(Tensor input, Tensor weight, Tensor bias, Tensor runningMean, Tensor runningVar, boolean training, float momentum, float eps) {
        return cpuFallback.batchNorm(input, weight, bias, runningMean, runningVar, training, momentum, eps);
    }

    @Override
    public Tensor conv2d(Tensor input, Tensor weight, Tensor bias, int stride, int padding, int dilation, int groups) {
        return cpuFallback.conv2d(input, weight, bias, stride, padding, dilation, groups);
    }

    @Override
    public Tensor maxPool2d(Tensor input, int kernelSize, int stride, int padding) {
        return cpuFallback.maxPool2d(input, kernelSize, stride, padding);
    }

    @Override
    public Tensor adaptiveAvgPool2d(Tensor input, int outputH, int outputW) {
        return cpuFallback.adaptiveAvgPool2d(input, outputH, outputW);
    }

    @Override
    public Tensor dropout(Tensor input, float p, boolean training) {
        return cpuFallback.dropout(input, p, training);
    }

    @Override
    public Tensor embedding(Tensor weight, Tensor input, long paddingIdx) {
        return cpuFallback.embedding(weight, input, paddingIdx);
    }

    @Override
    public long numel(Tensor a) {
        return cpuFallback.numel(a);
    }
}
