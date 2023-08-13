import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/view_state.dart';
import 'package:aves/widgets/viewer/view/histogram.dart';
import 'package:flutter/material.dart';

class ViewStateController with HistogramMixin {
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
