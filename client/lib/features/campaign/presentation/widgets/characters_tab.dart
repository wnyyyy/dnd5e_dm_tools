import 'package:dnd5e_dm_tools/features/campaign/cubit/campaign_cubit.dart';
import 'package:dnd5e_dm_tools/features/campaign/cubit/campaign_states.dart';
import 'package:dnd5e_dm_tools/features/campaign/data/models/character.dart';
import 'package:dnd5e_dm_tools/features/campaign/presentation/screens/character_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CharactersTab extends StatelessWidget {
  const CharactersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CampaignCubit, CampaignState>(
      builder: (context, state) {
        if (state is CampaignLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is CampaignLoaded) {
          final List<Character> sortedCharacters =
              List<Character>.from(state.characters);
          sortedCharacters.sort((a, b) => a.name.compareTo(b.name));
          final nonHidden = sortedCharacters.where((c) => !c.isHidden).toList();

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: nonHidden
                  .map(
                    (character) => ChoiceChip(
                      label: Text(character.name),
                      selected: false,
                      onSelected: (_) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: BlocProvider.of<CampaignCubit>(context),
                              child: CharacterDetailsScreen(
                                character: character,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                  .toList(),
            ),
          );
        } else if (state is CampaignError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Failed to load characters\n${state.message}'),
                TextButton(
                  onPressed: () {
                    context.read<CampaignCubit>().loadCampaign();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        } else {
          return const Center(child: Text('No characters data'));
        }
      },
    );
  }
}
