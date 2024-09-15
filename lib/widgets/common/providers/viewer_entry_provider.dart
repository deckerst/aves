import 'package:aves/model/entry/entry.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class ViewerEntryProvider extends ListenableProvider<ViewerEntryNotifier> {
  ViewerEntryProvider({
    super.key,
    super.child,
  }) : super(
          create: (context) => ViewerEntryNotifier(null),
          dispose: (context, value) => value.dispose(),
        );
}

class ViewerEntryNotifier extends ValueNotifier<AvesEntry?> {
  ViewerEntryNotifier(super.value);
}
