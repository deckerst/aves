import 'package:aves/model/settings.dart';
import 'package:aves/services/android_app_service.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:aves/widgets/fullscreen/info/maps/scale_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:tuple/tuple.dart';

import '../location_section.dart';

class EntryLeafletMap extends StatefulWidget {
  final LatLng latLng;
  final String geoUri;
  final double initialZoom;
  final EntryMapStyle style;

  EntryLeafletMap({
    Key key,
    Tuple2<double, double> latLng,
    this.geoUri,
    this.initialZoom,
    this.style,
  })  : latLng = LatLng(latLng.item1, latLng.item2),
        super(key: key);

  @override
  State<StatefulWidget> createState() => EntryLeafletMapState();
}

class EntryLeafletMapState extends State<EntryLeafletMap> with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  final MapController _mapController = MapController();

  static const markerSize = 40.0;

  @override
  void didUpdateWidget(EntryLeafletMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.latLng != oldWidget.latLng && _mapController != null) {
      _mapController.move(widget.latLng, settings.infoMapZoom);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final accentColor = Theme.of(context).accentColor;
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onScaleStart: (details) {
              // absorb scale gesture here to prevent scrolling
              // and triggering by mistake a move to the image page above
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                color: Colors.white70,
                height: 200,
                child: FlutterMap(
                  options: MapOptions(
                    center: widget.latLng,
                    zoom: widget.initialZoom,
                    interactive: false,
                  ),
                  children: [
                    _buildMapLayer(),
                    ScaleLayerWidget(
                      options: ScaleLayerOptions(
                        lineColor: accentColor,
                        lineWidth: 2,
                        textStyle: TextStyle(
                          color: accentColor,
                          fontSize: 12,
                        ),
                        padding: EdgeInsets.all(8),
                      ),
                    ),
                    MarkerLayerWidget(
                      options: MarkerLayerOptions(
                        markers: [
                          Marker(
                            width: markerSize,
                            height: markerSize,
                            point: widget.latLng,
                            builder: (ctx) {
                              return Icon(
                                Icons.place,
                                size: markerSize,
                                color: accentColor,
                              );
                            },
                            anchorPos: AnchorPos.align(AnchorAlign.top),
                          ),
                        ],
                      ),
                    ),
                  ],
                  mapController: _mapController,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 8),
        TooltipTheme(
          data: TooltipTheme.of(context).copyWith(
            preferBelow: false,
          ),
          child: Column(children: [
            IconButton(
              icon: Icon(AIcons.zoomIn),
              onPressed: _mapController == null ? null : () => _zoomBy(1),
              tooltip: 'Zoom in',
            ),
            IconButton(
              icon: Icon(AIcons.zoomOut),
              onPressed: _mapController == null ? null : () => _zoomBy(-1),
              tooltip: 'Zoom out',
            ),
            IconButton(
              icon: Icon(AIcons.openInNew),
              onPressed: () => AndroidAppService.openMap(widget.geoUri),
              tooltip: 'Show on map...',
            ),
          ]),
        )
      ],
    );
  }

  Widget _buildMapLayer() {
    switch (widget.style) {
      case EntryMapStyle.osmHot:
        return OSMHotLayer();
      case EntryMapStyle.stamenToner:
        return StamenTonerLayer();
      case EntryMapStyle.stamenWatercolor:
        return StamenWatercolorLayer();
      default:
        return SizedBox.shrink();
    }
  }

  void _zoomBy(double amount) {
    final endZoom = (settings.infoMapZoom + amount).clamp(1.0, 16.0);
    settings.infoMapZoom = endZoom;

    final zoomTween = Tween<double>(begin: _mapController.zoom, end: endZoom);
    final controller = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    final animation = CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);
    controller.addListener(() => _mapController.move(widget.latLng, zoomTween.evaluate(animation)));
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });
    controller.forward();
  }

  @override
  bool get wantKeepAlive => true;
}

class OSMHotLayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TileLayerWidget(
      options: TileLayerOptions(
        // attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, Tiles style by <a href="https://www.hotosm.org/" target="_blank">Humanitarian OpenStreetMap Team</a> hosted by <a href="https://openstreetmap.fr/" target="_blank">OpenStreetMap France</a>'
        minZoom: 1,
        maxZoom: 19,
        urlTemplate: 'https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
        subdomains: ['a', 'b', 'c'],
        retinaMode: MediaQuery.of(context).devicePixelRatio > 1,
      ),
    );
  }
}

class StamenTonerLayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TileLayerWidget(
      options: TileLayerOptions(
        // attribution: 'Map tiles by <a href="http://stamen.com">Stamen Design</a>, <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a> &mdash; Map data &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
        minZoom: 1,
        maxZoom: 20,
        urlTemplate: 'https://stamen-tiles-{s}.a.ssl.fastly.net/toner-lite/{z}/{x}/{y}{r}.png',
        subdomains: ['a', 'b', 'c', 'd'],
        retinaMode: MediaQuery.of(context).devicePixelRatio > 1,
      ),
    );
  }
}

class StamenWatercolorLayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TileLayerWidget(
      options: TileLayerOptions(
        // attribution: 'Map tiles by <a href="http://stamen.com">Stamen Design</a>, <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a> &mdash; Map data &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
        minZoom: 1,
        maxZoom: 16,
        urlTemplate: 'https://stamen-tiles-{s}.a.ssl.fastly.net/watercolor/{z}/{x}/{y}.jpg',
        subdomains: ['a', 'b', 'c', 'd'],
        retinaMode: MediaQuery.of(context).devicePixelRatio > 1,
      ),
    );
  }
}
