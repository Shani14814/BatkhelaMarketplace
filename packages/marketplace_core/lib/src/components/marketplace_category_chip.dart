import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// Category selection pill chip with Stitch visual design and accessible touch sizing.
class MarketplaceCategoryChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Widget? iconWidget;
  final bool isSelected;
  final VoidCallback? onTap;
  final Color? selectedColor;
  final Color? unselectedColor;
  final EdgeInsetsGeometry? margin;

  const MarketplaceCategoryChip({
    super.key,
    required this.label,
    this.icon,
    this.iconWidget,
    this.isSelected = false,
    this.onTap,
    this.selectedColor,
    this.unselectedColor,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final activeBg = selectedColor ?? AppColors.primary;
    final inactiveBg = unselectedColor ?? Colors.white;

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: Container(
        margin: margin ?? const EdgeInsets.only(right: AppSpacing.sm),
        child: Material(
          color: isSelected ? activeBg : inactiveBg,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.roundedFull,
            side: BorderSide(
              color: isSelected ? activeBg : AppColors.borderLight,
              width: 1.2,
            ),
          ),
          elevation: isSelected ? 2 : 0,
          shadowColor: isSelected ? activeBg.withAlpha(80) : Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppRadius.roundedFull,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (iconWidget != null) ...[
                    iconWidget!,
                    const SizedBox(width: AppSpacing.xs),
                  ] else if (icon != null) ...[
                    Icon(
                      icon,
                      size: 16,
                      color: isSelected ? Colors.white : AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
