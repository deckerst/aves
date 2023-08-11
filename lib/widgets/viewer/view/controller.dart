import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/view_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

class ViewStateController {
  final AvesEntry entry;
  final ValueNotifier<ViewState> viewStateNotifier;
  final ValueNotifier<ImageProvider?> fullImageNotifier = ValueNotifier(null);

  ViewState get viewState => viewStateNotifier.value;

  ViewStateController({
    required this.entry,
    required this.viewStateNotifier,
  });

  void dispose() {
    viewStateNotifier.dispose();
  }
}
