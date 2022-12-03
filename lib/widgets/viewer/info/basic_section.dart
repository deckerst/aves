import 'package:aves/app_mode.dart';
import 'package:aves/image_providers/app_icon_image_provider.dart';
import 'package:aves/model/actions/entry_actions.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/favourites.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/favourite.dart';
import 'package:aves/model/filters/mime.dart';
import 'package:aves/model/filters/rating.dart';
import 'package:aves/model/filters/tag.dart';
import 'package:aves/model/filters/type.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/theme/format.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/utils/file_utils.dart';
import 'package:aves/widgets/common/app_bar/rate_button.dart';
import 'package:aves/widgets/common/app_bar/tag_button.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:aves/widgets/viewer/action/entry_info_action_delegate.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BasicSection extends StatelessWidget {
  final AvesEntry entry;
  final CollectionLens? collection;
  final EntryInfoActionDelegate actionDelegate;
  final ValueNotifier<EntryAction?> isEditingMetadataNotifier;
  final FilterCallback onFilter;

  const BasicSection({
    super.key,
    required this.entry,
    this.collection,
    required this.actionDelegate,
    required this.isEditingMetadataNotifier,
    required this.onFilter,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: entry.metadataChangeNotifier,
        builder: (context, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BasicInfo(entry: entry),
              _buildChips(context),
              _buildEditButtons(context),
            ],
          );
        });
  }

  Widget _buildChips(BuildContext context) {
    final tags = entry.tags.toList()..sort(compareAsciiUpperCaseNatural);
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
      if (entry.rating != 0) RatingFilter(entry.rating),
      ...tags.map(TagFilter.new),
    };
    return AnimatedBuilder(
      animation: favourites,
      builder: (context, child) {
        final effectiveFilters = [
          ...filters,
          if (entry.isFavourite) FavouriteFilter.instance,
        ]..sort();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AvesFilterChip.outlineWidth / 2) + const EdgeInsets.only(top: 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: effectiveFilters
                .map((filter) => AvesFilterChip(
                      filter: filter,
                      onTap: onFilter,
                    ))
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildEditButtons(BuildContext context) {
    final children = [
      EntryAction.editRating,
      EntryAction.editTags,
    ].where((v) => actionDelegate.canApply(entry, v)).map((v) => _buildEditMetadataButton(context, v)).toList();

    return children.isEmpty
        ? const SizedBox()
        : TooltipTheme(
            data: TooltipTheme.of(context).copyWith(
              preferBelow: false,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AvesFilterChip.outlineWidth / 2) + const EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: children,
              ),
            ),
          );
  }

  Widget _buildEditMetadataButton(BuildContext context, EntryAction action) {
    return ValueListenableBuilder<EntryAction?>(
      valueListenable: isEditingMetadataNotifier,
      builder: (context, editingAction, child) {
        final isEditing = editingAction != null;
        final onPressed = isEditing ? null : () => actionDelegate.onActionSelected(context, entry, collection, action);
        Widget button;
        switch (action) {
          case EntryAction.editRating:
            button = RateButton(
              blurred: false,
              onChooserValue: (rating) => actionDelegate.quickRate(context, entry, rating),
              onPressed: onPressed,
            );
            break;
          case EntryAction.editTags:
            button = TagButton(
              blurred: false,
              onChooserValue: (filter) => actionDelegate.quickTag(context, entry, filter),
              onPressed: onPressed,
            );
            break;
          default:
            button = IconButton(
              icon: action.getIcon(),
              onPressed: onPressed,
              tooltip: action.getText(context),
            );
            break;
        }
        return Stack(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border.fromBorderSide(BorderSide(
                  color: isEditing ? Theme.of(context).disabledColor : context.select<AvesColorsData, Color>((v) => v.neutral),
                  width: AvesFilterChip.outlineWidth,
                )),
                borderRadius: const BorderRadius.all(Radius.circular(AvesFilterChip.defaultRadius)),
              ),
              child: button,
            ),
            Positioned.fill(
              child: Visibility(
                visible: editingAction == action,
                child: const Padding(
                  padding: EdgeInsets.all(1.0),
                  child: CircularProgressIndicator(
                    strokeWidth: AvesFilterChip.outlineWidth,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BasicInfo extends StatefulWidget {
  final AvesEntry entry;

  const _BasicInfo({
    required this.entry,
  });

  @override
  State<_BasicInfo> createState() => _BasicInfoState();
}

class _BasicInfoState extends State<_BasicInfo> {
  Future<String?> _ownerPackageLoader = SynchronousFuture(null);
  Future<void> _appNameLoader = SynchronousFuture(null);

  AvesEntry get entry => widget.entry;

  int get megaPixels => entry.megaPixels;

  bool get showMegaPixels => entry.isPhoto && megaPixels > 0;

  String get rasterResolutionText => '${entry.resolutionText}${showMegaPixels ? ' • $megaPixels MP' : ''}';

  static const ownerPackageNamePropKey = 'owner_package_name';
  static const iconSize = 20.0;

  @override
  void initState() {
    super.initState();
    if (!entry.trashed && entry.isMediaStoreMediaContent) {
      _ownerPackageLoader = metadataFetchService.hasContentResolverProp(ownerPackageNamePropKey).then((exists) {
        return exists ? metadataFetchService.getContentResolverProp(entry, ownerPackageNamePropKey) : SynchronousFuture(null);
      });
      final isViewerMode = context.read<ValueNotifier<AppMode>>().value == AppMode.view;
      if (isViewerMode && settings.isInstalledAppAccessAllowed) {
        _appNameLoader = androidFileUtils.initAppNames();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final infoUnknown = l10n.viewerInfoUnknown;
    final locale = l10n.localeName;
    final use24hour = context.select<MediaQueryData, bool>((v) => v.alwaysUse24HourFormat);

    // TODO TLAD line break on all characters for the following fields when this is fixed: https://github.com/flutter/flutter/issues/61081
    // inserting ZWSP (\u200B) between characters does help, but it messes with width and height computation (another Flutter issue)
    final title = entry.bestTitle ?? infoUnknown;
    final date = entry.bestDate;
    final dateText = date != null ? formatDateTime(date, locale, use24hour) : infoUnknown;
    final showResolution = !entry.isSvg && entry.isSized;
    final sizeText = entry.sizeBytes != null ? formatFileSize(locale, entry.sizeBytes!) : infoUnknown;
    final path = entry.path;

    return FutureBuilder<String?>(
      future: _ownerPackageLoader,
      builder: (context, snapshot) {
        final ownerPackage = snapshot.data;
        return FutureBuilder<void>(
          future: _appNameLoader,
          builder: (context, snapshot) {
            return InfoRowGroup(
              info: {
                l10n.viewerInfoLabelTitle: title,
                l10n.viewerInfoLabelDate: dateText,
                if (entry.isVideo) ..._buildVideoRows(context),
                if (showResolution) l10n.viewerInfoLabelResolution: rasterResolutionText,
                l10n.viewerInfoLabelSize: sizeText,
                if (!entry.trashed) l10n.viewerInfoLabelUri: entry.uri,
                if (path != null) l10n.viewerInfoLabelPath: path,
                if (ownerPackage != null) l10n.viewerInfoLabelOwner: ownerPackage,
              },
              spanBuilders: {
                l10n.viewerInfoLabelOwner: _ownerHandler(ownerPackage),
              },
            );
          },
        );
      },
    );
  }

  Map<String, String> _buildVideoRows(BuildContext context) {
    return {
      context.l10n.viewerInfoLabelDuration: entry.durationText,
    };
  }

  InfoValueSpanBuilder _ownerHandler(String? ownerPackage) {
    if (ownerPackage == null) return (context, key, value) => [];

    final appName = androidFileUtils.getCurrentAppName(ownerPackage) ?? ownerPackage;
    return (context, key, value) => [
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(end: 4),
              child: ConstrainedBox(
                // use constraints instead of sizing `Image`,
                // so that it can collapse when handling an empty image
                constraints: const BoxConstraints(
                  maxWidth: iconSize,
                  maxHeight: iconSize,
                ),
                child: Image(
                  image: AppIconImage(
                    packageName: ownerPackage,
                    size: iconSize,
                  ),
                ),
              ),
            ),
          ),
          TextSpan(
            text: appName,
            style: InfoRowGroup.valueStyle,
          ),
        ];
  }
}
