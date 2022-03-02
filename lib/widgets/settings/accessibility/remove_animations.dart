import 'package:aves/model/settings/enums/accessibility_animations.dart';
import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_selection_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RemoveAnimationsTile extends StatelessWidget {
  const RemoveAnimationsTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentAnimations = context.select<Settings, AccessibilityAnimations>((s) => s.accessibilityAnimations);

    return ListTile(
      title: Text(context.l10n.settingsRemoveAnimationsTile),
      subtitle: Text(currentAnimations.getName(context)),
      onTap: () => showSelectionDialog<AccessibilityAnimations>(
        context: context,
        builder: (context) => AvesSelectionDialog<AccessibilityAnimations>(
          initialValue: currentAnimations,
          options: Map.fromEntries(AccessibilityAnimations.values.map((v) => MapEntry(v, v.getName(context)))),
          title: context.l10n.settingsRemoveAnimationsTitle,
        ),
        onSelection: (v) => settings.accessibilityAnimations = v,
      ),
    );
  }
}
