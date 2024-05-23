import 'package:dnd5e_dm_tools/core/util/helper.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/status_tab/widgets/spell_info.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recase/recase.dart';

class Spellbook extends StatefulWidget {
  final Map<String, dynamic> character;
  final String slug;
  final Map<String, dynamic> spells;
  final List<Map<String, dynamic>> table;
  final VoidCallback? updateCharacter;
  final VoidCallback? onDone;

  const Spellbook({
    super.key,
    required this.character,
    required this.spells,
    required this.slug,
    required this.table,
    this.onDone,
    this.updateCharacter,
  });

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
    if (widget.character.containsKey('knownSpells')) {
      knownSpells = List<String>.from(widget.character['knownSpells']);
    }
    if (widget.character.containsKey('preparedSpells')) {
      preparedSpells =
          Map<String, bool>.from(widget.character['preparedSpells']);
    }
  }

  List<Widget> _buildSearchResults() {
    List<Widget> searchResults = [];
    if (searchText.isEmpty) {
      return searchResults;
    }

    List<MapEntry<String, dynamic>> matchingEntries = [];
    for (var entry in widget.spells.entries) {
      final spell = entry.value;
      if (spell['name'].toLowerCase().contains(searchText.toLowerCase())) {
        matchingEntries.add(entry);
      }
    }

    matchingEntries.sort(
      (a, b) {
        int levelA = a.value['level_int'] ?? 0;
        int levelB = b.value['level_int'] ?? 0;
        return levelA.compareTo(levelB);
      },
    );

    for (var entry in matchingEntries) {
      if (searchResults.length < 5) {
        final spell = entry.value;
        searchResults.add(ListTile(
          title: Text(spell['name'] ?? ''),
          subtitle: Row(
            children: [
              Text(spell['level'] ?? ''),
              const Spacer(),
              Text(spell['school'].toString().sentenceCase),
            ],
          ),
          onTap: () {
            _showSpellDialog(entry.key);
          },
        ));
      } else {
        break;
      }
    }

    return searchResults;
  }

  Widget _buildSpellList(int level) {
    List<dynamic> spellSlugs = widget.character['knownSpells'] ?? [];
    if (spellSlugs.isEmpty) {
      return Container();
    }
    List<MapEntry<String, dynamic>> spells = [];
    for (var spellSlug in spellSlugs) {
      var spell = widget.spells[spellSlug];
      spell ??= context.read<RulesCubit>().getAllSpells()[spellSlug] ?? {};
      if (spell['level_int'] == level) {
        spells.add(MapEntry(spellSlug, spell));
      }
    }
    if (spells.isEmpty) {
      return Container();
    }
    String label =
        level == 0 ? 'Cantrips' : '${spells[0].value['level']} spells';
    String spellCountLabel =
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
          for (var entry in spells)
            ListTile(
              title: Text(entry.value['name']),
              subtitle: Text(entry.value['school'].toString().sentenceCase),
              onTap: () {
                _showSpellDialog(entry.key);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSpellSlotsList() {
    Map<int, int> slots =
        getSpellSlotsForLevel(widget.table, widget.character['level'] ?? 1);
    final expendedSlots =
        Map<String, int>.from(widget.character['expendedSpellSlots'] ?? {});

    List<Padding> texts = [];
    for (var entry in slots.entries) {
      texts.add(Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card.filled(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${getOrdinal(entry.key)} Level',
                    style: Theme.of(context).textTheme.titleMedium),
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
      ));
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
      BuildContext context, Map<String, int> expended, Map<int, int> total) {
    Map<int, int> slots = Map<int, int>.from(expended);

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
                for (var entry in slots.entries) {
                  expendedNew[entry.key.toString()] =
                      total[entry.key]! - entry.value;
                }
                widget.character['expendedSpellSlots'] = expendedNew;
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
          updateCharacter: widget.updateCharacter!,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = _buildSearchResults();
    return Flex(
      direction: Axis.vertical,
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
                  : Flex(
                      direction: Axis.horizontal,
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
        Visibility(
          visible: searchText.isNotEmpty,
          child: Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                ),
                borderRadius: BorderRadius.circular(8.0),
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
                      separatorBuilder: (context, index) => const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Divider(),
                      ),
                    ),
            ),
          ),
        ),
        Visibility(
          visible: searchText.isEmpty,
          child: Expanded(
            child: ListView(
              children: [
                for (int i = 0; i < 10; i++) _buildSpellList(i),
              ],
            ),
          ),
        ),
        Visibility(
          visible: searchText.isEmpty,
          child: _buildSpellSlotsList(),
        ),
      ],
    );
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }
}
