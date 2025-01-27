import 'dart:async';
import 'dart:convert';

import 'package:aves/app_mode.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/location.dart';
import 'package:aves/model/entry/extensions/metadata_edition.dart';
import 'package:aves/model/entry/sort.dart';
import 'package:aves/model/filters/covered/location.dart';
import 'package:aves/model/metadata/catalog.dart';
import 'package:aves/model/settings/enums/coordinate_format.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/ref/poi.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/format.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/theme/themes.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/aves_app.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/basic/text_dropdown_button.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/fx/transitions.dart';
import 'package:aves/widgets/common/identity/aves_caption.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/dialogs/item_picker.dart';
import 'package:aves/widgets/dialogs/pick_dialogs/item_pick_page.dart';
import 'package:aves/widgets/dialogs/pick_dialogs/location_pick_page.dart';
import 'package:aves/widgets/dialogs/time_shift_dialog.dart';
import 'package:aves/widgets/map/map_page.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:gpx/gpx.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class EditEntryLocationDialog extends StatefulWidget {
  static const routeName = '/dialog/edit_entry_location';

  final Set<AvesEntry> entries;
  final CollectionLens? collection;

  const EditEntryLocationDialog({
    super.key,
    required this.entries,
    this.collection,
  });

  @override
  State<EditEntryLocationDialog> createState() => _EditEntryLocationDialogState();
}

class _EditEntryLocationDialogState extends State<EditEntryLocationDialog> with FeedbackMixin {
  final List<StreamSubscription> _subscriptions = [];
  LocationEditAction _action = LocationEditAction.chooseOnMap;
  LatLng? _mapCoordinates;
  late final AvesEntry mainEntry;
  late AvesEntry _copyItemSource;
  Gpx? _gpx;
  Duration _gpxShift = Duration.zero;
  final Map<AvesEntry, LatLng> _gpxMap = {};
  final TextEditingController _latitudeController = TextEditingController(), _longitudeController = TextEditingController();
  final ValueNotifier<bool> _isValidNotifier = ValueNotifier(false);

  NumberFormat get coordinateFormatter => NumberFormat('0.000000', context.locale);
  static const _minTimeToGpxPoint = Duration(hours: 1);

  @override
  void initState() {
    super.initState();
    final entries = widget.entries;
    mainEntry = entries.firstWhereOrNull((entry) => entry.hasGps) ?? entries.first;
    _initMapCoordinates();
    _initCopyItem();
    _initCustom();
    AvesApp.intentEventBus.on<LocationReceivedEvent>().listen((event) => _setCustomLocation(event.location));
  }

  void _initMapCoordinates() {
    _mapCoordinates = mainEntry.latLng;
  }

  void _initCopyItem() {
    _copyItemSource = mainEntry;
  }

