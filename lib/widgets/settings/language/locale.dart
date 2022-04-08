import 'dart:collection';

import 'package:aves/l10n/l10n.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/basic/reselectable_radio_list_tile.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/settings/language/locales.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

class LocaleTile extends StatelessWidget {
  static const systemLocaleOption = Locale('system');

  const LocaleTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // key is expected by test driver
      key: const Key('tile-language'),
      title: Text(context.l10n.settingsLanguage),
      subtitle: Selector<Settings, Locale?>(
        selector: (context, s) => settings.locale,
        builder: (context, locale, child) {
          return Text(locale == null ? context.l10n.settingsSystemDefault : getLocaleName(locale));
        },
      ),
      onTap: () async {
        final value = await Navigator.push<Locale>(
          context,
          MaterialPageRoute(
            settings: const RouteSettings(name: LocaleSelectionPage.routeName),
            builder: (context) => const LocaleSelectionPage(),
          ),
        );
        // wait for the dialog to hide as applying the change may block the UI
        await Future.delayed(Durations.pageTransitionAnimation * timeDilation);
        if (value != null) {
          settings.locale = value == systemLocaleOption ? null : value;
        }
      },
    );
  }

  static String getLocaleName(Locale locale) {
    // the package `flutter_localized_locales` has the answer for all locales
    // but it comes with 3 MB of assets
    return SupportedLocales.languagesByLanguageCode[locale.languageCode] ?? locale.toString();
  }
}

class LocaleSelectionPage extends StatefulWidget {
  static const routeName = '/settings/locale';

  const LocaleSelectionPage({Key? key}) : super(key: key);

  @override
  State<LocaleSelectionPage> createState() => _LocaleSelectionPageState();
}

class _LocaleSelectionPageState extends State<LocaleSelectionPage> {
  late Locale _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = settings.locale ?? LocaleTile.systemLocaleOption;
  }

  @override
  Widget build(BuildContext context) {
    return MediaQueryDataProvider(
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.settingsLanguage),
        ),
        body: SafeArea(
          child: ListView(
            children: _getLocaleOptions(context).entries.map((kv) {
              final value = kv.key;
              final title = kv.value;
              return ReselectableRadioListTile<Locale>(
                // key is expected by test driver
                key: Key(value.toString()),
                value: value,
                groupValue: _selectedValue,
                onChanged: (v) => Navigator.pop(context, v),
                reselectable: true,
                title: Text(
                  title,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  maxLines: 1,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  LinkedHashMap<Locale, String> _getLocaleOptions(BuildContext context) {
    final displayLocales = AppLocalizations.supportedLocales.map((locale) => MapEntry(locale, LocaleTile.getLocaleName(locale))).toList()..sort((a, b) => compareAsciiUpperCase(a.value, b.value));

    return LinkedHashMap.of({
      LocaleTile.systemLocaleOption: context.l10n.settingsSystemDefault,
      ...LinkedHashMap.fromEntries(displayLocales),
    });
  }
}
