import 'package:dnd5e_dm_tools/core/data/models/character.dart';
import 'package:flutter/material.dart';

class EquipTab extends StatelessWidget {
  const EquipTab({super.key, required this.character});
  final Character character;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Flex(
        direction: Axis.vertical,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.75 < 300
                ? 500
                : MediaQuery.of(context).size.height * 0.8,
            child: Container(),
            // child: BackpackWidget(
            //   character: character,
            //   slug: slug,
            // ),
          ),
        ],
      ),
    );
  }
}
