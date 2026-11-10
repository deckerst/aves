import 'dart:async';
import 'dart:convert';

import 'package:aves/model/entry/entry.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/services/media/enums.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/view/src/metadata/credentials.dart';
import 'package:aves/widgets/common/grid/theme.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:aves/widgets/viewer/info/credential/manifest.dart';
import 'package:aves_utils/aves_utils.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class const CredentialSectionSliver({
  super.key,
  required final AvesEntry entry,
}) extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CredentialSectionSliverState();
}

class _CredentialSectionSliverState extends State<CredentialSectionSliver> {
  late final Future<Map> _loader;

  static const double _thumbnailExtent = 40;

  @override
  void initState() {
    super.initState();
    _loader = metadataFetchService.getContentCredentials(widget.entry);
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: FutureBuilder<Map>(
        future: _loader,
        builder: (context, snapshot) {
          final fields = snapshot.data;
          if (fields == null || fields.isEmpty) return const SizedBox();

          final validityString = fields['validity'] as String?;
          final jsonString = fields['json'] as String?;
          if (validityString == null || jsonString == null) return const SizedBox();

          final json = jsonDecode(jsonString) as Map<String, Object?>;
          final activeManifestLabel = json['active_manifest'] as String?;
          final manifests = json['manifests'] as Map<String, Object?>?;
          if (activeManifestLabel == null || manifests == null) return const SizedBox();

          final validity = C2paValidity.values.safeByName(validityString, ignoreCase: true) ?? .unknown;
          final todoManifestIds = [activeManifestLabel];

          final children = <Widget>[];
          while (todoManifestIds.isNotEmpty) {
            final manifestId = todoManifestIds.removeAt(0);
            final manifest = manifests[manifestId] as Map<String, Object?>?;
            if (manifest != null) {
              children.add(
                Manifest(
                  entry: widget.entry,
                  json: manifest,
                  thumbnailExtent: _thumbnailExtent,
                ),
              );
              todoManifestIds.addAll(_getComponentManifests(manifest));
              todoManifestIds.addAll(_getParentManifests(manifest));
              if (todoManifestIds.isNotEmpty) {
                children.add(
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Icon(AIcons.goUp),
                  ),
                );
              }
            }
          }

          final durations = context.watch<DurationsData>();
          return GridTheme(
            extent: _thumbnailExtent,
            child: Wrap(
              alignment: .center,
              children: AnimationConfiguration.toStaggeredList(
                duration: durations.staggeredAnimation,
                delay: durations.staggeredAnimationDelay * timeDilation,
                childAnimationBuilder: (child) => SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: child,
                  ),
                ),
                children: [
                  SectionRow(
                    icon: validity.getIconData(),
                    padding: const EdgeInsets.symmetric(vertical: 24),
                  ),
                  ...children,
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<String> _getComponentManifests(Map<String, Object?> json) => _getRelatedManifests(json, 'componentOf');

  List<String> _getParentManifests(Map<String, Object?> json) => _getRelatedManifests(json, 'parentOf');

  List<String> _getRelatedManifests(Map<String, Object?> json, String relationship) {
    final ingredients = (json['ingredients'] as List?)?.cast<Map<String, Object?>>();
    if (ingredients == null) return [];

    return ingredients
        .where((v) => v['relationship'] == relationship)
        .map((v) {
          final manifest = v['manifest_data'] as Map<String, Object?>?;
          if (manifest == null) return null;
          return manifest['identifier'] as String?;
        })
        .nonNulls
        .toList();
  }
}
