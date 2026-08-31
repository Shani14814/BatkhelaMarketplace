import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Promotional Hero Banner aligned with Google Stitch Design System.
class MarketplaceHeroBanner extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? tag;
  final String? ctaLabel;
  final VoidCallback? onCtaTap;
  final String? imageUrl;
  final Widget? trailing;
  final Gradient? gradient;
  final Color? backgroundColor;
  final double height;

  const MarketplaceHeroBanner({
    super.key,
    required this.title,
    this.subtitle,
    this.tag,
    this.ctaLabel,
    this.onCtaTap,
    this.imageUrl,
    this.trailing,
    this.gradient,
    this.backgroundColor,
    this.height = 170.0,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGradient = gradient ??
        const LinearGradient(
          colors: [
            AppColors.primary,
            Color(0xFF004D53),
            AppColors.indigo,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: height),
      decoration: BoxDecoration(
        color: backgroundColor,
        gradient: backgroundColor == null ? effectiveGradient : null,
        borderRadius: AppRadius.roundedXl,
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A006D77),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Subtle decorative background circle
          Positioned(
            right: -30,
            bottom: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.softCyan.withAlpha(35),
              ),
            ),
          ),
          Positioned(
            right: 40,
            top: -20,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.coral.withAlpha(25),
              ),
            ),
          ),

          // Content Layer
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                // Left Column: Tag, Title, Subtitle, CTA
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (tag != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xxs,
                          ),
                          decoration: const BoxDecoration(
                            color: AppColors.coral,
                            borderRadius: AppRadius.roundedFull,
                          ),
                          child: Text(
                            tag!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                      ],
                      Text(
                        title,
                        style: AppTypography.headline(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          subtitle!,
                          style: const TextStyle(
                            color: Color(0xFFE0F7F6),
                            fontSize: 12,
                            height: 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (ctaLabel != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        Semantics(
                          button: true,
                          label: ctaLabel,
                          child: Material(
                            color: AppColors.softCyan,
                            borderRadius: AppRadius.roundedFull,
                            child: InkWell(
                              onTap: onCtaTap,
                              borderRadius: AppRadius.roundedFull,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.xs,
                                ),
                                child: Text(
                                  ctaLabel!,
                                  style: const TextStyle(
                                    color: Color(0xFF004D53),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Right Column: Optional Image or Trailing Widget
                if (trailing != null)
                  trailing!
                else if (imageUrl != null && imageUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: AppRadius.roundedLg,
                    child: Image.network(
                      imageUrl!,
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
