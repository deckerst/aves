import 'dart:collection';

import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/aves_app.dart';
import 'package:aves/widgets/common/basic/query_bar.dart';
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

  const LocaleSelectionPage({super.key});

  @override
  State<LocaleSelectionPage> createState() => _LocaleSelectionPageState();
}

class _LocaleSelectionPageState extends State<LocaleSelectionPage> {
  late Locale _selectedValue;
  final ValueNotifier<String> _queryNotifier = ValueNotifier('');

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
          title: Text(context.l10n.settingsLanguagePageTitle),
        ),
        body: SafeArea(
          child: ValueListenableBuilder<String>(
            valueListenable: _queryNotifier,
            builder: (context, query, child) {
              final upQuery = query.toUpperCase().trim();
              return ListView(
                children: [
                  QueryBar(
                    queryNotifier: _queryNotifier,
                    leadingPadding: const EdgeInsetsDirectional.only(start: 24, end: 8),
                  ),
                  ..._getLocaleOptions(context).entries.where((kv) {
                    if (upQuery.isEmpty) return true;
                    final title = kv.value;
                    return title.toUpperCase().contains(upQuery);
                  }).map((kv) {
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
                  }),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  LinkedHashMap<Locale, String> _getLocaleOptions(BuildContext context) {
    final displayLocales = AvesApp.supportedLocales.map((locale) => MapEntry(locale, LocaleTile.getLocaleName(locale))).toList()..sort((a, b) => compareAsciiUpperCase(a.value, b.value));

    return LinkedHashMap.of({
      LocaleTile.systemLocaleOption: context.l10n.settingsSystemDefault,
      ...LinkedHashMap.fromEntries(displayLocales),
    });
  }
}
