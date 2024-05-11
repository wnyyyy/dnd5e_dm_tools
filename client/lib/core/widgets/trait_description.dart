import 'package:flutter/material.dart';

class TraitDescription extends StatelessWidget {
  final Map<String, dynamic> traits;

  const TraitDescription({
    super.key,
    required this.traits,
  });

  @override
  Widget build(BuildContext context) {
    List<Text> texts = [];

    for (final trait in traits.entries) {
      texts.add(
        Text(
          trait.key,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      );
      texts.add(
        Text(
          trait.value['description'],
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
      if (Map<String, dynamic>.from(trait.value).length > 1) {
        for (final subtrait in trait.value.entries) {
          if (subtrait.key == 'description') continue;
          texts.add(Text(
            '• ${subtrait.key}',
            style: Theme.of(context).textTheme.titleMedium,
          ));
          texts.add(Text(
            subtrait.value,
            style: Theme.of(context).textTheme.bodyMedium,
          ));
        }
      }
    }

    return Column(children: texts);
  }
}
