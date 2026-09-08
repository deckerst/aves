import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/dialogs/selection_dialogs/single_selection.dart';
import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';

Future<void> showSelectionDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  required void Function(T value) onSelection,
}) async {
  final value = await showAvesDialog<T>(
    context: context,
    builder: builder,
    routeSettings: const RouteSettings(name: AvesSingleSelectionDialog.routeName),
  );
  // wait for the dialog to hide
  await Future.delayed(ADurations.dialogTransitionLoose * timeDilation);
  if (value != null) {
    onSelection(value);
  }
}

typedef TextBuilder<T> = String? Function(T value);
