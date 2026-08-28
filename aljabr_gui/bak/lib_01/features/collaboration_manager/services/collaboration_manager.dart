import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/utils/result.dart';
import '../../chat/models/message.dart';

/// Real-time collaboration session manager
class CollaborationManager {
  CollaborationManager({
    required this.sessionId,
    this.userId,
    this.userName = 'Anonymous',
  });

  final String sessionId;
  final String? userId;
  final String userName;

  WebSocketChannel? _channel;
  final StreamController<CollaborationEvent> _eventController =
      StreamController<CollaborationEvent>.broadcast();

  final List<Collaborator> _collaborators = [];
  final Map<String, CursorPosition> _cursors = {};

  /// Connect to collaboration server
  Future<Result<void>> connect(String serverUrl) async {
    try {
      final wsUrl = Uri.parse(
        serverUrl,
      ).replace(scheme: 'wss', path: '/collaborate');
      _channel = WebSocketChannel.connect(wsUrl);

      // Send join message
      _channel!.sink.add(
        jsonEncode({
          'type': 'join',
          'sessionId': sessionId,
          'userId': userId ?? _generateUserId(),
          'userName': userName,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      // Listen for events
      _channel!.stream.listen(
        (data) => _handleEvent(data),
        onError: (error) {
          _eventController.add(CollaborationError(error.toString()));
        },
        onDone: () {
          _eventController.add(CollaborationDisconnected());
        },
      );

      return const Success(null);
    } catch (e) {
      return Failure(NetworkError('Failed to connect: $e'));
    }
  }

  /// Send a message to all collaborators
  void sendMessage(Message message) {
    _sendEvent({
      'type': 'message',
      'messageId': message.id,
      'role': message.role.name,
      'content': message.content,
      'timestamp': message.createdAt.toIso8601String(),
    });
  }

  /// Send cursor position update
  void updateCursor(int line, int column, {String? fileId}) {
    _sendEvent({
      'type': 'cursor',
      'line': line,
      'column': column,
      'fileId': fileId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Request to edit a file
  Future<Result<bool>> requestFileLock(String fileId) async {
    final completer = Completer<Result<bool>>();

    final subscription = _eventController.stream.listen((event) {
      if (event is FileLockResponse) {
        if (event.fileId == fileId) {
          if (!completer.isCompleted) {
            completer.complete(Success(event.granted));
          }
        }
      }
    });

    _sendEvent({
      'type': 'request_lock',
      'fileId': fileId,
      'timestamp': DateTime.now().toIso8601String(),
    });

    // Timeout after 5 seconds
    final timer = Timer(const Duration(seconds: 5), () {
      if (!completer.isCompleted) {
        completer.complete(const Success(false));
      }
    });

    final result = await completer.future;
    timer.cancel();
    subscription.cancel();

    return result;
  }

  /// Release file lock
  void releaseFileLock(String fileId) {
    _sendEvent({
      'type': 'release_lock',
      'fileId': fileId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void _sendEvent(Map<String, dynamic> event) {
    event['userId'] = userId ?? _generateUserId();
    event['userName'] = userName;
    _channel?.sink.add(jsonEncode(event));
  }

  void _handleEvent(dynamic data) {
    try {
      final event = jsonDecode(data as String) as Map<String, dynamic>;
      final type = event['type'] as String;

      switch (type) {
        case 'user_joined':
          _addCollaborator(event);
          break;
        case 'user_left':
          _removeCollaborator(event);
          break;
        case 'message':
          _eventController.add(CollaborationMessage.fromJson(event));
          break;
        case 'cursor':
          _updateCursor(event);
          break;
        case 'file_lock_response':
          _eventController.add(FileLockResponse.fromJson(event));
          break;
        case 'file_update':
          _eventController.add(FileUpdateEvent.fromJson(event));
          break;
        case 'error':
          _eventController.add(CollaborationError(event['message'] as String));
          break;
        default:
          _eventController.add(CollaborationUnknownEvent(event));
      }
    } catch (e) {
      _eventController.add(CollaborationError('Parse error: $e'));
    }
  }

  void _addCollaborator(Map<String, dynamic> event) {
    final collaborator = Collaborator.fromJson(event);
    _collaborators.add(collaborator);
    _eventController.add(CollaboratorJoined(collaborator));
  }

  void _removeCollaborator(Map<String, dynamic> event) {
    final userId = event['userId'] as String;
    _collaborators.removeWhere((c) => c.userId == userId);
    _cursors.remove(userId);
    _eventController.add(CollaboratorLeft(userId));
  }

  void _updateCursor(Map<String, dynamic> event) {
    final userId = event['userId'] as String;
    final position = CursorPosition.fromJson(event);
    _cursors[userId] = position;
    _eventController.add(CursorUpdate(position));
  }

  String _generateUserId() {
    return 'user_${DateTime.now().millisecondsSinceEpoch.toRadixString(36)}';
  }

  /// Stream of collaboration events
  Stream<CollaborationEvent> get events => _eventController.stream;

  /// List of current collaborators
  List<Collaborator> get collaborators => List.unmodifiable(_collaborators);

  /// Current cursor positions
  Map<String, CursorPosition> get cursors => Map.unmodifiable(_cursors);

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }

  void dispose() {
    disconnect();
    _eventController.close();
  }
}

/// Collaboration event types
sealed class CollaborationEvent {}

class CollaboratorJoined extends CollaborationEvent {
  CollaboratorJoined(this.collaborator);
  final Collaborator collaborator;
}

class CollaboratorLeft extends CollaborationEvent {
  CollaboratorLeft(this.userId);
  final String userId;
}

class CollaborationMessage extends CollaborationEvent {
  CollaborationMessage({
    required this.messageId,
    required this.role,
    required this.content,
    required this.timestamp,
    required this.userId,
    required this.userName,
  });

  final String messageId;
  final String role;
  final String content;
  final DateTime timestamp;
  final String userId;
  final String userName;

  factory CollaborationMessage.fromJson(Map<String, dynamic> json) {
    return CollaborationMessage(
      messageId: json['messageId'] as String,
      role: json['role'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      userId: json['userId'] as String,
      userName: json['userName'] as String,
    );
  }
}

class CursorUpdate extends CollaborationEvent {
  CursorUpdate(this.position);
  final CursorPosition position;
}

class FileLockResponse extends CollaborationEvent {
  FileLockResponse({
    required this.fileId,
    required this.granted,
    required this.userId,
  });

  final String fileId;
  final bool granted;
  final String userId;

  factory FileLockResponse.fromJson(Map<String, dynamic> json) {
    return FileLockResponse(
      fileId: json['fileId'] as String,
      granted: json['granted'] as bool,
      userId: json['userId'] as String,
    );
  }
}

class FileUpdateEvent extends CollaborationEvent {
  FileUpdateEvent({
    required this.fileId,
    required this.content,
    required this.userId,
    required this.timestamp,
  });

  final String fileId;
  final String content;
  final String userId;
  final DateTime timestamp;

  factory FileUpdateEvent.fromJson(Map<String, dynamic> json) {
    return FileUpdateEvent(
      fileId: json['fileId'] as String,
      content: json['content'] as String,
      userId: json['userId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

class CollaborationError extends CollaborationEvent {
  CollaborationError(this.message);
  final String message;
}

class CollaborationDisconnected extends CollaborationEvent {}

class CollaborationUnknownEvent extends CollaborationEvent {
  CollaborationUnknownEvent(this.data);
  final Map<String, dynamic> data;
}

/// Collaborator information
class Collaborator {
  Collaborator({
    required this.userId,
    required this.userName,
    required this.joinedAt,
    this.isActive = true,
  });

  final String userId;
  final String userName;
  final DateTime joinedAt;
  final bool isActive;

  factory Collaborator.fromJson(Map<String, dynamic> json) {
    return Collaborator(
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      joinedAt: DateTime.parse(json['timestamp'] as String),
    );
  }
}

/// Cursor position
class CursorPosition {
  CursorPosition({
    required this.userId,
    required this.line,
    required this.column,
    this.fileId,
    required this.timestamp,
  });

  final String userId;
  final int line;
  final int column;
  final String? fileId;
  final DateTime timestamp;

  factory CursorPosition.fromJson(Map<String, dynamic> json) {
    return CursorPosition(
      userId: json['userId'] as String,
      line: json['line'] as int,
      column: json['column'] as int,
      fileId: json['fileId'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
