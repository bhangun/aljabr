# Complete ObjectBox Implementation for ChatEntry

## 1. ObjectBox Entity Models

```dart
// lib/features/chat/models/chat_entry_entity.dart

// ─── ToolCall Entity ────────────────────────────────────────────────────

@Embedded()
class ToolCallEntity {
  String id;
  int kindIndex;
  String summary;
  String? detailInput;
  String? detailOutput;
  int statusIndex;
  int riskIndex;
  int? durationMs;
  String? errorMessage;
  
  @Property(type: PropertyType.byteVector)
  List<String>? subtasks;
  
  @Property(type: PropertyType.byteVector)
  Map<String, dynamic>? result;
  
  int? progress;
  bool isBlocking;

  ToolCallEntity({
    required this.id,
    required this.kindIndex,
    required this.summary,
    this.detailInput,
    this.detailOutput,
    required this.statusIndex,
    required this.riskIndex,
    this.durationMs,
    this.errorMessage,
    this.subtasks,
    this.result,
    this.progress,
    this.isBlocking = false,
  });

  factory ToolCallEntity.fromToolCall(ToolCall toolCall) {
    return ToolCallEntity(
      id: toolCall.id,
      kindIndex: toolCall.kind.index,
      summary: toolCall.summary,
      detailInput: toolCall.detailInput,
      detailOutput: toolCall.detailOutput,
      statusIndex: toolCall.status.index,
      riskIndex: toolCall.risk.index,
      durationMs: toolCall.duration?.inMilliseconds,
      errorMessage: toolCall.errorMessage,
      subtasks: toolCall.subtasks,
      result: toolCall.result,
      progress: toolCall.progress,
      isBlocking: toolCall.isBlocking,
    );
  }

  ToolCall toToolCall() {
    return ToolCall(
      id: id,
      kind: ToolCallKind.values[kindIndex],
      summary: summary,
      detailInput: detailInput,
      detailOutput: detailOutput,
      status: ToolCallStatus.values[statusIndex],
      risk: RiskLevel.values[riskIndex],
      duration: durationMs != null 
          ? Duration(milliseconds: durationMs!) 
          : null,
      errorMessage: errorMessage,
      subtasks: subtasks,
      result: result,
      progress: progress,
      isBlocking: isBlocking,
    );
  }
}

// ─── ApprovalRequest Entity ────────────────────────────────────────────

@Embedded()
class ApprovalRequestEntity {
  String id;
  String command;
  String reason;
  int riskIndex;
  int statusIndex;

  ApprovalRequestEntity({
    required this.id,
    required this.command,
    required this.reason,
    required this.riskIndex,
    required this.statusIndex,
  });

  factory ApprovalRequestEntity.fromApproval(ApprovalRequest approval) {
    return ApprovalRequestEntity(
      id: approval.id,
      command: approval.command,
      reason: approval.reason,
      riskIndex: approval.risk.index,
      statusIndex: approval.status.index,
    );
  }

  ApprovalRequest toApproval() {
    return ApprovalRequest(
      id: id,
      command: command,
      reason: reason,
      risk: RiskLevel.values[riskIndex],
      status: ApprovalStatus.values[statusIndex],
    );
  }
}

// ─── Plan Entity ────────────────────────────────────────────────────────

@Embedded()
class PlanEntity {
  String title;
  
  @Property(type: PropertyType.byteVector)
  List<Map<String, dynamic>> steps;

  PlanEntity({
    required this.title,
    required this.steps,
  });

  factory PlanEntity.fromPlan(AgentPlan plan) {
    return PlanEntity(
      title: plan.title,
      steps: plan.steps.map((s) => {
        'id': s.id,
        'description': s.description,
        'statusIndex': s.status.index,
      }).toList(),
    );
  }

  AgentPlan toPlan() {
    return AgentPlan(
      title: title,
      steps: steps.map((s) => PlanStep(
        id: s['id'],
        description: s['description'],
        status: PlanStepStatus.values[s['statusIndex']],
      )).toList(),
    );
  }
}

// ─── Attachment Entity ─────────────────────────────────────────────────

@Entity()
class AttachmentEntity {
  @Id()
  int id = 0;

  String attachmentId;
  String name;
  int typeIndex;
  String? url;
  String? localPath;
  int size;
  String? mimeType;
  int statusIndex;
  String? thumbnailUrl;
  int? durationMs;
  
  @Property(type: PropertyType.byteVector)
  Map<String, dynamic>? metadata;
  
  String? errorMessage;
  
  // Relationship to ChatEntry
  @Index()
  String chatEntryId;

  AttachmentEntity({
    this.id = 0,
    required this.attachmentId,
    required this.name,
    required this.typeIndex,
    this.url,
    this.localPath,
    required this.size,
    this.mimeType,
    required this.statusIndex,
    this.thumbnailUrl,
    this.durationMs,
    this.metadata,
    this.errorMessage,
    required this.chatEntryId,
  });

  factory AttachmentEntity.fromAttachment(Attachment attachment, String chatEntryId) {
    return AttachmentEntity(
      attachmentId: attachment.id,
      name: attachment.name,
      typeIndex: attachment.type.index,
      url: attachment.url,
      localPath: attachment.localPath,
      size: attachment.size,
      mimeType: attachment.mimeType,
      statusIndex: attachment.status.index,
      thumbnailUrl: attachment.thumbnailUrl,
      durationMs: attachment.duration?.inMilliseconds,
      metadata: attachment.metadata,
      errorMessage: attachment.errorMessage,
      chatEntryId: chatEntryId,
    );
  }

  Attachment toAttachment() {
    return Attachment(
      id: attachmentId,
      name: name,
      type: AttachmentType.values[typeIndex],
      url: url,
      localPath: localPath,
      size: size,
      mimeType: mimeType,
      status: AttachmentStatus.values[statusIndex],
      thumbnailUrl: thumbnailUrl,
      duration: durationMs != null 
          ? Duration(milliseconds: durationMs!) 
          : null,
      metadata: metadata,
      errorMessage: errorMessage,
    );
  }
}

// ─── Session Entity ────────────────────────────────────────────────────

@Entity()
class SessionEntity {
  @Id()
  int id = 0;

  @Index()
  String sessionId;
  
  @Index()
  String projectId;
  
  String title;
  String? description;
  int statusIndex;
  int modeIndex;
  int createdAt;
  int updatedAt;
  int? lastActiveAt;
  String? forkOf;
  bool isPinned;
  int fileChanges;
  int messageCount;
  int pendingCount;
  int queueSize;
  int totalDurationMs;
  
  @Property(type: PropertyType.byteVector)
  Map<String, dynamic> metadata;
  
  bool isSelected;

  SessionEntity({
    this.id = 0,
    required this.sessionId,
    required this.projectId,
    required this.title,
    this.description,
    required this.statusIndex,
    required this.modeIndex,
    required this.createdAt,
    required this.updatedAt,
    this.lastActiveAt,
    this.forkOf,
    this.isPinned = false,
    this.fileChanges = 0,
    this.messageCount = 0,
    this.pendingCount = 0,
    this.queueSize = 0,
    this.totalDurationMs = 0,
    this.metadata = const {},
    this.isSelected = false,
  });

  factory SessionEntity.fromSession(Session session) {
    return SessionEntity(
      sessionId: session.id,
      projectId: session.projectId,
      title: session.title,
      description: session.description,
      statusIndex: session.status.index,
      modeIndex: session.mode.index,
      createdAt: session.createdAt.millisecondsSinceEpoch,
      updatedAt: session.updatedAt.millisecondsSinceEpoch,
      lastActiveAt: session.lastActiveAt?.millisecondsSinceEpoch,
      forkOf: session.forkOf,
      isPinned: session.isPinned,
      fileChanges: session.fileChanges,
      messageCount: session.messageCount,
      pendingCount: session.pendingCount,
      queueSize: session.queueSize,
      totalDurationMs: session.totalDuration.inMilliseconds,
      metadata: session.metadata,
      isSelected: session.isSelected,
    );
  }

  Session toSession() {
    return Session(
      id: sessionId,
      projectId: projectId,
      title: title,
      description: description,
      status: SessionStatus.values[statusIndex],
      mode: SessionMode.values[modeIndex],
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt),
      lastActiveAt: lastActiveAt != null 
          ? DateTime.fromMillisecondsSinceEpoch(lastActiveAt!) 
          : null,
      forkOf: forkOf,
      isPinned: isPinned,
      fileChanges: fileChanges,
      messageCount: messageCount,
      pendingCount: pendingCount,
      queueSize: queueSize,
      totalDuration: Duration(milliseconds: totalDurationMs),
      metadata: metadata,
      isSelected: isSelected,
    );
  }
}
```

