import 'package:dnd5e_dm_tools/core/data/models/action.dart';
import 'package:dnd5e_dm_tools/core/data/models/character.dart';
import 'package:dnd5e_dm_tools/core/data/models/class.dart';
import 'package:dnd5e_dm_tools/core/data/models/race.dart';
import 'package:dnd5e_dm_tools/core/util/enum.dart';
import 'package:dnd5e_dm_tools/core/util/helper.dart';
import 'package:dnd5e_dm_tools/core/widgets/description_text.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/equip_tab/widgets/item_details_dialog_content.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/status_tab/widgets/action_menu/add_action_button.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_cubit.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_state.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recase/recase.dart';

typedef OnUseActionCallback =
    void Function({required Action action, bool recharge});

class ActionWidget extends StatefulWidget {
  const ActionWidget({
    super.key,
    required this.action,
    required this.character,
    required this.classs,
    required this.race,
    required this.isEditMode,
    required this.onActionsChanged,
    required this.onUse,
    this.compactMode = false,
  });
  final Action action;
  final Character character;
  final Class classs;
  final Race race;
  final bool isEditMode;
  final ValueChanged<List<Action>> onActionsChanged;
  final OnUseActionCallback? onUse;
  final bool compactMode;

  @override
  ActionWidgetState createState() => ActionWidgetState();
}

