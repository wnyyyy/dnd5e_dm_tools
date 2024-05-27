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
  final Map<String, dynamic> action;
  final String actionSlug;
  final Map<String, dynamic> character;
  final String characterSlug;
  final bool isEditMode;
  final Function(Map<String, Map<String, dynamic>>) onActionsChanged;
  final OnUseActionCallback? onUse;

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
    final resourceFormula = widget.action['resource_formula'];
    if (resourceFormula != null) {
      final asi = Map<String, int>.from(
        widget.character['asi'] ??
            {
              'strength': 10,
              'dexterity': 10,
              'constitution': 10,
              'intelligence': 10,
              'wisdom': 10,
              'charisma': 10,
            },
      );
      final level = widget.character['level'] ?? 1;
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
    final remaining = resourceCount - usedCount; // Use parsed integer value
    final mustEquip = widget.action['must_equip'] ?? false;
    final resourceTypeStr = widget.action['resource_type'] ?? '';
    final resourceType = ResourceType.values.firstWhere(
        (e) => e.name == resourceTypeStr,
        orElse: () => ResourceType.none);
    switch (type) {
      case ActionMenuMode.abilities:
        if (requiresResource) {
          canUse = remaining > 0;
          usable = true;
        }
        break;
      case ActionMenuMode.items:
        final backpackItem =
            getBackpackItem(widget.character, widget.action['item']);
        canUse = mustEquip ? backpackItem['isEquipped'] ?? false : true;
        canUse = canUse && (backpackItem['quantity'] ?? 0) > 0;
        if (widget.action['expendable'] ?? false) {
          usable = true;
        }
        if (widget.action['ammo']?.toString().isNotEmpty ?? false) {
          usable = true;
        }
        break;
      default:
        canUse = true;
    }

    Widget buildSubtitle(context) {
      List<Widget> children = [];
      switch (type) {
        case ActionMenuMode.abilities:
          if (widget.action['requires_resource']) {
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
        default:
          break;
      }

      final actionFields = _buildFields(context);
      children.addAll(actionFields);

      if (children.length < 4) {
        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: List.generate(children.length, (index) {
            return Card.outlined(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: children[index],
              ),
            );
          }),
        );
      }

      return StaggeredGrid.count(
        crossAxisCount: 4,
        children: List.generate(children.length, (index) {
          return StaggeredGridTile.fit(
            crossAxisCellCount: 1,
            child: Card.outlined(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: children[index],
              ),
            ),
          );
        }),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
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
                        widget.action['title'],
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
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
            SizedBox(width: screenWidth * 0.8, child: const Divider()),
            Padding(
              padding: const EdgeInsets.only(left: 6, right: 6, bottom: 0),
              child: buildSubtitle(context),
            ),
            AnimatedCrossFade(
              firstChild: Container(),
              secondChild: Column(
                children: [
                  SizedBox(width: screenWidth * 0.8, child: const Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        DescriptionText(
                            inputText: widget.action['description'],
                            baseStyle: Theme.of(context).textTheme.bodySmall!),
                        if (widget.action['item'] != null)
                          BlocBuilder<RulesCubit, RulesState>(
                            builder: (context, state) {
                              final item = context
                                  .read<RulesCubit>()
                                  .getItem(widget.action['item'] ?? '');
                              if (item != null) {
                                final backpackItem = getBackpackItem(
                                    widget.character, widget.action['item']);
                                return Column(
                                  children: [
                                    const Divider(),
                                    ItemDetailsDialogContent(
                                      item: item,
                                      quantity: backpackItem['quantity'],
                                    )
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
    final actionFields = widget.action['fields'];
    final level = widget.character['level'] ?? 1;
    final prof = getProfBonus(level);
    final asi = Map<String, int>.from(
      widget.character['asi'] ??
          {
            'strength': 10,
            'dexterity': 10,
            'constitution': 10,
            'intelligence': 10,
            'wisdom': 10,
            'charisma': 10,
          },
    );
    final boldTheme = Theme.of(context).textTheme.labelLarge!.copyWith(
          fontWeight: FontWeight.bold,
        );

    if (actionFields['heal']?.toString().isNotEmpty ?? false) {
      final heal = parseFormula(actionFields['heal'], asi, prof, level);
      children.add(
          _buildVerticalField('Heal', heal, context, valueTheme: boldTheme));
    }

    if (actionFields['damage']?.toString().isNotEmpty ?? false) {
      final damage = parseFormula(actionFields['damage'], asi, prof, level);
      if (actionFields['type']?.toString().isNotEmpty ?? false) {
        final type = actionFields['type'].toString().sentenceCase;
        final typeWidget = DescriptionText(
            inputText: type,
            baseStyle: Theme.of(context).textTheme.labelSmall!);
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
        children.add(_buildVerticalField('Damage', damage, context,
            valueTheme: boldTheme));
      }
    }

    if (actionFields['attack']?.toString().isNotEmpty ?? false) {
      final attack = parseFormula(actionFields['attack'], asi, prof, level);
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
        final saveDc = parseFormula(actionFields['save_dc'], asi, prof, level);
        final saveWidget = DescriptionText(
          inputText: save,
          baseStyle: Theme.of(context).textTheme.labelMedium!,
        );
        final saveRow = Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
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
            )
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
      children.add(Column(
        children: [
          Text(
            'Condition',
            style: Theme.of(context).textTheme.labelSmall,
            softWrap: true,
          ),
          DescriptionText(
              textAlign: TextAlign.center,
              inputText: conditions,
              baseStyle: baseStyle),
        ],
      ));
    }

    if (actionFields['cast_time']?.toString().isNotEmpty ?? false) {
      final castTime = actionFields['cast_time'].toString().titleCase;
      children.add(_buildVerticalField('Cast Time', castTime, context));
    }

    return children;
  }

  Widget _buildVerticalField(String field, String value, BuildContext context,
      {Widget? extra, TextStyle? valueTheme}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
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
          if (widget.onUse != null) {
            widget.onUse!(
              action: widget.action,
              slug: widget.actionSlug,
              type: ActionMenuMode.abilities,
              recharge: true,
            );
          }
        },
      );
    }
    final type = ActionMenuMode.values.firstWhere(
        (e) => e.name == widget.action['type'],
        orElse: () => ActionMenuMode.all);
    return ActionChip(
      label: const Text('Use'),
      onPressed: () {
        if (widget.onUse != null) {
          widget.onUse!(
            action: widget.action,
            slug: widget.actionSlug,
            type: type,
          );
        }
      },
    );
  }
}
