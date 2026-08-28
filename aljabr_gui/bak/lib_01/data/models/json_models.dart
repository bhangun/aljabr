// ── FileReference ─────────────────────────────────────────────────────────────

import '../../core/entities/app_settings.dart';
import '../../features/chat/models/file_diff.dart';
import '../../features/chat/models/file_reference.dart';
import '../../features/chat/models/message.dart';
import '../../features/chat/models/session.dart';
import '../../features/chat/models/prompt_snippet.dart';
import '../../features/chat/models/project.dart';

// ── Project ───────────────────────────────────────────────────────────────────

extension ProjectJson on Project {
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'path': path,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}

Project projectFromJson(Map<String, dynamic> j) => Project(
  id: j['id'] as String,
  name: j['name'] as String,
  path: j['path'] as String?,
  createdAt: DateTime.parse(j['createdAt'] as String),
  updatedAt: DateTime.parse(j['updatedAt'] as String),
);

extension FileReferenceJson on FileReference {
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'path': path,
    'content': content,
    'language': language,
  };
}

FileReference fileReferenceFromJson(Map<String, dynamic> j) => FileReference(
  id: j['id'] as String,
  name: j['name'] as String,
  path: j['path'] as String,
  content: j['content'] as String,
  language: j['language'] as String? ?? '',
);

// ── DiffLine ──────────────────────────────────────────────────────────────────

extension DiffLineJson on DiffLine {
  Map<String, dynamic> toJson() => {
    'type': type.name,
    'content': content,
    'oldLineNumber': oldLineNumber,
    'newLineNumber': newLineNumber,
  };
}

DiffLine diffLineFromJson(Map<String, dynamic> j) => DiffLine(
  type: DiffLineType.values.firstWhere((e) => e.name == j['type']),
  content: j['content'] as String,
  oldLineNumber: j['oldLineNumber'] as int?,
  newLineNumber: j['newLineNumber'] as int?,
);

// ── FileDiff ──────────────────────────────────────────────────────────────────

extension FileDiffJson on FileDiff {
  Map<String, dynamic> toJson() => {
    'fileId': fileId,
    'fileName': fileName,
    'originalContent': originalContent,
    'modifiedContent': modifiedContent,
    'lines': lines.map((l) => l.toJson()).toList(),
    'addedLines': addedLines,
    'removedLines': removedLines,
  };
}

FileDiff fileDiffFromJson(Map<String, dynamic> j) => FileDiff(
  fileId: j['fileId'] as String,
  fileName: j['fileName'] as String,
  originalContent: j['originalContent'] as String,
  modifiedContent: j['modifiedContent'] as String,
  lines: (j['lines'] as List)
      .map((e) => diffLineFromJson(e as Map<String, dynamic>))
      .toList(),
  addedLines: j['addedLines'] as int,
  removedLines: j['removedLines'] as int,
);

// ── Message ───────────────────────────────────────────────────────────────────

extension MessageJson on Message {
  Map<String, dynamic> toJson() => {
    'id': id,
    'role': role.name,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
    'attachedFiles': attachedFiles.map((f) => f.toJson()).toList(),
    'diffs': diffs.map((d) => d.toJson()).toList(),
    'hasError': hasError,
    'errorMessage': errorMessage,
    'tokenCount': tokenCount,
    'wasEdited': wasEdited,
  };
}

Message messageFromJson(Map<String, dynamic> j) => Message(
  id: j['id'] as String,
  role: MessageRole.values.firstWhere((e) => e.name == j['role']),
  content: j['content'] as String,
  createdAt: DateTime.parse(j['createdAt'] as String),
  attachedFiles: (j['attachedFiles'] as List? ?? [])
      .map((e) => fileReferenceFromJson(e as Map<String, dynamic>))
      .toList(),
  diffs: (j['diffs'] as List? ?? [])
      .map((e) => fileDiffFromJson(e as Map<String, dynamic>))
      .toList(),
  hasError: j['hasError'] as bool? ?? false,
  errorMessage: j['errorMessage'] as String?,
  tokenCount: j['tokenCount'] as int?,
  wasEdited: j['wasEdited'] as bool? ?? false,
);

// ── Session ───────────────────────────────────────────────────────────────────

extension SessionJson on Session {
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'messages': messages.map((m) => m.toJson()).toList(),
    'files': files.map((f) => f.toJson()).toList(),
    'systemPrompt': systemPrompt,
    'isPinned': isPinned,
    'tags': tags,
    'projectId': projectId,
  };
}

Session sessionFromJson(Map<String, dynamic> j) => Session(
  id: j['id'] as String,
  title: j['title'] as String,
  createdAt: DateTime.parse(j['createdAt'] as String),
  updatedAt: DateTime.parse(j['updatedAt'] as String),
  messages: (j['messages'] as List? ?? [])
      .map((e) => messageFromJson(e as Map<String, dynamic>))
      .toList(),
  files: (j['files'] as List? ?? [])
      .map((e) => fileReferenceFromJson(e as Map<String, dynamic>))
      .toList(),
  systemPrompt: j['systemPrompt'] as String?,
  isPinned: j['isPinned'] as bool? ?? false,
  tags: (j['tags'] as List? ?? []).cast<String>(),
  projectId: j['projectId'] as String?,
);

// ── PromptSnippet ─────────────────────────────────────────────────────────────

extension PromptSnippetJson on PromptSnippet {
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'shortcut': shortcut,
  };
}

PromptSnippet promptSnippetFromJson(Map<String, dynamic> j) => PromptSnippet(
  id: j['id'] as String,
  title: j['title'] as String,
  content: j['content'] as String,
  shortcut: j['shortcut'] as String?,
);

// ── Export bundle (single session → portable JSON) ────────────────────────────

Map<String, dynamic> sessionExportBundle(Session session) => {
  'format': 'codex-agent-session-export',
  'formatVersion': 1,
  'exportedAt': DateTime.now().toIso8601String(),
  'session': session.toJson(),
};

Session sessionFromExportBundle(Map<String, dynamic> bundle) {
  final sessionJson = bundle['session'] as Map<String, dynamic>;
  return sessionFromJson(sessionJson);
}

// ── AppSettings ───────────────────────────────────────────────────────────────

extension AppSettingsJson on AppSettings {
  Map<String, dynamic> toJson() => {
    'provider': provider.name,
    'wayangProBaseUrl': wayangProBaseUrl,
    'apiKey': apiKey,
    'model': model,
    'maxTokens': maxTokens,
    'systemPrompt': systemPrompt,
    'streamingEnabled': streamingEnabled,
    'fontSize': fontSize,
    'tabSize': tabSize,
  };
}

AppSettings appSettingsFromJson(Map<String, dynamic> j) => AppSettings(
  provider: j['provider'] != null 
      ? AiProvider.values.firstWhere((e) => e.name == j['provider'], orElse: () => AiProvider.claude)
      : AiProvider.claude,
  wayangProBaseUrl: j['wayangProBaseUrl'] as String? ?? 'http://localhost:8080',
  apiKey: j['apiKey'] as String? ?? '',
  model: j['model'] as String? ?? 'claude-sonnet-4-6',
  maxTokens: j['maxTokens'] as int? ?? 8192,
  systemPrompt: j['systemPrompt'] as String? ?? AppSettings.defaultSystemPrompt,
  streamingEnabled: j['streamingEnabled'] as bool? ?? true,
  fontSize: (j['fontSize'] as num?)?.toDouble() ?? 13.0,
  tabSize: j['tabSize'] as int? ?? 2,
);
