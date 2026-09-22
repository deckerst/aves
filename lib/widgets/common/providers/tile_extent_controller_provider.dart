import 'package:aves/widgets/common/tile_extent_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class const TileExtentControllerProvider({
  super.key,
  required final TileExtentController controller,
  required final Widget child,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => ProxyProvider0<TileExtentController>(
        update: (context, _) => controller..setViewportSize(constraints.biggest),
        child: child,
      ),
    );
  }
}
