import 'package:aves/image_providers/app_icon_image_provider.dart';
import 'package:aves/model/actions/entry_info_actions.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/favourites.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/favourite.dart';
import 'package:aves/model/filters/mime.dart';
import 'package:aves/model/filters/tag.dart';
import 'package:aves/model/filters/type.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/format.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/utils/file_utils.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:aves/widgets/viewer/info/entry_info_action_delegate.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BasicSection extends StatelessWidget {
  final AvesEntry entry;
  final CollectionLens? collection;
  final EntryInfoActionDelegate actionDelegate;
  final ValueNotifier<bool> isEditingTagNotifier;
  final FilterCallback onFilter;

  const BasicSection({
    Key? key,
    required this.entry,
    this.collection,
    required this.actionDelegate,
    required this.isEditingTagNotifier,
    required this.onFilter,
  }) : super(key: key);

  int get megaPixels => entry.megaPixels;

  bool get showMegaPixels => entry.isPhoto && megaPixels > 0;

  String get rasterResolutionText => '${entry.resolutionText}${showMegaPixels ? ' • $megaPixels MP' : ''}';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final infoUnknown = l10n.viewerInfoUnknown;
    final locale = l10n.localeName;
    final use24hour = context.select<MediaQueryData, bool>((v) => v.alwaysUse24HourFormat);

    return AnimatedBuilder(
        animation: entry.metadataChangeNotifier,
        builder: (context, child) {
          // TODO TLAD line break on all characters for the following fields when this is fixed: https://github.com/flutter/flutter/issues/61081
          // inserting ZWSP (\u200B) between characters does help, but it messes with width and height computation (another Flutter issue)
          final title = entry.bestTitle ?? infoUnknown;
          final date = entry.bestDate;
          final dateText = date != null ? formatDateTime(date, locale, use24hour) : infoUnknown;
          final showResolution = !entry.isSvg && entry.isSized;
          final sizeText = entry.sizeBytes != null ? formatFilesize(entry.sizeBytes!) : infoUnknown;
          final path = entry.path;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoRowGroup(
                info: {
                  l10n.viewerInfoLabelTitle: title,
                  l10n.viewerInfoLabelDate: dateText,
                  if (entry.isVideo) ..._buildVideoRows(context),
                  if (showResolution) l10n.viewerInfoLabelResolution: rasterResolutionText,
                  l10n.viewerInfoLabelSize: sizeText,
                  l10n.viewerInfoLabelUri: entry.uri,
                  if (path != null) l10n.viewerInfoLabelPath: path,
                },
              ),
              OwnerProp(
                entry: entry,
              ),
              _buildChips(context),
            ],
          );
        });
  }

  Widget _buildChips(BuildContext context) {
    final tags = entry.tags.toList()..sort(compareAsciiUpperCase);
    final album = entry.directory;
    final filters = {
      MimeFilter(entry.mimeType),
      if (entry.isAnimated) TypeFilter.animated,
      if (entry.isGeotiff) TypeFilter.geotiff,
      if (entry.isMotionPhoto) TypeFilter.motionPhoto,
      if (entry.isRaw) TypeFilter.raw,
      if (entry.isImage && entry.is360) TypeFilter.panorama,
      if (entry.isVideo && entry.is360) TypeFilter.sphericalVideo,
      if (entry.isVideo && !entry.is360) MimeFilter.video,
      if (album != null) AlbumFilter(album, collection?.source.getAlbumDisplayName(context, album)),
      ...tags.map((tag) => TagFilter(tag)),
    };
    return AnimatedBuilder(
      animation: favourites,
      builder: (context, child) {
        final effectiveFilters = [
          ...filters,
          if (entry.isFavourite) FavouriteFilter.instance,
        ]..sort();

        final children = <Widget>[
          ...effectiveFilters.map((filter) => AvesFilterChip(
                filter: filter,
                onTap: onFilter,
              )),
          if (actionDelegate.canApply(EntryInfoAction.editTags)) _buildEditTagButton(context),
        ];

        return children.isEmpty
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: AvesFilterChip.outlineWidth / 2) + const EdgeInsets.only(top: 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: children,
                ),
              );
      },
    );
  }

  Widget _buildEditTagButton(BuildContext context) {
    const action = EntryInfoAction.editTags;
    return ValueListenableBuilder<bool>(
      valueListenable: isEditingTagNotifier,
      builder: (context, isEditing, child) {
        return Stack(
          children: [
            DecoratedBox(
              decoration: const BoxDecoration(
                border: Border.fromBorderSide(BorderSide(
                  color: AvesFilterChip.defaultOutlineColor,
                  width: AvesFilterChip.outlineWidth,
                )),
                borderRadius: BorderRadius.all(Radius.circular(AvesFilterChip.defaultRadius)),
              ),
              child: IconButton(
                icon: const Icon(AIcons.addTag),
                onPressed: isEditing ? null : () => actionDelegate.onActionSelected(context, action),
                tooltip: action.getText(context),
              ),
            ),
            if (isEditing)
              const Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.all(1.0),
                  child: CircularProgressIndicator(
                    strokeWidth: AvesFilterChip.outlineWidth,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Map<String, String> _buildVideoRows(BuildContext context) {
    return {
      context.l10n.viewerInfoLabelDuration: entry.durationText,
    };
  }
}

class OwnerProp extends StatefulWidget {
  final AvesEntry entry;

  const OwnerProp({
    Key? key,
    required this.entry,
  }) : super(key: key);

  @override
  _OwnerPropState createState() => _OwnerPropState();
}

class _OwnerPropState extends State<OwnerProp> {
  late Future<String?> _ownerPackageFuture;

  AvesEntry get entry => widget.entry;

  static const ownerPackageNamePropKey = 'owner_package_name';
  static const iconSize = 20.0;

  @override
  void initState() {
    super.initState();
    final isMediaContent = entry.uri.startsWith('content://media/external/');
    if (isMediaContent) {
      _ownerPackageFuture = metadataFetchService.hasContentResolverProp(ownerPackageNamePropKey).then((exists) {
        return exists ? metadataFetchService.getContentResolverProp(entry, ownerPackageNamePropKey) : SynchronousFuture(null);
      });
    } else {
      _ownerPackageFuture = SynchronousFuture(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _ownerPackageFuture,
      builder: (context, snapshot) {
        final ownerPackage = snapshot.data;
        if (ownerPackage == null) return const SizedBox();
        final appName = androidFileUtils.getCurrentAppName(ownerPackage) ?? ownerPackage;
        // as of Flutter v1.22.6, `SelectableText` cannot contain `WidgetSpan`
        // so we use a basic `Text` instead
        return Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: context.l10n.viewerInfoLabelOwner,
                style: InfoRowGroup.keyStyle,
              ),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Image(
                    image: AppIconImage(
                      packageName: ownerPackage,
                      size: iconSize,
                    ),
                    width: iconSize,
                    height: iconSize,
                  ),
                ),
              ),
              TextSpan(
                text: appName,
                style: InfoRowGroup.baseStyle,
              ),
            ],
          ),
        );
      },
    );
  }
}
