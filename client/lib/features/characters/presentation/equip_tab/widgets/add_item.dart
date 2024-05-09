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
  String searchText = '';
  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  List<Widget> _buildSearchResults(items, magicItems) {
    List<Widget> searchResults = [];
    if (searchText.isEmpty) {
      return searchResults;
    }
    if (magicItems[searchText] != null) {
      searchResults.add(ListTile(
        title: Text(magicItems[searchText]['name']),
        onTap: () {
          widget.onAdd(searchText, true);
        },
      ));
      return searchResults;
    }
    for (var entry in items.entries) {
      final item = entry.value;
      if (item['name'].toLowerCase().contains(searchText) &&
          searchResults.length < 15) {
        final gearCategory = item['gear_category'];
        final equipmentCategory = item['equipment_category'];
        final String subtitle;
        if (gearCategory != null && gearCategory['name'] != null) {
          subtitle = gearCategory;
        } else if (equipmentCategory != null &&
            equipmentCategory['name'] != null) {
          subtitle = equipmentCategory;
        } else {
          subtitle = '';
        }
        searchResults.add(ListTile(
          title: Text(item['name']),
          subtitle: Text(subtitle),
          onTap: () {
            widget.onAdd(entry.key, false);
          },
        ));
      }
    }
    return searchResults;
  }

  @override
  Widget build(BuildContext context) {
    final items = context.read<RulesCubit>().getAllItems();
    final magicItems = context.read<RulesCubit>().getAllMagicItems();
    final searchResults = _buildSearchResults(items, magicItems);
    return TextButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
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
                      labelText: 'Search Equipment and Items',
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
                              child: Text('No items found'),
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
                  ),
                ),
              ],
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
