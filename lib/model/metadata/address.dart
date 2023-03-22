import 'package:aves/geo/states.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

@immutable
class AddressDetails extends Equatable {
  final int id;
  final String? countryCode, countryName, adminArea, locality;

  @override
  List<Object?> get props => [id, countryCode, countryName, adminArea, locality];

  String? get place => locality != null && locality!.isNotEmpty ? locality : adminArea;

  String? get stateCode => GeoStates.stateCodeByName[stateName];

  String? get stateName => GeoStates.stateCountryCodes.contains(countryCode) ? adminArea : null;

  const AddressDetails({
    required this.id,
    this.countryCode,
    this.countryName,
    this.adminArea,
    this.locality,
  });

  AddressDetails copyWith({
    int? id,
  }) {
    return AddressDetails(
      id: id ?? this.id,
      countryCode: countryCode,
      countryName: countryName,
      adminArea: adminArea,
      locality: locality,
    );
  }

  factory AddressDetails.fromMap(Map map) {
    return AddressDetails(
      id: map['id'] as int,
      countryCode: map['countryCode'] as String?,
      countryName: map['countryName'] as String?,
      adminArea: map['adminArea'] as String?,
      locality: map['locality'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'countryCode': countryCode,
        'countryName': countryName,
        'adminArea': adminArea,
        'locality': locality,
      };
}
