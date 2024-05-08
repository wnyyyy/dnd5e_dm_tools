import 'package:dnd5e_dm_tools/features/characters/presentation/bio_tab/widgets/character_portrait.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/bio_tab/widgets/feat_list.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/bio_tab/widgets/proficiency_list.dart';
import 'package:flutter/material.dart';

class BioTab extends StatelessWidget {
  final Map<String, dynamic> character;
  final String slug;

  const BioTab({
    super.key,
    required this.character,
    required this.slug,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Flex(
        direction: Axis.vertical,
        children: [
          CharacterPortrait(
            character: character,
            slug: slug,
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                vertical: 4, horizontal: screenWidth * 0.08),
            child: const Divider(),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.08, vertical: 8),
            child: ProficiencyList(
              character: character,
              slug: slug,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.08, vertical: 8),
            child: FeatsList(
              character: character,
              slug: slug,
            ),
          ),
        ],
      ),
    );
  }
}
