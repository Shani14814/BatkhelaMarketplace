import 'package:flutter/material.dart';
import 'package:marketplace_core/marketplace_core.dart';
import 'admin_dashboard_screen.dart';

/// Secure Authorization Gate for Super Admin Web Control Center
class AdminAuthGate extends StatefulWidget {
  const AdminAuthGate({super.key});

  @override
  State<AdminAuthGate> createState() => _AdminAuthGateState();
}

class _AdminAuthGateState extends State<AdminAuthGate> {
  final TextEditingController _emailController = TextEditingController(text: 'admin@batkhela.marketplace');
  final TextEditingController _passwordController = TextEditingController(text: 'admin123');
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleAdminLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please enter admin email and password');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final profile = await AuthService.instance.signInWithPassword(
      email: email,
      password: password,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (profile == null) {
      setState(() {
        _errorMessage = AuthService.instance.errorNotifier.value ?? 'Authentication failed';
      });
    } else if (profile.role != UserRole.admin && profile.role != UserRole.superAdmin) {
      setState(() {
        _errorMessage = 'Access Denied: Account is not authorized for Admin Console';
      });
    }
  }

  Future<void> _handleDemoAdminLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await AuthService.instance.signInDemo(UserRole.superAdmin);

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserProfile?>(
      valueListenable: AuthService.instance.currentProfileNotifier,
      builder: (context, profile, _) {
        // Authorized Super Admin or Admin access
        if (profile != null && (profile.role == UserRole.admin || profile.role == UserRole.superAdmin)) {
          return const AdminDashboardScreen();
        }

        // Unauthorized or unauthenticated: Render Google Stitch Admin Login
        return Scaffold(
          backgroundColor: const Color(0xFF0B1120),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                width: 440,
                padding: const EdgeInsets.all(36.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF1E293B)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x66000000),
                      blurRadius: 30,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand Icon
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33006D77),
                              blurRadius: 16,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.admin_panel_settings_outlined, color: Colors.white, size: 36),
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'BATKHELA MARKETPLACE',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Super Admin Web Control Center',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    ),
                    const SizedBox(height: 28),

                    // Access Denied / Error Banner
                    if (_errorMessage != null || (profile != null && profile.role != UserRole.admin && profile.role != UserRole.superAdmin)) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.lock_outline, color: AppColors.error, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _errorMessage ?? 'Access Denied: Insufficient administrator privileges.',
                                style: const TextStyle(color: AppColors.error, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],

                    // Email Input
                    const Text('Admin Email', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'admin@batkhela.marketplace',
                        hintStyle: const TextStyle(color: Color(0xFF64748B)),
                        prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF94A3B8), size: 18),
                        filled: true,
                        fillColor: const Color(0xFF1E293B),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password Input
                    const Text('Password', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        hintStyle: const TextStyle(color: Color(0xFF64748B)),
                        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF94A3B8), size: 18),
                        filled: true,
                        fillColor: const Color(0xFF1E293B),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      ),
                      onSubmitted: (_) => _handleAdminLogin(),
                    ),
                    const SizedBox(height: 24),

                    // Sign In Button
                    SizedBox(
                      height: 46,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleAdminLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              )
                            : const Text('Sign In to Control Center', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Demo Super Admin 1-Click Access
                    OutlinedButton.icon(
                      onPressed: _isLoading ? null : _handleDemoAdminLogin,
                      icon: const Icon(Icons.key, color: AppColors.primaryLight, size: 16),
                      label: const Text('Demo Super Admin (1-Click Access)', style: TextStyle(color: AppColors.primaryLight, fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF334155)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
