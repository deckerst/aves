import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

// `ChangeNotifier` wrapper to call `notify` without constraint
class AChangeNotifier extends ChangeNotifier {
  void notify() {
    // why is this protected?
    super.notifyListeners();
  }
}

// contrary to standard `ValueListenableBuilder`, this widget allows providing a null listenable
class NullableValueListenableBuilder<T> extends StatefulWidget {
  final ValueListenable<T?>? valueListenable;
  final ValueWidgetBuilder<T?> builder;
  final Widget? child;

  const NullableValueListenableBuilder({
    super.key,
    required this.valueListenable,
    required this.builder,
    this.child,
  });

  @override
  State<NullableValueListenableBuilder> createState() => _NullableValueListenableBuilderState<T>();
}

class _NullableValueListenableBuilderState<T> extends State<NullableValueListenableBuilder<T>> {
  ValueNotifier<T?>? _internalValueListenable;

  ValueListenable<T?> get _valueListenable {
    var listenable = widget.valueListenable;
    if (listenable == null) {
      _internalValueListenable ??= ValueNotifier(null);
      listenable = _internalValueListenable;
    }
    return listenable!;
  }

  @override
  void dispose() {
    _internalValueListenable?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<T?>(
      valueListenable: _valueListenable,
      builder: widget.builder,
      child: widget.child,
    );
  }
}
