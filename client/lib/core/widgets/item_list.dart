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
                          icon: const Icon(Icons.delete),
                          onPressed: () => setState(() {
                            widget.items?.remove(key);
                            widget.onItemsChanged(widget.items ?? {});
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