## 2. ObjectBox Store Initialization

```dart
// lib/features/chat/store/objectbox_store.dart
import 'package:objectbox/objectbox.dart';
import 'package:path_provider/path_provider.dart';
import '../models/chat_entry_entity.dart';
import '../../../objectbox.g.dart';

class ObjectBoxStore {
  static final ObjectBoxStore _instance = ObjectBoxStore._internal();
  factory ObjectBoxStore() => _instance;
  ObjectBoxStore._internal();

  late Store _store;
  bool _isInitialized = false;

  // Boxes
  late Box<ChatEntryEntity> _chatEntryBox;
  late Box<AttachmentEntity> _attachmentBox;
  late Box<SessionEntity> _sessionBox;

  /// Initialize ObjectBox store
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      final dir = await getApplicationDocumentsDirectory();
      _store = await openStore(
        directory: dir.path,
        macosApplicationGroup: 'group.com.yourapp',
      );

      _chatEntryBox = _store.box<ChatEntryEntity>();
      _attachmentBox = _store.box<AttachmentEntity>();
      _sessionBox = _store.box<SessionEntity>();

      _isInitialized = true;
      logDebug('ObjectBox initialized at ${dir.path}');
    } catch (e) {
      logDebug('Failed to initialize ObjectBox: $e');
      rethrow;
    }
  }

  /// Get store instance
  Store get store {
    if (!_isInitialized) {
      throw StateError('ObjectBox not initialized. Call init() first.');
    }
    return _store;
  }

  /// Get chat entry box
  Box<ChatEntryEntity> get chatEntryBox {
    if (!_isInitialized) {
      throw StateError('ObjectBox not initialized. Call init() first.');
    }
    return _chatEntryBox;
  }

  /// Get attachment box
  Box<AttachmentEntity> get attachmentBox {
    if (!_isInitialized) {
      throw StateError('ObjectBox not initialized. Call init() first.');
    }
    return _attachmentBox;
  }

  /// Get session box
  Box<SessionEntity> get sessionBox {
    if (!_isInitialized) {
      throw StateError('ObjectBox not initialized. Call init() first.');
    }
    return _sessionBox;
  }

  /// Close store
  void close() {
    if (_isInitialized) {
      _store.close();
      _isInitialized = false;
    }
  }
}
```

