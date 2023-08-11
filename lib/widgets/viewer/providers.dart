import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/widgets/viewer/multipage/conductor.dart';
import 'package:aves/widgets/viewer/video/conductor.dart';
import 'package:aves/widgets/viewer/view/conductor.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class ViewStateConductorProvider extends ProxyProvider<MediaQueryData, ViewStateConductor> {
  ViewStateConductorProvider({
    super.key,
    super.child,
  }) : super(
          create: (context) => ViewStateConductor(),
          update: (context, mq, value) {
            value!.viewportSize = mq.size;
            return value;
          },
          dispose: (context, value) => value.dispose(),
        );
}

class VideoConductorProvider extends Provider<VideoConductor> {
  VideoConductorProvider({
    super.key,
    CollectionLens? collection,
    super.child,
  }) : super(
          create: (context) => VideoConductor(collection: collection),
          dispose: (context, value) => value.dispose(),
        );
}

class MultiPageConductorProvider extends Provider<MultiPageConductor> {
  MultiPageConductorProvider({
    super.key,
    super.child,
  }) : super(
          create: (context) => MultiPageConductor(),
          dispose: (context, value) => value.dispose(),
        );
}
