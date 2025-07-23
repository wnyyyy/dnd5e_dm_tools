import 'package:dnd5e_dm_tools/core/data/models/armor_class.dart';
import 'package:dnd5e_dm_tools/core/data/models/cost.dart';
import 'package:dnd5e_dm_tools/core/data/models/damage.dart';
import 'package:dnd5e_dm_tools/core/util/enum.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:fluttericon/maki_icons.dart';
import 'package:fluttericon/octicons_icons.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';

abstract class Item extends Equatable {
  const Item({
    required this.slug,
    required this.name,
    required this.itemType,
    required this.desc,
    required this.cost,
    required this.rarity,
    this.weight = 0,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    final slug = json['index'] as String?;
    if (slug == null || slug.isEmpty) {
      throw ArgumentError('Required field "index" is missing or empty');
    }
    final name = json['name'] as String? ?? '';
    final desc = json['desc'] as List<dynamic>? ?? [];
    final cost = Cost.fromJson(
      (json['cost'] as Map?)?.map((k, v) => MapEntry(k.toString(), v)) ?? {},
    );

    final equipmentCategoryMap =
        (json['equipment_category'] as Map?)?.map(
          (k, v) => MapEntry(k.toString(), v),
        ) ??
        {};
    final equipmentCategory = equipmentCategoryMap['index'] as String? ?? '';
    if (equipmentCategory.isEmpty) {
      throw ArgumentError(
        'Required field "equipment_category" is missing or empty',
      );
    }
    final gearCategoryMap = (json['gear_category'] as Map?)?.map(
      (k, v) => MapEntry(k.toString(), v),
    );
    final gearCategory = gearCategoryMap?['index'] as String?;
    final toolCategory = json['tool_category'] as String?;
    final weight = json['weight'] as num? ?? 0;

    final rarityMap = (json['rarity'] as Map?)?.cast<String, dynamic>() ?? {};
    final rarity = Rarity.values.firstWhere(
      (e) => e.name == (rarityMap['name'] as String? ?? ''),
      orElse: () => Rarity.common,
    );

    final itemType = _inferType(
      slug: slug,
      equipmentCategory: equipmentCategory,
      gearCategory: gearCategory,
      toolCategory: toolCategory,
    );

    switch (itemType) {
      case EquipmentType.armor:
      case EquipmentType.shield:
        final armorClass =
            (json['armor_class'] as Map?)?.map(
              (k, v) => MapEntry(k.toString(), v),
            ) ??
            {};
        if (armorClass.isEmpty) {
          final variant = json['variant'] as bool? ?? false;
          return ArmorTemplate(
            slug: slug,
            name: name,
            itemType: itemType,
            desc: List<String>.from(desc),
            cost: cost,
            weight: weight,
            rarity: rarity,
            variant: variant,
          );
        }
        final armorCategory = ArmorCategory.values.firstWhere(
          (e) => e.name == (json['armor_category'] as String? ?? ''),
          orElse: () => ArmorCategory.light,
        );
        return Armor(
          slug: slug,
          name: name,
          itemType: itemType,
          desc: List<String>.from(desc),
          cost: cost,
          weight: weight,
          rarity: rarity,
          armorClass: ArmorClass.fromJson(armorClass),
          armorCategory: armorCategory,
          stealthDisadvantage: json['stealth_disadvantage'] as bool? ?? false,
        );
      case EquipmentType.meleeWeapons:
      case EquipmentType.rangedWeapons:
        final damage =
            (json['damage'] as Map?)?.map(
              (k, v) => MapEntry(k.toString(), v),
            ) ??
            {};
        if (damage.isEmpty) {
          final variant = json['variant'] as bool? ?? false;
          return WeaponTemplate(
            slug: slug,
            name: name,
            itemType: itemType,
            desc: List<String>.from(desc),
            cost: cost,
            weight: weight,
            rarity: rarity,
            variant: variant,
          );
        }
        final properties =
            (json['properties'] as List<dynamic>?)
                ?.map(
                  (e) => WeaponProperty.values.firstWhere(
                    (p) =>
                        p.name.toLowerCase() ==
                        Map.castFrom(e as Map)['name'].toString().toLowerCase(),
                  ),
                )
                .toList() ??
            [];
        final categoryRange = json['category_range'] as String? ?? '';
        final WeaponCategory? weaponCategory;
        if (categoryRange.isEmpty) {
          weaponCategory = null;
        } else {
          weaponCategory = WeaponCategory.values.firstWhere(
            (e) => e.name == categoryRange,
          );
        }
        final range = (json['range'] as Map?)?['normal'] as int? ?? 5;
        final longRange = (json['range'] as Map?)?['long'] as int?;
        final twoHandedDamage = (json['two_handed_damage'] as Map?) != null
            ? Damage.fromJson(
                (json['two_handed_damage'] as Map).map(
                  (k, v) => MapEntry(k.toString(), v),
                ),
              )
            : null;
        return Weapon(
          slug: slug,
          name: name,
          itemType: itemType,
          desc: List<String>.from(desc),
          cost: cost,
          weight: weight,
          damage: Damage.fromJson(damage),
          weaponCategory: weaponCategory ?? WeaponCategory.simpleMelee,
          properties: properties,
          range: range,
          longRange: longRange,
          twoHandedDamage: twoHandedDamage,
          rarity: rarity,
        );
      default:
        return GenericItem(
          slug: slug,
          name: name,
          itemType: itemType,
          desc: List<String>.from(desc),
          cost: cost,
          weight: weight,
          rarity: rarity,
        );
    }
  }

  Icon get icon {
    final bows = [
      'crossbow-light',
      'crossbow-heavy',
      'crossbow-hand',
      'longbow',
      'shortbow',
    ];
    final expressions = slug
        .toLowerCase()
        .replaceAll(' ', '-')
        .replaceAll("'", '')
        .split('-');
    for (final expression in expressions) {
      if (bows.contains(expression)) {
        return const Icon(RpgAwesome.crossbow);
      }
    }
    if (expressions.contains('dagger')) {
      return const Icon(RpgAwesome.plain_dagger);
    }
    if (expressions.contains('maul')) {
      return const Icon(RpgAwesome.large_hammer);
    }
    if (expressions.contains('axe')) {
      return const Icon(RpgAwesome.battered_axe);
    }
    if (expressions.contains('greataxe')) {
      return const Icon(RpgAwesome.axe);
    }
    if (this is Armor &&
        ((this as Armor).armorCategory == ArmorCategory.medium ||
            (this as Armor).armorCategory == ArmorCategory.heavy)) {
      return const Icon(RpgAwesome.vest);
    }
    switch (itemType) {
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

  final String slug;
  final String name;
  final num weight;
  final List<String> desc;
  final Cost cost;
  final EquipmentType itemType;
  final Rarity rarity;

  Map<String, dynamic> toJson() {
    return {
      'index': slug,
      'name': name,
      'desc': desc,
      'cost': cost.toJson(),
      'tool_category': itemType.toolCategory,
      'gear_category': itemType.gearCategory,
      'equipment_category': itemType.equipmentCategory,
      'weight': weight,
    };
  }

  String get descriptor {
    switch (itemType) {
      case EquipmentType.armor:
        return 'Armor';
      case EquipmentType.shield:
        return 'Shield';
      case EquipmentType.meleeWeapons:
      case EquipmentType.rangedWeapons:
        return 'Weapon';
      case EquipmentType.magic:
        return 'Magic Item';
      case EquipmentType.profession:
        return 'Tool';
      case EquipmentType.adventure:
        return 'Adventuring Gear';
      case EquipmentType.mount:
        return 'Mount';
      case EquipmentType.music:
        return 'Musical Instrument';
      case EquipmentType.special:
        return 'Special Item';
      case EquipmentType.potion:
        return 'Consumable';
      case EquipmentType.accessories:
        return 'Accessory';
      case EquipmentType.scroll:
        return 'Scroll';
      default:
        return 'Misc';
    }
  }

  Item copyWith({
    String? slug,
    String? name,
    EquipmentType? itemType,
    List<String>? desc,
    Cost? cost,
    int? weight,
    Damage? damage,
    ArmorClass? armorClass,
    Rarity? rarity,
    bool? variant,
    WeaponCategory? weaponCategory,
    List<WeaponProperty>? properties,
    int? range,
    int? longRange,
    bool? expendable,
    ArmorCategory? armorCategory,
    bool? stealthDisadvantage,
  }) {
    if (this is Armor) {
      final armor = this as Armor;
      return Armor(
        slug: slug ?? armor.slug,
        name: name ?? armor.name,
        itemType: itemType ?? armor.itemType,
        desc: desc ?? armor.desc,
        cost: cost ?? armor.cost,
        weight: weight ?? armor.weight,
        armorClass: armorClass ?? armor.armorClass,
        rarity: rarity ?? armor.rarity,
        armorCategory: armorCategory ?? armor.armorCategory,
        stealthDisadvantage: stealthDisadvantage ?? armor.stealthDisadvantage,
      );
    } else if (this is ArmorTemplate) {
      final template = this as ArmorTemplate;
      return ArmorTemplate(
        slug: slug ?? template.slug,
        name: name ?? template.name,
        itemType: itemType ?? template.itemType,
        desc: desc ?? template.desc,
        cost: cost ?? template.cost,
        weight: weight ?? template.weight,
        rarity: rarity ?? template.rarity,
        variant: variant ?? template.variant,
      );
    } else if (this is Weapon) {
      final weapon = this as Weapon;
      return Weapon(
        slug: slug ?? weapon.slug,
        name: name ?? weapon.name,
        itemType: itemType ?? weapon.itemType,
        desc: desc ?? weapon.desc,
        cost: cost ?? weapon.cost,
        weight: weight ?? weapon.weight,
        damage: damage ?? weapon.damage,
        weaponCategory: weaponCategory ?? weapon.weaponCategory,
        properties: properties ?? weapon.properties,
        range: range ?? weapon.range,
        rarity: rarity ?? weapon.rarity,
        longRange: longRange ?? weapon.longRange,
      );
    } else if (this is WeaponTemplate) {
      final template = this as WeaponTemplate;
      return WeaponTemplate(
        slug: slug ?? template.slug,
        name: name ?? template.name,
        itemType: itemType ?? template.itemType,
        desc: desc ?? template.desc,
        cost: cost ?? template.cost,
        weight: weight ?? template.weight,
        rarity: rarity ?? template.rarity,
        variant: variant ?? template.variant,
      );
    } else if (this is GenericItem) {
      final generic = this as GenericItem;
      return GenericItem(
        slug: slug ?? generic.slug,
        name: name ?? generic.name,
        itemType: itemType ?? generic.itemType,
        desc: desc ?? generic.desc,
        cost: cost ?? generic.cost,
        weight: weight ?? generic.weight,
        expendable: expendable ?? generic.expendable,
        rarity: rarity ?? generic.rarity,
      );
    } else {
      // fallback for unknown Item types
      return GenericItem(
        slug: slug ?? this.slug,
        name: name ?? this.name,
        itemType: itemType ?? this.itemType,
        desc: desc ?? this.desc,
        cost: cost ?? this.cost,
        weight: weight ?? this.weight,
        expendable: expendable ?? false,
        rarity: rarity ?? this.rarity,
      );
    }
  }

  @override
  List<Object> get props => [slug, name, cost, itemType, desc, weight, rarity];

  @override
  String toString() => '$runtimeType $slug(name: $name, type: $itemType)';
}

abstract class Equipable extends Item {
  const Equipable({
    required super.slug,
    required super.name,
    required super.itemType,
    required super.desc,
    required super.cost,
    required super.weight,
    required super.rarity,
  });
}

class ArmorTemplate extends Equipable {
  const ArmorTemplate({
    required super.slug,
    required super.name,
    required super.itemType,
    required super.desc,
    required super.cost,
    required super.weight,
    required super.rarity,
    this.variant = false,
  });

  final bool variant;

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['variant'] = variant;
    return json;
  }

  @override
  List<Object> get props => super.props..add(rarity);
}

class Armor extends ArmorTemplate {
  const Armor({
    required super.slug,
    required super.name,
    required super.itemType,
    required super.desc,
    required super.cost,
    required super.weight,
    required super.rarity,
    required this.armorClass,
    required this.armorCategory,
    this.stealthDisadvantage = false,
  });

  final ArmorClass armorClass;
  final bool stealthDisadvantage;
  final ArmorCategory armorCategory;

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['armor_class'] = armorClass;
    json['stealth_disadvantage'] = stealthDisadvantage;
    json['armor_category'] = armorCategory.name;
    json['variant'] = null;
    return json;
  }

  @override
  List<Object> get props => super.props..add(armorClass);
}

class WeaponTemplate extends Equipable {
  const WeaponTemplate({
    required super.slug,
    required super.name,
    required super.itemType,
    required super.desc,
    required super.cost,
    required super.weight,
    required super.rarity,
    this.variant = false,
  });

