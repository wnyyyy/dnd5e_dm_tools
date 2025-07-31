import 'package:dnd5e_dm_tools/core/data/models/character.dart';

abstract class OnboardingState {
  OnboardingState();
  List<Character> characters = [];
  String selectedCharacter = '';
}

class OnboardingInitial extends OnboardingState {}

class OnboardingLoading extends OnboardingState {}

class OnboardingError extends OnboardingState {
  OnboardingError(this.message);
  final String message;
}

class OnboardingLoaded extends OnboardingState {
  OnboardingLoaded({
    required List<Character> characters,
    required String selectedCharacter,
  }) {
    this.characters = characters;
    this.selectedCharacter = selectedCharacter;
  }

  OnboardingLoaded copyWith({
    List<Character>? characters,
    String? selectedCharacter,
  }) {
    return OnboardingLoaded(
      characters: characters ?? this.characters,
      selectedCharacter: selectedCharacter ?? this.selectedCharacter,
    );
  }
}
