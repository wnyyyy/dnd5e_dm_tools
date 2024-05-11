import 'package:flutter/material.dart';
import 'package:dnd5e_dm_tools/core/util/enum.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/status_tab/widgets/action_menu/action_category_row.dart';

class AddActionButton extends StatelessWidget {
  const AddActionButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => showDialog(
        context: context,
        builder: (BuildContext context) => _AddActionDialog(),
      ),
      child: const Icon(Icons.add),
    );
  }
}

class _AddActionDialog extends StatefulWidget {
  @override
  _AddActionDialogState createState() => _AddActionDialogState();
}

class _AddActionDialogState extends State<_AddActionDialog> {
  TextEditingController textEditingController = TextEditingController();
  ActionMenuMode _selected = ActionMenuMode.abilities;
  ResourceType _resourceType = ResourceType.none;
  bool _requiresResource = false;
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Add Action', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 20),
            ActionCategoryRow(
              showAll: false,
              onSelected: (ActionMenuMode selected) {
                setState(() {});
              },
            ),
            _buildAddAbility(),
            _buildCommonFields(),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCommonFields() {
    return Column(
      children: [
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Title',
          ),
        ),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description',
          ),
          minLines: 3,
          maxLines: 5,
        ),
      ],
    );
  }

  Widget _buildAddAbility() {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Has resource', style: Theme.of(context).textTheme.bodyLarge),
            Checkbox(
              value: _requiresResource,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _requiresResource = value;
                    _resourceType = ResourceType.shortRest;
                  });
                }
              },
            ),
          ],
        ),
        if (_requiresResource)
          Column(
            children: [
              ChoiceChip(
                label: const Text('Short rest'),
                selected: _resourceType == ResourceType.shortRest,
                onSelected: (selected) {
                  setState(() {
                    _resourceType = ResourceType.shortRest;
                  });
                },
              ),
              ChoiceChip(
                label: const Text('Long rest'),
                selected: _resourceType == ResourceType.longRest,
                onSelected: (selected) {
                  setState(() {
                    _resourceType = ResourceType.longRest;
                  });
                },
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Icon(Icons.close),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Icon(Icons.check),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
