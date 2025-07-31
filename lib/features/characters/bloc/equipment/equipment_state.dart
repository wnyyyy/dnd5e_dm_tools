import 'package:dnd5e_dm_tools/core/data/models/backpack.dart';
import 'package:dnd5e_dm_tools/core/data/models/item.dart';
import 'package:equatable/equatable.dart';

abstract class EquipmentState extends Equatable {
  const EquipmentState();
  @override
  List<Object> get props => [];
}

class EquipmentInitial extends EquipmentState {}

class EquipmentLoading extends EquipmentState {}

class EquipmentError extends EquipmentState {
  const EquipmentError({required this.error});
  final String error;

  @override
  List<Object> get props => [error];
}

class EquipmentLoaded extends EquipmentState {
  const EquipmentLoaded({required this.backpack, required this.characterSlug});
  final Backpack backpack;
  final String characterSlug;

  EquipmentLoaded copyWith({Backpack? backpack}) {
    return EquipmentLoaded(
      backpack: backpack ?? this.backpack,
      characterSlug: characterSlug,
    );
  }

  @override
  List<Object> get props => [backpack, characterSlug];
}

class EquipmentCustomItemCreated extends EquipmentState {
  const EquipmentCustomItemCreated({
    required this.item,
    required this.updatedBackpack,
  });
  final Item item;
  final Backpack updatedBackpack;

  @override
  List<Object> get props => [item, updatedBackpack];
}
