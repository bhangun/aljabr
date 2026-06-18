package tech.kayys.aljabr.core.tensor;

import tech.kayys.aljabr.core.backend.ComputeBackend;
import tech.kayys.aljabr.core.memory.Buffer;

/** Default concrete tensor backed by a {@link Buffer}. */
public final class DefaultTensor implements Tensor {

    private final Shape shape;
    private final DType dtype;
    private final DeviceType device;
    private final Buffer buffer;
    private final ComputeBackend backend;
    private Tensor grad;
    private boolean requiresGrad;

    public DefaultTensor(Shape shape, DType dtype, DeviceType device, Buffer buffer, ComputeBackend backend) {
        this.shape = shape;
        this.dtype = dtype;
        this.device = device;
        this.buffer = buffer;
        this.backend = backend;
    }

    @Override public Shape shape()          { return shape; }
    @Override public DType dtype()          { return dtype; }
    @Override public DeviceType device()    { return device; }
    @Override public ComputeBackend backend(){ return backend; }

    public Buffer buffer() { return buffer; }

    @Override public Tensor add(Tensor other)        { return backend.add(this, other); }
    @Override public Tensor sub(Tensor other)        { return backend.sub(this, other); }
    @Override public Tensor mul(Tensor other)        { return backend.mul(this, other); }
    @Override public Tensor mul(float scalar)        { return backend.mul(this, scalar); }
    @Override public Tensor div(float scalar)        { return backend.div(this, scalar); }
    @Override public Tensor div(Tensor other)        { return backend.div(this, other); }
    @Override public Tensor add(float scalar)        { return backend.addScalar(this, scalar); }
    @Override public Tensor matmul(Tensor other)     { return backend.matmul(this, other); }
    @Override public Tensor reshape(long... newShape){ return backend.reshape(this, newShape); }
    @Override public Tensor softmax()                { return backend.softmax(this); }
    @Override public Tensor slice(long[] offsets, long[] sizes) { return backend.slice(this, offsets, sizes); }
    @Override public Tensor pow(float exponent)      { return backend.pow(this, exponent); }
    @Override public Tensor mean()                   { return backend.mean(this); }
    @Override public Tensor abs()                    { return backend.abs(this); }
    @Override public Tensor crossEntropy(Tensor t)   { return backend.crossEntropy(this, t); }
    @Override public Tensor binaryCrossEntropy(Tensor t){ return backend.binaryCrossEntropy(this, t); }
    @Override public Tensor cast(DType dtype)        { return backend.cast(this, dtype); }
    @Override public Tensor to(DeviceType device)    { return backend.to(this, device); }
    @Override public Tensor zerosLike()              { return backend.zerosLike(this); }
    @Override public Tensor sqrt()                   { return backend.sqrt(this); }
    @Override public Tensor relu()                   { return backend.relu(this); }
    @Override public Tensor sigmoid()                { return backend.sigmoid(this); }
    @Override public Tensor tanh()                   { return backend.tanh(this); }
    @Override public Tensor log()                    { return backend.log(this); }
    @Override public Tensor exp()                    { return backend.exp(this); }
    @Override public Tensor silu()                   { return backend.silu(this); }
    @Override public Tensor flatten()                { return backend.flatten(this); }
    @Override public Tensor unsqueeze(int dim)       { return backend.unsqueeze(this, dim); }
    @Override public Tensor squeeze()                { return backend.squeeze(this); }
    @Override public Tensor transpose()              { return backend.transpose(this); }
    @Override public Tensor transpose(int d0, int d1){ return backend.transpose(this, d0, d1); }
    @Override public long numel()                    { return shape.numel(); }
    @Override public float item()                    { return 0f; }
    @Override public void backward()                 {}
    @Override public Tensor grad()                   { return grad; }
    @Override public void setGrad(Tensor g)          { this.grad = g; }
    @Override public boolean requiresGrad()          { return requiresGrad; }
    @Override public void setRequiresGrad(boolean r) { this.requiresGrad = r; }

    @Override
    public void release() {
        if (buffer != null) buffer.release();
    }
}
