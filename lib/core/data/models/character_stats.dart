import 'package:dnd5e_dm_tools/core/data/models/asi.dart';
import 'package:dnd5e_dm_tools/core/data/models/death_save.dart';
import 'package:dnd5e_dm_tools/core/data/models/proficiency.dart';
import 'package:dnd5e_dm_tools/core/util/enum.dart';
import 'package:dnd5e_dm_tools/core/util/helper.dart';
import 'package:equatable/equatable.dart';

class CharacterStats extends Equatable {
  const CharacterStats({
    required this.passivePerception,
    required this.initiative,
    required this.ac,
    required this.hpMax,
    required this.hpCurr,
    required this.hpTemp,
    required this.hdMax,
    required this.hdCurr,
    required this.speed,
    required this.deathSave,
    required this.inspiration,
    required this.exhaustion,
  });

  factory CharacterStats.fromJson(
    Map<String, dynamic> json, {
    required ASI asi,
    required int level,
    required Proficiency proficiency,
  }) {
    final dex = asi.dexterity;
    final perception = proficiency.skills[Skill.perception];
    final int extraPerception;
    if (perception != null) {
      extraPerception = perception == ProficiencyLevel.proficient
          ? getProfBonus(level)
          : perception == ProficiencyLevel.expert
          ? getProfBonus(level) * 2
          : 0;
    } else {
      extraPerception = 0;
    }
    final passivePerception =
        json['passive_perception'] as int? ??
        getModifier(dex) + 10 + extraPerception;

    final initiative = json['initiative'] as int? ?? getModifier(dex);
    final ac = json['ac'] as int? ?? 10 + getModifier(asi.dexterity);
    final hpMax = json['hp_max'] as int? ?? 10;
    final hpCurr = json['hp_curr'] as int? ?? hpMax;
    final hpTemp = json['hp_temp'] as int? ?? 0;
    final hdMax = json['hd_max'] as int? ?? level;
    final hdCurr = json['hd_curr'] as int? ?? hdMax;
    final speed = json['speed'] as int? ?? 30;
    final deathSave = DeathSave.fromJson(
      Map<String, dynamic>.from(json['death_save'] as Map? ?? {}),
    );
    final inspiration = json['inspiration'] as int? ?? 0;
    final exhaustion = json['exhaustion'] as int? ?? 0;

    return CharacterStats(
      passivePerception: passivePerception,
      initiative: initiative,
      ac: ac,
      hpMax: hpMax,
      hpCurr: hpCurr,
      hpTemp: hpTemp,
      hdMax: hdMax,
      hdCurr: hdCurr,
      speed: speed,
      deathSave: deathSave,
      inspiration: inspiration,
      exhaustion: exhaustion,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'passive_perception': passivePerception,
      'initiative': initiative,
      'ac': ac,
      'hp_max': hpMax,
      'hp_curr': hpCurr,
      'hp_temp': hpTemp,
      'hd_max': hdMax,
      'hd_curr': hdCurr,
      'speed': speed,
      'death_save': deathSave.toJson(),
      'inspiration': inspiration,
      'exhaustion': exhaustion,
    };
  }

  CharacterStats copyWith({
    int? passivePerception,
    int? initiative,
    int? ac,
    int? hpMax,
    int? hpCurr,
    int? hpTemp,
    int? hdMax,
    int? hdCurr,
    int? speed,
    int? inspiration,
    DeathSave? deathSave,
    int? exhaustion,
  }) {
    return CharacterStats(
      passivePerception: passivePerception ?? this.passivePerception,
      initiative: initiative ?? this.initiative,
      ac: ac ?? this.ac,
      hpMax: hpMax ?? this.hpMax,
      hpCurr: hpCurr ?? this.hpCurr,
      hpTemp: hpTemp ?? this.hpTemp,
      hdMax: hdMax ?? this.hdMax,
      hdCurr: hdCurr ?? this.hdCurr,
      speed: speed ?? this.speed,
      deathSave: deathSave ?? this.deathSave,
      inspiration: inspiration ?? this.inspiration,
      exhaustion: exhaustion ?? this.exhaustion,
    );
  }

  final int passivePerception;
  final int initiative;
  final int ac;
  final int hpMax;
  final int hpCurr;
  final int hpTemp;
  final int hdMax;
  final int hdCurr;
  final int speed;
  final DeathSave deathSave;
  final int inspiration;
  final int exhaustion;

  @override
  List<Object> get props => [
    passivePerception,
    initiative,
    ac,
    hpMax,
    hpCurr,
    hdMax,
    hpTemp,
    hdCurr,
    speed,
    deathSave,
    inspiration,
    exhaustion,
  ];
}
