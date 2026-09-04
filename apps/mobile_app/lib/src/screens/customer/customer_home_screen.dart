import 'package:flutter/material.dart';
import 'package:marketplace_core/marketplace_core.dart';
import '../../data/customer_demo_data.dart';
import '../../widgets/route_navigation_preview.dart';
import '../../widgets/notification_inbox_sheet.dart';
import 'store_detail_screen.dart';

/// Customer Marketplace Main Screen featuring Stitch Bottom Navigation & 5 Core Views
class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _currentNavIndex = 0;
  String _selectedCategory = 'all';
  String _currentAddress = CustomerDemoData.activeDeliveryAddress;
  int _cartItemCount = 1;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    MarketplaceDataService.instance.notificationController.initSession(
      userId: 'usr_customer_1',
      role: 'customer',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        bottom: false,
        child: _buildCurrentTab(),
      ),
      bottomNavigationBar: MarketplaceBottomNav(
        currentIndex: _currentNavIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentNavIndex = index;
          });
        },
        destinations: [
          const MarketplaceNavDestination(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Home',
          ),
          const MarketplaceNavDestination(
            icon: Icons.grid_view_outlined,
            activeIcon: Icons.grid_view_rounded,
            label: 'Explore',
          ),
          const MarketplaceNavDestination(
            icon: Icons.search,
            activeIcon: Icons.search_rounded,
            label: 'Search',
          ),
          MarketplaceNavDestination(
            icon: Icons.receipt_long_outlined,
            activeIcon: Icons.receipt_long,
            label: 'Orders',
            badgeCount: CustomerDemoData.demoOrders.length,
          ),
          const MarketplaceNavDestination(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTab() {
    switch (_currentNavIndex) {
      case 0:
        return _buildHomeView();
      case 1:
        return _buildExploreView();
      case 2:
        return _buildSearchView();
      case 3:
        return _buildOrdersView();
      case 4:
        return _buildProfileView();
      default:
        return _buildHomeView();
    }
  }

  // ==========================================
  // TAB 0: HOME VIEW
  // ==========================================
  Widget _buildHomeView() {
    final filteredStores = _selectedCategory == 'all'
        ? CustomerDemoData.stores
        : CustomerDemoData.stores
            .where((s) => s.categoryId == _selectedCategory)
            .toList();

    return Column(
      children: [
        // Top Header
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _showLocationPicker(context),
                  borderRadius: AppRadius.roundedSm,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Text(
                              'DELIVERING TO',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Icon(Icons.keyboard_arrow_down, size: 14, color: AppColors.primary),
                          ],
                        ),
                        Text(
                          _currentAddress,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              StreamBuilder<int>(
                stream: MarketplaceDataService.instance.notificationController.unreadCountStream,
                initialData: MarketplaceDataService.instance.notificationController.currentUnreadCount,
                builder: (context, snapshot) {
                  final unreadCount = snapshot.data ?? 0;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
                        onPressed: () => NotificationInboxSheet.show(
                          context,
                          userId: 'usr_customer_1',
                          role: 'customer',
                        ),
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                            alignment: Alignment.center,
                            child: Text(
                              '$unreadCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                height: 1,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_bag_outlined, color: AppColors.textPrimary),
                    onPressed: () => _showCartOverview(context),
                  ),
                  if (_cartItemCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.coral,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        alignment: Alignment.center,
                        child: Text(
                          '$_cartItemCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),

        // Scrollable Body
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => await Future<void>.delayed(const Duration(milliseconds: 400)),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                // Search Entry Box
                Material(
                  color: Colors.white,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.roundedFull,
                    side: BorderSide(color: AppColors.borderLight),
                  ),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _currentNavIndex = 2; // Jump to Search Tab
                      });
                    },
                    borderRadius: AppRadius.roundedFull,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.md,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: AppColors.textSecondary, size: 20),
                          SizedBox(width: AppSpacing.sm),
                          Text(
                            'Search food, groceries, medicines in Batkhela...',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Promotional Hero Banner Carousel (4 Batkhela Campaigns)
                SizedBox(
                  height: 175,
                  child: PageView.builder(
                    itemCount: CustomerDemoData.promoBanners.length,
                    itemBuilder: (context, index) {
                      final banner = CustomerDemoData.promoBanners[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: MarketplaceHeroBanner(
                          title: banner.title,
                          subtitle: banner.subtitle,
                          tag: banner.tag,
                          ctaLabel: banner.ctaLabel,
                          gradient: LinearGradient(
                            colors: [
                              banner.primaryColor,
                              banner.primaryColor.withAlpha(210),
                              AppColors.indigo,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          onCtaTap: () {
                            setState(() {
                              _currentNavIndex = 1; // Explore tab
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Category Chips
                SizedBox(
                  height: 42,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: CustomerDemoData.categories.length,
                    itemBuilder: (context, index) {
                      final cat = CustomerDemoData.categories[index];
                      final isSelected = cat.id == _selectedCategory;
                      return MarketplaceCategoryChip(
                        label: cat.name,
                        icon: cat.icon,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            _selectedCategory = cat.id;
                          });
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Popular Stores Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Popular Stores in Batkhela',
                      style: AppTypography.headline(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _currentNavIndex = 1; // Jump to Explore
                        });
                      },
                      child: const Text(
                        'See All',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),

                // Stores List
                if (filteredStores.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                    child: Center(
                      child: Text(
                        'No stores found in this category.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  )
                else
                  ...filteredStores.map((store) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: VendorStoreCard(
                        name: store.name,
                        category: store.categoryName,
                        rating: store.rating,
                        reviewCount: store.reviewCount,
                        deliveryTime: store.deliveryTime,
                        deliveryFee: store.deliveryFee,
                        badges: store.badges,
                        isClosed: !store.isOpen,
                        onTap: () => _navigateToStore(context, store),
                      ),
                    );
                  }),

                const SizedBox(height: AppSpacing.md),

                // Featured Products Section Header
                Text(
                  'Recommended For You in Batkhela',
                  style: AppTypography.headline(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Featured Products List (Top 8 items)
                ...CustomerDemoData.allFeaturedProducts.take(8).map((product) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: ProductCatalogCard(
                      name: product.name,
                      description: product.description,
                      price: product.price,
                      discountPrice: product.discountPrice,
                      isAvailable: product.isAvailable,
                      onAdd: () {
                        setState(() {
                          _cartItemCount += 1;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Added ${product.name} to cart'),
                            backgroundColor: AppColors.primary,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // TAB 1: EXPLORE / CATEGORIES VIEW
  // ==========================================
  Widget _buildExploreView() {
    final filteredStores = _selectedCategory == 'all'
        ? CustomerDemoData.stores
        : CustomerDemoData.stores
            .where((s) => s.categoryId == _selectedCategory)
            .toList();

    return Column(
      children: [
        // App Bar Header
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(AppSpacing.md),
          alignment: Alignment.centerLeft,
          child: Text(
            'Explore Batkhela Businesses',
            style: AppTypography.headline(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        // Category Selector
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: SizedBox(
            height: 42,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: CustomerDemoData.categories.length,
              itemBuilder: (context, index) {
                final cat = CustomerDemoData.categories[index];
                final isSelected = cat.id == _selectedCategory;
                return MarketplaceCategoryChip(
                  label: cat.name,
                  icon: cat.icon,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      _selectedCategory = cat.id;
                    });
                  },
                );
              },
            ),
          ),
        ),
        const Divider(height: 1),

        // Business List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: filteredStores.length,
            itemBuilder: (context, index) {
              final store = filteredStores[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: VendorStoreCard(
                  name: store.name,
                  category: store.categoryName,
                  rating: store.rating,
                  reviewCount: store.reviewCount,
                  deliveryTime: store.deliveryTime,
                  deliveryFee: store.deliveryFee,
                  badges: store.badges,
                  isClosed: !store.isOpen,
                  onTap: () => _navigateToStore(context, store),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ==========================================
  // TAB 2: SEARCH VIEW
  // ==========================================
  Widget _buildSearchView() {
    final query = _searchQuery.trim().toLowerCase();
    final matchingStores = query.isEmpty
        ? <DemoStore>[]
        : CustomerDemoData.stores
            .where((s) =>
                s.name.toLowerCase().contains(query) ||
                s.categoryName.toLowerCase().contains(query) ||
                s.description.toLowerCase().contains(query))
            .toList();

    final matchingProducts = query.isEmpty
        ? <Product>[]
        : CustomerDemoData.allFeaturedProducts
            .where((p) =>
                p.name.toLowerCase().contains(query) ||
                (p.description?.toLowerCase().contains(query) ?? false))
            .toList();

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: TextField(
            autofocus: false,
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search stores, medicines, grocery...',
              prefixIcon: const Icon(Icons.search, color: AppColors.primary),
              suffixIcon: query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.backgroundLight,
              contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
              border: const OutlineInputBorder(
                borderRadius: AppRadius.roundedFull,
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: query.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_rounded, size: 64, color: AppColors.textTertiary.withAlpha(120)),
                      const SizedBox(height: AppSpacing.sm),
                      const Text(
                        'Search anything in Batkhela',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Karahi, Naan, Panadol, Fresh Milk, Apples & more',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    if (matchingStores.isNotEmpty) ...[
                      Text(
                        'Stores (${matchingStores.length})',
                        style: AppTypography.headline(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ...matchingStores.map((store) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: VendorStoreCard(
                            name: store.name,
                            category: store.categoryName,
                            rating: store.rating,
                            reviewCount: store.reviewCount,
                            deliveryTime: store.deliveryTime,
                            deliveryFee: store.deliveryFee,
                            onTap: () => _navigateToStore(context, store),
                          ),
                        );
                      }),
                    ],
                    if (matchingProducts.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Products (${matchingProducts.length})',
                        style: AppTypography.headline(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ...matchingProducts.map((p) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: ProductCatalogCard(
                            name: p.name,
                            description: p.description,
                            price: p.price,
                            discountPrice: p.discountPrice,
                            isAvailable: p.isAvailable,
                            onAdd: () {
                              setState(() {
                                _cartItemCount += 1;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Added ${p.name} to cart'),
                                  backgroundColor: AppColors.primary,
                                ),
                              );
                            },
                          ),
                        );
                      }),
                    ],
                    if (matchingStores.isEmpty && matchingProducts.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            'No results found for "$_searchQuery"',
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  // ==========================================
  // TAB 3: ORDERS VIEW
  // ==========================================
  Widget _buildOrdersView() {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(AppSpacing.md),
          alignment: Alignment.centerLeft,
          child: Text(
            'Your Orders',
            style: AppTypography.headline(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: CustomerDemoData.demoOrders.length,
            itemBuilder: (context, index) {
              final order = CustomerDemoData.demoOrders[index];

              return Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadius.roundedLg,
                  boxShadow: AppElevation.softSubtle,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order #${order.orderNumber ?? order.id}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        MarketplaceStatusBadge.fromOrderStatus(order.status),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Delivering to: ${order.deliveryAddress}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const Divider(height: 20),
                    ...order.items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${item.quantity}x ${item.productName}',
                              style: const TextStyle(fontSize: 13),
                            ),
                            Text(
                              'PKR ${item.totalPrice.toStringAsFixed(0)}',
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ],
                        ),
                      );
                    }),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Amount:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          'PKR ${order.totalAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    if (order.status == OrderStatus.outForDelivery ||
                        order.status == OrderStatus.preparing ||
                        order.status == OrderStatus.accepted) ...[
                      const SizedBox(height: AppSpacing.sm),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedMd),
                          ),
                          onPressed: () => _showLiveTrackingSheet(context, order),
                          icon: const Icon(Icons.location_on_outlined, size: 16),
                          label: const Text('Track Live Rider & Route', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ==========================================
  // TAB 4: PROFILE VIEW
  // ==========================================
  Widget _buildProfileView() {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(AppSpacing.md),
          alignment: Alignment.centerLeft,
          child: Text(
            'Customer Account',
            style: AppTypography.headline(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              // Profile Header Card
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadius.roundedLg,
                  boxShadow: AppElevation.softSubtle,
                ),
                child: const Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.primaryLight,
                      child: Icon(Icons.person, size: 32, color: AppColors.primary),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Batkhela Customer',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 2),
                          Text(
                            '+92 345 0000000',
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Menu Options
              Container(
                decoration: const BoxDecoration(
                  borderRadius: AppRadius.roundedLg,
                  boxShadow: AppElevation.softSubtle,
                ),
                child: Material(
                  color: Colors.white,
                  borderRadius: AppRadius.roundedLg,
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.location_on_outlined, color: AppColors.primary),
                        title: const Text('Saved Addresses'),
                        subtitle: Text(_currentAddress, style: const TextStyle(fontSize: 12)),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                        onTap: () => _showLocationPicker(context),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.language_outlined, color: AppColors.indigo),
                        title: const Text('Language / زبان'),
                        subtitle: const Text('English (Urdu supported)'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Language preference saved.')),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.headset_mic_outlined, color: AppColors.coral),
                        title: const Text('Batkhela Support & Helpline'),
                        subtitle: const Text('Local dispatch assistance: 0345-BATKHELA'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _navigateToStore(BuildContext context, DemoStore store) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => StoreDetailScreen(store: store),
      ),
    );
  }

  void _showLocationPicker(BuildContext context) {
    final locations = [
      'Main Bazaar, Near Clock Tower, Batkhela',
      'College Road, Batkhela',
      'Civil Hospital Road, Batkhela',
      'Thana Bazaar, Malakand',
      'Zafar Park Road, Batkhela',
    ];

    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Delivery Location',
                  style: AppTypography.headline(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.sm),
                ...locations.map((loc) {
                  final isCurrent = loc == _currentAddress;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.location_on,
                      color: isCurrent ? AppColors.primary : AppColors.textTertiary,
                    ),
                    title: Text(
                      loc,
                      style: TextStyle(
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                        color: isCurrent ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                    trailing: isCurrent ? const Icon(Icons.check, color: AppColors.primary) : null,
                    onTap: () {
                      setState(() {
                        _currentAddress = loc;
                      });
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCartOverview(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Your Cart',
                  style: AppTypography.headline(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.md),
                const ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryLight,
                    child: Text('1x', style: TextStyle(color: AppColors.primaryDark)),
                  ),
                  title: Text('Shinwari Mutton Karahi (Full KG)'),
                  trailing: Text('PKR 2,150', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const Divider(),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Estimated:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      'PKR 2,150',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Order dispatched to Batkhela riders!'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedFull),
                    ),
                    child: const Text('Confirm Order'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLiveTrackingSheet(BuildContext context, MarketplaceOrder order) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Header Drag Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Live Order Tracking',
                          style: AppTypography.headline(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Order #${order.orderNumber ?? order.id} • ${order.status.displayName}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    RouteNavigationPreview(
                      originTitle: 'Merchant Store',
                      originAddress: 'Batkhela Central Bazaar',
                      destinationTitle: 'Delivery Destination',
                      destinationAddress: order.deliveryAddress,
                      distanceKm: 2.3,
                      estimatedMinutes: 8,
                      isGpsActive: true,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(15),
                        borderRadius: AppRadius.roundedLg,
                        border: Border.all(color: AppColors.primary.withAlpha(40)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.two_wheeler, color: AppColors.primary, size: 24),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Rider Dispatched (Kamran Khan)',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                                ),
                                Text(
                                  'Honda CG 125 • Heading towards drop-off location',
                                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.success.withAlpha(30),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'LIVE GPS',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.success),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
