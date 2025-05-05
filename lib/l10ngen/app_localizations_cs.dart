// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class AppLocalizationsCs extends AppLocalizations {
  AppLocalizationsCs([String locale = 'cs']) : super(locale);

  @override
  String get appName => 'Aves';

  @override
  String get welcomeMessage => 'Vítá tě Aves';

  @override
  String get welcomeOptional => 'Volitelné';

  @override
  String get welcomeTermsToggle => 'Souhlasím s podmínkami použivání';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count položek',
      few: '$count položky',
      one: '$count položka',
    );
    return '$_temp0';
  }

  @override
  String columnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sloupců',
      few: '$count sloupce',
      one: '$count sloupec',
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
      other: '$countString sekund',
      few: '$countString sekundy',
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
      other: '$countString minut',
      few: '$countString minuty',
      one: '$countString minuta',
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
      other: '$countString dnů',
      few: '$countString dny',
      one: '$countString den',
    );
    return '$_temp0';
  }

  @override
  String focalLength(String length) {
    return '$length mm';
  }

  @override
  String get applyButtonLabel => 'POUŽÍT';

  @override
  String get createButtonLabel => 'CREATE';

  @override
  String get deleteButtonLabel => 'SMAZAT';

  @override
  String get nextButtonLabel => 'DALŠÍ';

  @override
  String get showButtonLabel => 'ZOBRAZIT';

  @override
  String get hideButtonLabel => 'SKRÝT';

  @override
  String get continueButtonLabel => 'POKRAČOVAT';

  @override
  String get saveCopyButtonLabel => 'ULOŽIT KOPII';

  @override
  String get applyTooltip => 'Použít';

  @override
  String get cancelTooltip => 'Zrušit';

  @override
  String get changeTooltip => 'Upravit';

  @override
  String get clearTooltip => 'Vyčistit';

  @override
  String get previousTooltip => 'Předchozí';

  @override
  String get nextTooltip => 'Další';

  @override
  String get showTooltip => 'Zobrazit';

  @override
  String get hideTooltip => 'Skrýt';

  @override
  String get actionRemove => 'Odstranit';

  @override
  String get resetTooltip => 'Resetovat';

  @override
  String get saveTooltip => 'Uložit';

  @override
  String get stopTooltip => 'Zastavit';

  @override
  String get pickTooltip => 'Vybrat';

  @override
  String get doubleBackExitMessage => 'Pro ukončení klepněte znovu na „zpět“.';

  @override
  String get doNotAskAgain => 'Znovu nezobrazovat';

  @override
  String get sourceStateLoading => 'Nahrávání';

  @override
  String get sourceStateCataloguing => 'Katalogizace';

  @override
  String get sourceStateLocatingCountries => 'Vyhledání zemí';

  @override
  String get sourceStateLocatingPlaces => 'Vyhledávání míst';

  @override
  String get chipActionDelete => 'Smazat';

  @override
  String get chipActionRemove => 'Odstranit';

  @override
  String get chipActionShowCollection => 'Zobrazit ve sbírce';

  @override
  String get chipActionGoToAlbumPage => 'Zobrazit v albech';

  @override
  String get chipActionGoToCountryPage => 'Zobrazit v zemích';

  @override
  String get chipActionGoToPlacePage => 'Zobrazit v místech';

  @override
  String get chipActionGoToTagPage => 'Zobrazit ve štítcích';

  @override
  String get chipActionGoToExplorerPage => 'Zobrazit v průzkumníku';

  @override
  String get chipActionDecompose => 'Rozdělit';

  @override
  String get chipActionFilterOut => 'Odfiltrovat';

  @override
  String get chipActionFilterIn => 'Filtrovat';

  @override
  String get chipActionHide => 'Skrýt';

  @override
  String get chipActionLock => 'Uzamknout';

  @override
  String get chipActionPin => 'Připnout nahoru';

  @override
  String get chipActionUnpin => 'Odepnout seshora';

  @override
  String get chipActionGroup => 'Group';

  @override
  String get chipActionRename => 'Přejmenovat';

  @override
  String get chipActionSetCover => 'Nastavit přebal';

  @override
  String get chipActionShowCountryStates => 'Zobrazit země';

  @override
  String get chipActionCreateGroup => 'Create group';

  @override
  String get chipActionCreateAlbum => 'Vytvořit album';

  @override
  String get chipActionCreateVault => 'Vytvořit trezor';

  @override
  String get chipActionConfigureVault => 'Upravit trezor';

  @override
  String get entryActionCopyToClipboard => 'Kopírovat do paměti';

  @override
  String get entryActionDelete => 'Smazat';

  @override
  String get entryActionConvert => 'Konvertovat';

  @override
  String get entryActionExport => 'Exportovat';

  @override
  String get entryActionInfo => 'Informace';

  @override
  String get entryActionRename => 'Přejmenovat';

  @override
  String get entryActionRestore => 'Obnovit';

  @override
  String get entryActionRotateCCW => 'Otočit doleva';

  @override
  String get entryActionRotateCW => 'Otočit doprava';

  @override
  String get entryActionFlip => 'Převrátit vodorovně';

  @override
  String get entryActionPrint => 'Tisknout';

  @override
  String get entryActionShare => 'Sdílet';

  @override
  String get entryActionShareImageOnly => 'Sdílet pouze obrázek';

  @override
  String get entryActionShareVideoOnly => 'Sdílet pouze video';

  @override
  String get entryActionViewSource => 'Zobrazit zdroj';

  @override
  String get entryActionShowGeoTiffOnMap => 'Zobrazit jako překryv mapy';

  @override
  String get entryActionConvertMotionPhotoToStillImage => 'Konvertovat na statický obrázek';

  @override
  String get entryActionViewMotionPhotoVideo => 'Otevřít video';

  @override
  String get entryActionEdit => 'Upravit';

  @override
  String get entryActionOpen => 'Otevřít s';

  @override
  String get entryActionSetAs => 'Nastavit jako';

  @override
  String get entryActionCast => 'Promítat';

  @override
  String get entryActionOpenMap => 'Zobrazit na mapě';

  @override
  String get entryActionRotateScreen => 'Otočit obrazovku';

  @override
  String get entryActionAddFavourite => 'Přidat do oblíbených';

  @override
  String get entryActionRemoveFavourite => 'Odebrat z oblíbených';

  @override
  String get videoActionCaptureFrame => 'Zachytit rámeček';

  @override
  String get videoActionMute => 'Ztlumit';

  @override
  String get videoActionUnmute => 'Zrušit ztlumení';

  @override
  String get videoActionPause => 'Pozastavit';

  @override
  String get videoActionPlay => 'Spustit';

  @override
  String get videoActionReplay10 => 'Přetočit zpět o 10 sekund';

  @override
  String get videoActionSkip10 => 'Posunout vpřed o 10 sekund';

  @override
  String get videoActionShowPreviousFrame => 'Zobrazit předchozí snímek';

  @override
  String get videoActionShowNextFrame => 'Zobrazit další snímek';

  @override
  String get videoActionSelectStreams => 'Vybrat stopy';

  @override
  String get videoActionSetSpeed => 'Rychlost přehrávání';

  @override
  String get videoActionABRepeat => 'Opakování A-B';

  @override
  String get videoRepeatActionSetStart => 'Nastavit začátek';

  @override
  String get videoRepeatActionSetEnd => 'Nastavit konec';

  @override
  String get viewerActionSettings => 'Nastavení';

  @override
  String get viewerActionLock => 'Uzamknout prohlížení';

  @override
  String get viewerActionUnlock => 'Odemknout prohlížení';

  @override
  String get slideshowActionResume => 'Pokračovat';

  @override
  String get slideshowActionShowInCollection => 'Zobrazit ve sbírce';

  @override
  String get entryInfoActionEditDate => 'Upravit datum a čas';

  @override
  String get entryInfoActionEditLocation => 'Upravit polohu';

  @override
  String get entryInfoActionEditTitleDescription => 'Upravit název a popis';

  @override
  String get entryInfoActionEditRating => 'Upravit hodnocení';

  @override
  String get entryInfoActionEditTags => 'Upravit štítky';

  @override
  String get entryInfoActionRemoveMetadata => 'Odstranit metadata';

  @override
  String get entryInfoActionExportMetadata => 'Exportovat metadata';

  @override
  String get entryInfoActionRemoveLocation => 'Odstranit polohu';

  @override
  String get editorActionTransform => 'Transformovat';

  @override
  String get editorTransformCrop => 'Oříznout';

  @override
  String get editorTransformRotate => 'Otočit';

  @override
  String get cropAspectRatioFree => 'Volný';

  @override
  String get cropAspectRatioOriginal => 'Originál';

  @override
  String get cropAspectRatioSquare => 'Čtverec';

  @override
  String get filterAspectRatioLandscapeLabel => 'Na šířku';

  @override
  String get filterAspectRatioPortraitLabel => 'Na výšku';

  @override
  String get filterBinLabel => 'Koš';

  @override
  String get filterFavouriteLabel => 'Oblíbené';

  @override
  String get filterNoDateLabel => 'Bez data';

  @override
  String get filterNoAddressLabel => 'Bez adresy';

  @override
  String get filterLocatedLabel => 'S polohou';

  @override
  String get filterNoLocationLabel => 'Bez polohy';

  @override
  String get filterNoRatingLabel => 'Nehodnocený';

  @override
  String get filterTaggedLabel => 'Se štítky';

  @override
  String get filterNoTagLabel => 'Bez štítků';

  @override
  String get filterNoTitleLabel => 'Bez názvu';

  @override
  String get filterOnThisDayLabel => 'V tento den';

  @override
  String get filterRecentlyAddedLabel => 'Naposled přidané';

  @override
  String get filterRatingRejectedLabel => 'Zamítnutý';

  @override
  String get filterTypeAnimatedLabel => 'Animovaný';

  @override
  String get filterTypeMotionPhotoLabel => 'Pohyblivá fotografie';

  @override
  String get filterTypePanoramaLabel => 'Panoráma';

  @override
  String get filterTypeRawLabel => 'Raw';

  @override
  String get filterTypeSphericalVideoLabel => '360° video';

  @override
  String get filterTypeGeotiffLabel => 'GeoTIFF';

  @override
  String get filterMimeImageLabel => 'Obrázek';

  @override
  String get filterMimeVideoLabel => 'Video';

  @override
  String get accessibilityAnimationsRemove => 'Zakázat vizuální efekty';

  @override
  String get accessibilityAnimationsKeep => 'Povolit vizuální efekty';

  @override
  String get albumTierNew => 'Nové';

  @override
  String get albumTierPinned => 'Připnuté';

  @override
  String get albumTierGroups => 'Groups';

  @override
  String get albumTierSpecial => 'Společné';

  @override
  String get albumTierApps => 'Aplikace';

  @override
  String get albumTierVaults => 'Trezory';

  @override
  String get albumTierDynamic => 'Dynamické';

  @override
  String get albumTierRegular => 'Ostatní';

  @override
  String get coordinateFormatDms => 'Stupně, minuty, vteřiny';

  @override
  String get coordinateFormatDdm => 'DDM';

  @override
  String get coordinateFormatDecimal => 'Stupně s desetinnými místy';

  @override
  String coordinateDms(String coordinate, String direction) {
    return '$coordinate $direction';
  }

  @override
  String get coordinateDmsNorth => 'S';

  @override
  String get coordinateDmsSouth => 'J';

  @override
  String get coordinateDmsEast => 'V';

  @override
  String get coordinateDmsWest => 'Z';

  @override
  String get displayRefreshRatePreferHighest => 'Nejvyšší';

  @override
  String get displayRefreshRatePreferLowest => 'Nejnižší';

  @override
  String get keepScreenOnNever => 'Nikdy';

  @override
  String get keepScreenOnVideoPlayback => 'Při přehrávání videa';

  @override
  String get keepScreenOnViewerOnly => 'Pouze v zobrazení prohlížeče';

  @override
  String get keepScreenOnAlways => 'Vždy';

  @override
  String get lengthUnitPixel => 'px';

  @override
  String get lengthUnitPercent => '%';

  @override
  String get mapStyleGoogleNormal => 'Mapy Google';

  @override
  String get mapStyleGoogleHybrid => 'Mapy Google (satelitní)';

  @override
  String get mapStyleGoogleTerrain => 'Mapy Google (terén)';

  @override
  String get mapStyleOsmLiberty => 'OSM Liberty';

  @override
  String get mapStyleOpenTopoMap => 'OpenTopoMap';

  @override
  String get mapStyleOsmHot => 'Humanitární OSM';

  @override
  String get mapStyleStamenWatercolor => 'Stamen Watercolor (vodové barvy)';

  @override
  String get maxBrightnessNever => 'Nikdy';

  @override
  String get maxBrightnessAlways => 'Vždy';

  @override
  String get nameConflictStrategyRename => 'Přejmenovat';

  @override
  String get nameConflictStrategyReplace => 'Nahradit';

  @override
  String get nameConflictStrategySkip => 'Přeskočit';

  @override
  String get overlayHistogramNone => 'Žádný';

  @override
  String get overlayHistogramRGB => 'RGB';

  @override
  String get overlayHistogramLuminance => 'Světelnost';

  @override
  String get subtitlePositionTop => 'Nahoře';

  @override
  String get subtitlePositionBottom => 'Dole';

  @override
  String get themeBrightnessLight => 'Světlé';

  @override
  String get themeBrightnessDark => 'Tmavé';

  @override
  String get themeBrightnessBlack => 'Černé';

  @override
  String get unitSystemMetric => 'Metrická soustava';

  @override
  String get unitSystemImperial => 'Imperiální jednotky';

  @override
  String get vaultLockTypePattern => 'Vzor';

  @override
  String get vaultLockTypePin => 'PIN';

  @override
  String get vaultLockTypePassword => 'Heslo';

  @override
  String get settingsVideoEnablePip => 'Obraz v obraze';

  @override
  String get videoControlsPlayOutside => 'Otevřít jiným přehrávačem';

  @override
  String get videoLoopModeNever => 'Nikdy';

  @override
  String get videoLoopModeShortOnly => 'Pouze krátká videa';

  @override
  String get videoLoopModeAlways => 'Vždy';

  @override
  String get videoPlaybackSkip => 'Přeskočit';

  @override
  String get videoPlaybackMuted => 'Přehrát ztlumené';

  @override
  String get videoPlaybackWithSound => 'Přehrát se zvukem';

  @override
  String get videoResumptionModeNever => 'Nikdy';

  @override
  String get videoResumptionModeAlways => 'Vždy';

  @override
  String get viewerTransitionSlide => 'Posun';

  @override
  String get viewerTransitionParallax => 'Parallax';

  @override
  String get viewerTransitionFade => 'Zeslábnutí';

  @override
  String get viewerTransitionZoomIn => 'Přiblížení';

  @override
  String get viewerTransitionNone => 'Žádný';

  @override
  String get wallpaperTargetHome => 'Domovská obrazovka';

  @override
  String get wallpaperTargetLock => 'Zamykací obrazovka';

  @override
  String get wallpaperTargetHomeLock => 'Domovská i zamykací obrazovka';

  @override
  String get widgetDisplayedItemRandom => 'Náhodně';

  @override
  String get widgetDisplayedItemMostRecent => 'Nejnovější';

  @override
  String get widgetOpenPageHome => 'Otevřít domovskou stránku';

  @override
  String get widgetOpenPageCollection => 'Otevřít sbírku';

  @override
  String get widgetOpenPageViewer => 'Otevřít prohlížeč';

  @override
  String get widgetTapUpdateWidget => 'Aktualizovat widget';

  @override
  String get storageVolumeDescriptionFallbackPrimary => 'Interní úložiště';

  @override
  String get storageVolumeDescriptionFallbackNonPrimary => 'SD karta';

  @override
  String get rootDirectoryDescription => 'kořenový adresář';

  @override
  String otherDirectoryDescription(String name) {
    return '„$name“ adresář';
  }

  @override
  String storageAccessDialogMessage(String directory, String volume) {
    return 'Prosím zvolte adresář $directory v „$volume“ na další obrazovce, abyste k němu povolili aplikaci přístup.';
  }

  @override
  String restrictedAccessDialogMessage(String directory, String volume) {
    return 'Tato aplikace nemá povolené úpravy souborů v adresáři $directory v „$volume“.\n\nPro přesun položek do jiného adresáře prosím použijte předinstalovaného správce souborů nebo galerii.';
  }

  @override
  String notEnoughSpaceDialogMessage(String neededSize, String freeSize, String volume) {
    return 'Pro dokončení této operace je vyžadováno $neededSize volného místa na „$volume“, ale k dispozici je pouze $freeSize.';
  }

  @override
  String get missingSystemFilePickerDialogMessage => 'Systémový nástroj pro výběr souborů chybí nebo je zakázaný. Prosím povolte jej a zkuste to znovu.';

  @override
  String unsupportedTypeDialogMessage(int count, String types) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tato operace není dostupná pro položky těchto typů: $types.',
      one: 'Tato operace není dostupná pro položky tohoto typu: $types.',
    );
    return '$_temp0';
  }

  @override
  String get nameConflictDialogSingleSourceMessage => 'Některé soubory v cílovém umístění mají stejný název.';

  @override
  String get nameConflictDialogMultipleSourceMessage => 'Některé soubory mají stejný název.';

  @override
  String get addShortcutDialogLabel => 'Název zástupce';

  @override
  String get addShortcutButtonLabel => 'PŘIDAT';

  @override
  String get noMatchingAppDialogMessage => 'Pro tuto operaci není k dispozici žádná aplikace.';

  @override
  String binEntriesConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Přesunout těchto $count položek do koše?',
      few: 'Přesunout tyto $count položky do koše?',
      one: 'Přesunout tuto položku do koše?',
    );
    return '$_temp0';
  }

  @override
  String deleteEntriesConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Smazat těchto $count položek?',
      few: 'Smazat tyto $count položky?',
      one: 'Smazat tuto položku?',
    );
    return '$_temp0';
  }

  @override
  String get moveUndatedConfirmationDialogMessage => 'Uložit data položek, než budete pokračovat?';

  @override
  String get moveUndatedConfirmationDialogSetDate => 'Uložit tada';

  @override
  String videoResumeDialogMessage(String time) {
    return 'Chcete obnovit přehrávání v čase $time?';
  }

  @override
  String get videoStartOverButtonLabel => 'SPUSTIT ZNOVU';

  @override
  String get videoResumeButtonLabel => 'POKRAČOVAT';

  @override
  String get setCoverDialogLatest => 'Poslední položka';

  @override
  String get setCoverDialogAuto => 'Automaticky';

  @override
  String get setCoverDialogCustom => 'Vlastní';

  @override
  String get hideFilterConfirmationDialogMessage => 'Odpovídající fotografie a videa budou ve vaší sbírce schovány. Můžete je znovu zobrazit v nastavení \"Soukromí\".\n\nOpravdu je chcete skrýt?';

  @override
  String get newAlbumDialogTitle => 'Nové album';

  @override
  String get newAlbumDialogNameLabel => 'Název alba';

  @override
  String get newAlbumDialogAlbumAlreadyExistsHelper => 'Album již existuje';

  @override
  String get newAlbumDialogNameLabelAlreadyExistsHelper => 'Adresář již existuje';

  @override
  String get newAlbumDialogStorageLabel => 'Úložiště:';

  @override
  String get newDynamicAlbumDialogTitle => 'Nové dynamické album';

  @override
  String get dynamicAlbumAlreadyExists => 'Dynamické album již existuje';

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
  String get newVaultWarningDialogMessage => 'Položky v trezorech jsou přístupné pouze této aplikaci a žádné jiné.\n\nPokud tuto aplikaci odinstalujete, nebo smažete její data, o všechny tyto položky přijdete.';

  @override
  String get newVaultDialogTitle => 'Nový trezor';

  @override
  String get configureVaultDialogTitle => 'Nastavit trezor';

  @override
  String get vaultDialogLockModeWhenScreenOff => 'Uzamknout při vypnutí displeje';

  @override
  String get vaultDialogLockTypeLabel => 'Typ uzamčení';

  @override
  String get patternDialogEnter => 'Zadejte gesto';

  @override
  String get patternDialogConfirm => 'Potvrďte gesto';

  @override
  String get pinDialogEnter => 'Zadejte PIN';

  @override
  String get pinDialogConfirm => 'Potvrďte PIN';

  @override
  String get passwordDialogEnter => 'Zadejte heslo';

  @override
  String get passwordDialogConfirm => 'Potvrďte heslo';

  @override
  String get authenticateToConfigureVault => 'Pro úpravu teroru se ověřte';

  @override
  String get authenticateToUnlockVault => 'Ověřte se pro otevření trezoru';

  @override
  String get vaultBinUsageDialogMessage => 'Některé trezory používají koš.';

  @override
  String get renameAlbumDialogLabel => 'Nový název';

  @override
  String get renameAlbumDialogLabelAlreadyExistsHelper => 'Adresář již existuje';

  @override
  String get renameEntrySetPageTitle => 'Přejmenovat';

  @override
  String get renameEntrySetPagePatternFieldLabel => 'Vzor názvu';

  @override
  String get renameEntrySetPageInsertTooltip => 'Vložit pole';

  @override
  String get renameEntrySetPagePreviewSectionTitle => 'Náhled';

  @override
  String get renameProcessorCounter => 'Počítadlo';

  @override
  String get renameProcessorHash => 'Hash';

  @override
  String get renameProcessorName => 'Název';

  @override
  String deleteSingleAlbumConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Smazat toto album a v něm obsažených $count položek?',
      few: 'Smazat toto album a v něm obsažené $count položky?',
      one: 'Smazat toto album a v něm obsaženou položku?',
    );
    return '$_temp0';
  }

  @override
  String deleteMultiAlbumConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Smazat tato alba a v nich obsažených $count položek?',
      few: 'Smazat tato alba a v nich obsažené $count položky?',
      one: 'Smazat tato alba a v nich obsaženou položku?',
    );
    return '$_temp0';
  }

  @override
  String get exportEntryDialogFormat => 'Formát:';

  @override
  String get exportEntryDialogWidth => 'Šířka';

  @override
  String get exportEntryDialogHeight => 'Výška';

  @override
  String get exportEntryDialogQuality => 'Kvalita';

  @override
  String get exportEntryDialogWriteMetadata => 'Zapsat metadata';

  @override
  String get renameEntryDialogLabel => 'Nový název';

  @override
  String get editEntryDialogCopyFromItem => 'Kopírovat z jiné položky';

  @override
  String get editEntryDialogTargetFieldsHeader => 'Pole k úpravě';

  @override
  String get editEntryDateDialogTitle => 'Datum a čas';

  @override
  String get editEntryDateDialogSetCustom => 'Nastavit vlastní datum';

  @override
  String get editEntryDateDialogCopyField => 'Kopírovat z jiného data';

  @override
  String get editEntryDateDialogExtractFromTitle => 'Odvodit z názvu';

  @override
  String get editEntryDateDialogShift => 'Posun';

  @override
  String get editEntryDateDialogSourceFileModifiedDate => 'Datum úpravy souboru';

  @override
  String get durationDialogHours => 'Hodiny';

  @override
  String get durationDialogMinutes => 'Minuty';

  @override
  String get durationDialogSeconds => 'Sekundy';

  @override
  String get editEntryLocationDialogTitle => 'Poloha';

  @override
  String get editEntryLocationDialogSetCustom => 'Nastavit vlastní polohu';

  @override
  String get editEntryLocationDialogChooseOnMap => 'Vybrat na mapě';

  @override
  String get editEntryLocationDialogImportGpx => 'Importovat GPX';

  @override
  String get editEntryLocationDialogLatitude => 'Zeměpisná šířka';

  @override
  String get editEntryLocationDialogLongitude => 'Zeměpisná délka';

  @override
  String get editEntryLocationDialogTimeShift => 'Časový posun';

  @override
  String get locationPickerUseThisLocationButton => 'Použít tuto polohu';

  @override
  String get editEntryRatingDialogTitle => 'Hodnocení';

  @override
  String get removeEntryMetadataDialogTitle => 'Odstranění metadat';

  @override
  String get removeEntryMetadataDialogAll => 'Vše';

  @override
  String get removeEntryMetadataDialogMore => 'Zobrazit více';

  @override
  String get removeEntryMetadataMotionPhotoXmpWarningDialogMessage => 'Pro přehrávání videa v pohyblivé fotografii je vyžadováno XMP.\n\nOpravdu jej chcete odstranit?';

  @override
  String get videoSpeedDialogLabel => 'Rychlost přehrávání';

  @override
  String get videoStreamSelectionDialogVideo => 'Video';

  @override
  String get videoStreamSelectionDialogAudio => 'Audio';

  @override
  String get videoStreamSelectionDialogText => 'Titulky';

  @override
  String get videoStreamSelectionDialogOff => 'Vypnuto';

  @override
  String get videoStreamSelectionDialogTrack => 'Stopa';

  @override
  String get videoStreamSelectionDialogNoSelection => 'Nejsou k dispozici žádné další stopy.';

  @override
  String get genericSuccessFeedback => 'Hotovo!';

  @override
  String get genericFailureFeedback => 'Selhání';

  @override
  String get genericDangerWarningDialogMessage => 'Jste si jisti?';

  @override
  String get tooManyItemsErrorDialogMessage => 'Zkuste znovu s několika dalšími položkami.';

  @override
  String get menuActionConfigureView => 'Zobrazení';

  @override
  String get menuActionSelect => 'Výběr';

  @override
  String get menuActionSelectAll => 'Vybrat vše';

  @override
  String get menuActionSelectNone => 'Zrušit výběr';

  @override
  String get menuActionMap => 'Mapa';

  @override
  String get menuActionSlideshow => 'Slideshow';

  @override
  String get menuActionStats => 'Statistiky';

  @override
  String get viewDialogSortSectionTitle => 'Řazení';

  @override
  String get viewDialogGroupSectionTitle => 'Seskupení';

  @override
  String get viewDialogLayoutSectionTitle => 'Rozložení';

  @override
  String get viewDialogReverseSortOrder => 'Obrátit řazení';

  @override
  String get tileLayoutMosaic => 'Mozaika';

  @override
  String get tileLayoutGrid => 'Mřížka';

  @override
  String get tileLayoutList => 'Seznam';

  @override
  String get castDialogTitle => 'Zařízení pro promítání';

  @override
  String get coverDialogTabCover => 'Přebal';

  @override
  String get coverDialogTabApp => 'Aplikace';

  @override
  String get coverDialogTabColor => 'Barva';

  @override
  String get appPickDialogTitle => 'Vybrat aplikaci';

  @override
  String get appPickDialogNone => 'Žádný';

  @override
  String get aboutPageTitle => 'O aplikaci';

  @override
  String get aboutLinkLicense => 'Licence';

  @override
  String get aboutLinkPolicy => 'Zásady ochrany osobních údajů';

  @override
  String get aboutBugSectionTitle => 'Hlášení chyb';

  @override
  String get aboutBugSaveLogInstruction => 'Uložte aplikační logy do souboru';

  @override
  String get aboutBugCopyInfoInstruction => 'Zkopírujte informace o systému';

  @override
  String get aboutBugCopyInfoButton => 'Kopírovat';

  @override
  String get aboutBugReportInstruction => 'Nahlásit na GitHub s logy a informacemi o systému';

  @override
  String get aboutBugReportButton => 'Nahlásit';

  @override
  String get aboutDataUsageSectionTitle => 'Využitý prostor';

  @override
  String get aboutDataUsageData => 'Data';

  @override
  String get aboutDataUsageCache => 'Mezipaměť';

  @override
  String get aboutDataUsageDatabase => 'Databáze';

  @override
  String get aboutDataUsageMisc => 'Různé';

  @override
  String get aboutDataUsageInternal => 'Interní';

  @override
  String get aboutDataUsageExternal => 'Externí';

  @override
  String get aboutDataUsageClearCache => 'Vymazat mezipaměť';

  @override
  String get aboutCreditsSectionTitle => 'Zásluhy';

  @override
  String get aboutCreditsWorldAtlas1 => 'Tato aplikace využívá soubor TopoJSON od';

  @override
  String get aboutCreditsWorldAtlas2 => 'pod ISC licencí.';

  @override
  String get aboutTranslatorsSectionTitle => 'Překladatalé';

  @override
  String get aboutLicensesSectionTitle => 'Licence open-source';

  @override
  String get aboutLicensesBanner => 'Tato aplikace využívá tyto open-source baličky a knihovny.';

  @override
  String get aboutLicensesAndroidLibrariesSectionTitle => 'Knihovny Androidu';

  @override
  String get aboutLicensesFlutterPluginsSectionTitle => 'Pluginy Flutteru';

  @override
  String get aboutLicensesFlutterPackagesSectionTitle => 'Baličky Flutteru';

  @override
  String get aboutLicensesDartPackagesSectionTitle => 'Balíčky Dartu';

  @override
  String get aboutLicensesShowAllButtonLabel => 'Zobrazit všechny licence';

  @override
  String get policyPageTitle => 'Zásady ochrany osobních údajů';

  @override
  String get collectionPageTitle => 'Sbírky';

  @override
  String get collectionPickPageTitle => 'Výběr';

  @override
  String get collectionSelectPageTitle => 'Vybrat položky';

  @override
  String get collectionActionShowTitleSearch => 'Filtrovat dle názvu';

  @override
  String get collectionActionHideTitleSearch => 'Skrýt filtr dle názvu';

  @override
  String get collectionActionAddDynamicAlbum => 'Přidat dynamické album';

  @override
  String get collectionActionAddShortcut => 'Vytvořit zástupce';

  @override
  String get collectionActionSetHome => 'Nastavit jako domov';

  @override
  String get collectionActionEmptyBin => 'Vysypat koš';

  @override
  String get collectionActionCopy => 'Kopírovat do alba';

  @override
  String get collectionActionMove => 'Přesunout do alba';

  @override
  String get collectionActionRescan => 'Znovu prohledat';

  @override
  String get collectionActionEdit => 'Upravit';

  @override
  String get collectionSearchTitlesHintText => 'Hledat názvy';

  @override
  String get collectionGroupAlbum => 'Podle alba';

  @override
  String get collectionGroupMonth => 'Podle měsíce';

  @override
  String get collectionGroupDay => 'Podle dne';

  @override
  String get sectionNone => 'No sections';

  @override
  String get sectionUnknown => 'Neznámý';

  @override
  String get dateToday => 'Dnes';

  @override
  String get dateYesterday => 'Včera';

  @override
  String get dateThisMonth => 'Tento měsíc';

  @override
  String collectionDeleteFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Chyba při mazání $count položek',
      one: 'Chyba při mazání 1 položky',
    );
    return '$_temp0';
  }

  @override
  String collectionCopyFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Chyba při kopírování $count položek',
      one: 'Chyba při kopírování 1 položky',
    );
    return '$_temp0';
  }

  @override
  String collectionMoveFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Chyba při přesouvání $count položek',
      one: 'Chyba při přesouvání 1 položky',
    );
    return '$_temp0';
  }

  @override
  String collectionRenameFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Chyba přejmenování $count položek',
      one: 'Chyba přejmenování 1 položky',
    );
    return '$_temp0';
  }

  @override
  String collectionEditFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Chyba při úpravě $count položek',
      one: 'Chyba při úpravě 1 položky',
    );
    return '$_temp0';
  }

  @override
  String collectionExportFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Chyba při exportu $count stránek',
      one: 'Chyba při exportu 1 stránky',
    );
    return '$_temp0';
  }

  @override
  String collectionCopySuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Zkopírováno $count položek',
      few: 'Zkopírovány $count položky',
      one: 'Zkopírována 1 položka',
    );
    return '$_temp0';
  }

  @override
  String collectionMoveSuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Přesunuto $count položek',
      few: 'Přesunuty $count položky',
      one: 'Přesunuta 1 položka',
    );
    return '$_temp0';
  }

  @override
  String collectionRenameSuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Přejmenováno $count položek',
      few: 'Přejmenovány $count položky',
      one: 'Přejmenována 1 položka',
    );
    return '$_temp0';
  }

  @override
  String collectionEditSuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Upraveno $count položek',
      few: 'Upraveny $count položky',
      one: 'Upravena 1 položka',
    );
    return '$_temp0';
  }

  @override
  String get collectionEmptyFavourites => 'Žádné oblíbené položky';

  @override
  String get collectionEmptyVideos => 'Žádná videa';

  @override
  String get collectionEmptyImages => 'Žádné obrázky';

  @override
  String get collectionEmptyGrantAccessButtonLabel => 'Povolit přístup';

  @override
  String get collectionSelectSectionTooltip => 'Vybrat sekci';

  @override
  String get collectionDeselectSectionTooltip => 'Zrušit výběr sekce';

  @override
  String get drawerAboutButton => 'O aplikaci';

  @override
  String get drawerSettingsButton => 'Nastavení';

  @override
  String get drawerCollectionAll => 'Celá sbírka';

  @override
  String get drawerCollectionFavourites => 'Oblíbené';

  @override
  String get drawerCollectionImages => 'Obrázky';

  @override
  String get drawerCollectionVideos => 'Videa';

  @override
  String get drawerCollectionAnimated => 'Animované';

  @override
  String get drawerCollectionMotionPhotos => 'Pohyblivé fotografie';

  @override
  String get drawerCollectionPanoramas => 'Panoramata';

  @override
  String get drawerCollectionRaws => 'Fotografie Raw';

  @override
  String get drawerCollectionSphericalVideos => '360° videa';

  @override
  String get drawerAlbumPage => 'Alba';

  @override
  String get drawerCountryPage => 'Země';

  @override
  String get drawerPlacePage => 'Místa';

  @override
  String get drawerTagPage => 'Štítky';

  @override
  String get sortByDate => 'Podle data';

  @override
  String get sortByName => 'Abecedně';

  @override
  String get sortByItemCount => 'Podle počtu položek';

  @override
  String get sortBySize => 'Podle velikosti';

  @override
  String get sortByAlbumFileName => 'Podle alba a názvu souboru';

  @override
  String get sortByRating => 'Podle hodnocení';

  @override
  String get sortByDuration => 'Podle trvání';

  @override
  String get sortByPath => 'By path';

  @override
  String get sortOrderNewestFirst => 'Od nejnovějšího';

  @override
  String get sortOrderOldestFirst => 'Od nejstaršího';

  @override
  String get sortOrderAtoZ => 'Od A do Z';

  @override
  String get sortOrderZtoA => 'Od Z do A';

  @override
  String get sortOrderHighestFirst => 'Od nejvyššího';

  @override
  String get sortOrderLowestFirst => 'Od nejnižšího';

  @override
  String get sortOrderLargestFirst => 'Od nejširšího';

  @override
  String get sortOrderSmallestFirst => 'Od nejužšího';

  @override
  String get sortOrderShortestFirst => 'Nejkratší první';

  @override
  String get sortOrderLongestFirst => 'Nejdelší první';

  @override
  String get albumGroupTier => 'Podle úrovně';

  @override
  String get albumGroupType => 'Podle typu';

  @override
  String get albumGroupVolume => 'Podle úložiště';

  @override
  String get albumMimeTypeMixed => 'Smíšené';

  @override
  String get albumPickPageTitleCopy => 'Kopírovat do alba';

  @override
  String get albumPickPageTitleExport => 'Exportovat do alba';

  @override
  String get albumPickPageTitleMove => 'Přesunout do alba';

  @override
  String get albumPickPageTitlePick => 'Vybrat album';

  @override
  String get albumCamera => 'Fotoaparát';

  @override
  String get albumDownload => 'Stažené';

  @override
  String get albumScreenshots => 'Snímky obrazovky';

  @override
  String get albumScreenRecordings => 'Nahrávky obrazovky';

  @override
  String get albumVideoCaptures => 'Snímky videa';

  @override
  String get albumPageTitle => 'Alba';

  @override
  String get albumEmpty => 'Žádná alba';

  @override
  String get createAlbumButtonLabel => 'VYTVOŘIT';

  @override
  String get newFilterBanner => 'nový';

  @override
  String get countryPageTitle => 'Země';

  @override
  String get countryEmpty => 'Žádné země';

  @override
  String get statePageTitle => 'Státy';

  @override
  String get stateEmpty => 'Žádné státy';

  @override
  String get placePageTitle => 'Místa';

  @override
  String get placeEmpty => 'Žádná místa';

  @override
  String get tagPageTitle => 'Štítky';

  @override
  String get tagEmpty => 'Žádné štítky';

  @override
  String get binPageTitle => 'Koš';

  @override
  String get explorerPageTitle => 'Průzkumník';

  @override
  String get explorerActionSelectStorageVolume => 'Vyberte úložiště';

  @override
  String get selectStorageVolumeDialogTitle => 'Vyberte úložiště';

  @override
  String get searchCollectionFieldHint => 'Prohledat sbírky';

  @override
  String get searchRecentSectionTitle => 'Nedávné';

  @override
  String get searchDateSectionTitle => 'Datum';

  @override
  String get searchFormatSectionTitle => 'Formats';

  @override
  String get searchAlbumsSectionTitle => 'Alba';

  @override
  String get searchCountriesSectionTitle => 'Země';

  @override
  String get searchStatesSectionTitle => 'Státy';

  @override
  String get searchPlacesSectionTitle => 'Místa';

  @override
  String get searchTagsSectionTitle => 'Štítky';

  @override
  String get searchRatingSectionTitle => 'Hodnocení';

  @override
  String get searchMetadataSectionTitle => 'Metadata';

  @override
  String get settingsPageTitle => 'Nastavení';

  @override
  String get settingsSystemDefault => 'Výchozí nastavení systému';

  @override
  String get settingsDefault => 'Výchozí';

  @override
  String get settingsDisabled => 'Zakázáno';

  @override
  String get settingsAskEverytime => 'Vždy se zeptat';

  @override
  String get settingsModificationWarningDialogMessage => 'Ostatní nastavení budou upravena.';

  @override
  String get settingsSearchFieldLabel => 'Prohledat nastavení';

  @override
  String get settingsSearchEmpty => 'Žádné odpovídající položky';

  @override
  String get settingsActionExport => 'Export';

  @override
  String get settingsActionExportDialogTitle => 'Export';

  @override
  String get settingsActionImport => 'Import';

  @override
  String get settingsActionImportDialogTitle => 'Import';

  @override
  String get appExportCovers => 'Přebaly';

  @override
  String get appExportDynamicAlbums => 'Dynamická alba';

  @override
  String get appExportFavourites => 'Oblíbené';

  @override
  String get appExportSettings => 'Nastavení';

  @override
  String get settingsNavigationSectionTitle => 'Navigace';

  @override
  String get settingsHomeTile => 'Domů';

  @override
  String get settingsHomeDialogTitle => 'Domů';

  @override
  String get setHomeCustom => 'Vlastní';

  @override
  String get settingsShowBottomNavigationBar => 'Zobrazit spodní navigační lištu';

  @override
  String get settingsKeepScreenOnTile => 'Ponechat obrazovku zapnutou';

  @override
  String get settingsKeepScreenOnDialogTitle => 'Ponechat obrazovku zapnutou';

  @override
  String get settingsDoubleBackExit => 'Klepnout dvakrát na „zpět“ pro ukončení';

  @override
  String get settingsConfirmationTile => 'Potvrzovací dialogy';

  @override
  String get settingsConfirmationDialogTitle => 'Potvrzovací dialogy';

  @override
  String get settingsConfirmationBeforeDeleteItems => 'Zeptat se před smazáním položek navždy';

  @override
  String get settingsConfirmationBeforeMoveToBinItems => 'Zeptat se před přesunem položek do koše';

  @override
  String get settingsConfirmationBeforeMoveUndatedItems => 'Zeptat se před přesunem položek bez data';

  @override
  String get settingsConfirmationAfterMoveToBinItems => 'Zobrazit zprávu po přesunu položek do koše';

  @override
  String get settingsConfirmationVaultDataLoss => 'Zobrazit varování o možnosti ztráty dat trezorů';

  @override
  String get settingsNavigationDrawerTile => 'Navigační menu';

  @override
  String get settingsNavigationDrawerEditorPageTitle => 'Navigační menu';

  @override
  String get settingsNavigationDrawerBanner => 'Stiskněte a podržte pro přesun položek a změnu jejich pořadí.';

  @override
  String get settingsNavigationDrawerTabTypes => 'Typy';

  @override
  String get settingsNavigationDrawerTabAlbums => 'Alba';

  @override
  String get settingsNavigationDrawerTabPages => 'Stránky';

  @override
  String get settingsNavigationDrawerAddAlbum => 'Přidat album';

  @override
  String get settingsThumbnailSectionTitle => 'Náhledy';

  @override
  String get settingsThumbnailOverlayTile => 'Zobrazené detaily';

  @override
  String get settingsThumbnailOverlayPageTitle => 'Zobrazené detaily';

  @override
  String get settingsThumbnailShowHdrIcon => 'Zobrazit ikonu HDR';

  @override
  String get settingsThumbnailShowFavouriteIcon => 'Zobrazit ikonu oblíbených';

  @override
  String get settingsThumbnailShowTagIcon => 'Zobrazit ikonu štítků';

  @override
  String get settingsThumbnailShowLocationIcon => 'Zobrazit ikonu polohy';

  @override
  String get settingsThumbnailShowMotionPhotoIcon => 'Zobrazit ikonu pohyblivých fotografií';

  @override
  String get settingsThumbnailShowRating => 'Zobrazit hodnocení';

  @override
  String get settingsThumbnailShowRawIcon => 'Zobrazit ikonu RAW';

  @override
  String get settingsThumbnailShowVideoDuration => 'Zobrazit délku videa';

  @override
  String get settingsCollectionQuickActionsTile => 'Rychlé akce';

  @override
  String get settingsCollectionQuickActionEditorPageTitle => 'Rychlé akce';

  @override
  String get settingsCollectionQuickActionTabBrowsing => 'Procházení';

  @override
  String get settingsCollectionQuickActionTabSelecting => 'Výběr';

  @override
  String get settingsCollectionBrowsingQuickActionEditorBanner => 'Stiskněte a podržte pro přesun tlačítek a vyberte, které akce budou zobrazeny při procházení položek.';

  @override
  String get settingsCollectionSelectionQuickActionEditorBanner => 'Stiskněte a podržte pro přesun tlačítek a vyberte, které akce budou zobrazeny při výběru položek.';

  @override
  String get settingsCollectionBurstPatternsTile => 'Vzory dávek';

  @override
  String get settingsCollectionBurstPatternsNone => 'Žádný';

  @override
  String get settingsViewerSectionTitle => 'Prohlížeč';

  @override
  String get settingsViewerGestureSideTapNext => 'Stisknout v rozích obrazovky pro zobrazení předcházející/následující položky';

  @override
  String get settingsViewerUseCutout => 'Použít oblast výřezu';

  @override
  String get settingsViewerMaximumBrightness => 'Nejvyšší jas';

  @override
  String get settingsMotionPhotoAutoPlay => 'Automatické přehrávání pohyblivých fotografií';

  @override
  String get settingsImageBackground => 'Pozadí obrázku';

  @override
  String get settingsViewerQuickActionsTile => 'Rychlé akce';

  @override
  String get settingsViewerQuickActionEditorPageTitle => 'Rychlé akce';

  @override
  String get settingsViewerQuickActionEditorBanner => 'Stiskněte a podržte pro přesun tlačítek a vyberte, které akce budou zobrazeny při prohlížení položek.';

  @override
  String get settingsViewerQuickActionEditorDisplayedButtonsSectionTitle => 'Zobrazená tlačítka';

  @override
  String get settingsViewerQuickActionEditorAvailableButtonsSectionTitle => 'Dostupná tlačítka';

  @override
  String get settingsViewerQuickActionEmpty => 'Žádná tlačítka';

  @override
  String get settingsViewerOverlayTile => 'Souhrn';

  @override
  String get settingsViewerOverlayPageTitle => 'Souhrn';

  @override
  String get settingsViewerShowOverlayOnOpening => 'Zobrazit při otevření';

  @override
  String get settingsViewerShowHistogram => 'Zobrazit histogram';

  @override
  String get settingsViewerShowMinimap => 'Zobrazit minimapu';

  @override
  String get settingsViewerShowInformation => 'Zobrazit informace';

  @override
  String get settingsViewerShowInformationSubtitle => 'Zobrazit název, datum, polohu apod.';

  @override
  String get settingsViewerShowRatingTags => 'Zobrazit hodnocení a štítky';

  @override
  String get settingsViewerShowShootingDetails => 'Zobrazit podrobnosti o pořízené fogotrafii';

  @override
  String get settingsViewerShowDescription => 'Zobrazit popis';

  @override
  String get settingsViewerShowOverlayThumbnails => 'Zobrazit náhledy';

  @override
  String get settingsViewerEnableOverlayBlurEffect => 'Efekt rozostření';

  @override
  String get settingsViewerSlideshowTile => 'Prezentace';

  @override
  String get settingsViewerSlideshowPageTitle => 'Prezentace';

  @override
  String get settingsSlideshowRepeat => 'Opakovat';

  @override
  String get settingsSlideshowShuffle => 'Náhodně';

  @override
  String get settingsSlideshowFillScreen => 'Vyplnit obrazovku';

  @override
  String get settingsSlideshowAnimatedZoomEffect => 'Animovaný efekt přiblížení';

  @override
  String get settingsSlideshowTransitionTile => 'Přechod';

  @override
  String get settingsSlideshowIntervalTile => 'Prodleva';

  @override
  String get settingsSlideshowVideoPlaybackTile => 'Přehrávání videa';

  @override
  String get settingsSlideshowVideoPlaybackDialogTitle => 'Přehrávání videa';

  @override
  String get settingsVideoPageTitle => 'Nastavení videa';

  @override
  String get settingsVideoSectionTitle => 'Video';

  @override
  String get settingsVideoShowVideos => 'Zobrazovat videa';

  @override
  String get settingsVideoPlaybackTile => 'Přehrávání';

  @override
  String get settingsVideoPlaybackPageTitle => 'Přehrávání';

  @override
  String get settingsVideoEnableHardwareAcceleration => 'Hardwarová akcelerace';

  @override
  String get settingsVideoAutoPlay => 'Automatické přehrávání';

  @override
  String get settingsVideoLoopModeTile => 'Režim smyčky';

  @override
  String get settingsVideoLoopModeDialogTitle => 'Režim smyčky';

  @override
  String get settingsVideoResumptionModeTile => 'Obnovit přehrávání';

  @override
  String get settingsVideoResumptionModeDialogTitle => 'Obnovit přehrávání';

  @override
  String get settingsVideoBackgroundMode => 'Režim na pozadí';

  @override
  String get settingsVideoBackgroundModeDialogTitle => 'Režim na pozadí';

  @override
  String get settingsVideoControlsTile => 'Ovládání';

  @override
  String get settingsVideoControlsPageTitle => 'Ovládání';

  @override
  String get settingsVideoButtonsTile => 'Tlačítka';

  @override
  String get settingsVideoGestureDoubleTapTogglePlay => 'Dvojité stisknutí pro spuštění / pauzu';

  @override
  String get settingsVideoGestureSideDoubleTapSeek => 'Dvojití stisknutí v rozích obrazovky pro posun vzad / vpřed';

  @override
  String get settingsVideoGestureVerticalDragBrightnessVolume => 'Potáhnout nahoru či dolů pro úpravu jasu/hlasitosti';

  @override
  String get settingsSubtitleThemeTile => 'Titulky';

  @override
  String get settingsSubtitleThemePageTitle => 'Titulky';

  @override
  String get settingsSubtitleThemeSample => 'Toto je příklad.';

  @override
  String get settingsSubtitleThemeTextAlignmentTile => 'Zarovnání textu';

  @override
  String get settingsSubtitleThemeTextAlignmentDialogTitle => 'Zarovnání textu';

  @override
  String get settingsSubtitleThemeTextPositionTile => 'Pozice textu';

  @override
  String get settingsSubtitleThemeTextPositionDialogTitle => 'Pozice textu';

  @override
  String get settingsSubtitleThemeTextSize => 'Velikost textu';

  @override
  String get settingsSubtitleThemeShowOutline => 'Zobrazovat obrys a stín';

  @override
  String get settingsSubtitleThemeTextColor => 'Barva textu';

  @override
  String get settingsSubtitleThemeTextOpacity => 'Průhlednost textu';

  @override
  String get settingsSubtitleThemeBackgroundColor => 'Barva pozadí';

  @override
  String get settingsSubtitleThemeBackgroundOpacity => 'Průhlednost pozadí';

  @override
  String get settingsSubtitleThemeTextAlignmentLeft => 'Doleva';

  @override
  String get settingsSubtitleThemeTextAlignmentCenter => 'Na střed';

  @override
  String get settingsSubtitleThemeTextAlignmentRight => 'Doprava';

  @override
  String get settingsPrivacySectionTitle => 'Soukromí';

  @override
  String get settingsAllowInstalledAppAccess => 'Povolit přístup do aplikačního inventáře';

  @override
  String get settingsAllowInstalledAppAccessSubtitle => 'Používá se pro zlepšení zobrazení alb';

  @override
  String get settingsAllowErrorReporting => 'Povolit anonymní chybová hlášení';

  @override
  String get settingsSaveSearchHistory => 'Uložit historii vyhledávání';

  @override
  String get settingsEnableBin => 'Používat koš';

  @override
  String get settingsEnableBinSubtitle => 'Ponechat v koši smazané položky po dobu 30 dní';

  @override
  String get settingsDisablingBinWarningDialogMessage => 'Položky v koši budou navždy odstraněny.';

  @override
  String get settingsAllowMediaManagement => 'Povolit správu médií';

  @override
  String get settingsHiddenItemsTile => 'Skryté položky';

  @override
  String get settingsHiddenItemsPageTitle => 'Skryté položky';

  @override
  String get settingsHiddenFiltersBanner => 'Fotografie a videa odpovídající filtrům skrytých položek nebudou zobrazeny ve vaši sbírce.';

  @override
  String get settingsHiddenFiltersEmpty => 'Žádné filtry skrytých položek';

  @override
  String get settingsStorageAccessTile => 'Přístup k úložišti';

  @override
  String get settingsStorageAccessPageTitle => 'Přístup k úložišti';

  @override
  String get settingsStorageAccessBanner => 'Některé adresáře vyžadují explicitní udělení přístupu k úpravě jejich souborů. Zde si můžete prohlédnout adresáře, ke kterým jste dříve udělili přístup.';

  @override
  String get settingsStorageAccessEmpty => 'Žádné povolené přístupy';

  @override
  String get settingsStorageAccessRevokeTooltip => 'Odvolat';

  @override
  String get settingsAccessibilitySectionTitle => 'Přístupnost';

  @override
  String get settingsRemoveAnimationsTile => 'Zakázat animace';

  @override
  String get settingsRemoveAnimationsDialogTitle => 'Zakázat animace';

  @override
  String get settingsTimeToTakeActionTile => 'Čas k provedení akce';

  @override
  String get settingsAccessibilityShowPinchGestureAlternatives => 'Zobrazit alternativy vícedotykových gest';

  @override
  String get settingsDisplaySectionTitle => 'Zobrazení';

  @override
  String get settingsThemeBrightnessTile => 'Vzhled';

  @override
  String get settingsThemeBrightnessDialogTitle => 'Vzhled';

  @override
  String get settingsThemeColorHighlights => 'Zvýraznění barev';

  @override
  String get settingsThemeEnableDynamicColor => 'Dynamické barvy';

  @override
  String get settingsDisplayRefreshRateModeTile => 'Obnovovací frekvence displeje';

  @override
  String get settingsDisplayRefreshRateModeDialogTitle => 'Obnovovací frekvence';

  @override
  String get settingsDisplayUseTvInterface => 'Rozhraní Android TV';

  @override
  String get settingsLanguageSectionTitle => 'Jazyk a formáty';

  @override
  String get settingsLanguageTile => 'Jazyk';

  @override
  String get settingsLanguagePageTitle => 'Jazyk';

  @override
  String get settingsCoordinateFormatTile => 'Formát souřadnic';

  @override
  String get settingsCoordinateFormatDialogTitle => 'Formát souřadnic';

  @override
  String get settingsUnitSystemTile => 'Jednotky';

  @override
  String get settingsUnitSystemDialogTitle => 'Jednotky';

  @override
  String get settingsForceWesternArabicNumeralsTile => 'Vynutit arabské číslice';

  @override
  String get settingsScreenSaverPageTitle => 'Spořič displeje';

  @override
  String get settingsWidgetPageTitle => 'Rámeček fotografie';

  @override
  String get settingsWidgetShowOutline => 'Obrys';

  @override
  String get settingsWidgetOpenPage => 'Při stisknutí widgetu';

  @override
  String get settingsWidgetDisplayedItem => 'Zobrazená položka';

  @override
  String get settingsCollectionTile => 'Sbírka';

  @override
  String get statsPageTitle => 'Statistiky';

  @override
  String statsWithGps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count položek s polohou',
      few: '$count položky s polohou',
      one: '1 položka s polohou',
    );
    return '$_temp0';
  }

  @override
  String get statsTopCountriesSectionTitle => 'Nejčastější země';

  @override
  String get statsTopStatesSectionTitle => 'Nejčastější státy';

  @override
  String get statsTopPlacesSectionTitle => 'Nejčastější místa';

  @override
  String get statsTopTagsSectionTitle => 'Nejčastější štítky';

  @override
  String get statsTopAlbumsSectionTitle => 'Nejčastější alba';

  @override
  String get viewerOpenPanoramaButtonLabel => 'OTEVŘÍT PANORAMA';

  @override
  String get viewerSetWallpaperButtonLabel => 'NASTAVIT POZADÍ';

  @override
  String get viewerErrorUnknown => 'Jejda!';

  @override
  String get viewerErrorDoesNotExist => 'Soubor již neexistuje.';

  @override
  String get viewerInfoPageTitle => 'Detaily';

  @override
  String get viewerInfoBackToViewerTooltip => 'Zpět k prohlížení';

  @override
  String get viewerInfoUnknown => 'neznámý';

  @override
  String get viewerInfoLabelDescription => 'Popis';

  @override
  String get viewerInfoLabelTitle => 'Název';

  @override
  String get viewerInfoLabelDate => 'Datum';

  @override
  String get viewerInfoLabelResolution => 'Rozlišení';

  @override
  String get viewerInfoLabelSize => 'Velikost';

  @override
  String get viewerInfoLabelUri => 'URI';

  @override
  String get viewerInfoLabelPath => 'Umístění';

  @override
  String get viewerInfoLabelDuration => 'Délka';

  @override
  String get viewerInfoLabelOwner => 'Vlastník';

  @override
  String get viewerInfoLabelCoordinates => 'Souřadnice';

  @override
  String get viewerInfoLabelAddress => 'Adresa';

  @override
  String get mapStyleDialogTitle => 'Styl mapy';

  @override
  String get mapStyleTooltip => 'Vyberte styl mapy';

  @override
  String get mapZoomInTooltip => 'Přiblížit';

  @override
  String get mapZoomOutTooltip => 'Oddálit';

  @override
  String get mapPointNorthUpTooltip => 'Sever nahoře';

  @override
  String get mapAttributionOsmData => 'Mapová data © [OpenStreetMap](https://www.openstreetmap.org/copyright) přispěvatelé';

  @override
  String get mapAttributionOsmLiberty => 'Dlaždice z [OpenMapTiles](https://www.openmaptiles.org/), [CC BY](http://creativecommons.org/licenses/by/4.0) • Hostované na [OSM Americana](https://tile.ourmap.us)';

  @override
  String get mapAttributionOpenTopoMap => '[SRTM](https://www.earthdata.nasa.gov/sensors/srtm) | Dlaždice z [OpenTopoMap](https://opentopomap.org/), [CC BY-SA](https://creativecommons.org/licenses/by-sa/3.0/)';

  @override
  String get mapAttributionOsmHot => 'Dlaždice z [HOT](https://www.hotosm.org/) • Hostováno na [OSM France](https://openstreetmap.fr/)';

  @override
  String get mapAttributionStamen => 'Dlaždice z [Stamen Design](https://stamen.com), [CC BY 3.0](https://creativecommons.org/licenses/by/3.0)';

  @override
  String get openMapPageTooltip => 'Zobrazit na mapě';

  @override
  String get mapEmptyRegion => 'Žádné obrázky v této oblasti';

  @override
  String get viewerInfoOpenEmbeddedFailureFeedback => 'Nepodařilo se extrahovat vložená data';

  @override
  String get viewerInfoOpenLinkText => 'Otevřít';

  @override
  String get viewerInfoViewXmlLinkText => 'Zobrazit XML';

  @override
  String get viewerInfoSearchFieldLabel => 'Prohledat metadata';

  @override
  String get viewerInfoSearchEmpty => 'Žádné odpovídající klíče';

  @override
  String get viewerInfoSearchSuggestionDate => 'Datum a čas';

  @override
  String get viewerInfoSearchSuggestionDescription => 'Popis';

  @override
  String get viewerInfoSearchSuggestionDimensions => 'Rozměry';

  @override
  String get viewerInfoSearchSuggestionResolution => 'Rozlišení';

  @override
  String get viewerInfoSearchSuggestionRights => 'Práva';

  @override
  String get wallpaperUseScrollEffect => 'Použít rolovací efekt na domovské obrazovce';

  @override
  String get tagEditorPageTitle => 'Upravit štítky';

  @override
  String get tagEditorPageNewTagFieldLabel => 'Nový štítek';

  @override
  String get tagEditorPageAddTagTooltip => 'Přidat štítek';

  @override
  String get tagEditorSectionRecent => 'Nedávné';

  @override
  String get tagEditorSectionPlaceholders => 'Umístění';

  @override
  String get tagEditorDiscardDialogMessage => 'Chcete zrušit změny?';

  @override
  String get tagPlaceholderCountry => 'Země';

  @override
  String get tagPlaceholderState => 'Stát';

  @override
  String get tagPlaceholderPlace => 'Místo';

  @override
  String get panoramaEnableSensorControl => 'Povolit ovládání senzorem';

  @override
  String get panoramaDisableSensorControl => 'Zakázat ovládání senzorem';

  @override
  String get sourceViewerPageTitle => 'Zdroj';
}
