package tech.kayys.aljabr.core.memory;

import java.lang.foreign.MemorySegment;

/** Minimal buffer contract — backing store for tensor data. */
public interface Buffer {
    MemorySegment segment();
    long sizeBytes();
    void retain();
    void release();
}
