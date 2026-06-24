package tech.kayys.aljabr.spi.model;

import java.util.List;

public record ModelFamilyRuntimeManifest(
        String familyId,
        List<String> modelTypes,
        List<String> architectureAdapterIds,
        List<String> tokenizerProfileIds,
        List<String> chatTemplateIds,
        ModelFamilyBundleProfile bundleProfile,
        ModelFamilyDirectSupport directSafetensorStatus,
        boolean tokenizerReady,
        boolean chatTemplateReady,
        boolean directSafetensorReady,
        List<ModelFamilyUnifiedRuntimeRequirement> unifiedRuntimeRequirements) {

    public ModelFamilyRuntimeManifest {
        familyId = familyId == null ? "" : familyId;
        modelTypes = modelTypes == null ? List.of() : List.copyOf(modelTypes);
        architectureAdapterIds = architectureAdapterIds == null ? List.of() : List.copyOf(architectureAdapterIds);
        tokenizerProfileIds = tokenizerProfileIds == null ? List.of() : List.copyOf(tokenizerProfileIds);
        chatTemplateIds = chatTemplateIds == null ? List.of() : List.copyOf(chatTemplateIds);
        unifiedRuntimeRequirements = unifiedRuntimeRequirements == null ? List.of() : List.copyOf(unifiedRuntimeRequirements);
    }

    public boolean requiresUnifiedRuntime() {
        return !unifiedRuntimeRequirements.isEmpty();
    }
}