  final bool variant;

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['variant'] = variant;
    return json;
  }
}

class Weapon extends WeaponTemplate {
  const Weapon({
    required super.slug,
    required super.name,
    required super.itemType,
    required super.desc,
    required super.cost,
    required super.weight,
    required super.rarity,
    required this.damage,
    required this.weaponCategory,
    required this.properties,
    required this.range,
    this.longRange,
    this.twoHandedDamage,
  });

  final Damage damage;
  final Damage? twoHandedDamage;
  final int? longRange;
  final int range;
  final WeaponCategory weaponCategory;
  final List<WeaponProperty> properties;

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['damage'] = damage.toJson();
    if (twoHandedDamage != null) {
      json['two_handed_damage'] = twoHandedDamage!.toJson();
    }
    json['category_range'] = weaponCategory.name;
    json['properties'] = properties
        .map(
          (e) => {
            'index': e.name
                .toLowerCase()
                .replaceAll(' ', '-')
                .replaceAll("'", ''),
            'name': e.name,
          },
        )
        .toList();
    json['variant'] = null;
    json['range'] = {'normal': range, 'long': longRange};
    return json;
  }

  @override
  List<Object> get props => super.props..add(damage);
}

class GenericItem extends Item {
  const GenericItem({
    required super.slug,
    required super.name,
    required super.itemType,
    required super.desc,
    required super.cost,
    required super.weight,
    required super.rarity,
    this.expendable = false,
  });

