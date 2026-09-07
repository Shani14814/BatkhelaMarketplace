import 'package:flutter/material.dart';
import 'package:marketplace_core/marketplace_core.dart';
import '../../data/vendor_demo_data.dart';
import '../vendor/vendor_dashboard_screen.dart';
import 'vendor_registration_screen.dart';
import 'phone_login_screen.dart';

/// Vendor Application Verification & Pending Approval Screen
class VendorPendingApprovalScreen extends StatefulWidget {
  const VendorPendingApprovalScreen({super.key});

  @override
  State<VendorPendingApprovalScreen> createState() => _VendorPendingApprovalScreenState();
}

class _VendorPendingApprovalScreenState extends State<VendorPendingApprovalScreen> {
  bool _isChecking = false;

  Future<void> _checkStatus() async {
    setState(() => _isChecking = true);
    await Future<void>.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;
    setState(() => _isChecking = false);

    final isVerified = VendorDemoController.instance.isCurrentVendorVerified;
    if (isVerified) {
      Navigator.pushAndRemoveUntil<void>(
        context,
        MaterialPageRoute<void>(builder: (context) => const VendorDashboardScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your application is currently under review by the Batkhela Merchant Desk.'),
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
      animation: VendorDemoController.instance,
      builder: (context, _) {
        final store = VendorDemoController.instance.store;
        final isApproved = store.isVerified || store.applicationStatus == 'approved';
        final isRejected = store.applicationStatus == 'rejected';

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: const Text(
              'Store Verification',
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
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : isRejected
                              ? AppColors.error.withValues(alpha: 0.15)
                              : AppColors.warning.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isApproved
                          ? Icons.verified_user
                          : isRejected
                              ? Icons.cancel_outlined
                              : Icons.hourglass_top_rounded,
                      size: 48,
                      color: isApproved
                          ? AppColors.primary
                          : isRejected
                              ? AppColors.error
                              : AppColors.warning,
                    ),
                  ),
                  const SizedBox(height: 18),

                  Text(
                    isApproved
                        ? 'Store Approved & Verified!'
                        : isRejected
                            ? 'Application Requires Revision'
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
                  const SizedBox(height: 8),

                  Text(
                    isApproved
                        ? 'Congratulations! Your storefront is verified and active on the Batkhela Marketplace.'
                        : isRejected
                            ? 'Your store registration could not be approved due to incomplete documentation. Please review and resubmit.'
                            : 'The Batkhela Commercial Onboarding Desk is reviewing your store registration, CNIC, and business address.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.4),
                  ),
                  const SizedBox(height: 24),

                  // Store Info Card
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: MarketplaceProductImage(
                                    imageUrl: store.logoUrl,
                                    productName: store.name,
                                    category: store.category,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      store.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      store.category,
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isApproved
                                      ? AppColors.softCyan.withValues(alpha: 0.4)
                                      : isRejected
                                          ? AppColors.error.withValues(alpha: 0.15)
                                          : AppColors.warning.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  isApproved
                                      ? 'APPROVED'
                                      : isRejected
                                          ? 'REJECTED'
                                          : 'PENDING',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isApproved
                                        ? AppColors.primary
                                        : isRejected
                                            ? AppColors.error
                                            : const Color(0xFFB45309),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24, color: Color(0xFFF1F5F9)),
                          _buildDetailRow(Icons.person_outline, 'Owner', store.ownerName ?? 'Not specified'),
                          const SizedBox(height: 8),
                          _buildDetailRow(Icons.phone_outlined, 'Phone', store.phone),
                          const SizedBox(height: 8),
                          _buildDetailRow(Icons.location_on_outlined, 'Address', store.address),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Onboarding Steps Card (when pending)
                  if (!isApproved && !isRejected) ...[
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Verification Timeline',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                            const SizedBox(height: 14),
                            _buildStep(
                              icon: Icons.check_circle,
                              iconColor: AppColors.primary,
                              title: 'Application Submitted',
                              subtitle: 'Store profile & KYC data received',
                              isDone: true,
                            ),
                            const SizedBox(height: 12),
                            _buildStep(
                              icon: Icons.sync,
                              iconColor: AppColors.warning,
                              title: 'Admin Verification',
                              subtitle: 'Checking CNIC & Batkhela business location',
                              isDone: false,
                              isActive: true,
                            ),
                            const SizedBox(height: 12),
                            _buildStep(
                              icon: Icons.radio_button_unchecked,
                              iconColor: Colors.grey.shade400,
                              title: 'Live Catalog Activation',
                              subtitle: 'Start publishing products and taking orders',
                              isDone: false,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Support / Helpline Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.indigo.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.support_agent_outlined, color: AppColors.indigo, size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Batkhela Merchant Desk',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Helpline: +92 345 900-HELP (9 AM – 9 PM)',
                                style: TextStyle(fontSize: 11, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  if (isApproved) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil<void>(
                            context,
                            MaterialPageRoute<void>(builder: (context) => const VendorDashboardScreen()),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Open Vendor Dashboard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                  ] else if (isRejected) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement<void, void>(
                            context,
                            MaterialPageRoute<void>(
                              builder: (context) => VendorRegistrationScreen(initialPhone: store.phone),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Update & Resubmit Application', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isChecking ? null : _checkStatus,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isChecking
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              )
                            : const Text('Check Verification Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),

                  TextButton(
                    onPressed: _handleSignOut,
                    child: const Text('Sign Out / Use Another Account', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
        ),
      ],
    );
  }

  Widget _buildStep({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    bool isDone = false,
    bool isActive = false,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isDone || isActive ? Colors.black87 : Colors.grey,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
