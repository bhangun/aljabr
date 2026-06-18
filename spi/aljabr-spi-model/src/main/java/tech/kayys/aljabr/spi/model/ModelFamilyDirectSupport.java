package tech.kayys.aljabr.spi.model;

/**
 * Readiness level for direct SafeTensor inference (no weight conversion required).
 */
public enum ModelFamilyDirectSupport {
    /** Direct SafeTensor inference is not yet ready. */
    PENDING,
    /** Direct SafeTensor inference is experimental. */
    EXPERIMENTAL,
    /** Direct SafeTensor inference is declared but no adapter is provided. */
    DECLARED_NO_ADAPTER,
    /** Direct SafeTensor inference is fully supported and ready for use. */
    READY
}
