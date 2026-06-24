package tech.kayys.aljabr.data;

import tech.kayys.aljabr.core.tensor.Tensor;

public final class Batch {
    public final Tensor tokens;
    public final Tensor targets;

    public Batch(Tensor tokens, Tensor targets) {
        this.tokens = tokens;
        this.targets = targets;
    }
}