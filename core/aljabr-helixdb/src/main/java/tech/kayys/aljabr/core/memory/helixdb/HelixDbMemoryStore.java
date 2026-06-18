package tech.kayys.aljabr.core.memory.helixdb;

import tech.kayys.aljabr.core.memory.UnifiedMemoryStore;

import java.lang.foreign.Arena;
import java.lang.foreign.MemorySegment;
import java.nio.ByteBuffer;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;

/**
 * HelixDB is a pure-Java high-performance embedded key-value store.
 * This class provides a bridge to its off-heap memory management system.
 * 
 * <p>It uses a persistent off-heap Arena to cache blocks. 
 * Data is returned as zero-copy views.
 */
public class HelixDbMemoryStore implements UnifiedMemoryStore {

    // Persistent storage arena
    private final Arena storageArena = Arena.ofShared();
    
    // Off-heap index
    private final ConcurrentHashMap<String, MemorySegment> index = new ConcurrentHashMap<>();

    public HelixDbMemoryStore(String dbPath) {
        System.out.println("Initialized HelixDB off-heap engine at " + dbPath);
    }

    @Override
    public void put(byte[] key, MemorySegment valueSegment) {
        String keyStr = new String(key);
        long size = valueSegment.byteSize();
        
        // Allocate permanent off-heap memory in our storage arena
        MemorySegment storedSegment = storageArena.allocate(size);
        
        // Copy data from the transient input segment to our persistent storage
        MemorySegment.copy(valueSegment, 0, storedSegment, 0, size);
        
        index.put(keyStr, storedSegment);
    }

    @Override
    public Optional<MemorySegment> getZeroCopy(byte[] key, long expectedSize, Arena callerArena) {
        String keyStr = new String(key);
        MemorySegment storedSegment = index.get(keyStr);
        if (storedSegment == null) {
            return Optional.empty();
        }

        // Return a zero-copy pointer (slice) directly to our cached segment!
        // Note: The caller must not close callerArena and expect our segment to be freed,
        // because our segment is tied to storageArena. In the future, ManagedArena should be used
        // to handle cross-arena lifecycle coupling safely.
        return Optional.of(storedSegment.asSlice(0, Math.min(expectedSize, storedSegment.byteSize())));
    }

    @Override
    public void delete(byte[] key) {
        index.remove(new String(key));
        // In a real LSM, we'd add a tombstone. Here we just remove from index.
        // Memory is reclaimed when the storageArena is closed.
    }

    @Override
    public void flush() {
        // HelixDB sync to disk (noop for now)
    }

    @Override
    public void close() {
        index.clear();
        storageArena.close();
    }
}
