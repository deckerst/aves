import 'dart:async';

import 'package:aves/model/filters/album.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/widgets/common/action_controls/quick_choosers/common/menu.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AlbumQuickChooser extends StatelessWidget {
  final ValueNotifier<String?> valueNotifier;
  final List<String> options;
  final bool blurred;
  final PopupMenuPosition chooserPosition;
  final Stream<Offset> pointerGlobalPosition;

  const AlbumQuickChooser({
    super.key,
    required this.valueNotifier,
    required this.options,
    required this.blurred,
    required this.chooserPosition,
    required this.pointerGlobalPosition,
  });

  @override
  Widget build(BuildContext context) {
    final source = context.read<CollectionSource>();
    return MenuQuickChooser<String>(
      valueNotifier: valueNotifier,
      options: options,
      autoReverse: true,
      blurred: blurred,
      chooserPosition: chooserPosition,
      pointerGlobalPosition: pointerGlobalPosition,
      itemBuilder: (context, album) => AvesFilterChip(
        filter: AlbumFilter(album, source.getAlbumDisplayName(context, album)),
        allowGenericIcon: false,
      ),
    );
  }
}
