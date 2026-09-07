import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

/// Intelligent, offline-resilient Product Image & Visual Badge Component
class MarketplaceProductImage extends StatelessWidget {
  final String? imageUrl;
  final String productName;
  final String? category;
  final double width;
  final double height;
  final BorderRadius borderRadius;
  final BoxFit fit;

  const MarketplaceProductImage({
    super.key,
    this.imageUrl,
    required this.productName,
    this.category,
    this.width = 88,
    this.height = 88,
    this.borderRadius = AppRadius.roundedMd,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: AppColors.backgroundLight,
      ),
      clipBehavior: Clip.antiAlias,
      child: (imageUrl != null && imageUrl!.trim().isNotEmpty && imageUrl!.startsWith('http'))
          ? Image.network(
              imageUrl!.trim(),
              fit: fit,
              width: width,
              height: height,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _buildThemedVisual();
              },
              errorBuilder: (context, error, stackTrace) => _buildThemedVisual(),
            )
          : _buildThemedVisual(),
    );
  }

  Widget _buildThemedVisual() {
    final cat = (category ?? '').toLowerCase();
    final name = productName.toLowerCase();

    List<Color> gradientColors;
    IconData icon;
    String badgeLabel;

    if (cat.contains('food') || cat.contains('restaurant') || cat.contains('bbq') || name.contains('karahi') || name.contains('kabab') || name.contains('tikka') || name.contains('biryani') || name.contains('naan')) {
      gradientColors = const [Color(0xFFEA580C), Color(0xFFC2410C), Color(0xFF7C2D12)];
      icon = Icons.restaurant_rounded;
      badgeLabel = 'FOOD';
    } else if (cat.contains('pharmacy') || cat.contains('health') || cat.contains('medicine') || name.contains('panadol') || name.contains('risek') || name.contains('syrup') || name.contains('tablet')) {
      gradientColors = const [Color(0xFFE11D48), Color(0xFFBE123C), Color(0xFF881337)];
      icon = Icons.medication_rounded;
      badgeLabel = 'MEDS';
    } else if (cat.contains('fruit') || cat.contains('vegetable') || cat.contains('produce') || name.contains('apple') || name.contains('mango') || name.contains('tomato') || name.contains('onion') || name.contains('potato')) {
      gradientColors = const [Color(0xFF16A34A), Color(0xFF15803D), Color(0xFF14532D)];
      icon = Icons.eco_rounded;
      badgeLabel = 'FRESH';
    } else if (cat.contains('bakery') || cat.contains('sweet') || name.contains('cake') || name.contains('jamun') || name.contains('halwa') || name.contains('biscuit')) {
      gradientColors = const [Color(0xFFD97706), Color(0xFFB45309), Color(0xFF78350F)];
      icon = Icons.cake_rounded;
      badgeLabel = 'SWEETS';
    } else if (cat.contains('grocery') || name.contains('rice') || name.contains('oil') || name.contains('atta') || name.contains('tea') || name.contains('milk') || name.contains('sugar')) {
      gradientColors = const [Color(0xFF4F46E5), Color(0xFF4338CA), Color(0xFF312E81)];
      icon = Icons.shopping_basket_rounded;
      badgeLabel = 'GROCERY';
    } else {
      gradientColors = const [AppColors.primary, AppColors.primaryDark, Color(0xFF003035)];
      icon = Icons.storefront_rounded;
      badgeLabel = 'LOCAL';
    }

    final effectiveW = width.isFinite ? width : 160.0;
    final effectiveH = height.isFinite ? height : 120.0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background decorative circle
          Positioned(
            right: -effectiveW * 0.2,
            bottom: -effectiveH * 0.2,
            child: Container(
              width: effectiveW * 0.8,
              height: effectiveH * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          // Main Icon
          Icon(
            icon,
            color: Colors.white.withValues(alpha: 0.9),
            size: effectiveH > 100 ? 44 : 28,
          ),
          // Category Tag Badge
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                badgeLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
