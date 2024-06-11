import 'package:aves/theme/durations.dart';
import 'package:aves/theme/styles.dart';
import 'package:aves/theme/themes.dart';
import 'package:aves/widgets/common/extensions/theme.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:decorated_icon/decorated_icon.dart';
import 'package:flutter/material.dart';

class SettingsTileLeading extends StatelessWidget {
  final IconData icon;
  final Color color;

  const SettingsTileLeading({
    super.key,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Themes.firstLayerColor(context),
        border: Border.fromBorderSide(BorderSide(
          color: color,
          width: AvesFilterChip.outlineWidth,
        )),
        shape: BoxShape.circle,
      ),
      duration: ADurations.themeColorModeAnimation,
      child: DecoratedIcon(
        icon,
        size: 18,
        color: DefaultTextStyle.of(context).style.color,
        shadows: Theme.of(context).isDark ? AStyles.embossShadows : null,
      ),
    );
  }
}
