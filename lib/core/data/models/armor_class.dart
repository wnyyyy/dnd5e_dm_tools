class ArmorClass {
  const ArmorClass({
    required this.base,
    required this.dexterityBonus,
    this.maxDexterityBonus,
  });

  factory ArmorClass.fromJson(Map<String, dynamic> json) {
    final base = json['base'] as int? ?? 0;
    if (base < 0) {
      throw ArgumentError('Base armor class cannot be negative');
    }
    final dexterityBonus = json['dex_bonus'] as bool? ?? false;
    final maxDexterityBonus = json['max_bonus'] as int?;

    return ArmorClass(
      base: base,
      dexterityBonus: dexterityBonus,
      maxDexterityBonus: maxDexterityBonus,
    );
  }

  final int base;
  final bool dexterityBonus;
  final int? maxDexterityBonus;

  Map<String, dynamic> toJson() {
    return {
      'base': base,
      'dex_bonus': dexterityBonus,
      'max_bonus': maxDexterityBonus,
    };
  }
}
