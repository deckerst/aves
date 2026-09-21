import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/basic/text/icon_span.dart';
import 'package:aves/widgets/viewer/overlay/top/details/details.dart';
import 'package:material_ui/material_ui.dart';

class OverlayDescriptionRow extends StatelessWidget {
  final String description;

  const new({
    super.key,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          IconSpan(
            icon: AIcons.description,
            size: ViewerDetailOverlayContent.iconSize,
            shadows: ViewerDetailOverlayContent.shadows(context),
            padding: const EdgeInsetsDirectional.only(end: ViewerDetailOverlayContent.iconPadding),
          ),
          TextSpan(text: description),
        ],
      ),
    );
  }
}
