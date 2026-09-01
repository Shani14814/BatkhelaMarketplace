import '../../models/category.dart';
import '../../models/vendor.dart';
import '../../models/product.dart';
import '../../models/customer_address.dart';
import '../../models/order.dart';
import '../customer_repository.dart';
import 'demo_category_repository.dart';

class DemoCustomerRepository implements CustomerRepository {
  final DemoCategoryRepository _categoryRepo;

  final List<Vendor> _vendors = [
    Vendor(
      id: 'store-1',
      storeName: 'Khyber Shinwari Tikka & Karahi',
      slug: 'khyber-shinwari',
      description: 'Authentic Shinwari Karahi, Dum Pukht, Chapli Kabab & BBQ near Main Bazar Batkhela',
      logoUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=500&q=80',
      bannerUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?w=1200&q=80',
      address: 'Main Bazar, GT Road, Batkhela',
      latitude: 34.6185,
      longitude: 71.9723,
      phone: '+92 345 9001122',
      commissionRate: 10.0,
      isOpen: true,
      isVerified: true,
      createdAt: DateTime(2026, 1, 1),
    ),
    Vendor(
      id: 'store-2',
      storeName: 'Madina Super Store & Grocery',
      slug: 'madina-super-store',
      description: 'Fresh groceries, spices, dairy products and household essentials at wholesale prices',
      logoUrl: 'https://images.unsplash.com/photo-1578916171728-46686eac8d58?w=500&q=80',
      bannerUrl: 'https://images.unsplash.com/photo-1604719312566-8912e9227c6a?w=1200&q=80',
      address: 'College Road, Batkhela',
      latitude: 34.6190,
      longitude: 71.9730,
      phone: '+92 345 9003344',
      commissionRate: 8.0,
      isOpen: true,
      isVerified: true,
      createdAt: DateTime(2026, 1, 5),
    ),
    Vendor(
      id: 'store-3',
      storeName: 'Batkhela Fresh Fruit & Sabzi Mandi',
      slug: 'fresh-fruits-sabzi',
      description: 'Hand-picked Swat Valley apples, peaches, and organic farm-fresh seasonal vegetables',
      logoUrl: 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=500&q=80',
      bannerUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=1200&q=80',
      address: 'Near Old Bus Stand, Batkhela',
      latitude: 34.6175,
      longitude: 71.9710,
      phone: '+92 345 9005566',
      commissionRate: 7.0,
      isOpen: true,
      isVerified: true,
      createdAt: DateTime(2026, 1, 10),
    ),
    Vendor(
      id: 'store-4',
      storeName: 'Al-Shifa Medicos & 24/7 Pharmacy',
      slug: 'al-shifa-medicos',
      description: 'Licensed pharmacy providing prescription medicines, surgical items, and baby care',
      logoUrl: 'https://images.unsplash.com/photo-1586015555751-63bb77f4322a?w=500&q=80',
      bannerUrl: 'https://images.unsplash.com/photo-1576602976047-174e57a47881?w=1200&q=80',
      address: 'Hospital Road, Batkhela',
      latitude: 34.6200,
      longitude: 71.9740,
      phone: '+92 345 9007788',
      commissionRate: 5.0,
      isOpen: true,
      isVerified: true,
      createdAt: DateTime(2026, 1, 15),
    ),
  ];

  final List<Product> _products = [
    Product(
      id: 'p-1',
      vendorId: 'store-1',
      categoryId: 'cat-1',
      category: 'Food & Dining',
      name: 'Special Shinwari Mutton Karahi (1 KG)',
      description: 'Fresh organic mutton cooked in its own natural fat with tomatoes, salt, and green chilies.',
      price: 2400.0,
      discountPrice: 2250.0,
      stockQuantity: 25,
      isAvailable: true,
      imageUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?w=800&q=80',
      createdAt: DateTime(2026, 1, 1),
    ),
    Product(
      id: 'p-2',
      vendorId: 'store-1',
      categoryId: 'cat-1',
      category: 'Food & Dining',
      name: 'Peshawari Chapli Kabab (Plate)',
      description: 'Spiced minced beef patties shallow fried with tomato slices and crushed coriander.',
      price: 450.0,
      discountPrice: 400.0,
      stockQuantity: 40,
      isAvailable: true,
      imageUrl: 'https://images.unsplash.com/photo-1599488615731-7e5c2823ff28?w=800&q=80',
      createdAt: DateTime(2026, 1, 2),
    ),
    Product(
      id: 'p-3',
      vendorId: 'store-2',
      categoryId: 'cat-2',
      category: 'Grocery & Essentials',
      name: 'Premium Super Basmati Rice (5 KG)',
      description: 'Aged long-grain aromatic rice from premium Punjab fields.',
      price: 1850.0,
      discountPrice: 1750.0,
      stockQuantity: 50,
      isAvailable: true,
      imageUrl: 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=800&q=80',
      createdAt: DateTime(2026, 1, 5),
    ),
    Product(
      id: 'p-4',
      vendorId: 'store-3',
      categoryId: 'cat-3',
      category: 'Fruits & Vegetables',
      name: 'Swat Royal Gala Apples (1 KG)',
      description: 'Freshly harvested, crisp, and naturally sweet high-altitude apples.',
      price: 320.0,
      discountPrice: 280.0,
      stockQuantity: 60,
      isAvailable: true,
      imageUrl: 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=800&q=80',
      createdAt: DateTime(2026, 1, 10),
    ),
    Product(
      id: 'p-5',
      vendorId: 'store-4',
      categoryId: 'cat-4',
      category: 'Pharmacy & Health',
      name: 'Panadol Extra 500mg (Box 100 Tabs)',
      description: 'Authentic Paracetamol formulation for fast relief from fever and pain.',
      price: 420.0,
      stockQuantity: 80,
      isAvailable: true,
      imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=800&q=80',
      createdAt: DateTime(2026, 1, 15),
    ),
  ];

