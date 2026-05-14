import 'dart:io';

import 'package:flutter/material.dart';

Widget itemCoverImageFromFile(
  String path, {
  required BoxFit fit,
  Color? color,
  BlendMode? colorBlendMode,
}) {
  final f = File(path);
  if (!f.existsSync()) return const SizedBox.shrink();
  return Image.file(f, fit: fit, color: color, colorBlendMode: colorBlendMode);
}
