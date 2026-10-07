import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('AI Coach Plan')),
        drawer: const AppDrawer(),
        body: Center(
          child: CircularProgressIndicator(color: colorScheme.primary),
        ),
      );
    }

    final plan = _plan;
    if (plan == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('AI Coach Plan')),
        drawer: const AppDrawer(),
        body: Center(
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
                  'No Plan Generated Yet',
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
                  'Scan your body metrics with the AI Body Scanner to generate your custom AI workout plan.',
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final timelineChanged = plan.adjustedTimelineMonths != plan.originalTimelineMonths;

    return Scaffold(
      appBar: AppBar(title: const Text('AI Coach Plan')),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTimelineCard(context, plan, timelineChanged),
              const SizedBox(height: 16),
              _buildDailyTargetsCard(context, plan),
              const SizedBox(height: 24),
              Text(
                'Weekly Workout & Meal Schedule',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tap a day to view its exercises and meals',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface.withValues(alpha: 0.65),
                ),
              ),
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

  Widget _buildTimelineCard(BuildContext context, AiCoachResult plan, bool changed) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle_outline, color: colorScheme.secondary, size: 20),
              const SizedBox(width: 8),
              Text(
                'TIMELINE REALITY CHECK',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (changed)
            Row(
              children: [
                Text(
                  '${plan.originalTimelineMonths} Months',
                  style: TextStyle(
                    fontSize: 18,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(width: 10),
                Icon(Icons.arrow_forward, size: 16, color: colorScheme.onSurface.withValues(alpha: 0.65)),
                const SizedBox(width: 10),
                Text(
                  '${plan.adjustedTimelineMonths} Months',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.secondary,
                  ),
                ),
              ],
            )
          else
            Text(
              '${plan.adjustedTimelineMonths} Months',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.secondary,
              ),
            ),
          const SizedBox(height: 4),
          Text(
            '${_formatDate(plan.startDate)} → ${_formatDate(plan.endDate)}',
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurface.withValues(alpha: 0.65),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            plan.aiNote,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurface,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTargetsCard(BuildContext context, AiCoachResult plan) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(Icons.bedtime_outlined, color: colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    plan.sleepRecommendation,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 32, color: colorScheme.primary.withValues(alpha: 0.2)),
          const SizedBox(width: 12),
          Row(
            children: [
              Icon(Icons.local_fire_department_outlined, color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                '${plan.dailyCalories} kcal/day',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () => context.go('/tutorial'),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text(
          'View Exercise Tutorials',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }
}