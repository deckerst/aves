import 'package:aves/model/entry/entry.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/buttons/captioned_button.dart';
import 'package:aves/widgets/common/identity/buttons/overlay_button.dart';
import 'package:aves/widgets/editor/control_panel.dart';
import 'package:aves/widgets/editor/transform/controller.dart';
import 'package:aves/widgets/editor/transform/transformation.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TransformControlPanel extends StatefulWidget {
  final AvesEntry entry;
  final VoidCallback onCancel;
  final void Function(Transformation transformation) onApply;

  const TransformControlPanel({
    super.key,
    required this.entry,
    required this.onCancel,
    required this.onApply,
  });

  @override
  State<TransformControlPanel> createState() => _TransformControlPanelState();
}

class _TransformControlPanelState extends State<TransformControlPanel> with TickerProviderStateMixin {
  late final List<(WidgetBuilder, WidgetBuilder)> _tabs;
  late final TabController _tabController;

  static const padding = EditorControlPanel.padding;

  @override
  void initState() {
    super.initState();
    _tabs = [
      (
        (context) => Tab(text: context.l10n.editorTransformCrop),
        (context) => const CropControlPanel(),
      ),
      (
        (context) => Tab(text: context.l10n.editorTransformRotate),
        (context) => const RotationControlPanel(),
      ),
    ];
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transformController = context.watch<TransformController>();
    return Column(
      children: [
        SizedBox(
          height: CropControlPanel.preferredHeight(context),
          child: AnimatedBuilder(
            animation: _tabController,
            builder: (context, child) {
              return AnimatedSwitcher(
                duration: context.select<DurationsData, Duration>((v) => v.formTransition),
                child: _tabs[_tabController.index].$2(context),
              );
            },
          ),
        ),
        const SizedBox(height: padding),
        Row(
          children: [
            const OverlayButton(
              child: BackButton(),
            ),
            Expanded(
              child: TabBar(
                tabs: _tabs.map((v) => v.$1(context)).toList(),
                controller: _tabController,
                padding: const EdgeInsets.symmetric(horizontal: padding),
                indicatorSize: TabBarIndicatorSize.label,
              ),
            ),
            OverlayButton(
              child: StreamBuilder<Transformation>(
                stream: transformController.transformationStream,
                builder: (context, snapshot) {
                  return IconButton(
                    icon: const Icon(AIcons.apply),
                    onPressed: transformController.modified ? () => widget.onApply(transformController.transformation) : null,
                    tooltip: context.l10n.applyTooltip,
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class CropControlPanel extends StatelessWidget {
  const CropControlPanel({super.key});

  static double preferredHeight(BuildContext context) => CropAspectRatio.values.map((v) {
        return CaptionedButton.getSize(context, v.getText(context), showCaption: true).height;
      }).max;

  @override
  Widget build(BuildContext context) {
    final aspectRatioNotifier = context.select<TransformController, ValueNotifier<CropAspectRatio>>((v) => v.aspectRatioNotifier);
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final ratio = CropAspectRatio.values[index];
        void setAspectRatio() => aspectRatioNotifier.value = ratio;
        return CaptionedButton(
          iconButtonBuilder: (context, focusNode) {
            return ValueListenableBuilder<CropAspectRatio>(
              valueListenable: aspectRatioNotifier,
              builder: (context, selectedRatio, child) {
                return IconButton(
                  color: ratio == selectedRatio ? Theme.of(context).colorScheme.primary : null,
                  onPressed: setAspectRatio,
                  focusNode: focusNode,
                  icon: ratio.getIcon(),
                );
              },
            );
          },
          caption: ratio.getText(context),
          onPressed: setAspectRatio,
        );
      },
      itemCount: CropAspectRatio.values.length,
    );
  }
}

class RotationControlPanel extends StatelessWidget {
  const RotationControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TransformController>();

    return Row(
      children: [
        _buildButton(context, EntryAction.flip, controller.flipHorizontally),
        Expanded(
          child: StreamBuilder<Transformation>(
            stream: controller.transformationStream,
            builder: (context, snapshot) {
              final transformation = snapshot.data ?? Transformation.zero;
              return Slider(
                value: transformation.straightenDegrees,
                min: TransformController.straightenDegreesMin,
                max: TransformController.straightenDegreesMax,
                divisions: 18,
                onChangeStart: (v) => controller.activity = TransformActivity.straighten,
                onChangeEnd: (v) => controller.activity = TransformActivity.none,
                label: NumberFormat('0.0°', context.l10n.localeName).format(transformation.straightenDegrees),
                onChanged: (v) => controller.straightenDegrees = v,
              );
            },
          ),
        ),
        _buildButton(context, EntryAction.rotateCW, controller.rotateClockwise),
      ],
    );
  }

  Widget _buildButton(BuildContext context, EntryAction action, VoidCallback onPressed) {
    return OverlayButton(
      child: IconButton(
        icon: action.getIcon(),
        onPressed: onPressed,
        tooltip: action.getText(context),
      ),
    );
  }
}
