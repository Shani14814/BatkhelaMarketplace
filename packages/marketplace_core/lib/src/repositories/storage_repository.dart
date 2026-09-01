import 'dart:typed_data';
import '../models/storage_domain.dart';

/// Storage Repository Contract for Clean Architecture
/// UI components and business logic interact solely via this interface.
abstract class StorageRepository {
  /// Upload user profile avatar
  Future<String> uploadUserAvatar({
    required String userId,
    required Uint8List bytes,
    required String fileName,
    String contentType = 'image/jpeg',
  });

  /// Upload vendor store logo
  Future<String> uploadStoreLogo({
    required String vendorId,
    required Uint8List bytes,
    required String fileName,
    String contentType = 'image/jpeg',
  });

  /// Upload vendor store banner
  Future<String> uploadStoreBanner({
    required String vendorId,
    required Uint8List bytes,
    required String fileName,
    String contentType = 'image/jpeg',
  });

  /// Upload product catalog image
  Future<String> uploadProductImage({
    required String vendorId,
    required String productId,
    required Uint8List bytes,
    required String fileName,
    String contentType = 'image/jpeg',
  });

  /// Upload delivery proof photo (strictly private access)
  Future<String> uploadDeliveryProof({
    required String deliveryId,
    required String riderId,
    required Uint8List bytes,
    required String fileName,
    String contentType = 'image/jpeg',
  });

  /// Generic upload method
  Future<String> uploadMedia({
    required StorageBucket bucket,
    required String path,
    required Uint8List bytes,
    required String contentType,
  });

  /// Delete media from storage
  Future<void> deleteMedia({
    required StorageBucket bucket,
    required String path,
  });

  /// Resolve public URL for public bucket assets
  String getPublicUrl({
    required StorageBucket bucket,
    required String path,
  });

  /// Create a time-limited signed URL for private bucket assets (e.g. delivery proofs)
  Future<String> getSignedUrl({
    required StorageBucket bucket,
    required String path,
    int expiresInSeconds = 3600,
  });

  /// Pre-upload client-side validation
  StorageValidationResult validateFile({
    required Uint8List bytes,
    required String fileName,
    String? mimeType,
    required StorageBucket bucket,
  });
}
