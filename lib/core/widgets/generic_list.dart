import 'package:dnd5e_dm_tools/core/data/models/feat.dart';
import 'package:flutter/material.dart';

class GenericList<T> extends StatefulWidget {
  const GenericList({
    super.key,
    required this.items,
    required this.onItemsChanged,
    required this.onAddItem,
    required this.onSelectItem,
    required this.tableName,
    required this.displayKeyGetter,
    required this.descriptionGetter,
    this.emptyMessage = 'No items',
  });

  final List<T> items;
  final void Function(List<T>) onItemsChanged;
  final void Function() onAddItem;
  final void Function(T) onSelectItem;
  final String tableName;
  final String Function(T) displayKeyGetter;
  final String Function(T) descriptionGetter;
  final String emptyMessage;

  @override
  State<GenericList<T>> createState() => _GenericListState<T>();
}

class _GenericListState<T> extends State<GenericList<T>> {
  bool _isEditMode = false;

  void _enableEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
  }

  void _editItem(int index, T item) {
    final titleController = TextEditingController(
      text: widget.displayKeyGetter(item),
    );
    final descriptionController = TextEditingController(
      text: widget.descriptionGetter(item),
    );

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
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
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
                  if (item is Map) {
                    final updated = Map<String, dynamic>.from(item);
                    updated['name'] = titleController.text;
                    updated['description'] = descriptionController.text;
                    setState(() {
                      widget.items[index] = updated as T;
                      widget.onItemsChanged(widget.items);
                    });
                  }
                  if (item is Feat) {
                    final newFeat = Feat(
                      slug: titleController.text,
                      name: titleController.text,
                      description: '',
                      effectsDesc: const [],
                      descOverride: descriptionController.text,
                    );
                    setState(() {
                      widget.items[index] = newFeat as T;
                      widget.onItemsChanged(widget.items);
                    });
                  }
                  Navigator.of(context).pop();
                }
              },
              child: const Icon(Icons.save),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  widget.items.removeAt(index);
                  widget.onItemsChanged(widget.items);
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
        border: Border.all(color: Theme.of(context).colorScheme.outline),
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
                  left: 16,
                  bottom: 8,
                  top: 8,
                  right: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.tableName,
                      style: Theme.of(context).textTheme.headlineMedium!
                          .copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSecondaryContainer,
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
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (widget.items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                widget.emptyMessage,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ...List.generate(widget.items.length, (index) {
            final item = widget.items[index];
            return ListTile(
              title: Text(widget.displayKeyGetter(item)),
              onTap: () => widget.onSelectItem(item),
              trailing: _isEditMode
                  ? IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editItem(index, item),
                    )
                  : null,
            );
          }),
        ],
      ),
    );
  }
}
