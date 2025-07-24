import 'package:dnd5e_dm_tools/core/data/models/character.dart';
import 'package:dnd5e_dm_tools/core/data/models/class.dart';
import 'package:dnd5e_dm_tools/core/data/models/spell.dart';
import 'package:dnd5e_dm_tools/core/data/models/spellbook.dart';
import 'package:dnd5e_dm_tools/core/util/const.dart';
import 'package:dnd5e_dm_tools/core/util/enum.dart';
import 'package:dnd5e_dm_tools/core/util/helper.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character/character_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character/character_event.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/status_tab/widgets/hitdice.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/status_tab/widgets/hitpoints.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/status_tab/widgets/inspiration.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/status_tab/widgets/spellbook_widget.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/status_tab/widgets/stats_widget.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_cubit.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_state.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttericon/octicons_icons.dart';

class StatusTab extends StatelessWidget {
  const StatusTab({super.key, required this.character, required this.classs});
  final Character character;
  final Class classs;

  @override
  Widget build(BuildContext context) {
    final asi = character.asi;

    final isCaster =
        context.read<SettingsCubit>().state.isCaster ||
        character.feats.containsKey('magic_initiate') ||
        character.feats.containsKey('magic-initiate');

    final Map<String, dynamic> spells = {};
    int spellAttackBonus = 0;
    int spellSaveDC = 0;
    final profBonus = getProfBonus(character.level);

    if (isCaster) {
      final spellcastingAbility =
          classs.spellCastingAbility ?? Attribute.intelligence;
      final mod = getModifier(asi.fromAttribute(spellcastingAbility));
      spellSaveDC = 8 + mod + profBonus;
      spellAttackBonus = mod + profBonus;
    }

    return BlocBuilder<RulesCubit, RulesState>(
      builder: (context, state) {
        if (state is RulesStateLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is! RulesStateLoaded) {
          return const SizedBox.shrink();
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            return constraints.maxWidth > wideScreenBreakpoint
                ? _buildWideLayout(
                    context,
                    isCaster,
                    spells,
                    spellAttackBonus,
                    spellSaveDC,
                  )
                : _buildNarrowLayout(
                    context,
                    isCaster,
                    spellAttackBonus,
                    spellSaveDC,
                  );
          },
        );
      },
    );
  }

  Widget _buildWideLayout(
    BuildContext context,
    bool isCaster,
    Map<String, dynamic> spells,
    int spellAttackBonus,
    int spellSaveDC,
  ) {
    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Flex(
              direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Flex(direction: Axis.vertical),
                const SizedBox(width: 16),
                Flex(
                  direction: Axis.vertical,
                  children: [
                    if (isCaster)
                      _buildSpellInfo(context, spellAttackBonus, spellSaveDC),
                    StatsWidget(
                      character: character,
                      onCharacterUpdated: (updatedCharacter) =>
                          onCharacterUpdated(updatedCharacter, context),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Expanded(
          //   child: Padding(
          //     padding: const EdgeInsets.all(16.0),
          //     child: ActionMenu(
          //       character: character,
          //       slug: slug,
          //       height: MediaQuery.of(context).size.height * 0.6,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildNarrowLayout(
    BuildContext context,
    bool isCaster,
    int spellAttackBonus,
    int spellSaveDC,
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Flex(
              direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flex(
                  direction: Axis.vertical,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Hitpoints(
                      character: character,
                      onCharacterUpdated: (updatedCharacter) =>
                          onCharacterUpdated(updatedCharacter, context),
                    ),
                    SizedBox(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          HitDice(
                            character: character,
                            classs: classs,
                            onCharacterUpdated: (updatedCharacter) =>
                                onCharacterUpdated(updatedCharacter, context),
                          ),
                          Inspiration(
                            character: character,
                            onCharacterUpdated: (updatedCharacter) =>
                                onCharacterUpdated(updatedCharacter, context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Flex(
                  direction: Axis.vertical,
                  children: [
                    if (isCaster)
                      _buildSpellInfo(context, spellAttackBonus, spellSaveDC),
                    StatsWidget(
                      character: character,
                      onCharacterUpdated: (updatedCharacter) =>
                          onCharacterUpdated(updatedCharacter, context),
                    ),
                  ],
                ),
              ],
            ),
            // const SizedBox(height: 16),
            // ActionMenu(character: character, slug: slug),
            // const SizedBox(height: 400),
          ],
        ),
      ),
    );
  }

  Widget _buildSpellInfo(
    BuildContext context,
    int spellAttackBonus,
    int spellSaveDC,
  ) {
    final rulesState = context.watch<RulesCubit>().state;
    if (rulesState is! RulesStateLoaded) {
      return const SizedBox.shrink();
    }
    final spells = rulesState.spells;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        children: [
          IconButton.outlined(
            padding: const EdgeInsets.all(12),
            iconSize: 36,
            icon: const Icon(Octicons.book),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Spellbook'),
                    content: SpellbookWidget(
                      character: character,
                      classs: classs,
                      spells: spells,
                      onCharacterUpdated: (updatedCharacter) =>
                          onCharacterUpdated(updatedCharacter, context),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Icon(Icons.done),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          const SizedBox(height: 4),
          Card.filled(
            child: Row(
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 70, maxWidth: 90),
                  child: _buildSpellStat(
                    context,
                    '+$spellAttackBonus',
                    'Spell Attack Bonus',
                  ),
                ),
                const SizedBox(height: 45, child: VerticalDivider()),
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 70, maxWidth: 90),
                  child: _buildSpellStat(
                    context,
                    '$spellSaveDC',
                    'Spell Save DC',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpellStat(BuildContext context, String value, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> onCharacterUpdated(
    Character updatedCharacter,
    BuildContext context,
  ) async {
    context.read<CharacterBloc>().add(
      CharacterUpdate(character: updatedCharacter, persistData: true),
    );
  }
}
