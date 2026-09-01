import 'package:flutter/material.dart';
import 'package:marketplace_core/marketplace_core.dart';
import 'auth_role_router.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleVerifyOtp() async {
    final token = _otpController.text.trim();
    if (token.length < 4) {
      setState(() {
        _errorMessage = 'Please enter a valid verification code';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final profile = await AuthService.instance.verifyPhoneOtp(
      phone: widget.phoneNumber,
      token: token,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (profile != null) {
      AuthRoleRouter.navigateForRole(context, profile.role);
    } else {
      setState(() {
        _errorMessage = AuthService.instance.errorNotifier.value ?? 'Invalid verification code';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
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
              const SizedBox(height: AppSpacing.lg),

              // Shield Icon
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
                ),
                child: const Icon(Icons.verified_user_outlined, size: 36, color: AppColors.primaryLight),
              ),
              const SizedBox(height: AppSpacing.lg),

              const Text(
                'Verification Code',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Enter the 6-digit code sent to ${widget.phoneNumber}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),

              const SizedBox(height: AppSpacing.xxl),

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

              // OTP Code Input
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: AppRadius.roundedLg,
                  border: Border.all(color: Colors.white24),
                ),
                child: TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    letterSpacing: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    hintText: '••••••',
                    hintStyle: TextStyle(color: Colors.white24, letterSpacing: 8),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  ),
                  onSubmitted: (_) => _handleVerifyOtp(),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Verify Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleVerifyOtp,
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
                          'Verify & Proceed',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Resend Option
              TextButton(
                onPressed: () {
                  AuthService.instance.sendPhoneOtp(widget.phoneNumber);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('A fresh verification code has been dispatched.')),
                  );
                },
                child: const Text(
                  'Didn\'t receive code? Resend Code',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
