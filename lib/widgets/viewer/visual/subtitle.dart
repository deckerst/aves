import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/common/basic/outlined_text.dart';
import 'package:aves/widgets/viewer/video/controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VideoSubtitles extends StatelessWidget {
  final AvesVideoController controller;

  const VideoSubtitles({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<MediaQueryData, Orientation>(
      selector: (c, mq) => mq.orientation,
      builder: (c, orientation, child) {
        return Align(
          alignment: Alignment(0, orientation == Orientation.portrait ? .5 : .8),
          child: StreamBuilder<String?>(
            stream: controller.timedTextStream,
            builder: (context, snapshot) {
              final text = snapshot.data;
              return text != null ? SubtitleText(text: text) : const SizedBox();
            },
          ),
        );
      },
    );
  }
}

class SubtitleText extends StatelessWidget {
  final String text;

  const SubtitleText({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    late final String displayText;

    if (!settings.videoShowRawTimedText) {
      displayText = text;
    } else {
      // TODO TLAD [video] process ASS tags, cf https://aegi.vmoe.info/docs/3.0/ASS_Tags/
      // e.g. `And I'm like, "We can't {\i1}not{\i0} see it."`
      // e.g. `{\fad(200,200)\blur3}lorem ipsum"`
      // e.g. `{\fnCrapFLTSB\an9\bord5\fs70\c&H403A2D&\3c&HE5E5E8&\pos(1868.286,27.429)}lorem ipsum"`
      // implement these with RegExp + TextSpans:
      // \i: italics
      // \b: bold
      // \c: fill color
      // \1c: fill color
      // \3c: border color
      // \r: reset
      displayText = text.replaceAll(RegExp('{.*?}'), '');
    }

    return OutlinedText(
      text: displayText,
      style: const TextStyle(
        fontSize: 20,
        shadows: [
          Shadow(
            color: Colors.black54,
            offset: Offset(1, 1),
          ),
        ],
      ),
      outlineWidth: 1,
      outlineColor: Colors.black,
      textAlign: TextAlign.center,
    );
  }
}
