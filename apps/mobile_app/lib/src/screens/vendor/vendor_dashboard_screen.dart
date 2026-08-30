import 'package:flutter/material.dart';
import 'package:marketplace_core/marketplace_core.dart';

class VendorDashboardScreen extends StatefulWidget {
  const VendorDashboardScreen({super.key});

  @override
  State<VendorDashboardScreen> createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboardScreen> {
  bool _isStoreOpen = true;

  final List<MarketplaceOrder> _vendorOrders = [
    MarketplaceOrder(
      id: 'ORD-501',
      orderNumber: 1042,
      customerId: 'CUST-01',
      vendorId: 'V-1',
      subtotal: 1450.0,
      totalAmount: 1600.0,
      status: OrderStatus.placed,
      deliveryAddress: 'Main Bazaar Road, Near GPO, Batkhela',
      customerNotes: 'Please make it medium spicy.',
      createdAt: DateTime.now().subtract(const Duration(minutes: 3)),
    ),
    MarketplaceOrder(
      id: 'ORD-500',
      orderNumber: 1039,
      customerId: 'CUST-02',
      vendorId: 'V-1',
      subtotal: 2900.0,
      totalAmount: 3100.0,
      status: OrderStatus.preparing,
      deliveryAddress: 'Civil Hospital Colony, Batkhela',
      createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store Manager: Shinwari Tikka'),
        actions: [
          Switch(
            value: _isStoreOpen,
            activeThumbColor: AppTheme.primaryGreen,
            onChanged: (val) {
              setState(() => _isStoreOpen = val);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isStoreOpen ? 'Store is now ONLINE & accepting orders' : 'Store is OFFLINE'),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Store Status Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isStoreOpen ? AppTheme.primaryGreen.withAlpha(20) : Colors.red.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isStoreOpen ? AppTheme.primaryGreen.withAlpha(80) : Colors.red.withAlpha(80),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _isStoreOpen ? Icons.check_circle : Icons.pause_circle,
                  color: _isStoreOpen ? AppTheme.primaryGreen : AppTheme.errorRed,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _isStoreOpen ? 'Accepting Orders across Batkhela' : 'Store is paused for new orders',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _isStoreOpen ? AppTheme.primaryGreen : AppTheme.errorRed,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Realtime Orders Queue
          const Text(
            'Incoming Orders Queue',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ..._vendorOrders.map((order) {
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order #${order.orderNumber ?? order.id}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Rs. ${order.totalAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Delivery to: ${order.deliveryAddress}'),
                    if (order.customerNotes != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Note: ${order.customerNotes}',
                        style: const TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.w600),
                      ),
                    ],
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (order.status == OrderStatus.placed) ...[
                          OutlinedButton(
                            onPressed: () {},
                            child: const Text('Reject'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Order Accepted! Notified rider network.')),
                              );
                            },
                            child: const Text('Accept Order'),
                          ),
                        ] else if (order.status == OrderStatus.preparing) ...[
                          ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Order marked Ready for Rider Pickup!')),
                              );
                            },
                            icon: const Icon(Icons.check, size: 18),
                            label: const Text('Mark Ready for Pickup'),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
