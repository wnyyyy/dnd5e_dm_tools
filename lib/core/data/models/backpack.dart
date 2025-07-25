import 'package:dnd5e_dm_tools/core/data/models/backpack_item.dart';
import 'package:dnd5e_dm_tools/core/util/enum.dart';
import 'package:equatable/equatable.dart';

class Backpack extends Equatable {
  const Backpack({
    required this.items,
    required this.copper,
    required this.silver,
    required this.gold,
  });

  factory Backpack.fromJson(Map<String, dynamic> json) {
    final items =
        (json['items'] as Map<String, dynamic>?)
            ?.map(
              (key, value) => MapEntry(
                key,
                BackpackItem.fromJson(value as Map<String, dynamic>, key),
              ),
            )
            .values
            .toList() ??
        [];

    final coinsMap = (json['coins'] as Map?)?.cast<String, int>() ?? {};
    final copper = coinsMap[CoinType.copper.symbol] ?? 0;
    final silver = coinsMap[CoinType.silver.symbol] ?? 0;
    final gold = coinsMap[CoinType.gold.symbol] ?? 0;

    return Backpack(items: items, copper: copper, silver: silver, gold: gold);
  }

  Map<String, dynamic> toJson() {
    final itemsJson = <String, dynamic>{};
    for (final item in items) {
      itemsJson[item.itemSlug] = item.toJson();
    }

    return {
      'items': itemsJson,
      'coins': {
        CoinType.copper.symbol: copper,
        CoinType.silver.symbol: silver,
        CoinType.gold.symbol: gold,
      },
    };
  }

  final List<BackpackItem> items;
  final int copper;
  final int silver;
  final int gold;

  BackpackItem? getItemBySlug(String itemSlug) {
    final item = items.where((item) => item.itemSlug == itemSlug).firstOrNull;
    return item;
  }

  Backpack removeBySlug(String itemSlug) {
    final updatedItems = items
        .where((item) => item.itemSlug != itemSlug)
        .toList();
    return copyWith(items: updatedItems);
  }

  Backpack updateItemQuantity(String itemSlug, {required int quantity}) {
    final updatedItems = items.map((item) {
      if (item.itemSlug == itemSlug) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();
    return copyWith(items: updatedItems);
  }

  Backpack copyWith({
    List<BackpackItem>? items,
    int? copper,
    int? silver,
    int? gold,
  }) {
    return Backpack(
      items: items ?? this.items,
      copper: copper ?? this.copper,
      silver: silver ?? this.silver,
      gold: gold ?? this.gold,
    );
  }

  num get totalWeight {
    num totalWeight = 0;
    if (items.isEmpty) {
      return totalWeight;
    }
    for (final itemBackpack in items) {
      final item = itemBackpack.item;
      if (item == null) {
        continue;
      }
      totalWeight += item.weight * itemBackpack.quantity;
    }
    return totalWeight;
  }

  @override
  List<Object> get props => [items];
}
