import 'package:aves/services/common/services.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/common/app_bar/crumb_line.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/material.dart';

class ExplorerCrumbLine extends StatelessWidget {
  final VolumeRelativeDirectory? directory;
  final void Function(VolumeRelativeDirectory? combinedPath) onTap;

  const ExplorerCrumbLine({
    super.key,
    required this.directory,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CrumbLine<VolumeRelativeDirectory?>(
      split: _split,
      combine: _combine,
      onTap: onTap,
    );
  }

  List<String> _split(BuildContext context) {
    final _directory = directory;
    if (_directory == null) return [];
    return [
      _directory.getVolumeDescription(context),
      ...pContext.split(_directory.relativeDir),
    ];
  }

  VolumeRelativeDirectory? _combine(BuildContext context, int index) {
    final _directory = directory;
    if (_directory == null) return null;

    final path = pContext.joinAll([
      _directory.volumePath,
      ..._split(context).skip(1).take(index),
    ]);
    return androidFileUtils.relativeDirectoryFromPath(path);
  }
}
