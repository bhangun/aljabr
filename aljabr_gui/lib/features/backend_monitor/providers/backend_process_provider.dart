import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils/logger.dart';
import '../../log/services/log_file_service.dart';

enum BackendStatus { stopped, starting, running, error }

enum ServerType { aljabr, gollek, frontend }

/// Information and process state for an individual server instance.
class SingleServerState {
  final String name;
  final String description;
  final BackendStatus status;
  final int httpPort;
  final int? grpcPort;
  final int? pid;
  final DateTime? startedAt;
  final List<String> logs;
  final String? lastError;

  const SingleServerState({
    required this.name,
    required this.description,
    this.status = BackendStatus.stopped,
    required this.httpPort,
    this.grpcPort,
    this.pid,
    this.startedAt,
    this.logs = const [],
    this.lastError,
  });

  Duration? get uptime =>
      startedAt != null ? DateTime.now().difference(startedAt!) : null;

  SingleServerState copyWith({
    String? name,
    String? description,
    BackendStatus? status,
    int? httpPort,
    int? grpcPort,
    int? pid,
    DateTime? startedAt,
    List<String>? logs,
    String? lastError,
  }) {
    return SingleServerState(
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      httpPort: httpPort ?? this.httpPort,
      grpcPort: grpcPort ?? this.grpcPort,
      pid: pid ?? this.pid,
      startedAt: startedAt ?? this.startedAt,
      logs: logs ?? this.logs,
      lastError: lastError,
    );
  }
}

const _defaultAljabr = SingleServerState(
  name: 'Aljabr Agent & Substrate',
  description: 'Autonomous Coding Engine, LSP Kernel & API',
  httpPort: 8085,
  grpcPort: 9000,
);

const _defaultGollek = SingleServerState(
  name: 'Gollek Inference Server',
  description: 'Local Neural Compute, Model Runner & KV Cache',
  httpPort: 8080,
  grpcPort: 9131,
);

const _defaultFrontend = SingleServerState(
  name: 'Aljabr UI',
  description: 'Flutter Desktop Client, View State & Network Bridge',
  httpPort: 0,
  status: BackendStatus.running,
);

/// Unified Dual-Backend & Frontend state managing Aljabr Platform, Gollek Inference Server, and Aljabr UI.
class BackendState {
  final SingleServerState aljabr;
  final SingleServerState gollek;
  final SingleServerState frontend;
  final List<String> logs;
  final String activeLogTab; // 'all' | 'aljabr' | 'gollek' | 'frontend'

  BackendState({
    BackendStatus? status,
    SingleServerState? aljabr,
    SingleServerState? gollek,
    SingleServerState? frontend,
    this.logs = const [],
    this.activeLogTab = 'all',
  })  : aljabr = aljabr ??
            _defaultAljabr.copyWith(status: status ?? BackendStatus.stopped),
        gollek = gollek ??
            _defaultGollek.copyWith(status: status ?? BackendStatus.stopped),
        frontend = frontend ?? _defaultFrontend;

  /// Backward-compatible status getter:
  /// If either is starting -> starting; if either is running -> running; if error -> error; else stopped.
  BackendStatus get status {
    if (aljabr.status == BackendStatus.starting ||
        gollek.status == BackendStatus.starting) {
      return BackendStatus.starting;
    }
    if (aljabr.status == BackendStatus.running ||
        gollek.status == BackendStatus.running) {
      return BackendStatus.running;
    }
    if (aljabr.status == BackendStatus.error ||
        gollek.status == BackendStatus.error) {
      return BackendStatus.error;
    }
    return BackendStatus.stopped;
  }

  BackendState copyWith({
    BackendStatus? status,
    SingleServerState? aljabr,
    SingleServerState? gollek,
    SingleServerState? frontend,
    List<String>? logs,
    String? activeLogTab,
  }) {
    return BackendState(
      aljabr: aljabr ??
          (status != null ? this.aljabr.copyWith(status: status) : this.aljabr),
      gollek: gollek ?? this.gollek,
      frontend: frontend ?? this.frontend,
      logs: logs ?? this.logs,
      activeLogTab: activeLogTab ?? this.activeLogTab,
    );
  }
}

