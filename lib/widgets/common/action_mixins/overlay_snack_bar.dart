import 'package:flutter/material.dart';

// adapted from Flutter `SnackBar` in `/material/snack_bar.dart`

// As of Flutter v3.41.9, `SnackBar` is not customizable enough to add margin
// and ignore pointers in that area, so we use an overlay entry instead.
// This overlay entry is not under a `Scaffold` (which is expected by `SnackBar`
// and `SnackBarAction`), and is not dismissed the same way.

const double _singleLineVerticalPadding = 14.0;
const Duration _snackBarDisplayDuration = Duration(milliseconds: 4000);
const Curve _snackBarHeightCurve = Curves.fastOutSlowIn;
const Curve _snackBarM3HeightCurve = Curves.easeInOutQuart;

const Curve _snackBarFadeInCurve = Interval(0.4, 1.0);
const Curve _snackBarM3FadeInCurve = Interval(0.4, 0.6, curve: Curves.easeInCirc);
const Curve _snackBarFadeOutCurve = Interval(0.72, 1.0, curve: Curves.fastOutSlowIn);

class OverlaySnackBar extends StatefulWidget {
  const OverlaySnackBar({
    super.key,
    required this.content,
    this.backgroundColor,
    this.elevation,
    this.margin,
    this.padding,
    this.width,
    this.shape,
    this.hitTestBehavior,
    this.behavior,
    this.action,
    this.actionOverflowThreshold,
    this.showCloseIcon,
    this.closeIconColor,
    this.duration = _snackBarDisplayDuration,
    bool? persist,
    this.animation,
    this.onVisible,
    this.dismissDirection,
    this.clipBehavior = Clip.hardEdge,
    required this.onDismiss,
  }) : assert(elevation == null || elevation >= 0.0),
       assert(width == null || margin == null, 'Width and margin can not be used together'),
       assert(
         actionOverflowThreshold == null || (actionOverflowThreshold >= 0 && actionOverflowThreshold <= 1),
         'Action overflow threshold must be between 0 and 1 inclusive',
       ),
       persist = persist ?? action != null;

  /// The primary content of the snack bar.
  ///
  /// Typically a [Text] widget.
  final Widget content;

  /// The snack bar's background color.
  ///
  /// If not specified, the ambient [SnackBarThemeData.backgroundColor] is used.
  /// If that is not specified it will default to a
  /// dark variation of [ColorScheme.surface] for light themes, or
  /// [ColorScheme.onSurface] for dark themes.
  final Color? backgroundColor;

  /// The z-coordinate at which to place the snack bar. This controls the size
  /// of the shadow below the snack bar.
  ///
  /// Defines the card's [Material.elevation].
  ///
  /// If this property is null, then the ambient [SnackBarThemeData.elevation]
  /// is used, if that is also null, the default value is 6.0.
  final double? elevation;

  /// Empty space to surround the snack bar.
  ///
  /// This property is only used when [behavior] is [SnackBarBehavior.floating].
  /// It can not be used if [width] is specified.
  ///
  /// If this property is null, then the ambient [SnackBarThemeData.insetPadding]
  /// is used. If that is also null, then the default is
  /// `EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 10.0)`.
  ///
  /// If this property is not null and [hitTestBehavior] is null, then [hitTestBehavior] default is [HitTestBehavior.deferToChild].
  final EdgeInsetsGeometry? margin;

  /// The amount of padding to apply to the snack bar's content and optional
  /// action.
  ///
  /// If this property is null, the default padding values are as follows:
  ///
  /// * [content]
  ///     * Top and bottom paddings are 14.
  ///     * Left padding is 24 if [behavior] is [SnackBarBehavior.fixed],
  ///       16 if [behavior] is [SnackBarBehavior.floating].
  ///     * Right padding is same as start padding if there is no [action],
  ///       otherwise 0.
  /// * [action]
  ///     * Top and bottom paddings are 14.
  ///     * Left and right paddings are half of [content]'s left padding.
  ///
  /// If this property is not null, the padding is as follows:
  ///
  /// * [content]
  ///     * Left, top and bottom paddings are assigned normally.
  ///     * Right padding is assigned normally if there is no [action],
  ///       otherwise 0.
  /// * [action]
  ///     * Left padding is replaced with half the right padding.
  ///     * Top and bottom paddings are assigned normally.
  ///     * Right padding is replaced with one and a half times the
  ///       right padding.
  final EdgeInsetsGeometry? padding;

