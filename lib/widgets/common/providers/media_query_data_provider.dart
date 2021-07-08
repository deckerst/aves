import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class MediaQueryDataProvider extends StatelessWidget {
  final Widget child;

  const MediaQueryDataProvider({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider<MediaQueryData>.value(
      value: MediaQuery.of(context),
      child: child,
    );
  }
}
