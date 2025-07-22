import 'package:dnd5e_dm_tools/core/data/models/character.dart';
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
