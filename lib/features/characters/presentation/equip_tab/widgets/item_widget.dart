import 'package:dnd5e_dm_tools/core/config/app_colors.dart';
import 'package:dnd5e_dm_tools/core/data/models/backpack_item.dart';
import 'package:dnd5e_dm_tools/core/data/models/item.dart';
import 'package:dnd5e_dm_tools/core/util/enum.dart';
import 'package:dnd5e_dm_tools/core/util/helper.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/equip_tab/widgets/item_details_dialog.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';

class ItemWidget extends StatefulWidget {
  const ItemWidget({
    super.key,
    required this.backpackItem,
    this.onQuantityChange,
    required this.onEquip,
  });

  final BackpackItem backpackItem;
  final Function(int)? onQuantityChange;
  final Function(String, bool)? onEquip;

  @override
  ItemWidgetState createState() => ItemWidgetState();
}

class ItemWidgetState extends State<ItemWidget> {
  late bool isEquipped;

  @override
  void initState() {
    super.initState();
    isEquipped = widget.backpackItem.isEquipped;
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.backpackItem.item;
    if (item == null) {
      return const SizedBox();
    }
    final quantity = widget.backpackItem.quantity;
    final title = quantity > 1 ? '${item.name} x$quantity' : item.name;
    final equipable = item is Equipable;

    return GestureDetector(
      onTap: () => _onItemTap(context),
      child: ListTile(
        leading: item.icon,
        title: Text(title),
        subtitle: equipable
            ? GestureDetector(
                onTap: () {
                  setState(() {
                    isEquipped = !isEquipped;
                    widget.onEquip?.call(
                      widget.backpackItem.itemSlug,
                      isEquipped,
                    );
                  });
                },
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      child: Checkbox(
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                        value: isEquipped,
                        onChanged: (bool? newValue) {
                          if (newValue != null) {
                            setState(() {
                              isEquipped = newValue;
                              widget.onEquip?.call(
                                widget.backpackItem.itemSlug,
                                isEquipped,
                              );
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isEquipped ? 'Equipped' : 'Not Equipped',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              )
            : GestureDetector(
                onTap: () => _onItemTap(context),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(item.descriptor),
                ),
              ),
        trailing: GestureDetector(
          onTap: () => _onItemTap(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _getItemWeight(context),
              const SizedBox(height: 8),
              _getItemValue(context),
            ],
          ),
        ),
      ),
    );
  }

  void _onItemTap(BuildContext context) {
    final item = widget.backpackItem.item;
    if (item == null) return;
    showDialog(
      context: context,
      builder: (context) {
        return ItemDetailsDialog(
          backpackItem: widget.backpackItem,
          onQuantityChange: widget.onQuantityChange,
          onEquip: widget.onEquip,
        );
      },
    );
  }

  Widget _getItemValue(BuildContext context) {
    final item = widget.backpackItem.item;
    if (item == null) return const SizedBox();
    final cost = item.cost;
    if (cost.quantity <= 0) {
      return const SizedBox();
    }
    final TextStyle textStyle = Theme.of(context).textTheme.bodyMedium!;
    final Color unitColor = item.cost.unit.color;

    return IntrinsicWidth(
      child: Container(
        constraints: const BoxConstraints(minWidth: 80),
        child: RichText(
          text: TextSpan(
            children: [
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Icon(
                  FontAwesome5.coins,
                  size: textStyle.fontSize,
                  color: unitColor,
                ),
              ),
              TextSpan(text: '  ${cost.quantity}', style: textStyle),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getItemWeight(BuildContext context) {
    final item = widget.backpackItem.item;
    if (item == null) return const SizedBox();
    final weight = widget.backpackItem.weight;
    final TextStyle textStyle = Theme.of(context).textTheme.bodyMedium!;
    final bool isInt = weight % 1 == 0;

    if (weight == 0) {
      return const SizedBox();
    }

    return IntrinsicWidth(
      child: Container(
        constraints: const BoxConstraints(minWidth: 80),
        child: RichText(
          text: TextSpan(
            children: [
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Icon(
                  FontAwesome5.weight_hanging,
                  size: textStyle.fontSize,
                  color: textStyle.color,
                ),
              ),
              TextSpan(
                text: '  ${isInt ? weight.toInt() : weight} lb',
                style: textStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
