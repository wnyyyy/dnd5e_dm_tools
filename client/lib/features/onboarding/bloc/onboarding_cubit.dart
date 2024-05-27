import 'package:dnd5e_dm_tools/core/data/repositories/characters_repository.dart';
import 'package:dnd5e_dm_tools/features/onboarding/bloc/onboarding_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final CharactersRepository charactersRepository;

  OnboardingCubit({
    required this.charactersRepository,
  }) : super(OnboardingInitial());

  void loadCharacters() async {
    emit(OnboardingLoading());
    try {
      final characters = await charactersRepository.getAll();
      emit(OnboardingLoaded(characters: characters));
    } catch (error) {
      emit(OnboardingError("Failed to load characters"));
    }
  }
}
