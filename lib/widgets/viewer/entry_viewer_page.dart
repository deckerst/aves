import 'package:aves/app_mode.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/widgets/viewer/controller.dart';
import 'package:aves/widgets/viewer/entry_viewer_stack.dart';
import 'package:aves/widgets/viewer/multipage/conductor.dart';
import 'package:aves/widgets/viewer/overlay/bottom.dart';
import 'package:aves/widgets/viewer/video/conductor.dart';
import 'package:aves/widgets/viewer/visual/conductor.dart';
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
}

class _EntryViewerPageState extends State<EntryViewerPage> {
  final ViewerController _viewerController = ViewerController();

  @override
  void dispose() {
    _viewerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ViewStateConductorProvider(
        child: VideoConductorProvider(
          child: MultiPageConductorProvider(
            child: EntryViewerStack(
              collection: widget.collection,
              initialEntry: widget.initialEntry,
              viewerController: _viewerController,
            ),
          ),
        ),
      ),
      backgroundColor: Navigator.canPop(context)
          ? Colors.transparent
          : Theme.of(context).brightness == Brightness.dark
              ? Colors.black
              : Colors.white,
      resizeToAvoidBottomInset: false,
    );
  }
}

class ViewStateConductorProvider extends StatelessWidget {
  final Widget? child;

  const ViewStateConductorProvider({
    super.key,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ProxyProvider<MediaQueryData, ViewStateConductor>(
      create: (context) => ViewStateConductor(),
      update: (context, mq, value) {
        value!.viewportSize = mq.size;
        return value;
      },
      dispose: (context, value) => value.dispose(),
      child: child,
    );
  }
}

class VideoConductorProvider extends StatelessWidget {
  final Widget? child;

  const VideoConductorProvider({
    super.key,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Provider<VideoConductor>(
      create: (context) => VideoConductor(
        persistPlayback: context.read<ValueNotifier<AppMode>>().value == AppMode.main,
      ),
      dispose: (context, value) => value.dispose(),
      child: child,
    );
  }
}

class MultiPageConductorProvider extends StatelessWidget {
  final Widget? child;

  const MultiPageConductorProvider({
    super.key,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Provider<MultiPageConductor>(
      create: (context) => MultiPageConductor(),
      dispose: (context, value) => value.dispose(),
      child: child,
    );
  }
}
