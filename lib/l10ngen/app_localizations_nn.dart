// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Norwegian Nynorsk (`nn`).
class AppLocalizationsNn extends AppLocalizations {
  AppLocalizationsNn([String locale = 'nn']) : super(locale);

  @override
  String get appName => 'Aves';

  @override
  String get welcomeMessage => 'Velkomen til Aves';

  @override
  String get welcomeOptional => 'Valfritt';

  @override
  String get welcomeTermsToggle => 'Eg samtykkjer til krava og føresetnadane';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count er valde',
      one: '$count er vald',
    );
    return '$_temp0';
  }

  @override
  String columnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kolonnar',
      one: '$count kolonne',
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
      other: '$countString minutt',
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
  String get applyButtonLabel => 'NYTTA';

  @override
  String get deleteButtonLabel => 'SLETT';

  @override
  String get nextButtonLabel => 'NESTE';

  @override
  String get showButtonLabel => 'VIS';

  @override
  String get hideButtonLabel => 'SKJUL';

  @override
  String get continueButtonLabel => 'HALD FRAM';

  @override
  String get saveCopyButtonLabel => 'SPAR KOPI';

  @override
  String get applyTooltip => 'Nytt';

  @override
  String get cancelTooltip => 'Avbryt';

  @override
  String get changeTooltip => 'Brigd';

  @override
  String get clearTooltip => 'Tøm';

  @override
  String get previousTooltip => 'Førre';

  @override
  String get nextTooltip => 'Neste';

  @override
  String get showTooltip => 'Vis';

  @override
  String get hideTooltip => 'Skjul';

  @override
  String get actionRemove => 'Tak bort';

  @override
  String get resetTooltip => 'Still attende';

  @override
  String get saveTooltip => 'Spar';

  @override
  String get stopTooltip => 'Stop';

  @override
  String get pickTooltip => 'Vel';

  @override
  String get doubleBackExitMessage => 'Trykk «attende» igjen for å gå ut.';

  @override
  String get doNotAskAgain => 'Ikkje spør att';

  @override
  String get sourceStateLoading => 'Hentar inn';

  @override
  String get sourceStateCataloguing => 'Cataloguing';

  @override
  String get sourceStateLocatingCountries => 'Finn land';

  @override
  String get sourceStateLocatingPlaces => 'Finn stadar';

  @override
  String get chipActionDelete => 'Slett';

  @override
  String get chipActionRemove => 'Remove';

  @override
  String get chipActionShowCollection => 'Vis i Samling';

  @override
  String get chipActionGoToAlbumPage => 'Vis i Album';

  @override
  String get chipActionGoToCountryPage => 'Vis i Land';

  @override
  String get chipActionGoToPlacePage => 'Vis i Stadar';

  @override
  String get chipActionGoToTagPage => 'Vis i Merke';

  @override
  String get chipActionGoToExplorerPage => 'Show in Explorer';

  @override
  String get chipActionDecompose => 'Split';

  @override
  String get chipActionFilterOut => 'Tak ut';

  @override
  String get chipActionFilterIn => 'Tak med';

  @override
  String get chipActionHide => 'Skjul';

  @override
  String get chipActionLock => 'Lås';

  @override
  String get chipActionPin => 'Fest til toppen';

  @override
  String get chipActionUnpin => 'losna ifrå toppen';

  @override
  String get chipActionRename => 'Byt namn';

  @override
  String get chipActionSetCover => 'Sett omslag';

  @override
  String get chipActionShowCountryStates => 'Vis landsdelar';

  @override
  String get chipActionCreateAlbum => 'Lag eit album';

  @override
  String get chipActionCreateVault => 'Kvelv';

  @override
  String get chipActionConfigureVault => 'Set opp kvelvet';

  @override
  String get entryActionCopyToClipboard => 'Kopier til utklippstavla';

  @override
  String get entryActionDelete => 'Slett';

  @override
  String get entryActionConvert => 'Lag om';

  @override
  String get entryActionExport => 'Før ut';

  @override
  String get entryActionInfo => 'Opplysingar';

  @override
  String get entryActionRename => 'Byt namn';

  @override
  String get entryActionRestore => 'Gjenopprett';

  @override
  String get entryActionRotateCCW => 'Snu imot klokka';

  @override
  String get entryActionRotateCW => 'Snu med klokka';

  @override
  String get entryActionFlip => 'Vend vassrett';

  @override
  String get entryActionPrint => 'Skriv ut';

  @override
  String get entryActionShare => 'Del';

  @override
  String get entryActionShareImageOnly => 'Del berre bilete';

  @override
  String get entryActionShareVideoOnly => 'Del berre video';

  @override
  String get entryActionViewSource => 'Vis kjelda';

  @override
  String get entryActionShowGeoTiffOnMap => 'Vis som overlagskart';

  @override
  String get entryActionConvertMotionPhotoToStillImage => 'Lag om til eit stillbilete';

  @override
  String get entryActionViewMotionPhotoVideo => 'Opne video';

  @override
  String get entryActionEdit => 'Brigd';

  @override
  String get entryActionOpen => 'Opne med';

  @override
  String get entryActionSetAs => 'Sett som';

  @override
  String get entryActionCast => 'Cast';

  @override
  String get entryActionOpenMap => 'Vis i kartapp';

  @override
  String get entryActionRotateScreen => 'Snu skjermen';

  @override
  String get entryActionAddFavourite => 'Lik';

  @override
  String get entryActionRemoveFavourite => 'Stogg å like';

  @override
  String get videoActionCaptureFrame => 'Grip biletet';

  @override
  String get videoActionMute => 'Døyv';

  @override
  String get videoActionUnmute => 'Ikkje døyv';

  @override
  String get videoActionPause => 'Stans';

  @override
  String get videoActionPlay => 'Spel av';

  @override
  String get videoActionReplay10 => 'Spol 10 sekund bakover';

  @override
  String get videoActionSkip10 => 'Spol 10 sekund framover';

  @override
  String get videoActionShowPreviousFrame => 'Show previous frame';

  @override
  String get videoActionShowNextFrame => 'Show next frame';

  @override
  String get videoActionSelectStreams => 'Vel spor';

  @override
  String get videoActionSetSpeed => 'Avspelingssnøggleik';

  @override
  String get videoActionABRepeat => 'A-B repeat';

  @override
  String get videoRepeatActionSetStart => 'Set start';

  @override
  String get videoRepeatActionSetEnd => 'Set end';

  @override
  String get viewerActionSettings => 'Innstillingar';

  @override
  String get viewerActionLock => 'Lås visinga';

  @override
  String get viewerActionUnlock => 'Lås opp visinga';

  @override
  String get slideshowActionResume => 'Hald fram';

  @override
  String get slideshowActionShowInCollection => 'Vis i Samling';

  @override
  String get entryInfoActionEditDate => 'Brigd datoen og tida';

  @override
  String get entryInfoActionEditLocation => 'Brigd stadsetjinga';

  @override
  String get entryInfoActionEditTitleDescription => 'Brigd namnet og utgreiinga';

  @override
  String get entryInfoActionEditRating => 'Brigd omdøminga';

  @override
  String get entryInfoActionEditTags => 'Brigd merka';

  @override
  String get entryInfoActionRemoveMetadata => 'Tak bort metadata';

  @override
  String get entryInfoActionExportMetadata => 'Før ut metadata';

  @override
  String get entryInfoActionRemoveLocation => 'Ta bort stadsetjinga';

  @override
  String get editorActionTransform => 'Form om';

  @override
  String get editorTransformCrop => 'Klipp til';

  @override
  String get editorTransformRotate => 'Snu';

  @override
  String get cropAspectRatioFree => 'Frihand';

  @override
  String get cropAspectRatioOriginal => 'Opphavleg';

  @override
  String get cropAspectRatioSquare => 'Kvadrat';

  @override
  String get filterAspectRatioLandscapeLabel => 'Liggjande';

  @override
  String get filterAspectRatioPortraitLabel => 'Ståande';

  @override
  String get filterBinLabel => 'Papirkorg';

  @override
  String get filterFavouriteLabel => 'Likar';

  @override
  String get filterNoDateLabel => 'Ikkje dagsette';

  @override
  String get filterNoAddressLabel => 'Inga adresse';

  @override
  String get filterLocatedLabel => 'Stadsette';

  @override
  String get filterNoLocationLabel => 'Ustadsette';

  @override
  String get filterNoRatingLabel => 'Ikkje dømde';

  @override
  String get filterTaggedLabel => 'Merkte';

  @override
  String get filterNoTagLabel => 'Utan merke';

  @override
  String get filterNoTitleLabel => 'Utan namn';

  @override
  String get filterOnThisDayLabel => 'På denne dagen';

  @override
  String get filterRecentlyAddedLabel => 'Nyleg lagde til';

  @override
  String get filterRatingRejectedLabel => 'Avslegen';

  @override
  String get filterTypeAnimatedLabel => 'Animert';

  @override
  String get filterTypeMotionPhotoLabel => 'Rørslebilete';

  @override
  String get filterTypePanoramaLabel => 'Panorama';

  @override
  String get filterTypeRawLabel => 'Rå';

  @override
  String get filterTypeSphericalVideoLabel => '360°-video';

  @override
  String get filterTypeGeotiffLabel => 'GeoTIFF';

  @override
  String get filterMimeImageLabel => 'Bilete';

  @override
  String get filterMimeVideoLabel => 'Video';

  @override
  String get accessibilityAnimationsRemove => 'Hindr skjermrørsler';

  @override
  String get accessibilityAnimationsKeep => 'Keep screen effects';

  @override
  String get albumTierNew => 'Ny';

  @override
  String get albumTierPinned => 'Festa';

  @override
  String get albumTierSpecial => 'Ofte opna';

  @override
  String get albumTierApps => 'Appar';

  @override
  String get albumTierVaults => 'Kvelv';

  @override
  String get albumTierDynamic => 'Dynamic';

  @override
  String get albumTierRegular => 'Andre';

  @override
  String get coordinateFormatDms => 'G-M-S';

  @override
  String get coordinateFormatDdm => 'DDM';

  @override
  String get coordinateFormatDecimal => 'Desimalgrader';

  @override
  String coordinateDms(String coordinate, String direction) {
    return '$coordinate $direction';
  }

  @override
  String get coordinateDmsNorth => 'N';

  @override
  String get coordinateDmsSouth => 'S';

  @override
  String get coordinateDmsEast => 'A';

  @override
  String get coordinateDmsWest => 'V';

  @override
  String get displayRefreshRatePreferHighest => 'Mest jamn';

  @override
  String get displayRefreshRatePreferLowest => 'Mest ujamn';

  @override
  String get keepScreenOnNever => 'Aldri';

  @override
  String get keepScreenOnVideoPlayback => 'Under videoavspeling';

  @override
  String get keepScreenOnViewerOnly => 'Berre på visingssida';

  @override
  String get keepScreenOnAlways => 'Heile tida';

  @override
  String get lengthUnitPixel => 'px';

  @override
  String get lengthUnitPercent => '%';

  @override
  String get mapStyleGoogleNormal => 'Google Maps';

  @override
  String get mapStyleGoogleHybrid => 'Google Maps (hybrid)';

  @override
  String get mapStyleGoogleTerrain => 'Google Maps (mark)';

  @override
  String get mapStyleOsmLiberty => 'OSM Liberty';

  @override
  String get mapStyleOpenTopoMap => 'OpenTopoMap';

  @override
  String get mapStyleOsmHot => 'Humanitært OSM';

  @override
  String get mapStyleStamenWatercolor => 'Stamen Watercolor (vassfarge)';

  @override
  String get maxBrightnessNever => 'Aldri';

  @override
  String get maxBrightnessAlways => 'Heile tida';

  @override
  String get nameConflictStrategyRename => 'Byt namn';

  @override
  String get nameConflictStrategyReplace => 'Byt ut';

  @override
  String get nameConflictStrategySkip => 'Hopp over';

  @override
  String get overlayHistogramNone => 'None';

  @override
  String get overlayHistogramRGB => 'RGB';

  @override
  String get overlayHistogramLuminance => 'Luminance';

  @override
  String get subtitlePositionTop => 'På toppen';

  @override
  String get subtitlePositionBottom => 'I botnen';

  @override
  String get themeBrightnessLight => 'Ljos';

  @override
  String get themeBrightnessDark => 'Mørk';

  @override
  String get themeBrightnessBlack => 'Svart';

  @override
  String get unitSystemMetric => 'Metrisk';

  @override
  String get unitSystemImperial => 'Engelske måleiningar';

  @override
  String get vaultLockTypePattern => 'Mønster';

  @override
  String get vaultLockTypePin => 'Talkode';

  @override
  String get vaultLockTypePassword => 'Passord';

  @override
  String get settingsVideoEnablePip => 'Picture-in-picture';

  @override
  String get videoControlsPlayOutside => 'Opne med ein ytre avspelar';

  @override
  String get videoLoopModeNever => 'Av';

  @override
  String get videoLoopModeShortOnly => 'Berre stutte videoar';

  @override
  String get videoLoopModeAlways => 'På';

  @override
  String get videoPlaybackSkip => 'Hopp over';

  @override
  String get videoPlaybackMuted => 'Spel av utan ljod';

  @override
  String get videoPlaybackWithSound => 'Spel av med ljod';

  @override
  String get videoResumptionModeNever => 'Aldri';

  @override
  String get videoResumptionModeAlways => 'Kvar gong';

  @override
  String get viewerTransitionSlide => 'Skridande';

  @override
  String get viewerTransitionParallax => 'Parallakse';

  @override
  String get viewerTransitionFade => 'Ton ut';

  @override
  String get viewerTransitionZoomIn => 'Auk';

  @override
  String get viewerTransitionNone => 'Ingen';

  @override
  String get wallpaperTargetHome => 'Heimskjermen';

  @override
  String get wallpaperTargetLock => 'Låseskjerm';

  @override
  String get wallpaperTargetHomeLock => 'Heim- og låseskjermane';

  @override
  String get widgetDisplayedItemRandom => 'Tilfeldig';

  @override
  String get widgetDisplayedItemMostRecent => 'Nylegaste';

  @override
  String get widgetOpenPageHome => 'Opne heimsida';

  @override
  String get widgetOpenPageCollection => 'Opne samlinga';

  @override
  String get widgetOpenPageViewer => 'Opne visinga';

  @override
  String get widgetTapUpdateWidget => 'Update widget';

  @override
  String get storageVolumeDescriptionFallbackPrimary => 'Indre gøyme';

  @override
  String get storageVolumeDescriptionFallbackNonPrimary => 'Ytre gøyme';

  @override
  String get rootDirectoryDescription => 'rotmappe';

  @override
  String otherDirectoryDescription(String name) {
    return '«$name»-mappa';
  }

  @override
  String storageAccessDialogMessage(String directory, String volume) {
    return 'Vel $directory i «$volume» i neste vising for å gje denne appen tilgjenge til ho.';
  }

  @override
  String restrictedAccessDialogMessage(String directory, String volume) {
    return 'Denne appen har ikkje lov til å brigde filer i «$directory»-mappa i «$volume».\n\nBruk ein førehandsinnlagd filhandsamar eller galleriapp til å flytta tinga til ei anna mappe.';
  }

  @override
  String notEnoughSpaceDialogMessage(String neededSize, String freeSize, String volume) {
    return 'Denne gjerda tarv $neededSize unytta rom på «$volume» for å verta fullgjord, men det er berre $freeSize att.';
  }

  @override
  String get missingSystemFilePickerDialogMessage => 'Systemfilveljaren er borte eller avslegen. Slå han på og røyn om att.';

  @override
  String unsupportedTypeDialogMessage(int count, String types) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Denne gjerda er ustødd for ting av fylgjande slag: $types.',
    );
    return '$_temp0';
  }

  @override
  String get nameConflictDialogSingleSourceMessage => 'Somme filer i målmappa har same namn.';

  @override
  String get nameConflictDialogMultipleSourceMessage => 'Somme filer har same namn.';

  @override
  String get addShortcutDialogLabel => 'Snarvegsmerke';

  @override
  String get addShortcutButtonLabel => 'LEGG TIL';

  @override
  String get noMatchingAppDialogMessage => 'Ingen appar kan handsame dette.';

  @override
  String binEntriesConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Flytt desse $count tinga til papirkorga?',
      one: 'Flytt denne tingen til papirkorga?',
    );
    return '$_temp0';
  }

  @override
  String deleteEntriesConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Slett desse $count tinga?',
      one: 'Slett denne tingen?',
    );
    return '$_temp0';
  }

  @override
  String get moveUndatedConfirmationDialogMessage => 'Spar datoane til tinga før du går vidare?';

  @override
  String get moveUndatedConfirmationDialogSetDate => 'Spar datoar';

  @override
  String videoResumeDialogMessage(String time) {
    return 'Hald fram avspeling ifrå $time?';
  }

  @override
  String get videoStartOverButtonLabel => 'BYRJA OM ATT';

  @override
  String get videoResumeButtonLabel => 'HALD FRAM';

  @override
  String get setCoverDialogLatest => 'Nyaste ting';

  @override
  String get setCoverDialogAuto => 'Auto';

  @override
  String get setCoverDialogCustom => 'Eiget';

  @override
  String get hideFilterConfirmationDialogMessage => 'Samsvarande bilete og videoar vil verte skjult ifrå samlinga di. Du kan visa dei att ifrå «Personvern»-innstillingane.\n\nEr du sikker på at du vil skjule dei?';

  @override
  String get newAlbumDialogTitle => 'Nytt Album';

  @override
  String get newAlbumDialogNameLabel => 'Albumsnamn';

  @override
  String get newAlbumDialogAlbumAlreadyExistsHelper => 'Album already exists';

  @override
  String get newAlbumDialogNameLabelAlreadyExistsHelper => 'Mappa finst alt';

  @override
  String get newAlbumDialogStorageLabel => 'Gøyme:';

  @override
  String get newDynamicAlbumDialogTitle => 'New Dynamic Album';

  @override
  String get dynamicAlbumAlreadyExists => 'Dynamic album already exists';

  @override
  String get newVaultWarningDialogMessage => 'Ting i kvelva er berre tilgjengelege for denne appen.\n\nOm du slettar denne appen eller tømmer dataa til denne appen, vil du missa alt som er i kvelva.';

  @override
  String get newVaultDialogTitle => 'Nytt kvelv';

  @override
  String get configureVaultDialogTitle => 'Set opp kvelvet';

  @override
  String get vaultDialogLockModeWhenScreenOff => 'Lås når skjermen slår seg av';

  @override
  String get vaultDialogLockTypeLabel => 'Låseslag';

  @override
  String get patternDialogEnter => 'Stryk inn eit mønster';

  @override
  String get patternDialogConfirm => 'Stadfest mønsteret';

  @override
  String get pinDialogEnter => 'Skriv inn ein talkode';

  @override
  String get pinDialogConfirm => 'Stadfest talkoden';

  @override
  String get passwordDialogEnter => 'Skriv inn passordet';

  @override
  String get passwordDialogConfirm => 'Stadfest passordet';

  @override
  String get authenticateToConfigureVault => 'Authenticate to configure vault';

  @override
  String get authenticateToUnlockVault => 'Authenticate to unlock vault';

  @override
  String get vaultBinUsageDialogMessage => 'Nokre kvelv nyttar papirkorga.';

  @override
  String get renameAlbumDialogLabel => 'Nytt namn';

  @override
  String get renameAlbumDialogLabelAlreadyExistsHelper => 'Mappa finst alt';

  @override
  String get renameEntrySetPageTitle => 'Byt namn';

  @override
  String get renameEntrySetPagePatternFieldLabel => 'Namngjevingsmønster';

  @override
  String get renameEntrySetPageInsertTooltip => 'Innskrivingsområde';

  @override
  String get renameEntrySetPagePreviewSectionTitle => 'Førehandsvis';

  @override
  String get renameProcessorCounter => 'Teljar';

  @override
  String get renameProcessorHash => 'Hash';

  @override
  String get renameProcessorName => 'Namn';

  @override
  String deleteSingleAlbumConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Slett dette albumet og dei $count tinga i det?',
      one: 'Slett dette albumet og tingen i det?',
    );
    return '$_temp0';
  }

  @override
  String deleteMultiAlbumConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Slett desse albuma og deira $count ting?',
      one: 'Slett desse albuma og deira ting?',
    );
    return '$_temp0';
  }

  @override
  String get exportEntryDialogFormat => 'Format:';

  @override
  String get exportEntryDialogWidth => 'Breidd';

  @override
  String get exportEntryDialogHeight => 'Høgd';

  @override
  String get exportEntryDialogQuality => 'Kvalitet';

  @override
  String get exportEntryDialogWriteMetadata => 'Tak med metadata';

  @override
  String get renameEntryDialogLabel => 'Nytt namn';

  @override
  String get editEntryDialogCopyFromItem => 'Kopier ifrå annan ting';

  @override
  String get editEntryDialogTargetFieldsHeader => 'Område å brigde';

  @override
  String get editEntryDateDialogTitle => 'Dato og tid';

  @override
  String get editEntryDateDialogSetCustom => 'Vel dato å setja';

  @override
  String get editEntryDateDialogCopyField => 'Kopier ifrå annan dato';

  @override
  String get editEntryDateDialogExtractFromTitle => 'Tak ut ifrå namn';

  @override
  String get editEntryDateDialogShift => 'Skyv';

  @override
  String get editEntryDateDialogSourceFileModifiedDate => 'Filbrigdedato';

  @override
  String get durationDialogHours => 'Timar';

  @override
  String get durationDialogMinutes => 'Minutt';

  @override
  String get durationDialogSeconds => 'Sekund';

  @override
  String get editEntryLocationDialogTitle => 'Stadsetjing';

  @override
  String get editEntryLocationDialogSetCustom => 'Set eiga stadsetjing';

  @override
  String get editEntryLocationDialogChooseOnMap => 'Vel på kartet';

  @override
  String get editEntryLocationDialogImportGpx => 'Import GPX';

  @override
  String get editEntryLocationDialogLatitude => 'Breiddegrad';

  @override
  String get editEntryLocationDialogLongitude => 'Lengdegrad';

  @override
  String get editEntryLocationDialogTimeShift => 'Time shift';

  @override
  String get locationPickerUseThisLocationButton => 'Nytt denne stadsetjinga';

  @override
  String get editEntryRatingDialogTitle => 'Omdøme';

  @override
  String get removeEntryMetadataDialogTitle => 'Metadataborttaking';

  @override
  String get removeEntryMetadataDialogAll => 'All';

  @override
  String get removeEntryMetadataDialogMore => 'Meir';

  @override
  String get removeEntryMetadataMotionPhotoXmpWarningDialogMessage => 'XMP er turvt for å kunne spela av videoen inni rørslebilete.\n\nEr du viss på at du vil ta det bort?';

  @override
  String get videoSpeedDialogLabel => 'Avspelingssnøggleik';

  @override
  String get videoStreamSelectionDialogVideo => 'Video';

  @override
  String get videoStreamSelectionDialogAudio => 'Ljod';

  @override
  String get videoStreamSelectionDialogText => 'Undertekster';

  @override
  String get videoStreamSelectionDialogOff => 'Av';

  @override
  String get videoStreamSelectionDialogTrack => 'Spor';

  @override
  String get videoStreamSelectionDialogNoSelection => 'Det er ingen andre spor.';

  @override
  String get genericSuccessFeedback => 'Ferdig';

  @override
  String get genericFailureFeedback => 'Mislykka';

  @override
  String get genericDangerWarningDialogMessage => 'Er du viss?';

  @override
  String get tooManyItemsErrorDialogMessage => 'Røyn att med færre ting.';

  @override
  String get menuActionConfigureView => 'Vis';

  @override
  String get menuActionSelect => 'Vel';

  @override
  String get menuActionSelectAll => 'Vel alle';

  @override
  String get menuActionSelectNone => 'Tak bort val';

  @override
  String get menuActionMap => 'Kart';

  @override
  String get menuActionSlideshow => 'Ljosbiletevising';

  @override
  String get menuActionStats => 'Samandrag';

  @override
  String get viewDialogSortSectionTitle => 'Sort';

  @override
  String get viewDialogGroupSectionTitle => 'Hop';

  @override
  String get viewDialogLayoutSectionTitle => 'Oppsett';

  @override
  String get viewDialogReverseSortOrder => 'Reverse sort order';

  @override
  String get tileLayoutMosaic => 'Mosaikk';

  @override
  String get tileLayoutGrid => 'Rutenett';

  @override
  String get tileLayoutList => 'Liste';

  @override
  String get castDialogTitle => 'Cast Devices';

  @override
  String get coverDialogTabCover => 'Omslag';

  @override
  String get coverDialogTabApp => 'App';

  @override
  String get coverDialogTabColor => 'Let';

  @override
  String get appPickDialogTitle => 'Vel app';

  @override
  String get appPickDialogNone => 'Ingen';

  @override
  String get aboutPageTitle => 'Om';

  @override
  String get aboutLinkLicense => 'Løyve';

  @override
  String get aboutLinkPolicy => 'Personvernutsegn';

  @override
  String get aboutBugSectionTitle => 'Mistakrapport';

  @override
  String get aboutBugSaveLogInstruction => 'Spar apploggar til ei fil';

  @override
  String get aboutBugCopyInfoInstruction => 'Kopier systemopplysingar';

  @override
  String get aboutBugCopyInfoButton => 'Kopier';

  @override
  String get aboutBugReportInstruction => 'Rapporter på GitHub med loggføringene og systemopplysingane dine';

  @override
  String get aboutBugReportButton => 'Rapporter';

  @override
  String get aboutDataUsageSectionTitle => 'Data Usage';

  @override
  String get aboutDataUsageData => 'Data';

  @override
  String get aboutDataUsageCache => 'Cache';

  @override
  String get aboutDataUsageDatabase => 'Database';

  @override
  String get aboutDataUsageMisc => 'Misc';

  @override
  String get aboutDataUsageInternal => 'Internal';

  @override
  String get aboutDataUsageExternal => 'External';

  @override
  String get aboutDataUsageClearCache => 'Clear Cache';

  @override
  String get aboutCreditsSectionTitle => 'Credits';

  @override
  String get aboutCreditsWorldAtlas1 => 'Denne appen nyttar ei TopoJSON-fil ifrå';

  @override
  String get aboutCreditsWorldAtlas2 => 'under ISC-løyve.';

  @override
  String get aboutTranslatorsSectionTitle => 'Omsetjarar';

  @override
  String get aboutLicensesSectionTitle => 'Løyve til opne kjeldekodar';

  @override
  String get aboutLicensesBanner => 'This app uses the following open-source packages and libraries.';

  @override
  String get aboutLicensesAndroidLibrariesSectionTitle => 'Android Libraries';

  @override
  String get aboutLicensesFlutterPluginsSectionTitle => 'Flutter-tillegg';

  @override
  String get aboutLicensesFlutterPackagesSectionTitle => 'Flutter-pakker';

  @override
  String get aboutLicensesDartPackagesSectionTitle => 'Dart-pakker';

  @override
  String get aboutLicensesShowAllButtonLabel => 'Vis alle løyve';

  @override
  String get policyPageTitle => 'Personvernutsegn';

  @override
  String get collectionPageTitle => 'Samling';

  @override
  String get collectionPickPageTitle => 'Vel';

  @override
  String get collectionSelectPageTitle => 'Vel ting';

  @override
  String get collectionActionShowTitleSearch => 'Show title filter';

  @override
  String get collectionActionHideTitleSearch => 'Hide title filter';

  @override
  String get collectionActionAddDynamicAlbum => 'Add dynamic album';

  @override
  String get collectionActionAddShortcut => 'Legg til snarveg';

  @override
  String get collectionActionSetHome => 'Set as home';

  @override
  String get collectionActionEmptyBin => 'Tøm papirkorga';

  @override
  String get collectionActionCopy => 'Kopier til album';

  @override
  String get collectionActionMove => 'Flytt til album';

  @override
  String get collectionActionRescan => 'Gjennomsøk att';

  @override
  String get collectionActionEdit => 'Brigd';

  @override
  String get collectionSearchTitlesHintText => 'Søk etter namn';

  @override
  String get collectionGroupAlbum => 'Etter album';

  @override
  String get collectionGroupMonth => 'Etter månad';

  @override
  String get collectionGroupDay => 'Etter dag';

  @override
  String get collectionGroupNone => 'Ikkje hop';

  @override
  String get sectionUnknown => 'Ukjend';

  @override
  String get dateToday => 'I dag';

  @override
  String get dateYesterday => 'I går';

  @override
  String get dateThisMonth => 'Denne månaden';

  @override
  String collectionDeleteFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kunne ikkje slette $count ting',
    );
    return '$_temp0';
  }

  @override
  String collectionCopyFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kunne ikkje kopiera $count ting',
    );
    return '$_temp0';
  }

  @override
  String collectionMoveFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kunne ikkje flytta $count ting',
    );
    return '$_temp0';
  }

  @override
  String collectionRenameFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kunne ikkje byta namn på $count ting',
    );
    return '$_temp0';
  }

  @override
  String collectionEditFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kunne ikkje brigde $count ting',
    );
    return '$_temp0';
  }

  @override
  String collectionExportFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Greidde ikkje å føra ut $count sider',
      one: 'Greidde ikkje å føra ut 1 side',
    );
    return '$_temp0';
  }

  @override
  String collectionCopySuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kopierte $count ting',
    );
    return '$_temp0';
  }

  @override
  String collectionMoveSuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Flytte $count ting',
    );
    return '$_temp0';
  }

  @override
  String collectionRenameSuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Bytte namna til $count ting',
      one: 'Bytte namnet til 1 ting',
    );
    return '$_temp0';
  }

  @override
  String collectionEditSuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Brigda $count ting',
    );
    return '$_temp0';
  }

  @override
  String get collectionEmptyFavourites => 'Det du likar vert vist her';

  @override
  String get collectionEmptyVideos => 'Ingen videoar';

  @override
  String get collectionEmptyImages => 'Ingen bilete';

  @override
  String get collectionEmptyGrantAccessButtonLabel => 'Gje tilgjenge';

  @override
  String get collectionSelectSectionTooltip => 'Vel utvalet';

  @override
  String get collectionDeselectSectionTooltip => 'Fråvel utvalet';

  @override
  String get drawerAboutButton => 'Om';

  @override
  String get drawerSettingsButton => 'Innstillingar';

  @override
  String get drawerCollectionAll => 'Alle samlingar';

  @override
  String get drawerCollectionFavourites => 'Likte';

  @override
  String get drawerCollectionImages => 'Bilete';

  @override
  String get drawerCollectionVideos => 'Videoar';

  @override
  String get drawerCollectionAnimated => 'Animated';

  @override
  String get drawerCollectionMotionPhotos => 'Rørslebilete';

  @override
  String get drawerCollectionPanoramas => 'Panorama';

  @override
  String get drawerCollectionRaws => 'Rå bilete';

  @override
  String get drawerCollectionSphericalVideos => '360°-videoar';

  @override
  String get drawerAlbumPage => 'Album';

  @override
  String get drawerCountryPage => 'Land';

  @override
  String get drawerPlacePage => 'Stadar';

  @override
  String get drawerTagPage => 'Merke';

  @override
  String get sortByDate => 'Etter dato';

  @override
  String get sortByName => 'Etter namn';

  @override
  String get sortByItemCount => 'Etter mengd ting';

  @override
  String get sortBySize => 'Etter storleik';

  @override
  String get sortByAlbumFileName => 'Etter album og filnamn';

  @override
  String get sortByRating => 'Etter omdøme';

  @override
  String get sortByDuration => 'By duration';

  @override
  String get sortByPath => 'By path';

  @override
  String get sortOrderNewestFirst => 'Nyaste først';

  @override
  String get sortOrderOldestFirst => 'Eldste først';

  @override
  String get sortOrderAtoZ => 'A-Å';

  @override
  String get sortOrderZtoA => 'Å-A';

  @override
  String get sortOrderHighestFirst => 'Høgste først';

  @override
  String get sortOrderLowestFirst => 'Lægste først';

  @override
  String get sortOrderLargestFirst => 'Største først';

  @override
  String get sortOrderSmallestFirst => 'Smæste først';

  @override
  String get sortOrderShortestFirst => 'Shortest first';

  @override
  String get sortOrderLongestFirst => 'Longest first';

  @override
  String get albumGroupTier => 'Etter nivå';

  @override
  String get albumGroupType => 'Etter slag';

  @override
  String get albumGroupVolume => 'Etter gøymestad';

  @override
  String get albumGroupNone => 'Ikkje hop';

  @override
  String get albumMimeTypeMixed => 'Blanda';

  @override
  String get albumPickPageTitleCopy => 'Kopier til album';

  @override
  String get albumPickPageTitleExport => 'Før ut til album';

  @override
  String get albumPickPageTitleMove => 'Flytt til album';

  @override
  String get albumPickPageTitlePick => 'Vel album';

  @override
  String get albumCamera => 'Kamera';

  @override
  String get albumDownload => 'Hent';

  @override
  String get albumScreenshots => 'Skjermbilete';

  @override
  String get albumScreenRecordings => 'Skjermopptak';

  @override
  String get albumVideoCaptures => 'Videoopptak';

  @override
  String get albumPageTitle => 'Album';

  @override
  String get albumEmpty => 'Ingen album';

  @override
  String get createAlbumButtonLabel => 'LAG';

  @override
  String get newFilterBanner => 'ny';

  @override
  String get countryPageTitle => 'Land';

  @override
  String get countryEmpty => 'Ingen land';

  @override
  String get statePageTitle => 'Landsdelar';

  @override
  String get stateEmpty => 'Ingen landsdelar';

  @override
  String get placePageTitle => 'Stadar';

  @override
  String get placeEmpty => 'Ingen stadar';

  @override
  String get tagPageTitle => 'Merke';

  @override
  String get tagEmpty => 'Ingen merke';

  @override
  String get binPageTitle => 'Papirkorga';

  @override
  String get explorerPageTitle => 'Explorer';

  @override
  String get explorerActionSelectStorageVolume => 'Select storage';

  @override
  String get selectStorageVolumeDialogTitle => 'Select Storage';

  @override
  String get searchCollectionFieldHint => 'Søk i samlinga';

  @override
  String get searchRecentSectionTitle => 'Nylege';

  @override
  String get searchDateSectionTitle => 'Dato';

  @override
  String get searchFormatSectionTitle => 'Formats';

  @override
  String get searchAlbumsSectionTitle => 'Album';

  @override
  String get searchCountriesSectionTitle => 'Land';

  @override
  String get searchStatesSectionTitle => 'Landsdelar';

  @override
  String get searchPlacesSectionTitle => 'Stadar';

  @override
  String get searchTagsSectionTitle => 'Merke';

  @override
  String get searchRatingSectionTitle => 'Omdøme';

  @override
  String get searchMetadataSectionTitle => 'Metadata';

  @override
  String get settingsPageTitle => 'Innstillingar';

  @override
  String get settingsSystemDefault => 'Systemforval';

  @override
  String get settingsDefault => 'Forval';

  @override
  String get settingsDisabled => 'Slegen av';

  @override
  String get settingsAskEverytime => 'Spør kvar gong';

  @override
  String get settingsModificationWarningDialogMessage => 'Andre innstillingar vil brigdast.';

  @override
  String get settingsSearchFieldLabel => 'Søkjeinnstillingar';

  @override
  String get settingsSearchEmpty => 'Ingen samsvarande innstilling';

  @override
  String get settingsActionExport => 'Før ut';

  @override
  String get settingsActionExportDialogTitle => 'Før ut';

  @override
  String get settingsActionImport => 'Før inn';

  @override
  String get settingsActionImportDialogTitle => 'Før inn';

  @override
  String get appExportCovers => 'Omslag';

  @override
  String get appExportDynamicAlbums => 'Dynamic albums';

  @override
  String get appExportFavourites => 'Likte ting';

  @override
  String get appExportSettings => 'Innstillingar';

  @override
  String get settingsNavigationSectionTitle => 'Finn fram';

  @override
  String get settingsHomeTile => 'Heim';

  @override
  String get settingsHomeDialogTitle => 'Heim';

  @override
  String get setHomeCustom => 'Custom';

  @override
  String get settingsShowBottomNavigationBar => 'Vis ei framfinningsrad på botnen';

  @override
  String get settingsKeepScreenOnTile => 'Hald skjermen slegen på';

  @override
  String get settingsKeepScreenOnDialogTitle => 'Hald skjermen slegen på';

  @override
  String get settingsDoubleBackExit => 'Trykk «Attende» to gongar for å gå ut av appen';

  @override
  String get settingsConfirmationTile => 'Stadfestingsvindaugo';

  @override
  String get settingsConfirmationDialogTitle => 'Stadfestingsvindaugo';

  @override
  String get settingsConfirmationBeforeDeleteItems => 'Verta spurd før du slettar noko for godt';

  @override
  String get settingsConfirmationBeforeMoveToBinItems => 'Verta spurd før du kastar ting i papirkorga';

  @override
  String get settingsConfirmationBeforeMoveUndatedItems => 'Verta spurd før du flyttar på ting utan dato';

  @override
  String get settingsConfirmationAfterMoveToBinItems => 'Verta spurd om du vil angre etter å ha kasta ting i søppelkorga';

  @override
  String get settingsConfirmationVaultDataLoss => 'Åtvar om datatap ved kvelvet';

  @override
  String get settingsNavigationDrawerTile => 'Framfinningsmenyen';

  @override
  String get settingsNavigationDrawerEditorPageTitle => 'Framfinningsmenyen';

  @override
  String get settingsNavigationDrawerBanner => 'Trykk og hald for å flytta og brigde rekkjefylgda til menytinga.';

  @override
  String get settingsNavigationDrawerTabTypes => 'Slag';

  @override
  String get settingsNavigationDrawerTabAlbums => 'Album';

  @override
  String get settingsNavigationDrawerTabPages => 'Sider';

  @override
  String get settingsNavigationDrawerAddAlbum => 'Legg til album';

  @override
  String get settingsThumbnailSectionTitle => 'Småbilete';

  @override
  String get settingsThumbnailOverlayTile => 'Overlag';

  @override
  String get settingsThumbnailOverlayPageTitle => 'Overlag';

  @override
  String get settingsThumbnailShowHdrIcon => 'Show HDR icon';

  @override
  String get settingsThumbnailShowFavouriteIcon => 'Vis likt-ikon';

  @override
  String get settingsThumbnailShowTagIcon => 'Vis merke-ikon';

  @override
  String get settingsThumbnailShowLocationIcon => 'Vis stad-ikon';

  @override
  String get settingsThumbnailShowMotionPhotoIcon => 'Vis rørslebilete-ikon';

  @override
  String get settingsThumbnailShowRating => 'Vis omdøme';

  @override
  String get settingsThumbnailShowRawIcon => 'Vis rå-ikon';

  @override
  String get settingsThumbnailShowVideoDuration => 'Vis videolengd';

  @override
  String get settingsCollectionQuickActionsTile => 'Kvikkgjerder';

  @override
  String get settingsCollectionQuickActionEditorPageTitle => 'Kvikkgjerder';

  @override
  String get settingsCollectionQuickActionTabBrowsing => 'Gjennomsyn';

  @override
  String get settingsCollectionQuickActionTabSelecting => 'Veljing';

  @override
  String get settingsCollectionBrowsingQuickActionEditorBanner => 'Trykk og hald for å flytta knappane og velja kva for slags gjerder som skal visast når du ser igjennom ting.';

  @override
  String get settingsCollectionSelectionQuickActionEditorBanner => 'Trykk og hald for å flytta knappane og velja kva for slags gjerder som skal visast når du vel ting.';

  @override
  String get settingsCollectionBurstPatternsTile => 'Attkjenning av seriebilete';

  @override
  String get settingsCollectionBurstPatternsNone => 'Ingen';

  @override
  String get settingsViewerSectionTitle => 'Visinga';

  @override
  String get settingsViewerGestureSideTapNext => 'Trykk på skjermkantane for å visa førre/neste ting';

  @override
  String get settingsViewerUseCutout => 'Nytt utklipt område';

  @override
  String get settingsViewerMaximumBrightness => 'Full ljosstyrke';

  @override
  String get settingsMotionPhotoAutoPlay => 'Spel av rørslebilete sjølvverkande';

  @override
  String get settingsImageBackground => 'Biletbakgrunn';

  @override
  String get settingsViewerQuickActionsTile => 'Kvikkgjerder';

  @override
  String get settingsViewerQuickActionEditorPageTitle => 'Kvikkgjerder';

  @override
  String get settingsViewerQuickActionEditorBanner => 'Trykk og hald for å flytta knappane og velja kva for slags gjerder som skal visast i visinga.';

  @override
  String get settingsViewerQuickActionEditorDisplayedButtonsSectionTitle => 'Viste knappar';

  @override
  String get settingsViewerQuickActionEditorAvailableButtonsSectionTitle => 'Tilgjengelege knappar';

  @override
  String get settingsViewerQuickActionEmpty => 'Ingen knappar';

  @override
  String get settingsViewerOverlayTile => 'Overlag';

  @override
  String get settingsViewerOverlayPageTitle => 'Overlag';

  @override
  String get settingsViewerShowOverlayOnOpening => 'Vis ved opning';

  @override
  String get settingsViewerShowHistogram => 'Show histogram';

  @override
  String get settingsViewerShowMinimap => 'Vis småkart';

  @override
  String get settingsViewerShowInformation => 'Vis opplysingar';

  @override
  String get settingsViewerShowInformationSubtitle => 'Vis namn, dato, stad, osv …';

  @override
  String get settingsViewerShowRatingTags => 'Vis omdøme og merke';

  @override
  String get settingsViewerShowShootingDetails => 'Vis biletetakingsopplysingar';

  @override
  String get settingsViewerShowDescription => 'Vis utgreiingar';

  @override
  String get settingsViewerShowOverlayThumbnails => 'Vis småbilete';

  @override
  String get settingsViewerEnableOverlayBlurEffect => 'Uskarp verknad';

  @override
  String get settingsViewerSlideshowTile => 'Ljosbiletevising';

  @override
  String get settingsViewerSlideshowPageTitle => 'Ljosbiletevising';

  @override
  String get settingsSlideshowRepeat => 'Gjentak';

  @override
  String get settingsSlideshowShuffle => 'Bland';

  @override
  String get settingsSlideshowFillScreen => 'Fyll skjermen';

  @override
  String get settingsSlideshowAnimatedZoomEffect => 'Animated zoom effect';

  @override
  String get settingsSlideshowTransitionTile => 'Overgang';

  @override
  String get settingsSlideshowIntervalTile => 'Byt til neste etter';

  @override
  String get settingsSlideshowVideoPlaybackTile => 'Videoavspeling';

  @override
  String get settingsSlideshowVideoPlaybackDialogTitle => 'Videoavspeling';

  @override
  String get settingsVideoPageTitle => 'Videoinnstillingar';

  @override
  String get settingsVideoSectionTitle => 'Video';

  @override
  String get settingsVideoShowVideos => 'Vis videoar';

  @override
  String get settingsVideoPlaybackTile => 'Avspeling';

  @override
  String get settingsVideoPlaybackPageTitle => 'Avspeling';

  @override
  String get settingsVideoEnableHardwareAcceleration => 'Auk ytinga med maskinvara';

  @override
  String get settingsVideoAutoPlay => 'Spel av med ein gong';

  @override
  String get settingsVideoLoopModeTile => 'Gjentak';

  @override
  String get settingsVideoLoopModeDialogTitle => 'Gjentak';

  @override
  String get settingsVideoResumptionModeTile => 'Spel av der du slapp';

  @override
  String get settingsVideoResumptionModeDialogTitle => 'Spel av der du slapp';

  @override
  String get settingsVideoBackgroundMode => 'Spel av i bakgrunnen';

  @override
  String get settingsVideoBackgroundModeDialogTitle => 'Spel av i bakgrunnen';

  @override
  String get settingsVideoControlsTile => 'Styring';

  @override
  String get settingsVideoControlsPageTitle => 'Styring';

  @override
  String get settingsVideoButtonsTile => 'Knappar';

  @override
  String get settingsVideoGestureDoubleTapTogglePlay => 'Dobbeltrykk for å spela/stansa';

  @override
  String get settingsVideoGestureSideDoubleTapSeek => 'Dobbeltrykk på skjermkantane for å hoppe framover/bakover';

  @override
  String get settingsVideoGestureVerticalDragBrightnessVolume => 'Dra opp eller ned for å brigde ljos-/ljodstyrken';

  @override
  String get settingsSubtitleThemeTile => 'Undertekster';

  @override
  String get settingsSubtitleThemePageTitle => 'Undertekster';

  @override
  String get settingsSubtitleThemeSample => 'Dette er eit døme.';

  @override
  String get settingsSubtitleThemeTextAlignmentTile => 'Tekststilling';

  @override
  String get settingsSubtitleThemeTextAlignmentDialogTitle => 'Tekststilling';

  @override
  String get settingsSubtitleThemeTextPositionTile => 'Tekststad';

  @override
  String get settingsSubtitleThemeTextPositionDialogTitle => 'Tekststad';

  @override
  String get settingsSubtitleThemeTextSize => 'Tekststorleik';

  @override
  String get settingsSubtitleThemeShowOutline => 'Vis omriss og skuggar';

  @override
  String get settingsSubtitleThemeTextColor => 'Tekstleten';

  @override
  String get settingsSubtitleThemeTextOpacity => 'Tekstgjennomsyn';

  @override
  String get settingsSubtitleThemeBackgroundColor => 'Bakgrunnsleten';

  @override
  String get settingsSubtitleThemeBackgroundOpacity => 'Bakgrunnsgjennomsyn';

  @override
  String get settingsSubtitleThemeTextAlignmentLeft => 'Venstre';

  @override
  String get settingsSubtitleThemeTextAlignmentCenter => 'Midten';

  @override
  String get settingsSubtitleThemeTextAlignmentRight => 'Høgre';

  @override
  String get settingsPrivacySectionTitle => 'Personvern';

  @override
  String get settingsAllowInstalledAppAccess => 'Gje tilgjenge til lista over innlagde appar';

  @override
  String get settingsAllowInstalledAppAccessSubtitle => 'Vert nytta til å betre albumsvisinga';

  @override
  String get settingsAllowErrorReporting => 'Send inn anonyme feilrapportar';

  @override
  String get settingsSaveSearchHistory => 'Spar søkjehistorikken';

  @override
  String get settingsEnableBin => 'Nytt papirkorga';

  @override
  String get settingsEnableBinSubtitle => 'Sparar på sletta ting i 30 dagar';

  @override
  String get settingsDisablingBinWarningDialogMessage => 'Ting i papirkorga vil slettast for godt.';

  @override
  String get settingsAllowMediaManagement => 'La få handsame medium';

  @override
  String get settingsHiddenItemsTile => 'Skjulte ting';

  @override
  String get settingsHiddenItemsPageTitle => 'Skjulte ting';

  @override
  String get settingsHiddenFiltersBanner => 'Photos and videos matching hidden filters will not appear in your collection.';

  @override
  String get settingsHiddenFiltersEmpty => 'No hidden filters';

  @override
  String get settingsStorageAccessTile => 'Gøymetilgjenge';

  @override
  String get settingsStorageAccessPageTitle => 'Gøymetilgjenge';

  @override
  String get settingsStorageAccessBanner => 'Nokre mapper krev at du gjev appen tilgjenge til dei for å brigde filer i dei. Du kan sjå på mappene som du har gjeve appen tilgjenge til her.';

  @override
  String get settingsStorageAccessEmpty => 'Ingen gjevne tilgjenge';

  @override
  String get settingsStorageAccessRevokeTooltip => 'Fråta';

  @override
  String get settingsAccessibilitySectionTitle => 'Tilgjenge';

  @override
  String get settingsRemoveAnimationsTile => 'Remove animations';

  @override
  String get settingsRemoveAnimationsDialogTitle => 'Remove Animations';

  @override
  String get settingsTimeToTakeActionTile => 'Tid for å gjera';

  @override
  String get settingsAccessibilityShowPinchGestureAlternatives => 'Vis andre utvegar for fleirtrykkhandvendingar';

  @override
  String get settingsDisplaySectionTitle => 'Vising';

  @override
  String get settingsThemeBrightnessTile => 'Ham';

  @override
  String get settingsThemeBrightnessDialogTitle => 'Ham';

  @override
  String get settingsThemeColorHighlights => 'Léta framhevjingar';

  @override
  String get settingsThemeEnableDynamicColor => 'Skiftande let';

  @override
  String get settingsDisplayRefreshRateModeTile => 'Rørslejamleiken til skjermen';

  @override
  String get settingsDisplayRefreshRateModeDialogTitle => 'Rørslejamleik';

  @override
  String get settingsDisplayUseTvInterface => 'Android TV-grensesnitt';

  @override
  String get settingsLanguageSectionTitle => 'Skriftmål og format';

  @override
  String get settingsLanguageTile => 'Skriftmål';

  @override
  String get settingsLanguagePageTitle => 'Skriftmål';

  @override
  String get settingsCoordinateFormatTile => 'Koordinatformat';

  @override
  String get settingsCoordinateFormatDialogTitle => 'Koordinatformat';

  @override
  String get settingsUnitSystemTile => 'Einingar';

  @override
  String get settingsUnitSystemDialogTitle => 'Einingar';

  @override
  String get settingsForceWesternArabicNumeralsTile => 'Force Arabic numerals';

  @override
  String get settingsScreenSaverPageTitle => 'Skjermsparar';

  @override
  String get settingsWidgetPageTitle => 'Bileteramme';

  @override
  String get settingsWidgetShowOutline => 'Omrit';

  @override
  String get settingsWidgetOpenPage => 'When tapping on the widget';

  @override
  String get settingsWidgetDisplayedItem => 'Vist ting';

  @override
  String get settingsCollectionTile => 'Samling';

  @override
  String get statsPageTitle => 'Samandrag';

  @override
  String statsWithGps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ting med stadsetjing',
    );
    return '$_temp0';
  }

  @override
  String get statsTopCountriesSectionTitle => 'Toppland';

  @override
  String get statsTopStatesSectionTitle => 'Topplandsdelar';

  @override
  String get statsTopPlacesSectionTitle => 'Toppstadar';

  @override
  String get statsTopTagsSectionTitle => 'Toppmerke';

  @override
  String get statsTopAlbumsSectionTitle => 'Topp-album';

  @override
  String get viewerOpenPanoramaButtonLabel => 'OPNE PANORAMA';

  @override
  String get viewerSetWallpaperButtonLabel => 'SET SOM BAKGRUNNSBILETE';

  @override
  String get viewerErrorUnknown => 'Oida.';

  @override
  String get viewerErrorDoesNotExist => 'Fila finst ikkje meir.';

  @override
  String get viewerInfoPageTitle => 'Opplysingar';

  @override
  String get viewerInfoBackToViewerTooltip => 'Attende til vising';

  @override
  String get viewerInfoUnknown => 'ukjend';

  @override
  String get viewerInfoLabelDescription => 'Utgreiing';

  @override
  String get viewerInfoLabelTitle => 'Namn';

  @override
  String get viewerInfoLabelDate => 'Dato';

  @override
  String get viewerInfoLabelResolution => 'Oppløysing';

  @override
  String get viewerInfoLabelSize => 'Storleik';

  @override
  String get viewerInfoLabelUri => 'URI';

  @override
  String get viewerInfoLabelPath => 'Sti';

  @override
  String get viewerInfoLabelDuration => 'Lengd';

  @override
  String get viewerInfoLabelOwner => 'Eigar';

  @override
  String get viewerInfoLabelCoordinates => 'Koordinatar';

  @override
  String get viewerInfoLabelAddress => 'Adresse';

  @override
  String get mapStyleDialogTitle => 'Kartstil';

  @override
  String get mapStyleTooltip => 'Vel kartstil';

  @override
  String get mapZoomInTooltip => 'Auk';

  @override
  String get mapZoomOutTooltip => 'Mink';

  @override
  String get mapPointNorthUpTooltip => 'Rett opp';

  @override
  String get mapAttributionOsmData => 'Kartdata © [OpenStreetMap](https://www.openstreetmap.org/copyright)-medverkarar';

  @override
  String get mapAttributionOsmLiberty => 'Tiles by [OpenMapTiles](https://www.openmaptiles.org/), [CC BY](http://creativecommons.org/licenses/by/4.0) • Hosted by [OSM Americana](https://tile.ourmap.us)';

  @override
  String get mapAttributionOpenTopoMap => '[SRTM](https://www.earthdata.nasa.gov/sensors/srtm) | Tiles by [OpenTopoMap](https://opentopomap.org/), [CC BY-SA](https://creativecommons.org/licenses/by-sa/3.0/)';

  @override
  String get mapAttributionOsmHot => 'Fliser av [HOT](https://www.hotosm.org/) • Hust av [OSM France](https://openstreetmap.fr/)';

  @override
  String get mapAttributionStamen => 'Fliser av [Stamen Design](https://stamen.com), [CC BY 3.0](https://creativecommons.org/licenses/by/3.0)';

  @override
  String get openMapPageTooltip => 'Vis på kartsida';

  @override
  String get mapEmptyRegion => 'Ingen bilete i dette området';

  @override
  String get viewerInfoOpenEmbeddedFailureFeedback => 'Greidde ikkje å pakke ut innbygde data';

  @override
  String get viewerInfoOpenLinkText => 'Opne';

  @override
  String get viewerInfoViewXmlLinkText => 'Vis XML';

  @override
  String get viewerInfoSearchFieldLabel => 'Søk metadata';

  @override
  String get viewerInfoSearchEmpty => 'Ingen samsvarande lyklar';

  @override
  String get viewerInfoSearchSuggestionDate => 'Dato og tid';

  @override
  String get viewerInfoSearchSuggestionDescription => 'Utgreiing';

  @override
  String get viewerInfoSearchSuggestionDimensions => 'Dimensions';

  @override
  String get viewerInfoSearchSuggestionResolution => 'Oppløysing';

  @override
  String get viewerInfoSearchSuggestionRights => 'Rettar';

  @override
  String get wallpaperUseScrollEffect => 'Use scroll effect on home screen';

  @override
  String get tagEditorPageTitle => 'Brigd merke';

  @override
  String get tagEditorPageNewTagFieldLabel => 'Nytt merke';

  @override
  String get tagEditorPageAddTagTooltip => 'Legg til merke';

  @override
  String get tagEditorSectionRecent => 'Nyleg';

  @override
  String get tagEditorSectionPlaceholders => 'Førebels';

  @override
  String get tagEditorDiscardDialogMessage => 'Vil du avvisa brigda?';

  @override
  String get tagPlaceholderCountry => 'Land';

  @override
  String get tagPlaceholderState => 'Landsdel';

  @override
  String get tagPlaceholderPlace => 'Stad';

  @override
  String get panoramaEnableSensorControl => 'Slå på sensorstyring';

  @override
  String get panoramaDisableSensorControl => 'Slå av sensorstyring';

  @override
  String get sourceViewerPageTitle => 'Kjelde';

  @override
  String get filePickerShowHiddenFiles => 'Vis skjulte filer';

  @override
  String get filePickerDoNotShowHiddenFiles => 'Ikkje vis skjulte filer';

  @override
  String get filePickerOpenFrom => 'Opne ifrå';

  @override
  String get filePickerNoItems => 'Ingen ting';

  @override
  String get filePickerUseThisFolder => 'Bruk denne mappa';
}
