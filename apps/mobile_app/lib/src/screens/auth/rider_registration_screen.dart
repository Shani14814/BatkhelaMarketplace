import 'package:flutter/material.dart';
import 'package:marketplace_core/marketplace_core.dart';
import '../../data/rider_demo_data.dart';
import 'rider_pending_approval_screen.dart';

/// Rider Registration & KYC Onboarding Screen
class RiderRegistrationScreen extends StatefulWidget {
  final String? initialPhone;

  const RiderRegistrationScreen({
    super.key,
    this.initialPhone,
  });

  @override
  State<RiderRegistrationScreen> createState() => _RiderRegistrationScreenState();
}

class _RiderRegistrationScreenState extends State<RiderRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _fullNameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _cnicCtrl;
  late final TextEditingController _vehicleModelCtrl;
  late final TextEditingController _plateNumberCtrl;
  late final TextEditingController _licenseNumberCtrl;

  String _selectedVehicleType = 'Motorcycle (125cc)';
  String _selectedZone = 'Main Bazaar & Hospital Road';
  String _selectedDocType = 'Valid Motorbike Driving License';
  bool _isLoading = false;

  final List<String> _vehicleTypes = const [
    'Motorcycle (125cc)',
    'Motorcycle (70cc)',
    'Scooter (100cc/125cc)',
    'Bicycle / Cargo E-Bike',
  ];

  final List<String> _batkhelaZones = const [
    'Main Bazaar & Hospital Road',
    'Thana Road & Malakand Bypass',
    'Degree College & Civil Hospital Colony',
    'Old Bus Stand & Sabzi Mandi',
    'All Batkhela Zones',
  ];

  final List<Map<String, dynamic>> _docPresets = const [
    {
      'title': 'Valid Motorbike Driving License',
      'desc': 'Govt issued Khyber Pakhtunkhwa / Malakand driving license',
      'icon': Icons.badge_outlined,
    },
    {
      'title': 'CNIC Smart Card (Front & Back)',
      'desc': 'National Identity Card issued by NADRA',
      'icon': Icons.credit_card_outlined,
    },
    {
      'title': 'Motorbike Registration Book / Excise Paper',
      'desc': 'Official vehicle ownership & road permit proof',
      'icon': Icons.description_outlined,
    },
  ];

  @override
  void initState() {
    super.initState();
    _fullNameCtrl = TextEditingController(text: '');
    _phoneCtrl = TextEditingController(text: widget.initialPhone ?? '+92 344 1122334');
    _cnicCtrl = TextEditingController(text: '');
    _vehicleModelCtrl = TextEditingController(text: 'Honda CG 125');
    _plateNumberCtrl = TextEditingController(text: '');
    _licenseNumberCtrl = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _phoneCtrl.dispose();
    _cnicCtrl.dispose();
    _vehicleModelCtrl.dispose();
    _plateNumberCtrl.dispose();
    _licenseNumberCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmitRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    await Future<void>.delayed(const Duration(milliseconds: 300));

    RiderDemoController.instance.registerRider(
      name: _fullNameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      vehicleType: _selectedVehicleType,
      vehicleModel: _vehicleModelCtrl.text.trim(),
      plateNumber: _plateNumberCtrl.text.trim(),
      licenseNumber: _licenseNumberCtrl.text.trim().isNotEmpty
          ? _licenseNumberCtrl.text.trim()
          : 'BK-M-2025-APP',
      cnic: _cnicCtrl.text.trim(),
      preferredZone: _selectedZone,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.pushReplacement<void, void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const RiderPendingApprovalScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Rider Partner Registration'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Banner
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(50),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(40),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.two_wheeler, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Join Batkhela Delivery Fleet',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Earn flexible income delivering food & groceries across Batkhela.',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // SECTION 1: Personal KYC
                _buildSectionHeader(
                  icon: Icons.person_outline,
                  title: '1. Personal Information & CNIC',
                  subtitle: 'Official credentials for identity verification',
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _fullNameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Full Legal Name *',
                    hintText: 'e.g. Kamran Khan',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Active Contact Number *',
                    hintText: 'e.g. +92 344 1122334',
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _cnicCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'National CNIC Number *',
                    hintText: 'e.g. 15402-1234567-1',
                    prefixIcon: const Icon(Icons.credit_card),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter your 13-digit CNIC';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // SECTION 2: Vehicle Information
                _buildSectionHeader(
                  icon: Icons.directions_bike_outlined,
                  title: '2. Vehicle & License Details',
                  subtitle: 'Transport details for delivery orders',
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  initialValue: _selectedVehicleType,
                  decoration: InputDecoration(
                    labelText: 'Vehicle Category *',
                    prefixIcon: const Icon(Icons.category_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: _vehicleTypes.map((t) {
                    return DropdownMenuItem(value: t, child: Text(t));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedVehicleType = val);
                  },
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _vehicleModelCtrl,
                        decoration: InputDecoration(
                          labelText: 'Make & Model *',
                          hintText: 'e.g. Honda 125',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _plateNumberCtrl,
                        decoration: InputDecoration(
                          labelText: 'Number Plate *',
                          hintText: 'e.g. BK-M-2024-88',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _licenseNumberCtrl,
                  decoration: InputDecoration(
                    labelText: 'Driving License Number (Optional)',
                    hintText: 'e.g. DL-MALAKAND-2024-91',
                    prefixIcon: const Icon(Icons.badge_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),

                // SECTION 3: Service Zone
                _buildSectionHeader(
                  icon: Icons.map_outlined,
                  title: '3. Preferred Batkhela Operating Zone',
                  subtitle: 'Area where you prefer to receive orders',
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  initialValue: _selectedZone,
                  decoration: InputDecoration(
                    labelText: 'Preferred Operational Zone *',
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: _batkhelaZones.map((z) {
                    return DropdownMenuItem(value: z, child: Text(z));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedZone = val);
                  },
                ),
                const SizedBox(height: 20),

                // SECTION 4: Document KYC Verification Proof
                _buildSectionHeader(
                  icon: Icons.verified_user_outlined,
                  title: '4. Document KYC Verification Proof',
                  subtitle: 'Select document uploaded for physical verification',
                ),
                const SizedBox(height: 12),

                ...List.generate(_docPresets.length, (index) {
                  final doc = _docPresets[index];
                  final isSelected = _selectedDocType == doc['title'];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    color: isSelected ? AppColors.primary.withAlpha(10) : Colors.white,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isSelected ? AppColors.primary : Colors.grey.shade200,
                        foregroundColor: isSelected ? Colors.white : Colors.grey.shade700,
                        child: Icon(doc['icon'] as IconData, size: 20),
                      ),
                      title: Text(
                        doc['title'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected ? AppColors.primary : Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        doc['desc'] as String,
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: AppColors.primary)
                          : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
                      onTap: () => setState(() => _selectedDocType = doc['title'] as String),
                    ),
                  );
                }),
                const SizedBox(height: 24),

                // Terms Notice
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'By registering, you agree to Batkhela Marketplace delivery safety terms and road regulations.',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

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
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Text(
                            'Submit Rider Application',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
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
