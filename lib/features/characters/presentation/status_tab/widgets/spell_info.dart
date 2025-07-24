import 'package:dnd5e_dm_tools/core/data/models/character.dart';
import 'package:dnd5e_dm_tools/core/data/models/spell.dart';
import 'package:dnd5e_dm_tools/core/util/enum.dart';
import 'package:dnd5e_dm_tools/core/widgets/description_text.dart';
import 'package:flutter/material.dart';

class SpellInfo extends StatefulWidget {
  const SpellInfo({
    super.key,
    required this.spell,
    required this.character,
    required this.classPreparesSpells,
    required this.onCharacterUpdated,
  });

  final Spell spell;
  final Character character;
  final bool classPreparesSpells;
  final ValueChanged<Character> onCharacterUpdated;

  @override
  State<SpellInfo> createState() => _SpellInfoState();
}

class _SpellInfoState extends State<SpellInfo> {
  late bool isLearned;
  late bool isPrepared;

  @override
  void initState() {
    super.initState();
    isLearned = widget.character.spellbook.knownSpells.contains(
      widget.spell.slug,
    );
    isPrepared =
        widget.character.spellbook.preparedSpells[widget.spell.slug] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.spell.name),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.spell.levelText,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        widget.spell.school.name,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: widget.spell.school.color,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 24, child: Divider()),
              DescriptionText(
                inputText: widget.spell.desc,
                baseStyle: Theme.of(context).textTheme.bodyMedium!,
              ),
              const SizedBox(height: 24, child: Divider()),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    if (widget.spell.concentration)
                      Text(
                        'Concentration',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (widget.spell.ritual)
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Text(
                          'Ritual',
                          style: Theme.of(context).textTheme.bodySmall!
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
                    if (widget.spell.range.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Range: ',
                            style: Theme.of(context).textTheme.bodySmall!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(widget.spell.range),
                        ],
                      ),
                    if (widget.spell.components.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Components: ',
                            style: Theme.of(context).textTheme.bodySmall!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          Flexible(
                            child: Text(
                              widget.spell.components,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2, // or more if needed
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    if (widget.spell.duration.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Duration: ',
                            style: Theme.of(context).textTheme.bodySmall!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(widget.spell.duration),
                        ],
                      ),
                    if (widget.spell.castingTime.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Casting Time: ',
                            style: Theme.of(context).textTheme.bodySmall!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(widget.spell.castingTime),
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
                              widget.character.spellbook.knownSpells.add(
                                widget.spell.slug,
                              );
                              widget.character.spellbook.preparedSpells
                                  .putIfAbsent(widget.spell.slug, () => true);
                            } else {
                              widget.character.spellbook.knownSpells.remove(
                                widget.spell.slug,
                              );
                              widget.character.spellbook.preparedSpells.remove(
                                widget.spell.slug,
                              );
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
                if (isLearned && widget.classPreparesSpells)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Text('Prepared'),
                      Checkbox(
                        value:
                            widget.character.spellbook.preparedSpells[widget
                                .spell
                                .slug] ??
                            false,
                        onChanged: (value) {
                          setState(() {
                            widget.character.spellbook.preparedSpells[widget
                                    .spell
                                    .slug] =
                                value ?? false;
                          });
                        },
                      ),
                    ],
                  ),
              ],
            ),
            TextButton(
              onPressed: () {
                final newKnownSpells = List<String>.from(
                  widget.character.spellbook.knownSpells,
                );
                final newPreparedSpells = Map<String, bool>.from(
                  widget.character.spellbook.preparedSpells,
                );
                final updatedCharacter = widget.character.copyWith(
                  spellbook: widget.character.spellbook.copyWith(
                    knownSpells: newKnownSpells,
                    preparedSpells: newPreparedSpells,
                  ),
                );
                widget.onCharacterUpdated(updatedCharacter);
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
