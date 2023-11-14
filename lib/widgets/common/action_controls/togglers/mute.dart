import 'dart:async';

import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/basic/popup/menu_row.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/buttons/captioned_button.dart';
import 'package:aves_utils/aves_utils.dart';
import 'package:aves_video/aves_video.dart';
import 'package:flutter/material.dart';

class MuteToggler extends StatelessWidget {
  final AvesVideoController? controller;
  final bool isMenuItem;
  final FocusNode? focusNode;
  final VoidCallback? onPressed;

  const MuteToggler({
    super.key,
    required this.controller,
    this.isMenuItem = false,
    this.focusNode,
    this.onPressed,
  });

  bool get isMuted => controller?.isMuted ?? false;

  @override
  Widget build(BuildContext context) {
    return NullableValueListenableBuilder<bool>(
      valueListenable: controller?.canMuteNotifier,
      builder: (context, value, child) {
        final canDo = value ?? false;
        return StreamBuilder<double>(
          stream: controller?.volumeStream ?? Stream.value(1.0),
          builder: (context, snapshot) {
            final icon = Icon(isMuted ? AIcons.unmute : AIcons.mute);
            final text = isMuted ? context.l10n.videoActionUnmute : context.l10n.videoActionMute;

            return isMenuItem
                ? MenuRow(
                    text: text,
                    icon: icon,
                  )
                : IconButton(
                    icon: icon,
                    onPressed: canDo ? onPressed : null,
                    focusNode: focusNode,
                    tooltip: text,
                  );
          },
        );
      },
    );
  }
}

class MuteTogglerCaption extends StatelessWidget {
  final AvesVideoController? controller;
  final bool enabled;

  const MuteTogglerCaption({
    super.key,
    required this.controller,
    required this.enabled,
  });

  bool get isMuted => controller?.isMuted ?? false;

  @override
  Widget build(BuildContext context) {
    return NullableValueListenableBuilder<bool>(
      valueListenable: controller?.canMuteNotifier,
      builder: (context, value, child) {
        final canDo = value ?? false;
        return StreamBuilder<double>(
          stream: controller?.volumeStream ?? Stream.value(1.0),
          builder: (context, snapshot) {
            return CaptionedButtonText(
              text: isMuted ? context.l10n.videoActionUnmute : context.l10n.videoActionMute,
              enabled: canDo && enabled,
            );
          },
        );
      },
    );
  }
}
