import 'package:aves/model/source/collection_source.dart';
import 'package:aves/utils/durations.dart';
import 'package:flutter/material.dart';

class SourceStateAwareAppBarTitle extends StatelessWidget {
  final Widget title;
  final CollectionSource source;

  const SourceStateAwareAppBarTitle({
    Key key,
    @required this.title,
    @required this.source,
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

  const SourceStateSubtitle({@required this.source});

  @override
  Widget build(BuildContext context) {
    String subtitle;
    switch (source.stateNotifier.value) {
      case SourceState.loading:
        subtitle = 'Loading';
        break;
      case SourceState.cataloguing:
        subtitle = 'Cataloguing';
        break;
      case SourceState.locating:
        subtitle = 'Locating';
        break;
      case SourceState.ready:
      default:
        break;
    }
    final subtitleStyle = Theme.of(context).textTheme.caption;
    return subtitle == null
        ? const SizedBox.shrink()
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(subtitle, style: subtitleStyle),
              StreamBuilder<ProgressEvent>(
                stream: source.progressStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError || !snapshot.hasData) return const SizedBox.shrink();
                  final progress = snapshot.data;
                  return Padding(
                    padding: const EdgeInsetsDirectional.only(start: 8),
                    child: Text(
                      '${progress.done}/${progress.total}',
                      style: subtitleStyle.copyWith(color: Colors.white30),
                    ),
                  );
                },
              ),
            ],
          );
  }
}
