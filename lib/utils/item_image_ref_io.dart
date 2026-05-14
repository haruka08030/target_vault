import 'dart:io';

bool itemImageRefIsDisplayable(String? ref) {
  if (ref == null || ref.isEmpty) return false;
  if (ref.startsWith('data:image/')) {
    final i = ref.indexOf(',');
    return i >= 0 && i < ref.length - 1;
  }
  return File(ref).existsSync();
}
