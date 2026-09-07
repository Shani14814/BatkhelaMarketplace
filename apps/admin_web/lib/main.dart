import 'package:flutter/material.dart';
import 'package:marketplace_core/marketplace_core.dart';
import 'src/screens/admin_auth_gate.dart';

bool _isProductionSupabaseConfigured(String url, String key) {
  final cleanUrl = url.trim().toLowerCase();
  final cleanKey = key.trim().toLowerCase();

  if (cleanUrl.isEmpty || cleanKey.isEmpty) return false;
  if (cleanUrl.contains('placeholder') ||
      cleanUrl.contains('your-project') ||
      cleanUrl.contains('example.com')) {
    return false;
  }
  if (cleanKey.contains('placeholder') ||
      cleanKey.contains('your-anon-key') ||
      cleanKey.length < 20) {
    return false;
  }

  final uri = Uri.tryParse(cleanUrl);
  return uri != null && uri.hasScheme && (uri.scheme == 'https' || uri.scheme == 'http') && uri.hasAuthority;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  final isSupabaseConfigured = _isProductionSupabaseConfigured(supabaseUrl, supabaseAnonKey);

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
      debugPrint('Supabase initialization failed. Defaulting to Demo Mode for safety.');
      AuthService.instance.initialize(
        repository: DemoAuthRepository(),
        isDemoMode: true,
      );
      MarketplaceDataService.instance.initialize(isDemoMode: true);
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
