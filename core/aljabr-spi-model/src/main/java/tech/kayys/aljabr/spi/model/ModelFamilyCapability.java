package tech.kayys.aljabr.spi.model;

/**
 * Enumeration of capabilities that a {@link ModelFamilyPlugin} may declare.
 * These capability flags drive contract validation and runtime routing.
 */
public enum ModelFamilyCapability {
    /** The family supports causal-language-model (text-generation) inference. */
    CAUSAL_LM,
    /** The family bundles a tokenizer descriptor. */
    TOKENIZER,
    /** The family processes multi-modal (text + media) inputs. */
    MULTIMODAL,
    /** Inference is available directly from SafeTensor weights (no conversion). */
    DIRECT_SAFETENSOR_INFERENCE,
    /** The family produces embedding vectors. */
    EMBEDDING,
    /** The family can process image (visual) inputs. */
    VISION,
    /** The family includes a chat template configuration. */
    CHAT_TEMPLATE
}
