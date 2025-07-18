import 'package:flutter/material.dart';

class TraitDescription extends StatelessWidget {

  const TraitDescription({
    super.key,
    required this.inputText,
    this.separator = '***',
    this.boldify = true,
  });
  final String inputText;
  final String separator;
  final bool boldify;

  @override
  Widget build(BuildContext context) {
    final List<TextSpan> spans = [];
    final parts = inputText.split(separator);

    if (boldify) {
      for (int i = 0; i < parts.length; i++) {
        if (parts[i].isEmpty) continue;

        if (i % 2 != 0) {
          spans.add(TextSpan(
            text: '${i != 1 ? '\n' : ''}${parts[i]}',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),);
        } else {
          spans.add(TextSpan(
            text: '${parts[i]}\n',
            style: Theme.of(context).textTheme.bodyMedium,
          ),);
        }
      }
    } else {
      for (int i = 0; i < parts.length; i++) {
        if (parts[i].isEmpty) continue;

        spans.add(TextSpan(
          text: '${i != 1 ? '\n' : ''}${parts[i]}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),);
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
