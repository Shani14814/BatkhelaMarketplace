import 'package:flutter/material.dart';
import '../models/order.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

enum BadgeVariant {
  info,
  success,
  warning,
  error,
  indigo,
  neutral,
}

/// Semantic Status Badge aligned with Stitch design tokens.
class MarketplaceStatusBadge extends StatelessWidget {
  final String label;
  final BadgeVariant variant;
  final IconData? icon;
  final double fontSize;
  final EdgeInsetsGeometry? padding;

  const MarketplaceStatusBadge({
    super.key,
    required this.label,
    this.variant = BadgeVariant.info,
    this.icon,
    this.fontSize = 11.0,
    this.padding,
  });

  /// Factory constructor to render badge directly from [OrderStatus]
  factory MarketplaceStatusBadge.fromOrderStatus(OrderStatus status) {
    switch (status) {
      case OrderStatus.placed:
        return MarketplaceStatusBadge(
          label: status.displayName,
          variant: BadgeVariant.info,
          icon: Icons.receipt_long_outlined,
        );
      case OrderStatus.accepted:
        return MarketplaceStatusBadge(
          label: status.displayName,
          variant: BadgeVariant.indigo,
          icon: Icons.check_box_outlined,
        );
      case OrderStatus.preparing:
        return MarketplaceStatusBadge(
          label: status.displayName,
          variant: BadgeVariant.warning,
          icon: Icons.soup_kitchen_outlined,
        );
      case OrderStatus.readyForPickup:
        return MarketplaceStatusBadge(
          label: status.displayName,
          variant: BadgeVariant.indigo,
          icon: Icons.inventory_2_outlined,
        );
      case OrderStatus.outForDelivery:
        return MarketplaceStatusBadge(
          label: status.displayName,
          variant: BadgeVariant.indigo,
          icon: Icons.delivery_dining_outlined,
        );
      case OrderStatus.delivered:
        return MarketplaceStatusBadge(
          label: status.displayName,
          variant: BadgeVariant.success,
          icon: Icons.check_circle_outline,
        );
      case OrderStatus.cancelled:
        return MarketplaceStatusBadge(
          label: status.displayName,
          variant: BadgeVariant.error,
          icon: Icons.cancel_outlined,
        );
    }
  }

  Color get _backgroundColor {
    switch (variant) {
      case BadgeVariant.info:
        return AppColors.infoLight;
      case BadgeVariant.success:
        return AppColors.successLight;
      case BadgeVariant.warning:
        return AppColors.warningLight;
      case BadgeVariant.error:
        return AppColors.errorLight;
      case BadgeVariant.indigo:
        return AppColors.indigoLight;
      case BadgeVariant.neutral:
        return const Color(0xFFF1F5F9);
    }
  }

  Color get _textColor {
    switch (variant) {
      case BadgeVariant.info:
        return AppColors.primaryDark;
      case BadgeVariant.success:
        return const Color(0xFF14532D);
      case BadgeVariant.warning:
        return const Color(0xFF92400E);
      case BadgeVariant.error:
        return const Color(0xFF991B1B);
      case BadgeVariant.indigo:
        return const Color(0xFF3730A3);
      case BadgeVariant.neutral:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 3.0,
          ),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: AppRadius.roundedFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: fontSize + 2,
              color: _textColor,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: _textColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
