package tech.kayys.aljabr.core.memory.helixdb;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;
import tech.kayys.aljabr.core.memory.ManagedArena;

import java.lang.foreign.MemorySegment;
import java.lang.foreign.ValueLayout;
import java.nio.file.Path;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

class HelixDbMemoryStoreTest {

    @Test
    void testZeroCopyGet(@TempDir Path tempDir) {
        try (HelixDbMemoryStore store = new HelixDbMemoryStore(tempDir.toString())) {
            byte[] key = "test-key-helix".getBytes();
            
            try (ManagedArena arena = ManagedArena.create()) {
                // Prepare some data
                MemorySegment input = arena.allocate(150);
                for (int i = 0; i < 150; i++) {
                    input.set(ValueLayout.JAVA_BYTE, i, (byte) (i * 2));
                }
                
                // Put
                store.put(key, input);
                
                // Get Zero Copy
                Optional<MemorySegment> outputOpt = store.getZeroCopy(key, 150, arena.raw());
                assertTrue(outputOpt.isPresent());
                
                MemorySegment output = outputOpt.get();
                assertEquals(150, output.byteSize());
                
                // Verify
                for (int i = 0; i < 150; i++) {
                    assertEquals((byte) (i * 2), output.get(ValueLayout.JAVA_BYTE, i));
                }
            }
        }
    }
}
