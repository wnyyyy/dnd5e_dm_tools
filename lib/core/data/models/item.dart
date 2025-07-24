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
    List<ItemContent>? contents,
  }) : contents = contents ?? const [];

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

    final variant = json['variant'] as bool? ?? false;
    final variants =
        (json['variants'] as List<dynamic>?)?.map((e) {
          final itemJson = (e as Map).cast<String, dynamic>();
          return itemJson['index']?.toString() ?? '';
        }).toList() ??
        [];

    final itemType = _inferType(
      slug: slug,
      equipmentCategory: equipmentCategory,
      gearCategory: gearCategory,
      toolCategory: toolCategory,
    );

    final contents =
        (json['contents'] as List<dynamic>?)
            ?.map(
              (e) => ItemContent.fromJson(
                Map<String, dynamic>.from(e as Map? ?? {}),
              ),
            )
            .toList() ??
        [];

    switch (itemType) {
      case EquipmentType.armor:
      case EquipmentType.shield:
        final armorClass =
            (json['armor_class'] as Map?)?.map(
              (k, v) => MapEntry(k.toString(), v),
            ) ??
            {};
        if (armorClass.isEmpty) {
          return ArmorTemplate(
            slug: slug,
            name: name,
            itemType: itemType,
            desc: List<String>.from(desc),
            cost: cost,
            weight: weight,
            rarity: rarity,
            variant: variant,
            variants: variants,
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
        if (!variant && variants.isNotEmpty) {
          return GenericTemplate(
            slug: slug,
            name: name,
            itemType: itemType,
            desc: List<String>.from(desc),
            cost: cost,
            weight: weight,
            rarity: rarity,
            variant: variant,
            contents: contents,
          );
        }
        return GenericItem(
          slug: slug,
          name: name,
          itemType: itemType,
          desc: List<String>.from(desc),
          cost: cost,
          weight: weight,
          rarity: rarity,
          contents: contents,
        );
    }
  }

  Icon get icon {
    final expressions = slug
        .toLowerCase()
        .replaceAll(' ', '-')
        .replaceAll("'", '')
        .split('-');
    if (expressions.contains('bolt') || expressions.contains('arrow')) {
      return const Icon(RpgAwesome.broadhead_arrow);
    }
    if (expressions.contains('case') && expressions.contains('bolt')) {
      return const Icon(RpgAwesome.arrow_cluster);
    }
    if (expressions.contains('book')) {
      return const Icon(RpgAwesome.book);
    }
    if (expressions.contains('backpack')) {
      return const Icon(Octicons.briefcase);
    }
    if (expressions.contains('scroll') &&
        (expressions.contains('pedigree') ||
            expressions.contains('pedrigree'))) {
      return const Icon(FontAwesome5.scroll);
    }
    if (expressions.contains('set') &&
        (expressions.contains('chess') ||
            expressions.contains('dragonchess'))) {
      return const Icon(FontAwesome5.chess);
    }
    if (expressions.contains('set') && (expressions.contains('dice'))) {
      return const Icon(RpgAwesome.perspective_dice_six);
    }
    if (expressions.contains('set') && (expressions.contains('card'))) {
      return const Icon(RpgAwesome.spades_card);
    }
    if (expressions.contains('clothes')) {
      return const Icon(FontAwesome5.tshirt);
    }
    if (expressions.contains('ring')) {
      return const Icon(FontAwesome5.ring);
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
    final bows = ['crossbow', 'longbow', 'shortbow'];
    for (final expression in expressions) {
      if (bows.contains(expression)) {
        return const Icon(RpgAwesome.crossbow);
      }
    }
    if (this is Armor &&
        ((this as Armor).armorCategory == ArmorCategory.medium ||
            (this as Armor).armorCategory == ArmorCategory.heavy)) {
      return const Icon(RpgAwesome.vest);
    }
    if (expressions.contains('calligraphers')) {
      return const Icon(FontAwesome5.map);
    }
    if (expressions.contains('alchemists')) {
      return const Icon(RpgAwesome.bubbling_potion);
    }
    if (expressions.contains('cooks')) {
      return const Icon(FontAwesome.food);
    }
    if (expressions.contains('woodcarvers')) {
      return const Icon(RpgAwesome.hand_saw);
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
  final List<ItemContent> contents;

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
      'rarity': {'name': rarity.name},
      'contents': contents.map((item) => item.toJson()).toList(),
    };
  }

  String get descriptor {
    switch (itemType) {
      case EquipmentType.backpack:
      case EquipmentType.adventure:
      case EquipmentType.bedroll:
      case EquipmentType.torch:
      case EquipmentType.waterskin:
        return 'Adventuring Gear';
      case EquipmentType.armor:
        return 'Armor';
      case EquipmentType.shield:
        return 'Shield';
      case EquipmentType.meleeWeapons:
      case EquipmentType.rangedWeapons:
        return 'Weapon';
      case EquipmentType.magic:
        return 'Magic';
      case EquipmentType.profession:
        return "Artisan's Tools";
      case EquipmentType.mount:
        return 'Mount';
      case EquipmentType.music:
        return 'Musical Instrument';
      case EquipmentType.special:
        return 'Special';
      case EquipmentType.potion:
        return 'Consumable';
      case EquipmentType.accessories:
        return 'Accessory';
      case EquipmentType.scroll:
        return 'Scroll';
      case EquipmentType.ammunition:
        return 'Ammunition';
      case EquipmentType.clothes:
        return 'Clothes';
      case EquipmentType.misc:
      case EquipmentType.unknown:
        return 'Misc';
      case EquipmentType.food:
        return 'Food';
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
    Damage? twoHandedDamage,
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
    List<String>? variants,
    List<ItemContent>? contents,
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
        variants: variants ?? template.variants,
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
        twoHandedDamage: twoHandedDamage ?? weapon.twoHandedDamage,
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
        variants: variants ?? template.variants,
      );
    } else if (this is GenericTemplate) {
      final generic = this as GenericTemplate;
      return GenericTemplate(
        slug: slug ?? generic.slug,
        name: name ?? generic.name,
        itemType: itemType ?? generic.itemType,
        desc: desc ?? generic.desc,
        cost: cost ?? generic.cost,
        weight: weight ?? generic.weight,
        rarity: rarity ?? generic.rarity,
        variant: variant ?? generic.variant,
        variants: variants ?? generic.variants,
        contents: contents ?? generic.contents,
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
        contents: contents ?? generic.contents,
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
        contents: contents ?? this.contents,
      );
    }
  }

  @override
  List<Object> get props => [slug, name, cost, itemType, desc, weight, rarity];

  @override
  String toString() => '$runtimeType $slug(name: $name, type: $itemType)';
}

