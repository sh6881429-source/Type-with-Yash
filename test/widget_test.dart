import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:type_with_yash/core/constants/app_constants.dart';
import 'package:type_with_yash/core/services/onboarding_storage.dart';
import 'package:type_with_yash/core/theme/neo_colors.dart';
import 'package:type_with_yash/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:type_with_yash/presentation/screens/splash/splash_screen.dart';
import 'package:type_with_yash/presentation/screens/dashboard_placeholder/dashboard_placeholder_screen.dart';
import 'package:type_with_yash/presentation/widgets/neo_box.dart';
import 'package:type_with_yash/presentation/widgets/neo_button.dart';
import 'package:type_with_yash/presentation/widgets/neo_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Branding and Constants Tests', () {
    test('App constants match project identity specifications', () {
      expect(AppConstants.appName, equals('Type with Yash'));
      expect(AppConstants.appTagline, equals('Practice Today. Type Tomorrow.'));
      expect(AppConstants.developerCredit, equals('Developed by Yash Shukla'));
      expect(
        AppConstants.welcomeCredit,
        equals('Created with care by Yash Shukla'),
      );
    });
  });

  group('Neo-Brutalism Widgets Tests', () {
    testWidgets('NeoButton triggers onPressed callback and renders label', (
      WidgetTester tester,
    ) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeoButton(
              label: 'Test Button',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
      await tester.tap(find.text('Test Button'));
      await tester.pumpAndSettle();

      expect(pressed, isTrue);
    });

    testWidgets(
      'NeoBox renders child with hard offset shadow and solid border',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: NeoBox(
                borderWidth: 3.0,
                shadowOffset: Offset(5, 5),
                child: Text('Box Child'),
              ),
            ),
          ),
        );

        expect(find.text('Box Child'), findsOneWidget);
        final container = tester.widget<Container>(
          find.byType(Container).first,
        );
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.border?.top.width, equals(3.0));
        expect(decoration.boxShadow?.first.offset, equals(const Offset(5, 5)));
        expect(decoration.boxShadow?.first.blurRadius, equals(0.0));
      },
    );

    testWidgets('NeoCard renders title, description, and icon', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NeoCard(
              icon: Icon(Icons.print),
              title: 'Print & Type',
              description: 'Print your passage and practise from paper.',
              cardColor: NeoColors.mint,
            ),
          ),
        ),
      );

      expect(find.text('Print & Type'), findsOneWidget);
      expect(
        find.text('Print your passage and practise from paper.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.print), findsOneWidget);
    });
  });

  group('Onboarding Storage & Screen Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test(
      'OnboardingStorage correctly persists and resets state locally',
      () async {
        expect(await OnboardingStorage.isOnboardingCompleted(), isFalse);

        await OnboardingStorage.setOnboardingCompleted(completed: true);
        expect(await OnboardingStorage.isOnboardingCompleted(), isTrue);

        await OnboardingStorage.resetOnboardingForDev();
        expect(await OnboardingStorage.isOnboardingCompleted(), isFalse);
      },
    );

    testWidgets('OnboardingScreen renders header, 3 cards, and CTA button', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const MaterialApp(home: OnboardingScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Welcome to\nType with Yash'), findsOneWidget);
      expect(find.text('100 Practice Passages'), findsOneWidget);
      expect(find.text('Print & Type'), findsOneWidget);
      expect(find.text('Track Your Progress'), findsOneWidget);
      expect(find.text("Let's Get Started  →"), findsOneWidget);
      expect(find.text(AppConstants.welcomeCredit), findsOneWidget);
    });

    testWidgets('SplashScreen renders title, tagline, and developer credit', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
      await tester.pump(const Duration(milliseconds: 700));

      expect(find.text(AppConstants.appName), findsOneWidget);
      expect(find.text(AppConstants.appTagline), findsOneWidget);
      expect(find.text(AppConstants.developerCredit), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets(
      'DashboardPlaceholderScreen renders desktop sidebar and check items',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          const MaterialApp(home: DashboardPlaceholderScreen()),
        );
        await tester.pumpAndSettle();

        expect(find.text('Hello, Aspirant!'), findsOneWidget);
        expect(find.text('Dashboard'), findsOneWidget);
        expect(find.text('Start Test'), findsOneWidget);
        expect(find.text('Start Typing Test'), findsOneWidget);
      },
    );
  });
}
