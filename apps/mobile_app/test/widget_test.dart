import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketplace_core/marketplace_core.dart';
import 'package:mobile_app/main.dart';
import 'package:mobile_app/src/screens/role_selector_screen.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    AuthService.instance.initialize(
      repository: DemoAuthRepository(),
      isDemoMode: true,
    );
  });

  testWidgets('App launch renders AuthGate with phone entry and demo mode switch', (WidgetTester tester) async {
    await AuthService.instance.signOut();
    await tester.pumpWidget(const BatkhelaMarketplaceMobileApp());
    await tester.pumpAndSettle();

    expect(find.text('BATKHELA MARKETPLACE'), findsOneWidget);
    expect(find.text('Send Verification Code'), findsOneWidget);
    expect(find.text('Switch to Demo Testing Mode (Role Selector)'), findsOneWidget);

    // Tap switch to demo mode
    await tester.tap(find.text('Switch to Demo Testing Mode (Role Selector)'));
    await tester.pumpAndSettle();

    expect(find.byType(RoleSelectorScreen), findsOneWidget);
    expect(find.text('Customer Experience'), findsOneWidget);
    expect(find.text('Vendor Store Portal'), findsOneWidget);
    expect(find.text('Rider Delivery App'), findsOneWidget);
  });
}
