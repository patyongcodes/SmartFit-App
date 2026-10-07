import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../main.dart';
import 'app_logo.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _navigate(BuildContext context, String path) {
    Navigator.pop(context);
    context.go(path);
  }

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.toString();
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      backgroundColor: colorScheme.surface,
      elevation: 16,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                children: [
                  _DrawerItem(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    path: '/main',
                    currentPath: currentPath,
                    onTap: () => _navigate(context, '/main'),
                  ),
                  _sectionLabel(context, 'ONBOARDING'),
                  _DrawerItem(
                    icon: Icons.camera_alt_outlined,
                    label: 'Body Scanner',
                    path: '/body-scanner',
                    currentPath: currentPath,
                    onTap: () => _navigate(context, '/body-scanner'),
                  ),
                  _DrawerItem(
                    icon: Icons.restaurant_menu_rounded,
                    label: 'AI Coach Plan',
                    path: '/plan-result',
                    currentPath: currentPath,
                    onTap: () => _navigate(context, '/plan-result'),
                  ),
                  _sectionLabel(context, 'WORKOUT'),
                  _DrawerItem(
                    icon: Icons.fitness_center_rounded,
                    label: 'Exercise Library',
                    path: '/tutorial',
                    currentPath: currentPath,
                    onTap: () => _navigate(context, '/tutorial'),
                  ),
                  _DrawerItem(
                    icon: Icons.play_circle_outline_rounded,
                    label: 'Tutorial Detail',
                    path: '/tutorial-detail',
                    currentPath: currentPath,
                    onTap: () => _navigate(context, '/tutorial-detail'),
                  ),
                  _DrawerItem(
                    icon: Icons.bluetooth_rounded,
                    label: 'Device Pairing',
                    path: '/pairing',
                    currentPath: currentPath,
                    onTap: () => _navigate(context, '/pairing'),
                  ),
                  _DrawerItem(
                    icon: Icons.tune_rounded,
                    label: 'Calibration',
                    path: '/calibration',
                    currentPath: currentPath,
                    onTap: () => _navigate(context, '/calibration'),
                  ),
                  _DrawerItem(
                    icon: Icons.access_time_rounded,
                    label: 'Active Dashboard',
                    path: '/dashboard',
                    currentPath: currentPath,
                    onTap: () => _navigate(context, '/dashboard'),
                  ),
                  _sectionLabel(context, 'PROGRESS'),
                  _DrawerItem(
                    icon: Icons.summarize_outlined,
                    label: 'Session Summary',
                    path: '/summary',
                    currentPath: currentPath,
                    onTap: () => _navigate(context, '/summary'),
                  ),
                  _DrawerItem(
                    icon: Icons.notifications_none_rounded,
                    label: 'Progress & Level',
                    path: '/progress',
                    currentPath: currentPath,
                    onTap: () => _navigate(context, '/progress'),
                  ),
                  _sectionLabel(context, 'PREFERENCES'),
                  
                  // Redesigned Modern Capsule Theme Selector
                  ValueListenableBuilder<ThemeMode>(
                    valueListenable: themeNotifier,
                    builder: (context, currentMode, child) {
                      return _ThemeCapsuleSelector(
                        currentMode: currentMode,
                        onChanged: (mode) => themeNotifier.value = mode,
                      );
                    },
                  ),
                ],
              ),
            ),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colorScheme.outline.withValues(alpha: 0.15), width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const AppLogo(size: 48),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SmartFit',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Biomechanical Tracker',
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 18, 12, 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: colorScheme.outline.withValues(alpha: 0.15))),
      ),
      child: SafeArea(
        top: false,
        child: Text(
          'v1.0 Prototype · Not for Clinical Use',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String path;
  final String currentPath;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.path,
    required this.currentPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentPath == path;
    final colorScheme = Theme.of(context).colorScheme;
    final activeColor = colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: isSelected
            ? activeColor.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? activeColor
                        : colorScheme.onSurface.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: isSelected
                        ? (colorScheme.brightness == Brightness.dark
                            ? colorScheme.surface
                            : Colors.white)
                        : colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? activeColor : colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeCapsuleSelector extends StatelessWidget {
  final ThemeMode currentMode;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeCapsuleSelector({
    required this.currentMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final options = const [
      (ThemeMode.system, Icons.hdr_auto_rounded, 'System'),
      (ThemeMode.light, Icons.light_mode_rounded, 'Light'),
      (ThemeMode.dark, Icons.dark_mode_rounded, 'Dark'),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: options.map((option) {
          final mode = option.$1;
          final icon = option.$2;
          final label = option.$3;
          final isSelected = currentMode == mode;

          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(mode),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? colorScheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 15,
                      color: isSelected
                          ? (colorScheme.brightness == Brightness.dark
                              ? colorScheme.surface
                              : Colors.white)
                          : colorScheme.onSurface.withValues(alpha: 0.65),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? (colorScheme.brightness == Brightness.dark
                                ? colorScheme.surface
                                : Colors.white)
                            : colorScheme.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}