class ItemContent extends Equatable {
  const ItemContent({required this.slug, required this.quantity, this.item});

  factory ItemContent.fromJson(Map<String, dynamic> json) {
    return ItemContent(
      slug: (json['item'] as Map?)?['index'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item': {'index': slug},
      'quantity': quantity,
    };
  }

  ItemContent copyWith({String? slug, int? quantity, Item? item}) {
    return ItemContent(
      slug: slug ?? this.slug,
      quantity: quantity ?? this.quantity,
      item: item ?? this.item,
    );
  }

  final String slug;
  final int quantity;
  final Item? item;

  @override
  List<Object> get props => [slug, quantity];
}

abstract class Template extends Item {
  const Template({
    required super.slug,
    required super.name,
    required super.itemType,
    required super.desc,
    required super.cost,
    required super.weight,
    required super.rarity,
    super.contents,
    this.variant = false,
    this.variants = const [],
  });

  final bool variant;
  final List<String> variants;

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['variant'] = variant;
    json['variants'] = variants.map((e) => {'index': e}).toList();
    return json;
  }

  @override
  List<Object> get props => super.props
    ..add(variant)
    ..addAll(variants);
}

class GenericTemplate extends Template {
  const GenericTemplate({
    required super.slug,
    required super.name,
    required super.itemType,
    required super.desc,
    required super.cost,
    required super.weight,
    required super.rarity,
    super.variant,
    super.variants,
    super.contents,
  });
}

abstract class Equipable extends Template {
  const Equipable({
    required super.slug,
    required super.name,
    required super.itemType,
    required super.desc,
    required super.cost,
    required super.weight,
    required super.rarity,
    super.variants,
    super.variant,
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
    super.variants,
    super.variant,
  });
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
    json['variant'] = false;
    json['variants'] = [];
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
    super.variant,
    super.variants,
  });
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
    json['range'] = {'normal': range, 'long': longRange};
    json['variant'] = false;
    json['variants'] = [];
    return json;
  }

  @override
  List<Object> get props => super.props..add(damage);
}

class GenericItem extends GenericTemplate {
  const GenericItem({
    required super.slug,
    required super.name,
    required super.itemType,
    required super.desc,
    required super.cost,
    required super.weight,
    required super.rarity,
    super.contents,
    this.expendable = false,
  });

  final bool expendable;

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['variant'] = false;
    json['variants'] = [];
    return json;
  }

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
  for (final expression in slugStr.split('-')) {
    if (expression.length > 3) {
      type = _getItemType(expression);
      if (type != EquipmentType.unknown) {
        return type;
      }
    }
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
    case 'backpack':
    case 'bag-of-holding':
      return EquipmentType.backpack;
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
    case 'clothes':
      return EquipmentType.clothes;
    case 'food':
      return EquipmentType.food;
    default:
      return EquipmentType.unknown;
  }
}
