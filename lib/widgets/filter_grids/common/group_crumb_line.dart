import 'package:aves/model/grouping/common.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/widgets/common/app_bar/crumb_line.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/material.dart';

class FilterGroupCrumbLine extends StatelessWidget {
  final Uri? groupUri;
  final void Function(Uri? groupUri) onTap;

  const FilterGroupCrumbLine({
    super.key,
    required this.groupUri,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CrumbLine<Uri?>(
      split: _split,
      combine: _combine,
      onTap: onTap,
    );
  }

  List<String> _split(BuildContext context) {
    final path = FilterGrouping.getGroupPath(groupUri);
    final crumbs = [context.l10n.ungrouped];
    if (path != null) {
      crumbs.addAll(pContext.split(path));
    }
    return crumbs;
  }

  Uri? _combine(BuildContext context, int index) {
    if (groupUri == null || index == 0) return null;

    var targetGroupUri = groupUri;
    for (var i = _split(context).length - 1; i > index; i--) {
      targetGroupUri = FilterGrouping.getParentGroup(targetGroupUri);
    }
    return targetGroupUri;
  }
}
