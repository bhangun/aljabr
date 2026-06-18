package tech.kayys.aljabr.spi.model;
import tech.kayys.aljabr.spi.spec.*;
import tech.kayys.aljabr.core.tensor.DeviceType;
import tech.kayys.aljabr.core.model.ModelFormat;

import java.nio.file.Path;
import java.util.Map;

public record ModelArtifact(
        Path path,
        String checksum,
        Map<String, String> metadata) {
}
