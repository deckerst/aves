import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

extension ExtraContext on BuildContext {
  String get currentRouteName => ModalRoute.of(this)?.settings?.name;

  AppLocalizations get l10n => AppLocalizations.of(this);
}
