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
  final Map<String, dynamic> entry;

  DatabaseEditorLoaded({required this.entry});
  @override
  List<Object?> get props => [entry];
}
