import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/onboarding_storage.dart';
import '../../../core/theme/neo_colors.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/neo_box.dart';
import '../dashboard_placeholder/dashboard_placeholder_screen.dart';
import '../onboarding/onboarding_screen.dart';

/// Animated Splash Screen matching Reference Image 1
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _nameOpacityAnimation;
  late Animation<double> _taglineSlideAnimation;
  late Animation<double> _creditOpacityAnimation;
  late Animation<double> _progressAnimation;

  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutBack),
      ),
    );

    _nameOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.65, curve: Curves.easeIn),
      ),
    );

    _taglineSlideAnimation = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.8, curve: Curves.easeOutQuad),
      ),
    );

    _creditOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.65, 0.9, curve: Curves.easeIn),
      ),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.95, curve: Curves.easeInOut),
      ),
    );

    _controller.forward().whenComplete(_checkNextScreen);
  }

  Future<void> _checkNextScreen() async {
    try {
      final bool completed = await OnboardingStorage.isOnboardingCompleted();
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (context, animation, secondaryAnimation) =>
              FadeTransition(
                opacity: animation,
                child: completed
                    ? const DashboardPlaceholderScreen()
                    : const OnboardingScreen(),
              ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMessage = 'Failed to load local preferences: $e';
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoColors.background,
      body: Stack(
        children: [
          // Background playful decorative shapes (yellow squiggles, lavender pills)
          Positioned(
            top: 70,
            left: 80,
            child: _buildDecorativeShape(
              NeoColors.yellow,
              30,
              12,
              rotation: -0.4,
            ),
          ),
          Positioned(
            top: 140,
            right: 120,
            child: _buildDecorativeShape(
              NeoColors.lavender,
              42,
              16,
              rotation: 0.5,
            ),
          ),
          Positioned(
            bottom: 120,
            left: 110,
            child: _buildDecorativeShape(NeoColors.pink, 34, 14, rotation: 0.3),
          ),
          Positioned(
            bottom: 160,
            right: 90,
            child: _buildDecorativeShape(
              NeoColors.mint,
              40,
              16,
              rotation: -0.6,
            ),
          ),

          // Central splash content
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated Logo
                    Transform.scale(
                      scale: _logoScaleAnimation.value,
                      child: const AppLogo(size: 130, showWordmark: false),
                    ),
                    const SizedBox(height: 24),

                    // App Title
                    Opacity(
                      opacity: _nameOpacityAnimation.value,
                      child: const Text(
                        AppConstants.appName,
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          color: NeoColors.textPrimary,
                          letterSpacing: -1.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tagline Pill
                    Transform.translate(
                      offset: Offset(0, _taglineSlideAnimation.value),
                      child: Opacity(
                        opacity: _nameOpacityAnimation.value,
                        child: NeoBox(
                          backgroundColor: NeoColors.yellow,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 8,
                          ),
                          borderRadius: 20,
                          borderWidth: 2.2,
                          shadowOffset: const Offset(3, 3),
                          child: const Text(
                            AppConstants.appTagline,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: NeoColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Developer Credit
                    Opacity(
                      opacity: _creditOpacityAnimation.value,
                      child: const Text(
                        AppConstants.developerCredit,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: NeoColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 38),

                    // Neo-Brutalism Progress Bar
                    Container(
                      width: 260,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: NeoColors.border, width: 2.0),
                        boxShadow: const [
                          BoxShadow(
                            color: NeoColors.shadow,
                            offset: Offset(2, 2),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(2),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _progressAnimation.value.clamp(0.05, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: NeoColors.purple,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ),

                    if (_hasError) ...[
                      const SizedBox(height: 20),
                      Text(
                        _errorMessage,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _checkNextScreen,
                        child: const Text('Retry'),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecorativeShape(
    Color color,
    double width,
    double height, {
    double rotation = 0.0,
  }) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(height / 2),
          border: Border.all(color: NeoColors.border, width: 2.0),
        ),
      ),
    );
  }
}