  /// The width of the snack bar.
  ///
  /// If width is specified, the snack bar will be centered horizontally in the
  /// available space. This property is only used when [behavior] is
  /// [SnackBarBehavior.floating]. It can not be used if [margin] is specified.
  ///
  /// If this property is null, then the ambient [SnackBarThemeData.width]
  /// is used. If that is null, the snack bar will take up the full device
  /// width less the margin.
  final double? width;

  /// The shape of the snack bar's [Material].
  ///
  /// Defines the snack bar's [Material.shape].
  ///
  /// If this property is null, then the ambient [SnackBarThemeData.shape]
  /// is used. If that's null then the shape will
  /// depend on the [SnackBarBehavior]. For [SnackBarBehavior.fixed], no
  /// overriding shape is specified, so the [SnackBar] is rectangular. For
  /// [SnackBarBehavior.floating], it uses a [RoundedRectangleBorder] with a
  /// circular corner radius of 4.0.
  final ShapeBorder? shape;

  /// Defines how the snack bar area, including margin, will behave during hit testing.
  ///
  /// If this property is null, and [margin] is not null or the ambient
  /// [SnackBarThemeData.insetPadding] is not null, then
  /// [HitTestBehavior.deferToChild] is used by default.
  ///
  /// Please refer to [HitTestBehavior] for a detailed explanation of every behavior.
  final HitTestBehavior? hitTestBehavior;

  /// This defines the behavior and location of the snack bar.
  ///
  /// Defines where a [SnackBar] should appear within a [Scaffold] and how its
  /// location should be adjusted when the scaffold also includes a
  /// [FloatingActionButton] or a [BottomNavigationBar]
  ///
  /// If this property is null, then the ambient [SnackBarThemeData.behavior]
  /// is used. If that is null, then the default is [SnackBarBehavior.fixed].
  ///
  /// If this value is [SnackBarBehavior.floating], the length of the bar
  /// is defined by either [width] or [margin].
  final SnackBarBehavior? behavior;

  /// (optional) The percentage threshold for action widget's width before it overflows
  /// to a new line.
  ///
  /// Must be between 0 and 1.
  /// If the width of the [action] divided by the total snackbar width
  /// is greater than this percentage, the [action] will appear below the [content].
  ///
  /// At a value of 0, the action will always overflow to a new line.
  ///
  /// Defaults to 0.25.
  final double? actionOverflowThreshold;

  /// (optional) Whether to include a "close" icon widget.
  ///
  /// Tapping the icon will close the snack bar.
  final bool? showCloseIcon;

  /// An optional color for the close icon, if [showCloseIcon] is
  /// true.
  ///
  /// If this property is null, then the ambient [SnackBarThemeData.closeIconColor]
  /// is used. If that is null, then the default is inverse surface.
  ///
  /// If [closeIconColor] is a [WidgetStateColor], then the icon color will be
  /// resolved against the set of [WidgetState]s that the action text
  /// is in, thus allowing for different colors for states such as pressed,
  /// hovered and others.
  final Color? closeIconColor;

  /// The amount of time the snack bar should be displayed.
  ///
  /// Defaults to 4.0s.
  ///
  /// See also:
  ///
  ///  * [ScaffoldMessengerState.removeCurrentSnackBar], which abruptly hides the
  ///    currently displayed snack bar, if any, and allows the next to be
  ///    displayed.
  ///  * <https://material.io/design/components/snackbars.html>
  final Duration duration;

  /// Whether the snack bar will stay or auto-dismiss after timeout.
  ///
  /// If true, the snack bar remains visible even after the timeout, until the
  /// user taps the action button or the close icon.
  ///
  /// If false, the snack bar will be dismissed after the timeout.
  ///
  /// If not provided, but the snackbar action is not null, the snackbar will
  /// persist as well.
  final bool persist;

  /// The animation driving the entrance and exit of the snack bar.
  final Animation<double>? animation;