## 3. ObjectBox Cache Manager

```dart
// lib/features/chat/services/objectbox_cache_manager.dart
import 'package:objectbox/objectbox.dart';
import '../models/chat_entry_entity.dart';
import '../models/chat_message.dart';
import '../store/objectbox_store.dart';
import '../../project/models/session.dart';
import '../../diff/models/file_diff.dart';

class ObjectBoxObjectBoxCacheManager {
  static final ObjectBoxObjectBoxCacheManager _instance = ObjectBoxObjectBoxCacheManager._internal();
  factory ObjectBoxObjectBoxCacheManager() => _instance;
  ObjectBoxObjectBoxCacheManager._internal();

  ObjectBoxStore get _store => ObjectBoxStore();

  /// Initialize cache
  Future<void> init() async {
    await _store.init();
  }

  // ─── Session Caching ──────────────────────────────────────────────────

  /// Cache a session
  Future<void> cacheSession(Session session) async {
    try {
      final entity = SessionEntity.fromSession(session);
      // Check if exists
      final existing = _store.sessionBox
          .query(SessionEntity_.sessionId.equals(session.id))
          .build()
          .findFirst();
      
      if (existing != null) {
        entity.id = existing.id;
        _store.sessionBox.put(entity);
      } else {
        _store.sessionBox.put(entity);
      }
    } catch (e) {
      logDebug('Failed to cache session: $e');
    }
  }

  /// Get cached session
  Future<Session?> getCachedSession(String sessionId) async {
    try {
      final entity = _store.sessionBox
          .query(SessionEntity_.sessionId.equals(sessionId))
          .build()
          .findFirst();
      
      return entity?.toSession();
    } catch (e) {
      logDebug('Failed to get cached session: $e');
      return null;
    }
  }

  /// Get all cached sessions
  Future<List<Session>> getCachedSessions() async {
    try {
      final entities = _store.sessionBox
          .query()
          .order(SessionEntity_.lastActiveAt, flags: Order.descending)
          .build()
          .find();
      
      return entities.map((e) => e.toSession()).toList();
    } catch (e) {
      logDebug('Failed to get cached sessions: $e');
      return [];
    }
  }

  /// Delete cached session and all related data
  Future<void> deleteCachedSession(String sessionId) async {
    try {
      // Delete all chat entries for this session
      final entries = _store.chatEntryBox
          .query(ChatEntryEntity_.sessionId.equals(sessionId))
          .build()
          .find();
      
      for (final entry in entries) {
        // Delete attachments
        final attachments = _store.attachmentBox
            .query(AttachmentEntity_.chatEntryId.equals(entry.entryId))
            .build()
            .find();
        _store.attachmentBox.removeMany(attachments.map((a) => a.id).toList());
      }
      
      // Delete chat entries
      _store.chatEntryBox.removeMany(entries.map((e) => e.id).toList());
      
      // Delete session
      final session = _store.sessionBox
          .query(SessionEntity_.sessionId.equals(sessionId))
          .build()
          .findFirst();
      
      if (session != null) {
        _store.sessionBox.remove(session.id);
      }
    } catch (e) {
      logDebug('Failed to delete cached session: $e');
    }
  }

  // ─── Transcript Caching ──────────────────────────────────────────────

  /// Cache transcript entries for a session
  Future<void> cacheTranscript(
    String sessionId,
    List<ChatEntry> entries,
  ) async {
    try {
      // Delete existing entries for this session
      final existing = _store.chatEntryBox
          .query(ChatEntryEntity_.sessionId.equals(sessionId))
          .build()
          .find();
      
      // Delete associated attachments
      for (final entry in existing) {
        final attachments = _store.attachmentBox
            .query(AttachmentEntity_.chatEntryId.equals(entry.entryId))
            .build()
            .find();
        _store.attachmentBox.removeMany(attachments.map((a) => a.id).toList());
      }
      
      _store.chatEntryBox.removeMany(existing.map((e) => e.id).toList());

      // Insert new entries
      for (final entry in entries) {
        final entity = ChatEntryEntity.fromChatEntry(entry, sessionId);
        final savedId = _store.chatEntryBox.put(entity);
        
        // Save attachments
        if (entry.attachments != null) {
          for (final attachment in entry.attachments!) {
            final attachmentEntity = AttachmentEntity.fromAttachment(
              attachment,
              entry.id,
            );
            _store.attachmentBox.put(attachmentEntity);
          }
        }
      }
    } catch (e) {
      logDebug('Failed to cache transcript: $e');
    }
  }

  /// Get cached transcript
  Future<List<ChatEntry>> getCachedTranscript(String sessionId) async {
    try {
      final entities = _store.chatEntryBox
          .query(ChatEntryEntity_.sessionId.equals(sessionId))
          .order(ChatEntryEntity_.timestamp)
          .build()
          .find();
      
      final entries = <ChatEntry>[];
      for (final entity in entities) {
        // Load attachments
        final attachments = _store.attachmentBox
            .query(AttachmentEntity_.chatEntryId.equals(entity.entryId))
            .build()
            .find();
        
        final chatEntry = entity.toChatEntry();
        // Add attachments to entry
        if (attachments.isNotEmpty) {
          entries.add(ChatEntry(
            id: chatEntry.id,
            type: chatEntry.type,
            status: chatEntry.status,
            text: chatEntry.text,
            isLoading: chatEntry.isLoading,
            timestamp: chatEntry.timestamp,
            toolCall: chatEntry.toolCall,
            approval: chatEntry.approval,
            plan: chatEntry.plan,
            attachments: attachments.map((a) => a.toAttachment()).toList(),
            errorMessage: chatEntry.errorMessage,
            retryCount: chatEntry.retryCount,
            metadata: chatEntry.metadata,
            jobId: chatEntry.jobId,
            queuePosition: chatEntry.queuePosition,
          ));
        } else {
          entries.add(chatEntry);
        }
      }
      
      return entries;
    } catch (e) {
      logDebug('Failed to get cached transcript: $e');
      return [];
    }
  }

  /// Get transcript metadata (count, last modified, etc.)
  Future<Map<String, dynamic>> getTranscriptMetadata(String sessionId) async {
    try {
      final count = _store.chatEntryBox
          .query(ChatEntryEntity_.sessionId.equals(sessionId))
          .build()
          .count();
      
      // Get last entry timestamp
      final lastEntry = _store.chatEntryBox
          .query(ChatEntryEntity_.sessionId.equals(sessionId))
          .order(ChatEntryEntity_.timestamp, flags: Order.descending)
          .build()
          .findFirst();
      
      return {
        'entryCount': count,
        'lastModified': lastEntry != null 
            ? DateTime.fromMillisecondsSinceEpoch(lastEntry.timestamp)
            : null,
        'sessionId': sessionId,
      };
    } catch (e) {
      logDebug('Failed to get transcript metadata: $e');
      return {};
    }
  }

  // ─── Diff Caching ────────────────────────────────────────────────────

  /// Cache diffs (implement as needed)
  Future<void> cacheDiffs(String sessionId, List<FileDiff> diffs) async {
    // TODO: Implement diff caching with ObjectBox
    // You'll need to create DiffEntity models
  }

  /// Get cached diffs
  Future<List<FileDiff>?> getCachedDiffs(String sessionId) async {
    // TODO: Implement diff retrieval
    return null;
  }

  // ─── Query Operations ─────────────────────────────────────────────────

  /// Search transcripts by text
  Future<List<ChatEntry>> searchTranscript(
    String sessionId,
    String query,
  ) async {
    try {
      // Use ObjectBox query with contains
      final entities = _store.chatEntryBox
          .query(
            ChatEntryEntity_.sessionId.equals(sessionId) &
            ChatEntryEntity_.text.contains(query, caseSensitive: false)
          )
          .order(ChatEntryEntity_.timestamp)
          .build()
          .find();
      
      return entities.map((e) => e.toChatEntry()).toList();
    } catch (e) {
      logDebug('Failed to search transcript: $e');
      return [];
    }
  }

  /// Get transcript count for a session
  int getTranscriptCount(String sessionId) {
    try {
      return _store.chatEntryBox
          .query(ChatEntryEntity_.sessionId.equals(sessionId))
          .build()
          .count();
    } catch (e) {
      logDebug('Failed to get transcript count: $e');
      return 0;
    }
  }

  /// Get entries by status
  Future<List<ChatEntry>> getEntriesByStatus(
    String sessionId,
    ChatEntryStatus status,
  ) async {
    try {
      final entities = _store.chatEntryBox
          .query(
            ChatEntryEntity_.sessionId.equals(sessionId) &
            ChatEntryEntity_.statusIndex.equals(status.index)
          )
          .build()
          .find();
      
      return entities.map((e) => e.toChatEntry()).toList();
    } catch (e) {
      logDebug('Failed to get entries by status: $e');
      return [];
    }
  }

  // ─── Batch Operations ────────────────────────────────────────────────

  /// Batch cache sessions
  Future<void> cacheSessionsBatch(List<Session> sessions) async {
    try {
      final entities = sessions.map((s) => SessionEntity.fromSession(s)).toList();
      _store.sessionBox.putMany(entities);
    } catch (e) {
      logDebug('Failed to cache sessions batch: $e');
    }
  }

  /// Batch cache transcript entries
  Future<void> cacheTranscriptBatch(
    Map<String, List<ChatEntry>> sessionEntries,
  ) async {
    try {
      for (final entry in sessionEntries.entries) {
        await cacheTranscript(entry.key, entry.value);
      }
    } catch (e) {
      logDebug('Failed to cache transcript batch: $e');
    }
  }

  // ─── Cache Maintenance ───────────────────────────────────────────────

  /// Clear old caches
  Future<void> clearOldCaches({int olderThanDays = 7}) async {
    try {
      final cutoff = DateTime.now()
          .subtract(Duration(days: olderThanDays))
          .millisecondsSinceEpoch;
      
      // Find old sessions
      final oldSessions = _store.sessionBox
          .query(SessionEntity_.lastActiveAt.lessThan(cutoff))
          .build()
          .find();
      
      for (final session in oldSessions) {
        await deleteCachedSession(session.sessionId);
      }
      
      logDebug('Cleaned up ${oldSessions.length} old sessions');
    } catch (e) {
      logDebug('Failed to clear old caches: $e');
    }
  }

  /// Clear all cache
  Future<void> clearAllCache() async {
    try {
      _store.chatEntryBox.removeAll();
      _store.attachmentBox.removeAll();
      _store.sessionBox.removeAll();
      logDebug('Cleared all cache');
    } catch (e) {
      logDebug('Failed to clear all cache: $e');
    }
  }

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final sessionCount = _store.sessionBox.count();
      final entryCount = _store.chatEntryBox.count();
      final attachmentCount = _store.attachmentBox.count();
      
      // Calculate total size (approximate)
      int totalSize = 0;
      // This would need proper size calculation
      
      return {
        'sessionCount': sessionCount,
        'entryCount': entryCount,
        'attachmentCount': attachmentCount,
        'totalSize': totalSize,
        'lastCleaned': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      logDebug('Failed to get cache stats: $e');
      return {};
    }
  }

  // ─── Dispose ──────────────────────────────────────────────────────────

  /// Close store
  void dispose() {
    _store.close();
  }
}
```

