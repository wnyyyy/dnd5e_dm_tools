import 'package:dnd5e_dm_tools/core/util/helper.dart';
import 'package:dnd5e_dm_tools/core/widgets/error_handler.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_events.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_states.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/bio_tab/bio_tab.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/equip_tab/equip_tab.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/skills_tab.dart/skills_tab.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/status_tab/status_tab.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_cubit.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CharacterScreen extends StatelessWidget {
  const CharacterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final offline = context.read<SettingsCubit>().state.offlineMode;
    return BlocBuilder<CharacterBloc, CharacterState>(
      builder: (context, state) {
        if (state is CharacterStateInitial) {
          final slug = context.read<SettingsCubit>().state.name;
          context
              .read<CharacterBloc>()
              .add(CharacterLoad(slug, offline: offline));
        }
        if (state is CharacterStateLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is CharacterStateError) {
          return ErrorHandler(
              error: state.error,
              onRetry: () {
                final slug = context.read<SettingsCubit>().state.name;
                context
                    .read<CharacterBloc>()
                    .add(CharacterLoad(slug, offline: offline));
              });
        }
        if (state is CharacterStateLoaded) {
          final classs =
              context.read<RulesCubit>().getClass(state.character['class']);
          if (classs == null) {
            return Container();
          }
          final classTable = parseTable(classs['table'] ?? '');
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
                          table: classTable,
                        ),
                        SkillsTab(
                          character: state.character,
                          slug: state.slug,
                        ),
                        EquipTab(
                          character: state.character,
                          slug: state.slug,
                        )
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
