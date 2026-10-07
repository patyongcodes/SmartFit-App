import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_drawer.dart';
import '../../data/sessions/workout_session.dart';
import '../../data/sessions/session_storage.dart';

class SessionSummaryScreen extends StatelessWidget {
  final WorkoutSession? session;

  const SessionSummaryScreen({super.key, this.session});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Session Summary'), elevation: 0),
      drawer: const AppDrawer(),
      body: SessionSummaryScreenBody(session: session),
    );
  }
}

class SessionSummaryScreenBody extends StatefulWidget {
  final WorkoutSession? session;

  const SessionSummaryScreenBody({super.key, this.session});

  @override
  State<SessionSummaryScreenBody> createState() => _SessionSummaryScreenBodyState();
}

class _SessionSummaryScreenBodyState extends State<SessionSummaryScreenBody> {
  bool _isSaved = false;
  bool _isSaving = false;

  Future<void> _handleSave() async {
    if (widget.session == null) return;
    setState(() => _isSaving = true);
    await SessionStorage.saveSession(widget.session!);
    if (!mounted) return;
    setState(() {
      _isSaving = false;
      _isSaved = true;
    });
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.fitness_center_rounded,
              size: 72,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              'No Active Session Summary',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete a workout session to view your biomechanical score, rep count, and movement breakdown.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => context.go('/exercise-library'),
                icon: const Icon(Icons.play_arrow_rounded, size: 20),
                label: const Text(
                  'Start a Workout',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final colorScheme = Theme.of(context).colorScheme;

    if (session == null) {
      return _buildEmptyState(context);
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: colorScheme.primary.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: Icon(Icons.check_circle_rounded, color: colorScheme.primary, size: 40),
              ),
              const SizedBox(height: 16),
              Text('Session Completed!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.3, color: colorScheme.onSurface)),
              const SizedBox(height: 6),
              Text(session.title, style: TextStyle(fontSize: 13, color: colorScheme.onSurface.withValues(alpha: 0.65))),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(child: _buildMetricTile(context, label: 'Duration', value: '${session.durationMinutes} mins', icon: Icons.timer_outlined)),
            const SizedBox(width: 10),
            Expanded(child: _buildMetricTile(context, label: 'Form Score', value: '${session.formScorePercent}%', icon: Icons.auto_graph_rounded)),
            const SizedBox(width: 10),
            Expanded(child: _buildMetricTile(context, label: 'Reps', value: '${session.totalReps}', icon: Icons.repeat_rounded)),
          ],
        ),
        const SizedBox(height: 24),
        Text('Biomechanical Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.3, color: colorScheme.onSurface)),
        const SizedBox(height: 12),
        ...session.breakdown.entries.map((entry) {
          final percent = entry.value.clamp(0, 1).toDouble();
          final status = percent >= 0.9 ? 'Excellent' : percent >= 0.75 ? 'Good' : 'Needs Work';
          final color = percent >= 0.9 ? colorScheme.primary : percent >= 0.75 ? colorScheme.secondary : colorScheme.tertiary;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildAnalysisRow(context, title: entry.key, status: status, percentage: percent, color: color),
          );
        }),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _isSaved || _isSaving ? null : _handleSave,
            icon: Icon(_isSaved ? Icons.check : Icons.save_outlined, color: AppColors.white),
            label: Text(
              _isSaving ? 'Saving...' : (_isSaved ? 'Saved to Progress' : 'Save Session'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue,
              disabledBackgroundColor: AppColors.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        if (_isSaved) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () => context.go('/progress'),
              style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('View Progress', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.blue)),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMetricTile(BuildContext context, {required String label, required String value, required IconData icon}) {
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: colorScheme.onSurface.withValues(alpha: 0.6))),
        ],
      ),
    );
  }

  Widget _buildAnalysisRow(BuildContext context, {required String title, required String status, required double percentage, required Color color}) {
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
              Text(status, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(value: percentage, minHeight: 6, backgroundColor: colorScheme.outline.withValues(alpha: 0.2), color: color),
          ),
        ],
      ),
    );
  }
}