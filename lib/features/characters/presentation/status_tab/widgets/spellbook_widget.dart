import 'package:dnd5e_dm_tools/core/data/models/character.dart';
import 'package:dnd5e_dm_tools/core/data/models/class.dart';
import 'package:dnd5e_dm_tools/core/data/models/spell.dart';
import 'package:dnd5e_dm_tools/core/util/enum.dart';
import 'package:dnd5e_dm_tools/core/util/helper.dart';
import 'package:dnd5e_dm_tools/core/util/logger.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/status_tab/widgets/spell_info.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_cubit.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

class SpellbookWidget extends StatefulWidget {
  const SpellbookWidget({
    super.key,
    required this.character,
    required this.classs,
    required this.onCharacterUpdated,
  });
  final Character character;
  final Class classs;
  final ValueChanged<Character> onCharacterUpdated;

  @override
  SpellbookWidgetState createState() => SpellbookWidgetState();
}

class SpellbookWidgetState extends State<SpellbookWidget> {
  String searchText = '';
  TextEditingController textEditingController = TextEditingController();

  late List<String> knownSpells;
  late Map<String, bool> preparedSpells;

  @override
  void initState() {
    super.initState();
    knownSpells = widget.character.spellbook.knownSpells;
    preparedSpells = widget.character.spellbook.preparedSpells;
    if (!classPreparesSpells(widget.classs.slug)) {
      preparedSpells = Map.fromEntries(
        knownSpells.map((spell) => MapEntry(spell, true)),
      );
    }
  }

  List<Widget> _buildSearchResults(int maxSpellLevel) {
    final rulesState = context.read<RulesCubit>().state;
    if (rulesState is! RulesStateLoaded) {
      logUI('Rules not loaded', level: Level.warning);
      return [];
    }
    final spellList = <Spell>[];
    for (int i = 0; i <= maxSpellLevel; i++) {
      final spells = rulesState.spellMapByLevel[i] ?? [];
      spellList.addAll(spells);
    }
    final List<Widget> searchResults = [];
    if (searchText.isEmpty) {
      return searchResults;
    }

    final List<Spell> matchingEntries = [];
    for (final entry in spellList) {
      if (entry.name.toLowerCase().contains(searchText.toLowerCase())) {
        final duplicates = matchingEntries.where((e) => e.name == entry.name);
        if (duplicates.isEmpty) {
          matchingEntries.add(entry);
        } else {
          final toRemove = duplicates.reduce(
            (a, b) => a.slug.length < b.slug.length ? a : b,
          );
          matchingEntries.remove(toRemove);
          if (toRemove.slug.length < entry.slug.length) {
            matchingEntries.add(entry);
          }
        }
      }
    }

    matchingEntries.sort((a, b) {
      final int levelA = a.level;
      final int levelB = b.level;
      return levelA.compareTo(levelB);
    });

    for (final spell in matchingEntries) {
      searchResults.add(
        ListTile(
          title: Text(spell.name),
          subtitle: Row(
            children: [
              Text(spell.levelText),
              const Spacer(),
              Text(spell.school.name),
            ],
          ),
          onTap: () {
            _showSpellDialog(spell);
          },
        ),
      );
    }

    return searchResults;
  }

