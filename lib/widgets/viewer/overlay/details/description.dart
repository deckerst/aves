import 'package:aves/theme/icons.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/viewer/overlay/details/details.dart';
import 'package:decorated_icon/decorated_icon.dart';
import 'package:flutter/material.dart';

class OverlayDescriptionRow extends StatelessWidget {
  final String description;

  const OverlayDescriptionRow({
    super.key,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(end: ViewerDetailOverlayContent.iconPadding),
              child: DecoratedIcon(
                AIcons.description,
                size: ViewerDetailOverlayContent.iconSize,
                shadows: ViewerDetailOverlayContent.shadows(context),
              ),
            ),
          ),
          TextSpan(text: description),
        ],
      ),
      strutStyle: Constants.overflowStrutStyle,
    );
  }
}
