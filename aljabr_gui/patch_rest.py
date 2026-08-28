import sys

with open('lib/data/rest_backend_service.dart', 'r') as f:
    content = f.read()

injection = """
  Future<String> _getBaseUrl() async {
    for (final port in [8085, 8080]) {
      try {
        final res = await http.get(Uri.parse('http://127.0.0.1:$port/api/v1/providers')).timeout(const Duration(milliseconds: 500));
        if (res.statusCode == 200) {
          return 'http://127.0.0.1:$port/api/v1';
        }
      } catch (_) {}
    }
    return 'http://127.0.0.1:8080/api/v1'; // fallback
  }

  @override
  Future<List<Map<String, dynamic>>> listSkills({String? category, String? query, bool includeTrash = false}) async {
    final baseUrl = await _getBaseUrl();
    final uri = Uri.parse('$baseUrl/skills').replace(queryParameters: {
      if (category != null) 'category': category,
      if (query != null) 'query': query,
      if (includeTrash) 'includeTrash': 'true',
    });
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(res.body));
    }
    return [];
  }

  @override
  Future<Map<String, dynamic>> getSkill(String id) async {
    final baseUrl = await _getBaseUrl();
    final res = await http.get(Uri.parse('$baseUrl/skills/$id'));
    if (res.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(res.body));
    }
    throw Exception('Failed to load skill: ${res.statusCode}');
  }

  @override
  Future<Map<String, dynamic>> createSkill(Map<String, dynamic> data) async {
    final baseUrl = await _getBaseUrl();
    final res = await http.post(
      Uri.parse('$baseUrl/skills'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return Map<String, dynamic>.from(jsonDecode(res.body));
    }
    throw Exception('Failed to create skill: ${res.body}');
  }

  @override
  Future<Map<String, dynamic>> updateSkill(String id, Map<String, dynamic> data) async {
    final baseUrl = await _getBaseUrl();
    final res = await http.put(
      Uri.parse('$baseUrl/skills/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (res.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(res.body));
    }
    throw Exception('Failed to update skill: ${res.body}');
  }

  @override
  Future<void> deleteSkill(String id, {bool hard = false}) async {
    final baseUrl = await _getBaseUrl();
    final uri = Uri.parse('$baseUrl/skills/$id').replace(queryParameters: {
      if (hard) 'hard': 'true',
    });
    final res = await http.delete(uri);
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Failed to delete skill: ${res.body}');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> listTrashedSkills() async {
    final baseUrl = await _getBaseUrl();
    final res = await http.get(Uri.parse('$baseUrl/skills/trash'));
    if (res.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(res.body));
    }
    return [];
  }

  @override
  Future<void> restoreSkill(String id) async {
    final baseUrl = await _getBaseUrl();
    final res = await http.post(Uri.parse('$baseUrl/skills/$id/restore'));
    if (res.statusCode != 200) {
      throw Exception('Failed to restore skill: ${res.body}');
    }
  }

  @override
  Future<void> reloadSkills() async {
    final baseUrl = await _getBaseUrl();
    final res = await http.post(Uri.parse('$baseUrl/skills/reload'));
    if (res.statusCode != 200) {
      throw Exception('Failed to reload skills: ${res.body}');
    }
  }
"""

content = content.replace('\n}\n', '\n' + injection + '\n}\n')

with open('lib/data/rest_backend_service.dart', 'w') as f:
    f.write(content)
