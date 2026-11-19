import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:momos/utils/const_image_key.dart';

/// High-performance disk cache manager for network images.
/// Ensures images are stored locally, avoiding repeat network calls,
/// throttling concurrent downloads to keep the UI responsive.
class ImageDiskCacheManager {
  static Directory? _cacheDir;
  static final Map<String, Future<File?>> _inFlight = {};
  static int _activeDownloads = 0;
  static const int _maxConcurrent = 6;
  static final List<Function> _queue = [];

  static Future<Directory> getCacheDirectory() async {
    if (_cacheDir != null) return _cacheDir!;
    final temp = await getTemporaryDirectory();
    _cacheDir = Directory('${temp.path}/momo_img_cache');
    if (!await _cacheDir!.exists()) {
      await _cacheDir!.create(recursive: true);
    }
    return _cacheDir!;
  }

  static String getCacheKey(String url) {
    final bytes = utf8.encode(url);
    final base = base64Url.encode(bytes).replaceAll('=', '');
    final short = base.length > 32 ? base.substring(base.length - 32) : base;
    return '${url.hashCode.abs().toRadixString(36)}_$short.bin';
  }

  static File? getLocalFileIfCached(String url) {
    if (kIsWeb || _cacheDir == null) return null;
    final file = File('${_cacheDir!.path}/${getCacheKey(url)}');
    return (file.existsSync() && file.lengthSync() > 0) ? file : null;
  }

  static Future<File?> getImageFile(String url) async {
    if (kIsWeb) return null;
    try {
      final dir = await getCacheDirectory();
      final file = File('${dir.path}/${getCacheKey(url)}');
      if (file.existsSync() && file.lengthSync() > 0) {
        return file;
      }

      if (_inFlight.containsKey(url)) {
        return await _inFlight[url];
      }

      final completer = Completer<File?>();
      _inFlight[url] = completer.future;

      void processDownload() async {
        _activeDownloads++;
        try {
          final uri = Uri.parse(url);
          final response = await http
              .get(uri)
              .timeout(const Duration(seconds: 15));
          if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
            await file.writeAsBytes(response.bodyBytes, flush: true);
            completer.complete(file);
          } else {
            completer.complete(null);
          }
        } catch (_) {
          completer.complete(null);
        } finally {
          _inFlight.remove(url);
          _activeDownloads--;
          if (_queue.isNotEmpty) {
            final next = _queue.removeAt(0);
            next();
          }
        }
      }

      if (_activeDownloads < _maxConcurrent) {
        processDownload();
      } else {
        _queue.add(processDownload);
      }

      return await completer.future;
    } catch (_) {
      return null;
    }
  }
}

/// Memory and disk-optimized network image widget that automatically calculates
/// cacheWidth and cacheHeight to prevent decoding full-resolution bitmaps
/// and caches images locally for butter-smooth rendering.
class SafeNetworkImage extends StatefulWidget {
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

  /// Pre-warms cache directory in background
  static Future<void> initCache() async {
    if (!kIsWeb) {
      await ImageDiskCacheManager.getCacheDirectory();
    }
  }

  /// Precaches image in local disk and memory ahead of time
  static Future<void> precache(
    String url, {
    BuildContext? context,
    int? cacheWidth,
    int? cacheHeight,
  }) async {
    try {
      if (url.isEmpty || !url.startsWith('http')) return;
      final file = await ImageDiskCacheManager.getImageFile(url);
      if (file != null && file.existsSync()) {
        final provider = ResizeImage.resizeIfNeeded(
          cacheWidth,
          cacheHeight,
          FileImage(file),
        );
        final ctx = context ?? Get.context;
        if (ctx != null && ctx.mounted) {
          precacheImage(provider, ctx);
        }
      }
    } catch (_) {}
  }

  @override
  State<SafeNetworkImage> createState() => _SafeNetworkImageState();
}

