import 'package:aves/model/entry.dart';
import 'package:aves/model/multipage.dart';
import 'package:aves/widgets/viewer/multipage/controller.dart';
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
    return controller != null
        ? StreamBuilder<MultiPageInfo?>(
            stream: controller.infoStream,
            builder: (context, snapshot) {
              final multiPageInfo = controller.info;
              return ValueListenableBuilder<int?>(
                valueListenable: controller.pageNotifier,
                builder: (context, page, child) {
                  final pageEntry = multiPageInfo?.getPageEntryByIndex(page);
                  return builder(pageEntry);
                },
              );
            },
          )
        : builder(null);
  }
}
