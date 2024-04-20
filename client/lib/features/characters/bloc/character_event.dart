import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class CharacterEvent extends Equatable {
  const CharacterEvent();

  @override
  List<Object> get props => [];
}

class CharacterLoad extends CharacterEvent {
  const CharacterLoad();

  @override
  List<Object> get props => [];
}

class TabUpdated extends CharacterEvent {
  final int index;

  const TabUpdated(this.index);

  @override
  List<Object> get props => [index];
}
