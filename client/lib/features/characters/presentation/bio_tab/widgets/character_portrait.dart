import 'package:dnd5e_dm_tools/core/widgets/trait_description.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_events.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_states.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_bloc.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class CharacterPortrait extends StatelessWidget {
  final Map<String, dynamic> character;
  final String name;

  const CharacterPortrait({
    super.key,
    required this.character,
    required this.name,
  });

  void _showEditLevel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView.builder(
          itemCount: 20,
          itemBuilder: (context, index) => ListTile(
            title: Text('Level ${index + 1}'),
            onTap: () {
              context.read<CharacterBloc>().add(CharacterUpdate(
                    character: character,
                    name: name,
                  ));
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
          content: TraitDescription(
            inputText: data?['traits'] ?? "Could not load race",
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
    return BlocBuilder(builder: (context, state) {
      if (state is CharacterStateLoaded) {
        final character = state.character;
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
                  child: Image.asset(
                    'assets/char/${name.trim().replaceAll(' ', '_')}.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.centerLeft,
                  ),
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
                        name[0].toUpperCase() + name.substring(1).toLowerCase(),
                        style:
                            Theme.of(context).textTheme.displaySmall!.copyWith(
                                  fontFamily: GoogleFonts.patuaOne().fontFamily,
                                ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () =>
                            context.read<SettingsCubit>().state.isEditMode
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
                          '${race?['name'] ?? 'Unknown'}',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${classs?['name'] ?? 'Unknown'}',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
                )
              ],
            )
          ],
        );
      }

      return Container();
    });
  }
}
