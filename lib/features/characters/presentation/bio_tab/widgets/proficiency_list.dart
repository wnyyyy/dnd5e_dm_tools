import 'package:dnd5e_dm_tools/core/data/models/character.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character/character_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character/character_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProficiencyList extends StatefulWidget {
  const ProficiencyList({super.key, required this.character});

  final Character character;

  @override
  State<ProficiencyList> createState() => _ProficiencyListState();
}

class _ProficiencyListState extends State<ProficiencyList> {
  bool _isEditMode = false;
  late TextEditingController _languagesController;
  late TextEditingController _weaponsController;
  late TextEditingController _armorController;
  late TextEditingController _toolsController;

  @override
  void initState() {
    super.initState();
    _languagesController = TextEditingController();
    _weaponsController = TextEditingController();
    _armorController = TextEditingController();
    _toolsController = TextEditingController();
    _resetFields();
  }

  @override
  void dispose() {
    _languagesController.dispose();
    _weaponsController.dispose();
    _armorController.dispose();
    _toolsController.dispose();
    super.dispose();
  }

  void _resetFields() {
    _languagesController.text = widget.character.proficiency.languages;
    _weaponsController.text = widget.character.proficiency.weapons;
    _armorController.text = widget.character.proficiency.armor;
    _toolsController.text = widget.character.proficiency.tools;
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildHeader(), _buildProfList()],
      ),
    );
  }

  Widget _buildProfList() {
    final profs = {
      'Languages': _languagesController,
      'Weapons': _weaponsController,
      'Armor': _armorController,
      'Tools': _toolsController,
    };
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: profs.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: entry.value,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: entry.key,
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      floatingLabelStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    minLines: 1,
                    maxLines: 5,
                    enabled: _isEditMode,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8, top: 8, right: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Proficiencies',
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
              Row(
                children: [
                  if (_isEditMode)
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _resetFields();
                          _isEditMode = false;
                        });
                      },
                      icon: const Icon(Icons.undo),
                    ),
                  IconButton(
                    onPressed: () {
                      if (_isEditMode) {
                        context.read<CharacterBloc>().add(
                          CharacterUpdate(
                            character: widget.character.copyWith(
                              proficiency: widget.character.proficiency
                                  .copyWith(
                                    languages: _languagesController.text.trim(),
                                    weapons: _weaponsController.text.trim(),
                                    armor: _armorController.text.trim(),
                                    tools: _toolsController.text.trim(),
                                  ),
                            ),
                            persistData: true,
                          ),
                        );
                      } else {
                        setState(() {
                          _resetFields();
                        });
                      }
                      setState(() {
                        _isEditMode = !_isEditMode;
                      });
                    },
                    icon: Icon(_isEditMode ? Icons.check : Icons.edit),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
