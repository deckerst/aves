import 'dart:math';

import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/section_keys.dart';
import 'package:aves/widgets/collection/grid/headers/album.dart';
import 'package:aves/widgets/collection/grid/headers/date.dart';
import 'package:aves/widgets/collection/grid/headers/rating.dart';
import 'package:aves/widgets/common/grid/header.dart';
import 'package:flutter/material.dart';

class CollectionSectionHeader extends StatelessWidget {
  final CollectionLens collection;
  final SectionKey sectionKey;
  final double height;
  final bool selectable;

  const CollectionSectionHeader({
    super.key,
    required this.collection,
    required this.sectionKey,
    required this.height,
    required this.selectable,
  });

  @override
  Widget build(BuildContext context) {
    final header = _buildHeader(context);
    return header != null
        ? SizedBox(
            height: height,
            child: header,
          )
        : const SizedBox();
  }

  Widget? _buildHeader(BuildContext context) {
    switch (collection.sortFactor) {
      case .date:
        switch (collection.sectionFactor) {
          case .album:
            return _buildAlbumHeader(context);
          case .month:
            return MonthSectionHeader<AvesEntry>(
              key: ValueKey(sectionKey),
              date: (sectionKey as EntryDateSectionKey).date,
              selectable: selectable,
            );
          case .day:
            return DaySectionHeader<AvesEntry>(
              key: ValueKey(sectionKey),
              date: (sectionKey as EntryDateSectionKey).date,
              selectable: selectable,
            );
          case .none:
            break;
        }
      case .name:
      case .path:
        return _buildAlbumHeader(context);
      case .rating:
        return RatingSectionHeader<AvesEntry>(
          key: ValueKey(sectionKey),
          rating: (sectionKey as EntryRatingSectionKey).rating,
          selectable: selectable,
        );
      case .size:
      case .duration:
        break;
    }
    return null;
  }

  Widget _buildAlbumHeader(BuildContext context) {
    final source = collection.source;
    final directory = (sectionKey as EntryAlbumSectionKey).directory;
    return AlbumSectionHeader(
      key: ValueKey(sectionKey),
      directory: directory,
      albumName: directory != null ? source.getStoredAlbumDisplayName(context, directory) : null,
      selectable: selectable,
    );
  }

  static double getPreferredHeight(BuildContext context, double maxWidth, CollectionSource source, SectionKey sectionKey) {
    var headerExtent = 0.0;
    if (sectionKey is EntryAlbumSectionKey) {
      // only compute height for album headers, as they're the only likely ones to split on multiple lines
      headerExtent = AlbumSectionHeader.getPreferredHeight(context, maxWidth, source, sectionKey);
    }

    final textScaler = MediaQuery.textScalerOf(context);
    headerExtent = max(headerExtent, textScaler.scale(SectionHeader.leadingSize.height)) + SectionHeader.padding.vertical + SectionHeader.margin.vertical;
    return headerExtent;
  }
}
