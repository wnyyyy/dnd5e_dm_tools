import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class CharacterScreenEvent extends Equatable {
  const CharacterScreenEvent();

  @override
  List<Object> get props => [];
}

class TabUpdated extends CharacterScreenEvent {
  final int index;

  const TabUpdated(this.index);

  @override
  List<Object> get props => [index];
}
