import 'package:dnd5e_dm_tools/core/util/enum.dart';
import 'package:equatable/equatable.dart';

class Cost extends Equatable {
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

  num get costGP {
    switch (unit) {
      case CoinType.copper:
        return quantity / 100.0;
      case CoinType.silver:
        return quantity / 10.0;
      case CoinType.gold:
        return quantity.toDouble();
    }
  }

  num get costSP {
    switch (unit) {
      case CoinType.copper:
        return quantity / 10.0;
      case CoinType.silver:
        return quantity.toDouble();
      case CoinType.gold:
        return quantity * 10.0;
    }
  }

  num get costCP {
    switch (unit) {
      case CoinType.copper:
        return quantity.toDouble();
      case CoinType.silver:
        return quantity * 10.0;
      case CoinType.gold:
        return quantity * 100.0;
    }
  }

  Cost get costNormalized {
    if (costGP >= 1 && costGP == costGP.roundToDouble()) {
      return Cost(quantity: costGP.toInt(), unit: CoinType.gold);
    } else if (costSP >= 1 && costSP == costSP.roundToDouble()) {
      return Cost(quantity: costSP.toInt(), unit: CoinType.silver);
    } else {
      return Cost(quantity: costCP.toInt(), unit: CoinType.copper);
    }
  }

  Map<String, dynamic> toJson() {
    return {'quantity': quantity, 'unit': unit.symbol};
  }

  @override
  List<Object?> get props => [quantity, unit];
}
