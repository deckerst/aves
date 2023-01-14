import 'dart:ui';

import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/material.dart';

class AvesDialog extends StatelessWidget {
  final String? title;
  final ScrollController scrollController;
  final List<Widget>? scrollableContent;
  final bool hasScrollBar;
  final double horizontalContentPadding;
  final Widget? content;
  final List<Widget> actions;

  static const Radius cornerRadius = Radius.circular(24);
  static const double defaultHorizontalContentPadding = 24;
  static const double controlCaptionPadding = 16;
  static const double borderWidth = 1.0;
  static const EdgeInsets actionsPadding = EdgeInsets.symmetric(vertical: 4, horizontal: 16);
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(horizontal: 8);

  AvesDialog({
    super.key,
    this.title,
    ScrollController? scrollController,
    this.scrollableContent,
    this.hasScrollBar = true,
    this.horizontalContentPadding = defaultHorizontalContentPadding,
    this.content,
    required this.actions,
  })  : assert((scrollableContent != null) ^ (content != null)),
        scrollController = scrollController ?? ScrollController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: title != null
          ? Padding(
              // padding to avoid transparent border overlapping
              padding: const EdgeInsets.symmetric(horizontal: borderWidth),
              child: DialogTitle(title: title!),
            )
          : null,
      titlePadding: EdgeInsets.zero,
      // the `scrollable` flag of `AlertDialog` makes it
      // scroll both the title and the content together,
      // and overflow feedback ignores the dialog shape,
      // so we restrict scrolling to the content instead
      content: _buildContent(context),
      contentPadding: scrollableContent != null ? EdgeInsets.zero : EdgeInsets.only(left: horizontalContentPadding, top: 20, right: horizontalContentPadding),
      actions: actions,
      actionsPadding: actionsPadding,
      buttonPadding: buttonPadding,
      // clipping to prevent highlighted material to bleed through rounded corners
      clipBehavior: Clip.antiAlias,
      shape: shape(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (content != null) {
      return content!;
    }

    if (scrollableContent != null) {
      Widget child = ListView(
        controller: scrollController,
        shrinkWrap: true,
        children: scrollableContent!,
      );

      if (hasScrollBar) {
        child = Theme(
          data: Theme.of(context).copyWith(
            scrollbarTheme: ScrollbarThemeData(
              thumbVisibility: MaterialStateProperty.all(true),
              radius: const Radius.circular(16),
              crossAxisMargin: 4,
              // adapt margin when corner is around content itself, not outside for the title
              mainAxisMargin: 4 + (title != null ? 0 : cornerRadius.y / 2),
              interactive: true,
            ),
          ),
          child: Scrollbar(
            controller: scrollController,
            notificationPredicate: (notification) {
              // as of Flutter v3.0.1, the `Scrollbar` does not only respond to the nearest `ScrollView`
              // despite the `defaultScrollNotificationPredicate` checking notification depth,
              // as the notifications coming from the controller in `ListWheelScrollView` in `WheelSelector` still have a depth of 0.
              // Cancelling notification bubbling seems ineffective, so we check the metrics type as a workaround.
              return defaultScrollNotificationPredicate(notification) && notification.metrics is! FixedExtentMetrics;
            },
            child: child,
          ),
        );
      }

      return Container(
        // padding to avoid transparent border overlapping
        padding: const EdgeInsets.symmetric(horizontal: borderWidth),
        // workaround because the dialog tries
        // to size itself to the content intrinsic size,
        // but the `ListView` viewport does not have one
        width: 1,
        child: DecoratedBox(
          decoration: contentDecoration(context),
          child: child,
        ),
      );
    }

    return const SizedBox();
  }

  static Decoration contentDecoration(BuildContext context) => BoxDecoration(
        border: Border(
          bottom: Divider.createBorderSide(context, width: borderWidth),
        ),
      );

  static ShapeBorder shape(BuildContext context) {
    return RoundedRectangleBorder(
      side: Divider.createBorderSide(context, width: borderWidth),
      borderRadius: const BorderRadius.all(cornerRadius),
    );
  }
}

class DialogTitle extends StatelessWidget {
  final String title;

  const DialogTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: AvesDialog.contentDecoration(context),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.normal,
          fontFeatures: [FontFeature.enable('smcp')],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

Future<void> showNoMatchingAppDialog(BuildContext context) => showDialog(
      context: context,
      builder: (context) => AvesDialog(
        content: Text(context.l10n.noMatchingAppDialogMessage),
        actions: const [OkButton()],
      ),
    );

class CancelButton extends StatelessWidget {
  const CancelButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.pop(context),
      child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
    );
  }
}

class OkButton extends StatelessWidget {
  const OkButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.pop(context),
      child: Text(MaterialLocalizations.of(context).okButtonLabel),
    );
  }
}
