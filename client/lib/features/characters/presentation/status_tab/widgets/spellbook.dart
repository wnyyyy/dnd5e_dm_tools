import 'package:flutter/material.dart';

class Spellbook extends StatefulWidget {
  final Map<String, dynamic> character;
  final Map<String, dynamic> spells;

  const Spellbook({
    super.key,
    required this.character,
    required this.spells,
  });

  @override
  SpellbookState createState() => SpellbookState();
}

class SpellbookState extends State<Spellbook> {
  String searchText = '';
  Map<String, bool> preparedSpells = {};

  @override
  void initState() {
    super.initState();
    if (widget.character.containsKey('preparedSpells')) {
      preparedSpells =
          Map<String, bool>.from(widget.character['preparedSpells']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: (value) {
              setState(() {
                searchText = value.toLowerCase();
              });
            },
            decoration: const InputDecoration(
              labelText: 'Search Spells',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: widget.spells.keys.length,
            itemBuilder: (context, index) {
              String level = widget.spells.keys.elementAt(index);
              List<dynamic> spellsAtLevel = widget.spells[level];
              return Visibility(
                visible: spellsAtLevel.any((spell) =>
                    spell['name'].toLowerCase().contains(searchText)),
                child: ExpansionTile(
                  title: Text('Level $level Spells'),
                  children: spellsAtLevel.map<Widget>((spell) {
                    bool isPrepared = preparedSpells[spell['name']] ?? false;
                    return Visibility(
                      visible: spell['name'].toLowerCase().contains(searchText),
                      child: ListTile(
                        title: Text(spell['name']),
                        trailing: Checkbox(
                          value: isPrepared,
                          onChanged: (bool? value) {
                            setState(() {
                              preparedSpells[spell['name']] = value!;
                            });
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
