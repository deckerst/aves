import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:aves/flutter_version.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:aves/widgets/common/identity/buttons.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class BugReport extends StatefulWidget {
  const BugReport({Key? key}) : super(key: key);

  @override
  _BugReportState createState() => _BugReportState();
}

class _BugReportState extends State<BugReport> with FeedbackMixin {
  late Future<String> _infoLoader;
  bool _showInstructions = false;

  @override
  void initState() {
    super.initState();
    _infoLoader = _getInfo();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ExpansionPanelList(
      expansionCallback: (index, isExpanded) {
        setState(() => _showInstructions = !isExpanded);
      },
      expandedHeaderPadding: EdgeInsets.zero,
      elevation: 0,
      children: [
        ExpansionPanel(
          headerBuilder: (context, isExpanded) => ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: AlignmentDirectional.centerStart,
              child: Text(l10n.aboutBug, style: Constants.titleTextStyle),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStep(1, l10n.aboutBugSaveLogInstruction, l10n.aboutBugSaveLogButton, _saveLogs),
                _buildStep(2, l10n.aboutBugCopyInfoInstruction, l10n.aboutBugCopyInfoButton, _copySystemInfo),
                FutureBuilder<String>(
                  future: _infoLoader,
                  builder: (context, snapshot) {
                    final info = snapshot.data;
                    if (info == null) return const SizedBox();
                    return Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade800,
                          border: Border.all(
                            color: Colors.white,
                          ),
                          borderRadius: const BorderRadius.all(Radius.circular(8)),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: SelectableText(info));
                  },
                ),
                _buildStep(3, l10n.aboutBugReportInstruction, l10n.aboutBugReportButton, _goToGithub),
                const SizedBox(height: 16),
              ],
            ),
          ),
          isExpanded: _showInstructions,
          canTapOnHeader: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
      ],
    );
  }

  Widget _buildStep(int step, String text, String buttonText, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.fromBorderSide(BorderSide(
                color: Theme.of(context).colorScheme.secondary,
                width: AvesFilterChip.outlineWidth,
              )),
              shape: BoxShape.circle,
            ),
            child: Text('$step'),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
          const SizedBox(width: 8),
          AvesOutlinedButton(
            label: buttonText,
            onPressed: onPressed,
          )
        ],
      ),
    );
  }

  Future<String> _getInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final hasPlayServices = await availability.hasPlayServices;
    return [
      'Aves version: ${packageInfo.version} (Build ${packageInfo.buildNumber})',
      'Flutter version: ${version['frameworkVersion']} (Channel ${version['channel']})',
      'Android version: ${androidInfo.version.release} (SDK ${androidInfo.version.sdkInt})',
      'Device: ${androidInfo.manufacturer} ${androidInfo.model}',
      'Google Play services: ${hasPlayServices ? 'ready' : 'not available'}',
    ].join('\n');
  }

  Future<void> _saveLogs() async {
    final result = await Process.run('logcat', ['-d']);
    final logs = result.stdout;
    final success = await storageService.createFile(
      'aves-logs-${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.txt',
      MimeTypes.plainText,
      Uint8List.fromList(utf8.encode(logs)),
    );
    if (success != null) {
      if (success) {
        showFeedback(context, context.l10n.genericSuccessFeedback);
      } else {
        showFeedback(context, context.l10n.genericFailureFeedback);
      }
    }
  }

  Future<void> _copySystemInfo() async {
    await Clipboard.setData(ClipboardData(text: await _infoLoader));
    showFeedback(context, context.l10n.genericSuccessFeedback);
  }

  Future<void> _goToGithub() async {
    await launch('${Constants.avesGithub}/issues/new');
  }
}
