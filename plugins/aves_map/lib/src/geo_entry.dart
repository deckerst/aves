import 'package:fluster/fluster.dart';
import 'package:flutter/foundation.dart';

class GeoEntry<T> extends Clusterable {
  T? entry;

  GeoEntry({
    this.entry,
    super.latitude,
    super.longitude,
    super.isCluster = false,
    super.clusterId,
    super.pointsSize,
    super.markerId,
    super.childMarkerId,
  });

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
