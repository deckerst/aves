import 'dart:async';

import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/themes.dart';
import 'package:aves/widgets/aves_app.dart';
import 'package:aves/widgets/common/fx/blurred.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class const AvesFloatingBar({
  super.key,
  required final EdgeInsets margin,
  required final Widget Function(BuildContext context, Color backgroundColor, Widget? child) builder,
  final Widget? child,
}) extends StatefulWidget {
  static const borderRadius = BorderRadius.all(Radius.circular(8));

  @override
  State<AvesFloatingBar> createState() => _AvesFloatingBarState();
}

class _AvesFloatingBarState extends State<AvesFloatingBar> with RouteAware {
  // prevent expensive blurring when the current page is hidden
  final ValueNotifier<bool> _isBlurAllowedNotifier = ValueNotifier(true);
  Timer? _blurBlockTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      AvesApp.pageRouteObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    AvesApp.pageRouteObserver.unsubscribe(this);
    _isBlurAllowedNotifier.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    // post to prevent single frame flash during hero
    _blurBlockTimer?.cancel();
    _blurBlockTimer = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _isBlurAllowedNotifier.value = true;
    });
  }

  @override
  void didPushNext() {
    // delay blur disabling, otherwise visual artifacts appear during page transition with Impeller
    _blurBlockTimer?.cancel();
    _blurBlockTimer = Timer(ADurations.pageTransitionLoose, () {
      if (mounted) {
        _isBlurAllowedNotifier.value = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = theme.appBarTheme.backgroundColor ?? Themes.firstLayerColor(context);
    return ValueListenableBuilder<bool>(
      valueListenable: _isBlurAllowedNotifier,
      builder: (context, isBlurAllowed, child) {
        final blurred = isBlurAllowed && context.select<Settings, bool>((v) => v.enableBlurEffect);
        return Container(
          foregroundDecoration: BoxDecoration(
            border: Border.all(
              color: theme.dividerColor,
            ),
            borderRadius: AvesFloatingBar.borderRadius,
          ),
          margin: widget.margin,
          child: BlurredRRect(
            enabled: blurred,
            borderRadius: AvesFloatingBar.borderRadius,
            child: widget.builder(
              context,
              blurred ? backgroundColor.withValues(alpha: .85) : backgroundColor,
              widget.child,
            ),
          ),
        );
      },
    );
  }
}
