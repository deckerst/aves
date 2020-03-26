import 'package:aves/model/collection_filters.dart';
import 'package:aves/utils/color_utils.dart';
import 'package:flutter/material.dart';

typedef FilterCallback = void Function(CollectionFilter filter);

class AvesFilterChip extends StatelessWidget {
  final CollectionFilter filter;
  final FilterCallback onPressed;

  String get label => filter.label;

  static const double buttonBorderWidth = 2;
  static const double maxChipWidth = 160;

  const AvesFilterChip(
    this.filter, {
    @required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final icon = filter.iconBuilder(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: maxChipWidth),
      child: Tooltip(
        message: label,
        child: OutlineButton(
          onPressed: onPressed != null ? () => onPressed(filter) : null,
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
                icon,
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
