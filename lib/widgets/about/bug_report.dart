import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:aves/app_flavor.dart';
import 'package:aves/flutter_version.dart';
import 'package:aves/model/device.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/ref/locales.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/styles.dart';
import 'package:aves/theme/themes.dart';
import 'package:aves/widgets/about/app_ref.dart';
import 'package:aves/widgets/aves_app.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/fx/borders.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:aves/widgets/common/identity/buttons/outlined_button.dart';
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

class _BugReportState extends State<BugReport> with FeedbackMixin {
  late Future<String> _infoLoader;
  bool _showInstructions = false;

  static const bugReportUrl = '${AppReference.avesGithub}/issues/new?labels=type%3Abug&template=bug_report.md';

  @override
  void initState() {
    super.initState();
    _infoLoader = _getInfo(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
              child: Text(l10n.aboutBugSectionTitle, style: AStyles.knownTitleText),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStep(1, l10n.aboutBugSaveLogInstruction, l10n.saveTooltip, _saveLogs),
                _buildStep(2, l10n.aboutBugCopyInfoInstruction, l10n.aboutBugCopyInfoButton, _copySystemInfo),
                FutureBuilder<String>(
                  future: _infoLoader,
                  builder: (context, snapshot) {
                    final info = snapshot.data;
                    if (info == null) return const SizedBox();

                    return Container(
                      decoration: BoxDecoration(
                        color: Themes.secondLayerColor(context),
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                          width: AvesBorder.curvedBorderWidth(context),
                        ),
                        borderRadius: const BorderRadius.all(Radius.circular(16)),
                      ),
                      constraints: const BoxConstraints(maxHeight: 100),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      clipBehavior: Clip.antiAlias,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(8),
                        // to show a scroll bar, we would need to provide a scroll controller
                        // to both the `Scrollable` and the `Scrollbar`, but
                        // as of Flutter v3.0.0, `SelectableText` does not allow passing the `scrollController`
                        child: SelectableText(
                          info,
                          textDirection: ui.TextDirection.ltr,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    );
                  },
                ),
                _buildStep(3, l10n.aboutBugReportInstruction, l10n.aboutBugReportButton, _goToGithub),
                const SizedBox(height: 16),
              ],
            ),
          ),
          isExpanded: _showInstructions,
          canTapOnHeader: true,
          backgroundColor: Colors.transparent,
        ),
      ],
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
              border: Border.fromBorderSide(BorderSide(
                color: isMonochrome ? context.select<AvesColorsData, Color>((v) => v.neutral) : Theme.of(context).colorScheme.primary,
                width: AvesFilterChip.outlineWidth,
              )),
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
    final supportsHdr = await windowService.supportsHdr();
    final supportsWideGamut = await windowService.supportsWideGamut();
    final connections = await Connectivity().checkConnectivity();
    final storageVolumes = await storageService.getStorageVolumes();
    final storageGrants = await storageService.getGrantedDirectories();
    return [
      'Package: ${device.packageName}',
      'Installer: ${packageInfo.installerStore}',
      'Aves version: ${device.packageVersion}-$flavor, build ${packageInfo.buildNumber}',
      'Flutter: ${version['channel']} ${version['frameworkVersion']}',
      'Android version: ${androidInfo.version.release}, API ${androidInfo.version.sdkInt}',
      'Android build: ${androidInfo.display}',
      'Device: ${androidInfo.manufacturer} ${androidInfo.model}',
      'Display: pixel ratio=${view.devicePixelRatio}, logical=${mediaQuery.size.width}x${mediaQuery.size.height}, physical=${view.physicalSize.width}x${view.physicalSize.height}',
      'Support: dynamic colors=${device.isDynamicColorAvailable}, geocoder=${device.hasGeocoder}, HDR=$supportsHdr, wide gamut=$supportsWideGamut',
      'Mobile services: ${mobileServices.isServiceAvailable ? 'ready' : 'not available'}',
      'Connectivity: ${connections.map((v) => v.name).join(', ')}',
      'System locales: ${WidgetsBinding.instance.platformDispatcher.locales.join(', ')}',
      'Storage volumes: ${storageVolumes.map((v) => v.path).join(', ')}',
      'Storage grants: ${storageGrants.join(', ')}',
      'Error reporting: ${settings.isErrorReportingAllowed}',
    ].join('\n');
  }

  Future<void> _saveLogs() async {
    final result = await Process.run('logcat', ['-d']);
    final logs = result.stdout;
    final success = await storageService.createFile(
      'aves-logs-${DateFormat('yyyyMMdd_HHmmss', asciiLocale).format(DateTime.now())}.txt',
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

  Future<void> _copySystemInfo() async {
    await Clipboard.setData(ClipboardData(text: await _infoLoader));
    showFeedback(context, FeedbackType.info, context.l10n.genericSuccessFeedback);
  }

  Future<void> _goToGithub() => AvesApp.launchUrl(bugReportUrl);
}
