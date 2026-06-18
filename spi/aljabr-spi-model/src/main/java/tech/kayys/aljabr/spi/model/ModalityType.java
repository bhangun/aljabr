package tech.kayys.aljabr.spi.model;

/**
 * Enumerates the supported input and output modality types for multimodal requests.
 */
public enum ModalityType {
    /** Plain text input or output. */
    TEXT,
    /** Still image (JPEG, PNG, WebP, etc.). */
    IMAGE,
    /** Audio clip (WAV, MP3, etc.). */
    AUDIO,
    /** Video clip. */
    VIDEO,
    /** Structured document (PDF, DOCX, etc.). */
    DOCUMENT,
    /** Pre-computed dense vector embedding. */
    EMBEDDING,
    /** Numeric time-series data. */
    TIME_SERIES;

    /**
     * Returns true if this modality represents binary data (non-text).
     * @return true for IMAGE, AUDIO, VIDEO, DOCUMENT, EMBEDDING, TIME_SERIES
     */
    public boolean isBinary() {
        return this != TEXT;
    }
}
