// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Norwegian Bokmål (`nb`).
class AppLocalizationsNb extends AppLocalizations {
  AppLocalizationsNb([String locale = 'nb']) : super(locale);

  @override
  String get appName => 'Aves';

  @override
  String get welcomeMessage => 'Velkommen';

  @override
  String get welcomeOptional => 'Valgfritt';

  @override
  String get welcomeTermsToggle => 'Jeg samtykker til vilkår og betingelser';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementer',
      one: '$count element',
    );
    return '$_temp0';
  }

  @override
  String columnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kolonner',
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
      other: '$countString minutter',
      one: '$countString minutt',
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
      other: '$countString dager',
      one: '$countString dag',
    );
    return '$_temp0';
  }

  @override
  String focalLength(String length) {
    return '$length mm';
  }

  @override
  String get applyButtonLabel => 'BRUK';

  @override
  String get createButtonLabel => 'CREATE';

  @override
  String get deleteButtonLabel => 'SLETT';

  @override
  String get nextButtonLabel => 'NESTE';

  @override
  String get showButtonLabel => 'VIS';

  @override
  String get hideButtonLabel => 'SKJUL';

  @override
  String get continueButtonLabel => 'FORTSETT';

  @override
  String get saveCopyButtonLabel => 'Lagre kopi';

  @override
  String get applyTooltip => 'Bruk';

  @override
  String get cancelTooltip => 'Avbryt';

  @override
  String get changeTooltip => 'Endre';

  @override
  String get clearTooltip => 'Tøm';

  @override
  String get previousTooltip => 'Forrige';

  @override
  String get nextTooltip => 'Neste';

  @override
  String get showTooltip => 'Vis';

  @override
  String get hideTooltip => 'Skjul';

  @override
  String get actionRemove => 'Fjern';

  @override
  String get resetTooltip => 'Tilbakestill';

  @override
  String get saveTooltip => 'Lagre';

  @override
  String get stopTooltip => 'Stop';

  @override
  String get pickTooltip => 'Velg';

  @override
  String get doubleBackExitMessage => 'Trykk «Tilbake» igjen for å avslutte.';

  @override
  String get doNotAskAgain => 'Ikke spør igjen';

  @override
  String get sourceStateLoading => 'Laster inn';

  @override
  String get sourceStateCataloguing => 'Katalogisering';

  @override
  String get sourceStateLocatingCountries => 'Lokalisering av land';

  @override
  String get sourceStateLocatingPlaces => 'Lokalisering av steder';

  @override
  String get chipActionDelete => 'Slett';

  @override
  String get chipActionRemove => 'Remove';

  @override
  String get chipActionShowCollection => 'Vis i samling';

  @override
  String get chipActionGoToAlbumPage => 'Vis i album';

  @override
  String get chipActionGoToCountryPage => 'Vis i land';

  @override
  String get chipActionGoToPlacePage => 'Vis i «Steder»';

  @override
  String get chipActionGoToTagPage => 'Vis i etiketter';

  @override
  String get chipActionGoToExplorerPage => 'Show in Explorer';

  @override
  String get chipActionDecompose => 'Split';

  @override
  String get chipActionFilterOut => 'Ekskluder';

  @override
  String get chipActionFilterIn => 'Inkluder';

  @override
  String get chipActionHide => 'Skjul';

  @override
  String get chipActionLock => 'Lås';

  @override
  String get chipActionPin => 'Fest til toppen';

  @override
  String get chipActionUnpin => 'Løsne fra toppen';

  @override
  String get chipActionGroup => 'Group';

  @override
  String get chipActionRename => 'Gi nytt navn';

  @override
  String get chipActionSetCover => 'Sett omslag';

  @override
  String get chipActionShowCountryStates => 'Vis tilstander';

  @override
  String get chipActionCreateGroup => 'Create group';

  @override
  String get chipActionCreateAlbum => 'Opprett album';

  @override
  String get chipActionCreateVault => 'Opprett hvelv';

  @override
  String get chipActionConfigureVault => 'Sett opp hvelv';

  @override
  String get entryActionCopyToClipboard => 'Kopier til utklippstavle';

  @override
  String get entryActionDelete => 'Slett';

  @override
  String get entryActionConvert => 'Konverter';

  @override
  String get entryActionExport => 'Eksporter';

  @override
  String get entryActionInfo => 'Info';

  @override
  String get entryActionRename => 'Gi nytt navn';

  @override
  String get entryActionRestore => 'Gjenopprett';

  @override
  String get entryActionRotateCCW => 'Roter mot klokken';

  @override
  String get entryActionRotateCW => 'Roter med klokken';

  @override
  String get entryActionFlip => 'Vend vannrett';

  @override
  String get entryActionPrint => 'Skriv ut';

  @override
  String get entryActionShare => 'Del';

  @override
  String get entryActionShareImageOnly => 'Del kun bilde';

  @override
  String get entryActionShareVideoOnly => 'Del kun video';

  @override
  String get entryActionViewSource => 'Vis kilde';

  @override
  String get entryActionShowGeoTiffOnMap => 'Vis som overlagskart';

  @override
  String get entryActionConvertMotionPhotoToStillImage => 'Konverter til stillbilde';

  @override
  String get entryActionViewMotionPhotoVideo => 'Åpne video';

  @override
  String get entryActionEdit => 'Rediger';

  @override
  String get entryActionOpen => 'Åpne med';

  @override
  String get entryActionSetAs => 'Sett som';

  @override
  String get entryActionCast => 'Cast';

  @override
  String get entryActionOpenMap => 'Vis i kartprogram';

  @override
  String get entryActionRotateScreen => 'Roter skjerm';

  @override
  String get entryActionAddFavourite => 'Legg til i favoritter';

  @override
  String get entryActionRemoveFavourite => 'Fjern fra favoritter';

  @override
  String get videoActionCaptureFrame => 'Fang ramme';

  @override
  String get videoActionMute => 'Forstum';

  @override
  String get videoActionUnmute => 'Opphev forstummelse';

  @override
  String get videoActionPause => 'Pause';

  @override
  String get videoActionPlay => 'Spill';

  @override
  String get videoActionReplay10 => 'Blafre bakover 10 sekunder';

  @override
  String get videoActionSkip10 => 'Blafre forover 10 sekunder';

  @override
  String get videoActionShowPreviousFrame => 'Show previous frame';

  @override
  String get videoActionShowNextFrame => 'Show next frame';

  @override
  String get videoActionSelectStreams => 'Velg spor';

  @override
  String get videoActionSetSpeed => 'Avspillingshastighet';

  @override
  String get videoActionABRepeat => 'A-B repeat';

  @override
  String get videoRepeatActionSetStart => 'Set start';

  @override
  String get videoRepeatActionSetEnd => 'Set end';

  @override
  String get viewerActionSettings => 'Innstillinger';

  @override
  String get viewerActionLock => 'Lock viewer';

  @override
  String get viewerActionUnlock => 'Unlock viewer';

  @override
  String get slideshowActionResume => 'Fortsett';

  @override
  String get slideshowActionShowInCollection => 'Vis i samling';

  @override
  String get entryInfoActionEditDate => 'Rediger dato og tid';

  @override
  String get entryInfoActionEditLocation => 'Rediger plassering';

  @override
  String get entryInfoActionEditTitleDescription => 'Rediger navn og beskrivelse';

  @override
  String get entryInfoActionEditRating => 'Rediger vurdering';

  @override
  String get entryInfoActionEditTags => 'Rediger etiketter';

  @override
  String get entryInfoActionRemoveMetadata => 'Fjern metadata';

  @override
  String get entryInfoActionExportMetadata => 'Eksporter metadata';

  @override
  String get entryInfoActionRemoveLocation => 'Fjern posisjon';

  @override
  String get editorActionTransform => 'Transform';

  @override
  String get editorTransformCrop => 'Beskjær';

  @override
  String get editorTransformRotate => 'Roter';

  @override
  String get cropAspectRatioFree => 'Free';

  @override
  String get cropAspectRatioOriginal => 'Original';

  @override
  String get cropAspectRatioSquare => 'Square';

  @override
  String get filterAspectRatioLandscapeLabel => 'Liggende';

  @override
  String get filterAspectRatioPortraitLabel => 'Stående';

  @override
  String get filterBinLabel => 'Papirkurv';

  @override
  String get filterFavouriteLabel => 'Favorittmerk';

  @override
  String get filterNoDateLabel => 'Udatert';

  @override
  String get filterNoAddressLabel => 'Ingen adresse';

  @override
  String get filterLocatedLabel => 'Posisjonert';

  @override
  String get filterNoLocationLabel => 'Uten posisjon';

  @override
  String get filterNoRatingLabel => 'Uvurdert';

  @override
  String get filterTaggedLabel => 'Etikettmerket';

  @override
  String get filterNoTagLabel => 'Uten etiketter';

  @override
  String get filterNoTitleLabel => 'Uten navn';

  @override
  String get filterOnThisDayLabel => 'På denne dagen';

  @override
  String get filterRecentlyAddedLabel => 'Nylig tillagt';

  @override
  String get filterRatingRejectedLabel => 'Avslått';

  @override
  String get filterTypeAnimatedLabel => 'Animert';

  @override
  String get filterTypeMotionPhotoLabel => 'Bevegelig bilde';

  @override
  String get filterTypePanoramaLabel => 'Panorama';

  @override
  String get filterTypeRawLabel => 'Raw';

  @override
  String get filterTypeSphericalVideoLabel => '360°-video';

  @override
  String get filterTypeGeotiffLabel => 'GeoTIFF';

  @override
  String get filterMimeImageLabel => 'Bilde';

  @override
  String get filterMimeVideoLabel => 'Video';

  @override
  String get accessibilityAnimationsRemove => 'Forhindre skjermeffekter';

  @override
  String get accessibilityAnimationsKeep => 'Behold skjermeffekter';

  @override
  String get albumTierNew => 'Ny';

  @override
  String get albumTierPinned => 'Festet';

  @override
  String get albumTierGroups => 'Groups';

  @override
  String get albumTierSpecial => 'Ofte åpnet';

  @override
  String get albumTierApps => 'Programmer';

  @override
  String get albumTierVaults => 'Hvelv';

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
  String get coordinateDmsEast => 'Ø';

  @override
  String get coordinateDmsWest => 'V';

  @override
  String get displayRefreshRatePreferHighest => 'Høyeste takt';

  @override
  String get displayRefreshRatePreferLowest => 'Laveste takt';

  @override
  String get keepScreenOnNever => 'Aldri';

  @override
  String get keepScreenOnVideoPlayback => 'Under videoavspilling';

  @override
  String get keepScreenOnViewerOnly => 'Kun visningsside';

  @override
  String get keepScreenOnAlways => 'Alltid';

  @override
  String get lengthUnitPixel => 'px';

  @override
  String get lengthUnitPercent => '%';

  @override
  String get mapStyleGoogleNormal => 'Google Maps';

  @override
  String get mapStyleGoogleHybrid => 'Google Maps (hybrid)';

  @override
  String get mapStyleGoogleTerrain => 'Google Maps (terreng)';

  @override
  String get mapStyleOsmLiberty => 'OSM Liberty';

  @override
  String get mapStyleOpenTopoMap => 'OpenTopoMap';

  @override
  String get mapStyleOsmHot => 'Humanitært OSM';

  @override
  String get mapStyleStamenWatercolor => 'Stamen Watercolor (akvarell)';

  @override
  String get maxBrightnessNever => 'Aldri';

  @override
  String get maxBrightnessAlways => 'Alltid';

  @override
  String get nameConflictStrategyRename => 'Gi nytt navn';

  @override
  String get nameConflictStrategyReplace => 'Erstatt';

  @override
  String get nameConflictStrategySkip => 'Hopp over';

  @override
  String get overlayHistogramNone => 'None';

  @override
  String get overlayHistogramRGB => 'RGB';

  @override
  String get overlayHistogramLuminance => 'Luminance';

  @override
  String get subtitlePositionTop => 'Topp';

  @override
  String get subtitlePositionBottom => 'Bunn';

  @override
  String get themeBrightnessLight => 'Lys';

  @override
  String get themeBrightnessDark => 'Mørk';

  @override
  String get themeBrightnessBlack => 'Svart';

  @override
  String get unitSystemMetric => 'Metrisk';

  @override
  String get unitSystemImperial => 'Engelske måleenheter';

  @override
  String get vaultLockTypePattern => 'Mønster';

  @override
  String get vaultLockTypePin => 'PIN';

  @override
  String get vaultLockTypePassword => 'Passord';

  @override
  String get settingsVideoEnablePip => 'Picture-in-picture';

  @override
  String get videoControlsPlayOutside => 'Åpne med annen avspiller';

  @override
  String get videoLoopModeNever => 'Aldri';

  @override
  String get videoLoopModeShortOnly => 'Kun korte videoer';

  @override
  String get videoLoopModeAlways => 'Alltid';

  @override
  String get videoPlaybackSkip => 'Hopp over';

  @override
  String get videoPlaybackMuted => 'Spill forstummet';

  @override
  String get videoPlaybackWithSound => 'Spill med lyd';

  @override
  String get videoResumptionModeNever => 'Aldri';

  @override
  String get videoResumptionModeAlways => 'Alltid';

  @override
  String get viewerTransitionSlide => 'Glidende';

  @override
  String get viewerTransitionParallax => 'Parallakse';

  @override
  String get viewerTransitionFade => 'Ton ut';

  @override
  String get viewerTransitionZoomIn => 'Forstørr';

  @override
  String get viewerTransitionNone => 'Ingen';

  @override
  String get wallpaperTargetHome => 'Hjemmeskjerm';

  @override
  String get wallpaperTargetLock => 'Lås skjerm';

  @override
  String get wallpaperTargetHomeLock => 'Hjem- og låseskjermer';

  @override
  String get widgetDisplayedItemRandom => 'Tilfeldig';

  @override
  String get widgetDisplayedItemMostRecent => 'Nyligst';

  @override
  String get widgetOpenPageHome => 'Åpne startside';

  @override
  String get widgetOpenPageCollection => 'Åpne samling';

  @override
  String get widgetOpenPageViewer => 'Åpne visning';

  @override
  String get widgetTapUpdateWidget => 'Update widget';

  @override
  String get storageVolumeDescriptionFallbackPrimary => 'Internlagring';

  @override
  String get storageVolumeDescriptionFallbackNonPrimary => 'SD-kort';

  @override
  String get rootDirectoryDescription => 'rotmappe';

  @override
  String otherDirectoryDescription(String name) {
    return '«$name»-mappen';
  }

  @override
  String storageAccessDialogMessage(String directory, String volume) {
    return 'Velg $directory for «$volume» i neste skjerm for å gi dette programmet tilgang til det.';
  }

  @override
  String restrictedAccessDialogMessage(String directory, String volume) {
    return 'Dette kartet kan ikke endre filer i $directory for «$volume».\n\nBruk en pre-installert filbehandler eller et galleriprogram for å flytte elementene til en annen mappe.';
  }

  @override
  String notEnoughSpaceDialogMessage(String neededSize, String freeSize, String volume) {
    return 'Denne operasjonen trenger $neededSize ledig plass på «$volume» for å fullføres, men det er kun $freeSize igjen.';
  }

  @override
  String get missingSystemFilePickerDialogMessage => 'Systemfilvelgeren mangler eller er avskrudd. Skru den på igjen og prøv igjen.';

  @override
  String unsupportedTypeDialogMessage(int count, String types) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Denne operasjonen støttes ikke for elementer av følgende typer: $types.',
      one: 'Denne operasjonen støttes ikke for elementer av følgende type: $types.',
    );
    return '$_temp0';
  }

  @override
  String get nameConflictDialogSingleSourceMessage => 'Noen filer i målmappen har samme navn.';

  @override
  String get nameConflictDialogMultipleSourceMessage => 'Noen filer har samme navn.';

  @override
  String get addShortcutDialogLabel => 'Snarveisetikett';

  @override
  String get addShortcutButtonLabel => 'LEGG TIL';

  @override
  String get noMatchingAppDialogMessage => 'Ingen programmer kan håndtere dette.';

  @override
  String binEntriesConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Flytt disse $count elementene til papirkurven?',
      one: 'Flytt dette elementet til papirkurven?',
    );
    return '$_temp0';
  }

  @override
  String deleteEntriesConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Slett disse $count elementene?',
      one: 'Slett dette elementet?',
    );
    return '$_temp0';
  }

  @override
  String get moveUndatedConfirmationDialogMessage => 'Lagre elementdatoer før fortsettelse?';

  @override
  String get moveUndatedConfirmationDialogSetDate => 'Lagre datoer';

  @override
  String videoResumeDialogMessage(String time) {
    return 'Fortsett avspilling fra $time?';
  }

  @override
  String get videoStartOverButtonLabel => 'START OM IGJEN';

  @override
  String get videoResumeButtonLabel => 'FORTSETT';

  @override
  String get setCoverDialogLatest => 'Nyeste element';

  @override
  String get setCoverDialogAuto => 'Auto';

  @override
  String get setCoverDialogCustom => 'Egendefinert';

  @override
  String get hideFilterConfirmationDialogMessage => 'Samsvarende bilder og videoer vil bli skjult fra samlingen din? Du kan vise dem igjen fra «Personvern»-innstillingene.\n\nEr du sikker på at du vil skjule dem?';

  @override
  String get newAlbumDialogTitle => 'Nytt album';

  @override
  String get newAlbumDialogNameLabel => 'Albumsnavn';

  @override
  String get newAlbumDialogAlbumAlreadyExistsHelper => 'Album already exists';

  @override
  String get newAlbumDialogNameLabelAlreadyExistsHelper => 'Mappen finnes allerede';

  @override
  String get newAlbumDialogStorageLabel => 'Lagring:';

  @override
  String get newDynamicAlbumDialogTitle => 'New Dynamic Album';

  @override
  String get dynamicAlbumAlreadyExists => 'Dynamic album already exists';

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
  String get newVaultWarningDialogMessage => 'Elementer i hvelv er kun tilgjengelig for dette programmet, og ikke andre.\n\nHvis du avinstallerer dette programmet, eller tømmer denne programdataen vil du miste alle disse elementene.';

  @override
  String get newVaultDialogTitle => 'Nytt hvelv';

  @override
  String get configureVaultDialogTitle => 'Sett opp hvelv';

  @override
  String get vaultDialogLockModeWhenScreenOff => 'Lås når skjermen skrur seg av';

  @override
  String get vaultDialogLockTypeLabel => 'Låsetype';

  @override
  String get patternDialogEnter => 'Enter pattern';

  @override
  String get patternDialogConfirm => 'Bekreft mønster';

  @override
  String get pinDialogEnter => 'Skriv inn PIN';

  @override
  String get pinDialogConfirm => 'Bekreft PIN';

  @override
  String get passwordDialogEnter => 'Skriv inn passord';

  @override
  String get passwordDialogConfirm => 'Bekreft passord';

  @override
  String get authenticateToConfigureVault => 'Identitetsbekreft for å sette opp hvelv';

  @override
  String get authenticateToUnlockVault => 'Identitetsbekreft for å låse opp hvelv';

  @override
  String get vaultBinUsageDialogMessage => 'Noen hvelv bruker papirkurven.';

  @override
  String get renameAlbumDialogLabel => 'Nytt navn';

  @override
  String get renameAlbumDialogLabelAlreadyExistsHelper => 'Mappen finnes allerede';

  @override
  String get renameEntrySetPageTitle => 'Gi nytt navn';

  @override
  String get renameEntrySetPagePatternFieldLabel => 'Navngivningsmønster';

  @override
  String get renameEntrySetPageInsertTooltip => 'Sett inn felt';

  @override
  String get renameEntrySetPagePreviewSectionTitle => 'Forhåndsvis';

  @override
  String get renameProcessorCounter => 'Teller';

  @override
  String get renameProcessorHash => 'Hash';

  @override
  String get renameProcessorName => 'Navn';

  @override
  String deleteSingleAlbumConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Slett dette albumet og de $count elementene i det?',
      one: 'Slett dette albumet og elementet i det?',
    );
    return '$_temp0';
  }

  @override
  String deleteMultiAlbumConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Slett disse albumene og de $count elementene i dem?',
      one: 'Slett disse albumene og elementet i demt?',
    );
    return '$_temp0';
  }

  @override
  String get exportEntryDialogFormat => 'Format:';

  @override
  String get exportEntryDialogWidth => 'Bredde';

  @override
  String get exportEntryDialogHeight => 'Høyde';

  @override
  String get exportEntryDialogQuality => 'Kvalitet';

  @override
  String get exportEntryDialogWriteMetadata => 'Skriv metadata';

  @override
  String get renameEntryDialogLabel => 'Nytt navn';

  @override
  String get editEntryDialogCopyFromItem => 'Kopier fra annet element';

  @override
  String get editEntryDialogTargetFieldsHeader => 'Felter å endre';

  @override
  String get editEntryDateDialogTitle => 'Dato og tid';

  @override
  String get editEntryDateDialogSetCustom => 'Sett egendefinert dato';

  @override
  String get editEntryDateDialogCopyField => 'Kopier fra annen dato';

  @override
  String get editEntryDateDialogExtractFromTitle => 'Utled fra navn';

  @override
  String get editEntryDateDialogShift => 'Bytt';

  @override
  String get editEntryDateDialogSourceFileModifiedDate => 'Filendringsdato';

  @override
  String get durationDialogHours => 'Timer';

  @override
  String get durationDialogMinutes => 'Minutter';

  @override
  String get durationDialogSeconds => 'Sekunder';

  @override
  String get editEntryLocationDialogTitle => 'Plassering';

  @override
  String get editEntryLocationDialogSetCustom => 'Sett egendefinert plassering';

  @override
  String get editEntryLocationDialogChooseOnMap => 'Velg på kartet';

  @override
  String get editEntryLocationDialogImportGpx => 'Import GPX';

  @override
  String get editEntryLocationDialogLatitude => 'Breddegrad';

  @override
  String get editEntryLocationDialogLongitude => 'Lengdegrad';

  @override
  String get editEntryLocationDialogTimeShift => 'Time shift';

  @override
  String get locationPickerUseThisLocationButton => 'Bruk denne plasseringen';

  @override
  String get editEntryRatingDialogTitle => 'Vurdering';

  @override
  String get removeEntryMetadataDialogTitle => 'Metadatafjerning';

  @override
  String get removeEntryMetadataDialogAll => 'All';

  @override
  String get removeEntryMetadataDialogMore => 'Mer';

  @override
  String get removeEntryMetadataMotionPhotoXmpWarningDialogMessage => 'XMP kreves for å spille videoen inne i et bevegelig bilde.\n\nEr du sikker på at du vil fjerne det?';

  @override
  String get videoSpeedDialogLabel => 'Avspillingshastighet';

  @override
  String get videoStreamSelectionDialogVideo => 'Video';

  @override
  String get videoStreamSelectionDialogAudio => 'Lyd';

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
  String get genericFailureFeedback => 'Mislykket';

  @override
  String get genericDangerWarningDialogMessage => 'Er du sikker?';

  @override
  String get tooManyItemsErrorDialogMessage => 'Prøv igjen med færre elementer.';

  @override
  String get menuActionConfigureView => 'Vis';

  @override
  String get menuActionSelect => 'Velg';

  @override
  String get menuActionSelectAll => 'Velg alle';

  @override
  String get menuActionSelectNone => 'Fravelg alt';

  @override
  String get menuActionMap => 'Kart';

  @override
  String get menuActionSlideshow => 'Lysbildevisning';

  @override
  String get menuActionStats => 'Statistikk';

  @override
  String get viewDialogSortSectionTitle => 'Sortering';

  @override
  String get viewDialogGroupSectionTitle => 'Gruppe';

  @override
  String get viewDialogLayoutSectionTitle => 'Tilpasning';

  @override
  String get viewDialogReverseSortOrder => 'Omvendt sorteringsrekkefølge';

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
  String get coverDialogTabApp => 'Program';

  @override
  String get coverDialogTabColor => 'Farge';

  @override
  String get appPickDialogTitle => 'Velg program';

  @override
  String get appPickDialogNone => 'Ingen';

  @override
  String get aboutPageTitle => 'Om';

  @override
  String get aboutLinkLicense => 'Lisens';

  @override
  String get aboutLinkPolicy => 'Personvernspraksis';

  @override
  String get aboutBugSectionTitle => 'Feilrapport';

  @override
  String get aboutBugSaveLogInstruction => 'Lagre programlogger til fil';

  @override
  String get aboutBugCopyInfoInstruction => 'Kopier systeminfo';

  @override
  String get aboutBugCopyInfoButton => 'Kopier';

  @override
  String get aboutBugReportInstruction => 'Innrapporter på GitHub med loggføring og systeminfo';

  @override
  String get aboutBugReportButton => 'Rapporter';

  @override
  String get aboutDataUsageSectionTitle => 'Databruk';

  @override
  String get aboutDataUsageData => 'Data';

  @override
  String get aboutDataUsageCache => 'Hurtiglager';

  @override
  String get aboutDataUsageDatabase => 'Database';

  @override
  String get aboutDataUsageMisc => 'Ymse';

  @override
  String get aboutDataUsageInternal => 'Internal';

  @override
  String get aboutDataUsageExternal => 'External';

  @override
  String get aboutDataUsageClearCache => 'Clear Cache';

  @override
  String get aboutCreditsSectionTitle => 'Bidragsytere';

  @override
  String get aboutCreditsWorldAtlas1 => 'Dette programmet bruker en TopoJSON-fil fra';

  @override
  String get aboutCreditsWorldAtlas2 => 'under ISC-lisens.';

  @override
  String get aboutTranslatorsSectionTitle => 'Oversettere';

  @override
  String get aboutLicensesSectionTitle => 'Frie lisenser';

  @override
  String get aboutLicensesBanner => 'Programmet bruker følgende frie pakker og bibliotek.';

  @override
  String get aboutLicensesAndroidLibrariesSectionTitle => 'Android-bibliotek';

  @override
  String get aboutLicensesFlutterPluginsSectionTitle => 'Flutter-programtillegg';

  @override
  String get aboutLicensesFlutterPackagesSectionTitle => 'Flutter-pakker';

  @override
  String get aboutLicensesDartPackagesSectionTitle => 'Dart-pakker';

  @override
  String get aboutLicensesShowAllButtonLabel => 'Vis alle lisenser';

  @override
  String get policyPageTitle => 'Personvernspraksis';

  @override
  String get collectionPageTitle => 'Samling';

  @override
  String get collectionPickPageTitle => 'Velg';

  @override
  String get collectionSelectPageTitle => 'Velg elementer';

  @override
  String get collectionActionShowTitleSearch => 'Vis navnefilter';

  @override
  String get collectionActionHideTitleSearch => 'Skjul navnefilter';

  @override
  String get collectionActionAddDynamicAlbum => 'Add dynamic album';

  @override
  String get collectionActionAddShortcut => 'Legg til snarvei';

  @override
  String get collectionActionSetHome => 'Set as home';

  @override
  String get collectionActionEmptyBin => 'Tøm papirkurv';

  @override
  String get collectionActionCopy => 'Kopier til album';

  @override
  String get collectionActionMove => 'Flytt til album';

  @override
  String get collectionActionRescan => 'Skann igjen';

  @override
  String get collectionActionEdit => 'Rediger';

  @override
  String get collectionSearchTitlesHintText => 'Søk etter navn';

  @override
  String get collectionGroupAlbum => 'Etter album';

  @override
  String get collectionGroupMonth => 'Etter måned';

  @override
  String get collectionGroupDay => 'Etter dag';

  @override
  String get sectionNone => 'No sections';

  @override
  String get sectionUnknown => 'Ukjent';

  @override
  String get dateToday => 'I dag';

  @override
  String get dateYesterday => 'I går';

  @override
  String get dateThisMonth => 'Denne måneden';

  @override
  String collectionDeleteFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Klarte ikke å fjerne $count elementer',
      one: 'Klarte ikke å fjerne 1 element',
    );
    return '$_temp0';
  }

  @override
  String collectionCopyFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Klarte ikke å kopiere $count elementer',
      one: 'Klarte ikke å kopiere 1 element',
    );
    return '$_temp0';
  }

  @override
  String collectionMoveFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Klarte ikke å flytte $count elementer',
      one: 'Klarte ikke å flytte 1 element',
    );
    return '$_temp0';
  }

  @override
  String collectionRenameFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Klarte ikke å endre navn på $count elementer',
      one: 'Klarte ikke å endre navn på 1 element',
    );
    return '$_temp0';
  }

  @override
  String collectionEditFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Klarte ikke å redigere $count elementer',
      one: 'Klarte ikke å redigere 1 element',
    );
    return '$_temp0';
  }

  @override
  String collectionExportFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Klarte ikke å eksportere $count sider',
      one: 'Klarte ikke å eksportere 1 side',
    );
    return '$_temp0';
  }

  @override
  String collectionCopySuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kopierte $count elementer',
      one: 'Kopierte 1 element',
    );
    return '$_temp0';
  }

  @override
  String collectionMoveSuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Flyttet $count elementer',
      one: 'Flyttet 1 element',
    );
    return '$_temp0';
  }

  @override
  String collectionRenameSuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Endret navn på $count elementer',
      one: 'Endret navn på 1 element',
    );
    return '$_temp0';
  }

  @override
  String collectionEditSuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Redigerte $count elementer',
      one: 'Redigerte 1 element',
    );
    return '$_temp0';
  }

  @override
  String get collectionEmptyFavourites => 'Ingen favoritter';

  @override
  String get collectionEmptyVideos => 'Ingen videoer';

  @override
  String get collectionEmptyImages => 'Ingen bilder';

  @override
  String get collectionEmptyGrantAccessButtonLabel => 'Innvilg tilgang';

  @override
  String get collectionSelectSectionTooltip => 'Velg utvalg';

  @override
  String get collectionDeselectSectionTooltip => 'Fravelg utvalg';

  @override
  String get drawerAboutButton => 'Om';

  @override
  String get drawerSettingsButton => 'Innstillinger';

  @override
  String get drawerCollectionAll => 'Alle samlinger';

  @override
  String get drawerCollectionFavourites => 'Favoritter';

  @override
  String get drawerCollectionImages => 'Bilder';

  @override
  String get drawerCollectionVideos => 'Videoer';

  @override
  String get drawerCollectionAnimated => 'Animert';

  @override
  String get drawerCollectionMotionPhotos => 'Bevegelige bilder';

  @override
  String get drawerCollectionPanoramas => 'Panoramaer';

  @override
  String get drawerCollectionRaws => 'Raw bilder';

  @override
  String get drawerCollectionSphericalVideos => '360°-videoer';

  @override
  String get drawerAlbumPage => 'Album';

  @override
  String get drawerCountryPage => 'Land';

  @override
  String get drawerPlacePage => 'Steder';

  @override
  String get drawerTagPage => 'Etiketter';

  @override
  String get sortByDate => 'Etter dato';

  @override
  String get sortByName => 'Etter navn';

  @override
  String get sortByItemCount => 'Etter antall elementer';

  @override
  String get sortBySize => 'Etter størrelse';

  @override
  String get sortByAlbumFileName => 'Etter album og filnavn';

  @override
  String get sortByRating => 'Etter vurdering';

  @override
  String get sortByDuration => 'By duration';

  @override
  String get sortByPath => 'By path';

  @override
  String get sortOrderNewestFirst => 'Nyeste først';

  @override
  String get sortOrderOldestFirst => 'Eldste først';

  @override
  String get sortOrderAtoZ => 'A-Å';

  @override
  String get sortOrderZtoA => 'Å-A';

  @override
  String get sortOrderHighestFirst => 'Høyeste først';

  @override
  String get sortOrderLowestFirst => 'Laveste først';

  @override
  String get sortOrderLargestFirst => 'Største først';

  @override
  String get sortOrderSmallestFirst => 'Minste først';

  @override
  String get sortOrderShortestFirst => 'Shortest first';

  @override
  String get sortOrderLongestFirst => 'Longest first';

  @override
  String get albumGroupTier => 'Etter nivå';

  @override
  String get albumGroupType => 'Etter type';

  @override
  String get albumGroupVolume => 'Etter lagringsdataområde';

  @override
  String get albumMimeTypeMixed => 'Blandet';

  @override
  String get albumPickPageTitleCopy => 'Kopier til album';

  @override
  String get albumPickPageTitleExport => 'Eksporter til album';

  @override
  String get albumPickPageTitleMove => 'Flytt til album';

  @override
  String get albumPickPageTitlePick => 'Velg album';

  @override
  String get albumCamera => 'Kamera';

  @override
  String get albumDownload => 'Last ned';

  @override
  String get albumScreenshots => 'Skjermavbildninger';

  @override
  String get albumScreenRecordings => 'Skjermopptak';

  @override
  String get albumVideoCaptures => 'Videoopptak';

  @override
  String get albumPageTitle => 'Album';

  @override
  String get albumEmpty => 'Ingen album';

  @override
  String get createAlbumButtonLabel => 'OPPRETT';

  @override
  String get newFilterBanner => 'ny';

  @override
  String get countryPageTitle => 'Land';

  @override
  String get countryEmpty => 'Ingen land';

  @override
  String get statePageTitle => 'Tilstander';

  @override
  String get stateEmpty => 'Ingen tilstander';

  @override
  String get placePageTitle => 'Steder';

  @override
  String get placeEmpty => 'Ingen steder';

  @override
  String get tagPageTitle => 'Etiketter';

  @override
  String get tagEmpty => 'Ingen etiketter';

  @override
  String get binPageTitle => 'Papirkurv';

  @override
  String get explorerPageTitle => 'Explorer';

  @override
  String get explorerActionSelectStorageVolume => 'Select storage';

  @override
  String get selectStorageVolumeDialogTitle => 'Select Storage';

  @override
  String get searchCollectionFieldHint => 'Søk i samling';

  @override
  String get searchRecentSectionTitle => 'Nylige';

  @override
  String get searchDateSectionTitle => 'Dato';

  @override
  String get searchFormatSectionTitle => 'Formats';

  @override
  String get searchAlbumsSectionTitle => 'Album';

  @override
  String get searchCountriesSectionTitle => 'Land';

  @override
  String get searchStatesSectionTitle => 'Tilstander';

  @override
  String get searchPlacesSectionTitle => 'Steder';

  @override
  String get searchTagsSectionTitle => 'Etiketter';

  @override
  String get searchRatingSectionTitle => 'Vurderinger';

  @override
  String get searchMetadataSectionTitle => 'Metadata';

  @override
  String get settingsPageTitle => 'Innstillinger';

  @override
  String get settingsSystemDefault => 'Systemforvalg';

  @override
  String get settingsDefault => 'Forvalg';

  @override
  String get settingsDisabled => 'Avskrudd';

  @override
  String get settingsAskEverytime => 'Spør hver gang';

  @override
  String get settingsModificationWarningDialogMessage => 'Andre innstillinger vil bli endret.';

  @override
  String get settingsSearchFieldLabel => 'Søkeinnstillinger';

  @override
  String get settingsSearchEmpty => 'Ingen samsvarende innstilling';

  @override
  String get settingsActionExport => 'Eksporter';

  @override
  String get settingsActionExportDialogTitle => 'Eksporter';

  @override
  String get settingsActionImport => 'Importer';

  @override
  String get settingsActionImportDialogTitle => 'Importer';

  @override
  String get appExportCovers => 'Omslag';

  @override
  String get appExportDynamicAlbums => 'Dynamic albums';

  @override
  String get appExportFavourites => 'Favoritter';

  @override
  String get appExportSettings => 'Innstillinger';

  @override
  String get settingsNavigationSectionTitle => 'Navigasjon';

  @override
  String get settingsHomeTile => 'Hjem';

  @override
  String get settingsHomeDialogTitle => 'Hjem';

  @override
  String get setHomeCustom => 'Custom';

  @override
  String get settingsShowBottomNavigationBar => 'Vis navigasjonsfelt på bunnen';

  @override
  String get settingsKeepScreenOnTile => 'Behold skjermen påslått';

  @override
  String get settingsKeepScreenOnDialogTitle => 'Behold skjermen påslått';

  @override
  String get settingsDoubleBackExit => 'Trykk «Tilbake» to ganger for å avslutte';

  @override
  String get settingsConfirmationTile => 'Bekreftelsesdialoger';

  @override
  String get settingsConfirmationDialogTitle => 'Bekreftelsesdialoger';

  @override
  String get settingsConfirmationBeforeDeleteItems => 'Spør før permanent sletting av elementer';

  @override
  String get settingsConfirmationBeforeMoveToBinItems => 'Spør før flytting av elementer til papirkurven';

  @override
  String get settingsConfirmationBeforeMoveUndatedItems => 'Spør før flytting av ikke-daterte elementer';

  @override
  String get settingsConfirmationAfterMoveToBinItems => 'Vis melding etter flytting av elementer til papirkurven';

  @override
  String get settingsConfirmationVaultDataLoss => 'Vis advarsel om hvelv-datatap';

  @override
  String get settingsNavigationDrawerTile => 'Navigasjonsmeny';

  @override
  String get settingsNavigationDrawerEditorPageTitle => 'Navigasjonsmeny';

  @override
  String get settingsNavigationDrawerBanner => 'Trykk og hold for å flytte og endre rekkefølge på menyelementer.';

  @override
  String get settingsNavigationDrawerTabTypes => 'Typer';

  @override
  String get settingsNavigationDrawerTabAlbums => 'Album';

  @override
  String get settingsNavigationDrawerTabPages => 'Sider';

  @override
  String get settingsNavigationDrawerAddAlbum => 'Legg til album';

  @override
  String get settingsThumbnailSectionTitle => 'Miniatyrbilder';

  @override
  String get settingsThumbnailOverlayTile => 'Overlag';

  @override
  String get settingsThumbnailOverlayPageTitle => 'Overlag';

  @override
  String get settingsThumbnailShowHdrIcon => 'Show HDR icon';

  @override
  String get settingsThumbnailShowFavouriteIcon => 'Vis favoritt-ikon';

  @override
  String get settingsThumbnailShowTagIcon => 'Vis etikett-ikon';

  @override
  String get settingsThumbnailShowLocationIcon => 'Vis plasserings-ikon';

  @override
  String get settingsThumbnailShowMotionPhotoIcon => 'Vis bevegelig bilde -ikon';

  @override
  String get settingsThumbnailShowRating => 'Vis vurdering';

  @override
  String get settingsThumbnailShowRawIcon => 'Vis raw-ikon';

  @override
  String get settingsThumbnailShowVideoDuration => 'Vis videovarighet';

  @override
  String get settingsCollectionQuickActionsTile => 'Hurtighandlinger';

  @override
  String get settingsCollectionQuickActionEditorPageTitle => 'Hurtighandlinger';

  @override
  String get settingsCollectionQuickActionTabBrowsing => 'Utforskning';

  @override
  String get settingsCollectionQuickActionTabSelecting => 'Utvelgelse';

  @override
  String get settingsCollectionBrowsingQuickActionEditorBanner => 'Trykk og hold for å flytte knapper og velge hvilke handlinger som skal vises ved utforskning av elementer.';

  @override
  String get settingsCollectionSelectionQuickActionEditorBanner => 'Trykk og hold for å flytte knapper og velge hvilke handlinger som vises når du velger elementer.';

  @override
  String get settingsCollectionBurstPatternsTile => 'Burst patterns';

  @override
  String get settingsCollectionBurstPatternsNone => 'None';

  @override
  String get settingsViewerSectionTitle => 'Viser';

  @override
  String get settingsViewerGestureSideTapNext => 'Trykk på skjermkantene for å vise forrige/neste element';

  @override
  String get settingsViewerUseCutout => 'Bruk utklippsområde';

  @override
  String get settingsViewerMaximumBrightness => 'Maksimal lysstyrke';

  @override
  String get settingsMotionPhotoAutoPlay => 'Auto-spill bevegelige bilder';

  @override
  String get settingsImageBackground => 'Bildebakgrunn';

  @override
  String get settingsViewerQuickActionsTile => 'Hurtighandlinger';

  @override
  String get settingsViewerQuickActionEditorPageTitle => 'Hurtighandlinger';

  @override
  String get settingsViewerQuickActionEditorBanner => 'Trykk og hold for å flytte knapper og velg hvilke handlinger som vises i viseren.';

  @override
  String get settingsViewerQuickActionEditorDisplayedButtonsSectionTitle => 'Viste knapper';

  @override
  String get settingsViewerQuickActionEditorAvailableButtonsSectionTitle => 'Tilgjengelige knapper';

  @override
  String get settingsViewerQuickActionEmpty => 'Ingen knapper';

  @override
  String get settingsViewerOverlayTile => 'Overlag';

  @override
  String get settingsViewerOverlayPageTitle => 'Overlag';

  @override
  String get settingsViewerShowOverlayOnOpening => 'Vis ved åpning';

  @override
  String get settingsViewerShowHistogram => 'Show histogram';

  @override
  String get settingsViewerShowMinimap => 'Vis minikart';

  @override
  String get settingsViewerShowInformation => 'Vis info';

  @override
  String get settingsViewerShowInformationSubtitle => 'Vis navn, dato, posisjon, osv.';

  @override
  String get settingsViewerShowRatingTags => 'Vis vurdering og etiketter';

  @override
  String get settingsViewerShowShootingDetails => 'Vis knipsingsdetaljer';

  @override
  String get settingsViewerShowDescription => 'Vis beskrivelse';

  @override
  String get settingsViewerShowOverlayThumbnails => 'Vis miniatyrbilder';

  @override
  String get settingsViewerEnableOverlayBlurEffect => 'Tilsløringseffekt';

  @override
  String get settingsViewerSlideshowTile => 'Lysbildevisning';

  @override
  String get settingsViewerSlideshowPageTitle => 'Lysbildevisning';

  @override
  String get settingsSlideshowRepeat => 'Gjenta';

  @override
  String get settingsSlideshowShuffle => 'Stokk';

  @override
  String get settingsSlideshowFillScreen => 'Fyll skjermen';

  @override
  String get settingsSlideshowAnimatedZoomEffect => 'Animert forstørrelseseffekt';

  @override
  String get settingsSlideshowTransitionTile => 'Overgang';

  @override
  String get settingsSlideshowIntervalTile => 'Intervall';

  @override
  String get settingsSlideshowVideoPlaybackTile => 'Videoavspilling';

  @override
  String get settingsSlideshowVideoPlaybackDialogTitle => 'Videoavspilling';

  @override
  String get settingsVideoPageTitle => 'Videoinnstillinger';

  @override
  String get settingsVideoSectionTitle => 'Video';

  @override
  String get settingsVideoShowVideos => 'Vis videoer';

  @override
  String get settingsVideoPlaybackTile => 'Avspilling';

  @override
  String get settingsVideoPlaybackPageTitle => 'Avspilling';

  @override
  String get settingsVideoEnableHardwareAcceleration => 'Maskinvareakselerasjon';

  @override
  String get settingsVideoAutoPlay => 'Automatisk avspilling';

  @override
  String get settingsVideoLoopModeTile => 'Gjentagelsesmodus';

  @override
  String get settingsVideoLoopModeDialogTitle => 'Gjentagelsesmodus';

  @override
  String get settingsVideoResumptionModeTile => 'Gjenoppta avspilling';

  @override
  String get settingsVideoResumptionModeDialogTitle => 'Gjenoppta avspilling';

  @override
  String get settingsVideoBackgroundMode => 'Bakgrunnsmodus';

  @override
  String get settingsVideoBackgroundModeDialogTitle => 'Bakgrunnsmodus';

  @override
  String get settingsVideoControlsTile => 'Kontroller';

  @override
  String get settingsVideoControlsPageTitle => 'Kontroller';

  @override
  String get settingsVideoButtonsTile => 'Knapper';

  @override
  String get settingsVideoGestureDoubleTapTogglePlay => 'Dobbelttrykk for å spille/pause';

  @override
  String get settingsVideoGestureSideDoubleTapSeek => 'Dobbelttrykk på skjermkantene for å blafre forover/bakover';

  @override
  String get settingsVideoGestureVerticalDragBrightnessVolume => 'Dra opp eller ned for å justere lys-/lydstyrke';

  @override
  String get settingsSubtitleThemeTile => 'Undertekster';

  @override
  String get settingsSubtitleThemePageTitle => 'Undertekster';

  @override
  String get settingsSubtitleThemeSample => 'Dette er et eksempel.';

  @override
  String get settingsSubtitleThemeTextAlignmentTile => 'Tekstjustering';

  @override
  String get settingsSubtitleThemeTextAlignmentDialogTitle => 'Tekstjustering';

  @override
  String get settingsSubtitleThemeTextPositionTile => 'Tekstposisjon';

  @override
  String get settingsSubtitleThemeTextPositionDialogTitle => 'Tekstposisjon';

  @override
  String get settingsSubtitleThemeTextSize => 'Tekststørrelse';

  @override
  String get settingsSubtitleThemeShowOutline => 'Vis omriss og skygge';

  @override
  String get settingsSubtitleThemeTextColor => 'Tekstfarge';

  @override
  String get settingsSubtitleThemeTextOpacity => 'Tekst-dekkevne';

  @override
  String get settingsSubtitleThemeBackgroundColor => 'Bakgrunnsfarge';

  @override
  String get settingsSubtitleThemeBackgroundOpacity => 'Bakgrunnsdekkevne';

  @override
  String get settingsSubtitleThemeTextAlignmentLeft => 'Venstre';

  @override
  String get settingsSubtitleThemeTextAlignmentCenter => 'Midten';

  @override
  String get settingsSubtitleThemeTextAlignmentRight => 'Høyre';

  @override
  String get settingsPrivacySectionTitle => 'Personvern';

  @override
  String get settingsAllowInstalledAppAccess => 'Tillat tilgang til programliste';

  @override
  String get settingsAllowInstalledAppAccessSubtitle => 'Brukt til forbedring av albumsvisning';

  @override
  String get settingsAllowErrorReporting => 'Tillat anonym feilrapportering';

  @override
  String get settingsSaveSearchHistory => 'Lagre søkehistorikk';

  @override
  String get settingsEnableBin => 'Bruk papirkurv';

  @override
  String get settingsEnableBinSubtitle => 'Behold slettede elementer i 30 dager';

  @override
  String get settingsDisablingBinWarningDialogMessage => 'Elementer i papirkurven vil bli slettet for godt.';

  @override
  String get settingsAllowMediaManagement => 'Tillat mediahåndtering';

  @override
  String get settingsHiddenItemsTile => 'Skjulte elementer';

  @override
  String get settingsHiddenItemsPageTitle => 'Skjulte elementer';

  @override
  String get settingsHiddenFiltersBanner => 'Bilder og videoer som samsvarer med skjulte filtre vil ikke vises i samlingen din.';

  @override
  String get settingsHiddenFiltersEmpty => 'Ingen skjulte filtre';

  @override
  String get settingsStorageAccessTile => 'Lagringstilgang';

  @override
  String get settingsStorageAccessPageTitle => 'Lagringstilgang';

  @override
  String get settingsStorageAccessBanner => 'Noen mapper krever eksplisitt tilgang til å endre filene i dem. Du kan gjennomse hvilke mapper du har gitt tilgang til tidligere her.';

  @override
  String get settingsStorageAccessEmpty => 'Ingen tilgangsinnvilgelser';

  @override
  String get settingsStorageAccessRevokeTooltip => 'Tilbakekall';

  @override
  String get settingsAccessibilitySectionTitle => 'Tilgjengelighet';

  @override
  String get settingsRemoveAnimationsTile => 'Fjern animasjoner';

  @override
  String get settingsRemoveAnimationsDialogTitle => 'Fjern animasjoner';

  @override
  String get settingsTimeToTakeActionTile => 'Tid for handling';

  @override
  String get settingsAccessibilityShowPinchGestureAlternatives => 'Vis multi-trykkhåndvendingsalternativer';

  @override
  String get settingsDisplaySectionTitle => 'Visning';

  @override
  String get settingsThemeBrightnessTile => 'Drakt';

  @override
  String get settingsThemeBrightnessDialogTitle => 'Drakt';

  @override
  String get settingsThemeColorHighlights => 'Fargede framhevelser';

  @override
  String get settingsThemeEnableDynamicColor => 'Dynamisk farge';

  @override
  String get settingsDisplayRefreshRateModeTile => 'Visningsoppfiskningstakt';

  @override
  String get settingsDisplayRefreshRateModeDialogTitle => 'Oppfriskningstakt';

  @override
  String get settingsDisplayUseTvInterface => 'Android TV-grensesnitt';

  @override
  String get settingsLanguageSectionTitle => 'Språk og formater';

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
  String get settingsForceWesternArabicNumeralsTile => 'Force Arabic numerals';

  @override
  String get settingsScreenSaverPageTitle => 'Skjermsparer';

  @override
  String get settingsWidgetPageTitle => 'Bilderamme';

  @override
  String get settingsWidgetShowOutline => 'Omriss';

  @override
  String get settingsWidgetOpenPage => 'Når miniprogrammet trykkes';

  @override
  String get settingsWidgetDisplayedItem => 'Vist element';

  @override
  String get settingsCollectionTile => 'Samling';

  @override
  String get statsPageTitle => 'Statistikk';

  @override
  String statsWithGps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementer med plassering',
      one: '1 element med plassering',
    );
    return '$_temp0';
  }

  @override
  String get statsTopCountriesSectionTitle => 'Toppland';

  @override
  String get statsTopStatesSectionTitle => 'Top States';

  @override
  String get statsTopPlacesSectionTitle => 'Toppsteder';

  @override
  String get statsTopTagsSectionTitle => 'Topp-etiketter';

  @override
  String get statsTopAlbumsSectionTitle => 'Topp-album';

  @override
  String get viewerOpenPanoramaButtonLabel => 'ÅPNE PANORAMA';

  @override
  String get viewerSetWallpaperButtonLabel => 'SETT SOM BAKGRUNNSBILDE';

  @override
  String get viewerErrorUnknown => 'Oida.';

  @override
  String get viewerErrorDoesNotExist => 'Filen finnes ikke lenger.';

  @override
  String get viewerInfoPageTitle => 'Info';

  @override
  String get viewerInfoBackToViewerTooltip => 'Tilbake til visning';

  @override
  String get viewerInfoUnknown => 'ukjent';

  @override
  String get viewerInfoLabelDescription => 'Beskrivelse';

  @override
  String get viewerInfoLabelTitle => 'Navn';

  @override
  String get viewerInfoLabelDate => 'Dato';

  @override
  String get viewerInfoLabelResolution => 'Oppløsning';

  @override
  String get viewerInfoLabelSize => 'Størrelse';

  @override
  String get viewerInfoLabelUri => 'URI';

  @override
  String get viewerInfoLabelPath => 'Sti';

  @override
  String get viewerInfoLabelDuration => 'Varighet';

  @override
  String get viewerInfoLabelOwner => 'Eier';

  @override
  String get viewerInfoLabelCoordinates => 'Koordinater';

  @override
  String get viewerInfoLabelAddress => 'Adresse';

  @override
  String get mapStyleDialogTitle => 'Kartstil';

  @override
  String get mapStyleTooltip => 'Velg kartstil';

  @override
  String get mapZoomInTooltip => 'Forstørr';

  @override
  String get mapZoomOutTooltip => 'Forminsk';

  @override
  String get mapPointNorthUpTooltip => 'Nord oppover';

  @override
  String get mapAttributionOsmData => 'Kartdata © [OpenStreetMap](https://www.openstreetmap.org/copyright)-bidragsyterne';

  @override
  String get mapAttributionOsmLiberty => 'Tiles by [OpenMapTiles](https://www.openmaptiles.org/), [CC BY](http://creativecommons.org/licenses/by/4.0) • Hosted by [OSM Americana](https://tile.ourmap.us)';

  @override
  String get mapAttributionOpenTopoMap => '[SRTM](https://www.earthdata.nasa.gov/sensors/srtm) | Tiles by [OpenTopoMap](https://opentopomap.org/), [CC BY-SA](https://creativecommons.org/licenses/by-sa/3.0/)';

  @override
  String get mapAttributionOsmHot => 'Flis av [HOT](https://www.hotosm.org) • Vertstjent av [OSM France](https://openstreetmap.fr)';

  @override
  String get mapAttributionStamen => 'Flis av [Stamen Design](https://stamen.com), [CC BY 3.0](https://creativecommons.org/licenses/by/3.0)';

  @override
  String get openMapPageTooltip => 'Vis på kartsiden';

  @override
  String get mapEmptyRegion => 'Ingen bilder i denne regionen';

  @override
  String get viewerInfoOpenEmbeddedFailureFeedback => 'Klarte ikke å pakke ut innebygd data';

  @override
  String get viewerInfoOpenLinkText => 'Åpne';

  @override
  String get viewerInfoViewXmlLinkText => 'Vis XML';

  @override
  String get viewerInfoSearchFieldLabel => 'Søk metadata';

  @override
  String get viewerInfoSearchEmpty => 'Ingen samsvarende nøkler';

  @override
  String get viewerInfoSearchSuggestionDate => 'Dato og tid';

  @override
  String get viewerInfoSearchSuggestionDescription => 'Beskrivelse';

  @override
  String get viewerInfoSearchSuggestionDimensions => 'Dimensjoner';

  @override
  String get viewerInfoSearchSuggestionResolution => 'Oppløsning';

  @override
  String get viewerInfoSearchSuggestionRights => 'Rettigheter';

  @override
  String get wallpaperUseScrollEffect => 'Bruk rulleeffekt på hjemmeskjerm';

  @override
  String get tagEditorPageTitle => 'Rediger etiketter';

  @override
  String get tagEditorPageNewTagFieldLabel => 'Ny etikett';

  @override
  String get tagEditorPageAddTagTooltip => 'Legg til etikett';

  @override
  String get tagEditorSectionRecent => 'Nylig';

  @override
  String get tagEditorSectionPlaceholders => 'Plassholdere';

  @override
  String get tagEditorDiscardDialogMessage => 'Forkast endringer?';

  @override
  String get tagPlaceholderCountry => 'Land';

  @override
  String get tagPlaceholderState => 'Tilstand';

  @override
  String get tagPlaceholderPlace => 'Sted';

  @override
  String get panoramaEnableSensorControl => 'Skru på sensorstyring';

  @override
  String get panoramaDisableSensorControl => 'Skru av sensorstyring';

  @override
  String get sourceViewerPageTitle => 'Kilde';
}
