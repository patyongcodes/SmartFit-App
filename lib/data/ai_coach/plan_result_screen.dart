import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/widgets/weekly_schedule_view.dart';
import '../../data/ai_coach/ai_coach_models.dart';
import '../../data/ai_coach/ai_coach_storage.dart';

class PlanResultScreen extends StatefulWidget {
  final AiCoachResult? result;

  const PlanResultScreen({super.key, this.result});

  @override
  State<PlanResultScreen> createState() => _PlanResultScreenState();
}

class _PlanResultScreenState extends State<PlanResultScreen> {
  AiCoachResult? _plan;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _resolvePlan();
  }

  Future<void> _resolvePlan() async {
    if (widget.result != null) {
      setState(() {
        _plan = widget.result;
        _isLoading = false;
      });
      return;
    }
    final saved = await AiCoachStorage.loadPlan();
    if (!mounted) return;
    setState(() {
      _plan = saved;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('AI Coach Plan')),
        drawer: const AppDrawer(),
        body: const Center(child: CircularProgressIndicator(color: AppColors.blue)),
      );
    }

    final plan = _plan;
    if (plan == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('AI Coach Plan')),
        drawer: const AppDrawer(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.info_outline, size: 40, color: AppColors.textSecondary),
                const SizedBox(height: 12),
                const Text('No plan generated yet.', style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.push('/body-scanner'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('Go to Body Scanner', style: TextStyle(color: AppColors.white)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final timelineChanged = plan.adjustedTimelineMonths != plan.originalTimelineMonths;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('AI Coach Plan')),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTimelineCard(plan, timelineChanged),
              const SizedBox(height: 16),
              _buildBodyCompositionCard(plan),
              const SizedBox(height: 16),
              _buildNutritionCard(plan),
              const SizedBox(height: 24),
              const Text('Weekly Workout & Meal Schedule', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              const Text('Tap a day to view its exercises and meals', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              WeeklyScheduleView(schedule: plan.weeklySchedule),
              const SizedBox(height: 32),
              _buildContinueButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineCard(AiCoachResult plan, bool changed) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.divider)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle_outline, color: AppColors.green, size: 20),
              SizedBox(width: 8),
              Text('TIMELINE REALITY CHECK', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 16),
          if (changed)
            Row(
              children: [
                Text('${plan.originalTimelineMonths} Months', style: const TextStyle(fontSize: 18, color: AppColors.textSecondary, decoration: TextDecoration.lineThrough)),
                const SizedBox(width: 10),
                const Icon(Icons.arrow_forward, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 10),
                Text('${plan.adjustedTimelineMonths} Months', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.green)),
              ],
            )
          else
            Text('${plan.adjustedTimelineMonths} Months', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.green)),
          const SizedBox(height: 4),
          Text('${_formatDate(plan.startDate)} → ${_formatDate(plan.endDate)}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Text(plan.aiNote, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildBodyCompositionCard(AiCoachResult plan) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.divider)),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: AppColors.blue.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.accessibility_new, color: AppColors.blue),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Estimated Body Fat', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                Text(
                  '${plan.bodyFatPercent.toStringAsFixed(1)}% · ${plan.bodyFatCategory}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionCard(AiCoachResult plan) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.blue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.blue.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bedtime_outlined, color: AppColors.blue, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(plan.sleepRecommendation, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w600))),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.local_fire_department_outlined, color: AppColors.blue, size: 20),
              const SizedBox(width: 8),
              Text('${plan.dailyCalories} kcal/day', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMacroChip('Protein', '${plan.proteinG}g'),
              _buildMacroChip('Carbs', '${plan.carbG}g'),
              _buildMacroChip('Fat', '${plan.fatG}g'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroChip(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.blue)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () => context.go('/tutorial'),
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        child: const Text('View Exercise Tutorials', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.white)),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }
}