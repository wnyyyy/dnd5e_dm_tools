import 'package:dnd5e_dm_tools/features/campaign/data/repository/campaign_repository.dart';
import 'package:dnd5e_dm_tools/features/campaign/cubit/campaign_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CampaignCubit extends Cubit<CampaignState> {
  final CampaignRepository campaignRepository;

  CampaignCubit({
    required this.campaignRepository,
  }) : super(CampaignInitial());

  void loadCampaign() async {
    emit(CampaignLoading());
    try {
      final locations = await campaignRepository.getLocations();
      final characters = await campaignRepository.getCharacters();
      final adventure = await campaignRepository.getAdventure();
      emit(CampaignLoaded(
        locations: locations,
        characters: characters,
        adventure: adventure,
      ));
    } catch (e) {
      emit(CampaignError());
    }
  }
}
