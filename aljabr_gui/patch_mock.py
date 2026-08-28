import sys

with open('lib/features/chat/services/mock_backend_service.dart', 'r') as f:
    content = f.read()

injection = """
  @override
  Future<List<Map<String, dynamic>>> listSkills({String? category, String? query, bool includeTrash = false}) async => [];
  @override
  Future<Map<String, dynamic>> getSkill(String id) async => throw UnimplementedError();
  @override
  Future<Map<String, dynamic>> createSkill(Map<String, dynamic> data) async => throw UnimplementedError();
  @override
  Future<Map<String, dynamic>> updateSkill(String id, Map<String, dynamic> data) async => throw UnimplementedError();
  @override
  Future<void> deleteSkill(String id, {bool hard = false}) async => throw UnimplementedError();
  @override
  Future<List<Map<String, dynamic>>> listTrashedSkills() async => [];
  @override
  Future<void> restoreSkill(String id) async => throw UnimplementedError();
  @override
  Future<void> reloadSkills() async => throw UnimplementedError();
"""

content = content.replace('\n}\n', '\n' + injection + '\n}\n')

with open('lib/features/chat/services/mock_backend_service.dart', 'w') as f:
    f.write(content)
