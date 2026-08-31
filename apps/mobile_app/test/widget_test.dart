import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_app/main.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('Role Selector renders correctly on mobile launch', (WidgetTester tester) async {
    await tester.pumpWidget(const BatkhelaMarketplaceMobileApp());
    expect(find.text('BATKHELA MARKETPLACE'), findsOneWidget);
    expect(find.text('Customer Experience'), findsOneWidget);
    expect(find.text('Vendor Store Portal'), findsOneWidget);
    expect(find.text('Rider Delivery App'), findsOneWidget);
  });
}
