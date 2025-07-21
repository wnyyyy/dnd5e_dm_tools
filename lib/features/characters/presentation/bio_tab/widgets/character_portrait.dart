import 'package:cached_network_image/cached_network_image.dart';
import 'package:dnd5e_dm_tools/core/data/models/character.dart';
import 'package:dnd5e_dm_tools/core/data/models/class.dart';
import 'package:dnd5e_dm_tools/core/data/models/race.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_event.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/bio_tab/widgets/class_description.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';

class CharacterPortrait extends StatelessWidget {
  const CharacterPortrait({
    super.key,
    required this.character,
    required this.race,
    required this.classs,
  });
  final Character character;
  final Race race;
  final Class classs;

  void _showEditLevel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView.builder(
          itemCount: 20,
          itemBuilder: (context, index) => ListTile(
            title: Text('Level ${index + 1}'),
            onTap: () {
              final updatedCharacter = character.copyWith(level: index + 1);
              context.read<CharacterBloc>().add(
                CharacterUpdate(character: updatedCharacter, persistData: true),
              );
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  void _showRaceModal(BuildContext context, Race race) {
    showDialog(
      context: context,
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        final dialogWidth = screenWidth > 900
            ? 810.0
            : (screenWidth * 0.9) < 450.0
            ? 450.0
            : screenWidth * 0.9;
        return AlertDialog(
          title: Text(race.name),
          content: SingleChildScrollView(
            child: SizedBox(
              width: dialogWidth,
              height: screenHeight * 0.6,
              child: Markdown(data: race.traits),
            ),
          ),
          actions: [
            TextButton(
              child: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  Color? _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    try {
      var hexColor = hex.replaceAll('#', '');
      if (hexColor.length == 6) hexColor = 'FF$hexColor';
      if (hexColor.length == 8) {
        return Color(int.parse('0x$hexColor'));
      }
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color:
                    _parseColor(character.color)?.withAlpha(128) ??
                    Theme.of(context).colorScheme.outline,
                width: 3,
              ),
            ),
            child: CachedNetworkImage(
              imageUrl: character.imageUrl,
              placeholder: (context, url) =>
                  const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) =>
                  Image.asset('assets/img/unknown.jpg', fit: BoxFit.cover),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    character.name,
                    style: Theme.of(context).textTheme.displaySmall!.copyWith(
                      fontFamily: GoogleFonts.patuaOne().fontFamily,
                    ),
                  ),
                  GestureDetector(
                    onLongPress: () => _showEditLevel(context),
                    onTap: () => context.read<SettingsCubit>().state.isEditMode
                        ? _showEditLevel(context)
                        : null,
                    child: Text(
                      'Level ${character.level}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => _showRaceModal(context, race),
                    child: Text(
                      race.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                      softWrap: false,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => showDialog(
                      context: context,
                      builder: (context) {
                        return ClassDescription(
                          classs: classs,
                          character: character,
                        );
                      },
                    ),
                    child: Text(
                      classs.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
