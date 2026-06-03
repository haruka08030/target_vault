class VaultTransaction {
  const VaultTransaction({
    required this.id,
    required this.itemId,
    required this.amount,
    required this.date,
    this.note,
    required this.createdAt,
  });

  final String id;
  final String itemId;
  final double amount;
  final DateTime date;
  final String? note;
  final DateTime createdAt;

  factory VaultTransaction.fromRow(Map<String, dynamic> json) {
    DateTime parseTs(dynamic v) {
      if (v is DateTime) return v;
      return DateTime.parse(v.toString());
    }

    return VaultTransaction(
      id: json['id'].toString(),
      itemId: json['item_id'].toString(),
      amount: (json['amount'] as num).toDouble(),
      date: parseTs(json['date']),
      note: json['note'] as String?,
      createdAt: parseTs(json['created_at']),
    );
  }
}
