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
  Map<String, Map<String, dynamic>> items = {};

  List<DropdownMenuItem<String>> get dropdownItems {
    return [
      const DropdownMenuItem(value: "name", child: Text("Name")),
      const DropdownMenuItem(value: "value", child: Text("Value")),
      const DropdownMenuItem(value: "equipable", child: Text("Can Equip")),
    ];
  }

  Widget buildAddItemButton() {
    return AddItemButton(
      onAdd: (itemSlug, isMagic) {
        if (!isMagic) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return _buildQuantityDialog(context, itemSlug);
            },
          );
        } else {
          _addItemToBackpack(itemSlug, 1, isEquipped: false);
          Navigator.pop(context);
        }
      },
    );
  }

  StatefulBuilder _buildQuantityDialog(BuildContext context, String itemSlug) {
    int quantity = 1;
    Timer? timer;

    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: const Text('Quantity'),
          content: _buildQuantitySelector(setState, quantity, timer),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: <Widget>[
            TextButton(
              child: const Icon(Icons.close),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Icon(Icons.done),
              onPressed: () {
                _addItemToBackpack(itemSlug, quantity);
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Row _buildQuantitySelector(StateSetter setState, int quantity, Timer? timer) {
    return Row(
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
            timer = Timer.periodic(const Duration(milliseconds: 25), (t) {
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
            controller: TextEditingController(text: quantity.toString())
              ..selection =
                  TextSelection.collapsed(offset: quantity.toString().length),
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
            timer = Timer.periodic(const Duration(milliseconds: 50), (t) {
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
    );
  }

  void _addItemToBackpack(String itemSlug, int quantity,
      {bool isEquipped = false}) {
    final currQuantity = widget.character['backpack']['items'][itemSlug] != null
        ? widget.character['backpack']['items'][itemSlug]['quantity']
        : 0;
    widget.character['backpack']['items'][itemSlug] = {
      'quantity': currQuantity + quantity,
      'isEquipped': isEquipped,
    };
    context.read<CharacterBloc>().add(
          CharacterUpdate(
            character: widget.character,
            slug: widget.slug,
            persistData: true,
            offline: context.read<SettingsCubit>().state.offlineMode,
          ),
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
    final screenWidth = MediaQuery.of(context).size.width;

    items.clear(); // Clear previous items before updating

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

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth > 1200;
        final double horizontalPadding = isWide ? screenWidth * 0.1 : 16;

        return Column(
          children: [
            _buildFilters(horizontalPadding),
            Expanded(
              child: Card(
                margin: EdgeInsets.symmetric(
                    horizontal: horizontalPadding, vertical: 8),
                child: isWide
                    ? _buildWideLayout(sortedItems)
                    : _buildNarrowLayout(sortedItems),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilters(double horizontalPadding) {
    return Padding(
      padding: EdgeInsets.only(
          right: horizontalPadding, left: horizontalPadding, top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                label: const Text('Can Equip'),
                selected: filterCriteria == 'equippable',
                onSelected: (bool selected) {
                  setState(() {
                    filterCriteria = 'equippable';
                  });
                },
              ),
            ],
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
    );
  }

  Widget _buildWideLayout(Map<String, Map<String, dynamic>> sortedItems) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _buildItemList(sortedItems),
        ),
        const VerticalDivider(),
        SizedBox(
          width: 200,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: CoinsWidget(
                  character: widget.character,
                  slug: widget.slug,
                ),
              ),
              buildAddItemButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(Map<String, Map<String, dynamic>> sortedItems) {
    return Column(
      children: [
        Expanded(
          child: _buildItemList(sortedItems),
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
              ),
            )
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
                child: Text(
                  'Total Weight: ${getTotalWeight(widget.character['backpack']['items'], sortedItems)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  ListView _buildItemList(Map<String, Map<String, dynamic>> sortedItems) {
    return ListView.separated(
      itemCount: sortedItems.length,
      itemBuilder: (context, index) {
        final backpackItem = sortedItems.entries.elementAt(index);
        final item = Map<String, dynamic>.from(items[backpackItem.key] ?? {});
        if (item.isEmpty) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ItemWidget(
            item: item,
            quantity: backpackItem.value['quantity'],
            onQuantityChange: (quantity) {
              if (quantity == 0) {
                widget.character['backpack']['items'].remove(backpackItem.key);
              } else {
                widget.character['backpack']['items'][backpackItem.key]
                    ['quantity'] = quantity;
              }
              context.read<CharacterBloc>().add(
                    CharacterUpdate(
                      character: widget.character,
                      slug: widget.slug,
                      persistData: true,
                      offline: context.read<SettingsCubit>().state.offlineMode,
                    ),
                  );
            },
            isEquipped: backpackItem.value['isEquipped'],
            onEquip: (itemKey, isEquipped) {
              widget.character['backpack']['items'][itemKey]['isEquipped'] =
                  isEquipped;
              context.read<CharacterBloc>().add(
                    CharacterUpdate(
                      character: widget.character,
                      slug: widget.slug,
                      persistData: true,
                      offline: context.read<SettingsCubit>().state.offlineMode,
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
    );
  }
}
