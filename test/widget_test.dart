import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:beyonders_signup_login/main.dart';




void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const EmergencySignupApp(isFirstLaunch: true));

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
