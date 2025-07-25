import 'package:dnd5e_dm_tools/core/util/enum.dart';
import 'package:equatable/equatable.dart';

enum ActionType { item, spell, ability }

extension ActionTypeOrder on ActionType {
  int get order {
    switch (this) {
      case ActionType.ability:
        return 0;
      case ActionType.item:
        return 1;
      case ActionType.spell:
        return 2;
    }
  }
}

abstract class Action extends Equatable {
  const Action({
    required this.slug,
    required this.title,
    required this.description,
    required this.type,
    required this.fields,
  });

  factory Action.fromJson(Map<String, dynamic> json) {
    final title = json['title'] as String? ?? '';
    final slug = json['slug'] as String? ?? '';
    if (slug.isEmpty) {
      throw ArgumentError('Required fields "slug" missing or empty');
    }
    final description = json['description'] as String? ?? '';
    final type = ActionType.values[json['type'] as int? ?? 0];
    final fields = ActionFields.fromJson(
      Map<String, dynamic>.from(json['fields'] as Map? ?? {}),
    );
    switch (type) {
      case ActionType.item:
        return ActionItem(
          slug: slug,
          title: title,
          fields: fields,
          description: description,
          itemSlug: json['item_slug'] as String? ?? '',
          mustEquip: json['must_equip'] as bool? ?? false,
          expendable: json['expendable'] as bool? ?? false,
          ammo: json['ammo'] as String?,
        );
      case ActionType.spell:
        return ActionSpell(
          slug: slug,
          title: title,
          fields: fields,
          description: description,
          spellSlug: json['spell_slug'] as String? ?? '',
        );
      case ActionType.ability:
        return ActionAbility(
          slug: slug,
          title: title,
          fields: fields,
          description: description,
          ability: json['ability'] as String? ?? '',
          requiresResource: json['requires_resource'] as bool? ?? false,
          resourceType: ResourceType.values[json['resource_type'] as int? ?? 0],
          usedCount: json['used_count'] as int? ?? 0,
          resourceFormula: json['resource_formula'] as String? ?? '',
          resourceCount: json['resource_count'] as int?,
        );
    }
  }

  final String title;
  final String slug;
  final ActionType type;
  final ActionFields fields;
  final String description;

  Map<String, dynamic> toJson() {
    return {
      'slug': slug,
      'title': title,
      'type': type.index,
      'fields': fields.toJson(),
      'description': description,
    };
  }

  Action copyWith({
    String? title,
    ActionFields? fields,
    String? itemSlug,
    bool? mustEquip,
    bool? expendable,
    String? ammo,
    String? spellSlug,
    String? ability,
    bool? requiresResource,
    ResourceType? resourceType,
    int? usedCount,
    String? resourceFormula,
    String? description,
    int? resourceCount,
  }) {
    switch (type) {
      case ActionType.item:
        return ActionItem(
          slug: slug,
          title: title ?? this.title,
          fields: fields ?? this.fields,
          description: description ?? this.description,
          itemSlug: itemSlug ?? (this as ActionItem).itemSlug,
          mustEquip: mustEquip ?? (this as ActionItem).mustEquip,
          expendable: expendable ?? (this as ActionItem).expendable,
          ammo: ammo ?? (this as ActionItem).ammo,
        );
      case ActionType.spell:
        return ActionSpell(
          slug: slug,
          title: title ?? this.title,
          fields: fields ?? this.fields,
          description: description ?? this.description,
          spellSlug: spellSlug ?? (this as ActionSpell).spellSlug,
        );
      case ActionType.ability:
        return ActionAbility(
          slug: slug,
          title: title ?? this.title,
          fields: fields ?? this.fields,
          description: description ?? this.description,
          ability: ability ?? (this as ActionAbility).ability,
          requiresResource:
              requiresResource ?? (this as ActionAbility).requiresResource,
          resourceType: resourceType ?? (this as ActionAbility).resourceType,
          usedCount: usedCount ?? (this as ActionAbility).usedCount,
          resourceFormula:
              resourceFormula ?? (this as ActionAbility).resourceFormula,
          resourceCount: resourceCount ?? (this as ActionAbility).resourceCount,
        );
    }
  }
}