  Widget _buildSpellList(int level, Map<int, List<Spell>> spellMap) {
    final List<String> spellSlugs = widget.character.spellbook.knownSpells;
    if (spellSlugs.isEmpty) {
      return Container();
    }
    final List<Spell> spells = [];
    final spellsLvl = spellMap[level] ?? [];
    for (final spellSlug in spellSlugs) {
      final Spell spell;
      try {
        spell = spellsLvl.firstWhere((s) => s.slug == spellSlug);
      } catch (e) {
        continue;
      }
      spells.add(spell);
    }
    if (spells.isEmpty) {
      return Container();
    }

    final String label = spells.first.levelTextPlural;
    final String spellCountLabel =
        '${spells.length} ${spells.length == 1 ? 'spell' : 'spells'}';
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ExpansionTile(
        title: Text(label),
        subtitle: Row(children: [Text(spellCountLabel)]),
        children: [
          for (final entry in spells)
            ListTile(
              title: Text(entry.name),
              subtitle: Text(
                entry.school.name,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: entry.school.color,
                ),
              ),
              onTap: () {
                _showSpellDialog(entry);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSpellSlotsList() {
    final Map<int, int> slots = {};
    final classsSpellSlots = widget.classs.getSpellSlotsForLevel(
      widget.character.level,
    );
    if (classsSpellSlots.isEmpty) {
      final isMagicInitiate = widget.character.feats.any(
        (feat) =>
            feat.name.toLowerCase().contains('magic_initiate') ||
            feat.name.toLowerCase().contains('magic-initiate'),
      );
      if (isMagicInitiate) {
        slots[1] = 1;
      }
    } else {
      for (int i = 1; i <= 9; i++) {
        slots[i] = classsSpellSlots[i] ?? 0;
      }
    }
    if (slots.isEmpty) {
      return Container();
    }

    final expendedSlots = widget.character.spellbook.expendedSpellSlots;

    final List<Padding> texts = [];
    for (final entry in slots.entries) {
      if (entry.value == 0) {
        continue;
      }
      texts.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card.filled(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${getOrdinal(entry.key)} Level',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total: ${entry.value}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (expendedSlots.containsKey(entry.key))
                        Text(
                          'Expended: ${expendedSlots[entry.key]}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onLongPress: () => _editSpellSlots(context, expendedSlots, slots),
        child: ExpansionTile(title: const Text('Spell Slots'), children: texts),
      ),
    );
  }

  void _editSpellSlots(
    BuildContext context,
    Map<int, int> expended,
    Map<int, int> total,
  ) {
    final Map<int, int> slots = Map<int, int>.from(
      expended.map((key, value) => MapEntry(key, total[key]! - value)),
    );
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Spell Slots'),
          content: SizedBox(
            width: screenWidth * 0.9 > 250 ? 250 : screenWidth * 0.9,
            height: screenHeight * 0.7 > 400 ? 400 : screenHeight * 0.7,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return ListView.builder(
                  itemBuilder: (context, index) {
                    final level = index + 1;
                    final max = total[level] ?? 0;
                    final curr = slots[level] ?? max;

                    return ListTile(
                      title: Text('${getOrdinal(level)} Level'),
                      subtitle: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  slots[level] = (slots[level] ?? max) - 1;
                                  if (slots[level]! < 0) {
                                    slots[level] = 0;
                                  }
                                });
                              },
                              iconSize: 32,
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                          ),
                          Text(
                            '$curr/$max',
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  slots[level] = (slots[level] ?? max) + 1;
                                  if (slots[level]! > max) {
                                    slots[level] = max;
                                  }
                                });
                              },
                              iconSize: 32,
                              icon: const Icon(Icons.add_circle_outline),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  itemCount: total.length,
                );
              },
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Icon(Icons.close),
            ),
            TextButton(
              onPressed: () {
                final expendedNew = Map<int, int>.from(expended);
                for (final entry in slots.entries) {
                  expendedNew[entry.key] = total[entry.key]! - entry.value;
                }
                final updatedCharacter = widget.character.copyWith(
                  spellbook: widget.character.spellbook.copyWith(
                    expendedSpellSlots: expendedNew,
                  ),
                );
                widget.onCharacterUpdated(updatedCharacter);
                Navigator.of(context).pop();
              },
              child: const Icon(Icons.done),
            ),
          ],
        );
      },
    );
  }

  void _showSpellDialog(Spell spell) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SpellInfo(
          spell: spell,
          character: widget.character,
          classPreparesSpells: classPreparesSpells(widget.classs.slug),
          onCharacterUpdated: widget.onCharacterUpdated,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final rulesState = context.read<RulesCubit>().state;
    if (rulesState is! RulesStateLoaded) {
      logUI('Rules not loaded', level: Level.warning);
      return const SizedBox.shrink();
    }
    final spellsMapByLevel = rulesState.spellMapByLevel;
    int highestSpellSlotLevel = widget.classs.getHighestSpellSlotLevel(
      widget.character.level,
    );
    if (highestSpellSlotLevel == 0) {
      if (widget.character.feats.any(
        (feat) =>
            feat.name.toLowerCase().contains('magic_initiate') ||
            feat.name.toLowerCase().contains('magic-initiate'),
      )) {
        highestSpellSlotLevel = 1;
      } else {
        return const SizedBox.shrink();
      }
    }
    final searchResults = _buildSearchResults(highestSpellSlotLevel);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final List<Widget> spellLists = List.generate(
      10,
      (i) => _buildSpellList(i, spellsMapByLevel),
      growable: false,
    );
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: screenWidth * 0.75,
        maxHeight: screenHeight * 0.75,
        minWidth: screenWidth * 0.5,
        minHeight: screenHeight * 0.5,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: textEditingController,
              onChanged: (value) {
                setState(() {
                  searchText = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                labelText: 'Search Spells',
                border: const OutlineInputBorder(),
                suffixIcon: searchText.isEmpty
                    ? const Icon(Icons.search)
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.done),
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                searchText = '';
                                textEditingController.clear();
                              });
                            },
                          ),
                        ],
                      ),
              ),
            ),
          ),
          Expanded(
            child: SizedBox(
              width: screenWidth * 0.85 > 400 ? 400 : screenWidth * 0.85,
              child: searchText.isNotEmpty
                  ? Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: searchResults.isEmpty
                          ? const Center(child: Text('No spells found'))
                          : ListView.separated(
                              itemCount: searchResults.length,
                              itemBuilder: (context, index) {
                                return searchResults[index];
                              },
                              separatorBuilder: (context, index) =>
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                    ),
                                    child: Divider(),
                                  ),
                            ),
                    )
                  : Column(
                      children: [
                        if (knownSpells.isNotEmpty)
                          Expanded(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: screenWidth > 600
                                    ? screenWidth * 0.5
                                    : screenWidth * 0.9,
                                minWidth: screenWidth * 0.5,
                              ),
                              child: ListView(children: spellLists),
                            ),
                          ),
                        _buildSpellSlotsList(),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }
}
