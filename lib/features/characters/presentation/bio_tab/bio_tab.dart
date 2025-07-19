import 'package:dnd5e_dm_tools/core/data/models/character.dart';
import 'package:dnd5e_dm_tools/core/data/models/class.dart';
import 'package:dnd5e_dm_tools/core/data/models/race.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/bio_tab/widgets/character_portrait.dart';
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
    return OrientationBuilder(
      builder: (context, orientation) {
        return orientation == Orientation.portrait
            ? _buildPortraitContent(context)
            : _buildLandscapeContent(context);
      },
    );
  }

  Widget _buildPortraitContent(BuildContext context) {
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
            child: Container(),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.08,
              vertical: 8,
            ),
            child: Container(),
          ),
        ],
      ),
    );
  }

  Widget _buildLandscapeContent(BuildContext context) {
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
                  child: Container(),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.02,
                    vertical: 8,
                  ),
                  child: Container(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
