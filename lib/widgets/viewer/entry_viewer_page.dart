import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/widgets/common/basic/scaffold.dart';
import 'package:aves/widgets/common/extensions/theme.dart';
import 'package:aves/widgets/viewer/controls/controller.dart';
import 'package:aves/widgets/viewer/entry_viewer_stack.dart';
import 'package:aves/widgets/viewer/overlay/bottom.dart';
import 'package:aves/widgets/viewer/providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EntryViewerPage extends StatefulWidget {
  static const routeName = '/viewer';

  final CollectionLens? collection;
  final AvesEntry initialEntry;

  const EntryViewerPage({
    super.key,
    this.collection,
    required this.initialEntry,
  });

  @override
  State<EntryViewerPage> createState() => _EntryViewerPageState();

  static EdgeInsets snackBarMargin(BuildContext context) {
    return EdgeInsets.only(bottom: ViewerBottomOverlay.actionSafeHeight(context));
  }

  static Color getBackground(BuildContext context) => Theme.of(context).isDark ? Colors.black : Colors.white;
}

class _EntryViewerPageState extends State<EntryViewerPage> {
  final ViewerController _viewerController = ViewerController();

  @override
  void dispose() {
    _viewerController.dispose();
    // provided collection should be a new instance specifically created
    // for the `EntryViewerPage` widget, so it can be safely disposed here
    widget.collection?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final collection = widget.collection;
    return AvesScaffold(
      body: MultiProvider(
        providers: [
          ViewStateConductorProvider(),
          VideoConductorProvider(collection: collection),
          MultiPageConductorProvider(),
        ],
        child: EntryViewerStack(
          collection: collection,
          initialEntry: widget.initialEntry,
          viewerController: _viewerController,
        ),
      ),
      backgroundColor: Navigator.canPop(context) ? Colors.transparent : EntryViewerPage.getBackground(context),
      resizeToAvoidBottomInset: false,
    );
  }
}
