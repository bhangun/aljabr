/// A repository / workspace root. Each [Project] owns many [Session]s
/// (one per agent conversation run against that codebase).
class Project {
  final String id;
  final String name;
  final String rootPath;
  final String? branch;

  const Project({
    required this.id,
    required this.name,
    required this.rootPath,
    this.branch,
  });
}
