package tech.kayys.aljabr.spi.model;

import java.util.List;

public record ModelFamilyRuntimeCompatibility(
        boolean compatible,
        String selectedArchitectureAdapterId,
        String selectedArchitectureAdapterBy,
        List<String> problemCodes,
        List<String> remediationHints,
        ModelFamilyResolution modelFamily) {

    public ModelFamilyRuntimeCompatibility {
        selectedArchitectureAdapterId = selectedArchitectureAdapterId == null ? "" : selectedArchitectureAdapterId;
        selectedArchitectureAdapterBy = selectedArchitectureAdapterBy == null ? "" : selectedArchitectureAdapterBy;
        problemCodes = problemCodes == null ? List.of() : List.copyOf(problemCodes);
        remediationHints = remediationHints == null ? List.of() : List.copyOf(remediationHints);
    }
}
