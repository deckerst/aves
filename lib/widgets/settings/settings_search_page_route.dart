import 'package:aves/theme/themes.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/search/route.dart';
import 'package:aves/widgets/settings/settings_page.dart';
import 'package:aves/widgets/settings/settings_search_delegate.dart';
import 'package:material_ui/material_ui.dart';

class SettingsSearchPageRoute extends SearchPageRoute {
  new({
    required BuildContext context,
    super.background,
  }) : super(
         delegate: SettingsSearchDelegate(
           searchFieldLabel: context.l10n.settingsSearchFieldLabel,
           searchFieldStyle: Themes.searchFieldStyle(context),
           sections: SettingsPage.sections,
         ),
       );
}
