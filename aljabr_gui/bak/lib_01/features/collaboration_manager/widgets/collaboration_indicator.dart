import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../services/collaboration_manager.dart';

/// Shows online collaborators and status
class CollaborationIndicator extends ConsumerStatefulWidget {
  const CollaborationIndicator({super.key, required this.collaborationManager});

  final CollaborationManager collaborationManager;

  @override
  ConsumerState<CollaborationIndicator> createState() =>
      _CollaborationIndicatorState();
}

class _CollaborationIndicatorState
    extends ConsumerState<CollaborationIndicator> {
  List<Collaborator> _collaborators = [];

  @override
  void initState() {
    super.initState();
    _collaborators = widget.collaborationManager.collaborators;
    widget.collaborationManager.events.listen((event) {
      if (event is CollaboratorJoined || event is CollaboratorLeft) {
        setState(() {
          _collaborators = widget.collaborationManager.collaborators;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_collaborators.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.people_alt_outlined,
            size: 14,
            color: AppTheme.textMuted,
          ),
          const SizedBox(width: 6),
          Text(
            '${_collaborators.length} online',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
          ),
          const SizedBox(width: 6),
          ..._collaborators
              .take(3)
              .map((c) => _CollaboratorAvatar(collaborator: c)),
          if (_collaborators.length > 3)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                '+${_collaborators.length - 3}',
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
              ),
            ),
        ],
      ),
    );
  }
}

class _CollaboratorAvatar extends StatelessWidget {
  const _CollaboratorAvatar({required this.collaborator});
  final Collaborator collaborator;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 2),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: _getColor(collaborator.userId),
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Center(
        child: Text(
          collaborator.userName.isNotEmpty
              ? collaborator.userName[0].toUpperCase()
              : '?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Color _getColor(String id) {
    // Generate consistent color from user ID
    final hash = id.hashCode.abs();
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.teal,
    ];
    return colors[hash % colors.length];
  }
}
