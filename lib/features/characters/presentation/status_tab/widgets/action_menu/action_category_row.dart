import 'package:dnd5e_dm_tools/core/util/enum.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttericon/font_awesome5_icons.dart';

class ActionCategoryRow extends StatefulWidget {
  const ActionCategoryRow({
    super.key,
    required this.onSelected,
    this.showAll = true,
    this.showSpells = true,
  });
  final Function(ActionMenuMode) onSelected;
  final bool showAll;
  final bool showSpells;

  @override
  ActionCategoryRowState createState() => ActionCategoryRowState();
}

class ActionCategoryRowState extends State<ActionCategoryRow> {
  late ActionMenuMode _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.showAll ? ActionMenuMode.all : ActionMenuMode.abilities;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        if (widget.showAll)
          Padding(
            padding: const EdgeInsets.all(8),
            child: ChoiceChip(
              showCheckmark: false,
              label: const Icon(Icons.remove),
              selected: _selected == ActionMenuMode.all,
              onSelected: (selected) {
                setState(() {
                  _selected = ActionMenuMode.all;
                  context.read<SettingsCubit>().toggleActionFilter(_selected);
                  widget.onSelected(_selected);
                });
              },
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: ChoiceChip(
            showCheckmark: false,
            label: const Icon(FontAwesome5.star),
            selected: _selected == ActionMenuMode.abilities,
            onSelected: (selected) {
              setState(() {
                _selected = ActionMenuMode.abilities;
                context.read<SettingsCubit>().toggleActionFilter(_selected);
                widget.onSelected(_selected);
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: ChoiceChip(
            showCheckmark: false,
            label: const Icon(FontAwesome5.cubes),
            selected: _selected == ActionMenuMode.items,
            onSelected: (selected) {
              setState(() {
                _selected = ActionMenuMode.items;
                context.read<SettingsCubit>().toggleActionFilter(_selected);
                widget.onSelected(_selected);
              });
            },
          ),
        ),
        if (widget.showSpells)
          Padding(
            padding: const EdgeInsets.all(8),
            child: ChoiceChip(
              showCheckmark: false,
              label: const Icon(FontAwesome5.hat_wizard),
              selected: _selected == ActionMenuMode.spells,
              onSelected: (selected) {
                setState(() {
                  _selected = ActionMenuMode.spells;
                  context.read<SettingsCubit>().toggleActionFilter(_selected);
                  widget.onSelected(_selected);
                });
              },
            ),
          ),
      ],
    );
  }
}
