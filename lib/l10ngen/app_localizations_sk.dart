// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Slovak (`sk`).
class AppLocalizationsSk extends AppLocalizations {
  AppLocalizationsSk([String locale = 'sk']) : super(locale);

  @override
  String get appName => 'Aves';

  @override
  String get welcomeMessage => 'Vitajte v Aves';

  @override
  String get welcomeOptional => 'Voliteľné';

  @override
  String get welcomeTermsToggle => 'Súhlasím s pravidlami a podmienkami';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count položiek',
      one: '$count položka',
    );
    return '$_temp0';
  }

  @override
  String columnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stĺpcov',
      one: '$count stĺpec',
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
      other: '$countString sekúnd',
      one: '$countString sekunda',
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
      other: '$countString minút',
      few: '$countString minúty',
      one: '$countString minúta',
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
      other: '$countString dni',
    );
    return '$_temp0';
  }

  @override
  String focalLength(String length) {
    return '$length mm';
  }

  @override
  String get applyButtonLabel => 'POUŽIŤ';

  @override
  String get createButtonLabel => 'CREATE';

  @override
  String get deleteButtonLabel => 'ODSTRÁNIŤ';

  @override
  String get nextButtonLabel => 'ĎALEJ';

  @override
  String get showButtonLabel => 'ZOBRAZIŤ';

  @override
  String get hideButtonLabel => 'SCHOVAŤ';

  @override
  String get continueButtonLabel => 'POKRAČOVAŤ';

  @override
  String get saveCopyButtonLabel => 'Uložiť kópiu';

  @override
  String get applyTooltip => 'Použiť';

  @override
  String get cancelTooltip => 'ZRUŠIŤ';

  @override
  String get changeTooltip => 'ZMENIŤ';

  @override
  String get clearTooltip => 'VYČISTIŤ';

  @override
  String get previousTooltip => 'PREDCHÁDZAJÚCE';

  @override
  String get nextTooltip => 'Ďalej';

  @override
  String get showTooltip => 'Zobraziť';

  @override
  String get hideTooltip => 'Schovať';

  @override
  String get actionRemove => 'Odstrániť';

  @override
  String get resetTooltip => 'Znovu';

  @override
  String get saveTooltip => 'Uložiť';

  @override
  String get stopTooltip => 'Zastaviť';

  @override
  String get pickTooltip => 'Vybrať';

  @override
  String get doubleBackExitMessage => 'Stlač znovu “späť” pre ukončenie.';

  @override
  String get doNotAskAgain => 'Nepýtať sa znovu';

  @override
  String get sourceStateLoading => 'Načítavanie';

  @override
  String get sourceStateCataloguing => 'Indexovanie';

  @override
  String get sourceStateLocatingCountries => 'Hľadanie krajín';

  @override
  String get sourceStateLocatingPlaces => 'Hľadanie miest';

  @override
  String get chipActionDelete => 'Odstrániť';

  @override
  String get chipActionRemove => 'Odstrániť';

  @override
  String get chipActionShowCollection => 'Zobraziť v kolekcií';

  @override
  String get chipActionGoToAlbumPage => 'Zobraziť v albumoch';

  @override
  String get chipActionGoToCountryPage => 'Zobraziť v krajinách';

  @override
  String get chipActionGoToPlacePage => 'Otvoriť v miestach';

  @override
  String get chipActionGoToTagPage => 'Zobraziť v označeniach';

  @override
  String get chipActionGoToExplorerPage => 'Zobraziť v Explorer';

  @override
  String get chipActionDecompose => 'Rozdeliť';

  @override
  String get chipActionFilterOut => 'Filtrovať';

  @override
  String get chipActionFilterIn => 'Prefiltrovať';

  @override
  String get chipActionHide => 'Skryť';

  @override
  String get chipActionLock => 'Zamknúť';

  @override
  String get chipActionPin => 'Pripnúť na začiatok';

  @override
  String get chipActionUnpin => 'Odstrániť z pripnutia';

  @override
  String get chipActionGroup => 'Group';

  @override
  String get chipActionRename => 'Premenovať';

  @override
  String get chipActionSetCover => 'Nastaviť pozadie';

  @override
  String get chipActionShowCountryStates => 'Zobraziť štáty';

  @override
  String get chipActionCreateGroup => 'Create group';

  @override
  String get chipActionCreateAlbum => 'Vytvoriť album';

  @override
  String get chipActionCreateVault => 'Vytvoriť trezor';

  @override
  String get chipActionConfigureVault => 'Nastaviť trezor';

  @override
  String get entryActionCopyToClipboard => 'Skopírovať';

  @override
  String get entryActionDelete => 'Odstrániť';

  @override
  String get entryActionConvert => 'Zmeniť';

  @override
  String get entryActionExport => 'Exportovať';

  @override
  String get entryActionInfo => 'Informácie';

  @override
  String get entryActionRename => 'Premenovať';

  @override
  String get entryActionRestore => 'Obnoviť';

  @override
  String get entryActionRotateCCW => 'Otočiť proti smeru hodinových ručičiek';

  @override
  String get entryActionRotateCW => 'Otočiť po smere hodinových ručičiek';

  @override
  String get entryActionFlip => 'Prevrátiť horizontálne';

  @override
  String get entryActionPrint => 'Vytlačiť';

  @override
  String get entryActionShare => 'Zdieľať';

  @override
  String get entryActionShareImageOnly => 'Zdieľať iba obrázok';

  @override
  String get entryActionShareVideoOnly => 'Zdieľať iba video';

  @override
  String get entryActionViewSource => 'Zobraziť zdroj';

  @override
  String get entryActionShowGeoTiffOnMap => 'Zobraziť na mape';

  @override
  String get entryActionConvertMotionPhotoToStillImage => 'Konvertovať na statický obrázok';

  @override
  String get entryActionViewMotionPhotoVideo => 'Otvoriť video';

  @override
  String get entryActionEdit => 'Upraviť';

  @override
  String get entryActionOpen => 'Otvoriť v';

  @override
  String get entryActionSetAs => 'Nastaviť ako';

  @override
  String get entryActionCast => 'Krúžky';

  @override
  String get entryActionOpenMap => 'Ukázať na mape v aplikácií';

  @override
  String get entryActionRotateScreen => 'Otočiť obrazovku';

  @override
  String get entryActionAddFavourite => 'Pridať do obľúbených';

  @override
  String get entryActionRemoveFavourite => 'Odstrániť z obľúbených';

  @override
  String get videoActionCaptureFrame => 'Zachytiť obraz';

  @override
  String get videoActionMute => 'Stlmiť zvuk';

  @override
  String get videoActionUnmute => 'Zapnúť zvuk';

  @override
  String get videoActionPause => 'Pozastaviť';

  @override
  String get videoActionPlay => 'Spustiť';

  @override
  String get videoActionReplay10 => 'Pretočiť späť o 10 sekúnd';

  @override
  String get videoActionSkip10 => 'Pretočiť dopredu o 10 sekúnd';

  @override
  String get videoActionShowPreviousFrame => 'Zobraziť predchádzajúci rám';

  @override
  String get videoActionShowNextFrame => 'Zobraziť ďalší rám';

  @override
  String get videoActionSelectStreams => 'Výber stopy';

  @override
  String get videoActionSetSpeed => 'Rýchlosť prehrávania';

  @override
  String get videoActionABRepeat => 'Opakovanie A-B';

  @override
  String get videoRepeatActionSetStart => 'Nastaviť začiatok';

  @override
  String get videoRepeatActionSetEnd => 'Nastaviť koniec';

  @override
  String get viewerActionSettings => 'Nastavenia';

  @override
  String get viewerActionLock => 'Uzamknúť pohľad';

  @override
  String get viewerActionUnlock => 'Odomknúť pohľad';

  @override
  String get slideshowActionResume => 'Pokračovať';

  @override
  String get slideshowActionShowInCollection => 'Zobraziť v kolekcií';

  @override
  String get entryInfoActionEditDate => 'Upraviť dátum a čas';

  @override
  String get entryInfoActionEditLocation => 'Upraviť polohu';

  @override
  String get entryInfoActionEditTitleDescription => 'Upraviť nadpis & popis';

  @override
  String get entryInfoActionEditRating => 'Upraviť hodnotenie';

  @override
  String get entryInfoActionEditTags => 'Upraviť značky';

  @override
  String get entryInfoActionRemoveMetadata => 'Odstrániť metadáta';

  @override
  String get entryInfoActionExportMetadata => 'Exportovať metadáta';

  @override
  String get entryInfoActionRemoveLocation => 'Odstrániť polohu';

  @override
  String get editorActionTransform => 'Transformovať';

  @override
  String get editorTransformCrop => 'Orezať';

  @override
  String get editorTransformRotate => 'Otočiť';

  @override
  String get cropAspectRatioFree => 'Uvoľniť';

  @override
  String get cropAspectRatioOriginal => 'Originál';

  @override
  String get cropAspectRatioSquare => 'Štvorec';

  @override
  String get filterAspectRatioLandscapeLabel => 'Horizontálne';

  @override
  String get filterAspectRatioPortraitLabel => 'Vetrikálne';

  @override
  String get filterBinLabel => 'Kôš';

  @override
  String get filterFavouriteLabel => 'Obľúbené';

  @override
  String get filterNoDateLabel => 'Bez dátumu';

  @override
  String get filterNoAddressLabel => 'Bez adresy';

  @override
  String get filterLocatedLabel => 'Lokalizované';

  @override
  String get filterNoLocationLabel => 'Nelokalizované';

  @override
  String get filterNoRatingLabel => 'Nehodnotené';

  @override
  String get filterTaggedLabel => 'Označené';

  @override
  String get filterNoTagLabel => 'Neoznačené';

  @override
  String get filterNoTitleLabel => 'Bez nadpisu';

  @override
  String get filterOnThisDayLabel => 'Tento deň';

  @override
  String get filterRecentlyAddedLabel => 'Nedávno pridané';

  @override
  String get filterRatingRejectedLabel => 'Zamietnuté';

  @override
  String get filterTypeAnimatedLabel => 'Animované';

  @override
  String get filterTypeMotionPhotoLabel => 'Fotka v pohybe';

  @override
  String get filterTypePanoramaLabel => 'Panoráma';

  @override
  String get filterTypeRawLabel => 'Raw';

  @override
  String get filterTypeSphericalVideoLabel => '360° Video';

  @override
  String get filterTypeGeotiffLabel => 'GeoTIFF';

  @override
  String get filterMimeImageLabel => 'Obrázok';

  @override
  String get filterMimeVideoLabel => 'Video';

  @override
  String get accessibilityAnimationsRemove => 'Predchádzanie efektom obrazovky';

  @override
  String get accessibilityAnimationsKeep => 'Zachovanie efektov na obrazovke';

  @override
  String get albumTierNew => 'Nový';

  @override
  String get albumTierPinned => 'Pripnuté';

  @override
  String get albumTierGroups => 'Groups';

  @override
  String get albumTierSpecial => 'Spoločné';

  @override
  String get albumTierApps => 'Aplikácie';

  @override
  String get albumTierVaults => 'Trezory';

  @override
  String get albumTierDynamic => 'Dynamické';

  @override
  String get albumTierRegular => 'Ostatné';

  @override
  String get coordinateFormatDms => 'DMS';

  @override
  String get coordinateFormatDdm => 'DDM';

  @override
  String get coordinateFormatDecimal => 'Desatinné stupne';

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
  String get displayRefreshRatePreferHighest => 'Najvyššie možné';

  @override
  String get displayRefreshRatePreferLowest => 'Najnižšie možné';

  @override
  String get keepScreenOnNever => 'Nikdy';

  @override
  String get keepScreenOnVideoPlayback => 'Počas prehrávania';

  @override
  String get keepScreenOnViewerOnly => 'Iba stránka prehliadača';

  @override
  String get keepScreenOnAlways => 'Vždy';

  @override
  String get lengthUnitPixel => 'px';

  @override
  String get lengthUnitPercent => '%';

  @override
  String get mapStyleGoogleNormal => 'Google mapy';

  @override
  String get mapStyleGoogleHybrid => 'Google mapy (Hybridné)';

  @override
  String get mapStyleGoogleTerrain => 'Google mapy (terén)';

  @override
  String get mapStyleOsmLiberty => 'OSM Slobody';

  @override
  String get mapStyleOpenTopoMap => 'OpenTopoMap';

  @override
  String get mapStyleOsmHot => 'Humanitarian OSM';

  @override
  String get mapStyleStamenWatercolor => 'Stamen Watercolor';

  @override
  String get maxBrightnessNever => 'Nikdy';

  @override
  String get maxBrightnessAlways => 'Vždy';

  @override
  String get nameConflictStrategyRename => 'Premenovať';

  @override
  String get nameConflictStrategyReplace => 'Nahradiť';

  @override
  String get nameConflictStrategySkip => 'Preskočiť';

  @override
  String get overlayHistogramNone => 'Žiadne';

  @override
  String get overlayHistogramRGB => 'RGB';

  @override
  String get overlayHistogramLuminance => 'Svietivosť';

  @override
  String get subtitlePositionTop => 'Navrchu';

  @override
  String get subtitlePositionBottom => 'Naspodku';

  @override
  String get themeBrightnessLight => 'Svetlá';

  @override
  String get themeBrightnessDark => 'Tmavá';

  @override
  String get themeBrightnessBlack => 'Čierna';

  @override
  String get unitSystemMetric => 'Metrické';

  @override
  String get unitSystemImperial => 'Imperiálne';

  @override
  String get vaultLockTypePattern => 'Vzor';

  @override
  String get vaultLockTypePin => 'PIN';

  @override
  String get vaultLockTypePassword => 'Heslo';

  @override
  String get settingsVideoEnablePip => 'Obraz-v-obraze';

  @override
  String get videoControlsPlayOutside => 'Otvoriť v inom prehrávači';

  @override
  String get videoLoopModeNever => 'Nikdy';

  @override
  String get videoLoopModeShortOnly => 'Iba krátke videá';

  @override
  String get videoLoopModeAlways => 'Vždy';

  @override
  String get videoPlaybackSkip => 'Preskočiť';

  @override
  String get videoPlaybackMuted => 'Spustiť stlmené';

  @override
  String get videoPlaybackWithSound => 'Spustiť so zvukom';

  @override
  String get videoResumptionModeNever => 'Nikdy';

  @override
  String get videoResumptionModeAlways => 'Vždy';

  @override
  String get viewerTransitionSlide => 'Snímka';

  @override
  String get viewerTransitionParallax => 'Parallax';

  @override
  String get viewerTransitionFade => 'Vyblednúť';

  @override
  String get viewerTransitionZoomIn => 'Priblížiť';

  @override
  String get viewerTransitionNone => 'Žiadne';

  @override
  String get wallpaperTargetHome => 'Domáca obrazovka';

  @override
  String get wallpaperTargetLock => 'Zamknutá obrazovka';

  @override
  String get wallpaperTargetHomeLock => 'Domáca a zamknutá obrazovka';

  @override
  String get widgetDisplayedItemRandom => 'Náhodné';

  @override
  String get widgetDisplayedItemMostRecent => 'Najnovšie';

  @override
  String get widgetOpenPageHome => 'Isť domov';

  @override
  String get widgetOpenPageCollection => 'Otvoriť kolekciu';

  @override
  String get widgetOpenPageViewer => 'Otvoriť prehliadač';

  @override
  String get widgetTapUpdateWidget => 'Aktualizovať widget';

  @override
  String get storageVolumeDescriptionFallbackPrimary => 'Vnútorný ukladací priestor';

  @override
  String get storageVolumeDescriptionFallbackNonPrimary => 'SD karta';

  @override
  String get rootDirectoryDescription => 'Koreňový adresár';

  @override
  String otherDirectoryDescription(String name) {
    return '“$name” priečinok';
  }

  @override
  String storageAccessDialogMessage(String directory, String volume) {
    return 'Prosím vyber $directory - “$volume” v ďalšom okne aby aplikácia mala prístup k dátam v priečinku.';
  }

  @override
  String restrictedAccessDialogMessage(String directory, String volume) {
    return 'Táto aplikácia nemôže modifikovať súbory v $directory - “$volume”.\n\nProsím použi predinštalovanú aplikáciu na presun súborov do iného priečinka.';
  }

  @override
  String notEnoughSpaceDialogMessage(String neededSize, String freeSize, String volume) {
    return 'Táto operácia potrebuje $neededSize voľnej pamäti “$volume” na dokončenie, dostupných je však iba $freeSize.';
  }

  @override
  String get missingSystemFilePickerDialogMessage => 'Systémový vyberač súborov chýba alebo je vypnutý. Povoľte ho a skúste to znova.';

  @override
  String unsupportedTypeDialogMessage(int count, String types) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Táto operácia neni podporovaná pre $types súbory.',
      one: 'Táto operácia neni podporovaná pre $types súbor.',
    );
    return '$_temp0';
  }

  @override
  String get nameConflictDialogSingleSourceMessage => 'Niektoré súbory v cieľovej destinácií majú rovnaké názvy.';

  @override
  String get nameConflictDialogMultipleSourceMessage => 'Niektoré súbory majú rovnaký názov.';

  @override
  String get addShortcutDialogLabel => 'Názov skratky';

  @override
  String get addShortcutButtonLabel => 'PRIDAŤ';

  @override
  String get noMatchingAppDialogMessage => 'Nie je podporované žiadnou aplikáciou.';

  @override
  String binEntriesConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Presunúť týchto $count položiek do koša?',
      one: 'Presunúť túto položku do koša?',
    );
    return '$_temp0';
  }

  @override
  String deleteEntriesConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Odstrániť týchto $count položiek?',
      one: 'Odstrániť túto položku?',
    );
    return '$_temp0';
  }

  @override
  String get moveUndatedConfirmationDialogMessage => 'Uložiť dátumy pred pokračovaním?';

  @override
  String get moveUndatedConfirmationDialogSetDate => 'Uložiť dátumy';

  @override
  String videoResumeDialogMessage(String time) {
    return 'Pokračovať v prehrávaní od $time?';
  }

  @override
  String get videoStartOverButtonLabel => 'ODZNOVA';

  @override
  String get videoResumeButtonLabel => 'POKRAČOVAŤ';

  @override
  String get setCoverDialogLatest => 'Posledná položka';

  @override
  String get setCoverDialogAuto => 'Automaticky';

  @override
  String get setCoverDialogCustom => 'Vlastné';

  @override
  String get hideFilterConfirmationDialogMessage => 'Vybrané fotky a videá sa nebudú zobrazovať vo vašich kolekciách. Môžete ich obnoviť v nastaveniach “Súkromie”.\n\nUrčite chcete schovať tieto súbory?';

  @override
  String get newAlbumDialogTitle => 'Nový album';

  @override
  String get newAlbumDialogNameLabel => 'Názov albumu';

  @override
  String get newAlbumDialogAlbumAlreadyExistsHelper => 'Album už existuje';

  @override
  String get newAlbumDialogNameLabelAlreadyExistsHelper => 'Priečinok už existuje';

  @override
  String get newAlbumDialogStorageLabel => 'Úložisko:';

  @override
  String get newDynamicAlbumDialogTitle => 'Nový dynamický album';

  @override
  String get dynamicAlbumAlreadyExists => 'Dynamický album už existuje';

  @override
  String get newGroupDialogTitle => 'New Group';

  @override
  String get newGroupDialogNameLabel => 'Group name';

  @override
  String get groupAlreadyExists => 'Group already exists';

  @override
  String get groupEmpty => 'No groups';

  @override
  String get ungrouped => 'Ungrouped';

  @override
  String get groupPickerTitle => 'Pick Group';

  @override
  String get groupPickerUseThisGroupButton => 'Use this group';

  @override
  String get newVaultWarningDialogMessage => 'Položky v trezoroch sú dostupné iba v tejto aplikácií\n\nAk aplikáciu odinštaluješ alebo vymažeš dáta aplikácie, stratíš všetky položky z trezorov.';

  @override
  String get newVaultDialogTitle => 'Nový trezor';

  @override
  String get configureVaultDialogTitle => 'Nastavenie trezoru';

  @override
  String get vaultDialogLockModeWhenScreenOff => 'Uzamknúť pri vypnutí obrazovky';

  @override
  String get vaultDialogLockTypeLabel => 'Typ uzamknutia';

  @override
  String get patternDialogEnter => 'Nastavenie vzoru';

  @override
  String get patternDialogConfirm => 'Potvrď vzor';

  @override
  String get pinDialogEnter => 'Vložiť PIN';

  @override
  String get pinDialogConfirm => 'Potvrď PIN';

  @override
  String get passwordDialogEnter => 'Zadaj heslo';

  @override
  String get passwordDialogConfirm => 'Potvrď heslo';

  @override
  String get authenticateToConfigureVault => 'Na konfiguráciu trezora je potrebné overenie';

  @override
  String get authenticateToUnlockVault => 'Pre odomknutie trezora je potrebné prihlásenie';

  @override
  String get vaultBinUsageDialogMessage => 'Niektoré trezory používajú kôš.';

  @override
  String get renameAlbumDialogLabel => 'Nový názov';

  @override
  String get renameAlbumDialogLabelAlreadyExistsHelper => 'Priečinok už existuje';

  @override
  String get renameEntrySetPageTitle => 'Premenovať';

  @override
  String get renameEntrySetPagePatternFieldLabel => 'Formát';

  @override
  String get renameEntrySetPageInsertTooltip => 'Vložiť položku';

  @override
  String get renameEntrySetPagePreviewSectionTitle => 'Náhľad';

  @override
  String get renameProcessorCounter => 'Počítadlo';

  @override
  String get renameProcessorHash => 'Hash';

  @override
  String get renameProcessorName => 'Názov';

  @override
  String deleteSingleAlbumConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Odstrániť tento album a $count položiek v ňom?',
      one: 'Odstrániť tento album a položku v ňom?',
    );
    return '$_temp0';
  }

  @override
  String deleteMultiAlbumConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Odstrániť tieto albumy a $count položiek v nich?',
      one: 'Odstrániť tieto albumy a položku v nich?',
    );
    return '$_temp0';
  }

  @override
  String get exportEntryDialogFormat => 'Formát:';

  @override
  String get exportEntryDialogWidth => 'Šírka';

  @override
  String get exportEntryDialogHeight => 'Výška';

  @override
  String get exportEntryDialogQuality => 'Kvalita';

  @override
  String get exportEntryDialogWriteMetadata => 'Zapísať metadáta';

  @override
  String get renameEntryDialogLabel => 'Nový názov';

  @override
  String get editEntryDialogCopyFromItem => 'Kopírovať z inej položky';

  @override
  String get editEntryDialogTargetFieldsHeader => 'Polia k úprave';

  @override
  String get editEntryDateDialogTitle => 'Dátum & Čas';

  @override
  String get editEntryDateDialogSetCustom => 'Nastaviť vlastný dátum';

  @override
  String get editEntryDateDialogCopyField => 'Kopírovať z iného dátumu';

  @override
  String get editEntryDateDialogExtractFromTitle => 'Extrahovať z nadpisu';

  @override
  String get editEntryDateDialogShift => 'Posun';

  @override
  String get editEntryDateDialogSourceFileModifiedDate => 'Dátum modifikácie súboru';

  @override
  String get durationDialogHours => 'Hodiny';

  @override
  String get durationDialogMinutes => 'Minúty';

  @override
  String get durationDialogSeconds => 'Sekundy';

  @override
  String get editEntryLocationDialogTitle => 'Poloha';

  @override
  String get editEntryLocationDialogSetCustom => 'Nastaviť vlastnú polohu';

  @override
  String get editEntryLocationDialogChooseOnMap => 'Vybrať z mapy';

  @override
  String get editEntryLocationDialogImportGpx => 'Import GPX';

  @override
  String get editEntryLocationDialogLatitude => 'Zemepisná šírka';

  @override
  String get editEntryLocationDialogLongitude => 'Zemepisná dĺžka';

  @override
  String get editEntryLocationDialogTimeShift => 'Time shift';

  @override
  String get locationPickerUseThisLocationButton => 'Použiť túto polohu';

  @override
  String get editEntryRatingDialogTitle => 'Hodnotenie';

  @override
  String get removeEntryMetadataDialogTitle => 'Odstránenie metadát';

  @override
  String get removeEntryMetadataDialogAll => 'All';

  @override
  String get removeEntryMetadataDialogMore => 'Viac';

  @override
  String get removeEntryMetadataMotionPhotoXmpWarningDialogMessage => 'XMP je potrebné pre prehranie videa vo vnútri pohyblivej fotky.\n\nUrčite to chceš odstrániť?';

  @override
  String get videoSpeedDialogLabel => 'Rýchlosť prehrávania';

  @override
  String get videoStreamSelectionDialogVideo => 'Video';

  @override
  String get videoStreamSelectionDialogAudio => 'Zvuk';

  @override
  String get videoStreamSelectionDialogText => 'Titulky';

  @override
  String get videoStreamSelectionDialogOff => 'Vypnúť';

  @override
  String get videoStreamSelectionDialogTrack => 'Stopa';

  @override
  String get videoStreamSelectionDialogNoSelection => 'Žiadne iné položky.';

  @override
  String get genericSuccessFeedback => 'Hotovo!';

  @override
  String get genericFailureFeedback => 'Nastala chyba';

  @override
  String get genericDangerWarningDialogMessage => 'Si si istý?';

  @override
  String get tooManyItemsErrorDialogMessage => 'Skús znova s menším počtom položiek.';

  @override
  String get menuActionConfigureView => 'Zobrazenie';

  @override
  String get menuActionSelect => 'Označiť';

  @override
  String get menuActionSelectAll => 'Označiť všetko';

  @override
  String get menuActionSelectNone => 'Nič neoznačiť';

  @override
  String get menuActionMap => 'Mapa';

  @override
  String get menuActionSlideshow => 'Prezentácia';

  @override
  String get menuActionStats => 'Štatistiky';

  @override
  String get viewDialogSortSectionTitle => 'Zoradiť';

  @override
  String get viewDialogGroupSectionTitle => 'Zoskupiť';

  @override
  String get viewDialogLayoutSectionTitle => 'Rozloženie';

  @override
  String get viewDialogReverseSortOrder => 'Zoradiť opačne';

  @override
  String get tileLayoutMosaic => 'Mozaika';

  @override
  String get tileLayoutGrid => 'Mriežka';

  @override
  String get tileLayoutList => 'Zoznam';

  @override
  String get castDialogTitle => 'Cast zariadenia';

  @override
  String get coverDialogTabCover => 'Obálka';

  @override
  String get coverDialogTabApp => 'Aplikácia';

  @override
  String get coverDialogTabColor => 'Farba';

  @override
  String get appPickDialogTitle => 'Výber aplikácie';

  @override
  String get appPickDialogNone => 'Nič';

  @override
  String get aboutPageTitle => 'O aplikácií';

  @override
  String get aboutLinkLicense => 'Licencia';

  @override
  String get aboutLinkPolicy => 'Zásady súkromia';

  @override
  String get aboutBugSectionTitle => 'Nahlásenie chyby';

  @override
  String get aboutBugSaveLogInstruction => 'Uložiť záznamy aplikácie do súboru';

  @override
  String get aboutBugCopyInfoInstruction => 'Kopírovať systémové informácie';

  @override
  String get aboutBugCopyInfoButton => 'Kopírovať';

  @override
  String get aboutBugReportInstruction => 'Nahlásiť na Github spolu so záznamami a systémovými informáciami';

  @override
  String get aboutBugReportButton => 'Nahlásiť';

  @override
  String get aboutDataUsageSectionTitle => 'Využitie dát';

  @override
  String get aboutDataUsageData => 'Dáta';

  @override
  String get aboutDataUsageCache => 'Cache';

  @override
  String get aboutDataUsageDatabase => 'Databáza';

  @override
  String get aboutDataUsageMisc => 'Rôzne';

  @override
  String get aboutDataUsageInternal => 'Interné';

  @override
  String get aboutDataUsageExternal => 'Externé';

  @override
  String get aboutDataUsageClearCache => 'Vymazať cache';

  @override
  String get aboutCreditsSectionTitle => 'Kredit';

  @override
  String get aboutCreditsWorldAtlas1 => 'Táto aplikácia používa TopoJSON súbor od';

  @override
  String get aboutCreditsWorldAtlas2 => 'pod ISC licenciou.';

  @override
  String get aboutTranslatorsSectionTitle => 'Prekladatelia';

  @override
  String get aboutLicensesSectionTitle => 'Open-Source Licencie';

  @override
  String get aboutLicensesBanner => 'Táto aplikácia používa nasledujúce open-source balíčky a knižnice.';

  @override
  String get aboutLicensesAndroidLibrariesSectionTitle => 'Android knižnice';

  @override
  String get aboutLicensesFlutterPluginsSectionTitle => 'Flutter Pluginy';

  @override
  String get aboutLicensesFlutterPackagesSectionTitle => 'Flutter Balíčky';

  @override
  String get aboutLicensesDartPackagesSectionTitle => 'Dart Balíčky';

  @override
  String get aboutLicensesShowAllButtonLabel => 'Zobraziť všetky licencie';

  @override
  String get policyPageTitle => 'Zásady súkromia';

  @override
  String get collectionPageTitle => 'Kolekcie';

  @override
  String get collectionPickPageTitle => 'Vybrať';

  @override
  String get collectionSelectPageTitle => 'Označiť položky';

  @override
  String get collectionActionShowTitleSearch => 'Zobraziť filter';

  @override
  String get collectionActionHideTitleSearch => 'Skryť filter';

  @override
  String get collectionActionAddDynamicAlbum => 'Pridať dynamický album';

  @override
  String get collectionActionAddShortcut => 'Pridať skratku';

  @override
  String get collectionActionSetHome => 'Nastaviť ako doma';

  @override
  String get collectionActionEmptyBin => 'Vyprázdniť kôš';

  @override
  String get collectionActionCopy => 'Kopírovať do albumu';

  @override
  String get collectionActionMove => 'Presunúť do albumu';

  @override
  String get collectionActionRescan => 'Opätovné skenovanie';

  @override
  String get collectionActionEdit => 'Upraviť';

  @override
  String get collectionSearchTitlesHintText => 'Vyhľadávanie v nadpisoch';

  @override
  String get collectionGroupAlbum => 'Podľa albumu';

  @override
  String get collectionGroupMonth => 'Podľa mesiaca';

  @override
  String get collectionGroupDay => 'Podľa dňa';

  @override
  String get sectionNone => 'No sections';

  @override
  String get sectionUnknown => 'Neznáme';

  @override
  String get dateToday => 'Dnes';

  @override
  String get dateYesterday => 'Včera';

  @override
  String get dateThisMonth => 'Tento mesiac';

  @override
  String collectionDeleteFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      few: 'Nepodarilo sa odstrániť $count položky',
      other: 'Nepodarilo sa odstrániť $count položiek',
      one: 'Nepodarilo sa odstrániť položku',
    );
    return '$_temp0';
  }

  @override
  String collectionCopyFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nepodarilo sa kopírovať $count položiek',
      few: 'Nepodarilo sa kopírovať $count položky',
      one: 'Nepodarilo sa kopírovať položku',
    );
    return '$_temp0';
  }

  @override
  String collectionMoveFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nepodarilo sa presunúť $count položiek',
      few: 'Nepodarilo sa presunúť $count položky',
      one: 'Nepodarilo sa presunúť položku',
    );
    return '$_temp0';
  }

  @override
  String collectionRenameFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nepodarilo sa premenovať $count položiek',
      few: 'Nepodarilo sa premenovať $count položky',
      one: 'Nepodarilo sa premenovať položku',
    );
    return '$_temp0';
  }

  @override
  String collectionEditFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nepodarilo sa upraviť $count položiek',
      few: 'Nepodarilo sa upraviť $count položky',
      one: 'Nepodarilo sa upraviť položku',
    );
    return '$_temp0';
  }

  @override
  String collectionExportFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nepodarilo sa exportovať $count stránok',
      one: 'Nepodarilo sa exportovať stránku',
    );
    return '$_temp0';
  }

  @override
  String collectionCopySuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Bolo skopírovaných $count položiek',
      one: 'Položka bola skopírovaná',
    );
    return '$_temp0';
  }

  @override
  String collectionMoveSuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Bolo presunutých $count položiek',
      one: 'Položka bola presunutá',
    );
    return '$_temp0';
  }

  @override
  String collectionRenameSuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Bolo premenovaných $count položiek',
      one: 'Položka bola premenovaná',
    );
    return '$_temp0';
  }

  @override
  String collectionEditSuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Bolo upravených $count položiek',
      one: 'Položka bola upravená',
    );
    return '$_temp0';
  }

  @override
  String get collectionEmptyFavourites => 'Žiadne obľúbené';

  @override
  String get collectionEmptyVideos => 'Žiadne videá';

  @override
  String get collectionEmptyImages => 'Žiadne obrázky';

  @override
  String get collectionEmptyGrantAccessButtonLabel => 'Poskytnúť prístup';

  @override
  String get collectionSelectSectionTooltip => 'Označiť sekciu';

  @override
  String get collectionDeselectSectionTooltip => 'Odznačiť sekciu';

  @override
  String get drawerAboutButton => 'O aplikácií';

  @override
  String get drawerSettingsButton => 'Nastavenia';

  @override
  String get drawerCollectionAll => 'Všetky kolekcie';

  @override
  String get drawerCollectionFavourites => 'Obľúbené';

  @override
  String get drawerCollectionImages => 'Obrázky';

  @override
  String get drawerCollectionVideos => 'Videá';

  @override
  String get drawerCollectionAnimated => 'Animované';

  @override
  String get drawerCollectionMotionPhotos => 'Fotky v pohybe';

  @override
  String get drawerCollectionPanoramas => 'Panorámy';

  @override
  String get drawerCollectionRaws => 'Raw fotky';

  @override
  String get drawerCollectionSphericalVideos => '360° Videá';

  @override
  String get drawerAlbumPage => 'Albumy';

  @override
  String get drawerCountryPage => 'Krajiny';

  @override
  String get drawerPlacePage => 'Miesta';

  @override
  String get drawerTagPage => 'Značky';

  @override
  String get sortByDate => 'Podľa dátumu';

  @override
  String get sortByName => 'Podľa názvu';

  @override
  String get sortByItemCount => 'Podľa počtu položiek';

  @override
  String get sortBySize => 'Podľa rozmerov';

  @override
  String get sortByAlbumFileName => 'Podľa albumu & názvu';

  @override
  String get sortByRating => 'Podľa hodnotenia';

  @override
  String get sortByDuration => 'Trvanie';

  @override
  String get sortByPath => 'By path';

  @override
  String get sortOrderNewestFirst => 'Najskôr najnovšie';

  @override
  String get sortOrderOldestFirst => 'Najskôr najstaršie';

  @override
  String get sortOrderAtoZ => 'od A po Z';

  @override
  String get sortOrderZtoA => 'od Z po A';

  @override
  String get sortOrderHighestFirst => 'Od najväčšieho';

  @override
  String get sortOrderLowestFirst => 'Od najmenšieho';

  @override
  String get sortOrderLargestFirst => 'Najväčšie prvé';

  @override
  String get sortOrderSmallestFirst => 'Najmenšie prvé';

  @override
  String get sortOrderShortestFirst => 'Najkratší prvý';

  @override
  String get sortOrderLongestFirst => 'Najdlhšie prvý';

  @override
  String get albumGroupTier => 'Podľa úrovne';

  @override
  String get albumGroupType => 'Podľa typu';

  @override
  String get albumGroupVolume => 'Podľa objemu pamäte';

  @override
  String get albumMimeTypeMixed => 'Zmiešané';

  @override
  String get albumPickPageTitleCopy => 'Kopírovať do Albumu';

  @override
  String get albumPickPageTitleExport => 'Exportovať do albumu';

  @override
  String get albumPickPageTitleMove => 'Presunúť do Albumu';

  @override
  String get albumPickPageTitlePick => 'Vyber album';

  @override
  String get albumCamera => 'Kamera';

  @override
  String get albumDownload => 'Stiahnuť';

  @override
  String get albumScreenshots => 'Snímky obrazovky';

  @override
  String get albumScreenRecordings => 'Nahrávania obrazovky';

  @override
  String get albumVideoCaptures => 'Video záznamy';

  @override
  String get albumPageTitle => 'Albumy';

  @override
  String get albumEmpty => 'Žiadne albumy';

  @override
  String get createAlbumButtonLabel => 'Vytvoriť';

  @override
  String get newFilterBanner => 'Nový';

  @override
  String get countryPageTitle => 'Krajiny';

  @override
  String get countryEmpty => 'Žiadne krajiny';

  @override
  String get statePageTitle => 'Štáty';

  @override
  String get stateEmpty => 'Žiadne štáty';

  @override
  String get placePageTitle => 'Miesta';

  @override
  String get placeEmpty => 'Žiadne miesta';

  @override
  String get tagPageTitle => 'Značky';

  @override
  String get tagEmpty => 'Žiadne značky';

  @override
  String get binPageTitle => 'Kôš';

  @override
  String get explorerPageTitle => 'Prieskumník';

  @override
  String get explorerActionSelectStorageVolume => 'Vyberte skladovanie';

  @override
  String get selectStorageVolumeDialogTitle => 'Vyberte uloženie';

  @override
  String get searchCollectionFieldHint => 'Vyhľadávanie kolekcie';

  @override
  String get searchRecentSectionTitle => 'Nedávne';

  @override
  String get searchDateSectionTitle => 'Dátum';

  @override
  String get searchFormatSectionTitle => 'Formats';

  @override
  String get searchAlbumsSectionTitle => 'Albumy';

  @override
  String get searchCountriesSectionTitle => 'Krajiny';

  @override
  String get searchStatesSectionTitle => 'Štáty';

  @override
  String get searchPlacesSectionTitle => 'Miesta';

  @override
  String get searchTagsSectionTitle => 'Značky';

  @override
  String get searchRatingSectionTitle => 'Hodnotenia';

  @override
  String get searchMetadataSectionTitle => 'Metadáta';

  @override
  String get settingsPageTitle => 'Nastavenia';

  @override
  String get settingsSystemDefault => 'Predvolené';

  @override
  String get settingsDefault => 'Predvolené';

  @override
  String get settingsDisabled => 'Zakázané';

  @override
  String get settingsAskEverytime => 'Vždy sa spýtať';

  @override
  String get settingsModificationWarningDialogMessage => 'Ostatné nastavenia budú modifikované.';

  @override
  String get settingsSearchFieldLabel => 'Nastavenia vyhľadávania';

  @override
  String get settingsSearchEmpty => 'Žiadne vyhovujúce nastavenia';

  @override
  String get settingsActionExport => 'Exportovať';

  @override
  String get settingsActionExportDialogTitle => 'Exportovať';

  @override
  String get settingsActionImport => 'Importovať';

  @override
  String get settingsActionImportDialogTitle => 'Importovať';

  @override
  String get appExportCovers => 'Obaly';

  @override
  String get appExportDynamicAlbums => 'Dynamické albumy';

  @override
  String get appExportFavourites => 'Obľúbené';

  @override
  String get appExportSettings => 'Nastavenia';

  @override
  String get settingsNavigationSectionTitle => 'Navigácia';

  @override
  String get settingsHomeTile => 'Domov';

  @override
  String get settingsHomeDialogTitle => 'Domov';

  @override
  String get setHomeCustom => 'Vlastné';

  @override
  String get settingsShowBottomNavigationBar => 'Zobraziť navigačnú lištu na spodku';

  @override
  String get settingsKeepScreenOnTile => 'Nevypínať obrazovku';

  @override
  String get settingsKeepScreenOnDialogTitle => 'Nevypínať obrazovku';

  @override
  String get settingsDoubleBackExit => 'Stlač krok späť 2 krát pre opustenie aplikácie';

  @override
  String get settingsConfirmationTile => 'Potvrdzujúce dialógy';

  @override
  String get settingsConfirmationDialogTitle => 'Potvrdzujúce dialógy';

  @override
  String get settingsConfirmationBeforeDeleteItems => 'Spýtať sa pred odstránením';

  @override
  String get settingsConfirmationBeforeMoveToBinItems => 'Spýtať sa pred presunom do koša';

  @override
  String get settingsConfirmationBeforeMoveUndatedItems => 'Spýtať sa pred presunom položiek bez dátumu';

  @override
  String get settingsConfirmationAfterMoveToBinItems => 'Zobraziť správu po presune položiek do koša';

  @override
  String get settingsConfirmationVaultDataLoss => 'Zobrazenie upozornenia na stratu údajov trezora';

  @override
  String get settingsNavigationDrawerTile => 'Navigačné menu';

  @override
  String get settingsNavigationDrawerEditorPageTitle => 'Navigačné menu';

  @override
  String get settingsNavigationDrawerBanner => 'Dotknite sa a podržte, ak chcete presúvať a meniť poradie položiek ponuky.';

  @override
  String get settingsNavigationDrawerTabTypes => 'Typy';

  @override
  String get settingsNavigationDrawerTabAlbums => 'Albumy';

  @override
  String get settingsNavigationDrawerTabPages => 'Stránky';

  @override
  String get settingsNavigationDrawerAddAlbum => 'Pridať album';

  @override
  String get settingsThumbnailSectionTitle => 'Miniatúry';

  @override
  String get settingsThumbnailOverlayTile => 'Prekrytie';

  @override
  String get settingsThumbnailOverlayPageTitle => 'Prekrytie';

  @override
  String get settingsThumbnailShowHdrIcon => 'Zobraziť ikonu HDR';

  @override
  String get settingsThumbnailShowFavouriteIcon => 'Zobraziť obľúbenú ikonu';

  @override
  String get settingsThumbnailShowTagIcon => 'Zobraziť ikonu značky';

  @override
  String get settingsThumbnailShowLocationIcon => 'Zobraziť ikonu pozície';

  @override
  String get settingsThumbnailShowMotionPhotoIcon => 'Zobraziť ikonu pohybujúcich sa fotiek';

  @override
  String get settingsThumbnailShowRating => 'Zobraziť hodnotenie';

  @override
  String get settingsThumbnailShowRawIcon => 'Zobraziť raw ikonu';

  @override
  String get settingsThumbnailShowVideoDuration => 'Zobraziť dĺžku videa';

  @override
  String get settingsCollectionQuickActionsTile => 'Rýchle akcie';

  @override
  String get settingsCollectionQuickActionEditorPageTitle => 'Rýchle akcie';

  @override
  String get settingsCollectionQuickActionTabBrowsing => 'Prehliadanie';

  @override
  String get settingsCollectionQuickActionTabSelecting => 'Výber';

  @override
  String get settingsCollectionBrowsingQuickActionEditorBanner => 'Dotykom a podržaním môžete presúvať tlačidlá a vyberať akcie, ktoré sa zobrazia pri prehľadávaní položiek.';

  @override
  String get settingsCollectionSelectionQuickActionEditorBanner => 'Dotykom a podržaním môžete presúvať tlačidlá a vybrať, ktoré akcie sa zobrazia pri výbere položiek.';

  @override
  String get settingsCollectionBurstPatternsTile => 'Vzory dávkového snímania';

  @override
  String get settingsCollectionBurstPatternsNone => 'Žiadny';

  @override
  String get settingsViewerSectionTitle => 'Prehliadač';

  @override
  String get settingsViewerGestureSideTapNext => 'Ťuknutím na okraje obrazovky zobrazíte predchádzajúcu/nasledujúcu položku';

  @override
  String get settingsViewerUseCutout => 'Použitie oblasti výrezu';

  @override
  String get settingsViewerMaximumBrightness => 'Maximálny jas';

  @override
  String get settingsMotionPhotoAutoPlay => 'Automaticky prehrať pohyblivé fotografie';

  @override
  String get settingsImageBackground => 'Obrazové pozadie';

  @override
  String get settingsViewerQuickActionsTile => 'Rýchle akcie';

  @override
  String get settingsViewerQuickActionEditorPageTitle => 'Rýchle akcie';

  @override
  String get settingsViewerQuickActionEditorBanner => 'Dotknite sa tlačidiel a podržte ich, aby ste ich presunuli a vybrali akcie, ktoré sa zobrazia v prehliadači.';

  @override
  String get settingsViewerQuickActionEditorDisplayedButtonsSectionTitle => 'Zobrazené tlačidlá';

  @override
  String get settingsViewerQuickActionEditorAvailableButtonsSectionTitle => 'Dostupné tlačidlá';

  @override
  String get settingsViewerQuickActionEmpty => 'Žiadne tlačidlá';

  @override
  String get settingsViewerOverlayTile => 'Prekrytie';

  @override
  String get settingsViewerOverlayPageTitle => 'Prekrytie';

  @override
  String get settingsViewerShowOverlayOnOpening => 'Zobraziť pri otvorení';

  @override
  String get settingsViewerShowHistogram => 'Zobraziť histogram';

  @override
  String get settingsViewerShowMinimap => 'Zobraziť minimapu';

  @override
  String get settingsViewerShowInformation => 'Zobraziť informácie';

  @override
  String get settingsViewerShowInformationSubtitle => 'Zobraziť nadpis, dátum, miesto, atď.';

  @override
  String get settingsViewerShowRatingTags => 'Zobraziť hodnotenie a štítky';

  @override
  String get settingsViewerShowShootingDetails => 'Zobraziť podrobnosti o snímaní';

  @override
  String get settingsViewerShowDescription => 'Zobraziť popis';

  @override
  String get settingsViewerShowOverlayThumbnails => 'Zobraziť miniatúry';

  @override
  String get settingsViewerEnableOverlayBlurEffect => 'Efekt rozmazania';

  @override
  String get settingsViewerSlideshowTile => 'Prezentácia';

  @override
  String get settingsViewerSlideshowPageTitle => 'Prezentácia';

  @override
  String get settingsSlideshowRepeat => 'Opakovať';

  @override
  String get settingsSlideshowShuffle => 'Náhodný výber';

  @override
  String get settingsSlideshowFillScreen => 'Vyplnenie obrazovky';

  @override
  String get settingsSlideshowAnimatedZoomEffect => 'Animovaný efekt priblíženia';

  @override
  String get settingsSlideshowTransitionTile => 'Prechod';

  @override
  String get settingsSlideshowIntervalTile => 'Interval';

  @override
  String get settingsSlideshowVideoPlaybackTile => 'Prehrávanie videa';

  @override
  String get settingsSlideshowVideoPlaybackDialogTitle => 'Prehrávanie videa';

  @override
  String get settingsVideoPageTitle => 'Nastavenia videa';

  @override
  String get settingsVideoSectionTitle => 'Video';

  @override
  String get settingsVideoShowVideos => 'Zobraziť videá';

  @override
  String get settingsVideoPlaybackTile => 'Prehrávanie';

  @override
  String get settingsVideoPlaybackPageTitle => 'Prehrávanie';

  @override
  String get settingsVideoEnableHardwareAcceleration => 'Hardvérová akcelerácia';

  @override
  String get settingsVideoAutoPlay => 'Automatické prehrávanie';

  @override
  String get settingsVideoLoopModeTile => 'Režim slučky';

  @override
  String get settingsVideoLoopModeDialogTitle => 'Režim slučky';

  @override
  String get settingsVideoResumptionModeTile => 'Pokračovanie prehrávania';

  @override
  String get settingsVideoResumptionModeDialogTitle => 'Pokračovanie prehrávania';

  @override
  String get settingsVideoBackgroundMode => 'Režim na pozadí';

  @override
  String get settingsVideoBackgroundModeDialogTitle => 'Režim na pozadí';

  @override
  String get settingsVideoControlsTile => 'Ovládacie prvky';

  @override
  String get settingsVideoControlsPageTitle => 'Ovládacie prvky';

  @override
  String get settingsVideoButtonsTile => 'Tlačidlá';

  @override
  String get settingsVideoGestureDoubleTapTogglePlay => 'Dvojitým ťuknutím spustíte prehrávanie/pozastavenie';

  @override
  String get settingsVideoGestureSideDoubleTapSeek => 'Dvojitým ťuknutím na okraje obrazovky môžete hľadať dozadu/dopredu';

  @override
  String get settingsVideoGestureVerticalDragBrightnessVolume => 'Potiahnutím nahor alebo nadol upravíte jas/hlasitosť';

  @override
  String get settingsSubtitleThemeTile => 'Titulky';

  @override
  String get settingsSubtitleThemePageTitle => 'Titulky';

  @override
  String get settingsSubtitleThemeSample => 'Toto je ukážka.';

  @override
  String get settingsSubtitleThemeTextAlignmentTile => 'Zarovnanie textu';

  @override
  String get settingsSubtitleThemeTextAlignmentDialogTitle => 'Zarovnanie textu';

  @override
  String get settingsSubtitleThemeTextPositionTile => 'Pozícia textu';

  @override
  String get settingsSubtitleThemeTextPositionDialogTitle => 'Pozícia textu';

  @override
  String get settingsSubtitleThemeTextSize => 'Veľkosť textu';

  @override
  String get settingsSubtitleThemeShowOutline => 'Zobrazenie obrysu a tieňa';

  @override
  String get settingsSubtitleThemeTextColor => 'Farba textu';

  @override
  String get settingsSubtitleThemeTextOpacity => 'Ne/priehľadnosť textu';

  @override
  String get settingsSubtitleThemeBackgroundColor => 'Farba pozadia';

  @override
  String get settingsSubtitleThemeBackgroundOpacity => 'Ne/priehľadnosť pozadia';

  @override
  String get settingsSubtitleThemeTextAlignmentLeft => 'Vľavo';

  @override
  String get settingsSubtitleThemeTextAlignmentCenter => 'V strede';

  @override
  String get settingsSubtitleThemeTextAlignmentRight => 'Vpravo';

  @override
  String get settingsPrivacySectionTitle => 'Súkromie';

  @override
  String get settingsAllowInstalledAppAccess => 'Povolenie prístupu k inventáru aplikácií';

  @override
  String get settingsAllowInstalledAppAccessSubtitle => 'Slúži na zlepšenie zobrazenia albumu';

  @override
  String get settingsAllowErrorReporting => 'Povolenie anonymného hlásenia chýb';

  @override
  String get settingsSaveSearchHistory => 'Uložiť históriu vyhľadávania';

  @override
  String get settingsEnableBin => 'Používanie odpadkového koša';

  @override
  String get settingsEnableBinSubtitle => 'Uchovávanie vymazaných položiek po dobu 30 dní';

  @override
  String get settingsDisablingBinWarningDialogMessage => 'Položky v koši budú navždy vymazané.';

  @override
  String get settingsAllowMediaManagement => 'Umožniť správu médií';

  @override
  String get settingsHiddenItemsTile => 'Skryté položky';

  @override
  String get settingsHiddenItemsPageTitle => 'Skryté položky';

  @override
  String get settingsHiddenFiltersBanner => 'Fotografie a videá zodpovedajúce skrytým filtrom sa nezobrazia vo vašej zbierke.';

  @override
  String get settingsHiddenFiltersEmpty => 'Žiadne skryté filtre';

  @override
  String get settingsStorageAccessTile => 'Prístup k úložisku';

  @override
  String get settingsStorageAccessPageTitle => 'Prístup k úložisku';

  @override
  String get settingsStorageAccessBanner => 'Niektoré adresáre vyžadujú explicitné udelenie prístupu na úpravu súborov v nich. Tu si môžete prezrieť adresáre, ku ktorým ste predtým udelili prístup.';

  @override
  String get settingsStorageAccessEmpty => 'Žiadne povolené prístupy';

  @override
  String get settingsStorageAccessRevokeTooltip => 'Odvolať';

  @override
  String get settingsAccessibilitySectionTitle => 'Prístupnosť';

  @override
  String get settingsRemoveAnimationsTile => 'Odstránenie animácií';

  @override
  String get settingsRemoveAnimationsDialogTitle => 'Odstránenie animácií';

  @override
  String get settingsTimeToTakeActionTile => 'Čas na vykonanie akcie';

  @override
  String get settingsAccessibilityShowPinchGestureAlternatives => 'Zobrazenie alternatív viacdotykových gest';

  @override
  String get settingsDisplaySectionTitle => 'Displej';

  @override
  String get settingsThemeBrightnessTile => 'Téma';

  @override
  String get settingsThemeBrightnessDialogTitle => 'Téma';

  @override
  String get settingsThemeColorHighlights => 'Farebné zvýraznenia';

  @override
  String get settingsThemeEnableDynamicColor => 'Dynamická farba';

  @override
  String get settingsDisplayRefreshRateModeTile => 'Obnovovacia frekvencia displeja';

  @override
  String get settingsDisplayRefreshRateModeDialogTitle => 'Obnovovacia frekvencia';

  @override
  String get settingsDisplayUseTvInterface => 'Rozhranie systému Android TV';

  @override
  String get settingsLanguageSectionTitle => 'Jazyk a formáty';

  @override
  String get settingsLanguageTile => 'Jazyk';

  @override
  String get settingsLanguagePageTitle => 'Jazyk';

  @override
  String get settingsCoordinateFormatTile => 'Formát súradníc';

  @override
  String get settingsCoordinateFormatDialogTitle => 'Formát súradníc';

  @override
  String get settingsUnitSystemTile => 'Jednotky';

  @override
  String get settingsUnitSystemDialogTitle => 'Jednotky';

  @override
  String get settingsForceWesternArabicNumeralsTile => 'Vynútiť arabské číslice';

  @override
  String get settingsScreenSaverPageTitle => 'Šetrič obrazovky';

  @override
  String get settingsWidgetPageTitle => 'Fotorámik';

  @override
  String get settingsWidgetShowOutline => 'Obrys';

  @override
  String get settingsWidgetOpenPage => 'Keď ťuknete na miniaplikáciu';

  @override
  String get settingsWidgetDisplayedItem => 'Zobrazená položka';

  @override
  String get settingsCollectionTile => 'Kolekcia';

  @override
  String get statsPageTitle => 'Štatistiky';

  @override
  String statsWithGps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count položiek s polohami',
      one: '1 položka s polohou',
    );
    return '$_temp0';
  }

  @override
  String get statsTopCountriesSectionTitle => 'Najlepšie krajiny';

  @override
  String get statsTopStatesSectionTitle => 'Najlepšie Štáty';

  @override
  String get statsTopPlacesSectionTitle => 'Najlepšie miesta';

  @override
  String get statsTopTagsSectionTitle => 'Najlepšie značky';

  @override
  String get statsTopAlbumsSectionTitle => 'Najlepšie albumy';

  @override
  String get viewerOpenPanoramaButtonLabel => 'OTVORIŤ PANORÁMU';

  @override
  String get viewerSetWallpaperButtonLabel => 'NASTAVIŤ POZADIE';

  @override
  String get viewerErrorUnknown => 'Ups!';

  @override
  String get viewerErrorDoesNotExist => 'Súbor už neexistuje.';

  @override
  String get viewerInfoPageTitle => 'Informácie';

  @override
  String get viewerInfoBackToViewerTooltip => 'Späť na prehliadač';

  @override
  String get viewerInfoUnknown => 'neznáme';

  @override
  String get viewerInfoLabelDescription => 'Popis';

  @override
  String get viewerInfoLabelTitle => 'Nadpis';

  @override
  String get viewerInfoLabelDate => 'Dátum';

  @override
  String get viewerInfoLabelResolution => 'Rozlíšenie';

  @override
  String get viewerInfoLabelSize => 'Veľkosť';

  @override
  String get viewerInfoLabelUri => 'URI';

  @override
  String get viewerInfoLabelPath => 'Cesta';

  @override
  String get viewerInfoLabelDuration => 'Trvanie';

  @override
  String get viewerInfoLabelOwner => 'Vlastník';

  @override
  String get viewerInfoLabelCoordinates => 'Súradnice';

  @override
  String get viewerInfoLabelAddress => 'Adresa';

  @override
  String get mapStyleDialogTitle => 'Štýl mapy';

  @override
  String get mapStyleTooltip => 'Vybrať štýl mapy';

  @override
  String get mapZoomInTooltip => 'Priblížiť';

  @override
  String get mapZoomOutTooltip => 'Oddialiť';

  @override
  String get mapPointNorthUpTooltip => 'Nastaviť sever nahor';

  @override
  String get mapAttributionOsmData => 'Údaje máp © [OpenStreetMap](https://www.openstreetmap.org/copyright) prispievatelia';

  @override
  String get mapAttributionOsmLiberty => 'Dlaždice podľa [OpenMapTiles](https://www.openmaptiles.org/), [CC BY](http://creativecommons.org/licenses/by/4.0) • Hostovaný [OSM Americana](https://tile.ourmap.us)';

  @override
  String get mapAttributionOpenTopoMap => '[SRTM](https://www.earthdata.nasa.gov/sensors/srtm) Dlaždice podľa [OpenTopoMap](https://opentopomap.org/), [CC BY-SA](https://creativecommons.org/licenses/by-sa/3.0/)';

  @override
  String get mapAttributionOsmHot => '[HOT](https://www.hotosm.org/) • Hosťuje [OSM France](https://openstreetmap.fr/)';

  @override
  String get mapAttributionStamen => '[Stamen Design](https://stamen.com), [CC BY 3.0](https://creativecommons.org/licenses/by/3.0)';

  @override
  String get openMapPageTooltip => 'Zobraziť na stránke mapy';

  @override
  String get mapEmptyRegion => 'Žiadne obrázky v tejto oblasti';

  @override
  String get viewerInfoOpenEmbeddedFailureFeedback => 'Nepodarilo sa extrahovať vložené údaje';

  @override
  String get viewerInfoOpenLinkText => 'Otvoriť';

  @override
  String get viewerInfoViewXmlLinkText => 'Zobraziť XML';

  @override
  String get viewerInfoSearchFieldLabel => 'Prehľadávať metadáta';

  @override
  String get viewerInfoSearchEmpty => 'Žiadne zodpovedajúce kľúče';

  @override
  String get viewerInfoSearchSuggestionDate => 'Dátum a čas';

  @override
  String get viewerInfoSearchSuggestionDescription => 'Popis';

  @override
  String get viewerInfoSearchSuggestionDimensions => 'Rozmery';

  @override
  String get viewerInfoSearchSuggestionResolution => 'Rozlíšenie';

  @override
  String get viewerInfoSearchSuggestionRights => 'Práva';

  @override
  String get wallpaperUseScrollEffect => 'Používanie efektu posúvania na domovskej obrazovke';

  @override
  String get tagEditorPageTitle => 'Upraviť štítky';

  @override
  String get tagEditorPageNewTagFieldLabel => 'Nový štítok';

  @override
  String get tagEditorPageAddTagTooltip => 'Pridať štítok';

  @override
  String get tagEditorSectionRecent => 'Nedávne';

  @override
  String get tagEditorSectionPlaceholders => 'Zástupcovia';

  @override
  String get tagEditorDiscardDialogMessage => 'Naozaj chceš zrušiť zmeny?';

  @override
  String get tagPlaceholderCountry => 'Krajina';

  @override
  String get tagPlaceholderState => 'Štát';

  @override
  String get tagPlaceholderPlace => 'Miesto';

  @override
  String get panoramaEnableSensorControl => 'Povoliť senzory';

  @override
  String get panoramaDisableSensorControl => 'Zakázať senzory';

  @override
  String get sourceViewerPageTitle => 'Zdroj';
}
