import 'package:dnd5e_dm_tools/core/data/models/action.dart';
import 'package:dnd5e_dm_tools/core/data/models/character.dart';
import 'package:dnd5e_dm_tools/core/data/models/class.dart';
import 'package:dnd5e_dm_tools/core/data/models/race.dart';
import 'package:dnd5e_dm_tools/core/util/const.dart';
import 'package:dnd5e_dm_tools/core/util/enum.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/status_tab/widgets/action_menu/action_category_row.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/status_tab/widgets/action_menu/action_widget.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/status_tab/widgets/action_menu/add_action_button.dart';
import 'package:flutter/material.dart' hide Action;

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
  ActionMenuMode _mode = ActionMenuMode.all;
  late List<Action> actions;
  late ScrollController _scrollController;

  void _enableEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
  }

  @override
  void initState() {
    super.initState();
    actions = widget.character.actions;
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredActions = _getFilteredItems(actions);
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).colorScheme.outline),
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
                            ),
                          ...filteredActions.map((action) {
                            final isLastItem = filteredActions.last == action;
                            return Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: isLastItem
                                      ? BorderSide.none
                                      : BorderSide(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.outline,
                                        ),
                                ),
                              ),
                              child: ActionWidget(
                                action: action,
                                character: widget.character,
                                onUse: onUseAction,
                                classs: widget.classs,
                                race: widget.race,
                                isEditMode: false,
                                onActionsChanged: (List<Action> value) {},
                              ),
                            );
                          }),
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

  void onUseAction({required Action action, bool recharge = false}) {}

  void onActionsChanged(List<Action> actions) {
    setState(() {
      this.actions = actions;
    });
    widget.onCharacterUpdated(widget.character.copyWith(actions: actions));
  }

  List<Action> _getFilteredItems(List<Action> actions) {
    if (_mode == ActionMenuMode.all) {
      return actions;
    }
    final filtered = List<Action>.empty(growable: true);
    for (final action in actions) {
      if (_mode == ActionMenuMode.abilities &&
          action.type == ActionType.ability) {
        filtered.add(action);
      } else if (_mode == ActionMenuMode.items &&
          action.type == ActionType.item) {
        filtered.add(action);
      } else if (_mode == ActionMenuMode.spells &&
          action.type == ActionType.spell) {
        filtered.add(action);
      }
    }
    return filtered;
  }
}
