import 'package:aves/model/actions/entry_actions.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/tag.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/widgets/common/app_bar/quick_choosers/chooser_button.dart';
import 'package:aves/widgets/common/app_bar/quick_choosers/filter_chooser.dart';
import 'package:aves/widgets/common/app_bar/quick_choosers/tag_chooser.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/filter_grids/common/filter_nav_page.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TagButton extends ChooserQuickButton<CollectionFilter> {
  const TagButton({
    super.key,
    super.chooserPosition,
    super.onChooserValue,
    required super.onPressed,
  });

  @override
  State<TagButton> createState() => _TagButtonState();
}

class _TagButtonState extends ChooserQuickButtonState<TagButton, CollectionFilter> {
  EntryAction get action => EntryAction.editTags;

  @override
  Widget get icon => action.getIcon();

  @override
  String get tooltip => action.getText(context);

  @override
  Widget buildChooser(Animation<double> animation) {
    final options = settings.recentTags;
    final takeCount = FilterQuickChooser.maxOptionCount - options.length;
    if (takeCount > 0) {
      final source = context.read<CollectionSource>();
      final filters = source.sortedTags.map(TagFilter.new).whereNot(options.contains).toSet();
      final allMapEntries = filters.map((filter) => FilterGridItem(filter, source.recentEntry(filter))).toList();
      allMapEntries.sort(FilterNavigationPage.compareFiltersByDate);
      options.addAll(allMapEntries.take(takeCount).map((v) => v.filter));
    }

    return MediaQueryDataProvider(
      child: FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: animation,
          child: TagQuickChooser(
            valueNotifier: chooserValueNotifier,
            options: widget.chooserPosition == PopupMenuPosition.over ? options.reversed.toList() : options,
            pointerGlobalPosition: pointerGlobalPosition,
          ),
        ),
      ),
    );
  }
}
