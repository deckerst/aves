import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/enums.dart';
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
                  ? SizedBox.shrink()
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

  const SourceStateSubtitle({required this.source});

  @override
  Widget build(BuildContext context) {
    String? subtitle;
    switch (source.stateNotifier.value) {
      case SourceState.loading:
        subtitle = context.l10n.sourceStateLoading;
        break;
      case SourceState.cataloguing:
        subtitle = context.l10n.sourceStateCataloguing;
        break;
      case SourceState.locating:
        subtitle = context.l10n.sourceStateLocating;
        break;
      case SourceState.ready:
      default:
        break;
    }
    final subtitleStyle = Theme.of(context).textTheme.caption;
    return subtitle == null
        ? SizedBox.shrink()
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(subtitle, style: subtitleStyle),
              StreamBuilder<ProgressEvent>(
                stream: source.progressStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError || !snapshot.hasData) return SizedBox.shrink();
                  final progress = snapshot.data!;
                  return Padding(
                    padding: EdgeInsetsDirectional.only(start: 8),
                    child: Text(
                      '${progress.done}/${progress.total}',
                      style: subtitleStyle!.copyWith(color: Colors.white30),
                    ),
                  );
                },
              ),
            ],
          );
  }
}
