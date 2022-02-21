import 'package:aves/theme/colors.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:aves/widgets/settings/accessibility/remove_animations.dart';
import 'package:aves/widgets/settings/accessibility/time_to_take_action.dart';
import 'package:aves/widgets/settings/common/tile_leading.dart';
import 'package:flutter/material.dart';

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
        color: AColors.accessibility,
      ),
      title: context.l10n.settingsSectionAccessibility,
      expandedNotifier: expandedNotifier,
      showHighlight: false,
      children: const [
        RemoveAnimationsTile(),
        TimeToTakeActionTile(),
      ],
    );
  }
}
