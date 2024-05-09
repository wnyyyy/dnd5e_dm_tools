import 'package:dnd5e_dm_tools/features/rules/rules_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BackpackWidget extends StatelessWidget {
  final Map<String, dynamic> character;

  const BackpackWidget({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    final Map<String, Map> backpack =
        Map<String, Map>.from(character['backpack'] ?? {});
    final Map<String, Map> backpackItems =
        Map<String, Map>.from(backpack['items'] ?? {});
    final Map<String, Map> items = Map<String, Map>.from({});
    for (final backpackItem in backpackItems.entries) {
      final item = context.read<RulesCubit>().getItem(backpackItem.key);
      if (item != null) {
        items[backpackItem.key] = item;
      }
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          ListTile(
            title: const Text('Coins'),
            subtitle: Text(
                'CP: ${backpack['cp'] ?? 0}, SP: ${backpack['sp'] ?? 0}, GP: ${backpack['gp'] ?? 0}, 1 GP = 10 SP = 100 CP'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: backpackItems.length,
              itemBuilder: (context, index) {
                return Container();
              },
            ),
          ),
        ],
      ),
    );
  }
}
