import 'package:dnd5e_dm_tools/core/util/const.dart';
import 'package:dnd5e_dm_tools/core/util/enum.dart';
import 'package:dnd5e_dm_tools/core/util/helper.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_events.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/status_tab/widgets/action_menu/action_category_row.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/status_tab/widgets/action_menu/action_item.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/status_tab/widgets/action_menu/add_action.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_cubit.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ActionMenu extends StatefulWidget {
  final Map<String, dynamic> character;
  final String slug;
  final double? height;

  const ActionMenu({
    super.key,
    required this.character,
    required this.slug,
    this.height,
  });

  @override
  State<ActionMenu> createState() => _ActionMenuState();
}

class _ActionMenuState extends State<ActionMenu> {
  bool _isEditMode = false;
  ActionMenuMode _mode = ActionMenuMode.all;
  late Map<String, Map<String, dynamic>> actions;

  void _enableEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
  }

  @override
  void initState() {
    super.initState();
    actions =
        Map<String, Map<String, dynamic>>.from(widget.character['actions']);
  }

  @override
  Widget build(BuildContext context) {
    final filteredActions = _getFilteredItems(actions);
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: screenWidth > wideScreenBreakpoint
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          ActionCategoryRow(
            onSelected: (mode) {
              setState(() {
                _mode = mode;
              });
            },
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                ),
                left: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 16, bottom: 8, top: 8, right: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Actions',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium!
                                .copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSecondaryContainer,
                                ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: _enableEditMode,
                                icon: Icon(
                                    _isEditMode ? Icons.check : Icons.edit),
                              ),
                              if (_isEditMode)
                                AddActionButton(
                                  character: widget.character,
                                  slug: widget.slug,
                                  onActionsChanged: onActionsChanged,
                                ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: widget.height,
                  child: Scrollbar(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          if (filteredActions.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text('No actions.',
                                  style: Theme.of(context).textTheme.bodyLarge),
                            ),
                          ...filteredActions.keys.map(
                            (key) {
                              final isLastItem =
                                  key == filteredActions.keys.last;
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: isLastItem
                                        ? BorderSide.none
                                        : BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outline,
                                          ),
                                  ),
                                ),
                                child: ActionItem(
                                  action: filteredActions[key]!,
                                  actionSlug: key,
                                  character: widget.character,
                                  characterSlug: widget.slug,
                                  isEditMode: _isEditMode,
                                  onActionsChanged: onActionsChanged,
                                  onUse: onUseAction,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void onUseAction({
    required Map<String, dynamic> action,
    required String slug,
    required ActionMenuMode type,
    bool recharge = false,
  }) {
    switch (type) {
      case ActionMenuMode.abilities:
        var usedCount = action['used_count'] ?? 0;
        if (recharge) {
          usedCount = 0;
        } else {
          usedCount++;
        }
        action['used_count'] = usedCount;
        widget.character['actions'][slug] = action;
        break;
      case ActionMenuMode.items:
        if (recharge) {
          break;
        }
        if (action['expendable']) {
          final itemSlug = action['item'] ?? '';
          final backpackItem = getBackpackItem(widget.character, itemSlug);
          if (backpackItem['quantity'] > 0) {
            backpackItem['quantity']--;
            widget.character['backpack']['items'][itemSlug] = backpackItem;
          }
        }
        if (action['ammo'] != null) {
          final ammoSlug = action['ammo'] ?? '';
          final ammoItem = getBackpackItem(widget.character, ammoSlug);
          if (ammoItem['quantity'] > 0) {
            ammoItem['quantity']--;
            widget.character['backpack']['items'][ammoSlug] = ammoItem;
          }
        }
        break;
      case ActionMenuMode.spells:
        if (recharge) {
          break;
        }
        final actionSpell = action['spell'] ?? '';
        final spell = context.read<RulesCubit>().getSpell(actionSpell);
        if (spell != null) {
          final level = spell['level_int'] ?? 0;
          if (level > 0) {
            final expendedSlotsMap =
                widget.character['expended_spell_slots'] ?? {};
            final expendedSlots = expendedSlotsMap[level.toString()] ?? 0;
            expendedSlotsMap[level.toString()] = expendedSlots + 1;
            widget.character['expended_spell_slots'] = expendedSlotsMap;
          }
        }
        break;
      default:
        break;
    }
    context.read<CharacterBloc>().add(
          CharacterUpdate(
            character: widget.character,
            slug: widget.slug,
            offline: context.read<SettingsCubit>().state.offlineMode,
            persistData: true,
          ),
        );
  }

  void onActionsChanged(Map<String, dynamic> actions) {
    setState(() {
      this.actions = Map<String, Map<String, dynamic>>.from(actions);
    });
    context.read<CharacterBloc>().add(
          CharacterUpdate(
            character: widget.character,
            slug: widget.slug,
            offline: context.read<SettingsCubit>().state.offlineMode,
            persistData: true,
          ),
        );
  }

  Map<String, dynamic> _getFilteredItems(
      Map<String, Map<String, dynamic>> actions) {
    if (_mode == ActionMenuMode.all) {
      return actions;
    }
    var filtered = <String, Map<String, dynamic>>{};
    for (final key in actions.keys) {
      final action = actions[key]!;
      final type = ActionMenuMode.values.firstWhere(
        (e) => e.name == action['type'],
        orElse: () => ActionMenuMode.all,
      );
      if (type == _mode) {
        filtered[key] = action;
      }
    }
    return filtered;
  }
}
