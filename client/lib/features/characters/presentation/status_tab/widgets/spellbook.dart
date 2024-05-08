import 'package:dnd5e_dm_tools/core/widgets/description_text.dart';
import 'package:flutter/material.dart';

class Spellbook extends StatefulWidget {
  final Map<String, dynamic> character;
  final Map<String, dynamic> spells;
  final VoidCallback? updateCharacter;
  final VoidCallback? onDone;

  const Spellbook({
    super.key,
    required this.character,
    required this.spells,
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
    for (var entry in widget.spells.entries) {
      final spell = entry.value;
      if (spell['name'].toLowerCase().contains(searchText) &&
          searchResults.length < 5) {
        searchResults.add(ListTile(
          title: Text(spell['name']),
          onTap: () {
            _showSpellDialog(entry.key);
          },
        ));
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
      final spell = widget.spells[spellSlug];
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
    Map<String, dynamic> classs = widget.character['class'];
    int spellSlots = widget.character['spellSlots'][level];
    return ExpansionTile(
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
            onTap: () {
              _showSpellDialog(entry.key);
            },
          ),
      ],
    );
  }

  void _showSpellDialog(String spellSlug) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final spell = widget.spells[spellSlug];
        bool isLearned = knownSpells.contains(spellSlug);
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text(spell['name']),
              content: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(spell['level'],
                                style: Theme.of(context).textTheme.bodySmall!),
                            Text(spell['school'],
                                style: Theme.of(context).textTheme.bodySmall!),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          spell['document__title'],
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 24,
                      child: Divider(),
                    ),
                    DescriptionText(
                      inputText: spell['desc'],
                      baseStyle: Theme.of(context).textTheme.bodyMedium!,
                    ),
                    const SizedBox(
                      height: 24,
                      child: Divider(),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          if (spell['concentration'] != null &&
                              spell['concentration'] == 'yes')
                            Text(
                              'Concentration',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          if (spell['ritual'] != null &&
                              spell['ritual'] == 'yes')
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Text(
                                'Ritual',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Wrap(
                        direction: Axis.horizontal,
                        spacing: 16,
                        children: [
                          if (spell['range'] != null &&
                              spell['range'].isNotEmpty)
                            Flex(
                              mainAxisSize: MainAxisSize.min,
                              direction: Axis.horizontal,
                              children: [
                                Text(
                                  'Range: ',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(spell['range']),
                              ],
                            ),
                          if (spell['components'] != null &&
                              spell['components'].isNotEmpty)
                            Flex(
                              mainAxisSize: MainAxisSize.min,
                              direction: Axis.horizontal,
                              children: [
                                Text(
                                  'Components: ',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(spell['components']),
                              ],
                            ),
                          if (spell['duration'] != null &&
                              spell['duration'].isNotEmpty)
                            Flex(
                              mainAxisSize: MainAxisSize.min,
                              direction: Axis.horizontal,
                              children: [
                                Text(
                                  'Duration: ',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(spell['duration']),
                              ],
                            ),
                          if (spell['casting_time'] != null &&
                              spell['casting_time'].isNotEmpty)
                            Flex(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              direction: Axis.horizontal,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 3),
                                  child: Text(
                                    'Casting Time: ',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Flexible(child: Text(spell['casting_time'])),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(isLearned ? 'Learned' : 'Unlearned'),
                            Padding(
                              padding: const EdgeInsets.only(left: 12.0),
                              child: Switch(
                                value: isLearned,
                                onChanged: (value) {
                                  setState(
                                    () {
                                      isLearned = value;
                                    },
                                  );
                                  if (value) {
                                    knownSpells.add(spellSlug);
                                    preparedSpells.putIfAbsent(
                                        spellSlug, () => true);
                                  } else {
                                    knownSpells.remove(spellSlug);
                                  }
                                  if (widget.updateCharacter != null) {
                                    widget.character['knownSpells'] =
                                        knownSpells;
                                    widget.character['preparedSpells'] =
                                        preparedSpells;
                                    widget.updateCharacter!();
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        if (isLearned)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const Text('Prepared'),
                              Checkbox(
                                value: preparedSpells[spellSlug] ?? false,
                                onChanged: (value) {
                                  setState(() {
                                    preparedSpells[spellSlug] = value!;
                                  });
                                  if (widget.updateCharacter != null) {
                                    widget.character['preparedSpells'] =
                                        preparedSpells;
                                    widget.updateCharacter!();
                                  }
                                },
                              ),
                            ],
                          ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => widget.onDone?.call(),
                      child: const Icon(Icons.done),
                    ),
                  ],
                ),
              ],
            );
          },
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
                border: Border.all(),
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
        Expanded(
          child: ListView(
            children: [
              for (int i = 0; i < 10; i++) _buildSpellList(i),
            ],
          ),
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
