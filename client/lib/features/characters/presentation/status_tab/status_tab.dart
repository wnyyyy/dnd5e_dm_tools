import 'package:dnd5e_dm_tools/core/util/const.dart';
import 'package:dnd5e_dm_tools/core/util/helper.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_events.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/status_tab/widgets/action_menu/action_menu.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/status_tab/widgets/hitdice.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/status_tab/widgets/hp.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/status_tab/widgets/inspiration.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/status_tab/widgets/spellbook.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/status_tab/widgets/stats.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_cubit.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttericon/octicons_icons.dart';

class StatusTab extends StatelessWidget {
  final Map<String, dynamic> character;
  final String slug;
  final List<Map<String, dynamic>> table;

  const StatusTab({
    super.key,
    required this.character,
    required this.slug,
    required this.table,
  });

  @override
  Widget build(BuildContext context) {
    character['asi'] ??= {
      'dexterity': 10,
      'constitution': 10,
      'wisdom': 10,
      'intelligence': 10,
      'charisma': 10,
      'strength': 10,
    };
    character['ac'] ??= 0;
    character['initiative'] ??= getModifier(character['asi']?['dexterity']);
    character['speed'] ??= 30;
    character['hp_max'] ??= 1;
    character['hp_curr'] ??= 1;
    character['hd_max'] ??= 1;
    character['hd_curr'] ??= 1;

    final classs = context.read<RulesCubit>().getClass(character['class']);
    final isCaster = context.read<SettingsCubit>().state.isCaster;
    final Map<String, dynamic> spells = {};
    int spellAttackBonus = 0;
    int spellSaveDC = 0;

    if (isCaster) {
      final classOnly = context.read<SettingsCubit>().state.classOnlySpells;
      spells.addAll(
        classOnly
            ? context.read<RulesCubit>().getSpellsByClass(character['class'])
            : context.read<RulesCubit>().getAllSpells(),
      );

      final spellcastingAbility =
          (classs?['spellcasting_ability'] ?? 'intelligence')
              .toString()
              .toLowerCase();
      final mod = getModifier(character['asi']![spellcastingAbility] ?? 0);
      spellSaveDC = 8 + mod + getProfBonus(character['level'] ?? 1);
      spellAttackBonus = mod + getProfBonus(character['level'] ?? 1);
    }

    if (classs == null) {
      return Container();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return constraints.maxWidth > wideScreenBreakpoint
            ? _buildWideLayout(context, classs, isCaster, spells,
                spellAttackBonus, spellSaveDC)
            : _buildNarrowLayout(context, classs, isCaster, spells,
                spellAttackBonus, spellSaveDC);
      },
    );
  }

  Widget _buildWideLayout(
    BuildContext context,
    Map<String, dynamic> classs,
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
                Flex(
                  direction: Axis.vertical,
                  children: [
                    Hitpoints(character: character, slug: slug),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        HitDice(
                            character: character, classs: classs, slug: slug),
                        Inspiration(character: character, slug: slug)
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Flex(
                  direction: Axis.vertical,
                  children: [
                    if (isCaster)
                      _buildSpellInfo(
                          context, spells, spellAttackBonus, spellSaveDC),
                    StatsView(
                      onSave: () => context.read<CharacterBloc>().add(
                            CharacterUpdate(
                              character: character,
                              slug: slug,
                              offline: context
                                  .read<SettingsCubit>()
                                  .state
                                  .offlineMode,
                              persistData: true,
                            ),
                          ),
                      character: character,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ActionMenu(
                character: character,
                slug: slug,
                height: MediaQuery.of(context).size.height * 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNarrowLayout(
    BuildContext context,
    Map<String, dynamic> classs,
    bool isCaster,
    Map<String, dynamic> spells,
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
                    Hitpoints(character: character, slug: slug),
                    SizedBox(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          HitDice(
                              character: character, classs: classs, slug: slug),
                          Inspiration(character: character, slug: slug),
                        ],
                      ),
                    ),
                  ],
                ),
                Flex(
                  direction: Axis.vertical,
                  children: [
                    if (isCaster)
                      _buildSpellInfo(
                          context, spells, spellAttackBonus, spellSaveDC),
                    StatsView(
                      onSave: () => context.read<CharacterBloc>().add(
                            CharacterUpdate(
                              character: character,
                              slug: slug,
                              offline: context
                                  .read<SettingsCubit>()
                                  .state
                                  .offlineMode,
                              persistData: true,
                            ),
                          ),
                      character: character,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            ActionMenu(character: character, slug: slug),
            const SizedBox(height: 400),
          ],
        ),
      ),
    );
  }

  Widget _buildSpellInfo(
    BuildContext context,
    Map<String, dynamic> spells,
    int spellAttackBonus,
    int spellSaveDC,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
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
                    content: Spellbook(
                      character: character,
                      spells: spells,
                      slug: slug,
                      table: table,
                      updateCharacter: () => context.read<CharacterBloc>().add(
                            CharacterUpdate(
                              character: character,
                              slug: slug,
                              persistData: true,
                              offline: context
                                  .read<SettingsCubit>()
                                  .state
                                  .offlineMode,
                            ),
                          ),
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
          Card.filled(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  _buildSpellStat(
                      context, '+$spellAttackBonus', 'Spell\nAttack\nBonus'),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: SizedBox(
                      height: 45,
                      child: VerticalDivider(),
                    ),
                  ),
                  _buildSpellStat(context, '$spellSaveDC', 'Spell\nSave\nDC'),
                ],
              ),
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
}
