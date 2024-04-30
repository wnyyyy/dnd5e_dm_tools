import 'package:equatable/equatable.dart';

abstract class CharacterState extends Equatable {
  const CharacterState();

  @override
  List<Object> get props => [];
}

class CharacterStateInitial extends CharacterState {
  @override
  List<Object> get props => [];
}

class CharacterStateLoading extends CharacterState {
  @override
  List<Object> get props => [];
}

class CharacterStateError extends CharacterState {
  final String error;
  const CharacterStateError(this.error);

  @override
  List<Object> get props => [error];
}

class CharacterStateLoaded extends CharacterState {
  final Map<String, dynamic> character;
  final Map<String, dynamic> race;
  final Map<String, dynamic> classs;
  final String name;
  final bool editingFeats;
  final bool editingProf;
  final Map<String, dynamic>? showFeatDetails;
  final Map<String, Map>? availableFeats;
  const CharacterStateLoaded({
    required this.character,
    required this.name,
    required this.race,
    required this.classs,
    this.showFeatDetails,
    this.availableFeats,
    this.editingFeats = false,
    this.editingProf = false,
  });

  CharacterStateLoaded copyWith({
    Map<String, dynamic>? character,
    Map<String, dynamic>? race,
    Map<String, dynamic>? classs,
    String? name,
    Map<String, dynamic>? showFeatDetails,
    Map<String, Map>? availableFeats,
    bool? editingFeats,
    bool? editingProf,
  }) {
    return CharacterStateLoaded(
      character: character ?? this.character,
      race: race ?? this.race,
      classs: classs ?? this.classs,
      name: name ?? this.name,
      availableFeats: availableFeats ?? this.availableFeats,
      showFeatDetails: showFeatDetails ?? this.showFeatDetails,
      editingFeats: editingFeats ?? this.editingFeats,
      editingProf: editingProf ?? this.editingProf,
    );
  }

  @override
  List<Object> get props => [
        ...character.entries,
        name,
        race,
        classs,
        editingFeats,
        editingProf,
      ];
}
