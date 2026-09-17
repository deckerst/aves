import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/common/basic/color_indicator.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/settings/common/tiles.dart';
import 'package:flex_color_picker/flex_color_picker.dart' show ColorPicker, ColorPickerType;
import 'package:material_ui/material_ui.dart';

class const ColorListTile({
  super.key,
  required final TitleBuilder title,
  required final Color value,
  required final ValueSetter<Color> onChanged,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title(context) ?? '?'),
      trailing: ColorIndicator(
        value: value,
      ),
      contentPadding: const EdgeInsetsDirectional.only(start: 16, end: 36 - ColorIndicator.radius),
      onTap: () async {
        final color = await showAvesDialog<Color>(
          context: context,
          builder: (context) => ColorPickerDialog(
            initialValue: value,
          ),
          routeSettings: const RouteSettings(name: ColorPickerDialog.routeName),
        );
        if (color != null) {
          onChanged(color);
        }
      },
    );
  }
}

class const ColorPickerDialog({
  super.key,
  required final Color initialValue,
}) extends StatefulWidget {
  static const routeName = '/dialog/pick_color';

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late Color color;

  @override
  void initState() {
    super.initState();
    color = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    final useTvLayout = settings.useTvLayout;
    return AvesDialog(
      scrollableContent: [
        ColorPicker(
          color: color,
          onColorChanged: (v) => color = v,
          pickersEnabled: useTvLayout
              ? const {
                  ColorPickerType.primary: true,
                  ColorPickerType.accent: false,
                }
              : const {
                  ColorPickerType.primary: false,
                  ColorPickerType.accent: false,
                  ColorPickerType.wheel: true,
                },
          hasBorder: true,
          borderRadius: 20,
          subheading: useTvLayout ? const SizedBox(height: 16) : null,
        ),
      ],
      actions: [
        const CancelButton(),
        TextButton(
          onPressed: () => Navigator.maybeOf(context)?.pop<Color>(color),
          child: Text(context.l10n.applyButtonLabel),
        ),
      ],
    );
  }
}
