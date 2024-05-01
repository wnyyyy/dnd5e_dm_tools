import 'package:dnd5e_dm_tools/core/util/helper.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_events.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/status_tab/widgets/hitdice.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/status_tab/widgets/hp.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/status_tab/widgets/stats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StatusTab extends StatelessWidget {
  final Map<String, dynamic> character;
  final Map<String, dynamic> race;
  final Map<String, dynamic> classs;
  final String name;

  const StatusTab({
    super.key,
    required this.character,
    required this.name,
    required this.race,
    required this.classs,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flex(
              direction: Axis.vertical,
              children: [
                Hitpoints(
                  character: character,
                  classs: classs,
                  race: race,
                  name: name,
                ),
                HitDice(
                    character: character,
                    classs: classs,
                    race: race,
                    name: name)
              ],
            ),
            StatsView(
                onSave: () => context.read<CharacterBloc>().add(CharacterUpdate(
                    character: character,
                    race: race,
                    classs: classs,
                    name: name)),
                character: character),
          ],
        ),
      ),
    );
  }

  Widget _buildHitDice() {
    return Container();
  }
}
