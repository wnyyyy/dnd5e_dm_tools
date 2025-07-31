import 'package:dnd5e_dm_tools/core/data/models/archetype.dart';
import 'package:dnd5e_dm_tools/core/data/models/character.dart';
import 'package:dnd5e_dm_tools/core/data/models/class.dart';
import 'package:dnd5e_dm_tools/core/data/models/race.dart';
import 'package:dnd5e_dm_tools/core/util/const.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/bio_tab/widgets/character_portrait.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/bio_tab/widgets/feat_list.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/bio_tab/widgets/proficiency_list.dart';
import 'package:flutter/material.dart';

class BioTab extends StatelessWidget {
  const BioTab({
    super.key,
    required this.character,
    required this.classs,
    required this.race,
  });
  final Character character;
  final Class classs;
  final Race race;

  @override
  Widget build(BuildContext context) {
    final Archetype? archetype = classs.archetypes
        .where((element) => element.slug == character.archetype)
        .firstOrNull;

    return LayoutBuilder(
      builder: (context, constraints) {
        return constraints.maxWidth > wideScreenBreakpoint
            ? _buildLandscapeContent(context, archetype)
            : _buildPortraitContent(context, archetype);
      },
    );
  }

  Widget _buildPortraitContent(BuildContext context, Archetype? archetype) {
    final screenWidth = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CharacterPortrait(
              character: character,
              race: race,
              classs: classs,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: 4,
              horizontal: screenWidth * 0.08,
            ),
            child: const Divider(),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.08,
              vertical: 8,
            ),
            child: ProficiencyList(character: character),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.08,
              vertical: 8,
            ),
            child: FeatList(slug: character.slug, archetype: archetype),
          ),
        ],
      ),
    );
  }

  Widget _buildLandscapeContent(BuildContext context, Archetype? archetype) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: AspectRatio(
              aspectRatio: 5 / 6,
              child: CharacterPortrait(
                character: character,
                race: race,
                classs: classs,
              ),
            ),
          ),
        ),
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.02,
                    vertical: 8,
                  ),
                  child: ProficiencyList(character: character),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.02,
                    vertical: 8,
                  ),
                  child: FeatList(slug: character.slug, archetype: archetype),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
