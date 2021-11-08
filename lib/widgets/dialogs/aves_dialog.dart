import 'dart:ui';

import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AvesDialog extends AlertDialog {
  static const double defaultHorizontalContentPadding = 24;
  static const double controlCaptionPadding = 16;
  static const double borderWidth = 1.0;

  AvesDialog({
    Key? key,
    required BuildContext context,
    String? title,
    ScrollController? scrollController,
    List<Widget>? scrollableContent,
    bool hasScrollBar = true,
    double horizontalContentPadding = defaultHorizontalContentPadding,
    Widget? content,
    required List<Widget> actions,
  })  : assert((scrollableContent != null) ^ (content != null)),
        super(
          key: key,
          title: title != null
              ? Padding(
                  // padding to avoid transparent border overlapping
                  padding: const EdgeInsets.symmetric(horizontal: borderWidth),
                  child: DialogTitle(title: title),
                )
              : null,
          titlePadding: EdgeInsets.zero,
          // the `scrollable` flag of `AlertDialog` makes it
          // scroll both the title and the content together,
          // and overflow feedback ignores the dialog shape,
          // so we restrict scrolling to the content instead
          content: _buildContent(context, scrollController, scrollableContent, hasScrollBar, content),
          contentPadding: scrollableContent != null ? EdgeInsets.zero : EdgeInsets.fromLTRB(horizontalContentPadding, 20, horizontalContentPadding, 0),
          actions: actions,
          actionsPadding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(
            side: Divider.createBorderSide(context, width: borderWidth),
            borderRadius: const BorderRadius.all(Radius.circular(24)),
          ),
        );

  static Widget _buildContent(
    BuildContext context,
    ScrollController? scrollController,
    List<Widget>? scrollableContent,
    bool hasScrollBar,
    Widget? content,
  ) {
    if (content != null) {
      return content;
    }

    if (scrollableContent != null) {
      scrollController ??= ScrollController();

      Widget child = ListView(
        controller: scrollController,
        shrinkWrap: true,
        children: scrollableContent,
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
            controller: scrollController,
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
          decoration: BoxDecoration(
            border: Border(
              bottom: Divider.createBorderSide(context, width: borderWidth),
            ),
          ),
          child: child,
        ),
      );
    }

    return const SizedBox();
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
      decoration: BoxDecoration(
        border: Border(
          bottom: Divider.createBorderSide(context, width: AvesDialog.borderWidth),
        ),
      ),
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
        context: context,
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
