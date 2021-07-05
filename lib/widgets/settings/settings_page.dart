import 'dart:convert';
import 'dart:typed_data';

import 'package:aves/model/actions/settings_actions.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/services/services.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/basic/menu_row.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/settings/language/language.dart';
import 'package:aves/widgets/settings/navigation.dart';
import 'package:aves/widgets/settings/privacy/privacy.dart';
import 'package:aves/widgets/settings/thumbnails.dart';
import 'package:aves/widgets/settings/video/video.dart';
import 'package:aves/widgets/settings/viewer/viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';

class SettingsPage extends StatefulWidget {
  static const routeName = '/settings';

  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with FeedbackMixin {
  final ValueNotifier<String?> _expandedNotifier = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MediaQueryDataProvider(
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.settingsPageTitle),
          actions: [
            PopupMenuButton<SettingsAction>(
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    value: SettingsAction.export,
                    child: MenuRow(text: context.l10n.settingsActionExport, icon: AIcons.export),
                  ),
                  PopupMenuItem(
                    value: SettingsAction.import,
                    child: MenuRow(text: context.l10n.settingsActionImport, icon: AIcons.import),
                  ),
                ];
              },
              onSelected: (action) {
                // wait for the popup menu to hide before proceeding with the action
                Future.delayed(Durations.popupMenuAnimation * timeDilation, () => _onActionSelected(action));
              },
            ),
          ],
        ),
        body: Theme(
          data: theme.copyWith(
            textTheme: theme.textTheme.copyWith(
              // dense style font for tile subtitles, without modifying title font
              bodyText2: const TextStyle(fontSize: 12),
            ),
          ),
          child: SafeArea(
            child: AnimationLimiter(
              child: ListView(
                padding: const EdgeInsets.all(8),
                children: AnimationConfiguration.toStaggeredList(
                  duration: Durations.staggeredAnimation,
                  delay: Durations.staggeredAnimationDelay,
                  childAnimationBuilder: (child) => SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: child,
                    ),
                  ),
                  children: [
                    NavigationSection(expandedNotifier: _expandedNotifier),
                    ThumbnailsSection(expandedNotifier: _expandedNotifier),
                    ViewerSection(expandedNotifier: _expandedNotifier),
                    VideoSection(expandedNotifier: _expandedNotifier),
                    PrivacySection(expandedNotifier: _expandedNotifier),
                    LanguageSection(expandedNotifier: _expandedNotifier),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onActionSelected(SettingsAction action) async {
    switch (action) {
      case SettingsAction.export:
        final success = await storageService.createFile(
          'aves-settings-${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.json',
          MimeTypes.json,
          Uint8List.fromList(utf8.encode(settings.toJson())),
        );
        if (success != null) {
          if (success) {
            showFeedback(context, context.l10n.genericSuccessFeedback);
          } else {
            showFeedback(context, context.l10n.genericFailureFeedback);
          }
        }
        break;
      case SettingsAction.import:
        final bytes = await storageService.openFile(MimeTypes.json);
        if (bytes.isNotEmpty) {
          try {
            await settings.fromJson(utf8.decode(bytes));
            showFeedback(context, context.l10n.genericSuccessFeedback);
          } catch (error) {
            debugPrint('failed to import settings, error=$error');
            showFeedback(context, context.l10n.genericFailureFeedback);
          }
        }
        break;
    }
  }
}
