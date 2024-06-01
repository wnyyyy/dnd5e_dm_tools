import 'package:dnd5e_dm_tools/core/util/enum.dart';
import 'package:dnd5e_dm_tools/core/util/helper.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/status_tab/widgets/action_menu/action_category_row.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddActionButton extends StatelessWidget {
  const AddActionButton({
    required this.character,
    required this.slug,
    required this.onActionsChanged,
    this.action,
    this.actionSlug,
    super.key,
  });
  final Map<String, dynamic> character;
  final String slug;
  final Map<String, dynamic>? action;
  final String? actionSlug;
  final Function(Map<String, Map<String, dynamic>>) onActionsChanged;

  @override
  Widget build(BuildContext context) {
    return IconButton(
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
      icon: actionSlug != null ? const Icon(Icons.edit) : const Icon(Icons.add),
    );
  }
}

class _AddActionDialog extends StatefulWidget {
  const _AddActionDialog({
    required this.character,
    required this.slug,
    this.action,
    this.editActionSlug,
    required this.onActionsChanged,
  });
  final Map<String, dynamic> character;
  final String slug;
  final Map<String, dynamic>? action;
  final String? editActionSlug;
  final Function(Map<String, Map<String, dynamic>>) onActionsChanged;
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
  final TextEditingController _formulaController = TextEditingController();

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
  bool _isAdditionalFieldsExpanded = false;
  bool _isFormulaValid = true;

