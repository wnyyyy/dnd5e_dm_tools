import 'package:dnd5e_dm_tools/core/widgets/error_handler.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_events.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_states.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/bio_tab/bio_tab.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/skills_tab.dart/skills_tab.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/status_tab/status_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CharacterScreen extends StatelessWidget {
  const CharacterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CharacterBloc, CharacterState>(
      builder: (context, state) {
        if (state is CharacterStateInitial) {
          return Container();
        }
        if (state is CharacterStateLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is CharacterStateError) {
          return ErrorHandler(
              error: state.error,
              onRetry: () {
                context.read<CharacterBloc>().add(CharacterLoad(state.slug));
              });
        }
        if (state is CharacterStateLoaded) {
          return DefaultTabController(
              length: 4,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: 'Bio'),
                      Tab(text: 'Status'),
                      Tab(text: 'Skills'),
                      Tab(text: 'Equip'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        BioTab(
                          character: state.character,
                          slug: state.slug,
                        ),
                        StatusTab(
                          character: state.character,
                          slug: state.slug,
                        ),
                        SkillsTab(
                          character: state.character,
                          slug: state.slug,
                        ),
                        const Placeholder()
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
