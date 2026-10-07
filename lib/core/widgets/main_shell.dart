import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'app_drawer.dart';
import '../../features/home/home_screen.dart';
import '../../features/tutorial/exercise_library_screen.dart';
import '../../features/dashboard/active_dashboard_screen.dart';
import '../../features/progress/progress_level_screen.dart';

class NavItemData {
  final String label;
  final String title;
  final IconData icon;
  final Widget body;

  const NavItemData({
    required this.label,
    required this.title,
    required this.icon,
    required this.body,
  });
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  final List<NavItemData> _items = const [
    NavItemData(
      label: 'Home',
      title: 'Home',
      icon: Icons.home_rounded,
      body: HomeScreenBody(),
    ),
    NavItemData(
      label: 'Exercises',
      title: 'Exercise Library',
      icon: Icons.pie_chart_outline_rounded,
      body: ExerciseLibraryScreenBody(),
    ),
    NavItemData(
      label: 'Dashboard',
      title: 'Active Dashboard',
      icon: Icons.access_time_rounded,
      body: ActiveDashboardScreenBody(),
    ),
    NavItemData(
      label: 'Progress',
      title: 'Progress & Level',
      icon: Icons.notifications_none_rounded,
      body: ProgressLevelScreenBody(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(_items[_selectedIndex].title),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        foregroundColor: colorScheme.onSurface,
      ),
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: _items.map((e) => e.body).toList(),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomFloatingNavBar(
              selectedIndex: _selectedIndex,
              items: _items,
              onTap: (index) => setState(() => _selectedIndex = index),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomFloatingNavBar extends StatelessWidget {
  final int selectedIndex;
  final List<NavItemData> items;
  final ValueChanged<int> onTap;

  const CustomFloatingNavBar({
    super.key,
    required this.selectedIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12, left: 35, right: 35),
          child: SizedBox(
            height: 84,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = constraints.maxWidth / items.length;

                return TweenAnimationBuilder<double>(
                  tween: Tween<double>(end: selectedIndex.toDouble()),
                  duration: const Duration(milliseconds: 380),
                  curve: Curves.fastOutSlowIn,
                  builder: (context, animValue, child) {
                    const buttonSize = 60.0;
                    final activeX = (animValue + 0.5) * itemWidth - (buttonSize / 2);

                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Curved Floating Base with Dynamic Edge Flattening
                        Positioned.fill(
                          top: 14,
                          child: CustomPaint(
                            painter: CurvedNavPainter(
                              position: animValue,
                              itemCount: items.length,
                              backgroundColor: colorScheme.surface,
                              borderColor: colorScheme.outline.withValues(alpha: 0.2),
                            ),
                          ),
                        ),

                        // Floating Green Active Icon Circle
                        Positioned(
                          left: activeX,
                          top: -6,
                          child: Container(
                            width: buttonSize,
                            height: buttonSize,
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary.withValues(alpha: 0.42),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Icon(
                              items[selectedIndex].icon,
                              color: colorScheme.brightness == Brightness.dark
                                  ? colorScheme.surface
                                  : Colors.white,
                              size: 28,
                            ),
                          ),
                        ),

                        // Navigation Icons & Labels
                        Positioned.fill(
                          top: 14,
                          child: Row(
                            children: List.generate(items.length, (index) {
                              final isSelected = index == selectedIndex;
                              final inactiveColor = colorScheme.onSurface.withValues(alpha: 0.45);

                              return Expanded(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => onTap(index),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (!isSelected) ...[
                                        Icon(
                                          items[index].icon,
                                          color: inactiveColor,
                                          size: 22,
                                        ),
                                        const SizedBox(height: 4),
                                      ],
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: AnimatedDefaultTextStyle(
                                          duration: const Duration(milliseconds: 200),
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                            color: isSelected ? colorScheme.primary : inactiveColor,
                                          ),
                                          child: Text(items[index].label),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class CurvedNavPainter extends CustomPainter {
  final double position;
  final int itemCount;
  final Color backgroundColor;
  final Color borderColor;

  CurvedNavPainter({
    required this.position,
    required this.itemCount,
    required this.backgroundColor,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final itemWidth = size.width / itemCount;
    final centerX = itemWidth * (position + 0.5);

    // Increased corner radius for a more rounded floating capsule look
    const cornerRadius = 38.0;
    const baseNotchDepth = 28.0;
    const baseNotchRadius = 36.0;

    // Calculate edge dampening factor (0.0 at far edges, 1.0 towards center)
    final double maxIndex = (itemCount - 1).toDouble();
    final double distFromEdge = position <= (maxIndex / 2) ? position : (maxIndex - position);
    
    // Smooth transition that removes notch completely when at the edge items (0 or maxIndex)
    final double notchFactor = Curves.easeInOut.transform((distFromEdge / 0.75).clamp(0.0, 1.0));
    
    final currentNotchDepth = baseNotchDepth * notchFactor;
    final currentNotchRadius = baseNotchRadius * notchFactor;

    path.moveTo(0, cornerRadius);
    path.quadraticBezierTo(0, 0, cornerRadius, 0);

    if (currentNotchDepth > 0.5) {
      final startX = (centerX - currentNotchRadius - 6).clamp(cornerRadius, size.width - cornerRadius);
      final endX = (centerX + currentNotchRadius + 6).clamp(cornerRadius, size.width - cornerRadius);

      final cp1X = (centerX - currentNotchRadius / 1.5).clamp(startX, centerX);
      final cp2X = (centerX - currentNotchRadius / 2.2).clamp(cp1X, centerX);
      final cp3X = (centerX + currentNotchRadius / 2.2).clamp(centerX, endX);
      final cp4X = (centerX + currentNotchRadius / 1.5).clamp(centerX, cp3X);

      path.lineTo(startX, 0);

      // Dynamic stretch-down notch
      path.cubicTo(
        cp1X, 0,
        cp2X, currentNotchDepth,
        centerX, currentNotchDepth,
      );
      path.cubicTo(
        cp3X, currentNotchDepth,
        cp4X, 0,
        endX, 0,
      );
    }

    path.lineTo(size.width - cornerRadius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, cornerRadius);
    path.lineTo(size.width, size.height - cornerRadius);
    path.quadraticBezierTo(size.width, size.height, size.width - cornerRadius, size.height);
    path.lineTo(cornerRadius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - cornerRadius);
    path.close();

    canvas.drawShadow(
      path,
      Colors.black.withValues(alpha: 0.12),
      10.0,
      true,
    );

    final fillPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    final strokePaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CurvedNavPainter oldDelegate) {
    return oldDelegate.position != position ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.borderColor != borderColor;
  }
}