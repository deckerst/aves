import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:decorated_icon/decorated_icon.dart';
import 'package:flutter/material.dart';

class SettingsTileLeading extends StatelessWidget {
  final IconData icon;
  final Color color;

  const SettingsTileLeading({
    Key? key,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        border: Border.fromBorderSide(BorderSide(
          color: color,
          width: AvesFilterChip.outlineWidth,
        )),
        shape: BoxShape.circle,
      ),
      child: DecoratedIcon(
        icon,
        shadows: Constants.embossShadows,
        size: 18,
      ),
    );
  }
}
