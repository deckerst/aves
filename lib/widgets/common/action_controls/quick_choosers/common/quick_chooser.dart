import 'package:aves/theme/themes.dart';
import 'package:aves/widgets/common/fx/blurred.dart';
import 'package:aves/widgets/common/fx/borders.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:material_ui/material_ui.dart';

class const QuickChooser({
  super.key,
  required final bool blurred,
  required final Widget child,
}) extends StatelessWidget {
  static const margin = EdgeInsets.all(8);
  static const padding = EdgeInsets.symmetric(horizontal: 8);

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final backgroundColor = blurred ? Themes.overlayBackgroundColor(brightness: brightness, blurred: blurred) : null;
    const borderRadius = BorderRadius.all(AvesDialog.cornerRadius);
    return Padding(
      padding: margin,
      child: BlurredRRect(
        enabled: blurred,
        borderRadius: borderRadius,
        child: Material(
          borderRadius: borderRadius,
          color: backgroundColor,
          child: Ink(
            decoration: BoxDecoration(
              border: AvesBorder.border(context),
              borderRadius: borderRadius,
            ),
            child: Padding(
              padding: padding,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
