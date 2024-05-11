import 'package:dnd5e_dm_tools/core/util/enum.dart';
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
  final ActionMenuMode _mode = ActionMenuMode.all;
  late Map<String, Map<String, dynamic>> _items;

  void _enableEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
  }

  @override
  void initState() {
    super.initState();
    _items =
        Map<String, Map<String, dynamic>>.from(widget.character['items'] ?? {});
  }

  @override
  Widget build(BuildContext context) {
    final items = _getFilteredItems();
    return DecoratedBox(
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
                      style:
                          Theme.of(context).textTheme.headlineMedium!.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondaryContainer,
                              ),
                    ),
                    Row(
                      children: [
                        if (_isEditMode) const AddActionButton(),
                        IconButton(
                          onPressed: _enableEditMode,
                          icon: Icon(_isEditMode ? Icons.check : Icons.edit),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('No actions.',
                  style: Theme.of(context).textTheme.bodyLarge),
            ),
          ...items.keys.map(
            (key) {
              return Container();
            },
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getFilteredItems() {
    return _items;
  }

  void _persist() {}
}