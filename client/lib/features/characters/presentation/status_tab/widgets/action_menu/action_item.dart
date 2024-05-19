import 'package:dnd5e_dm_tools/core/util/enum.dart';
import 'package:dnd5e_dm_tools/core/util/helper.dart';
import 'package:dnd5e_dm_tools/core/widgets/description_text.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/equip_tab/widgets/item.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/equip_tab/widgets/item_details_dialog.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/equip_tab/widgets/item_details_dialog_content.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/status_tab/widgets/action_menu/add_action.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ActionItem extends StatelessWidget {
  final Map<String, dynamic> action;
  final String actionSlug;
  final Map<String, dynamic> character;
  final String characterSlug;
  final bool isEditMode;
  final Function(Map<String, Map<String, dynamic>>) onActionsChanged;
  final Function(Map<String, dynamic>)? onUse;

  const ActionItem({
    super.key,
    required this.action,
    required this.actionSlug,
    required this.character,
    required this.characterSlug,
    required this.isEditMode,
    required this.onActionsChanged,
    this.onUse,
  });

  @override
  Widget build(BuildContext context) {
    bool canUse = true;
    bool usable = false;
    final ActionMenuMode type = ActionMenuMode.values.firstWhere(
        (e) => e.name == action['type'],
        orElse: () => ActionMenuMode.all);
    final requiresResource = (action['requires_resource'] ?? false) as bool;
    final usedCount = action['used_count'] ?? 0;
    final remaining = (action['resource_count'] ?? 1) - usedCount;
    final mustEquip = action['must_equip'] ?? false;
    switch (type) {
      case ActionMenuMode.abilities:
        if (requiresResource) {
          canUse = remaining > 0;
          usable = true;
        }
        break;
      case ActionMenuMode.items:
        final backpackItem = getBackpackItem(character, action['item']);
        canUse = mustEquip ? backpackItem['isEquipped'] ?? false : true;
        canUse = canUse && (backpackItem['quantity'] ?? 0) > 0;
        if (action['expendable'] ?? false) {
          usable = true;
        }
        if (action['ammo']?.toString().isNotEmpty ?? false) {
          usable = true;
        }
        break;
      default:
        canUse = true;
    }

    String? getAttack() {
      final description = action['description'];
      if (description == null) {
        return null;
      }

      final lastAtkIndex = description.lastIndexOf('Attack:');
      if (lastAtkIndex == -1) {
        return null;
      }

      final atkSubstring = description.substring(lastAtkIndex);
      final preffixStr = atkSubstring.split('\n')[0].split('Attack:')[1].trim();

      try {
        if (preffixStr.isNotEmpty) {
          final atkType = preffixStr.toLowerCase();
          final atk = getAttributeFromPrefix(atkType);
          final mod = getModifier(character['asi'][atk.toLowerCase()]);
          final prof = getProfBonus(character['level']);
          final total = mod + prof;
          final sign = total >= 0 ? '+' : '';
          return '$sign$total to hit';
        }
      } catch (e) {
        return null;
      }

      return null;
    }

    String? getArea() {
      final description = action['description'];
      if (description == null) {
        return null;
      }

      final lastDcIndex = description.lastIndexOf('Area:');
      if (lastDcIndex == -1) {
        return null;
      }

      final dcSubstring = description.substring(lastDcIndex);
      final preffixStr = dcSubstring.split('\n')[0].split('Area:')[1].trim();

      try {
        if (preffixStr.isNotEmpty) {
          return '$preffixStr';
        }
      } catch (e) {
        return null;
      }

      return null;
    }

    String? getSaveDC() {
      final description = action['description'];
      if (description == null) {
        return null;
      }

      final lastDcIndex = description.lastIndexOf('DC:');
      if (lastDcIndex == -1) {
        return null;
      }

      final dcSubstring = description.substring(lastDcIndex);
      final preffixStr = dcSubstring.split('\n')[0].split('DC:')[1].trim();

      try {
        if (preffixStr.isNotEmpty) {
          final attribPreff = preffixStr.split('+')[1].trim();
          final attribute = getAttributeFromPrefix(attribPreff);
          final mod = getModifier(character['asi'][attribute]);
          final prof = getProfBonus(character['level']);
          final total = mod + prof + 8;
          return '$total';
        }
      } catch (e) {
        return null;
      }

      return null;
    }

    String? getDamage() {
      final description = action['description'];
      if (description == null) {
        return null;
      }

      final lastDmgIndex = description.lastIndexOf('Damage:');
      if (lastDmgIndex == -1) {
        return null;
      }

      final dmgSubstring = description.substring(lastDmgIndex);
      final preffixStr = dmgSubstring.split('\n')[0].split('Damage:')[1].trim();

      try {
        if (preffixStr.isNotEmpty) {
          final diceParts = preffixStr.split('d');
          final diceCount = diceParts[0].trim();
          final remaining = diceParts[1].split('+');
          final diceType = remaining[0].trim();
          final hasDamage = remaining.length > 1;

          if (hasDamage) {
            final damageTypePreffix = remaining[1].trim().toLowerCase();
            final damageType = getAttributeFromPrefix(damageTypePreffix);
            final mod = getModifier(character['asi'][damageType.toLowerCase()]);
            final sign = mod >= 0
                ? '+'
                : mod == 0
                    ? ''
                    : '-';
            return '${diceCount}d$diceType $sign ${mod.abs()}';
          }

          return '${diceCount}d$diceType';
        }
      } catch (e) {
        return null;
      }

      return null;
    }

    Widget buildSubtitle(context) {
      List<Widget> children = [];
      switch (type) {
        case ActionMenuMode.abilities:
          if (action['requires_resource']) {
            final String use = remaining == 1 ? 'use' : 'uses';
            children.add(
              Text('$remaining $use',
                  style: Theme.of(context).textTheme.labelMedium),
            );
          }
          String? damage = getDamage();
          String? attack = getAttack();
          String? saveDc = getSaveDC();
          String? area = getArea();
          if (attack != null) {
            children.add(Text('Attack: $attack',
                style: Theme.of(context).textTheme.labelMedium));
          }
          if (damage != null) {
            children.add(Text('Damage: $damage',
                style: Theme.of(context).textTheme.labelMedium));
          }
          if (saveDc != null) {
            children.add(Text('Save DC: $saveDc',
                style: Theme.of(context).textTheme.labelMedium));
          }
          if (area != null) {
            children.add(Text('Area: $area',
                style: Theme.of(context).textTheme.labelMedium));
          }

        case ActionMenuMode.items:
          if ((action['must_equip'] ?? false) && !canUse) {
            return Text('Must be equipped',
                style: Theme.of(context).textTheme.labelMedium);
          }
          String? damage = getDamage();
          String? attack = getAttack();
          if (attack != null) {
            children.add(Text('Attack: $attack',
                style: Theme.of(context).textTheme.labelMedium));
          }
          if (damage != null) {
            children.add(Text('Damage: $damage',
                style: Theme.of(context).textTheme.labelMedium));
          }
          if (action['expendable'] ?? false) {
            final backpackItem = getBackpackItem(character, action['item']);
            final inBackpack = backpackItem['quantity'] ?? 0;
            final String use = inBackpack == 1 ? 'use' : 'uses';
            children.add(Text('$inBackpack available $use',
                style: Theme.of(context).textTheme.labelMedium));
          }
        default:
          return Container();
      }
      return Wrap(
        children: children
            .map((e) => Card.outlined(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: e,
                  ),
                ))
            .toList(),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () => _onTap(context),
        child: ListTile(
          title: Text(action['title'],
              style: Theme.of(context).textTheme.titleMedium),
          subtitle: buildSubtitle(context),
          trailing: isEditMode
              ? AddActionButton(
                  character: character,
                  slug: characterSlug,
                  action: action,
                  actionSlug: actionSlug,
                  onActionsChanged: onActionsChanged,
                )
              : usable
                  ? _buildUse(context)
                  : null,
        ),
      ),
    );
  }

  Widget _buildUse(BuildContext context) {
    return ActionChip(
      label: const Text('Use'),
      onPressed: () {
        if (onUse != null) {
          var character = this.character;
          final ammo = action['ammo'];
          final backpackItem = getBackpackItem(character, action['item']);
        }
      },
    );
  }

  void _onTap(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final item = context.read<RulesCubit>().getItem(action['item'] ?? '');
        final Map<String, dynamic>? backpackItem;
        if (item != null) {
          backpackItem = getBackpackItem(character, action['item']);
        } else {
          backpackItem = null;
        }
        return AlertDialog(
          title: Text(action['title']),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              DescriptionText(
                  inputText: action['description'],
                  baseStyle: Theme.of(context).textTheme.bodySmall!),
              if (item != null)
                Column(
                  children: [
                    const Divider(),
                    ItemDetailsDialogContent(
                      item: item,
                      quantity: backpackItem != null
                          ? backpackItem['quantity']
                          : null,
                    )
                  ],
                )
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: <Widget>[
            IconButton(
                onPressed: () => {
                      character['actions'].remove(actionSlug),
                      onActionsChanged(character['actions']),
                    },
                icon: const Icon(Icons.delete)),
            IconButton(
              icon: const Icon(Icons.done),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
