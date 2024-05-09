import 'dart:async';
import 'dart:math';

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
    if (character['backpack'] == null) {
      character['backpack'] = {
        'cp': 0,
        'sp': 0,
        'gp': 0,
        'items': Map<String, dynamic>.from({}),
      };
    }
    if (character['backpack']['items'] == null) {
      character['backpack']['items'] = Map<String, dynamic>.from({});
    }
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
                    int quantity = 1;
                    Timer? timer;

                    return StatefulBuilder(
                      builder: (context, setState) {
                        return AlertDialog(
                          title: const Text('Quantity'),
                          content: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              GestureDetector(
                                child: const Icon(Icons.remove_circle_outline),
                                onTap: () {
                                  if (quantity > 1) {
                                    setState(() => quantity--);
                                  }
                                },
                                onLongPressStart: (details) {
                                  timer = Timer.periodic(
                                      const Duration(milliseconds: 25), (t) {
                                    setState(() {
                                      quantity = max(1, quantity - 1);
                                    });
                                  });
                                },
                                onLongPressEnd: (details) {
                                  timer?.cancel();
                                },
                              ),
                              SizedBox(
                                width: 100,
                                child: TextField(
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                  controller: TextEditingController(
                                      text: quantity.toString())
                                    ..selection = TextSelection.collapsed(
                                        offset: quantity.toString().length),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    int newQuantity = int.tryParse(value) ?? 1;
                                    setState(
                                        () => quantity = max(1, newQuantity));
                                  },
                                ),
                              ),
                              GestureDetector(
                                child: const Icon(Icons.add_circle_outline),
                                onTap: () {
                                  setState(() => quantity++);
                                },
                                onLongPressStart: (details) {
                                  timer = Timer.periodic(
                                      const Duration(milliseconds: 50), (t) {
                                    setState(() {
                                      quantity++;
                                    });
                                  });
                                },
                                onLongPressEnd: (details) {
                                  timer?.cancel();
                                },
                              ),
                            ],
                          ),
                          actionsAlignment: MainAxisAlignment.spaceBetween,
                          actions: <Widget>[
                            TextButton(
                              child: const Icon(Icons.close),
                              onPressed: () {
                                timer?.cancel();
                                Navigator.pop(context);
                              },
                            ),
                            TextButton(
                              child: const Icon(Icons.done),
                              onPressed: () {
                                timer?.cancel();
                                character['backpack']['items'][itemSlug] = {
                                  'quantity': quantity,
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
              height: MediaQuery.of(context).size.height * 0.7 < 300
                  ? 500
                  : MediaQuery.of(context).size.height * 0.7,
              child: BackpackWidget(
                character: character,
                slug: slug,
              )),
        ],
      ),
    );
  }
}
