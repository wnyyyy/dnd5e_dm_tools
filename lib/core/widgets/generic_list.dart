import 'package:flutter/material.dart';

class GenericList<T> extends StatefulWidget {
  const GenericList({
    super.key,
    required this.items,
    required this.onItemsChanged,
    required this.onAddItem,
    required this.onSelectItem,
    required this.onEditItem,
    required this.tableName,
    required this.displayKeyGetter,
    required this.slugGetter,
    required this.descriptionGetter,
    this.emptyMessage = 'No items',
    this.onChangeEditMode,
  });

  final List<T> items;
  final void Function(List<T>)? onItemsChanged;
  final void Function() onAddItem;
  final void Function(T) onSelectItem;
  final void Function(T, String, String) onEditItem;
  final String tableName;
  final String Function(T) displayKeyGetter;
  final String Function(T) descriptionGetter;
  final String Function(T) slugGetter;
  final String emptyMessage;
  final void Function(bool)? onChangeEditMode;

  @override
  State<GenericList<T>> createState() => _GenericListState<T>();
}

class _GenericListState<T> extends State<GenericList<T>> {
  bool _isEditMode = false;

  void _enableEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
      widget.onChangeEditMode?.call(_isEditMode);
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
                setState(() {
                  widget.items.removeAt(index);
                  widget.onItemsChanged?.call(widget.items);
                });
                Navigator.of(context).pop();
              },
              child: const Icon(Icons.delete),
            ),
            TextButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  widget.onEditItem(
                    item,
                    titleController.text,
                    descriptionController.text,
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Icon(Icons.save),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Icon(Icons.close),
            ),
          ],
        );
      },
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    final List<T> reordered = List<T>.from(widget.items);
    final T moved = reordered.removeAt(oldIndex);

    if (oldIndex < newIndex) {
      reordered.insert(newIndex - 1, moved);
    } else {
      reordered.insert(newIndex, moved);
    }
    widget.onItemsChanged?.call(reordered);
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
          ReorderableListView(
            shrinkWrap: true,
            buildDefaultDragHandles: false,
            physics: const NeverScrollableScrollPhysics(),
            onReorder: _isEditMode && widget.onItemsChanged != null
                ? _onReorder
                : (_, _) {},
            children: [
              for (int index = 0; index < widget.items.length; index++)
                ListTile(
                  contentPadding: const EdgeInsetsDirectional.only(start: 16),
                  key: ValueKey(widget.slugGetter(widget.items[index])),
                  title: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(widget.displayKeyGetter(widget.items[index])),
                  ),
                  onTap: () => widget.onSelectItem(widget.items[index]),
                  trailing: _isEditMode && widget.onItemsChanged != null
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () =>
                                  _editItem(index, widget.items[index]),
                            ),
                            ReorderableDragStartListener(
                              index: index,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  height: double.infinity,
                                  padding: const EdgeInsets.only(right: 16),
                                  child: const Icon(Icons.drag_handle),
                                ),
                              ),
                            ),
                          ],
                        )
                      : null,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
