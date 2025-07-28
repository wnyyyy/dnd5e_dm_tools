import 'package:dnd5e_dm_tools/core/data/models/archetype.dart';
import 'package:dnd5e_dm_tools/core/data/models/character.dart';
import 'package:dnd5e_dm_tools/core/data/models/class.dart';
import 'package:dnd5e_dm_tools/core/data/models/feat.dart';
import 'package:dnd5e_dm_tools/core/data/models/race.dart';
import 'package:dnd5e_dm_tools/core/widgets/description_text.dart';
import 'package:dnd5e_dm_tools/core/widgets/generic_list.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character/character_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character/character_event.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character/character_state.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_cubit.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FeatList extends StatefulWidget {
  const FeatList({super.key, required this.slug, this.archetype});
  final String slug;
  final Archetype? archetype;

  @override
  State<FeatList> createState() => _FeatListState();
}

class _FeatListState extends State<FeatList> {
  bool _isEditMode = false;
  List<Feat> _feats = [];

  @override
  void initState() {
    super.initState();
    final characterState = context.read<CharacterBloc>().state;
    if (characterState is CharacterLoaded) {
      _feats = characterState.character.feats;
    }
  }

  @override
  Widget build(BuildContext context) {
    final characterState = context.watch<CharacterBloc>().state;
    final rulesState = context.watch<RulesCubit>().state;
    if (characterState is! CharacterLoaded || rulesState is! RulesStateLoaded) {
      return const SizedBox();
    }
    final race = characterState.race;
    final classs = characterState.classs;
    final character = characterState.character;

    void onItemsChanged(List<Feat> items) {
      setState(() {
        _feats = items;
      });
      context.read<CharacterBloc>().add(
        CharacterUpdate(
          character: character.copyWith(feats: items),
          persistData: true,
        ),
      );
    }

    void onAddItem() {
      showDialog(
        context: context,
        builder: (context) => _AddFeatDialog(
          character: character,
          race: race,
          classs: classs,
          archetype: widget.archetype,
          onItemsChanged: onItemsChanged,
        ),
      );
    }

    void onEditItem(Feat feat, String title, String description) {
      final updatedFeats = List<Feat>.from(character.feats);
      final index = updatedFeats.indexOf(feat);
      if (index != -1) {
        final (desFeat, effectsDesc) = Feat.buildFromDescription(description);
        updatedFeats[index] = feat.copyWith(
          name: title,
          description: desFeat,
          effectsDesc: effectsDesc,
        );
        onItemsChanged(updatedFeats);
      }
    }

    void onFeatSelected(Feat feat) {
      showDialog(
        context: context,
        builder: (context) {
          final screenWidth = MediaQuery.of(context).size.width;
          final screenHeight = MediaQuery.of(context).size.height;
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: screenWidth > 900
                  ? screenWidth * 0.5
                  : screenWidth > 600
                  ? screenWidth * 0.75
                  : screenWidth * 0.9,
              maxHeight: screenHeight * 0.8,
            ),
            child: AlertDialog(
              title: Text(
                feat.name,
                style: feat.name.length > 24
                    ? Theme.of(context).textTheme.titleMedium
                    : Theme.of(context).textTheme.titleLarge,
              ),
              content: SingleChildScrollView(
                child: DescriptionText(
                  inputText: feat.fullDescription,
                  baseStyle: Theme.of(context).textTheme.bodyMedium!,
                ),
              ),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: [
                Visibility(
                  visible: _isEditMode,
                  child: TextButton(
                    onPressed: () {
                      final updatedFeats = List<Feat>.from(character.feats);
                      updatedFeats.removeWhere((f) => f.slug == feat.slug);
                      onItemsChanged(updatedFeats);
                      Navigator.of(context).pop();
                    },
                    child: const Icon(Icons.delete),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close),
                ),
              ],
            ),
          );
        },
      );
    }

    return GenericList(
      items: _feats,
      onAddItem: () => onAddItem(),
      onItemsChanged: onItemsChanged,
      tableName: 'Feats',
      onSelectItem: onFeatSelected,
      onEditItem: onEditItem,
      emptyMessage: 'None',
      displayKeyGetter: (feat) => feat.name,
      descriptionGetter: (feat) => feat.fullDescription,
      slugGetter: (feat) => feat.slug,
      onChangeEditMode: (isEditMode) {
        setState(() {
          _isEditMode = isEditMode;
        });
        if (!isEditMode) {
          onItemsChanged(_feats);
        }
      },
    );
  }
}

