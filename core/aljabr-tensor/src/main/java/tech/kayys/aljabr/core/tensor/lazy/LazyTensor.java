package tech.kayys.aljabr.core.tensor.lazy;

import tech.kayys.aljabr.core.backend.ComputeBackend;
import tech.kayys.aljabr.core.tensor.DType;
import tech.kayys.aljabr.core.tensor.DeviceType;
import tech.kayys.aljabr.core.tensor.Shape;
import tech.kayys.aljabr.core.tensor.Tensor;

import java.util.List;

/**
 * A Tensor implementation that defers computation by recording operations into a GraphNode DAG.
 * When actual data is requested via eval() or array access, the DAG is compiled,
 * optimized, and executed on the provided ComputeBackend.
 */
public class LazyTensor implements Tensor {

    private final GraphNode node;
    private final ComputeBackend executionBackend;
    private final GraphExecutor executor;

    public LazyTensor(GraphNode node, ComputeBackend executionBackend) {
        this.node = node;
        this.executionBackend = executionBackend;
        this.executor = new GraphExecutor(executionBackend);
    }

    public GraphNode getNode() {
        return node;
    }

    @Override
    public Tensor eval() {
        if (!node.isEvaluated()) {
            GraphNode optimized = GraphOptimizer.optimize(node);
            executor.evaluate(optimized);
            node.setMaterializedData(optimized.getMaterializedData());
        }
        return node.getMaterializedData();
    }

    @Override
    public Shape shape() {
        return node.getOutputShape();
    }

    @Override
    public DType dtype() {
        return node.getOutputDType();
    }

    @Override
    public DeviceType device() {
        if (node.isEvaluated()) {
            return node.getMaterializedData().device();
        }
        return DeviceType.CPU;
    }

    @Override
    public ComputeBackend backend() {
        return executionBackend;
    }

    @Override
    public float item() {
        return eval().item();
    }

    @Override
    public void backward() {
        eval().backward();
    }

    @Override
    public Tensor grad() {
        return eval().grad();
    }

    @Override
    public void setGrad(Tensor grad) {
        eval().setGrad(grad);
    }

    @Override
    public boolean requiresGrad() {
        return eval().requiresGrad();
    }

    @Override
    public void setRequiresGrad(boolean requiresGrad) {
        eval().setRequiresGrad(requiresGrad);
    }

    @Override
    public long numel() {
        return shape().numel();
    }

    // ── Math Operations (DAG recording) ──────────────────────────────────────────────────────

    private LazyTensor op(OpType type, List<Tensor> inputs, Object[] args, Shape outShape, DType outDType) {
        List<GraphNode> inputNodes = inputs.stream()
                .map(t -> (t instanceof LazyTensor lt) ? lt.getNode() : GraphNode.constant(t))
                .toList();
        GraphNode newNode = new GraphNode(type, inputNodes, args, outShape, outDType);
        return new LazyTensor(newNode, executionBackend);
    }

    @Override
    public Tensor add(Tensor t) {
        return op(OpType.ADD, List.of(this, t), new Object[0], this.shape(), this.dtype());
    }

    @Override
    public Tensor sub(Tensor t) {
        return op(OpType.SUB, List.of(this, t), new Object[0], this.shape(), this.dtype());
    }

    @Override
    public Tensor mul(Tensor t) {
        return op(OpType.MUL, List.of(this, t), new Object[0], this.shape(), this.dtype());
    }

    @Override
    public Tensor div(Tensor t) {
        return op(OpType.DIV, List.of(this, t), new Object[0], this.shape(), this.dtype());
    }

    @Override
    public Tensor add(float scalar) {
        return op(OpType.ADD_SCALAR, List.of(this), new Object[]{scalar}, this.shape(), this.dtype());
    }

    @Override
    public Tensor mul(float scalar) {
        return op(OpType.MUL_SCALAR, List.of(this), new Object[]{scalar}, this.shape(), this.dtype());
    }

    @Override
    public Tensor div(float scalar) {
        return op(OpType.DIV_SCALAR, List.of(this), new Object[]{scalar}, this.shape(), this.dtype());
    }

