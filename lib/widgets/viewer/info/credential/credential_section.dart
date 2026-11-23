import 'dart:async';
import 'dart:convert';

import 'package:aves/model/entry/entry.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/services/media/enums.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/theme/text.dart';
import 'package:aves/utils/string_utils.dart';
import 'package:aves/view/src/metadata/credentials.dart';
import 'package:aves/widgets/common/identity/buttons/outlined_button.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:aves/widgets/viewer/info/credential/manifest.dart';
import 'package:aves_utils/aves_utils.dart';
import 'package:collection/collection.dart';
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
  Future<Map> _loader = Future.value({});
  bool _showAllManifests = false;

  static final _statusPrefixPattern = RegExp('(signingCredential|assertion)\\.');

  @override
  void initState() {
    super.initState();
    _registerWidget(widget);
    _initLoader();
  }

  @override
  void didUpdateWidget(covariant CredentialSectionSliver oldWidget) {
    super.didUpdateWidget(oldWidget);
    _unregisterWidget(oldWidget);
    _registerWidget(widget);
  }

  @override
  void dispose() {
    _unregisterWidget(widget);
    super.dispose();
  }

  void _registerWidget(CredentialSectionSliver widget) {
    widget.entry.metadataChangeNotifier.addListener(_onMetadataChanged);
  }

  void _unregisterWidget(CredentialSectionSliver widget) {
    widget.entry.metadataChangeNotifier.removeListener(_onMetadataChanged);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final mainStyle = textTheme.bodyMedium!;
    final subColor = theme.colorScheme.onSurfaceVariant;

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
          final manifestById = json['manifests'] as Map<String, Object?>?;
          if (activeManifestLabel == null || manifestById == null) return const SizedBox();

          final validity = C2paValidity.values.safeByName(validityString, ignoreCase: true) ?? .unknown;
          final todoManifestIds = [activeManifestLabel];

          final validationStatus = (json['validation_status'] as List? ?? []).cast<Map>();
          final errorCodes = validationStatus.map((kv) => kv['code']).whereType<String>().toSet();
          final errorLine = errorCodes.map((v) => v.replaceFirst(_statusPrefixPattern, '').replaceAll('.', '_').toSentenceCase()).join(AText.separator);

          final manifestList = <Map<String, Object?>>[];
          while (todoManifestIds.isNotEmpty) {
            final manifestId = todoManifestIds.removeAt(0);
            final manifest = manifestById[manifestId] as Map<String, Object?>?;
            if (manifest != null) {
              manifestList.add(manifest);
              todoManifestIds.addAll(_getComponentManifests(manifest));
              todoManifestIds.addAll(_getParentManifests(manifest));
            }
          }

          final children = <Widget>[];

          if (errorLine.isNotEmpty) {
            children.add(
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, bottom: 16),
                child: Row(
                  children: [
                    Icon(AIcons.error, size: 16, color: subColor),
                    const SizedBox(width: 4),
                    Expanded(child: SelectableText(errorLine, style: mainStyle)),
                  ],
                ),
              ),
            );
          }

          void _addManifest(Map<String, Object?> manifest, index) => children.add(
            Manifest(
              entry: widget.entry,
              json: manifest,
              index: index,
            ),
          );
          void _addLink() => children.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Icon(AIcons.goUp, size: 20, color: subColor),
            ),
          );

          final manifestCount = manifestList.length;
          final newest = manifestList.first;
          final intermediate = manifestCount > 2 ? manifestList.getRange(1, manifestList.length - 1).toList() : [];
          final oldest = manifestList.last;
          _addManifest(newest, manifestList.length);
          if (newest != oldest) {
            if (intermediate.isEmpty || _showAllManifests) {
              intermediate.forEachIndexed((i, manifest) {
                _addLink();
                _addManifest(manifest, manifestList.length - (i + 1));
              });
            } else {
              _addLink();
              children.add(
                AvesOutlinedButton(
                  label: MaterialLocalizations.of(context).moreButtonTooltip,
                  onPressed: () => setState(() => _showAllManifests = true),
                ),
              );
            }
            _addLink();
            _addManifest(oldest, 1);
          }

          final durations = context.watch<DurationsData>();
          return Column(
            crossAxisAlignment: .center,
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
          // `manifest_data` / `identifier`
          var manifest = v['manifest_data'] as Map<String, Object?>?;
          if (manifest != null) {
            return manifest['identifier'] as String?;
          }
          // `active_manifest` / `url`
          manifest = v['active_manifest'] as Map<String, Object?>?;
          if (manifest != null) {
            final url = manifest['url'] as String?;
            return url?.replaceFirst('self#jumbf=/c2pa/', '');
          }
          return null;
        })
        .nonNulls
        .toList();
  }

  void _initLoader() {
    _loader = metadataFetchService.getContentCredentials(widget.entry);
  }

  void _onMetadataChanged() {
    _initLoader();
    setState(() {});
  }
}
