import 'package:aves/model/settings/settings.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class SettingsProvider extends StatelessWidget {
  final Widget child;

  const SettingsProvider({@required this.child});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Settings>.value(
      value: settings,
      child: child,
    );
  }
}