class ActionWidgetState extends State<ActionWidget> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final rulesState = context.watch<RulesCubit>().state;
    if (rulesState is! RulesStateLoaded) {
      return const SizedBox.shrink();
    }
    final spellMap = rulesState.spellMap;
    final backpack = widget.character.backpack;
    final action = widget.action;
    final classs = widget.classs;
    final spellSlots = classs.getSpellSlotsForLevel(
      widget.character.level,
      feats: widget.character.feats,
    );
    final expendedSpellSlots = widget.character.spellbook.expendedSpellSlots;
    final type = action.type;

    final bool requiresResource;
    switch (type) {
      case ActionType.ability:
        requiresResource = (action as ActionAbility).requiresResource;
      case ActionType.item:
        requiresResource =
            (action as ActionItem).mustEquip ||
            action.expendable ||
            (action.ammo?.isNotEmpty ?? false);
      case ActionType.spell:
        final spell = spellMap[(action as ActionSpell).spellSlug];
        requiresResource = spell != null && spell.level > 0;
    }

    final int resourceCount;
    switch (type) {
      case ActionType.ability:
        final abilityAction = action as ActionAbility;
        final resourceFormula = abilityAction.resourceFormula;
        if (resourceFormula.isEmpty) {
          resourceCount = abilityAction.resourceCount ?? 1;
        } else {
          resourceCount =
              int.tryParse(
                parseFormula(
                  resourceFormula,
                  widget.character.asi,
                  getProfBonus(widget.character.level),
                  widget.character.level,
                  widget.classs.table,
                ),
              ) ??
              1;
        }
      case ActionType.item:
        final itemSlug = (action as ActionItem).itemSlug;
        final backpackItem = backpack.getItemBySlug(itemSlug);
        resourceCount = backpackItem?.quantity ?? 0;
      case ActionType.spell:
        final spellSlug = (action as ActionSpell).spellSlug;
        final spell = spellMap[spellSlug];
        final spellLevelSlots = spellSlots[spell?.level ?? 0] ?? 0;
        resourceCount = spellLevelSlots;
    }

    final int usedCount;
    switch (type) {
      case ActionType.ability:
        usedCount = (action as ActionAbility).usedCount;
      case ActionType.item:
        usedCount = 0;
      case ActionType.spell:
        final spellSlug = (action as ActionSpell).spellSlug;
        final spell = spellMap[spellSlug];
        final spellLvl = spell?.level ?? 0;
        if (spellLvl > 0) {
          usedCount = expendedSpellSlots[spellLvl] ?? 0;
        } else {
          usedCount = 0;
        }
    }

    final remaining = resourceCount - usedCount;

    bool canUse = true;
    bool usable = false;

    switch (type) {
      case ActionType.ability:
        if (requiresResource) {
          canUse = remaining > 0;
          usable = true;
        }
      case ActionType.item:
        final backpackItem = backpack.getItemBySlug(
          (action as ActionItem).itemSlug,
        );
        if (action.mustEquip) {
          canUse = backpackItem?.isEquipped ?? false;
          if (canUse) {
            usable = false;
          }
        } else {
          canUse = true;
        }
        canUse = canUse && (backpackItem?.quantity ?? 0) > 0;
        if (action.expendable) {
          usable = true;
        }
        if ((action.ammo?.isNotEmpty ?? false) &&
            (action.ammo?.toString() != 'none')) {
          usable = true;
        }
      case ActionType.spell:
        final spell = spellMap[(action as ActionSpell).spellSlug];
        if (spell != null) {
          final level = spell.level;
          if (level > 0) {
            usable = true;
          }
        }
    }
    Widget buildSubtitle(BuildContext context) {
      final boldTheme = Theme.of(
        context,
      ).textTheme.labelLarge!.copyWith(fontWeight: FontWeight.bold);
      final boldThemeMedium = Theme.of(
        context,
      ).textTheme.labelMedium!.copyWith(fontWeight: FontWeight.bold);
      final List<Widget> children = [];

      switch (type) {
        case ActionType.ability:
          final requiresResource = (action as ActionAbility).requiresResource;
          if (requiresResource) {
            final color = remaining > 0
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).colorScheme.error;
            children.add(
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$remaining/$resourceCount',
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 8, width: 32, child: Divider()),
                  if (action.customResource?.name.isNotEmpty ?? false)
                    Text(
                      action.customResource!.name,
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    )
                  else if (remaining > 0)
                    Text(
                      'Available\nUses',
                      style: Theme.of(context).textTheme.labelSmall,
                      textAlign: TextAlign.center,
                    )
                  else
                    Text(
                      'No Uses\nAvailable',
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      softWrap: false,
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            );
            final resourceType = action.resourceType;
            if (resourceType == ResourceType.shortRest ||
                resourceType == ResourceType.longRest) {
              children.add(
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Recharge',
                      style: Theme.of(context).textTheme.labelSmall,
                      textAlign: TextAlign.center,
                      softWrap: false,
                    ),
                    const SizedBox(height: 2),
                    if (resourceType == ResourceType.shortRest)
                      Text(
                        'Short Rest',
                        style: Theme.of(context).textTheme.labelMedium,
                        textAlign: TextAlign.center,
                        softWrap: true,
                      )
                    else
                      Text(
                        'Long Rest',
                        style: Theme.of(context).textTheme.labelMedium,
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              );
            }
            if (resourceType == ResourceType.custom &&
                action.customResource != null) {
              children.add(
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Recharge',
                      style: Theme.of(context).textTheme.labelSmall,
                      textAlign: TextAlign.center,
                      softWrap: false,
                    ),
                    const SizedBox(height: 2),
                    if (action.customResource!.longRest == 'all' &&
                        action.customResource!.shortRest != 'all')
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Text(
                          'Long Rest',
                          style: Theme.of(context).textTheme.labelMedium,
                          textAlign: TextAlign.center,
                        ),
                      )
                    else if (action.customResource!.longRest.isNotEmpty &&
                        action.customResource!.shortRest != 'all')
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Text(
                          '${action.customResource!.longRest}/Long Rest',
                          style: Theme.of(context).textTheme.labelMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    if (action.customResource!.shortRest == 'all')
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(
                          'Short Rest',
                          style: Theme.of(context).textTheme.labelMedium,
                          textAlign: TextAlign.center,
                        ),
                      )
                    else if (action.customResource!.shortRest.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(
                          '${action.customResource!.shortRest}/Short Rest',
                          style: Theme.of(context).textTheme.labelMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              );
            }
          }
        case ActionType.spell:
          final spell = spellMap[(action as ActionSpell).spellSlug];
          if (spell == null) {
            break;
          }
          final level = spell.level;
          final levelText = spell.levelText;
          final school = spell.school;
          if (level == 0) {
            children.add(
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    school.name,
                    softWrap: false,
                    style: Theme.of(
                      context,
                    ).textTheme.labelMedium!.copyWith(color: school.color),
                  ),
                  Text(levelText, softWrap: false, style: boldThemeMedium),
                ],
              ),
            );
          } else {
            final totalSlots = spellSlots[level] ?? 0;
            final availableSlots =
                totalSlots - (expendedSpellSlots[level] ?? 0);
            children.add(
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    school.name,
                    style: Theme.of(
                      context,
                    ).textTheme.labelMedium!.copyWith(color: school.color),
                    softWrap: false,
                  ),
                  Text(levelText, softWrap: false, style: boldThemeMedium),
                  const SizedBox(width: 36, child: Divider(height: 8)),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Slots: ',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        Text(
                          '$availableSlots/$totalSlots',
                          style: Theme.of(context).textTheme.labelMedium!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          final ritual = spell.ritual;
          if (ritual) {
            children.add(
              Text(
                'Ritual',
                style: boldTheme,
                softWrap: false,
                textAlign: TextAlign.center,
              ),
            );
          }
          final concentration = spell.concentration;
          if (concentration) {
            children.add(
              Text(
                'Concentration',
                style: boldTheme,
                softWrap: false,
                textAlign: TextAlign.center,
              ),
            );
          }
          final vsm = spell.components;
          var components = '';
          if (vsm.contains('V')) {
            components += 'V';
          }
          if (vsm.contains('S')) {
            components += 'S';
          }
          if (vsm.contains('M')) {
            components += 'M';
          }
          final List<TextSpan> componentSpans = [];
          bool isFirst = true;
          for (final component in components.split('')) {
            final TextSpan textSpan = TextSpan(
              text: component,
              style: Theme.of(
                context,
              ).textTheme.labelMedium!.copyWith(fontWeight: FontWeight.bold),
            );
            if (!isFirst) {
              componentSpans.add(
                TextSpan(
                  text: ' • ',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              );
            }
            componentSpans.add(textSpan);
            isFirst = false;
          }
          if (componentSpans.isNotEmpty) {
            children.add(
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Components',
                    style: Theme.of(context).textTheme.labelSmall,
                    softWrap: false,
                    textAlign: TextAlign.center,
                  ),
                  RichText(
                    text: TextSpan(children: componentSpans),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

        case ActionType.item:
          final backpackItem = backpack.getItemBySlug(
            (action as ActionItem).itemSlug,
          );
          final quantity = backpackItem?.quantity ?? 0;
          final equipped = backpackItem?.isEquipped ?? false;
          final equippedStr = equipped ? 'Equipped' : 'Not Equipped';
          final requiresEquipped = action.mustEquip;
          final quantityStr = '${quantity}x available';
          final expendable = action.expendable;
          final hasAmmo =
              (action.ammo?.isNotEmpty ?? false) &&
              (action.ammo?.toString() != 'none');
          final String ammoStr;
          if (hasAmmo) {
            final ammo = action.ammo ?? '';
            final itemMap =
                (context.read<RulesCubit>().state as RulesStateLoaded).itemMap;
            final ammoItem = itemMap[ammo];
            if (ammoItem == null) {
              break;
            }
            final ammoBackpackItem = backpack.getItemBySlug(ammo);
            final ammoQuantity = ammoBackpackItem?.quantity ?? 0;
            ammoStr = '${ammoQuantity}x ${ammoItem.name.split(' ').last}';
          } else {
            ammoStr = '';
          }
          if (requiresEquipped || expendable || ammoStr.isNotEmpty) {
            children.add(
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (requiresEquipped)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        equippedStr,
                        style: Theme.of(context).textTheme.labelMedium!
                            .copyWith(fontWeight: FontWeight.bold),
                        softWrap: false,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (expendable)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        quantityStr,
                        style: Theme.of(context).textTheme.labelMedium!
                            .copyWith(fontWeight: FontWeight.bold),
                        softWrap: false,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (ammoStr.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        ammoStr,
                        style: Theme.of(context).textTheme.labelMedium!
                            .copyWith(fontWeight: FontWeight.bold),
                        softWrap: false,
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            );
          }
      }

      final actionFields = _buildFields(context);
      children.addAll(actionFields);

      return LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          final cols = w >= 1400
              ? 5
              : w >= 900
              ? 4
              : 3;

          return MasonryGridView.count(
            crossAxisCount: cols,
            itemCount: children.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, i) {
              return Card.outlined(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 4,
                  ),
                  child: children[i],
                ),
              );
            },
          );
        },
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        setState(() {
          isExpanded = !isExpanded;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 24),
                    child: Text(
                      action.title,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontFamily: GoogleFonts.montserrat().fontFamily,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 18),
                    child: _buildUse(
                      context,
                      usable,
                      remaining,
                      requiresResource,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!widget.compactMode)
            Align(
              child: SizedBox(
                width: screenWidth * 0.8,
                child: const Divider(height: 6),
              ),
            ),
          if (!widget.compactMode)
            Column(
              children: [buildSubtitle(context), const SizedBox(height: 4)],
            ),
          AnimatedCrossFade(
            firstChild: Container(),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.compactMode)
                  Column(
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: SizedBox(
                          width: screenWidth * 0.8,
                          child: const Divider(height: 2),
                        ),
                      ),
                      buildSubtitle(context),
                    ],
                  ),
                Align(
                  child: SizedBox(
                    width: screenWidth * 0.8,
                    child: const Divider(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      DescriptionText(
                        inputText: action.description,
                        baseStyle: Theme.of(context).textTheme.bodySmall!,
                        extraBoldWords: action.getExtraBoldWords(
                          widget.classs,
                          widget.character,
                        ),
                      ),
                      if (action.type == ActionType.item &&
                          action is ActionItem &&
                          action.itemSlug.isNotEmpty)
                        BlocBuilder<RulesCubit, RulesState>(
                          builder: (context, state) {
                            if (state is! RulesStateLoaded) {
                              return Container();
                            }
                            final item = state.itemMap[action.itemSlug];
                            if (item != null) {
                              final backpackItem = backpack.getItemBySlug(
                                action.itemSlug,
                              );
                              if (backpackItem == null) {
                                return Container();
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ItemDetailsDialogContent(
                                    backpackItem: backpackItem.copyWith(
                                      item: item,
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return Container();
                            }
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 150),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFields(BuildContext context) {
    final children = <Widget>[];
    final actionFields = widget.action.fields;
    final level = widget.character.level;
    final prof = getProfBonus(level);
    final asi = widget.character.asi;
    final boldTheme = Theme.of(
      context,
    ).textTheme.labelLarge!.copyWith(fontWeight: FontWeight.bold);

    if (actionFields.heal?.isNotEmpty ?? false) {
      final heal = parseFormula(actionFields.heal ?? '', asi, prof, level, widget.classs.table);
      children.add(
        _buildVerticalField('Heal', heal, context, valueTheme: boldTheme),
      );
    }

    if (actionFields.damage?.isNotEmpty ?? false) {
      final damage = parseFormula(actionFields.damage ?? '', asi, prof, level, widget.classs.table);
      if (actionFields.type?.isNotEmpty ?? false) {
        final type = actionFields.type?.sentenceCase ?? '';
        final typeColor = DamageType.values
            .where((e) => e.name.toLowerCase() == type.toLowerCase())
            .firstOrNull
            ?.color;
        final typeWidget = Text(
          type,
          style: Theme.of(context).textTheme.labelMedium!.copyWith(
            color: typeColor ?? Theme.of(context).colorScheme.onSurface,
          ),
        );
        children.add(
          _buildVerticalField(
            'Damage',
            damage,
            context,
            extra: typeWidget,
            valueTheme: boldTheme,
          ),
        );
      } else {
        children.add(
          _buildVerticalField('Damage', damage, context, valueTheme: boldTheme),
        );
      }
    }

    if (actionFields.attack?.isNotEmpty ?? false) {
      final attack = parseFormula(actionFields.attack ?? '', asi, prof, level, widget.classs.table);
      final attackStr = (int.tryParse(attack) ?? 0) > 0 ? '+$attack' : attack;
      children.add(
        _buildVerticalField(
          'Attack',
          attackStr,
          context,
          valueTheme: boldTheme,
        ),
      );
    }

    if ((actionFields.saveAttribute?.isNotEmpty ?? false) &&
        (actionFields.saveAttribute?.toLowerCase() != 'none')) {
      final save = actionFields.saveAttribute?.sentenceCase ?? '';
      if (actionFields.saveDc?.isNotEmpty ?? false) {
        final saveDc = parseFormula(
          actionFields.saveDc ?? '',
          asi,
          prof,
          level,
          widget.classs.table,
        );
        final saveWidget = DescriptionText(
          inputText: save,
          baseStyle: Theme.of(context).textTheme.labelMedium!,
        );
        final saveRow = Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Save: ',
              softWrap: true,
              style: Theme.of(context).textTheme.labelSmall,
            ),
            Text(saveDc, softWrap: true, style: boldTheme),
          ],
        );

        if (actionFields.halfOnSuccess?.toString() == 'true') {
          children.add(
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                saveRow,
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: saveWidget,
                ),
                Text(
                  'Half on Success',
                  style: Theme.of(context).textTheme.labelSmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        } else {
          children.add(
            Column(
              children: [
                saveRow,
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: saveWidget,
                ),
              ],
            ),
          );
        }
      }
    }

    if (actionFields.area?.isNotEmpty ?? false) {
      final area = actionFields.area?.sentenceCase ?? '';
      children.add(_buildVerticalField('Area', area, context));
    }

    if (actionFields.range?.isNotEmpty ?? false) {
      final range = actionFields.range?.sentenceCase ?? '';
      children.add(_buildVerticalField('Range', range, context));
    }

    if ((actionFields.duration?.isNotEmpty ?? false) &&
        actionFields.duration?.toLowerCase() != 'instantaneous') {
      final duration = actionFields.duration?.sentenceCase ?? '';
      children.add(_buildVerticalField('Duration', duration, context));
    }

    if (actionFields.conditions?.isNotEmpty ?? false) {
      final conditionsField = actionFields.conditions?.toString() ?? '';
      final wordCount = conditionsField.split(' ').length;
      final String conditions;
      final TextStyle baseStyle;
      if (wordCount > 3) {
        conditions = conditionsField.sentenceCase;
        baseStyle = Theme.of(context).textTheme.labelMedium!;
      } else {
        conditions = conditionsField.titleCase;
        baseStyle = Theme.of(context).textTheme.labelLarge!;
      }
      children.add(
        Column(
          children: [
            Text(
              'Condition',
              style: Theme.of(context).textTheme.labelSmall,
              softWrap: true,
            ),
            DescriptionText(
              textAlign: TextAlign.center,
              inputText: conditions,
              baseStyle: baseStyle,
            ),
          ],
        ),
      );
    }

    if (actionFields.castTime?.isNotEmpty ?? false) {
      final castTimeStr = actionFields.castTime?.toLowerCase();
      final castTime = castTimeStr == '1 action'
          ? 'action'
          : castTimeStr == '1 bonus action'
          ? 'bonus action'
          : castTimeStr == '1 reaction'
          ? 'reaction'
          : castTimeStr ?? '';
      children.add(
        _buildVerticalField('Cast Time', castTime.titleCase, context),
      );
    }

    return children;
  }

  Widget _buildVerticalField(
    String field,
    String value,
    BuildContext context, {
    Widget? extra,
    TextStyle? valueTheme,
  }) {
    return Column(
      children: [
        Text(field, style: Theme.of(context).textTheme.labelSmall),
        Text(
          value,
          textAlign: TextAlign.center,
          style: valueTheme ?? Theme.of(context).textTheme.labelSmall,
        ),
        if (extra != null)
          Padding(padding: const EdgeInsets.only(top: 2), child: extra),
      ],
    );
  }

  Widget _buildUse(
    BuildContext context,
    bool usable,
    int remaining,
    bool requiresResource,
  ) {
    final editMode = widget.isEditMode;
    if (editMode) {
      return AddActionButton(
        character: widget.character,
        action: widget.action,
        classs: widget.classs,
        race: widget.race,
        onActionsChanged: widget.onActionsChanged,
      );
    }
    if (!usable) {
      return const SizedBox();
    }
    if (remaining == 0 && requiresResource) {
      return ActionChip(
        label: const Text('Recharge'),
        onPressed: () {
          widget.onUse?.call(action: widget.action, recharge: true);
        },
      );
    }
    return ActionChip(
      label: const Text('Use'),
      onPressed: () {
        widget.onUse?.call(action: widget.action);
      },
    );
  }
}
