import 'dart:async';
import 'package:flutter/material.dart';
import 'package:marketplace_core/marketplace_core.dart';
import '../../data/customer_demo_data.dart';
import '../../data/rider_demo_data.dart';
import '../../services/live_sync_controller.dart';
import '../../widgets/route_navigation_preview.dart';
import '../../widgets/notification_inbox_sheet.dart';
import 'store_detail_screen.dart';
import 'product_detail_sheet.dart';
import 'cart_sheet.dart';

/// Customer Marketplace Main Screen featuring Arby's-inspired Warm Modern UI,
/// Auto-Scrolling Hero Carousel, Animated Category Cards, Popular Picks Carousel,
/// Professional Vendor Cards, and Real-Time Rider/Vendor Self-Delivery GPS Tracking.
class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  static const Color _kBrandRed = Color(0xFFC8102E);
  static const Color _kBrandDarkRed = Color(0xFF8B0018);
  static const Color _kWarmCreamBg = Color(0xFFFAF6F0);

  int _currentNavIndex = 0;
  String _selectedCategory = 'all';
  String _currentAddress = CustomerDemoData.activeDeliveryAddress;
  String _searchQuery = '';

  late final PageController _bannerPageController;
  int _currentBannerPage = 0;
  Timer? _bannerAutoScrollTimer;

  @override
  void initState() {
    super.initState();
    _bannerPageController = PageController(viewportFraction: 0.94);
    LiveSyncController.instance.startLiveSync();
    final currentUserId = AuthService.instance.currentProfile?.id ?? 'usr_customer_1';
    MarketplaceDataService.instance.notificationController.initSession(
      userId: currentUserId,
      role: 'customer',
    );
    _startBannerAutoScroll();
  }

  void _startBannerAutoScroll() {
    // Skip periodic timer in widget tests so pumpAndSettle completes immediately
    if (HostingerApiClient.instance.isTestEnvironment) return;
    _bannerAutoScrollTimer?.cancel();
    _bannerAutoScrollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_bannerPageController.hasClients) return;
      final total = CustomerDemoData.promoBanners.length;
      if (total <= 1) return;
      final next = (_currentBannerPage + 1) % total;
      _bannerPageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _bannerAutoScrollTimer?.cancel();
    _bannerPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kWarmCreamBg,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: LiveSyncController.instance,
          builder: (context, _) => _buildCurrentTab(),
        ),
      ),
      bottomNavigationBar: ValueListenableBuilder<List<CartItem>>(
        valueListenable: CartController.instance.itemsNotifier,
        builder: (context, items, _) {
          return _buildModernBottomBar(items);
        },
      ),
    );
  }

  Widget _buildModernBottomBar(List<CartItem> cartItems) {
    final cartCount = CartController.instance.totalItemCount;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(18),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(
                index: 0,
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Home',
              ),
              _buildBottomNavItem(
                index: 1,
                icon: Icons.grid_view_outlined,
                activeIcon: Icons.grid_view_rounded,
                label: 'Explore',
              ),
              // Center Elevated Circular Cart Button + Search access
              GestureDetector(
                onTap: () => CartSheet.show(context),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [_kBrandRed, _kBrandDarkRed],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _kBrandRed.withAlpha(90),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 22),
                              Text(
                                'Cart',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (cartCount > 0)
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: _kBrandRed, width: 1.5),
                              ),
                              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                              alignment: Alignment.center,
                              child: Text(
                                '$cartCount',
                                style: const TextStyle(
                                  color: _kBrandRed,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
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
              _buildBottomNavItem(
                index: 2,
                icon: Icons.search_outlined,
                activeIcon: Icons.search_rounded,
                label: 'Search',
              ),
              _buildBottomNavItem(
                index: 3,
                icon: Icons.receipt_long_outlined,
                activeIcon: Icons.receipt_long_rounded,
                label: 'Orders',
              ),
              _buildBottomNavItem(
                index: 4,
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = _currentNavIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _currentNavIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 12 : 8,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isSelected ? _kBrandRed : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? Colors.white : const Color(0xFF475569),
              size: 21,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF475569),
              ),
            ),
          ],
        ),
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
  // TAB 0: ARBY'S-STYLE CRAFTED HOME VIEW
  // ==========================================
  Widget _buildHomeView() {
    final filteredStores = CustomerDemoData.storesForCategory(_selectedCategory);
    final popularProducts = CustomerDemoData.productsForCategory(_selectedCategory);

    return RefreshIndicator(
      color: _kBrandRed,
      onRefresh: () async {
        await LiveSyncController.instance.syncNow();
      },
      child: ListView(
        padding: const EdgeInsets.only(bottom: 28),
        children: [
          // 1. Top Brand Header (Brand Crest on Left + Circular Bell & Profile on Right)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Brand Logo & Tagline
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_kBrandRed, _kBrandDarkRed],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: _kBrandRed.withAlpha(60),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 10),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Batkhela',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: _kBrandRed,
                            letterSpacing: -0.6,
                            height: 1.05,
                          ),
                        ),
                        Text(
                          'Batkhela Local Express',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF334155),
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Circular Notification & Profile Buttons
                Row(
                  children: [
                    StreamBuilder<int>(
                      stream: MarketplaceDataService.instance.notificationController.unreadCountStream,
                      initialData: MarketplaceDataService.instance.notificationController.currentUnreadCount,
                      builder: (context, snapshot) {
                        final unreadCount = snapshot.data ?? 0;
                        final userId = AuthService.instance.currentProfile?.id ?? 'usr_customer_1';
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            _buildCircularHeaderIconButton(
                              icon: Icons.notifications_none_rounded,
                              onTap: () => NotificationInboxSheet.show(
                                context,
                                userId: userId,
                                role: 'customer',
                              ),
                            ),
                            if (unreadCount > 0)
                              Positioned(
                                right: 2,
                                top: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: _kBrandRed,
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
                    const SizedBox(width: 10),
                    _buildCircularHeaderIconButton(
                      icon: Icons.person_outline_rounded,
                      onTap: () {
                        setState(() {
                          _currentNavIndex = 4;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. "Deliver to" Location Pill + Search Icon Card (Exact Reference Style)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(12),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: _kBrandRed.withAlpha(22),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.location_on_rounded, color: _kBrandRed, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: () => _showLocationPicker(context),
                      borderRadius: BorderRadius.circular(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'DELIVERING TO',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: _kBrandRed,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  _currentAddress,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1E293B),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 18,
                                color: Color(0xFF1E293B),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _currentNavIndex = 2; // Jump to Search Tab
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _kWarmCreamBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.search_rounded, color: Color(0xFF1E293B), size: 22),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // 3. Auto-Scrolling Animated Hero Promo Banner Carousel
          SizedBox(
            height: 196,
            child: PageView.builder(
              controller: _bannerPageController,
              itemCount: CustomerDemoData.promoBanners.length,
              onPageChanged: (idx) {
                setState(() {
                  _currentBannerPage = idx;
                });
              },
              itemBuilder: (context, index) {
                final banner = CustomerDemoData.promoBanners[index];
                final isCurrent = index == _currentBannerPage;
                return AnimatedScale(
                  scale: isCurrent ? 1.0 : 0.95,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [banner.primaryColor, banner.accentColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: banner.primaryColor.withAlpha(75),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        // Subtle decorative glow circle on right
                        Positioned(
                          right: -30,
                          top: -20,
                          child: Container(
                            width: 190,
                            height: 190,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(22),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        // Right Product Image
                        Positioned(
                          right: -8,
                          bottom: -6,
                          top: 10,
                          width: 168,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              banner.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Icon(
                                banner.icon,
                                size: 90,
                                color: Colors.white.withAlpha(80),
                              ),
                            ),
                          ),
                        ),
                        // Left Headline, Subtitle & White Pill CTA Button
                        Padding(
                          padding: const EdgeInsets.fromLTRB(18, 16, 150, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                banner.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w900,
                                  height: 1.06,
                                  letterSpacing: -0.4,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                banner.subtitle,
                                style: TextStyle(
                                  color: Colors.white.withAlpha(235),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Spacer(),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedCategory = banner.targetCategoryId;
                                  });
                                },
                                borderRadius: BorderRadius.circular(30),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(35),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        banner.ctaLabel,
                                        style: TextStyle(
                                          color: banner.primaryColor,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 14,
                                        color: banner.primaryColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Pagination Dots at Bottom Center
                        Positioned(
                          bottom: 10,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              CustomerDemoData.promoBanners.length,
                              (dotIdx) {
                                final active = dotIdx == _currentBannerPage;
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                  width: active ? 16 : 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: active ? Colors.white : Colors.white.withAlpha(110),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // 4. Animated Horizontal Category Icon Tiles (Featured, Grocery, Medicine, Fast Food, Cold Drinks, etc.)
          SizedBox(
            height: 94,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: CustomerDemoData.categories.length,
              itemBuilder: (context, index) {
                final cat = CustomerDemoData.categories[index];
                final isSelected = cat.id == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = cat.id;
                      });
                    },
                    child: AnimatedScale(
                      scale: isSelected ? 1.05 : 1.0,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutBack,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: 78,
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected ? _kBrandRed : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? _kBrandRed.withAlpha(38)
                                  : Colors.black.withAlpha(10),
                              blurRadius: isSelected ? 12 : 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? _kBrandRed.withAlpha(22)
                                    : cat.accentColor.withAlpha(20),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                cat.emoji,
                                style: const TextStyle(fontSize: 22),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              cat.name,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                                color: isSelected ? _kBrandRed : const Color(0xFF334155),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 18),

          // 5. "Popular Picks" Horizontal Product Carousel (Exact Arby's Card Style with Red '+' Circle)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Popular Picks',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.4,
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      _currentNavIndex = 2; // Open Search / All Products
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Row(
                      children: [
                        Text(
                          'View All',
                          style: TextStyle(
                            color: _kBrandRed,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, size: 15, color: _kBrandRed),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 228,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: popularProducts.take(10).length,
              itemBuilder: (context, index) {
                final product = popularProducts[index];
                final store = CustomerDemoData.stores.firstWhere(
                  (s) => s.id == product.vendorId,
                  orElse: () => CustomerDemoData.stores.first,
                );
                final effectivePrice = product.discountPrice ?? product.price;

                return Container(
                  width: 158,
                  margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => ProductDetailSheet.show(
                      context,
                      product: product,
                      vendorId: store.id,
                      vendorName: store.name,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: SizedBox(
                              height: 104,
                              width: double.infinity,
                              child: Image.network(
                                product.imageUrl ?? '',
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  color: _kWarmCreamBg,
                                  child: const Icon(Icons.fastfood_rounded, color: _kBrandRed, size: 36),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            store.name,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Rs. ${effectivePrice.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: _kBrandRed,
                                ),
                              ),
                              InkWell(
                                onTap: () => _handleQuickAddProduct(product, store),
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: const BoxDecoration(
                                    color: _kBrandRed,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // 6. Batkhela Rewards & Perks Banner Card (Exact Reference Style)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _kBrandRed.withAlpha(35)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _kBrandRed.withAlpha(18),
                      shape: BoxShape.circle,
                      border: Border.all(color: _kBrandRed, width: 2),
                    ),
                    child: const Icon(Icons.workspace_premium_rounded, color: _kBrandRed, size: 26),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BATKHELA REWARDS',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: _kBrandRed,
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Earn points with every order and get free delivery perks.',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF475569),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kBrandRed,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: _kBrandRed,
                          content: Text('Batkhela Rewards Activated! Free delivery unlocked on eligible stores.'),
                        ),
                      );
                    },
                    child: const Text(
                      'Join Now',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 7. Popular Stores / Vendors in Batkhela Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Popular Stores in Batkhela',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.3,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _currentNavIndex = 1; // Jump to Explore
                    });
                  },
                  child: const Text(
                    'See All →',
                    style: TextStyle(
                      color: _kBrandRed,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Professional Vendor Cards List
          if (filteredStores.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
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
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: VendorStoreCard(
                  name: store.name,
                  category: store.categoryName,
                  address: store.address,
                  imageUrl: store.imageUrl,
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

          const SizedBox(height: 8),

          // 8. Recommended Products Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Recommended For You in Batkhela',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E293B),
                letterSpacing: -0.3,
              ),
            ),
          ),
          const SizedBox(height: 10),

          ...popularProducts.take(14).map((product) {
            final store = CustomerDemoData.stores.firstWhere(
              (s) => s.id == product.vendorId,
              orElse: () => CustomerDemoData.stores.first,
            );

            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: ProductCatalogCard(
                name: product.name,
                description: product.description,
                category: product.category,
                imageUrl: product.imageUrl,
                price: product.price,
                discountPrice: product.discountPrice,
                isAvailable: product.isAvailable,
                onTap: () => ProductDetailSheet.show(
                  context,
                  product: product,
                  vendorId: store.id,
                  vendorName: store.name,
                ),
                onAdd: () => _handleQuickAddProduct(product, store),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _handleQuickAddProduct(Product product, DemoStore store) {
    final added = CartController.instance.addItem(
      product,
      vendorId: store.id,
      vendorName: store.name,
    );
    if (!added) {
      ProductDetailSheet.show(
        context,
        product: product,
        vendorId: store.id,
        vendorName: store.name,
      );
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${product.name} to cart'),
          backgroundColor: _kBrandRed,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildCircularHeaderIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: Colors.black.withAlpha(30),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: const Color(0xFF1E293B), size: 22),
        ),
      ),
    );
  }

  // ==========================================
  // TAB 1: EXPLORE / CATEGORIES VIEW
  // ==========================================
  Widget _buildExploreView() {
    final filteredStores = CustomerDemoData.storesForCategory(_selectedCategory);

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(AppSpacing.md),
          alignment: Alignment.centerLeft,
          child: Text(
            'Explore Batkhela Businesses',
            style: AppTypography.headline(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: CustomerDemoData.categories.length,
              itemBuilder: (context, index) {
                final cat = CustomerDemoData.categories[index];
                final isSelected = cat.id == _selectedCategory;
                return MarketplaceCategoryChip(
                  label: '${cat.emoji} ${cat.name}',
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
                  address: store.address,
                  imageUrl: store.imageUrl,
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
              hintText: 'Search stores, medicines, grocery, burgers...',
              prefixIcon: const Icon(Icons.search, color: _kBrandRed),
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
              fillColor: _kWarmCreamBg,
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
                        'Karahi, Zinger Burger, Panadol, Cold Drinks, Grocery & more',
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
                            address: store.address,
                            imageUrl: store.imageUrl,
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
                    ],
                    if (matchingProducts.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Products (${matchingProducts.length})',
                        style: AppTypography.headline(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ...matchingProducts.map((p) {
                        final store = CustomerDemoData.stores.firstWhere(
                          (s) => s.id == p.vendorId,
                          orElse: () => CustomerDemoData.stores.first,
                        );
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: ProductCatalogCard(
                            name: p.name,
                            description: p.description,
                            category: p.category,
                            imageUrl: p.imageUrl,
                            price: p.price,
                            discountPrice: p.discountPrice,
                            isAvailable: p.isAvailable,
                            onTap: () => ProductDetailSheet.show(
                              context,
                              product: p,
                              vendorId: store.id,
                              vendorName: store.name,
                            ),
                            onAdd: () => _handleQuickAddProduct(p, store),
                          ),
                        );
                      }),
                    ],
                    if (matchingStores.isEmpty && matchingProducts.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: _kBrandRed.withAlpha(20),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.search_off_rounded, size: 32, color: _kBrandRed),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                'No matches for "$_searchQuery"',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                textAlign: TextAlign.center,
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

  // ==========================================
  // TAB 3: ORDERS VIEW (WITH SELF-DELIVERY & RIDER TRACKING)
  // ==========================================
  Widget _buildOrdersView() {
    final currentUserId = AuthService.instance.currentProfile?.id ?? 'usr_customer_1';

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
          child: StreamBuilder<List<MarketplaceOrder>>(
            stream: MarketplaceDataService.instance.customerRepo.streamCustomerOrders(currentUserId),
            builder: (context, snapshot) {
              final orders = (snapshot.hasData && snapshot.data!.isNotEmpty)
                  ? snapshot.data!
                  : CustomerDemoData.demoOrders;

              if (orders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: AppSpacing.md),
                      const Text(
                        'No Orders Yet',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final isVendorSelf = order.deliveryAssignmentType == 'vendor_self';
                  final courierName = order.assignedRiderName ??
                      (isVendorSelf ? 'Vendor Self-Delivery' : 'Kamran Khan (Batkhela Rider)');

                  return Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
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
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                            ),
                            MarketplaceStatusBadge.fromOrderStatus(order.status),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Delivering to: ${order.deliveryAddress}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        if (order.assignedRiderName != null || order.status == OrderStatus.outForDelivery) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isVendorSelf
                                  ? const Color(0xFFFEF3C7)
                                  : AppColors.primary.withAlpha(15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isVendorSelf ? Icons.storefront_rounded : Icons.two_wheeler_rounded,
                                  size: 16,
                                  color: isVendorSelf ? const Color(0xFFB45309) : AppColors.primary,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    isVendorSelf
                                        ? 'Vendor Self-Delivery: $courierName'
                                        : 'Delivery Partner: $courierName',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                      color: isVendorSelf ? const Color(0xFFB45309) : AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const Divider(height: 20),
                        ...order.items.map((item) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item.quantity}x ${item.productName}',
                                    style: const TextStyle(fontSize: 13),
                                  ),
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
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                color: _kBrandRed,
                              ),
                            ),
                          ],
                        ),
                        if (order.status == OrderStatus.outForDelivery ||
                            order.status == OrderStatus.readyForPickup ||
                            order.status == OrderStatus.preparing ||
                            order.status == OrderStatus.accepted ||
                            order.status == OrderStatus.placed) ...[
                          const SizedBox(height: AppSpacing.sm),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _kBrandRed,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
    final profile = AuthService.instance.currentProfile;
    final displayName = profile?.fullName ?? 'Batkhela Customer';
    final displayPhone = profile?.phone.isNotEmpty == true ? profile!.phone : '+92 345 0000000';

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
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppElevation.softSubtle,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: _kBrandRed.withAlpha(20),
                      child: const Icon(Icons.person, size: 32, color: _kBrandRed),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            displayPhone,
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppElevation.softSubtle,
                ),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.location_on_outlined, color: _kBrandRed),
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
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.red),
                        title: const Text('Sign Out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                        onTap: () async {
                          await AuthService.instance.signOut();
                          if (!mounted) return;
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
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
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kBrandRed,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final gps = await HostingerApiClient.instance.getCurrentDeviceGps();
                      if (gps != null && mounted) {
                        final addr = await HostingerApiClient.instance.reverseGeocode(
                          gps.latitude,
                          gps.longitude,
                        );
                        if (!mounted) return;
                        setState(() {
                          _currentAddress = addr;
                          CustomerDemoData.activeDeliveryAddress = addr;
                        });
                      }
                    },
                    icon: const Icon(Icons.my_location, size: 18),
                    label: const Text('Detect My Real Exact GPS Location'),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ...locations.map((loc) {
                  final isCurrent = loc == _currentAddress;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.location_on,
                      color: isCurrent ? _kBrandRed : AppColors.textTertiary,
                    ),
                    title: Text(
                      loc,
                      style: TextStyle(
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                        color: isCurrent ? _kBrandRed : AppColors.textPrimary,
                      ),
                    ),
                    trailing: isCurrent ? const Icon(Icons.check, color: _kBrandRed) : null,
                    onTap: () {
                      setState(() {
                        _currentAddress = loc;
                        CustomerDemoData.activeDeliveryAddress = loc;
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

  void _showLiveTrackingSheet(BuildContext context, MarketplaceOrder order) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return AnimatedBuilder(
          animation: LiveSyncController.instance,
          builder: (context, _) {
            final liveOrder = CustomerDemoData.demoOrders.firstWhere(
              (o) => o.id == order.id,
              orElse: () => order,
            );
            final storeObj = CustomerDemoData.stores.firstWhere(
              (s) => s.id == liveOrder.vendorId,
              orElse: () => CustomerDemoData.stores.first,
            );
            final rLat = liveOrder.riderLat ?? RiderDemoController.instance.liveRiderLat;
            final rLng = liveOrder.riderLng ?? RiderDemoController.instance.liveRiderLng;
            final isOut = liveOrder.status == OrderStatus.outForDelivery;
            final isVendorSelf = liveOrder.deliveryAssignmentType == 'vendor_self';
            final courierName = liveOrder.assignedRiderName ??
                (isVendorSelf
                    ? '${storeObj.name} (Vendor Self-Delivery)'
                    : 'Kamran Khan (Batkhela Rider)');

            return Container(
              height: MediaQuery.of(context).size.height * 0.80,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
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
                              'Live Order & Delivery GPS Tracking',
                              style: AppTypography.headline(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Order #${liveOrder.orderNumber ?? liveOrder.id} • ${liveOrder.status.displayName}',
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
                          originTitle: storeObj.name,
                          originAddress: storeObj.address,
                          destinationTitle: 'Your Exact Delivery Pin',
                          destinationAddress: liveOrder.deliveryAddress,
                          distanceKm: 2.3,
                          estimatedMinutes: 8,
                          originLat: 34.6175,
                          originLng: 71.9712,
                          destinationLat: liveOrder.deliveryLat ?? 34.6212,
                          destinationLng: liveOrder.deliveryLng ?? 71.9765,
                          riderLat: rLat,
                          riderLng: rLng,
                          isGpsActive: true,
                          isOutForDelivery: isOut,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: _kBrandRed.withAlpha(15),
                            borderRadius: AppRadius.roundedLg,
                            border: Border.all(color: _kBrandRed.withAlpha(45)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isVendorSelf ? Icons.storefront_rounded : Icons.two_wheeler,
                                color: _kBrandRed,
                                size: 26,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isOut
                                          ? 'Out for Delivery • $courierName'
                                          : 'Assigned Partner • $courierName',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      'Exact Live GPS: ${rLat.toStringAsFixed(5)}° N, ${rLng.toStringAsFixed(5)}° E',
                                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
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
      },
    );
  }
}
