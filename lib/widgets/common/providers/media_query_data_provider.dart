import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class const MediaQueryDataProvider({
  super.key,
  final MediaQueryData? value,
  required final Widget child,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider<MediaQueryData>.value(
      value: value ?? MediaQuery.of(context),
      child: child,
    );
  }
}
