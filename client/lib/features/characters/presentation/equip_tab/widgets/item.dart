import 'package:dnd5e_dm_tools/core/util/helper.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';

class ItemWidget extends StatelessWidget {
  final Map<String, dynamic> item;
  final int? quantity;
  final bool? isEquipped;

  const ItemWidget(
      {super.key, required this.item, this.quantity, this.isEquipped});

  @override
  Widget build(BuildContext context) {
    final type =
        getEquipmentType(item['equipment_category']?['index'] ?? 'Unknown');
    final title =
        (quantity ?? 1) > 1 ? '${item['name']} x$quantity' : item['name'];
    return ListTile(
      leading: equipmentTypeToIcon(type),
      title: Text(title),
      subtitle: _getItemDescription(context),
      trailing: isEquipped != null
          ? Checkbox(
              value: isEquipped,
              onChanged: (bool? newValue) {
                if (newValue != null) {}
              },
            )
          : null,
      onTap: () => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(item['name']),
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
    final costUnit = item['cost']?['unit'] ?? 'gp';
    final costValue = item['cost']?['quantity'] ?? 0;
    final double costTotal;
    switch (costUnit) {
      case 'cp':
        costTotal = costValue / 100;
        break;
      case 'sp':
        costTotal = costValue / 10;
        break;
      case 'gp':
        costTotal = costValue.toDouble();
        break;
      default:
        costTotal = 0;
    }

    final weight = item['weight'] ?? 0;
    final TextStyle textStyle = Theme.of(context).textTheme.bodyMedium!;

    TextSpan valueSpan;
    if (costTotal > 0) {
      valueSpan = TextSpan(
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
          TextSpan(
            text: ' $weight lbs',
            style: textStyle,
          )
        ],
      );
    } else {
      valueSpan = TextSpan(text: '$weight lbs', style: textStyle);
    }

    return RichText(
      text: TextSpan(
        children: [valueSpan],
      ),
    );
  }
}
