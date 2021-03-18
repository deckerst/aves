import 'dart:collection';

import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_selection_dialog.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';

class LanguageTile extends StatelessWidget {
  final Locale _systemLocale = WidgetsBinding.instance.window.locale;

  static const _systemLocaleOption = Locale('system');

  @override
  Widget build(BuildContext context) {
    final current = settings.locale;
    return ListTile(
      title: Text(context.l10n.settingsLanguage),
      subtitle: Text('${current == null ? '${context.l10n.settingsSystemDefault} • ${_getLocaleName(_systemLocale)}' : _getLocaleName(current)}'),
      onTap: () async {
        final value = await showDialog<Locale>(
          context: context,
          builder: (context) => AvesSelectionDialog<Locale>(
            initialValue: settings.locale ?? _systemLocaleOption,
            options: _getLocaleOptions(context),
            optionSubtitleBuilder: (locale) => locale == _systemLocaleOption ? _getLocaleName(_systemLocale) : null,
            title: context.l10n.settingsLanguage,
          ),
        );
        if (value != null) {
          settings.locale = value == _systemLocaleOption ? null : value;
        }
      },
    );
  }

  String _getLocaleName(Locale locale) => LocaleNamesLocalizationsDelegate.nativeLocaleNames[locale.toString()];

  LinkedHashMap<Locale, String> _getLocaleOptions(BuildContext context) {
    final supportedLocales = List<Locale>.from(AppLocalizations.supportedLocales);
    supportedLocales.removeWhere((locale) => locale == _systemLocale);
    final displayLocales = supportedLocales.map((locale) => MapEntry(locale, _getLocaleName(locale))).toList()..sort((a, b) => compareAsciiUpperCase(a.value, b.value));

    return LinkedHashMap.of({
      _systemLocaleOption: context.l10n.settingsSystemDefault,
      ...LinkedHashMap.fromEntries(displayLocales),
    });
  }
}
