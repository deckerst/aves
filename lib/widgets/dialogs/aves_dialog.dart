import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AvesDialog extends AlertDialog {
  static const contentHorizontalPadding = EdgeInsets.symmetric(horizontal: 24);
  static const borderWidth = 1.0;

  AvesDialog({
    @required BuildContext context,
    String title,
    ScrollController scrollController,
    List<Widget> scrollableContent,
    Widget content,
    @required List<Widget> actions,
  })  : assert((scrollableContent != null) ^ (content != null)),
        super(
          title: title != null
              ? Padding(
                  // padding to avoid transparent border overlapping
                  padding: EdgeInsets.symmetric(horizontal: borderWidth),
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
                  padding: EdgeInsets.symmetric(horizontal: borderWidth),
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
          contentPadding: scrollableContent != null ? EdgeInsets.zero : EdgeInsets.fromLTRB(24, 20, 24, 0),
          actions: actions,
          actionsPadding: EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(
            side: Divider.createBorderSide(context, width: borderWidth),
            borderRadius: BorderRadius.circular(24),
          ),
        );
}

class DialogTitle extends StatelessWidget {
  final String title;

  const DialogTitle({@required this.title});

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
        style: TextStyle(
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
        title: 'No Matching App',
        content: Text('There are no apps that can handle this.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'.toUpperCase()),
          ),
        ],
      );
    },
  );
}
