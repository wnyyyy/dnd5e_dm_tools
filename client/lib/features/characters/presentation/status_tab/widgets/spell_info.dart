import 'package:dnd5e_dm_tools/core/widgets/description_text.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SpellInfoDialog extends StatefulWidget {
  const SpellInfoDialog({
    super.key,
    required this.spellSlug,
    required this.spells,
    required this.knownSpells,
    required this.preparedSpells,
    required this.updateCharacter,
  });
  final String spellSlug;
  final Map<String, dynamic> spells;
  final List<String> knownSpells;
  final Map<String, bool> preparedSpells;
  final VoidCallback updateCharacter;

  @override
  SpellInfoDialogState createState() => SpellInfoDialogState();
}

class SpellInfoDialogState extends State<SpellInfoDialog> {
  late bool isLearned;
  late Map<String, bool> preparedSpells;

  @override
  void initState() {
    super.initState();
    isLearned = widget.knownSpells.contains(widget.spellSlug);
    preparedSpells = Map<String, bool>.from(widget.preparedSpells);
  }

  @override
  Widget build(BuildContext context) {
    var spell = widget.spells[widget.spellSlug] as Map<String, dynamic>?;
    spell ??= context.read<RulesCubit>().getAllSpells()[widget.spellSlug]
            as Map<String, dynamic>? ??
        {};
    if (spell.isEmpty) {
      return Container();
    }

    return AlertDialog(
      title: Text(spell['name']?.toString() ?? ''),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 700,
          ),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        spell['level']?.toString() ?? '',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        spell['school']?.toString() ?? '',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (spell['document__title']?.toString() != null)
                    Text(
                      spell['document__title']?.toString() ?? '',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
              const SizedBox(
                height: 24,
                child: Divider(),
              ),
              DescriptionText(
                inputText: spell['desc']?.toString() ?? '',
                baseStyle: Theme.of(context).textTheme.bodyMedium!,
              ),
              const SizedBox(
                height: 24,
                child: Divider(),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    if (spell['concentration'] != null &&
                        spell['concentration'] == 'yes')
                      Text(
                        'Concentration',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    if (spell['ritual'] != null && spell['ritual'] == 'yes')
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Text(
                          'Ritual',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  spacing: 16,
                  children: [
                    if (spell['range'] != null &&
                        (spell['range'] as String).isNotEmpty)
                      Flex(
                        mainAxisSize: MainAxisSize.min,
                        direction: Axis.horizontal,
                        children: [
                          Text(
                            'Range: ',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(spell['range']?.toString() ?? ''),
                        ],
                      ),
                    if (spell['components'] != null &&
                        (spell['components'] as String).isNotEmpty)
                      Flex(
                        mainAxisSize: MainAxisSize.min,
                        direction: Axis.horizontal,
                        children: [
                          Text(
                            'Components: ',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(spell['components']?.toString() ?? ''),
                        ],
                      ),
                    if (spell['duration'] != null &&
                        (spell['duration'] as String).isNotEmpty)
                      Flex(
                        mainAxisSize: MainAxisSize.min,
                        direction: Axis.horizontal,
                        children: [
                          Text(
                            'Duration: ',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(spell['duration']?.toString() ?? ''),
                        ],
                      ),
                    if (spell['casting_time'] != null &&
                        (spell['casting_time'] as String).isNotEmpty)
                      Flex(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        direction: Axis.horizontal,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Text(
                              'Casting Time: ',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Flexible(
                            child: Text(
                              spell['casting_time']?.toString() ?? '',
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(isLearned ? 'Learned' : 'Unlearned'),
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: Switch(
                        value: isLearned,
                        onChanged: (value) {
                          setState(() {
                            isLearned = value;
                            if (value) {
                              widget.knownSpells.add(widget.spellSlug);
                              widget.preparedSpells
                                  .putIfAbsent(widget.spellSlug, () => true);
                            } else {
                              widget.knownSpells.remove(widget.spellSlug);
                              widget.preparedSpells.remove(widget.spellSlug);
                            }
                            widget.updateCharacter();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                if (isLearned)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Text('Prepared'),
                      Checkbox(
                        value: preparedSpells[widget.spellSlug] ?? false,
                        onChanged: (value) {
                          setState(() {
                            preparedSpells[widget.spellSlug] = value!;
                            widget.updateCharacter();
                          });
                        },
                      ),
                    ],
                  ),
              ],
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Icon(Icons.done),
            ),
          ],
        ),
      ],
    );
  }
}
