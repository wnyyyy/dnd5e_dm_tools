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
    return OrientationBuilder(
      builder: (context, orientation) {
        return SingleChildScrollView(
          child: orientation == Orientation.portrait
              ? _buildPortraitContent(context)
              : _buildLandscapeContent(context),
        );
      },
    );
  }

  Widget _buildPortraitContent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Flex(
      crossAxisAlignment: CrossAxisAlignment.start,
      direction: Axis.vertical,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CharacterPortrait(
            character: character,
            slug: slug,
          ),
        ),
        Padding(
          padding:
              EdgeInsets.symmetric(vertical: 4, horizontal: screenWidth * 0.08),
          child: const Divider(),
        ),
        Padding(
          padding:
              EdgeInsets.symmetric(horizontal: screenWidth * 0.08, vertical: 8),
          child: ProficiencyList(
            character: character,
            slug: slug,
          ),
        ),
        Padding(
          padding:
              EdgeInsets.symmetric(horizontal: screenWidth * 0.08, vertical: 8),
          child: FeatsList(
            character: character,
            slug: slug,
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeContent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Flex(
      crossAxisAlignment: CrossAxisAlignment.start,
      direction: Axis.horizontal,
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.01, vertical: screenHeight * 0.02),
            child: CharacterPortrait(
              character: character,
              slug: slug,
            ),
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.02, vertical: 8),
                child: ProficiencyList(
                  character: character,
                  slug: slug,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.02, vertical: 8),
                child: FeatsList(
                  character: character,
                  slug: slug,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
