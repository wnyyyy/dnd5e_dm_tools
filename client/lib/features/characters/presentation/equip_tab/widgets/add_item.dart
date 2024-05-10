import 'package:dnd5e_dm_tools/core/util/helper.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddItemButton extends StatefulWidget {
  final Function(String, bool) onAdd;

  const AddItemButton({
    super.key,
    required this.onAdd,
  });

  @override
  AddItemButtonState createState() => AddItemButtonState();
}

class AddItemButtonState extends State<AddItemButton> {
  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  List<Widget> _buildSearchResults(Map<String, dynamic> items,
      Map<String, dynamic> magicItems, String searchText) {
    List<Widget> searchResults = [];
    if (searchText.isEmpty) {
      return searchResults;
    }
    if (magicItems.containsKey(searchText)) {
      searchResults.add(ListTile(
        title: Text(magicItems[searchText]['name']),
        onTap: () {
          widget.onAdd(searchText, true);
        },
      ));
      return searchResults;
    }

    List<Map<String, dynamic>> filteredItems = [];

    for (var entry in items.entries) {
      final item = entry.value;
      if (item['name'].toLowerCase().contains(searchText)) {
        item['entryKey'] = entry.key;
        filteredItems.add(item);
      }
    }

    filteredItems.sort((a, b) {
      final aCat = a['equipment_category']?['index'];
      final bCat = b['equipment_category']?['index'];
      if (aCat == 'weapon' && bCat != 'weapon') return -1;
      if (bCat == 'weapon' && aCat != 'weapon') return 1;
      if (aCat == 'armor' && bCat != 'armor') return -1;
      if (bCat == 'armor' && aCat != 'armor') return 1;
      return a['name'].compareTo(b['name']);
    });

    for (var item in filteredItems) {
      if (searchResults.length >= 15) break;
      final String subtitle = getItemDescriptor(item);

      searchResults.add(ListTile(
        title: Text(item['name']),
        subtitle: Text(subtitle),
        onTap: () {
          widget.onAdd(item['entryKey'], false);
        },
      ));
    }

    return searchResults;
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setDialogState) {
                  return Flex(
                    direction: Axis.vertical,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 24),
                        child: TextField(
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
                              final items =
                                  context.read<RulesCubit>().getAllItems();
                              final magicItems =
                                  context.read<RulesCubit>().getAllMagicItems();
                              final searchText =
                                  textEditingController.text.toLowerCase();
                              final searchResults = _buildSearchResults(
                                  items, magicItems, searchText);
                              return Padding(
                                padding: const EdgeInsets.only(
                                    left: 12, right: 12, bottom: 24),
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
                                          separatorBuilder: (context, index) =>
                                              const Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16.0),
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
                  );
                },
              ),
            );
          },
        );
      },
      child: const Text('Add Item'),
    );
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }
}
