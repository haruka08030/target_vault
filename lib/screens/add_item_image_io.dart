import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// ギャラリー画像をアプリ領域に保存し、そのパスを返す。
Future<String?> savePickedImageToAppDir(XFile x) async {
  final dir = await getApplicationDocumentsDirectory();
  final dest = File(
    '${dir.path}/item_${DateTime.now().millisecondsSinceEpoch}.jpg',
  );
  await x.saveTo(dest.path);
  return dest.path;
}
