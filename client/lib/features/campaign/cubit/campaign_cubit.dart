import 'dart:async';

import 'package:dnd5e_dm_tools/features/campaign/data/models/adventure.dart';
import 'package:dnd5e_dm_tools/features/campaign/data/repository/campaign_repository.dart';
import 'package:dnd5e_dm_tools/features/campaign/cubit/campaign_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum CampaignTab { locations, characters, adventure }

class CampaignCubit extends Cubit<CampaignState> {
  final CampaignRepository campaignRepository;
  StreamSubscription? _locationsSubscription;

  CampaignCubit({
    required this.campaignRepository,
  }) : super(CampaignInitial());

  @override
  Future<void> close() {
    _locationsSubscription?.cancel();
    return super.close();
  }

  void loadCampaign() {
    if (state is CampaignLoading) {
      return;
    }

    emit(CampaignLoading());
    _locationsSubscription?.cancel();
    _locationsSubscription =
        campaignRepository.getLocationsStream().listen((locations) {
      emit(CampaignLoaded(
        locations: locations,
        characters: const [],
        adventure: const Adventure(entries: []),
      ));
    }, onError: (error) {
      emit(CampaignError());
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
          await campaignRepository.updateLocation(entryId, name, content);
          break;
        case CampaignTab.characters:
          //await campaignRepository.updateCharacter(entryId, name, content);
          break;
        case CampaignTab.adventure:
          //await campaignRepository.updateAdventureEntry(entryId, name, content);
          break;
      }
      // Optionally, reload or handle state change locally
    } catch (e) {
      // Handle exceptions, maybe emit error state
    }
  }
}
