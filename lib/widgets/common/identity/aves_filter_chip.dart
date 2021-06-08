import 'package:aves/app_mode.dart';
import 'package:aves/model/actions/chip_actions.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/location.dart';
import 'package:aves/model/filters/tag.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/common/basic/menu_row.dart';
import 'package:aves/widgets/filter_grids/common/chip_action_delegate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

typedef FilterCallback = void Function(CollectionFilter filter);
typedef OffsetFilterCallback = void Function(BuildContext context, CollectionFilter filter, Offset tapPosition);

enum HeroType { always, onTap, never }

class AvesFilterChip extends StatefulWidget {
  final CollectionFilter filter;
  final bool removable;
  final bool showGenericIcon;
  final Widget? background;
  final Widget? details;
  final BorderRadius? borderRadius;
  final double padding;
  final HeroType heroType;
  final FilterCallback? onTap;
  final OffsetFilterCallback? onLongPress;

  static const Color defaultOutlineColor = Colors.white;
  static const double defaultRadius = 32;
  static const double outlineWidth = 2;
  static const double minChipHeight = kMinInteractiveDimension;
  static const double minChipWidth = 80;
  static const double maxChipWidth = 160;

  const AvesFilterChip({
    Key? key,
    required this.filter,
    this.removable = false,
    this.showGenericIcon = true,
    this.background,
    this.details,
    this.borderRadius,
    this.padding = 6.0,
    this.heroType = HeroType.onTap,
    this.onTap,
    this.onLongPress = showDefaultLongPressMenu,
  }) : super(key: key);

  static Future<void> showDefaultLongPressMenu(BuildContext context, CollectionFilter filter, Offset tapPosition) async {
    if (context.read<ValueNotifier<AppMode>>().value == AppMode.main) {
      final actions = [
        if (filter is AlbumFilter) ChipAction.goToAlbumPage,
        if ((filter is LocationFilter && filter.level == LocationLevel.country)) ChipAction.goToCountryPage,
        if (filter is TagFilter) ChipAction.goToTagPage,
        ChipAction.hide,
      ];

      // remove focus, if any, to prevent the keyboard from showing up
      // after the user is done with the popup menu
      FocusManager.instance.primaryFocus?.unfocus();

      final overlay = Overlay.of(context)!.context.findRenderObject() as RenderBox;
      const touchArea = Size(40, 40);
      final selectedAction = await showMenu<ChipAction>(
        context: context,
        position: RelativeRect.fromRect(tapPosition & touchArea, Offset.zero & overlay.size),
        items: actions
            .map((action) => PopupMenuItem(
                  value: action,
                  child: MenuRow(text: action.getText(context), icon: action.getIcon()),
                ))
            .toList(),
      );
      if (selectedAction != null) {
        // wait for the popup menu to hide before proceeding with the action
        Future.delayed(Durations.popupMenuAnimation * timeDilation, () => ChipActionDelegate().onActionSelected(context, filter, selectedAction));
      }
    }
  }

  @override
  _AvesFilterChipState createState() => _AvesFilterChipState();
}

class _AvesFilterChipState extends State<AvesFilterChip> {
  late Future<Color> _colorFuture;
  late Color _outlineColor;
  late bool _tapped;
  Offset? _tapPosition;

  CollectionFilter get filter => widget.filter;

  double get padding => widget.padding;

  FilterCallback? get onTap => widget.onTap;

  OffsetFilterCallback? get onLongPress => widget.onLongPress;

  @override
  void initState() {
    super.initState();
    _tapped = false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initColorLoader();
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
            filter.getLabel(context),
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
          Flexible(child: widget.details!),
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
            style: Theme.of(context).textTheme.bodyText2!.copyWith(
                  shadows: Constants.embossShadows,
                ),
            child: content,
          ),
        ),
      );
    }

    final borderRadius = widget.borderRadius ?? const BorderRadius.all(Radius.circular(AvesFilterChip.defaultRadius));
    Widget chip = Container(
      constraints: const BoxConstraints(
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
            message: filter.getTooltip(context),
            preferBelow: false,
            child: Material(
              color: hasBackground ? Colors.transparent : Theme.of(context).scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: borderRadius,
              ),
              child: InkWell(
                // as of Flutter v1.22.5, `InkWell` does not have `onLongPressStart` like `GestureDetector`,
                // so we get the long press details from the tap instead
                onTapDown: onLongPress != null ? (details) => _tapPosition = details.globalPosition : null,
                onTap: onTap != null
                    ? () {
                        WidgetsBinding.instance!.addPostFrameCallback((_) => onTap!(filter));
                        setState(() => _tapped = true);
                      }
                    : null,
                onLongPress: onLongPress != null ? () => onLongPress!(context, filter, _tapPosition!) : null,
                borderRadius: borderRadius,
                child: FutureBuilder<Color>(
                  future: _colorFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      _outlineColor = snapshot.data!;
                    }
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.fromBorderSide(BorderSide(
                          color: _outlineColor,
                          width: AvesFilterChip.outlineWidth,
                        )),
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
        ],
      ),
    );

    if (widget.heroType == HeroType.always || widget.heroType == HeroType.onTap && _tapped) {
      chip = Hero(
        tag: filter,
        transitionOnUserGestures: true,
        child: DefaultTextStyle(
          style: const TextStyle(),
          child: chip,
        ),
      );
    }
    return chip;
  }
}
