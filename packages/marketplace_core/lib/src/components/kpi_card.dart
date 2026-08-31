import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_elevation.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// KPI / Metric card for Vendor and Admin performance analytics.
class KpiCard extends StatelessWidget {
  final String? label;
  final String? title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final String? trendText;
  final String? trend;
  final bool? isPositiveTrend;
  final bool? isPositive;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final VoidCallback? onTap;

  const KpiCard({
    super.key,
    this.label,
    this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.trendText,
    this.trend,
    this.isPositiveTrend,
    this.isPositive,
    this.iconColor,
    this.iconBackgroundColor,
    this.onTap,
  }) : assert(label != null || title != null, 'Either label or title must be provided');

  String get effectiveLabel => label ?? title ?? '';
  String? get effectiveTrend => trendText ?? trend;
  bool? get effectiveIsPositive => isPositiveTrend ?? isPositive;

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? AppColors.primary;
    final effectiveIconBg = iconBackgroundColor ?? AppColors.primaryLight;

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        effectiveLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xs + 2),
                      decoration: BoxDecoration(
                        color: effectiveIconBg,
                        borderRadius: AppRadius.roundedMd,
                      ),
                      child: Icon(
                        icon,
                        size: 18,
                        color: effectiveIconColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  value,
                  style: AppTypography.headline(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (effectiveTrend != null || subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      if (effectiveTrend != null) ...[
                        if (effectiveIsPositive != null)
                          Icon(
                            effectiveIsPositive!
                                ? Icons.trending_up
                                : Icons.trending_down,
                            size: 14,
                            color: effectiveIsPositive!
                                ? AppColors.success
                                : AppColors.coral,
                          ),
                        if (effectiveIsPositive != null) const SizedBox(width: 2),
                        Text(
                          effectiveTrend!,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: effectiveIsPositive == null
                                ? AppColors.textTertiary
                                : (effectiveIsPositive!
                                    ? AppColors.success
                                    : AppColors.coral),
                          ),
                        ),
                        if (subtitle != null) const SizedBox(width: 6),
                      ],
                      if (subtitle != null)
                        Expanded(
                          child: Text(
                            subtitle!,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
