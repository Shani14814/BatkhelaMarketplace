import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_elevation.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Reusable Product Card for Catalog browsing and ordering.
class ProductCatalogCard extends StatelessWidget {
  final String name;
  final String? description;
  final double price;
  final double? discountPrice;
  final String? imageUrl;
  final bool isAvailable;
  final VoidCallback? onAdd;
  final VoidCallback? onTap;
  final String currency;

  const ProductCatalogCard({
    super.key,
    required this.name,
    this.description,
    required this.price,
    this.discountPrice,
    this.imageUrl,
    this.isAvailable = true,
    this.onAdd,
    this.onTap,
    this.currency = 'PKR',
  });

  bool get hasDiscount => discountPrice != null && discountPrice! < price;

  int? get discountPercentage {
    if (!hasDiscount) return null;
    return (((price - discountPrice!) / price) * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.roundedLg,
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppElevation.softSubtle,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.roundedLg,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Details Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTypography.headline(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (description != null && description!.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          description!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: AppSpacing.sm),
                      // Price & Discount row
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: AppSpacing.xs,
                        children: [
                          Text(
                            '$currency ${(discountPrice ?? price).toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          if (hasDiscount) ...[
                            Text(
                              '$currency ${price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textTertiary,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xs,
                                vertical: 2,
                              ),
                              decoration: const BoxDecoration(
                                color: AppColors.coralLight,
                                borderRadius: AppRadius.roundedXs,
                              ),
                              child: Text(
                                '-$discountPercentage%',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.coral,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: AppSpacing.md),

                // Right Image & Add Button Stack
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.bottomCenter,
                      children: [
                        Container(
                          width: 84,
                          height: 84,
                          decoration: const BoxDecoration(
                            borderRadius: AppRadius.roundedMd,
                            color: AppColors.backgroundLight,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: imageUrl != null && imageUrl!.isNotEmpty
                              ? Image.network(
                                  imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                                )
                              : _buildPlaceholder(),
                        ),
                        if (!isAvailable)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(140),
                                borderRadius: AppRadius.roundedMd,
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'Sold Out',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        // Add Button Overlay
                        if (isAvailable && onAdd != null)
                          Positioned(
                            bottom: -10,
                            child: Semantics(
                              button: true,
                              label: 'Add $name to cart',
                              child: Material(
                                color: AppColors.primary,
                                borderRadius: AppRadius.roundedFull,
                                elevation: 2,
                                child: InkWell(
                                  onTap: onAdd,
                                  borderRadius: AppRadius.roundedFull,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.md,
                                      vertical: 4,
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.add, size: 14, color: Colors.white),
                                        SizedBox(width: 2),
                                        Text(
                                          'ADD',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (isAvailable && onAdd != null)
                      const SizedBox(height: 10),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.backgroundLight,
      alignment: Alignment.center,
      child: const Icon(
        Icons.fastfood_outlined,
        size: 32,
        color: AppColors.textTertiary,
      ),
    );
  }
}
