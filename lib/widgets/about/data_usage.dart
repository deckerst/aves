import 'package:aves/ref/brand_colors.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/styles.dart';
import 'package:aves/utils/file_utils.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_donut.dart';
import 'package:aves/widgets/common/identity/buttons/outlined_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AboutDataUsage extends StatefulWidget {
  const AboutDataUsage({super.key});

  @override
  State<AboutDataUsage> createState() => _AboutDataUsageState();
}

class _AboutDataUsageState extends State<AboutDataUsage> with FeedbackMixin {
  late Future<Map<String, int>> _loader;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final animationDuration = context.select<DurationsData, Duration>((v) => v.expansionTileAnimation);
    return ExpansionPanelList(
      expansionCallback: (index, isExpanded) {
        setState(() => _isExpanded = isExpanded);
      },
      animationDuration: animationDuration,
      expandedHeaderPadding: EdgeInsets.zero,
      elevation: 0,
      children: [
        ExpansionPanel(
          headerBuilder: (context, isExpanded) => ConstrainedBox(
            constraints: const BoxConstraints(minHeight: kMinInteractiveDimension),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: AlignmentDirectional.centerStart,
              child: Text(l10n.aboutDataUsageSectionTitle, style: AStyles.knownTitleText),
            ),
          ),
          body: FutureBuilder<Map<String, int>>(
            future: _loader,
            builder: (context, snapshot) {
              final data = snapshot.data;
              if (data == null) return const SizedBox();

              final dataMap = {
                DataUsageDonut.bin: data['trash'] ?? 0,
                DataUsageDonut.database: data['database'] ?? 0,
                DataUsageDonut.vaults: data['vaults'] ?? 0,
                DataUsageDonut.misc: data['miscData'] ?? 0,
              };
              final flutter = data['flutter'] ?? 0;
              if (flutter > 0) {
                dataMap[DataUsageDonut.flutter] = flutter;
              }
              final cacheMap = {
                DataUsageDonut.internal: data['internalCache'] ?? 0,
                DataUsageDonut.external: data['externalCache'] ?? 0,
              };
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DataUsageDonut(
                    title: l10n.aboutDataUsageData,
                    byTypes: dataMap,
                    animationDuration: animationDuration,
                  ),
                  DataUsageDonut(
                    title: l10n.aboutDataUsageCache,
                    byTypes: cacheMap,
                    animationDuration: animationDuration,
                  ),
                  Center(
                    child: AvesOutlinedButton(
                      label: context.l10n.aboutDataUsageClearCache,
                      onPressed: () async {
                        await storageService.deleteTempDirectory();
                        await mediaFetchService.clearSizedThumbnailDiskCache();
                        imageCache.clear();
                        _reload();
                        setState(() {});
                      },
                    ),
                  ),
                ],
              );
            },
          ),
          isExpanded: _isExpanded,
          canTapOnHeader: true,
          backgroundColor: Colors.transparent,
        ),
      ],
    );
  }

  void _reload() {
    _loader = storageService.getDataUsage();
  }
}

class DataUsageDonut extends StatelessWidget {
  final String title;
  final Map<String, int> byTypes;
  final Duration animationDuration;

  // data
  static const String bin = 'bin';
  static const String database = 'database';
  static const String flutter = 'flutter';
  static const String vaults = 'vaults';
  static const String misc = 'misc';

  // cache
  static const String internal = 'internal';
  static const String external = 'external';

  const DataUsageDonut({
    super.key,
    required this.title,
    required this.byTypes,
    required this.animationDuration,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = context.locale;

    return AvesDonut(
      title: Text(title),
      byTypes: byTypes,
      animationDuration: animationDuration,
      formatKey: (d) {
        switch (d.key) {
          case bin:
            return l10n.binPageTitle;
          case database:
            return l10n.aboutDataUsageDatabase;
          case flutter:
            return 'Flutter';
          case vaults:
            return l10n.albumTierVaults;
          case misc:
            return l10n.aboutDataUsageMisc;
          case internal:
            return l10n.aboutDataUsageInternal;
          case external:
            return l10n.aboutDataUsageExternal;
          default:
            return d.key;
        }
      },
      formatValue: (v) => formatFileSize(locale, v, round: 0),
      colorize: (context, d) {
        final colors = context.read<AvesColorsData>();
        Color? color;
        switch (d.key) {
          case flutter:
            color = colors.fromBrandColor(BrandColors.flutter);
        }
        return color ?? colors.fromString(d.key);
      },
    );
  }
}
