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

enum CoinType {
  copper,
  silver,
  gold,
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
