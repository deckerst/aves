import 'dart:ui';

import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/model/source/events.dart';
import 'package:aves/model/source/source_state.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/material.dart';

class SourceStateAwareAppBarTitle extends StatelessWidget {
  final Widget title;
  final CollectionSource source;

  const SourceStateAwareAppBarTitle({
    Key? key,
    required this.title,
    required this.source,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title,
        ValueListenableBuilder<SourceState>(
          valueListenable: source.stateNotifier,
          builder: (context, sourceState, child) {
            return AnimatedSwitcher(
              duration: Durations.appBarTitleAnimation,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SizeTransition(
                  sizeFactor: animation,
                  child: child,
                ),
              ),
              child: sourceState == SourceState.ready
                  ? const SizedBox.shrink()
                  : SourceStateSubtitle(
                      source: source,
                    ),
            );
          },
        ),
      ],
    );
  }
}

class SourceStateSubtitle extends StatelessWidget {
  final CollectionSource source;

  const SourceStateSubtitle({
    Key? key,
    required this.source,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sourceState = source.stateNotifier.value;
    final subtitle = sourceState.getName(context.l10n);
    if (subtitle == null) return const SizedBox();

    final theme = Theme.of(context);
    return DefaultTextStyle.merge(
      style: theme.textTheme.caption!.copyWith(fontFeatures: const [FontFeature.disable('smcp')]),
      child: ValueListenableBuilder<ProgressEvent>(
        valueListenable: source.progressNotifier,
        builder: (context, progress, snapshot) {
          return Text.rich(
            TextSpan(
              children: [
                TextSpan(text: subtitle),
                if (progress.total != 0 && sourceState != SourceState.locatingCountries) ...[
                  const WidgetSpan(child: SizedBox(width: 8)),
                  TextSpan(
                    text: '${progress.done}/${progress.total}',
                    style: TextStyle(color: theme.brightness == Brightness.dark ? Colors.white30 : Colors.black26),
                  ),
                ]
              ],
            ),
          );
        },
      ),
    );
  }
}
