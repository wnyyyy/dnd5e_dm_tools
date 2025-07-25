import 'package:dnd5e_dm_tools/core/data/models/action.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:fluttericon/maki_icons.dart';
import 'package:fluttericon/octicons_icons.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';

enum EquipmentType {
  armor,
  shield,
  accessories,
  rangedWeapons,
  meleeWeapons,
  ammunition,
  scroll,
  magic,
  potion,
  adventure,
  profession,
  clothes,
  mount,
  special,
  music,
  torch,
  backpack,
  waterskin,
  food,
  bedroll,
  misc,
  unknown,
}

extension EquipmentTypeOrder on EquipmentType {
  int get order {
    switch (this) {
      case EquipmentType.armor:
        return 0;
      case EquipmentType.shield:
        return 1;
      case EquipmentType.accessories:
        return 2;
      case EquipmentType.rangedWeapons:
        return 3;
      case EquipmentType.meleeWeapons:
        return 4;
      case EquipmentType.ammunition:
        return 5;
      case EquipmentType.scroll:
        return 6;
      case EquipmentType.magic:
        return 7;
      case EquipmentType.potion:
        return 8;
      case EquipmentType.adventure:
        return 10;
      case EquipmentType.profession:
        return 9;
      case EquipmentType.clothes:
        return 11;
      case EquipmentType.mount:
        return 12;
      case EquipmentType.special:
        return 13;
      case EquipmentType.music:
        return 14;
      case EquipmentType.torch:
        return 15;
      case EquipmentType.backpack:
        return 16;
      case EquipmentType.waterskin:
        return 17;
      case EquipmentType.food:
        return 18;
      case EquipmentType.bedroll:
        return 19;
      case EquipmentType.misc:
        return 20;
      case EquipmentType.unknown:
        return 21;
    }
  }
}

extension Categories on EquipmentType {
  Map<String, dynamic> get equipmentCategory {
    switch (this) {
      case EquipmentType.meleeWeapons:
      case EquipmentType.rangedWeapons:
        return {'index': 'weapon', 'name': 'Weapon'};
      case EquipmentType.armor:
        return {'index': 'armor', 'name': 'Armor'};
      case EquipmentType.ammunition:
        return {'index': 'ammunition', 'name': 'Ammunition'};
      case EquipmentType.potion:
        return {'index': 'potion', 'name': 'Potion'};
      case EquipmentType.special:
        return {'index': 'wondrous-items', 'name': 'Wondrous Items'};
      default:
        return {'index': 'adventuring-gear', 'name': 'Adventuring Gear'};
    }
  }

  Map<String, dynamic>? get gearCategory {
    switch (this) {
      case EquipmentType.adventure:
      case EquipmentType.torch:
      case EquipmentType.misc:
        return {'index': 'standard-gear', 'name': 'Standard Gear'};
      default:
        return null;
    }
  }

