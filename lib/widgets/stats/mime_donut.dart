import 'package:aves/model/filters/mime.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/utils/mime_utils.dart';
import 'package:aves/widgets/common/identity/aves_donut.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class const MimeDonut({
  super.key,
  required final IconData icon,
  required final Map<String, int> byMimeTypes,
  required final Duration animationDuration,
  required final AFilterCallback onFilterSelection,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final itemCountFormatter = settings.avesLocale.decimalNumberFormat();

    String formatKey(AvesDonutDatum d) => MimeUtils.displayType(d.key);
    return AvesDonut(
      title: Icon(icon),
      byTypes: byMimeTypes,
      animationDuration: animationDuration,
      formatKey: formatKey,
      formatValue: itemCountFormatter.format,
      colorize: (context, d) {
        final colors = context.read<AvesColorsData>();
        return colors.fromString(formatKey(d));
      },
      onTap: (d) => onFilterSelection(MimeFilter(d.key)),
    );
  }
}
