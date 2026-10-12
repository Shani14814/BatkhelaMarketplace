import 'package:flutter/material.dart';
import 'package:marketplace_core/marketplace_core.dart';
import '../../data/customer_demo_data.dart';
import '../../services/live_sync_controller.dart';
import 'product_detail_sheet.dart';
import 'cart_sheet.dart';

/// Soft, modern Store Details & Catalog screen for Customers browsing any Vendor shop.
class StoreDetailScreen extends StatefulWidget {
  final DemoStore store;

  const StoreDetailScreen({
    super.key,
    required this.store,
  });

  @override
  State<StoreDetailScreen> createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends State<StoreDetailScreen> {
  static const Color _bgCream = Color(0xFFFAF6F0);
  static const Color _brandRed = Color(0xFFC8102E);
  static const Color _brandRedDark = Color(0xFF9E0B22);
  static const Color _textDark = Color(0xFF1E1915);
  static const Color _textMuted = Color(0xFF6E655F);
  static const Color _softBorder = Color(0xFFEDE6DC);

  String _selectedSubCategory = 'All';
  String _selectedSortOrFilter = 'all'; // 'all', 'deals', 'price_asc', 'price_desc'
  String _searchQuery = '';
  bool _isGridView = true; // Default to 2-column soft grid instead of single-line list
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  DemoStore get _liveStore {
    final idx = CustomerDemoData.stores.indexWhere((s) => s.id == widget.store.id);
    if (idx != -1) {
      return CustomerDemoData.stores[idx];
    }
    return widget.store;
  }

  String _resolveProductCategory(Product p) {
    final raw = p.category?.trim() ?? '';
    if (raw.isNotEmpty && raw.toLowerCase() != 'general') {
      return raw;
    }
    final text = '${p.name.toLowerCase()} ${(p.description ?? '').toLowerCase()}';
    if (text.contains('power bank') || text.contains('solar') || text.contains('battery')) {
      return 'Power Banks';
    }
    if (text.contains('earbud') || text.contains('airpod') || text.contains('headphone') || text.contains('anc')) {
      return 'Audio & Earbuds';
    }
    if (text.contains('charger') || text.contains('adapter') || text.contains('cable') || text.contains('type-c')) {
      return 'Chargers';
    }
    if (text.contains('watch') || text.contains('amoled')) {
      return 'Smartwatches';
    }
    if (text.contains('karahi') || text.contains('handi')) {
      return 'Karahi';
    }
    if (text.contains('tikka') || text.contains('kabab') || text.contains('bbq') || text.contains('platter')) {
      return 'BBQ & Grill';
    }
    if (text.contains('pulao') || text.contains('biryani') || text.contains('rice')) {
      return 'Rice & Pulao';
    }
    if (text.contains('burger') || text.contains('zinger') || text.contains('shawarma') || text.contains('wrap') || text.contains('pizza') || text.contains('fries')) {
      return 'Fast Food';
    }
    if (text.contains('drink') || text.contains('pepsi') || text.contains('sting') || text.contains('shake') || text.contains('tea') || text.contains('kahwa')) {
      return 'Drinks & Shakes';
    }
    if (text.contains('naan') || text.contains('roti') || text.contains('raita')) {
      return 'Sides & Naan';
    }
    return 'Specials';
  }

  String _emojiForSubCategory(String cat) {
    final lower = cat.toLowerCase();
    if (lower == 'all') return '✨';
    if (lower.contains('power') || lower.contains('battery') || lower.contains('solar')) return '🔋';
    if (lower.contains('audio') || lower.contains('earbud') || lower.contains('sound')) return '🎧';
    if (lower.contains('charger') || lower.contains('cable') || lower.contains('adapter')) return '🔌';
    if (lower.contains('watch')) return '⌚';
    if (lower.contains('karahi') || lower.contains('handi')) return '🍲';
    if (lower.contains('bbq') || lower.contains('tikka') || lower.contains('kabab') || lower.contains('grill')) return '🍖';
    if (lower.contains('burger') || lower.contains('fast') || lower.contains('zinger')) return '🍔';
    if (lower.contains('pizza')) return '🍕';
    if (lower.contains('wrap') || lower.contains('shawarma') || lower.contains('roll')) return '🌯';
    if (lower.contains('drink') || lower.contains('shake') || lower.contains('beverage') || lower.contains('cold')) return '🥤';
    if (lower.contains('tea') || lower.contains('kahwa') || lower.contains('chai')) return '🍵';
    if (lower.contains('rice') || lower.contains('pulao') || lower.contains('biryani') || lower.contains('staple')) return '🍚';
    if (lower.contains('naan') || lower.contains('bread') || lower.contains('side') || lower.contains('tandoor')) return '🫓';
    if (lower.contains('sweet') || lower.contains('mithai') || lower.contains('cake') || lower.contains('bakery')) return '🍰';
    if (lower.contains('med') || lower.contains('tablet') || lower.contains('pain') || lower.contains('first aid') || lower.contains('care') || lower.contains('device') || lower.contains('vitamin')) return '💊';
    if (lower.contains('fruit') || lower.contains('apple') || lower.contains('mango')) return '🍎';
    if (lower.contains('veg') || lower.contains('sabzi')) return '🥬';
    if (lower.contains('honey') || lower.contains('dry fruit') || lower.contains('nut')) return '🍯';
    if (lower.contains('dairy') || lower.contains('milk') || lower.contains('breakfast')) return '🥛';
    if (lower.contains('oil') || lower.contains('ghee') || lower.contains('cooking')) return '🫙';
    if (lower.contains('fabric') || lower.contains('suit') || lower.contains('fashion') || lower.contains('wear') || lower.contains('shawl')) return '👔';
    if (lower.contains('footwear') || lower.contains('chappal')) return '👞';
    if (lower.contains('tool') || lower.contains('hardware') || lower.contains('cement') || lower.contains('paint') || lower.contains('electric')) return '🛠️';
    return '🏷️';
  }

  List<String> _subCategoriesFor(DemoStore store) {
    final cats = <String>{};
    for (final p in store.products) {
      cats.add(_resolveProductCategory(p));
    }
    return ['All', ...cats];
  }

  int _countForSubCategory(DemoStore store, String subCat) {
    if (subCat == 'All') return store.products.length;
    return store.products.where((p) => _resolveProductCategory(p) == subCat).length;
  }

  List<Product> _filteredProductsFor(DemoStore store) {
    Iterable<Product> list = store.products;

    // 1. Subcategory filter
    if (_selectedSubCategory != 'All') {
      list = list.where((p) => _resolveProductCategory(p) == _selectedSubCategory);
    }

    // 2. Search query filter
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      list = list.where((p) {
        final nameMatch = p.name.toLowerCase().contains(q);
        final descMatch = (p.description ?? '').toLowerCase().contains(q);
        final catMatch = _resolveProductCategory(p).toLowerCase().contains(q);
        return nameMatch || descMatch || catMatch;
      });
    }

    // 3. Quick filter / sort
    var result = list.toList();
    if (_selectedSortOrFilter == 'deals') {
      result = result
          .where((p) => p.discountPrice != null && p.discountPrice! > 0 && p.discountPrice! < p.price)
          .toList();
    } else if (_selectedSortOrFilter == 'price_asc') {
      result.sort((a, b) => a.effectivePrice.compareTo(b.effectivePrice));
    } else if (_selectedSortOrFilter == 'price_desc') {
      result.sort((a, b) => b.effectivePrice.compareTo(a.effectivePrice));
    }

    return result;
  }

