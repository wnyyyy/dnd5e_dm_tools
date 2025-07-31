import 'dart:async';
import 'dart:math';

import 'package:dnd5e_dm_tools/core/data/models/backpack.dart';
import 'package:dnd5e_dm_tools/core/data/models/character.dart';
import 'package:dnd5e_dm_tools/core/util/enum.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character/character_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character/character_state.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/equipment/equipment_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/equipment/equipment_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:google_fonts/google_fonts.dart';

class CoinsWidget extends StatelessWidget {
  const CoinsWidget({super.key, required this.onBackpackUpdated});

  final ValueChanged<Backpack> onBackpackUpdated;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EquipmentBloc>().state;
    final charState = context.watch<CharacterBloc>().state;
    if (state is! EquipmentLoaded || charState is! CharacterLoaded) {
      return const SizedBox.shrink();
    }
    final Backpack backpack = state.backpack;
    return GestureDetector(
      onLongPress: () => _showCoinEdit(context, charState.character, backpack),
      child: ListTile(
        title: Text('Coins', style: Theme.of(context).textTheme.titleLarge),
        isThreeLine: true,
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    fontFamily: GoogleFonts.robotoMono().fontFamily,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    WidgetSpan(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(
                          FontAwesome5.coins,
                          color: CoinType.copper.color,
                          size: 15,
                        ),
                      ),
                    ),
                    const TextSpan(text: 'CP:'),
                    TextSpan(
                      text: ' ${backpack.copper}\n',
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        fontFamily: GoogleFonts.roboto().fontFamily,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    WidgetSpan(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(
                          FontAwesome5.coins,
                          color: CoinType.silver.color,
                          size: 15,
                        ),
                      ),
                    ),
                    const TextSpan(text: 'SP:'),
                    TextSpan(
                      text: ' ${backpack.silver}\n',
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        fontFamily: GoogleFonts.roboto().fontFamily,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    WidgetSpan(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(
                          FontAwesome5.coins,
                          color: CoinType.gold.color,
                          size: 15,
                        ),
                      ),
                    ),
                    const TextSpan(text: 'GP:'),
                    TextSpan(
                      text: ' ${backpack.gold}',
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        fontFamily: GoogleFonts.roboto().fontFamily,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Text('100 CP\n10 SP\n1 GP', textAlign: TextAlign.end),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showCoinEdit(
    BuildContext context,
    Character character,
    Backpack backpack,
  ) {
    int cp = backpack.copper;
    int sp = backpack.silver;
    int gp = backpack.gold;
    final Map<String, Timer?> timers = {'cp': null, 'sp': null, 'gp': null};

    void updateCoins(String type, int value) {
      switch (type) {
        case 'cp':
          cp = max(0, value);
        case 'sp':
          sp = max(0, value);
        case 'gp':
          gp = max(0, value);
      }
    }

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Coins'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: ['cp', 'sp', 'gp'].map((type) {
                  final int coinValue = type == 'cp'
                      ? cp
                      : type == 'sp'
                      ? sp
                      : gp;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      GestureDetector(
                        child: const Icon(Icons.remove_circle_outline),
                        onTap: () =>
                            setState(() => updateCoins(type, coinValue - 1)),
                        onLongPressStart: (details) {
                          timers[type] = Timer.periodic(
                            const Duration(milliseconds: 35),
                            (t) {
                              final int currentCoinValue = type == 'cp'
                                  ? cp
                                  : type == 'sp'
                                  ? sp
                                  : gp;
                              setState(
                                () => updateCoins(type, currentCoinValue - 1),
                              );
                            },
                          );
                        },
                        onLongPressEnd: (details) {
                          timers[type]?.cancel();
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              FontAwesome5.coins,
                              color: type == 'cp'
                                  ? CoinType.copper.color
                                  : type == 'sp'
                                  ? CoinType.silver.color
                                  : CoinType.gold.color,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 75,
                              child: TextField(
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                                controller:
                                    TextEditingController(
                                        text: coinValue.toString(),
                                      )
                                      ..selection = TextSelection.collapsed(
                                        offset: coinValue.toString().length,
                                      ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  final int newQuantity =
                                      int.tryParse(value) ?? coinValue;
                                  setState(
                                    () => updateCoins(type, newQuantity),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        child: const Icon(Icons.add_circle_outline),
                        onTap: () =>
                            setState(() => updateCoins(type, coinValue + 1)),
                        onLongPressStart: (details) {
                          timers[type] = Timer.periodic(
                            const Duration(milliseconds: 35),
                            (t) {
                              final int currentCoinValue = type == 'cp'
                                  ? cp
                                  : type == 'sp'
                                  ? sp
                                  : gp;
                              setState(
                                () => updateCoins(type, currentCoinValue + 1),
                              );
                            },
                          );
                        },
                        onLongPressEnd: (details) {
                          timers[type]?.cancel();
                        },
                      ),
                    ],
                  );
                }).toList(),
              ),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: <Widget>[
                TextButton(
                  child: const Icon(Icons.close),
                  onPressed: () {
                    for (final timer in timers.values) {
                      timer?.cancel();
                    }
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: const Icon(Icons.done),
                  onPressed: () {
                    for (final timer in timers.values) {
                      timer?.cancel();
                    }
                    final updatedBackpack = backpack.copyWith(
                      copper: cp,
                      silver: sp,
                      gold: gp,
                    );
                    onBackpackUpdated(updatedBackpack);
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
