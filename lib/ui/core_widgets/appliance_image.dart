import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Displays appliance/product images with automatic disk & memory caching via
/// [CachedNetworkImage], smooth fade-in, progress indicator, and fallback icon.
class ApplianceImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final IconData fallbackIcon;
  final Color? backgroundColor;

  const ApplianceImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 12,
    this.fallbackIcon = Icons.kitchen_outlined,
    this.backgroundColor,
  });

  /// Returns a cached [ImageProvider] for valid HTTP(S) URLs, or `null` otherwise.
  static ImageProvider? provider(String url) {
    final trimmed = url.trim();
    final uri = Uri.tryParse(trimmed);
    if (uri != null && (uri.isScheme('http') || uri.isScheme('https'))) {
      return CachedNetworkImageProvider(trimmed);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? context.surfaceBg;
    final trimmedUrl = imageUrl.trim();

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: width,
        height: height,
        color: bg,
        child: _buildImageContent(context, trimmedUrl),
      ),
    );
  }

  Widget _buildImageContent(BuildContext context, String url) {
    if (url.isEmpty) {
      return _buildFallback();
    }

    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      );
    }

    final uri = Uri.tryParse(url);
    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
      return _buildFallback();
    }

    final dpr = MediaQuery.devicePixelRatioOf(context);
    final int? memWidth = (width != null && width!.isFinite && width! > 0)
        ? (width! * dpr).round()
        : null;

    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: memWidth,
      maxWidthDiskCache: 1000,
      fadeInDuration: const Duration(milliseconds: 220),
      fadeOutDuration: const Duration(milliseconds: 120),
      progressIndicatorBuilder: (context, url, downloadProgress) {
        final progress = downloadProgress.progress;
        if (progress != null) {
          return Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                value: progress,
              ),
            ),
          );
        }
        return Center(
          child: Icon(
            fallbackIcon,
            size: (height != null && height! < 60) ? 20 : 32,
            color: AppColors.textMuted.withValues(alpha: 0.35),
          ),
        );
      },
      errorWidget: (context, url, error) => _buildFallback(),
    );
  }

  Widget _buildFallback() {
    return Center(
      child: Icon(
        fallbackIcon,
        size: (height != null && height! < 60) ? 24 : 40,
        color: AppColors.textMuted.withValues(alpha: 0.6),
      ),
    );
  }
}

