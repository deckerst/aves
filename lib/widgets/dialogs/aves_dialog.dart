import 'dart:ui';

import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AvesDialog extends AlertDialog {
  static const contentHorizontalPadding = EdgeInsets.symmetric(horizontal: 24);
  static const borderWidth = 1.0;

  AvesDialog({
    required BuildContext context,
    String? title,
    ScrollController? scrollController,
    List<Widget>? scrollableContent,
    Widget? content,
    required List<Widget> actions,
  })  : assert((scrollableContent != null) ^ (content != null)),
        super(
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
          content: scrollableContent != null
              ? Container(
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
                    child: ListView(
                      controller: scrollController ?? ScrollController(),
                      shrinkWrap: true,
                      children: scrollableContent,
                    ),
                  ),
                )
              : content,
          contentPadding: scrollableContent != null ? EdgeInsets.zero : const EdgeInsets.fromLTRB(24, 20, 24, 0),
          actions: actions,
          actionsPadding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(
            side: Divider.createBorderSide(context, width: borderWidth),
            borderRadius: const BorderRadius.all(Radius.circular(24)),
          ),
        );
}

class DialogTitle extends StatelessWidget {
  final String title;

  const DialogTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 20),
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
