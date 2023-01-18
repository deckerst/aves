import 'package:aves/widgets/common/identity/buttons/overlay_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

typedef CaptionedIconButtonBuilder = Widget Function(BuildContext context, FocusNode focusNode);

class CaptionedButton extends StatefulWidget {
  final Animation<double> scale;
  final Widget captionText;
  final CaptionedIconButtonBuilder iconButtonBuilder;
  final bool autofocus, showCaption;
  final VoidCallback? onPressed;

  static const EdgeInsets padding = EdgeInsets.symmetric(horizontal: 8);
  static const double iconTextPadding = 8;

  CaptionedButton({
    super.key,
    this.scale = kAlwaysCompleteAnimation,
    Widget? icon,
    CaptionedIconButtonBuilder? iconButtonBuilder,
    String? caption,
    Widget? captionText,
    this.autofocus = false,
    this.showCaption = true,
    required this.onPressed,
  })  : assert(icon != null || iconButtonBuilder != null),
        assert(caption != null || captionText != null),
        iconButtonBuilder = iconButtonBuilder ?? ((_, focusNode) => IconButton(icon: icon!, onPressed: onPressed, focusNode: focusNode)),
        captionText = captionText ?? CaptionedButtonText(text: caption!, enabled: onPressed != null);

  @override
  State<CaptionedButton> createState() => _CaptionedButtonState();

  static double getWidth(BuildContext context) => OverlayButton.getSize(context) + padding.horizontal;

  static Size getSize(BuildContext context, String text, {required bool showCaption}) {
    final width = getWidth(context);
    var height = width;
    if (showCaption) {
      final para = RenderParagraph(
        TextSpan(text: text, style: CaptionedButtonText.textStyle(context)),
        textDirection: TextDirection.ltr,
        textScaleFactor: MediaQuery.textScaleFactorOf(context),
        maxLines: CaptionedButtonText.maxLines,
      )..layout(const BoxConstraints(), parentUsesSize: true);
      height += para.getMaxIntrinsicHeight(width) + padding.vertical;
    }
    return Size(width, height);
  }

  static double getTelevisionButtonHeight(BuildContext context) {
    final text = 'whatever' * 42;
    return CaptionedButton.getSize(context, text, showCaption: true).height;
  }
}

class _CaptionedButtonState extends State<CaptionedButton> {
  final FocusNode _focusNode = FocusNode();
  final ValueNotifier<bool> _focusedNotifier = ValueNotifier(false);
  bool _didAutofocus = false;

  @override
  void initState() {
    super.initState();
    _updateTraversal();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _handleAutofocus();
  }

  @override
  void didUpdateWidget(covariant CaptionedButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.onPressed != widget.onPressed) {
      _updateTraversal();
    }
    if (oldWidget.autofocus != widget.autofocus) {
      _handleAutofocus();
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _focusedNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: CaptionedButton.getWidth(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: CaptionedButton.padding.top),
          OverlayButton(
            scale: widget.scale,
            focusNode: _focusNode,
            child: widget.iconButtonBuilder(context, _focusNode),
          ),
          if (widget.showCaption) ...[
            const SizedBox(height: CaptionedButton.iconTextPadding),
            ScaleTransition(
              scale: widget.scale,
              child: ValueListenableBuilder<bool>(
                valueListenable: _focusedNotifier,
                builder: (context, focused, child) {
                  final style = CaptionedButtonText.textStyle(context);
                  return AnimatedDefaultTextStyle(
                    style: focused
                        ? style.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                          )
                        : style,
                    duration: const Duration(milliseconds: 200),
                    child: widget.captionText,
                  );
                },
              ),
            ),
          ],
          SizedBox(height: CaptionedButton.padding.bottom),
        ],
      ),
    );
  }

  void _handleAutofocus() {
    if (!_didAutofocus && widget.autofocus) {
      FocusScope.of(context).autofocus(_focusNode);
      _didAutofocus = true;
    }
  }

  void _onFocusChanged() => _focusedNotifier.value = _focusNode.hasFocus;

  void _updateTraversal() {
    final enabled = widget.onPressed != null;
    _focusNode.skipTraversal = !enabled;
    _focusNode.canRequestFocus = enabled;
  }
}

class CaptionedButtonText extends StatelessWidget {
  final String text;
  final bool enabled;

  static const int maxLines = 2;

  const CaptionedButtonText({
    super.key,
    required this.text,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    var style = DefaultTextStyle.of(context).style;
    if (!enabled) {
      style = style.copyWith(color: style.color!.withOpacity(.2));
    }

    return Text(
      text,
      style: style,
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
      maxLines: maxLines,
    );
  }

  static TextStyle textStyle(BuildContext context) => Theme.of(context).textTheme.bodySmall!;
}
