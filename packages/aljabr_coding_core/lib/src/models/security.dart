enum SecurityPreset { custom, standard, strict }

enum FileAccessPolicy { alwaysAsk, allowAll, denyAll, allowList }

enum TerminalExecutionPolicy { requireReview, autoApprove, autoDeny }

enum ArtifactReviewPolicy { alwaysAsk, autoApprove, autoDeny }

class LocalPermission {
  final String resource;
  final bool isAllowed;

  LocalPermission({required this.resource, required this.isAllowed});
}
