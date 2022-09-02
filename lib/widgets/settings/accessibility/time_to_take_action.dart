import 'package:aves/model/settings/enums/accessibility_timeout.dart';
import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/services/accessibility_service.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/settings/common/tiles.dart';
import 'package:flutter/material.dart';

class TimeToTakeActionTile extends StatefulWidget {
  const TimeToTakeActionTile({super.key});

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
    return FutureBuilder<bool>(
      future: _hasSystemOptionLoader,
      builder: (context, snapshot) {
        if (snapshot.hasError || !snapshot.hasData) return const SizedBox();
        final hasSystemOption = snapshot.data!;
        final optionValues = hasSystemOption ? AccessibilityTimeout.values : AccessibilityTimeout.values.where((v) => v != AccessibilityTimeout.system).toList();

        return SettingsSelectionListTile<AccessibilityTimeout>(
          values: optionValues,
          getName: (context, v) => v.getName(context),
          selector: (context, s) => s.timeToTakeAction,
          onSelection: (v) => settings.timeToTakeAction = v,
          tileTitle: context.l10n.settingsTimeToTakeActionTile,
          dialogTitle: context.l10n.settingsTimeToTakeActionDialogTitle,
        );
      },
    );
  }
}
