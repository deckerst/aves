import 'dart:async';

import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/settings/settings_definition.dart';
import 'package:aves/widgets/settings/video/video.dart';
import 'package:flutter/material.dart';

class VideoSettingsPage extends StatefulWidget {
  static const routeName = '/settings/video';

  const VideoSettingsPage({super.key});

  @override
  State<VideoSettingsPage> createState() => _VideoSettingsPageState();
}

class _VideoSettingsPageState extends State<VideoSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MediaQueryDataProvider(
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.settingsVideoPageTitle),
        ),
        body: Theme(
          data: theme.copyWith(
            textTheme: theme.textTheme.copyWith(
              // dense style font for tile subtitles, without modifying title font
              bodyMedium: const TextStyle(fontSize: 12),
            ),
          ),
          child: SafeArea(
            child: FutureBuilder<List<SettingsTile>>(
              future: Future.value(VideoSection(standalonePage: true).tiles(context)),
              builder: (context, snapshot) {
                final tiles = snapshot.data;
                if (tiles == null) return const SizedBox();

                return ListView(
                  children: tiles.map((v) => v.build(context)).toList(),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
