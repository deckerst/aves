import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class FilterGroupProvider extends ListenableProvider<FilterGroupNotifier> {
  FilterGroupProvider({
    super.key,
    super.child,
  }) : super(
          create: (context) => FilterGroupNotifier(null),
          dispose: (context, value) => value.dispose(),
        );
}

class FilterGroupNotifier extends ValueNotifier<Uri?> {
  FilterGroupNotifier(super.value);
}
