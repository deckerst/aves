import 'package:aves/locale/aves_locale.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/grid/sections/list_layout.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class DraggableCrumbLabel extends StatelessWidget {
  final String label;

  const new({
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

  const new({
    super.key,
    required this.offsetY,
    required this.lineBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final sll = context.read<SectionedListLayout<T>>();
    final sectionLayout = sll.getSectionAt(offsetY);
    if (sectionLayout == null) return const SizedBox();

    final item = sll.getItemAt(Offset(0, offsetY)) ?? sll.sections[sectionLayout.sectionKey]!.first;

    final lines = lineBuilder(context, item);
    if (lines.isEmpty) return const SizedBox();

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _thumbLabelMaxWidth),
      child: Padding(
        padding: _padding,
        child: lines.length > 1
            ? Column(
                mainAxisSize: .min,
                crossAxisAlignment: .end,
                children: lines.map((v) => _buildText(v, isCrumb: false)).toList(),
              )
            : _buildText(lines.first, isCrumb: false),
      ),
    );
  }

  static String formatMonthThumbLabel(BuildContext context, AvesLocale locale, DateTime? date) {
    if (date == null) return context.l10n.sectionUnknown;
    return locale.yMMM(date);
  }

  static String formatDayThumbLabel(BuildContext context, AvesLocale locale, DateTime? date) {
    if (date == null) return context.l10n.sectionUnknown;
    return locale.yMMMd(date);
  }
}

const double _crumbLabelMaxWidth = 96;
const double _thumbLabelMaxWidth = 144;
const EdgeInsets _padding = .symmetric(vertical: 4, horizontal: 8);

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
