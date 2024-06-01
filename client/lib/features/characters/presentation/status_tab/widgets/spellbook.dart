import 'package:dnd5e_dm_tools/core/util/helper.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/status_tab/widgets/spell_info.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recase/recase.dart';

class Spellbook extends StatefulWidget {
  const Spellbook({
    super.key,
    required this.character,
    required this.spells,
    required this.slug,
    required this.table,
    this.updateCharacter,
  });
  final Map<String, dynamic> character;
  final String slug;
  final Map<String, dynamic> spells;
  final List<Map<String, dynamic>> table;
  final VoidCallback? updateCharacter;

  @override
  SpellbookState createState() => SpellbookState();
}

class SpellbookState extends State<Spellbook> {
  String searchText = '';
  List<String> knownSpells = [];
  Map<String, bool> preparedSpells = {};
  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.character.containsKey('known_spells')) {
      knownSpells =
          List<String>.from(widget.character['known_spells'] as List<dynamic>);
    }
    if (widget.character.containsKey('prepared_spells')) {
      preparedSpells = Map<String, bool>.from(
        widget.character['prepared_spells'] as Map<dynamic, dynamic>,
      );
    }
  }

  List<Widget> _buildSearchResults() {
    final List<Widget> searchResults = [];
    if (searchText.isEmpty) {
      return searchResults;
    }

    final List<MapEntry<String, dynamic>> matchingEntries = [];
    for (final entry in widget.spells.entries) {
      final spell = entry.value as Map<String, dynamic>;
      if (spell['name']
              ?.toString()
              .toLowerCase()
              .contains(searchText.toLowerCase()) ??
          false) {
        matchingEntries.add(entry);
      }
    }

    matchingEntries.sort(
      (a, b) {
        final int levelA = (a.value as Map)['level_int'] as int? ?? 0;
        final int levelB = (b.value as Map)['level_int'] as int? ?? 0;
        return levelA.compareTo(levelB);
      },
    );

    for (final entry in matchingEntries) {
      final spell = entry.value as Map<String, dynamic>;
      searchResults.add(
        ListTile(
          title: Text(spell['name']?.toString() ?? ''),
          subtitle: Row(
            children: [
              Text(spell['level']?.toString() ?? ''),
              const Spacer(),
              Text(spell['school'].toString().sentenceCase),
            ],
          ),
          onTap: () {
            _showSpellDialog(entry.key);
          },
        ),
      );
    }

    return searchResults;
  }

  Widget _buildSpellList(int level) {
    final List<dynamic> spellSlugs =
        widget.character['known_spells'] as List<dynamic>? ?? [];
    if (spellSlugs.isEmpty) {
      return Container();
    }
    final List<MapEntry<String, dynamic>> spells = [];
    for (final spellSlug in spellSlugs) {
      var spell = widget.spells[spellSlug] as Map<String, dynamic>?;
      spell ??= context.read<RulesCubit>().getAllSpells()[spellSlug]
              as Map<String, dynamic>? ??
          {};
      if (spell['level_int'] == level) {
        spells.add(MapEntry(spellSlug as String, spell));
      }
    }
    if (spells.isEmpty) {
      return Container();
    }
    final String label = level == 0
        ? 'Cantrips'
        : '${(spells[0].value as Map?)?['level']} spells';
    final String spellCountLabel =
        '${spells.length} ${spells.length == 1 ? 'spell' : 'spells'}';
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ExpansionTile(
        title: Text(label),
        subtitle: Row(
          children: [
            Text(spellCountLabel),
          ],
        ),
        children: [
          for (final entry in spells)
            ListTile(
              title: Text((entry.value as Map)['name']?.toString() ?? ''),
              subtitle:
                  Text((entry.value as Map)['school'].toString().sentenceCase),
              onTap: () {
                _showSpellDialog(entry.key);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSpellSlotsList() {
    final Map<int, int> slots = getSpellSlotsForLevel(
      widget.table,
      widget.character['level'] as int? ?? 1,
    );
    final expendedSlots = getExpendedSlots(widget.character);

    final List<Padding> texts = [];
    for (final entry in slots.entries) {
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
                      if (expendedSlots.containsKey(entry.key.toString()))
                        Text(
                          'Used: ${expendedSlots[entry.key.toString()]}',
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
        child: ExpansionTile(
          title: const Text('Spell Slots'),
          children: texts,
        ),
      ),
    );
  }

  void _editSpellSlots(
    BuildContext context,
    Map<String, int> expended,
    Map<int, int> total,
  ) {
    final Map<int, int> slots = Map<int, int>.from(
      expended.map((key, value) => MapEntry(int.parse(key), value)),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Spell Slots'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return ListView.builder(
                itemBuilder: (context, index) {
                  final level = index + 1;
                  final max = total[level] ?? 0;
                  final curr =
                      (slots[level] ?? max) - (expended[level.toString()] ?? 0);

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
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Icon(Icons.close),
            ),
            TextButton(
              onPressed: () {
                final expendedNew = Map<String, int>.from(expended);
                for (final entry in slots.entries) {
                  expendedNew[entry.key.toString()] =
                      total[entry.key]! - entry.value;
                }
                widget.character['expended_spell_slots'] = expendedNew;
                widget.updateCharacter?.call();
                Navigator.of(context).pop();
              },
              child: const Icon(Icons.done),
            ),
          ],
        );
      },
    );
  }

  void _showSpellDialog(String spellSlug) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SpellInfoDialog(
          spellSlug: spellSlug,
          spells: widget.spells,
          knownSpells: knownSpells,
          preparedSpells: preparedSpells,
          updateCharacter: () {
            setState(() {
              widget.character['known_spells'] = knownSpells;
              widget.character['prepared_spells'] = preparedSpells;
            });
            widget.updateCharacter?.call();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = _buildSearchResults();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: screenWidth * 0.7,
        maxHeight: screenHeight * 0.7,
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
            child: searchText.isNotEmpty
                ? Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).dividerColor,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: screenWidth * 0.5,
                        minWidth: screenWidth * 0.5,
                      ),
                      child: searchResults.isEmpty
                          ? const Center(
                              child: Text('No spells found'),
                            )
                          : ListView.separated(
                              itemCount: searchResults.length,
                              itemBuilder: (context, index) {
                                return searchResults[index];
                              },
                              separatorBuilder: (context, index) =>
                                  const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.0),
                                child: Divider(),
                              ),
                            ),
                    ),
                  )
                : Column(
                    children: [
                      if (knownSpells.isNotEmpty)
                        Expanded(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: screenWidth * 0.5,
                              minWidth: screenWidth * 0.5,
                            ),
                            child: ListView(
                              children: [
                                for (int i = 0; i < 10; i++) _buildSpellList(i),
                              ],
                            ),
                          ),
                        ),
                      _buildSpellSlotsList(),
                    ],
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
