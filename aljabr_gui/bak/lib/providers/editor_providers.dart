import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Which top-level view is showing on the right: source, diff, or terminal.
enum EditorPanelTab { code, diff, terminal }

class EditorPanelTabNotifier extends StateNotifier<EditorPanelTab> {
  EditorPanelTabNotifier() : super(EditorPanelTab.code);
  void select(EditorPanelTab tab) => state = tab;
}

final editorPanelTabProvider =
    StateNotifierProvider<EditorPanelTabNotifier, EditorPanelTab>(
  (ref) => EditorPanelTabNotifier(),
);

/// Open file tabs (like open buffers in an editor) + which one is active.
class OpenFilesNotifier extends StateNotifier<List<String>> {
  OpenFilesNotifier()
      : super(const [
          'src/main/resources/application.properties',
          'docker-compose.yml',
        ]);

  void open(String path) {
    if (!state.contains(path)) state = [...state, path];
  }

  void close(String path) {
    state = state.where((p) => p != path).toList();
  }
}

final openFilesProvider =
    StateNotifierProvider<OpenFilesNotifier, List<String>>(
  (ref) => OpenFilesNotifier(),
);

class ActiveFileNotifier extends StateNotifier<String> {
  ActiveFileNotifier() : super('src/main/resources/application.properties');
  void select(String path) => state = path;
}

final activeFileProvider = StateNotifierProvider<ActiveFileNotifier, String>(
  (ref) => ActiveFileNotifier(),
);

/// Rolling shell output for the Terminal tab.
class TerminalLogNotifier extends StateNotifier<List<String>> {
  TerminalLogNotifier()
      : super(const [
          r'$ docker compose up -d postgres redis',
          ' ✔ Container wayang-postgres  Started',
          ' ✔ Container wayang-redis     Started',
          r'$ mvn quarkus:dev -Dquarkus.http.port=8086',
          '[INFO] Scanning for projects...',
          '[INFO] Building wayang-platform-api 1.0.0-SNAPSHOT',
          '[INFO] Listening for transport dt_socket at address: 5005',
          '__________  __  __  ___',
          '--/ __ \\/ / / / / _ \\  Quarkus dev mode',
          'INFO  [io.quarkus] Profile dev activated. Live Coding activated.',
        ]);

  void append(String line) => state = [...state, line];
}

final terminalLogProvider =
    StateNotifierProvider<TerminalLogNotifier, List<String>>(
  (ref) => TerminalLogNotifier(),
);

/// Raw source per file, keyed by path — real content for every file the
/// explorer lists, rendered through [SyntaxHighlighter] via [CodeLine].
final Map<String, List<String>> sampleFileContents = {
  'src/main/resources/application.properties': const [
    '# ==============================================',
    '# Wayang Pro API - Application Configuration',
    '# ==============================================',
    '',
    '# --- Gollek / Gamelan required config stubs ---',
    '# Override via environment variables in production.',
    r'gamelan.embedding.openai.api-key=${GAMELAN_OPENAI_API_KEY:dummy-key}',
    r'gollek.rag.default-llm-model=${GOLLEK_RAG_LLM_MODEL:dummy-model}',
    r'gollek.rag.default-embedding-model=${GOLLEK_RAG_EMBEDDING_MODEL:dummy-model}',
    r'gollek.audio.whisper.default-model=${GOLLEK_WHISPER_MODEL:dummy-model}',
    r'gollek.hub.token=${GOLLEK_HUB_TOKEN:dummy-token}',
    r'gollek.admin.api-key=${GOLLEK_ADMIN_API_KEY:dummy-key}',
    r'secret.master-key=${SECRET_MASTER_KEY:dummy-key}',
    '',
    '# --- Datasource / ORM ---',
    '# Connects to docker-compose PostgreSQL',
    'quarkus.datasource.db-kind=postgresql',
    'quarkus.datasource.username=wayang',
    'quarkus.datasource.password=wayang_dev',
    'quarkus.datasource.jdbc.url=jdbc:postgresql://localhost/wayang',
    'quarkus.hibernate-orm.database.generation=none',
    'quarkus.hibernate-orm.mapping.format.global=ignore',
    '',
    '# --- Flyway ---',
    'quarkus.flyway.migrate-at-start=true',
    'quarkus.flyway.locations=classpath:db/migration',
    '',
    '# --- Redis ---',
    'quarkus.redis.hosts=redis://localhost:6379',
    '',
    '# --- Dev Services ---',
    'quarkus.devservices.enabled=false',
  ],
  'docker-compose.yml': const [
    'services:',
    '  postgres:',
    '    image: postgres:16-alpine',
    '    ports: ["5433:5432"]',
    '    environment:',
    '      POSTGRES_DB: wayang',
    '      POSTGRES_USER: wayang',
    '      POSTGRES_PASSWORD: wayang_dev',
    '',
    '  redis:',
    '    image: redis:7-alpine',
    '    ports: ["6379:6379"]',
  ],
  'src/main/resources/db/migration/V2__add_index.sql': const [
    '-- Speeds up session lookups by project',
    'CREATE INDEX idx_sessions_project_id',
    '  ON sessions (project_id);',
  ],
  'src/main/resources/db/migration/V1__init.sql': const [
    '-- Initial schema',
    'CREATE TABLE sessions (',
    "  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),",
    '  project_id UUID NOT NULL,',
    "  title TEXT NOT NULL,",
    "  status TEXT NOT NULL DEFAULT 'queued',",
    '  created_at TIMESTAMP NOT NULL DEFAULT now()',
    ');',
  ],
  'src/main/java/com/wayang/SessionResource.java': const [
    'package com.wayang;',
    '',
    'import jakarta.ws.rs.GET;',
    'import jakarta.ws.rs.Path;',
    '',
    '@Path("/sessions")',
    'public class SessionResource {',
    '',
    '    private final GollekService gollek;',
    '',
    '    public SessionResource(GollekService gollek) {',
    '        this.gollek = gollek;',
    '    }',
    '',
    '    @GET',
    '    public String list() {',
    '        // TODO: paginate this once we have real volume',
    '        return gollek.listSessions();',
    '    }',
    '}',
  ],
  'src/main/java/com/wayang/GollekService.java': const [
    'package com.wayang;',
    '',
    'public class GollekService {',
    '',
    '    private final String ragModel;',
    '',
    '    public GollekService(String ragModel) {',
    '        this.ragModel = ragModel;',
    '    }',
    '',
    '    public String listSessions() {',
    '        return "[]"; // stub until the repository layer lands',
    '    }',
    '}',
  ],
  'README.md': const [
    '# wayang-platform',
    '',
    'Backend services for the Wayang agent platform.',
    '',
    '## Getting started',
    '',
    '```bash',
    'docker compose up -d',
    'mvn quarkus:dev',
    '```',
  ],
  'pom.xml': const [
    '<project>',
    '  <groupId>com.wayang</groupId>',
    '  <artifactId>wayang-platform-api</artifactId>',
    '  <version>1.0.0-SNAPSHOT</version>',
    '</project>',
  ],
};

/// Zero-indexed line numbers to visually flag as "recently changed" per
/// file, used to highlight the exact line the agent edited.
final Map<String, Set<int>> highlightedLineIndexes = {
  'src/main/resources/application.properties': {21},
  'docker-compose.yml': {3},
};
