import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/images.dart';
import 'package:aves/ref/metadata/geotiff.dart';
import 'package:aves/utils/math_utils.dart';
import 'package:aves_map/aves_map.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:latlong2/latlong.dart';
import 'package:proj4dart/proj4dart.dart' as proj4;

@immutable
class GeoTiffInfo extends Equatable {
  final List<double>? modelPixelScale, modelTiePoints, modelTransformation;
  final int? projCSType, projLinearUnits;

  @override
  List<Object?> get props => [modelPixelScale, modelTiePoints, modelTransformation, projCSType, projLinearUnits];

  const GeoTiffInfo({
    this.modelPixelScale,
    this.modelTiePoints,
    this.modelTransformation,
    this.projCSType,
    this.projLinearUnits,
  });

  factory GeoTiffInfo.fromMap(Map map) {
    return GeoTiffInfo(
      modelPixelScale: (map[GeoTiffExifTags.modelPixelScale] as List?)?.cast<double>(),
      modelTiePoints: (map[GeoTiffExifTags.modelTiePoints] as List?)?.cast<double>(),
      modelTransformation: (map[GeoTiffExifTags.modelTransformation] as List?)?.cast<double>(),
      projCSType: map[GeoTiffKeys.projCSType] as int?,
      projLinearUnits: map[GeoTiffKeys.projLinearUnits] as int?,
    );
  }
}

class MappedGeoTiff with MapOverlay {
  final AvesEntry entry;

  late final GeoTiffCoordinateConverter _converter;
  late final int _mapServiceTileSize;
  late final MapServiceHelper _mapServiceHelper;

  static final _tileImagePaint = Paint();
  static final _tileMissingPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = const Color(0xFF000000);

  MappedGeoTiff({
    required GeoTiffInfo info,
    required this.entry,
    required double devicePixelRatio,
  }) {
    _converter = GeoTiffCoordinateConverter(info: info, entry: entry);
    _mapServiceTileSize = (256 * devicePixelRatio).round();
    _mapServiceHelper = MapServiceHelper(_mapServiceTileSize);
  }

  @override
  Future<MapTile?> getTile(int tx, int ty, int? zoomLevel) async {
    zoomLevel ??= 0;

    // global projected coordinates in meters (EPSG:3857 Spherical Mercator)
    final tileTopLeft3857 = _mapServiceHelper.tileTopLeft(tx, ty, zoomLevel);
    final tileBottomRight3857 = _mapServiceHelper.tileTopLeft(tx + 1, ty + 1, zoomLevel);

    // image region coordinates in pixels
    final tileTopLeftPx = _converter.epsg3857ToPoint(tileTopLeft3857);
    final tileBottomRightPx = _converter.epsg3857ToPoint(tileBottomRight3857);
    if (tileTopLeftPx == null || tileBottomRightPx == null) return null;

    final tileLeft = tileTopLeftPx.x;
    final tileRight = tileBottomRightPx.x;
    final tileTop = tileTopLeftPx.y;
    final tileBottom = tileBottomRightPx.y;

    final width = entry.width;
    final height = entry.height;

    final regionLeft = tileLeft.clamp(0, width);
    final regionRight = tileRight.clamp(0, width);
    final regionTop = tileTop.clamp(0, height);
    final regionBottom = tileBottom.clamp(0, height);

    final regionWidth = regionRight - regionLeft;
    final regionHeight = regionBottom - regionTop;
    if (regionWidth == 0 || regionHeight == 0) return null;

    final tileXScale = (tileRight - tileLeft) / _mapServiceTileSize;
    final sampleSize = max<int>(1, highestPowerOf2(tileXScale));
    final region = entry.getRegion(
      sampleSize: sampleSize,
      region: Rectangle(regionLeft, regionTop, regionWidth, regionHeight),
    );

    final imageInfoCompleter = Completer<ImageInfo?>();
    final imageStream = region.resolve(ImageConfiguration.empty);
    final imageStreamListener = ImageStreamListener((image, synchronousCall) {
      imageInfoCompleter.complete(image);
    }, onError: imageInfoCompleter.completeError);
    imageStream.addListener(imageStreamListener);
    ImageInfo? regionImageInfo;
    try {
      regionImageInfo = await imageInfoCompleter.future;
    } catch (error) {
      debugPrint('failed to get image for region=$region with error=$error');
    }
    imageStream.removeListener(imageStreamListener);

    final imageOffset = Offset(
      regionLeft > tileLeft ? (regionLeft - tileLeft).toDouble() : 0,
      regionTop > tileTop ? (regionTop - tileTop).toDouble() : 0,
    );
    final tileImageScaleX = (tileRight - tileLeft) / _mapServiceTileSize;
    final tileImageScaleY = (tileBottom - tileTop) / _mapServiceTileSize;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.scale(1 / tileImageScaleX, 1 / tileImageScaleY);
    if (regionImageInfo != null) {
      final s = sampleSize.toDouble();
      canvas.scale(s, s);
      canvas.drawImage(regionImageInfo.image, imageOffset / s, _tileImagePaint);
      canvas.scale(1 / s, 1 / s);
    } else {
      // fallback to show area
      canvas.drawRect(
        Rect.fromLTWH(
          imageOffset.dx,
          imageOffset.dy,
          regionWidth.toDouble(),
          regionHeight.toDouble(),
        ),
        _tileMissingPaint,
      );
    }
    canvas.scale(tileImageScaleX, tileImageScaleY);

    final picture = recorder.endRecording();
    final tileImage = await picture.toImage(_mapServiceTileSize, _mapServiceTileSize);
    final byteData = await tileImage.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return null;

    return MapTile(
      width: tileImage.width,
      height: tileImage.height,
      data: byteData.buffer.asUint8List(),
    );
  }

