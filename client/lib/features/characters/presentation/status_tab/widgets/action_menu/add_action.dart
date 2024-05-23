import 'package:dnd5e_dm_tools/core/util/helper.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_cubit.dart';
import 'package:flutter/material.dart';
import 'package:dnd5e_dm_tools/core/util/enum.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/status_tab/widgets/action_menu/action_category_row.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddActionButton extends StatelessWidget {
  final Map<String, dynamic> character;
  final String slug;
  final Map<String, dynamic>? action;
  final String? actionSlug;
  final Function(Map<String, Map<String, dynamic>>) onActionsChanged;

  const AddActionButton({
    required this.character,
    required this.slug,
    required this.onActionsChanged,
    this.action,
    this.actionSlug,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => showDialog(
        context: context,
        builder: (BuildContext context) => _AddActionDialog(
          character: character,
          slug: slug,
          action: action,
          editActionSlug: actionSlug,
          onActionsChanged: onActionsChanged,
        ),
      ),
      child:
          actionSlug != null ? const Icon(Icons.edit) : const Icon(Icons.add),
    );
  }
}

class _AddActionDialog extends StatefulWidget {
  final Map<String, dynamic> character;
  final String slug;
  final Map<String, dynamic>? action;
  final String? editActionSlug;
  final Function(Map<String, Map<String, dynamic>>) onActionsChanged;

  const _AddActionDialog({
    required this.character,
    required this.slug,
    this.action,
    this.editActionSlug,
    required this.onActionsChanged,
  });
  @override
  _AddActionDialogState createState() => _AddActionDialogState();
}

class _AddActionDialogState extends State<_AddActionDialog> {
  TextEditingController textEditingController = TextEditingController();
  ActionMenuMode _selected = ActionMenuMode.abilities;
  ResourceType _resourceType = ResourceType.none;
  bool _requiresResource = false;
  bool _expendable = false;
  String _ammo = 'none';
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  int _resourceCount = 0;
  String _selectedEntry = 'none';
  final charFeats = {};
  final classFeats = {};
  final archetypeFeats = {};
  final raceFeats = {};
  final items = {};
  final spells = {};
  late String? oldTitle;