  @override
  void initState() {
    super.initState();
    final classs = context
        .read<RulesCubit>()
        .getClass(widget.character['class'] as String? ?? '');
    final race =
        context.read<RulesCubit>().getRace(widget.character['race'] as String);
    final table = parseTable(classs?['table'] as String? ?? '');
    final classFeats = getClassFeatures(
      classs?['desc'] as String? ?? '',
      level: widget.character['level'] as int? ?? 1,
      table: table,
    );
    for (final feat in classFeats.entries) {
      if (feat.key != 'Ability Score Improvement') {
        this.classFeats[feat.key] = (feat.value as Map)['description'];
      }
    }
    final archetype =
        (classs?['archetypes'] as List<Map<String, dynamic>>?)?.firstWhere(
      (archetype) => archetype['slug'] == widget.character['subclass'],
      orElse: () => {},
    );
    final archetypeDesc = archetype?['desc'] ?? '';
    final subclassFeats = getArchetypeFeatures(archetypeDesc as String);
    for (final feat in subclassFeats.entries) {
      archetypeFeats[feat.key] = (feat.value as Map)['description'];
    }
    final racialFeats = getRacialFeatures(race?['traits'] as String? ?? '');
    for (final feat in racialFeats.entries) {
      raceFeats[feat.key] = feat.value;
    }

    for (final spellSlug
        in widget.character['known_spells'] as List<dynamic>? ?? []) {
      final spell = context.read<RulesCubit>().getSpell(spellSlug as String);
      if (spell != null) {
        spells[spellSlug] = spell;
      }
    }

    final characterBackpack = Map<String, dynamic>.from(
      widget.character['backpack'] as Map<String, dynamic>? ?? {},
    );
    final characterItems = Map<String, dynamic>.from(
      characterBackpack['items'] as Map<String, dynamic>? ?? {},
    );
    for (final charItem in characterItems.entries) {
      final item = context.read<RulesCubit>().getItem(charItem.key);
      if (item != null) {
        items[charItem.key] = item;
      }
    }

    if (widget.action != null) {
      final actionType = ActionMenuMode.values.firstWhere(
        (e) => e.name == widget.action!['type'],
        orElse: () => ActionMenuMode.abilities,
      );
      _selected = actionType;
      _descriptionController.text =
          widget.action!['description'] as String? ?? '';
      _titleController.text = widget.action!['title'] as String? ?? '';
      final fields = widget.action!['fields'] as Map<String, dynamic>? ?? {};
      _healController.text = fields['heal'] as String? ?? '';
      _damageController.text = fields['damage'] as String? ?? '';
      _attackController.text = fields['attack'] as String? ?? '';
      _saveDcController.text = fields['save_dc'] as String? ?? '';
      _areaController.text = fields['area'] as String? ?? '';
      _rangeController.text = fields['range'] as String? ?? '';
      _conditionsController.text = fields['conditions'] as String? ?? '';
      _durationController.text = fields['duration'] as String? ?? '';
      _castTimeController.text = fields['cast_time'] as String? ?? '';
      _typeController.text = fields['type'] as String? ?? '';
      _selectedSaveAttribute = fields['save'] as String? ?? 'None';
      _halfOnSuccess = fields['half_on_success'] as bool? ?? false;
      _isAdditionalFieldsExpanded = true;

      switch (actionType) {
        case ActionMenuMode.abilities:
          _selectedEntry = widget.action!['ability'] as String? ?? 'none';
          _requiresResource =
              widget.action!['requires_resource'] as bool? ?? false;
          _resourceType = ResourceType.values.firstWhere(
            (e) =>
                e.name ==
                (widget.action!['resource_type'] as String? ?? 'none'),
            orElse: () => ResourceType.none,
          );
          _resourceCount = widget.action!['resource_count'] as int? ?? 0;
        case ActionMenuMode.items:
          _selectedEntry = widget.action!['item'] as String? ?? 'none';
          _requiresResource = widget.action!['must_equip'] as bool? ?? false;
          _expendable = widget.action!['expendable'] as bool? ?? false;
          _ammo = widget.action!['ammo'] as String? ?? 'none';
        case ActionMenuMode.spells:
          _selectedEntry = widget.action!['spell'] as String? ?? 'none';
        default:
          _selected = ActionMenuMode.abilities;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return PopScope(
      child: Dialog(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: screenWidth > 900
                ? screenWidth * 0.5
                : screenWidth > 600
                    ? screenWidth * 0.75
                    : screenWidth * 0.9,
            minWidth: 400,
            maxHeight: screenHeight * 0.9,
            minHeight: screenHeight * 0.9,
          ),
          child: Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          'Add Action',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
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
                        if (_selected == ActionMenuMode.abilities)
                          _buildAddAbility(),
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
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: _buildActionButtons(context),
                  ),
                ],
              ),
            ),
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
      case ActionMenuMode.items:
        final equipableItems = Map.fromEntries(
          items.entries
              .where(
                (entry) =>
                    isEquipable(entry.value as Map<String, dynamic>? ?? {}),
              )
              .toList(),
        );
        if (equipableItems.isNotEmpty) {
          options.addAll(_buildSection('Equippable', equipableItems));
        }
        final misc = Map.fromEntries(
          items.entries
              .where(
                (entry) =>
                    !isEquipable(entry.value as Map<String, dynamic>? ?? {}),
              )
              .toList(),
        );
        if (misc.isNotEmpty) {
          options.addAll(_buildSection('Misc', misc));
        }
      case ActionMenuMode.spells:
        final cantrips = Map.fromEntries(
          spells.entries
              .where(
                (entry) =>
                    (entry.value as Map<String, dynamic>? ?? {})['level_int'] ==
                    0,
              )
              .toList(),
        );
        if (cantrips.isNotEmpty) {
          options.addAll(_buildSection('Cantrips', cantrips));
        }
        for (var i = 1; i < 10; i++) {
          final spellsByLevel = Map.fromEntries(
            spells.entries
                .where(
                  (entry) =>
                      (entry.value as Map<String, dynamic>? ??
                          {})['level_int'] ==
                      i,
                )
                .toList(),
          );
          if (spellsByLevel.isNotEmpty) {
            options.addAll(_buildSection('Level $i', spellsByLevel));
          }
        }
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

