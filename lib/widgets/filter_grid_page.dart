import 'dart:typed_data';
import 'dart:ui';

import 'package:aves/model/collection_lens.dart';
import 'package:aves/model/collection_source.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/settings.dart';
import 'package:aves/services/image_file_service.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/album/collection_page.dart';
import 'package:aves/widgets/app_drawer.dart';
import 'package:aves/widgets/common/aves_filter_chip.dart';
import 'package:aves/widgets/common/data_providers/media_query_data_provider.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:aves/widgets/common/image_providers/thumbnail_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class FilterNavigationPage extends StatelessWidget {
  final CollectionSource source;
  final String title;
  final Map<String, ImageEntry> filterEntries;
  final CollectionFilter Function(String key) filterBuilder;

  const FilterNavigationPage({
    @required this.source,
    @required this.title,
    @required this.filterEntries,
    @required this.filterBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return FilterGridPage(
      source: source,
      appBar: SliverAppBar(
        title: Text(title),
        floating: true,
      ),
      filterEntries: filterEntries,
      filterBuilder: filterBuilder,
      onPressed: (filter) => Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => CollectionPage(CollectionLens(
            source: source,
            filters: [filter],
            groupFactor: settings.collectionGroupFactor,
            sortFactor: settings.collectionSortFactor,
          )),
        ),
        (route) => false,
      ),
    );
  }
}

class FilterGridPage extends StatelessWidget {
  final CollectionSource source;
  final Widget appBar;
  final Map<String, ImageEntry> filterEntries;
  final CollectionFilter Function(String key) filterBuilder;
  final FilterCallback onPressed;

  const FilterGridPage({
    @required this.source,
    @required this.appBar,
    @required this.filterEntries,
    @required this.filterBuilder,
    @required this.onPressed,
  });

  List<String> get filterKeys => filterEntries.keys.toList();

  static const Color detailColor = Color(0xFFE0E0E0);
  static const double maxCrossAxisExtent = 180;

  @override
  Widget build(BuildContext context) {
    return MediaQueryDataProvider(
      child: Scaffold(
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              appBar,
              SliverPadding(
                padding: const EdgeInsets.all(AvesFilterChip.outlineWidth),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final key = filterKeys[i];
                      return DecoratedFilterChip(
                        source: source,
                        filter: filterBuilder(key),
                        entry: filterEntries[key],
                        onPressed: onPressed,
                      );
                    },
                    childCount: filterKeys.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: maxCrossAxisExtent,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Selector<MediaQueryData, double>(
                  selector: (context, mq) => mq.viewInsets.bottom,
                  builder: (context, mqViewInsetsBottom, child) {
                    return SizedBox(height: mqViewInsetsBottom);
                  },
                ),
              ),
            ],
          ),
        ),
        drawer: AppDrawer(
          source: source,
        ),
        resizeToAvoidBottomInset: false,
      ),
    );
  }
}

class DecoratedFilterChip extends StatefulWidget {
  final CollectionSource source;
  final CollectionFilter filter;
  final ImageEntry entry;
  final FilterCallback onPressed;

  const DecoratedFilterChip({
    @required this.source,
    @required this.filter,
    @required this.entry,
    @required this.onPressed,
  });

  @override
  _DecoratedFilterChipState createState() => _DecoratedFilterChipState();
}

class _DecoratedFilterChipState extends State<DecoratedFilterChip> {
  CollectionSource get source => widget.source;

  CollectionFilter get filter => widget.filter;

  ImageEntry get entry => widget.entry;

  Future<Uint8List> _svgByteLoader;

  @override
  void initState() {
    super.initState();
    _svgByteLoader = _initSvgByteLoader();
  }

  @override
  void didUpdateWidget(DecoratedFilterChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entry != entry) {
      _svgByteLoader = _initSvgByteLoader();
    }
  }

  Future<Uint8List> _initSvgByteLoader() async {
    if (entry == null || !entry.isSvg) return null;

    final uri = entry.uri;
    final bytes = await ImageFileService.getImage(uri, entry.mimeType);
    if (bytes == null || bytes.isEmpty) return bytes;

    final svgRoot = await svg.fromSvgBytes(bytes, uri);
    const extent = FilterGridPage.maxCrossAxisExtent;
    final picture = svgRoot.toPicture(size: const Size(extent, extent));
    final uiImage = await picture.toImage(extent.ceil(), extent.ceil());
    final data = await uiImage.toByteData(format: ImageByteFormat.png);
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  @override
  Widget build(BuildContext context) {
    if (entry == null || !entry.isSvg) {
      Decoration decoration;
      if (entry != null) {
        decoration = BoxDecoration(
          image: DecorationImage(
            image: ThumbnailProvider(
              entry: entry,
              extent: FilterGridPage.maxCrossAxisExtent,
            ),
            fit: BoxFit.cover,
          ),
          borderRadius: AvesFilterChip.borderRadius,
        );
      }
      return _buildChip(decoration);
    }

    return FutureBuilder(
      future: _svgByteLoader,
      builder: (context, AsyncSnapshot<Uint8List> snapshot) {
        Decoration decoration;
        if (!snapshot.hasError && snapshot.connectionState == ConnectionState.done) {
          decoration = BoxDecoration(
            image: DecorationImage(
              image: MemoryImage(snapshot.data),
              fit: BoxFit.cover,
            ),
            borderRadius: AvesFilterChip.borderRadius,
          );
        }
        return _buildChip(decoration);
      },
    );
  }

  AvesFilterChip _buildChip(Decoration decoration) {
    return AvesFilterChip(
      filter: filter,
      showGenericIcon: false,
      decoration: decoration,
      details: _buildDetails(filter),
      onPressed: widget.onPressed,
    );
  }

  Widget _buildDetails(CollectionFilter filter) {
    final count = Text(
      '${source.count(filter)}',
      style: const TextStyle(color: FilterGridPage.detailColor),
    );
    return filter is AlbumFilter && androidFileUtils.isOnRemovableStorage(filter.album)
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                AIcons.removableStorage,
                size: 16,
                color: FilterGridPage.detailColor,
              ),
              const SizedBox(width: 8),
              count,
            ],
          )
        : count;
  }
}
