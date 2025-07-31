import 'package:dnd5e_dm_tools/core/config/app_colors.dart';
import 'package:dnd5e_dm_tools/core/data/models/character.dart';
import 'package:dnd5e_dm_tools/core/util/enum.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character/character_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character/character_event.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/skills_tab/widgets/attribute_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AttributesColumn extends StatelessWidget {
  const AttributesColumn({required this.character});
  final Character character;

  void editAttribute(
    BuildContext context,
    String attributeName,
    int currentValue,
  ) {
    final TextEditingController controller = TextEditingController(
      text: currentValue.toString(),
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $attributeName'),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Enter new value'),
            controller: controller,
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: <Widget>[
            TextButton(
              child: const Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Icon(Icons.check),
              onPressed: () {
                final newValue = int.tryParse(controller.text);
                if (newValue != null && newValue >= 0) {
                  final newAsi = character.asi.copyFromName(
                    name: attributeName,
                    value: newValue,
                  );
                  context.read<CharacterBloc>().add(
                    CharacterUpdate(
                      character: character.copyWith(asi: newAsi),
                      persistData: true,
                    ),
                  );
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final attrs = [
      {
        'name': Attribute.strength.name,
        'value': character.asi.strength,
        'color': theme.strengthColor,
      },
      {
        'name': Attribute.dexterity.name,
        'value': character.asi.dexterity,
        'color': theme.dexterityColor,
      },
      {
        'name': Attribute.constitution.name,
        'value': character.asi.constitution,
        'color': theme.constitutionColor,
      },
      {
        'name': Attribute.intelligence.name,
        'value': character.asi.intelligence,
        'color': theme.intelligenceColor,
      },
      {
        'name': Attribute.wisdom.name,
        'value': character.asi.wisdom,
        'color': theme.wisdomColor,
      },
      {
        'name': Attribute.charisma.name,
        'value': character.asi.charisma,
        'color': theme.charismaColor,
      },
    ];
    return Column(
      children: attrs.map((attr) {
        final attrName = attr['name']?.toString() ?? '';
        final attrValue = int.parse(attr['value']?.toString() ?? '10');
        final color = attr['color'] as Color? ?? Colors.grey;
        return AttributeCard(
          onLongPress: () => editAttribute(context, attrName, attrValue),
          attributeName: attrName,
          attributeValue: attrValue,
          color: color,
        );
      }).toList(),
    );
  }
}
