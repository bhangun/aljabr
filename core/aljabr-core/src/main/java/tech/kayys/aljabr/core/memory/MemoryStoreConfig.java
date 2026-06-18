package tech.kayys.aljabr.core.memory;

public class MemoryStoreConfig {
    private String engineType;
    private String dbPath;

    public MemoryStoreConfig(String engineType, String dbPath) {
        this.engineType = engineType;
        this.dbPath = dbPath;
    }

    public String getEngineType() {
        return engineType;
    }

    public String getDbPath() {
        return dbPath;
    }
}
