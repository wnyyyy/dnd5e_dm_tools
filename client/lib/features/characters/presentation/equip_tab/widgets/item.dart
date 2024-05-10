import 'package:dnd5e_dm_tools/core/util/helper.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';

class ItemWidget extends StatefulWidget {
  final Map<String, dynamic> item;
  final int? quantity;
  final bool? isEquipped;

  const ItemWidget(
      {super.key, required this.item, this.quantity, this.isEquipped});

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
    final type = getEquipmentTypeFromItem(widget.item);
    final title = (widget.quantity ?? 1) > 1
        ? '${widget.item['name']} x${widget.quantity}'
        : widget.item['name'];

    final equipable =
        widget.item['armor_class'] != null || widget.item['damage'] != null;

    return ListTile(
      leading: equipmentTypeToIcon(type),
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: _getItemDescription(context),
          ),
          equipable
              ? Row(
                  children: [
                    Checkbox(
                      value: isEquipped,
                      onChanged: (bool? newValue) {
                        if (newValue != null) {
                          setState(() {
                            isEquipped = newValue;
                          });
                        }
                      },
                    ),
                    Text(isEquipped ? 'Equipped' : 'Not Equipped')
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(getItemDescriptor(widget.item)),
                ),
        ],
      ),
      onTap: () => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(widget.item['name']),
          content: const Text('Detailed info about the item.'),
          actions: [
            TextButton(
              child: const Icon(Icons.done),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getItemDescription(BuildContext context) {
    final costUnit = widget.item['cost']?['unit'] ?? 'gp';
    final costValue = widget.item['cost']?['quantity'] ?? 0;
    final weight = widget.item['weight'] ?? 0;

    final double costTotal = _getCostTotal(costUnit, costValue);
    final TextStyle textStyle = Theme.of(context).textTheme.bodyMedium!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RichText(
          text: TextSpan(
            text: '${costTotal.toStringAsFixed(2)} ',
            style: textStyle,
            children: [
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Icon(
                  FontAwesome5.coins,
                  size: textStyle.fontSize,
                  color: textStyle.color,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              FontAwesome5.weight_hanging,
              size: textStyle.fontSize,
              color: textStyle.color,
            ),
            const SizedBox(width: 4),
            Text('$weight lbs', style: textStyle),
          ],
        ),
      ],
    );
  }

  double _getCostTotal(String costUnit, int costValue) {
    switch (costUnit) {
      case 'cp':
        return costValue / 100;
      case 'sp':
        return costValue / 10;
      case 'gp':
        return costValue.toDouble();
      default:
        return 0;
    }
  }
}
