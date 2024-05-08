import 'package:equatable/equatable.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  SettingsState copyWith({
    String? name,
    bool? isEditMode,
    bool? isCaster,
  });

  @override
  List<Object> get props => [];
}

class SettingsInitial extends SettingsState {
  @override
  List<Object> get props => [];

  @override
  SettingsInitial copyWith({
    String? name,
    bool? isEditMode,
    bool? isCaster,
  }) {
    return SettingsInitial();
  }
}

class SettingsLoading extends SettingsState {
  @override
  List<Object> get props => [];

  @override
  SettingsLoading copyWith({
    String? name,
    bool? isEditMode,
    bool? isCaster,
  }) {
    return SettingsLoading();
  }
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError(this.message);

  @override
  List<Object> get props => [message];

  @override
  SettingsError copyWith({
    String? name,
    bool? isEditMode,
    bool? isCaster,
  }) {
    return SettingsError(message);
  }
}

class SettingsLoaded extends SettingsState {
  final String name;
  final bool isEditMode;
  final bool isCaster;

  const SettingsLoaded({
    required this.name,
    required this.isEditMode,
    required this.isCaster,
  });

  @override
  SettingsLoaded copyWith({
    String? name,
    bool? isEditMode,
    bool? isCaster,
  }) {
    return SettingsLoaded(
      name: name ?? this.name,
      isEditMode: isEditMode ?? this.isEditMode,
      isCaster: isCaster ?? this.isCaster,
    );
  }

  @override
  List<Object> get props => [name, isEditMode, isCaster];
}
