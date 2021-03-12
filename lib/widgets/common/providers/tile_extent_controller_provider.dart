import 'package:aves/widgets/common/tile_extent_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class TileExtentControllerProvider extends StatelessWidget {
  final TileExtentController controller;
  final Widget child;

  const TileExtentControllerProvider({
    @required this.controller,
    @required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return MultiProvider(
          providers: [
            ProxyProvider0(
              update: (_, __) => constraints.biggest,
            ),
            ProxyProvider<Size, TileExtentController>(
              update: (_, viewportSize, __) => controller..applyTileExtent(viewportSize: viewportSize),
            ),
          ],
          child: child,
        );
      },
    );
  }
}
