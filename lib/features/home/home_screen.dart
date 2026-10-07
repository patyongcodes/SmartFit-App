import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/services/onboarding_prefs.dart';
import '../../data/ai_coach/ai_coach_models.dart';
import '../../data/ai_coach/ai_coach_storage.dart';
import '../../data/ai_coach/program_calendar.dart';
import '../../data/sessions/session_storage.dart';
import '../../data/sessions/streak_calculator.dart';
import '../../data/sessions/workout_session.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Dashboard'),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      drawer: const AppDrawer(),
      body: const HomeScreenBody(),
    );
  }
}

class HomeScreenBody extends StatefulWidget {
  const HomeScreenBody({super.key});

  @override
  State<HomeScreenBody> createState() => _HomeScreenBodyState();
}

class _HomeScreenBodyState extends State<HomeScreenBody>
    with SingleTickerProviderStateMixin {
  String _userName = '';
  AiCoachResult? _plan;
  List<ScheduledDay> _currentWeek = [];
  ScheduledDay? _today;
  List<WorkoutSession> _sessions = [];
  int _streak = 0;
  double? _avgFormScore;
  int _repsThisWeek = 0;
  bool _isLoading = true;

  late AnimationController _fadeController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _fadeInAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );

    _load();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final name = await OnboardingPrefs.getUserName();
    final plan = await AiCoachStorage.loadPlan();
    final sessions = await SessionStorage.getAllSessions();

    var currentWeek = <ScheduledDay>[];
    ScheduledDay? today;
    var streak = 0;

    if (plan != null) {
      final calendar = ProgramCalendar.generate(plan);
      final weeks = ProgramCalendar.groupByWeek(calendar);
      final now = DateTime.now();
      for (final week in weeks) {
        final idx = week.indexWhere((d) => d.isSameDate(now));
        if (idx != -1) {
          currentWeek = week;
          today = week[idx];
          break;
        }
      }
      streak = StreakCalculator.calculate(calendar: calendar, sessions: sessions, today: now);
    }

    double? avgForm;
    if (sessions.isNotEmpty) {
      final total = sessions.fold<int>(0, (sum, s) => sum + s.formScorePercent);
      avgForm = total / sessions.length;
    }

    var repsThisWeek = 0;
    if (currentWeek.isNotEmpty) {
      final weekStart = currentWeek.first.date;
      final weekEnd = currentWeek.last.date;
      for (final s in sessions) {
        final d = DateTime(s.date.year, s.date.month, s.date.day);
        if (!d.isBefore(weekStart) && !d.isAfter(weekEnd)) {
          repsThisWeek += s.totalReps;
        }
      }
    }

    if (!mounted) return;
    setState(() {
      _userName = (name == null || name.isEmpty) ? 'Athlete' : name;
      _plan = plan;
      _currentWeek = currentWeek;
      _today = today;
      _sessions = sessions;
      _streak = streak;
      _avgFormScore = avgForm;
      _repsThisWeek = repsThisWeek;
      _isLoading = false;
    });

    _fadeController.forward();
  }

  bool _hasSessionOn(DateTime date) {
    return _sessions.any((s) => s.date.year == date.year && s.date.month == date.month && s.date.day == date.day);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: Colors.white,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final bottomInset = MediaQuery.of(context).padding.bottom;

    return FadeTransition(
      opacity: _fadeInAnimation,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
        color: Colors.white,
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              80 + bottomInset,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 20),
                _buildActiveSessionHero(context),
                const SizedBox(height: 18),
                _buildMetricsRow(context),
                const SizedBox(height: 22),
                _buildSectionHeader(
                  context,
                  title: 'Weekly Schedule',
                  actionLabel: 'This Week',
                  onAction: () => context.push('/tutorial'),
                ),
                const SizedBox(height: 12),
                _buildCalendarStrip(context),
                const SizedBox(height: 22),
                _buildSectionHeader(
                  context,
                  title: 'Scheduled Routine',
                  actionLabel: 'View All',
                  onAction: () => context.push('/tutorial'),
                ),
                const SizedBox(height: 12),
                _buildWorkoutList(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 450),
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3), width: 2),
              ),
              child: Icon(Icons.person_outline_rounded, color: colorScheme.primary, size: 28),
            ),
            Positioned(
              right: 2,
              bottom: 2,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: colorScheme.secondary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'WELCOME BACK',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _userName,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.4,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 450),
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            shape: BoxShape.circle,
            border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
          ),
          child: IconButton(
            onPressed: () {},
            icon: Icon(Icons.tune_rounded, color: colorScheme.onSurface, size: 22),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveSessionHero(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final plan = _plan;

    if (plan == null) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded, size: 16, color: colorScheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        'NO PROGRAM YET',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Generate Your Plan',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Scan your body to get a personalized workout and meal program.',
              style: TextStyle(
                fontSize: 14,
                height: 1.35,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/body-scanner'),
                icon: const Icon(Icons.camera_alt_outlined, size: 22),
                label: const Text(
                  'Get Started',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  elevation: 2,
                  shadowColor: colorScheme.primary.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final today = _today;
    final isRestDay = today?.template.isRestDay ?? false;
    final muscles = today?.template.targetMuscles.join(' & ') ?? '';
    final totalDays = plan.endDate.difference(plan.startDate).inDays.clamp(1, 999999);
    final elapsedDays = DateTime.now().difference(plan.startDate).inDays.clamp(0, totalDays) + 1;

    final badgeLabel = isRestDay ? 'REST DAY' : 'PROGRAM ACTIVE';
    final badgeIcon = isRestDay ? Icons.bed_rounded : Icons.sensors_rounded;
    final title = isRestDay ? 'Recovery Day' : (muscles.isNotEmpty ? '$muscles Session' : 'Training Session');
    final subtitle = isRestDay
        ? 'No workout scheduled — recovery is part of the plan.'
        : "Complete today's exercises to keep your streak going.";

    return AnimatedContainer(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOut,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(badgeIcon, size: 16, color: colorScheme.primary),
                    const SizedBox(width: 6),
                    Text(
                      badgeLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                'Day $elapsedDays of $totalDays',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface.withValues(alpha: 0.65),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.3,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              height: 1.35,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: isRestDay ? null : () => context.push('/tutorial'),
              icon: const Icon(Icons.play_arrow_rounded, size: 22),
              label: Text(
                isRestDay ? 'Resting Today' : 'Start Tracking Session',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                disabledBackgroundColor: colorScheme.primary.withValues(alpha: 0.4),
                elevation: 2,
                shadowColor: colorScheme.primary.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsRow(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final formScoreText = _avgFormScore == null ? '—' : '${_avgFormScore!.round()}%';
    final formScoreTrend = _sessions.isEmpty ? 'No data' : '${_sessions.length} logged';
    final streakTrend = _streak > 0 ? 'Active' : 'Start Today';

    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            label: 'Avg Form Score',
            value: formScoreText,
            trend: formScoreTrend,
            icon: Icons.speed_rounded,
            accentColor: colorScheme.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MetricCard(
            label: 'Active Streak',
            value: '$_streak Days',
            trend: streakTrend,
            icon: Icons.bolt_rounded,
            accentColor: colorScheme.secondary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MetricCard(
            label: 'Reps Tracked',
            value: '$_repsThisWeek',
            trend: 'This Wk',
            icon: Icons.equalizer_rounded,
            accentColor: colorScheme.tertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarStrip(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final week = _currentWeek;

    if (week.isEmpty) {
      return Text(
        'Generate a plan to see your weekly schedule.',
        style: TextStyle(fontSize: 13, color: colorScheme.onSurface.withValues(alpha: 0.6)),
      );
    }

    const dayLabels = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    final now = DateTime.now();
    final selectedIndex = week.indexWhere((d) => d.isSameDate(now));

    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: week.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final day = week[index];
          final isSelected = index == selectedIndex;
          final isFuture = day.date.isAfter(DateTime(now.year, now.month, now.day));
          final isDone = day.template.isRestDay ? !isFuture : (!isFuture && _hasSessionOn(day.date));

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 58,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.outline.withValues(alpha: 0.2),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dayLabels[index],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: isSelected
                        ? colorScheme.onPrimary.withValues(alpha: 0.85)
                        : colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
                Text(
                  '${day.date.day}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                  ),
                ),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isDone
                        ? (isSelected ? colorScheme.onPrimary : colorScheme.primary)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: isDone
                        ? null
                        : Border.all(
                            color: isSelected
                                ? colorScheme.onPrimary.withValues(alpha: 0.5)
                                : colorScheme.outline.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                  ),
                  child: isDone
                      ? Icon(
                          Icons.check_rounded,
                          size: 13,
                          color: isSelected ? colorScheme.primary : colorScheme.onPrimary,
                        )
                      : null,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required String actionLabel,
    VoidCallback? onAction,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
            color: colorScheme.onSurface,
          ),
        ),
        TextButton(
          onPressed: onAction,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            actionLabel,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutList(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final today = _today;

    if (today == null) {
      return Text(
        'No schedule available yet.',
        style: TextStyle(fontSize: 13, color: colorScheme.onSurface.withValues(alpha: 0.6)),
      );
    }
    if (today.template.isRestDay) {
      return Text(
        'Rest day — no exercises scheduled today.',
        style: TextStyle(fontSize: 13, color: colorScheme.onSurface.withValues(alpha: 0.6)),
      );
    }

    final exercises = today.template.exercises;
    if (exercises.isEmpty) {
      return Text(
        'No exercises listed for today.',
        style: TextStyle(fontSize: 13, color: colorScheme.onSurface.withValues(alpha: 0.6)),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < exercises.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _WorkoutListItem(
            title: exercises[i].name,
            subtitle: '${exercises[i].muscleGroup} • ${exercises[i].sets} Sets × ${exercises[i].reps} Reps',
            time: 'Today',
            icon: Icons.fitness_center_rounded,
          ),
        ],
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String trend;
  final IconData icon;
  final Color accentColor;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.trend,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 450),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
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
              Icon(icon, size: 18, color: accentColor),
              const SizedBox(width: 4),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    trend,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.2,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface.withValues(alpha: 0.65),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _WorkoutListItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;

  const _WorkoutListItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 450),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: colorScheme.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
            ),
            child: Text(
              time,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}