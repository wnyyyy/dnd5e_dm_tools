import 'package:dnd5e_dm_tools/core/data/models/backpack_item.dart';
import 'package:dnd5e_dm_tools/core/data/models/item.dart';
import 'package:equatable/equatable.dart';

class Backpack extends Equatable {
  const Backpack({required this.items});

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

    return Backpack(items: items);
  }

  final List<BackpackItem> items;

  Backpack copyWith({List<BackpackItem>? items}) {
    return Backpack(items: items ?? this.items);
  }

  @override
  List<Object> get props => [items];
}
