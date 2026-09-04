library;

// Constants & Theme
export 'src/constants/app_constants.dart';
export 'src/theme/app_colors.dart';
export 'src/theme/app_typography.dart';
export 'src/theme/app_spacing.dart';
export 'src/theme/app_radius.dart';
export 'src/theme/app_elevation.dart';
export 'src/theme/app_breakpoints.dart';
export 'src/theme/app_theme.dart';

// Routing & Localization
export 'src/routing/app_routes.dart';
export 'src/localization/app_localizations_foundation.dart';

// Domain Models
export 'src/models/user_profile.dart';
export 'src/models/vendor.dart';
export 'src/models/product.dart';
export 'src/models/order.dart';
export 'src/models/delivery.dart';
export 'src/models/category.dart';
export 'src/models/customer_address.dart';
export 'src/models/rider_profile.dart';
export 'src/models/platform_setting.dart';
export 'src/models/storage_domain.dart';
export 'src/models/location_domain.dart';
export 'src/models/notification_domain.dart';

// Services & Repositories
export 'src/services/supabase_service.dart';
export 'src/services/auth_repository.dart';
export 'src/services/demo_auth_repository.dart';
export 'src/services/supabase_auth_repository.dart';
export 'src/services/auth_service.dart';
export 'src/services/marketplace_data_service.dart';
export 'src/services/realtime_subscription_manager.dart';
export 'src/services/location/location_service.dart';
export 'src/services/location/demo_location_service.dart';
export 'src/services/location/rider_location_tracker.dart';
export 'src/services/notification/push_notification_adapter.dart';
export 'src/services/notification/notification_controller.dart';

export 'src/repositories/customer_repository.dart';
export 'src/repositories/vendor_repository.dart';
export 'src/repositories/product_repository.dart';
export 'src/repositories/order_repository.dart';
export 'src/repositories/rider_repository.dart';
export 'src/repositories/delivery_repository.dart';
export 'src/repositories/category_repository.dart';
export 'src/repositories/admin_repository.dart';
export 'src/repositories/storage_repository.dart';
export 'src/repositories/notification_repository.dart';

export 'src/repositories/demo/demo_customer_repository.dart';
export 'src/repositories/demo/demo_vendor_repository.dart';
export 'src/repositories/demo/demo_product_repository.dart';
export 'src/repositories/demo/demo_order_repository.dart';
export 'src/repositories/demo/demo_rider_repository.dart';
export 'src/repositories/demo/demo_delivery_repository.dart';
export 'src/repositories/demo/demo_category_repository.dart';
export 'src/repositories/demo/demo_admin_repository.dart';
export 'src/repositories/demo/demo_storage_repository.dart';
export 'src/repositories/demo/demo_notification_repository.dart';

export 'src/repositories/supabase/supabase_customer_repository.dart';
export 'src/repositories/supabase/supabase_vendor_repository.dart';
export 'src/repositories/supabase/supabase_product_repository.dart';
export 'src/repositories/supabase/supabase_order_repository.dart';
export 'src/repositories/supabase/supabase_rider_repository.dart';
export 'src/repositories/supabase/supabase_delivery_repository.dart';
export 'src/repositories/supabase/supabase_category_repository.dart';
export 'src/repositories/supabase/supabase_admin_repository.dart';
export 'src/repositories/supabase/supabase_storage_repository.dart';
export 'src/repositories/supabase/supabase_notification_repository.dart';

// Shared UI Components (Google Stitch System)
export 'src/components/marketplace_hero_banner.dart';
export 'src/components/marketplace_category_chip.dart';
export 'src/components/vendor_store_card.dart';
export 'src/components/product_catalog_card.dart';
export 'src/components/marketplace_status_badge.dart';
export 'src/components/marketplace_bottom_nav.dart';
export 'src/components/kpi_card.dart';
export 'src/components/vendor_quick_action_button.dart';
