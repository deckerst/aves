import 'package:aves/locale/number.dart';
import 'package:aves/theme/themes.dart';
import 'package:aves/widgets/common/basic/text/outlined.dart';
import 'package:aves/widgets/common/extensions/theme.dart';
import 'package:aves/widgets/common/grid/sections/section_layout_builder.dart';
import 'package:aves/widgets/common/thumbnail/decorated.dart';
import 'package:material_ui/material_ui.dart';

class const DayTile<T>({
  super.key,
  required final DateTime dayToBuild,
  required final double tileWidth,
  required final T? dayItem,
  required final TileBuilder<T> tileBuilder,
  required final ANumberFormat numberFormat,
}) extends StatelessWidget {
  static List<Shadow> shadows(BuildContext context) => [
    Shadow(
      color: Theme.of(context).isDark ? Colors.black : Colors.white,
      offset: const Offset(0, 1),
      blurRadius: 2,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final _item = dayItem;
    return Stack(
      children: [
        _item != null
            ? tileBuilder(_item, Size.square(tileWidth))
            : Container(
                color: Themes.secondLayerColor(context),
              ),
        IgnorePointer(
          child: Container(
            alignment: .topStart,
            padding: EdgeInsets.symmetric(horizontal: tileWidth / 25),
            foregroundDecoration: tileDecoration(context),
            child: OutlinedText(
              textSpans: [
                TextSpan(
                  text: numberFormat.format(dayToBuild.day),
                  style: TextStyle(
                    shadows: shadows(context),
                  ),
                ),
              ],
              outlineColor: Themes.firstLayerColor(context),
            ),
          ),
        ),
      ],
    );
  }

  static Decoration tileDecoration(BuildContext context) {
    return BoxDecoration(
      border: Border.fromBorderSide(
        BorderSide(
          color: DecoratedThumbnail.borderColor(context),
          width: DecoratedThumbnail.borderWidth(context),
        ),
      ),
    );
  }
}
