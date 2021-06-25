import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/settings/language/language.dart';
import 'package:aves/widgets/settings/navigation.dart';
import 'package:aves/widgets/settings/privacy/privacy.dart';
import 'package:aves/widgets/settings/thumbnails.dart';
import 'package:aves/widgets/settings/video/video.dart';
import 'package:aves/widgets/settings/viewer/viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class SettingsPage extends StatefulWidget {
  static const routeName = '/settings';

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final ValueNotifier<String?> _expandedNotifier = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MediaQueryDataProvider(
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.settingsPageTitle),
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
}
