import 'dart:async';
import 'dart:math';

import 'package:dnd5e_dm_tools/core/config/app_colors.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_events.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:google_fonts/google_fonts.dart';

class CoinsWidget extends StatelessWidget {
  final Map<String, dynamic> character;
  final String slug;

  const CoinsWidget({super.key, required this.character, required this.slug});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> backpack =
        Map<String, dynamic>.from(character['backpack'] ?? {});
    return GestureDetector(
      onLongPress: () => _showCoinEdit(context),
      child: ListTile(
        title: Text(
          'Coins',
          style: Theme.of(context).textTheme.titleLarge,
        ),
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
                        child: Icon(FontAwesome5.coins,
                            color: Theme.of(context).copperColor, size: 15),
                      ),
                    ),
                    const TextSpan(text: 'CP:'),
                    TextSpan(
                        text: ' ${backpack['cp'] ?? 0}\n',
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(
                              fontFamily: GoogleFonts.roboto().fontFamily,
                              fontWeight: FontWeight.bold,
                            )),
                    WidgetSpan(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(FontAwesome5.coins,
                            color: Theme.of(context).silverColor, size: 15),
                      ),
                    ),
                    const TextSpan(text: 'SP:'),
                    TextSpan(
                        text: ' ${backpack['sp'] ?? 0}\n',
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(
                              fontFamily: GoogleFonts.roboto().fontFamily,
                              fontWeight: FontWeight.bold,
                            )),
                    WidgetSpan(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(FontAwesome5.coins,
                            color: Theme.of(context).goldColor, size: 15),
                      ),
                    ),
                    const TextSpan(text: 'GP:'),
                    TextSpan(
                        text: ' ${backpack['gp'] ?? 0}',
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(
                              fontFamily: GoogleFonts.roboto().fontFamily,
                              fontWeight: FontWeight.bold,
                            )),
                  ],
                ),
              ),
              const Text(
                '100 CP\n10 SP\n1 GP',
                textAlign: TextAlign.end,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showCoinEdit(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        int cp = character['backpack']['cp'] ?? 0;
        int sp = character['backpack']['sp'] ?? 0;
        int gp = character['backpack']['gp'] ?? 0;
        Map<String, Timer?> timers = {'cp': null, 'sp': null, 'gp': null};

        void updateCoins(String type, int value) {
          switch (type) {
            case 'cp':
              cp = max(0, value);
              break;
            case 'sp':
              sp = max(0, value);
              break;
            case 'gp':
              gp = max(0, value);
              break;
          }
        }

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Coins'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: ['cp', 'sp', 'gp'].map((type) {
                  int coinValue = type == 'cp'
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
                              const Duration(milliseconds: 35), (t) {
                            int currentCoinValue = 0;
                            switch (type) {
                              case 'cp':
                                currentCoinValue = cp;
                                break;
                              case 'sp':
                                currentCoinValue = sp;
                                break;
                              case 'gp':
                                currentCoinValue = gp;
                                break;
                            }
                            setState(
                                () => updateCoins(type, currentCoinValue - 1));
                          });
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
                              type == 'cp'
                                  ? FontAwesome5.coins
                                  : type == 'sp'
                                      ? FontAwesome5.coins
                                      : FontAwesome5.coins,
                              color: type == 'cp'
                                  ? Theme.of(context).copperColor
                                  : type == 'sp'
                                      ? Theme.of(context).silverColor
                                      : Theme.of(context).goldColor,
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
                                controller: TextEditingController(
                                    text: coinValue.toString())
                                  ..selection = TextSelection.collapsed(
                                      offset: coinValue.toString().length),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  int newQuantity =
                                      int.tryParse(value) ?? coinValue;
                                  setState(
                                      () => updateCoins(type, newQuantity));
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
                              const Duration(milliseconds: 35), (t) {
                            int currentCoinValue = 0;
                            switch (type) {
                              case 'cp':
                                currentCoinValue = cp;
                                break;
                              case 'sp':
                                currentCoinValue = sp;
                                break;
                              case 'gp':
                                currentCoinValue = gp;
                                break;
                            }
                            setState(
                                () => updateCoins(type, currentCoinValue + 1));
                          });
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
                    for (var timer in timers.values) {
                      timer?.cancel();
                    }
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: const Icon(Icons.done),
                  onPressed: () {
                    for (var timer in timers.values) {
                      timer?.cancel();
                    }
                    character['backpack']['cp'] = cp;
                    character['backpack']['sp'] = sp;
                    character['backpack']['gp'] = gp;
                    context.read<CharacterBloc>().add(
                          CharacterUpdate(
                            character: character,
                            slug: slug,
                            persistData: true,
                            offline:
                                context.read<SettingsCubit>().state.offlineMode,
                          ),
                        );
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
