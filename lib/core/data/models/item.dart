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
    final cost = Cost.fromJson(json['cost'] as Map<String, dynamic>? ?? {});

    final equipmentCategoryMap =
        json['equipment_category'] as Map<String, dynamic>? ?? {};
    final equipmentCategory = equipmentCategoryMap['index'] as String? ?? '';
    if (equipmentCategory.isEmpty) {
      throw ArgumentError(
        'Required field "equipment_category" is missing or empty',
      );
    }
    final gearCategoryMap = json['gear_category'] as Map<String, dynamic>?;
    final gearCategory = gearCategoryMap?['index'] as String?;
    final toolCategory = json['tool_category'] as String?;
    final weight = json['weight'] as int? ?? 0;

    final itemType = _inferType(
      slug: slug,
      equipmentCategory: equipmentCategory,
      gearCategory: gearCategory,
      toolCategory: toolCategory,
    );

    switch (itemType) {
      case EquipmentType.armor:
      case EquipmentType.shield:
        return Armor(
          slug: slug,
          name: name,
          itemType: itemType,
          desc: List<String>.from(desc),
          cost: cost,
          weight: weight,
          armorClass: json['armor_class'] as int? ?? 0,
        );
      case EquipmentType.meleeWeapons:
      case EquipmentType.rangedWeapons:
        return Weapon(
          slug: slug,
          name: name,
          itemType: itemType,
          desc: List<String>.from(desc),
          cost: cost,
          weight: weight,
          damage: Damage.fromJson(
            json['damage'] as Map<String, dynamic>? ?? {},
          ),
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
  final int weight;
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

  Item copyWith({
    String? slug,
    String? name,
    EquipmentType? itemType,
    List<String>? desc,
    Cost? cost,
    int? weight,
    Damage? damage,
    int? armorClass,
  }) {
    switch (itemType) {
      case EquipmentType.armor:
      case EquipmentType.shield:
        return Armor(
          slug: slug ?? this.slug,
          name: name ?? this.name,
          itemType: itemType ?? this.itemType,
          desc: desc ?? this.desc,
          cost: cost ?? this.cost,
          weight: weight ?? this.weight,
          armorClass: armorClass ?? (this as Armor).armorClass,
        );
      case EquipmentType.meleeWeapons:
      case EquipmentType.rangedWeapons:
        return Weapon(
          slug: slug ?? this.slug,
          name: name ?? this.name,
          itemType: itemType ?? this.itemType,
          desc: desc ?? this.desc,
          cost: cost ?? this.cost,
          weight: weight ?? this.weight,
          damage: damage ?? (this as Weapon).damage,
        );
      default:
        return GenericItem(
          slug: slug ?? this.slug,
          name: name ?? this.name,
          itemType: itemType ?? this.itemType,
          desc: desc ?? this.desc,
          cost: cost ?? this.cost,
          weight: weight ?? this.weight,
          expendable: (this as GenericItem).expendable,
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
  });

  final int armorClass;

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['armor_class'] = armorClass;
    return json;
  }

  @override
  List<Object> get props => super.props..add(armorClass);
}

class Weapon extends Equipable {
  const Weapon({
    required super.slug,
    required super.name,
    required super.itemType,
    required super.desc,
    required super.cost,
    required super.weight,
    required this.damage,
  });

  final Damage damage;

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['damage'] = damage.toJson();
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