    @Override
    public Tensor matmul(Tensor t) {
        Shape s = new Shape(this.shape().dim(this.shape().rank() - 2), t.shape().dim(t.shape().rank() - 1));
        return op(OpType.MATMUL, List.of(this, t), new Object[0], s, this.dtype());
    }

    @Override
    public Tensor reshape(long... newShape) {
        return op(OpType.RESHAPE, List.of(this), new Object[]{newShape}, new Shape(newShape), this.dtype());
    }

    @Override
    public Tensor relu() {
        return op(OpType.RELU, List.of(this), new Object[0], this.shape(), this.dtype());
    }

    @Override
    public Tensor silu() {
        return op(OpType.SILU, List.of(this), new Object[0], this.shape(), this.dtype());
    }

    @Override public Tensor crossEntropy(Tensor t) { throw new UnsupportedOperationException(); }
    @Override public Tensor binaryCrossEntropy(Tensor t) { throw new UnsupportedOperationException(); }
    @Override public Tensor dropout(float p, boolean training) { throw new UnsupportedOperationException(); }
    @Override public Tensor slice(long[] offsets, long[] sizes) { throw new UnsupportedOperationException(); }
    @Override public List<Tensor> split(int axis, int parts) { throw new UnsupportedOperationException(); }
    @Override public Tensor pow(float exponent) { throw new UnsupportedOperationException(); }
    @Override public Tensor mean() { throw new UnsupportedOperationException(); }
    @Override public Tensor abs() { throw new UnsupportedOperationException(); }
    @Override public Tensor cast(DType dtype) { throw new UnsupportedOperationException(); }
    @Override public Tensor to(DeviceType device) { throw new UnsupportedOperationException(); }
    @Override public Tensor zerosLike() { throw new UnsupportedOperationException(); }
    @Override public Tensor sqrt() { throw new UnsupportedOperationException(); }
    @Override public Tensor sigmoid() { throw new UnsupportedOperationException(); }
    @Override public Tensor tanh() { throw new UnsupportedOperationException(); }
    @Override public Tensor log() { throw new UnsupportedOperationException(); }
    @Override public Tensor exp() { throw new UnsupportedOperationException(); }
    @Override public Tensor flatten() { throw new UnsupportedOperationException(); }
    @Override public Tensor unsqueeze(int dim) { throw new UnsupportedOperationException(); }
    @Override public Tensor squeeze() { throw new UnsupportedOperationException(); }
    @Override public Tensor transpose() { throw new UnsupportedOperationException(); }
    @Override public Tensor transpose(int dim0, int dim1) { throw new UnsupportedOperationException(); }
    @Override public Tensor gelu() { throw new UnsupportedOperationException(); }
    @Override public Tensor softmax(int dim) { throw new UnsupportedOperationException(); }
    @Override public Tensor softmax() { throw new UnsupportedOperationException(); }
    @Override public Tensor logSoftmax(int dim) { throw new UnsupportedOperationException(); }
    @Override public Tensor mean(int dim, boolean keepDim) { throw new UnsupportedOperationException(); }
    @Override public Tensor sum() { throw new UnsupportedOperationException(); }
    @Override public Tensor sum(int dim, boolean keepDim) { throw new UnsupportedOperationException(); }
    @Override public Tensor layerNorm(long[] normalizedShape, Tensor weight, Tensor bias, float eps) { throw new UnsupportedOperationException(); }
    @Override public Tensor rmsNorm(Tensor weight, float eps) { throw new UnsupportedOperationException(); }
    @Override public Tensor batchNorm(Tensor weight, Tensor bias, Tensor runningMean, Tensor runningVar, boolean training, float momentum, float eps) { throw new UnsupportedOperationException(); }
    @Override public Tensor conv2d(Tensor weight, Tensor bias, int stride, int padding, int dilation, int groups) { throw new UnsupportedOperationException(); }
    @Override public Tensor maxPool2d(int kernelSize, int stride, int padding) { throw new UnsupportedOperationException(); }
    @Override public Tensor adaptiveAvgPool2d(int outputH, int outputW) { throw new UnsupportedOperationException(); }
    @Override public Tensor attention(Tensor K, Tensor V) { throw new UnsupportedOperationException(); }
    @Override public Tensor embedding(Tensor weight, long paddingIdx) { throw new UnsupportedOperationException(); }
}