/// Dynamic Workspace & Path Resolver without any hardcoded paths.
class DynamicPathResolver {
  static String? _cachedWorkspaceRoot;

  static String get homeDir =>
      Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'] ?? '';

  static String expandPath(String path) {
    if (path.startsWith('~/')) {
      final home = homeDir;
      return home.isNotEmpty ? '$home/${path.substring(2)}' : path;
    } else if (path == '~') {
      return homeDir;
    }
    return path;
  }

  /// Automatically discovers the root of the wayang-platform repository.
  static String resolveWorkspaceRoot() {
    if (_cachedWorkspaceRoot != null &&
        Directory(_cachedWorkspaceRoot!).existsSync()) {
      return _cachedWorkspaceRoot!;
    }

    // 1. Check environment variables
    for (final envKey in [
      'WAYANG_HOME',
      'PROJECT_ROOT',
      'WORKSPACE_ROOT',
      'ALJABR_HOME'
    ]) {
      final val = Platform.environment[envKey];
      if (val != null && val.trim().isNotEmpty) {
        final expanded = expandPath(val.trim());
        if (Directory(expanded).existsSync()) {
          _cachedWorkspaceRoot = expanded;
          return expanded;
        }
      }
    }

    // 2. Walk up directory tree from current working directory & executable
    final probeDirs = <Directory>[
      Directory.current.absolute,
      File(Platform.resolvedExecutable).parent.absolute,
    ];

    for (final startDir in probeDirs) {
      Directory current = startDir;
      while (true) {
        // Marker A: has Families and Wayang-Projects subdirectories
        final familiesDir = Directory('${current.path}/Families');
        final wayangProjectsDir = Directory('${current.path}/Wayang-Projects');
        if (familiesDir.existsSync() && wayangProjectsDir.existsSync()) {
          _cachedWorkspaceRoot = current.path;
          return current.path;
        }

        // Marker B: inside Wayang-Agents/Aljabr
        if (Directory('${current.path}/Backend/aljabr-api').existsSync()) {
          // Check if parent 3 levels up is wayang-platform
          final candidateRoot = current.parent.parent.parent;
          if (Directory('${candidateRoot.path}/Families').existsSync()) {
            _cachedWorkspaceRoot = candidateRoot.path;
            return candidateRoot.path;
          }
        }

        if (current.parent.path == current.path) break;
        current = current.parent;
      }
    }

    // 3. Fallback dynamically relative to user's home directory
    final home = homeDir;
    if (home.isNotEmpty) {
      final commonRelativePaths = [
        '$home/Workspace/workkayys/Products/Wayang/wayang-platform',
        '$home/Workspace/Wayang/wayang-platform',
        '$home/Workspace/wayang-platform',
        '$home/Projects/wayang-platform',
        '$home/wayang-platform',
      ];
      for (final p in commonRelativePaths) {
        if (Directory(p).existsSync()) {
          _cachedWorkspaceRoot = p;
          return p;
        }
      }
    }

    return Directory.current.absolute.path;
  }

  static String resolveAljabrApiDir() {
    final root = resolveWorkspaceRoot();
    final candidates = [
      '$root/Wayang-Projects/Wayang-Agents/Aljabr/Backend/aljabr-api',
      '$root/Wayang-Agents/Aljabr/Backend/aljabr-api',
      '$root/Backend/aljabr-api',
      '$root/aljabr-api',
      '${Directory.current.path}/../Backend/aljabr-api',
    ];

    for (final c in candidates) {
      if (Directory(c).existsSync()) return Directory(c).absolute.path;
    }
    return candidates.first;
  }

  static String resolveGollekDir() {
    final root = resolveWorkspaceRoot();
    final candidates = [
      '$root/Families/gollek',
      '$root/gollek',
      '${Directory.current.path}/../../../../Families/gollek',
    ];

    for (final c in candidates) {
      if (Directory(c).existsSync()) return Directory(c).absolute.path;
    }
    return candidates.first;
  }
}

