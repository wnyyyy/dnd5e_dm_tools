import 'dart:async';
import 'dart:math';

import 'package:dnd5e_dm_tools/core/util/helper.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_events.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/equip_tab/widgets/add_item.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/equip_tab/widgets/coins.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/equip_tab/widgets/item.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_cubit.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BackpackWidget extends StatefulWidget {
  final Map<String, dynamic> character;
  final String slug;

  const BackpackWidget(
      {super.key, required this.character, required this.slug});

  @override
  State<BackpackWidget> createState() => _BackpackWidgetState();
}

class _BackpackWidgetState extends State<BackpackWidget> {
  String sortCriteria = 'name';
  String filterCriteria = 'all';

  List<DropdownMenuItem<String>> get dropdownItems {
    return [
      const DropdownMenuItem(value: "name", child: Text("Name")),
      const DropdownMenuItem(value: "value", child: Text("Value")),
      const DropdownMenuItem(value: "equipable", child: Text("Equipable")),
    ];
  }

  Widget buildAddItemButton() {
    return AddItemButton(
      onAdd: (itemSlug, isMagic) {
        if (!isMagic) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              int quantity = 1;
              Timer? timer;

              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: const Text('Quantity'),
                    content: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        GestureDetector(
                          child: const Icon(Icons.remove_circle_outline),
                          onTap: () {
                            if (quantity > 1) {
                              setState(() => quantity--);
                            }
                          },
                          onLongPressStart: (details) {
                            timer = Timer.periodic(
                                const Duration(milliseconds: 25), (t) {
                              setState(() {
                                quantity = max(1, quantity - 1);
                              });
                            });
                          },
                          onLongPressEnd: (details) {
                            timer?.cancel();
                          },
                        ),
                        SizedBox(
                          width: 100,
                          child: TextField(
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            controller:
                                TextEditingController(text: quantity.toString())
                                  ..selection = TextSelection.collapsed(
                                      offset: quantity.toString().length),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              int newQuantity = int.tryParse(value) ?? 1;
                              setState(() => quantity = max(1, newQuantity));
                            },
                          ),
                        ),
                        GestureDetector(
                          child: const Icon(Icons.add_circle_outline),
                          onTap: () {
                            setState(() => quantity++);
                          },
                          onLongPressStart: (details) {
                            timer = Timer.periodic(
                                const Duration(milliseconds: 50), (t) {
                              setState(() {
                                quantity++;
                              });
                            });
                          },
                          onLongPressEnd: (details) {
                            timer?.cancel();
                          },
                        ),
                      ],
                    ),
                    actionsAlignment: MainAxisAlignment.spaceBetween,
                    actions: <Widget>[
                      TextButton(
                        child: const Icon(Icons.close),
                        onPressed: () {
                          timer?.cancel();
                          Navigator.pop(context);
                        },
                      ),
                      TextButton(
                        child: const Icon(Icons.done),
                        onPressed: () {
                          timer?.cancel();
                          final currQuantity = widget.character['backpack']
                                      ['items'][itemSlug] !=
                                  null
                              ? widget.character['backpack']['items'][itemSlug]
                                  ['quantity']
                              : 0;
                          widget.character['backpack']['items'][itemSlug] = {
                            'quantity': currQuantity + quantity,
                            'isEquipped': false,
                          };
                          context.read<CharacterBloc>().add(
                                CharacterUpdate(
                                  character: widget.character,
                                  slug: widget.slug,
                                  persistData: true,
                                  offline: context
                                      .read<SettingsCubit>()
                                      .state
                                      .offlineMode,
                                ),
                              );
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  );
                },
              );
            },
          );
        } else {
          widget.character['backpack']['items'][itemSlug] = {
            'quantity': 1,
            'isEquipped': false,
          };
          context.read<CharacterBloc>().add(
                CharacterUpdate(
                  character: widget.character,
                  slug: widget.slug,
                  persistData: true,
                  offline: context.read<SettingsCubit>().state.offlineMode,
                ),
              );
          Navigator.pop(context);
        }
      },
    );
  }

  bool applyFilter(Map<String, dynamic> item, String filter, bool isEquipped) {
    switch (filter) {
      case 'all':
        return true;
      case 'equipped':
        return isEquipped;
      case 'equippable':
        return isEquipable(item);
      default:
        return true;
    }
  }

  Map<String, Map<String, dynamic>> sortItems(
      Map<String, Map<String, dynamic>> items, String criteria) {
    var sortedEntries = items.entries.toList();

    switch (criteria) {
      case 'name':
        sortedEntries
            .sort((a, b) => a.value['name'].compareTo(b.value['name']));
        break;
      case 'value':
        sortedEntries.sort((b, a) => getCostTotal(
                    a.value['cost']?['unit'] ?? 'none',
                    a.value['cost']?['quantity'] ?? 0,
                    (a.value['quantity'] ?? 0.0).toDouble())
                .compareTo(getCostTotal(
              b.value['cost']?['unit'] ?? 'none',
              b.value['cost']?['quantity'] ?? 0,
              (b.value['quantity'] ?? 0.0).toDouble(),
            )));
        break;
      case 'equipable':
        sortedEntries.sort((a, b) {
          if (isEquipable(a.value) && !isEquipable(b.value)) return -1;
          if (!isEquipable(a.value) && isEquipable(b.value)) return 1;
          return 0;
        });
        break;
    }
    return Map.fromEntries(sortedEntries);
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> backpack =
        Map<String, dynamic>.from(widget.character['backpack'] ?? {});
    final Map<String, Map> backpackItems = backpack['items'] != null
        ? Map<String, Map>.from(backpack['items'])
        : {};
    final Map<String, Map<String, dynamic>> items = {};
    final screenWidth = MediaQuery.of(context).size.width;

    for (final backpackItem in backpackItems.entries) {
      final item = context.read<RulesCubit>().getItem(backpackItem.key);
      if (item != null) {
        Map<String, dynamic> typedItem = Map<String, dynamic>.from(item);

        if (applyFilter(typedItem, filterCriteria,
            backpackItem.value['isEquipped'] ?? false)) {
          items[backpackItem.key] = typedItem;
          items[backpackItem.key]?['quantity'] =
              backpackItem.value['quantity'] ?? 0;
          items[backpackItem.key]?['isEquipped'] =
              backpackItem.value['isEquipped'] ?? false;
        }
      }
    }

    final sortedItems = sortItems(items, sortCriteria);

    return Column(
      children: [
        Wrap(
          spacing: 8.0,
          children: [
            ChoiceChip(
              label: const Text('All Items'),
              selected: filterCriteria == 'all',
              onSelected: (bool selected) {
                setState(() {
                  filterCriteria = 'all';
                });
              },
            ),
            ChoiceChip(
              label: const Text('Equipped'),
              selected: filterCriteria == 'equipped',
              onSelected: (bool selected) {
                setState(() {
                  filterCriteria = 'equipped';
                });
              },
            ),
            ChoiceChip(
              label: const Text('Equippable'),
              selected: filterCriteria == 'equippable',
              onSelected: (bool selected) {
                setState(() {
                  filterCriteria = 'equippable';
                });
              },
            ),
            DropdownButton<String>(
              value: sortCriteria,
              items: dropdownItems,
              onChanged: (String? value) {
                setState(() {
                  sortCriteria = value ?? 'name';
                });
              },
            ),
          ],
        ),
        Expanded(
          child: Card(
            margin: EdgeInsets.all(screenWidth * 0.10),
            child: Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    itemCount: sortedItems.length,
                    itemBuilder: (context, index) {
                      final backpackItem = sortedItems.entries.elementAt(index);
                      final item = Map<String, dynamic>.from(
                          items[backpackItem.key] ?? {});
                      if (item.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: ItemWidget(
                          item: item,
                          quantity: backpackItem.value['quantity'],
                          isEquipped: backpackItem.value['isEquipped'],
                          onEquip: (itemKey, isEquipped) {
                            widget.character['backpack']['items'][itemKey]
                                ['isEquipped'] = isEquipped;
                            context.read<CharacterBloc>().add(
                                  CharacterUpdate(
                                    character: widget.character,
                                    slug: widget.slug,
                                    persistData: true,
                                    offline: context
                                        .read<SettingsCubit>()
                                        .state
                                        .offlineMode,
                                  ),
                                );
                          },
                        ),
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
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: CoinsWidget(
                        character: widget.character,
                        slug: widget.slug,
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                      height: 80,
                      child: VerticalDivider(),
                    ),
                    Expanded(
                        child: Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: buildAddItemButton(),
                    ))
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
