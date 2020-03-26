import 'package:aves/model/collection_filters.dart';
import 'package:aves/utils/color_utils.dart';
import 'package:flutter/material.dart';

typedef FilterCallback = void Function(CollectionFilter filter);

class AvesFilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const AvesFilterChip({
    this.icon,
    @required this.label,
    @required this.onPressed,
  });

  factory AvesFilterChip.fromFilter(
    CollectionFilter filter, {
    @required FilterCallback onPressed,
  }) =>
      AvesFilterChip(
        icon: filter.icon,
        label: filter.label,
        onPressed: onPressed != null ? () => onPressed(filter) : null,
      );

  static const double buttonBorderWidth = 2;
  static const double maxChipWidth = 160;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: maxChipWidth),
      child: Tooltip(
        message: label,
        child: OutlineButton(
          onPressed: onPressed,
          borderSide: BorderSide(
            color: stringToColor(label),
            width: buttonBorderWidth,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(42),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
