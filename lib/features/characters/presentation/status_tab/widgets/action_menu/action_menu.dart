import 'package:dnd5e_dm_tools/core/data/models/action.dart';
import 'package:dnd5e_dm_tools/core/data/models/action_resource.dart';
import 'package:dnd5e_dm_tools/core/data/models/backpack.dart';
import 'package:dnd5e_dm_tools/core/data/models/character.dart';
import 'package:dnd5e_dm_tools/core/data/models/class.dart';
import 'package:dnd5e_dm_tools/core/data/models/race.dart';
import 'package:dnd5e_dm_tools/core/util/const.dart';
import 'package:dnd5e_dm_tools/core/util/enum.dart';
import 'package:dnd5e_dm_tools/core/util/helper.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/status_tab/widgets/action_menu/action_category_row.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/status_tab/widgets/action_menu/action_widget.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/status_tab/widgets/action_menu/add_action_button.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_cubit.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_state.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_cubit.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:flutter_bloc/flutter_bloc.dart';

class ActionMenu extends StatefulWidget {
  const ActionMenu({
    super.key,
    required this.character,
    required this.classs,
    required this.race,
    required this.onCharacterUpdated,
    this.height,
  });
  final Character character;
  final Class classs;
  final Race race;
  final double? height;
  final ValueChanged<Character> onCharacterUpdated;

  @override
  State<ActionMenu> createState() => _ActionMenuState();
}

class _ActionMenuState extends State<ActionMenu> {
  bool _isEditMode = false;
  bool _isCompactMode = false;
  ActionMenuMode _mode = ActionMenuMode.all;
  late List<Action> actions;
  late ScrollController _scrollController;

