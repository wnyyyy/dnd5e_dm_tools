import 'package:flutter/material.dart';

class TraitDescription extends StatelessWidget {
  final String inputText;

  const TraitDescription({super.key, required this.inputText});

  @override
  Widget build(BuildContext context) {
    List<TextSpan> spans = [];
    final parts = inputText.split('***');

    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isEmpty) continue;

      if (i % 2 != 0) {
        spans.add(TextSpan(
          text: parts[i],
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ));
      } else {
        spans.add(TextSpan(
          text: parts[i],
          style: Theme.of(context).textTheme.bodyMedium,
        ));
      }
    }
    return RichText(
      text: TextSpan(
        children: spans,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
