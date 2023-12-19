import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';

class DebugColorSection extends StatefulWidget {
  const DebugColorSection({super.key});

  @override
  State<DebugColorSection> createState() => _DebugColorSectionState();
}

class _DebugColorSectionState extends State<DebugColorSection> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    final scheme = Theme.of(context).colorScheme;
    final List<(String, Color)> colors = [
      ('primary', scheme.primary),
      ('onPrimary', scheme.onPrimary),
      ('primaryContainer', scheme.primaryContainer),
      ('onPrimaryContainer', scheme.onPrimaryContainer),
      ('secondary', scheme.secondary),
      ('onSecondary', scheme.onSecondary),
      ('secondaryContainer', scheme.secondaryContainer),
      ('onSecondaryContainer', scheme.onSecondaryContainer),
      ('tertiary', scheme.tertiary),
      ('onTertiary', scheme.onTertiary),
      ('tertiaryContainer', scheme.tertiaryContainer),
      ('onTertiaryContainer', scheme.onTertiaryContainer),
      ('error', scheme.error),
      ('onError', scheme.onError),
      ('errorContainer', scheme.errorContainer),
      ('onErrorContainer', scheme.onErrorContainer),
      ('background', scheme.background),
      ('onBackground', scheme.onBackground),
      ('surface', scheme.surface),
      ('onSurface', scheme.onSurface),
      ('surfaceVariant', scheme.surfaceVariant),
      ('onSurfaceVariant', scheme.onSurfaceVariant),
      ('outline', scheme.outline),
      ('outlineVariant', scheme.outlineVariant),
      ('shadow', scheme.shadow),
      ('scrim', scheme.scrim),
      ('inverseSurface', scheme.inverseSurface),
      ('onInverseSurface', scheme.onInverseSurface),
      ('inversePrimary', scheme.inversePrimary),
      ('surfaceTint', scheme.surfaceTint),
    ];
    return AvesExpansionTile(
      title: 'Colors',
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: colors.map((kv) {
              final (text, color) = kv;
              return Row(
                children: [
                  Text(text),
                  const Spacer(),
                  Text(
                    color.hex,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 20,
                    height: 20,
                    color: color,
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
