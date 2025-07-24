import 'package:dnd5e_dm_tools/core/data/models/backpack_item.dart';
import 'package:dnd5e_dm_tools/core/data/models/character.dart';
import 'package:dnd5e_dm_tools/core/data/models/item.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/items_repository.dart';
import 'package:dnd5e_dm_tools/core/util/logger.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/equipment/equipment_event.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/equipment/equipment_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

class EquipmentBloc extends Bloc<EquipmentEvent, EquipmentState> {
  EquipmentBloc({required this.itemsRepository}) : super(EquipmentInitial()) {
    on<BuildBackpack>(_onBuildBackpack);
    on<CreateCustomItem>(_onCreateCustomItem);
  }
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
          isEquipped: backpackItem.isEquipped,
        ),
      );
    }
    return newItemList;
  }

  Future<void> _onCreateCustomItem(
    CreateCustomItem event,
    Emitter<EquipmentState> emit,
  ) async {
    try {
      emit(EquipmentLoading());
      final item = event.item;
      if (item.slug.isEmpty) {
        throw Exception('Item slug cannot be empty');
      }
      final updatedBackpack = event.currentBackpack.copyWith(
        items: [
          ...event.currentBackpack.items,
          BackpackItem(itemSlug: item.slug, quantity: 1, item: item),
        ],
      );
      await itemsRepository.save(item.slug, item, false);
      logBloc('Custom item created: ${item.slug}');
      emit(
        EquipmentCustomItemCreated(
          item: item,
          updatedBackpack: updatedBackpack,
        ),
      );
    } catch (error) {
      logBloc('Error creating custom item: $error', level: Level.error);
      emit(EquipmentError(error: 'Failed to create custom item - $error'));
    }
  }
}
