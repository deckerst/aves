import 'package:aves/widgets/common/basic/list_tiles/reselectable_radio.dart';
import 'package:aves/widgets/common/basic/text/fading_line.dart';
import 'package:aves/widgets/dialogs/selection_dialogs/common.dart';
import 'package:material_ui/material_ui.dart';

class const SelectionRadioListTile<T>({
  super.key,
  required final T value,
  final Widget? leading,
  required final String title,
  final IconBuilder<T>? optionIconBuilder,
  final TextBuilder<T>? optionSubtitleBuilder,
  final bool? dense,
  final Widget? secondary,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final icon = optionIconBuilder?.call(value);
    final subtitle = optionSubtitleBuilder?.call(value);
    return ReselectableRadioListTile<T>(
      // key is expected by test driver
      key: Key('$value'),
      value: value,
      reselectable: true,
      title: Row(
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 12),
              child: Icon(icon),
            ),
          Expanded(
            child: Text(
              title,
              overflow: .ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
      subtitle: subtitle != null ? FadingLine(subtitle) : null,
      dense: dense,
      secondary: secondary,
    );
  }
}
