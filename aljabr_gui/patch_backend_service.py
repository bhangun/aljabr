import sys

with open('lib/data/backend_service.dart', 'r') as f:
    content = f.read()

injection = """
  // Skills Management
  Future<List<Map<String, dynamic>>> listSkills({String? category, String? query, bool includeTrash = false});
  Future<Map<String, dynamic>> getSkill(String id);
  Future<Map<String, dynamic>> createSkill(Map<String, dynamic> data);
  Future<Map<String, dynamic>> updateSkill(String id, Map<String, dynamic> data);
  Future<void> deleteSkill(String id, {bool hard = false});
  Future<List<Map<String, dynamic>>> listTrashedSkills();
  Future<void> restoreSkill(String id);
  Future<void> reloadSkills();
"""

content = content.replace('}', injection + '\n}')

with open('lib/data/backend_service.dart', 'w') as f:
    f.write(content)
