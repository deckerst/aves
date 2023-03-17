import 'dart:math';

import 'package:aves/image_providers/app_icon_image_provider.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/common/basic/list_tiles/color.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/fx/borders.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/dialogs/item_picker.dart';
import 'package:aves/widgets/dialogs/pick_dialogs/app_pick_page.dart';
import 'package:aves/widgets/dialogs/pick_dialogs/item_pick_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class CoverSelectionDialog extends StatefulWidget {
  static const routeName = '/dialog/select_cover';

  final CollectionFilter filter;
  final AvesEntry? customEntry;
  final String? customPackage;
  final Color? customColor;

  const CoverSelectionDialog({
    super.key,
    required this.filter,
    required this.customEntry,
    required this.customPackage,
    required this.customColor,
  });

  @override
  State<CoverSelectionDialog> createState() => _CoverSelectionDialogState();
}

class _CoverSelectionDialogState extends State<CoverSelectionDialog> {
  late bool _isCustomEntry, _isCustomPackage, _isCustomColor;
  AvesEntry? _customEntry;
  String? _customPackage;
  Color? _customColor;

  CollectionFilter get filter => widget.filter;

  bool get showAppTab => filter is AlbumFilter && settings.isInstalledAppAccessAllowed;

  bool get showColorTab => settings.themeColorMode == AvesThemeColorMode.polychrome;

  static const double itemPickerExtent = 46;
  static const double appPickerExtent = 32;
  static const double colorPickerRadius = Constants.colorPickerRadius;

  double tabBarHeight(BuildContext context) => 64 * max(1, MediaQuery.textScaleFactorOf(context));

  static const double tabIndicatorWeight = 2;

