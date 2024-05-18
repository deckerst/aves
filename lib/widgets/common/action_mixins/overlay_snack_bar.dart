import 'package:aves/widgets/common/extensions/theme.dart';
import 'package:flutter/material.dart';

// adapted from Flutter `SnackBar` in `/material/snack_bar.dart`

// As of Flutter v3.0.1, `SnackBar` is not customizable enough to add margin
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
  final Widget content;
  final Color? backgroundColor;
  final double? elevation;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final ShapeBorder? shape;
  final HitTestBehavior? hitTestBehavior;
  final SnackBarBehavior? behavior;
  final Widget? action;
  final double? actionOverflowThreshold;
  final bool? showCloseIcon;
  final Color? closeIconColor;
  final Duration duration;
  final Animation<double>? animation;
  final VoidCallback? onVisible;
  final DismissDirection dismissDirection;
  final Clip clipBehavior;
  final VoidCallback onDismiss;

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
    this.animation,
    this.onVisible,
    this.dismissDirection = DismissDirection.down,
    this.clipBehavior = Clip.hardEdge,
    required this.onDismiss,
  })  : assert(elevation == null || elevation >= 0.0),
        assert(
          width == null || margin == null,
          'Width and margin can not be used together',
        ),
        assert(actionOverflowThreshold == null || (actionOverflowThreshold >= 0 && actionOverflowThreshold <= 1), 'Action overflow threshold must be between 0 and 1 inclusive');

  @override
  State<OverlaySnackBar> createState() => _OverlaySnackBarState();
}

class _OverlaySnackBarState extends State<OverlaySnackBar> {
  bool _wasVisible = false;

  @override
  void initState() {
    super.initState();
    widget.animation!.addStatusListener(_onAnimationStatusChanged);
  }

