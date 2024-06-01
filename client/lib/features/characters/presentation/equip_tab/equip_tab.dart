import 'package:dnd5e_dm_tools/features/characters/presentation/equip_tab/widgets/backpack.dart';
import 'package:flutter/material.dart';

class EquipTab extends StatelessWidget {
  const EquipTab({
    super.key,
    required this.character,
    required this.slug,
  });
  final Map<String, dynamic> character;
  final String slug;

  @override
  Widget build(BuildContext context) {
    if (character['backpack'] == null) {
      character['backpack'] = {
        'cp': 0,
        'sp': 0,
        'gp': 0,
        'items': Map<String, dynamic>.from({}),
      };
    }
    final backpack = character['backpack'] as Map<String, dynamic>;
    if (backpack['items'] == null) {
      backpack['items'] = Map<String, dynamic>.from({});
    }
    return SingleChildScrollView(
      child: Flex(
        direction: Axis.vertical,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.75 < 300
                ? 500
                : MediaQuery.of(context).size.height * 0.9,
            child: BackpackWidget(
              character: character,
              slug: slug,
            ),
          ),
        ],
      ),
    );
  }
}
