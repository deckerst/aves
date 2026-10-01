import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/common/basic/list_tiles/common.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_list_subtitle.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/dialogs/duration_dialog.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class const SettingsDurationListTile({
  super.key,
  required final int Function(BuildContext, Settings) selector,
  required final ValueChanged<int> onChanged,
  required final TitleBuilder title,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Selector<Settings, int>(
      selector: selector,
      builder: (context, current, child) {
        final currentMinutes = current ~/ Duration.secondsPerMinute;
        final currentSeconds = current % Duration.secondsPerMinute;

        final l10n = context.l10n;
        final subtitle = [
          if (currentMinutes > 0) l10n.timeMinutes(currentMinutes),
          if (currentSeconds > 0) l10n.timeSeconds(currentSeconds),
        ].join(' ');

        return ListTile(
          title: Text(title(context) ?? '?'),
          subtitle: AvesListSubtitle(subtitle),
          onTap: () async {
            final seconds = await showAvesDialog<int>(
              context: context,
              builder: (context) => DurationDialog(initialSeconds: current),
            );
            if (seconds != null) {
              onChanged(seconds);
            }
          },
        );
      },
    );
  }
}
