import 'dart:async';
import 'dart:math';

import 'package:aves/app_mode.dart';
import 'package:aves/model/actions/chip_actions.dart';
import 'package:aves/model/covers.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/location.dart';
import 'package:aves/model/filters/tag.dart';
import 'package:aves/model/settings/enums/accessibility_animations.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/collection/filter_bar.dart';
import 'package:aves/widgets/common/basic/font_size_icon_theme.dart';
import 'package:aves/widgets/common/basic/popup/menu_row.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/filter_grids/common/action_delegates/chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

typedef FilterCallback = void Function(CollectionFilter filter);
typedef OffsetFilterCallback = void Function(BuildContext context, CollectionFilter filter, Offset tapPosition);

enum HeroType { always, onTap, never }

@immutable
class AvesFilterDecoration {
  final Widget widget;
  final Radius radius;

  const AvesFilterDecoration({
    required this.widget,
    required this.radius,
  });

  BorderRadius get textBorderRadius => BorderRadius.vertical(bottom: radius);

  BorderRadius get chipBorderRadius => BorderRadius.all(radius);
}

class AvesFilterChip extends StatefulWidget {
  final CollectionFilter filter;
  final bool showText, showGenericIcon, useFilterColor;
  final AvesFilterDecoration? decoration;
  final String? banner;
  final Widget? leadingOverride, details;
  final double padding;
  final double? maxWidth;
  final HeroType heroType;
  final FilterCallback? onTap, onRemove;
  final OffsetFilterCallback? onLongPress;

  static const double defaultRadius = 32;
  static const double outlineWidth = 2;
  static const double minChipHeight = kMinInteractiveDimension;
  static const double minChipWidth = 80;
  static const double iconSize = 18;
  static const double fontSize = 14;
  static const double decoratedContentVerticalPadding = 5;

  const AvesFilterChip({
    super.key,
    required this.filter,
    this.showText = true,
    this.showGenericIcon = true,
    this.useFilterColor = true,
    this.decoration,
    this.banner,
    this.leadingOverride,
    this.details,
    this.padding = 6.0,
    this.maxWidth,
    this.heroType = HeroType.onTap,
    this.onTap,
    this.onRemove,
    this.onLongPress = showDefaultLongPressMenu,
  });

  static double computeMaxWidth(
    BuildContext context, {
    required int minChipPerRow,
    required double chipPadding,
    required double rowPadding,
  }) {
    return context.select<MediaQueryData, double>((mq) {
      return (mq.size.width - mq.padding.horizontal - chipPadding * minChipPerRow - rowPadding) / minChipPerRow;
    });
  }

  static Future<void> showDefaultLongPressMenu(BuildContext context, CollectionFilter filter, Offset tapPosition) async {
    if (context.read<ValueNotifier<AppMode>>().value.canNavigate) {
      final actions = [
        if (filter is AlbumFilter) ChipAction.goToAlbumPage,
        if ((filter is LocationFilter && filter.level == LocationLevel.country)) ChipAction.goToCountryPage,
        if ((filter is LocationFilter && filter.level == LocationLevel.place)) ChipAction.goToPlacePage,
        if (filter is TagFilter) ChipAction.goToTagPage,
        ChipAction.reverse,
        ChipAction.hide,
        ChipAction.lockVault,
      ];

      // remove focus, if any, to prevent the keyboard from showing up
      // after the user is done with the popup menu
      FocusManager.instance.primaryFocus?.unfocus();

      final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
      const touchArea = Size(kMinInteractiveDimension, kMinInteractiveDimension);
      final actionDelegate = ChipActionDelegate();
      final selectedAction = await showMenu<ChipAction>(
        context: context,
        position: RelativeRect.fromRect(tapPosition & touchArea, Offset.zero & overlay.size),
        items: [
          PopupMenuItem(
            child: Text(filter.getLabel(context)),
          ),
          const PopupMenuDivider(),
          ...actions.where((action) => actionDelegate.isVisible(action, filter: filter)).map((action) {
            late String text;
            if (action == ChipAction.reverse) {
              text = filter.reversed ? context.l10n.chipActionFilterIn : context.l10n.chipActionFilterOut;
            } else {
              text = action.getText(context);
            }
            return PopupMenuItem(
              value: action,
              child: FontSizeIconTheme(
                child: MenuRow(text: text, icon: action.getIcon()),
              ),
            );
          }),
        ],
      );
      if (selectedAction != null) {
        // wait for the popup menu to hide before proceeding with the action
        await Future.delayed(Durations.popupMenuAnimation * timeDilation);
        actionDelegate.onActionSelected(context, filter, selectedAction);
      }
    }
  }

  @override
  State<AvesFilterChip> createState() => _AvesFilterChipState();
}

class _AvesFilterChipState extends State<AvesFilterChip> {
  final List<StreamSubscription> _subscriptions = [];
  late Future<Color> _colorFuture;
  late Color _outlineColor;
  late bool _tapped;
  Offset? _tapPosition;

  CollectionFilter get filter => widget.filter;

  double get padding => widget.padding;

