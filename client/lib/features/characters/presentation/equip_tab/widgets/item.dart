import 'package:dnd5e_dm_tools/core/config/app_colors.dart';
import 'package:dnd5e_dm_tools/core/util/helper.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'item_details_dialog.dart';

class ItemWidget extends StatefulWidget {
  final Map<String, dynamic> item;
  final int? quantity;
  final bool? isEquipped;
  final Function(String, bool)? onEquip;
  final Function(int)? onQuantityChange;

  const ItemWidget({
    super.key,
    required this.item,
    this.quantity,
    this.isEquipped,
    this.onQuantityChange,
    required this.onEquip,
  });

  @override
  ItemWidgetState createState() => ItemWidgetState();
}

class ItemWidgetState extends State<ItemWidget> {
  late bool isEquipped;

  @override
  void initState() {
    super.initState();
    isEquipped = widget.isEquipped ?? false;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.item.isEmpty) {
      return const SizedBox();
    }
    final type = getEquipmentTypeFromItem(widget.item);
    final title = (widget.quantity ?? 1) > 1
        ? '${widget.item['name'] ?? ''} x${widget.quantity}'
        : widget.item['name'] ?? '';

    final equipable = isEquipable(widget.item);

    return GestureDetector(
      onLongPress: () => _onItemTap(context),
      child: ListTile(
        leading: GestureDetector(
          onTap: () => _onItemTap(context),
          child: itemToIcon(widget.item) ?? equipmentTypeToIcon(type),
        ),
        title: GestureDetector(
          onTap: () => _onItemTap(context),
          child: Text(title),
        ),
        subtitle: equipable
            ? GestureDetector(
                onTap: () {
                  setState(() {
                    isEquipped = !isEquipped;
                    widget.onEquip?.call(widget.item['index'], isEquipped);
                  });
                },
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      child: Checkbox(
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                        value: widget.isEquipped,
                        onChanged: (bool? newValue) {
                          if (newValue != null) {
                            setState(() {
                              isEquipped = newValue;
                              widget.onEquip
                                  ?.call(widget.item['index'], isEquipped);
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(isEquipped ? 'Equipped' : 'Not Equipped',
                        style: Theme.of(context).textTheme.labelSmall)
                  ],
                ),
              )
            : GestureDetector(
                onTap: () => _onItemTap(context),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(getItemDescriptor(widget.item)),
                ),
              ),
        trailing: GestureDetector(
          onTap: () => _onItemTap(context),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _getItemWeight(context, widget.quantity ?? 1),
              const SizedBox(height: 8),
              _getItemValue(context, widget.quantity ?? 1),
            ],
          ),
        ),
      ),
    );
  }

  void _onItemTap(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return ItemDetailsDialog(
          item: widget.item,
          quantity: widget.quantity,
          onQuantityChange: widget.onQuantityChange,
          isEquipped: isEquipped,
          onEquip: widget.onEquip,
        );
      },
    );
  }

  Widget _getItemValue(
    BuildContext context,
    int quantity, {
    bool appendGp = false,
    bool ignoreBase = false,
  }) {
    final costUnit = widget.item['cost']?['unit'] ?? 'gp';
    final costValue = widget.item['cost']?['quantity'] ?? 0;
    final baseQuantity = ignoreBase ? 1 : widget.item['quantity'] ?? 1;

    final double costTotal;
    if (appendGp) {
      costTotal = costValue.toDouble();
    } else {
      costTotal = _getCostTotal(costUnit, costValue, quantity / baseQuantity);
    }
    final bool isInt = costTotal % 1 == 0;

    final TextStyle textStyle = Theme.of(context).textTheme.bodyMedium!;
    final Color unitColor = costUnit == 'gp'
        ? Theme.of(context).goldColor
        : costUnit == 'sp'
            ? Theme.of(context).silverColor
            : Theme.of(context).copperColor;
    if (costTotal == 0) {
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
                  FontAwesome5.coins,
                  size: textStyle.fontSize,
                  color: appendGp ? unitColor : textStyle.color,
                ),
              ),
              TextSpan(
                text:
                    '  ${isInt ? costTotal.toInt() : costTotal.toStringAsFixed(appendGp ? 0 : 2)}',
                style: textStyle,
              ),
              if (appendGp)
                TextSpan(text: ' ${costUnit.toString().toUpperCase()}'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getItemWeight(BuildContext context, int quantity,
      {bool ignoreBase = false}) {
    final baseQuantity = widget.item['quantity'] ?? 1;
    final weight = (widget.item['weight'] ?? 0.0).toDouble() *
        quantity /
        (ignoreBase ? 1 : baseQuantity);
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
              )
            ],
          ),
        ),
      ),
    );
  }

  double _getCostTotal(String costUnit, int costValue, double quantity) {
    switch (costUnit) {
      case 'cp':
        return costValue.toDouble() / 100.0 * quantity;
      case 'sp':
        return costValue.toDouble() / 10.0 * quantity;
      case 'gp':
        return costValue.toDouble() * quantity;
      default:
        return 0;
    }
  }
}
