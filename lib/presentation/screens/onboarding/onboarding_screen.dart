import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/onboarding_storage.dart';
import '../../../core/theme/neo_colors.dart';
import '../../widgets/neo_button.dart';
import '../../widgets/neo_card.dart';
import '../dashboard_placeholder/dashboard_placeholder_screen.dart';

/// Welcome / Onboarding Screen matching Reference Image 1 Screen 2
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool _isSaving = false;
  String? _errorMessage;

  Future<void> _handleGetStarted() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final bool saved = await OnboardingStorage.setOnboardingCompleted(
        completed: true,
      );
      if (!saved) {
        throw Exception('Unable to write to local storage preferences.');
      }

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (context, animation, secondaryAnimation) =>
              FadeTransition(
                opacity: animation,
                child: const DashboardPlaceholderScreen(),
              ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorMessage = 'Failed to save onboarding status: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 40.0,
              vertical: 32.0,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1040),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Heading
                  const Text(
                    'Welcome to\nType with Yash',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Segoe UI',
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: NeoColors.textPrimary,
                      letterSpacing: -0.8,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Subtitle
                  const Text(
                    'Your personal typing practice companion for BSF exam preparation.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: NeoColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 38),

                  // 3 Feature Cards
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final bool isWide = constraints.maxWidth > 700;
                      final cardWidth = isWide
                          ? (constraints.maxWidth - 40) / 3
                          : constraints.maxWidth;

                      final cards = [
                        NeoCard(
                          width: cardWidth,
                          minHeight: isWide ? 250 : null,
                          cardColor: NeoColors.lavender,
                          iconContainerColor: Colors.white,
                          icon: const Icon(
                            Icons.menu_book_rounded,
                            size: 30,
                            color: NeoColors.textPrimary,
                          ),
                          title: '100 Practice Passages',
                          description: 'Practise with a structured library of English passages to improve your typing speed and accuracy.',
                        ),
                        NeoCard(
                          width: cardWidth,
                          minHeight: isWide ? 250 : null,
                          cardColor: NeoColors.mint,
                          iconContainerColor: Colors.white,
                          icon: const Icon(
                            Icons.print_rounded,
                            size: 30,
                            color: NeoColors.textPrimary,
                          ),
                          title: 'Print & Type',
                          description: 'Print your passage and practise from paper without seeing the reference text on your typing screen.',
                        ),
                        NeoCard(
                          width: cardWidth,
                          minHeight: isWide ? 250 : null,
                          cardColor: NeoColors.pink,
                          iconContainerColor: Colors.white,
                          icon: const Icon(
                            Icons.insights_rounded,
                            size: 30,
                            color: NeoColors.textPrimary,
                          ),
                          title: 'Track Your Progress',
                          description: 'Monitor your typing speed, accuracy, mistakes, and improvement over time.',
                        ),
                      ];

                      if (isWide) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: cards,
                        );
                      } else {
                        return Column(
                          children: [
                            cards[0],
                            const SizedBox(height: 16),
                            cards[1],
                            const SizedBox(height: 16),
                            cards[2],
                          ],
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 38),

                  // Error notification if persistence fails
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: NeoColors.coral.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: NeoColors.border, width: 2),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: NeoColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],

                  // Broad Primary CTA Button: "Let's Get Started ->"
                  SizedBox(
                    width: 360,
                    child: NeoButton(
                      label: _isSaving ? 'Starting...' : "Let's Get Started  →",
                      onPressed: _isSaving ? null : _handleGetStarted,
                      backgroundColor: NeoColors.yellow,
                      height: 52,
                      borderRadius: 12,
                      borderWidth: 2.5,
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: NeoColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Welcome screen footer credit
                  const Text(
                    AppConstants.welcomeCredit,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: NeoColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
