import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/common/action_controls/quick_choosers/album_chooser.dart';
import 'package:aves/widgets/common/action_controls/quick_choosers/common/button.dart';
import 'package:aves/widgets/common/action_controls/quick_choosers/filter_quick_chooser_mixin.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/filter_grids/common/filter_nav_page.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MoveButton extends ChooserQuickButton<String> {
  final bool copy;

  const MoveButton({
    super.key,
    required this.copy,
    required super.blurred,
    super.onChooserValue,
    required super.onPressed,
  });

  @override
  State<MoveButton> createState() => _MoveButtonState();
}

class _MoveButtonState extends ChooserQuickButtonState<MoveButton, String> {
  EntryAction get action => widget.copy ? EntryAction.copy : EntryAction.move;

  @override
  Widget get icon => action.getIcon();

  @override
  String get tooltip => action.getText(context);

  @override
  Widget buildChooser(Animation<double> animation, PopupMenuPosition chooserPosition) {
    final source = context.read<CollectionSource>();
    final rawAlbums = source.rawAlbums;
    final options = settings.recentDestinationAlbums.where(rawAlbums.contains).toList();
    final takeCount = FilterQuickChooserMixin.maxTotalOptionCount - options.length;
    if (takeCount > 0) {
      final filters = rawAlbums.whereNot(options.contains).map((album) => AlbumFilter(album, null)).toSet();
      final allMapEntries = filters.map((filter) => FilterGridItem(filter, source.recentEntry(filter))).toList();
      allMapEntries.sort(FilterNavigationPage.compareFiltersByDate);
      options.addAll(allMapEntries.take(takeCount).map((v) => v.filter.album));
    }

    return MediaQueryDataProvider(
      child: FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: animation,
          alignment: chooserPosition == PopupMenuPosition.over ? Alignment.bottomCenter : Alignment.topCenter,
          child: AlbumQuickChooser(
            valueNotifier: chooserValueNotifier,
            options: options,
            blurred: widget.blurred,
            chooserPosition: chooserPosition,
            pointerGlobalPosition: pointerGlobalPosition,
          ),
        ),
      ),
    );
  }
}
