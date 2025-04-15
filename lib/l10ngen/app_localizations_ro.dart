// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Romanian Moldavian Moldovan (`ro`).
class AppLocalizationsRo extends AppLocalizations {
  AppLocalizationsRo([String locale = 'ro']) : super(locale);

  @override
  String get appName => 'Aves';

  @override
  String get welcomeMessage => 'Bun venit la Aves';

  @override
  String get welcomeOptional => 'Opțional';

  @override
  String get welcomeTermsToggle => 'Sunt de acord cu Termenii și condițiile';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elemente',
      one: '$count element',
    );
    return '$_temp0';
  }

  @override
  String columnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count coloane',
      one: '$count coloană',
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
      other: '$countString secunde',
      one: '$countString secundă',
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
      other: '$countString minute',
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
      other: '$countString zile',
      one: '$countString zi',
    );
    return '$_temp0';
  }

  @override
  String focalLength(String length) {
    return '$length mm';
  }

  @override
  String get applyButtonLabel => 'APLICA';

  @override
  String get deleteButtonLabel => 'ȘTERGE';

  @override
  String get nextButtonLabel => 'URMĂTORUL';

  @override
  String get showButtonLabel => 'SPECTACOL';

  @override
  String get hideButtonLabel => 'ASCUNDE';

  @override
  String get continueButtonLabel => 'CONTINUA';

  @override
  String get saveCopyButtonLabel => 'SALVEAZĂ COPIA';

  @override
  String get applyTooltip => 'Aplică';

  @override
  String get cancelTooltip => 'Anulare';

  @override
  String get changeTooltip => 'Schimbare';

  @override
  String get clearTooltip => 'Golire';

  @override
  String get previousTooltip => 'Anterior';

  @override
  String get nextTooltip => 'Următorul';

  @override
  String get showTooltip => 'Spectacol';

  @override
  String get hideTooltip => 'Ascunde';

  @override
  String get actionRemove => 'Elimina';

  @override
  String get resetTooltip => 'Resetați';

  @override
  String get saveTooltip => 'Salvați';

  @override
  String get stopTooltip => 'Oprește';

  @override
  String get pickTooltip => 'Alege';

  @override
  String get doubleBackExitMessage => 'Atingeți „înapoi” din nou pentru a ieși.';

  @override
  String get doNotAskAgain => 'Nu cere din nou';

  @override
  String get sourceStateLoading => 'Se încarcă';

  @override
  String get sourceStateCataloguing => 'Catalogare';

  @override
  String get sourceStateLocatingCountries => 'Localizarea țărilor';

  @override
  String get sourceStateLocatingPlaces => 'Localizarea locurilor';

  @override
  String get chipActionDelete => 'Șterge';

  @override
  String get chipActionRemove => 'Elimină';

  @override
  String get chipActionShowCollection => 'Afișați în colecție';

  @override
  String get chipActionGoToAlbumPage => 'Afișați în albume';

  @override
  String get chipActionGoToCountryPage => 'Adișați în țări';

  @override
  String get chipActionGoToPlacePage => 'Arată în Locuri';

  @override
  String get chipActionGoToTagPage => 'Afișați în etichete';

  @override
  String get chipActionGoToExplorerPage => 'Afișare în Explorer';

  @override
  String get chipActionDecompose => 'Divizare';

  @override
  String get chipActionFilterOut => 'Filtre de ieșire';

  @override
  String get chipActionFilterIn => 'Filtre de intrare';

  @override
  String get chipActionHide => 'Ascunde';

  @override
  String get chipActionLock => 'Blocare';

  @override
  String get chipActionPin => 'Fixați sus';

  @override
  String get chipActionUnpin => 'Anulați fixarea de sus';

  @override
  String get chipActionRename => 'Redenumiți';

  @override
  String get chipActionSetCover => 'Setați capacul';

  @override
  String get chipActionShowCountryStates => 'Afișare state';

  @override
  String get chipActionCreateAlbum => 'Creați album';

  @override
  String get chipActionCreateVault => 'Creare seif';

  @override
  String get chipActionConfigureVault => 'Configurare seif';

  @override
  String get entryActionCopyToClipboard => 'Copiați în clipboard';

  @override
  String get entryActionDelete => 'Șterge';

  @override
  String get entryActionConvert => 'Convertit';

  @override
  String get entryActionExport => 'Export';

  @override
  String get entryActionInfo => 'Info';

  @override
  String get entryActionRename => 'Redenumiți';

  @override
  String get entryActionRestore => 'Restabiliți';

  @override
  String get entryActionRotateCCW => 'Rotiți în sens invers acelor de ceasornic';

  @override
  String get entryActionRotateCW => 'Roteste in sensul acelor de ceasornic';

  @override
  String get entryActionFlip => 'Întoarceți pe orizontală';

  @override
  String get entryActionPrint => 'Imprimare';

  @override
  String get entryActionShare => 'Partajare';

  @override
  String get entryActionShareImageOnly => 'Distribuie doar imaginea';

  @override
  String get entryActionShareVideoOnly => 'Distribuie numai videoclipul';

  @override
  String get entryActionViewSource => 'Vizualizare sursă';

  @override
  String get entryActionShowGeoTiffOnMap => 'Afișați ca suprapunere a hărții';

  @override
  String get entryActionConvertMotionPhotoToStillImage => 'Convertiți în imagine statică';

  @override
  String get entryActionViewMotionPhotoVideo => 'Deschide videoclipul';

  @override
  String get entryActionEdit => 'Editați';

  @override
  String get entryActionOpen => 'Deschide cu';

  @override
  String get entryActionSetAs => 'Setați ca';

  @override
  String get entryActionCast => 'Proiectare';

  @override
  String get entryActionOpenMap => 'Afișați în aplicația pentru hartă';

  @override
  String get entryActionRotateScreen => 'Rotiți ecranul';

  @override
  String get entryActionAddFavourite => 'Adauga la favorite';

  @override
  String get entryActionRemoveFavourite => 'Eliminați din favorite';

  @override
  String get videoActionCaptureFrame => 'Captură cadru';

  @override
  String get videoActionMute => 'Dezactivați sunetul';

  @override
  String get videoActionUnmute => 'Activați sunetul';

  @override
  String get videoActionPause => 'Pauză';

  @override
  String get videoActionPlay => 'Redă';

  @override
  String get videoActionReplay10 => 'Căutați înapoi 10 secunde';

  @override
  String get videoActionSkip10 => 'Căutați înainte 10 secunde';

  @override
  String get videoActionShowPreviousFrame => 'Afișează cadrul anterior';

  @override
  String get videoActionShowNextFrame => 'Afișează următorul cadru';

  @override
  String get videoActionSelectStreams => 'Selectați piese';

  @override
  String get videoActionSetSpeed => 'Viteza de redare';

  @override
  String get videoActionABRepeat => 'Repetă de la A la B';

  @override
  String get videoRepeatActionSetStart => 'Setează începutul';

  @override
  String get videoRepeatActionSetEnd => 'Setează sfârșitul';

  @override
  String get viewerActionSettings => 'Setări';

  @override
  String get viewerActionLock => 'Blocarea vizualizatorului';

  @override
  String get viewerActionUnlock => 'Deblocare vizualizator';

  @override
  String get slideshowActionResume => 'Reluare';

  @override
  String get slideshowActionShowInCollection => 'Afișați în colecție';

  @override
  String get entryInfoActionEditDate => 'Editați data și ora';

  @override
  String get entryInfoActionEditLocation => 'Editați locația';

  @override
  String get entryInfoActionEditTitleDescription => 'Editați titlul și descrierea';

  @override
  String get entryInfoActionEditRating => 'Editați evaluarea';

  @override
  String get entryInfoActionEditTags => 'Editați etichetele';

  @override
  String get entryInfoActionRemoveMetadata => 'Eliminați metadatele';

  @override
  String get entryInfoActionExportMetadata => 'Exportare metadate';

  @override
  String get entryInfoActionRemoveLocation => 'Eliminare locație';

  @override
  String get editorActionTransform => 'Transformă';

  @override
  String get editorTransformCrop => 'Decupare';

  @override
  String get editorTransformRotate => 'Rotire';

  @override
  String get cropAspectRatioFree => 'Liber';

  @override
  String get cropAspectRatioOriginal => 'Original';

  @override
  String get cropAspectRatioSquare => 'Pătrat';

  @override
  String get filterAspectRatioLandscapeLabel => 'Peisaj';

  @override
  String get filterAspectRatioPortraitLabel => 'Portret';

  @override
  String get filterBinLabel => 'Cos de gunoi';

  @override
  String get filterFavouriteLabel => 'Favorit';

  @override
  String get filterNoDateLabel => 'Nedatat';

  @override
  String get filterNoAddressLabel => 'Nicio adresă';

  @override
  String get filterLocatedLabel => 'Locație';

  @override
  String get filterNoLocationLabel => 'Nelocat';

  @override
  String get filterNoRatingLabel => 'Neevaluat';

  @override
  String get filterTaggedLabel => 'Etichetat';

  @override
  String get filterNoTagLabel => 'Neetichetat';

  @override
  String get filterNoTitleLabel => 'Fără titlu';

  @override
  String get filterOnThisDayLabel => 'În această zi';

  @override
  String get filterRecentlyAddedLabel => 'Adaugate recent';

  @override
  String get filterRatingRejectedLabel => 'Respins';

  @override
  String get filterTypeAnimatedLabel => 'Animații';

  @override
  String get filterTypeMotionPhotoLabel => 'Fotografie în mișcare';

  @override
  String get filterTypePanoramaLabel => 'Panoramă';

  @override
  String get filterTypeRawLabel => 'Raw';

  @override
  String get filterTypeSphericalVideoLabel => 'Video 360°';

  @override
  String get filterTypeGeotiffLabel => 'GeoTIFF';

  @override
  String get filterMimeImageLabel => 'Imagine';

  @override
  String get filterMimeVideoLabel => 'Video';

  @override
  String get accessibilityAnimationsRemove => 'Preveniți efectele ecranului';

  @override
  String get accessibilityAnimationsKeep => 'Păstrați efectele ecranului';

  @override
  String get albumTierNew => 'Nou';

  @override
  String get albumTierPinned => 'Fixat';

  @override
  String get albumTierSpecial => 'Uzual';

  @override
  String get albumTierApps => 'Aplicații';

  @override
  String get albumTierVaults => 'Seifuri';

  @override
  String get albumTierDynamic => 'Dinamic';

  @override
  String get albumTierRegular => 'Alții';

  @override
  String get coordinateFormatDms => 'DMS';

  @override
  String get coordinateFormatDdm => 'DDM';

  @override
  String get coordinateFormatDecimal => 'Grade zecimale';

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
  String get displayRefreshRatePreferHighest => 'Rata cea mai mare';

  @override
  String get displayRefreshRatePreferLowest => 'Rata cea mai mica';

  @override
  String get keepScreenOnNever => 'Nu';

  @override
  String get keepScreenOnVideoPlayback => 'În timpul redării video';

  @override
  String get keepScreenOnViewerOnly => 'Numai pagina de vizualizare';

  @override
  String get keepScreenOnAlways => 'Mereu';

  @override
  String get lengthUnitPixel => 'px';

  @override
  String get lengthUnitPercent => '%';

  @override
  String get mapStyleGoogleNormal => 'Hărți Google';

  @override
  String get mapStyleGoogleHybrid => 'Hărți Google (hibrid)';

  @override
  String get mapStyleGoogleTerrain => 'Hărți Google (Teren)';

  @override
  String get mapStyleOsmLiberty => 'OSM Liberty';

  @override
  String get mapStyleOpenTopoMap => 'OpenTopoMap';

  @override
  String get mapStyleOsmHot => 'OSM umanitar';

  @override
  String get mapStyleStamenWatercolor => 'Stamine Acuarela';

  @override
  String get maxBrightnessNever => 'Niciodată';

  @override
  String get maxBrightnessAlways => 'Mereu';

  @override
  String get nameConflictStrategyRename => 'Redenumiți';

  @override
  String get nameConflictStrategyReplace => 'Înlocuiți';

  @override
  String get nameConflictStrategySkip => 'Sări';

  @override
  String get overlayHistogramNone => 'Nimic';

  @override
  String get overlayHistogramRGB => 'RGB';

  @override
  String get overlayHistogramLuminance => 'Luminanță';

  @override
  String get subtitlePositionTop => 'Sus';

  @override
  String get subtitlePositionBottom => 'Jos';

  @override
  String get themeBrightnessLight => 'Luminoasă';

  @override
  String get themeBrightnessDark => 'Întunecată';

  @override
  String get themeBrightnessBlack => 'Black';

  @override
  String get unitSystemMetric => 'Metrice';

  @override
  String get unitSystemImperial => 'Imperial';

  @override
  String get vaultLockTypePattern => 'Model';

  @override
  String get vaultLockTypePin => 'Pin';

  @override
  String get vaultLockTypePassword => 'Parolă';

  @override
  String get settingsVideoEnablePip => 'Imagine în imagine';

  @override
  String get videoControlsPlayOutside => 'Deschide cu alt player';

  @override
  String get videoLoopModeNever => 'Niciodată';

  @override
  String get videoLoopModeShortOnly => 'Numai videoclipuri scurte';

  @override
  String get videoLoopModeAlways => 'Mereu';

  @override
  String get videoPlaybackSkip => 'Sări';

  @override
  String get videoPlaybackMuted => 'Redare fără sunet';

  @override
  String get videoPlaybackWithSound => 'Redare cu sunet';

  @override
  String get videoResumptionModeNever => 'Niciodată';

  @override
  String get videoResumptionModeAlways => 'Mereu';

  @override
  String get viewerTransitionSlide => 'Slide';

  @override
  String get viewerTransitionParallax => 'Paralaxă';

  @override
  String get viewerTransitionFade => 'Decolorare';

  @override
  String get viewerTransitionZoomIn => 'Mărește zoom';

  @override
  String get viewerTransitionNone => 'Nici unul';

  @override
  String get wallpaperTargetHome => 'Ecranul de start';

  @override
  String get wallpaperTargetLock => 'Ecranul de blocare';

  @override
  String get wallpaperTargetHomeLock => 'Ecranul de start și de blocare';

  @override
  String get widgetDisplayedItemRandom => 'Aleatoriu';

  @override
  String get widgetDisplayedItemMostRecent => 'Cele mai recente';

  @override
  String get widgetOpenPageHome => 'Deschide acasă';

  @override
  String get widgetOpenPageCollection => 'Deschide colecții';

  @override
  String get widgetOpenPageViewer => 'Deschide vizualizatorul';

  @override
  String get widgetTapUpdateWidget => 'Actualizare widget';

  @override
  String get storageVolumeDescriptionFallbackPrimary => 'Stocare internă';

  @override
  String get storageVolumeDescriptionFallbackNonPrimary => 'card SD';

  @override
  String get rootDirectoryDescription => 'directorul rădăcină';

  @override
  String otherDirectoryDescription(String name) {
    return 'directorul „$name”';
  }

  @override
  String storageAccessDialogMessage(String directory, String volume) {
    return 'Vă rugăm să selectați $directory „$volume” în ecranul următor pentru a oferi acestei aplicații acces la acesta.';
  }

  @override
  String restrictedAccessDialogMessage(String directory, String volume) {
    return 'Această aplicație nu are permisiunea de a modifica fișiere din $directory „$volume”.\n\nUtilizați un manager de fișiere preinstalat sau o aplicație de galerie pentru a muta elementele într-un alt director.';
  }

  @override
  String notEnoughSpaceDialogMessage(String neededSize, String freeSize, String volume) {
    return 'Această operațiune are nevoie de $neededSize spațiu liber pe „$volume” pentru a fi finalizată, dar a mai rămas doar $freeSize.';
  }

  @override
  String get missingSystemFilePickerDialogMessage => 'Selectorul de fișiere de sistem lipsește sau este dezactivat. Activați-l și încercați din nou.';

  @override
  String unsupportedTypeDialogMessage(int count, String types) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Această operațiune nu este acceptată pentru articole de următoarele tipuri: $types.',
      one: 'Această operațiune nu este acceptată pentru articole de următorul tip: $types.',
    );
    return '$_temp0';
  }

  @override
  String get nameConflictDialogSingleSourceMessage => 'Unele fișiere din folderul de destinație au același nume.';

  @override
  String get nameConflictDialogMultipleSourceMessage => 'Unele fișiere au același nume.';

  @override
  String get addShortcutDialogLabel => 'Etichetă de comandă rapidă';

  @override
  String get addShortcutButtonLabel => 'ADD';

  @override
  String get noMatchingAppDialogMessage => 'Nu există aplicații care să se ocupe de asta.';

  @override
  String binEntriesConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mutați aceste $count articole în coșul de reciclare?',
      one: 'Mutați acest articol în coșul de reciclare?',
    );
    return '$_temp0';
  }

  @override
  String deleteEntriesConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ștergeți aceste $count articole?',
      one: 'Ștergeți acest articol?',
    );
    return '$_temp0';
  }

  @override
  String get moveUndatedConfirmationDialogMessage => 'Salvați datele articolului înainte de a continua?';

  @override
  String get moveUndatedConfirmationDialogSetDate => 'Salvați datele';

  @override
  String videoResumeDialogMessage(String time) {
    return 'Doriți să reluați redarea la $time?';
  }

  @override
  String get videoStartOverButtonLabel => 'Începe din nou';

  @override
  String get videoResumeButtonLabel => 'Reluați';

  @override
  String get setCoverDialogLatest => 'Ultimul articol';

  @override
  String get setCoverDialogAuto => 'Auto';

  @override
  String get setCoverDialogCustom => 'Personalizat';

  @override
  String get hideFilterConfirmationDialogMessage => 'Fotografiile și videoclipurile care se potrivesc vor fi ascunse din colecția ta. Le puteți afișa din nou din setările „Confidențialitate”.\n\n Ești sigur că vrei să le ascunzi?';

  @override
  String get newAlbumDialogTitle => 'Album nou';

  @override
  String get newAlbumDialogNameLabel => 'Numele albumului';

  @override
  String get newAlbumDialogAlbumAlreadyExistsHelper => 'Albumul există deja';

  @override
  String get newAlbumDialogNameLabelAlreadyExistsHelper => 'Directorul există deja';

  @override
  String get newAlbumDialogStorageLabel => 'Depozitare:';

  @override
  String get newDynamicAlbumDialogTitle => 'Nou album dinamic';

  @override
  String get dynamicAlbumAlreadyExists => 'Albumul dinamic există deja';

  @override
  String get newVaultWarningDialogMessage => 'Elementele din seifuri sunt disponibile doar pentru această aplicație și nu pentru altele.\n\nDacă dezinstalezi această aplicație sau ștergi datele acestei aplicații, vei pierde toate aceste elemente.';

  @override
  String get newVaultDialogTitle => 'Seif nou';

  @override
  String get configureVaultDialogTitle => 'Configurare seif';

  @override
  String get vaultDialogLockModeWhenScreenOff => 'Blocare atunci când ecranul se oprește';

  @override
  String get vaultDialogLockTypeLabel => 'Tip de blocare';

  @override
  String get patternDialogEnter => 'Introdu modelul';

  @override
  String get patternDialogConfirm => 'Confirmă modelul';

  @override
  String get pinDialogEnter => 'Introdu codul PIN';

  @override
  String get pinDialogConfirm => 'Confirmă codul PIN';

  @override
  String get passwordDialogEnter => 'Introdu parola';

  @override
  String get passwordDialogConfirm => 'Confirmă parola';

  @override
  String get authenticateToConfigureVault => 'Autentifică-te pentru a configura seiful';

  @override
  String get authenticateToUnlockVault => 'Autentifică-te pentru a debloca seiful';

  @override
  String get vaultBinUsageDialogMessage => 'Unele seifuri folosesc coșul de reciclare.';

  @override
  String get renameAlbumDialogLabel => 'Nume nou';

  @override
  String get renameAlbumDialogLabelAlreadyExistsHelper => 'Directorul există deja';

  @override
  String get renameEntrySetPageTitle => 'Redenumiți';

  @override
  String get renameEntrySetPagePatternFieldLabel => 'Model de denumire';

  @override
  String get renameEntrySetPageInsertTooltip => 'Inserați câmp';

  @override
  String get renameEntrySetPagePreviewSectionTitle => 'Previzualizare';

  @override
  String get renameProcessorCounter => 'Tejghea';

  @override
  String get renameProcessorHash => 'Hash';

  @override
  String get renameProcessorName => 'Nume';

  @override
  String deleteSingleAlbumConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ștergi acest album și $count articolele din el?',
      one: 'Ștergi acest album și articolul din el?',
    );
    return '$_temp0';
  }

  @override
  String deleteMultiAlbumConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ștergi aceste albume și $count articolele din ele?',
      one: 'Ștergi aceste albume și articolul din ele?',
    );
    return '$_temp0';
  }

  @override
  String get exportEntryDialogFormat => 'Format:';

  @override
  String get exportEntryDialogWidth => 'Lățime';

  @override
  String get exportEntryDialogHeight => 'Înălțime';

  @override
  String get exportEntryDialogQuality => 'Calitate';

  @override
  String get exportEntryDialogWriteMetadata => 'Scrierea metadatelor';

  @override
  String get renameEntryDialogLabel => 'Nume nou';

  @override
  String get editEntryDialogCopyFromItem => 'Copiați din alt articol';

  @override
  String get editEntryDialogTargetFieldsHeader => 'Câmpuri de modificat';

  @override
  String get editEntryDateDialogTitle => 'Data și ora';

  @override
  String get editEntryDateDialogSetCustom => 'Setați o dată personalizată';

  @override
  String get editEntryDateDialogCopyField => 'Copie de la altă dată';

  @override
  String get editEntryDateDialogExtractFromTitle => 'Extras din titlu';

  @override
  String get editEntryDateDialogShift => 'Schimbă';

  @override
  String get editEntryDateDialogSourceFileModifiedDate => 'Data modificării fișierului';

  @override
  String get durationDialogHours => 'Ore';

  @override
  String get durationDialogMinutes => 'Minute';

  @override
  String get durationDialogSeconds => 'secunde';

  @override
  String get editEntryLocationDialogTitle => 'Locație';

  @override
  String get editEntryLocationDialogSetCustom => 'Setați locația personalizată';

  @override
  String get editEntryLocationDialogChooseOnMap => 'Alegeți pe hartă';

  @override
  String get editEntryLocationDialogImportGpx => 'Import GPX';

  @override
  String get editEntryLocationDialogLatitude => 'Latitudine';

  @override
  String get editEntryLocationDialogLongitude => 'Longitudine';

  @override
  String get editEntryLocationDialogTimeShift => 'Schimb de timp';

  @override
  String get locationPickerUseThisLocationButton => 'Utilizați această locație';

  @override
  String get editEntryRatingDialogTitle => 'Evaluare';

  @override
  String get removeEntryMetadataDialogTitle => 'Eliminarea metadatelor';

  @override
  String get removeEntryMetadataDialogAll => 'Toate';

  @override
  String get removeEntryMetadataDialogMore => 'Mai mult';

  @override
  String get removeEntryMetadataMotionPhotoXmpWarningDialogMessage => 'XMP este necesar pentru a reda videoclipul dintr-o fotografie în mișcare.\n\nSunteți sigur că doriți să-l eliminați?';

  @override
  String get videoSpeedDialogLabel => 'Viteza de redare';

  @override
  String get videoStreamSelectionDialogVideo => 'Video';

  @override
  String get videoStreamSelectionDialogAudio => 'Audio';

  @override
  String get videoStreamSelectionDialogText => 'Subtitrări';

  @override
  String get videoStreamSelectionDialogOff => 'Oprit';

  @override
  String get videoStreamSelectionDialogTrack => 'Pistă';

  @override
  String get videoStreamSelectionDialogNoSelection => 'Nu există alte piese.';

  @override
  String get genericSuccessFeedback => 'Terminat!';

  @override
  String get genericFailureFeedback => 'Eșuat';

  @override
  String get genericDangerWarningDialogMessage => 'Esti sigur?';

  @override
  String get tooManyItemsErrorDialogMessage => 'Încearcă din nou cu mai puține elemente.';

  @override
  String get menuActionConfigureView => 'Vedere';

  @override
  String get menuActionSelect => 'Selectați';

  @override
  String get menuActionSelectAll => 'Selectează tot';

  @override
  String get menuActionSelectNone => 'Nu selectați nimic';

  @override
  String get menuActionMap => 'Hartă';

  @override
  String get menuActionSlideshow => 'Prezentare de diapozitive';

  @override
  String get menuActionStats => 'Statistici';

  @override
  String get viewDialogSortSectionTitle => 'Sortează';

  @override
  String get viewDialogGroupSectionTitle => 'Grup';

  @override
  String get viewDialogLayoutSectionTitle => 'Aspect';

  @override
  String get viewDialogReverseSortOrder => 'Ordinea de sortare inversă';

  @override
  String get tileLayoutMosaic => 'Mozaic';

  @override
  String get tileLayoutGrid => 'Grilă';

  @override
  String get tileLayoutList => 'Listă';

  @override
  String get castDialogTitle => 'Dispozitive de proiectare';

  @override
  String get coverDialogTabCover => 'Copertă';

  @override
  String get coverDialogTabApp => 'App';

  @override
  String get coverDialogTabColor => 'Culoare';

  @override
  String get appPickDialogTitle => 'Alegeți aplicația';

  @override
  String get appPickDialogNone => 'Nici unul';

  @override
  String get aboutPageTitle => 'Despre';

  @override
  String get aboutLinkLicense => 'Licență';

  @override
  String get aboutLinkPolicy => 'Politica de Confidențialitate';

  @override
  String get aboutBugSectionTitle => 'Raport de eroare';

  @override
  String get aboutBugSaveLogInstruction => 'Salvați jurnalele aplicației într-un fișier';

  @override
  String get aboutBugCopyInfoInstruction => 'Copiați informațiile despre sistem';

  @override
  String get aboutBugCopyInfoButton => 'Copie';

  @override
  String get aboutBugReportInstruction => 'Raportați pe GitHub cu jurnalele și informațiile de sistem';

  @override
  String get aboutBugReportButton => 'Raport';

  @override
  String get aboutDataUsageSectionTitle => 'Utilizare date';

  @override
  String get aboutDataUsageData => 'Date';

  @override
  String get aboutDataUsageCache => 'Cache';

  @override
  String get aboutDataUsageDatabase => 'Bază de date';

  @override
  String get aboutDataUsageMisc => 'Diverse';

  @override
  String get aboutDataUsageInternal => 'Intern';

  @override
  String get aboutDataUsageExternal => 'Extern';

  @override
  String get aboutDataUsageClearCache => 'Golește memoria cache';

  @override
  String get aboutCreditsSectionTitle => 'Credite';

  @override
  String get aboutCreditsWorldAtlas1 => 'Această aplicație folosește un fișier TopoJSON de la';

  @override
  String get aboutCreditsWorldAtlas2 => 'sub licență ISC.';

  @override
  String get aboutTranslatorsSectionTitle => 'Traducători';

  @override
  String get aboutLicensesSectionTitle => 'Licențe open-source';

  @override
  String get aboutLicensesBanner => 'Această aplicație folosește următoarele pachete și biblioteci open-source.';

  @override
  String get aboutLicensesAndroidLibrariesSectionTitle => 'Biblioteci Android';

  @override
  String get aboutLicensesFlutterPluginsSectionTitle => 'Pluginuri Flutter';

  @override
  String get aboutLicensesFlutterPackagesSectionTitle => 'Pachete Flutter';

  @override
  String get aboutLicensesDartPackagesSectionTitle => 'Pachete Dart';

  @override
  String get aboutLicensesShowAllButtonLabel => 'Afișați toate licențele';

  @override
  String get policyPageTitle => 'Politica de Confidențialitate';

  @override
  String get collectionPageTitle => 'Colectie';

  @override
  String get collectionPickPageTitle => 'Alege';

  @override
  String get collectionSelectPageTitle => 'Selectați articole';

  @override
  String get collectionActionShowTitleSearch => 'Afișează filtrul de titlu';

  @override
  String get collectionActionHideTitleSearch => 'Ascunde filtrul de titlu';

  @override
  String get collectionActionAddDynamicAlbum => 'Adaugă album dinamic';

  @override
  String get collectionActionAddShortcut => 'Adauga scurtatura';

  @override
  String get collectionActionSetHome => 'Setare ca principal';

  @override
  String get collectionActionEmptyBin => 'Coșul gol';

  @override
  String get collectionActionCopy => 'Copiați în album';

  @override
  String get collectionActionMove => 'Mutați la album';

  @override
  String get collectionActionRescan => 'Rescanați';

  @override
  String get collectionActionEdit => 'Editați';

  @override
  String get collectionSearchTitlesHintText => 'Căutați titluri';

  @override
  String get collectionGroupAlbum => 'După album';

  @override
  String get collectionGroupMonth => 'După lună';

  @override
  String get collectionGroupDay => 'După zi';

  @override
  String get collectionGroupNone => 'Nu grupați';

  @override
  String get sectionUnknown => 'Necunoscut';

  @override
  String get dateToday => 'Astăzi';

  @override
  String get dateYesterday => 'Ieri';

  @override
  String get dateThisMonth => 'Luna aceasta';

  @override
  String collectionDeleteFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'A eșuat ștergerea a $count elemente',
      one: 'A eșuat ștergerea unui element',
    );
    return '$_temp0';
  }

  @override
  String collectionCopyFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Eșuat la copierea $count articole',
      one: 'Eșuat la copierea unui articol',
    );
    return '$_temp0';
  }

  @override
  String collectionMoveFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nu s-au mutat $count articole',
      one: 'Nu s-au mutat 1 articol',
    );
    return '$_temp0';
  }

  @override
  String collectionRenameFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'A eșuat redenumirea a $count elemente',
      one: 'A eșuat redenumirea unui element',
    );
    return '$_temp0';
  }

  @override
  String collectionEditFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'A eșuat editarea a $count elemente',
      one: 'A eșuat editarea unui element',
    );
    return '$_temp0';
  }

  @override
  String collectionExportFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'A eșuat exportarea a $count pagini',
      one: 'A eșuat exportarea unei pagini',
    );
    return '$_temp0';
  }

  @override
  String collectionCopySuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'S-au copiat $count articole',
      one: 'S-a copiat 1 articol',
    );
    return '$_temp0';
  }

  @override
  String collectionMoveSuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'S-au mutat $count articole',
      one: 'S-a mutat 1 articol',
    );
    return '$_temp0';
  }

  @override
  String collectionRenameSuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'S-au renumit $count articole',
      one: 'Sa renumit 1 articol',
    );
    return '$_temp0';
  }

  @override
  String collectionEditSuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'S-au editat $count articole',
      one: 'S-a editat 1 articol',
    );
    return '$_temp0';
  }

  @override
  String get collectionEmptyFavourites => 'Fără favorite';

  @override
  String get collectionEmptyVideos => 'Fără videoclipuri';

  @override
  String get collectionEmptyImages => 'Fără imagini';

  @override
  String get collectionEmptyGrantAccessButtonLabel => 'Acordare acces';

  @override
  String get collectionSelectSectionTooltip => 'Selectați secțiunea';

  @override
  String get collectionDeselectSectionTooltip => 'Deselectați secțiunea';

  @override
  String get drawerAboutButton => 'Despre';

  @override
  String get drawerSettingsButton => 'Setări';

  @override
  String get drawerCollectionAll => 'Toată colecția';

  @override
  String get drawerCollectionFavourites => 'Favorite';

  @override
  String get drawerCollectionImages => 'Imagini';

  @override
  String get drawerCollectionVideos => 'Videoclipuri';

  @override
  String get drawerCollectionAnimated => 'Animate';

  @override
  String get drawerCollectionMotionPhotos => 'Fotografii în mișcare';

  @override
  String get drawerCollectionPanoramas => 'Panorame';

  @override
  String get drawerCollectionRaws => 'Fotografii Raw';

  @override
  String get drawerCollectionSphericalVideos => 'Videoclipuri 360°';

  @override
  String get drawerAlbumPage => 'Albume';

  @override
  String get drawerCountryPage => 'Țări';

  @override
  String get drawerPlacePage => 'Locații';

  @override
  String get drawerTagPage => 'Etichete';

  @override
  String get sortByDate => 'După dată';

  @override
  String get sortByName => 'După nume';

  @override
  String get sortByItemCount => 'După numărul de elemente';

  @override
  String get sortBySize => 'După dimensiune';

  @override
  String get sortByAlbumFileName => 'După album și numele fișierului';

  @override
  String get sortByRating => 'După evaluare';

  @override
  String get sortByDuration => 'După durată';

  @override
  String get sortByPath => 'By path';

  @override
  String get sortOrderNewestFirst => 'Cele mai noi mai întâi';

  @override
  String get sortOrderOldestFirst => 'Cele mai vechi mai întâi';

  @override
  String get sortOrderAtoZ => 'De la A la Z';

  @override
  String get sortOrderZtoA => 'De la Z la A';

  @override
  String get sortOrderHighestFirst => 'Cele mai înalte întâi';

  @override
  String get sortOrderLowestFirst => 'Cele mai joase mai întâi';

  @override
  String get sortOrderLargestFirst => 'Cele mai mari întâi';

  @override
  String get sortOrderSmallestFirst => 'Cele mai mici întâi';

  @override
  String get sortOrderShortestFirst => 'Cel mai scurt mai întâi';

  @override
  String get sortOrderLongestFirst => 'Cel mai lung mai întâi';

  @override
  String get albumGroupTier => 'După nivel';

  @override
  String get albumGroupType => 'După tip';

  @override
  String get albumGroupVolume => 'După volumul de stocare';

  @override
  String get albumGroupNone => 'Nu se grupează';

  @override
  String get albumMimeTypeMixed => 'Amestecat';

  @override
  String get albumPickPageTitleCopy => 'Copiere în album';

  @override
  String get albumPickPageTitleExport => 'Exportare în album';

  @override
  String get albumPickPageTitleMove => 'Mutare în album';

  @override
  String get albumPickPageTitlePick => 'Alegeți albumul';

  @override
  String get albumCamera => 'Cameră';

  @override
  String get albumDownload => 'Descărcări';

  @override
  String get albumScreenshots => 'Capturi de ecran';

  @override
  String get albumScreenRecordings => 'Înregistrări de ecran';

  @override
  String get albumVideoCaptures => 'Capturi video';

  @override
  String get albumPageTitle => 'Albume';

  @override
  String get albumEmpty => 'Fără albume';

  @override
  String get createAlbumButtonLabel => 'CREARE';

  @override
  String get newFilterBanner => 'nou';

  @override
  String get countryPageTitle => 'Țări';

  @override
  String get countryEmpty => 'Fără țări';

  @override
  String get statePageTitle => 'State';

  @override
  String get stateEmpty => 'Nu există state';

  @override
  String get placePageTitle => 'Locații';

  @override
  String get placeEmpty => 'Nu există locații';

  @override
  String get tagPageTitle => 'Etichete';

  @override
  String get tagEmpty => 'Fără etichete';

  @override
  String get binPageTitle => 'Coș de reciclare';

  @override
  String get explorerPageTitle => 'Explorer';

  @override
  String get explorerActionSelectStorageVolume => 'Selectează spațiu de stocare';

  @override
  String get selectStorageVolumeDialogTitle => 'Selectează spațiu de stocare';

  @override
  String get searchCollectionFieldHint => 'Căutare colecție';

  @override
  String get searchRecentSectionTitle => 'Recente';

  @override
  String get searchDateSectionTitle => 'Dată';

  @override
  String get searchFormatSectionTitle => 'Formats';

  @override
  String get searchAlbumsSectionTitle => 'Albume';

  @override
  String get searchCountriesSectionTitle => 'Țări';

  @override
  String get searchStatesSectionTitle => 'State';

  @override
  String get searchPlacesSectionTitle => 'Locuri';

  @override
  String get searchTagsSectionTitle => 'Etichete';

  @override
  String get searchRatingSectionTitle => 'Evaluări';

  @override
  String get searchMetadataSectionTitle => 'Metadate';

  @override
  String get settingsPageTitle => 'Setări';

  @override
  String get settingsSystemDefault => 'Implicit sistem';

  @override
  String get settingsDefault => 'Implicit';

  @override
  String get settingsDisabled => 'Dezactivat';

  @override
  String get settingsAskEverytime => 'Întreabă de fiecare dată';

  @override
  String get settingsModificationWarningDialogMessage => 'Alte setări vor fi modificate.';

  @override
  String get settingsSearchFieldLabel => 'Căutare setări';

  @override
  String get settingsSearchEmpty => 'Nicio setare potrivită';

  @override
  String get settingsActionExport => 'Export';

  @override
  String get settingsActionExportDialogTitle => 'Export';

  @override
  String get settingsActionImport => 'Import';

  @override
  String get settingsActionImportDialogTitle => 'Import';

  @override
  String get appExportCovers => 'Coperți';

  @override
  String get appExportDynamicAlbums => 'Albume dinamice';

  @override
  String get appExportFavourites => 'Favorite';

  @override
  String get appExportSettings => 'Setări';

  @override
  String get settingsNavigationSectionTitle => 'Navigare';

  @override
  String get settingsHomeTile => 'Acasă';

  @override
  String get settingsHomeDialogTitle => 'Acasă';

  @override
  String get setHomeCustom => 'Personalizat';

  @override
  String get settingsShowBottomNavigationBar => 'Afișare bară de navigare din partea de jos';

  @override
  String get settingsKeepScreenOnTile => 'Se păstrează ecranul pornit';

  @override
  String get settingsKeepScreenOnDialogTitle => 'Se păstrează ecranul pornit';

  @override
  String get settingsDoubleBackExit => 'Atingeți „înapoi” de două ori pentru a ieși';

  @override
  String get settingsConfirmationTile => 'Dialogurile de confirmare';

  @override
  String get settingsConfirmationDialogTitle => 'Dialoguri de confirmare';

  @override
  String get settingsConfirmationBeforeDeleteItems => 'Întreabă înainte de a șterge articole pentru totdeauna';

  @override
  String get settingsConfirmationBeforeMoveToBinItems => 'Întreabă înainte de a muta obiecte în coșul de reciclare';

  @override
  String get settingsConfirmationBeforeMoveUndatedItems => 'Întreabă înainte de a muta articole fără dată';

  @override
  String get settingsConfirmationAfterMoveToBinItems => 'Afișare mesaj după mutarea elementelor în coșul de reciclare';

  @override
  String get settingsConfirmationVaultDataLoss => 'Afișare avertisment privind pierderile de date din seif';

  @override
  String get settingsNavigationDrawerTile => 'Meniu de navigare';

  @override
  String get settingsNavigationDrawerEditorPageTitle => 'Meniu de navigare';

  @override
  String get settingsNavigationDrawerBanner => 'Atingeți și țineți apăsat pentru a muta și a reordona elementele de meniu.';

  @override
  String get settingsNavigationDrawerTabTypes => 'Tipuri';

  @override
  String get settingsNavigationDrawerTabAlbums => 'Albume';

  @override
  String get settingsNavigationDrawerTabPages => 'Pagini';

  @override
  String get settingsNavigationDrawerAddAlbum => 'Adăugare album';

  @override
  String get settingsThumbnailSectionTitle => 'Miniaturi';

  @override
  String get settingsThumbnailOverlayTile => 'Suprapunere';

  @override
  String get settingsThumbnailOverlayPageTitle => 'Suprapunere';

  @override
  String get settingsThumbnailShowHdrIcon => 'Afișare pictogramă HDR';

  @override
  String get settingsThumbnailShowFavouriteIcon => 'Afișare pictogramă favorite';

  @override
  String get settingsThumbnailShowTagIcon => 'Afișare pictogramă etichetă';

  @override
  String get settingsThumbnailShowLocationIcon => 'Afișare pictogramă locație';

  @override
  String get settingsThumbnailShowMotionPhotoIcon => 'Afișare pictogramă fotografie în mișcare';

  @override
  String get settingsThumbnailShowRating => 'Afișare evaluare';

  @override
  String get settingsThumbnailShowRawIcon => 'Afișare pictogramă Raw';

  @override
  String get settingsThumbnailShowVideoDuration => 'Afișare durată videoclip';

  @override
  String get settingsCollectionQuickActionsTile => 'Acțiuni rapide';

  @override
  String get settingsCollectionQuickActionEditorPageTitle => 'Acțiuni rapide';

  @override
  String get settingsCollectionQuickActionTabBrowsing => 'Navigare';

  @override
  String get settingsCollectionQuickActionTabSelecting => 'Selectare';

  @override
  String get settingsCollectionBrowsingQuickActionEditorBanner => 'Atingeți și mențineți apăsat pentru a muta butoanele și a selecta acțiunile care sunt afișate atunci când navigați prin elemente.';

  @override
  String get settingsCollectionSelectionQuickActionEditorBanner => 'Atingeți și țineți apăsat pentru a muta butoanele și a selecta acțiunile care sunt afișate la selectarea elementelor.';

  @override
  String get settingsCollectionBurstPatternsTile => 'Modele de rafale';

  @override
  String get settingsCollectionBurstPatternsNone => 'Niciunul';

  @override
  String get settingsViewerSectionTitle => 'Vizualizator';

  @override
  String get settingsViewerGestureSideTapNext => 'Atingeți marginile ecranului pentru a afișa elementul anterior/următor';

  @override
  String get settingsViewerUseCutout => 'Utilizarea zonei de decupare';

  @override
  String get settingsViewerMaximumBrightness => 'Luminozitate maximă';

  @override
  String get settingsMotionPhotoAutoPlay => 'Redarea automată a fotografiilor în mișcare';

  @override
  String get settingsImageBackground => 'Fundal imagine';

  @override
  String get settingsViewerQuickActionsTile => 'Acțiuni rapide';

  @override
  String get settingsViewerQuickActionEditorPageTitle => 'Acțiuni rapide';

  @override
  String get settingsViewerQuickActionEditorBanner => 'Atingeți și țineți apăsat pentru a muta butoanele și a selecta acțiunile care sunt afișate în vizualizator.';

  @override
  String get settingsViewerQuickActionEditorDisplayedButtonsSectionTitle => 'Butoane afișate';

  @override
  String get settingsViewerQuickActionEditorAvailableButtonsSectionTitle => 'Butoane disponibile';

  @override
  String get settingsViewerQuickActionEmpty => 'Fără butoane';

  @override
  String get settingsViewerOverlayTile => 'Suprapunere';

  @override
  String get settingsViewerOverlayPageTitle => 'Suprapunere';

  @override
  String get settingsViewerShowOverlayOnOpening => 'Afișare la deschidere';

  @override
  String get settingsViewerShowHistogram => 'Afișare histogramă';

  @override
  String get settingsViewerShowMinimap => 'Afișare mini-hartă';

  @override
  String get settingsViewerShowInformation => 'Afișare informații';

  @override
  String get settingsViewerShowInformationSubtitle => 'Afișare titlu, dată, locație etc.';

  @override
  String get settingsViewerShowRatingTags => 'Afișare evaluare și etichete';

  @override
  String get settingsViewerShowShootingDetails => 'Afișare detalii de fotografiere';

  @override
  String get settingsViewerShowDescription => 'Afișare descriere';

  @override
  String get settingsViewerShowOverlayThumbnails => 'Afișare miniaturi';

  @override
  String get settingsViewerEnableOverlayBlurEffect => 'Efect de estompare';

  @override
  String get settingsViewerSlideshowTile => 'Prezentare diapozitive';

  @override
  String get settingsViewerSlideshowPageTitle => 'Prezentare diapozitive';

  @override
  String get settingsSlideshowRepeat => 'Repetare';

  @override
  String get settingsSlideshowShuffle => 'Amestecare';

  @override
  String get settingsSlideshowFillScreen => 'Se umple ecranul';

  @override
  String get settingsSlideshowAnimatedZoomEffect => 'Efect de zoom animat';

  @override
  String get settingsSlideshowTransitionTile => 'Tranziție';

  @override
  String get settingsSlideshowIntervalTile => 'Interval';

  @override
  String get settingsSlideshowVideoPlaybackTile => 'Redare video';

  @override
  String get settingsSlideshowVideoPlaybackDialogTitle => 'Redare video';

  @override
  String get settingsVideoPageTitle => 'Setări video';

  @override
  String get settingsVideoSectionTitle => 'Video';

  @override
  String get settingsVideoShowVideos => 'Afișare videoclipuri';

  @override
  String get settingsVideoPlaybackTile => 'Redare';

  @override
  String get settingsVideoPlaybackPageTitle => 'Redare';

  @override
  String get settingsVideoEnableHardwareAcceleration => 'Accelerare hardware';

  @override
  String get settingsVideoAutoPlay => 'Redare automată';

  @override
  String get settingsVideoLoopModeTile => 'Modul buclă';

  @override
  String get settingsVideoLoopModeDialogTitle => 'Mod buclă';

  @override
  String get settingsVideoResumptionModeTile => 'Reluare redare';

  @override
  String get settingsVideoResumptionModeDialogTitle => 'Reluare redare';

  @override
  String get settingsVideoBackgroundMode => 'Mod fundal';

  @override
  String get settingsVideoBackgroundModeDialogTitle => 'Mod fundal';

  @override
  String get settingsVideoControlsTile => 'Controale';

  @override
  String get settingsVideoControlsPageTitle => 'Controale';

  @override
  String get settingsVideoButtonsTile => 'Butoane';

  @override
  String get settingsVideoGestureDoubleTapTogglePlay => 'Atingeți de două ori pentru a reda/întrerupe';

  @override
  String get settingsVideoGestureSideDoubleTapSeek => 'Atingeți de două ori marginile ecranului pentru a trece înapoi/înainte';

  @override
  String get settingsVideoGestureVerticalDragBrightnessVolume => 'Glisați în sus sau în jos pentru a regla luminozitatea/volumul';

  @override
  String get settingsSubtitleThemeTile => 'Subtitrări';

  @override
  String get settingsSubtitleThemePageTitle => 'Subtitrări';

  @override
  String get settingsSubtitleThemeSample => 'Acesta este un exemplu.';

  @override
  String get settingsSubtitleThemeTextAlignmentTile => 'Alinierea textului';

  @override
  String get settingsSubtitleThemeTextAlignmentDialogTitle => 'Alinierea textului';

  @override
  String get settingsSubtitleThemeTextPositionTile => 'Poziția textului';

  @override
  String get settingsSubtitleThemeTextPositionDialogTitle => 'Poziția textului';

  @override
  String get settingsSubtitleThemeTextSize => 'Dimensiunea textului';

  @override
  String get settingsSubtitleThemeShowOutline => 'Afișarea conturului și a umbrei';

  @override
  String get settingsSubtitleThemeTextColor => 'Culoarea textului';

  @override
  String get settingsSubtitleThemeTextOpacity => 'Opacitatea textului';

  @override
  String get settingsSubtitleThemeBackgroundColor => 'Culoarea de fundal';

  @override
  String get settingsSubtitleThemeBackgroundOpacity => 'Opacitatea fundalului';

  @override
  String get settingsSubtitleThemeTextAlignmentLeft => 'Stânga';

  @override
  String get settingsSubtitleThemeTextAlignmentCenter => 'Centru';

  @override
  String get settingsSubtitleThemeTextAlignmentRight => 'Dreapta';

  @override
  String get settingsPrivacySectionTitle => 'Confidențialitate';

  @override
  String get settingsAllowInstalledAppAccess => 'Permiteți accesul la inventarul aplicațiilor';

  @override
  String get settingsAllowInstalledAppAccessSubtitle => 'Folosit pentru a îmbunătăți afișarea albumelor';

  @override
  String get settingsAllowErrorReporting => 'Permiteți raportarea anonimă a erorilor';

  @override
  String get settingsSaveSearchHistory => 'Salvare istoric căutări';

  @override
  String get settingsEnableBin => 'Utilizare coș de reciclare';

  @override
  String get settingsEnableBinSubtitle => 'Se păstrează elementele șterse timp de 30 de zile';

  @override
  String get settingsDisablingBinWarningDialogMessage => 'Articolele din coșul de reciclare vor fi șterse pentru totdeauna.';

  @override
  String get settingsAllowMediaManagement => 'Permiteți gestionarea media';

  @override
  String get settingsHiddenItemsTile => 'Articole ascunse';

  @override
  String get settingsHiddenItemsPageTitle => 'Articole ascunse';

  @override
  String get settingsHiddenFiltersBanner => 'Fotografiile și videoclipurile care corespund filtrelor ascunse nu vor apărea în colecție.';

  @override
  String get settingsHiddenFiltersEmpty => 'Fără filtre ascunse';

  @override
  String get settingsStorageAccessTile => 'Acces la stocare';

  @override
  String get settingsStorageAccessPageTitle => 'Acces la stocare';

  @override
  String get settingsStorageAccessBanner => 'Unele directoare necesită o acordare de acces explicită pentru a modifica fișierele din ele. Puteți consulta aici directoarele la care anterior ați dat acces.';

  @override
  String get settingsStorageAccessEmpty => 'Fără acordări de acces';

  @override
  String get settingsStorageAccessRevokeTooltip => 'Revocare';

  @override
  String get settingsAccessibilitySectionTitle => 'Accesibilitate';

  @override
  String get settingsRemoveAnimationsTile => 'Eliminați animațiile';

  @override
  String get settingsRemoveAnimationsDialogTitle => 'Eliminați animațiile';

  @override
  String get settingsTimeToTakeActionTile => 'Timpul pentru acțiune';

  @override
  String get settingsAccessibilityShowPinchGestureAlternatives => 'Afișare alternative de gesturi atingeri-multiple';

  @override
  String get settingsDisplaySectionTitle => 'Afișare';

  @override
  String get settingsThemeBrightnessTile => 'Temă';

  @override
  String get settingsThemeBrightnessDialogTitle => 'Temă';

  @override
  String get settingsThemeColorHighlights => 'Evidențieri de culoare';

  @override
  String get settingsThemeEnableDynamicColor => 'Culoare dinamică';

  @override
  String get settingsDisplayRefreshRateModeTile => 'Rata de reîmprospătare a ecranului';

  @override
  String get settingsDisplayRefreshRateModeDialogTitle => 'Rată de reîmprospătare';

  @override
  String get settingsDisplayUseTvInterface => 'Interfață Android TV';

  @override
  String get settingsLanguageSectionTitle => 'Limbă și formate';

  @override
  String get settingsLanguageTile => 'Limbă';

  @override
  String get settingsLanguagePageTitle => 'Limbă';

  @override
  String get settingsCoordinateFormatTile => 'Formatul coordonatelor';

  @override
  String get settingsCoordinateFormatDialogTitle => 'Formatul coordonatelor';

  @override
  String get settingsUnitSystemTile => 'Unități';

  @override
  String get settingsUnitSystemDialogTitle => 'Unități';

  @override
  String get settingsForceWesternArabicNumeralsTile => 'Cifre arabe forțat';

  @override
  String get settingsScreenSaverPageTitle => 'Economizor de ecran';

  @override
  String get settingsWidgetPageTitle => 'Ramă foto';

  @override
  String get settingsWidgetShowOutline => 'Contur';

  @override
  String get settingsWidgetOpenPage => 'Când atingeți widget-ul';

  @override
  String get settingsWidgetDisplayedItem => 'Element afișat';

  @override
  String get settingsCollectionTile => 'Colecție';

  @override
  String get statsPageTitle => 'Statistici';

  @override
  String statsWithGps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articole cu locație',
      one: '1 articol cu locație',
    );
    return '$_temp0';
  }

  @override
  String get statsTopCountriesSectionTitle => 'Țări de top';

  @override
  String get statsTopStatesSectionTitle => 'Statele de top';

  @override
  String get statsTopPlacesSectionTitle => 'Locuri de top';

  @override
  String get statsTopTagsSectionTitle => 'Etichete de top';

  @override
  String get statsTopAlbumsSectionTitle => 'Albume de top';

  @override
  String get viewerOpenPanoramaButtonLabel => 'DESCHIDERE PANORAMĂ';

  @override
  String get viewerSetWallpaperButtonLabel => 'SETARE CA FUNDAL';

  @override
  String get viewerErrorUnknown => 'Hopa!';

  @override
  String get viewerErrorDoesNotExist => 'Fișierul nu mai există.';

  @override
  String get viewerInfoPageTitle => 'Informații';

  @override
  String get viewerInfoBackToViewerTooltip => 'Înapoi la vizualizator';

  @override
  String get viewerInfoUnknown => 'necunoscut';

  @override
  String get viewerInfoLabelDescription => 'Descriere';

  @override
  String get viewerInfoLabelTitle => 'Titlu';

  @override
  String get viewerInfoLabelDate => 'Dată';

  @override
  String get viewerInfoLabelResolution => 'Rezoluție';

  @override
  String get viewerInfoLabelSize => 'Dimensiune';

  @override
  String get viewerInfoLabelUri => 'URI';

  @override
  String get viewerInfoLabelPath => 'Cale';

  @override
  String get viewerInfoLabelDuration => 'Durată';

  @override
  String get viewerInfoLabelOwner => 'Proprietar';

  @override
  String get viewerInfoLabelCoordinates => 'Coordonate';

  @override
  String get viewerInfoLabelAddress => 'Adresă';

  @override
  String get mapStyleDialogTitle => 'Stil hartă';

  @override
  String get mapStyleTooltip => 'Selectați stilul hărții';

  @override
  String get mapZoomInTooltip => 'Mărire';

  @override
  String get mapZoomOutTooltip => 'Micșorare';

  @override
  String get mapPointNorthUpTooltip => 'Îndreptați spre nord în sus';

  @override
  String get mapAttributionOsmData => 'Datele hărții © [OpenStreetMap](https://www.openstreetmap.org/copyright) contributori';

  @override
  String get mapAttributionOsmLiberty => 'Plăci de la [OpenMapTiles](https://www.openmaptiles.org/), [CC BY](http://creativecommons.org/licenses/by/4.0) • Găzduit de [OSM Americana](https://tile.ourmap.us)';

  @override
  String get mapAttributionOpenTopoMap => '[SRTM](https://www.earthdata.nasa.gov/sensors/srtm) | Plăci de la [OpenTopoMap](https://opentopomap.org/), [CC BY-SA](https://creativecommons.org/licenses/by-sa/3.0/)';

  @override
  String get mapAttributionOsmHot => 'Plăci de la [HOT](https://www.hotosm.org/) • Găzduit de [OSM France](https://openstreetmap.fr/)';

  @override
  String get mapAttributionStamen => 'Plăci de la [Stamen Design](https://stamen.com), [CC BY 3.0](https://creativecommons.org/licenses/by/3.0)';

  @override
  String get openMapPageTooltip => 'Vizualizare pe pagina hărții';

  @override
  String get mapEmptyRegion => 'Nu există imagini în această regiune';

  @override
  String get viewerInfoOpenEmbeddedFailureFeedback => 'Nu s-a reușit extragerea datelor încorporate';

  @override
  String get viewerInfoOpenLinkText => 'Deschidere';

  @override
  String get viewerInfoViewXmlLinkText => 'Vizualizare XML';

  @override
  String get viewerInfoSearchFieldLabel => 'Căutare metadate';

  @override
  String get viewerInfoSearchEmpty => 'Nu există chei potrivite';

  @override
  String get viewerInfoSearchSuggestionDate => 'Data și ora';

  @override
  String get viewerInfoSearchSuggestionDescription => 'Descriere';

  @override
  String get viewerInfoSearchSuggestionDimensions => 'Dimensiuni';

  @override
  String get viewerInfoSearchSuggestionResolution => 'Rezoluție';

  @override
  String get viewerInfoSearchSuggestionRights => 'Drepturi';

  @override
  String get wallpaperUseScrollEffect => 'Utilizați efectul de derulare pe ecranul de pornire';

  @override
  String get tagEditorPageTitle => 'Editare etichete';

  @override
  String get tagEditorPageNewTagFieldLabel => 'Etichetă nouă';

  @override
  String get tagEditorPageAddTagTooltip => 'Adăugare etichetă';

  @override
  String get tagEditorSectionRecent => 'Recente';

  @override
  String get tagEditorSectionPlaceholders => 'Substituenți';

  @override
  String get tagEditorDiscardDialogMessage => 'Dorești să renunți la modificări?';

  @override
  String get tagPlaceholderCountry => 'Țară';

  @override
  String get tagPlaceholderState => 'Stat';

  @override
  String get tagPlaceholderPlace => 'Loc';

  @override
  String get panoramaEnableSensorControl => 'Activați controlul tactil';

  @override
  String get panoramaDisableSensorControl => 'Dezactivați controlul tactil';

  @override
  String get sourceViewerPageTitle => 'Sursă';

  @override
  String get filePickerShowHiddenFiles => 'Afișare fișiere ascunse';

  @override
  String get filePickerDoNotShowHiddenFiles => 'Nu se afișează fișiere ascunse';

  @override
  String get filePickerOpenFrom => 'Deschidere din';

  @override
  String get filePickerNoItems => 'Fără articole';

  @override
  String get filePickerUseThisFolder => 'Utilizați acest dosar';
}
