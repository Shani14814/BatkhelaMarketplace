import 'package:flutter/material.dart';
import 'package:marketplace_core/marketplace_core.dart';
import '../../data/vendor_demo_data.dart';

class VendorBusinessView extends StatelessWidget {
  const VendorBusinessView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: VendorDemoController.instance,
      builder: (context, _) {
        final store = VendorDemoController.instance.store;

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: const Text(
              'Store Profile & Settings',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                tooltip: 'Edit Store Details',
                onPressed: () => _showEditBusinessModal(context, store),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Store Header Card
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
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(20),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.storefront, color: AppColors.primary, size: 32),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  store.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  store.category,
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.star_rounded, size: 18, color: AppColors.warning),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${store.rating} (${store.reviewCount} customer reviews)',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24, color: Color(0xFFF1F5F9)),

                      // Store Status Switch Tile
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: store.isOpen
                              ? AppColors.softCyan.withAlpha(45)
                              : AppColors.error.withAlpha(15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: store.isOpen
                                ? AppColors.primary.withAlpha(40)
                                : AppColors.error.withAlpha(40),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              store.isOpen ? Icons.check_circle : Icons.pause_circle_filled,
                              color: store.isOpen ? AppColors.primary : AppColors.error,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    store.isOpen ? 'Store is OPEN & Accepting Orders' : 'Store is Temporarily CLOSED',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: store.isOpen ? AppColors.primary : AppColors.error,
                                    ),
                                  ),
                                  Text(
                                    store.isOpen
                                        ? 'Batkhela customers can place instant orders'
                                        : 'Orders are paused in the customer marketplace',
                                    style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: store.isOpen,
                              activeThumbColor: AppColors.primary,
                              activeTrackColor: AppColors.softCyan,
                              onChanged: (val) {
                                VendorDemoController.instance.toggleStoreOpenStatus(val);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Operational Details
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
                        'Operational Information',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoTile(
                        icon: Icons.phone_outlined,
                        label: 'Merchant Phone',
                        value: store.phone,
                      ),
                      const Divider(height: 20, color: Color(0xFFF1F5F9)),
                      _buildInfoTile(
                        icon: Icons.location_on_outlined,
                        label: 'Store Location',
                        value: store.address,
                      ),
                      const Divider(height: 20, color: Color(0xFFF1F5F9)),
                      _buildInfoTile(
                        icon: Icons.access_time_outlined,
                        label: 'Operating Hours',
                        value: store.operatingHours,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Batkhela Vendor Badge / Tier
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: AppColors.indigo.withAlpha(30)),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.indigo.withAlpha(20),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.verified, color: AppColors.indigo, size: 24),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Verified Batkhela Merchant',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.indigo),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Malakand Division Licensed Food & Commercial Establishment',
                              style: TextStyle(fontSize: 11, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  void _showEditBusinessModal(BuildContext context, VendorStoreProfile store) {
    final nameCtrl = TextEditingController(text: store.name);
    final catCtrl = TextEditingController(text: store.category);
    final phoneCtrl = TextEditingController(text: store.phone);
    final addrCtrl = TextEditingController(text: store.address);
    final hoursCtrl = TextEditingController(text: store.operatingHours);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Edit Store Profile',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(sheetContext).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Store Business Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: catCtrl,
                  decoration: InputDecoration(
                    labelText: 'Business Category',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  decoration: InputDecoration(
                    labelText: 'Contact Phone Number',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: addrCtrl,
                  decoration: InputDecoration(
                    labelText: 'Store Address in Batkhela',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: hoursCtrl,
                  decoration: InputDecoration(
                    labelText: 'Operating Schedule',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      final name = nameCtrl.text.trim();
                      if (name.isEmpty) return;

                      VendorDemoController.instance.updateStoreProfile(
                        name: name,
                        category: catCtrl.text.trim(),
                        phone: phoneCtrl.text.trim(),
                        address: addrCtrl.text.trim(),
                        operatingHours: hoursCtrl.text.trim(),
                      );

                      Navigator.of(sheetContext).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Store profile updated successfully!')),
                      );
                    },
                    child: const Text('Save Store Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
