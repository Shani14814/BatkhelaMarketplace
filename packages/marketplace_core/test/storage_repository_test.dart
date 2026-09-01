import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:marketplace_core/marketplace_core.dart';

void main() {
  setUp(() {
    MarketplaceDataService.instance.initialize(isDemoMode: true);
  });

  group('Phase 7F — Storage & Secure Media Management Tests', () {
    test('StorageValidator accepts valid JPG, PNG, and WebP files under size limit', () {
      final validBytes = Uint8List.fromList(List.filled(1024, 0xFF)); // 1 KB

      final avatarRes = StorageValidator.validate(
        bytes: validBytes,
        fileName: 'profile.jpg',
        mimeType: 'image/jpeg',
        bucket: StorageBucket.userAvatars,
      );
      expect(avatarRes.isValid, isTrue);

      final logoRes = StorageValidator.validate(
        bytes: validBytes,
        fileName: 'store_logo.png',
        mimeType: 'image/png',
        bucket: StorageBucket.storeLogos,
      );
      expect(logoRes.isValid, isTrue);

      final bannerRes = StorageValidator.validate(
        bytes: validBytes,
        fileName: 'banner.webp',
        mimeType: 'image/webp',
        bucket: StorageBucket.storeBanners,
      );
      expect(bannerRes.isValid, isTrue);
    });

    test('StorageValidator rejects invalid file extensions and unsupported MIME types', () {
      final validBytes = Uint8List.fromList(List.filled(1024, 0xFF));

      // Unsupported extension
      final pdfRes = StorageValidator.validate(
        bytes: validBytes,
        fileName: 'document.pdf',
        mimeType: 'application/pdf',
        bucket: StorageBucket.productImages,
      );
      expect(pdfRes.isValid, isFalse);
      expect(pdfRes.errorMessage, contains('Unsupported file extension'));

      // Unsupported MIME type
      final svgRes = StorageValidator.validate(
        bytes: validBytes,
        fileName: 'icon.svg',
        mimeType: 'image/svg+xml',
        bucket: StorageBucket.storeLogos,
      );
      expect(svgRes.isValid, isFalse);
    });

    test('StorageValidator enforces domain-specific file size limits', () {
      // 3 MB payload exceeds avatar 2 MB limit
      final largeBytes = Uint8List.fromList(List.filled(3 * 1024 * 1024, 0xAA));

      final avatarRes = StorageValidator.validate(
        bytes: largeBytes,
        fileName: 'avatar.jpg',
        bucket: StorageBucket.userAvatars,
      );
      expect(avatarRes.isValid, isFalse);
      expect(avatarRes.errorMessage, contains('exceeds maximum allowed limit'));

      // Same 3 MB payload is valid for Store Banners (5 MB limit)
      final bannerRes = StorageValidator.validate(
        bytes: largeBytes,
        fileName: 'banner.jpg',
        bucket: StorageBucket.storeBanners,
      );
      expect(bannerRes.isValid, isTrue);
    });

    test('DemoStorageRepository uploads and deletes user avatar safely', () async {
      final storageRepo = MarketplaceDataService.instance.storageRepo;
      final bytes = Uint8List.fromList([1, 2, 3, 4, 5]);

      final url = await storageRepo.uploadUserAvatar(
        userId: 'user-123',
        bytes: bytes,
        fileName: 'avatar.jpg',
      );

      expect(url, contains('user-avatars'));
      expect(url, contains('user-123/avatar.jpg'));

      if (storageRepo is DemoStorageRepository) {
        expect(storageRepo.hasFile(StorageBucket.userAvatars, 'user-123/avatar.jpg'), isTrue);

        await storageRepo.deleteMedia(
          bucket: StorageBucket.userAvatars,
          path: 'user-123/avatar.jpg',
        );
        expect(storageRepo.hasFile(StorageBucket.userAvatars, 'user-123/avatar.jpg'), isFalse);
      }
    });

    test('DemoStorageRepository uploads vendor store logo and banner', () async {
      final storageRepo = MarketplaceDataService.instance.storageRepo;
      final bytes = Uint8List.fromList([10, 20, 30, 40]);

      final logoUrl = await storageRepo.uploadStoreLogo(
        vendorId: 'store-1',
        bytes: bytes,
        fileName: 'logo.png',
        contentType: 'image/png',
      );
      expect(logoUrl, contains('store-logos'));
      expect(logoUrl, contains('store-1/logo.png'));

      final bannerUrl = await storageRepo.uploadStoreBanner(
        vendorId: 'store-1',
        bytes: bytes,
        fileName: 'banner.webp',
        contentType: 'image/webp',
      );
      expect(bannerUrl, contains('store-banners'));
      expect(bannerUrl, contains('store-1/banner.webp'));
    });

    test('DemoStorageRepository uploads product catalog image with vendor hierarchy', () async {
      final storageRepo = MarketplaceDataService.instance.storageRepo;
      final bytes = Uint8List.fromList([100, 200]);

      final productImageUrl = await storageRepo.uploadProductImage(
        vendorId: 'store-1',
        productId: 'prod-45',
        bytes: bytes,
        fileName: 'karahi.jpg',
      );

      expect(productImageUrl, contains('product-images'));
      expect(productImageUrl, contains('store-1/prod-45/karahi.jpg'));
    });

    test('DemoStorageRepository uploads delivery proof with private signed URL generation', () async {
      final storageRepo = MarketplaceDataService.instance.storageRepo;
      final bytes = Uint8List.fromList([55, 66, 77, 88]);

      final proofUrl = await storageRepo.uploadDeliveryProof(
        deliveryId: 'del-901',
        riderId: 'rider-prof-1',
        bytes: bytes,
        fileName: 'receipt_signature.jpg',
      );

      // Delivery proofs are private, should return signed URL structure
      expect(proofUrl, contains('delivery-proofs'));
      expect(proofUrl, contains('del-901/rider-prof-1/receipt_signature.jpg'));
      expect(proofUrl, contains('token=mock_signed_token'));
    });

    test('DemoStorageRepository throws on empty file upload', () async {
      final storageRepo = MarketplaceDataService.instance.storageRepo;
      final emptyBytes = Uint8List(0);

      expect(
        () async => await storageRepo.uploadUserAvatar(
          userId: 'user-fail',
          bytes: emptyBytes,
          fileName: 'avatar.jpg',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('MarketplaceDataService seamlessly switches to Supabase storage implementation in Supabase Mode', () {
      MarketplaceDataService.instance.initialize(isDemoMode: false);
      expect(MarketplaceDataService.instance.isDemoMode, isFalse);
      expect(MarketplaceDataService.instance.storageRepo, isA<SupabaseStorageRepository>());

      // Restore demo mode
      MarketplaceDataService.instance.initialize(isDemoMode: true);
      expect(MarketplaceDataService.instance.isDemoMode, isTrue);
      expect(MarketplaceDataService.instance.storageRepo, isA<DemoStorageRepository>());
    });
  });
}
