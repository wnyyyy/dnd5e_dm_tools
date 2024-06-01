abstract class OnboardingState {

  OnboardingState();
  Map<String, dynamic> characters = Map<String, dynamic>.from({});
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
    required Map<String, dynamic> characters,
    required String selectedCharacter,
  }) {
    this.characters = characters;
    this.selectedCharacter = selectedCharacter;
  }

  OnboardingLoaded copyWith({
    Map<String, dynamic>? characters,
    String? selectedCharacter,
  }) {
    return OnboardingLoaded(
      characters: characters ?? this.characters,
      selectedCharacter: selectedCharacter ?? this.selectedCharacter,
    );
  }
}