  @override
  void didUpdateWidget(OverlaySnackBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animation != oldWidget.animation) {
      oldWidget.animation!.removeStatusListener(_onAnimationStatusChanged);
      widget.animation!.addStatusListener(_onAnimationStatusChanged);
    }
  }

  @override
  void dispose() {
    widget.animation!.removeStatusListener(_onAnimationStatusChanged);
    super.dispose();
  }

  void _onAnimationStatusChanged(AnimationStatus animationStatus) {
    switch (animationStatus) {
      case AnimationStatus.dismissed:
      case AnimationStatus.forward:
      case AnimationStatus.reverse:
        break;
      case AnimationStatus.completed:
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
    final SnackBarThemeData snackBarTheme = theme.snackBarTheme;
    final bool isThemeDark = theme.isDark;
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
      // assert that our other properties are configured properly.
      if (snackBarBehavior != SnackBarBehavior.floating) {
        String message(String parameter) {
          final String prefix = '$parameter can only be used with floating behavior.';
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

    final bool isFloatingSnackBar = snackBarBehavior == SnackBarBehavior.floating;
    final double horizontalPadding = isFloatingSnackBar ? 16.0 : 24.0;
    final EdgeInsetsGeometry padding = widget.padding ?? EdgeInsetsDirectional.only(start: horizontalPadding, end: widget.action != null || showCloseIcon ? 0 : horizontalPadding);

    final double iconHorizontalMargin = (widget.padding?.resolve(TextDirection.ltr).right ?? horizontalPadding) / 12.0;

    final CurvedAnimation heightAnimation = CurvedAnimation(parent: widget.animation!, curve: _snackBarHeightCurve);
    final CurvedAnimation fadeInAnimation = CurvedAnimation(parent: widget.animation!, curve: _snackBarFadeInCurve);
    final CurvedAnimation fadeInM3Animation = CurvedAnimation(parent: widget.animation!, curve: _snackBarM3FadeInCurve);

    final CurvedAnimation fadeOutAnimation = CurvedAnimation(
      parent: widget.animation!,
      curve: _snackBarFadeOutCurve,
      reverseCurve: const Threshold(0.0),
    );
    // Material 3 Animation has a height animation on entry, but a direct fade out on exit.
    final CurvedAnimation heightM3Animation = CurvedAnimation(
      parent: widget.animation!,
      curve: _snackBarM3HeightCurve,
      reverseCurve: const Threshold(0.0),
    );

    final IconButton? iconButton = showCloseIcon
        ? IconButton(
            icon: const Icon(Icons.close),
            iconSize: 24.0,
            color: widget.closeIconColor ?? snackBarTheme.closeIconColor ?? defaults.closeIconColor,
            onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(reason: SnackBarClosedReason.dismiss),
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
      snackBar = SafeArea(
        top: false,
        child: snackBar,
      );
    }

    final double elevation = widget.elevation ?? snackBarTheme.elevation ?? defaults.elevation!;
    final Color backgroundColor = widget.backgroundColor ?? snackBarTheme.backgroundColor ?? defaults.backgroundColor!;
    final ShapeBorder? shape = widget.shape ?? snackBarTheme.shape ?? (isFloatingSnackBar ? defaults.shape : null);

    snackBar = Material(
      shape: shape,
      elevation: elevation,
      color: backgroundColor,
      clipBehavior: widget.clipBehavior,
      child: Theme(
        data: effectiveTheme,
        child: accessibleNavigation || theme.useMaterial3
            ? snackBar
            : FadeTransition(
                opacity: fadeOutAnimation,
                child: snackBar,
              ),
      ),
    );

    if (isFloatingSnackBar) {
      // If width is provided, do not include horizontal margins.
      if (width != null) {
        snackBar = Container(
          margin: EdgeInsets.only(top: margin.top, bottom: margin.bottom),
          width: width,
          child: snackBar,
        );
      } else {
        snackBar = Padding(
          padding: margin,
          child: snackBar,
        );
      }
      snackBar = SafeArea(
        top: false,
        bottom: false,
        child: snackBar,
      );
    }

    snackBar = Semantics(
      container: true,
      liveRegion: true,
      onDismiss: widget.onDismiss,
      child: Dismissible(
        key: const Key('dismissible'),
        direction: widget.dismissDirection,
        resizeDuration: null,
        behavior: widget.hitTestBehavior ?? (widget.margin != null ? HitTestBehavior.deferToChild : HitTestBehavior.opaque),
        onDismissed: (direction) => widget.onDismiss(),
        child: snackBar,
      ),
    );

    final Widget snackBarTransition;
    if (accessibleNavigation) {
      snackBarTransition = snackBar;
    } else if (isFloatingSnackBar && !theme.useMaterial3) {
      snackBarTransition = FadeTransition(
        opacity: fadeInAnimation,
        child: snackBar,
      );
      // Is Material 3 Floating Snack Bar.
    } else if (isFloatingSnackBar && theme.useMaterial3) {
      snackBarTransition = FadeTransition(
        opacity: fadeInM3Animation,
        child: AnimatedBuilder(
          animation: heightM3Animation,
          builder: (context, child) {
            return Align(
              alignment: AlignmentDirectional.bottomStart,
              heightFactor: heightM3Animation.value,
              child: child,
            );
          },
          child: snackBar,
        ),
      );
    } else {
      snackBarTransition = AnimatedBuilder(
        animation: heightAnimation,
        builder: (context, child) {
          return Align(
            alignment: AlignmentDirectional.topStart,
            heightFactor: heightAnimation.value,
            child: child,
          );
        },
        child: snackBar,
      );
    }

    return Hero(
      tag: '<SnackBar Hero tag - ${widget.content}>',
      transitionOnUserGestures: true,
      child: ClipRect(
        clipBehavior: widget.clipBehavior,
        child: snackBarTransition,
      ),
    );
  }
}

// BEGIN GENERATED TOKEN PROPERTIES - Snackbar

// Do not edit by hand. The code between the "BEGIN GENERATED" and
// "END GENERATED" comments are generated from data in the Material
// Design token database by the script:
//   dev/tools/gen_defaults/bin/gen_defaults.dart.

class _SnackbarDefaultsM3 extends SnackBarThemeData {
  _SnackbarDefaultsM3(this.context);

  final BuildContext context;
  late final ThemeData _theme = Theme.of(context);
  late final ColorScheme _colors = _theme.colorScheme;

  @override
  Color get backgroundColor => _colors.inverseSurface;

  @override
  Color get actionTextColor => WidgetStateColor.resolveWith((states) {
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
  Color get disabledActionTextColor => _colors.inversePrimary;

  @override
  TextStyle get contentTextStyle => Theme.of(context).textTheme.bodyMedium!.copyWith(
        color: _colors.onInverseSurface,
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

// END GENERATED TOKEN PROPERTIES - Snackbar
