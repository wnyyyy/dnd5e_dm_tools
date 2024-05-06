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
      ],
    );
  }
}
