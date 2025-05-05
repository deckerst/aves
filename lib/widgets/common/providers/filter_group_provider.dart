import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class FilterGroupProvider extends ListenableProvider<FilterGroupNotifier> {
  FilterGroupProvider({
    super.key,
    Uri? initialValue,
    super.child,
  }) : super(
          create: (context) => FilterGroupNotifier(initialValue),
          dispose: (context, value) => value.dispose(),
        );
}

class FilterGroupNotifier extends ValueNotifier<Uri?> {
  FilterGroupNotifier(super.value);
}
