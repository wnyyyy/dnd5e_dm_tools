import 'package:dnd5e_dm_tools/core/config/app_colors.dart';
import 'package:dnd5e_dm_tools/core/util/helper.dart';
import 'package:dnd5e_dm_tools/core/widgets/description_text.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';

class ItemWidget extends StatefulWidget {
  final Map<String, dynamic> item;
  final int? quantity;
  final bool? isEquipped;
  final Function(String, bool)? onEquip;

  const ItemWidget({
    super.key,
    required this.item,
    this.quantity,
    this.isEquipped,
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
            : Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(getItemDescriptor(widget.item)),
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

  void _onItemTap(context) {
    var descs = widget.item['desc'] ?? [];
    List<String> resultList = [];
    for (int i = 0; i < descs.length; i++) {
      resultList.add(descs[i]);
      if (i != descs.length - 1) {
        resultList.add('');
      }
    }
    descs = resultList;

    final equipmentCategory = widget.item['equipment_category']?['name'];
    final gearCategory = widget.item['gear_category']?['name'];
    final toolCategory = widget.item['tool_category'];
    final labels = [];
    if (equipmentCategory != null) labels.add(equipmentCategory);
    if (gearCategory != null) labels.add(gearCategory);
    if (toolCategory != null) labels.add(toolCategory);
    final rarity = widget.item['rarity']?['name'];
    final baseQuantity = widget.item['quantity'] ?? 1;
    final isWeapon = widget.item['damage'] != null;
    final isArmor = widget.item['armor_class'] != null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: equipmentTypeToIcon(
                          getEquipmentTypeFromItem(widget.item)),
                    ),
                    TextSpan(
                      text: '  ${widget.item['name']}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    if (baseQuantity > 1)
                      TextSpan(
                        text: ' (x$baseQuantity)',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                rarity ?? 'Common',
                style: Theme.of(context)
                    .textTheme
                    .labelSmall!
                    .copyWith(color: rarityToColor(rarity)),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                ...descs
                    .map((desc) => DescriptionText(
                          inputText: desc,
                          baseStyle: Theme.of(context).textTheme.bodySmall!,
                          addTabSpace: true,
                        ))
                    .toList(),
                if (descs.isNotEmpty)
                  const SizedBox(
                    height: 32,
                    child: Divider(),
                  ),
                Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _getItemValue(context, 1, appendGp: true, ignoreBase: true),
                    _getItemWeight(context, 1, ignoreBase: true),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...labels.map((label) => Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              label,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          )),
                    ],
                  ),
                ),
                if (isWeapon) _getWeaponInfo(context),
                if (isArmor) _getArmorInfo(context),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Icon(Icons.done),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Widget _getWeaponInfo(BuildContext context) {
    final categoryRange = widget.item['category_range'] ?? '';
    final properties = widget.item['properties'] ?? [];
    final rangeNormal = widget.item['range']?['normal'] ?? '';
    final rangeLong = widget.item['range']?['long'];
    final damage = widget.item['damage']?['damage_dice'] ?? '';
    final damageType = widget.item['damage']?['damage_type']?['name'] ?? '';

    return Container(
      padding: const EdgeInsets.all(8.0),
      width: double.infinity,
      child: Card.outlined(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(categoryRange,
                  style: Theme.of(context).textTheme.titleMedium),
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 6),
                child: Column(
                  children: [
                    for (final prop in properties)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          prop['name'],
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(
                height: 12,
                child: Divider(),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Damage: $damage $damageType',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Range: $rangeNormal ft',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    if (rangeLong != null)
                      Text(
                        'Long Range: $rangeLong ft',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getArmorInfo(BuildContext context) {
    final armorCategory = widget.item['armor_category'] ?? '';
    final minimumStr = widget.item['str_minimum'];
    final stealthDisadvantage = widget.item['stealth_disadvantage'] ?? false;
    final armorClass = widget.item['armor_class']?['base'] ?? 0;
    final dexBonus = widget.item['armor_class']?['dex_bonus'] ?? false;

    return Container(
      padding: const EdgeInsets.all(8.0),
      width: double.infinity,
      child: Card.outlined(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                armorCategory,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (minimumStr != null && minimumStr > 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          'Minimum Strength: $minimumStr',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    if (stealthDisadvantage)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          'Has Stealth Disadvantage',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        'Armor Class: $armorClass',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        'Dex Bonus: ${dexBonus ? 'Yes' : 'No'}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
