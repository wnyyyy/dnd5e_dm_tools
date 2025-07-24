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
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Icon(
                      item.icon.icon,
                      size: 26,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                TextSpan(
                  text: item.name,
                  style: item.name.length > 20
                      ? Theme.of(context).textTheme.titleLarge
                      : Theme.of(context).textTheme.headlineSmall,
                ),
                if (backpackItem.quantity > 1)
                  TextSpan(
                    text: ' (x${backpackItem.quantity})',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (item.rarity != Rarity.common)
                  Text(
                    item.rarity.name,
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge!.copyWith(color: item.rarity.color),
                  ),
                const SizedBox(height: 4),
                Text(
                  item.descriptor,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
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
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [_getItemValue(context), _getItemWeight(context)],
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
    final versatile = weapon.properties.any(
      (prop) => prop == WeaponProperty.versatile,
    );

    return Container(
      padding: const EdgeInsets.all(8.0),
      width: double.infinity,
      child: Card.outlined(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 8.0,
            bottom: 8.0,
          ),
          child: Column(
            children: [
              Text(
                weapon.weaponCategory.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 6),
                child: Wrap(
                  spacing: 6,
                  children: weapon.properties
                      .map(
                        (prop) => Chip(
                          labelPadding: EdgeInsets.zero,
                          labelStyle: Theme.of(context).textTheme.labelSmall,
                          visualDensity: VisualDensity.compact,
                          label: Text(prop.name),
                        ),
                      )
                      .toList(),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Text(
                          'Damage: ${weapon.damage.dice} ${weapon.damage.type.name}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        if (versatile && weapon.twoHandedDamage != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(
                              'Two-Handed: ${weapon.twoHandedDamage?.dice}',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
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
    final costTotal = (costNormal?.quantity ?? 1) * backpackItem.quantity;

    return RichText(
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
          TextSpan(text: '  $costTotal', style: textStyle),
          TextSpan(
            text: ' ${costNormal?.unit.symbol.toUpperCase()}',
            style: textStyle,
          ),
        ],
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
            text: '  ${isInt ? weight.toInt() : weight.toStringAsFixed(1)} lb',
            style: textStyle,
          ),
        ],
      ),
    );
  }
}