class ActionFields {
  const ActionFields({
    this.heal,
    this.damage,
    this.attack,
    this.saveDc,
    this.saveAttribute,
    this.area,
    this.range,
    this.conditions,
    this.duration,
    this.castTime,
    this.type,
    this.halfOnSuccess,
  });

  factory ActionFields.fromJson(Map<String, dynamic> json) {
    return ActionFields(
      heal: json['heal'] as String?,
      damage: json['damage'] as String?,
      attack: json['attack'] as String?,
      saveDc: json['save_dc'] as String?,
      saveAttribute: json['save_attribute'] as String?,
      area: json['area'] as String?,
      range: json['range'] as String?,
      conditions: json['conditions'] as String?,
      duration: json['duration'] as String?,
      castTime: json['cast_time'] as String?,
      type: json['type'] as String?,
      halfOnSuccess: json['half_on_success'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'heal': heal,
      'damage': damage,
      'attack': attack,
      'save_dc': saveDc,
      'save_attribute': saveAttribute,
      'area': area,
      'range': range,
      'conditions': conditions,
      'duration': duration,
      'cast_time': castTime,
      'type': type,
      'half_on_success': halfOnSuccess,
    };
  }

  final String? heal;
  final String? damage;
  final String? attack;
  final String? saveDc;
  final String? saveAttribute;
  final String? area;
  final String? range;
  final String? conditions;
  final String? duration;
  final String? castTime;
  final String? type;
  final bool? halfOnSuccess;

  ActionFields copyWith({
    String? heal,
    String? damage,
    String? attack,
    String? saveDc,
    String? saveAttribute,
    String? area,
    String? range,
    String? conditions,
    String? duration,
    String? castTime,
    String? type,
    bool? halfOnSuccess,
  }) {
    return ActionFields(
      heal: heal ?? this.heal,
      damage: damage ?? this.damage,
      attack: attack ?? this.attack,
      saveDc: saveDc ?? this.saveDc,
      saveAttribute: saveAttribute ?? this.saveAttribute,
      area: area ?? this.area,
      range: range ?? this.range,
      conditions: conditions ?? this.conditions,
      duration: duration ?? this.duration,
      castTime: castTime ?? this.castTime,
      type: type ?? this.type,
      halfOnSuccess: halfOnSuccess ?? this.halfOnSuccess,
    );
  }
}

class ActionItem extends Action {
  const ActionItem({
    required super.slug,
    required super.title,
    required super.fields,
    required super.description,
    required this.itemSlug,
    this.mustEquip = false,
    this.expendable = false,
    this.ammo,
  }) : super(type: ActionType.item);

  final String itemSlug;
  final bool mustEquip;
  final bool expendable;
  final String? ammo;

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['item_slug'] = itemSlug;
    json['must_equip'] = mustEquip;
    json['expendable'] = expendable;
    json['ammo'] = ammo;
    return json;
  }

  @override
  List<Object?> get props => [
    title,
    description,
    fields,
    itemSlug,
    mustEquip,
    expendable,
    ammo,
  ];
}

class ActionSpell extends Action {
  const ActionSpell({
    required super.slug,
    required super.title,
    required super.fields,
    required super.description,
    required this.spellSlug,
  }) : super(type: ActionType.spell);

  final String spellSlug;

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['spell_slug'] = spellSlug;
    return json;
  }

  @override
  List<Object?> get props => [title, fields, spellSlug, description];
}

class ActionAbility extends Action {
  const ActionAbility({
    required super.slug,
    required super.title,
    required super.fields,
    required this.ability,
    required super.description,
    this.requiresResource = false,
    this.resourceType = ResourceType.none,
    this.usedCount = 0,
    this.resourceCount,
    required this.resourceFormula,
  }) : super(type: ActionType.ability);

  final String ability;
  final bool requiresResource;
  final ResourceType resourceType;
  final int usedCount;
  final String resourceFormula;
  final int? resourceCount;

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['ability'] = ability;
    json['requires_resource'] = requiresResource;
    json['resource_type'] = resourceType;
    json['used_count'] = usedCount;
    json['resource_formula'] = resourceFormula;
    json['resource_count'] = resourceCount;
    return json;
  }

  @override
  List<Object?> get props => [
    title,
    description,
    fields,
    ability,
    requiresResource,
    resourceType,
    usedCount,
    resourceFormula,
    resourceCount,
  ];
}