  final List<CustomerAddress> _addresses = [
    CustomerAddress(
      id: 'addr-1',
      userId: 'demo-user-default',
      title: 'Home',
      fullAddress: 'House 14, Street 2, Mohallah Zargarano, Batkhela',
      landmark: 'Near Govt Degree College',
      city: 'Batkhela',
      latitude: 34.6185,
      longitude: 71.9720,
      isDefault: true,
      createdAt: DateTime(2026, 2, 1),
    ),
    CustomerAddress(
      id: 'addr-2',
      userId: 'demo-user-default',
      title: 'Office / Shop',
      fullAddress: 'Shop 5, Al-Khyber Commercial Plaza, Main GT Road',
      landmark: 'Opposite District Courts',
      city: 'Batkhela',
      latitude: 34.6192,
      longitude: 71.9745,
      isDefault: false,
      createdAt: DateTime(2026, 2, 10),
    ),
  ];

  final List<MarketplaceOrder> _orders = [];

  DemoCustomerRepository({DemoCategoryRepository? categoryRepo})
      : _categoryRepo = categoryRepo ?? DemoCategoryRepository();

  @override
  Future<List<MarketplaceCategory>> getCategories() async {
    return _categoryRepo.getActiveCategories();
  }

  @override
  Future<List<Vendor>> getVendors({String? categoryId, String? searchQuery}) async {
    var result = _vendors.where((v) => v.isVerified).toList();
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      result = result
          .where((v) =>
              v.storeName.toLowerCase().contains(query) ||
              (v.description?.toLowerCase().contains(query) ?? false) ||
              v.address.toLowerCase().contains(query))
          .toList();
    }
    return result;
  }

  @override
  Future<Vendor?> getVendorById(String vendorId) async {
    final match = _vendors.where((v) => v.id == vendorId);
    return match.isNotEmpty ? match.first : null;
  }

  @override
  Future<List<Product>> getVendorProducts(String vendorId) async {
    return _products.where((p) => p.vendorId == vendorId && p.isAvailable).toList();
  }

  @override
  Future<List<CustomerAddress>> getCustomerAddresses(String userId) async {
    return _addresses.where((a) => a.userId == userId || a.userId == 'demo-user-default').toList();
  }

  @override
  Future<CustomerAddress> addCustomerAddress(CustomerAddress address) async {
    _addresses.add(address);
    return address;
  }

  @override
  Future<void> setDefaultAddress(String userId, String addressId) async {
    for (int i = 0; i < _addresses.length; i++) {
      if (_addresses[i].userId == userId || _addresses[i].userId == 'demo-user-default') {
        _addresses[i] = _addresses[i].copyWith(isDefault: _addresses[i].id == addressId);
      }
    }
  }

  @override
  Future<List<MarketplaceOrder>> getCustomerOrders(String customerId) async {
    return _orders.where((o) => o.customerId == customerId || customerId.startsWith('demo-user')).toList();
  }

  @override
  Future<MarketplaceOrder> createOrder(MarketplaceOrder order) async {
    // Trusted calculation verification
    double calculatedSubtotal = 0.0;
    for (final item in order.items) {
      calculatedSubtotal += item.totalPrice;
    }
    final trustedTotal = calculatedSubtotal + order.deliveryFee + order.platformFee;

    final verifiedOrder = MarketplaceOrder(
      id: 'ord-${DateTime.now().millisecondsSinceEpoch}',
      orderNumber: 1000 + _orders.length + 1,
      customerId: order.customerId,
      vendorId: order.vendorId,
      subtotal: calculatedSubtotal > 0 ? calculatedSubtotal : order.subtotal,
      deliveryFee: order.deliveryFee,
      platformFee: order.platformFee,
      totalAmount: trustedTotal > 0 ? trustedTotal : order.totalAmount,
      status: OrderStatus.placed,
      paymentMethod: order.paymentMethod,
      paymentStatus: 'pending',
      deliveryAddress: order.deliveryAddress,
      deliveryLat: order.deliveryLat,
      deliveryLng: order.deliveryLng,
      customerNotes: order.customerNotes,
      items: order.items,
      createdAt: DateTime.now(),
    );

    _orders.insert(0, verifiedOrder);
    return verifiedOrder;
  }
}
