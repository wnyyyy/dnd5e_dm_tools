import 'package:equatable/equatable.dart';

abstract class DatabaseEditorState extends Equatable {
  const DatabaseEditorState({required this.selectedIndex});
  final int selectedIndex;
  @override
  List<Object?> get props => [selectedIndex];
}

class DatabaseEditorInitial extends DatabaseEditorState {
  const DatabaseEditorInitial({required super.selectedIndex});
}

class DatabaseEditorError extends DatabaseEditorState {
  const DatabaseEditorError({required super.selectedIndex, this.message});
  final String? message;
}

class DatabaseEditorSynced extends DatabaseEditorState {
  const DatabaseEditorSynced({
    required super.selectedIndex,
    this.type,
    required this.previousState,
  });

  final String? type;
  final DatabaseEditorLoaded previousState;
  @override
  List<Object?> get props => [selectedIndex, type, previousState];
}

class DatabaseEditorLoading extends DatabaseEditorState {
  const DatabaseEditorLoading({required super.selectedIndex});
}

class DatabaseEditorLoaded extends DatabaseEditorState {
  const DatabaseEditorLoaded({
    required this.entry,
    required this.originalEntry,
    required this.slug,
    required super.selectedIndex,
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
    );
  }

  @override
  List<Object?> get props => [entry, originalEntry, slug, selectedIndex];
}
