import 'dart:async';
import 'dart:math';

import 'package:dnd5e_dm_tools/core/data/models/backpack.dart';
import 'package:dnd5e_dm_tools/core/data/models/backpack_item.dart';
import 'package:dnd5e_dm_tools/core/data/models/item.dart';
import 'package:dnd5e_dm_tools/core/util/enum.dart';
import 'package:dnd5e_dm_tools/core/util/logger.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character/character_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character/character_state.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/equipment/equipment_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/equipment/equipment_event.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/equipment/equipment_state.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/equip_tab/widgets/add_item_button.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/equip_tab/widgets/coins_widget.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/equip_tab/widgets/item_widget.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_cubit.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_state.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

class BackpackWidget extends StatefulWidget {
  const BackpackWidget({
    super.key,
    required this.backpack,
    required this.onBackpackUpdated,
  });
  final Backpack backpack;
  final ValueChanged<Backpack> onBackpackUpdated;

  @override
  State<BackpackWidget> createState() => _BackpackWidgetState();
}

class _BackpackWidgetState extends State<BackpackWidget> {
  EquipSort sortCriteria = EquipSort.type;
  EquipFilter filterCriteria = EquipFilter.all;
  Map<String, Map<String, dynamic>> items = {};

  @override
  void initState() {
    super.initState();
    sortCriteria = context.read<SettingsCubit>().state.selectedEquipSort;
    filterCriteria = context.read<SettingsCubit>().state.selectedEquipFilter;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EquipmentBloc>().state;
    final charState = context.watch<CharacterBloc>().state;
    if (state is! EquipmentLoaded || charState is! CharacterLoaded) {
      return const SizedBox.shrink();
    }
    final screenWidth = MediaQuery.of(context).size.width;
    final items = state.backpack.items;

    var corrupt = false;
    for (final backpackItem in items) {
      if (backpackItem.item == null) {
        logUI(
          'Backpack item ${backpackItem.itemSlug} is invalid or missing. Updating backpack.',
          level: Level.warning,
        );
        corrupt = true;
        break;
      }
    }
    if (corrupt) {
      final character = charState.character;
      context.read<EquipmentBloc>().add(
        BuildBackpack(
          character: character.copyWith(
            backpack: character.backpack.copyWith(
              items: items.where((item) => item.item != null).toList(),
            ),
          ),
        ),
      );
      return const Center(child: CircularProgressIndicator());
    }

    final filteredItems = items
        .where((item) => applyFilter(item, filterCriteria))
        .toList();
    final sortedItems = sortItems(filteredItems, sortCriteria);

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth > 900;
        final double horizontalPadding = isWide ? screenWidth * 0.1 : 16;

        return Column(
          children: [
            _buildFilters(horizontalPadding, isWide),
            Expanded(
              child: Card(
                margin: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 8,
                ),
                child: isWide
                    ? _buildWideLayout(context, sortedItems)
                    : _buildNarrowLayout(context, sortedItems),
              ),
            ),
          ],
        );
      },
    );
  }

  List<DropdownMenuItem<EquipSort>> get dropdownItems {
    return [
      const DropdownMenuItem(value: EquipSort.type, child: Text('Type')),
      const DropdownMenuItem(value: EquipSort.name, child: Text('Name')),
      const DropdownMenuItem(value: EquipSort.value, child: Text('Value')),
      const DropdownMenuItem(
        value: EquipSort.canEquip,
        child: Text('Can Equip'),
      ),
    ];
  }

  Widget buildAddItemButton(BuildContext context) {
    final rulesState = context.watch<RulesCubit>().state;
    if (rulesState is! RulesStateLoaded) {
      return const SizedBox.shrink();
    }
    return AddItemButton(
      onAdd: (item) {
        if (item is GenericItem) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            showDialog(
              context: context,
              builder: (BuildContext contextNew) {
                return _buildQuantityDialog(contextNew, item);
              },
            );
          });
        } else {
          _addItemToBackpack(context, item, 1);
        }
      },
      onCreateItem: (item) {
        context.read<EquipmentBloc>().add(
          CreateCustomItem(item: item, currentBackpack: widget.backpack),
        );
        context.read<RulesCubit>().reloadRule('items');
        Navigator.pop(context);
      },
    );
  }

  AlertDialog _buildQuantityDialog(BuildContext context, Item item) {
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
              decoration: const InputDecoration(border: OutlineInputBorder()),
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
            _addItemToBackpack(context, item, quantity);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  void _addItemToBackpack(
    BuildContext context,
    Item item,
    int quantity, {
    bool isEquipped = false,
  }) {
    final backpackItems = widget.backpack.items;
    var currBackpackItem = backpackItems.firstWhere(
      (currItem) => currItem.itemSlug == item.slug,
      orElse: () {
        final backpackItem = BackpackItem(
          itemSlug: item.slug,
          item: item,
          quantity: quantity,
          isEquipped: isEquipped,
        );
        backpackItems.add(backpackItem);
        return backpackItem;
      },
    );
    currBackpackItem = currBackpackItem.copyWith(
      quantity: currBackpackItem.quantity + quantity,
      isEquipped: isEquipped,
    );
    widget.onBackpackUpdated(widget.backpack.copyWith(items: backpackItems));
  }

  bool applyFilter(BackpackItem backpackItem, EquipFilter filter) {
    switch (filter) {
      case EquipFilter.all:
        return true;
      case EquipFilter.equipped:
        return backpackItem.isEquipped;
      case EquipFilter.canEquip:
        return backpackItem.item is Equipable && backpackItem.isEquipped;
    }
  }

  List<BackpackItem> sortItems(
    List<BackpackItem> backpackItems,
    EquipSort criteria,
  ) {
    final sorted = List<BackpackItem>.from(backpackItems);
    switch (criteria) {
      case EquipSort.name:
        sorted.sort(
          (a, b) => (a.item?.name ?? '').toLowerCase().compareTo(
            (b.item?.name ?? '').toLowerCase(),
          ),
        );
      case EquipSort.value:
        sorted.sort(
          (b, a) =>
              a.item?.cost.costCP.compareTo(b.item?.cost.costCP ?? 0) ?? 0,
        );
      case EquipSort.canEquip:
        sorted.sort((a, b) {
          final aEquip = a.item is Equipable;
          final bEquip = b.item is Equipable;
          if (aEquip && !bEquip) return -1;
          if (!aEquip && bEquip) return 1;
          return 0;
        });
      case EquipSort.type:
        sorted.sort((a, b) {
          final aType = a.item?.itemType;
          final bType = b.item?.itemType;
          if (aType == bType) return 0;
          if (aType == null) return 1;
          if (bType == null) return -1;
          return aType.name.compareTo(bType.name);
        });
    }
    return sorted;
  }

  Widget _buildFilters(double horizontalPadding, bool wide) {
    return Padding(
      padding: EdgeInsets.only(
        right: horizontalPadding,
        left: horizontalPadding,
        top: 8,
      ),
      child: Flex(
        direction: wide ? Axis.horizontal : Axis.vertical,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: wide
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8.0,
            children: [
              ChoiceChip(
                label: const Text('All Items'),
                selected: filterCriteria == EquipFilter.all,
                onSelected: (bool selected) {
                  setState(() {
                    filterCriteria = EquipFilter.all;
                  });
                  context.read<SettingsCubit>().toggleEquipFilter(
                    EquipFilter.all,
                  );
                },
              ),
              ChoiceChip(
                label: const Text('Equipped'),
                selected: filterCriteria == EquipFilter.equipped,
                onSelected: (bool selected) {
                  setState(() {
                    filterCriteria = EquipFilter.equipped;
                  });
                  context.read<SettingsCubit>().toggleEquipFilter(
                    EquipFilter.equipped,
                  );
                },
              ),
              ChoiceChip(
                label: const Text('Can Equip'),
                selected: filterCriteria == EquipFilter.canEquip,
                onSelected: (bool selected) {
                  setState(() {
                    filterCriteria = EquipFilter.canEquip;
                    context.read<SettingsCubit>().toggleEquipFilter(
                      EquipFilter.canEquip,
                    );
                  });
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: DropdownButton<EquipSort>(
              value: sortCriteria,
              items: dropdownItems,
              onChanged: (EquipSort? value) {
                setState(() {
                  sortCriteria = value ?? EquipSort.type;
                  context.read<SettingsCubit>().toggleEquipSort(
                    value ?? EquipSort.type,
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWideLayout(
    BuildContext context,
    List<BackpackItem> sortedItems,
  ) {
    return Row(
      children: [
        Expanded(flex: 3, child: _buildItemList(sortedItems)),
        const VerticalDivider(),
        SizedBox(
          width: 200,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: CoinsWidget(onBackpackUpdated: widget.onBackpackUpdated),
              ),
              buildAddItemButton(context),
              if (widget.backpack.totalWeight > 0)
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    top: 8.0,
                    bottom: 8.0,
                  ),
                  child: Text(
                    'Total Weight: ${widget.backpack.totalWeight.toStringAsFixed(1)} lbs',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(
    BuildContext context,
    List<BackpackItem> sortedItems,
  ) {
    final weightIsInt = widget.backpack.totalWeight % 1 == 0;
    final weightStr = weightIsInt
        ? widget.backpack.totalWeight.toStringAsFixed(0)
        : widget.backpack.totalWeight.toStringAsFixed(1);
    return Column(
      children: [
        Expanded(child: _buildItemList(sortedItems)),
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
              child: CoinsWidget(onBackpackUpdated: widget.onBackpackUpdated),
            ),
            const SizedBox(width: 8, height: 80, child: VerticalDivider()),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: buildAddItemButton(context),
              ),
            ),
          ],
        ),
        if (widget.backpack.totalWeight > 0)
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    top: 8.0,
                    bottom: 8.0,
                  ),
                  child: Text(
                    'Total Weight: $weightStr lbs',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  ListView _buildItemList(List<BackpackItem> sortedItems) {
    return ListView.separated(
      itemCount: sortedItems.length,
      itemBuilder: (context, index) {
        final backpackItem = sortedItems.elementAt(index);
        if (backpackItem.item == null || backpackItem.quantity == 0) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ItemWidget(
            backpackItem: backpackItem,
            onQuantityChange: (quantity) {
              if (quantity == 0) {
                final updatedBackpack = widget.backpack.removeBySlug(
                  backpackItem.itemSlug,
                );
                widget.onBackpackUpdated(updatedBackpack);
              } else {
                final updatedItems = widget.backpack.items.map((item) {
                  if (item.itemSlug == backpackItem.itemSlug) {
                    return item.copyWith(quantity: quantity);
                  }
                  return item;
                }).toList();
                final updatedBackpack = widget.backpack.copyWith(
                  items: updatedItems,
                );
                widget.onBackpackUpdated(updatedBackpack);
              }
            },
            onEquip: (itemSlug, isEquipped) {
              final updatedItems = widget.backpack.items.map((item) {
                if (item.itemSlug == itemSlug) {
                  return item.copyWith(isEquipped: isEquipped);
                }
                return item;
              }).toList();
              final updatedBackpack = widget.backpack.copyWith(
                items: updatedItems,
              );
              widget.onBackpackUpdated(updatedBackpack);
            },
          ),
        );
      },
      separatorBuilder: (context, index) =>
          const SizedBox(child: Divider(height: 0)),
    );
  }
}
