import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../data/ai_coach/ai_coach_models.dart';

class WeeklyScheduleView extends StatefulWidget {
  final List<WorkoutDay> schedule;

  const WeeklyScheduleView({super.key, required this.schedule});

  @override
  State<WeeklyScheduleView> createState() => _WeeklyScheduleViewState();
}

class _WeeklyScheduleViewState extends State<WeeklyScheduleView> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.schedule.isEmpty) {
      return const Text('No schedule generated yet.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary));
    }

    final safeIndex = _selectedIndex.clamp(0, widget.schedule.length - 1);
    final selectedDay = widget.schedule[safeIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 64,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: widget.schedule.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final day = widget.schedule[index];
              final isSelected = index == safeIndex;
              final label = day.day.isNotEmpty ? day.day.substring(0, day.day.length >= 3 ? 3 : day.day.length) : '--';

              return GestureDetector(
                onTap: () => setState(() => _selectedIndex = index),
                child: Container(
                  width: 56,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.blue : AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: isSelected ? null : Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? AppColors.white : AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      Icon(
                        day.isRestDay ? Icons.bed : Icons.fitness_center,
                        size: 14,
                        color: isSelected ? AppColors.white : (day.isRestDay ? AppColors.green : AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        if (selectedDay.isRestDay)
          _buildRestDayCard()
        else if (selectedDay.exercises.isEmpty)
          const Text('No exercises listed for this day.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary))
        else
          Column(children: selectedDay.exercises.map(_buildExerciseTile).toList()),
        if (selectedDay.meals.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text('Meals', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          ...selectedDay.meals.map(_buildMealTile),
        ],
      ],
    );
  }

  Widget _buildRestDayCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.green.withValues(alpha: 0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.bed, color: AppColors.green, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Text('Rest Day — recovery is part of the plan.', style: TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          ),
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
}