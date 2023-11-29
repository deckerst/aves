import 'package:aves/model/entry/entry.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/common/basic/multi_cross_fader.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/buttons/overlay_button.dart';
import 'package:aves/widgets/editor/transform/control_panel.dart';
import 'package:aves/widgets/editor/transform/controller.dart';
import 'package:aves/widgets/viewer/overlay/viewer_buttons.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditorControlPanel extends StatelessWidget {
  final AvesEntry entry;
  final ValueNotifier<EditorAction?> actionNotifier;

  static const padding = ViewerButtonRowContent.padding;
  static const actions = [
    EditorAction.transform,
  ];

  const EditorControlPanel({
    super.key,
    required this.entry,
    required this.actionNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: actionNotifier.value == null,
      onPopInvoked: (didPop) {
        if (didPop) return;

        _cancelAction(context);
      },
      child: Padding(
        padding: const EdgeInsets.all(padding),
        child: TooltipTheme(
          data: TooltipTheme.of(context).copyWith(
            preferBelow: false,
          ),
          child: ValueListenableBuilder<EditorAction?>(
            valueListenable: actionNotifier,
            builder: (context, action, child) {
              return MultiCrossFader(
                duration: context.select<DurationsData, Duration>((v) => v.formTransition),
                alignment: Alignment.bottomCenter,
                layoutBuilder: (topChild, topChildKey, bottomChild, bottomChildKey) {
                  return Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      Positioned(
                        key: bottomChildKey,
                        left: 0.0,
                        bottom: 0.0,
                        right: 0.0,
                        child: bottomChild,
                      ),
                      Positioned(
                        key: topChildKey,
                        child: topChild,
                      ),
                    ],
                  );
                },
                child: action == null ? _buildTopLevelPanel(context) : _buildActionPanel(context, action),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTopLevelPanel(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...actions.map(
              (action) => Padding(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: padding / 2),
                child: OverlayButton(
                  child: IconButton(
                    icon: action.getIcon(),
                    onPressed: () => actionNotifier.value = action,
                    tooltip: action.getText(context),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: padding),
        Row(
          children: [
            const OverlayButton(
              child: CloseButton(),
            ),
            const Spacer(),
            OverlayTextButton(
              onPressed: () {},
              child: Text(context.l10n.saveCopyButtonLabel),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionPanel(BuildContext context, EditorAction action) {
    switch (action) {
      case EditorAction.transform:
        return TransformControlPanel(
          entry: entry,
          onCancel: () => _cancelAction(context),
          onApply: (transformation) => _applyAction(context),
        );
    }
  }

  void _cancelAction(BuildContext context) {
    actionNotifier.value = null;
    context.read<TransformController>().reset();
  }

  void _applyAction(BuildContext context) {
    actionNotifier.value = null;
    context.read<TransformController>().reset();
  }
}
