import 'package:aves/model/settings/enums/accessibility_animations.dart';
import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:aves/widgets/settings/accessibility/time_to_take_action.dart';
import 'package:aves/widgets/settings/common/tile_leading.dart';
import 'package:aves/widgets/settings/common/tiles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccessibilitySection extends StatelessWidget {
  final ValueNotifier<String?> expandedNotifier;

  const AccessibilitySection({
    Key? key,
    required this.expandedNotifier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AvesExpansionTile(
      leading: SettingsTileLeading(
        icon: AIcons.accessibility,
        color: context.select<AvesColorsData, Color>((v) => v.accessibility),
      ),
      title: context.l10n.settingsSectionAccessibility,
      expandedNotifier: expandedNotifier,
      showHighlight: false,
      children: [
        SettingsSelectionListTile<AccessibilityAnimations>(
          values: AccessibilityAnimations.values,
          getName: (context, v) => v.getName(context),
          selector: (context, s) => s.accessibilityAnimations,
          onSelection: (v) => settings.accessibilityAnimations = v,
          tileTitle: context.l10n.settingsRemoveAnimationsTile,
          dialogTitle: context.l10n.settingsRemoveAnimationsTitle,
        ),
        const TimeToTakeActionTile(),
      ],
    );
  }
}
