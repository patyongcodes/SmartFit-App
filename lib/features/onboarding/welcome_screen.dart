import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/onboarding_prefs.dart';
import '../../core/widgets/app_logo.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  bool? _isFirstLaunch;
  String? _userName;

  late AnimationController _controller;
  late AnimationController _exitController;

  // Staggered Entrance Animations
  late Animation<double> _screenFadeInAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<Offset> _logoSlideAnimation;
  late Animation<double> _contentFadeAnimation;
  late Animation<Offset> _contentSlideAnimation;
  late Animation<double> _bottomFadeAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _exitFadeAnimation;

  Timer? _messageTimer;
  int _currentMessageIndex = 0;

  final List<String> _loadingMessages = const [
    'Initializing local edge engine...',
    'Connecting BLE wrist & torso nodes...',
    'Calibrating posture & form baselines...',
    'Preparing real-time dashboard...',
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    // Initial Screen Fade In
    _screenFadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.15, curve: Curves.easeOut),
      ),
    );

    // Stagger 1: Logo Entry (Clean slide-up + fade)
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.05, 0.30, curve: Curves.easeOutCubic),
      ),
    );
    _logoSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.05, 0.30, curve: Curves.easeOutCubic),
      ),
    );

    // Stagger 2: Text Content Entry
    _contentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.20, 0.45, curve: Curves.easeOutCubic),
      ),
    );
    _contentSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.10),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.20, 0.45, curve: Curves.easeOutCubic),
      ),
    );

    // Stagger 3: Bottom Section Entry
    _bottomFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.60, curve: Curves.easeOut),
      ),
    );

    // Continuous Progress Indicator
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.12, 1.0, curve: Curves.easeInOutCubic),
      ),
    );

    // Exit Transition
    _exitFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _exitController,
        curve: Curves.easeInCubic,
      ),
    );

    _startMessageCycle();
    _checkOnboardingStatus();
  }

  void _startMessageCycle() {
    _messageTimer = Timer.periodic(const Duration(milliseconds: 750), (_) {
      if (mounted && _isFirstLaunch == false) {
        setState(() {
          _currentMessageIndex =
              (_currentMessageIndex + 1) % _loadingMessages.length;
        });
      }
    });
  }

  Future<void> _checkOnboardingStatus() async {
    final isComplete = await OnboardingPrefs.isOnboardingComplete();
    final storedName = await OnboardingPrefs.getUserName();
    if (!mounted) return;

    setState(() {
      _isFirstLaunch = !isComplete;
      _userName = storedName;
    });

    _controller.forward();

    if (isComplete) {
      _controller.addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          _exitController.forward().then((_) {
            if (mounted) {
              context.go('/main');
            }
          });
        }
      });
    }
  }

  void _handleGetStarted() {
    _exitController.forward().then((_) {
      if (mounted) {
        context.go('/name-input');
      }
    });
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    _controller.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final isReturningUser = _isFirstLaunch == false;
    final hasName = _userName != null && _userName!.trim().isNotEmpty;

    final titleText = isReturningUser && hasName
        ? 'Welcome back, ${_userName!.trim()}!'
        : 'SmartFit';

    final subtitleText = isReturningUser
        ? 'Real-time posture & form evaluation ready.'
        : 'Wearable IoT exercise form & posture evaluation';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: FadeTransition(
        opacity: _exitFadeAnimation,
        child: FadeTransition(
          opacity: _screenFadeInAnimation,
          child: Center(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(flex: 3),

                    // Completely Clean Logo (No containers, glows, or background shapes)
                    FadeTransition(
                      opacity: _logoFadeAnimation,
                      child: SlideTransition(
                        position: _logoSlideAnimation,
                        child: const AppLogo(size: 88),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Staggered Title & Hardware Badge Section
                    FadeTransition(
                      opacity: _contentFadeAnimation,
                      child: SlideTransition(
                        position: _contentSlideAnimation,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Sleek Hardware Status Chip
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: colorScheme.primary.withValues(alpha: 0.15),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'WEARABLE IOT SYSTEM',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.2,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            Text(
                              titleText,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isReturningUser && hasName ? 26 : 34,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.6,
                                color: colorScheme.onSurface,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              subtitleText,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.45,
                                color: colorScheme.onSurface.withValues(alpha: 0.6),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(flex: 3),

                    // Staggered Loading / CTA Action Section
                    FadeTransition(
                      opacity: _bottomFadeAnimation,
                      child: _buildBottomSection(colorScheme),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSection(ColorScheme colorScheme) {
    if (_isFirstLaunch == null) {
      return const SizedBox(height: 60);
    }

    if (_isFirstLaunch!) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _handleGetStarted,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Get Started',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded, size: 18),
            ],
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Smooth Loading Microcopy Switcher
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.15),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: Text(
            _loadingMessages[_currentMessageIndex],
            key: ValueKey<int>(_currentMessageIndex),
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.1,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Refined Edge Progress Capsule
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            final progress = _progressAnimation.value;
            return Container(
              width: 170,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}