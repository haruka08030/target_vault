import '../models/vault_item.dart';
import '../models/vault_transaction.dart';
import 'app_database.dart';

VaultItem vaultItemFromRow(Item row) {
  return VaultItem(
    id: row.id,
    title: row.title,
    targetAmount: row.targetAmount,
    currency: row.currency,
    imagePath: row.imagePath,
    targetDate: row.targetDate,
    category: row.category,
    status: row.status,
    sortOrder: row.sortOrder,
    isPinned: row.isPinned,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );
}

VaultTransaction vaultTransactionFromRow(Transaction row) {
  return VaultTransaction(
    id: row.id,
    itemId: row.itemId,
    amount: row.amount,
    date: row.date,
    note: row.note,
    createdAt: row.createdAt,
  );
}

int compareVaultItems(VaultItem a, VaultItem b) {
  final c = a.sortOrder.compareTo(b.sortOrder);
  if (c != 0) return c;
  return b.updatedAt.compareTo(a.updatedAt);
}
