import 'package:aves/theme/format.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/grid/section_layout.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DraggableCrumbLabel extends StatelessWidget {
  final String label;

  const DraggableCrumbLabel({
    super.key,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _crumbLabelMaxWidth),
      child: Padding(
        padding: _padding,
        child: _buildText(label, isCrumb: true),
      ),
    );
  }
}

class DraggableThumbLabel<T> extends StatelessWidget {
  final double offsetY;
  final List<String> Function(BuildContext context, T item) lineBuilder;

  const DraggableThumbLabel({
    super.key,
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
    final itemIndex = dy < 0 ? 0 : (dy ~/ (sll.tileHeight + sll.spacing)) * sll.columnCount;
    final item = section[itemIndex];

    final lines = lineBuilder(context, item);
    if (lines.isEmpty) return const SizedBox();

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _thumbLabelMaxWidth),
      child: Padding(
        padding: _padding,
        child: lines.length > 1
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: lines.map((v) => _buildText(v, isCrumb: false)).toList(),
              )
            : _buildText(lines.first, isCrumb: false),
      ),
    );
  }

  static String formatMonthThumbLabel(BuildContext context, DateTime? date) {
    final l10n = context.l10n;
    if (date == null) return l10n.sectionUnknown;
    return DateFormat.yMMM(l10n.localeName).format(date);
  }

  static String formatDayThumbLabel(BuildContext context, DateTime? date) {
    final l10n = context.l10n;
    if (date == null) return l10n.sectionUnknown;
    return formatDay(date, l10n.localeName);
  }
}

const double _crumbLabelMaxWidth = 96;
const double _thumbLabelMaxWidth = 144;
const EdgeInsets _padding = EdgeInsets.symmetric(vertical: 4, horizontal: 8);

Widget _buildText(String text, {required bool isCrumb}) => Text(
      text,
      style: TextStyle(
        color: Colors.black,
        fontSize: isCrumb ? 10 : 14,
      ),
      softWrap: false,
      overflow: TextOverflow.fade,
      maxLines: 1,
    );
