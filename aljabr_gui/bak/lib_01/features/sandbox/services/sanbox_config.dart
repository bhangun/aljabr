class SandboxConfig {
  const SandboxConfig({
    this.defaultTimeout = const Duration(seconds: 30),
    this.maxOutputLength = 10000,
    this.allowedLanguages = const ['dart', 'python', 'javascript', 'bash'],
    this.memoryLimit = 512, // MB
    this.cpuLimit = 100, // Percentage
    this.networkAccess = false,
  });

  final Duration defaultTimeout;
  final int maxOutputLength;
  final List<String> allowedLanguages;
  final int memoryLimit;
  final int cpuLimit;
  final bool networkAccess;

  static const defaultConfig = SandboxConfig();

  SandboxConfig copyWith({
    Duration? defaultTimeout,
    int? maxOutputLength,
    List<String>? allowedLanguages,
    int? memoryLimit,
    int? cpuLimit,
    bool? networkAccess,
  }) {
    return SandboxConfig(
      defaultTimeout: defaultTimeout ?? this.defaultTimeout,
      maxOutputLength: maxOutputLength ?? this.maxOutputLength,
      allowedLanguages: allowedLanguages ?? this.allowedLanguages,
      memoryLimit: memoryLimit ?? this.memoryLimit,
      cpuLimit: cpuLimit ?? this.cpuLimit,
      networkAccess: networkAccess ?? this.networkAccess,
    );
  }
}
