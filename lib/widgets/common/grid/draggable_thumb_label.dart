import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/grid/section_layout.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DraggableThumbLabel<T> extends StatelessWidget {
  final double offsetY;
  final List<String> Function(BuildContext context, T item) lineBuilder;

  const DraggableThumbLabel({
    required this.offsetY,
    required this.lineBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final sll = context.read<SectionedListLayout<T>>();
    final sectionLayout = sll.getSectionAt(offsetY);
    if (sectionLayout == null) return const SizedBox();

    final section = sll.sections[sectionLayout.sectionKey]!;
    final dy = offsetY - (sectionLayout.minOffset + sectionLayout.headerExtent);
    final itemIndex = dy < 0 ? 0 : (dy ~/ (sll.tileExtent + sll.spacing)) * sll.columnCount;
    final item = section[itemIndex];

    final lines = lineBuilder(context, item);
    if (lines.isEmpty) return const SizedBox();

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 140),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: lines.length > 1
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: lines.map(_buildText).toList(),
              )
            : _buildText(lines.first),
      ),
    );
  }

  Widget _buildText(String text) => Text(
        text,
        style: const TextStyle(
          color: Colors.black,
        ),
        softWrap: false,
        overflow: TextOverflow.fade,
        maxLines: 1,
      );

  static String formatMonthThumbLabel(BuildContext context, DateTime? date) {
    final l10n = context.l10n;
    if (date == null) return l10n.sectionUnknown;
    return DateFormat.yMMM(l10n.localeName).format(date);
  }

  static String formatDayThumbLabel(BuildContext context, DateTime? date) {
    final l10n = context.l10n;
    if (date == null) return l10n.sectionUnknown;
    return DateFormat.yMMMd(l10n.localeName).format(date);
  }
}
