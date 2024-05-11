import 'package:dnd5e_dm_tools/core/config/app_colors.dart';
import 'package:dnd5e_dm_tools/core/util/enum.dart';
import 'package:dnd5e_dm_tools/core/widgets/trait_description2.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_cubit.dart';
import 'package:flutter/gestures.dart';
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
    final bool canUse;
    final ActionMenuMode type = ActionMenuMode.values.firstWhere(
        (e) => e.name == action['type'],
        orElse: () => ActionMenuMode.all);
    final requiresResource = (action['requires_resource'] ?? false) as bool;
    final usedCount = action['used_count'] ?? 0;
    final remaining = (action['resource_count'] ?? 1) - usedCount;
    switch (type) {
      case ActionMenuMode.abilities:
        if (requiresResource) {
          canUse = remaining > 0;
        }
        break;
      case ActionMenuMode.items:
        canUse = character['actions']['bonus'] > 0;
        break;
      default:
        canUse = true;
    }

    Widget buildSubtitle() {
      switch (type) {
        case ActionMenuMode.abilities:
          if (!(action['requires_resource'] ?? true)) {
            return Container();
          }
          final String use = remaining == 1 ? 'use' : 'uses';
          return Text('$remaining available $use',
              style: Theme.of(context).textTheme.bodyMedium);
        case ActionMenuMode.items:
          return Container();
        default:
          return Container();
      }
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(action['title'],
            style: Theme.of(context).textTheme.titleMedium),
        subtitle: buildSubtitle(),
      ),
    );
  }
}
