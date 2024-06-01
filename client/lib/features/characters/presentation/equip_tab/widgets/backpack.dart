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
  const BackpackWidget({
    super.key,
    required this.character,
    required this.slug,
  });
  final Map<String, dynamic> character;
  final String slug;

  @override
  State<BackpackWidget> createState() => _BackpackWidgetState();
}

class _BackpackWidgetState extends State<BackpackWidget> {
  String sortCriteria = 'name';
  String filterCriteria = 'all';
  Map<String, Map<String, dynamic>> items = {};

  List<DropdownMenuItem<String>> get dropdownItems {
    return [
      const DropdownMenuItem(value: 'name', child: Text('Name')),
      const DropdownMenuItem(value: 'value', child: Text('Value')),
      const DropdownMenuItem(value: 'equipable', child: Text('Can Equip')),
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
          _addItemToBackpack(itemSlug, 1);
          Navigator.pop(context);
        }
      },
    );
  }

  AlertDialog _buildQuantityDialog(BuildContext context, String itemSlug) {
    int quantity = 1;
    Timer? timer;
    final TextEditingController controller = TextEditingController();
    controller.text = quantity.toString();

    void incrementQuantity() {
      setState(() {
        quantity++;
        controller.text = quantity.toString();
      });
    }

    void decrementQuantity() {
      setState(() {
        quantity = max(1, quantity - 1);
        controller.text = quantity.toString();
      });
    }

    return AlertDialog(
      title: const Text('Quantity'),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          GestureDetector(
            onTap: decrementQuantity,
            onLongPressStart: (details) {
              timer = Timer.periodic(const Duration(milliseconds: 100), (t) {
                decrementQuantity();
              });
            },
            onLongPressEnd: (details) {
              timer?.cancel();
            },
            child: const Icon(Icons.remove_circle_outline),
          ),
          SizedBox(
            width: 100,
            child: TextField(
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              controller: controller,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final int newQuantity = int.tryParse(value) ?? 1;
                setState(() {
                  quantity = max(1, newQuantity);
                });
              },
            ),
          ),
          GestureDetector(
            onTap: incrementQuantity,
            onLongPressStart: (details) {
              timer = Timer.periodic(const Duration(milliseconds: 100), (t) {
                incrementQuantity();
              });
            },
            onLongPressEnd: (details) {
              timer?.cancel();
            },
            child: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
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
          },
        ),
      ],
    );
  }

  void _addItemToBackpack(
    String itemSlug,
    int quantity, {
    bool isEquipped = false,
  }) {
    final items = (widget.character['backpack'] as Map?)?['items']
            as Map<String, dynamic>? ??
        {};
    final currQuantity = (items[itemSlug] != null
            ? int.tryParse(
                (items[itemSlug] as Map)['quantity']?.toString() ?? '0',
              )
            : 0) ??
        0;
    items[itemSlug] = {
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
    Map<String, Map<String, dynamic>> items,
    String criteria,
  ) {
    final sortedEntries = items.entries.toList();

    switch (criteria) {
      case 'name':
        sortedEntries.sort(
          (a, b) => (a.value['name']?.toString() ?? '')
              .compareTo(b.value['name']?.toString() ?? ''),
        );
      case 'value':
        sortedEntries.sort(
          (b, a) => getCostTotal(
            (a.value['cost'] as Map?)?['unit']?.toString() ?? 'none',
            int.tryParse(
                  (a.value['cost'] as Map?)?['quantity']?.toString() ?? '0',
                ) ??
                0,
            (int.tryParse(a.value['quantity']?.toString() ?? '0') ?? 0.0)
                .toDouble(),
          ).compareTo(
            getCostTotal(
              (b.value['cost'] as Map?)?['unit']?.toString() ?? 'none',
              int.tryParse(
                    (b.value['cost'] as Map?)?['quantity']?.toString() ?? '0',
                  ) ??
                  0,
              (int.tryParse(b.value['quantity']?.toString() ?? '0') ?? 0.0)
                  .toDouble(),
            ),
          ),
        );
      case 'equipable':
        sortedEntries.sort((a, b) {
          if (isEquipable(a.value) && !isEquipable(b.value)) return -1;
          if (!isEquipable(a.value) && isEquipable(b.value)) return 1;
          return 0;
        });
    }
    return Map.fromEntries(sortedEntries);
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> backpack =
        Map<String, dynamic>.from((widget.character['backpack'] as Map?) ?? {});
    final Map<String, Map> backpackItems = backpack['items'] != null
        ? Map<String, Map>.from(backpack['items'] as Map)
        : {};
    final screenWidth = MediaQuery.of(context).size.width;

    items.clear(); // Clear previous items before updating

    for (final backpackItem in backpackItems.entries) {
      final item = context.read<RulesCubit>().getItem(backpackItem.key);
      if (item != null) {
        final Map<String, dynamic> typedItem = Map<String, dynamic>.from(item);

        if (applyFilter(
          typedItem,
          filterCriteria,
          backpackItem.value['isEquipped'] as bool? ?? false,
        )) {
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
                  horizontal: horizontalPadding,
                  vertical: 8,
                ),
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
        right: horizontalPadding,
        left: horizontalPadding,
        top: 8,
      ),
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
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
                child: Text(
                  'Total Weight: ${getTotalWeight(items, sortedItems)}',
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
        if (backpackItem.value.isEmpty || backpackItem.value['quantity'] == 0) {
          return const SizedBox.shrink();
        }
        final item = Map<String, dynamic>.from(items[backpackItem.key] ?? {});
        if (item.isEmpty) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ItemWidget(
            item: item,
            quantity: int.tryParse(
                  backpackItem.value['quantity']?.toString() ?? '0',
                ) ??
                0,
            onQuantityChange: (quantity) {
              if (quantity == 0) {
                items.remove(backpackItem.key);
              } else {
                (items[backpackItem.key] as Map?)?['quantity'] = quantity;
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
            isEquipped: backpackItem.value['isEquipped'] as bool? ?? false,
            onEquip: (itemKey, isEquipped) {
              items[itemKey]?['isEquipped'] = isEquipped;
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
