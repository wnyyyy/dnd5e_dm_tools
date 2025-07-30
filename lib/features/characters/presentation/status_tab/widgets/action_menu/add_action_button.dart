import 'package:dnd5e_dm_tools/core/data/models/action.dart';
import 'package:dnd5e_dm_tools/core/data/models/action_resource.dart';
import 'package:dnd5e_dm_tools/core/data/models/character.dart';
import 'package:dnd5e_dm_tools/core/data/models/class.dart';
import 'package:dnd5e_dm_tools/core/data/models/feat.dart';
import 'package:dnd5e_dm_tools/core/data/models/item.dart';
import 'package:dnd5e_dm_tools/core/data/models/race.dart';
import 'package:dnd5e_dm_tools/core/data/models/spell.dart';
import 'package:dnd5e_dm_tools/core/util/enum.dart';
import 'package:dnd5e_dm_tools/core/util/helper.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/status_tab/widgets/action_menu/action_category_row.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_cubit.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_state.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:flutter_bloc/flutter_bloc.dart';

class AddActionButton extends StatelessWidget {
  const AddActionButton({
    required this.character,
    required this.classs,
    required this.race,
    required this.onActionsChanged,
    this.action,
    super.key,
  });
  final Character character;
  final Class classs;
  final Race race;
  final Action? action;
  final ValueChanged<List<Action>> onActionsChanged;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => showDialog(
        context: context,
        builder: (BuildContext context) => _AddActionDialog(
          character: character,
          action: action,
          classs: classs,
          race: race,
          onActionsChanged: onActionsChanged,
        ),
        barrierDismissible: false,
      ),
      icon: action != null ? const Icon(Icons.edit) : const Icon(Icons.add),
    );
  }
}

class _AddActionDialog extends StatefulWidget {
  const _AddActionDialog({
    required this.character,
    required this.classs,
    required this.race,
    this.action,
    required this.onActionsChanged,
  });
  final Character character;
  final Class classs;
  final Race race;
  final Action? action;
  final ValueChanged<List<Action>> onActionsChanged;

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
  final TextEditingController _sharedResourceController =
      TextEditingController();
  final TextEditingController _customResourceShortRestController =
      TextEditingController();
  final TextEditingController _customResourceLongRestController =
      TextEditingController();

  ActionType _selected = ActionType.ability;
  ResourceType _resourceType = ResourceType.none;
  bool _requiresResource = false;
  bool _expendable = false;
  String _ammo = 'none';
  int _resourceCount = 0;
  String _selectedEntry = 'none';
  final Map<String, Feat> charFeats = {};
  final Map<String, Feat> classFeats = {};
  final Map<String, Feat> archetypeFeats = {};
  final Map<String, Feat> raceFeats = {};
  final Map<String, Item> items = {};
  final Map<String, Spell> spells = {};
  String _selectedSaveAttribute = 'None';
  bool _halfOnSuccess = false;
  bool _isAdditionalFieldsExpanded = false;
  bool _isFormulaValid = true;

