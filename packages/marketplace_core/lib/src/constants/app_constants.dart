/// Application-wide constants for Batkhela Marketplace
class AppConstants {
  static const String appName = 'Batkhela Marketplace';
  static const String currency = 'PKR';
  static const String currencySymbol = 'Rs.';

  // Geographic boundaries & Center for Batkhela, Khyber Pakhtunkhwa
  static const double defaultLatitude = 34.6186;
  static const double defaultLongitude = 71.9723;
  static const double defaultZoom = 14.5;

  // Pagination & limits
  static const int defaultPageSize = 20;

  // Supabase Storage Buckets
  static const String productBucket = 'product-images';
  static const String vendorBucket = 'vendor-logos';
  static const String kycBucket = 'kyc-documents';
  static const String avatarBucket = 'avatars';
}
