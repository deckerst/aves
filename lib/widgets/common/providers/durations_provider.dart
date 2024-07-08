import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/durations.dart';
import 'package:provider/provider.dart';

class DurationsProvider extends ProxyProvider<Settings, DurationsData> {
  DurationsProvider({
    super.key,
    super.child,
  }) : super(
          update: (context, settings, __) {
            return settings.animate ? DurationsData() : DurationsData.noAnimation();
          },
        );
}
