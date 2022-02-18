import 'package:aves/model/filters/filters.dart';
import 'package:aves/theme/icons.dart';
import 'package:flutter/material.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';

class TrashFilter extends CollectionFilter {
  static const type = 'trash';

  static const instance = TrashFilter._private();

  @override
  List<Object?> get props => [];

  const TrashFilter._private();

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
      };

  @override
  EntryFilter get test => (entry) => entry.trashed;

  @override
  String get universalLabel => type;

  @override
  String getLabel(BuildContext context) => context.l10n.filterBinLabel;

  @override
  Widget iconBuilder(BuildContext context, double size, {bool showGenericIcon = true}) => Icon(AIcons.bin, size: size);

  @override
  String get category => type;

  @override
  String get key => type;
}
