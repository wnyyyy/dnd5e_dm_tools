import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:fluttericon/maki_icons.dart';
import 'package:fluttericon/octicons_icons.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';

enum EquipmentType {
  ammunition,
  adventure,
  magic,
  armor,
  profession,
  misc,
  mount,
  rangedWeapons,
  meleeWeapons,
  special,
  consumable,
  accessories,
  shield,
  scroll,
  music,
  torch,
  backpack,
  waterskin,
  food,
  bedroll,
  clothes,
  unknown,
}

extension EquipmentTypeIndex on EquipmentType {
  String get index {
    
  }
}

extension EquipmentTypeIcon on EquipmentType {
  Icon get icon {
    switch (this) {
      case EquipmentType.backpack:
        return const Icon(Maki.shop);
      case EquipmentType.bedroll:
        return const Icon(FontAwesome5.bed);
      case EquipmentType.clothes:
        return const Icon(FontAwesome5.tshirt);
      case EquipmentType.food:
        return const Icon(FontAwesome.food);
      case EquipmentType.waterskin:
        return const Icon(RpgAwesome.round_bottom_flask);
      case EquipmentType.ammunition:
        return const Icon(RpgAwesome.arrow_cluster);
      case EquipmentType.adventure:
        return const Icon(Icons.backpack);
      case EquipmentType.magic:
        return const Icon(RpgAwesome.fairy_wand);
      case EquipmentType.armor:
        return const Icon(RpgAwesome.vest);
      case EquipmentType.profession:
        return const Icon(Icons.star);
      case EquipmentType.music:
        return const Icon(Icons.music_note);
      case EquipmentType.misc:
        return const Icon(FontAwesome5.tools);
      case EquipmentType.mount:
        return const Icon(FontAwesome5.horse);
      case EquipmentType.rangedWeapons:
        return const Icon(RpgAwesome.crossbow);
      case EquipmentType.meleeWeapons:
        return const Icon(RpgAwesome.broadsword);
      case EquipmentType.special:
        return const Icon(Octicons.north_star);
      case EquipmentType.consumable:
        return const Icon(FontAwesome5.flask);
      case EquipmentType.accessories:
        return const Icon(FontAwesome5.ring);
      case EquipmentType.shield:
        return const Icon(Octicons.shield);
      case EquipmentType.scroll:
        return const Icon(RpgAwesome.book);
      case EquipmentType.torch:
        return const Icon(RpgAwesome.torch);
      case EquipmentType.unknown:
        return const Icon(RpgAwesome.torch);
    }
  }
}

enum ThemeColor {
  chestnutBrown,
  crimsonRed,
  forestGreen,
  midnightBlue,
  lavenderViolet,
  slateGrey,
}

enum Rarity { common, uncommon, rare, veryRare, legendary, artifact }

enum ActionMenuMode { all, abilities, items, spells }

enum EquipFilter { all, equipped, canEquip }

enum EquipSort { name, value, canEquip }

enum ResourceType { item, shortRest, longRest, spell, none }

enum Attribute {
  strength,
  dexterity,
  constitution,
  intelligence,
  wisdom,
  charisma,
}

extension AttributeName on Attribute {
  String get name {
    switch (this) {
      case Attribute.strength:
        return 'Strength';
      case Attribute.dexterity:
        return 'Dexterity';
      case Attribute.constitution:
        return 'Constitution';
      case Attribute.intelligence:
        return 'Intelligence';
      case Attribute.wisdom:
        return 'Wisdom';
      case Attribute.charisma:
        return 'Charisma';
    }
  }
}

enum ProficiencyLevel { proficient, expert, none }

enum CoinType { copper, silver, gold }

extension CoinTypeName on CoinType {
  String get name {
    switch (this) {
      case CoinType.copper:
        return 'Copper';
      case CoinType.silver:
        return 'Silver';
      case CoinType.gold:
        return 'Gold';
    }
  }

  String get symbol {
    switch (this) {
      case CoinType.copper:
        return 'cp';
      case CoinType.silver:
        return 'sp';
      case CoinType.gold:
        return 'gp';
    }
  }
}

enum Skill {
  acrobatics,
  animalHandling,
  arcana,
  athletics,
  deception,
  history,
  insight,
  intimidation,
  investigation,
  medicine,
  nature,
  perception,
  performance,
  persuasion,
  religion,
  sleightOfHand,
  stealth,
  survival,
}

extension SkillName on Skill {
  String get name {
    switch (this) {
      case Skill.acrobatics:
        return 'Acrobatics';
      case Skill.animalHandling:
        return 'Animal Handling';
      case Skill.arcana:
        return 'Arcana';
      case Skill.athletics:
        return 'Athletics';
      case Skill.deception:
        return 'Deception';
      case Skill.history:
        return 'History';
      case Skill.insight:
        return 'Insight';
      case Skill.intimidation:
        return 'Intimidation';
      case Skill.investigation:
        return 'Investigation';
      case Skill.medicine:
        return 'Medicine';
      case Skill.nature:
        return 'Nature';
      case Skill.perception:
        return 'Perception';
      case Skill.performance:
        return 'Performance';
      case Skill.persuasion:
        return 'Persuasion';
      case Skill.religion:
        return 'Religion';
      case Skill.sleightOfHand:
        return 'Sleight of Hand';
      case Skill.stealth:
        return 'Stealth';
      case Skill.survival:
        return 'Survival';
    }
  }
}

extension SkillAttribute on Skill {
  Attribute get attribute {
    switch (this) {
      case Skill.acrobatics:
      case Skill.sleightOfHand:
      case Skill.stealth:
        return Attribute.dexterity;
      case Skill.animalHandling:
      case Skill.insight:
      case Skill.medicine:
      case Skill.perception:
      case Skill.survival:
        return Attribute.wisdom;
      case Skill.arcana:
      case Skill.history:
      case Skill.investigation:
      case Skill.nature:
      case Skill.religion:
        return Attribute.intelligence;
      case Skill.athletics:
        return Attribute.strength;
      case Skill.deception:
      case Skill.intimidation:
      case Skill.performance:
      case Skill.persuasion:
        return Attribute.charisma;
    }
  }
}
