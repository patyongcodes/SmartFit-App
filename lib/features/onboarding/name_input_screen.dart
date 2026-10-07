import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/onboarding_prefs.dart';

class NameInputScreen extends StatefulWidget {
  const NameInputScreen({super.key});

  @override
  State<NameInputScreen> createState() => _NameInputScreenState();
}

class _NameInputScreenState extends State<NameInputScreen>
    with TickerProviderStateMixin {
  final _controller = TextEditingController();
  String? _errorText;

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
    _controller.dispose();
    _entryController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      setState(() => _errorText = 'Please enter your name');
      return;
    }

    await _exitController.forward();
    await OnboardingPrefs.saveUserName(name);
    if (!mounted) return;
    context.go('/');
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
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(flex: 1),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.person_outline_rounded,
                        color: colorScheme.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "What's your name?",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "We'll use this to personalize your SmartFit experience.",
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurface.withValues(alpha: 0.65),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _controller,
                      autofocus: true,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter your name',
                        hintStyle: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                        errorText: _errorText,
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: colorScheme.primary, width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
                        ),
                      ),
                      onChanged: (_) {
                        if (_errorText != null) setState(() => _errorText = null);
                      },
                    ),
                    const Spacer(flex: 3),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _handleContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          elevation: 2,
                          shadowColor: colorScheme.primary.withValues(alpha: 0.35),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text(
                          'Continue',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
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
}