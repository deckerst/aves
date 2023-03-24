import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/styles.dart';
import 'package:flutter/material.dart';

class AboutSectionTitle extends StatelessWidget {
  final String text;

  const AboutSectionTitle({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    Widget child = Container(
      alignment: AlignmentDirectional.centerStart,
      constraints: const BoxConstraints(minHeight: kMinInteractiveDimension),
      child: Text(text, style: AStyles.knownTitleText),
    );

    if (settings.useTvLayout) {
      child = InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(123)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              child,
            ],
          ),
        ),
      );
    }
    return child;
  }
}
