import 'dart:async';

import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/basic/menu.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/viewer/video/controller.dart';
import 'package:flutter/material.dart';

class MuteToggler extends StatelessWidget {
  final AvesVideoController? controller;
  final bool isMenuItem;
  final VoidCallback? onPressed;

  const MuteToggler({
    Key? key,
    required this.controller,
    this.isMenuItem = false,
    this.onPressed,
  }) : super(key: key);

  bool get isMuted => controller?.isMuted ?? false;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: controller?.canMuteNotifier ?? ValueNotifier(false),
      builder: (context, canDo, child) {
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
                    tooltip: text,
                  );
          },
        );
      },
    );
  }
}
