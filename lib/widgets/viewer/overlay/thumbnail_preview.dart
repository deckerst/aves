import 'package:aves/model/entry/entry.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/utils/debouncer.dart';
import 'package:aves/widgets/common/thumbnail/scroller.dart';
import 'package:aves/widgets/viewer/controls/notifications.dart';
import 'package:flutter/material.dart';

class ViewerThumbnailPreview extends StatefulWidget {
  final List<AvesEntry> entries;
  final int displayedIndex;
  final double availableWidth;

  const ViewerThumbnailPreview({
    super.key,
    required this.entries,
    required this.displayedIndex,
    required this.availableWidth,
  });

  @override
  State<ViewerThumbnailPreview> createState() => _ViewerThumbnailPreviewState();

  static double get preferredHeight => ThumbnailScroller.preferredHeight;
}

class _ViewerThumbnailPreviewState extends State<ViewerThumbnailPreview> {
  final ValueNotifier<int> _entryIndexNotifier = ValueNotifier(0);
  final Debouncer _debouncer = Debouncer(delay: Durations.viewerThumbnailScrollDebounceDelay);

  List<AvesEntry> get entries => widget.entries;

  int get entryCount => entries.length;

  @override
  void initState() {
    super.initState();
    _entryIndexNotifier.value = widget.displayedIndex;
    _entryIndexNotifier.addListener(_onScrollerIndexChanged);
  }

  @override
  void didUpdateWidget(covariant ViewerThumbnailPreview oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.displayedIndex != widget.displayedIndex) {
      _entryIndexNotifier.value = widget.displayedIndex;
    }
  }

  @override
  void dispose() {
    _entryIndexNotifier.removeListener(_onScrollerIndexChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThumbnailScroller(
      availableWidth: widget.availableWidth,
      entryCount: entryCount,
      entryBuilder: (index) => 0 <= index && index < entryCount ? entries[index] : null,
      indexNotifier: _entryIndexNotifier,
      onTap: (index) => ShowEntryNotification(animate: false, index: index).dispatch(context),
    );
  }

  void _onScrollerIndexChanged() => _debouncer(() {
        if (mounted) {
          ShowEntryNotification(animate: false, index: _entryIndexNotifier.value).dispatch(context);
        }
      });
}
