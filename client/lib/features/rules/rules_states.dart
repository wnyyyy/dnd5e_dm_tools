import 'package:equatable/equatable.dart';

abstract class RulesState extends Equatable {
  const RulesState();

  @override
  List<Object> get props => [];
}

class RulesStateInitial extends RulesState {
  @override
  List<Object> get props => [];
}

class RulesStateError extends RulesState {
  final String message;

  const RulesStateError(this.message);

  @override
  List<Object> get props => [message];
}

class RulesStateLoading extends RulesState {
  @override
  List<Object> get props => [];
}

class RulesStateLoaded extends RulesState {
  final Map<String, dynamic> conditions;

  const RulesStateLoaded({required this.conditions});

  @override
  List<Object> get props => [conditions];
}