  /// Called the first time that the snackbar is visible within a [Scaffold].
  ///
  /// When multiple [Scaffold]s are registered to the same [ScaffoldMessengerState],
  /// [onVisible] is called once for each scaffold.
  ///
  /// See also:
  ///
  ///  * [ScaffoldMessenger], which manages [SnackBar]s for [Scaffold] descendants.
  final VoidCallback? onVisible;

  /// The direction in which the SnackBar can be dismissed.
  ///
  /// If this property is null, then the ambient [SnackBarThemeData.dismissDirection]
  /// is used. If that is null, then the default is [DismissDirection.down].
  final DismissDirection? dismissDirection;

  /// {@macro flutter.material.Material.clipBehavior}
  ///
  /// Defaults to [Clip.hardEdge].
  final Clip clipBehavior;

  final Widget? action;
  final VoidCallback onDismiss;

  @override
  State<OverlaySnackBar> createState() => _OverlaySnackBarState();
}

class _OverlaySnackBarState extends State<OverlaySnackBar> {
  bool _wasVisible = false;

  CurvedAnimation? _heightAnimation;
  CurvedAnimation? _fadeInAnimation;
  CurvedAnimation? _fadeInM3Animation;
  CurvedAnimation? _fadeOutAnimation;
  CurvedAnimation? _heightM3Animation;

