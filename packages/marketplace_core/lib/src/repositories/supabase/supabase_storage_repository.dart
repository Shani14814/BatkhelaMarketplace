import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/storage_domain.dart';
import '../storage_repository.dart';

/// Supabase Storage Production Implementation
/// Securely executes storage operations using Supabase Storage API and RLS.
class SupabaseStorageRepository implements StorageRepository {
  final SupabaseClient? _customClient;

  SupabaseStorageRepository({SupabaseClient? client}) : _customClient = client;

  SupabaseClient get _client => _customClient ?? Supabase.instance.client;

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
      throw Exception(validation.errorMessage ?? 'File validation failed');
    }

    await _client.storage.from(bucket.bucketId).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            contentType: contentType,
            upsert: true,
          ),
        );

    if (bucket.isPublic) {
      return getPublicUrl(bucket: bucket, path: path);
    } else {
      return await getSignedUrl(bucket: bucket, path: path);
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
    await _client.storage.from(bucket.bucketId).remove([path]);
  }

  @override
  String getPublicUrl({
    required StorageBucket bucket,
    required String path,
  }) {
    return _client.storage.from(bucket.bucketId).getPublicUrl(path);
  }

  @override
  Future<String> getSignedUrl({
    required StorageBucket bucket,
    required String path,
    int expiresInSeconds = 3600,
  }) async {
    return await _client.storage
        .from(bucket.bucketId)
        .createSignedUrl(path, expiresInSeconds);
  }
}