  final bool expendable;

  @override
  List<Object> get props => super.props..add(expendable);
}

EquipmentType _inferType({
  required String slug,
  required String equipmentCategory,
  String? gearCategory,
  String? toolCategory,
}) {
  final slugStr = slug.toLowerCase().replaceAll(' ', '-').replaceAll("'", '');
  var type = _getItemType(slugStr);
  if (type != EquipmentType.unknown) {
    return type;
  }
  type = _getItemType(toolCategory ?? '');
  if (type != EquipmentType.unknown) {
    return type;
  }
  type = _getItemType(gearCategory ?? '');
  if (type != EquipmentType.unknown) {
    return type;
  }
  return _getItemType(
    equipmentCategory.toLowerCase().replaceAll(' ', '-').replaceAll("'", ''),
  );
}

EquipmentType _getItemType(String item) {
  if (item.isEmpty) {
    return EquipmentType.unknown;
  }
  final itemStr = item.toLowerCase().replaceAll(' ', '-').replaceAll("'", '');
  switch (itemStr) {
    case 'torch':
      return EquipmentType.torch;
    case 'ammunition':
      return EquipmentType.ammunition;
    case 'adventuring-gear':
      return EquipmentType.adventure;
    case 'arcane-foci':
    case 'druidic-foci':
    case 'holy-symbols':
    case 'rod':
    case 'staff':
    case 'wand':
      return EquipmentType.magic;
    case 'armor':
    case 'heavy-armor':
    case 'medium-armor':
    case 'light-armor':
      return EquipmentType.armor;
    case 'artisans-tools':
    case 'kits':
    case 'tools':
      return EquipmentType.profession;
    case 'equipment-packs':
    case 'gaming-sets':
    case 'other-tools':
    case 'standard-gear':
      return EquipmentType.misc;
    case 'land-vehicles':
    case 'mounts-and-other-animals':
    case 'mounts-and-vehicles':
    case 'tack-harness-and-drawn-vehicles':
    case 'waterborne-vehicles':
      return EquipmentType.mount;
    case 'martial-ranged-weapons':
    case 'ranged-weapons':
    case 'simple-ranged-weapons':
      return EquipmentType.rangedWeapons;
    case 'martial-melee-weapons':
    case 'simple-melee-weapons':
    case 'simple-weapons':
    case 'weapon':
      return EquipmentType.meleeWeapons;
    case 'musical-instruments':
    case 'music':
      return EquipmentType.music;
    case 'wondrous-items':
      return EquipmentType.special;
    case 'potion':
      return EquipmentType.potion;
    case 'rings':
      return EquipmentType.accessories;
    case 'shield':
      return EquipmentType.shield;
    case 'scroll':
      return EquipmentType.scroll;
    default:
      return EquipmentType.unknown;
  }
}