  final Key _dismissibleKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    widget.animation!.addStatusListener(_onAnimationStatusChanged);
    _setAnimations();
  }

  @override
  void didUpdateWidget(OverlaySnackBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animation != oldWidget.animation) {
      oldWidget.animation!.removeStatusListener(_onAnimationStatusChanged);
      widget.animation!.addStatusListener(_onAnimationStatusChanged);
      _disposeAnimations();
      _setAnimations();
    }
  }

  void _setAnimations() {
    assert(widget.animation != null);
    _heightAnimation = CurvedAnimation(parent: widget.animation!, curve: _snackBarHeightCurve);
    _fadeInAnimation = CurvedAnimation(parent: widget.animation!, curve: _snackBarFadeInCurve);
    _fadeInM3Animation = CurvedAnimation(parent: widget.animation!, curve: _snackBarM3FadeInCurve);
    _fadeOutAnimation = CurvedAnimation(
      parent: widget.animation!,
      curve: _snackBarFadeOutCurve,
      reverseCurve: const Threshold(0.0),
    );
    // Material 3 Animation has a height animation on entry, but a direct fade out on exit.
    _heightM3Animation = CurvedAnimation(
      parent: widget.animation!,
      curve: _snackBarM3HeightCurve,
      reverseCurve: const Threshold(0.0),
    );
  }

  void _disposeAnimations() {
    _heightAnimation?.dispose();
    _fadeInAnimation?.dispose();
    _fadeInM3Animation?.dispose();
    _fadeOutAnimation?.dispose();
    _heightM3Animation?.dispose();
    _heightAnimation = null;
    _fadeInAnimation = null;
    _fadeInM3Animation = null;
    _fadeOutAnimation = null;
    _heightM3Animation = null;
  }

  @override
  void dispose() {
    widget.animation!.removeStatusListener(_onAnimationStatusChanged);
    _disposeAnimations();
    super.dispose();
  }

  void _onAnimationStatusChanged(AnimationStatus status) {
    if (status.isCompleted) {
      if (widget.onVisible != null && !_wasVisible) {
        widget.onVisible!();
      }
      _wasVisible = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    final bool accessibleNavigation = MediaQuery.accessibleNavigationOf(context);
    assert(widget.animation != null);
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final SnackBarThemeData snackBarTheme = SnackBarTheme.of(context);
    final isThemeDark = theme.brightness == Brightness.dark;
    final Color buttonColor = isThemeDark ? colorScheme.primary : colorScheme.secondary;
    final SnackBarThemeData defaults = _SnackbarDefaultsM3(context);

    // SnackBar uses a theme that is the opposite brightness from
    // the surrounding theme.
    final Brightness brightness = isThemeDark ? Brightness.light : Brightness.dark;

    // Invert the theme values for Material 2. Material 3 values are tokenized to pre-inverted values.
    final ThemeData effectiveTheme = theme.useMaterial3
        ? theme
        : theme.copyWith(
            colorScheme: ColorScheme(
              primary: colorScheme.onPrimary,
              secondary: buttonColor,
              surface: colorScheme.onSurface,
              error: colorScheme.onError,
              onPrimary: colorScheme.primary,
              onSecondary: colorScheme.secondary,
              onSurface: colorScheme.surface,
              onError: colorScheme.error,
              brightness: brightness,
            ),
          );

    final TextStyle? contentTextStyle = snackBarTheme.contentTextStyle ?? defaults.contentTextStyle;
    final SnackBarBehavior snackBarBehavior = widget.behavior ?? snackBarTheme.behavior ?? defaults.behavior!;
    final double? width = widget.width ?? snackBarTheme.width;
    assert(() {
      // Whether the behavior is set through the constructor or the theme,
      // assert that other properties are configured properly.
      if (snackBarBehavior != SnackBarBehavior.floating) {
        String message(String parameter) {
          final prefix = '$parameter can only be used with floating behavior.';
          if (widget.behavior != null) {
            return '$prefix SnackBarBehavior.fixed was set in the SnackBar constructor.';
          } else if (snackBarTheme.behavior != null) {
            return '$prefix SnackBarBehavior.fixed was set by the inherited SnackBarThemeData.';
          } else {
            return '$prefix SnackBarBehavior.fixed was set by default.';
          }
        }

        assert(widget.margin == null, message('Margin'));
        assert(width == null, message('Width'));
      }
      return true;
    }());

    final bool showCloseIcon = widget.showCloseIcon ?? snackBarTheme.showCloseIcon ?? defaults.showCloseIcon!;

    final isFloatingSnackBar = snackBarBehavior == SnackBarBehavior.floating;
    final horizontalPadding = isFloatingSnackBar ? 16.0 : 24.0;
    final EdgeInsetsGeometry padding =
        widget.padding ??
        EdgeInsetsDirectional.only(
          start: horizontalPadding,
          end: widget.action != null || showCloseIcon ? 0 : horizontalPadding,
        );

    final double iconHorizontalMargin = (widget.padding?.resolve(TextDirection.ltr).right ?? horizontalPadding) / 12.0;

    final IconButton? iconButton = showCloseIcon
        ? IconButton(
            key: StandardComponentType.closeButton.key,
            icon: const Icon(Icons.close),
            iconSize: 24.0,
            color: widget.closeIconColor ?? snackBarTheme.closeIconColor ?? defaults.closeIconColor,
            onPressed: () => ScaffoldMessenger.of(
              context,
            ).hideCurrentSnackBar(reason: SnackBarClosedReason.dismiss),
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
          )
        : null;

    final EdgeInsets margin = widget.margin?.resolve(TextDirection.ltr) ?? snackBarTheme.insetPadding ?? defaults.insetPadding!;

    Widget snackBar = Padding(
      padding: padding,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              padding: widget.action != null ? null : const EdgeInsets.symmetric(vertical: _singleLineVerticalPadding),
              child: DefaultTextStyle(
                style: contentTextStyle!,
                child: widget.content,
              ),
            ),
          ),
          if (widget.action != null)
            TextButtonTheme(
              data: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: buttonColor,
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                ),
              ),
              child: widget.action!,
            ),
          if (showCloseIcon)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: iconHorizontalMargin),
              child: iconButton,
            ),
        ],
      ),
    );

    if (!isFloatingSnackBar) {
      snackBar = SafeArea(top: false, child: snackBar);
    }

    final double elevation = widget.elevation ?? snackBarTheme.elevation ?? defaults.elevation!;
    final Color backgroundColor = widget.backgroundColor ?? snackBarTheme.backgroundColor ?? defaults.backgroundColor!;
    final ShapeBorder? shape = widget.shape ?? snackBarTheme.shape ?? (isFloatingSnackBar ? defaults.shape : null);
    final DismissDirection dismissDirection = widget.dismissDirection ?? snackBarTheme.dismissDirection ?? DismissDirection.down;

    snackBar = Material(
      shape: shape,
      elevation: elevation,
      color: backgroundColor,
      clipBehavior: widget.clipBehavior,
      child: Theme(
        data: effectiveTheme,
        child: accessibleNavigation || theme.useMaterial3 ? snackBar : FadeTransition(opacity: _fadeOutAnimation!, child: snackBar),
      ),
    );

    if (isFloatingSnackBar) {
      // If width is provided, do not include horizontal margins.
      if (width != null) {
        snackBar = Padding(
          padding: EdgeInsets.only(top: margin.top, bottom: margin.bottom),
          child: SizedBox(width: width, child: snackBar),
        );
      } else {
        snackBar = Padding(padding: margin, child: snackBar);
      }
      snackBar = SafeArea(top: false, bottom: false, child: snackBar);
    }

    snackBar = Semantics(
      container: true,
      liveRegion: true,
      onDismiss: widget.onDismiss,
      child: Dismissible(
        key: _dismissibleKey,
        direction: dismissDirection,
        resizeDuration: null,
        behavior: widget.hitTestBehavior ?? (widget.margin != null || snackBarTheme.insetPadding != null ? HitTestBehavior.deferToChild : HitTestBehavior.opaque),
        onDismissed: (direction) => widget.onDismiss(),
        child: snackBar,
      ),
    );

    final Widget snackBarTransition;
    if (accessibleNavigation) {
      snackBarTransition = snackBar;
    } else if (isFloatingSnackBar && !theme.useMaterial3) {
      snackBarTransition = FadeTransition(opacity: _fadeInAnimation!, child: snackBar);
      // Is Material 3 Floating Snack Bar.
    } else if (isFloatingSnackBar && theme.useMaterial3) {
      snackBarTransition = FadeTransition(
        opacity: _fadeInM3Animation!,
        child: ValueListenableBuilder<double>(
          valueListenable: _heightM3Animation!,
          builder: (context, value, child) {
            return Align(alignment: Alignment.bottomLeft, heightFactor: value, child: child);
          },
          child: snackBar,
        ),
      );
    } else {
      snackBarTransition = ValueListenableBuilder<double>(
        valueListenable: _heightAnimation!,
        builder: (context, value, child) {
          return Align(alignment: AlignmentDirectional.topStart, heightFactor: value, child: child);
        },
        child: snackBar,
      );
    }

    return Hero(
      tag: '<SnackBar Hero tag - ${widget.content}>',
      transitionOnUserGestures: true,
      child: ClipRect(clipBehavior: widget.clipBehavior, child: snackBarTransition),
    );
  }
}