  List<Product> _featuredDealsFor(DemoStore store) {
    final deals = store.products
        .where((p) => p.discountPrice != null && p.discountPrice! > 0 && p.discountPrice! < p.price)
        .toList();
    if (deals.isNotEmpty) return deals;
    return store.products.take(3).toList();
  }

  void _addToCart(DemoStore store, Product product) {
    final added = CartController.instance.addItem(
      product,
      quantity: 1,
      vendorId: store.id,
      vendorName: store.name,
    );

    if (!added) {
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Start New Cart?'),
          content: Text(
            'Your cart currently contains items from ${CartController.instance.currentVendorName}. Would you like to clear the cart and add items from ${store.name}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                CartController.instance.addItem(
                  product,
                  quantity: 1,
                  vendorId: store.id,
                  vendorName: store.name,
                  clearIfDifferentVendor: true,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added ${product.name} to cart'),
                    backgroundColor: _brandRed,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _brandRed,
                foregroundColor: Colors.white,
              ),
              child: const Text('Start New Cart'),
            ),
          ],
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${product.name} to cart'),
        duration: const Duration(seconds: 2),
        backgroundColor: _brandRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        LiveSyncController.instance,
        CartController.instance.itemsNotifier,
      ]),
      builder: (context, _) {
        final store = _liveStore;
        final subCategories = _subCategoriesFor(store);
        if (!subCategories.contains(_selectedSubCategory)) {
          _selectedSubCategory = 'All';
        }
        final filteredProducts = _filteredProductsFor(store);
        final featuredDeals = _featuredDealsFor(store);

        return Scaffold(
          backgroundColor: _bgCream,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. Soft Immersive Store Banner Header
              _buildSliverHeader(store),

              // 2. Soft Elevated Store Profile Card + Search + Category & Sort Filters
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStoreProfileCard(store),
                    const SizedBox(height: 14),
                    _buildInStoreSearchBar(store),
                    const SizedBox(height: 16),
                    _buildCategoryFilterCarousel(store, subCategories),
                    const SizedBox(height: 12),
                    _buildQuickSortAndFilterRow(store),
                  ],
                ),
              ),

              // 3. Featured Store Highlights Horizontal Carousel (when viewing All & no search)
              if (_selectedSubCategory == 'All' &&
                  _searchQuery.trim().isEmpty &&
                  _selectedSortOrFilter == 'all' &&
                  featuredDeals.length > 1)
                SliverToBoxAdapter(
                  child: _buildStoreHighlightsCarousel(store, featuredDeals),
                ),

              // 4. Section Header with Item Count & View Switcher
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          color: _brandRed,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _selectedSubCategory == 'All'
                              ? 'Shop Catalog (${filteredProducts.length})'
                              : '$_selectedSubCategory (${filteredProducts.length})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: _textDark,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      // Soft Grid vs List view toggle pill
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _softBorder),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildViewModeButton(
                              icon: Icons.grid_view_rounded,
                              label: 'Grid',
                              isSelected: _isGridView,
                              onTap: () => setState(() => _isGridView = true),
                            ),
                            _buildViewModeButton(
                              icon: Icons.view_agenda_outlined,
                              label: 'Cards',
                              isSelected: !_isGridView,
                              onTap: () => setState(() => _isGridView = false),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 5. Empty State or Product Catalog (2-Column Soft Grid OR Soft Horizontal Cards)
              if (filteredProducts.isEmpty)
                SliverToBoxAdapter(
                  child: _buildEmptyCatalogState(),
                )
              else if (_isGridView)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.67,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = filteredProducts[index];
                        return _buildSoftGridProductCard(store, product);
                      },
                      childCount: filteredProducts.length,
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = filteredProducts[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _buildSoftWideProductCard(store, product),
                        );
                      },
                      childCount: filteredProducts.length,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 120),
              ),
            ],
          ),

          // Floating Modern Bottom Cart Bar
          bottomNavigationBar: _buildFloatingCartBar(),
        );
      },
    );
  }

  Widget _buildSliverHeader(DemoStore store) {
    return SliverAppBar(
      expandedHeight: 205.0,
      pinned: true,
      backgroundColor: _brandRed,
      foregroundColor: Colors.white,
      leadingWidth: 64,
      leading: Padding(
        padding: const EdgeInsets.only(left: 14, top: 6, bottom: 6),
        child: Material(
          color: Colors.black.withAlpha(115),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 14, top: 6, bottom: 6),
          child: Material(
            color: Colors.black.withAlpha(115),
            borderRadius: BorderRadius.circular(22),
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () => setState(() => _isGridView = !_isGridView),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isGridView ? Icons.grid_view_rounded : Icons.view_agenda_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _isGridView ? '2x2 Grid' : 'Wide View',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (store.imageUrl != null && store.imageUrl!.isNotEmpty)
              Image.network(
                store.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildHeaderFallback(),
              )
            else
              _buildHeaderFallback(),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withAlpha(90),
                    Colors.transparent,
                    Colors.black.withAlpha(190),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // Store Badges on Banner
            Positioned(
              left: 16,
              bottom: 16,
              right: 16,
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _brandRed,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      store.categoryName.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  ...store.badges.take(2).map(
                        (badge) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(235),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.verified_rounded, size: 12, color: _brandRed),
                              const SizedBox(width: 4),
                              Text(
                                badge,
                                style: const TextStyle(
                                  color: _textDark,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreProfileCard(DemoStore store) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _softBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Store Avatar / Logo
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF2F4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _brandRed.withAlpha(45), width: 1.5),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: (store.logoUrl ?? store.imageUrl) != null
                      ? Image.network(
                          (store.logoUrl ?? store.imageUrl)!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              const Icon(Icons.storefront_rounded, color: _brandRed, size: 28),
                        )
                      : const Icon(Icons.storefront_rounded, color: _brandRed, size: 28),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: _textDark,
                        height: 1.2,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      store.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: _textMuted,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Rating Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8EB),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, size: 16, color: Color(0xFFD97706)),
                        const SizedBox(width: 3),
                        Text(
                          store.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: _textDark,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${store.reviewCount}+',
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        color: _textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Location & Hours Strip
          Row(
            children: [
              const Icon(Icons.location_on_rounded, size: 15, color: _brandRed),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  store.address,
                  style: const TextStyle(
                    fontSize: 12,
                    color: _textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Soft Cream Info Metrics Bar
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            decoration: BoxDecoration(
              color: _bgCream,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _softBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricItem(
                  icon: Icons.schedule_rounded,
                  iconColor: const Color(0xFFD97706),
                  title: 'Delivery Time',
                  value: store.deliveryTime,
                ),
                Container(width: 1, height: 28, color: _softBorder),
                _buildMetricItem(
                  icon: Icons.delivery_dining_rounded,
                  iconColor: _brandRed,
                  title: 'Delivery Fee',
                  value: store.deliveryFee,
                ),
                Container(width: 1, height: 28, color: _softBorder),
                _buildMetricItem(
                  icon: Icons.verified_rounded,
                  iconColor: store.isOpen ? const Color(0xFF15803D) : Colors.redAccent,
                  title: 'Shop Status',
                  value: store.isOpen ? 'Open Now' : 'Closed',
                  valueColor: store.isOpen ? const Color(0xFF15803D) : Colors.redAccent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInStoreSearchBar(DemoStore store) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _softBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(6),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (val) => setState(() => _searchQuery = val),
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: _textDark),
          decoration: InputDecoration(
            hintText: 'Search products in ${store.name}...',
            hintStyle: const TextStyle(fontSize: 13, color: _textMuted, fontWeight: FontWeight.w500),
            prefixIcon: const Icon(Icons.search_rounded, color: _brandRed, size: 20),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18, color: _textMuted),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilterCarousel(DemoStore store, List<String> subCategories) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: subCategories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final cat = subCategories[index];
          final isSelected = cat == _selectedSubCategory;
          final count = _countForSubCategory(store, cat);
          final emoji = _emojiForSubCategory(cat);

          return GestureDetector(
            onTap: () => setState(() => _selectedSubCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? _brandRed : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected ? _brandRed : _softBorder,
                  width: 1.2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: _brandRed.withAlpha(65),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withAlpha(5),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 15)),
                  const SizedBox(width: 7),
                  Text(
                    cat,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                      color: isSelected ? Colors.white : _textDark,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white.withAlpha(45) : _bgCream,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? Colors.white : _textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickSortAndFilterRow(DemoStore store) {
    final filters = [
      {'id': 'all', 'label': 'All Items', 'icon': Icons.apps_rounded},
      {'id': 'deals', 'label': 'Discount Deals', 'icon': Icons.local_offer_rounded},
      {'id': 'price_asc', 'label': 'Lowest Price', 'icon': Icons.trending_down_rounded},
      {'id': 'price_desc', 'label': 'Premium First', 'icon': Icons.workspace_premium_rounded},
    ];

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final f = filters[index];
          final id = f['id'] as String;
          final isSelected = _selectedSortOrFilter == id;
          return GestureDetector(
            onTap: () => setState(() => _selectedSortOrFilter = id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? _textDark : Colors.white.withAlpha(220),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? _textDark : _softBorder,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    f['icon'] as IconData,
                    size: 14,
                    color: isSelected ? Colors.white : _brandRed,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    f['label'] as String,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : _textDark,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStoreHighlightsCarousel(DemoStore store, List<Product> highlights) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 18, 16, 10),
          child: Row(
            children: [
              Text('🔥', style: TextStyle(fontSize: 16)),
              SizedBox(width: 6),
              Text(
                'Featured Shop Picks',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: _textDark,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 128,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: highlights.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final product = highlights[index];
              final hasDiscount = product.discountPrice != null &&
                  product.discountPrice! > 0 &&
                  product.discountPrice! < product.price;
              final discountPct = hasDiscount
                  ? (((product.price - product.discountPrice!) / product.price) * 100).round()
                  : 0;

              return GestureDetector(
                onTap: () => ProductDetailSheet.show(
                  context,
                  product: product,
                  vendorId: store.id,
                  vendorName: store.name,
                ),
                child: Container(
                  width: 275,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFFFFF), Color(0xFFFFF7F8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _brandRed.withAlpha(40)),
                    boxShadow: [
                      BoxShadow(
                        color: _brandRed.withAlpha(12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: SizedBox(
                          width: 96,
                          height: double.infinity,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              if (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                                Image.network(
                                  product.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Container(
                                    color: _bgCream,
                                    child: const Icon(Icons.shopping_bag_outlined, color: _brandRed),
                                  ),
                                )
                              else
                                Container(
                                  color: _bgCream,
                                  child: const Icon(Icons.shopping_bag_outlined, color: _brandRed),
                                ),
                              if (hasDiscount)
                                Positioned(
                                  top: 6,
                                  left: 6,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _brandRed,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '-$discountPct%',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: _bgCream,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _resolveProductCategory(product),
                                style: const TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: _brandRed,
                                ),
                              ),
                            ),
                            Text(
                              product.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: _textDark,
                                height: 1.2,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Rs. ${product.effectivePrice.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                        color: _brandRed,
                                      ),
                                    ),
                                    if (hasDiscount)
                                      Text(
                                        'Rs. ${product.price.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: _textMuted,
                                          decoration: TextDecoration.lineThrough,
                                        ),
                                      ),
                                  ],
                                ),
                                InkWell(
                                  onTap: () => _addToCart(store, product),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _brandRed,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      '+ Add',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
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
              );
            },
          ),
        ),
      ],
    );
  }

  int _quantityInCart(String productId) {
    for (final item in CartController.instance.items) {
      if (item.product.id == productId) {
        return item.quantity;
      }
    }
    return 0;
  }

  /// Soft 2-Column Modern Grid Card for Store Catalog
  Widget _buildSoftGridProductCard(DemoStore store, Product product) {
    final hasDiscount = product.discountPrice != null &&
        product.discountPrice! > 0 &&
        product.discountPrice! < product.price;
    final discountPct = hasDiscount
        ? (((product.price - product.discountPrice!) / product.price) * 100).round()
        : 0;
    final subCat = _resolveProductCategory(product);
    final qtyInCart = _quantityInCart(product.id);

    return GestureDetector(
      onTap: () => ProductDetailSheet.show(
        context,
        product: product,
        vendorId: store.id,
        vendorName: store.name,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: qtyInCart > 0 ? _brandRed.withAlpha(90) : _softBorder,
            width: qtyInCart > 0 ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image + Badges
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(21)),
                    child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                        ? Image.network(
                            product.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              color: _bgCream,
                              child: const Icon(Icons.image_outlined, color: _textMuted, size: 32),
                            ),
                          )
                        : Container(
                            color: _bgCream,
                            child: const Icon(Icons.image_outlined, color: _textMuted, size: 32),
                          ),
                  ),
                  // Subtle bottom scrim for category pill readability
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 42,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, Colors.black.withAlpha(120)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  if (hasDiscount)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _brandRed,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: _brandRed.withAlpha(80),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '-$discountPct% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(235),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        subCat,
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: _textDark,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Product Details & Action Row
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: _textDark,
                            height: 1.2,
                          ),
                        ),
                        if (product.description != null && product.description!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            product.description!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: _textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (hasDiscount)
                                Text(
                                  'Rs. ${product.price.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    color: _textMuted,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              Text(
                                'Rs. ${product.effectivePrice.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: _brandRed,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildAddOrStepperButton(store, product, qtyInCart),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Soft Wide Card View (when user switches from Grid to Cards)
  Widget _buildSoftWideProductCard(DemoStore store, Product product) {
    final hasDiscount = product.discountPrice != null &&
        product.discountPrice! > 0 &&
        product.discountPrice! < product.price;
    final discountPct = hasDiscount
        ? (((product.price - product.discountPrice!) / product.price) * 100).round()
        : 0;
    final subCat = _resolveProductCategory(product);
    final qtyInCart = _quantityInCart(product.id);

    return GestureDetector(
      onTap: () => ProductDetailSheet.show(
        context,
        product: product,
        vendorId: store.id,
        vendorName: store.name,
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: qtyInCart > 0 ? _brandRed.withAlpha(90) : _softBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _bgCream,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${_emojiForSubCategory(subCat)} $subCat',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: _textDark,
                          ),
                        ),
                      ),
                      if (hasDiscount) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '-$discountPct%',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: _brandRed,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w900,
                      color: _textDark,
                      height: 1.25,
                    ),
                  ),
                  if (product.description != null && product.description!.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      product.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: _textMuted,
                        height: 1.35,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        'Rs. ${product.effectivePrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: _brandRed,
                        ),
                      ),
                      if (hasDiscount) ...[
                        const SizedBox(width: 6),
                        Text(
                          'Rs. ${product.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: _textMuted,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            // Right Image + Overlapping Add Button
            SizedBox(
              width: 108,
              height: 112,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: SizedBox(
                      width: 108,
                      height: 96,
                      child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                          ? Image.network(
                              product.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                color: _bgCream,
                                child: const Icon(Icons.image_outlined, color: _textMuted),
                              ),
                            )
                          : Container(
                              color: _bgCream,
                              child: const Icon(Icons.image_outlined, color: _textMuted),
                            ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    child: _buildAddOrStepperButton(store, product, qtyInCart),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddOrStepperButton(DemoStore store, Product product, int qtyInCart) {
    if (!product.isAvailable) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Text(
          'Sold Out',
          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: _textMuted),
        ),
      );
    }

    if (qtyInCart > 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: _brandRed,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: _brandRed.withAlpha(70),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () => CartController.instance.updateQuantity(product.id, -1),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Icon(Icons.remove_rounded, size: 15, color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Text(
                '$qtyInCart',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            InkWell(
              onTap: () => _addToCart(store, product),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Icon(Icons.add_rounded, size: 15, color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    return Material(
      color: _brandRed,
      borderRadius: BorderRadius.circular(14),
      elevation: 2,
      shadowColor: _brandRed.withAlpha(80),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _addToCart(store, product),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, size: 15, color: Colors.white),
              SizedBox(width: 2),
              Text(
                'Add',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewModeButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? _brandRed : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : _textMuted,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : _textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCatalogState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _softBorder),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: _bgCream,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_off_rounded, color: _brandRed, size: 30),
          ),
          const SizedBox(height: 12),
          const Text(
            'No matching products found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try clearing your search or selecting "All" categories.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: _textMuted),
          ),
          const SizedBox(height: 14),
          TextButton.icon(
            onPressed: () {
              _searchController.clear();
              setState(() {
                _selectedSubCategory = 'All';
                _selectedSortOrFilter = 'all';
                _searchQuery = '';
              });
            },
            icon: const Icon(Icons.refresh_rounded, size: 16, color: _brandRed),
            label: const Text(
              'Reset Filters',
              style: TextStyle(color: _brandRed, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingCartBar() {
    final cart = CartController.instance;
    if (cart.items.isEmpty) return const SizedBox.shrink();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_brandRed, _brandRedDark],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: _brandRed.withAlpha(95),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(45),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '${cart.totalItemCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cart.currentVendorName ?? 'Shopping Cart',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withAlpha(220),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Rs. ${cart.totalAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => CartSheet.show(context),
                icon: const Icon(Icons.shopping_bag_rounded, size: 17),
                label: const Text(
                  'View Cart',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: _brandRed,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderFallback() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_brandRed, _brandRedDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.storefront_outlined,
          size: 64,
          color: Colors.white.withAlpha(80),
        ),
      ),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: iconColor),
            const SizedBox(width: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 10.5,
                color: _textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            color: valueColor ?? _textDark,
          ),
        ),
      ],
    );
  }
}
