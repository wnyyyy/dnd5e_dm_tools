import 'package:dnd5e_dm_tools/core/widgets/error_handler.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character/character_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character/character_event.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character/character_state.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/bio_tab/bio_tab.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/equip_tab/equip_tab.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/skills_tab/skills_tab.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/status_tab/status_tab.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_cubit.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_state.dart';
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

class CharacterScreen extends StatefulWidget {
  const CharacterScreen({super.key});

  @override
  State<CharacterScreen> createState() => _CharacterScreenState();
}

class _CharacterScreenState extends State<CharacterScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: _tabIndex,
    );
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _tabIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RulesCubit, RulesState>(
      builder: (context, rulesState) {
        if (rulesState is RulesStateInitial ||
            rulesState is RulesStateLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (rulesState is RulesStateError) {
          return ErrorHandler(
            error: rulesState.message,
            onRetry: () {
              context.read<RulesCubit>().loadRules();
            },
          );
        }
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
            if (state is CharacterPostStart) {
              if (state.reloadItems) {
                context.read<RulesCubit>().reloadRule('items');
              }
              if (state.reloadSpells) {
                context.read<RulesCubit>().reloadRule('spells');
              }
              context.read<CharacterBloc>().add(
                CharacterPostLoad(
                  character: state.character,
                  classs: state.classs,
                  race: state.race,
                ),
              );
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
              if (_tabController.length != 4 ||
                  _tabController.index != _tabIndex) {
                _tabController.dispose();
                _tabController = TabController(
                  length: 4,
                  vsync: this,
                  initialIndex: _tabIndex,
                );
                _tabController.addListener(() {
                  if (_tabController.indexIsChanging) {
                    setState(() {
                      _tabIndex = _tabController.index;
                    });
                  }
                });
              }
              return DefaultTabController(
                length: 4,
                initialIndex: _tabIndex,
                child: Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(text: 'Bio'),
                        Tab(text: 'Status'),
                        Tab(text: 'Skills'),
                        Tab(text: 'Equip'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        physics: const NoScrollPhysics(),
                        children: [
                          BioTab(
                            character: state.character,
                            classs: state.classs,
                            race: state.race,
                          ),
                          StatusTab(
                            character: state.character,
                            classs: state.classs,
                            race: state.race,
                          ),
                          SkillsTab(
                            character: state.character,
                            classs: state.classs,
                          ),
                          EquipTab(character: state.character),
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
      },
    );
  }
}
