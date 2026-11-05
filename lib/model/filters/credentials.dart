import 'package:aves/model/filters/filters.dart';
import 'package:aves/services/media/enums.dart';
import 'package:aves/view/view.dart';
import 'package:aves_utils/aves_utils.dart';
import 'package:flutter/widgets.dart';

class const ContentCredentialsFilter(
  final C2paValidity validity, {
  super.reversed = false,
}) extends CollectionFilter {
  static const type = 'content_credentials';

  @override
  List<Object?> get props => [validity, reversed];

  factory fromMap(Map<String, Object?> json) {
    return ContentCredentialsFilter(
      C2paValidity.values.safeByName(json['validity'] as String, ignoreCase: true) ?? .unknown,
      reversed: json['reversed'] as bool? ?? false,
    );
  }

  @override
  Map<String, Object?> toJsonMap() => {
    'type': type,
    'validity': validity.name,
    if (reversed) 'reversed': reversed,
  };

  @override
  EntryPredicate get positiveTest =>
      (entry) => entry.credentialsValidity == validity;

  @override
  bool get exclusiveProp => true;

  @override
  String get universalLabel => validity.name;

  @override
  String getLabel(BuildContext context) => validity.getText(context);

  @override
  Widget? iconBuilder(BuildContext context, double size, {bool allowGenericIcon = true}) {
    return Icon(validity.getIconData(), size: size);
  }

  @override
  String get category => type;

  @override
  String get key => '$type-$reversed-${validity.name}';
}
