import 'package:equatable/equatable.dart';
import 'file_reference.dart';
import 'message.dart';
import 'session.dart';

/// Represents a branch in a conversation tree
class Branch extends Equatable {
  const Branch({
    required this.id,
    required this.parentMessageId,
    required this.messages,
    required this.createdAt,
    this.metadata = const {},
  });

  final String id;
  final String parentMessageId;
  final List<Message> messages;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;

  int get messageCount => messages.length;
  Message? get lastMessage => messages.isNotEmpty ? messages.last : null;

  Branch copyWith({
    String? id,
    String? parentMessageId,
    List<Message>? messages,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return Branch(
      id: id ?? this.id,
      parentMessageId: parentMessageId ?? this.parentMessageId,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [id, parentMessageId, messages.length, createdAt];
}

/// Extended Session with branching support
class BranchingSession extends Session {
  const BranchingSession({
    required super.id,
    required super.title,
    required super.createdAt,
    required super.updatedAt,
    super.messages = const [],
    super.files = const [],
    super.systemPrompt,
    super.isPinned = false,
    super.tags = const [],
    super.projectId,
    this.branches = const [],
    this.currentBranchId,
  });

  final List<Branch> branches;
  final String? currentBranchId;

  Branch? get currentBranch {
    if (currentBranchId == null) return null;
    try {
      return branches.firstWhere((b) => b.id == currentBranchId);
    } catch (_) {
      return null;
    }
  }

  List<Message> get currentMessages {
    if (currentBranch != null) {
      return currentBranch!.messages;
    }
    return messages;
  }

  BranchingSession copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Message>? messages,
    List<FileReference>? files,
    String? systemPrompt,
    bool? isPinned,
    List<String>? tags,
    String? projectId,
    List<Branch>? branches,
    String? currentBranchId,
  }) {
    return BranchingSession(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
      files: files ?? this.files,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      isPinned: isPinned ?? this.isPinned,
      tags: tags ?? this.tags,
      projectId: projectId ?? this.projectId,
      branches: branches ?? this.branches,
      currentBranchId: currentBranchId ?? this.currentBranchId,
    );
  }

  /// Create a new branch from a message
  Branch createBranch(String parentMessageId, {String? title}) {
    final parentIndex = messages.indexWhere((m) => m.id == parentMessageId);
    if (parentIndex == -1) {
      throw ArgumentError('Message not found: $parentMessageId');
    }

    final branchMessages = messages.take(parentIndex + 1).toList();
    final branch = Branch(
      id: 'branch_${DateTime.now().millisecondsSinceEpoch}',
      parentMessageId: parentMessageId,
      messages: branchMessages,
      createdAt: DateTime.now(),
      metadata: {'title': title ?? 'Branch ${branches.length + 1}'},
    );

    return branch;
  }

  @override
  List<Object?> get props => [...super.props, branches.length, currentBranchId];
}
