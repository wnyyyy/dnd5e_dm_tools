import 'package:dnd5e_dm_tools/core/util/enum.dart';
import 'package:dnd5e_dm_tools/core/util/helper.dart';
import 'package:flutter/material.dart';

class ActionItem extends StatelessWidget {
  final Map<String, dynamic> action;
  final Map<String, dynamic> character;

  const ActionItem({
    super.key,
    required this.action,
    required this.character,
  });

  @override
  Widget build(BuildContext context) {
    bool canUse = true;
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
        }
        break;
      case ActionMenuMode.items:
        final backpackItem = getBackpackItem(character, action['item']);
        canUse = mustEquip ? backpackItem['isEquipped'] ?? false : true;
        canUse = canUse && (backpackItem['quantity'] ?? 0) > 0;
        break;
      default:
        canUse = true;
    }

    Widget buildSubtitle(context) {
      switch (type) {
        case ActionMenuMode.abilities:
          if (!(action['requires_resource'] ?? true)) {
            return Container();
          }
          final String use = remaining == 1 ? 'use' : 'uses';
          return Text('$remaining available $use',
              style: Theme.of(context).textTheme.bodyMedium);
        case ActionMenuMode.items:
          if ((action['must_equip'] ?? false) && !canUse) {
            return Text('Must be equipped',
                style: Theme.of(context).textTheme.bodyMedium);
          }
          final backpackItem = getBackpackItem(character, action['item']);
          final inBackpack = backpackItem['quantity'] ?? 0;
          final String use = inBackpack == 1 ? 'use' : 'uses';
          return Text('$inBackpack available $use',
              style: Theme.of(context).textTheme.bodyMedium);
        default:
          return Container();
      }
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(action['title'],
            style: Theme.of(context).textTheme.titleMedium),
        subtitle: buildSubtitle(context),
      ),
    );
  }
}
