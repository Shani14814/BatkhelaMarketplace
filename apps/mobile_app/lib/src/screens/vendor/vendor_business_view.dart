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
              // Store Header Card with Banner & Logo
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                clipBehavior: Clip.antiAlias,
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner Image
                    Stack(
                      children: [
                        SizedBox(
                          height: 110,
                          width: double.infinity,
                          child: MarketplaceProductImage(
                            imageUrl: store.bannerUrl,
                            productName: store.name,
                            category: store.category,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  store.isVerified ? Icons.verified : Icons.hourglass_top,
                                  color: store.isVerified ? const Color(0xFF4ADE80) : Colors.amber,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  store.isVerified ? 'VERIFIED' : 'PENDING',
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Store Logo
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.08),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
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
                  ],
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
    String selectedLogo = store.logoUrl ?? 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=500&q=80';
    String selectedBanner = store.bannerUrl ?? 'https://images.unsplash.com/photo-1544025162-d76694265947?w=1200&q=80';

    final List<Map<String, String>> logoPresets = [
      {'label': 'Shinwari BBQ', 'url': 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=500&q=80'},
      {'label': 'Super Mart', 'url': 'https://images.unsplash.com/photo-1578916171728-46686eac8d58?w=500&q=80'},
      {'label': 'Pharmacy', 'url': 'https://images.unsplash.com/photo-1586015555751-63bb77f4322a?w=500&q=80'},
      {'label': 'Fresh Fruit', 'url': 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=500&q=80'},
      {'label': 'Bakery Sweets', 'url': 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=500&q=80'},
    ];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
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
                    const SizedBox(height: 14),

                    // Logo & Banner Preview & Presets
                    const Text('Store Logo Preset', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 70,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: logoPresets.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final item = logoPresets[index];
                          final isSel = selectedLogo == item['url'];
                          return GestureDetector(
                            onTap: () => setModalState(() => selectedLogo = item['url']!),
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSel ? AppColors.primary : Colors.grey.shade300,
                                  width: isSel ? 3 : 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: MarketplaceProductImage(
                                  imageUrl: item['url'],
                                  productName: item['label']!,
                                  category: item['label'],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 14),

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
                            logoUrl: selectedLogo,
                            bannerUrl: selectedBanner,
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
      },
    );
  }
}
