import 'package:aves/widgets/common/fx/checkered_decoration.dart';
import 'package:aves/widgets/viewer/visual/entry_page_view.dart';
import 'package:aves/widgets/viewer/visual/state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class VectorViewCheckeredBackground extends StatelessWidget {
  final Size displaySize;
  final ValueNotifier<ViewState> viewStateNotifier;
  final Widget child;

  const VectorViewCheckeredBackground({
    Key? key,
    required this.displaySize,
    required this.viewStateNotifier,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ViewState>(
      valueListenable: viewStateNotifier,
      builder: (context, viewState, child) {
        final viewportSize = viewState.viewportSize;
        if (viewportSize == null) return child!;

        final side = viewportSize.shortestSide;
        final checkSize = side / ((side / EntryPageView.decorationCheckSize).round());

        final viewSize = displaySize * viewState.scale!;
        final decorationSize = applyBoxFit(BoxFit.none, viewSize, viewportSize).source;
        final offset = ((decorationSize - viewportSize) as Offset) / 2;

        return Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              width: decorationSize.width,
              height: decorationSize.height,
              child: CustomPaint(
                painter: CheckeredPainter(
                  checkSize: checkSize,
                  offset: offset,
                ),
              ),
            ),
            child!,
          ],
        );
      },
      child: child,
    );
  }
}
