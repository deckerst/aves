import 'package:aves/l10n/l10n.dart';
import 'package:aves_model/aves_model.dart';

extension ExtraSourceStateView on SourceState {
  String? getName(AppLocalizations l10n) {
    return switch (this) {
      SourceState.loading => l10n.sourceStateLoading,
      SourceState.cataloguing => l10n.sourceStateCataloguing,
      SourceState.locatingCountries => l10n.sourceStateLocatingCountries,
      SourceState.locatingPlaces => l10n.sourceStateLocatingPlaces,
      SourceState.ready => null,
    };
  }
}
