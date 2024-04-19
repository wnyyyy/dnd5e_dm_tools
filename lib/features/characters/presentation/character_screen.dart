import 'package:dnd5e_dm_tools/features/characters/bloc/character_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_event.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_state.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/widgets/skills_tab.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/widgets/stats_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CharacterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CharacterBloc, CharacterState>(
      builder: (context, state) {
        if (state is CharacterStateLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return DefaultTabController(
            length: 4,
            child: Column(
              children: [
                TabBar(
                  tabs: [
                    Tab(text: 'Stats'),
                    Tab(text: 'Skills'),
                    Tab(text: 'Spells'),
                    Tab(text: 'Equipment'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      StatsTab(),
                      SkillsTab(),
                      Placeholder(),
                      Placeholder(),
                    ],
                  ),
                ),
              ],
            ));
      },
    );
  }
}
