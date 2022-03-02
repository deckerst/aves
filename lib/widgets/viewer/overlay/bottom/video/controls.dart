import 'dart:async';

import 'package:aves/model/actions/video_actions.dart';
import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/basic/menu.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/viewer/overlay/common.dart';
import 'package:aves/widgets/viewer/video/controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VideoControlRow extends StatelessWidget {
  final AvesVideoController? controller;
  final Animation<double> scale;
  final Function(VideoAction value) onActionSelected;

  static const double padding = 8;
  static const Radius radius = Radius.circular(123);

  const VideoControlRow({
    Key? key,
    required this.controller,
    required this.scale,
    required this.onActionSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<Settings, VideoControls>(
      selector: (context, s) => s.videoControls,
      builder: (context, videoControls, child) {
        switch (videoControls) {
          case VideoControls.none:
            return const SizedBox();
          case VideoControls.play:
            return Padding(
              padding: const EdgeInsetsDirectional.only(start: padding),
              child: _buildOverlayButton(
                child: PlayToggler(
                  controller: controller,
                  onPressed: () => onActionSelected(VideoAction.togglePlay),
                ),
              ),
            );
          case VideoControls.playSeek:
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: padding),
                _buildIconButton(
                  context,
                  VideoAction.replay10,
                  borderRadius: const BorderRadius.only(topLeft: radius, bottomLeft: radius),
                ),
                _buildOverlayButton(
                  child: PlayToggler(
                    controller: controller,
                    onPressed: () => onActionSelected(VideoAction.togglePlay),
                  ),
                  borderRadius: const BorderRadius.all(Radius.zero),
                ),
                _buildIconButton(
                  context,
                  VideoAction.skip10,
                  borderRadius: const BorderRadius.only(topRight: radius, bottomRight: radius),
                ),
              ],
            );
          case VideoControls.playOutside:
            return Padding(
              padding: const EdgeInsetsDirectional.only(start: padding),
              child: _buildIconButton(
                context,
                VideoAction.playOutside,
              ),
            );
        }
      },
    );
  }

  Widget _buildOverlayButton({
    BorderRadius? borderRadius,
    required Widget child,
  }) =>
      OverlayButton(
        scale: scale,
        borderRadius: borderRadius,
        child: child,
      );

  Widget _buildIconButton(
    BuildContext context,
    VideoAction action, {
    BorderRadius? borderRadius,
  }) =>
      _buildOverlayButton(
        borderRadius: borderRadius,
        child: IconButton(
          icon: action.getIcon(),
          onPressed: () => onActionSelected(action),
          tooltip: action.getText(context),
        ),
      );
}

class PlayToggler extends StatefulWidget {
  final AvesVideoController? controller;
  final bool isMenuItem;
  final VoidCallback? onPressed;

  const PlayToggler({
    Key? key,
    required this.controller,
    this.isMenuItem = false,
    this.onPressed,
  }) : super(key: key);

  @override
  State<PlayToggler> createState() => _PlayTogglerState();
}

class _PlayTogglerState extends State<PlayToggler> with SingleTickerProviderStateMixin {
  final List<StreamSubscription> _subscriptions = [];
  late AnimationController _playPauseAnimation;

  AvesVideoController? get controller => widget.controller;

  bool get isPlaying => controller?.isPlaying ?? false;

  @override
  void initState() {
    super.initState();
    _playPauseAnimation = AnimationController(
      duration: context.read<DurationsData>().iconAnimation,
      vsync: this,
    );
    _registerWidget(widget);
  }

  @override
  void didUpdateWidget(covariant PlayToggler oldWidget) {
    super.didUpdateWidget(oldWidget);
    _unregisterWidget(oldWidget);
    _registerWidget(widget);
  }

  @override
  void dispose() {
    _unregisterWidget(widget);
    _playPauseAnimation.dispose();
    super.dispose();
  }

  void _registerWidget(PlayToggler widget) {
    final controller = widget.controller;
    if (controller != null) {
      _subscriptions.add(controller.statusStream.listen(_onStatusChange));
      _onStatusChange(controller.status);
    }
  }

  void _unregisterWidget(PlayToggler widget) {
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isMenuItem) {
      return isPlaying
          ? MenuRow(
              text: context.l10n.videoActionPause,
              icon: const Icon(AIcons.pause),
            )
          : MenuRow(
              text: context.l10n.videoActionPlay,
              icon: const Icon(AIcons.play),
            );
    }
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.play_pause,
        progress: _playPauseAnimation,
      ),
      onPressed: widget.onPressed,
      tooltip: isPlaying ? context.l10n.videoActionPause : context.l10n.videoActionPlay,
    );
  }

  void _onStatusChange(VideoStatus status) {
    final status = _playPauseAnimation.status;
    if (isPlaying && status != AnimationStatus.forward && status != AnimationStatus.completed) {
      _playPauseAnimation.forward();
    } else if (!isPlaying && status != AnimationStatus.reverse && status != AnimationStatus.dismissed) {
      _playPauseAnimation.reverse();
    }
  }
}
