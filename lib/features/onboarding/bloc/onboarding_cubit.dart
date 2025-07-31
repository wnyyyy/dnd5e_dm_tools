import 'package:dnd5e_dm_tools/core/data/repositories/characters_repository.dart';
import 'package:dnd5e_dm_tools/core/util/logger.dart';
import 'package:dnd5e_dm_tools/features/onboarding/bloc/onboarding_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit({required this.charactersRepository})
    : super(OnboardingInitial());
  final CharactersRepository charactersRepository;

  Future<void> loadCharacters(int startPos) async {
    emit(OnboardingLoading());
    try {
      logBloc('Loading characters for onboarding');
      final characters = await charactersRepository.getAll();
      if (characters.isEmpty) {
        logBloc('No characters found for onboarding', level: Level.warning);
        emit(OnboardingError('No characters found'));
        return;
      }
      final index = startPos % characters.length;
      final firstCharacter = characters[index].slug;
      emit(
        OnboardingLoaded(
          characters: characters,
          selectedCharacter: firstCharacter,
        ),
      );
    } catch (error) {
      logBloc('Error loading characters: $error', level: Level.error);
      emit(OnboardingError('Failed to load characters'));
    }
  }

  void selectCharacter(String characterSlug) {
    final currentState = state as OnboardingLoaded;
    emit(currentState.copyWith(selectedCharacter: characterSlug));
  }
}
