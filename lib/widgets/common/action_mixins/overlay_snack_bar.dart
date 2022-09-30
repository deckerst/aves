import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:flutter/material.dart';

// adapted from Flutter `SnackBar` in `/material/snack_bar.dart`

// As of Flutter v3.0.1, `SnackBar` is not customizable enough to add margin
// and ignore pointers in that area, so we use an overlay entry instead.
// This overlay entry is not below a `Scaffold` (which is expected by `SnackBar`
// and `SnackBarAction`), and is not dismissed the same way.
// This adaptation assumes the `SnackBarBehavior.floating` behavior and no animation.
class OverlaySnackBar extends StatelessWidget {
  final Widget content;
  final Widget? action;
  final DismissDirection dismissDirection;
  final VoidCallback onDismiss;

  const OverlaySnackBar({
    super.key,
    required this.content,
    required this.action,
    required this.dismissDirection,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final snackBarTheme = theme.snackBarTheme;
    final isThemeDark = theme.brightness == Brightness.dark;
    final buttonColor = isThemeDark ? colorScheme.primary : colorScheme.secondary;

    final brightness = isThemeDark ? Brightness.light : Brightness.dark;
    final themeBackgroundColor = isThemeDark ? colorScheme.onSurface : Color.alphaBlend(colorScheme.onSurface.withOpacity(0.80), colorScheme.surface);
    final inverseTheme = theme.copyWith(
      colorScheme: ColorScheme(
        primary: colorScheme.onPrimary,
        secondary: buttonColor,
        surface: colorScheme.onSurface,
        background: themeBackgroundColor,
        error: colorScheme.onError,
        onPrimary: colorScheme.primary,
        onSecondary: colorScheme.secondary,
        onSurface: colorScheme.surface,
        onBackground: colorScheme.background,
        onError: colorScheme.error,
        brightness: brightness,
      ),
    );

    final contentTextStyle = snackBarTheme.contentTextStyle ?? ThemeData(brightness: brightness).textTheme.titleMedium;

    final horizontalPadding = FeedbackMixin.snackBarHorizontalPadding(snackBarTheme);
    final padding = EdgeInsetsDirectional.only(start: horizontalPadding, end: action != null ? 0 : horizontalPadding);
    const singleLineVerticalPadding = 14.0;

    Widget snackBar = Padding(
      padding: padding,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              padding: action != null ? null : const EdgeInsets.symmetric(vertical: singleLineVerticalPadding),
              child: DefaultTextStyle(
                style: contentTextStyle!,
                child: content,
              ),
            ),
          ),
          if (action != null)
            TextButtonTheme(
              data: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: buttonColor,
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                ),
              ),
              child: action!,
            ),
        ],
      ),
    );

    final elevation = snackBarTheme.elevation ?? 6.0;
    final backgroundColor = snackBarTheme.backgroundColor ?? inverseTheme.colorScheme.background;
    final shape = snackBarTheme.shape ?? const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4.0)));

    snackBar = Material(
      shape: shape,
      elevation: elevation,
      color: backgroundColor,
      child: Theme(
        data: inverseTheme,
        child: snackBar,
      ),
    );

    const topMargin = 5.0;
    const bottomMargin = 10.0;
    const horizontalMargin = 15.0;
    snackBar = Padding(
      padding: const EdgeInsets.fromLTRB(
        horizontalMargin,
        topMargin,
        horizontalMargin,
        bottomMargin,
      ),
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
      onDismiss: onDismiss,
      child: Dismissible(
        key: const Key('dismissible'),
        direction: dismissDirection,
        resizeDuration: null,
        onDismissed: (direction) => onDismiss(),
        child: snackBar,
      ),
    );

    return snackBar;
  }
}
