enum ItemStatus {
  /// 貯金中。まだ買っていない。
  saving,

  /// 埋め戻し中。先に買ってしまい、残高がマイナスから0に向かう。
  repaying,

  /// 完了。買い終えた。
  completed,

  /// アーカイブ。買わないことにした（やめた）。
  ///
  /// 削除と違い、履歴を残したまま棚から下ろす。貯金中に戻せる。
  archived;

  /// ホームの棚に並ぶか。
  bool get isActive => this == saving || this == repaying;

  String get dbValue => name;

  static ItemStatus fromDb(String value) => ItemStatus.values.firstWhere(
    (e) => e.dbValue == value,
    orElse: () => ItemStatus.saving,
  );
}
