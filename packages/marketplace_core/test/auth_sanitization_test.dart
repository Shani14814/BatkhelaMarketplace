import 'package:flutter_test/flutter_test.dart';
import 'package:marketplace_core/marketplace_core.dart';

void main() {
  group('AuthService Security & Sanitization Tests', () {
    setUp(() {
      AuthService.instance.initialize(
        repository: DemoAuthRepository(),
        isDemoMode: true,
      );
    });

    test('Demo Mode authentication initializes and switches profiles cleanly', () async {
      final profile = await AuthService.instance.signInDemo(UserRole.customer);
      expect(profile, isNotNull);
      expect(profile?.role, UserRole.customer);
      expect(AuthService.instance.isAuthenticated, isTrue);
      expect(AuthService.instance.currentRole, UserRole.customer);
    });

    test('updateCurrentProfile updates local profile state reactively', () async {
      final initial = await AuthService.instance.signInDemo(UserRole.customer);
      expect(initial, isNotNull);

      final updatedProfile = UserProfile(
        id: initial!.id,
        phone: initial.phone,
        fullName: 'Bilal Khan',
        role: initial.role,
        isActive: true,
        createdAt: initial.createdAt,
        updatedAt: DateTime.now(),
      );

      AuthService.instance.updateCurrentProfile(updatedProfile);

      expect(AuthService.instance.currentProfile?.fullName, 'Bilal Khan');
    });

    test('signOut clears active authenticated profile and session state', () async {
      await AuthService.instance.signInDemo(UserRole.customer);
      expect(AuthService.instance.isAuthenticated, isTrue);

      await AuthService.instance.signOut();
      expect(AuthService.instance.isAuthenticated, isFalse);
      expect(AuthService.instance.currentProfile, isNull);
    });
  });
}
