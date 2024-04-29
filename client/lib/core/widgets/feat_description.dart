import 'package:flutter/material.dart';

class FeatDescription extends StatelessWidget {
  final String inputText;
  final List<String> effectsDesc;

  FeatDescription({
    super.key,
    required this.inputText,
    required this.effectsDesc,
  });

  @override
  Widget build(BuildContext context) {
    List<TextSpan> spans = [];
    spans.add(TextSpan(
      text: inputText,
      style: Theme.of(context).textTheme.bodyMedium,
    ));

    for (int i = 0; i < effectsDesc.length; i++) {
      spans.add(TextSpan(
        text: '▪ ${effectsDesc[i]}',
        style: Theme.of(context).textTheme.bodyMedium,
      ));
    }
    return RichText(
      text: TextSpan(
        children: spans,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
