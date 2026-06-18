package tech.kayys.aljabr.autograd;

import tech.kayys.aljabr.ir.*;
import java.util.*;

public final class SigmoidGrad implements GradFn {
    @Override
    public Map<GValueId, GValueId> backward(
            GOp op,
            GValueId gradOut,
            GradContext ctx) {
        GValueRef x = op.inputs().get(0);
        GValueId dx = new GValueId(op.name() + "_dx");

        ctx.addOp(new GOp("sigmoid_backward", op.name() + "_backward", 
                List.of(x, new GValueRef(gradOut)), List.of(dx), Map.of()));

        return Map.of(x.id(), dx);
    }
}