  @override
  void initState() {
    super.initState();

    _customEntry = widget.customEntry;
    _isCustomEntry = _customEntry != null;

    _customPackage = widget.customPackage;
    _isCustomPackage = _customPackage != null;

    _customColor = widget.customColor;
    _isCustomColor = _customColor != null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tabs = <Tuple2<Tab, Widget>>[
      Tuple2(
        _buildTab(
          context,
          const Key('tab-entry'),
          AIcons.image,
          l10n.coverDialogTabCover,
        ),
        Column(children: _buildEntryOptions()),
      ),
      if (showAppTab)
        Tuple2(
          _buildTab(
            context,
            const Key('tab-package'),
            AIcons.app,
            l10n.coverDialogTabApp,
          ),
          Column(children: _buildAppOptions()),
        ),
      if (showColorTab)
        Tuple2(
          _buildTab(
            context,
            const Key('tab-color'),
            AIcons.opacity,
            l10n.coverDialogTabColor,
          ),
          Column(children: _buildColorOptions()),
        ),
    ];

    final contentWidget = DecoratedBox(
      decoration: AvesDialog.contentDecoration(context),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableBodyHeight = constraints.maxHeight - tabBarHeight(context) - tabIndicatorWeight;
          final maxHeight = min(availableBodyHeight, tabBodyMaxHeight(context));
          return DefaultTabController(
            length: 1 + (showAppTab ? 1 : 0) + (showColorTab ? 1 : 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Material(
                  borderRadius: const BorderRadius.vertical(
                    top: AvesDialog.cornerRadius,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: TabBar(
                    indicatorWeight: tabIndicatorWeight,
                    tabs: tabs.map((t) => t.item1).toList(),
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: maxHeight),
                  child: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    children: tabs
                        .map((t) => SingleChildScrollView(
                              child: t.item2,
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    final actionsWidget = Padding(
      padding: AvesDialog.actionsPadding,
      child: OverflowBar(
        alignment: MainAxisAlignment.end,
        spacing: AvesDialog.buttonPadding.horizontal / 2,
        overflowAlignment: OverflowBarAlignment.end,
        children: [
          const CancelButton(),
          TextButton(
            onPressed: () {
              final entry = _isCustomEntry ? _customEntry : null;
              final package = _isCustomPackage ? _customPackage : null;
              final color = _isCustomColor ? _customColor : null;
              return Navigator.maybeOf(context)?.pop(Tuple3<AvesEntry?, String?, Color?>(entry, package, color));
            },
            child: Text(l10n.applyButtonLabel),
          )
        ],
      ),
    );

    Widget dialogChild = LayoutBuilder(
      builder: (context, constraints) {
        final availableBodyWidth = constraints.maxWidth;
        final maxWidth = min(availableBodyWidth, tabBodyMaxWidth(context));
        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(child: contentWidget),
              actionsWidget,
            ],
          ),
        );
      },
    );

    return Dialog(
      shape: AvesDialog.shape(context),
      child: dialogChild,
    );
  }

  List<Widget> _buildEntryOptions() {
    final l10n = context.l10n;
    return [false, true].map(
      (isCustom) {
        final title = Text(
          isCustom ? l10n.setCoverDialogCustom : l10n.setCoverDialogLatest,
          softWrap: false,
          overflow: TextOverflow.fade,
          maxLines: 1,
        );
        return RadioListTile<bool>(
          value: isCustom,
          groupValue: _isCustomEntry,
          onChanged: (v) {
            if (v == null) return;
            if (v && _customEntry == null) {
              _pickEntry();
              return;
            }
            _isCustomEntry = v;
            setState(() {});
          },
          title: isCustom
              ? Row(
                  children: [
                    title,
                    const Spacer(),
                    if (_customEntry != null)
                      ItemPicker(
                        extent: itemPickerExtent,
                        entry: _customEntry!,
                        onTap: _pickEntry,
                      ),
                  ],
                )
              : title,
        );
      },
    ).toList();
  }

  List<Widget> _buildAppOptions() {
    final l10n = context.l10n;
    return [false, true].map(
      (isCustom) {
        final title = Text(
          isCustom ? l10n.setCoverDialogCustom : l10n.setCoverDialogAuto,
          softWrap: false,
          overflow: TextOverflow.fade,
          maxLines: 1,
        );
        return RadioListTile<bool>(
          value: isCustom,
          groupValue: _isCustomPackage,
          onChanged: (v) {
            if (v == null) return;
            if (v && _customPackage == null) {
              _pickPackage();
              return;
            }
            _isCustomPackage = v;
            setState(() {});
          },
          title: isCustom
              ? Row(
                  children: [
                    title,
                    const Spacer(),
                    if (_customPackage != null)
                      GestureDetector(
                        onTap: _pickPackage,
                        child: _customPackage!.isNotEmpty
                            ? Image(
                                image: AppIconImage(
                                  packageName: _customPackage!,
                                  size: appPickerExtent,
                                ),
                                width: appPickerExtent,
                                height: appPickerExtent,
                              )
                            : Container(
                                height: appPickerExtent,
                                width: appPickerExtent,
                                decoration: BoxDecoration(
                                  border: AvesBorder.border(context),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(AIcons.clear),
                              ),
                      ),
                  ],
                )
              : title,
        );
      },
    ).toList();
  }

  List<Widget> _buildColorOptions() {
    final l10n = context.l10n;
    return [false, true].map(
      (isCustom) {
        final title = Text(
          isCustom ? l10n.setCoverDialogCustom : l10n.setCoverDialogAuto,
          softWrap: false,
          overflow: TextOverflow.fade,
          maxLines: 1,
        );
        return RadioListTile<bool>(
          value: isCustom,
          groupValue: _isCustomColor,
          onChanged: (v) {
            if (v == null) return;
            if (v && _customColor == null) {
              _pickColor();
              return;
            }
            _isCustomColor = v;
            setState(() {});
          },
          title: isCustom
              ? Row(
                  children: [
                    title,
                    const Spacer(),
                    if (_customColor != null)
                      GestureDetector(
                        onTap: _pickColor,
                        child: Container(
                          height: colorPickerRadius * 2,
                          width: colorPickerRadius * 2,
                          decoration: BoxDecoration(
                            color: _customColor,
                            border: AvesBorder.border(context),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                )
              : title,
        );
      },
    ).toList();
  }

  Future<void> _pickEntry() async {
    final entry = await Navigator.maybeOf(context)?.push<AvesEntry>(
      MaterialPageRoute(
        settings: const RouteSettings(name: ItemPickPage.routeName),
        builder: (context) => ItemPickPage(
          collection: CollectionLens(
            source: context.read<CollectionSource>(),
            filters: {filter},
          ),
        ),
        fullscreenDialog: true,
      ),
    );
    if (entry != null) {
      _customEntry = entry;
      _isCustomEntry = true;
      setState(() {});
    }
  }

  Future<void> _pickPackage() async {
    final package = await Navigator.maybeOf(context)?.push<String>(
      MaterialPageRoute(
        settings: const RouteSettings(name: AppPickPage.routeName),
        builder: (context) => AppPickPage(
          initialValue: _customPackage,
        ),
        fullscreenDialog: true,
      ),
    );
    if (package != null) {
      _customPackage = package;
      _isCustomPackage = true;
      setState(() {});
    }
  }

  Future<void> _pickColor() async {
    final color = await showDialog<Color>(
      context: context,
      builder: (context) => ColorPickerDialog(
        // avoid a pure material color as the default, so that
        // picker controls are not on edge and palette panel is more stable
        initialValue: _customColor ?? const Color(0xff3f51b5),
      ),
      routeSettings: const RouteSettings(name: ColorPickerDialog.routeName),
    );
    if (color != null) {
      _customColor = color;
      _isCustomColor = true;
      setState(() {});
    }
  }

  // tabs

  Tab _buildTab(
    BuildContext context,
    Key key,
    IconData icon,
    String text, {
    Color? color,
  }) {
    // cannot use `IconTheme` over `TabBar` to change size,
    // because `TabBar` does so internally
    final textScaleFactor = MediaQuery.textScaleFactorOf(context);
    final iconSize = IconTheme.of(context).size! * textScaleFactor;
    return Tab(
      key: key,
      height: tabBarHeight(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: iconSize,
            color: color,
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: TextStyle(color: color),
            softWrap: false,
            overflow: TextOverflow.fade,
          ),
        ],
      ),
    );
  }

  // based on `ListTile` height computation (one line, no subtitle, not dense)
  double singleOptionTileHeight(BuildContext context) => 56.0 + Theme.of(context).visualDensity.baseSizeAdjustment.dy;

  double tabBodyMaxWidth(BuildContext context) {
    final l10n = context.l10n;
    final _optionLines = {
      l10n.setCoverDialogLatest,
      l10n.setCoverDialogAuto,
      l10n.setCoverDialogCustom,
    }.fold('', (previousValue, element) => '$previousValue\n$element');

    final para = RenderParagraph(
      TextSpan(text: _optionLines, style: Theme.of(context).textTheme.titleMedium!),
      textDirection: TextDirection.ltr,
      textScaleFactor: MediaQuery.textScaleFactorOf(context),
    )..layout(const BoxConstraints(), parentUsesSize: true);
    final textWidth = para.getMaxIntrinsicWidth(double.infinity);

    // from `RadioListTile` layout
    const contentPadding = 32;
    const leadingWidth = kMinInteractiveDimension + 8;
    return contentPadding + leadingWidth + textWidth + itemPickerExtent;
  }

  double tabBodyMaxHeight(BuildContext context) => 2 * singleOptionTileHeight(context);
}
