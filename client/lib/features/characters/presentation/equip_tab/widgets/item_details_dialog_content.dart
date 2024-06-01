import 'dart:collection';

import 'package:dnd5e_dm_tools/core/config/app_colors.dart';
import 'package:dnd5e_dm_tools/core/util/helper.dart';
import 'package:dnd5e_dm_tools/core/widgets/description_text.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';

class ItemDetailsDialogContent extends StatelessWidget {
  const ItemDetailsDialogContent({
    super.key,
    required this.item,
    this.quantity,
  });

  final Map<String, dynamic> item;
  final int? quantity;

  @override
  Widget build(BuildContext context) {
    final List<dynamic> descs = item['desc'] as List<dynamic>? ?? [];
    final List<String> resultList = [];
    for (int i = 0; i < descs.length; i++) {
      resultList.add(descs[i] as String);
      if (i != descs.length - 1) {
        resultList.add('');
      }
    }

    final String? equipmentCategory =
        (item['equipment_category'] as Map?)?['name'] as String?;
    final String? gearCategory =
        (item['gear_category'] as Map?)?['name'] as String?;
    final String? toolCategory = item['tool_category'] as String?;
    final List<String> labels = [];
    if (equipmentCategory != null) labels.add(equipmentCategory);
    if (gearCategory != null) labels.add(gearCategory);
    if (toolCategory != null) labels.add(toolCategory);
    final String? rarity = (item['rarity'] as Map?)?['name'] as String?;
    final int baseQuantity = item['quantity'] as int? ?? 1;
    final bool isWeapon = item['damage'] != null;
    final bool isArmor = item['armor_class'] != null;
    final Icon icon =
        itemToIcon(item) ?? equipmentTypeToIcon(getEquipmentTypeFromItem(item));
    final double screenWidth = MediaQuery.of(context).size.width;

    return ConstrainedBox(
      constraints:
          BoxConstraints(maxWidth: screenWidth > 800 ? 720 : screenWidth * 0.9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          RichText(
            text: TextSpan(
              children: [
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: icon,
                ),
                TextSpan(
                  text: '  ${item['name']}',
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
          const SizedBox(height: 16),
          Text(
            rarity ?? 'Common',
            style: Theme.of(context)
                .textTheme
                .labelSmall!
                .copyWith(color: rarityToColor(rarity)),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            child: ListBody(
              children: [
                ...descs.map(
                  (desc) => DescriptionText(
                    inputText: desc as String,
                    baseStyle: Theme.of(context).textTheme.bodySmall!,
                    addTabSpace: true,
                  ),
                ),
                if (descs.isNotEmpty)
                  const SizedBox(
                    height: 32,
                    child: Divider(),
                  ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _getItemValue(context, 1, appendGp: true, ignoreBase: true),
                    _getItemWeight(context, 1, ignoreBase: true),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...labels.map(
                        (label) => Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            label,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isWeapon) _getWeaponInfo(context),
                if (isArmor) _getArmorInfo(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getWeaponInfo(BuildContext context) {
    final String categoryRange = item['category_range'] as String? ?? '';
    final List<LinkedHashMap> properties = (item['properties'] as List?)
            ?.map((e) => LinkedHashMap<String, dynamic>.from(e as Map))
            .toList() ??
        [];
    final String rangeNormal =
        (item['range'] as LinkedHashMap?)?['normal']?.toString() ?? '';
    final String? rangeLong =
        (item['range'] as LinkedHashMap?)?['long']?.toString();
    final String damage =
        (item['damage'] as LinkedHashMap?)?['damage_dice'] as String? ?? '';
    final String damageType =
        ((item['damage'] as LinkedHashMap?)?['damage_type']
                as LinkedHashMap?)?['name'] as String? ??
            '';

    return Container(
      padding: const EdgeInsets.all(8.0),
      width: double.infinity,
      child: Card.outlined(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                categoryRange,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 6),
                child: Column(
                  children: properties
                      .map(
                        (prop) => Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            prop['name'] as String,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      )
                      .toList(),
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
    final String armorCategory = item['armor_category'] as String? ?? '';
    final int? minimumStr = item['str_minimum'] as int?;
    final bool stealthDisadvantage =
        item['stealth_disadvantage'] as bool? ?? false;
    final int armorClass = (item['armor_class'] as Map?)?['base'] as int? ?? 0;
    final bool dexBonus =
        (item['armor_class'] as Map?)?['dex_bonus'] as bool? ?? false;

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
    final cost =
        Map<String, dynamic>.from(item['cost'] as LinkedHashMap? ?? {});
    final String costUnit = cost['unit'] as String? ?? 'gp';
    final num costValue = cost['quantity'] as num? ?? 0;
    final int baseQuantity = ignoreBase ? 1 : item['quantity'] as int? ?? 1;

    final num costTotal;
    if (appendGp) {
      costTotal = costValue.toDouble();
    } else {
      costTotal = getCostTotal(costUnit, costValue, quantity / baseQuantity);
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
              if (appendGp) TextSpan(text: ' ${costUnit.toUpperCase()}'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getItemWeight(
    BuildContext context,
    int quantity, {
    bool ignoreBase = false,
  }) {
    final int baseQuantity = item['quantity'] as int? ?? 1;
    final double weight = (item['weight'] as num? ?? 0.0).toDouble() *
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
