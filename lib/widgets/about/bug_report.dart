import 'dart:convert';
import 'dart:io';

import 'package:aves/app_flavor.dart';
import 'package:aves/model/device.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/ref/locales.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/services/device_service.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/styles.dart';
import 'package:aves/utils/file_utils.dart';
import 'package:aves/widgets/about/app_ref.dart';
import 'package:aves/widgets/aves_app.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:aves/widgets/common/identity/buttons/outlined_button.dart';
import 'package:aves/widgets/settings/app_export/items.dart';
import 'package:aves_model/aves_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

class BugReport extends StatefulWidget {
  const BugReport({super.key});

  @override
  State<BugReport> createState() => _BugReportState();
}

class _BugReportState extends State<BugReport> {
  bool _showInstructions = false;

  @override
  Widget build(BuildContext context) {
    final animationDuration = context.select<DurationsData, Duration>((v) => v.expansionTileAnimation);
    return ExpansionPanelList(
      expansionCallback: (index, isExpanded) {
        setState(() => _showInstructions = isExpanded);
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
              child: Text(context.l10n.aboutBugSectionTitle, style: AStyles.knownTitleText),
            ),
          ),
          body: const BugReportContent(),
          isExpanded: _showInstructions,
          canTapOnHeader: true,
          backgroundColor: Colors.transparent,
        ),
      ],
    );
  }
}

class BugReportContent extends StatefulWidget {
  const BugReportContent({super.key});

  @override
  State<BugReportContent> createState() => _BugReportContentState();
}

class _BugReportContentState extends State<BugReportContent> with FeedbackMixin {
  late Future<String> _infoLoader;
  static const bugReportUrl = '${AppReference.avesGithub}/issues/new?labels=type%3Abug&template=bug_report.yml';

  @override
  void initState() {
    super.initState();
    _infoLoader = _getInfo(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          _buildStep(1, l10n.aboutBugSaveLogInstruction, l10n.saveTooltip, _saveLogs),
          _buildStep(2, l10n.aboutBugReportInstruction, l10n.aboutBugReportButton, _goToGithub),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildStep(int step, String text, String buttonText, VoidCallback onPressed) {
    final isMonochrome = settings.themeColorMode == AvesThemeColorMode.monochrome;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.fromBorderSide(
                BorderSide(
                  color: isMonochrome ? context.select<AvesColorsData, Color>((v) => v.neutral) : Theme.of(context).colorScheme.primary,
                  width: AvesFilterChip.outlineWidth,
                ),
              ),
              shape: BoxShape.circle,
            ),
            child: Text(NumberFormat('0', context.locale).format(step)),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
          const SizedBox(width: 8),
          AvesOutlinedButton(
            label: buttonText,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }

  Future<String> _getInfo(BuildContext context) async {
    final flavor = context.read<AppFlavor>().toString().split('.')[1];
    final packageInfo = await PackageInfo.fromPlatform();
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final mediaQuery = MediaQuery.of(context);
    final view = View.of(context);

    final ram = await deviceService.getRamSizes(<MemorySizeType>{.total});
    final heap = await deviceService.getHeapSizes(<MemorySizeType>{.max});
    final ramTotal = formatFileSize(kAsciiLocale, ram[MemorySizeType.total] ?? 0);
    final heapMax = formatFileSize(kAsciiLocale, heap[MemorySizeType.max] ?? 0);

    final supportsHdr = await windowService.supportsHdr();
    final supportsWideGamut = await windowService.supportsWideGamut();

    final connections = await Connectivity().checkConnectivity();
    final storageVolumes = await storageService.getStorageVolumes();
    final storageGrants = await storageService.getGrantedDirectories();

    final source = context.read<CollectionSource>();
    final entryCount = source.allEntries.length;
    final albumCount = source.rawAlbums.length;
    final tagCount = source.sortedTags.length;

    return [
      'Aves: ${device.packageVersion}-$flavor, build ${packageInfo.buildNumber}, package=${device.packageName}, installer=${packageInfo.installerStore}',
      'Flutter: ${FlutterVersion.channel} ${FlutterVersion.version}',
      'Android: ${androidInfo.version.release}, API ${androidInfo.version.sdkInt}, build: ${androidInfo.display}',
      'Device: ${androidInfo.manufacturer} ${androidInfo.model}',
      'Memory: ram.total=$ramTotal, heap.max=$heapMax',
      'Screen: size.physical=${view.physicalSize.width.round()}x${view.physicalSize.height.round()}, HDR=$supportsHdr, wide gamut=$supportsWideGamut',
      'Display: size.logical=${mediaQuery.size.width}x${mediaQuery.size.height}, pixel ratio=${view.devicePixelRatio}',
      'Mobile services: ${mobileServices.isServiceAvailable ? 'ready' : 'not available'}, geocoder=${device.hasGeocoder}',
      'Connectivity: ${connections.map((v) => v.name).join(', ')}',
      'System locales: ${WidgetsBinding.instance.platformDispatcher.locales.join(', ')}',
      'Storage volumes: ${storageVolumes.map((v) => v.path).join(', ')}',
      'Storage grants: ${storageGrants.join(', ')}',
      'Error reporting: ${settings.isErrorReportingAllowed}',
      'Collection: $entryCount items, $albumCount albums, $tagCount tags',
    ].join('\n');
  }

  Future<void> _saveLogs() async {
    final contentInfo = await _infoLoader;
    final contentSettings = const JsonEncoder.withIndent('  ').convert(AppExportItem.settings.export(context.read<CollectionSource>()));
    final contentLog = (await Process.run('logcat', ['-d'])).stdout as String;

    final logs = [
      contentInfo,
      contentSettings,
      contentLog,
    ].join('\n--------------------------------------------------------------------------------\n');

    final success = await storageService.createFile(
      'aves-logs-${DateFormat('yyyyMMdd_HHmmss', kAsciiLocale).format(DateTime.now())}.txt',
      MimeTypes.plainText,
      Uint8List.fromList(utf8.encode(logs)),
    );
    if (success != null) {
      if (success) {
        showFeedback(context, FeedbackType.info, context.l10n.genericSuccessFeedback);
      } else {
        showFeedback(context, FeedbackType.warn, context.l10n.genericFailureFeedback);
      }
    }
  }

  Future<void> _goToGithub() => AvesApp.launchUrl(bugReportUrl);
}
