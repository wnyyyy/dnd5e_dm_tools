import 'package:flutter/material.dart';

class FeatDescription extends StatelessWidget {
  final String inputText;
  final List<String> effectsDesc;

  FeatDescription({
    Key? key,
    required this.inputText,
    required this.effectsDesc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<TextSpan> spans = [];
    spans.add(TextSpan(
      text: '$inputText\n',
      style: Theme.of(context).textTheme.bodyMedium,
    ));

    for (int i = 0; i < effectsDesc.length; i++) {
      spans.add(TextSpan(
        text: '\n▪ ${effectsDesc[i]}${i == effectsDesc.length - 1 ? '' : '\n'}',
        style: Theme.of(context).textTheme.bodyMedium!,
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
