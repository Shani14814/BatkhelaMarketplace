import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:admin_web/main.dart';

void main() {
  testWidgets('Admin Dashboard renders correctly on desktop', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const BatkhelaAdminApp());
    await tester.pumpAndSettle();

    expect(find.text('BATKHELA'), findsOneWidget);
    expect(find.text('Super Admin'), findsOneWidget);
    expect(find.text('Operations Dashboard'), findsOneWidget);
  });
}
