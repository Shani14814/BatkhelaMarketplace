import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_elevation.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Reusable Store Card for Customers browsing marketplace vendors.
class VendorStoreCard extends StatelessWidget {
  final String name;
  final String? category;
  final String? address;
  final String? imageUrl;
  final double rating;
  final int? reviewCount;
  final String deliveryTime;
  final String? deliveryFee;
  final List<String>? badges;
  final bool isClosed;
  final VoidCallback? onTap;

  const VendorStoreCard({
    super.key,
    required this.name,
    this.category,
    this.address,
    this.imageUrl,
    this.rating = 4.5,
    this.reviewCount,
    this.deliveryTime = '25-35 min',
    this.deliveryFee,
    this.badges,
    this.isClosed = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.roundedLg,
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppElevation.softCard,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.roundedLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Store Header Image with Overlays
              SizedBox(
                height: 130,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (imageUrl != null && imageUrl!.isNotEmpty)
                      Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return _buildPlaceholder();
                        },
                        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                      )
                    else
                      _buildPlaceholder(),

                    // Subtle bottom gradient for readability
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.black.withAlpha(80),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),

                    // Closed Overlay if applicable
                    if (isClosed)
                      Container(
                        color: Colors.black54,
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: const BoxDecoration(
                            color: AppColors.coral,
                            borderRadius: AppRadius.roundedFull,
                          ),
                          child: const Text(
                            'Closed Now',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                    // Top Badges
                    if (badges != null && badges!.isNotEmpty && !isClosed)
                      Positioned(
                        top: AppSpacing.sm,
                        left: AppSpacing.sm,
                        child: Wrap(
                          spacing: AppSpacing.xs,
                          children: badges!.map((badge) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryDark.withAlpha(230),
                                borderRadius: AppRadius.roundedFull,
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Text(
                                badge,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),

              // Store Details
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: AppTypography.headline(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Rating Pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs + 2,
                            vertical: 2,
                          ),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: AppRadius.roundedSm,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 15,
                                color: Color(0xFFD97706),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                              if (reviewCount != null) ...[
                                const SizedBox(width: 2),
                                Text(
                                  '($reviewCount)',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (category != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        category!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (address != null && address!.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              address!,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textTertiary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    // Delivery Info Row
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          deliveryTime,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (deliveryFee != null) ...[
                          const SizedBox(width: AppSpacing.sm),
                          Container(
                            width: 3,
                            height: 3,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.textTertiary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          const Icon(
                            Icons.delivery_dining_outlined,
                            size: 14,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            deliveryFee!,
                            style: TextStyle(
                              fontSize: 12,
                              color: deliveryFee!.toLowerCase().contains('free')
                                  ? AppColors.success
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    final cat = (category ?? '').toLowerCase();
    final storeName = name.toLowerCase();

    List<Color> gradientColors;
    IconData icon;

    if (cat.contains('restaurant') || cat.contains('bbq') || storeName.contains('tikka') || storeName.contains('kabab') || storeName.contains('pulao') || storeName.contains('food')) {
      gradientColors = const [Color(0xFFEA580C), Color(0xFFC2410C), Color(0xFF7C2D12)];
      icon = Icons.restaurant_rounded;
    } else if (cat.contains('pharmacy') || cat.contains('health') || storeName.contains('pharmacy') || storeName.contains('medicos')) {
      gradientColors = const [Color(0xFFE11D48), Color(0xFFBE123C), Color(0xFF881337)];
      icon = Icons.local_pharmacy_rounded;
    } else if (cat.contains('fruit') || cat.contains('vegetable') || cat.contains('produce') || storeName.contains('sabzi') || storeName.contains('honey')) {
      gradientColors = const [Color(0xFF16A34A), Color(0xFF15803D), Color(0xFF14532D)];
      icon = Icons.eco_rounded;
    } else if (cat.contains('bakery') || cat.contains('sweet') || storeName.contains('sweet') || storeName.contains('baker')) {
      gradientColors = const [Color(0xFFD97706), Color(0xFFB45309), Color(0xFF78350F)];
      icon = Icons.cake_rounded;
    } else if (cat.contains('grocery') || storeName.contains('mart') || storeName.contains('wholesale')) {
      gradientColors = const [Color(0xFF4F46E5), Color(0xFF4338CA), Color(0xFF312E81)];
      icon = Icons.shopping_basket_rounded;
    } else if (cat.contains('electronic') || cat.contains('mobile') || storeName.contains('mobile')) {
      gradientColors = const [Color(0xFF0284C7), Color(0xFF0369A1), Color(0xFF0C4A6E)];
      icon = Icons.devices_other_rounded;
    } else {
      gradientColors = const [AppColors.primary, AppColors.primaryDark, Color(0xFF003035)];
      icon = Icons.storefront_rounded;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(45),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 34,
          color: Colors.white,
        ),
      ),
    );
  }
}
