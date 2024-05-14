import 'package:dnd5e_dm_tools/core/util/enum.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/status_tab/widgets/action_menu/action_category_row.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/status_tab/widgets/action_menu/action_item.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/status_tab/widgets/action_menu/add_action.dart';
import 'package:flutter/material.dart';

class ActionMenu extends StatefulWidget {
  const ActionMenu({
    super.key,
    required this.character,
    required this.slug,
  });

  final Map<String, dynamic> character;
  final String slug;

  @override
  State<ActionMenu> createState() => _ActionMenuState();
}

class _ActionMenuState extends State<ActionMenu> {
  bool _isEditMode = false;
  ActionMenuMode _mode = ActionMenuMode.all;
  late Map<String, Map<String, dynamic>> _actions;

  void _enableEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
  }

  @override
  void initState() {
    super.initState();
    final dynamic actions = widget.character['actions'];
    if (actions is Map) {
      _actions = actions.map<String, Map<String, dynamic>>((key, value) {
        final keyStr = key as String;
        final valueMap = Map<String, dynamic>.from(value);
        return MapEntry(keyStr, valueMap);
      });
    } else {
      _actions = <String, Map<String, dynamic>>{};
    }
  }

  @override
  Widget build(BuildContext context) {
    final actions = _getFilteredItems();
    return Column(
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
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
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
                            if (_isEditMode)
                              AddActionButton(
                                character: widget.character,
                                slug: widget.slug,
                              ),
                            IconButton(
                              onPressed: _enableEditMode,
                              icon:
                                  Icon(_isEditMode ? Icons.check : Icons.edit),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
              if (actions.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('No actions.',
                      style: Theme.of(context).textTheme.bodyLarge),
                ),
              ...actions.keys.map(
                (key) {
                  return ActionItem(
                      action: actions[key], character: widget.character);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> _getFilteredItems() {
    if (_mode == ActionMenuMode.all) {
      return _actions;
    }
    var filtered = <String, Map<String, dynamic>>{};
    for (final key in _actions.keys) {
      final action = _actions[key]!;
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
