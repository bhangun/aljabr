import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../theme/app_colors.dart';
import '../providers/backend_process_provider.dart';
import '../services/backend_installer_service.dart';

class BackendOnboardingDialog extends ConsumerStatefulWidget {
  const BackendOnboardingDialog({super.key});

  @override
  ConsumerState<BackendOnboardingDialog> createState() =>
      _BackendOnboardingDialogState();
}

class _BackendOnboardingDialogState
    extends ConsumerState<BackendOnboardingDialog> {
  int _currentStep =
      0; // 0: Detection/Welcome, 1: Install Options, 2: Auto Installing, 3: Completed
  InstallProgress _installProgress = const InstallProgress();
  StreamSubscription<InstallProgress>? _installSub;
  final TextEditingController _customPathController = TextEditingController();
  String? _customPathError;

  @override
  void dispose() {
    _installSub?.cancel();
    _customPathController.dispose();
    super.dispose();
  }

  void _startAutoInstall() {
    setState(() {
      _currentStep = 2;
    });

    final installer = ref.read(backendInstallerServiceProvider);
    _installSub = installer.autoInstall().listen(
      (prog) {
        setState(() {
          _installProgress = prog;
          if (prog.stage == InstallStage.completed) {
            _currentStep = 3;
          }
        });
      },
      onError: (err) {
        setState(() {
          _installProgress = InstallProgress(
            stage: InstallStage.failed,
            statusMessage: 'Installation failed: $err',
          );
        });
      },
    );
  }

  void _finishAndLaunch() {
    ref.read(backendProcessProvider.notifier).startAll();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final detectionAsync = ref.watch(backendDetectionProvider);

    return Dialog(
      backgroundColor: AppTheme.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.border, width: 1.2),
      ),
      child: Container(
        width: 820,
        height: 580,
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // ── Dialog Header ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                color: AppTheme.panel,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                border: Border(bottom: BorderSide(color: AppTheme.border)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.accent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Icon(Icons.rocket_launch_rounded,
                        size: 20, color: AppTheme.accent),
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Backend Substrate Setup & Onboarding',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Local AI Inference (Gollek) & Agentic Coding Engine (Wayang/Aljabr)',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Skip Setup',
                    icon: const Icon(Icons.close_rounded,
                        size: 20, color: AppTheme.textMuted),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // ── Body Content by Step ───────────────────────────────────────
            Expanded(
              child: detectionAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppTheme.accent),
                ),
                error: (e, _) => Center(
                  child: Text('Error detecting environment: $e',
                      style: const TextStyle(color: Colors.red)),
                ),
                data: (info) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: _buildStepContent(info),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(BackendInstallationInfo info) {
    switch (_currentStep) {
      case 0:
        return _buildWelcomeStep(info);
      case 1:
        return _buildManualOrChoiceStep(info);
      case 2:
        return _buildInstallingStep();
      case 3:
        return _buildCompletedStep();
      default:
        return const SizedBox.shrink();
    }
  }

  // ── Step 0: Welcome & System Inspection ───────────────────────────────────

  Widget _buildWelcomeStep(BackendInstallationInfo info) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'First-Run Environment Inspection',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Aljabr Studio requires the dual-substrate backend (Gollek + Wayang) to run local neural inference and autonomous coding agent loops.',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.5),
        ),
        const Gap(16),

        // System Specs Grid
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.panelAlt,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            children: [
              _SpecRow(
                icon: Icons.computer_rounded,
                label: 'Host Platform',
                value:
                    '${info.systemSpecs.os.toUpperCase()} (${info.systemSpecs.architecture})',
              ),
              const Divider(height: 14, color: AppTheme.border),
              _SpecRow(
                icon: Icons.memory_rounded,
                label: 'Hardware Compute',
                value: info.systemSpecs.hardwareAcceleration,
                isAccent: true,
              ),
              const Divider(height: 14, color: AppTheme.border),
              _SpecRow(
                icon: Icons.code_rounded,
                label: 'Java Runtime Environment',
                value: info.systemSpecs.hasJava
                    ? (info.systemSpecs.javaVersion ?? 'JDK Active')
                    : 'Not Detected (Auto-provisioned)',
              ),
              const Divider(height: 14, color: AppTheme.border),
              _SpecRow(
                icon: Icons.layers_outlined,
                label: 'Backend Substrates Status',
                value: info.isFullyInstalled
                    ? 'Both Backends Located'
                    : info.isPartiallyInstalled
                        ? 'Partially Located'
                        : 'Not Installed Yet',
                statusColor: info.isFullyInstalled
                    ? Colors.green
                    : info.isPartiallyInstalled
                        ? Colors.orange
                        : Colors.red,
              ),
            ],
          ),
        ),

        const Spacer(),

        // Bottom Actions
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (info.isFullyInstalled) ...[
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.textSecondary,
                  side: const BorderSide(color: AppTheme.border),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: const Text('Close'),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: _finishAndLaunch,
                icon: const Icon(Icons.play_arrow_rounded, size: 18),
                label: const Text('Start Backends & Enter IDE'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF238636),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ] else ...[
              OutlinedButton(
                onPressed: () => setState(() => _currentStep = 1),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.textSecondary,
                  side: const BorderSide(color: AppTheme.border),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: const Text('Manual Install / Link'),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: _startAutoInstall,
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text('1-Click Auto Install (Recommended)'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF238636),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  // ── Step 1: Manual / Terminal Install Options ─────────────────────────────

  Widget _buildManualOrChoiceStep(BackendInstallationInfo info) {
    final installer = ref.read(backendInstallerServiceProvider);
    final command = installer.getManualInstallCommand();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded,
                  size: 18, color: AppTheme.textSecondary),
              onPressed: () => setState(() => _currentStep = 0),
            ),
            const SizedBox(width: 6),
            const Text(
              'Manual Installation & Linking',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Terminal command box
        const Text(
          'Option A: Run the multi-platform setup script in your terminal:',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1117),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: SelectableText(
                  command,
                  style: const TextStyle(
                    color: Color(0xFF79C0FF),
                    fontFamily: 'monospace',
                    fontSize: 11.5,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Copy Command',
                icon: const Icon(Icons.copy_rounded,
                    size: 16, color: AppTheme.textMuted),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: command));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Installation command copied!')),
                  );
                },
              ),
            ],
          ),
        ),

        const Gap(16),

        // Custom path link box
        const Text(
          'Option B: Link existing local directory or custom repository:',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _customPathController,
                style:
                    const TextStyle(fontSize: 12, color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: 'e.g. /path/to/wayang-platform',
                  hintStyle:
                      const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  errorText: _customPathError,
                  filled: true,
                  fillColor: AppTheme.panelAlt,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppTheme.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppTheme.border),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                final path = _customPathController.text.trim();
                if (Directory(path).existsSync()) {
                  setState(() {
                    _customPathError = null;
                    _currentStep = 3;
                  });
                } else {
                  setState(() {
                    _customPathError = 'Directory does not exist';
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              child: const Text('Verify & Link'),
            ),
          ],
        ),

        const Spacer(),

        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FilledButton.icon(
              onPressed: _startAutoInstall,
              icon: const Icon(Icons.download_rounded, size: 16),
              label: const Text('Switch to 1-Click Auto Install'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF238636),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Step 2: Live Progress Step ────────────────────────────────────────────

  Widget _buildInstallingStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Automated Installation in Progress...',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _installProgress.statusMessage,
          style: const TextStyle(color: AppTheme.accent, fontSize: 13),
        ),
        const Gap(16),

        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: _installProgress.progress,
            minHeight: 8,
            backgroundColor: AppTheme.panelAlt,
            color: const Color(0xFF238636),
          ),
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${(_installProgress.progress * 100).toInt()}%',
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 11.5,
              fontFamily: 'monospace',
            ),
          ),
        ),

        const Gap(12),

        // Live Log Terminal
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1117),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.border),
            ),
            child: SingleChildScrollView(
              child: Text(
                _installProgress.detailedLog ??
                    'Initializing setup routines...',
                style: const TextStyle(
                  color: Color(0xFFC9D1D9),
                  fontSize: 11.5,
                  fontFamily: 'monospace',
                  height: 1.4,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Step 3: Completed Step ────────────────────────────────────────────────

  Widget _buildCompletedStep() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF238636).withValues(alpha: 0.15),
              border: Border.all(color: const Color(0xFF238636), width: 2),
            ),
            child: const Icon(Icons.check_circle_outline_rounded,
                size: 48, color: Color(0xFF3FB950)),
          ),
          const SizedBox(height: 16),
          const Text(
            'Dual-Substrate Backends Ready!',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Gollek Local Inference Engine and Wayang/Aljabr Platform are configured and ready to run.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const Gap(24),
          FilledButton.icon(
            onPressed: _finishAndLaunch,
            icon: const Icon(Icons.rocket_launch_rounded, size: 18),
            label: const Text('Start Backends & Launch Aljabr Studio'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF238636),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isAccent;
  final Color? statusColor;

  const _SpecRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isAccent = false,
    this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppTheme.textMuted),
        const SizedBox(width: 8),
        Text(label,
            style:
                const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        const Spacer(),
        if (statusColor != null) ...[
          Container(
            width: 6,
            height: 6,
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: statusColor),
          ),
          const SizedBox(width: 6),
        ],
        Text(
          value,
          style: TextStyle(
            color: statusColor ??
                (isAccent ? AppTheme.accent : AppTheme.textPrimary),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
