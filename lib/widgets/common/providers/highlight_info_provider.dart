import 'package:aves/model/highlight.dart';
import 'package:provider/provider.dart';

class HighlightInfoProvider extends ChangeNotifierProvider<HighlightInfo> {
  new({
    super.key,
    super.child,
  }) : super(
         create: (context) => HighlightInfo(),
       );
}
