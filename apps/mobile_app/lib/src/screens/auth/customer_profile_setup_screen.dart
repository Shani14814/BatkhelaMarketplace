import 'package:flutter/material.dart';
import 'package:marketplace_core/marketplace_core.dart';
import '../customer/customer_home_screen.dart';

/// Customer Profile Setup Screen for new users
class CustomerProfileSetupScreen extends StatefulWidget {
  final UserProfile profile;

  const CustomerProfileSetupScreen({
    super.key,
    required this.profile,
  });

  @override
  State<CustomerProfileSetupScreen> createState() => _CustomerProfileSetupScreenState();
}

class _CustomerProfileSetupScreenState extends State<CustomerProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _addressDetailController;
  String _selectedArea = 'Main Bazaar, Batkhela';
  bool _isSaving = false;

  final List<String> _batkhelaAreas = const [
    'Main Bazaar, Batkhela',
    'Thana Road, Batkhela',
    'College Road, Batkhela',
    'Mohallah Zargarano, Batkhela',
    'Bypass Chowk, Batkhela',
    'Hospital Road, Batkhela',
    'Old Bus Stand, Batkhela',
    'Malakand Road, Batkhela',
  ];

  @override
  void initState() {
    super.initState();
    final initialName = (widget.profile.fullName == 'Batkhela Customer' || widget.profile.fullName == 'Marketplace User' || widget.profile.fullName == 'User')
        ? ''
        : widget.profile.fullName;
    _nameController = TextEditingController(text: initialName);
    _addressDetailController = TextEditingController(text: 'House 14, Street 2');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressDetailController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final fullName = _nameController.text.trim();
    final fullAddress = '${_addressDetailController.text.trim()}, $_selectedArea';

    final updatedProfile = UserProfile(
      id: widget.profile.id,
      phone: widget.profile.phone,
      fullName: fullName.isNotEmpty ? fullName : 'Customer',
      avatarUrl: widget.profile.avatarUrl,
      role: UserRole.customer,
      isActive: true,
      createdAt: widget.profile.createdAt,
      updatedAt: DateTime.now(),
    );

    AuthService.instance.updateCurrentProfile(updatedProfile);

    try {
      await HostingerApiClient.instance.saveUser({
        'id': widget.profile.id,
        'phone': widget.profile.phone,
        'full_name': fullName.isNotEmpty ? fullName : 'Batkhela Customer',
        'role': 'customer',
        'status': 'active',
        'address': fullAddress,
        'area': _selectedArea,
      });
    } catch (_) {}

    try {
      await MarketplaceDataService.instance.customerRepo.addCustomerAddress(
        CustomerAddress(
          id: 'addr-${DateTime.now().millisecondsSinceEpoch}',
          userId: widget.profile.id,
          title: 'Home',
          fullAddress: fullAddress,
          city: 'Batkhela',
          landmark: _selectedArea,
          latitude: 34.6185,
          longitude: 71.9723,
          isDefault: true,
          createdAt: DateTime.now(),
        ),
      );
    } catch (_) {
      // Ignored for resilience
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    Navigator.pushAndRemoveUntil<void>(
      context,
      MaterialPageRoute<void>(builder: (context) => const CustomerHomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Banner
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: AppRadius.roundedLg,
                    boxShadow: AppElevation.softCard,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person_pin_circle_outlined, color: Colors.white, size: 32),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome to Batkhela!',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Set up your name and delivery address to start ordering.',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Full Name
                Text('Full Name', style: AppTypography.headline(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Muhammad Ahmad',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // Phone (Read-Only)
                Text('Phone Number', style: AppTypography.headline(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  initialValue: widget.profile.phone,
                  readOnly: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.phone_android_outlined),
                    suffixIcon: Icon(Icons.check_circle, color: AppColors.success),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Delivery Area Selector
                Text('Delivery Area / Neighborhood', style: AppTypography.headline(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: AppSpacing.xs),
                DropdownButtonFormField<String>(
                  initialValue: _selectedArea,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.location_city_outlined),
                  ),
                  items: _batkhelaAreas.map((area) {
                    return DropdownMenuItem<String>(
                      value: area,
                      child: Text(area, style: const TextStyle(fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedArea = val);
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // Address Details / Street
                Text('Street Address / House / Landmark', style: AppTypography.headline(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _addressDetailController,
                  decoration: const InputDecoration(
                    hintText: 'e.g. House 14, Near Degree College',
                    prefixIcon: Icon(Icons.home_outlined),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please provide delivery address details';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _handleSaveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedLg),
                      elevation: 2,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Text(
                            'Save & Start Shopping',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