class _SafeNetworkImageState extends State<SafeNetworkImage> {
  File? _cachedFile;
  bool _isLoading = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(SafeNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _loadImage();
    }
  }

  void _loadImage() {
    final url = widget.imageUrl?.trim();
    if (url == null || url.isEmpty || !url.startsWith('http')) {
      _cachedFile = null;
      _isLoading = false;
      _hasError = false;
      return;
    }

    if (kIsWeb) {
      _isLoading = false;
      _hasError = false;
      return;
    }

    final syncFile = ImageDiskCacheManager.getLocalFileIfCached(url);
    if (syncFile != null) {
      _cachedFile = syncFile;
      _isLoading = false;
      _hasError = false;
      return;
    }

    _isLoading = true;
    _hasError = false;

    ImageDiskCacheManager.getImageFile(url).then((file) {
      if (!mounted) return;
      if (file != null) {
        setState(() {
          _cachedFile = file;
          _isLoading = false;
          _hasError = false;
        });
      } else {
        setState(() {
          _cachedFile = null;
          _isLoading = false;
          _hasError = true;
        });
      }
    });
  }

  int? _resolveCacheWidth(BuildContext context) {
    if (widget.cacheWidth != null) return widget.cacheWidth;
    if (widget.width != null && widget.width! > 0) {
      // 2.5x density is optimal for sharp rendering while capping memory
      return (widget.width! * 2.5).round().clamp(50, 1200);
    }
    return null;
  }

  int? _resolveCacheHeight(BuildContext context) {
    if (widget.cacheHeight != null) return widget.cacheHeight;
    if (widget.height != null && widget.height! > 0) {
      return (widget.height! * 2.5).round().clamp(50, 1200);
    }
    return null;
  }

  Widget _buildFallback(
    BuildContext context,
    int? resolvedCacheW,
    int? resolvedCacheH,
  ) {
    final assetPath = widget.fallbackAsset ?? AppImages().momoImg;
    return Image.asset(
      assetPath,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      cacheWidth: resolvedCacheW,
      cacheHeight: resolvedCacheH,
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    if (widget.placeholder != null) return widget.placeholder!;
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F5),
        borderRadius:
            widget.borderRadius ??
            (widget.isCircle ? null : BorderRadius.circular(12)),
      ),
      child: Center(
        child: Icon(
          Icons.fastfood_outlined,
          color: Colors.grey.shade300,
          size: (widget.width != null && widget.width! < 60) ? 18 : 26,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resolvedCacheW = _resolveCacheWidth(context);
    final resolvedCacheH = _resolveCacheHeight(context);

    Widget content;
    final url = widget.imageUrl?.trim();

    if (url == null || url.isEmpty || !url.startsWith('http')) {
      content = _buildFallback(context, resolvedCacheW, resolvedCacheH);
    } else if (kIsWeb) {
      content = Image.network(
        url,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        cacheWidth: resolvedCacheW,
        cacheHeight: resolvedCacheH,
        gaplessPlayback: true,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildPlaceholder(context);
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildFallback(context, resolvedCacheW, resolvedCacheH);
        },
      );
    } else if (_cachedFile != null) {
      content = Image(
        image: ResizeImage.resizeIfNeeded(
          resolvedCacheW,
          resolvedCacheH,
          FileImage(_cachedFile!),
        ),
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallback(context, resolvedCacheW, resolvedCacheH);
        },
      );
    } else if (_hasError) {
      content = _buildFallback(context, resolvedCacheW, resolvedCacheH);
    } else if (_isLoading) {
      content = _buildPlaceholder(context);
    } else {
      content = _buildFallback(context, resolvedCacheW, resolvedCacheH);
    }

    if (widget.isCircle) {
      content = ClipOval(child: content);
    } else if (widget.borderRadius != null) {
      content = ClipRRect(borderRadius: widget.borderRadius!, child: content);
    }

    return RepaintBoundary(child: content);
  }
}
