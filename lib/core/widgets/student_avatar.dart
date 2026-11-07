import 'dart:io';
import 'package:flutter/material.dart';
import '../services/cloud_storage_service.dart';
import '../theme/app_theme.dart';

/// Professional Student & Faculty Avatar widget with support for:
/// 1. Permanent local files
/// 2. Cloudflare R2 URLs with automatic offline disk caching
/// 3. Preset faculty avatars & clean initial letter fallback
class StudentAvatar extends StatelessWidget {
  final String? photoUrl;
  final String name;
  final String? gender;
  final double radius;
  final String? badgeText;
  final Color? badgeColor;

  const StudentAvatar({
    super.key,
    required this.name,
    this.photoUrl,
    this.gender,
    this.radius = 20,
    this.badgeText,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    final cleanName = name.trim();
    final initial = cleanName.isNotEmpty ? cleanName.substring(0, 1).toUpperCase() : 'S';
    final isFemale = gender?.toLowerCase() == 'female';

    // Tone: Soft modern neutral / pastel
    final bgColor = isFemale ? const Color(0xFFFCE7F3) : const Color(0xFFE0F2FE);
    final textColor = isFemale ? const Color(0xFFBE185D) : const Color(0xFF0369A1);

    Widget avatarImage;
    if (photoUrl != null && photoUrl!.trim().isNotEmpty) {
      final resolved = CloudStorageService.resolveUrlOrPath(photoUrl);

      if (resolved.startsWith('http://') || resolved.startsWith('https://')) {
        avatarImage = FutureBuilder<File?>(
          future: CloudStorageService.instance.getCachedFileForRemoteUrl(resolved),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null && snapshot.data!.existsSync()) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: Image.file(
                  snapshot.data!,
                  width: radius * 2,
                  height: radius * 2,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _buildFallback(initial, bgColor, textColor),
                ),
              );
            }
            return ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: Image.network(
                resolved,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _buildFallback(initial, bgColor, textColor),
              ),
            );
          },
        );
      } else {
        final file = File(resolved);
        if (file.existsSync()) {
          avatarImage = ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Image.file(
              file,
              width: radius * 2,
              height: radius * 2,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _buildFallback(initial, bgColor, textColor),
            ),
          );
        } else {
          avatarImage = _buildFallback(initial, bgColor, textColor);
        }
      }
    } else {
      avatarImage = _buildFallback(initial, bgColor, textColor);
    }

    if (badgeText == null || badgeText!.isEmpty) {
      return avatarImage;
    }

    // Wrap with tiny badge (e.g. Roll No or active indicator)
    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatarImage,
        Positioned(
          right: -2,
          bottom: -2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: badgeColor ?? AppColors.primaryDark,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            child: Text(
              badgeText!,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFallback(String initial, Color bg, Color text) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Text(
        initial,
        style: TextStyle(
          fontSize: radius * 0.9,
          fontWeight: FontWeight.w800,
          color: text,
        ),
      ),
    );
  }
}
