import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riskora/app.dart';

void main() {
  testWidgets('RISKORA App launches on Home landing page, navigates to Login and authenticates', (WidgetTester tester) async {
    // Set desktop screen size for testing
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // 1. Build Riskora App: Opens to Home landing screen
    await tester.pumpWidget(const RiskoraApp(enableIntro: false));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Home page navbar components
    expect(find.text('RISKORA'), findsWidgets);
    expect(find.text('Home'), findsWidgets);
    expect(find.text('About us'), findsWidgets);
    expect(find.text('Contact us'), findsWidgets);
    expect(find.byKey(const ValueKey('nav_login_btn')), findsOneWidget);

    // 2. Click Login button in navbar to enter SecOps Auth Screen
    await tester.tap(find.byKey(const ValueKey('nav_login_btn')));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    // Verify Login page components
    expect(find.text('Sign In to Security Operations Center'), findsOneWidget);
    expect(find.text('Phone Number or Email'), findsOneWidget);
    expect(find.text('Forgot Password?'), findsOneWidget);
    expect(find.text('Register Now'), findsOneWidget);

    // 3. Authenticate into dashboard via demo login
    await tester.tap(find.text('Quick Demo Login (admin@riskora.ai)'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    // 4. Verify Dashboard loads cleanly
    expect(find.text('Security Operations Center'), findsOneWidget);
    expect(find.text('TOTAL DETECTIONS'), findsOneWidget);
  });
}
