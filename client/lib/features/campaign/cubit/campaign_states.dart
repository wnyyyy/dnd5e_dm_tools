import 'package:dnd5e_dm_tools/features/campaign/data/models/adventure.dart';
import 'package:dnd5e_dm_tools/features/campaign/data/models/character.dart';
import 'package:dnd5e_dm_tools/features/campaign/data/models/location.dart';
import 'package:equatable/equatable.dart';

abstract class CampaignState extends Equatable {}

class CampaignInitial extends CampaignState {
  @override
  List<Object?> get props => [];
}

class CampaignError extends CampaignState {
  @override
  List<Object?> get props => [];
}

class CampaignLoading extends CampaignState {
  @override
  List<Object?> get props => [];
}

class CampaignLoaded extends CampaignState {
  final List<Location> locations;
  final List<Character> characters;
  final Adventure adventure;

  CampaignLoaded({
    required this.locations,
    required this.characters,
    required this.adventure,
  });
  @override
  List<Object?> get props => [locations, characters, adventure];
}
