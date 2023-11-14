import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/multipage.dart';
import 'package:aves/widgets/viewer/multipage/controller.dart';
import 'package:aves_utils/aves_utils.dart';
import 'package:flutter/widgets.dart';

class PageEntryBuilder extends StatelessWidget {
  final MultiPageController? multiPageController;
  final Widget Function(AvesEntry? pageEntry) builder;

  const PageEntryBuilder({
    super.key,
    required this.multiPageController,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final controller = multiPageController;
    return StreamBuilder<MultiPageInfo?>(
      stream: controller != null ? controller.infoStream : Stream.value(null),
      builder: (context, snapshot) {
        final multiPageInfo = controller?.info;
        return NullableValueListenableBuilder<int?>(
          valueListenable: controller?.pageNotifier,
          builder: (context, page, child) {
            final pageEntry = multiPageInfo?.getPageEntryByIndex(page);
            return builder(pageEntry);
          },
        );
      },
    );
  }
}
