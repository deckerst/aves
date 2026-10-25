import 'package:aves/theme/colors.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/settings/common/tiles/switch_list.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class const SettingSwitchTrailingIcon({
  super.key,
  required final WidgetBuilder iconBuilder,
  required final bool disabled,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      // Switch width (`_kSwitchWidth`) + tile content padding
      padding: const EdgeInsetsDirectional.only(end: 59 + 16),
      child: Theme(
        data: theme.copyWith(
          iconTheme: theme.iconTheme.copyWith(
            size: getIconSize(context),
            color: getIconColor(context).withValues(alpha: disabled ? SettingsSwitchListTile.disabledOpacity : 1),
          ),
        ),
        child: AnimatedSwitcher(
          duration: context.read<DurationsData>().iconAnimation,
          child: Builder(
            key: key,
            builder: iconBuilder,
          ),
        ),
      ),
    );
  }

  static double getIconSize(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);
    return textScaler.scale(IconTheme.of(context).size!);
  }

  static Color getIconColor(BuildContext context) => context.select<AvesColorsData, Color>((v) => v.neutral);
}
