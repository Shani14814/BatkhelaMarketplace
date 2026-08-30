import 'package:flutter/material.dart';
import 'package:marketplace_core/marketplace_core.dart';
import 'src/screens/role_selector_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      home: const RoleSelectorScreen(),
    );
  }
}
