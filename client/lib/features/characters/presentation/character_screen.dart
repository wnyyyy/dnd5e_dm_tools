import 'package:dnd5e_dm_tools/features/characters/bloc/character_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_state.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/widgets/skills_tab.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/widgets/bio_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CharacterScreen extends StatelessWidget {
  const CharacterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CharacterBloc, CharacterState>(
      builder: (context, state) {
        if (state is CharacterStateLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is CharacterStateError) {
          return Center(child: Text(state.error));
        }
        if (state is CharacterStateLoaded) {
          return DefaultTabController(
              length: 4,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: 'Bio'),
                      Tab(text: 'Skills'),
                      Tab(text: 'Resources'),
                      Tab(text: 'Equipment'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        BioTab(character: state.character, name: state.name),
                        SkillsTab(),
                        const Placeholder(),
                        const Placeholder(),
                      ],
                    ),
                  ),
                ],
              ));
        }
        return Container();
      },
    );
  }
}
