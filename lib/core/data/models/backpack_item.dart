import 'package:dnd5e_dm_tools/core/data/models/item.dart';
import 'package:equatable/equatable.dart';

class BackpackItem extends Equatable {
  const BackpackItem({
    required this.itemSlug,
    required this.quantity,
    this.isEquipped = false,
    this.item,
  });

  factory BackpackItem.fromJson(Map<String, dynamic> json, String documentId) {
    return BackpackItem(
      itemSlug: documentId,
      quantity: json['quantity'] as int? ?? 1,
      isEquipped: json['is_equipped'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quantity': quantity,
      'is_equipped': Item is Equipable ? isEquipped : null,
    };
  }

  final String itemSlug;
  final Item? item;
  final int quantity;
  final bool isEquipped;

  @override
  List<Object> get props => [itemSlug, quantity, isEquipped];
}
