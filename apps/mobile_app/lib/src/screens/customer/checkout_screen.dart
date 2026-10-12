import 'dart:async';
import 'package:flutter/material.dart';
import 'package:marketplace_core/marketplace_core.dart';
import '../../data/customer_demo_data.dart';
import '../../data/rider_demo_data.dart';
import '../../data/vendor_demo_data.dart';
import '../../services/live_sync_controller.dart';
import '../../widgets/route_navigation_preview.dart';
import 'order_confirmation_screen.dart';

/// Soft, Clean, Clutter-Free Checkout & Exact GPS Pin Picker Screen
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  static const Color _bgCream = Color(0xFFFAF6F0);
  static const Color _brandRed = Color(0xFFC8102E);
  static const Color _brandRedDark = Color(0xFF9E0B22);
  static const Color _textDark = Color(0xFF1E1915);
  static const Color _textMuted = Color(0xFF6E655F);
  static const Color _softBorder = Color(0xFFEDE6DC);

  String _selectedAddress = CustomerDemoData.activeDeliveryAddress;
  double _selectedLat = 34.6186;
  double _selectedLng = 71.9723;
  bool _isDetectingExactLocation = false;
  String _paymentMethod = 'cash_on_delivery';
  final TextEditingController _notesController = TextEditingController();
  bool _isPlacingOrder = false;

  static const List<Map<String, dynamic>> _quickLocations = [
    {
      'label': '🏠 Main Bazaar',
      'address': 'Main Bazaar, Near Clock Tower, Batkhela',
      'lat': 34.6186,
      'lng': 71.9723,
    },
    {
      'label': '🏡 Zargarano',
      'address': 'House 14, Street 2, Mohallah Zargarano, Batkhela',
      'lat': 34.6204,
      'lng': 71.9748,
    },
    {
      'label': '🏢 GT Road Plaza',
      'address': 'Shop 5, Al-Khyber Plaza, Main GT Road, Batkhela',
      'lat': 34.6169,
      'lng': 71.9695,
    },
    {
      'label': '🏥 Hospital Road',
      'address': 'Hospital Road, Near DHQ Hospital, Batkhela',
      'lat': 34.6228,
      'lng': 71.9779,
    },
    {
      'label': '🎓 College Road',
      'address': 'College Road, Near Degree College, Batkhela',
      'lat': 34.6249,
      'lng': 71.9812,
    },
  ];

  @override
  void initState() {
    super.initState();
    LiveSyncController.instance.startLiveSync();
    if (!HostingerApiClient.instance.isTestEnvironment) {
      unawaited(_fetchCustomerExactGpsLocation());
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  String _cleanAddressDisplay(String raw) {
    // Strip trailing "(34.xxxx, 71.xxxx)" if present so UI stays clean and readable
    return raw.replaceAll(RegExp(r'\s*\([-0-9.,°\sNE]+\)\s*$'), '').trim();
  }

  Future<void> _fetchCustomerExactGpsLocation() async {
    if (!mounted) return;
    setState(() => _isDetectingExactLocation = true);
    try {
      final gps = await HostingerApiClient.instance.getCurrentDeviceGps();
      if (gps != null && mounted) {
        final resolvedAddr = await HostingerApiClient.instance.reverseGeocode(
          gps.latitude,
          gps.longitude,
        );
        if (!mounted) return;
        setState(() {
          _selectedLat = gps.latitude;
          _selectedLng = gps.longitude;
          _selectedAddress = resolvedAddr;
          CustomerDemoData.activeDeliveryAddress = resolvedAddr;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isDetectingExactLocation = false);
      }
    }
  }

  void _showAddressPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Choose Delivery Location',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Use your live GPS pin or select a popular Batkhela area',
                  style: TextStyle(fontSize: 12.5, color: _textMuted),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _brandRed,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _fetchCustomerExactGpsLocation();
                    },
                    icon: const Icon(Icons.my_location_rounded, size: 18),
                    label: const Text(
                      'Use My Current GPS Location',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _quickLocations.length,
                    separatorBuilder: (_, _) => const Divider(height: 8, color: _softBorder),
                    itemBuilder: (context, idx) {
                      final loc = _quickLocations[idx];
                      final addr = loc['address'] as String;
                      final lat = (loc['lat'] as num).toDouble();
                      final lng = (loc['lng'] as num).toDouble();
                      final isSelected = _cleanAddressDisplay(addr) == _cleanAddressDisplay(_selectedAddress);
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                        leading: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFFEE2E2) : _bgCream,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.location_on_rounded,
                            color: isSelected ? _brandRed : _textMuted,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          addr,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: _textDark,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle_rounded, color: _brandRed, size: 20)
                            : null,
                        onTap: () {
                          setState(() {
                            _selectedAddress = addr;
                            _selectedLat = lat;
                            _selectedLng = lng;
                            CustomerDemoData.activeDeliveryAddress = addr;
                          });
                          Navigator.pop(ctx);
                        },
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

  Future<void> _handlePlaceOrder() async {
    final cart = CartController.instance;
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty. Please add items before checkout.')),
      );
      return;
    }

    setState(() => _isPlacingOrder = true);

    final currentUserId = AuthService.instance.currentProfile?.id ?? 'usr_customer_1';
    final vendorId = cart.currentVendorId ?? 'store-1';
    final orderItems = cart.items.map((i) {
      return OrderItem(
        id: 'item-${DateTime.now().millisecondsSinceEpoch}-${i.product.id}',
        orderId: '',
        productId: i.product.id,
        productName: i.product.name,
        unitPrice: i.unitPrice,
        quantity: i.quantity,
        totalPrice: i.totalPrice,
      );
    }).toList();

    final orderNumber = 1000 + DateTime.now().millisecondsSinceEpoch % 9000;

    final newOrder = MarketplaceOrder(
      id: 'ord-${DateTime.now().millisecondsSinceEpoch}',
      orderNumber: orderNumber,
      customerId: currentUserId,
      vendorId: vendorId,
      subtotal: cart.subtotal,
      deliveryFee: cart.deliveryFee,
      platformFee: cart.platformFee,
      totalAmount: cart.totalAmount,
      status: OrderStatus.placed,
      paymentMethod: _paymentMethod,
      paymentStatus: _paymentMethod == 'cash_on_delivery' ? 'pending' : 'paid',
      deliveryAddress: _cleanAddressDisplay(_selectedAddress),
      deliveryLat: _selectedLat,
      deliveryLng: _selectedLng,
      riderLat: RiderDemoController.instance.liveRiderLat,
      riderLng: RiderDemoController.instance.liveRiderLng,
      customerNotes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      items: orderItems,
      createdAt: DateTime.now(),
    );

    CustomerDemoData.addPlacedOrder(newOrder);
    VendorDemoController.instance.orders.insert(0, newOrder);

    await HostingerApiClient.instance.placeOrder(newOrder);

    try {
      await MarketplaceDataService.instance.orderRepo.placeOrder(newOrder);
    } catch (_) {}

    try {
      await MarketplaceDataService.instance.notificationController.dispatchNotification(
        title: 'Order #$orderNumber Placed!',
        body: 'Your order from ${cart.currentVendorName ?? "Store"} has been confirmed.',
        type: NotificationType.orderPlaced,
        orderId: newOrder.id,
        payload: {'order_id': newOrder.id},
      );
    } catch (_) {}

    CartController.instance.clear();

    if (!mounted) return;
    setState(() => _isPlacingOrder = false);

    Navigator.pushReplacement<void, void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) => OrderConfirmationScreen(order: newOrder),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartController.instance;

    return AnimatedBuilder(
      animation: LiveSyncController.instance,
      builder: (context, _) {
        final activeOutOrder = CustomerDemoData.demoOrders
            .where((o) => o.status == OrderStatus.outForDelivery)
            .firstOrNull;
        final liveRiderLat = activeOutOrder?.riderLat ?? RiderDemoController.instance.liveRiderLat;
        final liveRiderLng = activeOutOrder?.riderLng ?? RiderDemoController.instance.liveRiderLng;
        final cleanAddr = _cleanAddressDisplay(_selectedAddress);

        return Scaffold(
          backgroundColor: _bgCream,
          appBar: AppBar(
            backgroundColor: _bgCream,
            foregroundColor: _textDark,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: false,
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Checkout',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: _textDark,
                    letterSpacing: -0.4,
                  ),
                ),
                Text(
                  'Confirm your delivery pin & payment',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: _textMuted,
                  ),
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      // 1. Clean Soft Delivery Location & Map Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: _softBorder),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(8),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Row
                            Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEE2E2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.location_on_rounded,
                                    color: _brandRed,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Delivery Location',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 15.5,
                                          color: _textDark,
                                        ),
                                      ),
                                      Text(
                                        'Drag or tap map to set exact doorstep pin',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: _textMuted,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () => _showAddressPicker(context),
                                  style: TextButton.styleFrom(
                                    backgroundColor: _bgCream,
                                    foregroundColor: _brandRed,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  icon: const Icon(Icons.edit_location_alt_rounded, size: 15),
                                  label: const Text(
                                    'Change',
                                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Clean Interactive Map (NO duplicate footer below!)
                            RouteNavigationPreview(
                              originTitle: cart.currentVendorName ?? 'Batkhela Store',
                              originAddress: 'Main Bazaar, Batkhela',
                              destinationTitle: 'Delivery Pin',
                              destinationAddress: cleanAddr,
                              distanceKm: 1.8,
                              estimatedMinutes: 12,
                              originLat: 34.6175,
                              originLng: 71.9712,
                              destinationLat: _selectedLat,
                              destinationLng: _selectedLng,
                              riderLat: liveRiderLat,
                              riderLng: liveRiderLng,
                              isOutForDelivery: activeOutOrder != null,
                              enablePinPicker: true,
                              showRouteDetailsFooter: false,
                              onLocationPicked: (lat, lng, resolvedAddr) {
                                setState(() {
                                  _selectedLat = lat;
                                  _selectedLng = lng;
                                  _selectedAddress = resolvedAddr;
                                  CustomerDemoData.activeDeliveryAddress = resolvedAddr;
                                });
                              },
                            ),
                            const SizedBox(height: 12),

                            // Single Clean Selected Address Pill Box
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: _bgCream,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: _softBorder),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.home_work_rounded, size: 18, color: _brandRed),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          cleanAddr,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                            color: _textDark,
                                            height: 1.25,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.verified_rounded,
                                              size: 13,
                                              color: Color(0xFF15803D),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              _isDetectingExactLocation
                                                  ? 'Detecting live GPS...'
                                                  : 'Exact GPS Pin Ready for Rider',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF15803D),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Quick Area Chips
                            SizedBox(
                              height: 34,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                itemCount: _quickLocations.length,
                                separatorBuilder: (_, _) => const SizedBox(width: 8),
                                itemBuilder: (context, idx) {
                                  final loc = _quickLocations[idx];
                                  final addr = loc['address'] as String;
                                  final label = loc['label'] as String;
                                  final lat = (loc['lat'] as num).toDouble();
                                  final lng = (loc['lng'] as num).toDouble();
                                  final isSelected = _cleanAddressDisplay(addr) == cleanAddr;

                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedAddress = addr;
                                        _selectedLat = lat;
                                        _selectedLng = lng;
                                        CustomerDemoData.activeDeliveryAddress = addr;
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 180),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isSelected ? _brandRed : Colors.white,
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                          color: isSelected ? _brandRed : _softBorder,
                                        ),
                                      ),
                                      child: Text(
                                        label,
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w800,
                                          color: isSelected ? Colors.white : _textDark,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 2. Soft Order Items & Delivery Note Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: _softBorder),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(8),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: _bgCream,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.shopping_bag_rounded, size: 18, color: _brandRed),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    cart.currentVendorName ?? 'Your Order Items',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      color: _textDark,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _bgCream,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${cart.totalItemCount} ${cart.totalItemCount == 1 ? "Item" : "Items"}',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                      color: _brandRed,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(height: 1, color: _softBorder),
                            ),
                            ...cart.items.map((i) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEE2E2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${i.quantity}x',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 12,
                                          color: _brandRed,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        i.product.name,
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700,
                                          color: _textDark,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Rs. ${i.totalPrice.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w900,
                                        color: _textDark,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            const SizedBox(height: 6),
                            // Soft Integrated Rider Note Field
                            Container(
                              decoration: BoxDecoration(
                                color: _bgCream,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: _softBorder),
                              ),
                              child: TextField(
                                controller: _notesController,
                                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: _textDark),
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.sticky_note_2_outlined, size: 18, color: _textMuted),
                                  hintText: 'Add delivery note (e.g. Ring bell, call at gate)...',
                                  hintStyle: TextStyle(fontSize: 12, color: _textMuted),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 3. Soft Visual Payment Method Selector
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: _softBorder),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(8),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Payment Method',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 15.5,
                                color: _textDark,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildPaymentOptionTile(
                              id: 'cash_on_delivery',
                              emoji: '💵',
                              title: 'Cash on Delivery (COD)',
                              subtitle: 'Pay cash when your order arrives',
                              badge: 'POPULAR',
                            ),
                            const SizedBox(height: 10),
                            _buildPaymentOptionTile(
                              id: 'jazzcash_easypaisa',
                              emoji: '📱',
                              title: 'JazzCash / Easypaisa',
                              subtitle: 'Instant mobile wallet transfer',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 4. Clean Bill Summary Card
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: _softBorder),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(8),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Bill Summary',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 15.5,
                                color: _textDark,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildSummaryRow(
                              'Items Subtotal',
                              'Rs. ${cart.subtotal.toStringAsFixed(0)}',
                            ),
                            const SizedBox(height: 8),
                            _buildSummaryRow(
                              'Delivery Fee',
                              cart.deliveryFee == 0
                                  ? 'FREE'
                                  : 'Rs. ${cart.deliveryFee.toStringAsFixed(0)}',
                              valueColor: cart.deliveryFee == 0 ? const Color(0xFF15803D) : _textDark,
                            ),
                            const SizedBox(height: 8),
                            _buildSummaryRow(
                              'Platform & Service Fee',
                              'Rs. ${cart.platformFee.toStringAsFixed(0)}',
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(height: 1, color: _softBorder),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total Payable',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: _textDark,
                                  ),
                                ),
                                Text(
                                  'Rs. ${cart.totalAmount.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: _brandRed,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Floating Bottom Place Order Bar
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: const Border(top: BorderSide(color: _softBorder)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(12),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_brandRed, _brandRedDark],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: _brandRed.withAlpha(85),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isPlacingOrder ? null : _handlePlaceOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        child: _isPlacingOrder
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.check_circle_outline_rounded, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        _paymentMethod == 'cash_on_delivery'
                                            ? 'Place Order (COD)'
                                            : 'Place Order (Wallet)',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withAlpha(45),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Rs. ${cart.totalAmount.toStringAsFixed(0)} →',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentOptionTile({
    required String id,
    required String emoji,
    required String title,
    required String subtitle,
    String? badge,
  }) {
    final isSelected = _paymentMethod == id;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF5F6) : _bgCream,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _brandRed : _softBorder,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _softBorder),
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: _textDark,
                          ),
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badge,
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF15803D),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11.5, color: _textMuted),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: isSelected ? _brandRed : _textMuted,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: _textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: valueColor ?? _textDark,
          ),
        ),
      ],
    );
  }
}
