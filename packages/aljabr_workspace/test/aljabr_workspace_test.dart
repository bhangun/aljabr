import 'package:flutter_test/flutter_test.dart';
import 'package:aljabr_workspace/aljabr_workspace.dart';

void main() {
  test('WorkspaceInfo and FileNode model tests', () {
    const ws = WorkspaceInfo(id: 'ws-1', name: 'Aljabr', path: '/home/workspace');
    expect(ws.name, 'Aljabr');
    expect(ws.isGit, isTrue);

    const node = FileNode(name: 'main.dart', path: '/home/workspace/main.dart');
    expect(node.extension, 'dart');
    expect(node.isDirectory, isFalse);
  });

  test('WorkItem and TimelineEvent model serialization', () {
    final item = WorkItem(
      id: 'WI-1',
      workspaceId: 'ws-1',
      type: WorkType.feature,
      title: 'Implement JWT Auth',
      description: 'Add token validation middleware',
    );
    expect(item.type.label, 'Feature');
    expect(item.status, WorkStatus.todo);

    final event = TimelineEvent(
      id: 'ev-1',
      executionId: 'exec-1',
      phase: 'PLANNING',
      kind: TimelineEventKind.decisionMade,
      title: 'Selected Spring Architect Skill',
      details: 'Based on pom.xml analysis',
    );
    expect(event.kind, TimelineEventKind.decisionMade);
    expect(event.phase, 'PLANNING');
  });
}
