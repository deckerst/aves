import 'package:aves/theme/durations.dart';
import 'package:aves/utils/constants.dart';
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
        border: Border.fromBorderSide(BorderSide(
          color: color,
          width: AvesFilterChip.outlineWidth,
        )),
        shape: BoxShape.circle,
      ),
      duration: Durations.themeColorModeAnimation,
      child: DecoratedIcon(
        icon,
        shadows: Theme.of(context).brightness == Brightness.dark ? Constants.embossShadows : null,
        size: 18,
      ),
    );
  }
}
