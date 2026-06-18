package tech.kayys.aljabr.spi.model;

import java.nio.file.Path;
import java.util.List;

public record ModelFamilyQuantizedLoaderProfile(
        boolean gemma4MobileQat,
        boolean inferredFromConfig,
        String format,
        String container,
        String loaderScope,
        List<String> problemCodes) {

    public ModelFamilyQuantizedLoaderProfile {
        format = format == null ? "" : format;
        container = container == null ? "" : container;
        loaderScope = loaderScope == null ? "" : loaderScope;
        problemCodes = problemCodes == null ? List.of() : List.copyOf(problemCodes);
    }

    public static ModelFamilyQuantizedLoaderProfile fromModelDir(Path dir) {
        try {
            Path configPath = dir.resolve("config.json");
            if (!java.nio.file.Files.exists(configPath)) {
                return null;
            }
            String configContent = java.nio.file.Files.readString(configPath);
            if (!configContent.contains("quantization_config")) {
                return null;
            }
            
            boolean isGemma4 = configContent.contains("\"gemma4\"");
            boolean hasQuantMethodGemma = configContent.contains("\"gemma\"");
            boolean hasVision = configContent.contains("\"vision_config\"");
            boolean hasAudio = configContent.contains("\"audio_config\"");
            
            boolean gemma4Mobile = isGemma4 && hasQuantMethodGemma && (hasVision || hasAudio);

            if (!gemma4Mobile) {
                // If it is not gemma4 mobile and has no other known format, we might just return generic
                if (!configContent.contains("\"future_format\"")) {
                    return null;
                }
            }

            String format = gemma4Mobile ? "mobile" : "future_format";
            String container = gemma4Mobile ? "transformers" : "future_container";
            String scope = gemma4Mobile ? "metadata_only_pending_mobile_quant_loader" : "metadata_only_pending_future_quant_loader";
            List<String> codes = new java.util.ArrayList<>();
            if (gemma4Mobile) {
                codes.add(ModelFamilyProblemCodes.QAT_MOBILE_LOADER_PENDING);
            } else {
                codes.add(ModelFamilyProblemCodes.QUANTIZED_WEIGHT_LOADER_PENDING);
            }
            
            return new ModelFamilyQuantizedLoaderProfile(
                    gemma4Mobile, true, format, container, scope, codes);
        } catch (Exception e) {
            return null;
        }
    }
}
