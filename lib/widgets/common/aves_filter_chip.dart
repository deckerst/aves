import 'package:aves/model/filters/filters.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:flutter/material.dart';

typedef FilterCallback = void Function(CollectionFilter filter);

class AvesFilterChip extends StatefulWidget {
  final CollectionFilter filter;
  final bool removable;
  final bool showGenericIcon;
  final Decoration decoration;
  final Widget details;
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
    this.decoration,
    this.details,
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
    final leading = filter.iconBuilder(context, AvesFilterChip.iconSize, showGenericIcon: widget.showGenericIcon);
    final trailing = widget.removable ? const Icon(AIcons.clear, size: AvesFilterChip.iconSize) : null;

    Widget content = Row(
      mainAxisSize: widget.decoration != null ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leading != null) ...[
          leading,
          const SizedBox(width: AvesFilterChip.padding),
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
      padding: const EdgeInsets.symmetric(horizontal: AvesFilterChip.padding * 2, vertical: 2),
      child: content,
    );

    if (widget.decoration != null) {
      content = Center(
        child: ColoredBox(
          color: Colors.black54,
          child: DefaultTextStyle(
            style: Theme.of(context).textTheme.bodyText2.copyWith(
              shadows: const [
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

    final chip = Container(
      constraints: const BoxConstraints(
        minWidth: AvesFilterChip.minChipWidth,
        maxWidth: AvesFilterChip.maxChipWidth,
        minHeight: AvesFilterChip.minChipHeight,
      ),
      decoration: widget.decoration,
      child: Tooltip(
        message: filter.tooltip,
        preferBelow: false,
        child: Material(
          color: widget.decoration != null ? Colors.transparent : Theme.of(context).scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius,
          ),
          child: InkWell(
            onTap: widget.onPressed != null ? () => widget.onPressed(filter) : null,
            borderRadius: borderRadius,
            child: FutureBuilder(
              future: _colorFuture,
              builder: (context, AsyncSnapshot<Color> snapshot) {
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
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: content,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );

    // TODO TLAD only hero between `FilterBar` and chips that are tapped
    return Hero(
      tag: filter,
      flightShuttleBuilder: (flight, animation, direction, fromHeroContext, toHeroContext) {
        final toHero = toHeroContext.widget as Hero;
        return Center(child: toHero.child);
      },
      child: chip,
    );
  }
}
