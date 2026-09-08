import 'package:aves/model/settings/settings.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

// to be placed at the edges of lists and grids,
// so that TV can reach them with D-pad
class TvEdgeFocus extends StatelessWidget {
  final FocusNode? focusNode;

  const new({
    super.key,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final useTvLayout = context.select<Settings, bool>((v) => v.useTvLayout);
    return useTvLayout
        ? Focus(
            focusNode: focusNode,
            child: const SizedBox(),
          )
        : const SizedBox();
  }
}
