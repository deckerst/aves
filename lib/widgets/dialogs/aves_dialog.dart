import 'dart:ui';

import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/material.dart';

class AvesDialog extends StatelessWidget {
  final String? title;
  final ScrollController? scrollController;
  final List<Widget>? scrollableContent;
  final bool hasScrollBar;
  final double horizontalContentPadding;
  final Widget? content;
  final List<Widget> actions;

  static const double defaultHorizontalContentPadding = 24;
  static const double controlCaptionPadding = 16;
  static const double borderWidth = 1.0;

  const AvesDialog({
    Key? key,
    this.title,
    this.scrollController,
    this.scrollableContent,
    this.hasScrollBar = true,
    this.horizontalContentPadding = defaultHorizontalContentPadding,
    this.content,
    required this.actions,
  })  : assert((scrollableContent != null) ^ (content != null)),
        super(key: key);

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
      actionsPadding: const EdgeInsets.symmetric(horizontal: 8),
      shape: shape(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (content != null) {
      return content!;
    }

    if (scrollableContent != null) {
      final _scrollController = scrollController ?? ScrollController();

      Widget child = ListView(
        controller: _scrollController,
        shrinkWrap: true,
        children: scrollableContent!,
      );

      if (hasScrollBar) {
        child = Theme(
          data: Theme.of(context).copyWith(
            scrollbarTheme: const ScrollbarThemeData(
              isAlwaysShown: true,
              radius: Radius.circular(16),
              crossAxisMargin: 4,
              mainAxisMargin: 4,
              interactive: true,
            ),
          ),
          child: Scrollbar(
            controller: _scrollController,
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

  static const Radius cornerRadius = Radius.circular(24);

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
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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

void showNoMatchingAppDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AvesDialog(
        title: context.l10n.noMatchingAppDialogTitle,
        content: Text(context.l10n.noMatchingAppDialogMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(MaterialLocalizations.of(context).okButtonLabel),
          ),
        ],
      );
    },
  );
}
