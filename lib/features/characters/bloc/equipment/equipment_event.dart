import 'package:dnd5e_dm_tools/core/data/models/backpack.dart';
import 'package:dnd5e_dm_tools/core/data/models/character.dart';
import 'package:dnd5e_dm_tools/core/data/models/item.dart';
import 'package:equatable/equatable.dart';

abstract class EquipmentEvent extends Equatable {
  const EquipmentEvent();

  @override
  List<Object> get props => [];
}

class BuildBackpack extends EquipmentEvent {
  const BuildBackpack({required this.character});

  final Character character;

  @override
  List<Object> get props => [character];
}

class CreateCustomItem extends EquipmentEvent {
  const CreateCustomItem({required this.item, required this.currentBackpack});

  final Item item;
  final Backpack currentBackpack;

  @override
  List<Object> get props => [item, currentBackpack];
}
