package tech.kayys.aljabr.core.memory.rocksdb;

import org.rocksdb.Options;
import org.rocksdb.RocksDB;
import org.rocksdb.RocksDBException;

import tech.kayys.aljabr.core.memory.UnifiedMemoryStore;

import java.lang.foreign.Arena;
import java.lang.foreign.MemorySegment;
import java.nio.ByteBuffer;
import java.util.Optional;

public class RocksDbMemoryStore implements UnifiedMemoryStore {

    private final RocksDB db;
    private final Options options;

    public RocksDbMemoryStore(String dbPath) {
        RocksDB.loadLibrary();
        try {
            this.options = new Options().setCreateIfMissing(true);
            this.db = RocksDB.open(options, dbPath);
        } catch (RocksDBException e) {
            throw new RuntimeException("Failed to initialize RocksDB at " + dbPath, e);
        }
    }

    @Override
    public void put(byte[] key, MemorySegment valueSegment) {
        try {
            // MemorySegment.asByteBuffer() provides a DirectByteBuffer mapping to the off-heap segment.
            // RocksDB supports put via direct ByteBuffer to avoid heap allocations.
            // Since this API does not directly accept the FFM DirectByteBuffer without custom JNI
            // in this specific version, we safely extract the byte array.
            byte[] bytes = valueSegment.toArray(java.lang.foreign.ValueLayout.JAVA_BYTE);
            db.put(key, bytes);
            // Note: Since RocksDB Java API doesn't fully support DirectByteBuffer puts out of the box in older versions without custom JNI,
            // we will simulate the integration path here. For true zero-copy PUT, custom JNI bindings are often needed.
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    @Override
    public Optional<MemorySegment> getZeroCopy(byte[] key, Arena arena) {
        try {
            // Standard RocksDB get creates a byte[] on heap.
            // For true zero-copy, you would use get(ColumnFamilyHandle, ReadOptions, ByteBuffer)
            // with a direct buffer. We use the standard get here for simplicity without column families.
            byte[] data = db.get(key);
            if (data == null) {
                return Optional.empty();
            }

            // Allocate an off-heap segment inside the provided Arena and copy the data.
            MemorySegment segment = arena.allocate(data.length);
            MemorySegment.copy(data, 0, segment, java.lang.foreign.ValueLayout.JAVA_BYTE, 0, data.length);

            return Optional.of(segment);
        } catch (RocksDBException e) {
            throw new RuntimeException("RocksDB get failed", e);
        }
    }

    @Override
    public void delete(byte[] key) {
        try {
            db.delete(key);
        } catch (RocksDBException e) {
            throw new RuntimeException(e);
        }
    }

    @Override
    public void flush() {
        try {
            db.flush(new org.rocksdb.FlushOptions());
        } catch (RocksDBException e) {
            throw new RuntimeException(e);
        }
    }

    @Override
    public void close() {
        if (db != null) db.close();
        if (options != null) options.close();
    }
}
