// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Estonian (`et`).
class AppLocalizationsEt extends AppLocalizations {
  AppLocalizationsEt([String locale = 'et']) : super(locale);

  @override
  String get appName => 'Aves';

  @override
  String get welcomeMessage => 'Tere tulemast kasutama Avest';

  @override
  String get welcomeOptional => 'Pole kohustuslik';

  @override
  String get welcomeTermsToggle => 'Nõustun kasutustingimustega';

  @override
  String itemCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString objekti',
      one: '$countString objekt',
    );
    return '$_temp0';
  }

  @override
  String columnCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString veergu',
      one: '$countString veerg',
    );
    return '$_temp0';
  }

  @override
  String timeSeconds(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString sekundit',
      one: '$countString sekund',
    );
    return '$_temp0';
  }

  @override
  String timeMinutes(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString minutit',
      one: '$countString minut',
    );
    return '$_temp0';
  }

  @override
  String timeDays(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString päeva',
      one: '$countString päev',
    );
    return '$_temp0';
  }

  @override
  String focalLength(String length) {
    return '$length mm';
  }

  @override
  String get applyButtonLabel => 'RAKENDA';

  @override
  String get deleteButtonLabel => 'KUSTUTA';

  @override
  String get nextButtonLabel => 'JÄRGMINE';

  @override
  String get showButtonLabel => 'NÄITA';

  @override
  String get hideButtonLabel => 'PEIDA';

  @override
  String get continueButtonLabel => 'JÄTKA';

  @override
  String get saveCopyButtonLabel => 'SALVESTA KOOPIA';

  @override
  String get applyTooltip => 'Rakenda';

  @override
  String get cancelTooltip => 'Katkesta';

  @override
  String get changeTooltip => 'Muuda';

  @override
  String get clearTooltip => 'Tühjenda';

  @override
  String get previousTooltip => 'Eelmine';

  @override
  String get nextTooltip => 'Järgmine';

  @override
  String get showTooltip => 'Näita';

  @override
  String get hideTooltip => 'Peida';

  @override
  String get actionRemove => 'Eemalda';

  @override
  String get resetTooltip => 'Lähtesta';

  @override
  String get saveTooltip => 'Salvesta';

  @override
  String get stopTooltip => 'Lõpeta';

  @override
  String get pickTooltip => 'Vali';

  @override
  String get doubleBackExitMessage => 'Väljumiseks klõpsi uuesti nuppu „Tagasi“.';

  @override
  String get doNotAskAgain => 'Ära küsi enam uuesti';

  @override
  String get sourceStateLoading => 'Laadime andmeid';

  @override
  String get sourceStateCataloguing => 'Katalogiseerime';

  @override
  String get sourceStateLocatingCountries => 'Tuvastame riike';

  @override
  String get sourceStateLocatingPlaces => 'Tuvastame asukohti';

  @override
  String get chipActionDelete => 'Kustuta';

  @override
  String get chipActionRemove => 'Eemalda';

  @override
  String get chipActionShowCollection => 'Näita kogumikus';

  @override
  String get chipActionGoToAlbumPage => 'Näita albumites';

  @override
  String get chipActionGoToCountryPage => 'Näita riikides';

  @override
  String get chipActionGoToPlacePage => 'Näita asukohtades';

  @override
  String get chipActionGoToTagPage => 'Näita siltides';

  @override
  String get chipActionGoToExplorerPage => 'Näita sirvijas';

  @override
  String get chipActionDecompose => 'Poolita';

  @override
  String get chipActionFilterOut => 'Sõelu välja';

  @override
  String get chipActionFilterIn => 'Sõelu sisse';

  @override
  String get chipActionHide => 'Peida';

  @override
  String get chipActionLock => 'Lukusta';

  @override
  String get chipActionPin => 'Kinnita üles äärde';

  @override
  String get chipActionUnpin => 'Eemalda ülalt äärest';

  @override
  String get chipActionRename => 'Muuda nime';

  @override
  String get chipActionSetCover => 'Määra kaanepildiks';

  @override
  String get chipActionShowCountryStates => 'Näita osariike';

  @override
  String get chipActionCreateAlbum => 'Loo album';

  @override
  String get chipActionCreateVault => 'Loo turvaruum';

  @override
  String get chipActionConfigureVault => 'Seadista turvaruumi';

  @override
  String get entryActionCopyToClipboard => 'Kopeeri lõikelauale';

  @override
  String get entryActionDelete => 'Kustuta';

  @override
  String get entryActionConvert => 'Konverteeri';

  @override
  String get entryActionExport => 'Ekspordi';

  @override
  String get entryActionInfo => 'Teave';

  @override
  String get entryActionRename => 'Muuda nime';

  @override
  String get entryActionRestore => 'Taasta';

  @override
  String get entryActionRotateCCW => 'Pööra vastupäeva';

  @override
  String get entryActionRotateCW => 'Pööra päripäeva';

  @override
  String get entryActionFlip => 'Pööra ümber horisontaalselt';

  @override
  String get entryActionPrint => 'Trüki';

  @override
  String get entryActionShare => 'Jaga';

  @override
  String get entryActionShareImageOnly => 'Jaga vaid pilti';

  @override
  String get entryActionShareVideoOnly => 'Jaga vaid videot';

  @override
  String get entryActionViewSource => 'Vaata allikat';

  @override
  String get entryActionShowGeoTiffOnMap => 'Näita kaardi ülekattena';

  @override
  String get entryActionConvertMotionPhotoToStillImage => 'Muuda stoppkaadriks';

  @override
  String get entryActionViewMotionPhotoVideo => 'Ava video';

  @override
  String get entryActionEdit => 'Muuda';

  @override
  String get entryActionOpen => 'Ava rakendusega';

  @override
  String get entryActionSetAs => 'Seadista kui';

  @override
  String get entryActionCast => 'Peegelda välisseadmesse';

  @override
  String get entryActionOpenMap => 'Näita kaardirakenduses';

  @override
  String get entryActionRotateScreen => 'Pööra ekraani';

  @override
  String get entryActionAddFavourite => 'Lisa lemmikuks';

  @override
  String get entryActionRemoveFavourite => 'Eemalda lemmikute hulgast';

  @override
  String get videoActionCaptureFrame => 'Tee stoppkaader';

  @override
  String get videoActionMute => 'Summuta';

  @override
  String get videoActionUnmute => 'Eemalda summutamine';

  @override
  String get videoActionPause => 'Peata';

  @override
  String get videoActionPlay => 'Esita';

  @override
  String get videoActionReplay10 => 'Keri tagasi 10 sekundit';

  @override
  String get videoActionSkip10 => 'Keri edasi 10 sekundit';

  @override
  String get videoActionShowPreviousFrame => 'Näita eelmist kaadrit';

  @override
  String get videoActionShowNextFrame => 'Näita järgmist kaadrit';

  @override
  String get videoActionSelectStreams => 'Vali meediavood';

  @override
  String get videoActionSetSpeed => 'Taasesituse kiirus';

  @override
  String get videoActionABRepeat => 'A-B kordus';

  @override
  String get videoRepeatActionSetStart => 'Määra algus';

  @override
  String get videoRepeatActionSetEnd => 'Määra lõpp';

  @override
  String get viewerActionSettings => 'Seadistused';

  @override
  String get viewerActionLock => 'Lukusta vaade';

  @override
  String get viewerActionUnlock => 'Eemalda vaate lukustus';

  @override
  String get slideshowActionResume => 'Jätka';

  @override
  String get slideshowActionShowInCollection => 'Näita kogumikus';

  @override
  String get entryInfoActionEditDate => 'Muuda kuupäeva ja kellaaega';

  @override
  String get entryInfoActionEditLocation => 'Muuda asukohta';

  @override
  String get entryInfoActionEditTitleDescription => 'Muuda pealkirja ja kirjeldust';

  @override
  String get entryInfoActionEditRating => 'Muuda hinnangut';

  @override
  String get entryInfoActionEditTags => 'Muuda silte';

  @override
  String get entryInfoActionRemoveMetadata => 'Eemalda metainfo';

  @override
  String get entryInfoActionExportMetadata => 'Ekspordi metainfo';

  @override
  String get entryInfoActionRemoveLocation => 'Eemalda asukoht';

  @override
  String get editorActionTransform => 'Muuda';

  @override
  String get editorTransformCrop => 'Kadreeri';

  @override
  String get editorTransformRotate => 'Pööra';

  @override
  String get cropAspectRatioFree => 'Vaba';

  @override
  String get cropAspectRatioOriginal => 'Algne';

  @override
  String get cropAspectRatioSquare => 'Ruut';

  @override
  String get filterAspectRatioLandscapeLabel => 'Rõhtloodis';

  @override
  String get filterAspectRatioPortraitLabel => 'Püstloodis';

  @override
  String get filterBinLabel => 'Prügikast';

  @override
  String get filterFavouriteLabel => 'Lemmik';

  @override
  String get filterNoDateLabel => 'Kuupäevata';

  @override
  String get filterNoAddressLabel => 'Aadressita';

  @override
  String get filterLocatedLabel => 'Asukoht tuvastatud';

  @override
  String get filterNoLocationLabel => 'Asukoht tuvastamata';

  @override
  String get filterNoRatingLabel => 'Pole hinnatud';

  @override
  String get filterTaggedLabel => 'Sildistatud';

  @override
  String get filterNoTagLabel => 'Sildistamata';

  @override
  String get filterNoTitleLabel => 'Ilma nimeta';

  @override
  String get filterOnThisDayLabel => 'Täna';

  @override
  String get filterRecentlyAddedLabel => 'Hiljuti lisatud';

  @override
  String get filterRatingRejectedLabel => 'Tagasilükatud';

  @override
  String get filterTypeAnimatedLabel => 'Animeeritud';

  @override
  String get filterTypeMotionPhotoLabel => 'Liikuv foto';

  @override
  String get filterTypePanoramaLabel => 'Panoraam';

  @override
  String get filterTypeRawLabel => 'Raw-vorming';

  @override
  String get filterTypeSphericalVideoLabel => '360° video';

  @override
  String get filterTypeGeotiffLabel => 'GeoTIFF';

  @override
  String get filterMimeImageLabel => 'Pilt';

  @override
  String get filterMimeVideoLabel => 'Video';

  @override
  String get accessibilityAnimationsRemove => 'Eemalda ekraanieffektid';

  @override
  String get accessibilityAnimationsKeep => 'Jäta ekraanieffektid alles';

  @override
  String get albumTierNew => 'Uus';

  @override
  String get albumTierPinned => 'Esiletõstetud';

  @override
  String get albumTierSpecial => 'Üldised';

  @override
  String get albumTierApps => 'Rakendused';

  @override
  String get albumTierVaults => 'Turvaruumid';

  @override
  String get albumTierDynamic => 'Dünaamiline';

  @override
  String get albumTierRegular => 'Muud';

  @override
  String get coordinateFormatDms => 'KMS';

  @override
  String get coordinateFormatDdm => 'KKM';

  @override
  String get coordinateFormatDecimal => 'Kümnendsüsteem';

  @override
  String coordinateDms(String coordinate, String direction) {
    return '$coordinate $direction';
  }

  @override
  String get coordinateDmsNorth => 'N';

  @override
  String get coordinateDmsSouth => 'S';

  @override
  String get coordinateDmsEast => 'E';

  @override
  String get coordinateDmsWest => 'W';

  @override
  String get displayRefreshRatePreferHighest => 'Kõrgeim sagedus';

  @override
  String get displayRefreshRatePreferLowest => 'Madalaim sagedus';

  @override
  String get keepScreenOnNever => 'Mitte kunagi';

  @override
  String get keepScreenOnVideoPlayback => 'Video taasesitusel';

  @override
  String get keepScreenOnViewerOnly => 'Vaid vaate lehel';

  @override
  String get keepScreenOnAlways => 'Alati';

  @override
  String get lengthUnitPixel => 'px';

  @override
  String get lengthUnitPercent => '%';

  @override
  String get mapStyleGoogleNormal => 'Google Maps';

  @override
  String get mapStyleGoogleHybrid => 'Google Maps (hübriidkaart)';

  @override
  String get mapStyleGoogleTerrain => 'Google Maps (maastik)';

  @override
  String get mapStyleOsmLiberty => 'OSM Liberty';

  @override
  String get mapStyleOpenTopoMap => 'OpenTopoMap';

  @override
  String get mapStyleOsmHot => 'OSMi humanitaarkaart';

  @override
  String get mapStyleStamenWatercolor => 'Stamen Watercolor';

  @override
  String get maxBrightnessNever => 'Mitte kunagi';

  @override
  String get maxBrightnessAlways => 'Alati';

  @override
  String get nameConflictStrategyRename => 'Muuda nime';

  @override
  String get nameConflictStrategyReplace => 'Asenda';

  @override
  String get nameConflictStrategySkip => 'Jäta vahele';

  @override
  String get overlayHistogramNone => 'Määratlemata';

  @override
  String get overlayHistogramRGB => 'RGB';

  @override
  String get overlayHistogramLuminance => 'Heledus';

  @override
  String get subtitlePositionTop => 'Üleval';

  @override
  String get subtitlePositionBottom => 'All';

  @override
  String get themeBrightnessLight => 'Hele kujundus';

  @override
  String get themeBrightnessDark => 'Tume kujundus';

  @override
  String get themeBrightnessBlack => 'Süsimust kujundus';

  @override
  String get unitSystemMetric => 'Meetermõõdustik';

  @override
  String get unitSystemImperial => 'Inglise mõõdustik';

  @override
  String get vaultLockTypePattern => 'Muster';

  @override
  String get vaultLockTypePin => 'PIN-kood';

  @override
  String get vaultLockTypePassword => 'Salasõna';

  @override
  String get settingsVideoEnablePip => 'Pilt pildis';

  @override
  String get videoControlsPlayOutside => 'Ava välises meediamängijas';

  @override
  String get videoLoopModeNever => 'Mitte kunagi';

  @override
  String get videoLoopModeShortOnly => 'Vaid lühivideod';

  @override
  String get videoLoopModeAlways => 'Alati';

  @override
  String get videoPlaybackSkip => 'Jäta vahele';

  @override
  String get videoPlaybackMuted => 'Esita summutatuna';

  @override
  String get videoPlaybackWithSound => 'Esita heliga';

  @override
  String get videoResumptionModeNever => 'Mitte kunagi';

  @override
  String get videoResumptionModeAlways => 'Alati';

  @override
  String get viewerTransitionSlide => 'Äraliuglemine';

  @override
  String get viewerTransitionParallax => 'Parallaks';

  @override
  String get viewerTransitionFade => 'Hajumine';

  @override
  String get viewerTransitionZoomIn => 'Sissesuumimine';

  @override
  String get viewerTransitionNone => 'Määratlemata';

  @override
  String get wallpaperTargetHome => 'Avaleht';

  @override
  String get wallpaperTargetLock => 'Lukustusvaade';

  @override
  String get wallpaperTargetHomeLock => 'Avaleht ja lukustusvaade';

  @override
  String get widgetDisplayedItemRandom => 'Juhuslik';

  @override
  String get widgetDisplayedItemMostRecent => 'Viimane';

  @override
  String get widgetOpenPageHome => 'Mine avalehele';

  @override
  String get widgetOpenPageCollection => 'Ava kogumik';

  @override
  String get widgetOpenPageViewer => 'Ava pildivaataja';

  @override
  String get widgetTapUpdateWidget => 'Värskenda vidinat';

  @override
  String get storageVolumeDescriptionFallbackPrimary => 'Sisemine andmehoidla';

  @override
  String get storageVolumeDescriptionFallbackNonPrimary => 'SD-kaart';

  @override
  String get rootDirectoryDescription => 'juurkaust';

  @override
  String otherDirectoryDescription(String name) {
    return '„$name“ kaust';
  }

  @override
  String storageAccessDialogMessage(String directory, String volume) {
    return 'Palun anna sellele rakendusele järgmises ekraanivaates õigused $directory kaustale „$volume“ andmekogus.';
  }

  @override
  String restrictedAccessDialogMessage(String directory, String volume) {
    return 'Sellel rakendusel pole õigusi muuta faile „$volume“ andmekogu $directory kaustas.\n\nPalun kasuta failihaldurit või galeriirakendust failide tõstmiseks muude asukohta.';
  }

  @override
  String notEnoughSpaceDialogMessage(String neededSize, String freeSize, String volume) {
    return 'See tegevus vajab „$volume“ andmeruumis $neededSize vaba andmemahtu, kuid alles on vaid $freeSize.';
  }

  @override
  String get missingSystemFilePickerDialogMessage => 'Süsteemi failihaldur/failivalija on puudu või kasutuselt eemaldatud. Palun pane ta tööle ja proovi siis uuesti.';

  @override
  String unsupportedTypeDialogMessage(int count, String types) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'See tegevus pole toetatud antud tüüpi objektide puhul: $types.',
      one: 'See tegevus pole toetatud antud tüüpi objekti puhul: $types.',
    );
    return '$_temp0';
  }

  @override
  String get nameConflictDialogSingleSourceMessage => 'Mõnedel sihtkausta failidel on sama nimi.';

  @override
  String get nameConflictDialogMultipleSourceMessage => 'Mõnedel failidel on sama nimi.';

  @override
  String get addShortcutDialogLabel => 'Kiirnupu silt';

  @override
  String get addShortcutButtonLabel => 'LISA';

  @override
  String get noMatchingAppDialogMessage => 'Pole rakendusi, mis oskaks seda kasutada.';

  @override
  String binEntriesConfirmationDialogMessage(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kas viskame need $countString objekti prügikasti?',
      one: 'Kas viskame selle objekti prügikasti?',
    );
    return '$_temp0';
  }

  @override
  String deleteEntriesConfirmationDialogMessage(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kas kustutame need $countString objekti?',
      one: 'Kas kustutame selle objekti?',
    );
    return '$_temp0';
  }

  @override
  String get moveUndatedConfirmationDialogMessage => 'Kas enne jätkamist salvestame objekti kuupäevad?';

  @override
  String get moveUndatedConfirmationDialogSetDate => 'Salvesta kuupäevad';

  @override
  String videoResumeDialogMessage(String time) {
    return 'Kas sa soovid jätkata esitamist $time kohalt?';
  }

  @override
  String get videoStartOverButtonLabel => 'ALUSTA UUESTI';

  @override
  String get videoResumeButtonLabel => 'JÄTKA';

  @override
  String get setCoverDialogLatest => 'Viimane objekt';

  @override
  String get setCoverDialogAuto => 'Automaatne';

  @override
  String get setCoverDialogCustom => 'Sinu valik';

  @override
  String get hideFilterConfirmationDialogMessage => 'Filtrile vastavad fotod ja videod on sinu meediakogust peidetud. Kui soovid neid uuesti kuvada, siis seadistuste alajaotusest „Privaatsus“ saad seda lubada.\n\nKas sa oled kindel, et soovid neid peita?';

  @override
  String get newAlbumDialogTitle => 'Uus album';

  @override
  String get newAlbumDialogNameLabel => 'Albumi nimi';

  @override
  String get newAlbumDialogAlbumAlreadyExistsHelper => 'Sellise nimega album on juba olemas';

  @override
  String get newAlbumDialogNameLabelAlreadyExistsHelper => 'Selline kaust on juba olemas';

  @override
  String get newAlbumDialogStorageLabel => 'Andmeruum:';

  @override
  String get newDynamicAlbumDialogTitle => 'Uus dünaamiline album';

  @override
  String get dynamicAlbumAlreadyExists => 'Selline dünaamiline album on juba olemas';

  @override
  String get newVaultWarningDialogMessage => 'Turvaruumis asuvad objektid on nähtavad vaid sellele rakendusele ja mitte ühelgi muul viisil.\n\nKui sa eemaldad nutiseadmest selle rakenduse või kustutad rakenduse andmed, siis kaob igasugune ligipääs nendele objektidele.';

  @override
  String get newVaultDialogTitle => 'Uus turvaruum';

  @override
  String get configureVaultDialogTitle => 'Seadista turvaruumi';

  @override
  String get vaultDialogLockModeWhenScreenOff => 'Ekraani väljalülitumisel lukusta turvaruum';

  @override
  String get vaultDialogLockTypeLabel => 'Lukustuse tüüp';

  @override
  String get patternDialogEnter => 'Sisesta viipemuster';

  @override
  String get patternDialogConfirm => 'Korda viipemustrit';

  @override
  String get pinDialogEnter => 'Sisesta PIN-kood';

  @override
  String get pinDialogConfirm => 'Korda PIN-koodi';

  @override
  String get passwordDialogEnter => 'Sisesta salasõna';

  @override
  String get passwordDialogConfirm => 'Korda salasõna';

  @override
  String get authenticateToConfigureVault => 'Turvaruumi seadistamiseks autendi';

  @override
  String get authenticateToUnlockVault => 'Turvaruumi lukustuse eemaldamiseks autendi';

  @override
  String get vaultBinUsageDialogMessage => 'Mõned turvaruumid kasutavad prügikasti.';

  @override
  String get renameAlbumDialogLabel => 'Uus nimi';

  @override
  String get renameAlbumDialogLabelAlreadyExistsHelper => 'Selline kaust on juba olemas';

  @override
  String get renameEntrySetPageTitle => 'Muuda nime';

  @override
  String get renameEntrySetPagePatternFieldLabel => 'Failide nimemuster';

  @override
  String get renameEntrySetPageInsertTooltip => 'Lisa väli';

  @override
  String get renameEntrySetPagePreviewSectionTitle => 'Eelvaade';

  @override
  String get renameProcessorCounter => 'Loendur';

  @override
  String get renameProcessorHash => 'Räsi';

  @override
  String get renameProcessorName => 'Nimi';

  @override
  String deleteSingleAlbumConfirmationDialogMessage(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kas kustutame selle albumi koos seal leiduva $countString objektiga?',
      one: 'Kas kustutame selle albumi koos seal leiduva ühe objektiga?',
    );
    return '$_temp0';
  }

  @override
  String deleteMultiAlbumConfirmationDialogMessage(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kas kustutame need albumis koos seal leiduva $countString objektiga?',
      one: 'Kas kustutame need albumis koos seal leiduva ühe objektiga?',
    );
    return '$_temp0';
  }

  @override
  String get exportEntryDialogFormat => 'Vorming:';

  @override
  String get exportEntryDialogWidth => 'Laius';

  @override
  String get exportEntryDialogHeight => 'Kõrgus';

  @override
  String get exportEntryDialogQuality => 'Kvaliteet';

  @override
  String get exportEntryDialogWriteMetadata => 'Salvesta metainfo';

  @override
  String get renameEntryDialogLabel => 'Uus nimi';

  @override
  String get editEntryDialogCopyFromItem => 'Kopi teisest objektist';

  @override
  String get editEntryDialogTargetFieldsHeader => 'Muudetavad väljad';

  @override
  String get editEntryDateDialogTitle => 'Kuupäev ja kellaaeg';

  @override
  String get editEntryDateDialogSetCustom => 'Määra soovitud kuupäev';

  @override
  String get editEntryDateDialogCopyField => 'Kopeeri muust kuupäevast';

  @override
  String get editEntryDateDialogExtractFromTitle => 'Tuvasta pealkirjast';

  @override
  String get editEntryDateDialogShift => 'Nihuta ajatemplit';

  @override
  String get editEntryDateDialogSourceFileModifiedDate => 'Faili muutmisaeg';

  @override
  String get durationDialogHours => 'Tunnid';

  @override
  String get durationDialogMinutes => 'Minutid';

  @override
  String get durationDialogSeconds => 'Sekundid';

  @override
  String get editEntryLocationDialogTitle => 'Asukoht';

  @override
  String get editEntryLocationDialogSetCustom => 'Määra asukoht ise';

  @override
  String get editEntryLocationDialogChooseOnMap => 'Vali kaardilt';

  @override
  String get editEntryLocationDialogImportGpx => 'Impordi GPX-fail';

  @override
  String get editEntryLocationDialogLatitude => 'Laiuskraad';

  @override
  String get editEntryLocationDialogLongitude => 'Pikkuskraad';

  @override
  String get editEntryLocationDialogTimeShift => 'Ajanihe';

  @override
  String get locationPickerUseThisLocationButton => 'Kasuta seda asukohta';

  @override
  String get editEntryRatingDialogTitle => 'Hinnang';

  @override
  String get removeEntryMetadataDialogTitle => 'Metainfo eemaldamine';

  @override
  String get removeEntryMetadataDialogAll => 'Kõik';

  @override
  String get removeEntryMetadataDialogMore => 'Veel';

  @override
  String get removeEntryMetadataMotionPhotoXmpWarningDialogMessage => 'XMP on vajalik video esitamisel foto sees.\n\nKas oled kindel, et soovid selle metainfo eemaldada?';

  @override
  String get videoSpeedDialogLabel => 'Taasesituse kiirus';

  @override
  String get videoStreamSelectionDialogVideo => 'Video';

  @override
  String get videoStreamSelectionDialogAudio => 'Heliriba';

  @override
  String get videoStreamSelectionDialogText => 'Subtiitrid';

  @override
  String get videoStreamSelectionDialogOff => 'Välja lülitatud';

  @override
  String get videoStreamSelectionDialogTrack => 'Videoriba';

  @override
  String get videoStreamSelectionDialogNoSelection => 'Rohkem meediaribasid failis pole.';

  @override
  String get genericSuccessFeedback => 'Valmis!';

  @override
  String get genericFailureFeedback => 'Ei õnnestunud';

  @override
  String get genericDangerWarningDialogMessage => 'Kas sa oled kindel?';

  @override
  String get tooManyItemsErrorDialogMessage => 'Proovi uuesti, aga väiksema arvu objektidega.';

  @override
  String get menuActionConfigureView => 'Vaata';

  @override
  String get menuActionSelect => 'Vali';

  @override
  String get menuActionSelectAll => 'Vali kõik';

  @override
  String get menuActionSelectNone => 'Ära vali midagi';

  @override
  String get menuActionMap => 'Kaart';

  @override
  String get menuActionSlideshow => 'Slaidiesitlus';

  @override
  String get menuActionStats => 'Statistika';

  @override
  String get viewDialogSortSectionTitle => 'Järjesta';

  @override
  String get viewDialogGroupSectionTitle => 'Rühmita';

  @override
  String get viewDialogLayoutSectionTitle => 'Paiguta';

  @override
  String get viewDialogReverseSortOrder => 'Tagurpidi järjestus';

  @override
  String get tileLayoutMosaic => 'Mosaiik';

  @override
  String get tileLayoutGrid => 'Ruudustik';

  @override
  String get tileLayoutList => 'Loend';

  @override
  String get castDialogTitle => 'Seadmed peegeldamiseks';

  @override
  String get coverDialogTabCover => 'Kaanepilt';

  @override
  String get coverDialogTabApp => 'Rakenduse';

  @override
  String get coverDialogTabColor => 'Värv';

  @override
  String get appPickDialogTitle => 'Vali rakendus';

  @override
  String get appPickDialogNone => 'Määratlemata';

  @override
  String get aboutPageTitle => 'Rakenduse teave';

  @override
  String get aboutLinkLicense => 'Litsents';

  @override
  String get aboutLinkPolicy => 'Privaatsuspoliitika';

  @override
  String get aboutBugSectionTitle => 'Veateated';

  @override
  String get aboutBugSaveLogInstruction => 'Salvesta rakenduse logid faili';

  @override
  String get aboutBugCopyInfoInstruction => 'Kopeeri süsteemiteave';

  @override
  String get aboutBugCopyInfoButton => 'Kopeeri';

  @override
  String get aboutBugReportInstruction => 'Teata GitHubis koos logide ja süsteemiteabega';

  @override
  String get aboutBugReportButton => 'Teata veast';

  @override
  String get aboutDataUsageSectionTitle => 'Andmekasutus';

  @override
  String get aboutDataUsageData => 'Andmed';

  @override
  String get aboutDataUsageCache => 'Vahemälu';

  @override
  String get aboutDataUsageDatabase => 'Andmebaas';

  @override
  String get aboutDataUsageMisc => 'Varia';

  @override
  String get aboutDataUsageInternal => 'Sisemine';

  @override
  String get aboutDataUsageExternal => 'Väline';

  @override
  String get aboutDataUsageClearCache => 'Tühjenda vahemälu';

  @override
  String get aboutCreditsSectionTitle => 'Tänuavaldused';

  @override
  String get aboutCreditsWorldAtlas1 => 'See rakendus kasutab TopoJSONi faili, mille on koostanud';

  @override
  String get aboutCreditsWorldAtlas2 => ', avaldatud ISC Litsentsi alusel.';

  @override
  String get aboutTranslatorsSectionTitle => 'Tõlkijad';

  @override
  String get aboutLicensesSectionTitle => 'Avatud lähtekoodiga tarkvara litsentsid';

  @override
  String get aboutLicensesBanner => 'See rakendus kasutab järgmiseid avatud lähtekoodiga pakette ja teeke.';

  @override
  String get aboutLicensesAndroidLibrariesSectionTitle => 'Androidi teegid';

  @override
  String get aboutLicensesFlutterPluginsSectionTitle => 'Flutteri lisamoodulid';

  @override
  String get aboutLicensesFlutterPackagesSectionTitle => 'Flutteri paketid';

  @override
  String get aboutLicensesDartPackagesSectionTitle => 'Darti paketid';

  @override
  String get aboutLicensesShowAllButtonLabel => 'Näita kõiki litsentse';

  @override
  String get policyPageTitle => 'Privaatsuspoliitika';

  @override
  String get collectionPageTitle => 'Meediakogu';

  @override
  String get collectionPickPageTitle => 'Vali';

  @override
  String get collectionSelectPageTitle => 'Vali objektid';

  @override
  String get collectionActionShowTitleSearch => 'Näita pealkirjade filtrit';

  @override
  String get collectionActionHideTitleSearch => 'Peida pealkirjade filter';

  @override
  String get collectionActionAddDynamicAlbum => 'Lisa dünaamiline album';

  @override
  String get collectionActionAddShortcut => 'Lisa viide';

  @override
  String get collectionActionSetHome => 'Märgi avaleheks';

  @override
  String get collectionActionEmptyBin => 'Tühjenda prügikast';

  @override
  String get collectionActionCopy => 'Kopeeri albumisse';

  @override
  String get collectionActionMove => 'Teisalda albumisse';

  @override
  String get collectionActionRescan => 'Skaneeri uuesti';

  @override
  String get collectionActionEdit => 'Muuda';

  @override
  String get collectionSearchTitlesHintText => 'Otsi pealkirju';

  @override
  String get collectionGroupAlbum => 'Albumi alusel';

  @override
  String get collectionGroupMonth => 'Kuude kaupa';

  @override
  String get collectionGroupDay => 'Päevade kaupa';

  @override
  String get collectionGroupNone => 'Ära rühmita';

  @override
  String get sectionUnknown => 'Teadmata';

  @override
  String get dateToday => 'Täna';

  @override
  String get dateYesterday => 'Eile';

  @override
  String get dateThisMonth => 'Sel kuul';

  @override
  String collectionDeleteFailureFeedback(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString objekti kustutamine ei õnnestunud',
      one: '1 objekti kustutamine ei õnnestunud',
    );
    return '$_temp0';
  }

  @override
  String collectionCopyFailureFeedback(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString objekti kopeerimine ei õnnestunud',
      one: '1 objekti kopeerimine ei õnnestunud',
    );
    return '$_temp0';
  }

  @override
  String collectionMoveFailureFeedback(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString objekti teisaldamine ei õnnestunud',
      one: '1 objekti teisaldamine ei õnnestunud',
    );
    return '$_temp0';
  }

  @override
  String collectionRenameFailureFeedback(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString objekti nime muutmine ei õnnestunud',
      one: '1 objekti nime muutmine ei õnnestunud',
    );
    return '$_temp0';
  }

  @override
  String collectionEditFailureFeedback(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString objekti muutmine ei õnnestunud',
      one: '1 objekti muutmine ei õnnestunud',
    );
    return '$_temp0';
  }

  @override
  String collectionExportFailureFeedback(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString lehe eksportimine ei õnnestunud',
      one: '1 lehe eksportimine ei õnnestunud',
    );
    return '$_temp0';
  }

  @override
  String collectionCopySuccessFeedback(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kopeerisime $countString objekti',
      one: 'Kopeerisime 1 objekti',
    );
    return '$_temp0';
  }

  @override
  String collectionMoveSuccessFeedback(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Teisaldasime $countString objekti',
      one: 'Teisaldasime 1 objekti',
    );
    return '$_temp0';
  }

  @override
  String collectionRenameSuccessFeedback(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Muutsime $countString objekti nime',
      one: 'Muutsime 1 objekti nime',
    );
    return '$_temp0';
  }

  @override
  String collectionEditSuccessFeedback(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Muutsime $countString objekti',
      one: 'Muutsime 1 objekti',
    );
    return '$_temp0';
  }

  @override
  String get collectionEmptyFavourites => 'Sul pole veel lemmikud';

  @override
  String get collectionEmptyVideos => 'Videoid pole';

  @override
  String get collectionEmptyImages => 'Pilte pole';

  @override
  String get collectionEmptyGrantAccessButtonLabel => 'Luba juurdepääs';

  @override
  String get collectionSelectSectionTooltip => 'Vali lõik';

  @override
  String get collectionDeselectSectionTooltip => 'Eemalda lõigu valik';

  @override
  String get drawerAboutButton => 'Teave';

  @override
  String get drawerSettingsButton => 'Seadistused';

  @override
  String get drawerCollectionAll => 'Kõik kogumikud';

  @override
  String get drawerCollectionFavourites => 'Lemmikud';

  @override
  String get drawerCollectionImages => 'Pildid';

  @override
  String get drawerCollectionVideos => 'Videod';

  @override
  String get drawerCollectionAnimated => 'Animeeritud';

  @override
  String get drawerCollectionMotionPhotos => 'Liikuvad fotod';

  @override
  String get drawerCollectionPanoramas => 'Panoraamfotod';

  @override
  String get drawerCollectionRaws => 'Raw-vormingus fotod';

  @override
  String get drawerCollectionSphericalVideos => '360° videod';

  @override
  String get drawerAlbumPage => 'Albumid';

  @override
  String get drawerCountryPage => 'Riigid';

  @override
  String get drawerPlacePage => 'Kohad';

  @override
  String get drawerTagPage => 'Sildid';

  @override
  String get sortByDate => 'Kuupäeva alusel';

  @override
  String get sortByName => 'Nime alusel';

  @override
  String get sortByItemCount => 'Objektide arvu järgi';

  @override
  String get sortBySize => 'Suuruse alusel';

  @override
  String get sortByAlbumFileName => 'Albumi ja failinime alusel';

  @override
  String get sortByRating => 'Hinnangu alusel';

  @override
  String get sortByDuration => 'Kestuse järgi';

  @override
  String get sortByPath => 'Asukoha alusel';

  @override
  String get sortOrderNewestFirst => 'Esmalt uuemad';

  @override
  String get sortOrderOldestFirst => 'Esmalt vanemad';

  @override
  String get sortOrderAtoZ => 'A kuni Z';

  @override
  String get sortOrderZtoA => 'Z kuni A';

  @override
  String get sortOrderHighestFirst => 'Esmalt kõrgemad';

  @override
  String get sortOrderLowestFirst => 'Esmalt madalamad';

  @override
  String get sortOrderLargestFirst => 'Esmalt suuremad';

  @override
  String get sortOrderSmallestFirst => 'Esmalt väiksemad';

  @override
  String get sortOrderShortestFirst => 'Esmalt lühemad';

  @override
  String get sortOrderLongestFirst => 'Esmalt pikemad';

  @override
  String get albumGroupTier => 'Taseme järgi';

  @override
  String get albumGroupType => 'Tüübi järgi';

  @override
  String get albumGroupVolume => 'Andmemahu alusel';

  @override
  String get albumGroupNone => 'Ära rühmita';

  @override
  String get albumMimeTypeMixed => 'Erinev sisu';

  @override
  String get albumPickPageTitleCopy => 'Kopeeri albumisse';

  @override
  String get albumPickPageTitleExport => 'Ekspordi albumisse';

  @override
  String get albumPickPageTitleMove => 'Teisalda albumisse';

  @override
  String get albumPickPageTitlePick => 'Vali album';

  @override
  String get albumCamera => 'Kaamera';

  @override
  String get albumDownload => 'Laadi alla';

  @override
  String get albumScreenshots => 'Ekraanitõmmised';

  @override
  String get albumScreenRecordings => 'Ekraanisalvestused';

  @override
  String get albumVideoCaptures => 'Videosalvestused';

  @override
  String get albumPageTitle => 'Albumid';

  @override
  String get albumEmpty => 'Albumeid ei leidu';

  @override
  String get createAlbumButtonLabel => 'LOO';

  @override
  String get newFilterBanner => 'uus';

  @override
  String get countryPageTitle => 'Riigid';

  @override
  String get countryEmpty => 'Riike pole';

  @override
  String get statePageTitle => 'Osariigid';

  @override
  String get stateEmpty => 'Osariike pole';

  @override
  String get placePageTitle => 'Asukohad';

  @override
  String get placeEmpty => 'Asukohti pole';

  @override
  String get tagPageTitle => 'Sildid';

  @override
  String get tagEmpty => 'Silte pole';

  @override
  String get binPageTitle => 'Prügikast';

  @override
  String get explorerPageTitle => 'Sirvija';

  @override
  String get explorerActionSelectStorageVolume => 'Vali andmeruum';

  @override
  String get selectStorageVolumeDialogTitle => 'Vali andmeruum';

  @override
  String get searchCollectionFieldHint => 'Otsi kogumikku';

  @override
  String get searchRecentSectionTitle => 'Hiljutised';

  @override
  String get searchDateSectionTitle => 'Kuupäevad';

  @override
  String get searchFormatSectionTitle => 'Vormingud';

  @override
  String get searchAlbumsSectionTitle => 'Albumid';

  @override
  String get searchCountriesSectionTitle => 'Riigid';

  @override
  String get searchStatesSectionTitle => 'Osariigid';

  @override
  String get searchPlacesSectionTitle => 'Asukohad';

  @override
  String get searchTagsSectionTitle => 'Sildid';

  @override
  String get searchRatingSectionTitle => 'Hinnagud';

  @override
  String get searchMetadataSectionTitle => 'Metainfo';

  @override
  String get settingsPageTitle => 'Seadistused';

  @override
  String get settingsSystemDefault => 'Süsteemi vaikeseadistused';

  @override
  String get settingsDefault => 'Vaikimisi';

  @override
  String get settingsDisabled => 'Pole kasutusel';

  @override
  String get settingsAskEverytime => 'Küsi iga kord';

  @override
  String get settingsModificationWarningDialogMessage => 'Muud seadistused kuuluvad muutmisele.';

  @override
  String get settingsSearchFieldLabel => 'Otsi seadistustest';

  @override
  String get settingsSearchEmpty => 'Sellist seadistust ei leidu';

  @override
  String get settingsActionExport => 'Ekspordi';

  @override
  String get settingsActionExportDialogTitle => 'Eksport';

  @override
  String get settingsActionImport => 'Impordi';

  @override
  String get settingsActionImportDialogTitle => 'Import';

  @override
  String get appExportCovers => 'Kaanepildid';

  @override
  String get appExportDynamicAlbums => 'Dünaamilised albumid';

  @override
  String get appExportFavourites => 'Lemmikud';

  @override
  String get appExportSettings => 'Seadistused';

  @override
  String get settingsNavigationSectionTitle => 'Põhivaated';

  @override
  String get settingsHomeTile => 'Avavaade';

  @override
  String get settingsHomeDialogTitle => 'Avavaade';

  @override
  String get setHomeCustom => 'Sinu valitud';

  @override
  String get settingsShowBottomNavigationBar => 'Näita alumist liikumisriba';

  @override
  String get settingsKeepScreenOnTile => 'Hoia ekraan sisselülitatuna';

  @override
  String get settingsKeepScreenOnDialogTitle => 'Hoia ekraan sisselülitatuna';

  @override
  String get settingsDoubleBackExit => 'Väljumiseks klõpsi „Tagasi“ nuppu kaks korda';

  @override
  String get settingsConfirmationTile => 'Kinnitused';

  @override
  String get settingsConfirmationDialogTitle => 'Kinnitused';

  @override
  String get settingsConfirmationBeforeDeleteItems => 'Küsi kinnitust enne objektide lõplikku kustutamist';

  @override
  String get settingsConfirmationBeforeMoveToBinItems => 'Küsi kinnitust enne objektide viskamist prügikasti';

  @override
  String get settingsConfirmationBeforeMoveUndatedItems => 'Küsi kinnitust enne kuupäevadeta objektide teisaldamist';

  @override
  String get settingsConfirmationAfterMoveToBinItems => 'Näita teadet peale objektide viskamist prügikasti';

  @override
  String get settingsConfirmationVaultDataLoss => 'Näita turvaruumi andmekao hoiatust';

  @override
  String get settingsNavigationDrawerTile => 'Ikooniriba';

  @override
  String get settingsNavigationDrawerEditorPageTitle => 'Ikooniriba';

  @override
  String get settingsNavigationDrawerBanner => 'Menüüobjektide teisaldamiseks ja järjekorra muutmiseks vajuta ja hoia all.';

  @override
  String get settingsNavigationDrawerTabTypes => 'Tüübid';

  @override
  String get settingsNavigationDrawerTabAlbums => 'Albumid';

  @override
  String get settingsNavigationDrawerTabPages => 'Lehed';

  @override
  String get settingsNavigationDrawerAddAlbum => 'Lisa album';

  @override
  String get settingsThumbnailSectionTitle => 'Pisipildid';

  @override
  String get settingsThumbnailOverlayTile => 'Ülekate';

  @override
  String get settingsThumbnailOverlayPageTitle => 'Ülekate';

  @override
  String get settingsThumbnailShowHdrIcon => 'Näita HDR-ikooni';

  @override
  String get settingsThumbnailShowFavouriteIcon => 'Näita lemmikute ikooni';

  @override
  String get settingsThumbnailShowTagIcon => 'Näita siltide ikooni';

  @override
  String get settingsThumbnailShowLocationIcon => 'Näita asukoha ikooni';

  @override
  String get settingsThumbnailShowMotionPhotoIcon => 'Näita liikuva foto ikooni';

  @override
  String get settingsThumbnailShowRating => 'Näita hinnangute ikooni';

  @override
  String get settingsThumbnailShowRawIcon => 'Näita Raw-vormingu ikooni';

  @override
  String get settingsThumbnailShowVideoDuration => 'Näita videote kestust';

  @override
  String get settingsCollectionQuickActionsTile => 'Kiirtoimingud';

  @override
  String get settingsCollectionQuickActionEditorPageTitle => 'Kiirtoimingud';

  @override
  String get settingsCollectionQuickActionTabBrowsing => 'Sirvimine';

  @override
  String get settingsCollectionQuickActionTabSelecting => 'Valimine';

  @override
  String get settingsCollectionBrowsingQuickActionEditorBanner => 'Kui soovid valida, mis tegevused on saadaval objektide sirvimisel, siis vajuta ning hoia soovitud ikooni ning lohista ta vajalikku vaatesse.';

  @override
  String get settingsCollectionSelectionQuickActionEditorBanner => 'Kui soovid valida, mis tegevused on saadaval objektide valimisel, siis vajuta ning hoia soovitud ikooni ning lohista ta vajalikku vaatesse.';

  @override
  String get settingsCollectionBurstPatternsTile => 'Laienda mustreid';

  @override
  String get settingsCollectionBurstPatternsNone => 'Määratlemata';

  @override
  String get settingsViewerSectionTitle => 'Pildivaataja';

  @override
  String get settingsViewerGestureSideTapNext => 'Eelmise ja järgmise meediafaili vaatamiseks puuduta ekraani ääri';

  @override
  String get settingsViewerUseCutout => 'Kasuta väljalõigatud ala';

  @override
  String get settingsViewerMaximumBrightness => 'Maksimaalne heledus';

  @override
  String get settingsMotionPhotoAutoPlay => 'Esita liikuivaid fotosid automaatselt';

  @override
  String get settingsImageBackground => 'Pildi taust';

  @override
  String get settingsViewerQuickActionsTile => 'Kiirtoimingud';

  @override
  String get settingsViewerQuickActionEditorPageTitle => 'Kiirtoimingud';

  @override
  String get settingsViewerQuickActionEditorBanner => 'Nuppude/ikoonide valimiseks ja kahe vaate vahel teisaldamiseks puuduta ja all hoides lohista uude kohta.';

  @override
  String get settingsViewerQuickActionEditorDisplayedButtonsSectionTitle => 'Kuvatavad nupud';

  @override
  String get settingsViewerQuickActionEditorAvailableButtonsSectionTitle => 'Saadaval olevad nupud';

  @override
  String get settingsViewerQuickActionEmpty => 'Sa pole ühtegi nuppu siia lisanud';

  @override
  String get settingsViewerOverlayTile => 'Ülekate';

  @override
  String get settingsViewerOverlayPageTitle => 'Ülekate';

  @override
  String get settingsViewerShowOverlayOnOpening => 'Näita avamisel';

  @override
  String get settingsViewerShowHistogram => 'Näita histogrammi';

  @override
  String get settingsViewerShowMinimap => 'Näita minikaarti';

  @override
  String get settingsViewerShowInformation => 'Näita teavet';

  @override
  String get settingsViewerShowInformationSubtitle => 'Näita nime, kuupäeva, asukohta jne.';

  @override
  String get settingsViewerShowRatingTags => 'Näita hinnangut ja silte';

  @override
  String get settingsViewerShowShootingDetails => 'Näita pildistamise üksikasju';

  @override
  String get settingsViewerShowDescription => 'Näita kirjeldust';

  @override
  String get settingsViewerShowOverlayThumbnails => 'Näita pisipilte';

  @override
  String get settingsViewerEnableOverlayBlurEffect => 'Hägustamisefekt';

  @override
  String get settingsViewerSlideshowTile => 'Slaidiesitlus';

  @override
  String get settingsViewerSlideshowPageTitle => 'Slaidiesitlus';

  @override
  String get settingsSlideshowRepeat => 'Korda';

  @override
  String get settingsSlideshowShuffle => 'Sega järjestust';

  @override
  String get settingsSlideshowFillScreen => 'Täida kogu ekraan';

  @override
  String get settingsSlideshowAnimatedZoomEffect => 'Animeeritud suumiefekt';

  @override
  String get settingsSlideshowTransitionTile => 'Üleminekud meedia vahetamisel';

  @override
  String get settingsSlideshowIntervalTile => 'Välp meedia vahetamisel';

  @override
  String get settingsSlideshowVideoPlaybackTile => 'Video taasesitus';

  @override
  String get settingsSlideshowVideoPlaybackDialogTitle => 'Video taasesitus';

  @override
  String get settingsVideoPageTitle => 'Video seadistused';

  @override
  String get settingsVideoSectionTitle => 'Video';

  @override
  String get settingsVideoShowVideos => 'Näita videoid';

  @override
  String get settingsVideoPlaybackTile => 'Taasesitus';

  @override
  String get settingsVideoPlaybackPageTitle => 'Taasesitus';

  @override
  String get settingsVideoEnableHardwareAcceleration => 'Raudvaraline kiirendus';

  @override
  String get settingsVideoAutoPlay => 'Automaatne taasesitus';

  @override
  String get settingsVideoLoopModeTile => 'Korda videoid';

  @override
  String get settingsVideoLoopModeDialogTitle => 'Korda videoid';

  @override
  String get settingsVideoResumptionModeTile => 'Jätka taasesitust';

  @override
  String get settingsVideoResumptionModeDialogTitle => 'Jätka taasesitust';

  @override
  String get settingsVideoBackgroundMode => 'Esitus taustal';

  @override
  String get settingsVideoBackgroundModeDialogTitle => 'Esitus taustal';

  @override
  String get settingsVideoControlsTile => 'Juhtnupud';

  @override
  String get settingsVideoControlsPageTitle => 'Juhtnupud';

  @override
  String get settingsVideoButtonsTile => 'Nupud';

  @override
  String get settingsVideoGestureDoubleTapTogglePlay => 'Esita või peata esitus topeltpuudutusega';

  @override
  String get settingsVideoGestureSideDoubleTapSeek => 'Topeltpuudutus ekraani äärtel kerib edasi või tagasi';

  @override
  String get settingsVideoGestureVerticalDragBrightnessVolume => 'Üles või alla viipamine muudab eredust ja helivaljust';

  @override
  String get settingsSubtitleThemeTile => 'Subtiitrid';

  @override
  String get settingsSubtitleThemePageTitle => 'Subtiitrid';

  @override
  String get settingsSubtitleThemeSample => 'See on üks lihtne näide.';

  @override
  String get settingsSubtitleThemeTextAlignmentTile => 'Teksti joondumine';

  @override
  String get settingsSubtitleThemeTextAlignmentDialogTitle => 'Teksti joondumine';

  @override
  String get settingsSubtitleThemeTextPositionTile => 'Teksti asukoht';

  @override
  String get settingsSubtitleThemeTextPositionDialogTitle => 'Teksti asukoht';

  @override
  String get settingsSubtitleThemeTextSize => 'Teksti suurus';

  @override
  String get settingsSubtitleThemeShowOutline => 'Näite äärejoont ja varju';

  @override
  String get settingsSubtitleThemeTextColor => 'Teksti värv';

  @override
  String get settingsSubtitleThemeTextOpacity => 'Teksti läbipaistmatus';

  @override
  String get settingsSubtitleThemeBackgroundColor => 'Taustavärv';

  @override
  String get settingsSubtitleThemeBackgroundOpacity => 'Tausta läbipaistmatus';

  @override
  String get settingsSubtitleThemeTextAlignmentLeft => 'Vasakul';

  @override
  String get settingsSubtitleThemeTextAlignmentCenter => 'Keskel';

  @override
  String get settingsSubtitleThemeTextAlignmentRight => 'Paremal';

  @override
  String get settingsPrivacySectionTitle => 'Privaatsus';

  @override
  String get settingsAllowInstalledAppAccess => 'Luba ligipääs rakenduse andmekogule';

  @override
  String get settingsAllowInstalledAppAccessSubtitle => 'Seda kasutatakse albumite kuvamise parandamiseks';

  @override
  String get settingsAllowErrorReporting => 'Luba anonüümset veateavitust';

  @override
  String get settingsSaveSearchHistory => 'Salvesta otsingute ajalugu';

  @override
  String get settingsEnableBin => 'Kasuta prügikasti';

  @override
  String get settingsEnableBinSubtitle => 'Hoia kustutatud objekte 30 päeva';

  @override
  String get settingsDisablingBinWarningDialogMessage => 'Prügikastis olevad objektid kustutatakse jäädavalt.';

  @override
  String get settingsAllowMediaManagement => 'Kasuta meediahaldust';

  @override
  String get settingsHiddenItemsTile => 'Peidetud objektid';

  @override
  String get settingsHiddenItemsPageTitle => 'Peidetud objektid';

  @override
  String get settingsHiddenFiltersBanner => 'Peidetuse filtritele vastavad fotod ja videod ei saa olema nähtavad sinu meediakogus.';

  @override
  String get settingsHiddenFiltersEmpty => 'Peidetuse filtreid ei ole';

  @override
  String get settingsStorageAccessTile => 'Ligipääs andmeruumile';

  @override
  String get settingsStorageAccessPageTitle => 'Ligipääs andmeruumile';

  @override
  String get settingsStorageAccessBanner => 'Mõned kaustad vajavad eraldi lubamist seal asuvate failide muutmiseks. Siin näed kaustu, millele sa varem oled sellised õigused jaganud.';

  @override
  String get settingsStorageAccessEmpty => 'Ligipääsuõigusi pole määratud';

  @override
  String get settingsStorageAccessRevokeTooltip => 'Eemalda õigused';

  @override
  String get settingsAccessibilitySectionTitle => 'Ligipääsetavus';

  @override
  String get settingsRemoveAnimationsTile => 'Eemalda animatsioonid';

  @override
  String get settingsRemoveAnimationsDialogTitle => 'Eemalda animatsioonid';

  @override
  String get settingsTimeToTakeActionTile => 'Viivitus enne toiminguid';

  @override
  String get settingsAccessibilityShowPinchGestureAlternatives => 'Näita alternatiive mitmikpuutele';

  @override
  String get settingsDisplaySectionTitle => 'Ekraan';

  @override
  String get settingsThemeBrightnessTile => 'Kujundus';

  @override
  String get settingsThemeBrightnessDialogTitle => 'Kujundus';

  @override
  String get settingsThemeColorHighlights => 'Esiletõstetud värvid';

  @override
  String get settingsThemeEnableDynamicColor => 'Dünaamilised värvid';

  @override
  String get settingsDisplayRefreshRateModeTile => 'Ekraani värskendussagedus';

  @override
  String get settingsDisplayRefreshRateModeDialogTitle => 'Värskendussagedus';

  @override
  String get settingsDisplayUseTvInterface => 'Android TV-liidestus';

  @override
  String get settingsLanguageSectionTitle => 'Keeled ja vormingud';

  @override
  String get settingsLanguageTile => 'Keel';

  @override
  String get settingsLanguagePageTitle => 'Keel';

  @override
  String get settingsCoordinateFormatTile => 'Koordinaatide vorming';

  @override
  String get settingsCoordinateFormatDialogTitle => 'Koordinaatide vorming';

  @override
  String get settingsUnitSystemTile => 'Ühikud';

  @override
  String get settingsUnitSystemDialogTitle => 'Ühikud';

  @override
  String get settingsForceWesternArabicNumeralsTile => 'Jõusta araabia numbrite kasutus';

  @override
  String get settingsScreenSaverPageTitle => 'Ekraanisäästja';

  @override
  String get settingsWidgetPageTitle => 'Fotoraam';

  @override
  String get settingsWidgetShowOutline => 'Piirjoon';

  @override
  String get settingsWidgetOpenPage => 'Vidinal klõpsides';

  @override
  String get settingsWidgetDisplayedItem => 'Kuvatav objekt';

  @override
  String get settingsCollectionTile => 'Meediakogu';

  @override
  String get statsPageTitle => 'Statistika';

  @override
  String statsWithGps(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString asukohaga objekti',
      one: '1 asukohaga objekt',
    );
    return '$_temp0';
  }

  @override
  String get statsTopCountriesSectionTitle => 'Populaarsemad riigid';

  @override
  String get statsTopStatesSectionTitle => 'Populaarsemad osariigid';

  @override
  String get statsTopPlacesSectionTitle => 'Populaarsemad kohad';

  @override
  String get statsTopTagsSectionTitle => 'Populaarsemad sildid';

  @override
  String get statsTopAlbumsSectionTitle => 'Populaarsemad albumid';

  @override
  String get viewerOpenPanoramaButtonLabel => 'AVA PANORAAM';

  @override
  String get viewerSetWallpaperButtonLabel => 'MÄÄRA TAUSTAPILDIKS';

  @override
  String get viewerErrorUnknown => 'Oih, vabandust!';

  @override
  String get viewerErrorDoesNotExist => 'Seda faili pole enam olemas.';

  @override
  String get viewerInfoPageTitle => 'Meedia teave';

  @override
  String get viewerInfoBackToViewerTooltip => 'Tagasi pildivaataja juurde';

  @override
  String get viewerInfoUnknown => 'teadmata';

  @override
  String get viewerInfoLabelDescription => 'Kirjeldus';

  @override
  String get viewerInfoLabelTitle => 'Pealkiri';

  @override
  String get viewerInfoLabelDate => 'Kuupäev';

  @override
  String get viewerInfoLabelResolution => 'Resolutsioon';

  @override
  String get viewerInfoLabelSize => 'Suurus';

  @override
  String get viewerInfoLabelUri => 'URI';

  @override
  String get viewerInfoLabelPath => 'Asukoht';

  @override
  String get viewerInfoLabelDuration => 'Kestus';

  @override
  String get viewerInfoLabelOwner => 'Omanik';

  @override
  String get viewerInfoLabelCoordinates => 'Koordinaadid';

  @override
  String get viewerInfoLabelAddress => 'Aadress';

  @override
  String get mapStyleDialogTitle => 'Kaardi stiil';

  @override
  String get mapStyleTooltip => 'Vali kaardi stiil';

  @override
  String get mapZoomInTooltip => 'Suumi sisse';

  @override
  String get mapZoomOutTooltip => 'Suumi välja';

  @override
  String get mapPointNorthUpTooltip => 'Põhjasuund ülal';

  @override
  String get mapAttributionOsmData => 'Kaardiandmed © [OpenStreetMap](https://www.openstreetmap.org/copyright) kaasautorid';

  @override
  String get mapAttributionOsmLiberty => 'Kaardipaanid: [OpenMapTiles](https://www.openmaptiles.org/), [CC BY](http://creativecommons.org/licenses/by/4.0) • Kaardiserver: [OSM Americana](https://tile.ourmap.us)';

  @override
  String get mapAttributionOpenTopoMap => '[SRTM](https://www.earthdata.nasa.gov/sensors/srtm) | Kaardipaanid: [OpenTopoMap](https://opentopomap.org/), [CC BY-SA](https://creativecommons.org/licenses/by-sa/3.0/)';

  @override
  String get mapAttributionOsmHot => 'Kaardipaanid: [HOT](https://www.hotosm.org/) • Kaardiserver: [OSM France](https://openstreetmap.fr/)';

  @override
  String get mapAttributionStamen => 'Kaardipaanid: [Stamen Design](https://stamen.com), [CC BY 3.0](https://creativecommons.org/licenses/by/3.0)';

  @override
  String get openMapPageTooltip => 'Vaata kaardilehel';

  @override
  String get mapEmptyRegion => 'Sellest piirkonnast ei leidu pilte';

  @override
  String get viewerInfoOpenEmbeddedFailureFeedback => 'Lõimitud andmete lugemine ei õnnestunud';

  @override
  String get viewerInfoOpenLinkText => 'Ava';

  @override
  String get viewerInfoViewXmlLinkText => 'Vaata XMLi';

  @override
  String get viewerInfoSearchFieldLabel => 'Otsi metainfot';

  @override
  String get viewerInfoSearchEmpty => 'Vastavaid võtmeid ei leidu';

  @override
  String get viewerInfoSearchSuggestionDate => 'Kuupäev ja kellaaeg';

  @override
  String get viewerInfoSearchSuggestionDescription => 'Kirjeldus';

  @override
  String get viewerInfoSearchSuggestionDimensions => 'Mõõdud';

  @override
  String get viewerInfoSearchSuggestionResolution => 'Resolutsioon';

  @override
  String get viewerInfoSearchSuggestionRights => 'Õigused';

  @override
  String get wallpaperUseScrollEffect => 'Kasuta avalehel kerimisefekti';

  @override
  String get tagEditorPageTitle => 'Muuda silte';

  @override
  String get tagEditorPageNewTagFieldLabel => 'Uus silt';

  @override
  String get tagEditorPageAddTagTooltip => 'Lisa silt';

  @override
  String get tagEditorSectionRecent => 'Hiljutised';

  @override
  String get tagEditorSectionPlaceholders => 'Asukohanäitajad';

  @override
  String get tagEditorDiscardDialogMessage => 'Kas sa soovid muudatustest loobuda?';

  @override
  String get tagPlaceholderCountry => 'Riik';

  @override
  String get tagPlaceholderState => 'Osariik';

  @override
  String get tagPlaceholderPlace => 'Asukoht';

  @override
  String get panoramaEnableSensorControl => 'Lülita anduripõhine kontroll sisse';

  @override
  String get panoramaDisableSensorControl => 'Lülita anduripõhine kontroll välja';

  @override
  String get sourceViewerPageTitle => 'Allikas';

  @override
  String get filePickerShowHiddenFiles => 'Näita peidetud faile';

  @override
  String get filePickerDoNotShowHiddenFiles => 'Ära näita peidetud faile';

  @override
  String get filePickerOpenFrom => 'Ava asukohast';

  @override
  String get filePickerNoItems => 'Meediafaile pole';

  @override
  String get filePickerUseThisFolder => 'Kasuta seda kausta';
}
