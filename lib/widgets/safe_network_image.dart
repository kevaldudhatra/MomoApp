import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:momos/utils/const_image_key.dart';

/// Memory-optimized network image widget that automatically calculates
/// cacheWidth and cacheHeight to prevent decoding full-resolution bitmaps
/// on low-RAM devices (2GB-4GB).
class SafeNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final bool isCircle;
  final int? cacheWidth;
  final int? cacheHeight;
  final String? fallbackAsset;
  final Widget? placeholder;

  const SafeNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.isCircle = false,
    this.cacheWidth,
    this.cacheHeight,
    this.fallbackAsset,
    this.placeholder,
  });

  int? _resolveCacheWidth(BuildContext context) {
    if (cacheWidth != null) return cacheWidth;
    if (width != null && width! > 0) {
      // 2.5x density is optimal for sharp rendering while capping memory
      return (width! * 2.5).round().clamp(50, 1200);
    }
    return null;
  }

  int? _resolveCacheHeight(BuildContext context) {
    if (cacheHeight != null) return cacheHeight;
    if (height != null && height! > 0) {
      return (height! * 2.5).round().clamp(50, 1200);
    }
    return null;
  }

  Widget _buildFallback(
    BuildContext context,
    int? resolvedCacheW,
    int? resolvedCacheH,
  ) {
    final assetPath = fallbackAsset ?? AppImages().momoImg;
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: resolvedCacheW,
      cacheHeight: resolvedCacheH,
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    if (placeholder != null) return placeholder!;
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width ?? double.infinity,
        height: height ?? double.infinity,
        color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resolvedCacheW = _resolveCacheWidth(context);
    final resolvedCacheH = _resolveCacheHeight(context);

    Widget content;
    final url = imageUrl?.trim();

    if (url == null || url.isEmpty || !url.startsWith('http')) {
      content = _buildFallback(context, resolvedCacheW, resolvedCacheH);
    } else {
      content = Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        cacheWidth: resolvedCacheW,
        cacheHeight: resolvedCacheH,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildPlaceholder(context);
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildFallback(context, resolvedCacheW, resolvedCacheH);
        },
      );
    }

    if (isCircle) {
      return ClipOval(child: content);
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: content);
    }

    return content;
  }
}