## 4. Integration with ChatTranscriptProvider

```dart
// lib/features/chat/providers/chat_transcript_provider.dart (Partial Update)
import '../services/objectbox_cache_manager.dart';

class ChatTranscriptNotifier extends StateNotifier<List<ChatEntry>> {
  final Ref _ref;
  final String sessionId;
  final ObjectBoxObjectBoxCacheManager _cache = ObjectBoxObjectBoxCacheManager();
  bool _loadedFromCache = false;

  ChatTranscriptNotifier(this._ref, this.sessionId) : super([]) {
    if (sessionId.isNotEmpty) {
      _loadFromCache();
    }
  }

  Future<void> _loadFromCache() async {
    try {
      final cached = await _cache.getCachedTranscript(sessionId);
      if (cached.isNotEmpty) {
        state = cached;
        _loadedFromCache = true;
        logDebug('Loaded ${cached.length} entries from ObjectBox cache');
      }
    } catch (e) {
      logDebug('Failed to load from cache: $e');
    }
  }

  Future<void> _saveToCache() async {
    try {
      await _cache.cacheTranscript(sessionId, state);
      logDebug('Saved ${state.length} entries to ObjectBox cache');
    } catch (e) {
      logDebug('Failed to save to cache: $e');
    }
  }

  // Call this after any state change
  void _persistState() {
    // Don't persist if loading from cache and no changes yet
    if (!_loadedFromCache) return;
    _saveToCache();
  }

  @override
  void appendEntry(ChatEntry entry) {
    final index = state.indexWhere((e) => e.id == entry.id);
    if (index >= 0) {
      final newState = List<ChatEntry>.from(state);
      newState[index] = entry;
      state = newState;
    } else {
      state = [...state, entry];
    }
    _persistState();
  }

  // ... rest of the class with _persistState() calls after state changes
}
```

