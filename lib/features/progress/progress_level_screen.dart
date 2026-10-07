import 'package:flutter/material.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/theme/app_colors.dart';
import '../../data/ai_coach/ai_coach_models.dart';
import '../../data/ai_coach/ai_coach_storage.dart';
import '../../data/ai_coach/program_calendar.dart';
import '../../data/sessions/workout_session.dart';
import '../../data/sessions/session_storage.dart';
import '../../data/sessions/streak_calculator.dart';

class ProgressLevelScreen extends StatelessWidget {
  const ProgressLevelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progress & Level'), elevation: 0),
      drawer: const AppDrawer(),
      body: const ProgressLevelScreenBody(),
    );
  }
}

class ProgressLevelScreenBody extends StatefulWidget {
  const ProgressLevelScreenBody({super.key});

  @override
  State<ProgressLevelScreenBody> createState() => _ProgressLevelScreenBodyState();
}

class _ProgressLevelScreenBodyState extends State<ProgressLevelScreenBody> {
  AiCoachResult? _plan;
  List<WorkoutSession> _sessions = [];
  int _streak = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final plan = await AiCoachStorage.loadPlan();
    final sessions = await SessionStorage.getAllSessions();

    var streak = 0;
    if (plan != null) {
      final calendar = ProgramCalendar.generate(plan);
      streak = StreakCalculator.calculate(calendar: calendar, sessions: sessions, today: DateTime.now());
    }

    if (!mounted) return;
    setState(() {
      _plan = plan;
      _sessions = sessions..sort((a, b) => b.date.compareTo(a.date));
      _streak = streak;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.blue));
    }

    final plan = _plan;
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (plan != null) _buildLevelCard(context, plan) else _buildNoPlanCard(),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _buildStatCard(context, icon: Icons.local_fire_department_rounded, title: 'Streak', value: '$_streak Days', iconColor: colorScheme.primary)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(context, icon: Icons.verified_rounded, title: 'Sessions Logged', value: '${_sessions.length}', iconColor: colorScheme.secondary)),
          ],
        ),
        const SizedBox(height: 24),
        Text('Milestones', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.3, color: colorScheme.onSurface)),
        const SizedBox(height: 12),
        ..._buildMilestones(context),
        const SizedBox(height: 24),
        Text('Session History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.3, color: colorScheme.onSurface)),
        const SizedBox(height: 12),
        if (_sessions.isEmpty)
          const Text('No sessions saved yet.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary))
        else
          ..._sessions.map((s) => _buildSessionTile(context, s)),
      ],
    );
  }

  Widget _buildNoPlanCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.divider)),
      child: const Text('Generate a plan from the Body Scanner to start tracking your progress.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
    );
  }

  Widget _buildLevelCard(BuildContext context, AiCoachResult plan) {
    final colorScheme = Theme.of(context).colorScheme;
    final today = DateTime.now();
    final totalDays = plan.endDate.difference(plan.startDate).inDays.clamp(1, 999999);
    final elapsedDays = today.difference(plan.startDate).inDays.clamp(0, totalDays);
    final progress = elapsedDays / totalDays;
    final level = 1 + (progress * 9).floor();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [colorScheme.primary, colorScheme.tertiary], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: colorScheme.primary.withValues(alpha: 0.25), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                child: Text('LEVEL $level', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.2)),
              ),
              const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 28),
            ],
          ),
          const SizedBox(height: 18),
          const Text('Program Progress', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.3)),
          const SizedBox(height: 4),
          Text('Day ${elapsedDays.clamp(1, totalDays)} of $totalDays', style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(value: progress.clamp(0, 1), minHeight: 8, backgroundColor: Colors.white.withValues(alpha: 0.25), color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, {required IconData icon, required String title, required String value, required Color iconColor}) {
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withValues(alpha: 0.6))),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
        ],
      ),
    );
  }

  List<Widget> _buildMilestones(BuildContext context) {
    final milestones = <Widget>[];

    if (_sessions.isNotEmpty) {
      final first = _sessions.reduce((a, b) => a.date.isBefore(b.date) ? a : b);
      milestones.add(_buildMilestoneTile(context, icon: Icons.flag_rounded, title: 'First Session Completed', subtitle: _formatDate(first.date)));
    }
    if (_sessions.length >= 5) {
      milestones.add(_buildMilestoneTile(context, icon: Icons.fitness_center_rounded, title: '5 Sessions Completed', subtitle: 'Keep up the consistency'));
    }
    if (_sessions.length >= 20) {
      milestones.add(_buildMilestoneTile(context, icon: Icons.emoji_events_rounded, title: '20 Sessions Completed', subtitle: 'Serious dedication'));
    }
    if (_streak >= 3) {
      milestones.add(_buildMilestoneTile(context, icon: Icons.local_fire_department_rounded, title: '$_streak-Day Streak', subtitle: 'Rest days don\'t count against you'));
    }
    final highForm = _sessions.where((s) => s.formScorePercent >= 90).length;
    if (highForm > 0) {
      milestones.add(_buildMilestoneTile(context, icon: Icons.center_focus_strong_rounded, title: 'Excellent Form', subtitle: '$highForm session(s) at 90%+ form score'));
    }

    if (milestones.isEmpty) {
      milestones.add(const Text('Complete your first session to start unlocking milestones.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)));
    }

    return milestones.map((m) => Padding(padding: const EdgeInsets.only(bottom: 10), child: m)).toList();
  }

  Widget _buildMilestoneTile(BuildContext context, {required IconData icon, required String title, required String subtitle}) {
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: colorScheme.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: colorScheme.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withValues(alpha: 0.6))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionTile(BuildContext context, WorkoutSession session) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.divider)),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: AppColors.blue.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.check_circle_outline, size: 18, color: AppColors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_formatDate(session.date), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                Text('${session.durationMinutes} mins · ${session.totalReps} reps', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text('${session.formScorePercent}%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.green)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}