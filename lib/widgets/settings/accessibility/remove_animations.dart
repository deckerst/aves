import 'package:aves/model/settings/enums/accessibility_animations.dart';
import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_selection_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

class RemoveAnimationsTile extends StatelessWidget {
  const RemoveAnimationsTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentAnimations = context.select<Settings, AccessibilityAnimations>((s) => s.accessibilityAnimations);

    return ListTile(
      title: Text(context.l10n.settingsRemoveAnimationsTile),
      subtitle: Text(currentAnimations.getName(context)),
      onTap: () async {
        final value = await showDialog<AccessibilityAnimations>(
          context: context,
          builder: (context) => AvesSelectionDialog<AccessibilityAnimations>(
            initialValue: currentAnimations,
            options: Map.fromEntries(AccessibilityAnimations.values.map((v) => MapEntry(v, v.getName(context)))),
            title: context.l10n.settingsRemoveAnimationsTitle,
          ),
        );
        // wait for the dialog to hide as applying the change may block the UI
        await Future.delayed(Durations.dialogTransitionAnimation * timeDilation);
        if (value != null) {
          settings.accessibilityAnimations = value;
        }
      },
    );
  }
}
