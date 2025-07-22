import 'package:equatable/equatable.dart';

class CharacterStats extends Equatable {
  const CharacterStats({required this.passivePerception});

  factory CharacterStats.fromJson(Map<String, dynamic> json) {
    return CharacterStats(
      passivePerception: json['passive_perception'] as int? ?? 10,
    );
  }

  Map<String, dynamic> toJson() {
    return {'passive_perception': passivePerception};
  }

  final int passivePerception;

  @override
  List<Object> get props => [passivePerception];
}
