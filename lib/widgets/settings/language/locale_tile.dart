import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/settings/language/locale_selection_page.dart';
import 'package:aves/widgets/settings/language/locales.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

class LocaleTile extends StatelessWidget {
  static const systemLocaleOption = Locale('system');

  const LocaleTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // key is expected by test driver
      key: const Key('tile-language'),
      title: Text(context.l10n.settingsLanguageTile),
      subtitle: Selector<Settings, Locale?>(
        selector: (context, s) => settings.locale,
        builder: (context, locale, child) {
          return Text(locale == null ? context.l10n.settingsSystemDefault : getLocaleName(locale));
        },
      ),
      onTap: () async {
        final value = await Navigator.maybeOf(context)?.push<Locale>(
          MaterialPageRoute(
            settings: const RouteSettings(name: LocaleSelectionPage.routeName),
            builder: (context) => const LocaleSelectionPage(),
          ),
        );
        // wait for the dialog to hide as applying the change may block the UI
        await Future.delayed(ADurations.pageTransitionLoose * timeDilation);
        if (value != null) {
          settings.locale = value == systemLocaleOption ? null : value;
        }
      },
    );
  }

  static String getLocaleName(Locale locale) {
    // the package `flutter_localized_locales` has the answer for all locales
    // but it comes with 3 MB of assets
    final localeString = locale.toString();
    return SupportedLocales.languagesByLanguageCode[localeString] ?? localeString;
  }
}
