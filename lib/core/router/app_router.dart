import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/main_shell.dart';
import '../../features/onboarding/welcome_screen.dart';
import '../../features/onboarding/name_input_screen.dart';
import '../../features/onboarding/launch_disclaimer_screen.dart';
import '../../features/ai_coach/body_scanner_screen.dart';
import '../../features/ai_coach/plan_result_screen.dart';
import '../../features/tutorial/exercise_library_screen.dart';
import '../../features/tutorial/tutorial_detail_screen.dart';
import '../../features/pairing_calibration/device_pairing_screen.dart';
import '../../features/pairing_calibration/calibration_screen.dart';
import '../../features/dashboard/active_dashboard_screen.dart';
import '../../features/progress/session_summary_screen.dart';
import '../../features/progress/progress_level_screen.dart';
import '../../features/home/home_screen.dart';
import '../../data/ai_coach/ai_coach_models.dart';
import '../../data/sessions/workout_session.dart';

CustomTransitionPage _buildPageWithTransition({required GoRouterState state, required Widget child}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      final slide = Tween<Offset>(begin: const Offset(0.04, 0), end: Offset.zero)
          .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      return FadeTransition(opacity: fade, child: SlideTransition(position: slide, child: child));
    },
  );
}

final appRouter = GoRouter(
  initialLocation: '/welcome',
  routes: [
    GoRoute(path: '/welcome', pageBuilder: (context, state) => _buildPageWithTransition(state: state, child: const WelcomeScreen())),
    GoRoute(path: '/name-input', pageBuilder: (context, state) => _buildPageWithTransition(state: state, child: const NameInputScreen())),
    GoRoute(path: '/', pageBuilder: (context, state) => _buildPageWithTransition(state: state, child: const LaunchDisclaimerScreen())),
    GoRoute(path: '/body-scanner', pageBuilder: (context, state) => _buildPageWithTransition(state: state, child: const BodyScannerScreen())),
    GoRoute(
      path: '/plan-result',
      pageBuilder: (context, state) => _buildPageWithTransition(state: state, child: PlanResultScreen(result: state.extra as AiCoachResult?)),
    ),
    GoRoute(path: '/tutorial', pageBuilder: (context, state) => _buildPageWithTransition(state: state, child: const ExerciseLibraryScreen())),
    GoRoute(path: '/tutorial-detail', pageBuilder: (context, state) => _buildPageWithTransition(state: state, child: const TutorialDetailScreen())),
    GoRoute(path: '/pairing', pageBuilder: (context, state) => _buildPageWithTransition(state: state, child: const DevicePairingScreen())),
    GoRoute(path: '/calibration', pageBuilder: (context, state) => _buildPageWithTransition(state: state, child: const CalibrationScreen())),
    GoRoute(path: '/dashboard', pageBuilder: (context, state) => _buildPageWithTransition(state: state, child: const ActiveDashboardScreen())),
    GoRoute(
      path: '/summary',
      pageBuilder: (context, state) => _buildPageWithTransition(state: state, child: SessionSummaryScreen(session: state.extra as WorkoutSession?)),
    ),
    GoRoute(path: '/progress', pageBuilder: (context, state) => _buildPageWithTransition(state: state, child: const ProgressLevelScreen())),
    GoRoute(path: '/home', pageBuilder: (context, state) => _buildPageWithTransition(state: state, child: const HomeScreen())),
    GoRoute(path: '/main', pageBuilder: (context, state) => _buildPageWithTransition(state: state, child: const MainShell())),
  ],
);