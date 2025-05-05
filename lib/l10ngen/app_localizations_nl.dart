// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appName => 'Aves';

  @override
  String get welcomeMessage => 'Welkom bij Aves';

  @override
  String get welcomeOptional => 'Optioneel';

  @override
  String get welcomeTermsToggle => 'Ik ga akkoord met de voorwaarden';

  @override
  String itemCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString items',
      one: '$countString item',
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
      other: '$countString kolommen',
      one: '$countString kolom',
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
      other: '$countString seconden',
      one: '$countString seconde',
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
      other: '$countString minuten',
      one: '$countString minuut',
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
      other: '$countString dagen',
      one: '$countString dag',
    );
    return '$_temp0';
  }

  @override
  String focalLength(String length) {
    return '$length mm';
  }

  @override
  String get applyButtonLabel => 'TOEPASSEN';

  @override
  String get createButtonLabel => 'CREATE';

  @override
  String get deleteButtonLabel => 'VERWIJDEREN';

  @override
  String get nextButtonLabel => 'VOLGENDE';

  @override
  String get showButtonLabel => 'TONEN';

  @override
  String get hideButtonLabel => 'VERBERGEN';

  @override
  String get continueButtonLabel => 'VERDER';

  @override
  String get saveCopyButtonLabel => 'KOPIE OPSLAAN';

  @override
  String get applyTooltip => 'Toepassen';

  @override
  String get cancelTooltip => 'Annuleren';

  @override
  String get changeTooltip => 'Aanpassen';

  @override
  String get clearTooltip => 'Leegmaken';

  @override
  String get previousTooltip => 'Vorige';

  @override
  String get nextTooltip => 'Volgende';

  @override
  String get showTooltip => 'Tonen';

  @override
  String get hideTooltip => 'Verbergen';

  @override
  String get actionRemove => 'Verwijderen';

  @override
  String get resetTooltip => 'Resetten';

  @override
  String get saveTooltip => 'Opslaan';

  @override
  String get stopTooltip => 'Stop';

  @override
  String get pickTooltip => 'Kies';

  @override
  String get doubleBackExitMessage => 'Tik nogmaals “Terug” om te sluiten.';

  @override
  String get doNotAskAgain => 'Niet opnieuw vragen';

  @override
  String get sourceStateLoading => 'Laden';

  @override
  String get sourceStateCataloguing => 'Catalogiseren';

  @override
  String get sourceStateLocatingCountries => 'Landen lokaliseren';

  @override
  String get sourceStateLocatingPlaces => 'Plaatsen lokaliseren';

  @override
  String get chipActionDelete => 'Verwijderen';

  @override
  String get chipActionRemove => 'Verwijderen';

  @override
  String get chipActionShowCollection => 'In Collectie tonen';

  @override
  String get chipActionGoToAlbumPage => 'In Albums tonen';

  @override
  String get chipActionGoToCountryPage => 'In Landen tonen';

  @override
  String get chipActionGoToPlacePage => 'In Plaatsen tonen';

  @override
  String get chipActionGoToTagPage => 'In Labels tonen';

  @override
  String get chipActionGoToExplorerPage => 'In Bestanden tonen';

  @override
  String get chipActionDecompose => 'Splitsen';

  @override
  String get chipActionFilterOut => 'Uitfilteren';

  @override
  String get chipActionFilterIn => 'Infilteren';

  @override
  String get chipActionHide => 'Verbergen';

  @override
  String get chipActionLock => 'Vergrendel';

  @override
  String get chipActionPin => 'Bovenaan pinnen';

  @override
  String get chipActionUnpin => 'Unpinnen';

  @override
  String get chipActionGroup => 'Group';

  @override
  String get chipActionRename => 'Hernoemen';

  @override
  String get chipActionSetCover => 'Album achtergrond instellen';

  @override
  String get chipActionShowCountryStates => 'Staten tonen';

  @override
  String get chipActionCreateGroup => 'Create group';

  @override
  String get chipActionCreateAlbum => 'Album aanmaken';

  @override
  String get chipActionCreateVault => 'Kluis aanmaken';

  @override
  String get chipActionConfigureVault => 'Kluis configureren';

  @override
  String get entryActionCopyToClipboard => 'Kopiëren naar Clipboard';

  @override
  String get entryActionDelete => 'Verwijderen';

  @override
  String get entryActionConvert => 'Converteren';

  @override
  String get entryActionExport => 'Exporteren';

  @override
  String get entryActionInfo => 'Info';

  @override
  String get entryActionRename => 'Hernoemen';

  @override
  String get entryActionRestore => 'Herstellen';

  @override
  String get entryActionRotateCCW => 'Linksom roteren';

  @override
  String get entryActionRotateCW => 'Rechtsom roteren';

  @override
  String get entryActionFlip => 'Horizontaal omdraaien';

  @override
  String get entryActionPrint => 'Printen';

  @override
  String get entryActionShare => 'Delen';

  @override
  String get entryActionShareImageOnly => 'Enkel afbeelding delen';

  @override
  String get entryActionShareVideoOnly => 'Enkel video delen';

  @override
  String get entryActionViewSource => 'Bron bekijken';

  @override
  String get entryActionShowGeoTiffOnMap => 'Als kaart-overlay tonen';

  @override
  String get entryActionConvertMotionPhotoToStillImage => 'Converteren naar stilstaand beeld';

  @override
  String get entryActionViewMotionPhotoVideo => 'Video openen';

  @override
  String get entryActionEdit => 'Bewerken';

  @override
  String get entryActionOpen => 'Openen als';

  @override
  String get entryActionSetAs => 'Instellen als';

  @override
  String get entryActionCast => 'Casten';

  @override
  String get entryActionOpenMap => 'In Kaarten-app tonen';

  @override
  String get entryActionRotateScreen => 'Scherm roteren';

  @override
  String get entryActionAddFavourite => 'Toevoegen aan favorieten';

  @override
  String get entryActionRemoveFavourite => 'Verwijderen uit favorieten';

  @override
  String get videoActionCaptureFrame => 'Frame opnemen';

  @override
  String get videoActionMute => 'Dempen';

  @override
  String get videoActionUnmute => 'Dempen opheffen';

  @override
  String get videoActionPause => 'Pauzeren';

  @override
  String get videoActionPlay => 'Afspelen';

  @override
  String get videoActionReplay10 => '10 seconden terug';

  @override
  String get videoActionSkip10 => '10 seconden vooruit';

  @override
  String get videoActionShowPreviousFrame => 'Vorig frame weergeven';

  @override
  String get videoActionShowNextFrame => 'Volgend frame weergeven';

  @override
  String get videoActionSelectStreams => 'Sporen selecteren';

  @override
  String get videoActionSetSpeed => 'Afspeelsnelheid';

  @override
  String get videoActionABRepeat => 'A-B herhalen';

  @override
  String get videoRepeatActionSetStart => 'Start instellen';

  @override
  String get videoRepeatActionSetEnd => 'Einde instellen';

  @override
  String get viewerActionSettings => 'Instellingen';

  @override
  String get viewerActionLock => 'Weergave vergrendelen';

  @override
  String get viewerActionUnlock => 'Weergave ontgrendelen';

  @override
  String get slideshowActionResume => 'Hervatten';

  @override
  String get slideshowActionShowInCollection => 'In Collectie tonen';

  @override
  String get entryInfoActionEditDate => 'Datum & tijd bewerken';

  @override
  String get entryInfoActionEditLocation => 'Locatie bewerken';

  @override
  String get entryInfoActionEditTitleDescription => 'Titel & beschrijving bewerken';

  @override
  String get entryInfoActionEditRating => 'Waardering bewerken';

  @override
  String get entryInfoActionEditTags => 'Labels bewerken';

  @override
  String get entryInfoActionRemoveMetadata => 'Verwijder metadata';

  @override
  String get entryInfoActionExportMetadata => 'Metagegevens exporteren';

  @override
  String get entryInfoActionRemoveLocation => 'Verwijder locatie';

  @override
  String get editorActionTransform => 'Transformeren';

  @override
  String get editorTransformCrop => 'Bijsnijden';

  @override
  String get editorTransformRotate => 'Roteren';

  @override
  String get cropAspectRatioFree => 'Vrij';

  @override
  String get cropAspectRatioOriginal => 'Origineel';

  @override
  String get cropAspectRatioSquare => 'Vierkant';

  @override
  String get filterAspectRatioLandscapeLabel => 'Liggend';

  @override
  String get filterAspectRatioPortraitLabel => 'Staand';

  @override
  String get filterBinLabel => 'Prullenbak';

  @override
  String get filterFavouriteLabel => 'Favoriet';

  @override
  String get filterNoDateLabel => 'Zonder datum';

  @override
  String get filterNoAddressLabel => 'Zonder adres';

  @override
  String get filterLocatedLabel => 'Met Plaats';

  @override
  String get filterNoLocationLabel => 'Zonder plaats';

  @override
  String get filterNoRatingLabel => 'Zonder waardering';

  @override
  String get filterTaggedLabel => 'Met label';

  @override
  String get filterNoTagLabel => 'Zonder label';

  @override
  String get filterNoTitleLabel => 'Zonder titel';

  @override
  String get filterOnThisDayLabel => 'Op deze dag';

  @override
  String get filterRecentlyAddedLabel => 'Recent toegevoegd';

  @override
  String get filterRatingRejectedLabel => 'Afgekeurd';

  @override
  String get filterTypeAnimatedLabel => 'Geanimeerd';

  @override
  String get filterTypeMotionPhotoLabel => 'Bewegende Foto';

  @override
  String get filterTypePanoramaLabel => 'Panorama';

  @override
  String get filterTypeRawLabel => 'Raw';

  @override
  String get filterTypeSphericalVideoLabel => '360° Video';

  @override
  String get filterTypeGeotiffLabel => 'GeoTIFF';

  @override
  String get filterMimeImageLabel => 'Afbeelding';

  @override
  String get filterMimeVideoLabel => 'Video';

  @override
  String get accessibilityAnimationsRemove => 'Schermeffecten uitschakelen';

  @override
  String get accessibilityAnimationsKeep => 'Schermeffecten behouden';

  @override
  String get albumTierNew => 'Nieuw';

  @override
  String get albumTierPinned => 'Gepint';

  @override
  String get albumTierGroups => 'Groups';

  @override
  String get albumTierSpecial => 'Veelgebruikt';

  @override
  String get albumTierApps => 'Apps';

  @override
  String get albumTierVaults => 'Kluizen';

  @override
  String get albumTierDynamic => 'Dynamisch';

  @override
  String get albumTierRegular => 'Overige';

  @override
  String get coordinateFormatDms => 'DMS';

  @override
  String get coordinateFormatDdm => 'DDM';

  @override
  String get coordinateFormatDecimal => 'Decimale graden';

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
  String get displayRefreshRatePreferHighest => 'Hoogste waardering';

  @override
  String get displayRefreshRatePreferLowest => 'Laagste waardering';

  @override
  String get keepScreenOnNever => 'Nooit';

  @override
  String get keepScreenOnVideoPlayback => 'Tijdens het afspelen van video';

  @override
  String get keepScreenOnViewerOnly => 'Alleen Viewerpagina';

  @override
  String get keepScreenOnAlways => 'Altijd';

  @override
  String get lengthUnitPixel => 'px';

  @override
  String get lengthUnitPercent => '%';

  @override
  String get mapStyleGoogleNormal => 'Google Maps';

  @override
  String get mapStyleGoogleHybrid => 'Google Maps (Hybride)';

  @override
  String get mapStyleGoogleTerrain => 'Google Maps (Terrein)';

  @override
  String get mapStyleOsmLiberty => 'OSM Liberty';

  @override
  String get mapStyleOpenTopoMap => 'OpenTopoMap';

  @override
  String get mapStyleOsmHot => 'Humanitarian OSM';

  @override
  String get mapStyleStamenWatercolor => 'Stamen Waterkleur';

  @override
  String get maxBrightnessNever => 'Nooit';

  @override
  String get maxBrightnessAlways => 'Altijd';

  @override
  String get nameConflictStrategyRename => 'Hernoemen';

  @override
  String get nameConflictStrategyReplace => 'Vervangen';

  @override
  String get nameConflictStrategySkip => 'Overslaan';

  @override
  String get overlayHistogramNone => 'Geen';

  @override
  String get overlayHistogramRGB => 'RGB';

  @override
  String get overlayHistogramLuminance => 'Helderheid';

  @override
  String get subtitlePositionTop => 'Boven';

  @override
  String get subtitlePositionBottom => 'Onder';

  @override
  String get themeBrightnessLight => 'Licht';

  @override
  String get themeBrightnessDark => 'Donker';

  @override
  String get themeBrightnessBlack => 'Zwart';

  @override
  String get unitSystemMetric => 'Metrisch';

  @override
  String get unitSystemImperial => 'Brits-Amerikaans';

  @override
  String get vaultLockTypePattern => 'Patroon';

  @override
  String get vaultLockTypePin => 'PIN';

  @override
  String get vaultLockTypePassword => 'Wachtwoord';

  @override
  String get settingsVideoEnablePip => 'Beeld-in-beeld';

  @override
  String get videoControlsPlayOutside => 'Met andere speler openen';

  @override
  String get videoLoopModeNever => 'Nooit';

  @override
  String get videoLoopModeShortOnly => 'Alleen korte video\'s';

  @override
  String get videoLoopModeAlways => 'Altijd';

  @override
  String get videoPlaybackSkip => 'Overslaan';

  @override
  String get videoPlaybackMuted => 'Gedempt afspelen';

  @override
  String get videoPlaybackWithSound => 'Met geluid afspelen';

  @override
  String get videoResumptionModeNever => 'Nooit';

  @override
  String get videoResumptionModeAlways => 'Altijd';

  @override
  String get viewerTransitionSlide => 'Slide';

  @override
  String get viewerTransitionParallax => 'Parallax';

  @override
  String get viewerTransitionFade => 'Vervagen';

  @override
  String get viewerTransitionZoomIn => 'Inzoomen';

  @override
  String get viewerTransitionNone => 'Geen';

  @override
  String get wallpaperTargetHome => 'Startscherm';

  @override
  String get wallpaperTargetLock => 'Vergrendelingsscherm';

  @override
  String get wallpaperTargetHomeLock => 'Start- en vergrendelingsschermen';

  @override
  String get widgetDisplayedItemRandom => 'Willekeurig';

  @override
  String get widgetDisplayedItemMostRecent => 'Laatst gebruikt';

  @override
  String get widgetOpenPageHome => 'Startscherm openen';

  @override
  String get widgetOpenPageCollection => 'Verzameling openen';

  @override
  String get widgetOpenPageViewer => 'Voorbeeld openen';

  @override
  String get widgetTapUpdateWidget => 'Widget bijwerken';

  @override
  String get storageVolumeDescriptionFallbackPrimary => 'Internale opslag';

  @override
  String get storageVolumeDescriptionFallbackNonPrimary => 'SD kaart';

  @override
  String get rootDirectoryDescription => 'root map';

  @override
  String otherDirectoryDescription(String name) {
    return '“$name” map';
  }

  @override
  String storageAccessDialogMessage(String directory, String volume) {
    return 'Selecteer in het volgende scherm de $directory van “$volume” om deze app er toegang toe te geven.';
  }

  @override
  String restrictedAccessDialogMessage(String directory, String volume) {
    return 'Deze applicatie mag geen bestanden wijzigen in de $directory van “$volume”,.\n\n Gebruik een vooraf geïnstalleerde filemanager of galerij-app om de items naar een andere map te verplaatsen.';
  }

  @override
  String notEnoughSpaceDialogMessage(String neededSize, String freeSize, String volume) {
    return 'Deze bewerking heeft $neededSize vrije ruimte op “$volume”, nodig om te voltooien, maar er is nog slechts $freeSize over.';
  }

  @override
  String get missingSystemFilePickerDialogMessage => 'De systeembestandskiezer ontbreekt of is uitgeschakeld. Schakel het in en probeer het opnieuw.';

  @override
  String unsupportedTypeDialogMessage(int count, String types) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Deze bewerking wordt niet ondersteund voor items van het volgende bestandstype: $types.',
    );
    return '$_temp0';
  }

  @override
  String get nameConflictDialogSingleSourceMessage => 'Sommige bestanden in de doelmap hebben dezelfde naam.';

  @override
  String get nameConflictDialogMultipleSourceMessage => 'Sommige bestanden hebben dezelfde naam.';

  @override
  String get addShortcutDialogLabel => 'Label snelkoppeling';

  @override
  String get addShortcutButtonLabel => 'TOEVOEGEN';

  @override
  String get noMatchingAppDialogMessage => 'Er zijn geen apps die dit ondersteunen.';

  @override
  String binEntriesConfirmationDialogMessage(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Deze $countString items naar de prullenbak verplaatsen?',
      one: 'Dit item naar de prullenbak verplaatsen??',
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
      other: 'Deze $countString items verwijderen?',
      one: 'Dit item verwijderen?',
    );
    return '$_temp0';
  }

  @override
  String get moveUndatedConfirmationDialogMessage => 'Datums opslaan alvorens door te gaan?';

  @override
  String get moveUndatedConfirmationDialogSetDate => 'Datums opslaan';

  @override
  String videoResumeDialogMessage(String time) {
    return 'Afspelen hervatten om $time?';
  }

  @override
  String get videoStartOverButtonLabel => 'OPNIEUW AFSPELLEN';

  @override
  String get videoResumeButtonLabel => 'HERVATTEN';

  @override
  String get setCoverDialogLatest => 'Laatste item';

  @override
  String get setCoverDialogAuto => 'Auto';

  @override
  String get setCoverDialogCustom => 'Aangepast';

  @override
  String get hideFilterConfirmationDialogMessage => 'Overeenkomstige foto’s en video’s worden verborgen binnen jouw verzameling. Je kunt ze opnieuw weergeven via de “Privacy”-instellingen.\n\nWeet je zeker dat je ze wilt verbergen?';

  @override
  String get newAlbumDialogTitle => 'Nieuw Album';

  @override
  String get newAlbumDialogNameLabel => 'Albumnaam';

  @override
  String get newAlbumDialogAlbumAlreadyExistsHelper => 'Album bestaat al';

  @override
  String get newAlbumDialogNameLabelAlreadyExistsHelper => 'Map bestaat al';

  @override
  String get newAlbumDialogStorageLabel => 'Opslag:';

  @override
  String get newDynamicAlbumDialogTitle => 'Nieuw dynamisch album';

  @override
  String get dynamicAlbumAlreadyExists => 'Dynamisch album bestaat al';

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
  String get newVaultWarningDialogMessage => 'Items in kluizen zijn alleen beschikbaar voor deze app en niet voor andere.\n\nAls je deze app verwijdert of deze app-gegevens wist, verlies je al deze items.';

  @override
  String get newVaultDialogTitle => 'Nieuwe kluis';

  @override
  String get configureVaultDialogTitle => 'Kluis configureren';

  @override
  String get vaultDialogLockModeWhenScreenOff => 'Vergrendelen wanneer het scherm wordt uitgeschakeld';

  @override
  String get vaultDialogLockTypeLabel => 'Vergrendelingstype';

  @override
  String get patternDialogEnter => 'Voer patroon in';

  @override
  String get patternDialogConfirm => 'Patroon bevestigen';

  @override
  String get pinDialogEnter => 'Voer PIN in';

  @override
  String get pinDialogConfirm => 'PIN bevestigen';

  @override
  String get passwordDialogEnter => 'Voer wachtwoord in';

  @override
  String get passwordDialogConfirm => 'Wachtwoord bevestigen';

  @override
  String get authenticateToConfigureVault => 'Verifieer om de kluis te configureren';

  @override
  String get authenticateToUnlockVault => 'Verifieer om de kluis te ontgrendelen';

  @override
  String get vaultBinUsageDialogMessage => 'Sommige kluizen gebruiken de prullenbak.';

  @override
  String get renameAlbumDialogLabel => 'Nieuwe naam';

  @override
  String get renameAlbumDialogLabelAlreadyExistsHelper => 'Map bestaat al';

  @override
  String get renameEntrySetPageTitle => 'Hernoemen';

  @override
  String get renameEntrySetPagePatternFieldLabel => 'Naamgevingspatroon';

  @override
  String get renameEntrySetPageInsertTooltip => 'Veld invoegen';

  @override
  String get renameEntrySetPagePreviewSectionTitle => 'Voorbeeld';

  @override
  String get renameProcessorCounter => 'Teller';

  @override
  String get renameProcessorHash => 'Controlenummer';

  @override
  String get renameProcessorName => 'Naam';

  @override
  String deleteSingleAlbumConfirmationDialogMessage(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dit album en de $countString items erbinnen verwijderen?',
      one: 'Dit album en het item erbinnen verwijderen?',
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
      other: 'Deze albums en de $countString items erbinnen verwijderen?',
      one: 'Deze albums en de items erbinnen verwijderen?',
    );
    return '$_temp0';
  }

  @override
  String get exportEntryDialogFormat => 'Type:';

  @override
  String get exportEntryDialogWidth => 'Breedte';

  @override
  String get exportEntryDialogHeight => 'Hoogte';

  @override
  String get exportEntryDialogQuality => 'Kwaliteit';

  @override
  String get exportEntryDialogWriteMetadata => 'Metadata schrijven';

  @override
  String get renameEntryDialogLabel => 'Nieuwe naam';

  @override
  String get editEntryDialogCopyFromItem => 'Van ander item kopiëren';

  @override
  String get editEntryDialogTargetFieldsHeader => 'Velden om aan te passen';

  @override
  String get editEntryDateDialogTitle => 'Datum & Tijd';

  @override
  String get editEntryDateDialogSetCustom => 'Aangepaste datum instellen';

  @override
  String get editEntryDateDialogCopyField => 'Van andere datum kopiëren';

  @override
  String get editEntryDateDialogExtractFromTitle => 'Uit titel halen';

  @override
  String get editEntryDateDialogShift => 'Verschuiven';

  @override
  String get editEntryDateDialogSourceFileModifiedDate => 'Wijzigingsdatum bestand';

  @override
  String get durationDialogHours => 'Uren';

  @override
  String get durationDialogMinutes => 'Minuten';

  @override
  String get durationDialogSeconds => 'Seconden';

  @override
  String get editEntryLocationDialogTitle => 'Locatie';

  @override
  String get editEntryLocationDialogSetCustom => 'Aangepaste locatie instellen';

  @override
  String get editEntryLocationDialogChooseOnMap => 'Op kaart kiezen';

  @override
  String get editEntryLocationDialogImportGpx => 'GPX importeren';

  @override
  String get editEntryLocationDialogLatitude => 'Breedtegraad';

  @override
  String get editEntryLocationDialogLongitude => 'Lengtegraad';

  @override
  String get editEntryLocationDialogTimeShift => 'Verschuiving van de tijd';

  @override
  String get locationPickerUseThisLocationButton => 'Gebruik deze locatie';

  @override
  String get editEntryRatingDialogTitle => 'Waardering';

  @override
  String get removeEntryMetadataDialogTitle => 'Verwijderen metadata';

  @override
  String get removeEntryMetadataDialogAll => 'Alle';

  @override
  String get removeEntryMetadataDialogMore => 'Meer';

  @override
  String get removeEntryMetadataMotionPhotoXmpWarningDialogMessage => 'XMP is vereist om de video in een bewegende foto af te spelen.\n\nWeet je zeker dat je deze wilt verwijderen?';

  @override
  String get videoSpeedDialogLabel => 'Afspeelsnelheid';

  @override
  String get videoStreamSelectionDialogVideo => 'Video';

  @override
  String get videoStreamSelectionDialogAudio => 'Audio';

  @override
  String get videoStreamSelectionDialogText => 'Ondertiteling';

  @override
  String get videoStreamSelectionDialogOff => 'Uit';

  @override
  String get videoStreamSelectionDialogTrack => 'Spoor';

  @override
  String get videoStreamSelectionDialogNoSelection => 'Er zijn geen andere sporen.';

  @override
  String get genericSuccessFeedback => 'Klaar!';

  @override
  String get genericFailureFeedback => 'Fout';

  @override
  String get genericDangerWarningDialogMessage => 'Weet je het zeker?';

  @override
  String get tooManyItemsErrorDialogMessage => 'Probeer opnieuw met minder items.';

  @override
  String get menuActionConfigureView => 'Beeld';

  @override
  String get menuActionSelect => 'Selecteren';

  @override
  String get menuActionSelectAll => 'Alles selecteren';

  @override
  String get menuActionSelectNone => 'Selectie ongedaan maken';

  @override
  String get menuActionMap => 'Kaart';

  @override
  String get menuActionSlideshow => 'Diavoorstelling';

  @override
  String get menuActionStats => 'Statistieken';

  @override
  String get viewDialogSortSectionTitle => 'Sorteer';

  @override
  String get viewDialogGroupSectionTitle => 'Groeperen';

  @override
  String get viewDialogLayoutSectionTitle => 'Layout';

  @override
  String get viewDialogReverseSortOrder => 'Sortering omkeren';

  @override
  String get tileLayoutMosaic => 'Mozaïek';

  @override
  String get tileLayoutGrid => 'Raster';

  @override
  String get tileLayoutList => 'Lijst';

  @override
  String get castDialogTitle => 'Cast-apparaten';

  @override
  String get coverDialogTabCover => 'Kaft';

  @override
  String get coverDialogTabApp => 'Applicatie';

  @override
  String get coverDialogTabColor => 'Kleur';

  @override
  String get appPickDialogTitle => 'Kies applicatie';

  @override
  String get appPickDialogNone => 'Geen';

  @override
  String get aboutPageTitle => 'Over';

  @override
  String get aboutLinkLicense => 'Licentie';

  @override
  String get aboutLinkPolicy => 'Privacybeleid';

  @override
  String get aboutBugSectionTitle => 'Foutmelding';

  @override
  String get aboutBugSaveLogInstruction => 'Sla applicatielogs op in een bestand';

  @override
  String get aboutBugCopyInfoInstruction => 'Systeeminformatie kopiëren';

  @override
  String get aboutBugCopyInfoButton => 'Kopieer';

  @override
  String get aboutBugReportInstruction => 'Melden op GitHub met de logs en systeeminformatie';

  @override
  String get aboutBugReportButton => 'Melden';

  @override
  String get aboutDataUsageSectionTitle => 'Gegevensgebruik';

  @override
  String get aboutDataUsageData => 'Data';

  @override
  String get aboutDataUsageCache => 'Cache';

  @override
  String get aboutDataUsageDatabase => 'Database';

  @override
  String get aboutDataUsageMisc => 'Overig';

  @override
  String get aboutDataUsageInternal => 'Intern';

  @override
  String get aboutDataUsageExternal => 'Extern';

  @override
  String get aboutDataUsageClearCache => 'Cache wissen';

  @override
  String get aboutCreditsSectionTitle => 'Dankbetuiging';

  @override
  String get aboutCreditsWorldAtlas1 => 'Deze applicatie gebruikt een TopoJSON-bestand van';

  @override
  String get aboutCreditsWorldAtlas2 => 'onder ISC-licentie.';

  @override
  String get aboutTranslatorsSectionTitle => 'Vertalers';

  @override
  String get aboutLicensesSectionTitle => 'Open-Source Licenties';

  @override
  String get aboutLicensesBanner => 'Deze app maakt gebruik van de volgende open-sourcepakketten en bibliotheken.';

  @override
  String get aboutLicensesAndroidLibrariesSectionTitle => 'Android bibliotheken';

  @override
  String get aboutLicensesFlutterPluginsSectionTitle => 'Flutter Plugins';

  @override
  String get aboutLicensesFlutterPackagesSectionTitle => 'Flutter Packages';

  @override
  String get aboutLicensesDartPackagesSectionTitle => 'Dart Packages';

  @override
  String get aboutLicensesShowAllButtonLabel => 'Alle licenties tonen';

  @override
  String get policyPageTitle => 'Privacybeleid';

  @override
  String get collectionPageTitle => 'Verzameling';

  @override
  String get collectionPickPageTitle => 'Kies';

  @override
  String get collectionSelectPageTitle => 'Items selecteren';

  @override
  String get collectionActionShowTitleSearch => 'Titelfilter weergeven';

  @override
  String get collectionActionHideTitleSearch => 'Verberg titel filter';

  @override
  String get collectionActionAddDynamicAlbum => 'Dynamisch album toevoegen';

  @override
  String get collectionActionAddShortcut => 'Snelkoppeling aanmaken';

  @override
  String get collectionActionSetHome => 'Als startpagina instellen';

  @override
  String get collectionActionEmptyBin => 'Prullenbak leegmaken';

  @override
  String get collectionActionCopy => 'Kopieer naar Album';

  @override
  String get collectionActionMove => 'Verplaats naar Album';

  @override
  String get collectionActionRescan => 'Opnieuw indexeren';

  @override
  String get collectionActionEdit => 'Bewerken';

  @override
  String get collectionSearchTitlesHintText => 'Zoek op titel';

  @override
  String get collectionGroupAlbum => 'Op Albumnaam';

  @override
  String get collectionGroupMonth => 'Op maand';

  @override
  String get collectionGroupDay => 'Op dag';

  @override
  String get sectionNone => 'No sections';

  @override
  String get sectionUnknown => 'Onbekend';

  @override
  String get dateToday => 'Vandaag';

  @override
  String get dateYesterday => 'Gisteren';

  @override
  String get dateThisMonth => 'Deze maand';

  @override
  String collectionDeleteFailureFeedback(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kan $countString items niet verwijderen',
      one: 'Kan 1 item niet verwijderen',
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
      other: 'Kan $countString items niet kopiëren',
      one: 'Kan 1 item niet kopiëren',
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
      other: 'Kan $countString items niet verplaatsen',
      one: 'Kan 1 item niet verplaatsen',
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
      other: 'Kan $countString items niet hernoemen',
      one: 'Kan 1 item niet hernoemen',
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
      other: 'Kan $countString items niet bewerken',
      one: 'Kan 1 item niet bewerken',
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
      other: 'Kan $countString pagina’s niet exporteren',
      one: 'Kan 1 pagina niet exporteren',
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
      other: '$countString items gekopieerd',
      one: '1 item gekopieerd',
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
      other: '$countString items verplaatst',
      one: '1 item verplaatst',
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
      other: '$countString items hernoemd',
      one: '1 item hernoemd',
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
      other: '$countString items bewerkt',
      one: '1 item bewerkt',
    );
    return '$_temp0';
  }

  @override
  String get collectionEmptyFavourites => 'Geen favourieten';

  @override
  String get collectionEmptyVideos => 'Geen video’s';

  @override
  String get collectionEmptyImages => 'Geen afbeeldingen';

  @override
  String get collectionEmptyGrantAccessButtonLabel => 'Toegang verlenen';

  @override
  String get collectionSelectSectionTooltip => 'Sectie selecteren';

  @override
  String get collectionDeselectSectionTooltip => 'Sectie niet selecteren';

  @override
  String get drawerAboutButton => 'Over';

  @override
  String get drawerSettingsButton => 'Instellingen';

  @override
  String get drawerCollectionAll => 'Alle verzamelingen';

  @override
  String get drawerCollectionFavourites => 'Favourieten';

  @override
  String get drawerCollectionImages => 'Afbeeldingen';

  @override
  String get drawerCollectionVideos => 'Video’s';

  @override
  String get drawerCollectionAnimated => 'Animaties';

  @override
  String get drawerCollectionMotionPhotos => 'Bewegende foto’s';

  @override
  String get drawerCollectionPanoramas => 'Panorama\'s';

  @override
  String get drawerCollectionRaws => 'Raw foto’s';

  @override
  String get drawerCollectionSphericalVideos => '360° video’s';

  @override
  String get drawerAlbumPage => 'Albums';

  @override
  String get drawerCountryPage => 'Landen';

  @override
  String get drawerPlacePage => 'Plaatsen';

  @override
  String get drawerTagPage => 'Labels';

  @override
  String get sortByDate => 'Op datum';

  @override
  String get sortByName => 'Op naam';

  @override
  String get sortByItemCount => 'Op aantal items';

  @override
  String get sortBySize => 'Op grootte';

  @override
  String get sortByAlbumFileName => 'Op album- en bestandsnaam';

  @override
  String get sortByRating => 'Op waardering';

  @override
  String get sortByDuration => 'Op lengte';

  @override
  String get sortByPath => 'Op pad';

  @override
  String get sortOrderNewestFirst => 'Nieuwste eerst';

  @override
  String get sortOrderOldestFirst => 'Oudste eerst';

  @override
  String get sortOrderAtoZ => 'A - Z';

  @override
  String get sortOrderZtoA => 'Z - A';

  @override
  String get sortOrderHighestFirst => 'Hoogste eerst';

  @override
  String get sortOrderLowestFirst => 'Laagste eerst';

  @override
  String get sortOrderLargestFirst => 'Grootste eerst';

  @override
  String get sortOrderSmallestFirst => 'Kleinste eerst';

  @override
  String get sortOrderShortestFirst => 'Kortste eerst';

  @override
  String get sortOrderLongestFirst => 'Langste eerst';

  @override
  String get albumGroupTier => 'Op rang';

  @override
  String get albumGroupType => 'Op type';

  @override
  String get albumGroupVolume => 'Op opslagvolume';

  @override
  String get albumMimeTypeMixed => 'Gemengd';

  @override
  String get albumPickPageTitleCopy => 'Kopieer naar Album';

  @override
  String get albumPickPageTitleExport => 'Exporteren naar Album';

  @override
  String get albumPickPageTitleMove => 'Verplaats naar Album';

  @override
  String get albumPickPageTitlePick => 'Kies Album';

  @override
  String get albumCamera => 'Camera';

  @override
  String get albumDownload => 'Opslaan';

  @override
  String get albumScreenshots => 'Schermopnames';

  @override
  String get albumScreenRecordings => 'Schermopnames';

  @override
  String get albumVideoCaptures => 'Video opnames';

  @override
  String get albumPageTitle => 'Albums';

  @override
  String get albumEmpty => 'Geen albums';

  @override
  String get createAlbumButtonLabel => 'AANMAKEN';

  @override
  String get newFilterBanner => 'nieuw';

  @override
  String get countryPageTitle => 'Landen';

  @override
  String get countryEmpty => 'Geen landen';

  @override
  String get statePageTitle => 'Staten';

  @override
  String get stateEmpty => 'Zonder Staten';

  @override
  String get placePageTitle => 'Plaatsen';

  @override
  String get placeEmpty => 'Zonder plaatsen';

  @override
  String get tagPageTitle => 'Labels';

  @override
  String get tagEmpty => 'Geen labels';

  @override
  String get binPageTitle => 'Prullenbak';

  @override
  String get explorerPageTitle => 'Bestanden';

  @override
  String get explorerActionSelectStorageVolume => 'Opslag selecteren';

  @override
  String get selectStorageVolumeDialogTitle => 'Opslag selecteren';

  @override
  String get searchCollectionFieldHint => 'Doorzoek collectie';

  @override
  String get searchRecentSectionTitle => 'Recent';

  @override
  String get searchDateSectionTitle => 'Datum';

  @override
  String get searchFormatSectionTitle => 'Formaten';

  @override
  String get searchAlbumsSectionTitle => 'Albums';

  @override
  String get searchCountriesSectionTitle => 'Landen';

  @override
  String get searchStatesSectionTitle => 'Staten';

  @override
  String get searchPlacesSectionTitle => 'Plaatsen';

  @override
  String get searchTagsSectionTitle => 'Labels';

  @override
  String get searchRatingSectionTitle => 'Waarderingen';

  @override
  String get searchMetadataSectionTitle => 'Metadata';

  @override
  String get settingsPageTitle => 'Instellingen';

  @override
  String get settingsSystemDefault => 'Systeem';

  @override
  String get settingsDefault => 'Standaard';

  @override
  String get settingsDisabled => 'Uitgeschakeld';

  @override
  String get settingsAskEverytime => 'Elke keer vragen';

  @override
  String get settingsModificationWarningDialogMessage => 'Andere instellingen zullen worden aangepast.';

  @override
  String get settingsSearchFieldLabel => 'Instellingen doorzoeken';

  @override
  String get settingsSearchEmpty => 'Geen instellingen gevonden';

  @override
  String get settingsActionExport => 'Exporteren';

  @override
  String get settingsActionExportDialogTitle => 'Exporteren';

  @override
  String get settingsActionImport => 'Importeren';

  @override
  String get settingsActionImportDialogTitle => 'Importeren';

  @override
  String get appExportCovers => 'Omslagen';

  @override
  String get appExportDynamicAlbums => 'Dynamische albums';

  @override
  String get appExportFavourites => 'Favorieten';

  @override
  String get appExportSettings => 'Instellingen';

  @override
  String get settingsNavigationSectionTitle => 'Navigatie';

  @override
  String get settingsHomeTile => 'Startscherm';

  @override
  String get settingsHomeDialogTitle => 'Startscherm';

  @override
  String get setHomeCustom => 'Aangepast';

  @override
  String get settingsShowBottomNavigationBar => 'Onderste navigatiebalk weergeven';

  @override
  String get settingsKeepScreenOnTile => 'Scherm aan houden';

  @override
  String get settingsKeepScreenOnDialogTitle => 'Scherm aan houden';

  @override
  String get settingsDoubleBackExit => 'Twee keer op “terug” tikken om af te sluiten';

  @override
  String get settingsConfirmationTile => 'Bevestigingsdialogen';

  @override
  String get settingsConfirmationDialogTitle => 'Bevestigingsdialogen';

  @override
  String get settingsConfirmationBeforeDeleteItems => 'Bevestiging vragen voordat items voor altijd worden verwijderd';

  @override
  String get settingsConfirmationBeforeMoveToBinItems => 'Bevestiging vragen voordat items naar de prullenbak worden verplaatst';

  @override
  String get settingsConfirmationBeforeMoveUndatedItems => 'Bevestiging vragen voordat ongedateerde items worden verplaatst';

  @override
  String get settingsConfirmationAfterMoveToBinItems => 'Bevestigingsbericht weergeven na het verplaatsen van items naar de prullenbak';

  @override
  String get settingsConfirmationVaultDataLoss => 'Waarschuwing weergeven voor verlies van kluisgegevens';

  @override
  String get settingsNavigationDrawerTile => 'Navigatiemenu';

  @override
  String get settingsNavigationDrawerEditorPageTitle => 'Navigatiemenu';

  @override
  String get settingsNavigationDrawerBanner => 'Houd ingedrukt om menu-items te verplaatsen en opnieuw te ordenen.';

  @override
  String get settingsNavigationDrawerTabTypes => 'Typen';

  @override
  String get settingsNavigationDrawerTabAlbums => 'Albums';

  @override
  String get settingsNavigationDrawerTabPages => 'Pagina’s';

  @override
  String get settingsNavigationDrawerAddAlbum => 'Album toevoegen';

  @override
  String get settingsThumbnailSectionTitle => 'Miniaturen';

  @override
  String get settingsThumbnailOverlayTile => 'Overlay';

  @override
  String get settingsThumbnailOverlayPageTitle => 'Overlay';

  @override
  String get settingsThumbnailShowHdrIcon => 'HDR-pictogram tonen';

  @override
  String get settingsThumbnailShowFavouriteIcon => 'Favorieten-pictogram tonen';

  @override
  String get settingsThumbnailShowTagIcon => 'Label-pictogram tonen';

  @override
  String get settingsThumbnailShowLocationIcon => 'Locatie-pictogram tonen';

  @override
  String get settingsThumbnailShowMotionPhotoIcon => 'Bewegende foto-pictogram tonen';

  @override
  String get settingsThumbnailShowRating => 'Waardering tonen';

  @override
  String get settingsThumbnailShowRawIcon => 'RAW-pictogram tonen';

  @override
  String get settingsThumbnailShowVideoDuration => 'Videoduur tonen';

  @override
  String get settingsCollectionQuickActionsTile => 'Snelle bewerkingen';

  @override
  String get settingsCollectionQuickActionEditorPageTitle => 'Snelle acties';

  @override
  String get settingsCollectionQuickActionTabBrowsing => 'Blader';

  @override
  String get settingsCollectionQuickActionTabSelecting => 'Selecteren';

  @override
  String get settingsCollectionBrowsingQuickActionEditorBanner => 'Houd knoppen ingedrukt om deze te verplaatsen en te selecteren welke acties worden weergegeven bij het bladeren door items.';

  @override
  String get settingsCollectionSelectionQuickActionEditorBanner => 'Houd knoppen ingedrukt om deze te verplaatsen en te selecteren welke acties worden weergegeven bij het selecteren van items.';

  @override
  String get settingsCollectionBurstPatternsTile => 'Burst-patronen';

  @override
  String get settingsCollectionBurstPatternsNone => 'Geen';

  @override
  String get settingsViewerSectionTitle => 'Voorbeeld';

  @override
  String get settingsViewerGestureSideTapNext => 'Tik op het scherm om het vorige/volgende item weer te geven';

  @override
  String get settingsViewerUseCutout => 'Uitgesneden gebied gebruiken';

  @override
  String get settingsViewerMaximumBrightness => 'Maximale helderheid';

  @override
  String get settingsMotionPhotoAutoPlay => 'Bewegingsfoto’s automatisch afspelen';

  @override
  String get settingsImageBackground => 'Afbeeldingsachtergrond';

  @override
  String get settingsViewerQuickActionsTile => 'Snelle bewerkingen';

  @override
  String get settingsViewerQuickActionEditorPageTitle => 'Snelle acties';

  @override
  String get settingsViewerQuickActionEditorBanner => 'Houd knoppen ingedrukt om deze te verplaatsen en te selecteren welke acties in de viewer worden weergegeven.';

  @override
  String get settingsViewerQuickActionEditorDisplayedButtonsSectionTitle => 'Zichtbare knoppen';

  @override
  String get settingsViewerQuickActionEditorAvailableButtonsSectionTitle => 'Beschikbare knoppen';

  @override
  String get settingsViewerQuickActionEmpty => 'Geen knoppen';

  @override
  String get settingsViewerOverlayTile => 'Overlay';

  @override
  String get settingsViewerOverlayPageTitle => 'Overlay';

  @override
  String get settingsViewerShowOverlayOnOpening => 'Bij openen weergeven';

  @override
  String get settingsViewerShowHistogram => 'Histogram weergeven';

  @override
  String get settingsViewerShowMinimap => 'Kleine kaart tonen';

  @override
  String get settingsViewerShowInformation => 'Informatie tonen';

  @override
  String get settingsViewerShowInformationSubtitle => 'Titel, datum, locatie, etc.';

  @override
  String get settingsViewerShowRatingTags => 'Waardering & labels tonen';

  @override
  String get settingsViewerShowShootingDetails => 'Opnamedetails tonen';

  @override
  String get settingsViewerShowDescription => 'Beschrijving tonen';

  @override
  String get settingsViewerShowOverlayThumbnails => 'Miniaturen tonen';

  @override
  String get settingsViewerEnableOverlayBlurEffect => 'Vervagingseffect';

  @override
  String get settingsViewerSlideshowTile => 'Diavoorstelling';

  @override
  String get settingsViewerSlideshowPageTitle => 'Diavoorstelling';

  @override
  String get settingsSlideshowRepeat => 'Herhalen';

  @override
  String get settingsSlideshowShuffle => 'Willekeurige volgorde';

  @override
  String get settingsSlideshowFillScreen => 'Volledig scherm';

  @override
  String get settingsSlideshowAnimatedZoomEffect => 'Geanimeerd zoomeffect';

  @override
  String get settingsSlideshowTransitionTile => 'Overgang';

  @override
  String get settingsSlideshowIntervalTile => 'Interval';

  @override
  String get settingsSlideshowVideoPlaybackTile => 'Video afspelen';

  @override
  String get settingsSlideshowVideoPlaybackDialogTitle => 'Video afspelen';

  @override
  String get settingsVideoPageTitle => 'Video Instellingen';

  @override
  String get settingsVideoSectionTitle => 'Video';

  @override
  String get settingsVideoShowVideos => 'Video\'s weergeven';

  @override
  String get settingsVideoPlaybackTile => 'Afspelen';

  @override
  String get settingsVideoPlaybackPageTitle => 'Afspelen';

  @override
  String get settingsVideoEnableHardwareAcceleration => 'Hardware-versnelling';

  @override
  String get settingsVideoAutoPlay => 'Automatisch afspelen';

  @override
  String get settingsVideoLoopModeTile => 'Herhaald afspelen';

  @override
  String get settingsVideoLoopModeDialogTitle => 'Herhaald afspelen';

  @override
  String get settingsVideoResumptionModeTile => 'Afspelen hervatten';

  @override
  String get settingsVideoResumptionModeDialogTitle => 'Afspelen hervatten';

  @override
  String get settingsVideoBackgroundMode => 'Achtergrond-modus';

  @override
  String get settingsVideoBackgroundModeDialogTitle => 'Achtergrond-modus';

  @override
  String get settingsVideoControlsTile => 'Bediening';

  @override
  String get settingsVideoControlsPageTitle => 'Bediening';

  @override
  String get settingsVideoButtonsTile => 'Knoppen';

  @override
  String get settingsVideoGestureDoubleTapTogglePlay => 'Dubbeltik om te spelen/pauzeren';

  @override
  String get settingsVideoGestureSideDoubleTapSeek => 'Dubbeltik op schermranden om achteruit/vooruit te zoeken';

  @override
  String get settingsVideoGestureVerticalDragBrightnessVolume => 'Veeg omhoog of naar beneden om helderheid/volume aan te passen';

  @override
  String get settingsSubtitleThemeTile => 'Ondertiteling';

  @override
  String get settingsSubtitleThemePageTitle => 'Ondertiteling';

  @override
  String get settingsSubtitleThemeSample => 'Dit is een voorbeeld.';

  @override
  String get settingsSubtitleThemeTextAlignmentTile => 'Tekst uitlijnen';

  @override
  String get settingsSubtitleThemeTextAlignmentDialogTitle => 'Tekst uitlijnen';

  @override
  String get settingsSubtitleThemeTextPositionTile => 'Tekstpositie';

  @override
  String get settingsSubtitleThemeTextPositionDialogTitle => 'Tekstpositie';

  @override
  String get settingsSubtitleThemeTextSize => 'Tekstgroote';

  @override
  String get settingsSubtitleThemeShowOutline => 'Omtrek en schaduw tonen';

  @override
  String get settingsSubtitleThemeTextColor => 'Tekstkleur';

  @override
  String get settingsSubtitleThemeTextOpacity => 'Tekstdoorzichtigheid';

  @override
  String get settingsSubtitleThemeBackgroundColor => 'Achtergrondkleur';

  @override
  String get settingsSubtitleThemeBackgroundOpacity => 'Achtergronddoorzichtigheid';

  @override
  String get settingsSubtitleThemeTextAlignmentLeft => 'Links';

  @override
  String get settingsSubtitleThemeTextAlignmentCenter => 'Midden';

  @override
  String get settingsSubtitleThemeTextAlignmentRight => 'Rechts';

  @override
  String get settingsPrivacySectionTitle => 'Privacy';

  @override
  String get settingsAllowInstalledAppAccess => 'Toegang tot app-inventaris toestaan';

  @override
  String get settingsAllowInstalledAppAccessSubtitle => 'Gebruikt om de albumweergave te verbeteren';

  @override
  String get settingsAllowErrorReporting => 'Anonieme foutmeldingen toestaan';

  @override
  String get settingsSaveSearchHistory => 'Zoekgeschiedenis opslaan';

  @override
  String get settingsEnableBin => 'Prullenbak gebruiken';

  @override
  String get settingsEnableBinSubtitle => 'Bewaar verwijderde items 30 dagen';

  @override
  String get settingsDisablingBinWarningDialogMessage => 'Items in de Prullenbak worden voor altijd verwijderd.';

  @override
  String get settingsAllowMediaManagement => 'Mediabeheer toestaan';

  @override
  String get settingsHiddenItemsTile => 'Verborgen items';

  @override
  String get settingsHiddenItemsPageTitle => 'Verborgen Items';

  @override
  String get settingsHiddenFiltersBanner => 'Foto’s en video’s die overeenkomen met verborgen filters, worden niet weergegeven in je verzameling.';

  @override
  String get settingsHiddenFiltersEmpty => 'Geen verborgen filters';

  @override
  String get settingsStorageAccessTile => 'Toegang tot opslag';

  @override
  String get settingsStorageAccessPageTitle => 'Toegang tot opslag';

  @override
  String get settingsStorageAccessBanner => 'Sommige mappen vereisen een expliciete toegangstoekenning om bestanden erin te wijzigen. Je kunt hier directory’s bekijken waartoe je eerder toegang hebt verleend.';

  @override
  String get settingsStorageAccessEmpty => 'Geen toegang verleend';

  @override
  String get settingsStorageAccessRevokeTooltip => 'Herroepen';

  @override
  String get settingsAccessibilitySectionTitle => 'Toegankelijkheid';

  @override
  String get settingsRemoveAnimationsTile => 'Animaties verwijderen';

  @override
  String get settingsRemoveAnimationsDialogTitle => 'Animaties verwijderen';

  @override
  String get settingsTimeToTakeActionTile => 'Reactietijd';

  @override
  String get settingsAccessibilityShowPinchGestureAlternatives => 'Alternatieven voor multi-touch-gebaren weergeven';

  @override
  String get settingsDisplaySectionTitle => 'Scherm';

  @override
  String get settingsThemeBrightnessTile => 'Thema';

  @override
  String get settingsThemeBrightnessDialogTitle => 'Thema';

  @override
  String get settingsThemeColorHighlights => 'Kleurmarkeringen';

  @override
  String get settingsThemeEnableDynamicColor => 'Dynamische kleuren';

  @override
  String get settingsDisplayRefreshRateModeTile => 'Vernieuwingssnelheid weergeven';

  @override
  String get settingsDisplayRefreshRateModeDialogTitle => 'Vernieuwingssnelheid';

  @override
  String get settingsDisplayUseTvInterface => 'Android TV-interface';

  @override
  String get settingsLanguageSectionTitle => 'Taal & landinstellingen';

  @override
  String get settingsLanguageTile => 'Taal';

  @override
  String get settingsLanguagePageTitle => 'Taal';

  @override
  String get settingsCoordinateFormatTile => 'Coördinaten-weergave';

  @override
  String get settingsCoordinateFormatDialogTitle => 'Coördinaten-weergave';

  @override
  String get settingsUnitSystemTile => 'Eenheden';

  @override
  String get settingsUnitSystemDialogTitle => 'Eenheden';

  @override
  String get settingsForceWesternArabicNumeralsTile => 'Arabische cijfers forceren';

  @override
  String get settingsScreenSaverPageTitle => 'Schermbeveiliging';

  @override
  String get settingsWidgetPageTitle => 'Fotolijst';

  @override
  String get settingsWidgetShowOutline => 'Contour';

  @override
  String get settingsWidgetOpenPage => 'Bij het tikken op de widget';

  @override
  String get settingsWidgetDisplayedItem => 'Zichtbaar item';

  @override
  String get settingsCollectionTile => 'Verzameling';

  @override
  String get statsPageTitle => 'Stats';

  @override
  String statsWithGps(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString items met locatie',
      one: '1 item met locatie',
    );
    return '$_temp0';
  }

  @override
  String get statsTopCountriesSectionTitle => 'Top Landen';

  @override
  String get statsTopStatesSectionTitle => 'Top Staten';

  @override
  String get statsTopPlacesSectionTitle => 'Top Plaatsen';

  @override
  String get statsTopTagsSectionTitle => 'Top Labels';

  @override
  String get statsTopAlbumsSectionTitle => 'Top Albums';

  @override
  String get viewerOpenPanoramaButtonLabel => 'PANORAMA OPENEN';

  @override
  String get viewerSetWallpaperButtonLabel => 'ALS ACHTERGROND INSTELLEN';

  @override
  String get viewerErrorUnknown => 'Oei!';

  @override
  String get viewerErrorDoesNotExist => 'Het bestand bestaat niet meer.';

  @override
  String get viewerInfoPageTitle => 'Info';

  @override
  String get viewerInfoBackToViewerTooltip => 'Terug naar viewer';

  @override
  String get viewerInfoUnknown => 'onbekendd';

  @override
  String get viewerInfoLabelDescription => 'Omschrijving';

  @override
  String get viewerInfoLabelTitle => 'Titel';

  @override
  String get viewerInfoLabelDate => 'Datum';

  @override
  String get viewerInfoLabelResolution => 'Resolutie';

  @override
  String get viewerInfoLabelSize => 'Grootte';

  @override
  String get viewerInfoLabelUri => 'URI';

  @override
  String get viewerInfoLabelPath => 'Pad';

  @override
  String get viewerInfoLabelDuration => 'Duur';

  @override
  String get viewerInfoLabelOwner => 'Eigenaar';

  @override
  String get viewerInfoLabelCoordinates => 'Coördinaten';

  @override
  String get viewerInfoLabelAddress => 'Adres';

  @override
  String get mapStyleDialogTitle => 'Kaartstijl';

  @override
  String get mapStyleTooltip => 'Kaartstijl selecteren';

  @override
  String get mapZoomInTooltip => 'Inzoomen';

  @override
  String get mapZoomOutTooltip => 'Uitzoomen';

  @override
  String get mapPointNorthUpTooltip => 'Noorden boven';

  @override
  String get mapAttributionOsmData => 'Kaartgegevens © [OpenStreetMap](https://www.openstreetmap.org/copyright) bijdragers';

  @override
  String get mapAttributionOsmLiberty => 'Symbolen van [OpenMapTiles](https://www.openmaptiles.org/), [CC BY](http://creativecommons.org/licenses/by/4.0) • Aangeboden door [OSM Americana](https://tile.ourmap.us)';

  @override
  String get mapAttributionOpenTopoMap => '[SRTM](https://www.earthdata.nasa.gov/sensors/srtm) | Tegels van [OpenTopoMap](https://opentopomap.org/), [CC BY-SA](https://creativecommons.org/licenses/by-sa/3.0/)';

  @override
  String get mapAttributionOsmHot => 'Tegels door [HOT](https://www.hotosm.org/) • Gehost door [OSM France](https://openstreetmap.fr/)';

  @override
  String get mapAttributionStamen => 'Tegels door [Stamen Design](https://stamen.com), [CC BY 3.0](https://creativecommons.org/licenses/by/3.0)';

  @override
  String get openMapPageTooltip => 'Op kaartpagina tonen';

  @override
  String get mapEmptyRegion => 'Geen afbeeldingen in dit gebied';

  @override
  String get viewerInfoOpenEmbeddedFailureFeedback => 'Kan ingesloten gegevens niet extraheren';

  @override
  String get viewerInfoOpenLinkText => 'Openen';

  @override
  String get viewerInfoViewXmlLinkText => 'Bekijk XML';

  @override
  String get viewerInfoSearchFieldLabel => 'Metadata doorzoeken';

  @override
  String get viewerInfoSearchEmpty => 'Geen overeenkomstige zoeksleutels';

  @override
  String get viewerInfoSearchSuggestionDate => 'Datum & tijd';

  @override
  String get viewerInfoSearchSuggestionDescription => 'Beschrijving';

  @override
  String get viewerInfoSearchSuggestionDimensions => 'Afmetingen';

  @override
  String get viewerInfoSearchSuggestionResolution => 'Resolutie';

  @override
  String get viewerInfoSearchSuggestionRights => 'Rechten';

  @override
  String get wallpaperUseScrollEffect => 'Scroll-effect gebruiken op startscherm';

  @override
  String get tagEditorPageTitle => 'Labels bewerken';

  @override
  String get tagEditorPageNewTagFieldLabel => 'Nieuw label';

  @override
  String get tagEditorPageAddTagTooltip => 'Label toevoegen';

  @override
  String get tagEditorSectionRecent => 'Recent';

  @override
  String get tagEditorSectionPlaceholders => 'Aanduidingen';

  @override
  String get tagEditorDiscardDialogMessage => 'Wijzigingen ongedaan maken?';

  @override
  String get tagPlaceholderCountry => 'Land';

  @override
  String get tagPlaceholderState => 'Staat';

  @override
  String get tagPlaceholderPlace => 'Plaats';

  @override
  String get panoramaEnableSensorControl => 'Sensor control inschakelen';

  @override
  String get panoramaDisableSensorControl => 'Sensor control uitschakelen';

  @override
  String get sourceViewerPageTitle => 'Source';
}
