import 'package:aves/model/entry.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/dialogs/location_pick_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

class EditEntryLocationDialog extends StatefulWidget {
  final AvesEntry entry;
  final CollectionLens? collection;

  const EditEntryLocationDialog({
    Key? key,
    required this.entry,
    this.collection,
  }) : super(key: key);

  @override
  State<EditEntryLocationDialog> createState() => _EditEntryLocationDialogState();
}

class _EditEntryLocationDialogState extends State<EditEntryLocationDialog> {
  _LocationAction _action = _LocationAction.set;
  final TextEditingController _latitudeController = TextEditingController(), _longitudeController = TextEditingController();
  final FocusNode _latitudeFocusNode = FocusNode(), _longitudeFocusNode = FocusNode();
  final ValueNotifier<bool> _isValidNotifier = ValueNotifier(false);

  NumberFormat get coordinateFormatter => NumberFormat('0.000000', context.l10n.localeName);

  @override
  void initState() {
    super.initState();
    _latitudeFocusNode.addListener(_onLatLngFocusChange);
    _longitudeFocusNode.addListener(_onLatLngFocusChange);
    WidgetsBinding.instance.addPostFrameCallback((_) => _setLocation(context, widget.entry.latLng));
  }

  @override
  void dispose() {
    _latitudeFocusNode.removeListener(_onLatLngFocusChange);
    _longitudeFocusNode.removeListener(_onLatLngFocusChange);
    _latitudeController.dispose();
    _longitudeController.dispose();
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
              RadioListTile<_LocationAction>(
                value: _LocationAction.set,
                groupValue: _action,
                onChanged: (v) => setState(() {
                  _action = v!;
                  _validate();
                }),
                title: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          TextField(
                            controller: _latitudeController,
                            focusNode: _latitudeFocusNode,
                            decoration: InputDecoration(
                              labelText: context.l10n.editEntryLocationDialogLatitude,
                              hintText: coordinateFormatter.format(Constants.pointNemo.latitude),
                            ),
                            onChanged: (_) => _validate(),
                          ),
                          TextField(
                            controller: _longitudeController,
                            focusNode: _longitudeFocusNode,
                            decoration: InputDecoration(
                              labelText: context.l10n.editEntryLocationDialogLongitude,
                              hintText: coordinateFormatter.format(Constants.pointNemo.longitude),
                            ),
                            onChanged: (_) => _validate(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: IconButton(
                        icon: const Icon(AIcons.map),
                        onPressed: _pickLocation,
                        tooltip: l10n.editEntryLocationDialogChooseOnMapTooltip,
                      ),
                    ),
                  ],
                ),
                contentPadding: const EdgeInsetsDirectional.only(start: 16, end: 8),
              ),
              RadioListTile<_LocationAction>(
                value: _LocationAction.remove,
                groupValue: _action,
                onChanged: (v) => setState(() {
                  _action = v!;
                  _latitudeFocusNode.unfocus();
                  _longitudeFocusNode.unfocus();
                  _validate();
                }),
                title: Text(l10n.actionRemove),
              ),
            ],
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
              ),
              ValueListenableBuilder<bool>(
                valueListenable: _isValidNotifier,
                builder: (context, isValid, child) {
                  return TextButton(
                    onPressed: isValid ? () => _submit(context) : null,
                    child: Text(context.l10n.applyButtonLabel),
                  );
                },
              ),
            ],
          );
        }),
      ),
    );
  }

  void _onLatLngFocusChange() {
    if (_latitudeFocusNode.hasFocus || _longitudeFocusNode.hasFocus) {
      setState(() {
        _action = _LocationAction.set;
        _validate();
      });
    }
  }

  void _setLocation(BuildContext context, LatLng? latLng) {
    _latitudeController.text = latLng != null ? coordinateFormatter.format(latLng.latitude) : '';
    _longitudeController.text = latLng != null ? coordinateFormatter.format(latLng.longitude) : '';
    setState(() {
      _action = _LocationAction.set;
      _validate();
    });
  }

  Future<void> _pickLocation() async {
    final latLng = await Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: LocationPickDialog.routeName),
        builder: (context) {
          final baseCollection = widget.collection;
          final mapCollection = baseCollection != null
              ? CollectionLens(
                  source: baseCollection.source,
                  filters: baseCollection.filters,
                  fixedSelection: baseCollection.sortedEntries.where((entry) => entry.hasGps).toList(),
                )
              : null;
          return LocationPickDialog(
            collection: mapCollection,
            initialLocation: _parseLatLng(),
          );
        },
        fullscreenDialog: true,
      ),
    );
    if (latLng != null) {
      _setLocation(context, latLng);
    }
  }

  LatLng? _parseLatLng() {
    double? tryParse(String text) {
      try {
        return double.tryParse(text) ?? (coordinateFormatter.parse(text).toDouble());
      } catch (e) {
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

  Future<void> _validate() async {
    switch (_action) {
      case _LocationAction.set:
        _isValidNotifier.value = _parseLatLng() != null;
        break;
      case _LocationAction.remove:
        _isValidNotifier.value = true;
        break;
    }
  }

  void _submit(BuildContext context) {
    switch (_action) {
      case _LocationAction.set:
        Navigator.pop(context, _parseLatLng());
        break;
      case _LocationAction.remove:
        Navigator.pop(context, LatLng(0, 0));
        break;
    }
  }
}

enum _LocationAction { set, remove }
