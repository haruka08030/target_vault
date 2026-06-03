import 'item_status.dart';

class VaultItem {
  const VaultItem({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currency,
    this.imagePath,
    this.targetDate,
    this.category,
    required this.status,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final double targetAmount;
  final String currency;
  final String? imagePath;
  final DateTime? targetDate;
  final String? category;
  final ItemStatus status;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory VaultItem.fromRow(Map<String, dynamic> json) {
    DateTime? parseTs(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      return DateTime.tryParse(v.toString());
    }

    return VaultItem(
      id: json['id'].toString(),
      title: json['title'] as String,
      targetAmount: (json['target_amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'JPY',
      imagePath: json['image_path'] as String?,
      targetDate: parseTs(json['target_date']),
      category: json['category'] as String?,
      status: ItemStatus.fromDb(json['status'] as String),
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      createdAt: parseTs(json['created_at']) ?? DateTime.now(),
      updatedAt: parseTs(json['updated_at']) ?? DateTime.now(),
    );
  }

  VaultItem copyWith({
    String? id,
    String? title,
    double? targetAmount,
    String? currency,
    String? imagePath,
    DateTime? targetDate,
    String? category,
    ItemStatus? status,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VaultItem(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currency: currency ?? this.currency,
      imagePath: imagePath ?? this.imagePath,
      targetDate: targetDate ?? this.targetDate,
      category: category ?? this.category,
      status: status ?? this.status,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
