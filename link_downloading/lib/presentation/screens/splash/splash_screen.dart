import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_config.dart';
import '../../providers/app_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _controller.forward();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(AppConfig.splashDuration);
    if (!mounted) return;
    final settings = ref.read(settingsProvider);
    if (settings.onboardingCompleted) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pushReplacementNamed('/onboarding');
    }
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(opacity: _fadeAnimation,
        child: ScaleTransition(scale: _scaleAnimation,
          child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Spacer(),
            Container(width: 120, height: 120,
              decoration: BoxDecoration(shape: BoxShape.circle,
                gradient: AppColors.eventHorizonGradient,
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.15), width: 1),
                boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.08), blurRadius: 40, spreadRadius: 10)]),
              child: Icon(Icons.download_rounded, size: 40, color: AppColors.primary.withValues(alpha: 0.9)),
            ),
            const SizedBox(height: 32),
            Text(AppStrings.appTagline, style: AppTypography.displayLarge.copyWith(fontSize: 36, letterSpacing: 6.0)),
            const SizedBox(height: 8),
            Text('into the void', style: AppTypography.caption.copyWith(
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.5), letterSpacing: 4)),
            const Spacer(),
            Padding(padding: const EdgeInsets.only(bottom: 32),
              child: Text(AppStrings.copyrightDisclaimer, style: AppTypography.caption.copyWith(
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.4), fontSize: 10), textAlign: TextAlign.center)),
          ])),
        ),
      ),
    );
  }
}
