import 'dart:async';

import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/basic/popup/menu_row.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/buttons/captioned_button.dart';
import 'package:aves_utils/aves_utils.dart';
import 'package:aves_video/aves_video.dart';
import 'package:material_ui/material_ui.dart';

class const MuteToggler({
  super.key,
  required final AvesVideoController? controller,
  final bool isMenuItem = false,
  final FocusNode? focusNode,
  final VoidCallback? onPressed,
}) extends StatelessWidget {
  bool get isMuted => controller?.isMuted ?? false;

  @override
  Widget build(BuildContext context) {
    return NullableValueListenableBuilder<bool>(
      valueListenable: controller?.canMuteNotifier,
      builder: (context, value, child) {
        final canDo = value ?? false;
        return StreamBuilder<double>(
          stream: controller?.volumeStream ?? Stream.value(1.0),
          builder: (context, _) {
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

class const MuteTogglerCaption({
  super.key,
  required final AvesVideoController? controller,
  required final bool enabled,
}) extends StatelessWidget {
  bool get isMuted => controller?.isMuted ?? false;

  @override
  Widget build(BuildContext context) {
    return NullableValueListenableBuilder<bool>(
      valueListenable: controller?.canMuteNotifier,
      builder: (context, value, child) {
        final canDo = value ?? false;
        return StreamBuilder<double>(
          stream: controller?.volumeStream ?? Stream.value(1.0),
          builder: (context, _) {
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
