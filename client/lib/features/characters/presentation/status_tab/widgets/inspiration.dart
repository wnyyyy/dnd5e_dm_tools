import 'package:dnd5e_dm_tools/features/characters/bloc/character_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_events.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Inspiration extends StatelessWidget {
  const Inspiration({
    super.key,
    required this.character,
    required this.slug,
  });

  final Map<String, dynamic> character;
  final String slug;

  @override
  Widget build(BuildContext context) {
    final int inspiration = character['inspiration'] ?? 0;
    final color = inspiration > 0 ? Colors.green : null;

    void updateInspiration(int newInspiration) {
      character['inspiration'] = newInspiration;
      context.read<CharacterBloc>().add(
            CharacterUpdate(
              character: character,
              slug: slug,
              offline: context.read<SettingsCubit>().state.offlineMode,
              persistData: true,
            ),
          );
    }

    return GestureDetector(
      onTap: () {
        if (inspiration < 5) {
          updateInspiration(inspiration + 1);
        }
      },
      child: Card(
        child: SizedBox(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Inspiration',
                    style: Theme.of(context).textTheme.titleSmall),
                Column(
                  children: [
                    if (inspiration > 0)
                      IconButton(
                        iconSize: 32,
                        onPressed: () {
                          if (inspiration > 0) {
                            updateInspiration(inspiration - 1);
                          }
                        },
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                    Text('$inspiration',
                        style:
                            Theme.of(context).textTheme.displaySmall!.copyWith(
                                  color: color,
                                )),
                    IconButton(
                      iconSize: 32,
                      onPressed: () {
                        updateInspiration(inspiration + 1);
                      },
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
