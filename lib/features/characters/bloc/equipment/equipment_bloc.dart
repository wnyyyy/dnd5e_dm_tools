import 'package:dnd5e_dm_tools/core/data/models/backpack_item.dart';
import 'package:dnd5e_dm_tools/core/data/models/character.dart';
import 'package:dnd5e_dm_tools/core/data/models/item.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/characters_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/items_repository.dart';
import 'package:dnd5e_dm_tools/core/util/logger.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/equipment/equipment_event.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/equipment/equipment_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

class EquipmentBloc extends Bloc<EquipmentEvent, EquipmentState> {
  EquipmentBloc({
    required this.charactersRepository,
    required this.itemsRepository,
  }) : super(EquipmentInitial()) {
    on<BuildBackpack>(_onBuildBackpack);
  }
  final CharactersRepository charactersRepository;
  final ItemsRepository itemsRepository;

  Future<void> _onBuildBackpack(
    BuildBackpack event,
    Emitter<EquipmentState> emit,
  ) async {
    emit(EquipmentLoading());
    try {
      final newItems = await _buildBackpackItems(event.character);
      emit(
        EquipmentLoaded(
          backpack: event.character.backpack.copyWith(items: newItems),
          characterSlug: event.character.slug,
        ),
      );
    } catch (error) {
      emit(EquipmentError(error: 'Failed to load backpack - $error'));
    }
  }

  Future<List<BackpackItem>> _buildBackpackItems(Character character) async {
    final newItemList = <BackpackItem>[];
    for (final backpackItem in character.backpack.items) {
      if (backpackItem.itemSlug.isEmpty) {
        continue;
      }
      final Item item;
      try {
        item = await itemsRepository.get(backpackItem.itemSlug);
      } catch (e) {
        logBloc(
          'Failed to load item: ${backpackItem.itemSlug} for character: ${character.slug} - $e',
          level: Level.warning,
        );
        continue;
      }
      newItemList.add(
        BackpackItem(
          itemSlug: backpackItem.itemSlug,
          quantity: backpackItem.quantity,
          item: item,
        ),
      );
    }
    return newItemList;
  }
}
