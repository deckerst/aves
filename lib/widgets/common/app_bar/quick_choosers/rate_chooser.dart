import 'dart:async';

import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:flutter/material.dart';

class RateQuickChooser extends StatefulWidget {
  final ValueNotifier<int?> ratingNotifier;
  final Stream<LongPressMoveUpdateDetails> moveUpdates;

  const RateQuickChooser({
    super.key,
    required this.ratingNotifier,
    required this.moveUpdates,
  });

  @override
  State<RateQuickChooser> createState() => _RateQuickChooserState();
}

class _RateQuickChooserState extends State<RateQuickChooser> {
  final List<StreamSubscription> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    _registerWidget(widget);
  }

  @override
  void didUpdateWidget(covariant RateQuickChooser oldWidget) {
    super.didUpdateWidget(oldWidget);
    _unregisterWidget(oldWidget);
    _registerWidget(widget);
  }

  @override
  void dispose() {
    _unregisterWidget(widget);
    super.dispose();
  }

  void _registerWidget(RateQuickChooser widget) {
    _subscriptions.add(widget.moveUpdates.map((event) => event.globalPosition).listen(_onPointerMove));
  }

  void _unregisterWidget(RateQuickChooser widget) {
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Material(
        shape: AvesDialog.shape(context),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ValueListenableBuilder<int?>(
            valueListenable: widget.ratingNotifier,
            builder: (context, rating, child) {
              final _rating = rating ?? 0;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...List.generate(5, (i) {
                    final thisRating = i + 1;
                    return Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        _rating < thisRating ? AIcons.rating : AIcons.ratingFull,
                        color: _rating < thisRating ? Colors.grey : Colors.amber,
                      ),
                    );
                  })
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _onPointerMove(Offset globalPosition) {
    final rowBox = context.findRenderObject() as RenderBox;
    final rowSize = rowBox.size;
    final local = rowBox.globalToLocal(globalPosition);
    widget.ratingNotifier.value = (5 * local.dx / rowSize.width).ceil().clamp(0, 5);
  }
}
