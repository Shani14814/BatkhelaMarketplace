import 'package:flutter/material.dart';
import 'package:marketplace_core/marketplace_core.dart';
import 'src/screens/auth/auth_gate.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AuthService.instance.initialize(
    repository: DemoAuthRepository(),
    isDemoMode: true,
  );
  MarketplaceDataService.instance.initialize(isDemoMode: true);
  runApp(const BatkhelaMarketplaceMobileApp());
}

class BatkhelaMarketplaceMobileApp extends StatelessWidget {
  const BatkhelaMarketplaceMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Batkhela Marketplace',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
    );
  }
}
