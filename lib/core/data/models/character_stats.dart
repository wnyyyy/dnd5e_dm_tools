import 'package:equatable/equatable.dart';

class CharacterStats extends Equatable {
  const CharacterStats({required this.passivePerception});

  factory CharacterStats.fromJson(Map<String, dynamic> json, int defaultValue) {
    return CharacterStats(
      passivePerception: json['passive_perception'] as int? ?? defaultValue,
    );
  }

  Map<String, dynamic> toJson() {
    return {'passive_perception': passivePerception};
  }

  final int passivePerception;

  @override
  List<Object> get props => [passivePerception];
}