  List<Widget> _buildSection(String label, Map<String, dynamic> items) {
    return [
      Text(label.toUpperCase(), style: Theme.of(context).textTheme.titleSmall),
      SizedBox(width: label.length * 10, child: const Divider()),
      Wrap(
        spacing: 4,
        children: [
          for (final entry in items.entries)
            ChoiceChip(
              labelPadding: EdgeInsets.zero,
              showCheckmark: false,
              label: Text(
                entry.value is String
                    ? entry.key
                    : (entry.value as Map?)?['name']?.toString() ?? entry.key,
                style: Theme.of(context).textTheme.labelSmall,
              ),
              selected: _selectedEntry == entry.key,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedEntry = entry.key;
                    if (entry.value is String) {
                      _titleController.text = entry.key;
                      _descriptionController.text =
                          entry.value as String? ?? '';
                    } else {
                      _titleController.text =
                          (entry.value as Map?)?['name']?.toString() ??
                              entry.key;
                      _descriptionController.text =
                          (entry.value as Map?)?['description']?.toString() ??
                              '';
                      if ((entry.value as Map?)?['desc']
                              ?.toString()
                              .isNotEmpty ??
                          false) {
                        _descriptionController.text =
                            ((entry.value as Map?)?['desc'] as List<String>? ??
                                [])[0];
                      }
                    }

                    if (_selected == ActionMenuMode.spells &&
                        entry.value is Map<String, dynamic>) {
                      final spell = entry.value as Map<String, dynamic>;
                      _rangeController.text = spell['range'] as String? ?? '';
                      _durationController.text =
                          spell['duration'] as String? ?? '';
                      final proficiency =
                          widget.character['proficiency_bonus'] as int? ?? 2;
                      final attributeValue = widget
                              .character[spell['casting_attribute']] as int? ??
                          0;
                      _saveDcController.text =
                          (8 + proficiency + attributeValue).toString();
                    }
                  } else {
                    _selectedEntry = 'none';
                    _titleController.clear();
                    _descriptionController.clear();
                    _rangeController.clear();
                    _durationController.clear();
                    _saveDcController.clear();
                  }
                });
              },
            ),
        ],
      ),
      const SizedBox(height: 12),
    ];
  }

  Widget _buildAddItem() {
    final screenWidth = MediaQuery.of(context).size.width;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Requires\nequipped\nitem',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            Checkbox(
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
          ],
        ),
        SizedBox(width: screenWidth > 600 ? 48 : 24),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('Expendable', style: Theme.of(context).textTheme.bodyMedium),
            Checkbox(
              value: _expendable,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _expendable = value;
                  });
                }
              },
            ),
          ],
        ),
        SizedBox(width: screenWidth > 600 ? 48 : 24),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Requires Ammo',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
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
                for (final item in items.entries)
                  DropdownMenuItem(
                    value: item.key,
                    child: Text(
                      (item.value as Map)['name'] as String,
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
        const SizedBox(height: 12),
        if (_requiresResource)
          Row(
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
                      Text(
                        'Resource\ncount',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (_formulaController.text.isNotEmpty) {
                              _formulaController.clear();
                            }
                            _resourceCount++;
                          });
                        },
                        icon: const Icon(Icons.add),
                      ),
                      Text(
                        _formulaController.text.isEmpty
                            ? _resourceCount.toString()
                            : 'x',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (_formulaController.text.isNotEmpty) {
                              _formulaController.clear();
                            }
                            if (_resourceCount > 0) {
                              _resourceCount--;
                            }
                          });
                        },
                        icon: const Icon(Icons.remove),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showFormulaDialog(context),
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
                  const SizedBox(height: 8),
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

  void _showFormulaDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Formula'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _formulaController,
                    decoration: InputDecoration(
                      errorText: _isFormulaValid ? null : 'Invalid formula',
                    ),
                    onChanged: (value) {
                      setState(() {
                        var valid = true;
                        try {
                          final asi = Map<String, int>.from(
                            widget.character['asi'] as Map<String, int>? ??
                                {
                                  'strength': 10,
                                  'dexterity': 10,
                                  'constitution': 10,
                                  'intelligence': 10,
                                  'wisdom': 10,
                                  'charisma': 10,
                                },
                          );
                          final t = parseFormula(value, asi, 0, 0);
                          final _ = int.parse(t);
                        } catch (e) {
                          valid = false;
                        }
                        _isFormulaValid = valid;
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: <Widget>[
            IconButton(
              onPressed: () {
                _formulaController.clear();
                setState(() {
                  _isFormulaValid = true;
                });
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.close),
            ),
            IconButton(
              onPressed: () {
                if (_isFormulaValid) {
                  setState(() {
                    if (_formulaController.text.isNotEmpty) {
                      _resourceCount = 0;
                    }
                  });
                  Navigator.of(context).pop();
                }
              },
              icon: const Icon(Icons.check),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExpansionTileFields() {
    return ExpansionTile(
      title: Text(
        'Additional Fields',
        style: Theme.of(context).textTheme.titleSmall,
      ),
      initiallyExpanded: _isAdditionalFieldsExpanded,
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
                    if (_saveDcController.text.isEmpty) {
                      final classSlug = widget.character['class'];
                      final classs = context
                          .read<RulesCubit>()
                          .getClass(classSlug as String);
                      final castingAttribute =
                          classs?['spellcasting_ability'] as String? ?? '';
                      final prefix = castingAttribute.isNotEmpty
                          ? castingAttribute.toLowerCase().substring(0, 3)
                          : '';
                      _saveDcController.text = '8+prof+$prefix';
                    }
                    if (_selectedSaveAttribute == 'None') {
                      _saveDcController.clear();
                    }
                  });
                },
                items: [
                  'None',
                  'Strength',
                  'Dexterity',
                  'Constitution',
                  'Intelligence',
                  'Wisdom',
                  'Charisma',
                ]
                    .map(
                      (attribute) => DropdownMenuItem(
                        value: attribute,
                        child: Text(
                          attribute,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    )
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
                    Text(
                      'Half on Success',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Checkbox(
                      value: _halfOnSuccess,
                      onChanged: (bool? newValue) {
                        setState(() {
                          _halfOnSuccess = newValue!;
                        });
                      },
                    ),
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
            action['type'] = actionType.name;
            String actionSlug = title.trim().replaceAll(' ', '_').toLowerCase();

            switch (actionType) {
              case ActionMenuMode.abilities:
                final ability = _selectedEntry;
                final requiresResource = _requiresResource;
                final resourceType = _resourceType;
                final resourceCount = _resourceCount;
                if (_formulaController.text.isNotEmpty) {
                  action['resource_formula'] = _formulaController.text;
                } else {
                  action['resource_count'] = resourceCount;
                }
                action['ability'] = ability;
                action['requires_resource'] = requiresResource;
                action['resource_type'] = resourceType.name;
              case ActionMenuMode.items:
                final item = _selectedEntry;
                final requiresResource = _requiresResource;
                final expendable = _expendable;
                final ammo = _ammo;
                action['item'] = item;
                action['must_equip'] = requiresResource;
                action['expendable'] = expendable;
                action['ammo'] = ammo;
              case ActionMenuMode.spells:
                if (_selectedEntry != 'none') {
                  final spell = _selectedEntry;
                  action['spell'] = spell;
                }

              default:
                break;
            }

            if (widget.editActionSlug != null) {
              actionSlug = widget.editActionSlug!;
            }

            widget.character['actions'] ??= {};
            final actions = widget.character['actions'] as Map<String, dynamic>;
            if (actionSlug.isNotEmpty) {
              actions[actionSlug] = action;
              final updatedActions =
                  Map<String, Map<String, dynamic>>.from(actions);
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
                final actions =
                    widget.character['actions'] as Map<String, dynamic>;
                actions.remove(widget.editActionSlug);
                final updatedActions =
                    Map<String, Map<String, dynamic>>.from(actions);
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
    _formulaController.dispose();
    super.dispose();
  }
}
