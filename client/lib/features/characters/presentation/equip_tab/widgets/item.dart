import 'package:dnd5e_dm_tools/core/config/app_colors.dart';
import 'package:dnd5e_dm_tools/core/util/helper.dart';
import 'package:dnd5e_dm_tools/core/widgets/description_text.dart';
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

    final equipable = isEquipable(widget.item);

    return GestureDetector(
      onLongPress: () => _onItemTap(context),
      child: ListTile(
        leading: GestureDetector(
          onTap: () => _onItemTap(context),
          child: equipmentTypeToIcon(type),
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
            : Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(getItemDescriptor(widget.item)),
              ),
        trailing: GestureDetector(
          onTap: () => _onItemTap(context),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
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

  void _onItemTap(context) {
    final descs = widget.item['desc'] ?? [];
    final equipmentCategory = widget.item['equipment_category']?['name'];
    final gearCategory = widget.item['gear_category']?['name'];
    final toolCategory = widget.item['tool_category'];
    final labels = [];
    if (equipmentCategory != null) labels.add(equipmentCategory);
    if (gearCategory != null) labels.add(gearCategory);
    if (toolCategory != null) labels.add(toolCategory);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.item['name']),
        content: Column(
          children: [
            for (final desc in descs)
              DescriptionText(
                inputText: desc,
                baseStyle: Theme.of(context).textTheme.bodySmall!,
                addTabSpace: true,
              ),
            if (!descs.isEmpty)
              const SizedBox(
                height: 32,
                child: Divider(),
              ),
            Flex(
              direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _getItemValue(context, 1, appendGp: true),
                _getItemWeight(context, 1),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final label in labels)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        label,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Icon(Icons.done),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _getItemValue(
    BuildContext context,
    int quantity, {
    bool appendGp = false,
  }) {
    final costUnit = widget.item['cost']?['unit'] ?? 'gp';
    final costValue = widget.item['cost']?['quantity'] ?? 0;

    final double costTotal;
    if (appendGp) {
      costTotal = costValue.toDouble();
    } else {
      costTotal = _getCostTotal(costUnit, costValue, quantity);
    }
    final TextStyle textStyle = Theme.of(context).textTheme.bodyMedium!;
    final Color unitColor = costUnit == 'gp'
        ? Theme.of(context).goldColor
        : costUnit == 'sp'
            ? Theme.of(context).silverColor
            : Theme.of(context).copperColor;

    return RichText(
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
            text: '  ${costTotal.toStringAsFixed(appendGp ? 0 : 2)} ',
            style: textStyle,
          ),
          if (appendGp) TextSpan(text: costUnit.toString().toUpperCase()),
        ],
      ),
    );
  }

  Widget _getItemWeight(BuildContext context, int quantity) {
    final weight = (widget.item['weight'] ?? 0) * quantity;
    final TextStyle textStyle = Theme.of(context).textTheme.bodyMedium!;

    return RichText(
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
            text: '  $weight lbs',
            style: textStyle,
          )
        ],
      ),
    );
  }

  double _getCostTotal(String costUnit, int costValue, int quantity) {
    switch (costUnit) {
      case 'cp':
        return costValue / 100 * quantity;
      case 'sp':
        return costValue / 10 * quantity;
      case 'gp':
        return costValue.toDouble() * quantity;
      default:
        return 0;
    }
  }
}
