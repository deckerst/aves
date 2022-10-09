import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/widgets.dart';

extension ExtraWidgetOpenPage on WidgetOpenPage {
  String getName(BuildContext context) {
    switch (this) {
      case WidgetOpenPage.home:
        return context.l10n.widgetOpenPageHome;
      case WidgetOpenPage.viewer:
        return context.l10n.widgetOpenPageViewer;
    }
  }
}
