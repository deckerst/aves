import 'package:aves/model/highlight.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class HighlightInfoProvider extends StatelessWidget {
  final Widget child;

  const HighlightInfoProvider({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HighlightInfo>(
      create: (context) => HighlightInfo(),
      child: child,
    );
  }
}
