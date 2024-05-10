import 'package:dnd5e_dm_tools/core/util/helper.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/equip_tab/widgets/coins.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/equip_tab/widgets/item.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BackpackWidget extends StatelessWidget {
  final Map<String, dynamic> character;
  final String slug;

  const BackpackWidget(
      {super.key, required this.character, required this.slug});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final Map<String, dynamic> backpack =
        Map<String, dynamic>.from(character['backpack'] ?? {});
    final Map<String, Map> backpackItems =
        Map<String, Map>.from(backpack['items'] ?? {});
    final Map<String, Map> items = Map<String, Map>.from({});
    for (final backpackItem in backpackItems.entries) {
      final item = context.read<RulesCubit>().getItem(backpackItem.key);
      if (item != null) {
        items[backpackItem.key] = item;
      }
    }

    return Card(
      margin: EdgeInsets.all(screenWidth * 0.10),
      child: Column(
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: backpackItems.length,
              itemBuilder: (context, index) {
                final backpackItem = backpackItems.entries.elementAt(index);
                final item =
                    Map<String, dynamic>.from(items[backpackItem.key] ?? {});
                if (item.isEmpty) {
                  return const SizedBox.shrink();
                }
                final equipable = isEquipable(item);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ItemWidget(
                      item: item,
                      quantity: backpackItem.value['quantity'],
                      isEquipped: backpackItem.value['isEquipped']),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(
                child: Divider(
                  height: 0,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 8,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(),
            ),
          ),
          CoinsWidget(
            character: character,
            slug: slug,
          ),
        ],
      ),
    );
  }
}