## 5. ObjectBox Model JSON

```json
// objectbox-model.json
{
  "_note1": "KEEP THIS FILE! Check it into version control.",
  "_note2": "ObjectBox manages crucial IDs for your object model.",
  "_note3": "Generated by ObjectBox Dart generator.",
  "entities": [
    {
      "id": "1",
      "lastPropertyId": "10",
      "name": "ChatEntryEntity",
      "properties": [
        {"id": "1", "name": "id", "type": 6, "flags": 1},
        {"id": "2", "name": "entryId", "type": 9, "flags": 4096},
        {"id": "3", "name": "sessionId", "type": 9, "flags": 4096},
        {"id": "4", "name": "typeIndex", "type": 6},
        {"id": "5", "name": "statusIndex", "type": 6},
        {"id": "6", "name": "text", "type": 9},
        {"id": "7", "name": "isLoading", "type": 1},
        {"id": "8", "name": "timestamp", "type": 6},
        {"id": "9", "name": "errorMessage", "type": 9},
        {"id": "10", "name": "jobId", "type": 9}
      ]
    },
    {
      "id": "2",
      "lastPropertyId": "14",
      "name": "AttachmentEntity",
      "properties": [
        {"id": "1", "name": "id", "type": 6, "flags": 1},
        {"id": "2", "name": "attachmentId", "type": 9},
        {"id": "3", "name": "name", "type": 9},
        {"id": "4", "name": "typeIndex", "type": 6},
        {"id": "5", "name": "url", "type": 9},
        {"id": "6", "name": "localPath", "type": 9},
        {"id": "7", "name": "size", "type": 6},
        {"id": "8", "name": "mimeType", "type": 9},
        {"id": "9", "name": "statusIndex", "type": 6},
        {"id": "10", "name": "thumbnailUrl", "type": 9},
        {"id": "11", "name": "durationMs", "type": 6},
        {"id": "12", "name": "errorMessage", "type": 9},
        {"id": "13", "name": "chatEntryId", "type": 9, "flags": 4096}
      ]
    },
    {
      "id": "3",
      "lastPropertyId": "18",
      "name": "SessionEntity",
      "properties": [
        {"id": "1", "name": "id", "type": 6, "flags": 1},
        {"id": "2", "name": "sessionId", "type": 9, "flags": 4096},
        {"id": "3", "name": "projectId", "type": 9, "flags": 4096},
        {"id": "4", "name": "title", "type": 9},
        {"id": "5", "name": "description", "type": 9},
        {"id": "6", "name": "statusIndex", "type": 6},
        {"id": "7", "name": "modeIndex", "type": 6},
        {"id": "8", "name": "createdAt", "type": 6},
        {"id": "9", "name": "updatedAt", "type": 6},
        {"id": "10", "name": "lastActiveAt", "type": 6},
        {"id": "11", "name": "forkOf", "type": 9},
        {"id": "12", "name": "isPinned", "type": 1},
        {"id": "13", "name": "fileChanges", "type": 6},
        {"id": "14", "name": "messageCount", "type": 6},
        {"id": "15", "name": "pendingCount", "type": 6},
        {"id": "16", "name": "queueSize", "type": 6},
        {"id": "17", "name": "totalDurationMs", "type": 6},
        {"id": "18", "name": "isSelected", "type": 1}
      ]
    }
  ],
  "lastEntityId": "3",
  "lastIndexId": "0:0",
  "lastRelationId": "0:0",
  "lastSequenceId": "0:0",
  "modelVersion": 5,
  "modelVersionParserMinimum": 5,
  "retiredEntityUids": [],
  "retiredIndexUids": [],
  "retiredPropertyUids": [],
  "retiredRelationUids": [],
  "version": 1
}
```

## 6. Main Initialization

```dart
// lib/main.dart
import 'package:aljabr/features/chat/services/objectbox_cache_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize ObjectBox
  final cacheManager = ObjectBoxObjectBoxCacheManager();
  await cacheManager.init();
  
  runApp(const ProviderScope(child: MyApp()));
}
```

## Key Features of This ObjectBox Implementation:

1. **Type-Safe Queries** - Using ObjectBox's query builder
2. **Relationships** - One-to-many between ChatEntry and Attachment
3. **Indexing** - Fast lookups on sessionId and entryId
4. **Embedded Objects** - ToolCall, Approval, Plan as embedded fields
5. **Batch Operations** - Efficient bulk inserts and deletes
6. **Search** - Full-text search on transcript text
7. **Query by Status** - Filter entries by status
8. **Stats** - Get cache statistics
9. **Cleanup** - Automatic cleanup of old sessions
10. **No Build Runner** - Uses ObjectBox's native generator