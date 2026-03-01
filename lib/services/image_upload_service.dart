import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;

class ImageUploadService {
  static const _apiBase = 'https://roomieverse.blog';

  /// Upload a list of local image paths to Cloudflare R2.
  /// Returns a list of public URLs.
  /// Skips paths that are already URLs (e.g. from editing existing listings).
  Future<List<String>> uploadImages(
    List<String> localPaths,
    String folder,
    String listingId,
  ) async {
    final urls = <String>[];

    for (final path in localPaths) {
      if (path.startsWith('http')) {
        urls.add(path);
        continue;
      }

      try {
        final url = await _uploadSingle(path, folder, listingId);
        if (url != null) urls.add(url);
      } catch (e) {
        debugPrint('ImageUpload: Failed to upload $path: $e');
      }
    }

    return urls;
  }

  Future<String?> _uploadSingle(
    String localPath,
    String folder,
    String listingId,
  ) async {
    // 1. Read & compress the image
    Uint8List? imageBytes;
    String contentType = 'image/jpeg';

    try {
      imageBytes = await FlutterImageCompress.compressWithFile(
        localPath,
        minWidth: 1200,
        minHeight: 1200,
        quality: 80,
        format: CompressFormat.jpeg,
      );
    } catch (e) {
      debugPrint('ImageUpload: Compression failed, using original: $e');
    }

    // Fallback to original file if compression fails
    if (imageBytes == null) {
      final file = File(localPath);
      if (!file.existsSync()) return null;
      imageBytes = await file.readAsBytes();

      // Detect content type from extension
      final ext = localPath.toLowerCase().split('.').last;
      if (ext == 'png') {
        contentType = 'image/png';
      } else if (ext == 'webp') {
        contentType = 'image/webp';
      }
    }

    // 2. Request presigned URL from API
    final presignedResponse = await http.post(
      Uri.parse('$_apiBase/api/upload'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contentType': contentType,
        'folder': folder,
        'id': listingId,
      }),
    );

    if (presignedResponse.statusCode != 200) {
      debugPrint(
        'ImageUpload: Failed to get presigned URL: '
        '${presignedResponse.statusCode} ${presignedResponse.body}',
      );
      return null;
    }

    final data = jsonDecode(presignedResponse.body) as Map<String, dynamic>;
    final presignedUrl = data['presignedUrl'] as String;
    final publicUrl = data['publicUrl'] as String;

    // 3. PUT image directly to R2
    final uploadResponse = await http.put(
      Uri.parse(presignedUrl),
      headers: {'Content-Type': contentType},
      body: imageBytes,
    );

    if (uploadResponse.statusCode != 200) {
      debugPrint(
        'ImageUpload: R2 upload failed: '
        '${uploadResponse.statusCode} ${uploadResponse.body}',
      );
      return null;
    }

    debugPrint('ImageUpload: Uploaded successfully → $publicUrl');
    return publicUrl;
  }
}
