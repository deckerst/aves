import 'package:aves/model/filters/filters.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

typedef FilterCallback = void Function(CollectionFilter filter);

class AvesFilterChip extends StatefulWidget {
  final CollectionFilter filter;
  final bool removable;
  final FilterCallback onPressed;

  static const double buttonBorderWidth = 2;
  static const double maxChipWidth = 160;
  static const double iconSize = 20;
  static const double padding = 6;

  const AvesFilterChip({
    Key key,
    this.filter,
    this.removable = false,
    @required this.onPressed,
  }) : super(key: key);

  @override
  _AvesFilterChipState createState() => _AvesFilterChipState();
}

class _AvesFilterChipState extends State<AvesFilterChip> {
  Future<Color> _colorFuture;

  CollectionFilter get filter => widget.filter;

  @override
  void initState() {
    super.initState();
    _initColorLoader();
  }

  @override
  void didUpdateWidget(AvesFilterChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filter != filter) {
      _initColorLoader();
    }
  }

  void _initColorLoader() => _colorFuture = filter.color(context);

  @override
  Widget build(BuildContext context) {
    final leading = filter.iconBuilder(context, AvesFilterChip.iconSize);
    final trailing = widget.removable ? Icon(OMIcons.clear, size: AvesFilterChip.iconSize) : null;

    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leading != null) ...[
          leading,
          const SizedBox(width: AvesFilterChip.padding * 1.6),
        ],
        Flexible(
          child: Text(
            filter.label,
            softWrap: false,
            overflow: TextOverflow.fade,
            maxLines: 1,
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AvesFilterChip.padding),
          trailing,
        ],
      ],
    );

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(42),
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: AvesFilterChip.maxChipWidth),
      child: Tooltip(
        message: filter.tooltip,
        child: FutureBuilder(
          future: _colorFuture,
          builder: (context, AsyncSnapshot<Color> snapshot) {
            return OutlineButton(
              onPressed: widget.onPressed != null ? () => widget.onPressed(filter) : null,
              borderSide: BorderSide(
                color: snapshot.hasData ? snapshot.data : Colors.transparent,
                width: AvesFilterChip.buttonBorderWidth,
              ),
              padding: const EdgeInsets.symmetric(horizontal: AvesFilterChip.padding * 2),
              shape: shape,
              child: child,
            );
          },
        ),
      ),
    );
  }
}
