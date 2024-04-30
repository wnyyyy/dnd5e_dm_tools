import 'package:dnd5e_dm_tools/core/data/repositories/feats_repository.dart';
import 'package:dnd5e_dm_tools/core/widgets/feat_description.dart';
import 'package:dnd5e_dm_tools/core/widgets/item_list.dart';
import 'package:dnd5e_dm_tools/core/widgets/trait_description.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SkillsTab extends StatelessWidget {
  final Map<String, dynamic> character;
  final Map<String, dynamic> race;
  final Map<String, dynamic> classs;
  final String name;

  const SkillsTab({
    super.key,
    required this.character,
    required this.name,
    required this.race,
    required this.classs,
  });

  @override
  Widget build(BuildContext context) {
    var feats = Map.castFrom(character['feats'] ?? {}).cast<String, Map>();
    return SingleChildScrollView(
      child: Flex(
        direction: Axis.vertical,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 32),
            child: Divider(),
          ),
        ],
      ),
    );
  }
}
