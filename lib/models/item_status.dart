enum ItemStatus {
  saving,
  repaying,
  completed;

  String get dbValue => name;

  static ItemStatus fromDb(String value) => ItemStatus.values.firstWhere(
    (e) => e.dbValue == value,
    orElse: () => ItemStatus.saving,
  );
}
