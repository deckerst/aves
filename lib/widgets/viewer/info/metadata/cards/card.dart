import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/basic/multi_cross_fader.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/highlight_title.dart';
import 'package:aves/widgets/settings/language/locales.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:material_ui/material_ui.dart';

class const MetadataCard({
  super.key,
  required final String title,
  required final int count,
  required final InfoRowGroup Function(int? index) indexedInfoGroupBuilder,
  required final List<Widget> Function(int? index) subCardsBuilder,
}) extends StatefulWidget {
  @override
  State<MetadataCard> createState() => _MetadataCardState();
}

class _MetadataCardState extends State<MetadataCard> {
  final ValueNotifier<int> _indexNotifier = ValueNotifier(0);

  int get count => widget.count;

  @override
  void initState() {
    super.initState();
    _indexNotifier.value = count - 1;
  }

  @override
  void didUpdateWidget(covariant MetadataCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.count != oldWidget.count) {
      _indexNotifier.value = count - 1;
    }
  }

  @override
  void dispose() {
    _indexNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isIndexed = count > 0;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
      child: ValueListenableBuilder<int>(
        valueListenable: _indexNotifier,
        builder: (context, index, child) {
          return Column(
            crossAxisAlignment: .start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 8, right: 8),
                child: Row(
                  crossAxisAlignment: .center,
                  children: [
                    Expanded(
                      child: HighlightTitle(
                        title: widget.title,
                        locale: KnownLocale.english,
                        showHighlight: false,
                      ),
                    ),
                    if (isIndexed) ...[
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(AIcons.previous),
                        onPressed: index > 0 ? () => _setIndex(index - 1) : null,
                        tooltip: context.l10n.previousTooltip,
                      ),
                      HighlightTitle(
                        title: '${index + 1}',
                        locale: KnownLocale.english,
                        showHighlight: false,
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(AIcons.next),
                        onPressed: index < count - 1 ? () => _setIndex(index + 1) : null,
                        tooltip: context.l10n.nextTooltip,
                      ),
                    ],
                  ],
                ),
              ),
              MultiCrossFader(
                duration: ADurations.xmpStructArrayCardTransition,
                sizeCurve: Curves.easeOutBack,
                alignment: .topStart,
                child: Padding(
                  // add padding at this level (instead of the column level)
                  // so that the crossfader can animate the content size
                  // without clipping the text
                  padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                  child: widget.indexedInfoGroupBuilder(isIndexed ? index : null),
                ),
              ),
              ...widget.subCardsBuilder(isIndexed ? index : null),
            ],
          );
        },
      ),
    );
  }

  void _setIndex(int index) => _indexNotifier.value = index.clamp(0, count - 1);
}
