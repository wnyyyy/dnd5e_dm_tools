import 'package:dnd5e_dm_tools/core/data/models/character.dart';
import 'package:dnd5e_dm_tools/core/data/models/class.dart';
import 'package:dnd5e_dm_tools/core/data/models/race.dart';
import 'package:dnd5e_dm_tools/core/util/const.dart';
import 'package:dnd5e_dm_tools/core/util/enum.dart';
import 'package:dnd5e_dm_tools/core/util/helper.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character/character_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character/character_event.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/status_tab/widgets/action_menu/action_menu.dart';
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
  const StatusTab({
    super.key,
    required this.character,
    required this.classs,
    required this.race,
  });
  final Character character;
  final Class classs;
  final Race race;

  @override
  Widget build(BuildContext context) {
    final asi = character.asi;

    final isCaster =
        context.read<SettingsCubit>().state.isCaster ||
        isMagicInitiate(character.feats);

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
    int spellAttackBonus,
    int spellSaveDC,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: screenWidth > 1200 ? 1 : 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Flex(
                direction: Axis.vertical,
                children: [
                  Hitpoints(
                    character: character,
                    onCharacterUpdated: (updatedCharacter) =>
                        onCharacterUpdated(updatedCharacter, context),
                  ),
                  if (screenWidth > 1200)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
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
                        if (isCaster)
                          _buildSpellInfo(
                            context,
                            spellAttackBonus,
                            spellSaveDC,
                          ),
                      ],
                    ),
                  if (screenWidth <= 1200)
                    Column(
                      children: [
                        Row(
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
                        if (isCaster)
                          _buildSpellInfo(
                            context,
                            spellAttackBonus,
                            spellSaveDC,
                          ),
                      ],
                    ),
                  StatsWidget(
                    character: character,
                    onCharacterUpdated: (updatedCharacter) =>
                        onCharacterUpdated(updatedCharacter, context),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: screenWidth > 1750 ? 3 : 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ActionMenu(
                character: character,
                classs: classs,
                race: race,
                onCharacterUpdated: (updatedCharacter) =>
                    onCharacterUpdated(updatedCharacter, context),
              ),
            ),
          ),
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
            Row(
              children: [
                Column(
                  children: [
                    Hitpoints(
                      character: character,
                      onCharacterUpdated: (updatedCharacter) =>
                          onCharacterUpdated(updatedCharacter, context),
                    ),
                    if (isCaster)
                      _buildSpellInfo(context, spellAttackBonus, spellSaveDC),
                  ],
                ),
                Column(
                  children: [
                    StatsWidget(
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
              ],
            ),

            ActionMenu(
              character: character,
              classs: classs,
              race: race,
              onCharacterUpdated: (updatedCharacter) =>
                  onCharacterUpdated(updatedCharacter, context),
            ),
            const SizedBox(height: 400),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        children: [
          Card.filled(
            child: Row(
              mainAxisSize: MainAxisSize.min,
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
          const SizedBox(height: 4),
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
