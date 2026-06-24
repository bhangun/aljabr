package tech.kayys.aljabr.spi.model;

/**
 * Recognised bundle-profile tiers for a model family.
 *
 * <p>The tier is declared as a string value ({@code "core"}, {@code "optional"},
 * {@code "experimental"}) inside the descriptor metadata map and parsed at
 * validation time.
 */
public enum ModelFamilyBundleProfile {
    /** Shipped by default; always included in the standard distribution. */
    CORE("core"),
    /** Opt-in; available but not included by default. */
    OPTIONAL("optional"),
    /** Only metadata; no artifacts included. */
    METADATA_ONLY("metadata_only"),
    /** Preview quality; may change or be removed without notice. */
    EXPERIMENTAL("experimental");

    private final String key;

    ModelFamilyBundleProfile(String key) {
        this.key = key;
    }

    /** The lowercase string value used in descriptor metadata. */
    public String key() {
        return key;
    }

    /**
     * Parse a metadata string value into a {@code ModelFamilyBundleProfile}.
     *
     * @param value the raw string from descriptor metadata, e.g. {@code "optional"}
     * @return the matching profile, or {@code null} if unrecognised
     */
    public static ModelFamilyBundleProfile fromKey(String value) {
        if (value == null) return null;
        for (ModelFamilyBundleProfile p : values()) {
            if (p.key.equalsIgnoreCase(value)) return p;
        }
        return null;
    }
}
