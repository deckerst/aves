import 'package:aves/model/highlight.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class HighlightInfoProvider extends StatelessWidget {
  final Widget child;

  const HighlightInfoProvider({required this.child});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HighlightInfo>(
      create: (context) => HighlightInfo(),
      child: child,
    );
  }
}