class BackendProcessNotifier extends Notifier<BackendState> {
  Process? _aljabrProcess;
  Process? _gollekProcess;
  @override
  BackendState build() {
    // Register frontend UI logger stream
    registerFrontendLogListener((level, message, formattedLine) {
      _appendLog('[$level] $message', ServerType.frontend);
    });

    // Populate initial logs with existing recent frontend logs
    final recent = getRecentFrontendLogs();
    final initialFrontendLogs = List<String>.from(recent);
    final initialLogs = List<String>.from(recent);

    final initialState = BackendState(
      frontend: _defaultFrontend.copyWith(logs: initialFrontendLogs),
      logs: initialLogs,
    );

    // Probe backends on startup so providers can fetch immediately
    Future.microtask(probeServers);
    return initialState;
  }

  /// Automatically probe port listeners to detect if backends are already running.
  Future<void> probeServers() async {
    try {
      // 1. Probe Aljabr (port 8085 / 9000)
      final aljabrRunning =
          await _isPortListening(8085) || await _isPortListening(9000);
      if (aljabrRunning && state.aljabr.status != BackendStatus.running) {
        state = state.copyWith(
          aljabr: state.aljabr.copyWith(
            status: BackendStatus.running,
            startedAt: state.aljabr.startedAt ?? DateTime.now(),
          ),
        );
        _appendLog('ℹ️ [Aljabr] Online and listening on HTTP 8085 / gRPC 9000',
            ServerType.aljabr);
      } else if (!aljabrRunning &&
          state.aljabr.status == BackendStatus.running &&
          _aljabrProcess == null) {
        state = state.copyWith(
          aljabr:
              state.aljabr.copyWith(status: BackendStatus.stopped, pid: null),
        );
      }

      // 2. Probe Gollek (gRPC 9131 / HTTP 8080 / 8082)
      final gollekRunning = await _isPortListening(9131) ||
          await _isPortListening(8080) ||
          await _isPortListening(8082);
      if (gollekRunning && state.gollek.status != BackendStatus.running) {
        state = state.copyWith(
          gollek: state.gollek.copyWith(
            status: BackendStatus.running,
            startedAt: state.gollek.startedAt ?? DateTime.now(),
          ),
        );
        _appendLog('ℹ️ [Gollek] Online and listening on gRPC 9131 / HTTP 8080',
            ServerType.gollek);
      } else if (!gollekRunning &&
          state.gollek.status == BackendStatus.running &&
          _gollekProcess == null) {
        state = state.copyWith(
          gollek:
              state.gollek.copyWith(status: BackendStatus.stopped, pid: null),
        );
      }
    } catch (_) {}
  }

  Future<bool> _isPortListening(int port) async {
    try {
      final res = await Process.run(
        'sh',
        ['-c', 'lsof -n -P -tiTCP:$port -sTCP:LISTEN 2>/dev/null'],
      );
      return res.stdout.toString().trim().isNotEmpty;
    } catch (_) {
      try {
        final socket = await Socket.connect('127.0.0.1', port,
            timeout: const Duration(milliseconds: 300));
        socket.destroy();
        return true;
      } catch (_) {
        return false;
      }
    }
  }

  // ── Aljabr Service Controls ───────────────────────────────────────────────

  Future<void> startAljabr() async {
    if (_aljabrProcess != null ||
        state.aljabr.status == BackendStatus.running) {
      return;
    }

    state = state.copyWith(
      aljabr: state.aljabr.copyWith(status: BackendStatus.starting, logs: []),
    );
    _appendLog(
        '🚀 Launching Aljabr Agent & Substrate Backend...', ServerType.aljabr);

    try {
      final aljabrDir = DynamicPathResolver.resolveAljabrApiDir();
      final scriptFile = File('$aljabrDir/start-local.sh');

      String executable;
      List<String> arguments;

      if (scriptFile.existsSync()) {
        executable = '/bin/bash';
        arguments = [scriptFile.path];
      } else {
        executable = 'mvn';
        arguments = ['quarkus:dev', '-o', '-Dquarkus.http.port=8085'];
      }

      _appendLog('• Working Directory: $aljabrDir', ServerType.aljabr);
      _appendLog(
          '• Command: $executable ${arguments.join(' ')}', ServerType.aljabr);

      final env = _buildEnvironment();

      _aljabrProcess = await Process.start(
        executable,
        arguments,
        workingDirectory: aljabrDir,
        environment: env,
      );

      final pid = _aljabrProcess!.pid;
      state = state.copyWith(
        aljabr: state.aljabr.copyWith(
          pid: pid,
          startedAt: DateTime.now(),
        ),
      );

      _aljabrProcess!.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        _appendLog(line, ServerType.aljabr);
        if (state.aljabr.status == BackendStatus.starting &&
            (line.contains('Listening on: http://localhost:8085') ||
                line.contains('Installed features:'))) {
          state = state.copyWith(
            aljabr: state.aljabr.copyWith(status: BackendStatus.running),
          );
        }
      });

