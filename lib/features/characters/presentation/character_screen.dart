import 'package:dnd5e_dm_tools/core/util/logger.dart';
import 'package:dnd5e_dm_tools/core/widgets/error_handler.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_event.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_state.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/bio_tab/bio_tab.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NoScrollPhysics extends ScrollPhysics {
  const NoScrollPhysics({super.parent});

  @override
  NoScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return NoScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    return 0.0;
  }

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) {
    return false;
  }
}

class CharacterScreen extends StatelessWidget {
  const CharacterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CharacterBloc, CharacterState>(
      builder: (context, state) {
        if (state is CharacterInitial) {
          final slug = context.read<SettingsCubit>().state.name;
          context.read<CharacterBloc>().add(CharacterLoad(slug));
          return Container();
        }
        if (state is CharacterLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is CharacterError) {
          return ErrorHandler(
            error: state.error,
            onRetry: () {
              final slug = context.read<SettingsCubit>().state.name;
              context.read<CharacterBloc>().add(CharacterLoad(slug));
            },
          );
        }
        if (state is CharacterLoaded) {
          logUI('Parsing class table for character: ${state.character.slug}');
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
                    physics: const NoScrollPhysics(),
                    children: [
                      BioTab(
                        character: state.character,
                        classs: state.classs,
                        race: state.race,
                      ),
                      Container(),
                      Container(),
                      Container(),
                      // StatusTab(
                      //   character: state.character,
                      //   slug: state.slug,
                      //   table: classTable,
                      // ),
                      // SkillsTab(character: state.character, slug: state.slug),
                      // EquipTab(character: state.character, slug: state.slug),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        return Container();
      },
    );
  }
}
