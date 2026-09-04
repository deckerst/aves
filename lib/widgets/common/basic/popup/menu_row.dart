import 'package:material_ui/material_ui.dart';

class MenuRow extends StatelessWidget {
  final String text;
  final Widget? icon;

  const new({
    super.key,
    required this.text,
    this.icon,
  });

  static const leadingPadding = EdgeInsetsDirectional.only(end: 12);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: .min,
      children: [
        if (icon != null)
          Padding(
            padding: leadingPadding,
            child: IconTheme.merge(
              data: IconThemeData(
                color: ListTileTheme.of(context).iconColor,
              ),
              child: icon!,
            ),
          ),
        Flexible(
          child: Text(text),
        ),
      ],
    );
  }
}
