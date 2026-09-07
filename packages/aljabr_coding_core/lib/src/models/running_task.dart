/// A background job shown in the "N tasks running" tray at the bottom
/// of the chat panel (timers, shell commands, etc).
class RunningTask {
  final String id;
  final String label;
  final bool isSpinning;

  const RunningTask({
    required this.id,
    required this.label,
    this.isSpinning = true,
  });
}
