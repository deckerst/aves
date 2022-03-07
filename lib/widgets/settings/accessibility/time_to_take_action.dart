import 'package:aves/model/settings/enums/accessibility_timeout.dart';
import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/services/accessibility_service.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_selection_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TimeToTakeActionTile extends StatefulWidget {
  const TimeToTakeActionTile({Key? key}) : super(key: key);

  @override
  State<TimeToTakeActionTile> createState() => _TimeToTakeActionTileState();
}

class _TimeToTakeActionTileState extends State<TimeToTakeActionTile> {
  late Future<bool> _hasSystemOptionLoader;

  @override
  void initState() {
    super.initState();
    _hasSystemOptionLoader = AccessibilityService.hasRecommendedTimeouts();
  }

  @override
  Widget build(BuildContext context) {
    final currentTimeToTakeAction = context.select<Settings, AccessibilityTimeout>((s) => s.timeToTakeAction);

    return FutureBuilder<bool>(
      future: _hasSystemOptionLoader,
      builder: (context, snapshot) {
        if (snapshot.hasError || !snapshot.hasData) return const SizedBox.shrink();
        final hasSystemOption = snapshot.data!;
        final optionValues = hasSystemOption ? AccessibilityTimeout.values : AccessibilityTimeout.values.where((v) => v != AccessibilityTimeout.system).toList();
        return ListTile(
          title: Text(context.l10n.settingsTimeToTakeActionTile),
          subtitle: Text(currentTimeToTakeAction.getName(context)),
          onTap: () => showSelectionDialog<AccessibilityTimeout>(
            context: context,
            builder: (context) => AvesSelectionDialog<AccessibilityTimeout>(
              initialValue: currentTimeToTakeAction,
              options: Map.fromEntries(optionValues.map((v) => MapEntry(v, v.getName(context)))),
              title: context.l10n.settingsTimeToTakeActionTitle,
            ),
            onSelection: (v) => settings.timeToTakeAction = v,
          ),
        );
      },
    );
  }
}
