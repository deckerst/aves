import 'package:aves/model/settings/enums.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:aves/widgets/viewer/info/maps/common.dart';
import 'package:aves/widgets/viewer/info/maps/scale_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:latlong/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class EntryLeafletMap extends StatefulWidget {
  final LatLng latLng;
  final String geoUri;
  final double initialZoom;
  final EntryMapStyle style;
  final Size markerSize;
  final WidgetBuilder markerBuilder;

  const EntryLeafletMap({
    Key key,
    this.latLng,
    this.geoUri,
    this.initialZoom,
    this.style,
    this.markerBuilder,
    this.markerSize,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EntryLeafletMapState();
}

class _EntryLeafletMapState extends State<EntryLeafletMap> with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  final MapController _mapController = MapController();

  @override
  void didUpdateWidget(covariant EntryLeafletMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.latLng != oldWidget.latLng && _mapController != null) {
      _mapController.move(widget.latLng, settings.infoMapZoom);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            MapDecorator(
              child: _buildMap(),
            ),
            MapButtonPanel(
              geoUri: widget.geoUri,
              zoomBy: _zoomBy,
            ),
          ],
        ),
        _buildAttribution(),
      ],
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      options: MapOptions(
        center: widget.latLng,
        zoom: widget.initialZoom,
        interactive: false,
      ),
      mapController: _mapController,
      children: [
        _buildMapLayer(),
        ScaleLayerWidget(
          options: ScaleLayerOptions(),
        ),
        MarkerLayerWidget(
          options: MarkerLayerOptions(
            markers: [
              Marker(
                width: widget.markerSize.width,
                height: widget.markerSize.height,
                point: widget.latLng,
                builder: widget.markerBuilder,
                anchorPos: AnchorPos.align(AnchorAlign.top),
              ),
            ],
          ),
        ),
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

  Widget _buildAttribution() {
    switch (widget.style) {
      case EntryMapStyle.osmHot:
        return _buildAttributionMarkdown(context.l10n.mapAttributionOsmHot);
      case EntryMapStyle.stamenToner:
      case EntryMapStyle.stamenWatercolor:
        return _buildAttributionMarkdown(context.l10n.mapAttributionStamen);
      default:
        return SizedBox.shrink();
    }
  }

  Widget _buildAttributionMarkdown(String data) {
    return Padding(
      padding: EdgeInsets.only(top: 4),
      child: MarkdownBody(
        data: data,
        selectable: true,
        styleSheet: MarkdownStyleSheet(
          a: TextStyle(color: Theme.of(context).accentColor),
          p: TextStyle(color: Colors.white70, fontSize: InfoRowGroup.fontSize),
        ),
        onTapLink: (text, href, title) async {
          if (await canLaunch(href)) {
            await launch(href);
          }
        },
      ),
    );
  }

  void _zoomBy(double amount) {
    if (_mapController == null) return;

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
        urlTemplate: 'https://stamen-tiles-{s}.a.ssl.fastly.net/watercolor/{z}/{x}/{y}.jpg',
        subdomains: ['a', 'b', 'c', 'd'],
        retinaMode: MediaQuery.of(context).devicePixelRatio > 1,
      ),
    );
  }
}
