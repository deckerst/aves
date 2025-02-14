// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hungarian (`hu`).
class AppLocalizationsHu extends AppLocalizations {
  AppLocalizationsHu([String locale = 'hu']) : super(locale);

  @override
  String get appName => 'Aves';

  @override
  String get welcomeMessage => 'Üdvözöl az Aves';

  @override
  String get welcomeOptional => 'Nem kötelező';

  @override
  String get welcomeTermsToggle => 'Elfogadom a felhasználási feltételeket';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elem',
    );
    return '$_temp0';
  }

  @override
  String columnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count oszlop',
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
      other: '$countString másodperc',
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
      other: '$countString perc',
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
      other: '$countString nap',
    );
    return '$_temp0';
  }

  @override
  String focalLength(String length) {
    return '$length mm';
  }

  @override
  String get applyButtonLabel => 'ALKALMAZ';

  @override
  String get deleteButtonLabel => 'TÖRLÉS';

  @override
  String get nextButtonLabel => 'KÖVETKEZŐ';

  @override
  String get showButtonLabel => 'MUTAT';

  @override
  String get hideButtonLabel => 'ELREJTÉS';

  @override
  String get continueButtonLabel => 'FOLYTAT';

  @override
  String get saveCopyButtonLabel => 'MÁSOLAT MENTÉSE';

  @override
  String get applyTooltip => 'Alkalmaz';

  @override
  String get cancelTooltip => 'Mégse';

  @override
  String get changeTooltip => 'Változtat';

  @override
  String get clearTooltip => 'Töröl';

  @override
  String get previousTooltip => 'Előző';

  @override
  String get nextTooltip => 'Következő';

  @override
  String get showTooltip => 'Megjelenítés';

  @override
  String get hideTooltip => 'Elrejtés';

  @override
  String get actionRemove => 'Eltávolítás';

  @override
  String get resetTooltip => 'Visszaállít';

  @override
  String get saveTooltip => 'Mentés';

  @override
  String get stopTooltip => 'Állj';

  @override
  String get pickTooltip => 'Kiválaszt';

  @override
  String get doubleBackExitMessage => 'Nyomd meg a „visszát” még egyszer a kilépéshez.';

  @override
  String get doNotAskAgain => 'Ne kérdezd újra';

  @override
  String get sourceStateLoading => 'Betöltés';

  @override
  String get sourceStateCataloguing => 'Katalógus';

  @override
  String get sourceStateLocatingCountries => 'Országok meghatározása';

  @override
  String get sourceStateLocatingPlaces => 'Helyek meghatározása';

  @override
  String get chipActionDelete => 'Törlés';

  @override
  String get chipActionRemove => 'Eltávolítás';

  @override
  String get chipActionShowCollection => 'Megjelenítés a gyűjteményekben';

  @override
  String get chipActionGoToAlbumPage => 'Megjelenítés az albumokban';

  @override
  String get chipActionGoToCountryPage => 'Megjelenítés az országokban';

  @override
  String get chipActionGoToPlacePage => 'Megjelenítés a helyekben';

  @override
  String get chipActionGoToTagPage => 'Megjelenítés a címkékben';

  @override
  String get chipActionGoToExplorerPage => 'Mutatás a böngészőben';

  @override
  String get chipActionDecompose => 'Felosztás';

  @override
  String get chipActionFilterOut => 'Nem tartalmazza';

  @override
  String get chipActionFilterIn => 'Tartalmazza';

  @override
  String get chipActionHide => 'Elrejtés';

  @override
  String get chipActionLock => 'Zárolás';

  @override
  String get chipActionPin => 'Kitűzés felülre';

  @override
  String get chipActionUnpin => 'Kitűzés megszüntetése';

  @override
  String get chipActionRename => 'Átnevezés';

  @override
  String get chipActionSetCover => 'Borító beállítása';

  @override
  String get chipActionShowCountryStates => 'Megyék megjelenítése';

  @override
  String get chipActionCreateAlbum => 'Új album';

  @override
  String get chipActionCreateVault => 'Széf készítése';

  @override
  String get chipActionConfigureVault => 'Széf beállítása';

  @override
  String get entryActionCopyToClipboard => 'Vágolapra másolás';

  @override
  String get entryActionDelete => 'Törlés';

  @override
  String get entryActionConvert => 'Átalakítás';

  @override
  String get entryActionExport => 'Exportálás';

  @override
  String get entryActionInfo => 'Infó';

  @override
  String get entryActionRename => 'Átnevezés';

  @override
  String get entryActionRestore => 'Visszaállítás';

  @override
  String get entryActionRotateCCW => 'Forgatás balra';

  @override
  String get entryActionRotateCW => 'Forgatás jobbra';

  @override
  String get entryActionFlip => 'Forgatás vízszintesen';

  @override
  String get entryActionPrint => 'Nyomtatás';

  @override
  String get entryActionShare => 'Megosztás';

  @override
  String get entryActionShareImageOnly => 'Csak kép megosztása';

  @override
  String get entryActionShareVideoOnly => 'Csak videó megosztása';

  @override
  String get entryActionViewSource => 'Forrás megtekintése';

  @override
  String get entryActionShowGeoTiffOnMap => 'Térképre helyezve';

  @override
  String get entryActionConvertMotionPhotoToStillImage => 'Átalakítás állóképpé';

  @override
  String get entryActionViewMotionPhotoVideo => 'Videó megnyitása';

  @override
  String get entryActionEdit => 'Szerkesztés';

  @override
  String get entryActionOpen => 'Megnyitás ezzel';

  @override
  String get entryActionSetAs => 'Beállit, mint';

  @override
  String get entryActionCast => 'Kivetítés';

  @override
  String get entryActionOpenMap => 'Megjelenítés térkép alkalmazásban';

  @override
  String get entryActionRotateScreen => 'Képernyő forgatása';

  @override
  String get entryActionAddFavourite => 'Kedvencekhez adás';

  @override
  String get entryActionRemoveFavourite => 'Eltávolítás a kedvencekből';

  @override
  String get videoActionCaptureFrame => 'Képkocka mentése';

  @override
  String get videoActionMute => 'Némítás';

  @override
  String get videoActionUnmute => 'Némítás feloldása';

  @override
  String get videoActionPause => 'Szünet';

  @override
  String get videoActionPlay => 'Lejátszás';

  @override
  String get videoActionReplay10 => 'Ugrás vissza 10 másodpercet';

  @override
  String get videoActionSkip10 => 'Ugrás előre 10 másodpercet';

  @override
  String get videoActionShowPreviousFrame => 'Előző képkocka mutatása';

  @override
  String get videoActionShowNextFrame => 'Következő képkocka mutatása';

  @override
  String get videoActionSelectStreams => 'Sávok kiválasztása';

  @override
  String get videoActionSetSpeed => 'Lejátszás sebessége';

  @override
  String get videoActionABRepeat => 'A-B ismétlés';

  @override
  String get videoRepeatActionSetStart => 'Kezdőpont beállítása';

  @override
  String get videoRepeatActionSetEnd => 'Végpont beállítása';

  @override
  String get viewerActionSettings => 'Beállítások';

  @override
  String get viewerActionLock => 'Megtekintő zárolása';

  @override
  String get viewerActionUnlock => 'Megtekintő feloldása';

  @override
  String get slideshowActionResume => 'Folytatás';

  @override
  String get slideshowActionShowInCollection => 'Megjelenítés a gyűjteményekben';

  @override
  String get entryInfoActionEditDate => 'Dátum és idő szerkesztése';

  @override
  String get entryInfoActionEditLocation => 'Hely szerkesztése';

  @override
  String get entryInfoActionEditTitleDescription => 'Cím és leírás szerkesztése';

  @override
  String get entryInfoActionEditRating => 'Értékelés szerkesztése';

  @override
  String get entryInfoActionEditTags => 'Címke szerkesztése';

  @override
  String get entryInfoActionRemoveMetadata => 'Metaadat eltávolítása';

  @override
  String get entryInfoActionExportMetadata => 'Metaadat exportálása';

  @override
  String get entryInfoActionRemoveLocation => 'Hely eltávolítása';

  @override
  String get editorActionTransform => 'Alakítás';

  @override
  String get editorTransformCrop => 'Vágás';

  @override
  String get editorTransformRotate => 'Forgatás';

  @override
  String get cropAspectRatioFree => 'Kötetlen';

  @override
  String get cropAspectRatioOriginal => 'Eredeti';

  @override
  String get cropAspectRatioSquare => 'Négyzet';

  @override
  String get filterAspectRatioLandscapeLabel => 'Fekvő';

  @override
  String get filterAspectRatioPortraitLabel => 'Álló';

  @override
  String get filterBinLabel => 'Kuka';

  @override
  String get filterFavouriteLabel => 'Kedvenc';

  @override
  String get filterNoDateLabel => 'Nincs dátum';

  @override
  String get filterNoAddressLabel => 'Nincs cím';

  @override
  String get filterLocatedLabel => 'Hely információval rendelkezők';

  @override
  String get filterNoLocationLabel => 'Hely információ nélküliek';

  @override
  String get filterNoRatingLabel => 'Nincs értékelés';

  @override
  String get filterTaggedLabel => 'Cimkézett';

  @override
  String get filterNoTagLabel => 'Cimkézetlen';

  @override
  String get filterNoTitleLabel => 'Névtelen';

  @override
  String get filterOnThisDayLabel => 'Ezen a napon';

  @override
  String get filterRecentlyAddedLabel => 'Nemrég hozzáadva';

  @override
  String get filterRatingRejectedLabel => 'Elutasított';

  @override
  String get filterTypeAnimatedLabel => 'Animált';

  @override
  String get filterTypeMotionPhotoLabel => 'Mozgó fotók';

  @override
  String get filterTypePanoramaLabel => 'Panoráma';

  @override
  String get filterTypeRawLabel => 'Raw';

  @override
  String get filterTypeSphericalVideoLabel => '360° videó';

  @override
  String get filterTypeGeotiffLabel => 'GeoTIFF';

  @override
  String get filterMimeImageLabel => 'Kép';

  @override
  String get filterMimeVideoLabel => 'Videó';

  @override
  String get accessibilityAnimationsRemove => 'Animációk mellőzése';

  @override
  String get accessibilityAnimationsKeep => 'Animációk megtartása';

  @override
  String get albumTierNew => 'Új';

  @override
  String get albumTierPinned => 'Kitűzött';

  @override
  String get albumTierSpecial => 'Gyakori';

  @override
  String get albumTierApps => 'Alkalmazások';

  @override
  String get albumTierVaults => 'Széfek';

  @override
  String get albumTierDynamic => 'Dinamikus';

  @override
  String get albumTierRegular => 'Egyebek';

  @override
  String get coordinateFormatDms => 'DMS';

  @override
  String get coordinateFormatDdm => 'DDM';

  @override
  String get coordinateFormatDecimal => 'Tizedes fokok';

  @override
  String coordinateDms(String coordinate, String direction) {
    return '$coordinate $direction';
  }

  @override
  String get coordinateDmsNorth => 'É';

  @override
  String get coordinateDmsSouth => 'D';

  @override
  String get coordinateDmsEast => 'K';

  @override
  String get coordinateDmsWest => 'Ny';

  @override
  String get displayRefreshRatePreferHighest => 'Legmagasabb érték';

  @override
  String get displayRefreshRatePreferLowest => 'Legalacsonyabb érték';

  @override
  String get keepScreenOnNever => 'Soha';

  @override
  String get keepScreenOnVideoPlayback => 'Videólejátszás alatt';

  @override
  String get keepScreenOnViewerOnly => 'Csak a megtekintőnél';

  @override
  String get keepScreenOnAlways => 'Mindig';

  @override
  String get lengthUnitPixel => 'px';

  @override
  String get lengthUnitPercent => '%';

  @override
  String get mapStyleGoogleNormal => 'Google térkép';

  @override
  String get mapStyleGoogleHybrid => 'Google térkép (Hibrid)';

  @override
  String get mapStyleGoogleTerrain => 'Google térkép (Domborzat)';

  @override
  String get mapStyleOsmLiberty => 'OSM Liberty';

  @override
  String get mapStyleOpenTopoMap => 'OpenTopoMap';

  @override
  String get mapStyleOsmHot => 'Humanitarian OSM';

  @override
  String get mapStyleStamenWatercolor => 'Stamen Akvarell';

  @override
  String get maxBrightnessNever => 'Soha';

  @override
  String get maxBrightnessAlways => 'Mindig';

  @override
  String get nameConflictStrategyRename => 'Átnevezés';

  @override
  String get nameConflictStrategyReplace => 'Kicserél';

  @override
  String get nameConflictStrategySkip => 'Átugrik';

  @override
  String get overlayHistogramNone => 'Nincs';

  @override
  String get overlayHistogramRGB => 'RGB';

  @override
  String get overlayHistogramLuminance => 'Fényerő';

  @override
  String get subtitlePositionTop => 'Felül';

  @override
  String get subtitlePositionBottom => 'Alul';

  @override
  String get themeBrightnessLight => 'Világos';

  @override
  String get themeBrightnessDark => 'Sötét';

  @override
  String get themeBrightnessBlack => 'Fekete';

  @override
  String get unitSystemMetric => 'Metrikus';

  @override
  String get unitSystemImperial => 'Angolszász';

  @override
  String get vaultLockTypePattern => 'Minta';

  @override
  String get vaultLockTypePin => 'PIN';

  @override
  String get vaultLockTypePassword => 'Jelszó';

  @override
  String get settingsVideoEnablePip => 'Kép a képben';

  @override
  String get videoControlsPlayOutside => 'Megnyitás másik lejátszóval';

  @override
  String get videoLoopModeNever => 'Soha';

  @override
  String get videoLoopModeShortOnly => 'Csak rövid videók';

  @override
  String get videoLoopModeAlways => 'Mindig';

  @override
  String get videoPlaybackSkip => 'Átugrik';

  @override
  String get videoPlaybackMuted => 'Lejátszás némítva';

  @override
  String get videoPlaybackWithSound => 'Lejátszás hanggal';

  @override
  String get videoResumptionModeNever => 'Soha';

  @override
  String get videoResumptionModeAlways => 'Mindig';

  @override
  String get viewerTransitionSlide => 'Csúsztatás';

  @override
  String get viewerTransitionParallax => 'Parallaxis';

  @override
  String get viewerTransitionFade => 'Áttünés';

  @override
  String get viewerTransitionZoomIn => 'Nagyítás';

  @override
  String get viewerTransitionNone => 'Nincs';

  @override
  String get wallpaperTargetHome => 'Kezdőképernyő';

  @override
  String get wallpaperTargetLock => 'Lezárási képernyő';

  @override
  String get wallpaperTargetHomeLock => 'Kezdő és lezárási képernyő';

  @override
  String get widgetDisplayedItemRandom => 'Véletlenszerű';

  @override
  String get widgetDisplayedItemMostRecent => 'Legutóbbi';

  @override
  String get widgetOpenPageHome => 'Kezdőlap megnyitása';

  @override
  String get widgetOpenPageCollection => 'Gyűjtemény megnyitása';

  @override
  String get widgetOpenPageViewer => 'Megtekintő megnyitása';

  @override
  String get widgetTapUpdateWidget => 'Widget frissítése';

  @override
  String get storageVolumeDescriptionFallbackPrimary => 'Belső tárhely';

  @override
  String get storageVolumeDescriptionFallbackNonPrimary => 'SD kártya';

  @override
  String get rootDirectoryDescription => 'gyökér mappa';

  @override
  String otherDirectoryDescription(String name) {
    return '„$name” mappa';
  }

  @override
  String storageAccessDialogMessage(String directory, String volume) {
    return 'Válaszd ki a $directory mappát a „$volume” tárhelyen a következő képernyőn, hogy az Aves hozzáférjen.';
  }

  @override
  String restrictedAccessDialogMessage(String directory, String volume) {
    return 'Az Avesnek nincs engedélyezve, hogy módosításokat végezzen a $directory mappában a „$volume” tárhelyen.\n\nHasználd a telefon fájlkezelőjét vagy galériáját az elemek másik mappába helyezéséhez.';
  }

  @override
  String notEnoughSpaceDialogMessage(String neededSize, String freeSize, String volume) {
    return 'Ehhez a művelethez $neededSize szabad helyre van szükség itt: „$volume”, de csak $freeSize szabad.';
  }

  @override
  String get missingSystemFilePickerDialogMessage => 'A rendszer fájlkezelője hiányzik vagy letiltott. Engedélyezd és próbáld újra.';

  @override
  String unsupportedTypeDialogMessage(int count, String types) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ez a művelet nem támogatott a következő típusú elemeknél: $types.',
      one: 'Ez a művelet nem támogatott a következő típusú elemnél: $types.',
    );
    return '$_temp0';
  }

  @override
  String get nameConflictDialogSingleSourceMessage => 'Néhány fájl neve ugyanaz a cél mappában.';

  @override
  String get nameConflictDialogMultipleSourceMessage => 'Néhány fájl neve ugyanaz.';

  @override
  String get addShortcutDialogLabel => 'Parancsikon címke';

  @override
  String get addShortcutButtonLabel => 'HOZZÁAD';

  @override
  String get noMatchingAppDialogMessage => 'Nincs alkalmazás ami elboldogul ezzel.';

  @override
  String binEntriesConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Áthelyezed a $count elemet a kukába?',
      one: 'Áthelyezed a kukába?',
    );
    return '$_temp0';
  }

  @override
  String deleteEntriesConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Törlöd ezt a $count elemet?',
      one: 'Törlöd ezt az elemet?',
    );
    return '$_temp0';
  }

  @override
  String get moveUndatedConfirmationDialogMessage => 'Mented az elemek dátumait a végrehajtás előtt?';

  @override
  String get moveUndatedConfirmationDialogSetDate => 'Dátumok mentése';

  @override
  String videoResumeDialogMessage(String time) {
    return 'Folytatod a lejátszást innen: $time?';
  }

  @override
  String get videoStartOverButtonLabel => 'KEZDÉS ELÖLRŐL';

  @override
  String get videoResumeButtonLabel => 'FOLYTATÁS';

  @override
  String get setCoverDialogLatest => 'Legutóbbi elem';

  @override
  String get setCoverDialogAuto => 'Automatikus';

  @override
  String get setCoverDialogCustom => 'Egyéni';

  @override
  String get hideFilterConfirmationDialogMessage => 'Az egyező képek és videók el lesznek rejtve a gyűjteményedből. Újra megjelenítheted ezeket az „Adatvédelem” beállításokban.\n\nBiztosan el akarod rejteni őket?';

  @override
  String get newAlbumDialogTitle => 'Új album';

  @override
  String get newAlbumDialogNameLabel => 'Album neve';

  @override
  String get newAlbumDialogAlbumAlreadyExistsHelper => 'Az album már létezik';

  @override
  String get newAlbumDialogNameLabelAlreadyExistsHelper => 'A mappa már létezik';

  @override
  String get newAlbumDialogStorageLabel => 'Tárhely:';

  @override
  String get newDynamicAlbumDialogTitle => 'Új Dinamikus Album';

  @override
  String get dynamicAlbumAlreadyExists => 'A dinamikus album már létezik';

  @override
  String get newVaultWarningDialogMessage => 'A széfben lévő elemek csak ebben az alkalmazásban érhetőek el.\n\nHa eltávolítod az alkalmazást vagy törlöd az adatokat, ezeket az elemeket is elveszíted.';

  @override
  String get newVaultDialogTitle => 'Új széf';

  @override
  String get configureVaultDialogTitle => 'Széf konfigurálása';

  @override
  String get vaultDialogLockModeWhenScreenOff => 'Zárolás képernyő kikapcsoláskor';

  @override
  String get vaultDialogLockTypeLabel => 'Zárolás típusa';

  @override
  String get patternDialogEnter => 'Minta megadása';

  @override
  String get patternDialogConfirm => 'Minta megerősítése';

  @override
  String get pinDialogEnter => 'PIN megadása';

  @override
  String get pinDialogConfirm => 'PIN megerősítése';

  @override
  String get passwordDialogEnter => 'Jelszó megadása';

  @override
  String get passwordDialogConfirm => 'Jelszó megerősítése';

  @override
  String get authenticateToConfigureVault => 'Azonosítás a széf beállításához';

  @override
  String get authenticateToUnlockVault => 'Azonosítás a széf feloldásához';

  @override
  String get vaultBinUsageDialogMessage => 'Néhány széf használja a kukát.';

  @override
  String get renameAlbumDialogLabel => 'Új név';

  @override
  String get renameAlbumDialogLabelAlreadyExistsHelper => 'A mappa már létezik';

  @override
  String get renameEntrySetPageTitle => 'Átnevezés';

  @override
  String get renameEntrySetPagePatternFieldLabel => 'Elnevezési minta';

  @override
  String get renameEntrySetPageInsertTooltip => 'Mező beszúrása';

  @override
  String get renameEntrySetPagePreviewSectionTitle => 'Előnézet';

  @override
  String get renameProcessorCounter => 'Számláló';

  @override
  String get renameProcessorHash => 'Hash-kulcs';

  @override
  String get renameProcessorName => 'Név';

  @override
  String deleteSingleAlbumConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Törlöd ezt az albumot és a benne levő $count elemet?',
      one: 'Törlöd ezt az albumot és az egy elemet benne ?',
    );
    return '$_temp0';
  }

  @override
  String deleteMultiAlbumConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Törlöd ezt az albumot és a benne levő $count elemet?',
      one: 'Törlöd ezt az albumot és az egy elemet benne ?',
    );
    return '$_temp0';
  }

  @override
  String get exportEntryDialogFormat => 'Formátum:';

  @override
  String get exportEntryDialogWidth => 'Szélesség';

  @override
  String get exportEntryDialogHeight => 'Magasság';

  @override
  String get exportEntryDialogQuality => 'Minőség';

  @override
  String get exportEntryDialogWriteMetadata => 'Metaadat írása';

  @override
  String get renameEntryDialogLabel => 'Új név';

  @override
  String get editEntryDialogCopyFromItem => 'Másolás másik elemről';

  @override
  String get editEntryDialogTargetFieldsHeader => 'Módosítandó mezők';

  @override
  String get editEntryDateDialogTitle => 'Dátum és idő';

  @override
  String get editEntryDateDialogSetCustom => 'Egyéni dátum beállítása';

  @override
  String get editEntryDateDialogCopyField => 'Másolás másik dátumról';

  @override
  String get editEntryDateDialogExtractFromTitle => 'Kibontás a címből';

  @override
  String get editEntryDateDialogShift => 'Csúsztatás';

  @override
  String get editEntryDateDialogSourceFileModifiedDate => 'Fájl módosítás dátuma';

  @override
  String get durationDialogHours => 'Óra';

  @override
  String get durationDialogMinutes => 'Perc';

  @override
  String get durationDialogSeconds => 'Másodperc';

  @override
  String get editEntryLocationDialogTitle => 'Hely';

  @override
  String get editEntryLocationDialogSetCustom => 'Egyéni hely beállítása';

  @override
  String get editEntryLocationDialogChooseOnMap => 'Kijelölés térképen';

  @override
  String get editEntryLocationDialogImportGpx => 'GPX importálás';

  @override
  String get editEntryLocationDialogLatitude => 'Szélesség';

  @override
  String get editEntryLocationDialogLongitude => 'Hosszúság';

  @override
  String get editEntryLocationDialogTimeShift => 'Időeltolódás';

  @override
  String get locationPickerUseThisLocationButton => 'Használd ezt a helyet';

  @override
  String get editEntryRatingDialogTitle => 'Értékelés';

  @override
  String get removeEntryMetadataDialogTitle => 'Metaadat eltávolítása';

  @override
  String get removeEntryMetadataDialogAll => 'Összes';

  @override
  String get removeEntryMetadataDialogMore => 'Továbbiak';

  @override
  String get removeEntryMetadataMotionPhotoXmpWarningDialogMessage => 'Az XMP szükséges a mozgó fotókban lévő videó lejátszásához.\n\nBiztosan eltávolítod?';

  @override
  String get videoSpeedDialogLabel => 'Lejátszás sebessége';

  @override
  String get videoStreamSelectionDialogVideo => 'Videó';

  @override
  String get videoStreamSelectionDialogAudio => 'Audió';

  @override
  String get videoStreamSelectionDialogText => 'Feliratok';

  @override
  String get videoStreamSelectionDialogOff => 'Ki';

  @override
  String get videoStreamSelectionDialogTrack => 'Sáv';

  @override
  String get videoStreamSelectionDialogNoSelection => 'Nincsenek más sávok.';

  @override
  String get genericSuccessFeedback => 'Kész!';

  @override
  String get genericFailureFeedback => 'Sikertelen';

  @override
  String get genericDangerWarningDialogMessage => 'Biztos benne?';

  @override
  String get tooManyItemsErrorDialogMessage => 'Próbáld újra kevesebb elemmel.';

  @override
  String get menuActionConfigureView => 'Nézet';

  @override
  String get menuActionSelect => 'Kiválasztás';

  @override
  String get menuActionSelectAll => 'Összes kijelölése';

  @override
  String get menuActionSelectNone => 'Kijelölés megszüntetése';

  @override
  String get menuActionMap => 'Térkép';

  @override
  String get menuActionSlideshow => 'Diavetités';

  @override
  String get menuActionStats => 'Statisztikák';

  @override
  String get viewDialogSortSectionTitle => 'Rendezés';

  @override
  String get viewDialogGroupSectionTitle => 'Csoport';

  @override
  String get viewDialogLayoutSectionTitle => 'Elrendezés';

  @override
  String get viewDialogReverseSortOrder => 'Fordított sorrend';

  @override
  String get tileLayoutMosaic => 'Mozaik';

  @override
  String get tileLayoutGrid => 'Rács';

  @override
  String get tileLayoutList => 'Lista';

  @override
  String get castDialogTitle => 'Kivetítő eszközök';

  @override
  String get coverDialogTabCover => 'Borító';

  @override
  String get coverDialogTabApp => 'Alkalmazás';

  @override
  String get coverDialogTabColor => 'Szín';

  @override
  String get appPickDialogTitle => 'Alkalmazás választása';

  @override
  String get appPickDialogNone => 'Nincs';

  @override
  String get aboutPageTitle => 'Névjegy';

  @override
  String get aboutLinkLicense => 'Licensz';

  @override
  String get aboutLinkPolicy => 'Adatvédelmi irányelvek';

  @override
  String get aboutBugSectionTitle => 'Hibajelentés';

  @override
  String get aboutBugSaveLogInstruction => 'Naplófájlok mentése';

  @override
  String get aboutBugCopyInfoInstruction => 'Rendszer információ másolása';

  @override
  String get aboutBugCopyInfoButton => 'Másolás';

  @override
  String get aboutBugReportInstruction => 'Jelentés GitHub-on naplófájlokkal és rendszer információval';

  @override
  String get aboutBugReportButton => 'Jelentés';

  @override
  String get aboutDataUsageSectionTitle => 'Adatforgalom';

  @override
  String get aboutDataUsageData => 'Adat';

  @override
  String get aboutDataUsageCache => 'Gyorsítótár';

  @override
  String get aboutDataUsageDatabase => 'Adatbázis';

  @override
  String get aboutDataUsageMisc => 'Egyéb';

  @override
  String get aboutDataUsageInternal => 'Belső';

  @override
  String get aboutDataUsageExternal => 'Külső';

  @override
  String get aboutDataUsageClearCache => 'Gyorsítótár törlése';

  @override
  String get aboutCreditsSectionTitle => 'Készítők';

  @override
  String get aboutCreditsWorldAtlas1 => 'Ez az app egy TopoJSON fájlt használ';

  @override
  String get aboutCreditsWorldAtlas2 => 'oldalról ISC Licenccel.';

  @override
  String get aboutTranslatorsSectionTitle => 'Fordítók';

  @override
  String get aboutLicensesSectionTitle => 'Nyílt forrású licenszek';

  @override
  String get aboutLicensesBanner => 'Használt nyílt forrású csomagok és könyvtárak.';

  @override
  String get aboutLicensesAndroidLibrariesSectionTitle => 'Android könyvtárak';

  @override
  String get aboutLicensesFlutterPluginsSectionTitle => 'Flutter beépülők';

  @override
  String get aboutLicensesFlutterPackagesSectionTitle => 'Flutter csomagok';

  @override
  String get aboutLicensesDartPackagesSectionTitle => 'Dart csomagok';

  @override
  String get aboutLicensesShowAllButtonLabel => 'Minden licensz megjelenítése';

  @override
  String get policyPageTitle => 'Adatvédelmi irányelvek';

  @override
  String get collectionPageTitle => 'Gyűjtemény';

  @override
  String get collectionPickPageTitle => 'Választ';

  @override
  String get collectionSelectPageTitle => 'Elemek kiválasztása';

  @override
  String get collectionActionShowTitleSearch => 'Cím szűrő mutatása';

  @override
  String get collectionActionHideTitleSearch => 'Cím szűrő elrejtése';

  @override
  String get collectionActionAddDynamicAlbum => 'Dinamikus album hozzáadása';

  @override
  String get collectionActionAddShortcut => 'Parancsikon készítése';

  @override
  String get collectionActionSetHome => 'Kezdőlapnak beállít';

  @override
  String get collectionActionEmptyBin => 'A kuka üres';

  @override
  String get collectionActionCopy => 'Másolás albumba';

  @override
  String get collectionActionMove => 'Áthelyezés albumba';

  @override
  String get collectionActionRescan => 'Újraolvasás';

  @override
  String get collectionActionEdit => 'Szerkesztés';

  @override
  String get collectionSearchTitlesHintText => 'Címek keresése';

  @override
  String get collectionGroupAlbum => 'Albumok szerint';

  @override
  String get collectionGroupMonth => 'Hónapok szerint';

  @override
  String get collectionGroupDay => 'Napok szerint';

  @override
  String get collectionGroupNone => 'Nincs csoportositás';

  @override
  String get sectionUnknown => 'Ismeretlen';

  @override
  String get dateToday => 'Ma';

  @override
  String get dateYesterday => 'Tegnap';

  @override
  String get dateThisMonth => 'Ebben a hónapban';

  @override
  String collectionDeleteFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elem törlése sikertelen',
      one: 'Elem törlése sikertelen',
    );
    return '$_temp0';
  }

  @override
  String collectionCopyFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elem másolása sikertelen',
      one: 'Elem másolása sikertelen',
    );
    return '$_temp0';
  }

  @override
  String collectionMoveFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elem áthelyezése sikertelen',
      one: 'Elem áthelyezése sikertelen',
    );
    return '$_temp0';
  }

  @override
  String collectionRenameFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elem átnevezése sikertelen',
      one: 'Elem átnevezése sikertelen',
    );
    return '$_temp0';
  }

  @override
  String collectionEditFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elem szerkesztése sikertelen',
      one: 'Elem szerkesztése sikertelen',
    );
    return '$_temp0';
  }

  @override
  String collectionExportFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nem sikerült exportálni $count oldalt',
      one: 'Nem sikerült exportálni 1 oldalt',
    );
    return '$_temp0';
  }

  @override
  String collectionCopySuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elem másolva',
      one: '1 elem másolva',
    );
    return '$_temp0';
  }

  @override
  String collectionMoveSuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elem áthelyezve',
      one: '1 elem áthelyezve',
    );
    return '$_temp0';
  }

  @override
  String collectionRenameSuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elem átnevezve',
      one: '1 elem átnevezve',
    );
    return '$_temp0';
  }

  @override
  String collectionEditSuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elem szerkesztve',
      one: '1 elem szerkesztve',
    );
    return '$_temp0';
  }

  @override
  String get collectionEmptyFavourites => 'Nincsenek kedvencek';

  @override
  String get collectionEmptyVideos => 'Nincsenek videók';

  @override
  String get collectionEmptyImages => 'Nincsenek képek';

  @override
  String get collectionEmptyGrantAccessButtonLabel => 'Hozzáférés biztosítása';

  @override
  String get collectionSelectSectionTooltip => 'Szakasz kijelölése';

  @override
  String get collectionDeselectSectionTooltip => 'Szakasz kijelölésének megszüntetése';

  @override
  String get drawerAboutButton => 'Névjegy';

  @override
  String get drawerSettingsButton => 'Beállítások';

  @override
  String get drawerCollectionAll => 'Összes gyűjtemény';

  @override
  String get drawerCollectionFavourites => 'Kedvencek';

  @override
  String get drawerCollectionImages => 'Képek';

  @override
  String get drawerCollectionVideos => 'Videók';

  @override
  String get drawerCollectionAnimated => 'Animált';

  @override
  String get drawerCollectionMotionPhotos => 'Mozgó fotók';

  @override
  String get drawerCollectionPanoramas => 'Panorámák';

  @override
  String get drawerCollectionRaws => 'Raw fotók';

  @override
  String get drawerCollectionSphericalVideos => '360° videó';

  @override
  String get drawerAlbumPage => 'Albumok';

  @override
  String get drawerCountryPage => 'Országok';

  @override
  String get drawerPlacePage => 'Helyek';

  @override
  String get drawerTagPage => 'Címkék';

  @override
  String get sortByDate => 'Dátum';

  @override
  String get sortByName => 'Név';

  @override
  String get sortByItemCount => 'Elemek száma';

  @override
  String get sortBySize => 'Méret';

  @override
  String get sortByAlbumFileName => 'Album és fájlnév';

  @override
  String get sortByRating => 'Értékelés';

  @override
  String get sortByDuration => 'Hossz szerint';

  @override
  String get sortOrderNewestFirst => 'Legújabb legelöl';

  @override
  String get sortOrderOldestFirst => 'Legrégebbi legelöl';

  @override
  String get sortOrderAtoZ => 'A-Z';

  @override
  String get sortOrderZtoA => 'Z-A';

  @override
  String get sortOrderHighestFirst => 'Legmagasabb legelöl';

  @override
  String get sortOrderLowestFirst => 'Legalacsonyabb legelöl';

  @override
  String get sortOrderLargestFirst => 'Legnagyobb legelöl';

  @override
  String get sortOrderSmallestFirst => 'Legkisebb legelöl';

  @override
  String get sortOrderShortestFirst => 'Legrövidebb legelöl';

  @override
  String get sortOrderLongestFirst => 'Leghosszabb legelöl';

  @override
  String get albumGroupTier => 'Szint szerint';

  @override
  String get albumGroupType => 'Típus szerint';

  @override
  String get albumGroupVolume => 'Tárhely alapján';

  @override
  String get albumGroupNone => 'Nincs csoportositás';

  @override
  String get albumMimeTypeMixed => 'Vegyesen';

  @override
  String get albumPickPageTitleCopy => 'Másolás albumba';

  @override
  String get albumPickPageTitleExport => 'Exportálás albumba';

  @override
  String get albumPickPageTitleMove => 'Áthelyezés albumba';

  @override
  String get albumPickPageTitlePick => 'Album választása';

  @override
  String get albumCamera => 'Kamera';

  @override
  String get albumDownload => 'Letöltés';

  @override
  String get albumScreenshots => 'Képernyőképek';

  @override
  String get albumScreenRecordings => 'Képernyőfelvételek';

  @override
  String get albumVideoCaptures => 'Képkocka mentések';

  @override
  String get albumPageTitle => 'Albumok';

  @override
  String get albumEmpty => 'Nincsenek albumok';

  @override
  String get createAlbumButtonLabel => 'LÉTREHOZÁS';

  @override
  String get newFilterBanner => 'új';

  @override
  String get countryPageTitle => 'Országok';

  @override
  String get countryEmpty => 'Nincsenek országok';

  @override
  String get statePageTitle => 'Megyék';

  @override
  String get stateEmpty => 'Nincsenek megyék';

  @override
  String get placePageTitle => 'Helyek';

  @override
  String get placeEmpty => 'Nincsenek helyek';

  @override
  String get tagPageTitle => 'Címkék';

  @override
  String get tagEmpty => 'Nincsenek címkék';

  @override
  String get binPageTitle => 'Kuka';

  @override
  String get explorerPageTitle => 'Böngésző';

  @override
  String get explorerActionSelectStorageVolume => 'Tároló kiválasztása';

  @override
  String get selectStorageVolumeDialogTitle => 'Tároló Kiválasztása';

  @override
  String get searchCollectionFieldHint => 'Gyűjtemény keresése';

  @override
  String get searchRecentSectionTitle => 'Legutóbbi';

  @override
  String get searchDateSectionTitle => 'Dátum';

  @override
  String get searchAlbumsSectionTitle => 'Albumok';

  @override
  String get searchCountriesSectionTitle => 'Országok';

  @override
  String get searchStatesSectionTitle => 'Megyék';

  @override
  String get searchPlacesSectionTitle => 'Helyek';

  @override
  String get searchTagsSectionTitle => 'Címkék';

  @override
  String get searchRatingSectionTitle => 'Értékelések';

  @override
  String get searchMetadataSectionTitle => 'Metaadat';

  @override
  String get settingsPageTitle => 'Beállítások';

  @override
  String get settingsSystemDefault => 'Rendszer alapértéke';

  @override
  String get settingsDefault => 'Alapértelmezett';

  @override
  String get settingsDisabled => 'Letiltva';

  @override
  String get settingsAskEverytime => 'Mindig rákérdez';

  @override
  String get settingsModificationWarningDialogMessage => 'Egyéb beállítások is módosítva lesznek.';

  @override
  String get settingsSearchFieldLabel => 'Keresési beállítások';

  @override
  String get settingsSearchEmpty => 'Nincs egyező beállítás';

  @override
  String get settingsActionExport => 'Exportálás';

  @override
  String get settingsActionExportDialogTitle => 'Exportálás';

  @override
  String get settingsActionImport => 'Importálás';

  @override
  String get settingsActionImportDialogTitle => 'Importálás';

  @override
  String get appExportCovers => 'Borítóképek';

  @override
  String get appExportDynamicAlbums => 'Dinamikus albumok';

  @override
  String get appExportFavourites => 'Kedvencek';

  @override
  String get appExportSettings => 'Beállítások';

  @override
  String get settingsNavigationSectionTitle => 'Navigáció';

  @override
  String get settingsHomeTile => 'Kezdőlap';

  @override
  String get settingsHomeDialogTitle => 'Kezdőlap';

  @override
  String get setHomeCustom => 'Egyéni';

  @override
  String get settingsShowBottomNavigationBar => 'Alsó navigációs sáv mutatása';

  @override
  String get settingsKeepScreenOnTile => 'Kijelző bekapcsolva tartása';

  @override
  String get settingsKeepScreenOnDialogTitle => 'Kijelző bekapcsolva tartása';

  @override
  String get settingsDoubleBackExit => 'Nyomd meg a „visszát” kétszer a kilépéshez';

  @override
  String get settingsConfirmationTile => 'Megerősítési kérdések';

  @override
  String get settingsConfirmationDialogTitle => 'Megerősítési kérdések';

  @override
  String get settingsConfirmationBeforeDeleteItems => 'Kérdés az elemek végleges törlése előtt';

  @override
  String get settingsConfirmationBeforeMoveToBinItems => 'Kérdés az elemek kukába helyezése előtt';

  @override
  String get settingsConfirmationBeforeMoveUndatedItems => 'Kérdés a dátum nélküli elemek áthelyezése előtt';

  @override
  String get settingsConfirmationAfterMoveToBinItems => 'Üzenet az elemek kukába helyezése után';

  @override
  String get settingsConfirmationVaultDataLoss => 'Széf adatvesztési figyelmeztetés mutatása';

  @override
  String get settingsNavigationDrawerTile => 'Navigációs menü';

  @override
  String get settingsNavigationDrawerEditorPageTitle => 'Navigációs menü';

  @override
  String get settingsNavigationDrawerBanner => 'Érintsd és tartsd lenyomva a menü elemek mozgatásához és átrendezéshez.';

  @override
  String get settingsNavigationDrawerTabTypes => 'Típusok';

  @override
  String get settingsNavigationDrawerTabAlbums => 'Albumok';

  @override
  String get settingsNavigationDrawerTabPages => 'Oldalak';

  @override
  String get settingsNavigationDrawerAddAlbum => 'Album hozzáadása';

  @override
  String get settingsThumbnailSectionTitle => 'Miniatűrök';

  @override
  String get settingsThumbnailOverlayTile => 'Átfedés';

  @override
  String get settingsThumbnailOverlayPageTitle => 'Átfedés';

  @override
  String get settingsThumbnailShowHdrIcon => 'HDR ikon megjelenítése';

  @override
  String get settingsThumbnailShowFavouriteIcon => 'Kedvenc ikon mutatása';

  @override
  String get settingsThumbnailShowTagIcon => 'Címke ikon mutatása';

  @override
  String get settingsThumbnailShowLocationIcon => 'Hely ikon mutatása';

  @override
  String get settingsThumbnailShowMotionPhotoIcon => 'Mozgó fotó ikon mutatása';

  @override
  String get settingsThumbnailShowRating => 'Értékelés mutatása';

  @override
  String get settingsThumbnailShowRawIcon => 'Raw ikon mutatása';

  @override
  String get settingsThumbnailShowVideoDuration => 'Videó hosszának mutatása';

  @override
  String get settingsCollectionQuickActionsTile => 'Gyors műveletek';

  @override
  String get settingsCollectionQuickActionEditorPageTitle => 'Gyors műveletek';

  @override
  String get settingsCollectionQuickActionTabBrowsing => 'Böngészés';

  @override
  String get settingsCollectionQuickActionTabSelecting => 'Kiválasztás';

  @override
  String get settingsCollectionBrowsingQuickActionEditorBanner => 'Érintsd és tartsd lenyomva a gombok mozgatásához, válaszd ki az elemek böngészésekor megjelenő műveleteket.';

  @override
  String get settingsCollectionSelectionQuickActionEditorBanner => 'Érintsd és tartsd lenyomva a gombok mozgatásához, válaszd ki az elemek kiválasztásakor megjelenő műveleteket.';

  @override
  String get settingsCollectionBurstPatternsTile => 'Sorozatfelvételi minták';

  @override
  String get settingsCollectionBurstPatternsNone => 'Nincs';

  @override
  String get settingsViewerSectionTitle => 'Megtekintő';

  @override
  String get settingsViewerGestureSideTapNext => 'Koppints a képernyő szélein az előző/következő elemhez';

  @override
  String get settingsViewerUseCutout => 'Képernyő kivágási terület használata';

  @override
  String get settingsViewerMaximumBrightness => 'Maximális fényerő';

  @override
  String get settingsMotionPhotoAutoPlay => 'Mozgó fotók lejátszása';

  @override
  String get settingsImageBackground => 'Fénykép háttere';

  @override
  String get settingsViewerQuickActionsTile => 'Gyors műveletek';

  @override
  String get settingsViewerQuickActionEditorPageTitle => 'Gyors műveletek';

  @override
  String get settingsViewerQuickActionEditorBanner => 'Érintsd és tartsd lenyomva a gombok mozgatásához, válaszd ki a megtekintőben megjelenő műveleteket.';

  @override
  String get settingsViewerQuickActionEditorDisplayedButtonsSectionTitle => 'Megjelenített gombok';

  @override
  String get settingsViewerQuickActionEditorAvailableButtonsSectionTitle => 'Elérhető gombok';

  @override
  String get settingsViewerQuickActionEmpty => 'Nincsenek gombok';

  @override
  String get settingsViewerOverlayTile => 'Átfedés';

  @override
  String get settingsViewerOverlayPageTitle => 'Átfedés';

  @override
  String get settingsViewerShowOverlayOnOpening => 'Megjelenítés megnyitáskor';

  @override
  String get settingsViewerShowHistogram => 'Hisztogram megjelenítése';

  @override
  String get settingsViewerShowMinimap => 'Mini térkép mutatása';

  @override
  String get settingsViewerShowInformation => 'Információ mutatása';

  @override
  String get settingsViewerShowInformationSubtitle => 'Cím, dátum, hely, stb. mutatása';

  @override
  String get settingsViewerShowRatingTags => 'Értékelés és címkék mutatása';

  @override
  String get settingsViewerShowShootingDetails => 'Fényképezés részleteinek mutatása';

  @override
  String get settingsViewerShowDescription => 'Leírás mutatása';

  @override
  String get settingsViewerShowOverlayThumbnails => 'Miniatűrök mutatása';

  @override
  String get settingsViewerEnableOverlayBlurEffect => 'Elmosódási hatás';

  @override
  String get settingsViewerSlideshowTile => 'Diavetités';

  @override
  String get settingsViewerSlideshowPageTitle => 'Diavetités';

  @override
  String get settingsSlideshowRepeat => 'Ismétlés';

  @override
  String get settingsSlideshowShuffle => 'Keverés';

  @override
  String get settingsSlideshowFillScreen => 'Képernyő kitöltése';

  @override
  String get settingsSlideshowAnimatedZoomEffect => 'Animált nagyítási hatás';

  @override
  String get settingsSlideshowTransitionTile => 'Áttünés';

  @override
  String get settingsSlideshowIntervalTile => 'Hossz';

  @override
  String get settingsSlideshowVideoPlaybackTile => 'Videó lejátszás';

  @override
  String get settingsSlideshowVideoPlaybackDialogTitle => 'Videó lejátszás';

  @override
  String get settingsVideoPageTitle => 'Videó beállítások';

  @override
  String get settingsVideoSectionTitle => 'Videó';

  @override
  String get settingsVideoShowVideos => 'Videók mutatása';

  @override
  String get settingsVideoPlaybackTile => 'Visszajátszás';

  @override
  String get settingsVideoPlaybackPageTitle => 'Lejátszás';

  @override
  String get settingsVideoEnableHardwareAcceleration => 'Hardveres gyorsítás';

  @override
  String get settingsVideoAutoPlay => 'Automatikus lejátszás';

  @override
  String get settingsVideoLoopModeTile => 'Ismétlés';

  @override
  String get settingsVideoLoopModeDialogTitle => 'Ismétlés';

  @override
  String get settingsVideoResumptionModeTile => 'Lejátszás folytatása';

  @override
  String get settingsVideoResumptionModeDialogTitle => 'Lejátszás folytatása';

  @override
  String get settingsVideoBackgroundMode => 'Lejátszás háttérben';

  @override
  String get settingsVideoBackgroundModeDialogTitle => 'Lejátszás háttérben';

  @override
  String get settingsVideoControlsTile => 'Vezérlők';

  @override
  String get settingsVideoControlsPageTitle => 'Vezérlők';

  @override
  String get settingsVideoButtonsTile => 'Gombok';

  @override
  String get settingsVideoGestureDoubleTapTogglePlay => 'Lejátszás/szünet dupla koppintással';

  @override
  String get settingsVideoGestureSideDoubleTapSeek => 'Előre/hátra tekerés dupla koppintással a képernyő szélein';

  @override
  String get settingsVideoGestureVerticalDragBrightnessVolume => 'Fényerő/hangerő módosítása fel vagy lefelé csúsztatással';

  @override
  String get settingsSubtitleThemeTile => 'Feliratok';

  @override
  String get settingsSubtitleThemePageTitle => 'Feliratok';

  @override
  String get settingsSubtitleThemeSample => 'Ez egy minta.';

  @override
  String get settingsSubtitleThemeTextAlignmentTile => 'Szöveg pozíciója';

  @override
  String get settingsSubtitleThemeTextAlignmentDialogTitle => 'Szöveg pozíciója';

  @override
  String get settingsSubtitleThemeTextPositionTile => 'Szöveg pozíciója';

  @override
  String get settingsSubtitleThemeTextPositionDialogTitle => 'Szöveg pozíciója';

  @override
  String get settingsSubtitleThemeTextSize => 'Szöveg mérete';

  @override
  String get settingsSubtitleThemeShowOutline => 'Körvonal és árnyék megjelenítése';

  @override
  String get settingsSubtitleThemeTextColor => 'Szöveg színe';

  @override
  String get settingsSubtitleThemeTextOpacity => 'Szöveg átlátszósága';

  @override
  String get settingsSubtitleThemeBackgroundColor => 'Háttér szín';

  @override
  String get settingsSubtitleThemeBackgroundOpacity => 'Háttér átlátszósága';

  @override
  String get settingsSubtitleThemeTextAlignmentLeft => 'Balra';

  @override
  String get settingsSubtitleThemeTextAlignmentCenter => 'Középen';

  @override
  String get settingsSubtitleThemeTextAlignmentRight => 'Jobbra';

  @override
  String get settingsPrivacySectionTitle => 'Adatvédelem';

  @override
  String get settingsAllowInstalledAppAccess => 'Hozzáférés engedélyezése az app leltárhoz';

  @override
  String get settingsAllowInstalledAppAccessSubtitle => 'Az album megjelenítésének javítására szolgál';

  @override
  String get settingsAllowErrorReporting => 'Névtelen hibajelentés engedélyezése';

  @override
  String get settingsSaveSearchHistory => 'Keresési előzmény mentése';

  @override
  String get settingsEnableBin => 'Kuka használata';

  @override
  String get settingsEnableBinSubtitle => 'Törölt elemek megőrzése 30 napig';

  @override
  String get settingsDisablingBinWarningDialogMessage => 'A kukában lévő elemek örökre törlésre kerülnek.';

  @override
  String get settingsAllowMediaManagement => 'Média kezelés engedélyezése';

  @override
  String get settingsHiddenItemsTile => 'Rejtett elemek';

  @override
  String get settingsHiddenItemsPageTitle => 'Rejtett elemek';

  @override
  String get settingsHiddenFiltersBanner => 'A rejtett szűrőknek megfelelő képek és videók nem jelennek meg a gyűjteményében.';

  @override
  String get settingsHiddenFiltersEmpty => 'Nincsenek rejtett szűrők';

  @override
  String get settingsStorageAccessTile => 'Tárhely hozzáférés';

  @override
  String get settingsStorageAccessPageTitle => 'Tárhely hozzáférés';

  @override
  String get settingsStorageAccessBanner => 'Egyes könyvtárak kifejezett hozzáférési engedélyt igényelnek a benne lévő fájlok módosításához. Itt áttekintheted a könyvtárakat, amelyekhez korábban hozzáférést adtál.';

  @override
  String get settingsStorageAccessEmpty => 'Nincsenek jogok megadva';

  @override
  String get settingsStorageAccessRevokeTooltip => 'Megvonás';

  @override
  String get settingsAccessibilitySectionTitle => 'Kisegítő lehetőségek';

  @override
  String get settingsRemoveAnimationsTile => 'Animációk eltávolítása';

  @override
  String get settingsRemoveAnimationsDialogTitle => 'Animációk eltávolítása';

  @override
  String get settingsTimeToTakeActionTile => 'Ideje cselekedni';

  @override
  String get settingsAccessibilityShowPinchGestureAlternatives => 'Mutasson alternatív többujjas kézmozdulatokat';

  @override
  String get settingsDisplaySectionTitle => 'Kijelző';

  @override
  String get settingsThemeBrightnessTile => 'Téma';

  @override
  String get settingsThemeBrightnessDialogTitle => 'Téma';

  @override
  String get settingsThemeColorHighlights => 'Szín kiemelés';

  @override
  String get settingsThemeEnableDynamicColor => 'Dinamikus szín';

  @override
  String get settingsDisplayRefreshRateModeTile => 'Képernyőfrissítési ráta';

  @override
  String get settingsDisplayRefreshRateModeDialogTitle => 'Frissítési ráta';

  @override
  String get settingsDisplayUseTvInterface => 'Android TV felület';

  @override
  String get settingsLanguageSectionTitle => 'Nyelv és formátumok';

  @override
  String get settingsLanguageTile => 'Nyelv';

  @override
  String get settingsLanguagePageTitle => 'Nyelv';

  @override
  String get settingsCoordinateFormatTile => 'Koordináták formátuma';

  @override
  String get settingsCoordinateFormatDialogTitle => 'Koordináták formátuma';

  @override
  String get settingsUnitSystemTile => 'Mértékegységek';

  @override
  String get settingsUnitSystemDialogTitle => 'Mértékegységek';

  @override
  String get settingsForceWesternArabicNumeralsTile => 'Arab számok használata';

  @override
  String get settingsScreenSaverPageTitle => 'Képernyővédő';

  @override
  String get settingsWidgetPageTitle => 'Fotó keret';

  @override
  String get settingsWidgetShowOutline => 'Körvonal';

  @override
  String get settingsWidgetOpenPage => 'Widgetre koppintáskor';

  @override
  String get settingsWidgetDisplayedItem => 'Megjelenített elem';

  @override
  String get settingsCollectionTile => 'Gyűjtemény';

  @override
  String get statsPageTitle => 'Statisztikák';

  @override
  String statsWithGps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elem helyadatokkal',
    );
    return '$_temp0';
  }

  @override
  String get statsTopCountriesSectionTitle => 'Legjobb országok';

  @override
  String get statsTopStatesSectionTitle => 'Legjobb megyék';

  @override
  String get statsTopPlacesSectionTitle => 'Legjobb helyek';

  @override
  String get statsTopTagsSectionTitle => 'Legjobb címkék';

  @override
  String get statsTopAlbumsSectionTitle => 'Legjobb albumok';

  @override
  String get viewerOpenPanoramaButtonLabel => 'PANORÁMA MEGNYITÁSA';

  @override
  String get viewerSetWallpaperButtonLabel => 'BEÁLLÍTÁS HÁTTÉRKÉPNEK';

  @override
  String get viewerErrorUnknown => 'Hoppá!';

  @override
  String get viewerErrorDoesNotExist => 'A fájl már nem létezik.';

  @override
  String get viewerInfoPageTitle => 'Infó';

  @override
  String get viewerInfoBackToViewerTooltip => 'Vissza a megtekintőhöz';

  @override
  String get viewerInfoUnknown => 'ismeretlen';

  @override
  String get viewerInfoLabelDescription => 'Leírás';

  @override
  String get viewerInfoLabelTitle => 'Cím';

  @override
  String get viewerInfoLabelDate => 'Dátum';

  @override
  String get viewerInfoLabelResolution => 'Felbontás';

  @override
  String get viewerInfoLabelSize => 'Méret';

  @override
  String get viewerInfoLabelUri => 'URI';

  @override
  String get viewerInfoLabelPath => 'Hely';

  @override
  String get viewerInfoLabelDuration => 'Hossz';

  @override
  String get viewerInfoLabelOwner => 'Tulajdonos';

  @override
  String get viewerInfoLabelCoordinates => 'Koordináták';

  @override
  String get viewerInfoLabelAddress => 'Cím';

  @override
  String get mapStyleDialogTitle => 'Térkép stílus';

  @override
  String get mapStyleTooltip => 'Térkép stílus választása';

  @override
  String get mapZoomInTooltip => 'Nagyítás';

  @override
  String get mapZoomOutTooltip => 'Kicsinyítés';

  @override
  String get mapPointNorthUpTooltip => 'Mindig észak felé';

  @override
  String get mapAttributionOsmData => 'Térképadatok © [OpenStreetMap](https://www.openstreetmap.org/copyright) közreműködők';

  @override
  String get mapAttributionOsmLiberty => 'Csempék: [OpenMapTiles](https://www.openmaptiles.org/), [CC BY](http://creativecommons.org/licenses/by/4.0) • Kiszolgálja: [OSM Americana](https://tile.ourmap.us)';

  @override
  String get mapAttributionOpenTopoMap => '[SRTM](https://www.earthdata.nasa.gov/sensors/srtm) | Csempék: [OpenTopoMap](https://opentopomap.org/), [CC BY-SA](https://creativecommons.org/licenses/by-sa/3.0/)';

  @override
  String get mapAttributionOsmHot => 'Csempék: [HOT](https://www.hotosm.org/) • Kiszolgálja: [OSM France](https://openstreetmap.fr/)';

  @override
  String get mapAttributionStamen => 'Csempék: [Stamen Design](https://stamen.com), [CC BY 3.0](https://creativecommons.org/licenses/by/3.0)';

  @override
  String get openMapPageTooltip => 'Megtekintés a térképen';

  @override
  String get mapEmptyRegion => 'Nincsenek képek ebben a régióban';

  @override
  String get viewerInfoOpenEmbeddedFailureFeedback => 'Sikertelen a metaadatok kicsomagolása';

  @override
  String get viewerInfoOpenLinkText => 'Megnyitás';

  @override
  String get viewerInfoViewXmlLinkText => 'XML megtekintése';

  @override
  String get viewerInfoSearchFieldLabel => 'Metaadat keresése';

  @override
  String get viewerInfoSearchEmpty => 'Nincs egyező kulcs';

  @override
  String get viewerInfoSearchSuggestionDate => 'Dátum és idő';

  @override
  String get viewerInfoSearchSuggestionDescription => 'Leírás';

  @override
  String get viewerInfoSearchSuggestionDimensions => 'Méretek';

  @override
  String get viewerInfoSearchSuggestionResolution => 'Felbontás';

  @override
  String get viewerInfoSearchSuggestionRights => 'Jogok';

  @override
  String get wallpaperUseScrollEffect => 'Görgetés használata kezdőképernyőn';

  @override
  String get tagEditorPageTitle => 'Címkék szerkesztése';

  @override
  String get tagEditorPageNewTagFieldLabel => 'Új címke';

  @override
  String get tagEditorPageAddTagTooltip => 'Címke hozzáadása';

  @override
  String get tagEditorSectionRecent => 'Legutóbbi';

  @override
  String get tagEditorSectionPlaceholders => 'Helyszűrők';

  @override
  String get tagEditorDiscardDialogMessage => 'Elveted a változtatásokat?';

  @override
  String get tagPlaceholderCountry => 'Ország';

  @override
  String get tagPlaceholderState => 'Megye';

  @override
  String get tagPlaceholderPlace => 'Hely';

  @override
  String get panoramaEnableSensorControl => 'Szenzoros vezérlés engedélyezése';

  @override
  String get panoramaDisableSensorControl => 'Szenzoros vezérlés letiltása';

  @override
  String get sourceViewerPageTitle => 'Forrás';

  @override
  String get filePickerShowHiddenFiles => 'Rejtett fájlok mutatása';

  @override
  String get filePickerDoNotShowHiddenFiles => 'Ne mutassa a rejtett fájlokat';

  @override
  String get filePickerOpenFrom => 'Megnyitás innen';

  @override
  String get filePickerNoItems => 'Nincsenek elemek';

  @override
  String get filePickerUseThisFolder => 'Mappa használata';
}
