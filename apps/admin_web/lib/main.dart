import 'package:flutter/material.dart';
import 'package:marketplace_core/marketplace_core.dart';
import 'src/screens/admin_auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  final isSupabaseConfigured = supabaseUrl.trim().isNotEmpty && supabaseAnonKey.trim().isNotEmpty;

  if (isSupabaseConfigured) {
    try {
      await SupabaseService.initialize(
        supabaseUrl: supabaseUrl.trim(),
        publishableKey: supabaseAnonKey.trim(),
      );
      AuthService.instance.initialize(
        repository: SupabaseAuthRepository(),
        isDemoMode: false,
      );
      MarketplaceDataService.instance.initialize(isDemoMode: false);
    } catch (e) {
      debugPrint('Supabase initialization failed. Please verify SUPABASE_URL and SUPABASE_ANON_KEY.');
      rethrow;
    }
  } else {
    AuthService.instance.initialize(
      repository: DemoAuthRepository(),
      isDemoMode: true,
    );
    MarketplaceDataService.instance.initialize(isDemoMode: true);
  }

  runApp(const BatkhelaAdminApp());
}

class BatkhelaAdminApp extends StatelessWidget {
  const BatkhelaAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Batkhela Marketplace - Super Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AdminAuthGate(),
    );
  }
}
