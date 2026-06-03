bool itemImageRefIsDisplayable(String? ref) {
  if (ref == null || ref.isEmpty) return false;
  if (ref.startsWith('http://') || ref.startsWith('https://')) return true;
  if (ref.startsWith('data:image/')) {
    final i = ref.indexOf(',');
    return i >= 0 && i < ref.length - 1;
  }
  return false;
}
