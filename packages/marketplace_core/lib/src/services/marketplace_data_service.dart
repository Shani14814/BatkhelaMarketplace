import '../repositories/customer_repository.dart';
import '../repositories/vendor_repository.dart';
import '../repositories/product_repository.dart';
import '../repositories/order_repository.dart';
import '../repositories/rider_repository.dart';
import '../repositories/delivery_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/admin_repository.dart';
import '../repositories/storage_repository.dart';

import '../repositories/demo/demo_customer_repository.dart';
import '../repositories/demo/demo_vendor_repository.dart';
import '../repositories/demo/demo_product_repository.dart';
import '../repositories/demo/demo_order_repository.dart';
import '../repositories/demo/demo_rider_repository.dart';
import '../repositories/demo/demo_delivery_repository.dart';
import '../repositories/demo/demo_category_repository.dart';
import '../repositories/demo/demo_admin_repository.dart';
import '../repositories/demo/demo_storage_repository.dart';

import '../repositories/supabase/supabase_customer_repository.dart';
import '../repositories/supabase/supabase_vendor_repository.dart';
import '../repositories/supabase/supabase_product_repository.dart';
import '../repositories/supabase/supabase_order_repository.dart';
import '../repositories/supabase/supabase_rider_repository.dart';
import '../repositories/supabase/supabase_delivery_repository.dart';
import '../repositories/supabase/supabase_category_repository.dart';
import '../repositories/supabase/supabase_admin_repository.dart';
import '../repositories/supabase/supabase_storage_repository.dart';

/// Centralized Data Hub & Repository Registry for Batkhela Marketplace
class MarketplaceDataService {
  static final MarketplaceDataService instance = MarketplaceDataService._internal();
  MarketplaceDataService._internal();

  bool _isDemoMode = true;
  bool get isDemoMode => _isDemoMode;

  late CustomerRepository customerRepo;
  late VendorRepository vendorRepo;
  late ProductRepository productRepo;
  late OrderRepository orderRepo;
  late RiderRepository riderRepo;
  late DeliveryRepository deliveryRepo;
  late CategoryRepository categoryRepo;
  late AdminRepository adminRepo;
  late StorageRepository storageRepo;

  /// Initialize Data Hub with either Demo or Real Supabase Repositories
  void initialize({
    bool isDemoMode = true,
    CustomerRepository? customCustomerRepo,
    VendorRepository? customVendorRepo,
    ProductRepository? customProductRepo,
    OrderRepository? customOrderRepo,
    RiderRepository? customRiderRepo,
    DeliveryRepository? customDeliveryRepo,
    CategoryRepository? customCategoryRepo,
    AdminRepository? customAdminRepo,
    StorageRepository? customStorageRepo,
  }) {
    _isDemoMode = isDemoMode;

    if (isDemoMode) {
      final demoCategory = DemoCategoryRepository();
      categoryRepo = customCategoryRepo ?? demoCategory;
      customerRepo = customCustomerRepo ?? DemoCustomerRepository(categoryRepo: demoCategory);
      vendorRepo = customVendorRepo ?? DemoVendorRepository();
      productRepo = customProductRepo ?? DemoProductRepository();
      orderRepo = customOrderRepo ?? DemoOrderRepository();
      riderRepo = customRiderRepo ?? DemoRiderRepository();
      deliveryRepo = customDeliveryRepo ?? DemoDeliveryRepository();
      adminRepo = customAdminRepo ?? DemoAdminRepository();
      storageRepo = customStorageRepo ?? DemoStorageRepository();
    } else {
      categoryRepo = customCategoryRepo ?? SupabaseCategoryRepository();
      customerRepo = customCustomerRepo ?? SupabaseCustomerRepository();
      vendorRepo = customVendorRepo ?? SupabaseVendorRepository();
      productRepo = customProductRepo ?? SupabaseProductRepository();
      orderRepo = customOrderRepo ?? SupabaseOrderRepository();
      riderRepo = customRiderRepo ?? SupabaseRiderRepository();
      deliveryRepo = customDeliveryRepo ?? SupabaseDeliveryRepository();
      adminRepo = customAdminRepo ?? SupabaseAdminRepository();
      storageRepo = customStorageRepo ?? SupabaseStorageRepository();
    }
  }
}
