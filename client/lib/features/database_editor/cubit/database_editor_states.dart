import 'package:equatable/equatable.dart';

abstract class DatabaseEditorState extends Equatable {}

class DatabaseEditorInitial extends DatabaseEditorState {
  @override
  List<Object?> get props => [];
}

class DatabaseEditorError extends DatabaseEditorState {
  @override
  List<Object?> get props => [];
}

class DatabaseEditorLoading extends DatabaseEditorState {
  @override
  List<Object?> get props => [];
}

class DatabaseEditorLoaded extends DatabaseEditorState {

  DatabaseEditorLoaded({required this.entry, required this.slug});
  final Map<String, dynamic> entry;
  final String slug;
  @override
  List<Object?> get props => [entry, slug];
}
