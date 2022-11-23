import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/widgets.dart';

extension ExtraWidgetDisplayedItem on WidgetDisplayedItem {
  String getName(BuildContext context) {
    switch (this) {
      case WidgetDisplayedItem.random:
        return context.l10n.widgetDisplayedItemRandom;
      case WidgetDisplayedItem.mostRecent:
        return context.l10n.widgetDisplayedItemMostRecent;
    }
  }
}
