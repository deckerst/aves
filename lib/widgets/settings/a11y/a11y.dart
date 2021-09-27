import 'package:aves/theme/icons.dart';
import 'package:aves/utils/color_utils.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:aves/widgets/settings/a11y/time_to_take_action.dart';
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
        icon: AIcons.a11y,
        color: stringToColor('Accessibility'),
      ),
      title: context.l10n.settingsSectionAccessibility,
      expandedNotifier: expandedNotifier,
      showHighlight: false,
      children: const [
        TimeToTakeActionTile(),
      ],
    );
  }
}
