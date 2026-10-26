import 'package:aves/geo/states.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class const AddressDetails({
  required final int id,
  final String? countryCode,
  final String? countryName,
  final String? adminArea,
  final String? locality,
}) extends Equatable {
  @override
  List<Object?> get props => [id, countryCode, countryName, adminArea, locality];

  String? get place => locality != null && locality!.isNotEmpty ? locality : adminArea;

  String? get stateCode => GeoStates.stateCodeByName[stateName];

  String? get stateName => GeoStates.stateCodesByCountryCode.containsKey(countryCode) ? adminArea : null;

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

  factory fromMap(Map map) {
    return AddressDetails(
      id: map['id'] as int,
      countryCode: map['countryCode'] as String?,
      countryName: map['countryName'] as String?,
      adminArea: map['adminArea'] as String?,
      locality: map['locality'] as String?,
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'countryCode': countryCode,
    'countryName': countryName,
    'adminArea': adminArea,
    'locality': locality,
  };

  Map<String, Object?> toDbMap() => toMap();

  bool get isValid {
    if (countryName?.isNotEmpty == true && countryCode == null) return false;
    return true;
  }
}
