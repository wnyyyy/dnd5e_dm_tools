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
    final type = getEquipmentType(
        widget.item['equipment_category']?['index'] ?? 'Unknown');
    final title = (widget.quantity ?? 1) > 1
        ? '${widget.item['name']} x${widget.quantity}'
        : widget.item['name'];

    return ListTile(
      leading: equipmentTypeToIcon(type),
      title: Text(title),
      subtitle: _getItemDescription(context),
      trailing: Checkbox(
        value: isEquipped,
        onChanged: (bool? newValue) {
          if (newValue != null) {
            setState(() {
              isEquipped = newValue;
            });
          }
        },
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
        Text('$weight lbs', style: textStyle),
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