  @override
  String get id => entry.uri;

  @override
  ImageProvider get imageProvider => entry.fullImage;

  @override
  bool get canOverlay => center != null;

  LatLng? get center => _converter.center;

  @override
  LatLng? get topLeft => _converter.topLeft;

  @override
  LatLng? get bottomRight => _converter.bottomRight;
}

class GeoTiffCoordinateConverter {
  final AvesEntry entry;

  late LatLng? Function(Point<int> pixel) pointToLatLng;
  late Point<int>? Function(Point<double> smPoint) epsg3857ToPoint;

  GeoTiffCoordinateConverter({
    required GeoTiffInfo info,
    required this.entry,
  }) {
    pointToLatLng = (_) => null;
    epsg3857ToPoint = (_) => null;

    // limitation: only support some UTM coordinate systems
    final projCSType = info.projCSType;
    final srcProj4 = GeoUtils.epsgToProj4(projCSType);
    if (srcProj4 == null) {
      debugPrint('unsupported projCSType=$projCSType');
      return;
    }

    // limitation: only support model space values in units of meters
    // TODO TLAD [geotiff] default from parsing proj4 instead of meter?
    final projLinearUnits = info.projLinearUnits ?? GeoTiffUnits.linearMeter;
    if (projLinearUnits != GeoTiffUnits.linearMeter) {
      debugPrint('unsupported projLinearUnits=$projLinearUnits');
      return;
    }

    // limitation: only support tie points, not transformation matrix
    final modelTiePoints = info.modelTiePoints;
    if (modelTiePoints == null) return;

    if (modelTiePoints.length < 6) return;

    // map image space (I,J,K) to model space (X,Y,Z)
    final tpI = modelTiePoints[0];
    final tpJ = modelTiePoints[1];
    final tpK = modelTiePoints[2];
    final tpX = modelTiePoints[3];
    final tpY = modelTiePoints[4];
    final tpZ = modelTiePoints[5];

    // limitation: expect 0,0,0,X,Y,0
    if (tpI != 0 || tpJ != 0 || tpK != 0 || tpZ != 0) return;

    final modelPixelScale = info.modelPixelScale;
    if (modelPixelScale == null || modelPixelScale.length < 2) return;

    final xScale = modelPixelScale[0];
    final yScale = modelPixelScale[1];

    final geoTiffProjection = proj4.Projection.parse(srcProj4);
    final projToLatLng = proj4.ProjectionTuple(
      fromProj: geoTiffProjection,
      toProj: proj4.Projection.WGS84,
    );
    pointToLatLng = (pixel) {
      final srcPoint = proj4.Point(
        x: tpX + pixel.x * xScale,
        y: tpY - pixel.y * yScale,
      );
      final destPoint = projToLatLng.forward(srcPoint);

      final latitude = destPoint.y;
      final longitude = destPoint.x;
      if (latitude >= -90.0 && latitude <= 90.0 && longitude >= -180.0 && longitude <= 180.0) {
        return LatLng(latitude, longitude);
      }
      return null;
    };

    final projFromMapService = proj4.ProjectionTuple(
      fromProj: proj4.Projection.GOOGLE,
      toProj: geoTiffProjection,
    );
    epsg3857ToPoint = (smPoint) {
      final srcPoint = proj4.Point(x: smPoint.x, y: smPoint.y);
      final destPoint = projFromMapService.forward(srcPoint);
      return Point(((destPoint.x - tpX) / xScale).round(), -((destPoint.y - tpY) / yScale).round());
    };
  }

  int get width => entry.width;

  int get height => entry.height;

  LatLng? get center => pointToLatLng(Point((width / 2).round(), (height / 2).round()));

  LatLng? get topLeft => pointToLatLng(const Point(0, 0));

  LatLng? get bottomRight => pointToLatLng(Point(width, height));
}
