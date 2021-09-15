import 'package:aves/model/entry.dart';
import 'package:aves/model/settings/map_style.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/utils/debouncer.dart';
import 'package:aves/widgets/common/map/controller.dart';
import 'package:aves/widgets/common/map/geo_map.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/common/thumbnail/scroller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

class MapPage extends StatefulWidget {
  static const routeName = '/collection/map';

  final List<AvesEntry> entries;

  const MapPage({
    Key? key,
    required this.entries,
  }) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final AvesMapController _mapController = AvesMapController();
  late final ValueNotifier<bool> _isAnimatingNotifier;
  final ValueNotifier<int> _selectedIndexNotifier = ValueNotifier(0);
  final Debouncer _debouncer = Debouncer(delay: Durations.mapScrollDebounceDelay);

  List<AvesEntry> get entries => widget.entries;

  @override
  void initState() {
    super.initState();
    if (settings.infoMapStyle.isGoogleMaps) {
      _isAnimatingNotifier = ValueNotifier(true);
      Future.delayed(Durations.pageTransitionAnimation * timeDilation).then((_) {
        if (!mounted) return;
        _isAnimatingNotifier.value = false;
      });
    } else {
      _isAnimatingNotifier = ValueNotifier(false);
    }
    _selectedIndexNotifier.addListener(_onThumbnailIndexChange);
  }

  @override
  void dispose() {
    _mapController.dispose();
    _selectedIndexNotifier.removeListener(_onThumbnailIndexChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQueryDataProvider(
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: GeoMap(
                  controller: _mapController,
                  entries: entries,
                  interactive: true,
                  showBackButton: true,
                  isAnimatingNotifier: _isAnimatingNotifier,
                  onMarkerTap: (markerEntry, getClusterEntries) {
                    final index = entries.indexOf(markerEntry);
                    if (_selectedIndexNotifier.value != index) {
                      _selectedIndexNotifier.value = index;
                    } else {
                      _moveToEntry(markerEntry);
                    }
                  },
                ),
              ),
              const Divider(),
              Selector<MediaQueryData, double>(
                selector: (c, mq) => mq.size.width,
                builder: (c, mqWidth, child) {
                  return ThumbnailScroller(
                    availableWidth: mqWidth,
                    entryCount: entries.length,
                    entryBuilder: (index) => entries[index],
                    indexNotifier: _selectedIndexNotifier,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onThumbnailIndexChange() => _moveToEntry(widget.entries[_selectedIndexNotifier.value]);

  void _moveToEntry(AvesEntry entry) => _debouncer(() => _mapController.moveTo(entry.latLng!));
}
