import 'package:aves/l10n/l10n.dart';
import 'package:aves_model/aves_model.dart';

extension ExtraSourceStateView on SourceState {
  String? getName(AppLocalizations l10n) {
    return switch (this) {
      .loading => l10n.sourceStateLoading,
      .cataloguing => l10n.sourceStateCataloguing,
      .locatingCountries => l10n.sourceStateLocatingCountries,
      .locatingPlaces => l10n.sourceStateLocatingPlaces,
      .ready => null,
    };
  }
}
