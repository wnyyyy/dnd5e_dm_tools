import 'package:dnd5e_dm_tools/core/widgets/trait_description2.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_events.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/bio_tab/widgets/class_description.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_cubit.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class CharacterPortrait extends StatelessWidget {
  final Map<String, dynamic> character;
  final String slug;

  const CharacterPortrait({
    super.key,
    required this.character,
    required this.slug,
  });

  void _showEditLevel(BuildContext context) {
    final offline = context.read<SettingsCubit>().state.offlineMode;
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView.builder(
          itemCount: 20,
          itemBuilder: (context, index) => ListTile(
            title: Text('Level ${index + 1}'),
            onTap: () {
              character['level'] = index + 1;
              context.read<CharacterBloc>().add(
                    CharacterUpdate(
                      character: character,
                      slug: slug,
                      offline: offline,
                      persistData: true,
                    ),
                  );
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  void _showRaceModal(BuildContext context, Map<String, dynamic>? data) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(data?['name'] ?? "Error"),
          content: SingleChildScrollView(
            child: TraitDescription2(
              inputText: data?['traits'] ?? "Could not load race",
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

  @override
  Widget build(BuildContext context) {
    final name = character['name'].toString();
    final race = context.read<RulesCubit>().getRace(character['race']);
    final classs = context.read<RulesCubit>().getClass(character['class']);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                    color: Theme.of(context).colorScheme.outline, width: 3),
              ),
              child: Image.network(character['image_url']),
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    textAlign: TextAlign.center,
                    name,
                    style: Theme.of(context).textTheme.displaySmall!.copyWith(
                          fontFamily: GoogleFonts.patuaOne().fontFamily,
                        ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onLongPress: () => _showEditLevel(context),
                    onTap: () => context.read<SettingsCubit>().state.isEditMode
                        ? _showEditLevel(context)
                        : null,
                    child: Text(
                      'Level ${character['level']}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => _showRaceModal(context, race),
                    child: Text(
                      '${race?['name'] ?? 'Race not found'}',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => showDialog(
                      context: context,
                      builder: (context) {
                        if (classs == null) return Container();
                        return ClassDescription(
                            classs: classs,
                            character: character,
                            slug: slug,
                            editMode: false);
                      },
                    ),
                    child: Text(
                      '${classs?['name'] ?? 'Class not found'}',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                ],
              ),
            )
          ],
        )
      ],
    );
  }
}
