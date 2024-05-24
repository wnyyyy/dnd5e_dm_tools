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
        barrierDismissible: false,
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
  final TextEditingController textEditingController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _healController = TextEditingController();
  final TextEditingController _damageController = TextEditingController();
  final TextEditingController _attackController = TextEditingController();
  final TextEditingController _saveDcController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _rangeController = TextEditingController();
  final TextEditingController _conditionsController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _castTimeController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();

  ActionMenuMode _selected = ActionMenuMode.abilities;
  ResourceType _resourceType = ResourceType.none;
  bool _requiresResource = false;
  bool _expendable = false;
  String _ammo = 'none';
  int _resourceCount = 0;
  String _selectedEntry = 'none';
  final Map<String, dynamic> charFeats = {};
  final Map<String, dynamic> classFeats = {};
  final Map<String, dynamic> archetypeFeats = {};
  final Map<String, dynamic> raceFeats = {};
  final Map<String, dynamic> items = {};
  final Map<String, dynamic> spells = {};
  String _selectedSaveAttribute = 'None';
  bool _halfOnSuccess = false;

  @override
  void initState() {
    super.initState();
    final classs =
        context.read<RulesCubit>().getClass(widget.character['class'] ?? '');
    final race = context.read<RulesCubit>().getRace(widget.character['race']);
    final table = parseTable(classs?['table'] ?? {});
    final classFeats = getClassFeatures(classs?['desc'] ?? '',
        level: widget.character['level'] ?? 1, table: table);
    for (var feat in classFeats.entries) {
      if (feat.key != 'Ability Score Improvement') {
        this.classFeats[feat.key] = feat.value['description'];
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
    final racialFeats = getRacialFeatures(race?['traits'] ?? {});
    for (var feat in racialFeats.entries) {
      raceFeats[feat.key] = feat.value;
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
    return WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Add Action',
                  style: Theme.of(context).textTheme.titleMedium),
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
              const SizedBox(height: 12),
              if (_selected == ActionMenuMode.items) _buildAddItem(),
              if (_selected == ActionMenuMode.abilities) _buildAddAbility(),
              const SizedBox(
                height: 24,
                child: Divider(),
              ),
              _buildCommonFields(),
              _buildExpansionTileFields(),
              const SizedBox(
                height: 24,
                child: Divider(),
              ),
              _buildActionButtons(context),
            ],
          ),
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
          options.addAll(_buildSection('Archetype', archetypeFeats));
        }
        if (classFeats.isNotEmpty) {
          options.addAll(_buildSection('Class feats', classFeats));
        }
        if (raceFeats.isNotEmpty) {
          options.addAll(_buildSection('Racial feats', raceFeats));
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
        final cantrips = Map.fromEntries(spells.entries
            .where((entry) => entry.value['level_int'] == 0)
            .toList());
        if (cantrips.isNotEmpty) {
          options.addAll(_buildSection('Cantrips', cantrips));
        }
        for (var i = 1; i < 10; i++) {
          final spellsByLevel = Map.fromEntries(spells.entries
              .where((entry) => entry.value['level_int'] == i)
              .toList());
          if (spellsByLevel.isNotEmpty) {
            options.addAll(_buildSection('Level $i', spellsByLevel));
          }
        }
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
        controller: _scrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _scrollController,
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
                    ? entry.key
                    : entry.value['name'] ?? entry.key,
                style: Theme.of(context).textTheme.labelSmall,
              ),
              selected: _selectedEntry == entry.key,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedEntry = entry.key;
                    _titleController.text = entry.value is String
                        ? entry.key
                        : entry.value['name'] ?? entry.key;
                    _descriptionController.text = entry.value is String
                        ? entry.value
                        : entry.value['description'] ??
                            entry.value['desc'] ??
                            '';
                  } else {
                    _selectedEntry = 'none';
                    _titleController.clear();
                    _descriptionController.clear();
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
                  child: Text('None',
                      style: Theme.of(context).textTheme.titleSmall),
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
                        color: Theme.of(context).colorScheme.outline),
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
                        icon: const Icon(Icons.add),
                      ),
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
                        icon: const Icon(Icons.remove),
                      ),
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

  Widget _buildExpansionTileFields() {
    return ExpansionTile(
      title: Text('Additional Fields',
          style: Theme.of(context).textTheme.titleSmall),
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _healController,
                decoration: const InputDecoration(
                  labelText: 'Heal',
                  labelStyle: TextStyle(fontSize: 12),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: _damageController,
                decoration: const InputDecoration(
                  labelText: 'Damage',
                  labelStyle: TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _attackController,
                decoration: const InputDecoration(
                  labelText: 'Attack',
                  labelStyle: TextStyle(fontSize: 12),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(
                  labelText: 'Type',
                  labelStyle: TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedSaveAttribute,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedSaveAttribute = newValue!;
                  });
                },
                items: [
                  'None',
                  'Strength',
                  'Dexterity',
                  'Constitution',
                  'Intelligence',
                  'Wisdom',
                  'Charisma'
                ]
                    .map((attribute) => DropdownMenuItem(
                          value: attribute,
                          child: Text(attribute,
                              style: const TextStyle(fontSize: 12)),
                        ))
                    .toList(),
                decoration: const InputDecoration(
                  labelText: 'Save',
                  labelStyle: TextStyle(fontSize: 12),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  children: [
                    Text('Half on Success',
                        style: Theme.of(context).textTheme.bodySmall),
                    Checkbox(
                      value: _halfOnSuccess,
                      onChanged: (bool? newValue) {
                        setState(() {
                          _halfOnSuccess = newValue!;
                        });
                      },
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _saveDcController,
                decoration: const InputDecoration(
                  labelText: 'Save DC',
                  labelStyle: TextStyle(fontSize: 12),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: _rangeController,
                decoration: const InputDecoration(
                  labelText: 'Range',
                  labelStyle: TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _castTimeController,
                decoration: const InputDecoration(
                  labelText: 'Cast Time',
                  labelStyle: TextStyle(fontSize: 12),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: _areaController,
                decoration: const InputDecoration(
                  labelText: 'Area',
                  labelStyle: TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _conditionsController,
                decoration: const InputDecoration(
                  labelText: 'Condition',
                  labelStyle: TextStyle(fontSize: 12),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Duration',
                  labelStyle: TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
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
              Navigator.of(context).pop();
              _showDeleteConfirmationDialog(context);
            },
            icon: const Icon(Icons.delete),
          ),
        IconButton(
          onPressed: () {
            final actionType = _selected;
            final Map<String, dynamic> action = {};
            final fields = {
              'heal': _healController.text,
              'damage': _damageController.text,
              'attack': _attackController.text,
              'save_dc': _saveDcController.text,
              'save': _selectedSaveAttribute,
              'half_on_success': _halfOnSuccess,
              'area': _areaController.text,
              'range': _rangeController.text,
              'conditions': _conditionsController.text,
              'duration': _durationController.text,
              'cast_time': _castTimeController.text,
              'type': _typeController.text,
            };
            action['fields'] = fields;
            final description = _descriptionController.text;
            final title = _titleController.text;
            action['description'] = description;
            action['title'] = title;
            String actionSlug = title.trim().replaceAll(' ', '_').toLowerCase();

            switch (actionType) {
              case ActionMenuMode.abilities:
                final ability = _selectedEntry;
                final requiresResource = _requiresResource;
                final resourceType = _resourceType;
                final resourceCount = _resourceCount;
                action['ability'] = ability;
                action['requires_resource'] = requiresResource;
                action['resource_type'] = resourceType.name;
                action['resource_count'] = resourceCount;
                break;
              case ActionMenuMode.items:
                final item = _selectedEntry;
                final requiresResource = _requiresResource;
                final expendable = _expendable;
                final ammo = _ammo;
                break;
              case ActionMenuMode.spells:
                break;
              default:
                break;
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
                widget.character['actions']?.remove(widget.editActionSlug);
                final updatedActions = Map<String, Map<String, dynamic>>.from(
                    widget.character['actions']
                            ?.cast<String, Map<String, dynamic>>() ??
                        {});
                widget.onActionsChanged(updatedActions);
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _scrollController.dispose();
    _healController.dispose();
    _damageController.dispose();
    _attackController.dispose();
    _saveDcController.dispose();
    _areaController.dispose();
    _rangeController.dispose();
    _conditionsController.dispose();
    _durationController.dispose();
    _castTimeController.dispose();
    _typeController.dispose();
    super.dispose();
  }
}
