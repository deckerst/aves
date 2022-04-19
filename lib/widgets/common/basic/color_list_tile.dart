import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/fx/borders.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';

class ColorListTile extends StatelessWidget {
  final String title;
  final Color value;
  final ValueSetter<Color> onChanged;

  static const double radius = 16.0;

  const ColorListTile({
    Key? key,
    required this.title,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: Container(
        height: radius * 2,
        width: radius * 2,
        decoration: BoxDecoration(
          color: value,
          border: AvesBorder.border(context),
          shape: BoxShape.circle,
        ),
      ),
      contentPadding: const EdgeInsetsDirectional.only(start: 16, end: 36 - radius),
      onTap: () async {
        final color = await showDialog<Color>(
          context: context,
          builder: (context) => ColorPickerDialog(
            initialValue: value,
          ),
        );
        if (color != null) {
          onChanged(color);
        }
      },
    );
  }
}

class ColorPickerDialog extends StatefulWidget {
  final Color initialValue;

  const ColorPickerDialog({
    Key? key,
    required this.initialValue,
  }) : super(key: key);

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
    return AvesDialog(
      scrollableContent: [
        ColorPicker(
          color: color,
          onColorChanged: (v) => color = v,
          pickersEnabled: const {
            ColorPickerType.primary: false,
            ColorPickerType.accent: false,
            ColorPickerType.wheel: true,
          },
          hasBorder: true,
          borderRadius: 20,
        )
      ],
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, color),
          child: Text(context.l10n.applyButtonLabel),
        ),
      ],
    );
  }
}
