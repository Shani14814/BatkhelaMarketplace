import 'package:flutter/material.dart';
import 'package:marketplace_core/marketplace_core.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final int _cartItemCount = 2;

  final List<Vendor> _vendors = [
    Vendor(
      id: 'V-1',
      storeName: 'Batkhela Shinwari Tikka',
      slug: 'shinwari-tikka',
      description: 'Authentic Shinwari Karahi, BBQ, Kababs & Naan',
      address: 'Main GT Road, Batkhela',
      phone: '0345-9876543',
      isVerified: true,
      isOpen: true,
      createdAt: DateTime.now(),
    ),
    Vendor(
      id: 'V-2',
      storeName: 'Swat Valley Fresh Grocery',
      slug: 'swat-grocery',
      description: 'Fresh vegetables, seasonal fruits, dairy & essentials',
      address: 'Sabzi Mandi Road, Batkhela',
      isVerified: true,
      isOpen: true,
      createdAt: DateTime.now(),
    ),
    Vendor(
      id: 'V-3',
      storeName: 'Malakand Sweets & Bakers',
      slug: 'malakand-sweets',
      description: 'Traditional Batkhela sweets, cakes, and fresh biscuits',
      address: 'College Road, Batkhela',
      isVerified: true,
      isOpen: true,
      createdAt: DateTime.now(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delivering to',
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
            Row(
              children: [
                Icon(Icons.location_on, color: AppTheme.primaryGreen, size: 16),
                SizedBox(width: 4),
                Text(
                  'Batkhela Main Bazaar',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Icon(Icons.keyboard_arrow_down, size: 16),
              ],
            ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined),
                onPressed: () => _showCartSheet(context),
              ),
              if (_cartItemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$_cartItemCount',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search food, groceries, medicines in Batkhela...',
              prefixIcon: const Icon(Icons.search),
              fillColor: Colors.grey.shade100,
            ),
          ),
          const SizedBox(height: 20),

          // Promotional Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryGreen, AppTheme.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.accentGold,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'BATKHELA EXCLUSIVE',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Fast Delivery Across Batkhela & Thana',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Flat Rs. 80 delivery fee on your first order',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.delivery_dining, size: 48, color: Colors.white),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Featured Stores Section
          const Text(
            'Popular Stores in Batkhela',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ..._vendors.map((vendor) {
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 120,
                    color: AppTheme.primaryGreen.withAlpha(20),
                    alignment: Alignment.center,
                    child: Icon(Icons.restaurant, size: 48, color: AppTheme.primaryGreen.withAlpha(100)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              vendor.storeName,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const Row(
                              children: [
                                Icon(Icons.star, color: AppTheme.accentGold, size: 16),
                                SizedBox(width: 4),
                                Text('4.8 (120+)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ],
                        ),
                        if (vendor.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            vendor.description!,
                            style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                          ),
                        ],
                        const SizedBox(height: 8),
                        const Row(
                          children: [
                            Icon(Icons.access_time, size: 14, color: AppTheme.textMuted),
                            SizedBox(width: 4),
                            Text('20-30 min', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                            SizedBox(width: 16),
                            Icon(Icons.delivery_dining, size: 14, color: AppTheme.textMuted),
                            SizedBox(width: 4),
                            Text('Rs. 100 delivery', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showCartSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your Cart', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const ListTile(
                leading: CircleAvatar(child: Text('1x')),
                title: Text('Shinwari Special Mutton Karahi (Half)'),
                trailing: Text('Rs. 1,450', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const ListTile(
                leading: CircleAvatar(child: Text('4x')),
                title: Text('Kandahari Roghani Naan'),
                trailing: Text('Rs. 160', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const Spacer(),
              const Divider(),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total (including delivery):', style: TextStyle(fontWeight: FontWeight.w600)),
                  Text('Rs. 1,710', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Order placed successfully! Connecting to Batkhela Dispatcher.')),
                    );
                  },
                  child: const Text('Confirm & Place Order'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
