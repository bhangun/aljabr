
package tech.kayys.aljabr.autograd.spi;

import tech.kayys.aljabr.autograd.GradFn;
import tech.kayys.aljabr.autograd.GradRegistry;

public interface GradFnProvider {
    void registerGradients(GradRegistry registry);
}
