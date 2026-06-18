package tech.kayys.aljabr.spi.model;

import java.util.List;
import java.util.Collections;

public class ModelFamilyPluginRegistry {
    private static final ModelFamilyPluginRegistry INSTANCE = new ModelFamilyPluginRegistry();

    public static ModelFamilyPluginRegistry global() {
        return INSTANCE;
    }

    public List<Object> architectureAdapters() {
        return Collections.emptyList();
    }

    public void register(Object plugin) {}

    public void discoverServiceLoaderPlugins() {}

    public ModelFamilyResolution resolve(Object modelType, Object primaryArch) {
        return null;
    }
}
