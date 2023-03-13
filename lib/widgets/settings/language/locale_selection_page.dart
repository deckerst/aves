import 'dart:collection';

import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/aves_app.dart';
import 'package:aves/widgets/common/basic/list_tiles/reselectable_radio.dart';
import 'package:aves/widgets/common/basic/query_bar.dart';
import 'package:aves/widgets/common/basic/scaffold.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/settings/language/locale_tile.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

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
    final useTvLayout = settings.useTvLayout;
    return AvesScaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !useTvLayout,
        title: Text(context.l10n.settingsLanguagePageTitle),
      ),
      body: SafeArea(
        child: ValueListenableBuilder<String>(
          valueListenable: _queryNotifier,
          builder: (context, query, child) {
            final upQuery = query.toUpperCase().trim();
            return ListView(
              children: [
                if (!useTvLayout)
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
                    onChanged: (v) => Navigator.maybeOf(context)?.pop(v),
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
