import 'package:dnd5e_dm_tools/core/data/models/item.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_cubit.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddItemButton extends StatefulWidget {
  const AddItemButton({super.key, required this.onAdd});

  final void Function(Item) onAdd;

  @override
  State<AddItemButton> createState() => _AddItemButtonState();
}

class _AddItemButtonState extends State<AddItemButton> {
  final TextEditingController textEditingController = TextEditingController();

  List<Item> _filterItems(List<Item> items, String searchText) {
    if (searchText.isEmpty) return [];
    final lower = searchText.toLowerCase();
    return items.where((item) {
      final name = item.name.toLowerCase();
      final bool isCommon;
      if (item is GenericItem) {
        isCommon = true;
      } else if (item is WeaponTemplate) {
        isCommon = item.rarity.name == 'common';
      } else if (item is Weapon) {
        isCommon = item.rarity.name == 'common';
        // } else if (item is Armor) {
        //   isCommon = (item.rarity?.name ?? 'common') == 'common';
      } else {
        isCommon = false;
      }
      return name.contains(lower) && isCommon;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return IconButton(
      icon: const Icon(Icons.add_box_outlined, size: 36),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              child: StatefulBuilder(
                builder: (context, setDialogState) {
                  final rulesState = context.read<RulesCubit>().state;
                  final List<Item> items = rulesState is RulesStateLoaded
                      ? rulesState.allItems
                      : [];
                  final String searchText = textEditingController.text
                      .toLowerCase();
                  final List<Item> filteredItems = _filterItems(
                    items,
                    searchText,
                  );

                  return SizedBox(
                    width: screenWidth * 0.8,
                    height: screenHeight * 0.5,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 24,
                          ),
                          child: TextField(
                            autofocus: true,
                            controller: textEditingController,
                            onChanged: (_) => setDialogState(() {}),
                            decoration: InputDecoration(
                              labelText: 'Search Items',
                              border: const OutlineInputBorder(),
                              suffixIcon: textEditingController.text.isEmpty
                                  ? const Icon(Icons.search)
                                  : IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        textEditingController.clear();
                                        setDialogState(() {});
                                      },
                                    ),
                            ),
                          ),
                        ),
                        if (searchText.isNotEmpty)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 12,
                                right: 12,
                                bottom: 24,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: filteredItems.isEmpty
                                    ? const Center(
                                        child: Text('No items found'),
                                      )
                                    : ListView.separated(
                                        itemCount: filteredItems.length > 15
                                            ? 15
                                            : filteredItems.length,
                                        itemBuilder: (context, index) {
                                          final item = filteredItems[index];
                                          return ListTile(
                                            title: Text(item.name),
                                            subtitle: Text(item.descriptor),
                                            onTap: () {
                                              widget.onAdd(item);
                                              Navigator.of(context).pop();
                                            },
                                          );
                                        },
                                        separatorBuilder: (_, __) =>
                                            const Divider(),
                                      ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }
}
