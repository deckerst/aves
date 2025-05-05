// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Danish (`da`).
class AppLocalizationsDa extends AppLocalizations {
  AppLocalizationsDa([String locale = 'da']) : super(locale);

  @override
  String get appName => 'Aves';

  @override
  String get welcomeMessage => 'Velkommen til Aves';

  @override
  String get welcomeOptional => 'Valgfri';

  @override
  String get welcomeTermsToggle => 'Jeg accepterer vilkårene og betingelserne';

  @override
  String itemCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString elementer',
      one: '$countString element',
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
      other: '$countString kolonner',
      one: '$countString kolonne',
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
      other: '$countString dage',
      one: '$countString dag',
    );
    return '$_temp0';
  }

  @override
  String focalLength(String length) {
    return '$length mm';
  }

  @override
  String get applyButtonLabel => 'ANVEND';

  @override
  String get createButtonLabel => 'CREATE';

  @override
  String get deleteButtonLabel => 'SLET';

  @override
  String get nextButtonLabel => 'NÆSTE';

  @override
  String get showButtonLabel => 'VIS';

  @override
  String get hideButtonLabel => 'SKJUL';

  @override
  String get continueButtonLabel => 'FORTSÆT';

  @override
  String get saveCopyButtonLabel => 'GEM KOPI';

  @override
  String get applyTooltip => 'Anvend';

  @override
  String get cancelTooltip => 'Annuller';

  @override
  String get changeTooltip => 'Ændr';

  @override
  String get clearTooltip => 'Ryd';

  @override
  String get previousTooltip => 'Forrige';

  @override
  String get nextTooltip => 'Næste';

  @override
  String get showTooltip => 'Vis';

  @override
  String get hideTooltip => 'Skjul';

  @override
  String get actionRemove => 'Fjern';

  @override
  String get resetTooltip => 'Nulstil';

  @override
  String get saveTooltip => 'Gem';

  @override
  String get stopTooltip => 'Stop';

  @override
  String get pickTooltip => 'Vælg';

  @override
  String get doubleBackExitMessage => 'Tryk på “tilbage” igen for at afslutte.';

  @override
  String get doNotAskAgain => 'Spørg ikke igen';

  @override
  String get sourceStateLoading => 'Indlæser';

  @override
  String get sourceStateCataloguing => 'Katalogisering';

  @override
  String get sourceStateLocatingCountries => 'Lokaliserer lande';

  @override
  String get sourceStateLocatingPlaces => 'Lokaliserer steder';

  @override
  String get chipActionDelete => 'Slet';

  @override
  String get chipActionRemove => 'Fjern';

  @override
  String get chipActionShowCollection => 'Vis i samling';

  @override
  String get chipActionGoToAlbumPage => 'Vis i album';

  @override
  String get chipActionGoToCountryPage => 'Vis i lande';

  @override
  String get chipActionGoToPlacePage => 'Vis i steder';

  @override
  String get chipActionGoToTagPage => 'Vis i tags';

  @override
  String get chipActionGoToExplorerPage => 'Vis i stifinder';

  @override
  String get chipActionDecompose => 'Split';

  @override
  String get chipActionFilterOut => 'Filtrer ud';

  @override
  String get chipActionFilterIn => 'Filtrer ind';

  @override
  String get chipActionHide => 'Skjul';

  @override
  String get chipActionLock => 'Lås';

  @override
  String get chipActionPin => 'Fastgør til toppen';

  @override
  String get chipActionUnpin => 'Frigør fra toppen';

  @override
  String get chipActionGroup => 'Group';

  @override
  String get chipActionRename => 'Omdøb';

  @override
  String get chipActionSetCover => 'Indstil cover';

  @override
  String get chipActionShowCountryStates => 'Vis stater';

  @override
  String get chipActionCreateGroup => 'Create group';

  @override
  String get chipActionCreateAlbum => 'Opret album';

  @override
  String get chipActionCreateVault => 'Opret boks';

  @override
  String get chipActionConfigureVault => 'Konfigurer boks';

  @override
  String get entryActionCopyToClipboard => 'Kopiér til udklipsholder';

  @override
  String get entryActionDelete => 'Slet';

  @override
  String get entryActionConvert => 'Konverter';

  @override
  String get entryActionExport => 'Eksportér';

  @override
  String get entryActionInfo => 'Info';

  @override
  String get entryActionRename => 'Omdøb';

  @override
  String get entryActionRestore => 'Gendan';

  @override
  String get entryActionRotateCCW => 'Roter mod uret';

  @override
  String get entryActionRotateCW => 'Roter med uret';

  @override
  String get entryActionFlip => 'Vend det vandret';

  @override
  String get entryActionPrint => 'Udskriv';

  @override
  String get entryActionShare => 'Del';

  @override
  String get entryActionShareImageOnly => 'Del kun billede';

  @override
  String get entryActionShareVideoOnly => 'Del kun video';

  @override
  String get entryActionViewSource => 'Se kilde';

  @override
  String get entryActionShowGeoTiffOnMap => 'Vis som kortoverlejring';

  @override
  String get entryActionConvertMotionPhotoToStillImage => 'Konverter til stillbillede';

  @override
  String get entryActionViewMotionPhotoVideo => 'Åbn video';

  @override
  String get entryActionEdit => 'Rediger';

  @override
  String get entryActionOpen => 'Åbn med';

  @override
  String get entryActionSetAs => 'Indstil som';

  @override
  String get entryActionCast => 'Cast';

  @override
  String get entryActionOpenMap => 'Vis i kort-app';

  @override
  String get entryActionRotateScreen => 'Roter skærm';

  @override
  String get entryActionAddFavourite => 'Føj til favoritter';

  @override
  String get entryActionRemoveFavourite => 'Fjern fra favoritter';

  @override
  String get videoActionCaptureFrame => 'Tag billede af frame';

  @override
  String get videoActionMute => 'Slå lyden fra';

  @override
  String get videoActionUnmute => 'Slå lyden til';

  @override
  String get videoActionPause => 'Sæt på pause';

  @override
  String get videoActionPlay => 'Afspil';

  @override
  String get videoActionReplay10 => 'Spol 10 sekunder tilbage';

  @override
  String get videoActionSkip10 => 'Spol 10 sekunder frem';

  @override
  String get videoActionShowPreviousFrame => 'Vis forrige frame';

  @override
  String get videoActionShowNextFrame => 'Vis næste frame';

  @override
  String get videoActionSelectStreams => 'Vælg spor';

  @override
  String get videoActionSetSpeed => 'Afspilningshastighed';

  @override
  String get videoActionABRepeat => 'A-B gentagelse';

  @override
  String get videoRepeatActionSetStart => 'Sæt start';

  @override
  String get videoRepeatActionSetEnd => 'Sæt slut';

  @override
  String get viewerActionSettings => 'Indstillinger';

  @override
  String get viewerActionLock => 'Lås fremviser';

  @override
  String get viewerActionUnlock => 'Oplås fremviser';

  @override
  String get slideshowActionResume => 'Genoptag';

  @override
  String get slideshowActionShowInCollection => 'Vis i samling';

  @override
  String get entryInfoActionEditDate => 'Rediger dato og tid';

  @override
  String get entryInfoActionEditLocation => 'Rediger placering';

  @override
  String get entryInfoActionEditTitleDescription => 'Rediger titel og beskrivelse';

  @override
  String get entryInfoActionEditRating => 'Rediger bedømmelse';

  @override
  String get entryInfoActionEditTags => 'Rediger tags';

  @override
  String get entryInfoActionRemoveMetadata => 'Fjern metadata';

  @override
  String get entryInfoActionExportMetadata => 'Eksportér metadata';

  @override
  String get entryInfoActionRemoveLocation => 'Fjern placering';

  @override
  String get editorActionTransform => 'Transformer';

  @override
  String get editorTransformCrop => 'Beskær';

  @override
  String get editorTransformRotate => 'Roter';

  @override
  String get cropAspectRatioFree => 'Frit';

  @override
  String get cropAspectRatioOriginal => 'Original';

  @override
  String get cropAspectRatioSquare => 'Firkant';

  @override
  String get filterAspectRatioLandscapeLabel => 'Landskab';

  @override
  String get filterAspectRatioPortraitLabel => 'Portræt';

  @override
  String get filterBinLabel => 'Papirkurv';

  @override
  String get filterFavouriteLabel => 'Favorit';

  @override
  String get filterNoDateLabel => 'Udateret';

  @override
  String get filterNoAddressLabel => 'Ingen adresse';

  @override
  String get filterLocatedLabel => 'Placeret';

  @override
  String get filterNoLocationLabel => 'Ikke placeret';

  @override
  String get filterNoRatingLabel => 'Ikke bedømt';

  @override
  String get filterTaggedLabel => 'Tagget';

  @override
  String get filterNoTagLabel => 'Ikke tagget';

  @override
  String get filterNoTitleLabel => 'Uden titel';

  @override
  String get filterOnThisDayLabel => 'På denne dag';

  @override
  String get filterRecentlyAddedLabel => 'Nyligt tilføjet';

  @override
  String get filterRatingRejectedLabel => 'Afvist';

  @override
  String get filterTypeAnimatedLabel => 'Animeret';

  @override
  String get filterTypeMotionPhotoLabel => 'Bevægelsesfoto';

  @override
  String get filterTypePanoramaLabel => 'Panorama';

  @override
  String get filterTypeRawLabel => 'Rå';

  @override
  String get filterTypeSphericalVideoLabel => '360° video';

  @override
  String get filterTypeGeotiffLabel => 'GeoTIFF';

  @override
  String get filterMimeImageLabel => 'Billede';

  @override
  String get filterMimeVideoLabel => 'Video';

  @override
  String get accessibilityAnimationsRemove => 'Undgå skærmeffekter';

  @override
  String get accessibilityAnimationsKeep => 'Behold skærmeffekter';

  @override
  String get albumTierNew => 'Ny';

  @override
  String get albumTierPinned => 'Fastgjort';

  @override
  String get albumTierGroups => 'Groups';

  @override
  String get albumTierSpecial => 'Almindelig';

  @override
  String get albumTierApps => 'Apps';

  @override
  String get albumTierVaults => 'Bokse';

  @override
  String get albumTierDynamic => 'Dynamisk';

  @override
  String get albumTierRegular => 'Andre';

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
  String get coordinateDmsEast => 'Ø';

  @override
  String get coordinateDmsWest => 'V';

  @override
  String get displayRefreshRatePreferHighest => 'Højeste hastighed';

  @override
  String get displayRefreshRatePreferLowest => 'Laveste hastighed';

  @override
  String get keepScreenOnNever => 'Aldrig';

  @override
  String get keepScreenOnVideoPlayback => 'Under videoafspilning';

  @override
  String get keepScreenOnViewerOnly => 'Kun fremvisningsside';

  @override
  String get keepScreenOnAlways => 'Altid';

  @override
  String get lengthUnitPixel => 'px';

  @override
  String get lengthUnitPercent => '%';

  @override
  String get mapStyleGoogleNormal => 'Google Maps';

  @override
  String get mapStyleGoogleHybrid => 'Google Maps (Hybrid)';

  @override
  String get mapStyleGoogleTerrain => 'Google Maps (Terræn)';

  @override
  String get mapStyleOsmLiberty => 'OSM Liberty';

  @override
  String get mapStyleOpenTopoMap => 'OpenTopoMap';

  @override
  String get mapStyleOsmHot => 'Humanitært OSM';

  @override
  String get mapStyleStamenWatercolor => 'Stamen Watercolor';

  @override
  String get maxBrightnessNever => 'Aldrig';

  @override
  String get maxBrightnessAlways => 'Altid';

  @override
  String get nameConflictStrategyRename => 'Omdøb';

  @override
  String get nameConflictStrategyReplace => 'Erstat';

  @override
  String get nameConflictStrategySkip => 'Spring over';

  @override
  String get overlayHistogramNone => 'Ingen';

  @override
  String get overlayHistogramRGB => 'RGB';

  @override
  String get overlayHistogramLuminance => 'Luminans';

  @override
  String get subtitlePositionTop => 'Øverst';

  @override
  String get subtitlePositionBottom => 'Nederst';

  @override
  String get themeBrightnessLight => 'Lys';

  @override
  String get themeBrightnessDark => 'Mørk';

  @override
  String get themeBrightnessBlack => 'Sort';

  @override
  String get unitSystemMetric => 'Metrisk';

  @override
  String get unitSystemImperial => 'Imperial';

  @override
  String get vaultLockTypePattern => 'Mønster';

  @override
  String get vaultLockTypePin => 'PIN';

  @override
  String get vaultLockTypePassword => 'Adgangskode';

  @override
  String get settingsVideoEnablePip => 'Billede-i-Billede';

  @override
  String get videoControlsPlayOutside => 'Åbn med en anden afspiller';

  @override
  String get videoLoopModeNever => 'Aldrig';

  @override
  String get videoLoopModeShortOnly => 'Kun korte videoer';

  @override
  String get videoLoopModeAlways => 'Altid';

  @override
  String get videoPlaybackSkip => 'Spring over';

  @override
  String get videoPlaybackMuted => 'Afspil uden lyd';

  @override
  String get videoPlaybackWithSound => 'Afspil med lyd';

  @override
  String get videoResumptionModeNever => 'Aldrig';

  @override
  String get videoResumptionModeAlways => 'Altid';

  @override
  String get viewerTransitionSlide => 'Glide';

  @override
  String get viewerTransitionParallax => 'Parallakse';

  @override
  String get viewerTransitionFade => 'Fade';

  @override
  String get viewerTransitionZoomIn => 'Zoom ind';

  @override
  String get viewerTransitionNone => 'Ingen';

  @override
  String get wallpaperTargetHome => 'Startskærm';

  @override
  String get wallpaperTargetLock => 'Låseskærm';

  @override
  String get wallpaperTargetHomeLock => 'Startskærm og låseskærm';

  @override
  String get widgetDisplayedItemRandom => 'Tilfældig';

  @override
  String get widgetDisplayedItemMostRecent => 'Nyeste';

  @override
  String get widgetOpenPageHome => 'Åbn hjem';

  @override
  String get widgetOpenPageCollection => 'Åbn samling';

  @override
  String get widgetOpenPageViewer => 'Åbn fremviser';

  @override
  String get widgetTapUpdateWidget => 'Opdater widget';

  @override
  String get storageVolumeDescriptionFallbackPrimary => 'Internt lager';

  @override
  String get storageVolumeDescriptionFallbackNonPrimary => 'SD-kort';

  @override
  String get rootDirectoryDescription => 'rodmappe';

  @override
  String otherDirectoryDescription(String name) {
    return '“$name”-mappe';
  }

  @override
  String storageAccessDialogMessage(String directory, String volume) {
    return 'Vælg $directory for “$volume” på den næste skærm for at give appen adgang til den.';
  }

  @override
  String restrictedAccessDialogMessage(String directory, String volume) {
    return 'Denne app har ikke tilladelse til at ændre filer i $directory for “$volume”.\n\nBrug venligst en forudinstalleret filhåndtering eller galleriapp til at flytte elementerne til en anden mappe.';
  }

  @override
  String notEnoughSpaceDialogMessage(String neededSize, String freeSize, String volume) {
    return 'Denne handling kræver $neededSize ledig plads på “$volume” for at blive fuldført, men der er kun $freeSize tilbage.';
  }

  @override
  String get missingSystemFilePickerDialogMessage => 'Systemfilvælgeren mangler eller er deaktiveret. Aktiver den, og prøv igen.';

  @override
  String unsupportedTypeDialogMessage(int count, String types) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Denne handling understøttes ikke for elementer af følgende typer: $types.',
      one: 'Denne handling understøttes ikke for elementer af følgende type: $types.',
    );
    return '$_temp0';
  }

  @override
  String get nameConflictDialogSingleSourceMessage => 'Nogle filer i destinationsmappen har samme navn.';

  @override
  String get nameConflictDialogMultipleSourceMessage => 'Nogle filer har samme navn.';

  @override
  String get addShortcutDialogLabel => 'Genvejsetiket';

  @override
  String get addShortcutButtonLabel => 'TILFØJ';

  @override
  String get noMatchingAppDialogMessage => 'Der er ingen apps, der kan håndtere dette.';

  @override
  String binEntriesConfirmationDialogMessage(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Flyt $countString elementer til papirkurven?',
      one: 'Flyt dette element til papirkurven?',
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
      other: 'Slet $countString elementer?',
      one: 'Slet dette element?',
    );
    return '$_temp0';
  }

  @override
  String get moveUndatedConfirmationDialogMessage => 'Gem elementdatoer, før du fortsætter?';

  @override
  String get moveUndatedConfirmationDialogSetDate => 'Gem datoer';

  @override
  String videoResumeDialogMessage(String time) {
    return 'Vil du genoptage afspilningen på $time?';
  }

  @override
  String get videoStartOverButtonLabel => 'START FORFRA';

  @override
  String get videoResumeButtonLabel => 'GENOPTAG';

  @override
  String get setCoverDialogLatest => 'Seneste element';

  @override
  String get setCoverDialogAuto => 'Auto';

  @override
  String get setCoverDialogCustom => 'Brugerdefineret';

  @override
  String get hideFilterConfirmationDialogMessage => 'Matchende fotos og videoer skjules fra din samling. Du kan vise dem igen i indstillingerne “Privatliv”.\n\nEr du sikker på, at du vil skjule dem?';

  @override
  String get newAlbumDialogTitle => 'Nyt album';

  @override
  String get newAlbumDialogNameLabel => 'Albumnavn';

  @override
  String get newAlbumDialogAlbumAlreadyExistsHelper => 'Album findes allerede';

  @override
  String get newAlbumDialogNameLabelAlreadyExistsHelper => 'Mappe findes allerede';

  @override
  String get newAlbumDialogStorageLabel => 'Lager:';

  @override
  String get newDynamicAlbumDialogTitle => 'Nyt dynamisk album';

  @override
  String get dynamicAlbumAlreadyExists => 'Dynamisk album findes allerede';

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
  String get newVaultWarningDialogMessage => 'Elementer i bokse er kun tilgængelige for denne app og ingen andre.\n\nHvis du afinstallerer appen eller rydder dens data, mister du alle disse elementer.';

  @override
  String get newVaultDialogTitle => 'Ny boks';

  @override
  String get configureVaultDialogTitle => 'Konfigurer boks';

  @override
  String get vaultDialogLockModeWhenScreenOff => 'Lås når skærmen slukkes';

  @override
  String get vaultDialogLockTypeLabel => 'Låsetype';

  @override
  String get patternDialogEnter => 'Indtast mønster';

  @override
  String get patternDialogConfirm => 'Bekræft mønster';

  @override
  String get pinDialogEnter => 'Indtast PIN';

  @override
  String get pinDialogConfirm => 'Bekræft PIN';

  @override
  String get passwordDialogEnter => 'Indtast adgangskode';

  @override
  String get passwordDialogConfirm => 'Bekræft adgangskode';

  @override
  String get authenticateToConfigureVault => 'Godkend for at konfigurere boks';

  @override
  String get authenticateToUnlockVault => 'Godkend for at oplåse boks';

  @override
  String get vaultBinUsageDialogMessage => 'Nogle bokse bruger papirkurven.';

  @override
  String get renameAlbumDialogLabel => 'Nyt navn';

  @override
  String get renameAlbumDialogLabelAlreadyExistsHelper => 'Mappe findes allerede';

  @override
  String get renameEntrySetPageTitle => 'Omdøb';

  @override
  String get renameEntrySetPagePatternFieldLabel => 'Navngivningsmønster';

  @override
  String get renameEntrySetPageInsertTooltip => 'Indsætningsfelt';

  @override
  String get renameEntrySetPagePreviewSectionTitle => 'Forhåndsvisning';

  @override
  String get renameProcessorCounter => 'Tæller';

  @override
  String get renameProcessorHash => 'Hash';

  @override
  String get renameProcessorName => 'Navn';

  @override
  String deleteSingleAlbumConfirmationDialogMessage(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Slet dette album og de $countString elementer i det?',
      one: 'Slet dette album og elementet i det?',
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
      other: 'Slet disse album og de $countString elementer i dem?',
      one: 'Slet disse album og elementet i dem?',
    );
    return '$_temp0';
  }

  @override
  String get exportEntryDialogFormat => 'Format:';

  @override
  String get exportEntryDialogWidth => 'Bredde';

  @override
  String get exportEntryDialogHeight => 'Højde';

  @override
  String get exportEntryDialogQuality => 'Kvalitet';

  @override
  String get exportEntryDialogWriteMetadata => 'Skriv metadata';

  @override
  String get renameEntryDialogLabel => 'Nyt navn';

  @override
  String get editEntryDialogCopyFromItem => 'Kopiér fra et andet element';

  @override
  String get editEntryDialogTargetFieldsHeader => 'Felter at ændre';

  @override
  String get editEntryDateDialogTitle => 'Dato og Tid';

  @override
  String get editEntryDateDialogSetCustom => 'Indstil brugerdefineret dato';

  @override
  String get editEntryDateDialogCopyField => 'Kopiér fra en anden dato';

  @override
  String get editEntryDateDialogExtractFromTitle => 'Udtræk fra titel';

  @override
  String get editEntryDateDialogShift => 'Skift';

  @override
  String get editEntryDateDialogSourceFileModifiedDate => 'Filens ændringsdato';

  @override
  String get durationDialogHours => 'Timer';

  @override
  String get durationDialogMinutes => 'Minutter';

  @override
  String get durationDialogSeconds => 'Sekunder';

  @override
  String get editEntryLocationDialogTitle => 'Placering';

  @override
  String get editEntryLocationDialogSetCustom => 'Indstil brugerdefineret placering';

  @override
  String get editEntryLocationDialogChooseOnMap => 'Vælg på kort';

  @override
  String get editEntryLocationDialogImportGpx => 'Importér GPX';

  @override
  String get editEntryLocationDialogLatitude => 'Breddegrad';

  @override
  String get editEntryLocationDialogLongitude => 'Længdegrad';

  @override
  String get editEntryLocationDialogTimeShift => 'Tidsskift';

  @override
  String get locationPickerUseThisLocationButton => 'Brug denne placering';

  @override
  String get editEntryRatingDialogTitle => 'Bedømmelse';

  @override
  String get removeEntryMetadataDialogTitle => 'Fjernelse af metadata';

  @override
  String get removeEntryMetadataDialogAll => 'Alle';

  @override
  String get removeEntryMetadataDialogMore => 'Mere';

  @override
  String get removeEntryMetadataMotionPhotoXmpWarningDialogMessage => 'XMP er påkrævet for at afspille videoen i et bevægelsesfoto.\n\nEr du sikker på, at du vil fjerne den?';

  @override
  String get videoSpeedDialogLabel => 'Afspilningshastighed';

  @override
  String get videoStreamSelectionDialogVideo => 'Video';

  @override
  String get videoStreamSelectionDialogAudio => 'Lyd';

  @override
  String get videoStreamSelectionDialogText => 'Undertekster';

  @override
  String get videoStreamSelectionDialogOff => 'Fra';

  @override
  String get videoStreamSelectionDialogTrack => 'Spor';

  @override
  String get videoStreamSelectionDialogNoSelection => 'Der er ingen andre spor.';

  @override
  String get genericSuccessFeedback => 'Færdig!';

  @override
  String get genericFailureFeedback => 'Mislykkedes';

  @override
  String get genericDangerWarningDialogMessage => 'Er du sikker?';

  @override
  String get tooManyItemsErrorDialogMessage => 'Prøv igen med færre elementer.';

  @override
  String get menuActionConfigureView => 'Visning';

  @override
  String get menuActionSelect => 'Vælg';

  @override
  String get menuActionSelectAll => 'Vælg alle';

  @override
  String get menuActionSelectNone => 'Vælg ingen';

  @override
  String get menuActionMap => 'Kort';

  @override
  String get menuActionSlideshow => 'Diasshow';

  @override
  String get menuActionStats => 'Statistikker';

  @override
  String get viewDialogSortSectionTitle => 'Sortér';

  @override
  String get viewDialogGroupSectionTitle => 'Gruppér';

  @override
  String get viewDialogLayoutSectionTitle => 'Layout';

  @override
  String get viewDialogReverseSortOrder => 'Omvendt sorteringsrækkefølge';

  @override
  String get tileLayoutMosaic => 'Mosaik';

  @override
  String get tileLayoutGrid => 'Gitter';

  @override
  String get tileLayoutList => 'Liste';

  @override
  String get castDialogTitle => 'Cast-enheder';

  @override
  String get coverDialogTabCover => 'Cover';

  @override
  String get coverDialogTabApp => 'App';

  @override
  String get coverDialogTabColor => 'Farve';

  @override
  String get appPickDialogTitle => 'Vælg app';

  @override
  String get appPickDialogNone => 'Ingen';

  @override
  String get aboutPageTitle => 'Om';

  @override
  String get aboutLinkLicense => 'Licens';

  @override
  String get aboutLinkPolicy => 'Privatlivspolitik';

  @override
  String get aboutBugSectionTitle => 'Fejlrapport';

  @override
  String get aboutBugSaveLogInstruction => 'Gem app-logs i en fil';

  @override
  String get aboutBugCopyInfoInstruction => 'Kopiér systemoplysninger';

  @override
  String get aboutBugCopyInfoButton => 'Kopiér';

  @override
  String get aboutBugReportInstruction => 'Rapportér på GitHub med logfiler og systemoplysninger';

  @override
  String get aboutBugReportButton => 'Rapportér';

  @override
  String get aboutDataUsageSectionTitle => 'Dataforbrug';

  @override
  String get aboutDataUsageData => 'Data';

  @override
  String get aboutDataUsageCache => 'Cache';

  @override
  String get aboutDataUsageDatabase => 'Database';

  @override
  String get aboutDataUsageMisc => 'Diverse';

  @override
  String get aboutDataUsageInternal => 'Internt';

  @override
  String get aboutDataUsageExternal => 'Eksternt';

  @override
  String get aboutDataUsageClearCache => 'Ryd cache';

  @override
  String get aboutCreditsSectionTitle => 'Kreditering';

  @override
  String get aboutCreditsWorldAtlas1 => 'Denne app bruger en TopoJSON-fil fra';

  @override
  String get aboutCreditsWorldAtlas2 => 'under ISC-licens.';

  @override
  String get aboutTranslatorsSectionTitle => 'Oversættere';

  @override
  String get aboutLicensesSectionTitle => 'Open source-licenser';

  @override
  String get aboutLicensesBanner => 'Denne app bruger følgende open source-pakker og -biblioteker.';

  @override
  String get aboutLicensesAndroidLibrariesSectionTitle => 'Android-biblioteker';

  @override
  String get aboutLicensesFlutterPluginsSectionTitle => 'Flutter-plugins';

  @override
  String get aboutLicensesFlutterPackagesSectionTitle => 'Flutter-pakker';

  @override
  String get aboutLicensesDartPackagesSectionTitle => 'Dart-pakker';

  @override
  String get aboutLicensesShowAllButtonLabel => 'Vis alle licenser';

  @override
  String get policyPageTitle => 'Privatlivspolitik';

  @override
  String get collectionPageTitle => 'Samling';

  @override
  String get collectionPickPageTitle => 'Vælg';

  @override
  String get collectionSelectPageTitle => 'Vælg elementer';

  @override
  String get collectionActionShowTitleSearch => 'Vis titelfilter';

  @override
  String get collectionActionHideTitleSearch => 'Skjul titelfilter';

  @override
  String get collectionActionAddDynamicAlbum => 'Tilføj dynamisk album';

  @override
  String get collectionActionAddShortcut => 'Tilføj genvej';

  @override
  String get collectionActionSetHome => 'Indstil som hjem';

  @override
  String get collectionActionEmptyBin => 'Tøm papirkurv';

  @override
  String get collectionActionCopy => 'Kopiér til album';

  @override
  String get collectionActionMove => 'Flyt til album';

  @override
  String get collectionActionRescan => 'Scan igen';

  @override
  String get collectionActionEdit => 'Rediger';

  @override
  String get collectionSearchTitlesHintText => 'Søg i titler';

  @override
  String get collectionGroupAlbum => 'Efter album';

  @override
  String get collectionGroupMonth => 'Efter måned';

  @override
  String get collectionGroupDay => 'Efter dag';

  @override
  String get sectionNone => 'No sections';

  @override
  String get sectionUnknown => 'Ukendt';

  @override
  String get dateToday => 'I dag';

  @override
  String get dateYesterday => 'I går';

  @override
  String get dateThisMonth => 'Denne måned';

  @override
  String collectionDeleteFailureFeedback(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kunne ikke slette $countString elementer',
      one: 'Kunne ikke slette 1 element',
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
      other: 'Kunne ikke kopiere $countString elementer',
      one: 'Kunne ikke kopiere 1 element',
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
      other: 'Kunne ikke flytte $countString elementer',
      one: 'Kunne ikke flytte 1 element',
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
      other: 'Kunne ikke omdøbe $countString elementer',
      one: 'Kunne ikke omdøbe 1 element',
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
      other: 'Kunne ikke redigere $countString elementer',
      one: 'Kunne ikke redigere 1 element',
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
      other: 'Kunne ikke eksportere $countString sider',
      one: 'Kunne ikke eksportere 1 side',
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
      other: 'Kopierede $countString elementer',
      one: 'Kopierede 1 element',
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
      other: 'Flyttede $countString elementer',
      one: 'Flyttede 1 element',
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
      other: 'Omdøbte $countString elementer',
      one: 'Omdøbte 1 element',
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
      other: 'Redigerede $countString elementer',
      one: 'Redigerede 1 element',
    );
    return '$_temp0';
  }

  @override
  String get collectionEmptyFavourites => 'Ingen favoritter';

  @override
  String get collectionEmptyVideos => 'Ingen videoer';

  @override
  String get collectionEmptyImages => 'Ingen billeder';

  @override
  String get collectionEmptyGrantAccessButtonLabel => 'Giv adgang';

  @override
  String get collectionSelectSectionTooltip => 'Vælg sektion';

  @override
  String get collectionDeselectSectionTooltip => 'Fravælg sektion';

  @override
  String get drawerAboutButton => 'Om';

  @override
  String get drawerSettingsButton => 'Indstillinger';

  @override
  String get drawerCollectionAll => 'Alle samlinger';

  @override
  String get drawerCollectionFavourites => 'Favoritter';

  @override
  String get drawerCollectionImages => 'Billeder';

  @override
  String get drawerCollectionVideos => 'Videoer';

  @override
  String get drawerCollectionAnimated => 'Animeret';

  @override
  String get drawerCollectionMotionPhotos => 'Bevægelsesfotos';

  @override
  String get drawerCollectionPanoramas => 'Panoramaer';

  @override
  String get drawerCollectionRaws => 'Rå billeder';

  @override
  String get drawerCollectionSphericalVideos => '360° videoer';

  @override
  String get drawerAlbumPage => 'Album';

  @override
  String get drawerCountryPage => 'Lande';

  @override
  String get drawerPlacePage => 'Steder';

  @override
  String get drawerTagPage => 'Tags';

  @override
  String get sortByDate => 'Efter dato';

  @override
  String get sortByName => 'Efter navn';

  @override
  String get sortByItemCount => 'Efter antal elementer';

  @override
  String get sortBySize => 'Efter størrelse';

  @override
  String get sortByAlbumFileName => 'Efter album og filnavn';

  @override
  String get sortByRating => 'Efter bedømmelse';

  @override
  String get sortByDuration => 'Efter varighed';

  @override
  String get sortByPath => 'Efter sti';

  @override
  String get sortOrderNewestFirst => 'Nyeste først';

  @override
  String get sortOrderOldestFirst => 'Ældste først';

  @override
  String get sortOrderAtoZ => 'A til Å';

  @override
  String get sortOrderZtoA => 'Å til A';

  @override
  String get sortOrderHighestFirst => 'Højeste først';

  @override
  String get sortOrderLowestFirst => 'Laveste først';

  @override
  String get sortOrderLargestFirst => 'Største først';

  @override
  String get sortOrderSmallestFirst => 'Mindste først';

  @override
  String get sortOrderShortestFirst => 'Korteste først';

  @override
  String get sortOrderLongestFirst => 'Længste først';

  @override
  String get albumGroupTier => 'Efter kategori';

  @override
  String get albumGroupType => 'Efter type';

  @override
  String get albumGroupVolume => 'Efter lagervolume';

  @override
  String get albumMimeTypeMixed => 'Blandet';

  @override
  String get albumPickPageTitleCopy => 'Kopiér til album';

  @override
  String get albumPickPageTitleExport => 'Eksportér til album';

  @override
  String get albumPickPageTitleMove => 'Flyt til album';

  @override
  String get albumPickPageTitlePick => 'Vælg album';

  @override
  String get albumCamera => 'Kamera';

  @override
  String get albumDownload => 'Download';

  @override
  String get albumScreenshots => 'Skærmbilleder';

  @override
  String get albumScreenRecordings => 'Skærmoptagelser';

  @override
  String get albumVideoCaptures => 'Videooptagelser';

  @override
  String get albumPageTitle => 'Album';

  @override
  String get albumEmpty => 'Ingen album';

  @override
  String get createAlbumButtonLabel => 'OPRET';

  @override
  String get newFilterBanner => 'ny';

  @override
  String get countryPageTitle => 'Lande';

  @override
  String get countryEmpty => 'Ingen lande';

  @override
  String get statePageTitle => 'Stater';

  @override
  String get stateEmpty => 'Ingen stater';

  @override
  String get placePageTitle => 'Steder';

  @override
  String get placeEmpty => 'Ingen steder';

  @override
  String get tagPageTitle => 'Tags';

  @override
  String get tagEmpty => 'Ingen tags';

  @override
  String get binPageTitle => 'Papirkurv';

  @override
  String get explorerPageTitle => 'Stifinder';

  @override
  String get explorerActionSelectStorageVolume => 'Vælg lager';

  @override
  String get selectStorageVolumeDialogTitle => 'Vælg lager';

  @override
  String get searchCollectionFieldHint => 'Søg i samling';

  @override
  String get searchRecentSectionTitle => 'Seneste';

  @override
  String get searchDateSectionTitle => 'Dato';

  @override
  String get searchFormatSectionTitle => 'Formater';

  @override
  String get searchAlbumsSectionTitle => 'Album';

  @override
  String get searchCountriesSectionTitle => 'Lande';

  @override
  String get searchStatesSectionTitle => 'Stater';

  @override
  String get searchPlacesSectionTitle => 'Steder';

  @override
  String get searchTagsSectionTitle => 'Tags';

  @override
  String get searchRatingSectionTitle => 'Bedømmelser';

  @override
  String get searchMetadataSectionTitle => 'Metadata';

  @override
  String get settingsPageTitle => 'Indstillinger';

  @override
  String get settingsSystemDefault => 'Systemstandard';

  @override
  String get settingsDefault => 'Standard';

  @override
  String get settingsDisabled => 'Deaktiveret';

  @override
  String get settingsAskEverytime => 'Spørg hver gang';

  @override
  String get settingsModificationWarningDialogMessage => 'Andre indstillinger bliver ændret.';

  @override
  String get settingsSearchFieldLabel => 'Søg i indstillinger';

  @override
  String get settingsSearchEmpty => 'Ingen matchende indstilling';

  @override
  String get settingsActionExport => 'Eksportér';

  @override
  String get settingsActionExportDialogTitle => 'Eksport';

  @override
  String get settingsActionImport => 'Importér';

  @override
  String get settingsActionImportDialogTitle => 'Import';

  @override
  String get appExportCovers => 'Covers';

  @override
  String get appExportDynamicAlbums => 'Dynamiske album';

  @override
  String get appExportFavourites => 'Favoritter';

  @override
  String get appExportSettings => 'Indstillinger';

  @override
  String get settingsNavigationSectionTitle => 'Navigation';

  @override
  String get settingsHomeTile => 'Hjem';

  @override
  String get settingsHomeDialogTitle => 'Hjem';

  @override
  String get setHomeCustom => 'Tilpasset';

  @override
  String get settingsShowBottomNavigationBar => 'Vis nederste navigationslinje';

  @override
  String get settingsKeepScreenOnTile => 'Hold skærmen tændt';

  @override
  String get settingsKeepScreenOnDialogTitle => 'Hold skærmen tændt';

  @override
  String get settingsDoubleBackExit => 'Tryk på “tilbage” to gange for at afslutte';

  @override
  String get settingsConfirmationTile => 'Bekræftelsesdialogbokse';

  @override
  String get settingsConfirmationDialogTitle => 'Bekræftelsesdialogbokse';

  @override
  String get settingsConfirmationBeforeDeleteItems => 'Spørg før elementer slettes permanent';

  @override
  String get settingsConfirmationBeforeMoveToBinItems => 'Spørg før elementer flyttes til papirkurven';

  @override
  String get settingsConfirmationBeforeMoveUndatedItems => 'Spørg før udaterede elementer flyttes';

  @override
  String get settingsConfirmationAfterMoveToBinItems => 'Vis besked efter elementer flyttes til papirkurven';

  @override
  String get settingsConfirmationVaultDataLoss => 'Vis advarsel om datatab i bokse';

  @override
  String get settingsNavigationDrawerTile => 'Navigationsmenu';

  @override
  String get settingsNavigationDrawerEditorPageTitle => 'Navigationsmenu';

  @override
  String get settingsNavigationDrawerBanner => 'Tryk og hold for at flytte og omarrangere menuelementer.';

  @override
  String get settingsNavigationDrawerTabTypes => 'Typer';

  @override
  String get settingsNavigationDrawerTabAlbums => 'Album';

  @override
  String get settingsNavigationDrawerTabPages => 'Sider';

  @override
  String get settingsNavigationDrawerAddAlbum => 'Tilføj album';

  @override
  String get settingsThumbnailSectionTitle => 'Miniaturebilleder';

  @override
  String get settingsThumbnailOverlayTile => 'Overlejring';

  @override
  String get settingsThumbnailOverlayPageTitle => 'Overlejring';

  @override
  String get settingsThumbnailShowHdrIcon => 'Vis HDR-ikon';

  @override
  String get settingsThumbnailShowFavouriteIcon => 'Vis favorit-ikon';

  @override
  String get settingsThumbnailShowTagIcon => 'Vis tag-ikon';

  @override
  String get settingsThumbnailShowLocationIcon => 'Vis placeringsikon';

  @override
  String get settingsThumbnailShowMotionPhotoIcon => 'Vis bevægelsesfoto-ikon';

  @override
  String get settingsThumbnailShowRating => 'Vis bedømmelse';

  @override
  String get settingsThumbnailShowRawIcon => 'Vis RAW-ikon';

  @override
  String get settingsThumbnailShowVideoDuration => 'Vis videovarighed';

  @override
  String get settingsCollectionQuickActionsTile => 'Hurtighandlinger';

  @override
  String get settingsCollectionQuickActionEditorPageTitle => 'Hurtighandlinger';

  @override
  String get settingsCollectionQuickActionTabBrowsing => 'Browsing';

  @override
  String get settingsCollectionQuickActionTabSelecting => 'Valg';

  @override
  String get settingsCollectionBrowsingQuickActionEditorBanner => 'Tryk og hold for at flytte knapper og vælge, hvilke handlinger der vises, når du gennemser elementer.';

  @override
  String get settingsCollectionSelectionQuickActionEditorBanner => 'Tryk og hold for at flytte knapper og vælge, hvilke handlinger der vises, når du vælger elementer.';

  @override
  String get settingsCollectionBurstPatternsTile => 'Filnavnmønstre';

  @override
  String get settingsCollectionBurstPatternsNone => 'Ingen';

  @override
  String get settingsViewerSectionTitle => 'Fremviser';

  @override
  String get settingsViewerGestureSideTapNext => 'Tryk på skærmkanterne for at vise forrige/næste element';

  @override
  String get settingsViewerUseCutout => 'Brug udskæringsområde';

  @override
  String get settingsViewerMaximumBrightness => 'Maksimal lysstyrke';

  @override
  String get settingsMotionPhotoAutoPlay => 'Afspil bevægelsesfotos automatisk';

  @override
  String get settingsImageBackground => 'Billedbaggrund';

  @override
  String get settingsViewerQuickActionsTile => 'Hurtighandlinger';

  @override
  String get settingsViewerQuickActionEditorPageTitle => 'Hurtighandlinger';

  @override
  String get settingsViewerQuickActionEditorBanner => 'Tryk og hold for at flytte knapper og vælge, hvilke handlinger der vises i fremviseren.';

  @override
  String get settingsViewerQuickActionEditorDisplayedButtonsSectionTitle => 'Viste knapper';

  @override
  String get settingsViewerQuickActionEditorAvailableButtonsSectionTitle => 'Tilgængelige knapper';

  @override
  String get settingsViewerQuickActionEmpty => 'Ingen knapper';

  @override
  String get settingsViewerOverlayTile => 'Overlejring';

  @override
  String get settingsViewerOverlayPageTitle => 'Overlejring';

  @override
  String get settingsViewerShowOverlayOnOpening => 'Vis ved åbning';

  @override
  String get settingsViewerShowHistogram => 'Vis histogram';

  @override
  String get settingsViewerShowMinimap => 'Vis minikort';

  @override
  String get settingsViewerShowInformation => 'Vis oplysninger';

  @override
  String get settingsViewerShowInformationSubtitle => 'Vis titel, dato, placering osv.';

  @override
  String get settingsViewerShowRatingTags => 'Vis bedømmelse og tags';

  @override
  String get settingsViewerShowShootingDetails => 'Vis fotograferingsdetaljer';

  @override
  String get settingsViewerShowDescription => 'Vis beskrivelse';

  @override
  String get settingsViewerShowOverlayThumbnails => 'Vis miniaturebilleder';

  @override
  String get settingsViewerEnableOverlayBlurEffect => 'Sløringseffekt';

  @override
  String get settingsViewerSlideshowTile => 'Diasshow';

  @override
  String get settingsViewerSlideshowPageTitle => 'Diasshow';

  @override
  String get settingsSlideshowRepeat => 'Gentag';

  @override
  String get settingsSlideshowShuffle => 'Bland';

  @override
  String get settingsSlideshowFillScreen => 'Udfyld skærm';

  @override
  String get settingsSlideshowAnimatedZoomEffect => 'Animeret zoomeffekt';

  @override
  String get settingsSlideshowTransitionTile => 'Overgang';

  @override
  String get settingsSlideshowIntervalTile => 'Interval';

  @override
  String get settingsSlideshowVideoPlaybackTile => 'Videoafspilning';

  @override
  String get settingsSlideshowVideoPlaybackDialogTitle => 'Videoafspilning';

  @override
  String get settingsVideoPageTitle => 'Videoindstillinger';

  @override
  String get settingsVideoSectionTitle => 'Video';

  @override
  String get settingsVideoShowVideos => 'Vis videoer';

  @override
  String get settingsVideoPlaybackTile => 'Afspilning';

  @override
  String get settingsVideoPlaybackPageTitle => 'Afspilning';

  @override
  String get settingsVideoEnableHardwareAcceleration => 'Hardwareacceleration';

  @override
  String get settingsVideoAutoPlay => 'Afspil automatisk';

  @override
  String get settingsVideoLoopModeTile => 'Loop-tilstand';

  @override
  String get settingsVideoLoopModeDialogTitle => 'Loop-tilstand';

  @override
  String get settingsVideoResumptionModeTile => 'Genoptag afspilning';

  @override
  String get settingsVideoResumptionModeDialogTitle => 'Genoptag afspilning';

  @override
  String get settingsVideoBackgroundMode => 'Baggrundstilstand';

  @override
  String get settingsVideoBackgroundModeDialogTitle => 'Baggrundstilstand';

  @override
  String get settingsVideoControlsTile => 'Styring';

  @override
  String get settingsVideoControlsPageTitle => 'Styring';

  @override
  String get settingsVideoButtonsTile => 'Knapper';

  @override
  String get settingsVideoGestureDoubleTapTogglePlay => 'Dobbelttryk for at afspille/pause';

  @override
  String get settingsVideoGestureSideDoubleTapSeek => 'Dobbelttryk på skærmkanterne for at gå frem/tilbage';

  @override
  String get settingsVideoGestureVerticalDragBrightnessVolume => 'Stryg op eller ned for at justere lysstyrke/lydstyrke';

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
  String get settingsSubtitleThemeTextPositionTile => 'Tekstposition';

  @override
  String get settingsSubtitleThemeTextPositionDialogTitle => 'Tekstposition';

  @override
  String get settingsSubtitleThemeTextSize => 'Tekststørrelse';

  @override
  String get settingsSubtitleThemeShowOutline => 'Vis omrids og skygge';

  @override
  String get settingsSubtitleThemeTextColor => 'Tekstfarve';

  @override
  String get settingsSubtitleThemeTextOpacity => 'Tekstopacitet';

  @override
  String get settingsSubtitleThemeBackgroundColor => 'Baggrundsfarve';

  @override
  String get settingsSubtitleThemeBackgroundOpacity => 'Baggrundsopacitet';

  @override
  String get settingsSubtitleThemeTextAlignmentLeft => 'Venstre';

  @override
  String get settingsSubtitleThemeTextAlignmentCenter => 'Midten';

  @override
  String get settingsSubtitleThemeTextAlignmentRight => 'Højre';

  @override
  String get settingsPrivacySectionTitle => 'Privatliv';

  @override
  String get settingsAllowInstalledAppAccess => 'Tillad adgang til app-lager';

  @override
  String get settingsAllowInstalledAppAccessSubtitle => 'Bruges til at forbedre albumvisning';

  @override
  String get settingsAllowErrorReporting => 'Tillad anonym fejlrapportering';

  @override
  String get settingsSaveSearchHistory => 'Gem søgehistorik';

  @override
  String get settingsEnableBin => 'Brug papirkurv';

  @override
  String get settingsEnableBinSubtitle => 'Opbevar slettede elementer i 30 dage';

  @override
  String get settingsDisablingBinWarningDialogMessage => 'Elementer i papirkurven slettes for altid.';

  @override
  String get settingsAllowMediaManagement => 'Tillad mediehåndtering';

  @override
  String get settingsHiddenItemsTile => 'Skjulte elementer';

  @override
  String get settingsHiddenItemsPageTitle => 'Skjulte Elementer';

  @override
  String get settingsHiddenFiltersBanner => 'Billeder og videoer, der matcher skjulte filtre, vises ikke i din samling.';

  @override
  String get settingsHiddenFiltersEmpty => 'Ingen skjulte filtre';

  @override
  String get settingsStorageAccessTile => 'Lageradgang';

  @override
  String get settingsStorageAccessPageTitle => 'Lageradgang';

  @override
  String get settingsStorageAccessBanner => 'Nogle mapper kræver en eksplicit adgangstilladelse for at ændre filer i dem. Her kan du se de mapper, som du tidligere har givet adgang til.';

  @override
  String get settingsStorageAccessEmpty => 'Ingen adgangstilladelser';

  @override
  String get settingsStorageAccessRevokeTooltip => 'Tilbagekald';

  @override
  String get settingsAccessibilitySectionTitle => 'Tilgængelighed';

  @override
  String get settingsRemoveAnimationsTile => 'Fjern animationer';

  @override
  String get settingsRemoveAnimationsDialogTitle => 'Fjern animationer';

  @override
  String get settingsTimeToTakeActionTile => 'Tid til at handle';

  @override
  String get settingsAccessibilityShowPinchGestureAlternatives => 'Vis alternativer til multi-touch-bevægelser';

  @override
  String get settingsDisplaySectionTitle => 'Visning';

  @override
  String get settingsThemeBrightnessTile => 'Tema';

  @override
  String get settingsThemeBrightnessDialogTitle => 'Tema';

  @override
  String get settingsThemeColorHighlights => 'Farvemarkeringer';

  @override
  String get settingsThemeEnableDynamicColor => 'Dynamisk farve';

  @override
  String get settingsDisplayRefreshRateModeTile => 'Skærmens opdateringshastighed';

  @override
  String get settingsDisplayRefreshRateModeDialogTitle => 'Opdateringshastighed';

  @override
  String get settingsDisplayUseTvInterface => 'Android TV-grænseflade';

  @override
  String get settingsLanguageSectionTitle => 'Sprog og Formater';

  @override
  String get settingsLanguageTile => 'Sprog';

  @override
  String get settingsLanguagePageTitle => 'Sprog';

  @override
  String get settingsCoordinateFormatTile => 'Koordinatformat';

  @override
  String get settingsCoordinateFormatDialogTitle => 'Koordinatformat';

  @override
  String get settingsUnitSystemTile => 'Enheder';

  @override
  String get settingsUnitSystemDialogTitle => 'Enheder';

  @override
  String get settingsForceWesternArabicNumeralsTile => 'Fremtving arabiske tal';

  @override
  String get settingsScreenSaverPageTitle => 'Pauseskærm';

  @override
  String get settingsWidgetPageTitle => 'Fotoramme';

  @override
  String get settingsWidgetShowOutline => 'Omrids';

  @override
  String get settingsWidgetOpenPage => 'Ved tryk på widgetten';

  @override
  String get settingsWidgetDisplayedItem => 'Vist element';

  @override
  String get settingsCollectionTile => 'Samling';

  @override
  String get statsPageTitle => 'Statistikker';

  @override
  String statsWithGps(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString elementer med placering',
      one: '1 element med placering',
    );
    return '$_temp0';
  }

  @override
  String get statsTopCountriesSectionTitle => 'Top lande';

  @override
  String get statsTopStatesSectionTitle => 'Top stater';

  @override
  String get statsTopPlacesSectionTitle => 'Top steder';

  @override
  String get statsTopTagsSectionTitle => 'Top tags';

  @override
  String get statsTopAlbumsSectionTitle => 'Top album';

  @override
  String get viewerOpenPanoramaButtonLabel => 'ÅBN PANORAMA';

  @override
  String get viewerSetWallpaperButtonLabel => 'INDSTIL BAGGRUND';

  @override
  String get viewerErrorUnknown => 'Ups!';

  @override
  String get viewerErrorDoesNotExist => 'Filen findes ikke længere.';

  @override
  String get viewerInfoPageTitle => 'Info';

  @override
  String get viewerInfoBackToViewerTooltip => 'Tilbage til fremviser';

  @override
  String get viewerInfoUnknown => 'ukendt';

  @override
  String get viewerInfoLabelDescription => 'Beskrivelse';

  @override
  String get viewerInfoLabelTitle => 'Titel';

  @override
  String get viewerInfoLabelDate => 'Dato';

  @override
  String get viewerInfoLabelResolution => 'Opløsning';

  @override
  String get viewerInfoLabelSize => 'Størrelse';

  @override
  String get viewerInfoLabelUri => 'URI';

  @override
  String get viewerInfoLabelPath => 'Sti';

  @override
  String get viewerInfoLabelDuration => 'Varighed';

  @override
  String get viewerInfoLabelOwner => 'Ejer';

  @override
  String get viewerInfoLabelCoordinates => 'Koordinater';

  @override
  String get viewerInfoLabelAddress => 'Adresse';

  @override
  String get mapStyleDialogTitle => 'Kortstil';

  @override
  String get mapStyleTooltip => 'Vælg kortstil';

  @override
  String get mapZoomInTooltip => 'Zoom ind';

  @override
  String get mapZoomOutTooltip => 'Zoom ud';

  @override
  String get mapPointNorthUpTooltip => 'Peg nord op';

  @override
  String get mapAttributionOsmData => 'Kortdata © [OpenStreetMap](https://www.openstreetmap.org/copyright) bidragsydere';

  @override
  String get mapAttributionOsmLiberty => 'Fliser af [OpenMapTiles](https://www.openmaptiles.org/), [CC BY](http://creativecommons.org/licenses/by/4.0) • Hostet af [OSM Americana](https://tile.ourmap.us)';

  @override
  String get mapAttributionOpenTopoMap => '[SRTM](https://www.earthdata.nasa.gov/sensors/srtm) | Fliser af [OpenTopoMap](https://opentopomap.org/), [CC BY-SA](https://creativecommons.org/licenses/by-sa/3.0/)';

  @override
  String get mapAttributionOsmHot => 'Fliser af [HOT](https://www.hotosm.org/) • Hostet af [OSM France](https://openstreetmap.fr/)';

  @override
  String get mapAttributionStamen => 'Fliser af [Stamen Design](https://stamen.com), [CC BY 3.0](https://creativecommons.org/licenses/by/3.0)';

  @override
  String get openMapPageTooltip => 'Se på kortside';

  @override
  String get mapEmptyRegion => 'Ingen billeder i denne region';

  @override
  String get viewerInfoOpenEmbeddedFailureFeedback => 'Kunne ikke udtrække indlejrede data';

  @override
  String get viewerInfoOpenLinkText => 'Åbn';

  @override
  String get viewerInfoViewXmlLinkText => 'Se XML';

  @override
  String get viewerInfoSearchFieldLabel => 'Søg i metadata';

  @override
  String get viewerInfoSearchEmpty => 'Ingen matchende nøgler';

  @override
  String get viewerInfoSearchSuggestionDate => 'Dato og tid';

  @override
  String get viewerInfoSearchSuggestionDescription => 'Beskrivelse';

  @override
  String get viewerInfoSearchSuggestionDimensions => 'Dimensioner';

  @override
  String get viewerInfoSearchSuggestionResolution => 'Opløsning';

  @override
  String get viewerInfoSearchSuggestionRights => 'Rettigheder';

  @override
  String get wallpaperUseScrollEffect => 'Brug rulleeffekt på startside';

  @override
  String get tagEditorPageTitle => 'Rediger Tags';

  @override
  String get tagEditorPageNewTagFieldLabel => 'Nyt tag';

  @override
  String get tagEditorPageAddTagTooltip => 'Tilføj tag';

  @override
  String get tagEditorSectionRecent => 'Seneste';

  @override
  String get tagEditorSectionPlaceholders => 'Pladsholdere';

  @override
  String get tagEditorDiscardDialogMessage => 'Vil du kassere ændringerne?';

  @override
  String get tagPlaceholderCountry => 'Land';

  @override
  String get tagPlaceholderState => 'Stat';

  @override
  String get tagPlaceholderPlace => 'Sted';

  @override
  String get panoramaEnableSensorControl => 'Aktivér sensorstyring';

  @override
  String get panoramaDisableSensorControl => 'Deaktiver sensorstyring';

  @override
  String get sourceViewerPageTitle => 'Kilde';
}
