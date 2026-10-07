import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/onboarding_prefs.dart';

class LaunchDisclaimerScreen extends StatefulWidget {
  const LaunchDisclaimerScreen({super.key});

  @override
  State<LaunchDisclaimerScreen> createState() => _LaunchDisclaimerScreenState();
}

class _LaunchDisclaimerScreenState extends State<LaunchDisclaimerScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _exitController;

  late Animation<double> _fadeInAnimation;
  late Animation<double> _fadeOutAnimation;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _exitController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue(BuildContext context) async {
    await _exitController.forward();
    await OnboardingPrefs.setOnboardingComplete();
    if (!context.mounted) return;
    context.go('/main');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeOutAnimation,
        child: FadeTransition(
          opacity: _fadeInAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeInOut,
            color: colorScheme.surface,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                child: Column(
                  children: [
                    const Spacer(flex: 1),
                    _buildHeader(context),
                    const SizedBox(height: 28),
                    _buildNoticeCard(context),
                    const Spacer(flex: 2),
                    _buildFooterText(context),
                    const SizedBox(height: 16),
                    _buildContinueButton(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOut,
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'assets/images/smartfit.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'SmartFit',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'BIOMECHANICAL TRACKER',
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 2.2,
            color: colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildNoticeCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOut,
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.info_outline_rounded, color: colorScheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'IMPORTANT NOTICE',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 0.5,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'Please read before continuing',
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          _DisclaimerPoint(
            icon: Icons.bolt_rounded,
            badgeColor: colorScheme.primary.withValues(alpha: 0.12),
            iconColor: colorScheme.primary,
            text: 'SmartFit is an Educational Biomechanical Tracker designed to assist with movement consistency.',
          ),
          const SizedBox(height: 16),
          _DisclaimerPoint(
            icon: Icons.warning_amber_rounded,
            badgeColor: colorScheme.error.withValues(alpha: 0.12),
            iconColor: colorScheme.error,
            text: 'This is a prototype and NOT a medical device or injury prevention tool.',
          ),
          const SizedBox(height: 16),
          _DisclaimerPoint(
            icon: Icons.medical_services_outlined,
            badgeColor: colorScheme.tertiary.withValues(alpha: 0.12),
            iconColor: colorScheme.tertiary,
            text: 'Consult a qualified fitness professional before beginning any new exercise routine.',
          ),
        ],
      ),
    );
  }

  Widget _buildFooterText(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Text(
      'v1.0 Prototype · Not for Clinical Use',
      style: TextStyle(fontSize: 11, color: colorScheme.onSurface.withValues(alpha: 0.5)),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: () => _handleContinue(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 2,
          shadowColor: colorScheme.primary.withValues(alpha: 0.35),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Text(
          'I Understand & Continue',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _DisclaimerPoint extends StatelessWidget {
  final IconData icon;
  final Color badgeColor;
  final Color iconColor;
  final String text;

  const _DisclaimerPoint({
    required this.icon,
    required this.badgeColor,
    required this.iconColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: badgeColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurface.withValues(alpha: 0.85),
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}