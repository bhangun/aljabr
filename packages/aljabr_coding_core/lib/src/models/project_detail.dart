import 'rule_item.dart';
import 'session_statusx.dart';
import 'skill_detail.dart';
import 'skill_item.dart';

class ProjectDetails {
  final String projectName;
  final List<SkillItem> rules;
  final List<SkillItem> skills;
  final List<SkillDetail> skillDetails;
  final List<RuleItem> rulesList;
  final int activeConversations;
  final int archivedConversations;
  final Map<SessionStatus, int> sessionStats; // Session status distribution
  final int totalSessions;
  final double averageSessionDuration; // In minutes
  final int totalFilesChanged;
  final DateTime? lastActive;

  const ProjectDetails({
    required this.projectName,
    required this.rules,
    required this.skills,
    required this.skillDetails,
    required this.rulesList,
    required this.activeConversations,
    required this.archivedConversations,
    this.sessionStats = const {},
    this.totalSessions = 0,
    this.averageSessionDuration = 0,
    this.totalFilesChanged = 0,
    this.lastActive,
  });

  ProjectDetails copyWith({
    String? projectName,
    List<SkillItem>? rules,
    List<SkillItem>? skills,
    List<SkillDetail>? skillDetails,
    List<RuleItem>? rulesList,
    int? activeConversations,
    int? archivedConversations,
    Map<SessionStatus, int>? sessionStats,
    int? totalSessions,
    double? averageSessionDuration,
    int? totalFilesChanged,
    DateTime? lastActive,
  }) {
    return ProjectDetails(
      projectName: projectName ?? this.projectName,
      rules: rules ?? this.rules,
      skills: skills ?? this.skills,
      skillDetails: skillDetails ?? this.skillDetails,
      rulesList: rulesList ?? this.rulesList,
      activeConversations: activeConversations ?? this.activeConversations,
      archivedConversations:
          archivedConversations ?? this.archivedConversations,
      sessionStats: sessionStats ?? this.sessionStats,
      totalSessions: totalSessions ?? this.totalSessions,
      averageSessionDuration:
          averageSessionDuration ?? this.averageSessionDuration,
      totalFilesChanged: totalFilesChanged ?? this.totalFilesChanged,
      lastActive: lastActive ?? this.lastActive,
    );
  }
}
