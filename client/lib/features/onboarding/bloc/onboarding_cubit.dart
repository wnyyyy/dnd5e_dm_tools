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
      if (characters.isEmpty) {
        emit(OnboardingError("No characters found"));
        return;
      }
      final firstCharacter = characters.keys.first;
      emit(OnboardingLoaded(
        characters: characters,
        selectedCharacter: firstCharacter,
      ));
    } catch (error) {
      emit(OnboardingError("Failed to load characters"));
    }
  }

  void selectCharacter(String characterSlug) {
    final currentState = state as OnboardingLoaded;
    emit(currentState.copyWith(selectedCharacter: characterSlug));
  }
}
