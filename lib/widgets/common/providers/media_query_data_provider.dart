import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class MediaQueryDataProvider extends StatelessWidget {
  final MediaQueryData? value;
  final Widget child;

  const MediaQueryDataProvider({
    super.key,
    this.value,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Provider<MediaQueryData>.value(
      value: value ?? MediaQuery.of(context),
      child: child,
    );
  }
}
