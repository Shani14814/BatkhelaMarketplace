import 'package:flutter/material.dart';
import 'package:marketplace_core/marketplace_core.dart';
import '../../data/customer_demo_data.dart';
import 'product_detail_sheet.dart';
import 'cart_sheet.dart';

/// Store Details & Catalog screen for Customers browsing a vendor.
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
  String _selectedSubCategory = 'All';

  List<String> get _subCategories {
    final cats = widget.store.products
        .map((p) => p.category ?? 'General')
        .toSet()
        .toList();
    return ['All', ...cats];
  }

  List<Product> get _filteredProducts {
    if (_selectedSubCategory == 'All') {
      return widget.store.products;
    }
    return widget.store.products
        .where((p) => p.category == _selectedSubCategory)
        .toList();
  }

  void _addToCart(Product product) {
    final added = CartController.instance.addItem(
      product,
      quantity: 1,
      vendorId: widget.store.id,
      vendorName: widget.store.name,
    );

    if (!added) {
      // Prompt if items exist from another store
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Start New Cart?'),
          content: Text(
            'Your cart currently contains items from ${CartController.instance.currentVendorName}. Would you like to clear the cart and add items from ${widget.store.name}?',
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
                  vendorId: widget.store.id,
                  vendorName: widget.store.name,
                  clearIfDifferentVendor: true,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added ${product.name} to cart'),
                    backgroundColor: AppColors.primary,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
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
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // Store Header App Bar
          SliverAppBar(
            expandedHeight: 180.0,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (widget.store.imageUrl != null && widget.store.imageUrl!.isNotEmpty)
                    Image.network(
                      widget.store.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildHeaderFallback(),
                    )
                  else
                    _buildHeaderFallback(),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black87],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Store Info Card
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.roundedLg,
                boxShadow: AppElevation.softCard,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.store.name,
                          style: AppTypography.headline(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 4,
                        ),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: AppRadius.roundedSm,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, size: 14, color: Color(0xFFD97706)),
                            const SizedBox(width: 2),
                            Text(
                              widget.store.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    widget.store.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.store.address,
                          style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoColumn(
                        icon: Icons.access_time_rounded,
                        title: 'Delivery',
                        value: widget.store.deliveryTime,
                      ),
                      Container(width: 1, height: 28, color: AppColors.borderLight),
                      _buildInfoColumn(
                        icon: Icons.delivery_dining_outlined,
                        title: 'Fee',
                        value: widget.store.deliveryFee,
                      ),
                      Container(width: 1, height: 28, color: AppColors.borderLight),
                      _buildInfoColumn(
                        icon: Icons.verified_outlined,
                        title: 'Status',
                        value: widget.store.isOpen ? 'Open Now' : 'Closed',
                        valueColor: widget.store.isOpen ? AppColors.success : AppColors.coral,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Subcategory Filter Chips
          if (_subCategories.length > 1)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  itemCount: _subCategories.length,
                  itemBuilder: (context, index) {
                    final cat = _subCategories[index];
                    final isSelected = cat == _selectedSubCategory;
                    return MarketplaceCategoryChip(
                      label: cat,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          _selectedSubCategory = cat;
                        });
                      },
                    );
                  },
                ),
              ),
            ),

          // Section Title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Text(
                'Available Items (${_filteredProducts.length})',
                style: AppTypography.headline(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Products List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final product = _filteredProducts[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
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
                        vendorId: widget.store.id,
                        vendorName: widget.store.name,
                      ),
                      onAdd: () => _addToCart(product),
                    ),
                  );
                },
                childCount: _filteredProducts.length,
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),

      // Bottom Cart Summary Bar
      bottomNavigationBar: ValueListenableBuilder<List<CartItem>>(
        valueListenable: CartController.instance.itemsNotifier,
        builder: (context, items, _) {
          if (items.isEmpty) return const SizedBox.shrink();

          final cart = CartController.instance;

          return SafeArea(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: AppColors.borderLight),
                ),
                boxShadow: AppElevation.softCard,
              ),
              child: Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${cart.totalItemCount} Items in Cart',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'PKR ${cart.totalAmount.toStringAsFixed(0)}',
                        style: AppTypography.headline(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () => CartSheet.show(context),
                    icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                    label: const Text('View Cart'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.roundedFull,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                        vertical: AppSpacing.md,
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

  Widget _buildHeaderFallback() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
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

  Widget _buildInfoColumn({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(height: 2),
        Text(
          title,
          style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
