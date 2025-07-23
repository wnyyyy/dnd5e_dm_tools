
import 'package:dnd5e_dm_tools/core/data/models/backpack_item.dart';
import 'package:dnd5e_dm_tools/core/data/models/item.dart';
import 'package:dnd5e_dm_tools/core/util/enum.dart';
import 'package:dnd5e_dm_tools/core/widgets/description_text.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';

class ItemDetailsDialogContent extends StatelessWidget {
  const ItemDetailsDialogContent({super.key, required this.backpackItem});

  final BackpackItem backpackItem;

  @override
  Widget build(BuildContext context) {
    final List<String> resultList = [];
    final item = backpackItem.item;
    if (item == null) {
      return const SizedBox();
    }
    for (int i = 0; i < item.desc.length; i++) {
      resultList.add(item.desc[i]);
      if (i != item.desc.length - 1) {
        resultList.add('');
      }
    }

    final descStr = item.desc.join('\n\n');

    final List<String> labels = [];
    labels.add(item.descriptor);

    final bool isWeapon = item is Weapon;
    final bool isArmor = item is Armor;
    final double screenWidth = MediaQuery.of(context).size.width;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: screenWidth > 800 ? 720 : screenWidth * 0.9,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          RichText(
            text: TextSpan(
              children: [
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: item.icon,
                ),
                TextSpan(
                  text: '  ${item.name}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                if (backpackItem.quantity > 1)
                  TextSpan(
                    text: ' (x${backpackItem.quantity})',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            item.rarity.name,
            style: Theme.of(
              context,
            ).textTheme.labelSmall!.copyWith(color: item.rarity.color),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            child: ListBody(
              children: [
                DescriptionText(
                  inputText: descStr,
                  baseStyle: Theme.of(context).textTheme.bodyMedium!,
                ),
                if (item.desc.isNotEmpty)
                  const SizedBox(height: 32, child: Divider()),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [_getItemValue(context), _getItemWeight(context)],
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
    if (backpackItem.item == null || backpackItem.item is! Weapon) {
      return const SizedBox();
    }
    final Weapon weapon = backpackItem.item! as Weapon;
    var rangeStr = weapon.range.toString();
    if (weapon.longRange != null) {
      rangeStr += '/${weapon.longRange}';
    }

    return Container(
      padding: const EdgeInsets.all(8.0),
      width: double.infinity,
      child: Card.outlined(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                weapon.weaponCategory.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 6),
                child: Column(
                  children: weapon.properties
                      .map(
                        (prop) => Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            prop.name,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 12, child: Divider()),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Damage: ${weapon.damage.dice} ${weapon.damage.type.name}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Range: $rangeStr ft',
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

  Widget _getArmorInfo(BuildContext context) {
    if (backpackItem.item == null || backpackItem.item is! Armor) {
      return const SizedBox();
    }
    final Armor armor = backpackItem.item! as Armor;
    final dexBonusStr = armor.armorClass.dexterityBonus
        ? (armor.armorClass.maxDexterityBonus == null
              ? 'Yes'
              : 'Up to ${armor.armorClass.maxDexterityBonus}')
        : 'No';

    return Container(
      padding: const EdgeInsets.all(8.0),
      width: double.infinity,
      child: Card.outlined(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                armor.armorCategory.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (armor.stealthDisadvantage)
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
                        'Armor Class: ${armor.armorClass.base}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    if (armor.armorClass.dexterityBonus)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          'Dex Bonus: $dexBonusStr',
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

  Widget _getItemValue(BuildContext context) {
    final TextStyle textStyle = Theme.of(context).textTheme.bodyMedium!;
    final Color? unitColor = backpackItem.item?.cost.unit.color;
    final costCP = backpackItem.item?.cost.costCP ?? 0;
    if (costCP <= 0) {
      return const SizedBox();
    }
    final costNormal = backpackItem.item?.cost.costNormalized;

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
                  color: unitColor ?? textStyle.color,
                ),
              ),
              TextSpan(text: '  ${costNormal?.quantity}', style: textStyle),
              TextSpan(text: ' ${costNormal?.unit.symbol.toUpperCase()}'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getItemWeight(BuildContext context) {
    final num weight = backpackItem.weight;
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
                text:
                    '  ${isInt ? weight.toInt() : weight.toStringAsFixed(1)} lb',
                style: textStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
