/// A restorable point in a session's transcript. [entryCutoff] is the
/// number of [ChatEntry] rows that existed at the time the checkpoint was
/// taken — restoring truncates the transcript back to that length.
class Checkpoint {
  final String id;
  final String label;
  final DateTime createdAt;
  final int entryCutoff;

  const Checkpoint({
    required this.id,
    required this.label,
    required this.createdAt,
    required this.entryCutoff,
  });
}
