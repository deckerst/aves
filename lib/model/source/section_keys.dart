import 'package:aves/model/covers.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/grid/header.dart';
import 'package:aves_model/aves_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

@immutable
class const SectionKey() {
  double getPreferredHeight(BuildContext context, double maxWidth, {CollectionSource? source}) {
    return SectionHeader.getPreferredHeight(
      context: context,
      maxWidth: maxWidth,
      title: getTitle(context),
      hasLeading: hasLeading,
      hasTrailing: hasTrailing,
    );
  }

  String getTitle(BuildContext context) => '';

  bool get hasLeading => false;

  bool get hasTrailing => false;
}

class const EntryAlbumSectionKey(final String? directory) extends SectionKey with Equatable {
  @override
  List<Object?> get props => [directory];

  @override
  double getPreferredHeight(BuildContext context, double maxWidth, {CollectionSource? source}) {
    if (source == null) throw ArgumentError('collection source is null');

    final _directory = directory;
    if (_directory == null) {
      return SectionHeader.getPreferredHeight(
        context: context,
        maxWidth: maxWidth,
        title: context.l10n.sectionUnknown,
        hasLeading: false,
        hasTrailing: false,
      );
    }

    return SectionHeader.getPreferredHeight(
      context: context,
      maxWidth: maxWidth,
      title: source.getStoredAlbumDisplayName(context, _directory),
      hasLeading: covers.effectiveAlbumType(_directory) != AlbumType.regular,
      hasTrailing: androidFileUtils.isOnRemovableStorage(_directory),
    );
  }
}

class const EntryDateSectionKey({final int? year, final int? month, final int? day}) extends SectionKey with Equatable {
  @override
  List<Object?> get props => [year, month, day];

  static const EntryDateSectionKey unknown = EntryDateSectionKey();
}

class const EntryRatingSectionKey(final int rating) extends SectionKey with Equatable {
  @override
  List<Object?> get props => [rating];
}
