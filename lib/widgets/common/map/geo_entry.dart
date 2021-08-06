import 'package:aves/model/entry.dart';
import 'package:fluster/fluster.dart';
import 'package:flutter/foundation.dart';

class GeoEntry extends Clusterable {
  AvesEntry? entry;

  GeoEntry({
    this.entry,
    double? latitude,
    double? longitude,
    bool? isCluster = false,
    int? clusterId,
    int? pointsSize,
    String? markerId,
    String? childMarkerId,
  }) : super(
          latitude: latitude,
          longitude: longitude,
          isCluster: isCluster,
          clusterId: clusterId,
          pointsSize: pointsSize,
          markerId: markerId,
          childMarkerId: childMarkerId,
        );

  factory GeoEntry.createCluster(BaseCluster cluster, double longitude, double latitude) {
    return GeoEntry(
      latitude: latitude,
      longitude: longitude,
      isCluster: cluster.isCluster,
      clusterId: cluster.id,
      pointsSize: cluster.pointsSize,
      markerId: cluster.id.toString(),
      childMarkerId: cluster.childMarkerId,
    );
  }

  @override
  String toString() => '$runtimeType#${shortHash(this)}{isCluster=$isCluster, lat=$latitude, lng=$longitude, clusterId=$clusterId, pointsSize=$pointsSize, markerId=$markerId, childMarkerId=$childMarkerId}';
}
