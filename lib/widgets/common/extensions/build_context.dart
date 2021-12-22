import 'package:aves/l10n/l10n.dart';
import 'package:flutter/widgets.dart';

extension ExtraContext on BuildContext {
  String? get currentRouteName => ModalRoute.of(this)?.settings.name;

  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
