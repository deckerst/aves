import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/utils/debouncer.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/empty.dart';
import 'package:aves/widgets/common/thumbnail/scroller.dart';
import 'package:aves/widgets/map/info_row.dart';
import 'package:flutter/material.dart';

class MapEntryScroller extends StatefulWidget {
  final ValueNotifier<CollectionLens?> regionCollectionNotifier;
  final ValueNotifier<AvesEntry?> dotEntryNotifier;
  final ValueNotifier<int?> selectedIndexNotifier;
  final void Function(int index) onTap;

  const MapEntryScroller({
    super.key,
    required this.regionCollectionNotifier,
    required this.dotEntryNotifier,
    required this.selectedIndexNotifier,
    required this.onTap,
  });

  @override
  State<MapEntryScroller> createState() => _MapEntryScrollerState();
}

class _MapEntryScrollerState extends State<MapEntryScroller> {
  final ValueNotifier<AvesEntry?> _infoEntryNotifier = ValueNotifier(null);
  final Debouncer _infoDebouncer = Debouncer(delay: Durations.mapInfoDebounceDelay);

  @override
  void initState() {
    super.initState();
    _registerWidget(widget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onSelectedEntryChanged());
  }

  @override
  void didUpdateWidget(covariant MapEntryScroller oldWidget) {
    super.didUpdateWidget(oldWidget);
    _unregisterWidget(oldWidget);
    _registerWidget(widget);
  }

  @override
  void dispose() {
    _unregisterWidget(widget);
    super.dispose();
  }

  void _registerWidget(MapEntryScroller widget) {
    widget.dotEntryNotifier.addListener(_onSelectedEntryChanged);
  }

  void _unregisterWidget(MapEntryScroller widget) {
    widget.dotEntryNotifier.removeListener(_onSelectedEntryChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SafeArea(
              top: false,
              bottom: false,
              child: MapInfoRow(entryNotifier: _infoEntryNotifier),
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder<CollectionLens?>(
              valueListenable: widget.regionCollectionNotifier,
              builder: (context, regionCollection, child) {
                return AnimatedBuilder(
                  // update when entries are added/removed
                  animation: regionCollection ?? ChangeNotifier(),
                  builder: (context, child) {
                    final regionEntries = regionCollection?.sortedEntries ?? [];
                    return ThumbnailScroller(
                      availableWidth: MediaQuery.sizeOf(context).width,
                      entryCount: regionEntries.length,
                      entryBuilder: (index) => index < regionEntries.length ? regionEntries[index] : null,
                      indexNotifier: widget.selectedIndexNotifier,
                      onTap: widget.onTap,
                      heroTagger: (entry) => Object.hashAll([regionCollection?.id, entry.id]),
                      highlightable: true,
                      showLocation: false,
                    );
                  },
                );
              },
            ),
          ],
        ),
        Positioned.fill(
          child: ValueListenableBuilder<CollectionLens?>(
            valueListenable: widget.regionCollectionNotifier,
            builder: (context, regionCollection, child) {
              return regionCollection != null && regionCollection.isEmpty
                  ? EmptyContent(
                      text: context.l10n.mapEmptyRegion,
                      alignment: Alignment.center,
                      fontSize: 18,
                    )
                  : const SizedBox();
            },
          ),
        ),
      ],
    );
  }

  void _onSelectedEntryChanged() {
    final selectedEntry = widget.dotEntryNotifier.value;
    if (_infoEntryNotifier.value == null || selectedEntry == null) {
      _infoEntryNotifier.value = selectedEntry;
    } else {
      _infoDebouncer(() => _infoEntryNotifier.value = selectedEntry);
    }
  }
}
