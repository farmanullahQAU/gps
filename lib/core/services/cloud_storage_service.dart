import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Industry-Standard Local-First + Cloudflare R2 Photo Storage & Caching Service
///
/// Architecture:
/// 1. Permanent Local Storage: Copies temporary camera/gallery files from OS `/cache`
///    into `<appDocumentsDir>/gps_media/{category}/{entityId}_{hash}.jpg` so OS cache
///    eviction never breaks local offline avatars.
/// 2. Background Cloud R2 Sync: Uploads photos to the Cloudflare Worker R2 endpoint
///    (`/api/v1/media/upload`) when online, returning a permanent CDN URL or R2 path.
/// 3. Disk Caching for Remote R2 Photos: Downloads remote R2 URLs once and caches
///    them on disk so avatars work 100% offline even on secondary synced devices.
class CloudStorageService {
  CloudStorageService._();
  static final CloudStorageService instance = CloudStorageService._();

  static const String baseUrl = 'https://myschool-api.pages.dev';

  Directory? _mediaRootDir;

  Future<Directory> _getMediaDir(String category) async {
    if (_mediaRootDir == null) {
      try {
        final docs = await getApplicationDocumentsDirectory();
        _mediaRootDir = Directory(p.join(docs.path, 'gps_media'));
      } catch (_) {
        // Fallback for unit test environments where path_provider might not be mocked
        _mediaRootDir = Directory(p.join(Directory.systemTemp.path, 'gps_media'));
      }
    }
    final dir = Directory(p.join(_mediaRootDir!.path, category));
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Resolves a raw photo path or R2 relative path into a full URL or local file path.
  static String resolveUrlOrPath(String? rawPath) {
    if (rawPath == null || rawPath.trim().isEmpty) return '';
    final clean = rawPath.trim();
    if (clean.startsWith('preset_')) return clean;
    if (clean.startsWith('/r2/') || clean.startsWith('/api/v1/media/')) {
      return '$baseUrl$clean';
    }
    if (clean.startsWith('file://')) {
      return clean.replaceFirst('file://', '');
    }
    return clean;
  }

  /// Checks if we have a locally cached disk copy of a remote R2 URL.
  Future<File?> getCachedFileForRemoteUrl(String remoteUrl) async {
    try {
      final hash = md5.convert(utf8.encode(remoteUrl)).toString();
      final ext = p.extension(Uri.parse(remoteUrl).path).isNotEmpty
          ? p.extension(Uri.parse(remoteUrl).path)
          : '.jpg';
      final dir = await _getMediaDir('r2_cache');
      final cachedFile = File(p.join(dir.path, 'r2_$hash$ext'));
      if (cachedFile.existsSync() && cachedFile.lengthSync() > 0) {
        return cachedFile;
      }

      // Download in background and cache to disk
      final res = await http.get(Uri.parse(remoteUrl)).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200 && res.bodyBytes.isNotEmpty) {
        await cachedFile.writeAsBytes(res.bodyBytes, flush: true);
        return cachedFile;
      }
    } catch (_) {}
    return null;
  }

  /// Persists a picked image from temporary cache to permanent app storage AND
  /// attempts upload to Cloudflare R2 if online.
  ///
  /// [category]: `'students'` or `'staff'`
  /// [entityId]: Student ID or Teacher User ID
  /// [sourcePath]: Path returned by `ImagePicker` or existing `photoUrl`
  /// [authToken]: Optional JWT token for authenticated R2 bucket upload
  Future<String?> persistAndUploadPhoto({
    required String category,
    required String entityId,
    required String? sourcePath,
    String? authToken,
  }) async {
    if (sourcePath == null || sourcePath.trim().isEmpty) return null;
    final cleanSource = sourcePath.trim();

    // Presets or already-uploaded cloud URLs do not need re-copying
    if (cleanSource.startsWith('preset_') ||
        cleanSource.startsWith('http://') ||
        cleanSource.startsWith('https://') ||
        cleanSource.startsWith('/r2/') ||
        cleanSource.startsWith('/api/v1/media/')) {
      return cleanSource;
    }

    final filePath = cleanSource.startsWith('file://')
        ? cleanSource.replaceFirst('file://', '')
        : cleanSource;
    final srcFile = File(filePath);
    if (!srcFile.existsSync()) {
      return cleanSource;
    }

    // 1. Copy from volatile OS cache into permanent app media directory
    String permanentLocalPath = srcFile.path;
    try {
      final dir = await _getMediaDir(category);
      final bytes = await srcFile.readAsBytes();
      final contentHash = sha1.convert(bytes).toString().substring(0, 10);
      final ext = p.extension(srcFile.path).isNotEmpty ? p.extension(srcFile.path) : '.jpg';
      final destFile = File(p.join(dir.path, '${entityId}_$contentHash$ext'));

      if (srcFile.path != destFile.path) {
        await destFile.writeAsBytes(bytes, flush: true);
      }
      permanentLocalPath = destFile.path;

      // 2. Attempt upload to Cloudflare R2 bucket if online
      final r2Url = await _uploadBytesToCloudflareR2(
        category: category,
        entityId: entityId,
        fileName: p.basename(destFile.path),
        bytes: bytes,
        authToken: authToken,
      );
      if (r2Url != null && r2Url.isNotEmpty) {
        // Also pre-populate the R2 local cache so this device never re-downloads its own upload
        try {
          final fullUrl = resolveUrlOrPath(r2Url);
          final hash = md5.convert(utf8.encode(fullUrl)).toString();
          final cacheDir = await _getMediaDir('r2_cache');
          final cacheFile = File(p.join(cacheDir.path, 'r2_$hash$ext'));
          if (!cacheFile.existsSync()) {
            await cacheFile.writeAsBytes(bytes, flush: true);
          }
        } catch (_) {}
        return r2Url;
      }
    } catch (e) {
      debugPrint('CloudStorageService persist error: $e');
    }

    return permanentLocalPath;
  }

  /// Uploads binary image payload to Cloudflare R2 Worker endpoint (`/api/v1/media/upload`)
  Future<String?> _uploadBytesToCloudflareR2({
    required String category,
    required String entityId,
    required String fileName,
    required Uint8List bytes,
    String? authToken,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/v1/media/upload');
      final request = http.MultipartRequest('POST', uri);
      if (authToken != null && authToken.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $authToken';
      }
      request.fields['category'] = category;
      request.fields['entityId'] = entityId;
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: fileName,
        ),
      );

      final streamed = await request.send().timeout(const Duration(seconds: 8));
      final response = await http.Response.fromStream(streamed);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final url = (data['url'] ?? data['r2Url'] ?? data['path'] ?? '').toString().trim();
        if (url.isNotEmpty) {
          return url;
        }
      }
    } catch (_) {
      // Offline or endpoint unavailable — safely retain permanent local file path
    }
    return null;
  }
}
