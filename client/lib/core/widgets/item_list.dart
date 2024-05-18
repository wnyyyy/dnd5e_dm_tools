import 'package:flutter/material.dart';

class ItemList extends StatefulWidget {
  final Map<String, Map>? items;
  final Function(Map<String, Map>) onItemsChanged;
  final Function() onAddItem;
  final Function(MapEntry<String, Map>) onSelectItem;
  final String tableName;
  final String displayKey;
  final String emptyMessage;

  const ItemList({
    super.key,
    required this.items,
    required this.onItemsChanged,
    required this.onAddItem,
    required this.tableName,
    required this.displayKey,
    required this.onSelectItem,
    this.emptyMessage = 'No items',
  });

  @override
  ItemListState createState() => ItemListState();
}

class ItemListState extends State<ItemList> {
  bool _isEditMode = false;

  void _enableEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
  }

  void _editItem(String key, Map item) {
    final TextEditingController titleController =
        TextEditingController(text: item[widget.displayKey]);
    final TextEditingController descriptionController =
        TextEditingController(text: item['description']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit ${widget.tableName}'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                  ),
                ),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                  minLines: 3,
                  maxLines: 5,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Icon(Icons.close),
            ),
            TextButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  var newItem = {
                    widget.displayKey: titleController.text,
                    'description': descriptionController.text,
                  };
                  setState(() {
                    widget.items?[key] = newItem;
                    widget.onItemsChanged(widget.items ?? {});
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Icon(Icons.save),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  widget.items?.remove(key);
                  widget.onItemsChanged(widget.items ?? {});
                });
                Navigator.of(context).pop();
              },
              child: const Icon(Icons.delete),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      widget.tableName,
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
                            onPressed: widget.onAddItem,
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
          if (widget.items?.isEmpty ?? true)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(widget.emptyMessage,
                  style: Theme.of(context).textTheme.bodyLarge),
            ),
          ...widget.items?.keys.map((key) {
                return ListTile(
                  title: Text(widget.items?[key]?[widget.displayKey] ?? ''),
                  onTap: () => widget.onSelectItem(
                    MapEntry(key, widget.items?[key] ?? {}),
                  ),
                  trailing: _isEditMode
                      ? IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () =>
                              _editItem(key, widget.items?[key] ?? {}),
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
