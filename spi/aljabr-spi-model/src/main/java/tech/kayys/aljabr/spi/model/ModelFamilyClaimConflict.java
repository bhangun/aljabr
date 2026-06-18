package tech.kayys.aljabr.spi.model;

import java.util.List;

public record ModelFamilyClaimConflict(
        String claimType,
        String claim,
        List<String> familyIds) {

    public ModelFamilyClaimConflict {
        claimType = claimType == null ? "" : claimType;
        claim = claim == null ? "" : claim;
        familyIds = familyIds == null ? List.of() : List.copyOf(familyIds);
    }
}
