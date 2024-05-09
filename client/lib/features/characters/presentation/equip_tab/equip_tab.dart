import 'package:dnd5e_dm_tools/features/characters/bloc/character_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_events.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/equip_tab/widgets/add_item.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/equip_tab/widgets/backpack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EquipTab extends StatelessWidget {
  final Map<String, dynamic> character;
  final String slug;

  const EquipTab({
    super.key,
    required this.character,
    required this.slug,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Flex(
        direction: Axis.vertical,
        children: [
          AddItemButton(
            onAdd: (itemSlug, isMagic) {
              if (!isMagic) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Quantity'),
                      content: Text('Add $itemSlug to backpack?'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        TextButton(
                          child: const Text('Add'),
                          onPressed: () {
                            character['backpack']['items'][itemSlug] = {
                              'quantity': 1,
                              'isEquipped': false,
                            };
                            context.read<CharacterBloc>().add(
                                  CharacterUpdate(
                                    character: character,
                                    slug: slug,
                                    persistData: true,
                                  ),
                                );
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    );
                  },
                );
              } else {
                character['backpack']['items'][itemSlug] = {
                  'quantity': 1,
                  'isEquipped': false,
                };
                context.read<CharacterBloc>().add(
                      CharacterUpdate(
                        character: character,
                        slug: slug,
                        persistData: true,
                      ),
                    );
                Navigator.pop(context);
              }
            },
          ),
          SizedBox(
              height: screenHeight * 0.6,
              child: BackpackWidget(
                character: character,
              )),
        ],
      ),
    );
  }
}
