import 'package:dnd5e_dm_tools/core/data/models/character.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character/character_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character/character_state.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/equipment/equipment_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/equipment/equipment_event.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/equipment/equipment_state.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/equip_tab/widgets/backpack_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EquipTab extends StatelessWidget {
  const EquipTab({super.key, required this.character});
  final Character character;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Flex(
        direction: Axis.vertical,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.75 < 300
                ? 500
                : MediaQuery.of(context).size.height * 0.8,
            child: BlocBuilder<EquipmentBloc, EquipmentState>(
              builder: (context, state) {
                if (state is EquipmentLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is EquipmentLoaded) {
                  final characterBlocState = context
                      .read<CharacterBloc>()
                      .state;
                  if (characterBlocState is CharacterLoaded &&
                      characterBlocState.character.slug ==
                          state.characterSlug) {
                    return BackpackWidget(backpack: state.backpack);
                  } else {
                    context.read<EquipmentBloc>().add(
                      BuildBackpack(character: character),
                    );
                  }
                } else if (state is EquipmentError) {
                  return Center(child: Text(state.error));
                } else if (state is EquipmentInitial) {
                  context.read<EquipmentBloc>().add(
                    BuildBackpack(character: character),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
