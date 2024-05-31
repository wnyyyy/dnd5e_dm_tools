import 'package:dnd5e_dm_tools/features/characters/presentation/equip_tab/widgets/item_details_dialog_content.dart';
import 'package:flutter/material.dart';

class ItemDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> item;
  final int? quantity;
  final Function(int)? onQuantityChange;
  final bool isEquipped;
  final Function(String, bool)? onEquip;

  const ItemDetailsDialog({
    super.key,
    required this.item,
    this.quantity,
    this.onQuantityChange,
    required this.isEquipped,
    this.onEquip,
  });

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
        constraints: BoxConstraints(
          maxWidth: dialogWidth,
          minWidth: 450.0,
        ),
        child: ItemDetailsDialogContent(
          item: item,
          quantity: quantity,
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        if (quantity != null && quantity! > 0)
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
            decoration: const InputDecoration(
              hintText: 'Quantity',
            ),
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
                  final newQuantity = quantity! - delQuantity;
                  onQuantityChange?.call(newQuantity);
                  Navigator.of(context).pop();
                }),
          ],
        );
      },
    );
  }
}