  @override
  void initState() {
    super.initState();
    _tapped = false;
    _subscriptions.add(covers.packageChangeStream.listen(_onCoverColorChanged));
    _subscriptions.add(covers.colorChangeStream.listen(_onCoverColorChanged));
    _subscriptions.add(settings.updateStream.where((event) => event.key == Settings.themeColorModeKey).listen((_) {
      // delay so that contextual colors reflect the new settings
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _onCoverColorChanged(null);
      });
    }));
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

  @override
  void dispose() {
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
    super.dispose();
  }

  void _initColorLoader() {
    // For app albums, `filter.color` yields a regular async `Future` the first time
    // but it yields a `SynchronousFuture` when called again on a known album.
    // This works fine to avoid a frame with no Future data, for new widgets.
    // However, when the user moves away and back to a page with a chip using the async future,
    // the existing widget FutureBuilder cycles again from the start, with a frame in `waiting` state and no data.
    // So we save the result of the Future to a local variable because of this specific case.
    _colorFuture = filter.color(context);
    _outlineColor = context.read<AvesColorsData>().neutral;
  }

  void _onCoverColorChanged(Set<CollectionFilter>? event) {
    if (event == null || event.contains(filter)) {
      _initColorLoader();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final decoration = widget.decoration;
    final chipBackground = Theme.of(context).scaffoldBackgroundColor;

    final onTap = widget.onTap != null
        ? () {
            WidgetsBinding.instance.addPostFrameCallback((_) => widget.onTap?.call(filter));
            setState(() => _tapped = true);
          }
        : null;
    final onRemove = widget.onRemove != null
        ? () {
            WidgetsBinding.instance.addPostFrameCallback((_) => widget.onRemove?.call(filter));
            setState(() => _tapped = true);
          }
        : null;
    final onLongPress = widget.onLongPress != null
        ? () {
            if (_tapPosition != null) {
              widget.onLongPress?.call(context, filter, _tapPosition!);
            }
          }
        : null;

    Widget? content;
    if (widget.showText) {
      final textScaleFactor = MediaQuery.textScaleFactorOf(context);
      final iconSize = AvesFilterChip.iconSize * textScaleFactor;
      final leading = widget.leadingOverride ?? filter.iconBuilder(context, iconSize, showGenericIcon: widget.showGenericIcon);
      final trailing = onRemove != null
          ? IconButton(
              icon: Icon(AIcons.clear, size: iconSize),
              padding: EdgeInsets.zero,
              splashRadius: IconTheme.of(context).size,
              constraints: const BoxConstraints(),
              onPressed: onRemove,
            )
          : null;

      content = Row(
        mainAxisSize: decoration != null ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (leading != null) ...[
            leading,
            SizedBox(width: padding),
          ],
          Flexible(
            child: Text(
              filter.getLabel(context),
              style: TextStyle(
                fontSize: AvesFilterChip.fontSize,
                decoration: filter.reversed ? TextDecoration.lineThrough : null,
                decorationThickness: 2,
              ),
              softWrap: false,
              overflow: TextOverflow.fade,
            ),
          ),
          if (trailing != null) ...[
            SizedBox(width: padding),
            trailing,
          ],
        ],
      );

      final details = widget.details;
      if (details != null) {
        content = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            content,
            Flexible(child: details),
          ],
        );
      }

      if (decoration != null) {
        content = Align(
          alignment: Alignment.bottomCenter,
          child: ClipRRect(
            borderRadius: decoration.textBorderRadius,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: padding * 2, vertical: AvesFilterChip.decoratedContentVerticalPadding),
              color: chipBackground,
              child: content,
            ),
          ),
        );
      } else {
        content = Padding(
          padding: EdgeInsets.symmetric(horizontal: padding * 2),
          child: content,
        );
      }
    }

    final borderRadius = decoration?.chipBorderRadius ?? const BorderRadius.all(Radius.circular(AvesFilterChip.defaultRadius));
    final banner = widget.banner;
    Widget chip = Container(
      constraints: BoxConstraints(
        minWidth: AvesFilterChip.minChipWidth,
        maxWidth: max(
            AvesFilterChip.minChipWidth,
            widget.maxWidth ??
                AvesFilterChip.computeMaxWidth(
                  context,
                  minChipPerRow: 2,
                  chipPadding: FilterBar.chipPadding.horizontal,
                  rowPadding: FilterBar.rowPadding.horizontal,
                )),
        minHeight: AvesFilterChip.minChipHeight,
      ),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          if (decoration != null)
            ClipRRect(
              borderRadius: decoration.chipBorderRadius,
              child: decoration.widget,
            ),
          Material(
            color: decoration != null ? Colors.transparent : chipBackground,
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius,
            ),
            child: InkWell(
              // as of Flutter v2.8.0, `InkWell` does not have `onLongPressStart` like `GestureDetector`,
              // so we get the long press details from the tap instead
              onTapDown: onLongPress != null ? (details) => _tapPosition = details.globalPosition : null,
              onTap: onTap,
              onLongPress: onLongPress,
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
                        color: widget.useFilterColor ? _outlineColor : context.select<AvesColorsData, Color>((v) => v.neutral),
                        width: AvesFilterChip.outlineWidth,
                      )),
                      borderRadius: borderRadius,
                    ),
                    position: DecorationPosition.foreground,
                    child: content,
                  );
                },
              ),
            ),
          ),
          if (banner != null)
            LayoutBuilder(
              builder: (context, constraints) {
                return ClipRRect(
                  borderRadius: borderRadius,
                  child: Align(
                    // align to corner the scaled down banner in RTL
                    alignment: AlignmentDirectional.topStart,
                    child: Transform(
                      transform: Matrix4.identity().scaled((constraints.maxHeight / 90 - .4).clamp(.45, 1.0)),
                      child: Banner(
                        message: banner.toUpperCase(),
                        location: BannerLocation.topStart,
                        color: Theme.of(context).colorScheme.secondary,
                        child: const SizedBox(),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );

    final animate = context.select<Settings, bool>((v) => v.accessibilityAnimations.animate);
    if (animate && (widget.heroType == HeroType.always || widget.heroType == HeroType.onTap && _tapped)) {
      chip = Hero(
        tag: filter,
        transitionOnUserGestures: true,
        child: MediaQueryDataProvider(
          child: DefaultTextStyle(
            style: const TextStyle(),
            child: chip,
          ),
        ),
      );
    }
    return chip;
  }
}
