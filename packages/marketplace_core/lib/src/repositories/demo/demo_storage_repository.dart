import 'dart:typed_data';
import '../../models/storage_domain.dart';
import '../storage_repository.dart';

/// Demo Mode Storage Implementation
/// Allows full offline testing and APK preview without network or Supabase credentials.
class DemoStorageRepository implements StorageRepository {
  final Map<String, Uint8List> _mockStore = {};

  @override
  StorageValidationResult validateFile({
    required Uint8List bytes,
    required String fileName,
    String? mimeType,
    required StorageBucket bucket,
  }) {
    return StorageValidator.validate(
      bytes: bytes,
      fileName: fileName,
      mimeType: mimeType,
      bucket: bucket,
    );
  }

  @override
  Future<String> uploadMedia({
    required StorageBucket bucket,
    required String path,
    required Uint8List bytes,
    required String contentType,
  }) async {
    final validation = validateFile(
      bytes: bytes,
      fileName: path.split('/').last,
      mimeType: contentType,
      bucket: bucket,
    );

    if (!validation.isValid) {
      throw Exception(validation.errorMessage ?? 'Validation failed');
    }

    final fullKey = '${bucket.bucketId}/$path';
    _mockStore[fullKey] = bytes;

    if (bucket.isPublic) {
      return getPublicUrl(bucket: bucket, path: path);
    } else {
      return getSignedUrl(bucket: bucket, path: path);
    }
  }

  @override
  Future<String> uploadUserAvatar({
    required String userId,
    required Uint8List bytes,
    required String fileName,
    String contentType = 'image/jpeg',
  }) async {
    final path = '$userId/$fileName';
    return uploadMedia(
      bucket: StorageBucket.userAvatars,
      path: path,
      bytes: bytes,
      contentType: contentType,
    );
  }

  @override
  Future<String> uploadStoreLogo({
    required String vendorId,
    required Uint8List bytes,
    required String fileName,
    String contentType = 'image/jpeg',
  }) async {
    final path = '$vendorId/$fileName';
    return uploadMedia(
      bucket: StorageBucket.storeLogos,
      path: path,
      bytes: bytes,
      contentType: contentType,
    );
  }

  @override
  Future<String> uploadStoreBanner({
    required String vendorId,
    required Uint8List bytes,
    required String fileName,
    String contentType = 'image/jpeg',
  }) async {
    final path = '$vendorId/$fileName';
    return uploadMedia(
      bucket: StorageBucket.storeBanners,
      path: path,
      bytes: bytes,
      contentType: contentType,
    );
  }

  @override
  Future<String> uploadProductImage({
    required String vendorId,
    required String productId,
    required Uint8List bytes,
    required String fileName,
    String contentType = 'image/jpeg',
  }) async {
    final path = '$vendorId/$productId/$fileName';
    return uploadMedia(
      bucket: StorageBucket.productImages,
      path: path,
      bytes: bytes,
      contentType: contentType,
    );
  }

  @override
  Future<String> uploadDeliveryProof({
    required String deliveryId,
    required String riderId,
    required Uint8List bytes,
    required String fileName,
    String contentType = 'image/jpeg',
  }) async {
    final path = '$deliveryId/$riderId/$fileName';
    return uploadMedia(
      bucket: StorageBucket.deliveryProofs,
      path: path,
      bytes: bytes,
      contentType: contentType,
    );
  }

  @override
  Future<void> deleteMedia({
    required StorageBucket bucket,
    required String path,
  }) async {
    final fullKey = '${bucket.bucketId}/$path';
    _mockStore.remove(fullKey);
  }

  @override
  String getPublicUrl({
    required StorageBucket bucket,
    required String path,
  }) {
    return 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?mock_bucket=${bucket.bucketId}&mock_path=$path';
  }

  @override
  Future<String> getSignedUrl({
    required StorageBucket bucket,
    required String path,
    int expiresInSeconds = 3600,
  }) async {
    return 'https://storage.mock.batkhela.com/${bucket.bucketId}/$path?token=mock_signed_token_expires_${DateTime.now().millisecondsSinceEpoch + expiresInSeconds * 1000}';
  }

  // Diagnostic helper for unit tests
  bool hasFile(StorageBucket bucket, String path) =>
      _mockStore.containsKey('${bucket.bucketId}/$path');
}
