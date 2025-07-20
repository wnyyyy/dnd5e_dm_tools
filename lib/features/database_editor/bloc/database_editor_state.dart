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

  @override
  List<Object?> get props => [entry, originalEntry, slug, selectedIndex];
}
