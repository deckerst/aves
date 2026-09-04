import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/viewer/view_state.dart';
import 'package:aves/widgets/viewer/view/histogram.dart';
import 'package:flutter/foundation.dart';
import 'package:leak_tracker/leak_tracker.dart';
import 'package:material_ui/material_ui.dart';

class ViewStateController with HistogramMixin {
  final AvesEntry entry;
  late final ValueNotifier<ViewState> viewStateNotifier;
  final ValueNotifier<ImageProvider?> fullImageNotifier = ValueNotifier(null);

  ViewState get viewState => viewStateNotifier.value;

  new({
    required this.entry,
    required ViewState initialViewState,
  }) {
    if (kFlutterMemoryAllocationsEnabled) {
      LeakTracking.dispatchObjectCreated(
        library: 'aves',
        className: '$ViewStateController',
        object: this,
      );
    }
    viewStateNotifier = ValueNotifier<ViewState>(initialViewState);
  }

  void dispose() {
    if (kFlutterMemoryAllocationsEnabled) {
      LeakTracking.dispatchObjectDisposed(object: this);
    }
    viewStateNotifier.dispose();
    fullImageNotifier.dispose();
  }
}
