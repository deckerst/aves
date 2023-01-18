import 'package:aves/model/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// to be placed at the edges of lists and grids,
// so that TV can reach them with D-pad
class TvEdgeFocus extends StatelessWidget {
  const TvEdgeFocus({super.key});

  @override
  Widget build(BuildContext context) {
    final useTvLayout = context.select<Settings, bool>((s) => s.useTvLayout);
    return useTvLayout ? const Focus(child: SizedBox()) : const SizedBox();
  }
}