  @override
  void initState() {
    super.initState();
    final classs =
        context.read<RulesCubit>().getClass(widget.character['class'] ?? '');
    final table = parseTable(classs?['table'] ?? {});
    final classFeats = getClassFeatures(classs?['desc'] ?? '',
        level: widget.character['level'] ?? 1, table: table);
    for (var feat in classFeats.entries) {
      if (feat.key != 'Ability Score Improvement') {
        classFeats[feat.key] = feat.value['description'];
      }
    }
    final archetype = classs?['archetypes']?.firstWhere(
        (archetype) => archetype['slug'] == widget.character['subclass'],
        orElse: () => null);
    final archetypeDesc = archetype?['desc'] ?? '';
    final subclassFeats = getArchetypeFeatures(archetypeDesc);
    for (var feat in subclassFeats.entries) {
      archetypeFeats[feat.key] = feat.value['description'];
    }
    final charFeats = widget.character['feats'] ?? [];
    for (var feat in charFeats.entries) {
      charFeats[feat.key] = feat.value['name'];
    }

    for (var spellSlug in widget.character['knownSpells'] ?? []) {
      final spell = context.read<RulesCubit>().getSpell(spellSlug);
      if (spell != null) {
        spells[spellSlug] = spell;
      }
    }

    final characterBackpack =
        Map<String, dynamic>.from(widget.character['backpack'] ?? {});
    final characterItems =
        Map<String, dynamic>.from(characterBackpack['items'] ?? {});
    for (final charItem in characterItems.entries) {
      final item = context.read<RulesCubit>().getItem(charItem.key);
      if (item != null) {
        items[charItem.key] = item;
      }
    }

    if (widget.action != null) {
      final actionType = ActionMenuMode.values.firstWhere(
          (e) => e.name == widget.action!['type'],
          orElse: () => ActionMenuMode.abilities);
      _selected = actionType;
      _descriptionController.text = widget.action!['description'] ?? '';
      _titleController.text = widget.action!['title'] ?? '';
      switch (actionType) {
        case ActionMenuMode.abilities:
          _selectedEntry = widget.action!['ability'] ?? 'none';
          _requiresResource = widget.action!['requires_resource'] ?? false;
          _resourceType = ResourceType.values.firstWhere(
              (e) => e.name == (widget.action!['resource_type'] ?? 'none'),
              orElse: () => ResourceType.none);
          _resourceCount = widget.action!['resource_count'] ?? 0;
          break;
        case ActionMenuMode.items:
          _selectedEntry = widget.action!['item'] ?? 'none';
          _requiresResource = widget.action!['must_equip'] ?? false;
          _expendable = widget.action!['expendable'] ?? false;
          _ammo = widget.action!['ammo'] ?? 'none';
          break;
        case ActionMenuMode.spells:
          _selectedEntry = widget.action!['spell'] ?? 'none';
          break;
        default:
          _selected = ActionMenuMode.abilities;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Add Action', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 20),
            ActionCategoryRow(
              showAll: false,
              onSelected: (ActionMenuMode selected) {
                setState(() {
                  _selectedEntry = 'none';
                  _selected = selected;
                });
              },
            ),
            _buildSectionedList(),
            if (_selected == ActionMenuMode.items) _buildAddItem(),
            if (_selected == ActionMenuMode.abilities) _buildAddAbility(),
            _buildCommonFields(),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCommonFields() {
    return Column(
      children: [
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Title',
          ),
        ),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description',
          ),
          minLines: 3,
          maxLines: 5,
        ),
      ],
    );
  }

  Widget _buildSectionedList() {
    final List<Widget> options = [];
    switch (_selected) {
      case ActionMenuMode.abilities:
        if (archetypeFeats.isNotEmpty) {
          options.addAll(_buildSection('Equippable', archetypeFeats));
        }
        break;
      case ActionMenuMode.items:
        final equipableItems = Map.fromEntries(
            items.entries.where((entry) => isEquipable(entry.value)).toList());
        if (equipableItems.isNotEmpty) {
          options.addAll(_buildSection('Equippable', equipableItems));
        }
        final misc = Map.fromEntries(
            items.entries.where((entry) => !isEquipable(entry.value)).toList());
        if (misc.isNotEmpty) {
          options.addAll(_buildSection('Misc', misc));
        }
        break;
      case ActionMenuMode.spells:
        break;
      default:
        break;
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2),
      height: 200,
      width: double.infinity,
      child: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: options,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSection(String label, Map<dynamic, dynamic> items) {
    return [
      Text(label.toUpperCase(), style: Theme.of(context).textTheme.titleSmall),
      SizedBox(width: label.length * 10, child: const Divider()),
      Wrap(
        direction: Axis.horizontal,
        spacing: 4,
        runSpacing: 0,
        children: [
          for (var entry in items.entries)
            ChoiceChip(
              labelPadding: const EdgeInsets.all(0),
              showCheckmark: false,
              label: Text(
                entry.value is String
                    ? entry.value
                    : entry.value['name'] ?? entry.key,
                style: Theme.of(context).textTheme.labelSmall,
              ),
              selected: _selectedEntry == entry.key,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedEntry = entry.key;
                  } else {
                    _selectedEntry = 'none';
                  }
                });
              },
            )
        ],
      ),
      const SizedBox(height: 12),
    ];
  }

  Widget _buildAddItem() {
    final screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('Requires\nequipped\nitem',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center),
            Padding(
              padding: EdgeInsets.only(right: screenWidth * 0.2),
              child: Checkbox(
                value: _requiresResource,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _requiresResource = value;
                      _resourceType = ResourceType.item;
                    });
                  }
                },
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('Expendable', style: Theme.of(context).textTheme.bodyMedium),
            Padding(
              padding: EdgeInsets.only(right: screenWidth * 0.2),
              child: Checkbox(
                value: _expendable,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _expendable = value;
                    });
                  }
                },
              ),
            ),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('Requires Ammo',
                style: Theme.of(context).textTheme.bodyMedium),
            DropdownButton<String>(
              value: _ammo,
              onChanged: (String? newValue) {
                setState(() {
                  _ammo = newValue ?? 'none';
                });
              },
              items: [
                DropdownMenuItem(
                  value: 'none',
                  child: Text(
                    'None',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                for (var item in items.entries)
                  DropdownMenuItem(
                    value: item.key,
                    child: Text(
                      item.value['name'],
                      overflow: TextOverflow.fade,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddAbility() {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Has resource', style: Theme.of(context).textTheme.bodyLarge),
            Checkbox(
              value: _requiresResource,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _requiresResource = value;
                    _resourceType = ResourceType.shortRest;
                  });
                }
              },
            ),
          ],
        ),
        if (_requiresResource)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    children: [
                      Text('Resource\ncount',
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              _resourceCount++;
                            });
                          },
                          icon: const Icon(Icons.add)),
                      Text(_resourceCount.toString(),
                          style: Theme.of(context).textTheme.titleLarge),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              if (_resourceCount > 0) {
                                _resourceCount--;
                              }
                            });
                          },
                          icon: const Icon(Icons.remove)),
                    ],
                  ),
                ),
              ),
              Column(
                children: [
                  ChoiceChip(
                    label: const Text('Short rest'),
                    selected: _resourceType == ResourceType.shortRest,
                    onSelected: (selected) {
                      setState(() {
                        _resourceType = ResourceType.shortRest;
                      });
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Long rest'),
                    selected: _resourceType == ResourceType.longRest,
                    onSelected: (selected) {
                      setState(() {
                        _resourceType = ResourceType.longRest;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }

  void updateDescription(String title, String description) {
    _titleController.text = title;
    _descriptionController.text = description;
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
        if (widget.editActionSlug != null)
          IconButton(
            onPressed: () {
              widget.character['actions']?.remove(widget.editActionSlug);
              final updatedActions = Map<String, Map<String, dynamic>>.from(
                  widget.character['actions']
                          ?.cast<String, Map<String, dynamic>>() ??
                      {});
              widget.onActionsChanged(updatedActions);
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.delete),
          ),
        IconButton(
          onPressed: () {
            final actionType = _selected;
            final Map<String, dynamic> action;
            String actionSlug;

            switch (actionType) {
              case ActionMenuMode.abilities:
                final ability = _selectedEntry;
                final description = _descriptionController.text;
                final title = _titleController.text;
                final requiresResource = _requiresResource;
                final resourceType = _resourceType;
                final resourceCount = _resourceCount;
                action = {
                  'type': actionType.name,
                  'ability': ability.toLowerCase() != 'none' ? ability : null,
                  'description': description,
                  'title': title,
                  'requires_resource': requiresResource,
                  'resource_type': resourceType.name,
                  'resource_count': resourceCount,
                };
                actionSlug = title.trim().replaceAll(' ', '_').toLowerCase();
                break;
              case ActionMenuMode.items:
                final item = _selectedEntry;
                final description = _descriptionController.text;
                final title = _titleController.text;
                final requiresResource = _requiresResource;
                final expendable = _expendable;
                final ammo = _ammo;
                action = {
                  'type': actionType.name,
                  'item': item,
                  'description': description,
                  'title': title,
                  'must_equip': requiresResource,
                  'expendable': expendable,
                  'ammo': ammo,
                };
                actionSlug = title.trim().replaceAll(' ', '_').toLowerCase();
                break;
              case ActionMenuMode.spells:
                action = {};
                actionSlug = '';
                break;
              default:
                action = {};
                actionSlug = '';
            }

            if (widget.editActionSlug != null) {
              actionSlug = widget.editActionSlug!;
            }

            widget.character['actions'] ??= {};
            if (actionSlug.isNotEmpty) {
              widget.character['actions'][actionSlug] = action;
              final updatedActions = Map<String, Map<String, dynamic>>.from(
                  widget.character['actions']
                          ?.cast<String, Map<String, dynamic>>() ??
                      {});
              widget.onActionsChanged(updatedActions);
            }

            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.check),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
