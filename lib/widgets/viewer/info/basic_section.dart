import 'package:aves/app_mode.dart';
import 'package:aves/image_providers/app_icon_image_provider.dart';
import 'package:aves/model/apps.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/favourites.dart';
import 'package:aves/model/entry/extensions/multipage.dart';
import 'package:aves/model/entry/extensions/props.dart';
import 'package:aves/model/favourites.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/favourite.dart';
import 'package:aves/model/filters/mime.dart';
import 'package:aves/model/filters/rating.dart';
import 'package:aves/model/filters/tag.dart';
import 'package:aves/model/filters/type.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/theme/format.dart';
import 'package:aves/utils/file_utils.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/common/action_controls/quick_choosers/rate_button.dart';
import 'package:aves/widgets/common/action_controls/quick_choosers/tag_button.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:aves/widgets/viewer/action/entry_info_action_delegate.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BasicSection extends StatefulWidget {
  final AvesEntry entry;
  final CollectionLens? collection;
  final EntryInfoActionDelegate actionDelegate;
  final ValueNotifier<bool> isScrollingNotifier;
  final ValueNotifier<EntryAction?> isEditingMetadataNotifier;
  final FilterCallback onFilter;

  const BasicSection({
    super.key,
    required this.entry,
    this.collection,
    required this.actionDelegate,
    required this.isScrollingNotifier,
    required this.isEditingMetadataNotifier,
    required this.onFilter,
  });

  @override
  State<BasicSection> createState() => _BasicSectionState();
}

class _BasicSectionState extends State<BasicSection> {
  final FocusNode _chipFocusNode = FocusNode();

  CollectionLens? get collection => widget.collection;

  EntryInfoActionDelegate get actionDelegate => widget.actionDelegate;

  @override
  void initState() {
    super.initState();
    _registerWidget(widget);
    _onScrollingChanged();
  }

  @override
  void didUpdateWidget(covariant BasicSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _unregisterWidget(oldWidget);
    _registerWidget(widget);
  }

  @override
  void dispose() {
    _unregisterWidget(widget);
    _chipFocusNode.dispose();
    super.dispose();
  }

  void _registerWidget(BasicSection widget) {
    widget.isScrollingNotifier.addListener(_onScrollingChanged);
  }

  void _unregisterWidget(BasicSection widget) {
    widget.isScrollingNotifier.removeListener(_onScrollingChanged);
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    return AnimatedBuilder(
        animation: entry.metadataChangeNotifier,
        builder: (context, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BasicInfo(entry: entry),
              Focus(
                focusNode: _chipFocusNode,
                skipTraversal: true,
                canRequestFocus: false,
                child: _buildChips(context),
              ),
              _buildEditButtons(context),
            ],
          );
        });
  }

  Widget _buildChips(BuildContext context) {
    final entry = widget.entry;
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
                      onTap: widget.onFilter,
                    ))
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildEditButtons(BuildContext context) {
    final appMode = context.watch<ValueNotifier<AppMode>>().value;
    final entry = widget.entry;
    final children = [
      EntryAction.editRating,
      EntryAction.editTags,
    ]
        .where((v) => actionDelegate.isVisible(
              appMode: appMode,
              targetEntry: entry,
              action: v,
            ))
        .where((v) => actionDelegate.canApply(entry, v))
        .map((v) => _buildEditMetadataButton(context, v))
        .toList();

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
    final entry = widget.entry;
    return ValueListenableBuilder<EntryAction?>(
      valueListenable: widget.isEditingMetadataNotifier,
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
          case EntryAction.editTags:
            button = TagButton(
              blurred: false,
              onChooserValue: (filter) => actionDelegate.quickTag(context, entry, filter),
              onPressed: onPressed,
            );
          default:
            button = IconButton(
              icon: action.getIcon(),
              onPressed: onPressed,
              tooltip: action.getText(context),
            );
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

  void _onScrollingChanged() {
    if (!widget.isScrollingNotifier.value) {
      if (settings.useTvLayout) {
        // using `autofocus` while scrolling seems to fail for widget built offscreen
        // so we give focus to this page when the screen is no longer scrolling
        _chipFocusNode.children.firstOrNull?.requestFocus();
      }
    }
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

  int get megaPixels => (entry.width * entry.height / 1000000).round();

  // guess whether this is a photo, according to file type
  bool get isPhoto => [MimeTypes.heic, MimeTypes.heif, MimeTypes.jpeg, MimeTypes.tiff].contains(entry.mimeType) || entry.isRaw;

  bool get showMegaPixels => isPhoto && megaPixels > 0;

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
        _appNameLoader = appInventory.initAppNames();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final infoUnknown = l10n.viewerInfoUnknown;
    final locale = l10n.localeName;
    final use24hour = MediaQuery.alwaysUse24HourFormatOf(context);

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

    final appName = appInventory.getCurrentAppName(ownerPackage) ?? ownerPackage;
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
