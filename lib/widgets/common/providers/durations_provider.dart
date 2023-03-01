import 'package:aves/model/settings/enums/accessibility_animations.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/durations.dart';
import 'package:provider/provider.dart';

class DurationsProvider extends ProxyProvider<Settings, DurationsData> {
  DurationsProvider({
    super.key,
    super.child,
  }) : super(
          update: (context, settings, __) {
            final enabled = settings.accessibilityAnimations.animate;
            return enabled ? DurationsData() : DurationsData.noAnimation();
          },
        );
}
