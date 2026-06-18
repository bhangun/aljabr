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
    public Optional<MemorySegment> getZeroCopy(byte[] key, long expectedSize, Arena arena) {
        try {
            // Wrap the direct buffer as a MemorySegment, allocated natively off-heap.
            // Note: In newer JDKs, MemorySegment.ofBuffer provides a segment backed by the buffer.
            // But we specifically need this memory to be owned by the provided Arena.
            // Since ByteBuffer.allocateDirect is un-managed or GC-managed, for true Arena ownership
            // one would allocate from the Arena directly.
            // Let's allocate directly from Arena and provide its ByteBuffer to RocksDB!
            
            MemorySegment segment = arena.allocate(expectedSize);
            ByteBuffer arenaBuf = segment.asByteBuffer();
            
            ByteBuffer keyBuf = ByteBuffer.allocateDirect(key.length);
            keyBuf.put(key);
            keyBuf.flip();
            
            org.rocksdb.ReadOptions ro = new org.rocksdb.ReadOptions();
            int read = db.get(ro, keyBuf, arenaBuf);
            ro.close();
            
            if (read == org.rocksdb.RocksDB.NOT_FOUND || read < 0) {
                return Optional.empty();
            }

            return Optional.of(segment.asSlice(0, read));
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
