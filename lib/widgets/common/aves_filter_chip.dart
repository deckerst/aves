import 'package:aves/model/filters/filters.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:flutter/material.dart';

typedef FilterCallback = void Function(CollectionFilter filter);

enum HeroType { always, onTap, never }

class AvesFilterChip extends StatefulWidget {
  final CollectionFilter filter;
  final bool removable;
  final bool showGenericIcon;
  final Widget background;
  final Widget details;
  final HeroType heroType;
  final FilterCallback onPressed;

  static final BorderRadius borderRadius = BorderRadius.circular(32);
  static const double outlineWidth = 2;
  static const double minChipHeight = kMinInteractiveDimension;
  static const double minChipWidth = 80;
  static const double maxChipWidth = 160;
  static const double iconSize = 20;
  static const double padding = 6;

  const AvesFilterChip({
    Key key,
    this.filter,
    this.removable = false,
    this.showGenericIcon = true,
    this.background,
    this.details,
    this.heroType = HeroType.onTap,
    @required this.onPressed,
  }) : super(key: key);

  @override
  _AvesFilterChipState createState() => _AvesFilterChipState();
}

class _AvesFilterChipState extends State<AvesFilterChip> {
  Future<Color> _colorFuture;
  bool _tapped;

  CollectionFilter get filter => widget.filter;

  @override
  void initState() {
    super.initState();
    _initColorLoader();
    _tapped = false;
  }

  @override
  void didUpdateWidget(AvesFilterChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filter != filter) {
      _initColorLoader();
      _tapped = false;
    }
  }

  void _initColorLoader() => _colorFuture = filter.color(context);

  @override
  Widget build(BuildContext context) {
    final hasBackground = widget.background != null;
    final leading = filter.iconBuilder(context, AvesFilterChip.iconSize, showGenericIcon: widget.showGenericIcon);
    final trailing = widget.removable ? Icon(AIcons.clear, size: AvesFilterChip.iconSize) : null;

    Widget content = Row(
      mainAxisSize: hasBackground ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leading != null) ...[
          leading,
          SizedBox(width: AvesFilterChip.padding),
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
          SizedBox(width: AvesFilterChip.padding),
          trailing,
        ],
      ],
    );

    if (widget.details != null) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          content,
          widget.details,
        ],
      );
    }

    content = Padding(
      padding: EdgeInsets.symmetric(horizontal: AvesFilterChip.padding * 2, vertical: 2),
      child: content,
    );

    if (hasBackground) {
      content = Center(
        child: ColoredBox(
          color: Colors.black54,
          child: DefaultTextStyle(
            style: Theme.of(context).textTheme.bodyText2.copyWith(
              shadows: [
                Shadow(
                  color: Colors.black87,
                  offset: Offset(0.5, 1.0),
                )
              ],
            ),
            child: content,
          ),
        ),
      );
    }

    final borderRadius = AvesFilterChip.borderRadius;

    Widget chip = Container(
      constraints: BoxConstraints(
        minWidth: AvesFilterChip.minChipWidth,
        maxWidth: AvesFilterChip.maxChipWidth,
        minHeight: AvesFilterChip.minChipHeight,
      ),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          if (widget.background != null)
            ClipRRect(
              borderRadius: borderRadius,
              child: widget.background,
            ),
          Tooltip(
            message: filter.tooltip,
            preferBelow: false,
            child: Material(
              color: hasBackground ? Colors.transparent : Theme.of(context).scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: borderRadius,
              ),
              child: InkWell(
                onTap: widget.onPressed != null
                    ? () {
                        WidgetsBinding.instance.addPostFrameCallback((_) => widget.onPressed(filter));
                        setState(() => _tapped = true);
                      }
                    : null,
                borderRadius: borderRadius,
                child: FutureBuilder<Color>(
                  future: _colorFuture,
                  builder: (context, snapshot) {
                    final outlineColor = snapshot.hasData ? snapshot.data : Colors.transparent;
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: outlineColor,
                          width: AvesFilterChip.outlineWidth,
                        ),
                        borderRadius: borderRadius,
                      ),
                      position: DecorationPosition.foreground,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: content,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (widget.heroType == HeroType.always || widget.heroType == HeroType.onTap && _tapped) {
      chip = Hero(
        tag: filter,
        child: chip,
      );
    }
    return chip;
  }
}
