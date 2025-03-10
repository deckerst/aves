import 'dart:async';

import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/info.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/identity/buttons/outlined_button.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:aves/widgets/viewer/info/metadata/metadata_dir.dart';
import 'package:aves/widgets/viewer/info/metadata/metadata_dir_tile.dart';
import 'package:aves/widgets/viewer/info/metadata/tv_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

class MetadataSectionSliver extends StatefulWidget {
  final AvesEntry entry;
  final ValueNotifier<Map<String, MetadataDirectory>> metadataNotifier;

  const MetadataSectionSliver({
    super.key,
    required this.entry,
    required this.metadataNotifier,
  });

  @override
  State<StatefulWidget> createState() => _MetadataSectionSliverState();
}

class _MetadataSectionSliverState extends State<MetadataSectionSliver> {
  final ValueNotifier<String?> _expandedDirectoryNotifier = ValueNotifier(null);

  AvesEntry get entry => widget.entry;

  ValueNotifier<Map<String, MetadataDirectory>> get metadataNotifier => widget.metadataNotifier;

  @override
  void initState() {
    super.initState();
    _registerWidget(widget);
    metadataNotifier.value = {};
    _getMetadata();
  }

  @override
  void didUpdateWidget(covariant MetadataSectionSliver oldWidget) {
    super.didUpdateWidget(oldWidget);
    _unregisterWidget(oldWidget);
    _registerWidget(widget);
    _getMetadata();
  }

  @override
  void dispose() {
    _unregisterWidget(widget);
    _expandedDirectoryNotifier.dispose();
    super.dispose();
  }

  void _registerWidget(MetadataSectionSliver widget) {
    widget.entry.metadataChangeNotifier.addListener(_onMetadataChanged);
  }

  void _unregisterWidget(MetadataSectionSliver widget) {
    widget.entry.metadataChangeNotifier.removeListener(_onMetadataChanged);
  }

  @override
  Widget build(BuildContext context) {
    // use a `Column` inside a `SliverToBoxAdapter`, instead of a `SliverList`,
    // so that we can have the metadata-dependent `AnimationLimiter` inside the metadata section
    // warning: placing the `AnimationLimiter` as a parent to the `ScrollView`
    // triggers dispose & reinitialization of other sections, including heavy widgets like maps
    return SliverToBoxAdapter(
      child: NotificationListener<ScrollNotification>(
        // cancel notification bubbling so that the info page
        // does not misinterpret content scrolling for page scrolling
        onNotification: (notification) => true,
        child: ValueListenableBuilder<Map<String, MetadataDirectory>>(
            valueListenable: metadataNotifier,
            builder: (context, metadata, child) {
              Widget content;
              if (metadata.isEmpty) {
                content = const SizedBox();
              } else {
                final durations = context.watch<DurationsData>();
                content = Column(
                  children: AnimationConfiguration.toStaggeredList(
                    duration: durations.staggeredAnimation,
                    delay: durations.staggeredAnimationDelay * timeDilation,
                    childAnimationBuilder: (child) => SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: child,
                      ),
                    ),
                    children: settings.useTvLayout
                        ? [
                            const SizedBox(height: 16),
                            AvesOutlinedButton(
                              label: MaterialLocalizations.of(context).moreButtonTooltip,
                              onPressed: () {
                                Navigator.maybeOf(context)?.push(
                                  MaterialPageRoute(
                                    settings: const RouteSettings(name: TvMetadataPage.routeName),
                                    builder: (context) => TvMetadataPage(
                                      entry: entry,
                                      metadata: metadata,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ]
                        : [
                            const SectionRow(icon: AIcons.info),
                            ...metadata.entries.map((kv) => MetadataDirTile(
                                  entry: entry,
                                  title: kv.key,
                                  dir: kv.value,
                                  expandedDirectoryNotifier: _expandedDirectoryNotifier,
                                )),
                          ],
                  ),
                );
              }

              return AnimationLimiter(
                // we update the limiter key after fetching the metadata of a new entry,
                // in order to restart the staggered animation of the metadata section
                key: ValueKey(metadata.length),
                child: content,
              );
            }),
      ),
    );
  }

  void _onMetadataChanged() {
    metadataNotifier.value = {};
    _getMetadata();
  }

  Future<void> _getMetadata() async {
    final titledDirectories = await entry.getMetadataDirectories(context);
    if (!mounted) return;
    metadataNotifier.value = Map.fromEntries(titledDirectories);
    _expandedDirectoryNotifier.value = null;
  }
}
