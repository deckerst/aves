import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/extensions/media_query.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

class EmptyContent extends StatelessWidget {
  final IconData? icon;
  final String text;
  final Widget? bottom;
  final AlignmentGeometry alignment;
  final double fontSize;
  final bool safeBottom;

  const EmptyContent({
    super.key,
    this.icon,
    required this.text,
    this.bottom,
    this.alignment = const FractionalOffset(.5, .35),
    this.fontSize = 22,
    this.safeBottom = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary.withAlpha((255.0 * .5).round());
    final durations = context.watch<DurationsData>();
    return Padding(
      padding: safeBottom
          ? EdgeInsets.only(
              bottom: context.select<MediaQueryData, double>((mq) => mq.effectiveBottomPadding),
            )
          : EdgeInsets.zero,
      child: Align(
        alignment: alignment,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: AnimationConfiguration.toStaggeredList(
            duration: durations.staggeredAnimation,
            delay: durations.staggeredAnimationDelay * timeDilation,
            childAnimationBuilder: (child) => SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: child,
              ),
            ),
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 64,
                  color: color,
                ),
                const SizedBox(height: 16)
              ],
              if (text.isNotEmpty)
                Text(
                  text,
                  style: TextStyle(
                    color: color,
                    fontSize: fontSize,
                  ),
                  textAlign: TextAlign.center,
                ),
              if (bottom != null) bottom!,
            ],
          ),
        ),
      ),
    );
  }
}
