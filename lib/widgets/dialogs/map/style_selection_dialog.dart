import 'package:aves/model/settings/settings.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/collection_utils.dart';
import 'package:aves/view/src/settings/enums.dart';
import 'package:aves/widgets/common/basic/scaffold.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/buttons/outlined_button.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/dialogs/map/style_editor_dialog.dart';
import 'package:aves/widgets/dialogs/selection_dialogs/radio_list_tile.dart';
import 'package:aves_map/aves_map.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MapStyleSelectionDialog extends StatefulWidget {
  static const routeName = '/dialog/map_style_selection';

  const MapStyleSelectionDialog({super.key});

  @override
  State<MapStyleSelectionDialog> createState() => _MapStyleSelectionDialogState();
}

class _MapStyleSelectionDialogState extends State<MapStyleSelectionDialog> {
  late EntryMapStyle? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = settings.mapStyle;
  }

  @override
  Widget build(BuildContext context) {
    final useTvLayout = settings.useTvLayout;
    final l10n = context.l10n;
    final defaultStyles = availability.mapStyles;
    final customStyles = context.select<Settings, Set<EntryMapStyle>>((v) => v.customMapStyles).sortedBy((v) => v.getName(context));

    return PopScope(
      onPopInvokedWithResult: (didPop, result) => settings.mapStyle = _selectedValue,
      child: AvesScaffold(
        appBar: AppBar(
          automaticallyImplyLeading: !useTvLayout,
          title: Text(context.l10n.mapStyleDialogTitle),
        ),
        body: SafeArea(
          bottom: false,
          child: ListView(
            children: [
              ...defaultStyles.map((v) {
                return SelectionRadioListTile(
                  value: v,
                  title: v.getName(context),
                  needConfirmation: false,
                  secondary: _getDefaultStylePreview(v),
                  getGroupValue: () => _selectedValue,
                  setGroupValue: _setGroupValue,
                );
              }),
              ...customStyles.map((v) {
                return SelectionRadioListTile(
                  value: v,
                  title: v.getName(context),
                  needConfirmation: false,
                  secondary: _buildCustomStyleButtons(v),
                  getGroupValue: () => _selectedValue,
                  setGroupValue: _setGroupValue,
                );
              }),
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(top: 4, bottom: 8),
                child: AvesOutlinedButton(
                  icon: const Icon(AIcons.add),
                  label: l10n.mapStyleDialogAddStyle,
                  onPressed: _add,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _setGroupValue(EntryMapStyle? style) => setState(() => _selectedValue = style);

  Widget? _getDefaultStylePreview(EntryMapStyle style) {
    final assetName = _getImageAssetName(style);
    if (assetName == null) return null;

    return ImageMarker(
      count: null,
      locale: null,
      drawArrow: false,
      buildThumbnailImage: (_) => Image.asset('assets/$assetName'),
    );
  }

  String? _getImageAssetName(EntryMapStyle style) {
    if (style == EntryMapStyles.googleNormal) return 'map_tile_128_google_normal.png';
    if (style == EntryMapStyles.googleHybrid) return 'map_tile_128_google_hybrid.png';
    if (style == EntryMapStyles.googleTerrain) return 'map_tile_128_google_terrain.png';
    if (style == EntryMapStyles.osmLiberty) return 'map_tile_128_osm_liberty.png';
    if (style == EntryMapStyles.openTopoMap) return 'map_tile_128_opentopomap.png';
    if (style == EntryMapStyles.osmHot) return 'map_tile_128_osm_hot.png';
    if (style == EntryMapStyles.stamenWatercolor) return 'map_tile_128_stamen_watercolor.png';
    return null;
  }

  Widget _buildCustomStyleButtons(EntryMapStyle style) {
    final l10n = context.l10n;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(AIcons.edit),
          onPressed: () => _edit(style),
          tooltip: l10n.changeTooltip,
        ),
        IconButton(
          icon: const Icon(AIcons.clear),
          onPressed: () => _remove(style),
          tooltip: l10n.actionRemove,
        ),
      ],
    );
  }

  Future<void> _add() async {
    final newStyle = await showDialog<EntryMapStyle>(
      context: context,
      builder: (context) => const MapStyleEditorDialog(),
      routeSettings: const RouteSettings(name: MapStyleEditorDialog.routeName),
    );
    if (newStyle == null) return;

    settings.customMapStyles = settings.customMapStyles..add(newStyle);
    _setGroupValue(newStyle);
  }

  Future<void> _edit(EntryMapStyle style) async {
    final newStyle = await showDialog<EntryMapStyle>(
      context: context,
      builder: (context) => MapStyleEditorDialog(initialValue: style),
      routeSettings: const RouteSettings(name: MapStyleEditorDialog.routeName),
    );
    if (newStyle == null) return;

    settings.customMapStyles = settings.customMapStyles..replace(style, newStyle);
    _setGroupValue(newStyle);
  }

  Future<void> _remove(EntryMapStyle style) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AvesDialog(
        content: Text(l10n.genericDangerWarningDialogMessage),
        actions: [
          const CancelButton(),
          TextButton(
            onPressed: () => Navigator.maybeOf(context)?.pop(true),
            child: Text(l10n.applyButtonLabel),
          ),
        ],
      ),
      routeSettings: const RouteSettings(name: AvesDialog.warningRouteName),
    );
    if (confirmed == null || !confirmed) return;

    settings.customMapStyles = settings.customMapStyles..remove(style);
    if (_selectedValue == style) {
      _setGroupValue(null);
    }
  }
}
