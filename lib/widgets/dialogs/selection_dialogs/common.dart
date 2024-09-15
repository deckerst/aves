import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/dialogs/selection_dialogs/single_selection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

Future<void> showSelectionDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  required void Function(T value) onSelection,
}) async {
  final value = await showDialog<T>(
    context: context,
    builder: builder,
    routeSettings: const RouteSettings(name: AvesSingleSelectionDialog.routeName),
  );
  // wait for the dialog to hide as applying the change may block the UI
  await Future.delayed(ADurations.dialogTransitionLoose * timeDilation);
  if (value != null) {
    onSelection(value);
  }
}

typedef TextBuilder<T> = String? Function(T value);
