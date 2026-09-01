import 'package:flutter/material.dart';
import 'package:marketplace_core/marketplace_core.dart';
import 'otp_verification_screen.dart';
import '../role_selector_screen.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length < 9) {
      setState(() {
        _errorMessage = 'Please enter a valid Pakistani phone number';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final formattedPhone = phone.startsWith('+92')
        ? phone
        : phone.startsWith('0')
            ? '+92${phone.substring(1)}'
            : '+92$phone';

    final success = await AuthService.instance.sendPhoneOtp(formattedPhone);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (context) => OtpVerificationScreen(phoneNumber: formattedPhone),
        ),
      );
    } else {
      setState(() {
        _errorMessage = AuthService.instance.errorNotifier.value ?? 'Failed to send OTP code';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryDark, Color(0xFF0F172A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Marketplace Brand Icon & Logo
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: AppRadius.roundedXl,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x44006D77),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.shopping_bag_outlined, size: 48, color: Colors.white),
              ),
              const SizedBox(height: AppSpacing.lg),

              const Text(
                'BATKHELA MARKETPLACE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'Enter your mobile number to sign in or register',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),

              const Spacer(flex: 2),

              // Error Message Banner
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.15),
                    borderRadius: AppRadius.roundedMd,
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: AppColors.error, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              // Phone Number Input Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: AppRadius.roundedLg,
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
                      decoration: const BoxDecoration(
                        border: Border(right: BorderSide(color: Colors.white24)),
                      ),
                      child: const Row(
                        children: [
                          Text('🇵🇰', style: TextStyle(fontSize: 20)),
                          SizedBox(width: AppSpacing.xs),
                          Text(
                            '+92',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(color: Colors.white, fontSize: 15),
                        decoration: const InputDecoration(
                          hintText: '345 1234567',
                          hintStyle: TextStyle(color: Colors.white38),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        ),
                        onSubmitted: (_) => _handleSendOtp(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedLg),
                    elevation: 4,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text(
                          'Send Verification Code',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),

              const Spacer(flex: 3),

              // Demo Testing Mode Option
              TextButton.icon(
                onPressed: () {
                  Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(builder: (context) => const RoleSelectorScreen()),
                  );
                },
                icon: const Icon(Icons.developer_mode, color: AppColors.primaryLight, size: 18),
                label: const Text(
                  'Switch to Demo Testing Mode (Role Selector)',
                  style: TextStyle(color: AppColors.primaryLight, fontSize: 13),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}
