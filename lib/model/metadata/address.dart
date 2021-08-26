import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

@immutable
class AddressDetails {
  final int? contentId;
  final String? countryCode, countryName, adminArea, locality;

  String? get place => locality != null && locality!.isNotEmpty ? locality : adminArea;

  const AddressDetails({
    this.contentId,
    this.countryCode,
    this.countryName,
    this.adminArea,
    this.locality,
  });

  AddressDetails copyWith({
    int? contentId,
  }) {
    return AddressDetails(
      contentId: contentId ?? this.contentId,
      countryCode: countryCode,
      countryName: countryName,
      adminArea: adminArea,
      locality: locality,
    );
  }

  factory AddressDetails.fromMap(Map map) {
    return AddressDetails(
      contentId: map['contentId'] as int?,
      countryCode: map['countryCode'] as String?,
      countryName: map['countryName'] as String?,
      adminArea: map['adminArea'] as String?,
      locality: map['locality'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'contentId': contentId,
        'countryCode': countryCode,
        'countryName': countryName,
        'adminArea': adminArea,
        'locality': locality,
      };

  @override
  String toString() => '$runtimeType#${shortHash(this)}{contentId=$contentId, countryCode=$countryCode, countryName=$countryName, adminArea=$adminArea, locality=$locality}';
}
