import 'package:flutter/material.dart';
import 'package:marketplace_core/marketplace_core.dart';
import 'src/screens/admin_auth_gate.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AuthService.instance.initialize(
    repository: DemoAuthRepository(),
    isDemoMode: true,
  );
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
