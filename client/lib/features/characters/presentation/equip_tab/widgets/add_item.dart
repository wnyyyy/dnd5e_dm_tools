import 'package:dnd5e_dm_tools/core/util/helper.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddItemButton extends StatefulWidget {
  const AddItemButton({
    super.key,
    required this.onAdd,
  });

  final Function(String, bool) onAdd;

  @override
  AddItemButtonState createState() => AddItemButtonState();
}

class AddItemButtonState extends State<AddItemButton> {
  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  List<Widget> _buildSearchResults(
    Map<String, dynamic> items,
    String searchText,
  ) {
    final List<Widget> searchResults = [];
    if (searchText.isEmpty) {
      return searchResults;
    }
    if (items.containsKey(searchText) &&
        (items[searchText] as Map?)?['rarity'] != null) {
      final itemSearch = items[searchText] as Map<String, dynamic>;
      searchResults.add(
        ListTile(
          title: Text(
            itemSearch['name']?.toString() ?? '',
          ),
          subtitle: Text(
            (itemSearch['rarity'] as Map?)?['name']?.toString() ?? '',
          ),
          onTap: () {
            widget.onAdd(searchText, true);
          },
        ),
      );
      return searchResults;
    }

    final List<Map<String, dynamic>> filteredItems = [];

    for (final entry in items.entries) {
      final item = entry.value as Map<String, dynamic>;
      if (item['name'].toString().toLowerCase().contains(searchText) &&
          (item['rarity'] == null ||
              (item['rarity'] as Map)['name'] == 'Common')) {
        item['entryKey'] = entry.key;
        filteredItems.add(item);
      }
    }

    filteredItems.sort((a, b) {
      final String aCat =
          (a['equipment_category'] as Map?)?['index']?.toString() ?? '';
      final String bCat =
          (b['equipment_category'] as Map?)?['index']?.toString() ?? '';
      if (aCat == 'weapon' && bCat != 'weapon') return -1;
      if (bCat == 'weapon' && aCat != 'weapon') return 1;
      if (aCat == 'armor' && bCat != 'armor') return -1;
      if (bCat == 'armor' && aCat != 'armor') return 1;
      return (a['name']?.toString() ?? '')
          .compareTo(b['name']?.toString() ?? '');
    });

    for (final item in filteredItems) {
      if (searchResults.length >= 15) break;
      final String subtitle = getItemDescriptor(item);

      searchResults.add(
        ListTile(
          title: Text(item['name'] as String),
          subtitle: Text(subtitle),
          onTap: () {
            widget.onAdd(item['entryKey'] as String, false);
          },
        ),
      );
    }

    return searchResults;
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    return IconButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setDialogState) {
                  return SizedBox(
                    width: screenWidth * 0.8,
                    height: screenHeight * 0.5,
                    child: Flex(
                      direction: Axis.vertical,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 24,
                          ),
                          child: TextField(
                            autofocus: true,
                            controller: textEditingController,
                            onChanged: (value) {
                              setDialogState(() {});
                            },
                            decoration: InputDecoration(
                              labelText: 'Search Items',
                              border: const OutlineInputBorder(),
                              suffixIcon: textEditingController.text.isEmpty
                                  ? const Icon(Icons.search)
                                  : IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        textEditingController.clear();
                                        setDialogState(() {});
                                      },
                                    ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: textEditingController.text.isNotEmpty,
                          child: Expanded(
                            child: Builder(
                              builder: (context) {
                                final Map<String, dynamic> items =
                                    context.read<RulesCubit>().getAllItems();
                                final String searchText =
                                    textEditingController.text.toLowerCase();
                                final List<Widget> searchResults =
                                    _buildSearchResults(items, searchText);
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    left: 12,
                                    right: 12,
                                    bottom: 24,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: searchResults.isEmpty
                                        ? const Center(
                                            child: Text('No items found'),
                                          )
                                        : ListView.separated(
                                            itemCount: searchResults.length,
                                            itemBuilder: (context, index) =>
                                                searchResults[index],
                                            separatorBuilder:
                                                (context, index) =>
                                                    const Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 16.0,
                                              ),
                                              child: Divider(),
                                            ),
                                          ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
      icon: const Icon(Icons.add_box_outlined, size: 36),
    );
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }
}
