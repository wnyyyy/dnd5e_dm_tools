abstract class OnboardingState {
  var characters = Map<String, dynamic>.from({});

  OnboardingState();
}

class OnboardingInitial extends OnboardingState {}

class OnboardingLoading extends OnboardingState {}

class OnboardingError extends OnboardingState {
  final String message;

  OnboardingError(this.message);
}

class OnboardingLoaded extends OnboardingState {
  OnboardingLoaded({required Map<String, Map<String, dynamic>> characters}) {
    this.characters = characters;
  }
}
