import 'dart:async';

import 'package:dnd5e_dm_tools/features/campaign/data/models/adventure.dart';
import 'package:dnd5e_dm_tools/features/campaign/data/repository/campaign_repository.dart';
import 'package:dnd5e_dm_tools/features/campaign/cubit/campaign_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum CampaignTab { locations, characters, adventure }

class CampaignCubit extends Cubit<CampaignState> {
  final CampaignRepository campaignRepository;
  StreamSubscription? _locationsSubscription;
  StreamSubscription? _charactersSubscription;
  StreamSubscription? _adventureSubscription;

  CampaignCubit({
    required this.campaignRepository,
  }) : super(CampaignInitial());

  @override
  Future<void> close() {
    _locationsSubscription?.cancel();
    _charactersSubscription?.cancel();
    _adventureSubscription?.cancel();
    return super.close();
  }

  void retry() {
    emit(CampaignInitial());
    loadCampaign();
  }

  void loadCampaign() {
    emit(CampaignLoading());
    _locationsSubscription?.cancel();
    _charactersSubscription?.cancel();
    _adventureSubscription?.cancel();

    _locationsSubscription =
        campaignRepository.getLocationsStream().listen((locations) {
      if (state is CampaignLoaded) {
        emit((state as CampaignLoaded).copyWith(locations: locations));
      } else if (state is CampaignLoading) {
        emit(CampaignLoaded(
          locations: locations,
          characters: const [],
          adventure: const Adventure(entries: []),
        ));
      }
    }, onError: (error) {
      emit(CampaignError(message: error.toString()));
    });

    _charactersSubscription =
        campaignRepository.getCharactersStream().listen((characters) {
      if (state is CampaignLoaded) {
        emit((state as CampaignLoaded).copyWith(characters: characters));
      } else if (state is CampaignLoading) {
        emit(CampaignLoaded(
          locations: const [],
          characters: characters,
          adventure: const Adventure(entries: []),
        ));
      }
    }, onError: (error) {
      emit(CampaignError(message: error.toString()));
    });

    _adventureSubscription =
        campaignRepository.getAdventureStream().listen((adventure) {
      if (state is CampaignLoaded) {
        emit((state as CampaignLoaded).copyWith(adventure: adventure));
      } else if (state is CampaignLoading) {
        emit(CampaignLoaded(
          locations: const [],
          characters: const [],
          adventure: adventure,
        ));
      }
    }, onError: (error) {
      emit(CampaignError(message: error.toString()));
    });
  }

  Future<void> updateEntry({
    required String name,
    required int entryId,
    required String content,
    required CampaignTab type,
  }) async {
    try {
      switch (type) {
        case CampaignTab.locations:
          await campaignRepository.updateLocation(name, entryId, content);
          break;
        case CampaignTab.characters:
          await campaignRepository.updateCharacter(name, entryId, content);
          break;
        case CampaignTab.adventure:
          await campaignRepository.updateAdventureEntry(entryId, content);
          break;
      }
    } catch (e) {
      emit(CampaignError(message: e.toString()));
    }
  }
}
