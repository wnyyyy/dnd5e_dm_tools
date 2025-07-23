import 'package:dnd5e_dm_tools/core/util/enum.dart';

class Cost {
  const Cost({required this.quantity, required this.unit});

  factory Cost.fromJson(Map<String, dynamic> json) {
    final quantity = json['quantity'] as int? ?? 0;
    final unitStr = json['unit'] as String? ?? 'cp';
    final unit = CoinType.values.firstWhere(
      (e) => e.symbol == unitStr,
      orElse: () => CoinType.copper,
    );

    return Cost(quantity: quantity, unit: unit);
  }

  final int quantity;
  final CoinType unit;

  Map<String, dynamic> toJson() {
    return {'quantity': quantity, 'unit': unit.symbol};
  }

  @override
  String toString() => '$quantity ${unit.symbol}';
}
