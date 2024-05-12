import 'package:dnd5e_dm_tools/features/campaign/cubit/campaign_cubit.dart';
import 'package:dnd5e_dm_tools/features/campaign/cubit/campaign_states.dart';
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
        } else if (state is CampaignInitial) {
          context.read<CampaignCubit>().loadCampaign();
          return Container();
        } else if (state is CampaignLoaded) {
          return Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: List<Widget>.generate(
              state.characters.length,
              (index) {
                var character = state.characters[index];
                return ChoiceChip(
                  label: Text(character.name),
                  selected: false,
                  onSelected: (_) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: BlocProvider.of<CampaignCubit>(context),
                          child: Container(),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        } else if (state is CampaignError) {
          return const Center(child: Text('Failed to load characters'));
        } else {
          return const Center(child: Text('No character data'));
        }
      },
    );
  }
}
