import 'package:aves/model/filters/mime.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/utils/mime_utils.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_donut.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MimeDonut extends StatelessWidget {
  final IconData icon;
  final Map<String, int> byMimeTypes;
  final Duration animationDuration;
  final FilterCallback onFilterSelection;

  const MimeDonut({
    super.key,
    required this.icon,
    required this.byMimeTypes,
    required this.animationDuration,
    required this.onFilterSelection,
  });

  @override
  Widget build(BuildContext context) {
    final locale = context.l10n.localeName;
    final numberFormat = NumberFormat.decimalPattern(locale);

    String formatKey(d) => MimeUtils.displayType(d.key);
    return AvesDonut(
      title: Icon(icon),
      byTypes: byMimeTypes,
      animationDuration: animationDuration,
      formatKey: formatKey,
      formatValue: numberFormat.format,
      colorize: (context, d) {
        final colors = context.read<AvesColorsData>();
        return colors.fromString(formatKey(d));
      },
      onTap: (d) => onFilterSelection(MimeFilter(d.key)),
    );
  }
}
