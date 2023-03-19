import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/basic/font_size_icon_theme.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/material.dart';

class DrawerEditorBanner extends StatelessWidget {
  const DrawerEditorBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const FontSizeIconTheme(child: Icon(AIcons.info)),
          const SizedBox(width: 16),
          Expanded(child: Text(context.l10n.settingsNavigationDrawerBanner)),
        ],
      ),
    );
  }
}
