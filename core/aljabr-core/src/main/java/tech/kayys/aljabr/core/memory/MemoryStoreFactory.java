package tech.kayys.aljabr.core.memory;

import java.lang.reflect.Constructor;

public class MemoryStoreFactory {

    public static UnifiedMemoryStore create(MemoryStoreConfig config) {
        String engine = config.getEngineType() != null ? config.getEngineType().toLowerCase() : "rocksdb";
        
        try {
            switch (engine) {
                case "rocksdb":
                    Class<?> rocksClass = Class.forName("tech.kayys.aljabr.core.memory.rocksdb.RocksDbMemoryStore");
                    Constructor<?> rocksCtor = rocksClass.getConstructor(String.class);
                    return (UnifiedMemoryStore) rocksCtor.newInstance(config.getDbPath());
                case "helixdb":
                    Class<?> helixClass = Class.forName("tech.kayys.aljabr.core.memory.helixdb.HelixDbMemoryStore");
                    Constructor<?> helixCtor = helixClass.getConstructor(String.class);
                    return (UnifiedMemoryStore) helixCtor.newInstance(config.getDbPath());
                default:
                    throw new IllegalArgumentException("Unknown memory engine: " + engine);
            }
        } catch (Exception e) {
            throw new RuntimeException("Failed to instantiate MemoryStore for engine: " + engine, e);
        }
    }
}
