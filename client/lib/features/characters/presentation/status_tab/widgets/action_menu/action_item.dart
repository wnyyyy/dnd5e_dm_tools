import 'package:dnd5e_dm_tools/core/util/enum.dart';
import 'package:dnd5e_dm_tools/core/util/helper.dart';
import 'package:dnd5e_dm_tools/core/widgets/description_text.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/equip_tab/widgets/item_details_dialog_content.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/status_tab/widgets/action_menu/add_action.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_cubit.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recase/recase.dart';

typedef OnUseActionCallback = void Function({
  required Map<String, dynamic> action,
  required String slug,
  required ActionMenuMode type,
  bool recharge,
});

class ActionItem extends StatefulWidget {
  const ActionItem({
    super.key,
    required this.action,
    required this.actionSlug,
    required this.character,
    required this.characterSlug,
    required this.isEditMode,
    required this.onActionsChanged,
    required this.onUse,
  });
  final Map<String, dynamic> action;
  final String actionSlug;
  final Map<String, dynamic> character;
  final String characterSlug;
  final bool isEditMode;
  final Function(Map<String, Map<String, dynamic>>) onActionsChanged;
  final OnUseActionCallback? onUse;

  @override
  ActionItemState createState() => ActionItemState();
}

class ActionItemState extends State<ActionItem> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    bool canUse = true;
    bool usable = false;
    final ActionMenuMode type = ActionMenuMode.values.firstWhere(
      (e) => e.name == widget.action['type'],
      orElse: () => ActionMenuMode.all,
    );
    final requiresResource =
        (widget.action['requires_resource'] ?? false) as bool;
    final usedCount =
        int.tryParse(widget.action['used_count']?.toString() ?? '0') ?? 0;
    int resourceCount = 0;
    final resourceFormula = widget.action['resource_formula'] as String?;
    if (resourceFormula != null) {
      final asi = getAsi(widget.character);
      final level = widget.character['level'] as int? ?? 1;
      final prof = getProfBonus(level);
      try {
        final parsedValue =
            int.parse(parseFormula(resourceFormula, asi, prof, level));
        resourceCount = parsedValue;
      } catch (e) {
        resourceCount = 1;
      }
    } else {
      final resourceCountValue = widget.action['resource_count'];
      if (resourceCountValue is int) {
        resourceCount = resourceCountValue;
      } else if (resourceCountValue is String) {
        resourceCount = int.tryParse(resourceCountValue) ?? 1;
      } else {
        resourceCount = 1;
      }
    }
    final remaining = resourceCount - usedCount;
    final mustEquip = widget.action['must_equip'] as bool? ?? false;
    final resourceTypeStr = widget.action['resource_type'] ?? '';
    final resourceType = ResourceType.values.firstWhere(
      (e) => e.name == resourceTypeStr,
      orElse: () => ResourceType.none,
    );
    switch (type) {
      case ActionMenuMode.abilities:
        if (requiresResource) {
          canUse = remaining > 0;
          usable = true;
        }
      case ActionMenuMode.items:
        final backpackItem = getBackpackItem(
          widget.character,
          widget.action['item']?.toString() ?? '',
        );
        if (mustEquip) {
          canUse = backpackItem['isEquipped'] as bool? ?? false;
          if (canUse) {
            usable = false;
          }
        } else {
          canUse = true;
        }
        canUse = canUse && (backpackItem['quantity'] as int? ?? 0) > 0;
        if (widget.action['expendable'] as bool? ?? false) {
          usable = true;
        }
        if ((widget.action['ammo']?.toString().isNotEmpty ?? false) &&
            (widget.action['ammo']?.toString() != 'none')) {
          usable = true;
        }
      default:
        canUse = true;
    }

    Widget buildSubtitle() {
      final boldTheme = Theme.of(context).textTheme.labelLarge!.copyWith(
            fontWeight: FontWeight.bold,
          );
      final boldThemeMedium = Theme.of(context).textTheme.labelMedium!.copyWith(
            fontWeight: FontWeight.bold,
          );
      final List<Widget> children = [];
      switch (type) {
        case ActionMenuMode.abilities:
          if (widget.action['requires_resource'] as bool? ?? false) {
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
                  const SizedBox(
                    height: 8,
                    width: 32,
                    child: Divider(),
                  ),
                  if (remaining > 0)
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
          }
        case ActionMenuMode.spells:
          final spellSlug = widget.action['spell'] as String?;
          if (spellSlug == null) {
            break;
          }
          final spell = context.read<RulesCubit>().getSpell(spellSlug);
          if (spell == null) {
            break;
          }
          final level = spell['level'] ?? 'Cantrip';
          final school = spell['school'] ?? '';
          if (level == 'Cantrip') {
            children.add(
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    school.toString().sentenceCase,
                    softWrap: false,
                    style: boldThemeMedium,
                  ),
                  Text('$level', softWrap: false, style: boldThemeMedium),
                ],
              ),
            );
          } else {
            final classSlug = widget.character['class']?.toString() ?? '';
            final classs = context.read<RulesCubit>().getClass(classSlug) ?? {};
            final tableStr = classs['table'] as String? ?? '';
            final table = parseTable(tableStr);
            final Map<int, int> totalSlotsMap = getSpellSlotsForLevel(
              table,
              widget.character['level'] as int? ?? 1,
            );
            final expendedSlotsMap = getExpendedSlots(widget.character);
            final levelInt = spell['level_int'] ?? 1;
            final expendedSpellSlots = expendedSlotsMap[levelInt] ?? 0;
            final totalSlots = totalSlotsMap[levelInt] ?? 0;
            final availableSlots = totalSlots - expendedSpellSlots;
            children.add(
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    school.toString().sentenceCase,
                    softWrap: false,
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    '$level',
                    softWrap: false,
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(
                    width: 36,
                    child: Divider(
                      height: 6,
                    ),
                  ),
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
                          style:
                              Theme.of(context).textTheme.labelMedium!.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          final ritual = spell['ritual'] ?? 'no';
          if (ritual == 'yes') {
            children.add(
              Text(
                'Ritual',
                style: boldTheme,
                softWrap: false,
                textAlign: TextAlign.center,
              ),
            );
          }
          final concentration = spell['concentration'] ?? 'no';
          if (concentration == 'yes') {
            children.add(
              Text(
                'Concentration',
                style: boldTheme,
                softWrap: false,
                textAlign: TextAlign.center,
              ),
            );
          }
          final vsm = spell['components'] as String? ?? '';
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
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
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
                    text: TextSpan(
                      children: componentSpans,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

        case ActionMenuMode.items:
          final backpackItem = getBackpackItem(
            widget.character,
            widget.action['item']?.toString() ?? '',
          );
          final quantity = backpackItem['quantity'] as int? ?? 0;
          final equipped = backpackItem['isEquipped'] as bool? ?? false;
          final equippedStr = equipped ? 'Equipped' : 'Not Equipped';
          final requiresEquipped =
              widget.action['must_equip'] as bool? ?? false;
          final quantityStr = '${quantity}x available';
          final expendable = widget.action['expendable'] as bool? ?? false;
          final hasAmmo = widget.action['ammo']?.toString().isNotEmpty ?? false;
          final String ammoStr;
          if (hasAmmo) {
            final ammo = widget.action['ammo'] as String? ?? '';
            final ammoItem = context.read<RulesCubit>().getItem(ammo);
            if (ammoItem == null) {
              break;
            }
            final ammoBackpackItem = getBackpackItem(widget.character, ammo);
            final ammoQuantity = ammoBackpackItem['quantity'] ?? 0;
            ammoStr = '${ammoQuantity}x ${ammoItem["name"]}';
          } else {
            ammoStr = '';
          }
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
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      softWrap: false,
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (expendable)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      quantityStr,
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      softWrap: false,
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (ammoStr.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      ammoStr,
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      softWrap: false,
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          );
        default:
          break;
      }

      final actionFields = _buildFields(context);
      children.addAll(actionFields);

      return LayoutBuilder(
        builder: (context, constraints) {
          final int crossAxisCount =
              3 + ((constraints.maxWidth - 300) / 80).floor();
          if (constraints.maxWidth > 900) {
            return Wrap(
              children: List.generate(children.length, (index) {
                return Card.outlined(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: children[index],
                  ),
                );
              }),
            );
          } else {
            return StaggeredGrid.count(
              crossAxisCount: crossAxisCount,
              children: List.generate(children.length, (index) {
                return StaggeredGridTile.fit(
                  crossAxisCellCount: 1,
                  child: Card.outlined(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: children[index],
                    ),
                  ),
                );
              }),
            );
          }
        },
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final TextStyle? baseTitleTheme;
    if (screenWidth < 1200 && widget.action['title'].toString().length > 16) {
      baseTitleTheme = Theme.of(context).textTheme.titleMedium;
    } else {
      baseTitleTheme = Theme.of(context).textTheme.titleLarge;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          setState(() {
            isExpanded = !isExpanded;
          });
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12, left: 24),
                      child: Text(
                        widget.action['title'] as String? ?? '',
                        style: baseTitleTheme!.copyWith(
                          fontFamily: GoogleFonts.montserrat().fontFamily,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 18),
                      child: _buildUse(context, usable, remaining),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              child: SizedBox(width: screenWidth * 0.8, child: const Divider()),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 6, right: 6),
              child: buildSubtitle(),
            ),
            AnimatedCrossFade(
              firstChild: Container(),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                          inputText:
                              widget.action['description'] as String? ?? '',
                          baseStyle: Theme.of(context).textTheme.bodySmall!,
                        ),
                        if (widget.action['item'] != null)
                          BlocBuilder<RulesCubit, RulesState>(
                            builder: (context, state) {
                              final item = context.read<RulesCubit>().getItem(
                                    widget.action['item']?.toString() ?? '',
                                  );
                              if (item != null) {
                                final backpackItem = getBackpackItem(
                                  widget.character,
                                  widget.action['item']?.toString() ?? '',
                                );
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (item['description']
                                            ?.toString()
                                            .isNotEmpty ??
                                        false)
                                      const Divider(),
                                    ItemDetailsDialogContent(
                                      item: item,
                                      quantity:
                                          backpackItem['quantity'] as int? ?? 0,
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
                  const SizedBox(
                    height: 4,
                  ),
                ],
              ),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 150),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFields(BuildContext context) {
    final children = <Widget>[];
    final actionFields = widget.action['fields'] as Map<String, dynamic>;
    final level = widget.character['level'] as int? ?? 1;
    final prof = getProfBonus(level);
    final asi = getAsi(widget.character);
    final boldTheme = Theme.of(context).textTheme.labelLarge!.copyWith(
          fontWeight: FontWeight.bold,
        );

    if (actionFields['heal']?.toString().isNotEmpty ?? false) {
      final heal = parseFormula(
        actionFields['heal']?.toString() ?? '',
        asi,
        prof,
        level,
      );
      children.add(
        _buildVerticalField('Heal', heal, context, valueTheme: boldTheme),
      );
    }

    if (actionFields['damage']?.toString().isNotEmpty ?? false) {
      final damage = parseFormula(
        actionFields['damage']?.toString() ?? '',
        asi,
        prof,
        level,
      );
      if (actionFields['type']?.toString().isNotEmpty ?? false) {
        final type = actionFields['type'].toString().sentenceCase;
        final typeWidget = DescriptionText(
          inputText: type,
          baseStyle: Theme.of(context).textTheme.labelSmall!,
        );
        children.add(
          _buildVerticalField(
            'Damage',
            damage,
            extra: typeWidget,
            valueTheme: boldTheme,
            context,
          ),
        );
      } else {
        children.add(
          _buildVerticalField(
            'Damage',
            damage,
            context,
            valueTheme: boldTheme,
          ),
        );
      }
    }

    if (actionFields['attack']?.toString().isNotEmpty ?? false) {
      final attack = parseFormula(
        actionFields['attack']?.toString() ?? '',
        asi,
        prof,
        level,
      );
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

    if ((actionFields['save']?.toString().isNotEmpty ?? false) &&
        (actionFields['save'].toString().toLowerCase() != 'none')) {
      final save = actionFields['save'].toString().sentenceCase;
      if (actionFields['save_dc']?.toString().isNotEmpty ?? false) {
        final saveDc = parseFormula(
          actionFields['save_dc']?.toString() ?? '',
          asi,
          prof,
          level,
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
            Text(
              saveDc,
              softWrap: true,
              style: boldTheme,
            ),
          ],
        );

        if (actionFields['half_on_success']?.toString().isNotEmpty ?? false) {
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

    if (actionFields['area']?.toString().isNotEmpty ?? false) {
      final area = actionFields['area'].toString().sentenceCase;
      children.add(_buildVerticalField('Area', area, context));
    }

    if (actionFields['range']?.toString().isNotEmpty ?? false) {
      final range = actionFields['range'].toString().sentenceCase;
      children.add(_buildVerticalField('Range', range, context));
    }

    if (actionFields['duration']?.toString().isNotEmpty ?? false) {
      final duration = actionFields['duration'].toString().sentenceCase;
      children.add(_buildVerticalField('Duration', duration, context));
    }

    if (actionFields['conditions']?.toString().isNotEmpty ?? false) {
      final conditionsField = actionFields['conditions'].toString();
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

    if (actionFields['cast_time']?.toString().isNotEmpty ?? false) {
      final castTime = actionFields['cast_time'].toString().titleCase;
      children.add(_buildVerticalField('Cast Time', castTime, context));
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
        Text(
          field,
          style: Theme.of(context).textTheme.labelSmall,
        ),
        Text(
          value,
          textAlign: TextAlign.center,
          style: valueTheme ?? Theme.of(context).textTheme.labelSmall,
        ),
        if (extra != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: extra,
          ),
      ],
    );
  }

  Widget _buildUse(BuildContext context, bool usable, int remaining) {
    final editMode = widget.isEditMode;
    if (editMode) {
      return AddActionButton(
        character: widget.character,
        slug: widget.characterSlug,
        action: widget.action,
        actionSlug: widget.actionSlug,
        onActionsChanged: widget.onActionsChanged,
      );
    }
    if (!usable) {
      return const SizedBox();
    }
    if (remaining == 0 && widget.action['requires_resource'] == true) {
      return ActionChip(
        label: const Text('Recharge'),
        onPressed: () {
          widget.onUse?.call(
            action: widget.action,
            slug: widget.actionSlug,
            type: ActionMenuMode.abilities,
            recharge: true,
          );
        },
      );
    }
    final type = ActionMenuMode.values.firstWhere(
      (e) => e.name == widget.action['type'],
      orElse: () => ActionMenuMode.all,
    );
    return ActionChip(
      label: const Text('Use'),
      onPressed: () {
        widget.onUse?.call(
          action: widget.action,
          slug: widget.actionSlug,
          type: type,
        );
      },
    );
  }
}
