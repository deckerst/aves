import 'package:aves/model/filters/filters.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/constants.dart';
import 'package:flutter/material.dart';

typedef FilterCallback = void Function(CollectionFilter filter);
typedef OffsetFilterCallback = void Function(CollectionFilter filter, Offset tapPosition);

enum HeroType { always, onTap, never }

class AvesFilterChip extends StatefulWidget {
  final CollectionFilter filter;
  final bool removable;
  final bool showGenericIcon;
  final Widget background;
  final Widget details;
  final double padding;
  final HeroType heroType;
  final FilterCallback onTap;
  final OffsetFilterCallback onLongPress;
  final BorderRadius borderRadius;

  static const Color defaultOutlineColor = Colors.white;
  static const double defaultRadius = 32;
  static const double outlineWidth = 2;
  static const double minChipHeight = kMinInteractiveDimension;
  static const double minChipWidth = 80;
  static const double maxChipWidth = 160;

  const AvesFilterChip({
    Key key,
    @required this.filter,
    this.removable = false,
    this.showGenericIcon = true,
    this.background,
    this.details,
    this.borderRadius = const BorderRadius.all(Radius.circular(defaultRadius)),
    this.padding = 6.0,
    this.heroType = HeroType.onTap,
    this.onTap,
    this.onLongPress,
  })  : assert(filter != null),
        super(key: key);

  @override
  _AvesFilterChipState createState() => _AvesFilterChipState();
}

class _AvesFilterChipState extends State<AvesFilterChip> {
  Future<Color> _colorFuture;
  Color _outlineColor;
  bool _tapped;
  Offset _tapPosition;

  CollectionFilter get filter => widget.filter;

  BorderRadius get borderRadius => widget.borderRadius;

  double get padding => widget.padding;

  @override
  void initState() {
    super.initState();
    _initColorLoader();
    _tapped = false;
  }

  @override
  void didUpdateWidget(covariant AvesFilterChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filter != filter) {
      _initColorLoader();
      _tapped = false;
    }
  }

  void _initColorLoader() {
    // For app albums, `filter.color` yields a regular async `Future` the first time
    // but it yields a `SynchronousFuture` when called again on a known album.
    // This works fine to avoid a frame with no Future data, for new widgets.
    // However, when the user moves away and back to a page with a chip using the async future,
    // the existing widget FutureBuilder cycles again from the start, with a frame in `waiting` state and no data.
    // So we save the result of the Future to a local variable because of this specific case.
    _colorFuture = filter.color(context);
    _outlineColor = AvesFilterChip.defaultOutlineColor;
  }

  @override
  Widget build(BuildContext context) {
    final textScaleFactor = MediaQuery.textScaleFactorOf(context);
    final iconSize = 20 * textScaleFactor;

    final hasBackground = widget.background != null;
    final leading = filter.iconBuilder(context, iconSize, showGenericIcon: widget.showGenericIcon, embossed: hasBackground);
    final trailing = widget.removable ? Icon(AIcons.clear, size: iconSize) : null;

    Widget content = Row(
      mainAxisSize: hasBackground ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leading != null) ...[
          leading,
          SizedBox(width: padding),
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
          SizedBox(width: padding),
          trailing,
        ],
      ],
    );

    if (widget.details != null) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          content,
          Flexible(child: widget.details),
        ],
      );
    }

    content = Padding(
      padding: EdgeInsets.symmetric(horizontal: padding * 2, vertical: 2),
      child: content,
    );

    if (hasBackground) {
      content = Center(
        child: ColoredBox(
          color: Colors.black54,
          child: DefaultTextStyle(
            style: Theme.of(context).textTheme.bodyText2.copyWith(
              shadows: [Constants.embossShadow],
            ),
            child: content,
          ),
        ),
      );
    }

    Widget chip = Container(
      constraints: BoxConstraints(
        minWidth: AvesFilterChip.minChipWidth,
        maxWidth: AvesFilterChip.maxChipWidth,
        minHeight: AvesFilterChip.minChipHeight,
      ),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          if (hasBackground)
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
                // as of Flutter v1.22.5, `InkWell` does not have `onLongPressStart` like `GestureDetector`,
                // so we get the long press details from the tap instead
                onTapDown: (details) => _tapPosition = details.globalPosition,
                onTap: widget.onTap != null
                    ? () {
                        WidgetsBinding.instance.addPostFrameCallback((_) => widget.onTap(filter));
                        setState(() => _tapped = true);
                      }
                    : null,
                onLongPress: widget.onLongPress != null ? () => widget.onLongPress(filter, _tapPosition) : null,
                borderRadius: borderRadius,
                child: FutureBuilder<Color>(
                  future: _colorFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      _outlineColor = snapshot.data;
                    }
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _outlineColor,
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
        transitionOnUserGestures: true,
        child: DefaultTextStyle(
          style: TextStyle(),
          child: chip,
        ),
      );
    }
    return chip;
  }
}
