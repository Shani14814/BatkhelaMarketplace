import 'package:flutter/material.dart';
import 'package:marketplace_core/marketplace_core.dart';

/// Modal bottom sheet showcasing detailed product specs, quantity selector, and Add-to-Cart.
class ProductDetailSheet extends StatefulWidget {
  final Product product;
  final String vendorId;
  final String vendorName;

  const ProductDetailSheet({
    super.key,
    required this.product,
    required this.vendorId,
    required this.vendorName,
  });

  static Future<void> show(
    BuildContext context, {
    required Product product,
    required String vendorId,
    required String vendorName,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ProductDetailSheet(
        product: product,
        vendorId: vendorId,
        vendorName: vendorName,
      ),
    );
  }

  @override
  State<ProductDetailSheet> createState() => _ProductDetailSheetState();
}

class _ProductDetailSheetState extends State<ProductDetailSheet> {
  int _quantity = 1;
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  double get _totalPrice => widget.product.effectivePrice * _quantity;

  void _handleAddToCart() {
    final added = CartController.instance.addItem(
      widget.product,
      quantity: _quantity,
      vendorId: widget.vendorId,
      vendorName: widget.vendorName,
      specialInstructions: _notesController.text.trim(),
    );

    if (!added) {
      // Prompt user about switching stores
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Start New Cart?'),
          content: Text(
            'Your cart currently contains items from ${CartController.instance.currentVendorName}. Would you like to clear the cart and add items from ${widget.vendorName}?',
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
                  widget.product,
                  quantity: _quantity,
                  vendorId: widget.vendorId,
                  vendorName: widget.vendorName,
                  specialInstructions: _notesController.text.trim(),
                  clearIfDifferentVendor: true,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added $_quantity x ${widget.product.name} to cart'),
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

    Navigator.pop(context);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added $_quantity x ${widget.product.name} to cart'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Drag Handle & Close
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image Banner
                    MarketplaceProductImage(
                      imageUrl: widget.product.imageUrl,
                      productName: widget.product.name,
                      category: widget.product.category,
                      width: double.infinity,
                      height: 160,
                      borderRadius: AppRadius.roundedLg,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Store / Vendor Tag
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: AppRadius.roundedSm,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.storefront, size: 14, color: AppColors.primaryDark),
                          const SizedBox(width: 4),
                          Text(
                            widget.vendorName,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    // Product Name
                    Text(
                      widget.product.name,
                      style: AppTypography.headline(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    // Price & Discount row
                    Row(
                      children: [
                        Text(
                          'PKR ${widget.product.effectivePrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        if (widget.product.discountPrice != null && widget.product.discountPrice! < widget.product.price) ...[
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'PKR ${widget.product.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textTertiary,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: const BoxDecoration(
                              color: AppColors.coralLight,
                              borderRadius: AppRadius.roundedXs,
                            ),
                            child: Text(
                              'Save PKR ${(widget.product.price - widget.product.discountPrice!).toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.coral,
                              ),
                            ),
                          ),
                        ],
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: widget.product.isAvailable ? AppColors.successLight : AppColors.errorLight,
                            borderRadius: AppRadius.roundedSm,
                          ),
                          child: Text(
                            widget.product.isAvailable ? 'In Stock' : 'Out of Stock',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: widget.product.isAvailable ? AppColors.success : AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // Description
                    if (widget.product.description != null && widget.product.description!.isNotEmpty) ...[
                      Text(
                        'Details',
                        style: AppTypography.headline(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.product.description!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],

                    // Special Instructions
                    Text(
                      'Special Instructions / Customization',
                      style: AppTypography.headline(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _notesController,
                      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        hintText: 'e.g. Less spicy, well-done, extra sauce, call on arrival...',
                        hintStyle: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                        contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.roundedMd,
                          borderSide: BorderSide(color: AppColors.borderLight),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Quantity Counter Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Quantity',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.backgroundLight,
                            borderRadius: AppRadius.roundedFull,
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, size: 18),
                                onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  '$_quantity',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, size: 18),
                                onPressed: widget.product.isAvailable ? () => setState(() => _quantity++) : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),

            // Bottom Add to Cart Button Bar
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.borderLight)),
                boxShadow: AppElevation.softCard,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: widget.product.isAvailable ? _handleAddToCart : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedFull),
                    elevation: 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Add to Cart',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'PKR ${_totalPrice.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
