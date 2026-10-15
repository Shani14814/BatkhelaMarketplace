import 'dart:async';
import 'package:flutter/material.dart';
import 'package:marketplace_core/marketplace_core.dart';
import 'package:url_launcher/url_launcher.dart';
import 'auth_role_router.dart';
import 'customer_profile_setup_screen.dart';
import '../customer/customer_home_screen.dart';

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
  final FocusNode _focusNode = FocusNode();
  bool _isLoading = false;
  String? _errorMessage;
  int _resendCountdown = 45;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    // Auto populate if already generated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final lastData = AuthService.instance.lastOtpDataNotifier.value;
      if (lastData != null && lastData['otp_code'] != null) {
        final code = lastData['otp_code'].toString();
        if (code.isNotEmpty && _otpController.text.isEmpty) {
          // Keep controller empty for typing, but user can 1-tap auto-fill
        }
      }
    });
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() => _resendCountdown = 45);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _handleVerifyOtp([String? codeToVerify]) async {
    final token = (codeToVerify ?? _otpController.text).trim();
    if (token.length < 4) {
      setState(() {
        _errorMessage = 'Barah-e-karam 6-digit verification code darj karein';
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
      if (profile.role == UserRole.customer) {
        if (profile.fullName == 'Batkhela Customer' ||
            profile.fullName == 'Marketplace User' ||
            profile.fullName == 'User' ||
            profile.fullName.trim().isEmpty) {
          Navigator.pushReplacement<void, void>(
            context,
            MaterialPageRoute<void>(
              builder: (context) => CustomerProfileSetupScreen(profile: profile),
            ),
          );
        } else {
          Navigator.pushAndRemoveUntil<void>(
            context,
            MaterialPageRoute<void>(builder: (context) => const CustomerHomeScreen()),
            (route) => false,
          );
        }
      } else {
        AuthRoleRouter.navigateForRole(context, profile.role);
      }
    } else {
      setState(() {
        _errorMessage = AuthService.instance.errorNotifier.value ?? 'Ghalat ya expired verification code';
      });
    }
  }

  Future<void> _openWhatsApp() async {
    final lastData = AuthService.instance.lastOtpDataNotifier.value;
    String waUrl = lastData?['whatsapp_url']?.toString() ?? '';
    if (waUrl.isEmpty) {
      final digits = widget.phoneNumber.replaceAll(RegExp(r'\D'), '');
      final otp = lastData?['otp_code']?.toString() ?? '123456';
      waUrl = 'https://api.whatsapp.com/send?phone=$digits&text=${Uri.encodeComponent('Batkhela Marketplace OTP code: $otp')}';
    }

    final uri = Uri.tryParse(waUrl);
    if (uri != null) {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('WhatsApp launch error: $e')),
          );
        }
      }
    }
  }

  Future<void> _handleResend() async {
    if (_resendCountdown > 0) return;
    setState(() => _isLoading = true);
    final ok = await AuthService.instance.sendPhoneOtp(widget.phoneNumber);
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (ok) {
      _startCountdown();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Naya verification code WhatsApp aur SMS par bhej diya gaya hai.'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Map<String, dynamic>?>(
      valueListenable: AuthService.instance.lastOtpDataNotifier,
      builder: (context, otpData, _) {
        final serverOtp = otpData?['otp_code']?.toString();

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
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.md),

                    // Shield Icon with Soft Glow
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33006D77),
                            blurRadius: 20,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.verified_user_outlined,
                        size: 38,
                        color: AppColors.primaryLight,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    const Text(
                      'Verification Code',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '6-digit code has been dispatched to\n${widget.phoneNumber}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Real-Time Dispatched Code Card with 1-Tap Auto Fill
                    if (serverOtp != null && serverOtp.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: AppRadius.roundedLg,
                          border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF10B981).withValues(alpha: 0.15),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Live Server OTP Generated',
                                  style: TextStyle(
                                    color: Color(0xFF10B981),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                const Text(
                                  'Active for 10m',
                                  style: TextStyle(color: Colors.white38, fontSize: 11),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.key, color: Colors.white70, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      serverOtp,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 4,
                                      ),
                                    ),
                                  ],
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    _otpController.text = serverOtp;
                                    _handleVerifyOtp(serverOtp);
                                  },
                                  icon: const Icon(Icons.flash_on, size: 16),
                                  label: const Text('Auto-Fill & Go'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF10B981),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],

                    // WhatsApp Direct Verification Action
                    InkWell(
                      onTap: _openWhatsApp,
                      borderRadius: AppRadius.roundedLg,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF25D366).withValues(alpha: 0.15),
                          borderRadius: AppRadius.roundedLg,
                          border: Border.all(color: const Color(0xFF25D366).withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Color(0xFF25D366),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.chat, color: Colors.white, size: 16),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Open WhatsApp (Receive / Verify Code)',
                              style: TextStyle(
                                color: Color(0xFF25D366),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

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

                    // Interactive 6-Digit PIN Visual Box
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B).withValues(alpha: 0.85),
                        borderRadius: AppRadius.roundedLg,
                        border: Border.all(color: Colors.white30, width: 1.2),
                      ),
                      child: TextField(
                        controller: _otpController,
                        focusNode: _focusNode,
                        keyboardType: TextInputType.number,
                        cursorColor: AppColors.primaryLight,
                        textAlign: TextAlign.center,
                        maxLength: 6,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          letterSpacing: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          counterText: '',
                          filled: false,
                          isDense: true,
                          hintText: '••••••',
                          hintStyle: TextStyle(
                            color: Colors.white38,
                            letterSpacing: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        onChanged: (val) {
                          if (val.length == 6) {
                            _handleVerifyOtp();
                          }
                        },
                        onSubmitted: (_) => _handleVerifyOtp(),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Verify & Proceed Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () => _handleVerifyOtp(),
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

                    // Resend Countdown
                    TextButton(
                      onPressed: _resendCountdown > 0 ? null : _handleResend,
                      child: Text(
                        _resendCountdown > 0
                            ? 'Resend Code via SMS in ${_resendCountdown}s'
                            : 'Didn\'t receive code? Resend via SMS / WhatsApp',
                        style: TextStyle(
                          color: _resendCountdown > 0 ? Colors.white38 : Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
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
