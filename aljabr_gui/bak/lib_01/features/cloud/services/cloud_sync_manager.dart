import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../coding_agent.dart';
import '../../chat/models/session.dart';

/// Cloud synchronization manager
class CloudSyncManager {
  CloudSyncManager({required this.apiEndpoint, required this.apiKey});

  final String apiEndpoint;
  final String apiKey;

  bool _isSyncing = false;
  String? _lastSyncToken;
  final Map<String, DateTime> _syncStatus = {};

  /// Sync sessions to cloud
  Future<Result<List<Session>>> syncSessions(List<Session> sessions) async {
    if (_isSyncing) {
      return const Failure(NetworkError('Sync already in progress'));
    }

    _isSyncing = true;

    try {
      // Prepare sync payload
      final payload = {
        'sessions': sessions.map((s) => s.toJson()).toList(),
        'syncToken': _lastSyncToken,
        'deviceId': await _getDeviceId(),
        'timestamp': DateTime.now().toIso8601String(),
      };

      final response = await http.post(
        Uri.parse('$apiEndpoint/sync'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode != 200) {
        return Failure(ApiError('Sync failed: ${response.statusCode}'));
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      _lastSyncToken = data['syncToken'] as String?;

      // Get updated sessions from server
      final serverSessions =
          (data['sessions'] as List?)
              ?.map((s) => sessionFromJson(s as Map<String, dynamic>))
              .toList() ??
          [];

      return Success(serverSessions);
    } catch (e) {
      return Failure(NetworkError('Sync failed: $e'));
    } finally {
      _isSyncing = false;
    }
  }

  /// Backup all sessions to cloud
  Future<Result<CloudBackup>> createBackup(List<Session> sessions) async {
    try {
      final backup = CloudBackup(
        id: generateId(),
        createdAt: DateTime.now(),
        sessions: sessions,
        metadata: {
          'totalSessions': sessions.length,
          'totalMessages': sessions.fold(
            0,
            (sum, s) => sum + s.messages.length,
          ),
          'deviceId': await _getDeviceId(),
          'appVersion': '2.0.0',
        },
      );

      final response = await http.post(
        Uri.parse('$apiEndpoint/backup'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode(backup.toJson()),
      );

      if (response.statusCode != 200) {
        return Failure(ApiError('Backup failed: ${response.statusCode}'));
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final backupId = data['backupId'] as String;

      return Success(backup.copyWith(id: backupId));
    } catch (e) {
      return Failure(NetworkError('Backup failed: $e'));
    }
  }

  /// Restore from backup
  Future<Result<List<Session>>> restoreBackup(String backupId) async {
    try {
      final response = await http.get(
        Uri.parse('$apiEndpoint/backup/$backupId'),
        headers: {'Authorization': 'Bearer $apiKey'},
      );

      if (response.statusCode != 200) {
        return Failure(ApiError('Restore failed: ${response.statusCode}'));
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final backup = CloudBackup.fromJson(data);

      return Success(backup.sessions);
    } catch (e) {
      return Failure(NetworkError('Restore failed: $e'));
    }
  }

  /// List available backups
  Future<Result<List<CloudBackupInfo>>> listBackups() async {
    try {
      final response = await http.get(
        Uri.parse('$apiEndpoint/backups'),
        headers: {'Authorization': 'Bearer $apiKey'},
      );

      if (response.statusCode != 200) {
        return Failure(
          ApiError('Failed to list backups: ${response.statusCode}'),
        );
      }

      final data = jsonDecode(response.body) as List;
      final backups = data.map((b) => CloudBackupInfo.fromJson(b)).toList();

      return Success(backups);
    } catch (e) {
      return Failure(NetworkError('Failed to list backups: $e'));
    }
  }

  /// Delete a backup
  Future<Result<void>> deleteBackup(String backupId) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiEndpoint/backup/$backupId'),
        headers: {'Authorization': 'Bearer $apiKey'},
      );

      if (response.statusCode != 200) {
        return Failure(
          ApiError('Failed to delete backup: ${response.statusCode}'),
        );
      }

      return const Success(null);
    } catch (e) {
      return Failure(NetworkError('Failed to delete backup: $e'));
    }
  }

  /// Get sync status
  bool get isSyncing => _isSyncing;

  /// Get last sync time
  DateTime? get lastSyncTime =>
      _lastSyncToken != null ? DateTime.parse(_lastSyncToken!) : null;

  Future<String> _getDeviceId() async {
    // In production, use device_info_plus to get device ID
    return 'device_${DateTime.now().millisecondsSinceEpoch.toRadixString(36)}';
  }
}

/// Cloud backup structure
class CloudBackup {
  CloudBackup({
    required this.id,
    required this.createdAt,
    required this.sessions,
    this.metadata = const {},
  });

  final String id;
  final DateTime createdAt;
  final List<Session> sessions;
  final Map<String, dynamic> metadata;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'sessions': sessions.map((s) => s.toJson()).toList(),
      'metadata': metadata,
    };
  }

  factory CloudBackup.fromJson(Map<String, dynamic> json) {
    return CloudBackup(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      sessions: (json['sessions'] as List)
          .map((s) => sessionFromJson(s as Map<String, dynamic>))
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  CloudBackup copyWith({
    String? id,
    DateTime? createdAt,
    List<Session>? sessions,
    Map<String, dynamic>? metadata,
  }) {
    return CloudBackup(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      sessions: sessions ?? this.sessions,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Backup info (summary)
class CloudBackupInfo {
  CloudBackupInfo({
    required this.id,
    required this.createdAt,
    required this.sessionCount,
    required this.messageCount,
  });

  final String id;
  final DateTime createdAt;
  final int sessionCount;
  final int messageCount;

  factory CloudBackupInfo.fromJson(Map<String, dynamic> json) {
    return CloudBackupInfo(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      sessionCount: json['sessionCount'] as int,
      messageCount: json['messageCount'] as int,
    );
  }
}
