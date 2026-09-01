import 'dart:typed_data';

/// Enumeration of all Storage Buckets in Batkhela Marketplace
enum StorageBucket {
  userAvatars('user-avatars', 2 * 1024 * 1024, true), // 2 MB, Public Read
  storeLogos('store-logos', 3 * 1024 * 1024, true), // 3 MB, Public Read
  storeBanners('store-banners', 5 * 1024 * 1024, true), // 5 MB, Public Read
  productImages('product-images', 5 * 1024 * 1024, true), // 5 MB, Public Read
  deliveryProofs('delivery-proofs', 10 * 1024 * 1024, false); // 10 MB, Strictly Private

  final String bucketId;
  final int maxSizeBytes;
  final bool isPublic;

  const StorageBucket(this.bucketId, this.maxSizeBytes, this.isPublic);
}

/// Validation result for media files prior to upload
class StorageValidationResult {
  final bool isValid;
  final String? errorMessage;

  const StorageValidationResult({required this.isValid, this.errorMessage});

  factory StorageValidationResult.success() => const StorageValidationResult(isValid: true);
  factory StorageValidationResult.failure(String message) =>
      StorageValidationResult(isValid: false, errorMessage: message);
}

/// Helper class for file validation rules
class StorageValidator {
  static const Set<String> allowedMimeTypes = {
    'image/jpeg',
    'image/png',
    'image/webp',
  };

  static const Set<String> allowedExtensions = {
    'jpg',
    'jpeg',
    'png',
    'webp',
  };

  /// Validate file payload against bucket limits and MIME rules
  static StorageValidationResult validate({
    required Uint8List bytes,
    required String fileName,
    String? mimeType,
    required StorageBucket bucket,
  }) {
    if (bytes.isEmpty) {
      return StorageValidationResult.failure('File is empty.');
    }

    if (bytes.lengthInBytes > bucket.maxSizeBytes) {
      final maxMb = (bucket.maxSizeBytes / (1024 * 1024)).toStringAsFixed(1);
      return StorageValidationResult.failure(
        'File size (${(bytes.lengthInBytes / (1024 * 1024)).toStringAsFixed(2)} MB) exceeds maximum allowed limit of $maxMb MB.',
      );
    }

    final ext = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : '';
    if (!allowedExtensions.contains(ext)) {
      return StorageValidationResult.failure(
        'Unsupported file extension ".$ext". Allowed formats: jpg, jpeg, png, webp.',
      );
    }

    if (mimeType != null && !allowedMimeTypes.contains(mimeType.toLowerCase())) {
      return StorageValidationResult.failure(
        'Unsupported MIME type "$mimeType". Allowed: image/jpeg, image/png, image/webp.',
      );
    }

    return StorageValidationResult.success();
  }
}
