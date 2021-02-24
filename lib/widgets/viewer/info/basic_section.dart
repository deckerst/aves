import 'package:aves/image_providers/app_icon_image_provider.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/favourite_repo.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/favourite.dart';
import 'package:aves/model/filters/mime.dart';
import 'package:aves/model/filters/tag.dart';
import 'package:aves/model/filters/type.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/services/metadata_service.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/utils/file_utils.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BasicSection extends StatelessWidget {
  final AvesEntry entry;
  final CollectionLens collection;
  final ValueNotifier<bool> visibleNotifier;
  final FilterCallback onFilter;

  const BasicSection({
    Key key,
    @required this.entry,
    this.collection,
    @required this.visibleNotifier,
    @required this.onFilter,
  }) : super(key: key);

  int get megaPixels => entry.megaPixels;

  bool get showMegaPixels => entry.isPhoto && megaPixels != null && megaPixels > 0;

  String get rasterResolutionText => '${entry.resolutionText}${showMegaPixels ? ' • $megaPixels MP' : ''}';

  @override
  Widget build(BuildContext context) {
    final date = entry.bestDate;
    final dateText = date != null ? '${DateFormat.yMMMd().format(date)} • ${DateFormat.Hm().format(date)}' : Constants.infoUnknown;

    // TODO TLAD line break on all characters for the following fields when this is fixed: https://github.com/flutter/flutter/issues/61081
    // inserting ZWSP (\u200B) between characters does help, but it messes with width and height computation (another Flutter issue)
    final title = entry.bestTitle ?? Constants.infoUnknown;
    final uri = entry.uri ?? Constants.infoUnknown;
    final path = entry.path;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InfoRowGroup({
          'Title': title,
          'Date': dateText,
          if (entry.isVideo) ..._buildVideoRows(),
          if (!entry.isSvg && entry.isSized) 'Resolution': rasterResolutionText,
          'Size': entry.sizeBytes != null ? formatFilesize(entry.sizeBytes) : Constants.infoUnknown,
          'URI': uri,
          if (path != null) 'Path': path,
        }),
        OwnerProp(
          entry: entry,
          visibleNotifier: visibleNotifier,
        ),
        _buildChips(),
      ],
    );
  }

  Widget _buildChips() {
    final tags = entry.xmpSubjects..sort(compareAsciiUpperCase);
    final album = entry.directory;
    final filters = {
      MimeFilter(entry.mimeType),
      if (entry.isAnimated) TypeFilter(TypeFilter.animated),
      if (entry.isGeotiff) TypeFilter(TypeFilter.geotiff),
      if (entry.isImage && entry.is360) TypeFilter(TypeFilter.panorama),
      if (entry.isVideo && entry.is360) TypeFilter(TypeFilter.sphericalVideo),
      if (entry.isVideo && !entry.is360) MimeFilter(MimeTypes.anyVideo),
      if (album != null) AlbumFilter(album, collection?.source?.getUniqueAlbumName(album)),
      ...tags.map((tag) => TagFilter(tag)),
    };
    return AnimatedBuilder(
      animation: favourites.changeNotifier,
      builder: (context, child) {
        final effectiveFilters = [
          ...filters,
          if (entry.isFavourite) FavouriteFilter(),
        ]..sort();
        if (effectiveFilters.isEmpty) return SizedBox.shrink();
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: AvesFilterChip.outlineWidth / 2) + EdgeInsets.only(top: 8),
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

  Map<String, String> _buildVideoRows() {
    return {
      'Duration': entry.durationText,
    };
  }
}

class OwnerProp extends StatefulWidget {
  final AvesEntry entry;
  final ValueNotifier<bool> visibleNotifier;

  const OwnerProp({
    @required this.entry,
    @required this.visibleNotifier,
  });

  @override
  _OwnerPropState createState() => _OwnerPropState();
}

class _OwnerPropState extends State<OwnerProp> {
  final ValueNotifier<String> _loadedUri = ValueNotifier(null);
  String _ownerPackage;

  AvesEntry get entry => widget.entry;

  bool get isVisible => widget.visibleNotifier.value;

  static const iconSize = 20.0;

  @override
  void initState() {
    super.initState();
    _registerWidget(widget);
    _getOwner();
  }

  @override
  void didUpdateWidget(covariant OwnerProp oldWidget) {
    super.didUpdateWidget(oldWidget);
    _unregisterWidget(oldWidget);
    _registerWidget(widget);
    _getOwner();
  }

  @override
  void dispose() {
    _unregisterWidget(widget);
    super.dispose();
  }

  void _registerWidget(OwnerProp widget) {
    widget.visibleNotifier.addListener(_getOwner);
  }

  void _unregisterWidget(OwnerProp widget) {
    widget.visibleNotifier.removeListener(_getOwner);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: _loadedUri,
      builder: (context, uri, child) {
        if (_ownerPackage == null) return SizedBox();
        final appName = androidFileUtils.getCurrentAppName(_ownerPackage) ?? _ownerPackage;
        // as of Flutter v1.22.6, `SelectableText` cannot contain `WidgetSpan`
        // so be use a basic `Text` instead
        return Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Owned by',
                style: InfoRowGroup.keyStyle,
              ),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Image(
                    image: AppIconImage(
                      packageName: _ownerPackage,
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

  Future<void> _getOwner() async {
    if (entry == null) return;
    if (_loadedUri.value == entry.uri) return;
    if (isVisible) {
      _ownerPackage = await MetadataService.getContentResolverProp(widget.entry, 'owner_package_name');
      _loadedUri.value = entry.uri;
    } else {
      _ownerPackage = null;
      _loadedUri.value = null;
    }
  }
}
