import 'package:dnd5e_dm_tools/core/data/models/backpack_item.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/equip_tab/widgets/item_details_dialog_content.dart';
import 'package:flutter/material.dart';

class ItemDetailsDialog extends StatelessWidget {
  const ItemDetailsDialog({
    super.key,
    required this.backpackItem,
    this.onQuantityChange,
    this.onEquip,
  });
  final BackpackItem backpackItem;
  final Function(int)? onQuantityChange;
  final Function(String, bool)? onEquip;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 900
        ? 810.0
        : (screenWidth * 0.9) < 450.0
        ? 450.0
        : screenWidth * 0.9;

    return AlertDialog(
      content: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: dialogWidth, minWidth: 450.0),
        child: ItemDetailsDialogContent(backpackItem: backpackItem),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        if (backpackItem.quantity > 0)
          TextButton(
            child: const Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(context),
          ),
        TextButton(
          child: const Icon(Icons.done),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final inputController = TextEditingController();
        inputController.text = '1';
        return AlertDialog(
          title: const Text('Delete Item'),
          content: TextField(
            controller: inputController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Quantity'),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: <Widget>[
            TextButton(
              child: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Icon(Icons.done),
              onPressed: () {
                final delQuantity = int.tryParse(inputController.text) ?? 0;
                final newQuantity = backpackItem.quantity - delQuantity;
                if (newQuantity <= 0) {
                  onQuantityChange?.call(0);
                } else {
                  onQuantityChange?.call(newQuantity);
                }
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
