import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/chat/models/approval_request.dart';
import '../features/chat/models/chat_entry.dart';
import '../features/chat/providers/chat_transcript_provider.dart';
import '../features/project/providers/active_session_provider.dart';
import '../features/project/services/session_monitor.dart';

class MonitoringDashboard extends ConsumerStatefulWidget {
  const MonitoringDashboard({super.key});

  @override
  ConsumerState<MonitoringDashboard> createState() =>
      _MonitoringDashboardState();
}

class _MonitoringDashboardState extends ConsumerState<MonitoringDashboard> {
  final SessionMonitor _monitor = SessionMonitor();

  @override
  void initState() {
    super.initState();
    _startMonitoring();
  }

  void _startMonitoring() {
    // Listen to session events and track metrics
    final sessionId = ref.read(activeSessionIdProvider);
    _monitor.trackSessionStart(sessionId);

    // Track transcript events
    ref.listen<List<ChatEntry>>(
      chatTranscriptProvider(sessionId),
      (previous, current) {
        _trackTranscriptChanges(previous, current);
      },
    );
  }

  void _trackTranscriptChanges(
      List<ChatEntry>? previous, List<ChatEntry> current) {
    if (previous == null) return;

    final sessionId = ref.read(activeSessionIdProvider);

    // Track new entries
    for (final entry in current) {
      if (!previous.contains(entry)) {
        if (entry.toolCall != null) {
          _monitor.trackToolCall(sessionId);
        }
        if (entry.approval != null) {
          final approved = entry.approval?.status == ApprovalStatus.approved;
          _monitor.trackApproval(sessionId, approved);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = _monitor.getDashboard();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📊 Session Monitor',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMetricCard(
                'Active Sessions',
                dashboard['activeSessions'].toString(),
                Icons.circle,
                Colors.blue,
              ),
              _buildMetricCard(
                'Total Requests',
                dashboard['totalRequests'].toString(),
                Icons.swap_horiz,
                Colors.green,
              ),
              _buildMetricCard(
                'Error Rate',
                '${((dashboard['errorRate'] as double) * 100).toStringAsFixed(1)}%',
                Icons.error_outline,
                Colors.red,
              ),
              _buildMetricCard(
                'Tool Calls',
                dashboard['totalToolCalls'].toString(),
                Icons.build,
                Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildLatencyChart(),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLatencyChart() {
    // Implementation for latency chart
    return Container(
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Text('Latency Chart (Coming Soon)'),
      ),
    );
  }
}
