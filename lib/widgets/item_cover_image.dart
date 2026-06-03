import 'dart:convert';

import 'package:flutter/material.dart';

import 'item_cover_image_io.dart'
    if (dart.library.html) 'item_cover_image_web.dart'
    as platform;

/// ローカルファイルパス、`data:image/...;base64,...`、または `http(s)` URL を表示する。
class ItemCoverImage extends StatelessWidget {
  const ItemCoverImage({
    super.key,
    required this.imageRef,
    this.fit = BoxFit.cover,
    this.color,
    this.colorBlendMode,
  });

  final String imageRef;
  final BoxFit fit;
  final Color? color;
  final BlendMode? colorBlendMode;

  @override
  Widget build(BuildContext context) {
    if (imageRef.startsWith('http://') || imageRef.startsWith('https://')) {
      return Image.network(
        imageRef,
        fit: fit,
        color: color,
        colorBlendMode: colorBlendMode,
        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
      );
    }
    if (imageRef.startsWith('data:image/')) {
      final idx = imageRef.indexOf(',');
      if (idx < 0 || idx >= imageRef.length - 1) {
        return const SizedBox.shrink();
      }
      try {
        final bytes = base64Decode(imageRef.substring(idx + 1));
        return Image.memory(
          bytes,
          fit: fit,
          color: color,
          colorBlendMode: colorBlendMode,
        );
      } catch (_) {
        return const SizedBox.shrink();
      }
    }
    return platform.itemCoverImageFromFile(
      imageRef,
      fit: fit,
      color: color,
      colorBlendMode: colorBlendMode,
    );
  }
}
