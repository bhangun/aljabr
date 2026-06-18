package tech.kayys.aljabr.core.memory;

/**
 * Factory for creating instances of {@link UnifiedMemoryStore}.
 * 
 * <p>Provides configuration-driven instantiation of off-heap storage engines.
 * By default, this uses RocksDB for robust, production-ready KV storage,
 * but allows falling back or switching to HelixDB.
 */
public final class MemoryStoreFactory {

    private MemoryStoreFactory() {}

    /**
     * Creates a new memory store using the default engine (RocksDB).
     * 
     * @param dbPath the path on disk to store the database files
     * @return an instance of {@link UnifiedMemoryStore}
     */
    public static UnifiedMemoryStore createDefault(String dbPath) {
        return createRocksDb(dbPath);
    }

    /**
     * Creates a new RocksDB-backed memory store.
     * Note: This assumes the aljabr-rocksdb module is present on the classpath.
     */
    public static UnifiedMemoryStore createRocksDb(String dbPath) {
        try {
            Class<?> clazz = Class.forName("tech.kayys.aljabr.core.memory.rocksdb.RocksDbMemoryStore");
            return (UnifiedMemoryStore) clazz.getConstructor(String.class).newInstance(dbPath);
        } catch (Exception e) {
            throw new RuntimeException("Failed to load RocksDbMemoryStore. Ensure aljabr-rocksdb is on the classpath.", e);
        }
    }

    /**
     * Creates a new HelixDB-backed memory store.
     * Note: This assumes the aljabr-helixdb module is present on the classpath.
     */
    public static UnifiedMemoryStore createHelixDb(String dbPath) {
        try {
            Class<?> clazz = Class.forName("tech.kayys.aljabr.core.memory.helixdb.HelixDbMemoryStore");
            return (UnifiedMemoryStore) clazz.getConstructor(String.class).newInstance(dbPath);
        } catch (Exception e) {
            throw new RuntimeException("Failed to load HelixDbMemoryStore. Ensure aljabr-helixdb is on the classpath.", e);
        }
    }
}
