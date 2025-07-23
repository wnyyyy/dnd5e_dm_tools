import 'package:dnd5e_dm_tools/core/data/models/armor_class.dart';
import 'package:dnd5e_dm_tools/core/data/models/cost.dart';
import 'package:dnd5e_dm_tools/core/data/models/damage.dart';
import 'package:dnd5e_dm_tools/core/data/models/item.dart';
import 'package:dnd5e_dm_tools/core/util/enum.dart';
import 'package:flutter/material.dart';

enum CustomItemType { generic, weapon, armor }

class CustomItemButton extends StatelessWidget {
  const CustomItemButton({super.key, required this.onAdd});
  final void Function(Item) onAdd;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.add),
      label: const Text('Custom item'),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => _CustomItemDialog(onAdd: onAdd),
        );
      },
    );
  }
}

class _CustomItemDialog extends StatefulWidget {
  const _CustomItemDialog({required this.onAdd});
  final void Function(Item) onAdd;

  @override
  State<_CustomItemDialog> createState() => _CustomItemDialogState();
}

class _CustomItemDialogState extends State<_CustomItemDialog> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String descRaw = '';
  int weight = 0;
  int cost = 0;
  CoinType unit = CoinType.gold;
  Rarity rarity = Rarity.common;
  CustomItemType itemType = CustomItemType.generic;

  // Generic
  bool expendable = false;

  // Weapon
  String damageDice = '';
  DamageType damageType = DamageType.slashing;
  WeaponCategory weaponCategory = WeaponCategory.simpleMelee;
  List<WeaponProperty> selectedProperties = [];
  int range = 5;
  int? longRange;

  // Armor
  ArmorCategory armorCategory = ArmorCategory.light;
  int armorClass = 11;
  bool stealthDisadvantage = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return AlertDialog(
      title: const Text('Add Custom Item'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: SizedBox(
            width: screenWidth > 600 ? 600 : screenWidth * 0.9,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypeRadioRow(context),
                const SizedBox(height: 6),
                _buildNameField(context),
                const SizedBox(height: 6),
                _buildDescriptionField(context),
                const SizedBox(height: 6),
                _buildWeightCostRow(context),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildRarity(context),
                    if (itemType == CustomItemType.weapon) ...[
                      ..._buildWeaponFields(context),
                      const SizedBox(height: 6),
                    ],
                    if (itemType == CustomItemType.armor) ...[
                      ..._buildArmorFields(context),
                      const SizedBox(height: 6),
                    ],
                    if (itemType == CustomItemType.generic) ...[
                      _buildExpendable(context),
                      const SizedBox(height: 6),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(onPressed: _onAddPressed, child: const Text('Add')),
      ],
    );
  }

  Widget _buildTypeRadioRow(BuildContext context) {
    final types = [
      (CustomItemType.generic, 'Generic'),
      (CustomItemType.weapon, 'Weapon'),
      (CustomItemType.armor, 'Armor'),
    ];
    return Wrap(
      children: types.map((entry) {
        final type = entry.$1;
        final label = entry.$2;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ChoiceChip(
            label: Text(label),
            labelStyle: Theme.of(context).textTheme.labelSmall,
            selected: itemType == type,
            onSelected: (selected) {
              if (selected) setState(() => itemType = type);
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNameField(BuildContext context) {
    return TextFormField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Name',
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      ),
      style: Theme.of(context).textTheme.bodyMedium,
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
      onChanged: (v) => setState(() => name = v),
    );
  }

  Widget _buildDescriptionField(BuildContext context) {
    return TextFormField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Description',
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      ),
      style: Theme.of(context).textTheme.bodySmall,
      minLines: 2,
      maxLines: 6,
      onChanged: (v) => setState(() => descRaw = v),
    );
  }

  Widget _buildWeightCostRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: 'Weight (lb)',
              labelStyle: Theme.of(context).textTheme.labelSmall,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 12,
              ),
            ),
            keyboardType: TextInputType.number,
            onChanged: (v) => setState(() => weight = int.tryParse(v) ?? 0),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelStyle: Theme.of(context).textTheme.labelSmall,
              labelText: 'Cost',
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 12,
              ),
            ),
            keyboardType: TextInputType.number,
            onChanged: (v) => setState(() => cost = int.tryParse(v) ?? 0),
          ),
        ),
        const SizedBox(width: 4),
        DropdownButton<CoinType>(
          value: unit,
          style: Theme.of(context).textTheme.labelMedium,
          onChanged: (v) => setState(() => unit = v ?? CoinType.gold),
          items: CoinType.values
              .map(
                (c) => DropdownMenuItem(
                  value: c,
                  child: Text(c.symbol.toUpperCase()),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildExpendable(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Checkbox(
            value: expendable,
            onChanged: (v) => setState(() => expendable = v ?? false),
          ),
          const Text('Expendable'),
        ],
      ),
    );
  }

  Widget _buildRarity(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const Text('Rarity'),
          DropdownButton<Rarity>(
            style: Theme.of(context).textTheme.labelLarge,
            value: rarity,
            onChanged: (v) => setState(() => rarity = v ?? Rarity.common),
            items: Rarity.values
                .map((r) => DropdownMenuItem(value: r, child: Text(r.name)))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDamage(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 140),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Dice',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            ),
            onChanged: (v) => setState(() => damageDice = v),
            validator: (v) {
              final value = v?.trim() ?? '';
              final diceRegExp = RegExp(r'^(\d*)d\d+$');
              if (value.isEmpty) return 'Required';
              if (!diceRegExp.hasMatch(value)) return 'Format: XdY';
              return null;
            },
          ),
          DropdownButton<DamageType>(
            style: Theme.of(context).textTheme.labelLarge,
            value: damageType,
            onChanged: (v) =>
                setState(() => damageType = v ?? DamageType.slashing),
            items: DamageType.values
                .map((r) => DropdownMenuItem(value: r, child: Text(r.name)))
                .toList(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildWeaponFields(BuildContext context) {
    return [
      _buildDamage(context),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: DropdownButtonFormField<WeaponCategory>(
          value: weaponCategory,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Weapon Category',
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          ),
          onChanged: (v) =>
              setState(() => weaponCategory = v ?? WeaponCategory.simpleMelee),
          items: WeaponCategory.values
              .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
              .toList(),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Range',
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (v) => setState(() => range = int.tryParse(v) ?? 5),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: TextFormField(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Long Range',
                  labelStyle: Theme.of(context).textTheme.labelSmall,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (v) => setState(() => longRange = int.tryParse(v)),
              ),
            ),
          ],
        ),
      ),
      Card.outlined(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0, left: 4.0, right: 4.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  icon: const Icon(Icons.settings),
                  label: const Text('Weapon Properties'),
                  onPressed: () async {
                    final result = await showDialog<List<WeaponProperty>>(
                      context: context,
                      builder: (context) {
                        final tempSelected = List<WeaponProperty>.from(
                          selectedProperties,
                        );
                        return StatefulBuilder(
                          builder: (context, setDialogState) {
                            return AlertDialog(
                              title: const Text('Select Properties'),
                              content: SizedBox(
                                width: 300,
                                child: ListView(
                                  shrinkWrap: true,
                                  children: WeaponProperty.values
                                      .map(
                                        (prop) => CheckboxListTile(
                                          value: tempSelected.contains(prop),
                                          title: Text(prop.name),
                                          onChanged: (v) {
                                            setDialogState(() {
                                              if (v == true) {
                                                tempSelected.add(prop);
                                              } else {
                                                tempSelected.remove(prop);
                                              }
                                            });
                                          },
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, tempSelected),
                                  child: const Text('Done'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                    if (result != null) {
                      setState(() => selectedProperties = result);
                    }
                  },
                ),
              ),
              if (selectedProperties.isNotEmpty)
                Wrap(
                  spacing: 6,
                  children: selectedProperties
                      .map((p) => Chip(label: Text(p.name)))
                      .toList(),
                ),
            ],
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildArmorFields(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return [
      SizedBox(
        width: screenWidth > 600 ? 200 : screenWidth * 0.3,
        child: Column(
          children: [
            DropdownButtonFormField<ArmorCategory>(
              value: armorCategory,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Armor Category',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
              ),
              onChanged: (v) =>
                  setState(() => armorCategory = v ?? ArmorCategory.light),
              items: ArmorCategory.values
                  .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                  .toList(),
            ),
            const SizedBox(height: 8),
            TextFormField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Armor Class',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) =>
                  setState(() => armorClass = int.tryParse(v) ?? 11),
            ),
          ],
        ),
      ),
      Row(
        children: [
          Checkbox(
            value: stealthDisadvantage,
            onChanged: (v) => setState(() => stealthDisadvantage = v ?? false),
          ),
          const Text('Stealth Disadvantage'),
        ],
      ),
    ];
  }

  void _onAddPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      final descList = descRaw
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      Item customItem;
      if (itemType == CustomItemType.weapon) {
        customItem = Weapon(
          slug: 'custom-${name.trim().toLowerCase().replaceAll(' ', '-')}',
          name: name.trim(),
          itemType:
              (weaponCategory == WeaponCategory.martialRanged ||
                  weaponCategory == WeaponCategory.simpleRanged)
              ? EquipmentType.rangedWeapons
              : EquipmentType.meleeWeapons,
          desc: descList,
          cost: Cost(quantity: cost, unit: unit),
          weight: weight,
          rarity: rarity,
          damage: Damage(dice: damageDice, type: damageType),
          weaponCategory: weaponCategory,
          properties: selectedProperties,
          range: range,
          longRange: longRange,
        );
      } else if (itemType == CustomItemType.armor) {
        int? maxDex;
        final bool dexBonus;
        if (armorCategory == ArmorCategory.medium) {
          maxDex = 2;
          dexBonus = true;
        } else if (armorCategory == ArmorCategory.heavy) {
          dexBonus = false;
        } else {
          maxDex = null;
          dexBonus = true;
        }
        customItem = Armor(
          slug: 'custom-${name.trim().toLowerCase().replaceAll(' ', '-')}',
          name: name.trim(),
          itemType: EquipmentType.armor,
          desc: descList,
          cost: Cost(quantity: cost, unit: unit),
          weight: weight,
          rarity: rarity,
          armorClass: ArmorClass(
            base: armorClass,
            dexterityBonus: dexBonus,
            maxDexterityBonus: maxDex,
          ),
          armorCategory: armorCategory,
          stealthDisadvantage: stealthDisadvantage,
        );
      } else {
        customItem = GenericItem(
          slug: 'custom-${name.trim().toLowerCase().replaceAll(' ', '-')}',
          name: name.trim(),
          itemType: EquipmentType.misc,
          desc: descList,
          cost: Cost(quantity: cost, unit: unit),
          weight: weight,
          expendable: expendable,
          rarity: rarity,
        );
      }
      widget.onAdd(customItem);
      Navigator.of(context).pop();
    }
  }
}
