import 'dart:ui' as ui;

import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/settings/language/locale_selection_page.dart';
import 'package:aves/widgets/settings/language/locales.dart';
import 'package:aves_model/aves_model.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

class LocaleTile extends StatelessWidget {
  static const systemLocaleOption = ui.Locale('system');

  static const List<String> settingKeys = [SettingKeys.localeKey];

  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // key is expected by test driver
      key: const Key('tile-language'),
      title: Text(context.l10n.settingsLanguageTile),
      subtitle: Selector<Settings, ui.Locale?>(
        selector: (context, s) => settings.basicLocale,
        builder: (context, locale, child) {
          return Text(locale == null ? context.l10n.settingsSystemDefault : getLocaleName(locale));
        },
      ),
      onTap: () async {
        final value = await Navigator.maybeOf(context)?.push<ui.Locale>(
          MaterialPageRoute(
            settings: const RouteSettings(name: LocaleSelectionPage.routeName),
            builder: (context) => const LocaleSelectionPage(),
          ),
        );
        // wait for the dialog to hide
        await Future.delayed(ADurations.pageTransitionLoose * timeDilation);
        if (value != null) {
          settings.basicLocale = value == systemLocaleOption ? null : value;
        }
      },
    );
  }

  static String getLocaleName(ui.Locale locale) {
    // the package `flutter_localized_locales` has the answer for all locales
    // but it comes with 3 MB of assets
    final localeString = locale.toString();
    return SupportedLocales.languagesByLanguageCode[localeString] ?? localeString;
  }
}
