import 'dart:convert';
import 'dart:typed_data';

Future<Uint8List?> readImageBytesForUpload(String? ref) async {
  if (ref == null || ref.isEmpty) return null;
  if (ref.startsWith('http://') || ref.startsWith('https://')) return null;
  if (!ref.startsWith('data:image/')) return null;
  final i = ref.indexOf(',');
  if (i < 0 || i >= ref.length - 1) return null;
  return Uint8List.fromList(base64Decode(ref.substring(i + 1)));
}
