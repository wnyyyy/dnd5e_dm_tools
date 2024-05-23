import 'package:dnd5e_dm_tools/core/util/enum.dart';
import 'package:dnd5e_dm_tools/core/util/helper.dart';
import 'package:dnd5e_dm_tools/core/widgets/description_text.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/equip_tab/widgets/item_details_dialog_content.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/status_tab/widgets/action_menu/add_action.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_cubit.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_states.dart';
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
      child: ExpansionTile(
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
        children: <Widget>[
          DescriptionText(
              inputText: action['description'],
              baseStyle: Theme.of(context).textTheme.bodySmall!),
          if (action['item'] != null)
            BlocBuilder<RulesCubit, RulesState>(
              builder: (context, state) {
                final item =
                    context.read<RulesCubit>().getItem(action['item'] ?? '');
                if (item != null) {
                  final backpackItem =
                      getBackpackItem(character, action['item']);
                  return Column(
                    children: [
                      const Divider(),
                      ItemDetailsDialogContent(
                        item: item,
                        quantity: backpackItem['quantity'],
                      )
                    ],
                  );
                } else {
                  return Container();
                }
              },
            ),
          const SizedBox(
            height: 16,
          ),
        ],
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

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this action?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                character['actions'].remove(actionSlug);
                onActionsChanged(character['actions']);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
