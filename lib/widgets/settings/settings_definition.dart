import 'dart:async';

import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:flutter/widgets.dart';

abstract class SettingsSection {
  String get key;

  Widget icon(BuildContext context);

  String title(BuildContext context);

  FutureOr<List<SettingsTile>> tiles(BuildContext context);

  Widget build(BuildContext context, ValueNotifier<String?> expandedNotifier) {
    return FutureBuilder<List<SettingsTile>>(
      future: Future.value(tiles(context)),
      builder: (context, snapshot) {
        final tiles = snapshot.data;
        if (tiles == null) return const SizedBox();

        return AvesExpansionTile(
          // key is expected by test driver
          key: Key('section-$key'),
          // use a fixed value instead of the title to identify this expansion tile
          // so that the tile state is kept when the language is modified
          value: key,
          leading: icon(context),
          title: title(context),
          expandedNotifier: expandedNotifier,
          showHighlight: false,
          children: tiles.map((v) => v.build(context)).toList(),
        );
      },
    );
  }
}

abstract class SettingsTile {
  String title(BuildContext context);

  Widget build(BuildContext context);
}
