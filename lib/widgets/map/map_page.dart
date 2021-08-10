import 'package:aves/model/entry.dart';
import 'package:aves/model/settings/map_style.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/map/geo_map.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

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
  late final ValueNotifier<bool> _isAnimatingNotifier;

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
  }

  @override
  Widget build(BuildContext context) {
    return MediaQueryDataProvider(
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.mapPageTitle),
        ),
        body: SafeArea(
          child: GeoMap(
            entries: widget.entries,
            interactive: true,
            isAnimatingNotifier: _isAnimatingNotifier,
          ),
        ),
      ),
    );
  }
}