  void _enableEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
  }

  void _enableCompactMode() {
    setState(() {
      _isCompactMode = !_isCompactMode;
    });
    final settingsCubit = context.read<SettingsCubit>();
    settingsCubit.setCompactMode(_isCompactMode);
  }

  @override
  void initState() {
    super.initState();
    actions = widget.character.actions;
    _isCompactMode = context.read<SettingsCubit>().state.actionsCompactMode;
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ActionMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.character != oldWidget.character) {
      setState(() {
        actions = widget.character.actions;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredActions = _getFilteredItems(actions);
    final screenWidth = MediaQuery.of(context).size.width;
    final orientation = MediaQuery.of(context).orientation;
    final isCaster = widget.character.spellbook.knownSpells.isNotEmpty;
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            (screenWidth > wideScreenBreakpoint &&
                orientation == Orientation.landscape)
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          ActionCategoryRow(
            onSelected: (mode) {
              setState(() {
                _mode = mode;
              });
            },
            showSpells: isCaster,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: Theme.of(context).colorScheme.outline),
                left: BorderSide(color: Theme.of(context).colorScheme.outline),
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
                        left: 16,
                        bottom: 8,
                        top: 8,
                        right: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Actions',
                            style: Theme.of(context).textTheme.headlineMedium!
                                .copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSecondaryContainer,
                                ),
                          ),
                          Row(
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Compact',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSecondaryContainer,
                                        ),
                                  ),
                                  Checkbox(
                                    value: _isCompactMode,
                                    onChanged: (value) {
                                      if (value != null) {
                                        _enableCompactMode();
                                      }
                                    },
                                    activeColor: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ],
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: _enableEditMode,
                                icon: Icon(
                                  _isEditMode ? Icons.check : Icons.edit,
                                ),
                              ),
                              if (_isEditMode)
                                AddActionButton(
                                  character: widget.character,
                                  onActionsChanged: onActionsChanged,
                                  classs: widget.classs,
                                  race: widget.race,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: widget.height,
                  child: Scrollbar(
                    controller: _scrollController,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Column(
                        children: [
                          if (filteredActions.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                'No actions.',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            )
                          else if (_mode == ActionMenuMode.spells &&
                              context.read<RulesCubit>().state
                                  is RulesStateLoaded)
                            ..._buildSpellSections(
                              filteredActions,
                              context.read<RulesCubit>().state
                                  as RulesStateLoaded,
                            )
                          else
                            ..._buildPlainActions(filteredActions, context),
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

  List<Widget> _buildPlainActions(List<Action> actions, BuildContext context) {
    return actions.map((action) {
      final isLastItem = actions.last == action;
      return Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: isLastItem
                ? BorderSide.none
                : BorderSide(color: Theme.of(context).colorScheme.outline),
          ),
        ),
        child: ActionWidget(
          action: action,
          character: widget.character,
          onUse: onUseAction,
          classs: widget.classs,
          race: widget.race,
          isEditMode: _isEditMode,
          onActionsChanged: onActionsChanged,
          compactMode: _isCompactMode,
        ),
      );
    }).toList();
  }

  List<Widget> _buildSpellSections(
    List<Action> actions,
    RulesStateLoaded rulesState,
  ) {
    final spellMap = rulesState.spellMap;

    final Map<int, List<Action>> byLevel = {};

    for (final a in actions) {
      if (a.type != ActionType.spell) continue;
      final spellSlug = (a as ActionSpell).spellSlug;
      final lvl = spellMap[spellSlug]?.level ?? 0;
      (byLevel[lvl] ??= []).add(a);
    }

    final levels = byLevel.keys.toList()..sort();

    return [
      for (final lvl in levels)
        ExpansionTile(
          key: ValueKey('spell_lvl_$lvl'),
          title: Text(
            lvl == 0 ? 'Cantrips' : '${getOrdinal(lvl)}-level Spells',
            style: Theme.of(
              context,
            ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
          ),

          children: _buildPlainActions(byLevel[lvl]!, context),
        ),
    ];
  }

  void onUseAction({required Action action, bool recharge = false}) {
    switch (action.type) {
      case ActionType.ability:
        final abilityAction = action as ActionAbility;
        final updatedAction = action.copyWith(
          usedCount: recharge ? 0 : action.usedCount + 1,
        );
        final List<Action> updatedActions;

        if (abilityAction.resourceType == ResourceType.custom &&
            abilityAction.customResource != null &&
            abilityAction.customResource!.name.isNotEmpty) {
          final resourceName = abilityAction.customResource!.name;
          final actions = widget.character.actions;
          updatedActions = [];

          for (final action in actions) {
            if (action is ActionAbility &&
                action.customResource != null &&
                action.resourceType == ResourceType.custom &&
                action.customResource!.name == resourceName) {
              final updatedAction = action.copyWith(
                customResource: abilityAction.customResource,
                resourceFormula: abilityAction.customResource!.formula,
                usedCount: recharge ? 0 : action.usedCount + 1,
              );
              updatedActions.add(updatedAction);
            } else {
              updatedActions.add(action);
            }
          }
        } else {
          updatedActions = widget.character.actions.map((a) {
            if (a.slug == action.slug) {
              return updatedAction;
            }
            return a;
          }).toList();
        }

        setState(() {
          actions = updatedActions;
        });
        widget.onCharacterUpdated(
          widget.character.copyWith(actions: updatedActions),
        );
      case ActionType.item:
        if (recharge) {
          return;
        }
        Backpack updatedBackpack = widget.character.backpack;
        if ((action as ActionItem).expendable) {
          final itemSlug = action.itemSlug;
          final backpackItem = widget.character.backpack.getItemBySlug(
            itemSlug,
          );
          if (backpackItem != null && backpackItem.quantity > 0) {
            updatedBackpack = widget.character.backpack.updateItemQuantity(
              itemSlug,
              quantity: backpackItem.quantity - 1,
            );
          }
        }
        if (action.ammo != null) {
          final ammoSlug = action.ammo!;
          final ammoItem = widget.character.backpack.getItemBySlug(ammoSlug);
          if (ammoItem != null && ammoItem.quantity > 0) {
            updatedBackpack = updatedBackpack.updateItemQuantity(
              ammoSlug,
              quantity: ammoItem.quantity - 1,
            );
          }
        }
        final updatedCharacter = widget.character.copyWith(
          backpack: updatedBackpack,
        );
        widget.onCharacterUpdated(updatedCharacter);
      case ActionType.spell:
        if (recharge) {
          final updatedSpellbook = widget.character.spellbook.resetSlots();
          final updatedCharacter = widget.character.copyWith(
            spellbook: updatedSpellbook,
          );
          widget.onCharacterUpdated(updatedCharacter);
          return;
        }
        final rulesState = context.read<RulesCubit>().state;
        if (rulesState is! RulesStateLoaded) {
          return;
        }
        if ((action as ActionSpell).spellSlug.isNotEmpty) {
          final spellMap = rulesState.spellMap;
          final spell = spellMap[action.spellSlug];
          if (spell == null) {
            return;
          }
          final level = spell.level;
          if (level > 0) {
            final updatedSpellbook = widget.character.spellbook.useSlot(level);
            final updatedCharacter = widget.character.copyWith(
              spellbook: updatedSpellbook,
            );
            widget.onCharacterUpdated(updatedCharacter);
          }
        }
    }
  }

  void onActionsChanged(List<Action> actions) {
    final sharedResources = actions
        .where((action) => action.type == ActionType.ability)
        .map((action) => (action as ActionAbility).customResource)
        .whereType<ActionResource>()
        .where((resource) => resource.name.isNotEmpty)
        .toList();
    final currSharedResources = Map<String, ActionResource>.from(
      widget.character.sharedActionResources,
    );
    final Map<String, ActionResource> updatedResources = {};

    for (final resource in sharedResources) {
      final existing = currSharedResources[resource.name];
      if (existing == null) {
        updatedResources[resource.name] = resource;
      } else if (resource != currSharedResources[resource.name]) {
        updatedResources[resource.name] = resource;
      }
    }

    final updatedActions = <Action>[];

    for (final action in actions) {
      if (action is ActionAbility &&
          action.customResource != null &&
          action.resourceType == ResourceType.custom &&
          action.customResource!.name.isNotEmpty) {
        final resourceName = action.customResource!.name;
        if (!updatedResources.containsKey(resourceName)) {
          updatedResources[resourceName] = action.customResource!;
        }
        updatedActions.add(
          action.copyWith(
            customResource: updatedResources[resourceName],
            resourceFormula: updatedResources[resourceName]!.formula,
          ),
        );
      } else {
        updatedActions.add(action);
      }
    }

    setState(() {
      this.actions = updatedActions;
    });

    widget.onCharacterUpdated(
      widget.character.copyWith(
        actions: updatedActions,
        sharedActionResources: updatedResources,
      ),
    );
  }

  List<Action> _getFilteredItems(List<Action> actions) {
    List<Action> filtered;
    if (_mode == ActionMenuMode.all) {
      filtered = List<Action>.from(actions);
    } else {
      filtered = [
        for (final action in actions)
          if (_mode == ActionMenuMode.abilities &&
              action.type == ActionType.ability)
            action
          else if (_mode == ActionMenuMode.items &&
              action.type == ActionType.item)
            action
          else if (_mode == ActionMenuMode.spells &&
              action.type == ActionType.spell)
            action,
      ];
    }

    filtered.sort((a, b) {
      final typeCompare = a.type.order.compareTo(b.type.order);
      if (typeCompare != 0) return typeCompare;
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });
    return filtered;
  }
}