  String? get toolCategory {
    switch (this) {
      case EquipmentType.music:
        return 'Musical Instrument';
      case EquipmentType.profession:
        return "Artisan's Tools";
      default:
        return null;
    }
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
      case EquipmentType.potion:
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

enum SpellSchool {
  abjuration,
  conjuration,
  divination,
  enchantment,
  evocation,
  illusion,
  necromancy,
  transmutation,
}

extension SpellSchoolName on SpellSchool {
  String get name {
    switch (this) {
      case SpellSchool.abjuration:
        return 'Abjuration';
      case SpellSchool.conjuration:
        return 'Conjuration';
      case SpellSchool.divination:
        return 'Divination';
      case SpellSchool.enchantment:
        return 'Enchantment';
      case SpellSchool.evocation:
        return 'Evocation';
      case SpellSchool.illusion:
        return 'Illusion';
      case SpellSchool.necromancy:
        return 'Necromancy';
      case SpellSchool.transmutation:
        return 'Transmutation';
    }
  }

  Color get color {
    switch (this) {
      case SpellSchool.abjuration:
        return Colors.blueAccent;
      case SpellSchool.conjuration:
        return Colors.deepPurpleAccent;
      case SpellSchool.divination:
        return Colors.yellow[700]!;
      case SpellSchool.enchantment:
        return Colors.green[800]!;
      case SpellSchool.evocation:
        return Colors.redAccent;
      case SpellSchool.illusion:
        return Colors.pinkAccent;
      case SpellSchool.necromancy:
        return Colors.blueGrey[700]!;
      case SpellSchool.transmutation:
        return Colors.orangeAccent;
    }
  }
}

enum WeaponProperty {
  thrown,
  versatile,
  finesse,
  light,
  heavy,
  twoHanded,
  monk,
  loading,
  reach,
  ammunition,
  special,
}

extension WeaponPropertyName on WeaponProperty {
  String get name {
    switch (this) {
      case WeaponProperty.thrown:
        return 'Thrown';
      case WeaponProperty.versatile:
        return 'Versatile';
      case WeaponProperty.finesse:
        return 'Finesse';
      case WeaponProperty.light:
        return 'Light';
      case WeaponProperty.heavy:
        return 'Heavy';
      case WeaponProperty.twoHanded:
        return 'Two-Handed';
      case WeaponProperty.loading:
        return 'Loading';
      case WeaponProperty.ammunition:
        return 'Ammunition';
      case WeaponProperty.reach:
        return 'Reach';
      case WeaponProperty.special:
        return 'Special';
      case WeaponProperty.monk:
        return 'Monk';
    }
  }
}

enum WeaponCategory { simpleMelee, simpleRanged, martialMelee, martialRanged }

extension WeaponCategoryName on WeaponCategory {
  String get name {
    switch (this) {
      case WeaponCategory.simpleMelee:
        return 'Simple Melee';
      case WeaponCategory.simpleRanged:
        return 'Simple Ranged';
      case WeaponCategory.martialMelee:
        return 'Martial Melee';
      case WeaponCategory.martialRanged:
        return 'Martial Ranged';
    }
  }
}

enum ArmorCategory { light, medium, heavy, shield }

extension ArmorCategoryName on ArmorCategory {
  String get name {
    switch (this) {
      case ArmorCategory.light:
        return 'Light';
      case ArmorCategory.medium:
        return 'Medium';
      case ArmorCategory.heavy:
        return 'Heavy';
      case ArmorCategory.shield:
        return 'Shield';
    }
  }
}

enum Rarity { common, uncommon, rare, veryRare, legendary, artifact }

extension RarityName on Rarity {
  String get name {
    switch (this) {
      case Rarity.common:
        return 'Common';
      case Rarity.uncommon:
        return 'Uncommon';
      case Rarity.rare:
        return 'Rare';
      case Rarity.veryRare:
        return 'Very Rare';
      case Rarity.legendary:
        return 'Legendary';
      case Rarity.artifact:
        return 'Artifact';
    }
  }
}

extension RarityColor on Rarity {
  Color? get color {
    switch (this) {
      case Rarity.common:
        return null;
      case Rarity.uncommon:
        return Colors.green;
      case Rarity.rare:
        return Colors.blue;
      case Rarity.veryRare:
        return Colors.purple;
      case Rarity.legendary:
        return Colors.orange;
      case Rarity.artifact:
        return Colors.red;
    }
  }
}

enum ActionMenuMode { all, abilities, items, spells }

extension ActionMenuModeName on ActionMenuMode {
  String get name {
    switch (this) {
      case ActionMenuMode.all:
        return 'All';
      case ActionMenuMode.abilities:
        return 'Abilities';
      case ActionMenuMode.items:
        return 'Items';
      case ActionMenuMode.spells:
        return 'Spells';
    }
  }

  List<ActionType> get types {
    switch (this) {
      case ActionMenuMode.all:
        return ActionType.values;
      case ActionMenuMode.abilities:
        return [ActionType.ability];
      case ActionMenuMode.items:
        return [ActionType.item];
      case ActionMenuMode.spells:
        return [ActionType.spell];
    }
  }
}

enum EquipFilter { all, equipped, canEquip }

enum EquipSort { name, value, canEquip, type }

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

  Color get color {
    switch (this) {
      case CoinType.copper:
        return Colors.brown[500]!;
      case CoinType.silver:
        return Colors.grey[500]!;
      case CoinType.gold:
        return Colors.yellow[700]!;
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

enum DamageType {
  acid,
  bludgeoning,
  cold,
  fire,
  force,
  lightning,
  necrotic,
  piercing,
  poison,
  psychic,
  radiant,
  slashing,
  thunder,
}

extension DamageTypeName on DamageType {
  String get name {
    switch (this) {
      case DamageType.acid:
        return 'Acid';
      case DamageType.bludgeoning:
        return 'Bludgeoning';
      case DamageType.cold:
        return 'Cold';
      case DamageType.fire:
        return 'Fire';
      case DamageType.force:
        return 'Force';
      case DamageType.lightning:
        return 'Lightning';
      case DamageType.necrotic:
        return 'Necrotic';
      case DamageType.piercing:
        return 'Piercing';
      case DamageType.poison:
        return 'Poison';
      case DamageType.psychic:
        return 'Psychic';
      case DamageType.radiant:
        return 'Radiant';
      case DamageType.slashing:
        return 'Slashing';
      case DamageType.thunder:
        return 'Thunder';
    }
  }

  String get slug {
    switch (this) {
      case DamageType.acid:
        return 'acid';
      case DamageType.bludgeoning:
        return 'bludgeoning';
      case DamageType.cold:
        return 'cold';
      case DamageType.fire:
        return 'fire';
      case DamageType.force:
        return 'force';
      case DamageType.lightning:
        return 'lightning';
      case DamageType.necrotic:
        return 'necrotic';
      case DamageType.piercing:
        return 'piercing';
      case DamageType.poison:
        return 'poison';
      case DamageType.psychic:
        return 'psychic';
      case DamageType.radiant:
        return 'radiant';
      case DamageType.slashing:
        return 'slashing';
      case DamageType.thunder:
        return 'thunder';
    }
  }
}