class _AddFeatDialog extends StatefulWidget {
  const _AddFeatDialog({
    required this.character,
    required this.race,
    required this.classs,
    required this.onItemsChanged,
    this.archetype,
  });

  final Character character;
  final Race race;
  final Class classs;
  final void Function(List<Feat>) onItemsChanged;
  final Archetype? archetype;

  @override
  State<_AddFeatDialog> createState() => _AddFeatDialogState();
}

class _AddFeatDialogState extends State<_AddFeatDialog> {
  String selectedFilter = 'Character';
  String selectedFeat = 'none';
  String defaultFeatDesc = '';
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final racialFeats = widget.race.getRacialFeatures();
    final classFeats = widget.classs.getFeatures(level: widget.character.level);
    if (widget.archetype != null) {
      classFeats.addAll(widget.archetype!.getFeatures());
    }
    final allFeats =
        (context.read<RulesCubit>().state as RulesStateLoaded).feats;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    void updateTextFields(String title, String desc) {
      titleController.text = title;
      descriptionController.text = desc;
    }

    List<DropdownMenuItem<String>> getDropdownItems(List<Feat> feats) {
      if (feats.isEmpty) {
        return const [DropdownMenuItem(value: 'none', child: Text('None'))];
      }
      return [
        const DropdownMenuItem(value: 'none', child: Text('None')),
        ...feats.map(
          (entry) => DropdownMenuItem(
            value: entry.slug,
            child: Text(
              entry.name,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
      ];
    }

    Widget buildDropdown(String label, List<Feat> feats) {
      final items = getDropdownItems(feats);
      return DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
        ),
        items: items,
        value: selectedFeat,
        onChanged: (value) {
          setState(() {
            selectedFeat = value ?? 'none';
            if (value != null && value != 'none') {
              final feat = feats.firstWhere(
                (f) => f.slug == value,
                orElse: () => const Feat(
                  slug: 'none',
                  name: '',
                  description: '',
                  effectsDesc: [],
                ),
              );
              if (selectedFilter == 'Character') {
                defaultFeatDesc = feat.fullDescription;
              } else {
                defaultFeatDesc = '';
              }
              updateTextFields(feat.name, feat.fullDescription);
            } else {
              titleController.clear();
              descriptionController.clear();
            }
          });
        },
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: screenWidth > 900
            ? screenWidth * 0.5
            : screenWidth > 600
            ? screenWidth * 0.75
            : screenWidth * 0.9,
        maxHeight: screenHeight * 0.8,
      ),
      child: AlertDialog(
        title: const Text('Select a Feat'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 8.0,
                children: [
                  ChoiceChip(
                    label: Text(
                      'Character',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    selected: selectedFilter == 'Character',
                    onSelected: (selected) {
                      selectedFeat = 'none';
                      setState(() => selectedFilter = 'Character');
                    },
                  ),
                  ChoiceChip(
                    label: Text(
                      'Racial',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    selected: selectedFilter == 'Racial',
                    onSelected: (selected) {
                      selectedFeat = 'none';
                      setState(() => selectedFilter = 'Racial');
                    },
                  ),
                  ChoiceChip(
                    label: Text(
                      'Class',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    selected: selectedFilter == 'Class',
                    onSelected: (selected) {
                      selectedFeat = 'none';
                      setState(() => selectedFilter = 'Class');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (selectedFilter == 'Racial')
                buildDropdown('Racial Feat', racialFeats),
              if (selectedFilter == 'Class')
                buildDropdown('Class Feat', classFeats),
              if (selectedFilter == 'Character')
                buildDropdown('Character Feat', allFeats),
              const SizedBox(height: 24),
              TextField(
                decoration: const InputDecoration(labelText: 'Title'),
                controller: titleController,
              ),
              TextField(
                minLines: 3,
                maxLines: null,
                decoration: const InputDecoration(labelText: 'Description'),
                controller: descriptionController,
              ),
            ],
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Icon(Icons.close),
          ),
          TextButton(
            onPressed: () {
              final (description, effectsDesc) = Feat.buildFromDescription(
                descriptionController.text,
              );
              widget.onItemsChanged(
                widget.character.feats..add(
                  Feat(
                    slug: titleController.text,
                    name: titleController.text,
                    description: description,
                    effectsDesc: effectsDesc,
                  ),
                ),
              );
              Navigator.of(context).pop();
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