// BEGIN GENERATED TOKEN PROPERTIES - Snackbar

// Do not edit by hand. The code between the "BEGIN GENERATED" and
// "END GENERATED" comments are generated from data in the Material
// Design token database by the script:
//   dev/tools/gen_defaults/bin/gen_defaults.dart.

// dart format off
class _SnackbarDefaultsM3 extends SnackBarThemeData {
  _SnackbarDefaultsM3(this.context);

  final BuildContext context;
  late final ThemeData _theme = Theme.of(context);
  late final ColorScheme _colors = _theme.colorScheme;

  @override
  Color get backgroundColor => _colors.inverseSurface;

  @override
  Color get actionTextColor =>
      WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return _colors.inversePrimary;
        }
        if (states.contains(WidgetState.pressed)) {
          return _colors.inversePrimary;
        }
        if (states.contains(WidgetState.hovered)) {
          return _colors.inversePrimary;
        }
        if (states.contains(WidgetState.focused)) {
          return _colors.inversePrimary;
        }
        return _colors.inversePrimary;
      });

  @override
  Color get disabledActionTextColor =>
      _colors.inversePrimary;


  @override
  TextStyle get contentTextStyle =>
      Theme
          .of(context)
          .textTheme
          .bodyMedium!
          .copyWith
        (color: _colors.onInverseSurface,
      );

  @override
  double get elevation => 6.0;

  @override
  ShapeBorder get shape => const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4.0)));

  @override
  SnackBarBehavior get behavior => SnackBarBehavior.fixed;

  @override
  EdgeInsets get insetPadding => const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 10.0);

  @override
  bool get showCloseIcon => false;

  @override
  Color? get closeIconColor => _colors.onInverseSurface;

  @override
  double get actionOverflowThreshold => 0.25;
}
// dart format on

// END GENERATED TOKEN PROPERTIES - Snackbar
