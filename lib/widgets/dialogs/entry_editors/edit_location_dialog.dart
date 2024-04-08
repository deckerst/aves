import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/location.dart';
import 'package:aves/model/entry/extensions/metadata_edition.dart';
import 'package:aves/model/filters/location.dart';
import 'package:aves/model/settings/enums/coordinate_format.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/ref/poi.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/theme/themes.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/common/basic/text_dropdown_button.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/fx/transitions.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/dialogs/item_picker.dart';
import 'package:aves/widgets/dialogs/pick_dialogs/item_pick_page.dart';
import 'package:aves/widgets/dialogs/pick_dialogs/location_pick_page.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class EditEntryLocationDialog extends StatefulWidget {
  static const routeName = '/dialog/edit_entry_location';

  final AvesEntry entry;
  final CollectionLens? collection;

  const EditEntryLocationDialog({
    super.key,
    required this.entry,
    this.collection,
  });

  @override
  State<EditEntryLocationDialog> createState() => _EditEntryLocationDialogState();
}

class _EditEntryLocationDialogState extends State<EditEntryLocationDialog> {
  LocationEditAction _action = LocationEditAction.chooseOnMap;
  LatLng? _mapCoordinates;
  late AvesEntry _copyItemSource;
  final TextEditingController _latitudeController = TextEditingController(), _longitudeController = TextEditingController();
  final ValueNotifier<bool> _isValidNotifier = ValueNotifier(false);

  NumberFormat get coordinateFormatter => NumberFormat('0.000000', context.l10n.localeName);

  @override
  void initState() {
    super.initState();
    _initMapCoordinates();
    _initCopyItem();
    _initCustom();
  }

  void _initMapCoordinates() {
    _mapCoordinates = widget.entry.latLng;
  }

  void _initCopyItem() {
    _copyItemSource = widget.entry;
  }

  void _initCustom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final latLng = widget.entry.latLng;
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
                child: Column(
                  key: ValueKey(_action),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_action == LocationEditAction.chooseOnMap) _buildChooseOnMapContent(context),
                    if (_action == LocationEditAction.copyItem) _buildCopyItemContent(context),
                    if (_action == LocationEditAction.setCustom) _buildSetCustomContent(context),
                  ],
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

  Widget _buildChooseOnMapContent(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 16, end: 8),
      child: Row(
        children: [
          Expanded(child: _toText(context, _mapCoordinates)),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(AIcons.map),
            onPressed: _pickLocation,
            tooltip: l10n.editEntryLocationDialogChooseOnMap,
          ),
        ],
      ),
    );
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
    pickCollection?.dispose();
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
          Expanded(child: _toText(context, _copyItemSource.latLng)),
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
    pickCollection.dispose();
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

  Text _toText(BuildContext context, LatLng? latLng) {
    final l10n = context.l10n;
    if (latLng != null) {
      return Text(
        ExtraCoordinateFormat.toDMS(l10n, latLng).join('\n'),
      );
    } else {
      return Text(
        l10n.viewerInfoUnknown,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
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
      case LocationEditAction.remove:
        _isValidNotifier.value = true;
    }
  }

  void _submit(BuildContext context) {
    final navigator = Navigator.maybeOf(context);
    switch (_action) {
      case LocationEditAction.chooseOnMap:
        navigator?.pop(_mapCoordinates);
      case LocationEditAction.copyItem:
        navigator?.pop(_copyItemSource.latLng);
      case LocationEditAction.setCustom:
        navigator?.pop(_parseLatLng());
      case LocationEditAction.remove:
        navigator?.pop(ExtraAvesEntryMetadataEdition.removalLocation);
    }
  }
}
