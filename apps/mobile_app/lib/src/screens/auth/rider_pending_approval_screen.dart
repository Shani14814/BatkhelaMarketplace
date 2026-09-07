import 'package:flutter/material.dart';
import 'package:marketplace_core/marketplace_core.dart';
import '../../data/rider_demo_data.dart';
import '../rider/rider_home_screen.dart';
import 'rider_registration_screen.dart';
import 'phone_login_screen.dart';

/// Rider Application Verification & Pending Approval Screen
class RiderPendingApprovalScreen extends StatefulWidget {
  const RiderPendingApprovalScreen({super.key});

  @override
  State<RiderPendingApprovalScreen> createState() => _RiderPendingApprovalScreenState();
}

class _RiderPendingApprovalScreenState extends State<RiderPendingApprovalScreen> {
  bool _isChecking = false;

  Future<void> _checkStatus() async {
    setState(() => _isChecking = true);
    await Future<void>.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;
    setState(() => _isChecking = false);

    final isVerified = RiderDemoController.instance.isCurrentRiderVerified;
    if (isVerified) {
      Navigator.pushAndRemoveUntil<void>(
        context,
        MaterialPageRoute<void>(builder: (context) => const RiderHomeScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your application is currently under review by the Batkhela Delivery Fleet Team.'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  Future<void> _handleSignOut() async {
    await AuthService.instance.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil<void>(
      context,
      MaterialPageRoute<void>(builder: (context) => const PhoneLoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: RiderDemoController.instance,
      builder: (context, _) {
        final profile = RiderDemoController.instance.profile;
        final isApproved = profile.isVerified || profile.applicationStatus == 'approved';
        final isRejected = profile.applicationStatus == 'rejected';

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: const Text(
              'Rider Verification',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 18),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: AppColors.textPrimary),
                tooltip: 'Sign Out',
                onPressed: _handleSignOut,
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  // Header Status Icon
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: isApproved
                          ? AppColors.primary.withAlpha(35)
                          : isRejected
                              ? AppColors.error.withAlpha(35)
                              : AppColors.warning.withAlpha(35),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isApproved
                          ? Icons.check_circle_outline
                          : isRejected
                              ? Icons.cancel_outlined
                              : Icons.access_time_filled,
                      size: 48,
                      color: isApproved
                          ? AppColors.primary
                          : isRejected
                              ? AppColors.error
                              : AppColors.warning,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Status Headline
                  Text(
                    isApproved
                        ? 'Rider Partner Approved & Verified!'
                        : isRejected
                            ? 'Application Requires Update'
                            : 'Application Under Review',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isApproved
                          ? AppColors.primary
                          : isRejected
                              ? AppColors.error
                              : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isApproved
                        ? 'Your rider credentials and vehicle permit are verified. You can now go online and accept delivery orders in Batkhela.'
                        : isRejected
                            ? 'Your documents could not be verified by the Batkhela Delivery Fleet Team. Please review your details and re-apply.'
                            : 'We have received your rider application and CNIC documents. The Batkhela Delivery Fleet Desk is reviewing your application.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                  ),
                  const SizedBox(height: 24),

                  // Rider Card Summary
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(8),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(20),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.two_wheeler, color: AppColors.primary, size: 28),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    profile.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${profile.vehicleModel} (${profile.plateNumber})',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Zone: ${profile.preferredZone}',
                                    style: const TextStyle(fontSize: 11, color: AppColors.indigo, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        _buildInfoRow('Contact Phone', profile.phone),
                        _buildInfoRow('CNIC Number', profile.cnic),
                        _buildInfoRow('Driving License', profile.licenseNumber),
                        _buildInfoRow('Applied On', '${profile.appliedAt.day}/${profile.appliedAt.month}/${profile.appliedAt.year}'),
                        _buildInfoRow(
                          'Verification Status',
                          isApproved ? 'VERIFIED' : isRejected ? 'REJECTED' : 'PENDING REVIEW',
                          isBadge: true,
                          badgeColor: isApproved
                              ? AppColors.primary
                              : isRejected
                                  ? AppColors.error
                                  : AppColors.warning,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Verification Timeline Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Verification Timeline',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary),
                        ),
                        const SizedBox(height: 16),
                        _buildTimelineStep(
                          title: 'Application Submitted',
                          subtitle: 'Your personal, CNIC, and vehicle details were recorded.',
                          isDone: true,
                          isCurrent: false,
                        ),
                        _buildTimelineStep(
                          title: 'Document & License KYC Review',
                          subtitle: 'Batkhela Fleet Desk verifies NADRA CNIC and driving license permit.',
                          isDone: isApproved,
                          isCurrent: !isApproved && !isRejected,
                        ),
                        _buildTimelineStep(
                          title: 'Fleet Activation & Radar Launch',
                          subtitle: 'Account activated to receive order dispatch alerts in Batkhela.',
                          isDone: isApproved,
                          isCurrent: isApproved,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Support / Help Box
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.headset_mic_outlined, color: AppColors.primary, size: 24),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Batkhela Delivery Fleet Helpline',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Mon–Sat (9 AM – 9 PM): +92 345 900-HELP',
                                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Dialing Batkhela Delivery Fleet Helpline (+92 345 900-HELP)...')),
                            );
                          },
                          child: const Text('Call Support'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  if (isApproved) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                        onPressed: () {
                          Navigator.pushAndRemoveUntil<void>(
                            context,
                            MaterialPageRoute<void>(builder: (context) => const RiderHomeScreen()),
                            (route) => false,
                          );
                        },
                        icon: const Icon(Icons.two_wheeler),
                        label: const Text('Open Rider Radar', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ] else if (isRejected) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement<void, void>(
                            context,
                            MaterialPageRoute<void>(builder: (context) => const RiderRegistrationScreen()),
                          );
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Update & Re-Submit Application', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _isChecking ? null : _checkStatus,
                        icon: _isChecking
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                              )
                            : const Icon(Icons.sync),
                        label: Text(
                          _isChecking ? 'Checking...' : 'Check Verification Status',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBadge = false, Color? badgeColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          if (isBadge)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: (badgeColor ?? AppColors.primary).withAlpha(20),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                value,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: badgeColor ?? AppColors.primary),
              ),
            )
          else
            Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required String title,
    required String subtitle,
    required bool isDone,
    required bool isCurrent,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isDone
                    ? AppColors.primary
                    : isCurrent
                        ? AppColors.warning
                        : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isDone
                    ? Icons.check
                    : isCurrent
                        ? Icons.hourglass_top
                        : Icons.circle,
                size: 14,
                color: isDone || isCurrent ? Colors.white : Colors.grey.shade500,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 36,
                color: isDone ? AppColors.primary : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isDone
                        ? AppColors.textPrimary
                        : isCurrent
                            ? AppColors.warning
                            : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