  @override
  void initState() {
    super.initState();
    final rulesState = context.read<RulesCubit>().state;
    final classFeats = widget.classs.getFeatures(level: widget.character.level);
    for (final feat in classFeats) {
      if (feat.slug != 'Ability Score Improvement') {
        this.classFeats[feat.slug] = feat;
      }
    }
    final archetype = widget.classs.getArchetype(
      widget.character.archetype ?? '',
    );
    final subclassFeats = archetype?.getFeatures() ?? <Feat>[];
    for (final feat in subclassFeats) {
      archetypeFeats[feat.slug] = feat;
    }
    final racialFeats = widget.race.getRacialFeatures();
    for (final feat in racialFeats) {
      raceFeats[feat.slug] = feat;
    }

    for (final spellSlug in widget.character.spellbook.knownSpells) {
      if (rulesState is RulesStateLoaded) {
        final spell = rulesState.spellMap[spellSlug];
        if (spell != null) {
          spells[spell.slug] = spell;
        }
      }
    }

    final characterBackpack = widget.character.backpack;
    final characterItems = characterBackpack.items;
    for (final charItem in characterItems) {
      if (rulesState is RulesStateLoaded) {
        final item = rulesState.itemMap[charItem.itemSlug];
        if (item != null) {
          items[item.slug] = item;
        }
      }
    }

    if (widget.action != null) {
      final action = widget.action!;
      final actionType = action.type;
      _selected = actionType;
      _descriptionController.text = action.description;
      _titleController.text = action.title;
      final fields = action.fields;
      _healController.text = fields.heal ?? '';
      _damageController.text = fields.damage ?? '';
      _attackController.text = fields.attack ?? '';
      _saveDcController.text = fields.saveDc ?? '';
      _areaController.text = fields.area ?? '';
      _rangeController.text = fields.range ?? '';
      _conditionsController.text = fields.conditions ?? '';
      _durationController.text = fields.duration ?? '';
      _castTimeController.text = fields.castTime ?? '';
      _typeController.text = fields.type ?? '';
      _selectedSaveAttribute = fields.saveAttribute ?? 'None';
      _halfOnSuccess = fields.halfOnSuccess ?? false;
      _isAdditionalFieldsExpanded = true;

      switch (actionType) {
        case ActionType.ability:
          _selectedEntry = (action as ActionAbility).ability;
          _requiresResource = action.requiresResource;
          _resourceType = ResourceType.values.firstWhere(
            (e) => e == action.resourceType,
            orElse: () => ResourceType.none,
          );
          _resourceCount = action.resourceCount ?? 0;
          _formulaController.text = action.resourceFormula;
          _customResourceLongRestController.text =
              action.customResource?.longRest ?? 'all';
          _customResourceShortRestController.text =
              action.customResource?.shortRest ?? '0';
          _sharedResourceController.text =
              action.customResource?.name ?? 'None';
        case ActionType.item:
          _selectedEntry = (action as ActionItem).itemSlug;
          _requiresResource = action.mustEquip;
          _expendable = action.expendable;
          _ammo = action.ammo ?? 'none';
        case ActionType.spell:
          _selectedEntry = (action as ActionSpell).spellSlug;
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
            maxHeight: screenHeight * 0.9,
            minHeight: screenHeight * 0.9,
          ),
          child: Scrollbar(
            thumbVisibility: true,
            controller: _scrollController,
            child: SingleChildScrollView(
              controller: _scrollController,
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
                              _selected = selected.types.first;
                            });
                          },
                        ),
                        _buildSectionedList(context),
                        const SizedBox(height: 12),
                        if (_selected == ActionType.item) _buildAddItem(),
                        if (_selected == ActionType.ability) _buildAddAbility(),
                        const SizedBox(height: 24, child: Divider()),
                        _buildCommonFields(),
                        _buildExpansionTileFields(),
                        const SizedBox(height: 24, child: Divider()),
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
          decoration: const InputDecoration(labelText: 'Title'),
        ),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(labelText: 'Description'),
          minLines: 3,
          maxLines: 10,
        ),
      ],
    );
  }

  Widget _buildSectionedList(BuildContext context) {
    final List<Widget> options = [];
    final rulesState = context.read<RulesCubit>().state;
    if (rulesState is! RulesStateLoaded) {
      return const SizedBox();
    }
    switch (_selected) {
      case ActionType.ability:
        if (archetypeFeats.isNotEmpty) {
          options.addAll(_buildSection('Archetype', archetypeFeats));
        }
        if (classFeats.isNotEmpty) {
          options.addAll(_buildSection('Class feats', classFeats));
        }
        if (raceFeats.isNotEmpty) {
          options.addAll(_buildSection('Racial feats', raceFeats));
        }
      case ActionType.item:
        final equipableItems = Map.fromEntries(
          items.entries.where((entry) => entry.value is Equipable).toList(),
        );
        if (equipableItems.isNotEmpty) {
          options.addAll(_buildSection('Equippable', equipableItems));
        }
        final misc = Map.fromEntries(
          items.entries.where((entry) => entry.value is! Equipable).toList(),
        );
        if (misc.isNotEmpty) {
          options.addAll(_buildSection('Misc', misc));
        }
      case ActionType.spell:
        final cantrips = Map.fromEntries(
          spells.entries.where((entry) => entry.value.level == 0).toList(),
        );
        if (cantrips.isNotEmpty) {
          options.addAll(_buildSection('Cantrips', cantrips));
        }
        for (var i = 1; i < 10; i++) {
          final spellsByLevel = Map.fromEntries(
            spells.entries.where((entry) => entry.value.level == i).toList(),
          );
          if (spellsByLevel.isNotEmpty) {
            options.addAll(_buildSection('Level $i', spellsByLevel));
          }
        }
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: options,
      ),
    );
  }

  List<Widget> _buildSection(String label, Map<String, dynamic> items) {
    final List<Widget> widgets = [];
    widgets.add(
      Text(label.toUpperCase(), style: Theme.of(context).textTheme.titleSmall),
    );
    widgets.add(SizedBox(width: label.length * 10, child: const Divider()));

    final List<Widget> chips = [];
    for (final entry in items.entries) {
      final value = entry.value;
      final String chipLabel = value is String
          ? entry.key
          : value is Spell
          ? value.name
          : value is Item
          ? value.name
          : value is Feat
          ? value.name
          : entry.key;

      final String titleText = chipLabel;
      final String descriptionText = value is String
          ? value
          : value is Spell
          ? value.fullDesc
          : value is Item
          ? ''
          : value is Feat
          ? value.fullDescription
          : '';

      chips.add(
        ChoiceChip(
          labelPadding: EdgeInsets.zero,
          showCheckmark: false,
          label: Text(chipLabel, style: Theme.of(context).textTheme.labelSmall),
          selected: _selectedEntry == entry.key,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedEntry = entry.key;
                _titleController.text = titleText;
                _descriptionController.text = descriptionText;

                if (_selected == ActionType.spell && entry.value is Spell) {
                  final spell = entry.value as Spell;
                  _rangeController.text = spell.range;
                  _durationController.text = spell.duration;
                  _castTimeController.text = spell.castingTime;
                }
                if (_selected == ActionType.item && entry.value is Item) {
                  if (entry.value is Weapon) {
                    final weapon = entry.value as Weapon;
                    _rangeController.text = '${weapon.range}';
                    if (weapon.longRange != null) {
                      _rangeController.text += '| ${weapon.longRange} ft';
                    } else {
                      _rangeController.text += ' ft';
                    }
                    _damageController.text = weapon.damage.dice;
                    if (weapon.twoHandedDamage != null) {
                      _damageController.text +=
                          '|${weapon.twoHandedDamage?.dice ?? ''}';
                    }
                    final isDex =
                        weapon.weaponCategory == WeaponCategory.martialRanged ||
                        weapon.weaponCategory == WeaponCategory.simpleRanged;
                    _damageController.text += isDex ? '+dex' : '+str';
                    _attackController.text = isDex ? 'dex' : 'str';
                    _attackController.text += '+prof';
                    _typeController.text = weapon.damage.type.name;
                  }
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
      );
    }

    widgets.add(Wrap(spacing: 4, children: chips));
    widgets.add(const SizedBox(height: 12));
    return widgets;
  }

  Widget _buildAddItem() {
    final screenWidth = MediaQuery.of(context).size.width;
    return Flex(
      direction: screenWidth > 600 ? Axis.horizontal : Axis.vertical,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flex(
          direction: screenWidth > 600 ? Axis.vertical : Axis.horizontal,
          mainAxisAlignment: screenWidth > 600
              ? MainAxisAlignment.end
              : MainAxisAlignment.center,
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
        Flex(
          direction: screenWidth > 600 ? Axis.vertical : Axis.horizontal,
          mainAxisAlignment: screenWidth > 600
              ? MainAxisAlignment.end
              : MainAxisAlignment.center,
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
        Flex(
          direction: screenWidth > 600 ? Axis.vertical : Axis.horizontal,
          mainAxisAlignment: screenWidth > 600
              ? MainAxisAlignment.end
              : MainAxisAlignment.center,
          children: [
            Padding(
              padding: screenWidth > 600
                  ? EdgeInsets.zero
                  : const EdgeInsets.only(right: 16),
              child: Text(
                'Requires\nAmmo',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
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
                      item.value.name,
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
    final sharedResources = widget.character.sharedActionResources;
    final List<DropdownMenuEntry<String>> sharedResourceItems = [
      const DropdownMenuEntry<String>(value: 'None', label: 'None'),
      ...sharedResources.values.map(
        (sr) => DropdownMenuEntry<String>(value: sr.name, label: sr.name),
      ),
    ];
    // Ensure the current value is present
    if (_sharedResourceController.text.isNotEmpty &&
        !sharedResourceItems.any(
          (e) => e.value == _sharedResourceController.text,
        )) {
      sharedResourceItems.add(
        DropdownMenuEntry<String>(
          value: _sharedResourceController.text,
          label: _sharedResourceController.text,
        ),
      );
    }
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
              if (_resourceType == ResourceType.custom)
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
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 200),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                'Shared resource',
                                style: Theme.of(context).textTheme.bodySmall,
                                textAlign: TextAlign.start,
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                tooltip: 'Add new shared resource',
                                onPressed: () async {
                                  final TextEditingController
                                  newResourceController =
                                      TextEditingController();
                                  final result = await showDialog<String>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Add Shared Resource'),
                                      titleTextStyle: Theme.of(
                                        context,
                                      ).textTheme.titleSmall,
                                      content: TextField(
                                        controller: newResourceController,
                                        decoration: const InputDecoration(
                                          labelText: 'Resource Name',
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(
                                              newResourceController.text.trim(),
                                            );
                                          },
                                          child: const Text('Add'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (result != null && result.isNotEmpty) {
                                    setState(() {
                                      _sharedResourceController.text = result;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                          DropdownMenu<String>(
                            initialSelection:
                                _sharedResourceController.text.isEmpty
                                ? 'None'
                                : _sharedResourceController.text,
                            controller: _sharedResourceController,
                            dropdownMenuEntries: sharedResourceItems,
                            onSelected: (String? value) {
                              setState(() {
                                _sharedResourceController.text = value ?? '';
                                final customResource =
                                    widget
                                        .character
                                        .sharedActionResources[_sharedResourceController
                                        .text];
                                if (customResource != null) {
                                  _customResourceShortRestController.text =
                                      customResource.shortRest;
                                  _customResourceLongRestController.text =
                                      customResource.longRest;
                                  _formulaController.text =
                                      customResource.formula;
                                } else {
                                  _customResourceShortRestController.text = '0';
                                  _customResourceLongRestController.text =
                                      'all';
                                  _formulaController.clear();
                                }
                              });
                            },
                            textStyle: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          const SizedBox(height: 8, child: Divider()),
                          const SizedBox(height: 16),
                          Text(
                            'Recharge',
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller:
                                      _customResourceShortRestController,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    labelStyle: Theme.of(
                                      context,
                                    ).textTheme.labelMedium,
                                    labelText: 'Short rest',
                                    border: const OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 2),
                              Expanded(
                                child: TextFormField(
                                  controller: _customResourceLongRestController,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    labelText: 'Long rest',
                                    labelStyle: Theme.of(
                                      context,
                                    ).textTheme.labelMedium,
                                    border: const OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          TextFormField(
                            controller: _formulaController,
                            decoration: InputDecoration(
                              isDense: true,
                              labelText: 'Resource count formula',
                              labelStyle: Theme.of(context).textTheme.bodySmall,
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (_resourceType != ResourceType.custom)
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
                        _formulaController.clear();
                        _sharedResourceController.text = 'None';
                        _customResourceShortRestController.text = '0';
                        _customResourceLongRestController.text = 'all';
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
                        _formulaController.clear();
                        _sharedResourceController.clear();
                        _sharedResourceController.text = 'None';
                        _customResourceShortRestController.text = '0';
                        _customResourceLongRestController.text = 'all';
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  ChoiceChip(
                    label: const Text('Custom'),
                    selected: _resourceType == ResourceType.custom,
                    onSelected: (selected) {
                      setState(() {
                        _resourceType = ResourceType.custom;
                        _formulaController.clear();
                        _sharedResourceController.clear();
                        _sharedResourceController.text = 'None';
                        _customResourceShortRestController.text = '0';
                        _customResourceLongRestController.text = 'all';
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
                          final asi = widget.character.asi;
                          final t = parseFormula(value, asi, 0, 0, widget.classs.table);
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
              child: DropdownButtonFormField<String>(
                value: _typeController.text.isNotEmpty
                    ? _typeController.text
                    : 'None',

                decoration: const InputDecoration(
                  labelText: 'Type',
                  labelStyle: TextStyle(fontSize: 12),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: 'None',
                    child: Text('None'),
                  ),
                  ...DamageType.values.map(
                    (dt) => DropdownMenuItem<String>(
                      value: dt.name,
                      child: Text(dt.name),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _typeController.text = value == 'None' ? '' : value ?? '';
                  });
                },
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
                      final castingAttribute =
                          widget.classs.spellCastingAbility ??
                          Attribute.intelligence;
                      final prefix = castingAttribute.prefix;
                      _saveDcController.text = '8+prof+$prefix';
                    }
                    if (_selectedSaveAttribute == 'None') {
                      _saveDcController.clear();
                    }
                  });
                },
                items:
                    [
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
        if (widget.action != null)
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
            final fields = ActionFields(
              heal: _healController.text,
              damage: _damageController.text,
              attack: _attackController.text,
              saveDc: _saveDcController.text,
              saveAttribute: _selectedSaveAttribute,
              halfOnSuccess: _halfOnSuccess,
              area: _areaController.text,
              range: _rangeController.text,
              conditions: _conditionsController.text,
              duration: _durationController.text,
              castTime: _castTimeController.text,
              type: _typeController.text,
            );
            final description = _descriptionController.text;
            final title = _titleController.text;
            final String actionSlug = title
                .trim()
                .replaceAll(' ', '_')
                .toLowerCase();

            Action newAction;

            switch (actionType) {
              case ActionType.ability:
                if (!_requiresResource) {
                  _resourceCount = 0;
                  _formulaController.clear();
                  _resourceType = ResourceType.none;
                }
                newAction = ActionAbility(
                  slug: widget.action?.slug ?? actionSlug,
                  title: title,
                  description: description,
                  fields: fields,
                  ability: _selectedEntry,
                  requiresResource: _requiresResource,
                  resourceType: _resourceType,
                  resourceCount: _formulaController.text.isNotEmpty
                      ? null
                      : _resourceCount,
                  resourceFormula: _formulaController.text.isNotEmpty
                      ? _formulaController.text
                      : '',
                  customResource: _resourceType == ResourceType.custom
                      ? ActionResource(
                          name: _sharedResourceController.text,
                          formula: _formulaController.text,
                          shortRest: _customResourceShortRestController.text,
                          longRest: _customResourceLongRestController.text,
                        )
                      : null,
                );
              case ActionType.item:
                newAction = ActionItem(
                  slug: widget.action?.slug ?? actionSlug,
                  title: title,
                  description: description,
                  fields: fields,
                  itemSlug: _selectedEntry,
                  mustEquip: _requiresResource,
                  expendable: _expendable,
                  ammo: _ammo,
                );
              case ActionType.spell:
                newAction = ActionSpell(
                  slug: widget.action?.slug ?? actionSlug,
                  title: title,
                  description: description,
                  fields: fields,
                  spellSlug: _selectedEntry != 'none' ? _selectedEntry : '',
                );
            }

            final List<Action> newActions = List<Action>.from(
              widget.character.actions,
            );
            final existingIndex = newActions.indexWhere(
              (a) => a.slug == newAction.slug,
            );
            if (existingIndex != -1) {
              newActions[existingIndex] = newAction;
            } else {
              newActions.add(newAction);
            }
            widget.onActionsChanged(newActions);

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
                final List<Action> newActions = List<Action>.from(
                  widget.character.actions,
                );
                final index = newActions.indexWhere(
                  (a) => a.slug == widget.action?.slug,
                );
                if (index != -1) {
                  newActions.removeAt(index);
                  widget.onActionsChanged(newActions);
                }
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
    _sharedResourceController.dispose();
    _customResourceShortRestController.dispose();
    _customResourceLongRestController.dispose();
    super.dispose();
  }
}
