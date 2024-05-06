import 'package:flutter/material.dart';

class SpellList extends StatefulWidget {
  final Map<String, dynamic> character;
  final Map<String, dynamic>? spells;
  final int spellLevel;

  const SpellList({
    super.key,
    required this.character,
    required this.spellLevel,
    this.spells,
  });

  @override
  SpellListState createState() => SpellListState();
}

class SpellListState extends State<SpellList> {
  bool _isEditMode = false;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> filteredSpells = [];

  void _enableEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterSpells(String query) {
    setState(() {
      filteredSpells = widget.spells!.entries
          .where((entry) =>
              entry.value['name'].toLowerCase().contains(query.toLowerCase()))
          .map((entry) => entry.value['name'])
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final spells = widget.character['spells']?[widget.spellLevel] ?? {};
    final label = widget.spellLevel == 0
        ? 'Cantrips'
        : 'Level ${widget.spellLevel} Spells';
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 16, bottom: 8, top: 8, right: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label,
                      style:
                          Theme.of(context).textTheme.headlineMedium!.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondaryContainer,
                              ),
                    ),
                    Row(
                      children: [
                        if (_isEditMode)
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.add),
                          ),
                        IconButton(
                          onPressed: _enableEditMode,
                          icon: Icon(_isEditMode ? Icons.check : Icons.edit),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          if (spells?.isEmpty ?? true)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('None', style: Theme.of(context).textTheme.bodyLarge),
            ),
          ...spells?.keys.map((key) {
                return ListTile(
                  title: Text(spells?[key]?['name'] ?? ''),
                  onTap: () => print('Select spell'),
                  trailing: _isEditMode
                      ? IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => setState(() {
                            spells?.remove(key);
                          }),
                        )
                      : null,
                );
              }).toList() ??
              [],
        ],
      ),
    );
  }
}
