import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/model/settings/enums/widget_shape.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/services/widget_service.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/fx/borders.dart';
import 'package:aves/widgets/common/identity/buttons.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/home_widget.dart';
import 'package:aves/widgets/settings/common/collection_tile.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeWidgetSettingsPage extends StatefulWidget {
  static const routeName = '/settings/home_widget';

  final int widgetId;

  const HomeWidgetSettingsPage({
    super.key,
    required this.widgetId,
  });

  @override
  State<HomeWidgetSettingsPage> createState() => _HomeWidgetSettingsPageState();
}

class _HomeWidgetSettingsPageState extends State<HomeWidgetSettingsPage> {
  late Color? _outline;
  late WidgetShape _shape;
  late Set<CollectionFilter> _collectionFilters;

  int get widgetId => widget.widgetId;

  static const gradient = HomeWidgetPainter.backgroundGradient;
  static final deselectedGradient = LinearGradient(
    begin: gradient.begin,
    end: gradient.end,
    colors: gradient.colors.map((v) {
      final l = (v.computeLuminance() * 0xFF).toInt();
      return Color.fromARGB(0xFF, l, l, l);
    }).toList(),
    stops: gradient.stops,
    tileMode: gradient.tileMode,
    transform: gradient.transform,
  );

  @override
  void initState() {
    super.initState();
    _outline = settings.getWidgetOutline(widgetId);
    _shape = settings.getWidgetShape(widgetId);
    _collectionFilters = settings.getWidgetCollectionFilters(widgetId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return MediaQueryDataProvider(
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.settingsWidgetPageTitle),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    _buildShapeSelector(),
                    ListTile(
                      title: Text(l10n.settingsWidgetShowOutline),
                      trailing: HomeWidgetOutlineSelector(
                        getter: () => _outline,
                        setter: (v) => setState(() => _outline = v),
                      ),
                    ),
                    SettingsCollectionTile(
                      filters: _collectionFilters,
                      onSelection: (v) => setState(() => _collectionFilters = v),
                    ),
                  ],
                ),
              ),
              const Divider(height: 0),
              Padding(
                padding: const EdgeInsets.all(8),
                child: AvesOutlinedButton(
                  label: l10n.saveTooltip,
                  onPressed: () {
                    _saveSettings();
                    WidgetService.configure();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShapeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: WidgetShape.values.map((shape) {
          final selected = shape == _shape;
          final duration = context.read<DurationsData>().formTransition;
          return GestureDetector(
            onTap: () => setState(() => _shape = shape),
            child: AnimatedOpacity(
              duration: duration,
              opacity: selected ? 1.0 : .4,
              child: AnimatedContainer(
                duration: duration,
                width: 96,
                height: 124,
                decoration: ShapeDecoration(
                  gradient: selected ? gradient : deselectedGradient,
                  shape: _WidgetShapeBorder(_outline, shape),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _saveSettings() {
    settings.setWidgetOutline(widgetId, _outline);
    settings.setWidgetShape(widgetId, _shape);
    if (!const SetEquality().equals(_collectionFilters, settings.getWidgetCollectionFilters(widgetId))) {
      settings.setWidgetCollectionFilters(widgetId, _collectionFilters);
      settings.setWidgetUri(widgetId, null);
    }
  }
}

class _WidgetShapeBorder extends ShapeBorder {
  final Color? outline;
  final WidgetShape shape;

  static const _devicePixelRatio = 1.0;

  const _WidgetShapeBorder(this.outline, this.shape);

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return getOuterPath(rect, textDirection: textDirection);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return shape.path(rect.size, _devicePixelRatio);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (outline != null) {
      final path = shape.path(rect.size, _devicePixelRatio);
      canvas.clipPath(path);
      HomeWidgetPainter.drawOutline(canvas, path, _devicePixelRatio, outline!);
    }
  }

  @override
  ShapeBorder scale(double t) => this;
}

class HomeWidgetOutlineSelector extends StatefulWidget {
  final ValueGetter<Color?> getter;
  final ValueSetter<Color?> setter;

  const HomeWidgetOutlineSelector({
    super.key,
    required this.getter,
    required this.setter,
  });

  @override
  State<HomeWidgetOutlineSelector> createState() => _HomeWidgetOutlineSelectorState();
}

class _HomeWidgetOutlineSelectorState extends State<HomeWidgetOutlineSelector> {
  static const radius = Constants.colorPickerRadius;
  static const List<Color?> options = [
    null,
    Colors.black,
    Colors.white,
  ];

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<Color?>(
        items: _buildItems(context),
        value: widget.getter(),
        onChanged: (selected) {
          widget.setter(selected);
          setState(() {});
        },
      ),
    );
  }

  List<DropdownMenuItem<Color?>> _buildItems(BuildContext context) {
    return options.map((selected) {
      return DropdownMenuItem<Color?>(
        value: selected,
        child: Container(
          height: radius * 2,
          width: radius * 2,
          decoration: BoxDecoration(
            color: selected,
            border: AvesBorder.border(context),
            shape: BoxShape.circle,
          ),
          child: selected == null ? const Icon(AIcons.clear) : null,
        ),
      );
    }).toList();
  }
}
