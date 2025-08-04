import 'package:equatable/equatable.dart';

abstract class DatabaseEditorState extends Equatable {
  const DatabaseEditorState({required this.selectedIndex, required this.selectedUpdate});
  final int selectedIndex;
  final bool selectedUpdate;

  @override
  List<Object?> get props => [selectedIndex, selectedUpdate];
}

class DatabaseEditorInitial extends DatabaseEditorState {
  const DatabaseEditorInitial({required super.selectedIndex, required super.selectedUpdate});
}

class DatabaseEditorError extends DatabaseEditorState {
  const DatabaseEditorError({required super.selectedIndex, required super.selectedUpdate, this.message});
  final String? message;
}

class DatabaseEditorSynced extends DatabaseEditorState {
  const DatabaseEditorSynced({
    required super.selectedIndex,
    required super.selectedUpdate,
    this.type,
    required this.previousState,
  });

  final String? type;
  final DatabaseEditorLoaded previousState;
  @override
  List<Object?> get props => [selectedIndex, selectedUpdate, type, previousState];
}

class DatabaseEditorLoading extends DatabaseEditorState {
  const DatabaseEditorLoading({required super.selectedIndex, required super.selectedUpdate});
}

class DatabaseEditorLoaded extends DatabaseEditorState {
  const DatabaseEditorLoaded({
    required this.entry,
    required this.originalEntry,
    required this.slug,
    required super.selectedIndex,
    required super.selectedUpdate,
  });
  final Map<String, dynamic> entry;
  final Map<String, dynamic> originalEntry;
  final String slug;

  DatabaseEditorLoaded copyWith({
    Map<String, dynamic>? entry,
    Map<String, dynamic>? originalEntry,
    String? slug,
  }) {
    return DatabaseEditorLoaded(
      entry: entry ?? this.entry,
      originalEntry: originalEntry ?? this.originalEntry,
      slug: slug ?? this.slug,
      selectedIndex: selectedIndex,
      selectedUpdate: selectedUpdate,
    );
  }

  @override
  List<Object?> get props => [entry, originalEntry, slug, selectedIndex, selectedUpdate];
}
