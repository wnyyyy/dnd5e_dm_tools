import 'package:dnd5e_dm_tools/core/data/models/character.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character/character_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character/character_event.dart';
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
    const double minHeight = 500;
    final double maxHeight = MediaQuery.of(context).size.height * 0.8;
    final double height = maxHeight < 300 ? minHeight : maxHeight;

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: height,
            child: BlocBuilder<EquipmentBloc, EquipmentState>(
              builder: (context, state) {
                if (state is EquipmentLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is EquipmentCustomItemCreated) {
                  final updatedCharacter = character.copyWith(
                    backpack: state.updatedBackpack,
                  );
                  context.read<CharacterBloc>().add(
                    CharacterUpdate(
                      character: updatedCharacter,
                      persistData: true,
                    ),
                  );
                  context.read<EquipmentBloc>().add(
                    BuildBackpack(character: updatedCharacter),
                  );
                }

                if (state is EquipmentLoaded) {
                  final characterBlocState = context
                      .read<CharacterBloc>()
                      .state;
                  final isSameCharacter =
                      characterBlocState is CharacterLoaded &&
                      characterBlocState.character.slug == state.characterSlug;

                  if (isSameCharacter) {
                    return BackpackWidget(
                      backpack: state.backpack,
                      onBackpackUpdated: (backpack) {
                        final updatedCharacter = character.copyWith(
                          backpack: backpack,
                        );
                        context.read<CharacterBloc>().add(
                          CharacterUpdate(
                            character: updatedCharacter,
                            persistData: true,
                          ),
                        );
                        context.read<EquipmentBloc>().add(
                          BuildBackpack(character: updatedCharacter),
                        );
                      },
                    );
                  } else {
                    context.read<EquipmentBloc>().add(
                      BuildBackpack(character: character),
                    );
                  }
                }

                if (state is EquipmentError) {
                  return Center(child: Text(state.error));
                }

                if (state is EquipmentInitial) {
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
