import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:flutter/material.dart';

// adapted from Flutter `SnackBar` in `/material/snack_bar.dart`

// As of Flutter v3.0.1, `SnackBar` is not customizable enough to add margin
// and ignore pointers in that area, so we use an overlay entry instead.
// This overlay entry is not below a `Scaffold` (which is expected by `SnackBar`
// and `SnackBarAction`), and is not dismissed the same way.
// This adaptation assumes the `SnackBarBehavior.floating` behavior and no animation.
class OverlaySnackBar extends StatefulWidget {
  final Widget content;
  final Widget? action;
  final DismissDirection dismissDirection;
  final VoidCallback onDismiss;
  final Clip clipBehavior;

  const OverlaySnackBar({
    super.key,
    required this.content,
    this.action,
    this.dismissDirection = DismissDirection.down,
    this.clipBehavior = Clip.hardEdge,
    required this.onDismiss,
  });

  @override
  State<OverlaySnackBar> createState() => _OverlaySnackBarState();
}

class _OverlaySnackBarState extends State<OverlaySnackBar> {
  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final SnackBarThemeData snackBarTheme = theme.snackBarTheme;
    final bool isThemeDark = theme.brightness == Brightness.dark;
    final Color buttonColor = isThemeDark ? colorScheme.primary : colorScheme.secondary;
    final SnackBarThemeData defaults = theme.useMaterial3 ? _SnackbarDefaultsM3(context) : _SnackbarDefaultsM2(context);

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
              background: defaults.backgroundColor!,
              error: colorScheme.onError,
              onPrimary: colorScheme.primary,
              onSecondary: colorScheme.secondary,
              onSurface: colorScheme.surface,
              onBackground: colorScheme.background,
              onError: colorScheme.error,
              brightness: brightness,
            ),
          );

    final TextStyle? contentTextStyle = snackBarTheme.contentTextStyle ?? defaults.contentTextStyle;

    final horizontalPadding = FeedbackMixin.snackBarHorizontalPadding(snackBarTheme);
    final padding = EdgeInsetsDirectional.only(start: horizontalPadding, end: widget.action != null ? 0 : horizontalPadding);
    const singleLineVerticalPadding = 14.0;

    final EdgeInsets margin = snackBarTheme.insetPadding ?? defaults.insetPadding!;

    Widget snackBar = Padding(
      padding: padding,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              padding: widget.action != null ? null : const EdgeInsets.symmetric(vertical: singleLineVerticalPadding),
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
        ],
      ),
    );

    final double elevation = snackBarTheme.elevation ?? defaults.elevation!;
    final Color backgroundColor = snackBarTheme.backgroundColor ?? defaults.backgroundColor!;
    final ShapeBorder? shape = snackBarTheme.shape ?? defaults.shape;

    snackBar = Material(
      shape: shape,
      elevation: elevation,
      color: backgroundColor,
      child: Theme(
        data: effectiveTheme,
        child: snackBar,
      ),
    );

    snackBar = Padding(
      padding: margin,
      child: snackBar,
    );

    snackBar = SafeArea(
      top: false,
      bottom: false,
      child: snackBar,
    );

    snackBar = Semantics(
      container: true,
      liveRegion: true,
      onDismiss: widget.onDismiss,
      child: Dismissible(
        key: const Key('dismissible'),
        direction: widget.dismissDirection,
        resizeDuration: null,
        onDismissed: (direction) => widget.onDismiss(),
        child: snackBar,
      ),
    );

    final Widget snackBarTransition = snackBar;

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

// Hand coded defaults based on Material Design 2.
class _SnackbarDefaultsM2 extends SnackBarThemeData {
  _SnackbarDefaultsM2(BuildContext context)
      : _theme = Theme.of(context),
        _colors = Theme.of(context).colorScheme,
        super(elevation: 6.0);

  late final ThemeData _theme;
  late final ColorScheme _colors;

  @override
  Color get backgroundColor => _theme.brightness == Brightness.light ? Color.alphaBlend(_colors.onSurface.withOpacity(0.80), _colors.surface) : _colors.onSurface;

  @override
  TextStyle? get contentTextStyle => ThemeData(brightness: _theme.brightness == Brightness.light ? Brightness.dark : Brightness.light).textTheme.titleMedium;

  @override
  SnackBarBehavior get behavior => SnackBarBehavior.fixed;

  @override
  Color get actionTextColor => _colors.secondary;

  @override
  Color get disabledActionTextColor => _colors.onSurface.withOpacity(_theme.brightness == Brightness.light ? 0.38 : 0.3);

  @override
  ShapeBorder get shape => const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(4.0),
        ),
      );

  @override
  EdgeInsets get insetPadding => const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 10.0);

  @override
  bool get showCloseIcon => false;

  @override
  Color get closeIconColor => _colors.onSurface;

  @override
  double get actionOverflowThreshold => 0.25;
}

// BEGIN GENERATED TOKEN PROPERTIES - Snackbar

// Do not edit by hand. The code between the "BEGIN GENERATED" and
// "END GENERATED" comments are generated from data in the Material
// Design token database by the script:
//   dev/tools/gen_defaults/bin/gen_defaults.dart.

// Token database version: v0_162

class _SnackbarDefaultsM3 extends SnackBarThemeData {
  _SnackbarDefaultsM3(this.context);

  final BuildContext context;
  late final ThemeData _theme = Theme.of(context);
  late final ColorScheme _colors = _theme.colorScheme;

  @override
  Color get backgroundColor => _colors.inverseSurface;

  @override
  Color get actionTextColor => MaterialStateColor.resolveWith((states) {
        if (states.contains(MaterialState.disabled)) {
          return _colors.inversePrimary;
        }
        if (states.contains(MaterialState.pressed)) {
          return _colors.inversePrimary;
        }
        if (states.contains(MaterialState.hovered)) {
          return _colors.inversePrimary;
        }
        if (states.contains(MaterialState.focused)) {
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
