import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:aves/widgets/settings/language/locales.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:material_ui/material_ui.dart';

class const DebugColorSection({super.key}) extends StatefulWidget {
  @override
  State<DebugColorSection> createState() => _DebugColorSectionState();
}

class _DebugColorSectionState extends State<DebugColorSection> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    final scheme = Theme.of(context).colorScheme;
    final List<(String, Color)?> colors = [
      ('primary', scheme.primary),
      ('onPrimary', scheme.onPrimary),
      ('primaryContainer', scheme.primaryContainer),
      ('onPrimaryContainer', scheme.onPrimaryContainer),
      ('primaryFixed', scheme.primaryFixed),
      ('primaryFixedDim', scheme.primaryFixedDim),
      ('onPrimaryFixed', scheme.onPrimaryFixed),
      ('onPrimaryFixedVariant', scheme.onPrimaryFixedVariant),
      null,
      ('secondary', scheme.secondary),
      ('onSecondary', scheme.onSecondary),
      ('secondaryContainer', scheme.secondaryContainer),
      ('onSecondaryContainer', scheme.onSecondaryContainer),
      ('secondaryFixed', scheme.secondaryFixed),
      ('secondaryFixedDim', scheme.secondaryFixedDim),
      ('onSecondaryFixed', scheme.onSecondaryFixed),
      ('onSecondaryFixedVariant', scheme.onSecondaryFixedVariant),
      null,
      ('tertiary', scheme.tertiary),
      ('onTertiary', scheme.onTertiary),
      ('tertiaryContainer', scheme.tertiaryContainer),
      ('onTertiaryContainer', scheme.onTertiaryContainer),
      ('tertiaryFixed', scheme.tertiaryFixed),
      ('tertiaryFixedDim', scheme.tertiaryFixedDim),
      ('onTertiaryFixed', scheme.onTertiaryFixed),
      ('onTertiaryFixedVariant', scheme.onTertiaryFixedVariant),
      null,
      ('error', scheme.error),
      ('onError', scheme.onError),
      ('errorContainer', scheme.errorContainer),
      ('onErrorContainer', scheme.onErrorContainer),
      null,
      ('surface', scheme.surface),
      ('onSurface', scheme.onSurface),
      ('onSurfaceVariant', scheme.onSurfaceVariant),
      ('surfaceDim', scheme.surfaceDim),
      ('surfaceBright', scheme.surfaceBright),
      ('surfaceContainerLowest', scheme.surfaceContainerLowest),
      ('surfaceContainerLow', scheme.surfaceContainerLow),
      ('surfaceContainer', scheme.surfaceContainer),
      ('surfaceContainerHigh', scheme.surfaceContainerHigh),
      ('surfaceContainerHighest', scheme.surfaceContainerHighest),
      null,
      ('outline', scheme.outline),
      ('outlineVariant', scheme.outlineVariant),
      ('shadow', scheme.shadow),
      ('scrim', scheme.scrim),
      null,
      ('inverseSurface', scheme.inverseSurface),
      ('onInverseSurface', scheme.onInverseSurface),
      ('inversePrimary', scheme.inversePrimary),
      ('surfaceTint', scheme.surfaceTint),
    ];
    return AvesExpansionTile(
      title: 'Colors',
      locale: KnownLocale.english,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: colors.map((kv) {
              if (kv == null) return const Divider();
              final (text, color) = kv;
              return Row(
                children: [
                  Text(text),
                  const Spacer(),
                  Text(
                    color.hexAlpha,
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
