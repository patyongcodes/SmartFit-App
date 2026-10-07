import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/constants/sensor_thresholds.dart';
import '../../data/sensor/sensor_service.dart';
import '../../data/sensor/sensor_reading.dart';
import '../../data/sessions/workout_session.dart';
import 'widgets/form_warning_modal.dart';

class ActiveDashboardScreen extends StatelessWidget {
  const ActiveDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Active Dashboard')),
      drawer: const AppDrawer(),
      body: const ActiveDashboardScreenBody(),
    );
  }
}

class ActiveDashboardScreenBody extends StatefulWidget {
  const ActiveDashboardScreenBody({super.key});

  @override
  State<ActiveDashboardScreenBody> createState() => _ActiveDashboardScreenBodyState();
}

class _ActiveDashboardScreenBodyState extends State<ActiveDashboardScreenBody> {
  StreamSubscription<SensorReading>? _subscription;
  SensorReading? _latest;
  int _reps = 0;
  bool _isAlertShowing = false;
  DateTime? _lastAlertTime;
  DateTime? _sessionStart;

  int _totalReadings = 0;
  int _postureBreaches = 0;
  int _jerkBreaches = 0;
  int _inZoneReadings = 0;

  @override
  void initState() {
    super.initState();
    _sessionStart = DateTime.now();
    final source = SensorService.instance.dataSource;
    if (!source.isConnected) {
      source.connect().then((_) => source.startStreaming());
    }
    _subscription = source.readings.listen(_onReading);
  }

  void _onReading(SensorReading reading) {
    if (!mounted) return;
    setState(() {
      _latest = reading;
      _reps++;
      _totalReadings++;

      if (reading.torsoLeanAngle > SensorThresholds.maxLeanAngle) _postureBreaches++;
      if (reading.jerk > SensorThresholds.maxJerk) _jerkBreaches++;
      if (reading.heartRate >= SensorThresholds.hrLowerBound && reading.heartRate <= SensorThresholds.hrUpperBound) {
        _inZoneReadings++;
      }
    });

    final isBreach = reading.jerk > SensorThresholds.maxJerk || reading.torsoLeanAngle > SensorThresholds.maxLeanAngle;
    final now = DateTime.now();
    final cooledDown = _lastAlertTime == null || now.difference(_lastAlertTime!) > const Duration(seconds: 5);

    if (isBreach && !_isAlertShowing && cooledDown) {
      _lastAlertTime = now;
      _showFormWarning(reading);
    }
  }

  void _showFormWarning(SensorReading reading) {
    _isAlertShowing = true;
    final isJerkIssue = reading.jerk > SensorThresholds.maxJerk;
    showFormWarningModal(
      context: context,
      message: isJerkIssue
          ? 'Movement is too erratic. Slow down your repetitions to maintain control and reduce jerk.'
          : 'Your posture is leaning beyond a safe range. Straighten your back.',
    ).then((_) => _isAlertShowing = false);
  }

  void _handleEndSession() {
    _subscription?.cancel();

    final duration = _sessionStart != null ? DateTime.now().difference(_sessionStart!) : Duration.zero;
    final total = _totalReadings == 0 ? 1 : _totalReadings;

    final postureScore = (1 - (_postureBreaches / total)).clamp(0, 1);
    final smoothnessScore = (1 - (_jerkBreaches / total)).clamp(0, 1);
    final hrZoneScore = (_inZoneReadings / total).clamp(0, 1);
    final formScorePercent = (((postureScore + smoothnessScore) / 2) * 100).round().clamp(0, 100);

    final session = WorkoutSession(
      date: DateTime.now(),
      title: 'Workout Session',
      durationMinutes: duration.inMinutes < 1 ? 1 : duration.inMinutes,
      totalReps: _reps,
      formScorePercent: formScorePercent,
      breakdown: {
        'Posture Control': double.parse(postureScore.toStringAsFixed(2)),
        'Movement Smoothness': double.parse(smoothnessScore.toStringAsFixed(2)),
        'Heart Rate Zone': double.parse(hrZoneScore.toStringAsFixed(2)),
      },
    );

    context.go('/summary', extra: session);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reading = _latest;
    if (reading == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.blue));
    }

    final isPostureSafe = reading.torsoLeanAngle <= SensorThresholds.maxLeanAngle;
    final isRepSmooth = reading.jerk <= SensorThresholds.maxJerk;
    final hrZone = _hrZoneLabel(reading.heartRate);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildHeartRateGauge(reading.heartRate, hrZone),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildStatusCard('Spinal Alignment', isPostureSafe ? 'Neutral / Safe' : 'Correction Needed', isPostureSafe)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatusCard('Rep Control', isRepSmooth ? 'Smooth' : 'Erratic', isRepSmooth)),
              ],
            ),
            const SizedBox(height: 20),
            _buildStatsRow(),
            const SizedBox(height: 24),
            _buildEndSessionButton(),
          ],
        ),
      ),
    );
  }

  String _hrZoneLabel(int hr) {
    if (hr < SensorThresholds.hrLowerBound) return 'Under-Exertion';
    if (hr > SensorThresholds.hrUpperBound) return 'High Exertion';
    return 'Moderate Exertion';
  }

  Widget _buildHeartRateGauge(int hr, String zone) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.divider)),
      child: Column(
        children: [
          const Text('HEART RATE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 1.2)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$hr', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const Padding(padding: EdgeInsets.only(bottom: 10, left: 4), child: Text('BPM', style: TextStyle(fontSize: 14, color: AppColors.textSecondary))),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(color: AppColors.green.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
            child: Text('Zone: $zone', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.green)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String title, String value, bool isGood) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.divider)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(isGood ? Icons.check_circle : Icons.warning_amber_rounded, size: 16, color: isGood ? AppColors.green : Colors.red),
              const SizedBox(width: 6),
              Expanded(child: Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isGood ? AppColors.green : Colors.red)),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.divider)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStat('REPS', '$_reps'),
          _buildStat('CALORIES', '${(_reps * 0.6).round()}'),
          _buildStat('LOAD', '${(60 + _reps).clamp(0, 100)}%'),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildEndSessionButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _handleEndSession,
        icon: const Icon(Icons.stop_circle_outlined, color: AppColors.white),
        label: const Text('End Session', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.white)),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade400, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      ),
    );
  }
}