      _aljabrProcess!.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        _appendLog(line, ServerType.aljabr);
      });

      _aljabrProcess!.exitCode.then((code) {
        _aljabrProcess = null;
        _appendLog(
            'Aljabr backend process exited with code $code', ServerType.aljabr);
        if (code != 0 && code != 143) {
          state = state.copyWith(
            aljabr: state.aljabr.copyWith(
              status: BackendStatus.error,
              lastError: 'Exited with code $code',
              pid: null,
            ),
          );
        } else {
          state = state.copyWith(
            aljabr: state.aljabr.copyWith(
              status: BackendStatus.stopped,
              pid: null,
            ),
          );
        }
      });
    } catch (e, stack) {
      _aljabrProcess = null;
      _appendLog(
          '❌ Failed to start Aljabr backend: $e\n$stack', ServerType.aljabr);
      state = state.copyWith(
        aljabr: state.aljabr.copyWith(
          status: BackendStatus.error,
          lastError: e.toString(),
          pid: null,
        ),
      );
    }
  }

  Future<void> stopAljabr() async {
    _appendLog(
        '🛑 Stopping Aljabr Agent & Substrate Backend...', ServerType.aljabr);
    if (_aljabrProcess != null) {
      _aljabrProcess!.kill();
      _aljabrProcess = null;
    }
    // Cleanly kill any lingering process on Aljabr ports (8085, 9000)
    try {
      await Process.run('sh', [
        '-c',
        'lsof -n -P -tiTCP:8085,9000 -sTCP:LISTEN | xargs kill -9 2>/dev/null'
      ]);
    } catch (_) {}
    state = state.copyWith(
      aljabr: state.aljabr.copyWith(status: BackendStatus.stopped, pid: null),
    );
  }

  Future<void> restartAljabr() async {
    await stopAljabr();
    await Future.delayed(const Duration(milliseconds: 500));
    await startAljabr();
  }

  // ── Gollek Service Controls ───────────────────────────────────────────────

  Future<void> startGollek() async {
    if (_gollekProcess != null ||
        state.gollek.status == BackendStatus.running) {
      return;
    }

    state = state.copyWith(
      gollek: state.gollek.copyWith(status: BackendStatus.starting, logs: []),
    );
    _appendLog('🧠 Launching Gollek Inference Server...', ServerType.gollek);

    try {
      final root = DynamicPathResolver.resolveWorkspaceRoot();
      final gollekDir = DynamicPathResolver.resolveGollekDir();
      final scriptFile = File(
          '$root/Wayang-Projects/Wayang-Agents/Aljabr/Backend/start-gollek.sh');

      String executable;
      List<String> arguments;
      String workDir;

      if (scriptFile.existsSync()) {
        // Preferred: delegate to the official start-gollek.sh launcher
        executable = '/bin/bash';
        arguments = [scriptFile.path];
        workDir = scriptFile.parent.path;
      } else {
        // Fallback: run the pre-built gollek.jar directly with `serve --rest --port=8080`
        final jarFile = File('$gollekDir/ui/gollek-cli/build/gollek.jar');
        if (jarFile.existsSync()) {
          executable = 'java';
          arguments = [
            '--enable-native-access=ALL-UNNAMED',
            '--add-modules=jdk.incubator.vector',
            '-XX:MaxDirectMemorySize=24g',
            '-jar',
            jarFile.path,
            'serve',
            '--rest',
            '--port=8080',
            '--enable-cpu',
          ];
          workDir = gollekDir;
        } else if (File('$gollekDir/gradlew').existsSync()) {
          executable = './gradlew';
          arguments = [':ui:gollek-cli:quarkusDev', '--console=plain'];
          workDir = gollekDir;
        } else {
          _appendLog(
              '❌ Gollek: no start-gollek.sh, no gollek.jar, no gradlew found.',
              ServerType.gollek);
          _appendLog(
              '   Please build Gollek first: cd Families/gollek && ./scripts/build-gollek.sh',
              ServerType.gollek);
          return;
        }
      }

      _appendLog('• Working Directory: $workDir', ServerType.gollek);
      _appendLog(
          '• Command: $executable ${arguments.join(' ')}', ServerType.gollek);

      final env = _buildEnvironment();

      _gollekProcess = await Process.start(
        executable,
        arguments,
        workingDirectory: workDir,
        environment: env,
      );

      final pid = _gollekProcess!.pid;
      state = state.copyWith(
        gollek: state.gollek.copyWith(
          pid: pid,
          startedAt: DateTime.now(),
        ),
      );

      _gollekProcess!.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        _appendLog(line, ServerType.gollek);
        if (state.gollek.status == BackendStatus.starting &&
            (line.contains('8080') ||
                line.contains('Listening') ||
                line.contains('Started') ||
                line.contains('Serving HTTP'))) {
          state = state.copyWith(
            gollek: state.gollek.copyWith(status: BackendStatus.running),
          );
        }
      });

      _gollekProcess!.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        _appendLog(line, ServerType.gollek);
      });

      _gollekProcess!.exitCode.then((code) {
        _gollekProcess = null;
        _appendLog('Gollek inference process exited with code $code',
            ServerType.gollek);
        if (code != 0 && code != 143) {
          state = state.copyWith(
            gollek: state.gollek.copyWith(
              status: BackendStatus.error,
              lastError: 'Exited with code $code',
              pid: null,
            ),
          );
        } else {
          state = state.copyWith(
            gollek: state.gollek.copyWith(
              status: BackendStatus.stopped,
              pid: null,
            ),
          );
        }
      });
    } catch (e, stack) {
      _gollekProcess = null;
      _appendLog(
          '❌ Failed to start Gollek server: $e\n$stack', ServerType.gollek);
      state = state.copyWith(
        gollek: state.gollek.copyWith(
          status: BackendStatus.error,
          lastError: e.toString(),
          pid: null,
        ),
      );
    }
  }

  Future<void> stopGollek() async {
    _appendLog('🛑 Stopping Gollek Inference Server...', ServerType.gollek);
    if (_gollekProcess != null) {
      _gollekProcess!.kill();
      _gollekProcess = null;
    }
    try {
      await Process.run('sh', [
        '-c',
        'lsof -n -P -tiTCP:8080,8082,9090 -sTCP:LISTEN | xargs kill -9 2>/dev/null'
      ]);
    } catch (_) {}
    state = state.copyWith(
      gollek: state.gollek.copyWith(status: BackendStatus.stopped, pid: null),
    );
  }

  Future<void> restartGollek() async {
    await stopGollek();
    await Future.delayed(const Duration(milliseconds: 500));
    await startGollek();
  }

  // ── Master Controls (Ordered Boot Sequence) ──────────────────────────────

  /// Starts backends in strict dependency order: Gollek (Inference) -> Aljabr (Platform).
  Future<void> startAll() async {
    _appendLog('⚙️ Initiating ordered dual-backend startup sequence...', null);

    // Step 1: Boot Gollek Inference Server
    if (state.gollek.status != BackendStatus.running) {
      _appendLog('▶️ [Step 1/2] Starting Gollek Inference Substrate (:8080)...',
          ServerType.gollek);
      await startGollek();

      // Give Gollek a brief grace window to bind socket
      for (int i = 0; i < 20; i++) {
        if (state.gollek.status == BackendStatus.running ||
            await _isPortListening(8080) ||
            await _isPortListening(8082)) {
          _appendLog('✅ Gollek Inference Engine is active and ready.',
              ServerType.gollek);
          break;
        }
        await Future.delayed(const Duration(milliseconds: 250));
      }
    }

    // Step 2: Boot Aljabr Agent & Substrate Backend
    if (state.aljabr.status != BackendStatus.running) {
      _appendLog(
          '▶️ [Step 2/2] Starting Aljabr Agent Platform (:8085 / :9000)...',
          ServerType.aljabr);
      await startAljabr();
    }
  }

  Future<void> stopAll() async {
    _appendLog('🛑 Stopping all active backend services...', null);
    await Future.wait([stopAljabr(), stopGollek()]);
  }

  /// Backward-compatible alias for existing callers
  Future<void> startBackend() => startAll();

  /// Backward-compatible alias for existing callers
  Future<void> stopBackend() => stopAll();

  // ── Tab & Log Management ──────────────────────────────────────────────────

  void setActiveLogTab(String tab) {
    state = state.copyWith(activeLogTab: tab);
  }

  void clearLogs([ServerType? type]) {
    if (type == null) {
      state = state.copyWith(
        logs: [],
        aljabr: state.aljabr.copyWith(logs: []),
        gollek: state.gollek.copyWith(logs: []),
        frontend: state.frontend.copyWith(logs: []),
      );
    } else if (type == ServerType.aljabr) {
      state = state.copyWith(
        aljabr: state.aljabr.copyWith(logs: []),
      );
    } else if (type == ServerType.gollek) {
      state = state.copyWith(
        gollek: state.gollek.copyWith(logs: []),
      );
    } else if (type == ServerType.frontend) {
      state = state.copyWith(
        frontend: state.frontend.copyWith(logs: []),
      );
    }
  }

  Map<String, String> _buildEnvironment() {
    final home = DynamicPathResolver.homeDir;
    final path = Platform.environment['PATH'] ??
        '/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin';
    return {
      'HOME': home,
      'USER': Platform.environment['USER'] ?? 'user',
      'PATH': path,
      if (Platform.environment['JAVA_HOME'] != null)
        'JAVA_HOME': Platform.environment['JAVA_HOME']!,
    };
  }

  void _appendLog(String text, ServerType? origin) {
    final lines = text.split('\n');
    for (final rawLine in lines) {
      if (rawLine.trim().isEmpty) continue;
      String prefix;
      if (origin == ServerType.aljabr) {
        prefix = 'Aljabr';
      } else if (origin == ServerType.gollek) {
        prefix = 'Gollek';
      } else if (origin == ServerType.frontend) {
        prefix = 'Aljabr UI';
      } else {
        prefix = '';
      }

      final formattedLine = origin != null ? '[$prefix] $rawLine' : rawLine;

      logRaw(formattedLine);
      LogFileService.logServer(formattedLine);

      // Add to unified logs (capped at 1500 lines)
      final newLogs = List<String>.from(state.logs)..add(formattedLine);
      if (newLogs.length > 1500) {
        newLogs.removeRange(0, newLogs.length - 1500);
      }

      SingleServerState? updatedAljabr;
      SingleServerState? updatedGollek;
      SingleServerState? updatedFrontend;

      if (origin == ServerType.aljabr) {
        final aljabrLogs = List<String>.from(state.aljabr.logs)..add(rawLine);
        if (aljabrLogs.length > 1000) {
          aljabrLogs.removeRange(0, aljabrLogs.length - 1000);
        }
        updatedAljabr = state.aljabr.copyWith(logs: aljabrLogs);
      } else if (origin == ServerType.gollek) {
        final gollekLogs = List<String>.from(state.gollek.logs)..add(rawLine);
        if (gollekLogs.length > 1000) {
          gollekLogs.removeRange(0, gollekLogs.length - 1000);
        }
        updatedGollek = state.gollek.copyWith(logs: gollekLogs);
      } else if (origin == ServerType.frontend) {
        final frontendLogs = List<String>.from(state.frontend.logs)
          ..add(rawLine);
        if (frontendLogs.length > 1000) {
          frontendLogs.removeRange(0, frontendLogs.length - 1000);
        }
        updatedFrontend = state.frontend.copyWith(logs: frontendLogs);
      }

      state = state.copyWith(
        logs: newLogs,
        aljabr: updatedAljabr,
        gollek: updatedGollek,
        frontend: updatedFrontend,
      );
    }
  }
}

final backendProcessProvider =
    NotifierProvider<BackendProcessNotifier, BackendState>(
  () => BackendProcessNotifier(),
);
