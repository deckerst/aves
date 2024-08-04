import 'dart:async';

import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/viewer/view_state.dart';
import 'package:aves/widgets/editor/control_panel.dart';
import 'package:aves/widgets/editor/image.dart';
import 'package:aves/widgets/editor/transform/controller.dart';
import 'package:aves/widgets/editor/transform/cropper.dart';
import 'package:aves/widgets/viewer/overlay/minimap.dart';
import 'package:aves_magnifier/aves_magnifier.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ImageEditorPage extends StatefulWidget {
  static const routeName = '/image_editor';

  final AvesEntry entry;

  const ImageEditorPage({
    super.key,
    required this.entry,
  });

  @override
  State<ImageEditorPage> createState() => _ImageEditorPageState();
}

class _ImageEditorPageState extends State<ImageEditorPage> {
  final List<StreamSubscription> _subscriptions = [];
  final ValueNotifier<EditorAction?> _actionNotifier = ValueNotifier(null);
  final ValueNotifier<EdgeInsets> _paddingNotifier = ValueNotifier(EdgeInsets.zero);
  final ValueNotifier<ViewState> _viewStateNotifier = ValueNotifier<ViewState>(ViewState.zero);
  final AvesMagnifierController _magnifierController = AvesMagnifierController();
  late final TransformController _transformController;

  @override
  void initState() {
    super.initState();
    _transformController = TransformController(widget.entry.displaySize);
    _actionNotifier.addListener(_onActionChanged);
    _subscriptions.add(_transformController.transformationStream.map((v) => v.matrix).distinct().listen(_onTransformationMatrixChanged));
  }

  @override
  void dispose() {
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
    _actionNotifier.dispose();
    _paddingNotifier.dispose();
    _viewStateNotifier.dispose();
    _magnifierController.dispose();
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Provider<TransformController>.value(
        value: _transformController,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    ClipRect(
                      child: EditorImage(
                        magnifierController: _magnifierController,
                        transformController: _transformController,
                        actionNotifier: _actionNotifier,
                        paddingNotifier: _paddingNotifier,
                        viewStateNotifier: _viewStateNotifier,
                        entry: widget.entry,
                      ),
                    ),
                    if (settings.showOverlayMinimap)
                      PositionedDirectional(
                        start: 8,
                        bottom: 8,
                        child: Minimap(viewStateNotifier: _viewStateNotifier),
                      ),
                    ValueListenableBuilder<EditorAction?>(
                      valueListenable: _actionNotifier,
                      builder: (context, action, child) {
                        switch (action) {
                          case EditorAction.transform:
                            return Cropper(
                              magnifierController: _magnifierController,
                              transformController: _transformController,
                              paddingNotifier: _paddingNotifier,
                            );
                          case null:
                            return const SizedBox();
                        }
                      },
                    ),
                  ],
                ),
              ),
              EditorControlPanel(
                entry: widget.entry,
                actionNotifier: _actionNotifier,
              ),
            ],
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
    );
  }

  void _onActionChanged() => _updateImagePadding();

  void _updateImagePadding() {
    if (_actionNotifier.value == EditorAction.transform) {
      _paddingNotifier.value = Cropper.imagePadding;
    } else {
      _paddingNotifier.value = EdgeInsets.zero;
    }
  }

  void _onTransformationMatrixChanged(Matrix4 transformationMatrix) {
    final boundaries = _magnifierController.scaleBoundaries;
    if (boundaries != null) {
      _magnifierController.setScaleBoundaries(
        boundaries.copyWith(
          externalTransform: transformationMatrix,
        ),
      );
    }
  }
}
