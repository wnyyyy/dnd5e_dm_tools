import 'package:dnd5e_dm_tools/core/data/models/armor_class.dart';
import 'package:dnd5e_dm_tools/core/data/models/cost.dart';
import 'package:dnd5e_dm_tools/core/data/models/damage.dart';
import 'package:dnd5e_dm_tools/core/util/enum.dart';
import 'package:equatable/equatable.dart';

abstract class Item extends Equatable {
  const Item({
    required this.slug,
    required this.name,
    required this.itemType,
    required this.desc,
    required this.cost,
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
          return WeaponTemplate(
            slug: slug,
            name: name,
            itemType: itemType,
            desc: List<String>.from(desc),
            cost: cost,
            weight: weight,
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
        );
      default:
        return GenericItem(
          slug: slug,
          name: name,
          itemType: itemType,
          desc: List<String>.from(desc),
          cost: cost,
          weight: weight,
        );
    }
  }

  final String slug;
  final String name;
  final num weight;
  final List<String> desc;
  final Cost cost;
  final EquipmentType itemType;

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

  Item copyWithBase({
    String? slug,
    String? name,
    EquipmentType? itemType,
    List<String>? desc,
    Cost? cost,
    int? weight,
  }) {
    return GenericItem(
      slug: slug ?? this.slug,
      name: name ?? this.name,
      itemType: itemType ?? this.itemType,
      desc: desc ?? this.desc,
      cost: cost ?? this.cost,
      weight: weight ?? this.weight,
      expendable: (this is GenericItem) && (this as GenericItem).expendable,
    );
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
    switch (itemType ?? this.itemType) {
      case EquipmentType.armor:
      case EquipmentType.shield:
        return (this is Armor
                ? (this as Armor)
                : Armor(
                    slug: slug ?? this.slug,
                    name: name ?? this.name,
                    itemType: itemType ?? this.itemType,
                    desc: desc ?? this.desc,
                    cost: cost ?? this.cost,
                    weight: weight ?? this.weight,
                    armorClass: (this is Armor)
                        ? (this as Armor).armorClass
                        : ArmorClass.fromJson({}),
                    armorCategory:
                        armorCategory ?? (this as Armor).armorCategory,
                    stealthDisadvantage:
                        stealthDisadvantage ??
                        (this as Armor).stealthDisadvantage,
                  ))
            .copyWithArmor(
              slug: slug,
              name: name,
              itemType: itemType,
              desc: desc,
              cost: cost,
              weight: weight,
              armorClass: armorClass,
            );
      case EquipmentType.meleeWeapons:
      case EquipmentType.rangedWeapons:
        if (this is Weapon) {
          return (this as Weapon).copyWithWeapon(
            slug: slug,
            name: name,
            itemType: itemType,
            desc: desc,
            cost: cost,
            weight: weight,
            damage: damage,
            weaponCategory: weaponCategory,
            properties: properties,
            range: range,
            longRange: longRange,
            rarity: rarity,
            variant: variant,
          );
        } else if (this is WeaponTemplate) {
          return (this as WeaponTemplate).copyWithWeaponTemplate(
            slug: slug,
            name: name,
            itemType: itemType,
            desc: desc,
            cost: cost,
            weight: weight,
            rarity: rarity,
            variant: variant,
          );
        } else {
          return WeaponTemplate(
            slug: slug ?? this.slug,
            name: name ?? this.name,
            itemType: itemType ?? this.itemType,
            desc: desc ?? this.desc,
            cost: cost ?? this.cost,
            weight: weight ?? this.weight,
            rarity: rarity ?? Rarity.common,
            variant: variant ?? false,
          );
        }
      default:
        return GenericItem(
          slug: slug ?? this.slug,
          name: name ?? this.name,
          itemType: itemType ?? this.itemType,
          desc: desc ?? this.desc,
          cost: cost ?? this.cost,
          weight: weight ?? this.weight,
          expendable: (this is GenericItem) && (this as GenericItem).expendable,
        );
    }
  }

  @override
  List<Object> get props => [slug, name, cost, itemType, desc, weight];

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
  });
}

class Armor extends Equipable {
  const Armor({
    required super.slug,
    required super.name,
    required super.itemType,
    required super.desc,
    required super.cost,
    required super.weight,
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
    this.rarity = Rarity.common,
    this.variant = false,
  });

  final Rarity rarity;
  final bool variant;

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['rarity'] = {'name': rarity.name};
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
    required this.damage,
    required this.weaponCategory,
    required this.properties,
    required this.range,
    this.longRange,
  });

  final Damage damage;
  final int? longRange;
  final int range;
  final WeaponCategory weaponCategory;
  final List<WeaponProperty> properties;

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['damage'] = damage.toJson();
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

extension ArmorCopyWith on Armor {
  Armor copyWithArmor({
    String? slug,
    String? name,
    EquipmentType? itemType,
    List<String>? desc,
    Cost? cost,
    int? weight,
    ArmorClass? armorClass,
    ArmorCategory? armorCategory,
    bool? stealthDisadvantage,
  }) {
    return Armor(
      slug: slug ?? this.slug,
      name: name ?? this.name,
      itemType: itemType ?? this.itemType,
      desc: desc ?? this.desc,
      cost: cost ?? this.cost,
      weight: weight ?? this.weight,
      armorClass: armorClass ?? this.armorClass,
      armorCategory: armorCategory ?? this.armorCategory,
      stealthDisadvantage: stealthDisadvantage ?? this.stealthDisadvantage,
    );
  }
}

extension WeaponTemplateCopyWith on WeaponTemplate {
  WeaponTemplate copyWithWeaponTemplate({
    String? slug,
    String? name,
    EquipmentType? itemType,
    List<String>? desc,
    Cost? cost,
    int? weight,
    Rarity? rarity,
    bool? variant,
  }) {
    return WeaponTemplate(
      slug: slug ?? this.slug,
      name: name ?? this.name,
      itemType: itemType ?? this.itemType,
      desc: desc ?? this.desc,
      cost: cost ?? this.cost,
      weight: weight ?? this.weight,
      rarity: rarity ?? this.rarity,
      variant: variant ?? this.variant,
    );
  }
}

extension WeaponCopyWith on Weapon {
  Weapon copyWithWeapon({
    String? slug,
    String? name,
    EquipmentType? itemType,
    List<String>? desc,
    Cost? cost,
    int? weight,
    Damage? damage,
    WeaponCategory? weaponCategory,
    List<WeaponProperty>? properties,
    int? range,
    int? longRange,
    Rarity? rarity,
    bool? variant,
  }) {
    return Weapon(
      slug: slug ?? this.slug,
      name: name ?? this.name,
      itemType: itemType ?? this.itemType,
      desc: desc ?? this.desc,
      cost: cost ?? this.cost,
      weight: weight ?? this.weight,
      damage: damage ?? this.damage,
      weaponCategory: weaponCategory ?? this.weaponCategory,
      properties: properties ?? this.properties,
      range: range ?? this.range,
      longRange: longRange ?? this.longRange,
    );
  }
}
