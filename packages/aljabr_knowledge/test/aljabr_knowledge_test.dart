import 'package:flutter_test/flutter_test.dart';
import 'package:aljabr_knowledge/aljabr_knowledge.dart';

void main() {
  test('SkillDescriptor model tests', () {
    const skill = SkillDescriptor(
      id: 'skill-git',
      name: 'Git Skill',
      description: 'Performs git repository inspections',
    );
    expect(skill.isEnabled, isTrue);
    expect(skill.category, 'General');
  });
}
