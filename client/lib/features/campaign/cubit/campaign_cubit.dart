import 'dart:async';

import 'package:dnd5e_dm_tools/features/campaign/cubit/campaign_states.dart';
import 'package:dnd5e_dm_tools/features/campaign/data/models/adventure.dart';
import 'package:dnd5e_dm_tools/features/campaign/data/repository/campaign_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum CampaignTab { locations, characters, adventure }

class CampaignCubit extends Cubit<CampaignState> {
  CampaignCubit({
    required this.campaignRepository,
  }) : super(CampaignInitial());
  final CampaignRepository campaignRepository;
  StreamSubscription? _locationsSubscription;
  StreamSubscription? _charactersSubscription;
  StreamSubscription? _adventureSubscription;

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

    _locationsSubscription = campaignRepository.getLocationsStream().listen(
      (locations) {
        if (state is CampaignLoaded) {
          emit((state as CampaignLoaded).copyWith(locations: locations));
        } else if (state is CampaignLoading) {
          emit(
            CampaignLoaded(
              locations: locations,
              characters: const [],
              adventure: const Adventure(entries: []),
            ),
          );
        }
      },
      onError: (error) {
        emit(CampaignError(message: error.toString()));
      },
    );

    _charactersSubscription = campaignRepository.getCharactersStream().listen(
      (characters) {
        if (state is CampaignLoaded) {
          emit((state as CampaignLoaded).copyWith(characters: characters));
        } else if (state is CampaignLoading) {
          emit(
            CampaignLoaded(
              locations: const [],
              characters: characters,
              adventure: const Adventure(entries: []),
            ),
          );
        }
      },
      onError: (error) {
        emit(CampaignError(message: error.toString()));
      },
    );

    _adventureSubscription = campaignRepository.getAdventureStream().listen(
      (adventure) {
        if (state is CampaignLoaded) {
          emit((state as CampaignLoaded).copyWith(adventure: adventure));
        } else if (state is CampaignLoading) {
          emit(
            CampaignLoaded(
              locations: const [],
              characters: const [],
              adventure: adventure,
            ),
          );
        }
      },
      onError: (error) {
        emit(CampaignError(message: error.toString()));
      },
    );
  }

  Future<void> updateEntry({
    required String name,
    required String entryId,
    required String content,
    required CampaignTab type,
  }) async {
    try {
      switch (type) {
        case CampaignTab.locations:
          await campaignRepository.updateLocation(name, entryId, content);
        case CampaignTab.characters:
          await campaignRepository.updateCharacter(name, entryId, content);
        case CampaignTab.adventure:
          await campaignRepository.updateAdventureEntry(entryId, content);
      }
    } catch (e) {
      emit(CampaignError(message: e.toString()));
    }
  }

  Future<void> addEntry({
    required String name,
    required String content,
    required CampaignTab type,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      switch (type) {
        case CampaignTab.locations:
          await campaignRepository.addLocationEntry(name, content, timestamp);
        case CampaignTab.characters:
          await campaignRepository.addCharacterEntry(name, content, timestamp);
        case CampaignTab.adventure:
          await campaignRepository.addAdventureEntry(content, timestamp);
      }
    } catch (e) {
      emit(CampaignError(message: e.toString()));
    }
  }
}