  void _initCustom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final latLng = mainEntry.latLng;
      if (latLng != null) {
        _latitudeController.text = coordinateFormatter.format(latLng.latitude);
        _longitudeController.text = coordinateFormatter.format(latLng.longitude);
      } else {
        _latitudeController.text = '';
        _longitudeController.text = '';
      }
      setState(_validate);
    });
  }

  @override
  void dispose() {
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _isValidNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQueryDataProvider(
      child: TooltipTheme(
        data: TooltipTheme.of(context).copyWith(
          preferBelow: false,
        ),
        child: Builder(builder: (context) {
          final l10n = context.l10n;

          return AvesDialog(
            title: l10n.editEntryLocationDialogTitle,
            scrollableContent: [
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 8, right: 16),
                child: TextDropdownButton<LocationEditAction>(
                  values: LocationEditAction.values,
                  valueText: (v) => v.getText(context),
                  value: _action,
                  onChanged: (v) => setState(() {
                    _action = v!;
                    _validate();
                  }),
                  isExpanded: true,
                  dropdownColor: Themes.thirdLayerColor(context),
                ),
              ),
              AnimatedSwitcher(
                duration: context.read<DurationsData>().formTransition,
                switchInCurve: Curves.easeInOutCubic,
                switchOutCurve: Curves.easeInOutCubic,
                transitionBuilder: AvesTransitions.formTransitionBuilder,
                child: KeyedSubtree(
                  key: ValueKey(_action),
                  child: _buildContent(),
                ),
              ),
              const SizedBox(height: 8),
            ],
            actions: [
              const CancelButton(),
              ValueListenableBuilder<bool>(
                valueListenable: _isValidNotifier,
                builder: (context, isValid, child) {
                  return TextButton(
                    onPressed: isValid ? () => _submit(context) : null,
                    child: Text(l10n.applyButtonLabel),
                  );
                },
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildContent() {
    switch (_action) {
      case LocationEditAction.chooseOnMap:
        return _buildChooseOnMapContent(context);
      case LocationEditAction.copyItem:
        return _buildCopyItemContent(context);
      case LocationEditAction.setCustom:
        return _buildSetCustomContent(context);
      case LocationEditAction.importGpx:
        return _buildImportGpxContent(context);
      case LocationEditAction.remove:
        return const SizedBox();
    }
  }

  Widget _buildChooseOnMapContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 16, end: 8),
      child: Row(
        children: [
          Expanded(child: _coordinatesText(context, _mapCoordinates)),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(AIcons.map),
            onPressed: _pickLocation,
            tooltip: context.l10n.editEntryLocationDialogChooseOnMap,
          ),
        ],
      ),
    );
  }

  void _setCustomLocation(LatLng latLng) {
    _latitudeController.text = coordinateFormatter.format(latLng.latitude);
    _longitudeController.text = coordinateFormatter.format(latLng.longitude);
    _action = LocationEditAction.setCustom;
    setState(_validate);
  }

  CollectionLens? _createPickCollection() {
    final baseCollection = widget.collection;
    return baseCollection != null
        ? CollectionLens(
            source: baseCollection.source,
            filters: {
              ...baseCollection.filters.whereNot((filter) => filter == LocationFilter.unlocated),
              LocationFilter.located,
            },
          )
        : null;
  }

  Future<void> _pickLocation() async {
    final pickCollection = _createPickCollection();
    final latLng = await Navigator.maybeOf(context)?.push(
      MaterialPageRoute(
        settings: const RouteSettings(name: LocationPickPage.routeName),
        builder: (context) => LocationPickPage(
          collection: pickCollection,
          initialLocation: _mapCoordinates,
        ),
        fullscreenDialog: true,
      ),
    );
    if (latLng != null) {
      settings.mapDefaultCenter = latLng;
      setState(() {
        _mapCoordinates = latLng;
        _validate();
      });
    }
  }

  Widget _buildCopyItemContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 16, end: 8),
      child: Row(
        children: [
          Expanded(child: _coordinatesText(context, _copyItemSource.latLng)),
          const SizedBox(width: 8),
          ItemPicker(
            extent: 48,
            entry: _copyItemSource,
            onTap: _pickCopyItemSource,
          ),
        ],
      ),
    );
  }

  Future<void> _pickCopyItemSource() async {
    final pickCollection = _createPickCollection();
    if (pickCollection == null) return;

    final entry = await Navigator.maybeOf(context)?.push<AvesEntry>(
      MaterialPageRoute(
        settings: const RouteSettings(name: ItemPickPage.routeName),
        builder: (context) => ItemPickPage(
          collection: pickCollection,
          canRemoveFilters: true,
        ),
        fullscreenDialog: true,
      ),
    );
    if (entry != null) {
      setState(() {
        _copyItemSource = entry;
        _validate();
      });
    }
  }

  Widget _buildSetCustomContent(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                TextField(
                  controller: _latitudeController,
                  decoration: InputDecoration(
                    labelText: l10n.editEntryLocationDialogLatitude,
                    hintText: coordinateFormatter.format(PointsOfInterest.pointNemo.latitude),
                  ),
                  onChanged: (_) => _validate(),
                ),
                TextField(
                  controller: _longitudeController,
                  decoration: InputDecoration(
                    labelText: l10n.editEntryLocationDialogLongitude,
                    hintText: coordinateFormatter.format(PointsOfInterest.pointNemo.longitude),
                  ),
                  onChanged: (_) => _validate(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportGpxContent(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 16, end: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(child: _gpxDateRangeText(context, _gpx)),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(AIcons.fileImport),
                onPressed: _pickGpx,
                tooltip: l10n.pickTooltip,
              ),
            ],
          ),
          if (_gpx != null) ...[
            Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.editEntryLocationDialogTimeShift),
                      AvesCaption(_formatShiftDuration(_gpxShift)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(AIcons.edit),
                  onPressed: _pickGpxShift,
                  tooltip: l10n.changeTooltip,
                ),
              ],
            ),
            Row(
              children: [
                Expanded(child: Text(l10n.statsWithGps(_gpxMap.length))),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(AIcons.map),
                  onPressed: _previewGpx,
                  tooltip: l10n.openMapPageTooltip,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickGpx() async {
    final bytes = await storageService.openFile();
    if (bytes.isNotEmpty) {
      try {
        final allXmlString = utf8.decode(bytes);
        final gpx = GpxReader().fromString(allXmlString);

        _gpx = gpx;
        _gpxShift = Duration.zero;
        _updateGpxMapping();

        showFeedback(context, FeedbackType.info, context.l10n.genericSuccessFeedback);
      } catch (error, stack) {
        debugPrint('failed to import GPX, error=$error\n$stack');
        showFeedback(context, FeedbackType.warn, context.l10n.genericFailureFeedback);
      }
    }
  }

  Future<void> _pickGpxShift() async {
    final newShift = await showDialog<Duration>(
      context: context,
      builder: (context) => TimeShiftDialog(
        initialValue: _gpxShift,
      ),
      routeSettings: const RouteSettings(name: TimeShiftDialog.routeName),
    );
    if (newShift == null) return;

    _gpxShift = newShift;
    _updateGpxMapping();
  }

  String _formatShiftDuration(Duration duration) {
    final sign = duration.isNegative ? '-' : '+';
    duration = duration.abs();
    final hours = duration.inHours;
    duration -= Duration(hours: hours);
    final minutes = duration.inMinutes;
    duration -= Duration(minutes: minutes);
    final seconds = duration.inSeconds;
    return '$sign$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _updateGpxMapping() {
    _gpxMap.clear();

    final gpx = _gpx;
    if (gpx == null) return;

    final Map<AvesEntry, Wpt> wptByEntry = {};

    // dated items and points, oldest first
    final sortedEntries = widget.entries.where((v) => v.bestDate != null).sorted(AvesEntrySort.compareByDate).reversed.toList();
    final sortedPoints = gpx.trks.expand((trk) => trk.trksegs).expand((trkSeg) => trkSeg.trkpts).where((v) => v.time != null).sortedBy((v) => v.time!);
    if (sortedEntries.isNotEmpty && sortedPoints.isNotEmpty) {
      int entryIndex = 0;
      int pointIndex = 0;
      final int maxDurationSecs = const Duration(days: 365).inSeconds;
      int smallestDifferenceSecs = maxDurationSecs;
      while (entryIndex < sortedEntries.length && pointIndex < sortedPoints.length) {
        final entry = sortedEntries[entryIndex];
        final point = sortedPoints[pointIndex];
        final entryDate = entry.bestDate!;
        final pointTime = point.time!.add(_gpxShift);
        final differenceSecs = entryDate.difference(pointTime).inSeconds.abs();
        if (differenceSecs < smallestDifferenceSecs) {
          smallestDifferenceSecs = differenceSecs;
          wptByEntry[entry] = point;
          pointIndex++;
        } else {
          smallestDifferenceSecs = maxDurationSecs;
          entryIndex++;
        }
      }
    }

    _gpxMap.addEntries(wptByEntry.entries.map((kv) {
      final entry = kv.key;
      final wpt = kv.value;
      final timeToPoint = entry.bestDate!.difference(wpt.time!.add(_gpxShift)).abs();
      if (timeToPoint < _minTimeToGpxPoint) {
        final lat = wpt.lat;
        final lon = wpt.lon;
        if (lat != null && lon != null) {
          return MapEntry(entry, LatLng(lat, lon));
        }
      }
      return null;
    }).nonNulls);

    setState(_validate);
  }

  Future<void> _previewGpx() async {
    final source = widget.collection?.source;
    if (source == null) return;

    final previewEntries = _gpxMap.entries.map((kv) {
      final entry = kv.key.copyWith();
      final latLng = kv.value;
      final catalogMetadata = entry.catalogMetadata?.copyWith() ?? CatalogMetadata(id: entry.id);
      catalogMetadata.latitude = latLng.latitude;
      catalogMetadata.longitude = latLng.longitude;
      entry.catalogMetadata = catalogMetadata;
      return entry;
    }).toList();

    final mapCollection = CollectionLens(
      source: source,
      listenToSource: false,
      fixedSelection: previewEntries,
    );

    final tracks = _gpx?.trks
        .expand((trk) => trk.trksegs)
        .map((trkSeg) => trkSeg.trkpts
            .map((wpt) {
              final lat = wpt.lat;
              final lon = wpt.lon;
              return (lat != null && lon != null) ? LatLng(lat, lon) : null;
            })
            .nonNulls
            .toList())
        .toSet();

    await Navigator.maybeOf(context)?.push(
      MaterialPageRoute(
        settings: const RouteSettings(name: LocationPickPage.routeName),
        builder: (context) {
          return ListenableProvider<ValueNotifier<AppMode>>.value(
            value: ValueNotifier(AppMode.previewMap),
            child: MapPage(
              collection: mapCollection,
              tracks: tracks,
            ),
          );
        },
        fullscreenDialog: true,
      ),
    );
  }

  Text _unknownText(BuildContext context) {
    final l10n = context.l10n;
    return Text(
      l10n.viewerInfoUnknown,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  (DateTime, DateTime)? _gpxDateRange(Gpx? gpx) {
    final firstDate = gpx?.trks.firstOrNull?.trksegs.firstOrNull?.trkpts.firstOrNull?.time;
    final lastDate = gpx?.trks.lastOrNull?.trksegs.lastOrNull?.trkpts.lastOrNull?.time;
    return firstDate != null && lastDate != null ? (firstDate, lastDate) : null;
  }

  Text _gpxDateRangeText(BuildContext context, Gpx? gpx) {
    final dateRange = _gpxDateRange(gpx);
    if (dateRange != null) {
      final (firstDate, lastDate) = dateRange;
      final locale = context.locale;
      final use24hour = MediaQuery.alwaysUse24HourFormatOf(context);
      return Text(
        [
          formatDateTime(firstDate.toLocal(), locale, use24hour),
          formatDateTime(lastDate.toLocal(), locale, use24hour),
        ].join('\n'),
      );
    } else {
      return _unknownText(context);
    }
  }

  Text _coordinatesText(BuildContext context, LatLng? latLng) {
    final l10n = context.l10n;
    if (latLng != null) {
      return Text(
        ExtraCoordinateFormat.toDMS(l10n, latLng).join('\n'),
      );
    } else {
      return _unknownText(context);
    }
  }

  LatLng? _parseLatLng() {
    double? tryParse(String text) {
      try {
        return double.tryParse(text) ?? (coordinateFormatter.parse(text).toDouble());
      } catch (error) {
        // ignore
        return null;
      }
    }

    final lat = tryParse(_latitudeController.text);
    final lng = tryParse(_longitudeController.text);
    if (lat == null || lng == null) return null;
    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) return null;
    return LatLng(lat, lng);
  }

  void _validate() {
    switch (_action) {
      case LocationEditAction.chooseOnMap:
        _isValidNotifier.value = _mapCoordinates != null;
      case LocationEditAction.copyItem:
        _isValidNotifier.value = _copyItemSource.hasGps;
      case LocationEditAction.setCustom:
        _isValidNotifier.value = _parseLatLng() != null;
      case LocationEditAction.importGpx:
        _isValidNotifier.value = _gpxMap.isNotEmpty;
      case LocationEditAction.remove:
        _isValidNotifier.value = true;
    }
  }

  void _submit(BuildContext context) {
    final navigator = Navigator.maybeOf(context);
    final entries = widget.entries;
    final LocationEditActionResult result = {};
    void addLocationForAllEntries(LatLng? latLng) => result.addEntries(entries.map((v) => MapEntry(v, latLng)));
    switch (_action) {
      case LocationEditAction.chooseOnMap:
        addLocationForAllEntries(_mapCoordinates);
      case LocationEditAction.copyItem:
        addLocationForAllEntries(_copyItemSource.latLng);
      case LocationEditAction.setCustom:
        addLocationForAllEntries(_parseLatLng());
      case LocationEditAction.importGpx:
        result.addAll(_gpxMap);
      case LocationEditAction.remove:
        addLocationForAllEntries(ExtraAvesEntryMetadataEdition.removalLocation);
    }
    navigator?.pop(result);
  }
}

typedef LocationEditActionResult = Map<AvesEntry, LatLng?>;
