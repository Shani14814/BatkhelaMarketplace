import 'package:flutter/material.dart';
import 'package:marketplace_core/marketplace_core.dart';
import '../../data/vendor_demo_data.dart';
import 'vendor_pending_approval_screen.dart';

/// Vendor Store Registration & KYC Onboarding Screen
class VendorRegistrationScreen extends StatefulWidget {
  final String? initialPhone;

  const VendorRegistrationScreen({
    super.key,
    this.initialPhone,
  });

  @override
  State<VendorRegistrationScreen> createState() => _VendorRegistrationScreenState();
}

class _VendorRegistrationScreenState extends State<VendorRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _storeNameCtrl;
  late final TextEditingController _ownerNameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _cnicCtrl;
  late final TextEditingController _prepTimeCtrl;

  String _selectedCategory = 'Restaurants & BBQ';
  String _selectedLogoUrl = 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=500&q=80';
  bool _isLoading = false;

  final List<String> _categories = const [
    'Restaurants & BBQ',
    'Fresh Grocery',
    'Pharmacy & Health',
    'Fruits & Vegetables',
    'Bakery & Sweets',
    'General Stores',
  ];

  final List<String> _batkhelaLandmarks = const [
    'Main GT Road',
    'Bypass Chowk',
    'Hospital Road',
    'Thana Road',
    'Sabzi Mandi',
    'College Road',
    'Clock Tower Chowk',
  ];

  @override
  void initState() {
    super.initState();
    _storeNameCtrl = TextEditingController(text: '');
    _ownerNameCtrl = TextEditingController(text: '');
    _phoneCtrl = TextEditingController(text: widget.initialPhone ?? '+92 345 9876543');
    _addressCtrl = TextEditingController(text: '');
    _cnicCtrl = TextEditingController(text: '');
    _prepTimeCtrl = TextEditingController(text: '20-30 min');
  }

  @override
  void dispose() {
    _storeNameCtrl.dispose();
    _ownerNameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _cnicCtrl.dispose();
    _prepTimeCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmitRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simulate network submission delay
    await Future<void>.delayed(const Duration(milliseconds: 300));

    VendorDemoController.instance.registerVendorStore(
      name: _storeNameCtrl.text.trim(),
      category: _selectedCategory,
      ownerName: _ownerNameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      cnic: _cnicCtrl.text.trim(),
      logoUrl: _selectedLogoUrl,
      operatingHours: '10:00 AM – 11:00 PM (Daily)',
    );

    try {
      await HostingerApiClient.instance.saveUser({
        'phone': _phoneCtrl.text.trim(),
        'full_name': _ownerNameCtrl.text.trim(),
        'store_name': _storeNameCtrl.text.trim(),
        'role': 'vendor',
        'status': 'pending',
        'category': _selectedCategory,
        'address': _addressCtrl.text.trim(),
        'cnic': _cnicCtrl.text.trim(),
        'prep_time': _prepTimeCtrl.text.trim(),
        'logo_url': _selectedLogoUrl,
      });
    } catch (_) {}

    AuthService.instance.updateCurrentProfile(
      UserProfile(
        id: 'vend-${_phoneCtrl.text.replaceAll(RegExp(r'\D'), '')}',
        phone: _phoneCtrl.text.trim(),
        fullName: _ownerNameCtrl.text.trim(),
        role: UserRole.vendor,
        isActive: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.pushReplacement<void, void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const VendorPendingApprovalScreen(),
      ),
    );
  }

  void _showLogoSelectorModal() {
    final List<Map<String, String>> logoPresets = [
      {
        'label': 'Shinwari BBQ',
        'url': 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=500&q=80',
      },
      {
        'label': 'Super Mart',
        'url': 'https://images.unsplash.com/photo-1578916171728-46686eac8d58?w=500&q=80',
      },
      {
        'label': 'Pharmacy',
        'url': 'https://images.unsplash.com/photo-1586015555751-63bb77f4322a?w=500&q=80',
      },
      {
        'label': 'Fresh Fruit',
        'url': 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=500&q=80',
      },
      {
        'label': 'Bakery Sweets',
        'url': 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=500&q=80',
      },
    ];

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Store Logo / Preset',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 110,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: logoPresets.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final preset = logoPresets[index];
                      final isSelected = _selectedLogoUrl == preset['url'];
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedLogoUrl = preset['url']!);
                          Navigator.pop(sheetCtx);
                        },
                        child: Column(
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : Colors.grey.shade300,
                                  width: isSelected ? 3 : 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: MarketplaceProductImage(
                                  imageUrl: preset['url'],
                                  productName: preset['label']!,
                                  category: _selectedCategory,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              preset['label']!,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? AppColors.primary : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Vendor Registration & KYC',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Informational Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.store_mall_directory_outlined, color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Grow Your Store in Batkhela',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Register your business to start receiving online orders across Malakand.',
                              style: TextStyle(fontSize: 12, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Logo Picker Section
                Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primary, width: 2),
                            ),
                            child: ClipOval(
                              child: MarketplaceProductImage(
                                imageUrl: _selectedLogoUrl,
                                productName: 'Store Logo',
                                category: _selectedCategory,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _showLogoSelectorModal,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _showLogoSelectorModal,
                        icon: const Icon(Icons.photo_library_outlined, size: 16),
                        label: const Text('Change Store Logo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Section 1: Business Details
                const Text('Store Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary)),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _storeNameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Store Name *',
                    hintText: 'e.g. Khyber Shinwari Tikka & Karahi',
                    prefixIcon: const Icon(Icons.storefront_outlined),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Store name is required' : null,
                ),
                const SizedBox(height: 14),

                // Category Selector
                const Text('Primary Business Category *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categories.map((cat) {
                    final isSelected = cat == _selectedCategory;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: isSelected ? AppColors.primary : Colors.grey.shade300),
                      ),
                      onSelected: (_) => setState(() => _selectedCategory = cat),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Section 2: Owner & KYC
                const Text('Owner & Legal Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary)),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _ownerNameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Owner Full Name *',
                    hintText: 'e.g. Master Chef Abdullah Khan',
                    prefixIcon: const Icon(Icons.person_outline),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Owner name is required' : null,
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _cnicCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'CNIC / Trade License Number *',
                    hintText: 'e.g. 15402-1234567-1',
                    prefixIcon: const Icon(Icons.badge_outlined),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'CNIC or License number is required' : null,
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Contact Phone Number *',
                    hintText: '+92 345 9876543',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Phone number is required' : null,
                ),
                const SizedBox(height: 16),

                // Section 3: Location in Batkhela
                const Text('Location in Batkhela', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary)),
                const SizedBox(height: 8),

                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _batkhelaLandmarks.map((lm) {
                    return ActionChip(
                      label: Text(lm, style: const TextStyle(fontSize: 11)),
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.grey.shade300),
                      onPressed: () {
                        setState(() {
                          _addressCtrl.text = '$lm, Batkhela';
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),

                TextFormField(
                  controller: _addressCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Store Physical Address *',
                    hintText: 'e.g. Shop #4, Main GT Road, Near Bypass Chowk, Batkhela',
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Address is required' : null,
                ),
                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSubmitRegistration,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Text(
                            'Submit Application for Review',
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