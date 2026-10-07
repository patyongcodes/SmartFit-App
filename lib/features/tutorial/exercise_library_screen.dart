import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_drawer.dart';
import '../../data/ai_coach/ai_coach_models.dart';
import '../../data/ai_coach/ai_coach_storage.dart';
import '../../data/ai_coach/program_calendar.dart';
import '../../data/sessions/session_storage.dart';

class ExerciseLibraryScreen extends StatelessWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exercise Library')),
      drawer: const AppDrawer(),
      body: const ExerciseLibraryScreenBody(),
    );
  }
}

class ExerciseLibraryScreenBody extends StatefulWidget {
  const ExerciseLibraryScreenBody({super.key});

  @override
  State<ExerciseLibraryScreenBody> createState() => _ExerciseLibraryScreenBodyState();
}

class _ExerciseLibraryScreenBodyState extends State<ExerciseLibraryScreenBody> {
  static const _weekdayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  AiCoachResult? _plan;
  List<List<ScheduledDay>> _weeks = [];
  int _weekIndex = 0;
  int _dayIndex = 0;
  bool _isLoading = true;
  bool _hasSessionToday = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final plan = await AiCoachStorage.loadPlan();
    if (!mounted) return;

    if (plan == null) {
      setState(() => _isLoading = false);
      return;
    }

    final calendar = ProgramCalendar.generate(plan);
    final weeks = ProgramCalendar.groupByWeek(calendar);
    final today = DateTime.now();

    var weekIdx = 0;
    var dayIdx = 0;
    for (var w = 0; w < weeks.length; w++) {
      final idx = weeks[w].indexWhere((d) => d.isSameDate(today));
      if (idx != -1) {
        weekIdx = w;
        dayIdx = idx;
        break;
      }
    }

    final hasSession = await SessionStorage.hasSessionOnDate(today);

    if (!mounted) return;
    setState(() {
      _plan = plan;
      _weeks = weeks;
      _weekIndex = weekIdx;
      _dayIndex = dayIdx;
      _hasSessionToday = hasSession;
      _isLoading = false;
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
              Icons.auto_awesome_rounded,
              size: 72,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              'No Program Generated',
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
              'Scan your body metrics with the AI Body Scanner to generate your personalized workout schedule.',
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
                onPressed: () => context.push('/body-scanner'),
                icon: const Icon(Icons.document_scanner_outlined, size: 20),
                label: const Text(
                  'Open Body Scanner',
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.blue));
    }

    final plan = _plan;
    if (plan == null || _weeks.isEmpty) {
      return _buildEmptyState(context);
    }

    final week = _weeks[_weekIndex];
    final selectedDay = week[_dayIndex];
    final today = DateTime.now();
    final isSelectedToday = selectedDay.isSameDate(today);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your Program', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text('${_formatDate(plan.startDate)} — ${_formatDate(plan.endDate)}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            _buildWeekNav(week),
            const SizedBox(height: 12),
            _buildWeekStrip(week, today),
            const SizedBox(height: 20),
            if (selectedDay.isBeforeStart || selectedDay.isAfterEnd)
              _buildOutOfProgramCard(selectedDay)
            else ...[
              _buildDayHeader(selectedDay),
              const SizedBox(height: 12),
              if (selectedDay.template.isRestDay)
                _buildRestDayCard()
              else ...[
                ...selectedDay.template.exercises.map(_buildExerciseTile),
                const SizedBox(height: 8),
                if (isSelectedToday) _buildStartExerciseButton(context),
              ],
              const SizedBox(height: 24),
              const Text('Meals for this day', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              if (selectedDay.template.meals.isEmpty)
                const Text('No meals listed for this day.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary))
              else
                ...selectedDay.template.meals.map(_buildMealTile),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWeekNav(List<ScheduledDay> week) {
    final rangeLabel = '${_formatDate(week.first.date)} - ${_formatDate(week.last.date)}';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: _weekIndex > 0 ? () => setState(() { _weekIndex--; _dayIndex = 0; }) : null,
          icon: const Icon(Icons.chevron_left),
          color: AppColors.textPrimary,
        ),
        Text(rangeLabel, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        IconButton(
          onPressed: _weekIndex < _weeks.length - 1 ? () => setState(() { _weekIndex++; _dayIndex = 0; }) : null,
          icon: const Icon(Icons.chevron_right),
          color: AppColors.textPrimary,
        ),
      ],
    );
  }

  Widget _buildWeekStrip(List<ScheduledDay> week, DateTime today) {
    return Row(
      children: List.generate(week.length, (index) {
        final day = week[index];
        final isSelected = index == _dayIndex;
        final isToday = day.isSameDate(today);
        final isMuted = day.isBeforeStart || day.isAfterEnd;

        Color bgColor;
        Color textColor;
        if (isSelected) {
          bgColor = AppColors.blue;
          textColor = AppColors.white;
        } else if (isMuted) {
          bgColor = AppColors.background;
          textColor = AppColors.textSecondary;
        } else {
          bgColor = AppColors.cardBackground;
          textColor = AppColors.textPrimary;
        }

        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _dayIndex = index),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isToday && !isSelected ? AppColors.blue : (isMuted ? AppColors.divider : Colors.transparent),
                  width: isToday && !isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                children: [
                  Text(_weekdayLabels[index], style: TextStyle(fontSize: 10, color: isSelected ? AppColors.white70 : textColor)),
                  const SizedBox(height: 4),
                  Text('${day.date.day}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 4),
                  Icon(
                    day.template.isRestDay ? Icons.bed : Icons.fitness_center,
                    size: 12,
                    color: isSelected ? AppColors.white : (isMuted ? AppColors.textSecondary : (day.template.isRestDay ? AppColors.green : AppColors.blue)),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildOutOfProgramCard(ScheduledDay day) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.divider)),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              day.isBeforeStart ? 'This day is before your program started.' : 'This day is after your program\'s planned finish.',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayHeader(ScheduledDay day) {
    final muscles = day.template.targetMuscles.join(', ');
    return Text(
      day.template.isRestDay ? 'Rest Day' : (muscles.isNotEmpty ? muscles : 'Workout Day'),
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
    );
  }

  Widget _buildRestDayCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.green.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.green.withValues(alpha: 0.3))),
      child: const Row(
        children: [
          Icon(Icons.bed, color: AppColors.green, size: 22),
          SizedBox(width: 12),
          Expanded(child: Text('Rest Day — recovery is part of the plan.', style: TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _buildExerciseTile(ExerciseRecommendation ex) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.divider)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: AppColors.green.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.fitness_center, size: 18, color: AppColors.green),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(ex.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
                    if (ex.muscleGroup.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                        child: Text(ex.muscleGroup, style: const TextStyle(fontSize: 10, color: AppColors.blue, fontWeight: FontWeight.w600)),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(ex.description, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text('${ex.sets} sets × ${ex.reps} reps', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealTile(MealItem meal) {
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
            child: const Icon(Icons.restaurant, size: 18, color: AppColors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(meal.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                Text(meal.description, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text('${meal.calories} kcal', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildStartExerciseButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: _hasSessionToday ? null : () => context.push('/dashboard'),
        icon: const Icon(Icons.play_arrow, color: AppColors.white),
        label: Text(
          _hasSessionToday ? "Today's Session Completed" : 'Start Exercise',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.green,
          disabledBackgroundColor: AppColors.divider,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }
}