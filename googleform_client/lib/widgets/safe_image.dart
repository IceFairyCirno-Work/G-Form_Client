import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Simple LRU in-memory cache for network image bytes.
class _ImageMemoryCache {
  static const int _maxEntries = 50;
  static final Map<String, Uint8List> _cache = {};
  static final List<String> _keys = [];

  static String _cacheKey(String url, Map<String, String>? headers) {
    if (headers == null || headers.isEmpty) return url;
    final headerPart = headers.entries
        .map((entry) => '${entry.key}=${entry.value}')
        .join('&');
    return '$url|$headerPart';
  }

  static Uint8List? get(String url, Map<String, String>? headers) {
    final key = _cacheKey(url, headers);
    final bytes = _cache[key];
    if (bytes != null) {
      _keys.remove(key);
      _keys.add(key);
    }
    return bytes;
  }

  static void put(String url, Map<String, String>? headers, Uint8List bytes) {
    final key = _cacheKey(url, headers);
    if (_cache.containsKey(key)) {
      _keys.remove(key);
    } else {
      while (_keys.length >= _maxEntries) {
        final oldest = _keys.removeAt(0);
        _cache.remove(oldest);
      }
    }
    _cache[key] = bytes;
    _keys.add(key);
  }
}

/// Fetches image bytes via [HttpClient], catching all network errors.
/// Returns null on any failure (non-200, empty body, invalid URL, etc.).
Future<Uint8List?> fetchNetworkImageBytes(
  String url, {
  Map<String, String>? headers,
}) async {
  if (url.isEmpty ||
      (!url.startsWith('http://') && !url.startsWith('https://'))) {
    return null;
  }

  final cached = _ImageMemoryCache.get(url, headers);
  if (cached != null) {
    return cached;
  }

  HttpClient? client;
  try {
    client = HttpClient();
    final request = await client.getUrl(Uri.parse(url));
    headers?.forEach((name, value) {
      request.headers.set(name, value);
    });
    final response = await request.close();
    if (response.statusCode != HttpStatus.ok) {
      await response.drain<void>();
      return null;
    }
    final bytes = await consolidateHttpClientResponseBytes(response);
    if (bytes.isEmpty) return null;
    _ImageMemoryCache.put(url, headers, bytes);
    return bytes;
  } catch (e) {
    if (kDebugMode) {
      debugPrint('fetchNetworkImageBytes error for $url: $e');
    }
    return null;
  } finally {
    client?.close(force: true);
  }
}

/// Loads a network image using [HttpClient] + [Image.memory], bypassing
/// Flutter's [NetworkImage._loadAsync] which can throw uncaught exceptions.
class SafeImageLoader extends StatefulWidget {
  final String url;
  final Map<String, String>? headers;
  final BoxFit fit;
  final int? cacheWidth;
  final double? width;
  final double? height;
  final Widget fallback;
  final Widget? loading;

  const SafeImageLoader({
    super.key,
    required this.url,
    this.headers,
    this.fit = BoxFit.cover,
    this.cacheWidth,
    this.width,
    this.height,
    required this.fallback,
    this.loading,
  });

  @override
  State<SafeImageLoader> createState() => _SafeImageLoaderState();
}

class _SafeImageLoaderState extends State<SafeImageLoader> {
  Uint8List? _bytes;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(SafeImageLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url ||
        !mapEquals(oldWidget.headers, widget.headers)) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    final cached = _ImageMemoryCache.get(widget.url, widget.headers);
    if (cached != null) {
      if (!mounted) return;
      setState(() {
        _bytes = cached;
        _loading = false;
      });
      return;
    }

    setState(() {
      _loading = true;
      _bytes = null;
    });

    final bytes = await fetchNetworkImageBytes(
      widget.url,
      headers: widget.headers,
    );

    if (!mounted) return;
    setState(() {
      _bytes = bytes;
      _loading = false;
    });
  }

  Widget _defaultLoading() {
    return Container(
      color: const Color(0x14673AB7),
      width: widget.width,
      height: widget.height,
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0x66673AB7),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return widget.loading ?? _defaultLoading();
    }
    if (_bytes == null) {
      return widget.fallback;
    }
    return Image.memory(
      _bytes!,
      fit: widget.fit,
      cacheWidth: widget.cacheWidth,
      width: widget.width,
      height: widget.height,
      errorBuilder: (context, error, stackTrace) => widget.fallback,
    );
  }
}

/// Circle avatar that loads a network photo safely via [HttpClient].
class SafeAvatarImage extends StatefulWidget {
  final String url;
  final double radius;
  final Color backgroundColor;
  final Map<String, String>? headers;
  final Widget child;

  const SafeAvatarImage({
    super.key,
    required this.url,
    required this.radius,
    required this.backgroundColor,
    required this.child,
    this.headers,
  });

  @override
  State<SafeAvatarImage> createState() => _SafeAvatarImageState();
}

class _SafeAvatarImageState extends State<SafeAvatarImage> {
  Uint8List? _bytes;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(SafeAvatarImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url ||
        !mapEquals(oldWidget.headers, widget.headers)) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    final cached = _ImageMemoryCache.get(widget.url, widget.headers);
    if (cached != null) {
      if (!mounted) return;
      setState(() => _bytes = cached);
      return;
    }

    final bytes = await fetchNetworkImageBytes(
      widget.url,
      headers: widget.headers,
    );
    if (!mounted) return;
    setState(() => _bytes = bytes);
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: widget.backgroundColor,
      backgroundImage:
          _bytes != null ? MemoryImage(_bytes!) : null,
      child: _bytes == null ? widget.child : null,
    );
  }
}
