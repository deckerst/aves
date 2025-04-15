// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swedish (`sv`).
class AppLocalizationsSv extends AppLocalizations {
  AppLocalizationsSv([String locale = 'sv']) : super(locale);

  @override
  String get appName => 'Aves';

  @override
  String get welcomeMessage => 'Välkommen till Aves';

  @override
  String get welcomeOptional => 'Valfritt';

  @override
  String get welcomeTermsToggle => 'Jag godkänner användarvillkoren';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count objekt',
    );
    return '$_temp0';
  }

  @override
  String columnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kolumner',
      one: '$count kolumn',
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
      other: '$countString sekunder',
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
      other: '$countString minuter',
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
      other: '$countString dagar',
      one: '$countString dag',
    );
    return '$_temp0';
  }

  @override
  String focalLength(String length) {
    return '$length mm';
  }

  @override
  String get applyButtonLabel => 'TILLÄMPA';

  @override
  String get deleteButtonLabel => 'Ta bort';

  @override
  String get nextButtonLabel => 'NÄSTA';

  @override
  String get showButtonLabel => 'VISA';

  @override
  String get hideButtonLabel => 'GÖM';

  @override
  String get continueButtonLabel => 'FORTSÄTT';

  @override
  String get saveCopyButtonLabel => 'Spara kopia';

  @override
  String get applyTooltip => 'Tillämpa';

  @override
  String get cancelTooltip => 'Avbryt';

  @override
  String get changeTooltip => 'Ändra';

  @override
  String get clearTooltip => 'Rensa';

  @override
  String get previousTooltip => 'Föregående';

  @override
  String get nextTooltip => 'Nästa';

  @override
  String get showTooltip => 'Visa';

  @override
  String get hideTooltip => 'Göm';

  @override
  String get actionRemove => 'Ta bort';

  @override
  String get resetTooltip => 'Återställ';

  @override
  String get saveTooltip => 'Spara';

  @override
  String get stopTooltip => 'Stopp';

  @override
  String get pickTooltip => 'Välj';

  @override
  String get doubleBackExitMessage => 'Tryck ”bakåt” igen för att stänga.';

  @override
  String get doNotAskAgain => 'Fråga inte igen';

  @override
  String get sourceStateLoading => 'Laddar';

  @override
  String get sourceStateCataloguing => 'Katalogiserar';

  @override
  String get sourceStateLocatingCountries => 'Lokaliserar länder';

  @override
  String get sourceStateLocatingPlaces => 'Lokaliserar platser';

  @override
  String get chipActionDelete => 'Ta bort';

  @override
  String get chipActionRemove => 'Ta bort';

  @override
  String get chipActionShowCollection => 'Visa i Samling';

  @override
  String get chipActionGoToAlbumPage => 'Visa i Album';

  @override
  String get chipActionGoToCountryPage => 'Visa i Länder';

  @override
  String get chipActionGoToPlacePage => 'Visa i Platser';

  @override
  String get chipActionGoToTagPage => 'Visa på Etikettsidan';

  @override
  String get chipActionGoToExplorerPage => 'Visa i Utforskaren';

  @override
  String get chipActionDecompose => 'Splitta';

  @override
  String get chipActionFilterOut => 'Filtrera ut';

  @override
  String get chipActionFilterIn => 'Filtrera fram';

  @override
  String get chipActionHide => 'Göm';

  @override
  String get chipActionLock => 'Lås';

  @override
  String get chipActionPin => 'Fäst överst';

  @override
  String get chipActionUnpin => 'Släpp från fästet';

  @override
  String get chipActionRename => 'Byt namn';

  @override
  String get chipActionSetCover => 'Välj som omslag';

  @override
  String get chipActionShowCountryStates => 'Visa delstater';

  @override
  String get chipActionCreateAlbum => 'Skapa album';

  @override
  String get chipActionCreateVault => 'Skapa valv';

  @override
  String get chipActionConfigureVault => 'Konfigurera valv';

  @override
  String get entryActionCopyToClipboard => 'Kopiera till klippboken';

  @override
  String get entryActionDelete => 'Radera';

  @override
  String get entryActionConvert => 'Konvertera';

  @override
  String get entryActionExport => 'Exportera';

  @override
  String get entryActionInfo => 'Info';

  @override
  String get entryActionRename => 'Byt namn';

  @override
  String get entryActionRestore => 'Återställ';

  @override
  String get entryActionRotateCCW => 'Rotera moturs';

  @override
  String get entryActionRotateCW => 'Rotera medurs';

  @override
  String get entryActionFlip => 'Vrid horisontellt';

  @override
  String get entryActionPrint => 'Skriv ut';

  @override
  String get entryActionShare => 'Dela';

  @override
  String get entryActionShareImageOnly => 'Dela endast bild';

  @override
  String get entryActionShareVideoOnly => 'Dela endast video';

  @override
  String get entryActionViewSource => 'Visa källa';

  @override
  String get entryActionShowGeoTiffOnMap => 'Visa som kartöverlägg';

  @override
  String get entryActionConvertMotionPhotoToStillImage => 'Konvertera till stillbild';

  @override
  String get entryActionViewMotionPhotoVideo => 'Öppna video';

  @override
  String get entryActionEdit => 'Redigera';

  @override
  String get entryActionOpen => 'Öppna med';

  @override
  String get entryActionSetAs => 'Välj som';

  @override
  String get entryActionCast => 'Casta';

  @override
  String get entryActionOpenMap => 'Visa i kartappen';

  @override
  String get entryActionRotateScreen => 'Rotera skärmen';

  @override
  String get entryActionAddFavourite => 'Lägg till i favoritlistan';

  @override
  String get entryActionRemoveFavourite => 'Ta bort från favoritlistan';

  @override
  String get videoActionCaptureFrame => 'Fånga stillbild';

  @override
  String get videoActionMute => 'Ljud av';

  @override
  String get videoActionUnmute => 'Ljud på';

  @override
  String get videoActionPause => 'Pausa';

  @override
  String get videoActionPlay => 'Spela';

  @override
  String get videoActionReplay10 => 'Spola tillbaks 10 sekunder';

  @override
  String get videoActionSkip10 => 'Spola framåt 10 sekunder';

  @override
  String get videoActionShowPreviousFrame => 'Visa föregående bildruta';

  @override
  String get videoActionShowNextFrame => 'Visa nästa bildruta';

  @override
  String get videoActionSelectStreams => 'Välj spår';

  @override
  String get videoActionSetSpeed => 'Uppspelningshastighet';

  @override
  String get videoActionABRepeat => 'A-B återupprepa';

  @override
  String get videoRepeatActionSetStart => 'Ange start';

  @override
  String get videoRepeatActionSetEnd => 'Ange slut';

  @override
  String get viewerActionSettings => 'Inställningar';

  @override
  String get viewerActionLock => 'Lås bildvisaren';

  @override
  String get viewerActionUnlock => 'Lås upp bildvisaren';

  @override
  String get slideshowActionResume => 'Återuppta';

  @override
  String get slideshowActionShowInCollection => 'Visa i Samling';

  @override
  String get entryInfoActionEditDate => 'Redigera datum & tid';

  @override
  String get entryInfoActionEditLocation => 'Redigera plats';

  @override
  String get entryInfoActionEditTitleDescription => 'Redigera titel & beskrivning';

  @override
  String get entryInfoActionEditRating => 'Redigera omdöme';

  @override
  String get entryInfoActionEditTags => 'Redigera etiketter';

  @override
  String get entryInfoActionRemoveMetadata => 'Ta bort metadata';

  @override
  String get entryInfoActionExportMetadata => 'Exportera metadata';

  @override
  String get entryInfoActionRemoveLocation => 'Ta bort plats';

  @override
  String get editorActionTransform => 'Transformera';

  @override
  String get editorTransformCrop => 'Beskär';

  @override
  String get editorTransformRotate => 'Rotera';

  @override
  String get cropAspectRatioFree => 'Fri';

  @override
  String get cropAspectRatioOriginal => 'Original';

  @override
  String get cropAspectRatioSquare => 'Fyrkant';

  @override
  String get filterAspectRatioLandscapeLabel => 'Liggande bilder';

  @override
  String get filterAspectRatioPortraitLabel => 'Stående bilder';

  @override
  String get filterBinLabel => 'Papperskorg';

  @override
  String get filterFavouriteLabel => 'Favorit';

  @override
  String get filterNoDateLabel => 'Odaterad';

  @override
  String get filterNoAddressLabel => 'Ingen adress';

  @override
  String get filterLocatedLabel => 'Belägen';

  @override
  String get filterNoLocationLabel => 'Oplacerad';

  @override
  String get filterNoRatingLabel => 'Obedömd';

  @override
  String get filterTaggedLabel => 'Taggad';

  @override
  String get filterNoTagLabel => 'Inga etiketter tillagda';

  @override
  String get filterNoTitleLabel => 'Obetitlad';

  @override
  String get filterOnThisDayLabel => 'På den här dagen';

  @override
  String get filterRecentlyAddedLabel => 'Nyligen tillagda';

  @override
  String get filterRatingRejectedLabel => 'Avisad';

  @override
  String get filterTypeAnimatedLabel => 'Animerad';

  @override
  String get filterTypeMotionPhotoLabel => 'Rörelsefoto';

  @override
  String get filterTypePanoramaLabel => 'Panorama';

  @override
  String get filterTypeRawLabel => 'Raw';

  @override
  String get filterTypeSphericalVideoLabel => '360° Video';

  @override
  String get filterTypeGeotiffLabel => 'GeoTIFF';

  @override
  String get filterMimeImageLabel => 'Bild';

  @override
  String get filterMimeVideoLabel => 'Video';

  @override
  String get accessibilityAnimationsRemove => 'Förhindra skärmeffekter';

  @override
  String get accessibilityAnimationsKeep => 'Behåll skärmeffekter';

  @override
  String get albumTierNew => 'Ny';

  @override
  String get albumTierPinned => 'Fastnålad';

  @override
  String get albumTierSpecial => 'Vanliga';

  @override
  String get albumTierApps => 'Appar';

  @override
  String get albumTierVaults => 'Valv';

  @override
  String get albumTierDynamic => 'Dynamisk';

  @override
  String get albumTierRegular => 'Andra';

  @override
  String get coordinateFormatDms => 'DMS';

  @override
  String get coordinateFormatDdm => 'DDM';

  @override
  String get coordinateFormatDecimal => 'Decimalgrader';

  @override
  String coordinateDms(String coordinate, String direction) {
    return '$coordinate $direction';
  }

  @override
  String get coordinateDmsNorth => 'N';

  @override
  String get coordinateDmsSouth => 'S';

  @override
  String get coordinateDmsEast => 'Ö';

  @override
  String get coordinateDmsWest => 'V';

  @override
  String get displayRefreshRatePreferHighest => 'Högsta intervall';

  @override
  String get displayRefreshRatePreferLowest => 'Lägsta intervall';

  @override
  String get keepScreenOnNever => 'Aldrig';

  @override
  String get keepScreenOnVideoPlayback => 'Under videouppspelning';

  @override
  String get keepScreenOnViewerOnly => 'Endast på bildvisningssidan';

  @override
  String get keepScreenOnAlways => 'Alltid';

  @override
  String get lengthUnitPixel => 'px';

  @override
  String get lengthUnitPercent => '%';

  @override
  String get mapStyleGoogleNormal => 'Google Maps';

  @override
  String get mapStyleGoogleHybrid => 'Google Maps (Hybrid)';

  @override
  String get mapStyleGoogleTerrain => 'Google Maps (Terräng)';

  @override
  String get mapStyleOsmLiberty => 'OSM Liberty';

  @override
  String get mapStyleOpenTopoMap => 'OpenTopoMap';

  @override
  String get mapStyleOsmHot => 'Humanitär OSM';

  @override
  String get mapStyleStamenWatercolor => 'Stamen Watercolor (Akvarell)';

  @override
  String get maxBrightnessNever => 'Aldrig';

  @override
  String get maxBrightnessAlways => 'Alltid';

  @override
  String get nameConflictStrategyRename => 'Byt namn';

  @override
  String get nameConflictStrategyReplace => 'Ersätt';

  @override
  String get nameConflictStrategySkip => 'Skippa';

  @override
  String get overlayHistogramNone => 'Igen';

  @override
  String get overlayHistogramRGB => 'RGB';

  @override
  String get overlayHistogramLuminance => 'Luminans';

  @override
  String get subtitlePositionTop => 'Överkant';

  @override
  String get subtitlePositionBottom => 'Nederkant';

  @override
  String get themeBrightnessLight => 'Ljus';

  @override
  String get themeBrightnessDark => 'Mörk';

  @override
  String get themeBrightnessBlack => 'Svart';

  @override
  String get unitSystemMetric => 'Metriska';

  @override
  String get unitSystemImperial => 'Brittiskt';

  @override
  String get vaultLockTypePattern => 'Mönster';

  @override
  String get vaultLockTypePin => 'PIN';

  @override
  String get vaultLockTypePassword => 'Lösenord';

  @override
  String get settingsVideoEnablePip => 'Bild-i-bild';

  @override
  String get videoControlsPlayOutside => 'Öppna med annan spelare';

  @override
  String get videoLoopModeNever => 'Aldrig';

  @override
  String get videoLoopModeShortOnly => 'Bara korta videor';

  @override
  String get videoLoopModeAlways => 'Alltid';

  @override
  String get videoPlaybackSkip => 'Skippa';

  @override
  String get videoPlaybackMuted => 'Spela ljudlös';

  @override
  String get videoPlaybackWithSound => 'Spela med ljud';

  @override
  String get videoResumptionModeNever => 'Aldrig';

  @override
  String get videoResumptionModeAlways => 'Alltid';

  @override
  String get viewerTransitionSlide => 'Glid';

  @override
  String get viewerTransitionParallax => 'Parallax';

  @override
  String get viewerTransitionFade => 'Tona ut';

  @override
  String get viewerTransitionZoomIn => 'Zooma in';

  @override
  String get viewerTransitionNone => 'Igen';

  @override
  String get wallpaperTargetHome => 'Hemskärm';

  @override
  String get wallpaperTargetLock => 'Låsskärm';

  @override
  String get wallpaperTargetHomeLock => 'Hem och låsskärmar';

  @override
  String get widgetDisplayedItemRandom => 'Slumpartat';

  @override
  String get widgetDisplayedItemMostRecent => 'Det senaste';

  @override
  String get widgetOpenPageHome => 'Öppna startsida';

  @override
  String get widgetOpenPageCollection => 'Öppna samling';

  @override
  String get widgetOpenPageViewer => 'Öppna bildvisaren';

  @override
  String get widgetTapUpdateWidget => 'Uppdatera widgeten';

  @override
  String get storageVolumeDescriptionFallbackPrimary => 'Intern lagring';

  @override
  String get storageVolumeDescriptionFallbackNonPrimary => 'SD kort';

  @override
  String get rootDirectoryDescription => 'grundkatalog';

  @override
  String otherDirectoryDescription(String name) {
    return '”$name”-katalogen';
  }

  @override
  String storageAccessDialogMessage(String directory, String volume) {
    return 'Vänligen välj $directory i ”$volume” på nästa skärm för att ge appen åtkomst till den.';
  }

  @override
  String restrictedAccessDialogMessage(String directory, String volume) {
    return 'Denna applikation har ej tillåtelse att modifiera filer i $directory i ”$volume”.\n\nVänligen använd en förinstallerad filhanterare eller galleriapplikation för att flytta filerna till en annan katalog.';
  }

  @override
  String notEnoughSpaceDialogMessage(String neededSize, String freeSize, String volume) {
    return 'Denna åtgärd behöver $neededSize ledigt utrymme på ”$volume” för att kunna slutföras, men det är enbart $freeSize kvar.';
  }

  @override
  String get missingSystemFilePickerDialogMessage => 'Systemets filväljare saknas eller har inaktiverats. Vänligen aktivera denna och försök igen.';

  @override
  String unsupportedTypeDialogMessage(int count, String types) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Denna åtgärd stöds ej för följande typer av filer: $types.',
      one: 'Denna åtgärd stöds ej för filer av denna typ: $types.',
    );
    return '$_temp0';
  }

  @override
  String get nameConflictDialogSingleSourceMessage => 'Vissa filer i destinationsmappen har samma namn.';

  @override
  String get nameConflictDialogMultipleSourceMessage => 'Vissa filer har samma namn.';

  @override
  String get addShortcutDialogLabel => 'Rubrik för genväg';

  @override
  String get addShortcutButtonLabel => 'LÄGG TILL';

  @override
  String get noMatchingAppDialogMessage => 'Det finns inga applikationer som kan hantera detta.';

  @override
  String binEntriesConfirmationDialogMessage(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Flytta dessa $countString filer till papperskorgen?',
      one: 'Flytta denna fil till papperskorgen?',
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
      other: 'Vill du ta bort dessa $countString filer?',
      one: 'Vill du ta bort denna fil?',
    );
    return '$_temp0';
  }

  @override
  String get moveUndatedConfirmationDialogMessage => 'Registrera datum för filerna innan vi går vidare?';

  @override
  String get moveUndatedConfirmationDialogSetDate => 'Spara datum';

  @override
  String videoResumeDialogMessage(String time) {
    return 'Vill du återuppta uppspelningen vid tidpunkten $time?';
  }

  @override
  String get videoStartOverButtonLabel => 'BÖRJA OM';

  @override
  String get videoResumeButtonLabel => 'ÅTERUPPTA';

  @override
  String get setCoverDialogLatest => 'Senaste objektet';

  @override
  String get setCoverDialogAuto => 'Auto';

  @override
  String get setCoverDialogCustom => 'Anpassad';

  @override
  String get hideFilterConfirmationDialogMessage => 'Matchande foton och videor kommer att döljas från din samling. Du kan välja att visa dem igen från ”sekretessinställningarna”.\n\nÄr du säker på att du vill dölja dem?';

  @override
  String get newAlbumDialogTitle => 'Nytt Album';

  @override
  String get newAlbumDialogNameLabel => 'Album namn';

  @override
  String get newAlbumDialogAlbumAlreadyExistsHelper => 'Albumet existerar redan';

  @override
  String get newAlbumDialogNameLabelAlreadyExistsHelper => 'Katalogen existerar redan';

  @override
  String get newAlbumDialogStorageLabel => 'Lagring:';

  @override
  String get newDynamicAlbumDialogTitle => 'Nytt dynamiskt album';

  @override
  String get dynamicAlbumAlreadyExists => 'Dynamiskt album existerar redan';

  @override
  String get newVaultWarningDialogMessage => 'Objekt i valv är endast tillgängliga i denna app och inga andra.\n\nOm du avinstallerar den här appen eller rensar appens data kommer du att förlora alla dessa objekt.';

  @override
  String get newVaultDialogTitle => 'Nytt Valv';

  @override
  String get configureVaultDialogTitle => 'Konfigurera Valv';

  @override
  String get vaultDialogLockModeWhenScreenOff => 'Lås när skärmen stängs av';

  @override
  String get vaultDialogLockTypeLabel => 'Lås typ';

  @override
  String get patternDialogEnter => 'Ange mönster';

  @override
  String get patternDialogConfirm => 'Bekräfta mönster';

  @override
  String get pinDialogEnter => 'Ange Pinkod';

  @override
  String get pinDialogConfirm => 'Bekräfta pinkod';

  @override
  String get passwordDialogEnter => 'Ange lösenord';

  @override
  String get passwordDialogConfirm => 'Bekräfta lösenord';

  @override
  String get authenticateToConfigureVault => 'Verifiera dig för att konfigurera valvet';

  @override
  String get authenticateToUnlockVault => 'Verifiera dig för att låsa upp valvet';

  @override
  String get vaultBinUsageDialogMessage => 'Några valv använder papperskorgen.';

  @override
  String get renameAlbumDialogLabel => 'Nytt namn';

  @override
  String get renameAlbumDialogLabelAlreadyExistsHelper => 'Katalogen finns redan';

  @override
  String get renameEntrySetPageTitle => 'Ändra namn';

  @override
  String get renameEntrySetPagePatternFieldLabel => 'Namngivningsmönster';

  @override
  String get renameEntrySetPageInsertTooltip => 'Infoga fällt';

  @override
  String get renameEntrySetPagePreviewSectionTitle => 'Förhandsgranska';

  @override
  String get renameProcessorCounter => 'Numrering';

  @override
  String get renameProcessorHash => 'Hash';

  @override
  String get renameProcessorName => 'Namn';

  @override
  String deleteSingleAlbumConfirmationDialogMessage(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ta bort detta album och de $countString objekt som den innehåller?',
      one: 'Ta bort detta album samt det objektet som den innehåller?',
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
      other: 'Ta bort dessa album samt de $countString objekt som de innehåller?',
      one: 'Ta bort dessa album samt det objekt som de innehåller?',
    );
    return '$_temp0';
  }

  @override
  String get exportEntryDialogFormat => 'Format:';

  @override
  String get exportEntryDialogWidth => 'Bredd';

  @override
  String get exportEntryDialogHeight => 'Höjd';

  @override
  String get exportEntryDialogQuality => 'Kvalitet';

  @override
  String get exportEntryDialogWriteMetadata => 'Registrera metadata';

  @override
  String get renameEntryDialogLabel => 'Nytt namn';

  @override
  String get editEntryDialogCopyFromItem => 'Kopiera från annat objekt';

  @override
  String get editEntryDialogTargetFieldsHeader => 'Fällt att modifiera';

  @override
  String get editEntryDateDialogTitle => 'Datum & Tid';

  @override
  String get editEntryDateDialogSetCustom => 'Ange anpassat datum';

  @override
  String get editEntryDateDialogCopyField => 'Kopiera från annat datum';

  @override
  String get editEntryDateDialogExtractFromTitle => 'Extrahera från titel';

  @override
  String get editEntryDateDialogShift => 'Förskjut';

  @override
  String get editEntryDateDialogSourceFileModifiedDate => 'Datum då filen ändrades';

  @override
  String get durationDialogHours => 'Timmar';

  @override
  String get durationDialogMinutes => 'Minuter';

  @override
  String get durationDialogSeconds => 'Sekunder';

  @override
  String get editEntryLocationDialogTitle => 'Plats';

  @override
  String get editEntryLocationDialogSetCustom => 'Ange plats manuellt';

  @override
  String get editEntryLocationDialogChooseOnMap => 'Välj på karta';

  @override
  String get editEntryLocationDialogImportGpx => 'Importera GPX';

  @override
  String get editEntryLocationDialogLatitude => 'Latitud';

  @override
  String get editEntryLocationDialogLongitude => 'Longitud';

  @override
  String get editEntryLocationDialogTimeShift => 'Time shift';

  @override
  String get locationPickerUseThisLocationButton => 'Använd den här platsen';

  @override
  String get editEntryRatingDialogTitle => 'Omdöme';

  @override
  String get removeEntryMetadataDialogTitle => 'Borttagning av metadata';

  @override
  String get removeEntryMetadataDialogAll => 'Allt';

  @override
  String get removeEntryMetadataDialogMore => 'Mer';

  @override
  String get removeEntryMetadataMotionPhotoXmpWarningDialogMessage => 'XMP behövs för att spela upp videon i ett Rörelsefoto.\n\nÄr du säker att du vill ta bort det?';

  @override
  String get videoSpeedDialogLabel => 'Uppspelningshastighet';

  @override
  String get videoStreamSelectionDialogVideo => 'Video';

  @override
  String get videoStreamSelectionDialogAudio => 'Ljud';

  @override
  String get videoStreamSelectionDialogText => 'Undertexter';

  @override
  String get videoStreamSelectionDialogOff => 'Av';

  @override
  String get videoStreamSelectionDialogTrack => 'Spår';

  @override
  String get videoStreamSelectionDialogNoSelection => 'Det finns inga andra spår.';

  @override
  String get genericSuccessFeedback => 'Klar!';

  @override
  String get genericFailureFeedback => 'Misslyckad';

  @override
  String get genericDangerWarningDialogMessage => 'Är du säker?';

  @override
  String get tooManyItemsErrorDialogMessage => 'Försök ingen med färre objekt.';

  @override
  String get menuActionConfigureView => 'Visa';

  @override
  String get menuActionSelect => 'Välj';

  @override
  String get menuActionSelectAll => 'Välj alla';

  @override
  String get menuActionSelectNone => 'Välj ingen';

  @override
  String get menuActionMap => 'Karta';

  @override
  String get menuActionSlideshow => 'Bildspel';

  @override
  String get menuActionStats => 'Statistik';

  @override
  String get viewDialogSortSectionTitle => 'Sortera';

  @override
  String get viewDialogGroupSectionTitle => 'Gruppera';

  @override
  String get viewDialogLayoutSectionTitle => 'Layout';

  @override
  String get viewDialogReverseSortOrder => 'Omvänd sorteringsordning';

  @override
  String get tileLayoutMosaic => 'Mosaik';

  @override
  String get tileLayoutGrid => 'Rutnät';

  @override
  String get tileLayoutList => 'Lista';

  @override
  String get castDialogTitle => 'Uppspelningsenheter';

  @override
  String get coverDialogTabCover => 'Omslag';

  @override
  String get coverDialogTabApp => 'App';

  @override
  String get coverDialogTabColor => 'Färg';

  @override
  String get appPickDialogTitle => 'Välj App';

  @override
  String get appPickDialogNone => 'Igen';

  @override
  String get aboutPageTitle => 'Om';

  @override
  String get aboutLinkLicense => 'Licens';

  @override
  String get aboutLinkPolicy => 'IntegritetsPolicy';

  @override
  String get aboutBugSectionTitle => 'Felrapport';

  @override
  String get aboutBugSaveLogInstruction => 'Spara appens log till en fil';

  @override
  String get aboutBugCopyInfoInstruction => 'Kopiera systemInformation';

  @override
  String get aboutBugCopyInfoButton => 'Kopiera';

  @override
  String get aboutBugReportInstruction => 'Rapportera på GitHub tillsammans med bifogade loggar och systeminformation';

  @override
  String get aboutBugReportButton => 'Rapportera';

  @override
  String get aboutDataUsageSectionTitle => 'DataAnvänding';

  @override
  String get aboutDataUsageData => 'Data';

  @override
  String get aboutDataUsageCache => 'Cache';

  @override
  String get aboutDataUsageDatabase => 'Databas';

  @override
  String get aboutDataUsageMisc => 'Diverse';

  @override
  String get aboutDataUsageInternal => 'Internt';

  @override
  String get aboutDataUsageExternal => 'Externt';

  @override
  String get aboutDataUsageClearCache => 'Rensa Cacheminnet';

  @override
  String get aboutCreditsSectionTitle => 'Tillkännagivande';

  @override
  String get aboutCreditsWorldAtlas1 => 'Den här appen använder en TopoJSON fil från';

  @override
  String get aboutCreditsWorldAtlas2 => 'under ISC Licens.';

  @override
  String get aboutTranslatorsSectionTitle => 'Översättare';

  @override
  String get aboutLicensesSectionTitle => 'Öppen-Källkod Licenser';

  @override
  String get aboutLicensesBanner => 'Den här applikationen använder följande paket och bibliotek under öppen källkod-licens.';

  @override
  String get aboutLicensesAndroidLibrariesSectionTitle => 'Android Bibliotek';

  @override
  String get aboutLicensesFlutterPluginsSectionTitle => 'Flutter-programtillägg';

  @override
  String get aboutLicensesFlutterPackagesSectionTitle => 'Flutter-paket';

  @override
  String get aboutLicensesDartPackagesSectionTitle => 'Dart-paket';

  @override
  String get aboutLicensesShowAllButtonLabel => 'Visa alla licenser';

  @override
  String get policyPageTitle => 'IntegritetsPolicy';

  @override
  String get collectionPageTitle => 'Samling';

  @override
  String get collectionPickPageTitle => 'Välj';

  @override
  String get collectionSelectPageTitle => 'Välj objekt';

  @override
  String get collectionActionShowTitleSearch => 'Visa titelfilter';

  @override
  String get collectionActionHideTitleSearch => 'Göm titelfilter';

  @override
  String get collectionActionAddDynamicAlbum => 'Lägg till dynamiskt album';

  @override
  String get collectionActionAddShortcut => 'Lägg till genväg';

  @override
  String get collectionActionSetHome => 'Välj som startsida';

  @override
  String get collectionActionEmptyBin => 'Töm papperskorgen';

  @override
  String get collectionActionCopy => 'kopiera till album';

  @override
  String get collectionActionMove => 'Flytta till album';

  @override
  String get collectionActionRescan => 'Scanna om';

  @override
  String get collectionActionEdit => 'Redigera';

  @override
  String get collectionSearchTitlesHintText => 'Sök titlar';

  @override
  String get collectionGroupAlbum => 'Efter album';

  @override
  String get collectionGroupMonth => 'Efter månad';

  @override
  String get collectionGroupDay => 'Efter dag';

  @override
  String get collectionGroupNone => 'Gruppera inte';

  @override
  String get sectionUnknown => 'Okänd';

  @override
  String get dateToday => 'Idag';

  @override
  String get dateYesterday => 'Igår';

  @override
  String get dateThisMonth => 'Den här månaden';

  @override
  String collectionDeleteFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Misslyckades med att ta bort $count objekt',
    );
    return '$_temp0';
  }

  @override
  String collectionCopyFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Misslyckades med att kopiera $count objekt',
      one: 'Misslyckades med att kopiera 1 objekt',
    );
    return '$_temp0';
  }

  @override
  String collectionMoveFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Misslyckades med att flytta $count objekt',
      one: 'Misslyckades med att flytta 1 objekt',
    );
    return '$_temp0';
  }

  @override
  String collectionRenameFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Misslyckades med att byta namn på $count objekt',
      one: 'Misslyckades med att byta namn på 1 objekt',
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
      other: 'Misslyckades med att ändra $countString objekt',
      one: 'Misslyckades med att ändra 1 objekt',
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
      other: 'Misslyckades med att exportera $countString sidor',
      one: 'Misslyckades med att exportera 1 sida',
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
      other: 'Kopierade$countString objekt',
      one: 'Kopierade 1 objekt',
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
      other: 'Flyttade $countString objekt',
      one: 'Flyttade 1 objekt',
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
      other: 'Ändrat namn på $countString objekt',
      one: 'Ändrat namn på 1 objekt',
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
      other: 'Ändrat $countString objekt',
      one: 'Ändrat 1 objekt',
    );
    return '$_temp0';
  }

  @override
  String get collectionEmptyFavourites => 'Inga favoriter';

  @override
  String get collectionEmptyVideos => 'Inga videor';

  @override
  String get collectionEmptyImages => 'Inga bilder';

  @override
  String get collectionEmptyGrantAccessButtonLabel => 'Bevilja åtkomst';

  @override
  String get collectionSelectSectionTooltip => 'Markera sektion';

  @override
  String get collectionDeselectSectionTooltip => 'Avmarkera sektion';

  @override
  String get drawerAboutButton => 'Om';

  @override
  String get drawerSettingsButton => 'Inställningar';

  @override
  String get drawerCollectionAll => 'Hela samlingen';

  @override
  String get drawerCollectionFavourites => 'Favoriter';

  @override
  String get drawerCollectionImages => 'Bilder';

  @override
  String get drawerCollectionVideos => 'Videor';

  @override
  String get drawerCollectionAnimated => 'Animerade';

  @override
  String get drawerCollectionMotionPhotos => 'Rörelsefoton';

  @override
  String get drawerCollectionPanoramas => 'Panoraman';

  @override
  String get drawerCollectionRaws => 'Bilder i råformat';

  @override
  String get drawerCollectionSphericalVideos => '360°-Videor';

  @override
  String get drawerAlbumPage => 'Album';

  @override
  String get drawerCountryPage => 'Länder';

  @override
  String get drawerPlacePage => 'Platser';

  @override
  String get drawerTagPage => 'Etiketter';

  @override
  String get sortByDate => 'Efter datum';

  @override
  String get sortByName => 'Efter namn';

  @override
  String get sortByItemCount => 'Efter antal objekt';

  @override
  String get sortBySize => 'Efter storlek';

  @override
  String get sortByAlbumFileName => 'Efter album & filnamn';

  @override
  String get sortByRating => 'Efter omdömen';

  @override
  String get sortByDuration => 'Efter spellängd';

  @override
  String get sortByPath => 'By path';

  @override
  String get sortOrderNewestFirst => 'Nyast först';

  @override
  String get sortOrderOldestFirst => 'Äldst först';

  @override
  String get sortOrderAtoZ => 'A till Ö';

  @override
  String get sortOrderZtoA => 'Ö till A';

  @override
  String get sortOrderHighestFirst => 'Högst först';

  @override
  String get sortOrderLowestFirst => 'Lägst först';

  @override
  String get sortOrderLargestFirst => 'Störst först';

  @override
  String get sortOrderSmallestFirst => 'Minst först';

  @override
  String get sortOrderShortestFirst => 'Kortast först';

  @override
  String get sortOrderLongestFirst => 'Längst först';

  @override
  String get albumGroupTier => 'Efter nivå';

  @override
  String get albumGroupType => 'Efter typ';

  @override
  String get albumGroupVolume => 'Efter lagringsmedia';

  @override
  String get albumGroupNone => 'Gruppera inte';

  @override
  String get albumMimeTypeMixed => 'Blandat';

  @override
  String get albumPickPageTitleCopy => 'Kopiera till Album';

  @override
  String get albumPickPageTitleExport => 'Exportera till Album';

  @override
  String get albumPickPageTitleMove => 'Flytta till Album';

  @override
  String get albumPickPageTitlePick => 'Välj Album';

  @override
  String get albumCamera => 'Kamera';

  @override
  String get albumDownload => 'Nedladdningar';

  @override
  String get albumScreenshots => 'Skärmbilder';

  @override
  String get albumScreenRecordings => 'Skärminspelningar';

  @override
  String get albumVideoCaptures => 'Videoupptagningar';

  @override
  String get albumPageTitle => 'Album';

  @override
  String get albumEmpty => 'Inga album';

  @override
  String get createAlbumButtonLabel => 'SKAPA';

  @override
  String get newFilterBanner => 'ny';

  @override
  String get countryPageTitle => 'Länder';

  @override
  String get countryEmpty => 'Inga länder';

  @override
  String get statePageTitle => 'Delstater';

  @override
  String get stateEmpty => 'Inga delstater';

  @override
  String get placePageTitle => 'Platser';

  @override
  String get placeEmpty => 'Inga platser';

  @override
  String get tagPageTitle => 'Etiketter';

  @override
  String get tagEmpty => 'Inga etiketter';

  @override
  String get binPageTitle => 'Papperskorgen';

  @override
  String get explorerPageTitle => 'Utforskaren';

  @override
  String get explorerActionSelectStorageVolume => 'Välj lagringsplats';

  @override
  String get selectStorageVolumeDialogTitle => 'Välj Lagringsplats';

  @override
  String get searchCollectionFieldHint => 'Sök i samling';

  @override
  String get searchRecentSectionTitle => 'Nyligen';

  @override
  String get searchDateSectionTitle => 'Datum';

  @override
  String get searchFormatSectionTitle => 'Formats';

  @override
  String get searchAlbumsSectionTitle => 'Album';

  @override
  String get searchCountriesSectionTitle => 'Länder';

  @override
  String get searchStatesSectionTitle => 'Delstater';

  @override
  String get searchPlacesSectionTitle => 'Platser';

  @override
  String get searchTagsSectionTitle => 'Etiketter';

  @override
  String get searchRatingSectionTitle => 'Omdöme';

  @override
  String get searchMetadataSectionTitle => 'Metadata';

  @override
  String get settingsPageTitle => 'Inställningar';

  @override
  String get settingsSystemDefault => 'Systemets standard';

  @override
  String get settingsDefault => 'Standard';

  @override
  String get settingsDisabled => 'Inaktiverad';

  @override
  String get settingsAskEverytime => 'Fråga varje gång';

  @override
  String get settingsModificationWarningDialogMessage => 'Andra inställningar kommer att ändras.';

  @override
  String get settingsSearchFieldLabel => 'Sök efter inställningar';

  @override
  String get settingsSearchEmpty => 'Inga matchande inställningar hittades';

  @override
  String get settingsActionExport => 'Exportera';

  @override
  String get settingsActionExportDialogTitle => 'Exportera';

  @override
  String get settingsActionImport => 'Importera';

  @override
  String get settingsActionImportDialogTitle => 'Importera';

  @override
  String get appExportCovers => 'Omslagsbilder';

  @override
  String get appExportDynamicAlbums => 'Dynamiska album';

  @override
  String get appExportFavourites => 'Favoriter';

  @override
  String get appExportSettings => 'Inställningar';

  @override
  String get settingsNavigationSectionTitle => 'Navigering';

  @override
  String get settingsHomeTile => 'Startsida';

  @override
  String get settingsHomeDialogTitle => 'Startsida';

  @override
  String get setHomeCustom => 'Anpassad';

  @override
  String get settingsShowBottomNavigationBar => 'Visa nedre navigeringspanel';

  @override
  String get settingsKeepScreenOnTile => 'Behåll skärmen aktiv';

  @override
  String get settingsKeepScreenOnDialogTitle => 'Behåll Skärmen Aktiv';

  @override
  String get settingsDoubleBackExit => 'Tryck ”bakåt” två gånger för att avsluta';

  @override
  String get settingsConfirmationTile => 'Bekräftelsedialoger';

  @override
  String get settingsConfirmationDialogTitle => 'Bekräftelsedialoger';

  @override
  String get settingsConfirmationBeforeDeleteItems => 'Fråga innan objekt raderas permanent';

  @override
  String get settingsConfirmationBeforeMoveToBinItems => 'Fråga innan objekt flyttas till papperskorgen';

  @override
  String get settingsConfirmationBeforeMoveUndatedItems => 'Fråga innan odaterade objekt flyttas';

  @override
  String get settingsConfirmationAfterMoveToBinItems => 'Visa ett meddelande efter att objekt flyttats till papperskorgen';

  @override
  String get settingsConfirmationVaultDataLoss => 'Visa varning för dataförlust i valv';

  @override
  String get settingsNavigationDrawerTile => 'Navigeringsmeny';

  @override
  String get settingsNavigationDrawerEditorPageTitle => 'Navigeringsmeny';

  @override
  String get settingsNavigationDrawerBanner => 'Tryck och håll i för att flytta och arrangera om objekt i menyn.';

  @override
  String get settingsNavigationDrawerTabTypes => 'Kategorier';

  @override
  String get settingsNavigationDrawerTabAlbums => 'Album';

  @override
  String get settingsNavigationDrawerTabPages => 'Sidor';

  @override
  String get settingsNavigationDrawerAddAlbum => 'Lägg till album';

  @override
  String get settingsThumbnailSectionTitle => 'Miniatyrbilder';

  @override
  String get settingsThumbnailOverlayTile => 'Översikt';

  @override
  String get settingsThumbnailOverlayPageTitle => 'Översikt';

  @override
  String get settingsThumbnailShowHdrIcon => 'Visa HDR-ikon';

  @override
  String get settingsThumbnailShowFavouriteIcon => 'Visa favoritikon';

  @override
  String get settingsThumbnailShowTagIcon => 'Visa etikettikon';

  @override
  String get settingsThumbnailShowLocationIcon => 'Visa lokaliseringsikon';

  @override
  String get settingsThumbnailShowMotionPhotoIcon => 'Visa ikon för Rörelsefoto';

  @override
  String get settingsThumbnailShowRating => 'Visa omdömen';

  @override
  String get settingsThumbnailShowRawIcon => 'Visa ikon för råbildsformatet RAW';

  @override
  String get settingsThumbnailShowVideoDuration => 'Visa videons längd';

  @override
  String get settingsCollectionQuickActionsTile => 'Genvägar';

  @override
  String get settingsCollectionQuickActionEditorPageTitle => 'Genvägar';

  @override
  String get settingsCollectionQuickActionTabBrowsing => 'Bläddra';

  @override
  String get settingsCollectionQuickActionTabSelecting => 'Välja';

  @override
  String get settingsCollectionBrowsingQuickActionEditorBanner => 'Tryck och håll nere för att flytta knappar och välj på så vis vilka åtgärder som skall visas vid bläddring bland objekt.';

  @override
  String get settingsCollectionSelectionQuickActionEditorBanner => 'Tryck och håll nere för att flytta knappar och välj på så vis vilka åtgärder som skall visas när objekt väljs.';

  @override
  String get settingsCollectionBurstPatternsTile => 'Seriefotograferingsmönster';

  @override
  String get settingsCollectionBurstPatternsNone => 'Inget';

  @override
  String get settingsViewerSectionTitle => 'Bildvisare';

  @override
  String get settingsViewerGestureSideTapNext => 'Tryck på skärmens kanter för att visa tidigare/nästa objekt';

  @override
  String get settingsViewerUseCutout => 'Använd skärmutskärningsområdet';

  @override
  String get settingsViewerMaximumBrightness => 'Maximal ljusstyrka';

  @override
  String get settingsMotionPhotoAutoPlay => 'Spela automatiskt upp rörelsefoton';

  @override
  String get settingsImageBackground => 'Bakgrund för bilder';

  @override
  String get settingsViewerQuickActionsTile => 'Genvägar';

  @override
  String get settingsViewerQuickActionEditorPageTitle => 'Genvägar';

  @override
  String get settingsViewerQuickActionEditorBanner => 'Tryck och håll ner för att flytta och på så vis välja vilka åtgärder som skall visas i bildvisaren.';

  @override
  String get settingsViewerQuickActionEditorDisplayedButtonsSectionTitle => 'Knappar Som Visas';

  @override
  String get settingsViewerQuickActionEditorAvailableButtonsSectionTitle => 'Tillgängliga Knappar';

  @override
  String get settingsViewerQuickActionEmpty => 'Inga knappar';

  @override
  String get settingsViewerOverlayTile => 'Overlay';

  @override
  String get settingsViewerOverlayPageTitle => 'Overlay';

  @override
  String get settingsViewerShowOverlayOnOpening => 'Visas vid öppnande';

  @override
  String get settingsViewerShowHistogram => 'Visa histogram';

  @override
  String get settingsViewerShowMinimap => 'Visa miniatyrkarta';

  @override
  String get settingsViewerShowInformation => 'Visa information';

  @override
  String get settingsViewerShowInformationSubtitle => 'Visa titel, datum, plats, etc.';

  @override
  String get settingsViewerShowRatingTags => 'Visa omdöme & etiketter';

  @override
  String get settingsViewerShowShootingDetails => 'Visa bildtagningsdetaljer';

  @override
  String get settingsViewerShowDescription => 'Visa beskrivning';

  @override
  String get settingsViewerShowOverlayThumbnails => 'Visa miniatyrbilder';

  @override
  String get settingsViewerEnableOverlayBlurEffect => 'Effekt för oskärpa';

  @override
  String get settingsViewerSlideshowTile => 'Bildspel';

  @override
  String get settingsViewerSlideshowPageTitle => 'Bildspel';

  @override
  String get settingsSlideshowRepeat => 'Upprepa';

  @override
  String get settingsSlideshowShuffle => 'Blanda';

  @override
  String get settingsSlideshowFillScreen => 'Helskärm';

  @override
  String get settingsSlideshowAnimatedZoomEffect => 'Animerad inzoomningseffekt';

  @override
  String get settingsSlideshowTransitionTile => 'Övergång';

  @override
  String get settingsSlideshowIntervalTile => 'Intervall';

  @override
  String get settingsSlideshowVideoPlaybackTile => 'Videouppspelning';

  @override
  String get settingsSlideshowVideoPlaybackDialogTitle => 'Videouppspelning';

  @override
  String get settingsVideoPageTitle => 'Videoinställningar';

  @override
  String get settingsVideoSectionTitle => 'Video';

  @override
  String get settingsVideoShowVideos => 'Visa videor';

  @override
  String get settingsVideoPlaybackTile => 'Uppspelning';

  @override
  String get settingsVideoPlaybackPageTitle => 'Uppspelning';

  @override
  String get settingsVideoEnableHardwareAcceleration => 'Hårdvaruacceleration';

  @override
  String get settingsVideoAutoPlay => 'Automatisk uppspelning';

  @override
  String get settingsVideoLoopModeTile => 'Upprepningsläge';

  @override
  String get settingsVideoLoopModeDialogTitle => 'Upprepningsläge';

  @override
  String get settingsVideoResumptionModeTile => 'Återuppta uppspelning';

  @override
  String get settingsVideoResumptionModeDialogTitle => 'Återuppta Uppspelning';

  @override
  String get settingsVideoBackgroundMode => 'Bakgrundsläge';

  @override
  String get settingsVideoBackgroundModeDialogTitle => 'Bakgrundsläge';

  @override
  String get settingsVideoControlsTile => 'Reglage';

  @override
  String get settingsVideoControlsPageTitle => 'Reglage';

  @override
  String get settingsVideoButtonsTile => 'Knappar';

  @override
  String get settingsVideoGestureDoubleTapTogglePlay => 'Tryck två gånger för att spela upp/pausa';

  @override
  String get settingsVideoGestureSideDoubleTapSeek => 'Tryck två gånger på skärmkanterna för att spola bakåt/framåt';

  @override
  String get settingsVideoGestureVerticalDragBrightnessVolume => 'Svep upp och ner för att anpassa ljusstyrka/ljudvolym';

  @override
  String get settingsSubtitleThemeTile => 'Undertexter';

  @override
  String get settingsSubtitleThemePageTitle => 'Undertexter';

  @override
  String get settingsSubtitleThemeSample => 'Detta är ett exempel.';

  @override
  String get settingsSubtitleThemeTextAlignmentTile => 'Textplacering';

  @override
  String get settingsSubtitleThemeTextAlignmentDialogTitle => 'Textplacering';

  @override
  String get settingsSubtitleThemeTextPositionTile => 'Textposition';

  @override
  String get settingsSubtitleThemeTextPositionDialogTitle => 'Textposition';

  @override
  String get settingsSubtitleThemeTextSize => 'Textstorlek';

  @override
  String get settingsSubtitleThemeShowOutline => 'Visa kantlinjer och skuggor';

  @override
  String get settingsSubtitleThemeTextColor => 'Textfärg';

  @override
  String get settingsSubtitleThemeTextOpacity => 'Textens genomskinlighet';

  @override
  String get settingsSubtitleThemeBackgroundColor => 'Bakgrundsfärg';

  @override
  String get settingsSubtitleThemeBackgroundOpacity => 'Bakgrundens genomskinlighet';

  @override
  String get settingsSubtitleThemeTextAlignmentLeft => 'Vänster';

  @override
  String get settingsSubtitleThemeTextAlignmentCenter => 'Centrerad';

  @override
  String get settingsSubtitleThemeTextAlignmentRight => 'Höger';

  @override
  String get settingsPrivacySectionTitle => 'Sekretess';

  @override
  String get settingsAllowInstalledAppAccess => 'Tillåt åtkomst till applikationsförteckning';

  @override
  String get settingsAllowInstalledAppAccessSubtitle => 'Används för att förbättra visning av album';

  @override
  String get settingsAllowErrorReporting => 'Tillåt anonym felrapportering';

  @override
  String get settingsSaveSearchHistory => 'Spara sökhistorik';

  @override
  String get settingsEnableBin => 'Använd papperskorg';

  @override
  String get settingsEnableBinSubtitle => 'Behåll borttagna objekt i 30 dagar';

  @override
  String get settingsDisablingBinWarningDialogMessage => 'Objekt i papperskorgen kommer att tas bort permanent.';

  @override
  String get settingsAllowMediaManagement => 'Tillåt hantering av media';

  @override
  String get settingsHiddenItemsTile => 'Gömda objekt';

  @override
  String get settingsHiddenItemsPageTitle => 'Gömda Objekt';

  @override
  String get settingsHiddenFiltersBanner => 'Bilder och filmer som matchar gömda filter kommer inte visas i dina samlingar.';

  @override
  String get settingsHiddenFiltersEmpty => 'Inga dolda filter';

  @override
  String get settingsStorageAccessTile => 'Åtkomst till lagringsutrymme';

  @override
  String get settingsStorageAccessPageTitle => 'lagringsåtkomst';

  @override
  String get settingsStorageAccessBanner => 'För vissa kataloger krävs ett särskilt åtkomsttillstånd för att ändra filer i dem. Här kan du granska kataloger vilket du tidigare gett detta tillstånd.';

  @override
  String get settingsStorageAccessEmpty => 'Inga speciella åtkomsttillstånd';

  @override
  String get settingsStorageAccessRevokeTooltip => 'Upphäv';

  @override
  String get settingsAccessibilitySectionTitle => 'Tillgänglighet';

  @override
  String get settingsRemoveAnimationsTile => 'Inaktivera animationer';

  @override
  String get settingsRemoveAnimationsDialogTitle => 'Inaktivera Animationer';

  @override
  String get settingsTimeToTakeActionTile => 'Tid innan åtgärd vidtages';

  @override
  String get settingsAccessibilityShowPinchGestureAlternatives => 'Visa alternativ till multi-tryckgester';

  @override
  String get settingsDisplaySectionTitle => 'Skärm';

  @override
  String get settingsThemeBrightnessTile => 'Tema';

  @override
  String get settingsThemeBrightnessDialogTitle => 'Tema';

  @override
  String get settingsThemeColorHighlights => 'Färgbetoning';

  @override
  String get settingsThemeEnableDynamicColor => 'Dynamiska färger';

  @override
  String get settingsDisplayRefreshRateModeTile => 'Skärmens uppdateringshastighet';

  @override
  String get settingsDisplayRefreshRateModeDialogTitle => 'Uppdateringshastighet';

  @override
  String get settingsDisplayUseTvInterface => 'Android TV-gränssnitt';

  @override
  String get settingsLanguageSectionTitle => 'Språk & Format';

  @override
  String get settingsLanguageTile => 'Språk';

  @override
  String get settingsLanguagePageTitle => 'Språk';

  @override
  String get settingsCoordinateFormatTile => 'Koordinatformat';

  @override
  String get settingsCoordinateFormatDialogTitle => 'Koordinatformat';

  @override
  String get settingsUnitSystemTile => 'Enheter';

  @override
  String get settingsUnitSystemDialogTitle => 'Enheter';

  @override
  String get settingsForceWesternArabicNumeralsTile => 'Tvinga arabiska siffror';

  @override
  String get settingsScreenSaverPageTitle => 'Skärmsläckare';

  @override
  String get settingsWidgetPageTitle => 'Fotoram';

  @override
  String get settingsWidgetShowOutline => 'Kantlinje';

  @override
  String get settingsWidgetOpenPage => 'När widgeten trycks på';

  @override
  String get settingsWidgetDisplayedItem => 'Objekt som visas';

  @override
  String get settingsCollectionTile => 'Samling';

  @override
  String get statsPageTitle => 'Statistik';

  @override
  String statsWithGps(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString objekt som har sparad platsdata',
      one: '1 objekt som har sparad platsdata',
    );
    return '$_temp0';
  }

  @override
  String get statsTopCountriesSectionTitle => 'Populära Länder';

  @override
  String get statsTopStatesSectionTitle => 'Populära Delstater';

  @override
  String get statsTopPlacesSectionTitle => 'Populära Platser';

  @override
  String get statsTopTagsSectionTitle => 'Populära Etiketter';

  @override
  String get statsTopAlbumsSectionTitle => 'Populära Album';

  @override
  String get viewerOpenPanoramaButtonLabel => 'ÖPPNA PANORAMA';

  @override
  String get viewerSetWallpaperButtonLabel => 'ANGE SOM BAKGRUNDSBILD';

  @override
  String get viewerErrorUnknown => 'Ojsan!';

  @override
  String get viewerErrorDoesNotExist => 'Filen finns ej längre.';

  @override
  String get viewerInfoPageTitle => 'Info';

  @override
  String get viewerInfoBackToViewerTooltip => 'Tillbaka till bildvisaren';

  @override
  String get viewerInfoUnknown => 'okänd';

  @override
  String get viewerInfoLabelDescription => 'Beskrivning';

  @override
  String get viewerInfoLabelTitle => 'Titel';

  @override
  String get viewerInfoLabelDate => 'Datum';

  @override
  String get viewerInfoLabelResolution => 'Upplösning';

  @override
  String get viewerInfoLabelSize => 'Storlek';

  @override
  String get viewerInfoLabelUri => 'URI';

  @override
  String get viewerInfoLabelPath => 'Sökväg';

  @override
  String get viewerInfoLabelDuration => 'Varaktighet';

  @override
  String get viewerInfoLabelOwner => 'Ägare';

  @override
  String get viewerInfoLabelCoordinates => 'Koordinater';

  @override
  String get viewerInfoLabelAddress => 'Adress';

  @override
  String get mapStyleDialogTitle => 'Kartstil';

  @override
  String get mapStyleTooltip => 'Välj stil på karta';

  @override
  String get mapZoomInTooltip => 'Förstora';

  @override
  String get mapZoomOutTooltip => 'Förminska';

  @override
  String get mapPointNorthUpTooltip => 'Rikta norr uppåt';

  @override
  String get mapAttributionOsmData => 'Kartdata © [OpenStreetMap](https://www.openstreetmap.org/copyright) bidragsgivare';

  @override
  String get mapAttributionOsmLiberty => 'Brickor av [OpenMapTiles](https://www.openmaptiles.org/), [CC BY](http://creativecommons.org/licenses/by/4.0) • Tillhandahållen av [OSM Americana](https://tile.ourmap.us)';

  @override
  String get mapAttributionOpenTopoMap => '[SRTM](https://www.earthdata.nasa.gov/sensors/srtm) | Brickor av [OpenTopoMap](https://opentopomap.org/), [CC BY-SA](https://creativecommons.org/licenses/by-sa/3.0/)';

  @override
  String get mapAttributionOsmHot => 'Brickor av [HOT](https://www.hotosm.org/) • Tillhandahållen av [OSM France](https://openstreetmap.fr/)';

  @override
  String get mapAttributionStamen => 'Brickor av [Stamen Design](https://stamen.com), [CC BY 3.0](https://creativecommons.org/licenses/by/3.0)';

  @override
  String get openMapPageTooltip => 'Visa på kartsidan';

  @override
  String get mapEmptyRegion => 'Inga bilder i denna region';

  @override
  String get viewerInfoOpenEmbeddedFailureFeedback => 'Misslyckades att extrahera inbäddad data';

  @override
  String get viewerInfoOpenLinkText => 'Öppna';

  @override
  String get viewerInfoViewXmlLinkText => 'Visa XML';

  @override
  String get viewerInfoSearchFieldLabel => 'Sök metadata';

  @override
  String get viewerInfoSearchEmpty => 'Inga matchande nycklar';

  @override
  String get viewerInfoSearchSuggestionDate => 'Datum & tid';

  @override
  String get viewerInfoSearchSuggestionDescription => 'Beskrivning';

  @override
  String get viewerInfoSearchSuggestionDimensions => 'Dimensioner';

  @override
  String get viewerInfoSearchSuggestionResolution => 'Upplösning';

  @override
  String get viewerInfoSearchSuggestionRights => 'Rättigheter';

  @override
  String get wallpaperUseScrollEffect => 'Använd bläddringsanimation på hemskärmen';

  @override
  String get tagEditorPageTitle => 'Redigera Etiketter';

  @override
  String get tagEditorPageNewTagFieldLabel => 'Ny etikett';

  @override
  String get tagEditorPageAddTagTooltip => 'Lägg till etikett';

  @override
  String get tagEditorSectionRecent => 'Senaste';

  @override
  String get tagEditorSectionPlaceholders => 'Platshållare';

  @override
  String get tagEditorDiscardDialogMessage => 'Vill du kasta förändringarna?';

  @override
  String get tagPlaceholderCountry => 'Land';

  @override
  String get tagPlaceholderState => 'Delstat';

  @override
  String get tagPlaceholderPlace => 'Plats';

  @override
  String get panoramaEnableSensorControl => 'Aktivera sensorstyrning';

  @override
  String get panoramaDisableSensorControl => 'Inaktivera sensorstyrning';

  @override
  String get sourceViewerPageTitle => 'Källa';

  @override
  String get filePickerShowHiddenFiles => 'Visa dolda filer';

  @override
  String get filePickerDoNotShowHiddenFiles => 'Visa inte dolda filer';

  @override
  String get filePickerOpenFrom => 'Öppna från';

  @override
  String get filePickerNoItems => 'Inga objekt';

  @override
  String get filePickerUseThisFolder => 'Använd denna katalog';
}
