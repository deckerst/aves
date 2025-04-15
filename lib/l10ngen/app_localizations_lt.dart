// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Lithuanian (`lt`).
class AppLocalizationsLt extends AppLocalizations {
  AppLocalizationsLt([String locale = 'lt']) : super(locale);

  @override
  String get appName => 'Aves';

  @override
  String get welcomeMessage => 'Sveiki atvykę į Aves';

  @override
  String get welcomeOptional => 'Neprivaloma';

  @override
  String get welcomeTermsToggle => 'Sutinku su taisyklėmis ir sąlygomis';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementų',
      few: '$count elementai',
      one: '$count elementas',
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
      other: '$countString stulpeliai',
      one: '$countString stulpelis',
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
      other: '$countString sekundžių',
      few: '$countString sekundės',
      one: '$countString sekundė',
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
      other: '$countString minučių',
      few: '$countString minutės',
      one: '$countString minutė',
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
      other: '$countString dienų',
      few: '$countString dienos',
      one: '$countString diena',
    );
    return '$_temp0';
  }

  @override
  String focalLength(String length) {
    return '$length mm';
  }

  @override
  String get applyButtonLabel => 'TAIKYTI';

  @override
  String get deleteButtonLabel => 'IŠTRINTI';

  @override
  String get nextButtonLabel => 'TOLIAU';

  @override
  String get showButtonLabel => 'RODYTI';

  @override
  String get hideButtonLabel => 'SLĖPTI';

  @override
  String get continueButtonLabel => 'TĘSTI';

  @override
  String get saveCopyButtonLabel => 'IŠSAUGOTI KOPIJĄ';

  @override
  String get applyTooltip => 'Taikyti';

  @override
  String get cancelTooltip => 'Atšaukti';

  @override
  String get changeTooltip => 'Keisti';

  @override
  String get clearTooltip => 'Išvalyti';

  @override
  String get previousTooltip => 'Ankstesnis';

  @override
  String get nextTooltip => 'Toliau';

  @override
  String get showTooltip => 'Rodyti';

  @override
  String get hideTooltip => 'Slėpti';

  @override
  String get actionRemove => 'Pašalinti';

  @override
  String get resetTooltip => 'Atstatyti';

  @override
  String get saveTooltip => 'Išsaugoti';

  @override
  String get stopTooltip => 'Stabdyti';

  @override
  String get pickTooltip => 'Pasirinkti';

  @override
  String get doubleBackExitMessage => 'Dar kartą bakstelėkite „atgal“, kad išeitumėte.';

  @override
  String get doNotAskAgain => 'Daugiau neklausti';

  @override
  String get sourceStateLoading => 'Įkeliama';

  @override
  String get sourceStateCataloguing => 'Kataloguojama';

  @override
  String get sourceStateLocatingCountries => 'Aptinkamos šalys';

  @override
  String get sourceStateLocatingPlaces => 'Aptinkamos vietos';

  @override
  String get chipActionDelete => 'Išrinti';

  @override
  String get chipActionRemove => 'Remove';

  @override
  String get chipActionShowCollection => 'Rodyti kolekcijoje';

  @override
  String get chipActionGoToAlbumPage => 'Rodyti albumuose';

  @override
  String get chipActionGoToCountryPage => 'Rodyti šalyse';

  @override
  String get chipActionGoToPlacePage => 'Rodyti Vietose';

  @override
  String get chipActionGoToTagPage => 'Rodyti žymose';

  @override
  String get chipActionGoToExplorerPage => 'Rodyti Naršyklėje';

  @override
  String get chipActionDecompose => 'Split';

  @override
  String get chipActionFilterOut => 'Išfiltruoti';

  @override
  String get chipActionFilterIn => 'Filtruoti';

  @override
  String get chipActionHide => 'Slėpti';

  @override
  String get chipActionLock => 'Rakinti';

  @override
  String get chipActionPin => 'Prisegti viršuje';

  @override
  String get chipActionUnpin => 'Atsegti nuo viršaus';

  @override
  String get chipActionRename => 'Pervadinti';

  @override
  String get chipActionSetCover => 'Nustatyti viršelį';

  @override
  String get chipActionShowCountryStates => 'Rodyti valstybes';

  @override
  String get chipActionCreateAlbum => 'Sukurti albumą';

  @override
  String get chipActionCreateVault => 'Kurti saugyklą';

  @override
  String get chipActionConfigureVault => 'Konfigūruoti saugyklą';

  @override
  String get entryActionCopyToClipboard => 'Kopijuoti į iškarpinę';

  @override
  String get entryActionDelete => 'Išrinti';

  @override
  String get entryActionConvert => 'Konvertuoti';

  @override
  String get entryActionExport => 'Eksportuoti';

  @override
  String get entryActionInfo => 'Informacija';

  @override
  String get entryActionRename => 'Pervadinti';

  @override
  String get entryActionRestore => 'Atkurti';

  @override
  String get entryActionRotateCCW => 'Pasukti prieš laikrodžio rodyklę';

  @override
  String get entryActionRotateCW => 'Pasukti pagal laikrodžio rodyklę';

  @override
  String get entryActionFlip => 'Apversti horizontaliai';

  @override
  String get entryActionPrint => 'Spausdinti';

  @override
  String get entryActionShare => 'Dalintis';

  @override
  String get entryActionShareImageOnly => 'Bendrinti tik paveikslėlį';

  @override
  String get entryActionShareVideoOnly => 'Bendrinti tik vaizdo įrašą';

  @override
  String get entryActionViewSource => 'Peržiūrėti šaltinį';

  @override
  String get entryActionShowGeoTiffOnMap => 'Rodyti kaip žemėlapio uždangą';

  @override
  String get entryActionConvertMotionPhotoToStillImage => 'Konvertuoti į nejudantį paveikslėlį';

  @override
  String get entryActionViewMotionPhotoVideo => 'Atidaryti vaizdo įrašą';

  @override
  String get entryActionEdit => 'Redaguoti';

  @override
  String get entryActionOpen => 'Atidaryti naudojant';

  @override
  String get entryActionSetAs => 'Nustatyti kaip';

  @override
  String get entryActionCast => 'Transliuoti';

  @override
  String get entryActionOpenMap => 'Rodyti žemėlapio programėlėje';

  @override
  String get entryActionRotateScreen => 'Pasukti ekraną';

  @override
  String get entryActionAddFavourite => 'Pridėti prie mėgstamiausių';

  @override
  String get entryActionRemoveFavourite => 'Pašalinti iš mėgstamiausių';

  @override
  String get videoActionCaptureFrame => 'Užfiksuoti kadrą';

  @override
  String get videoActionMute => 'Nutildyti';

  @override
  String get videoActionUnmute => 'Įjungti garsą';

  @override
  String get videoActionPause => 'Pristabdyti';

  @override
  String get videoActionPlay => 'Groti';

  @override
  String get videoActionReplay10 => 'Prasukti 10 sekundžių atgal';

  @override
  String get videoActionSkip10 => 'Prasukti 10 sekundžių į priekį';

  @override
  String get videoActionShowPreviousFrame => 'Show previous frame';

  @override
  String get videoActionShowNextFrame => 'Show next frame';

  @override
  String get videoActionSelectStreams => 'Pasirinkti takelius';

  @override
  String get videoActionSetSpeed => 'Atkūrimo greitis';

  @override
  String get videoActionABRepeat => 'A-B kartoti';

  @override
  String get videoRepeatActionSetStart => 'Nustatyti pradžią';

  @override
  String get videoRepeatActionSetEnd => 'Nustatyti pabaigą';

  @override
  String get viewerActionSettings => 'Nustatymai';

  @override
  String get viewerActionLock => 'Užrakinti peržiūrą';

  @override
  String get viewerActionUnlock => 'Atrakinti peržiūrą';

  @override
  String get slideshowActionResume => 'Tęsti';

  @override
  String get slideshowActionShowInCollection => 'Rodyti kolekcijoje';

  @override
  String get entryInfoActionEditDate => 'Redaguoti datą ir laiką';

  @override
  String get entryInfoActionEditLocation => 'Redaguoti vietą';

  @override
  String get entryInfoActionEditTitleDescription => 'Redaguoti pavadinimą ir aprašymą';

  @override
  String get entryInfoActionEditRating => 'Redaguoti įvertinimą';

  @override
  String get entryInfoActionEditTags => 'Redaguoti žymas';

  @override
  String get entryInfoActionRemoveMetadata => 'Pašalinti metaduomenis';

  @override
  String get entryInfoActionExportMetadata => 'Eksportuoti metaduomenis';

  @override
  String get entryInfoActionRemoveLocation => 'Pašalinti vietą';

  @override
  String get editorActionTransform => 'Transformuoti';

  @override
  String get editorTransformCrop => 'Apkirpti';

  @override
  String get editorTransformRotate => 'Pasukti';

  @override
  String get cropAspectRatioFree => 'Laisvai';

  @override
  String get cropAspectRatioOriginal => 'Originalas';

  @override
  String get cropAspectRatioSquare => 'Kvadratas';

  @override
  String get filterAspectRatioLandscapeLabel => 'Gulsčias';

  @override
  String get filterAspectRatioPortraitLabel => 'Portretas';

  @override
  String get filterBinLabel => 'Šiukšlinė';

  @override
  String get filterFavouriteLabel => 'Mėgstamiausi';

  @override
  String get filterNoDateLabel => 'Be datos';

  @override
  String get filterNoAddressLabel => 'Nėra adreso';

  @override
  String get filterLocatedLabel => 'Lokalizuota';

  @override
  String get filterNoLocationLabel => 'Be vietovės';

  @override
  String get filterNoRatingLabel => 'Neįvertinta';

  @override
  String get filterTaggedLabel => 'Pažymėti';

  @override
  String get filterNoTagLabel => 'Nepažymėta';

  @override
  String get filterNoTitleLabel => 'Be pavadinimo';

  @override
  String get filterOnThisDayLabel => 'Šią dieną';

  @override
  String get filterRecentlyAddedLabel => 'Neseniai pridėta';

  @override
  String get filterRatingRejectedLabel => 'Atmesta';

  @override
  String get filterTypeAnimatedLabel => 'Animuota';

  @override
  String get filterTypeMotionPhotoLabel => 'Judanti nuotrauka';

  @override
  String get filterTypePanoramaLabel => 'Panorama';

  @override
  String get filterTypeRawLabel => 'Raw';

  @override
  String get filterTypeSphericalVideoLabel => '360° vaizdo įrašas';

  @override
  String get filterTypeGeotiffLabel => 'GeoTIFF';

  @override
  String get filterMimeImageLabel => 'Paveikslėlis';

  @override
  String get filterMimeVideoLabel => 'Vaizdo įrašas';

  @override
  String get accessibilityAnimationsRemove => 'Nerodyti ekrano efektų';

  @override
  String get accessibilityAnimationsKeep => 'Išlaikyti ekrano efektus';

  @override
  String get albumTierNew => 'Nauji';

  @override
  String get albumTierPinned => 'Prisegti';

  @override
  String get albumTierSpecial => 'Bendri';

  @override
  String get albumTierApps => 'Programėlių';

  @override
  String get albumTierVaults => 'Seifai';

  @override
  String get albumTierDynamic => 'Dynamic';

  @override
  String get albumTierRegular => 'Kiti';

  @override
  String get coordinateFormatDms => 'DMS';

  @override
  String get coordinateFormatDdm => 'DDM';

  @override
  String get coordinateFormatDecimal => 'Dešimtainiai laipsniai';

  @override
  String coordinateDms(String coordinate, String direction) {
    return '$coordinate $direction';
  }

  @override
  String get coordinateDmsNorth => 'Š';

  @override
  String get coordinateDmsSouth => 'P';

  @override
  String get coordinateDmsEast => 'R';

  @override
  String get coordinateDmsWest => 'V';

  @override
  String get displayRefreshRatePreferHighest => 'Aukščiausias dažnis';

  @override
  String get displayRefreshRatePreferLowest => 'Žemiausias dažnis';

  @override
  String get keepScreenOnNever => 'Niekada';

  @override
  String get keepScreenOnVideoPlayback => 'Vaizdo įrašo atkūrimo metu';

  @override
  String get keepScreenOnViewerOnly => 'Tik peržiūros puslapiui';

  @override
  String get keepScreenOnAlways => 'Visada';

  @override
  String get lengthUnitPixel => 'px';

  @override
  String get lengthUnitPercent => '%';

  @override
  String get mapStyleGoogleNormal => 'Google Maps';

  @override
  String get mapStyleGoogleHybrid => 'Google Maps (hibridinis)';

  @override
  String get mapStyleGoogleTerrain => 'Google Maps (reljefinis)';

  @override
  String get mapStyleOsmLiberty => 'OSM Liberty';

  @override
  String get mapStyleOpenTopoMap => 'OpenTopoMap';

  @override
  String get mapStyleOsmHot => 'Humanitarinis OSM';

  @override
  String get mapStyleStamenWatercolor => 'Stamen Watercolor (akvarelė)';

  @override
  String get maxBrightnessNever => 'Niekada';

  @override
  String get maxBrightnessAlways => 'Visada';

  @override
  String get nameConflictStrategyRename => 'Pervadinti';

  @override
  String get nameConflictStrategyReplace => 'Pakeisti';

  @override
  String get nameConflictStrategySkip => 'Praleisti';

  @override
  String get overlayHistogramNone => 'Jokios';

  @override
  String get overlayHistogramRGB => 'RGB';

  @override
  String get overlayHistogramLuminance => 'Skaistis';

  @override
  String get subtitlePositionTop => 'Viršuje';

  @override
  String get subtitlePositionBottom => 'Apačioje';

  @override
  String get themeBrightnessLight => 'Šviesi';

  @override
  String get themeBrightnessDark => 'Tamsi';

  @override
  String get themeBrightnessBlack => 'Juoda';

  @override
  String get unitSystemMetric => 'Metriniai';

  @override
  String get unitSystemImperial => 'Imperiniai';

  @override
  String get vaultLockTypePattern => 'Piešinys';

  @override
  String get vaultLockTypePin => 'PIN';

  @override
  String get vaultLockTypePassword => 'Slaptažodis';

  @override
  String get settingsVideoEnablePip => 'Paveikslas paveiksle';

  @override
  String get videoControlsPlayOutside => 'Atidaryti su kitu grotuvu';

  @override
  String get videoLoopModeNever => 'Niekada';

  @override
  String get videoLoopModeShortOnly => 'Tik trumpus vaizdo įrašus';

  @override
  String get videoLoopModeAlways => 'Visada';

  @override
  String get videoPlaybackSkip => 'Praleisti';

  @override
  String get videoPlaybackMuted => 'Groti išjungus garsą';

  @override
  String get videoPlaybackWithSound => 'Groti su garsu';

  @override
  String get videoResumptionModeNever => 'Niekada';

  @override
  String get videoResumptionModeAlways => 'Visada';

  @override
  String get viewerTransitionSlide => 'Skaidrės';

  @override
  String get viewerTransitionParallax => 'Paralaksas';

  @override
  String get viewerTransitionFade => 'Išblukimas';

  @override
  String get viewerTransitionZoomIn => 'Priartinimas';

  @override
  String get viewerTransitionNone => 'Joks';

  @override
  String get wallpaperTargetHome => 'Pagrindinis ekranas';

  @override
  String get wallpaperTargetLock => 'Užrakinimo ekranas';

  @override
  String get wallpaperTargetHomeLock => 'Pagrindinis ir užrakinimo ekranai';

  @override
  String get widgetDisplayedItemRandom => 'Atsitiktinė';

  @override
  String get widgetDisplayedItemMostRecent => 'Naujausia';

  @override
  String get widgetOpenPageHome => 'Atidaryti pagrindinį puslapį';

  @override
  String get widgetOpenPageCollection => 'Atidaryti kolekciją';

  @override
  String get widgetOpenPageViewer => 'Atidaryti peržiūrą';

  @override
  String get widgetTapUpdateWidget => 'Atnaujinti valdiklį';

  @override
  String get storageVolumeDescriptionFallbackPrimary => 'Vidinė atmintis';

  @override
  String get storageVolumeDescriptionFallbackNonPrimary => 'SD kortelė';

  @override
  String get rootDirectoryDescription => 'šakninis katalogas';

  @override
  String otherDirectoryDescription(String name) {
    return '„$name“ katalogas';
  }

  @override
  String storageAccessDialogMessage(String directory, String volume) {
    return 'Kitame ekrane pasirinkite $directory iš „$volume“, kad suteiktumėte šiai programėlei prieigą prie jo.';
  }

  @override
  String restrictedAccessDialogMessage(String directory, String volume) {
    return 'Šiai programai neleidžiama keisti „$volume“ $directory failų.\n\nNorėdami perkelti elementus į kitą katalogą, naudokite iš anksto įdiegtą failų tvarkyklę arba galerijos programėlę.';
  }

  @override
  String notEnoughSpaceDialogMessage(String neededSize, String freeSize, String volume) {
    return 'Šiai operacijai atlikti reikia $neededSize laisvos vietos „$volume“, tačiau liko tik $freeSize.';
  }

  @override
  String get missingSystemFilePickerDialogMessage => 'Trūksta sistemos failų rinkiklio arba jis išjungtas. Įgalinkite jį ir bandykite dar kartą.';

  @override
  String unsupportedTypeDialogMessage(int count, String types) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ši operacija nepalaikoma šių tipų elementams: $types.',
      one: 'Ši operacija nepalaikoma šio tipo elementams: $types.',
    );
    return '$_temp0';
  }

  @override
  String get nameConflictDialogSingleSourceMessage => 'Kai kurie failai paskirties aplanke turi tą patį pavadinimą.';

  @override
  String get nameConflictDialogMultipleSourceMessage => 'Kai kurie failai turi tą patį pavadinimą.';

  @override
  String get addShortcutDialogLabel => 'Nuorodos etiketė';

  @override
  String get addShortcutButtonLabel => 'PRIDĖTI';

  @override
  String get noMatchingAppDialogMessage => 'Nėra programėlių, kurios galėtų tai padaryti.';

  @override
  String binEntriesConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Perkelti šiuos $count elementus į šiukšlinę?',
      one: 'Perkelti šį elementą į šiukšlinę?',
    );
    return '$_temp0';
  }

  @override
  String deleteEntriesConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ištrinti šiuos $count elementus?',
      one: 'Ištrinti šį elementą?',
    );
    return '$_temp0';
  }

  @override
  String get moveUndatedConfirmationDialogMessage => 'Išsaugoti elemento datas prieš tęsiant?';

  @override
  String get moveUndatedConfirmationDialogSetDate => 'Išsaugoti datas';

  @override
  String videoResumeDialogMessage(String time) {
    return 'Ar norite tęsti grojimą nuo $time?';
  }

  @override
  String get videoStartOverButtonLabel => 'PRADĖTI IŠ NAUJO';

  @override
  String get videoResumeButtonLabel => 'TĘSTI';

  @override
  String get setCoverDialogLatest => 'Naujausias elementas';

  @override
  String get setCoverDialogAuto => 'Automatinis';

  @override
  String get setCoverDialogCustom => 'Pasirinktinis';

  @override
  String get hideFilterConfirmationDialogMessage => 'Atitinkančios nuotraukos ir vaizdo įrašai bus paslėpti jūsų kolekcijoje. Galite juos vėl parodyti „Privatumo“ nustatymuose.\n\nAr tikrai norite juos paslėpti?';

  @override
  String get newAlbumDialogTitle => 'Naujas albumas';

  @override
  String get newAlbumDialogNameLabel => 'Albumo pavadinimas';

  @override
  String get newAlbumDialogAlbumAlreadyExistsHelper => 'Album already exists';

  @override
  String get newAlbumDialogNameLabelAlreadyExistsHelper => 'Katalogas jau egzistuoja';

  @override
  String get newAlbumDialogStorageLabel => 'Saugykla:';

  @override
  String get newDynamicAlbumDialogTitle => 'New Dynamic Album';

  @override
  String get dynamicAlbumAlreadyExists => 'Dynamic album already exists';

  @override
  String get newVaultWarningDialogMessage => 'Daiktai saugyklose yra prieinami tik šiai programėlei ir jokiom kitom.\n\nJei pašalinsite šią programą arba išvalysite jos duomenis, jūs prarasite visus šiuos daiktus.';

  @override
  String get newVaultDialogTitle => 'Nauja saugykla';

  @override
  String get configureVaultDialogTitle => 'Konfigūruoti saugyklą';

  @override
  String get vaultDialogLockModeWhenScreenOff => 'Užrakinti kai ekranas išsijungia';

  @override
  String get vaultDialogLockTypeLabel => 'Užrakto tipas';

  @override
  String get patternDialogEnter => 'Įveskite paveikslą';

  @override
  String get patternDialogConfirm => 'Konfigūruoti paveikslą';

  @override
  String get pinDialogEnter => 'Įveskite PIN';

  @override
  String get pinDialogConfirm => 'Konfigūruoti PIN';

  @override
  String get passwordDialogEnter => 'Įveskite slaptažodį';

  @override
  String get passwordDialogConfirm => 'Patvirtinti slaptažodį';

  @override
  String get authenticateToConfigureVault => 'Autentifikuoti, kad konfigūruoti saugyklą';

  @override
  String get authenticateToUnlockVault => 'Autentifikuoti, kad atrakinti saugyklą';

  @override
  String get vaultBinUsageDialogMessage => 'Kai kurios saugyklos naudoja šiukšlių dėžę.';

  @override
  String get renameAlbumDialogLabel => 'Naujas pavadinimas';

  @override
  String get renameAlbumDialogLabelAlreadyExistsHelper => 'Katalogas jau egzistuoja';

  @override
  String get renameEntrySetPageTitle => 'Pervadinti';

  @override
  String get renameEntrySetPagePatternFieldLabel => 'Pavadinimų suteikimo modelis';

  @override
  String get renameEntrySetPageInsertTooltip => 'Įterpti lauką';

  @override
  String get renameEntrySetPagePreviewSectionTitle => 'Peržiūra';

  @override
  String get renameProcessorCounter => 'Skaitiklis';

  @override
  String get renameProcessorHash => 'Maiša';

  @override
  String get renameProcessorName => 'Pavadinimas';

  @override
  String deleteSingleAlbumConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ištrinti šį albumą ir jo $count elementus?',
      one: 'Ištrinti šį albumą ir jo elementą?',
    );
    return '$_temp0';
  }

  @override
  String deleteMultiAlbumConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ištrinti šiuos albumus ir jų $count elementus?',
      one: 'Ištrinti šiuos albumus ir jų elementą?',
    );
    return '$_temp0';
  }

  @override
  String get exportEntryDialogFormat => 'Formatas:';

  @override
  String get exportEntryDialogWidth => 'Plotis';

  @override
  String get exportEntryDialogHeight => 'Aukštis';

  @override
  String get exportEntryDialogQuality => 'Kokybė';

  @override
  String get exportEntryDialogWriteMetadata => 'Įrašyti metainformaciją';

  @override
  String get renameEntryDialogLabel => 'Naujas pavadinimas';

  @override
  String get editEntryDialogCopyFromItem => 'Kopijuoti iš kito elemento';

  @override
  String get editEntryDialogTargetFieldsHeader => 'Keičiami laukai';

  @override
  String get editEntryDateDialogTitle => 'Data ir laikas';

  @override
  String get editEntryDateDialogSetCustom => 'Nustatyti pasirinktinę datą';

  @override
  String get editEntryDateDialogCopyField => 'Kopijuoti iš kitos datos';

  @override
  String get editEntryDateDialogExtractFromTitle => 'Ištraukti iš pavadinimo';

  @override
  String get editEntryDateDialogShift => 'Pastumti';

  @override
  String get editEntryDateDialogSourceFileModifiedDate => 'Failo pakeitimo data';

  @override
  String get durationDialogHours => 'Valandos';

  @override
  String get durationDialogMinutes => 'Minutės';

  @override
  String get durationDialogSeconds => 'Sekundės';

  @override
  String get editEntryLocationDialogTitle => 'Vieta';

  @override
  String get editEntryLocationDialogSetCustom => 'Nustatyti pasirinktinę vietą';

  @override
  String get editEntryLocationDialogChooseOnMap => 'Pasirinkti žemėlapyje';

  @override
  String get editEntryLocationDialogImportGpx => 'Import GPX';

  @override
  String get editEntryLocationDialogLatitude => 'Platuma';

  @override
  String get editEntryLocationDialogLongitude => 'Ilguma';

  @override
  String get editEntryLocationDialogTimeShift => 'Time shift';

  @override
  String get locationPickerUseThisLocationButton => 'Naudoti šią vietą';

  @override
  String get editEntryRatingDialogTitle => 'Įvertinimas';

  @override
  String get removeEntryMetadataDialogTitle => 'Metaduomenų šalinimas';

  @override
  String get removeEntryMetadataDialogAll => 'All';

  @override
  String get removeEntryMetadataDialogMore => 'Daugiau';

  @override
  String get removeEntryMetadataMotionPhotoXmpWarningDialogMessage => 'Norint paleisti vaizdo įrašą judančioje nuotraukoje, reikalingas XMP.\n\nAr tikrai norite jį pašalinti?';

  @override
  String get videoSpeedDialogLabel => 'Atkūrimo greitis';

  @override
  String get videoStreamSelectionDialogVideo => 'Vaizdas';

  @override
  String get videoStreamSelectionDialogAudio => 'Garsas';

  @override
  String get videoStreamSelectionDialogText => 'Subtitrai';

  @override
  String get videoStreamSelectionDialogOff => 'Išjungti';

  @override
  String get videoStreamSelectionDialogTrack => 'Takelis';

  @override
  String get videoStreamSelectionDialogNoSelection => 'Kitų takelių nėra.';

  @override
  String get genericSuccessFeedback => 'Atlikta!';

  @override
  String get genericFailureFeedback => 'Nepavyko';

  @override
  String get genericDangerWarningDialogMessage => 'Ar tikrai?';

  @override
  String get tooManyItemsErrorDialogMessage => 'Bandykite vėl su mažiau daiktų.';

  @override
  String get menuActionConfigureView => 'Peržiūrėti';

  @override
  String get menuActionSelect => 'Pasirinkti';

  @override
  String get menuActionSelectAll => 'Pasirinkti viską';

  @override
  String get menuActionSelectNone => 'Nesirinkti nieko';

  @override
  String get menuActionMap => 'Žemėlapis';

  @override
  String get menuActionSlideshow => 'Skaidrių demonstravimas';

  @override
  String get menuActionStats => 'Statistika';

  @override
  String get viewDialogSortSectionTitle => 'Rikiuoti';

  @override
  String get viewDialogGroupSectionTitle => 'Grupuoti';

  @override
  String get viewDialogLayoutSectionTitle => 'Išdėstymas';

  @override
  String get viewDialogReverseSortOrder => 'Atvirkštinė rikiavimo tvarka';

  @override
  String get tileLayoutMosaic => 'Mozaika';

  @override
  String get tileLayoutGrid => 'Tinklelis';

  @override
  String get tileLayoutList => 'Sąrašas';

  @override
  String get castDialogTitle => 'Transliavimo įrenginiai';

  @override
  String get coverDialogTabCover => 'Viršelis';

  @override
  String get coverDialogTabApp => 'Programėlė';

  @override
  String get coverDialogTabColor => 'Spalva';

  @override
  String get appPickDialogTitle => 'Pasirinkite programėlę';

  @override
  String get appPickDialogNone => 'Jokia';

  @override
  String get aboutPageTitle => 'Apie';

  @override
  String get aboutLinkLicense => 'Licencija';

  @override
  String get aboutLinkPolicy => 'Privatumo politika';

  @override
  String get aboutBugSectionTitle => 'Pranešimas apie klaidą';

  @override
  String get aboutBugSaveLogInstruction => 'Išsaugokite programėlės žurnalus į failą';

  @override
  String get aboutBugCopyInfoInstruction => 'Nukopijuokite sistemos informaciją';

  @override
  String get aboutBugCopyInfoButton => 'Kopijuoti';

  @override
  String get aboutBugReportInstruction => 'Praneškite „GitHub“ kartu su žurnalais ir sistemos informacija';

  @override
  String get aboutBugReportButton => 'Pranešti';

  @override
  String get aboutDataUsageSectionTitle => 'Duomenų naudojimas';

  @override
  String get aboutDataUsageData => 'Duomenys';

  @override
  String get aboutDataUsageCache => 'Talpykla';

  @override
  String get aboutDataUsageDatabase => 'Duombazė';

  @override
  String get aboutDataUsageMisc => 'Įvairūs';

  @override
  String get aboutDataUsageInternal => 'Vidaus';

  @override
  String get aboutDataUsageExternal => 'Išorinė';

  @override
  String get aboutDataUsageClearCache => 'Valyti talpyklą';

  @override
  String get aboutCreditsSectionTitle => 'Padėkos';

  @override
  String get aboutCreditsWorldAtlas1 => 'Ši programa naudoja TopoJSON failą iš';

  @override
  String get aboutCreditsWorldAtlas2 => 'pagal ISC licenciją.';

  @override
  String get aboutTranslatorsSectionTitle => 'Vertėjai';

  @override
  String get aboutLicensesSectionTitle => 'Atvirojo kodo licencijos';

  @override
  String get aboutLicensesBanner => 'Šioje programėlėje naudojami šie atvirojo kodo paketai ir bibliotekos.';

  @override
  String get aboutLicensesAndroidLibrariesSectionTitle => 'Android bibliotekos';

  @override
  String get aboutLicensesFlutterPluginsSectionTitle => 'Flutter papildiniai';

  @override
  String get aboutLicensesFlutterPackagesSectionTitle => 'Flutter paketai';

  @override
  String get aboutLicensesDartPackagesSectionTitle => 'Dart paketai';

  @override
  String get aboutLicensesShowAllButtonLabel => 'Rodyti visas licencijas';

  @override
  String get policyPageTitle => 'Privatumo politika';

  @override
  String get collectionPageTitle => 'Kolekcija';

  @override
  String get collectionPickPageTitle => 'Pasirinkti';

  @override
  String get collectionSelectPageTitle => 'Pasirinkti elementus';

  @override
  String get collectionActionShowTitleSearch => 'Rodyti pavadinimo filtrą';

  @override
  String get collectionActionHideTitleSearch => 'Slėpti pavadinimo filtrą';

  @override
  String get collectionActionAddDynamicAlbum => 'Add dynamic album';

  @override
  String get collectionActionAddShortcut => 'Pridėti nuorodą';

  @override
  String get collectionActionSetHome => 'Nustatyti kaip namus';

  @override
  String get collectionActionEmptyBin => 'Išvalyti šiukšlinę';

  @override
  String get collectionActionCopy => 'Kopijuoti į albumą';

  @override
  String get collectionActionMove => 'Perkelti į albumą';

  @override
  String get collectionActionRescan => 'Nuskenuoti iš naujo';

  @override
  String get collectionActionEdit => 'Redaguoti';

  @override
  String get collectionSearchTitlesHintText => 'Ieškoti pavadinimų';

  @override
  String get collectionGroupAlbum => 'Pagal albumą';

  @override
  String get collectionGroupMonth => 'Pagal mėnesį';

  @override
  String get collectionGroupDay => 'Pagal dieną';

  @override
  String get collectionGroupNone => 'Negrupuoti';

  @override
  String get sectionUnknown => 'Nežinoma';

  @override
  String get dateToday => 'Šiandien';

  @override
  String get dateYesterday => 'Vakar';

  @override
  String get dateThisMonth => 'Šį mėnesį';

  @override
  String collectionDeleteFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nepavyko ištrinti $count elementų',
      one: 'Nepavyko ištrinti 1 elemento',
    );
    return '$_temp0';
  }

  @override
  String collectionCopyFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nepavyko nukopijuoti $count elementų',
      one: 'Nepavyko nukopijuoti 1 elemento',
    );
    return '$_temp0';
  }

  @override
  String collectionMoveFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nepavyko perkelti $count elementų',
      one: 'Nepavyko perkelti 1 elemento',
    );
    return '$_temp0';
  }

  @override
  String collectionRenameFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nepavyko pervadinti $count elementų',
      one: 'Nepavyko pervadinti 1 elemento',
    );
    return '$_temp0';
  }

  @override
  String collectionEditFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nepavyko redaguoti $count elementų',
      one: 'Nepavyko redaguoti 1 elemento',
    );
    return '$_temp0';
  }

  @override
  String collectionExportFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nepavyko eksportuoti $count puslapių',
      one: 'Nepavyko eksportuoti 1 puslapio',
    );
    return '$_temp0';
  }

  @override
  String collectionCopySuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nukopijuoti $count elementai',
      one: 'Nukopijuota 1 prekė',
    );
    return '$_temp0';
  }

  @override
  String collectionMoveSuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Perkelta $count elementų',
      one: 'Perkeltas 1 elementas',
    );
    return '$_temp0';
  }

  @override
  String collectionRenameSuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Pervadinti $count elementai',
      one: 'Pervadintas 1 elementas',
    );
    return '$_temp0';
  }

  @override
  String collectionEditSuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Redaguoti $count elementai',
      one: 'Redaguotas 1 elementas',
    );
    return '$_temp0';
  }

  @override
  String get collectionEmptyFavourites => 'Nėra mėgstamiausių';

  @override
  String get collectionEmptyVideos => 'Nėra vaizdo įrašų';

  @override
  String get collectionEmptyImages => 'Nėra paveiklėlių';

  @override
  String get collectionEmptyGrantAccessButtonLabel => 'Suteikti prieigą';

  @override
  String get collectionSelectSectionTooltip => 'Pasirinkti pasirinkimą';

  @override
  String get collectionDeselectSectionTooltip => 'Panaikinti pasirinkimą';

  @override
  String get drawerAboutButton => 'Apie';

  @override
  String get drawerSettingsButton => 'Nustatymai';

  @override
  String get drawerCollectionAll => 'Visos kolekcijos';

  @override
  String get drawerCollectionFavourites => 'Mėgstamiausi';

  @override
  String get drawerCollectionImages => 'Paveikslėliai';

  @override
  String get drawerCollectionVideos => 'Vaizdo įrašai';

  @override
  String get drawerCollectionAnimated => 'Animuota';

  @override
  String get drawerCollectionMotionPhotos => 'Judančios nuotraukos';

  @override
  String get drawerCollectionPanoramas => 'Panoramos';

  @override
  String get drawerCollectionRaws => 'Raw nuotraukos';

  @override
  String get drawerCollectionSphericalVideos => '360° vaizdo įrašai';

  @override
  String get drawerAlbumPage => 'Albumai';

  @override
  String get drawerCountryPage => 'Šalys';

  @override
  String get drawerPlacePage => 'Vietos';

  @override
  String get drawerTagPage => 'Žymos';

  @override
  String get sortByDate => 'Pagal datą';

  @override
  String get sortByName => 'Pagal pavadinimą';

  @override
  String get sortByItemCount => 'Pagal elementų skaičių';

  @override
  String get sortBySize => 'Pagal dydį';

  @override
  String get sortByAlbumFileName => 'Pagal albumą ir failo pavadinimą';

  @override
  String get sortByRating => 'Pagal įvertinimą';

  @override
  String get sortByDuration => 'Pagal trukmę';

  @override
  String get sortByPath => 'By path';

  @override
  String get sortOrderNewestFirst => 'Naujausi viršuje';

  @override
  String get sortOrderOldestFirst => 'Seniausi viršuje';

  @override
  String get sortOrderAtoZ => 'A — Z';

  @override
  String get sortOrderZtoA => 'Z — A';

  @override
  String get sortOrderHighestFirst => 'Anksčiausi viršuje';

  @override
  String get sortOrderLowestFirst => 'Žemiausi viršuje';

  @override
  String get sortOrderLargestFirst => 'Didžiausi viršuje';

  @override
  String get sortOrderSmallestFirst => 'Mažiausi viršuje';

  @override
  String get sortOrderShortestFirst => 'Trumpiausi pirmiausiai';

  @override
  String get sortOrderLongestFirst => 'Ilgiausi pirmiausiai';

  @override
  String get albumGroupTier => 'Pagal lygį';

  @override
  String get albumGroupType => 'Pagal tipą';

  @override
  String get albumGroupVolume => 'Pagal apimtį saugykloje';

  @override
  String get albumGroupNone => 'Negrupuoti';

  @override
  String get albumMimeTypeMixed => 'Mišrus';

  @override
  String get albumPickPageTitleCopy => 'Kopijuoti į albumą';

  @override
  String get albumPickPageTitleExport => 'Eksportuoti į albumą';

  @override
  String get albumPickPageTitleMove => 'Perkelti į albumą';

  @override
  String get albumPickPageTitlePick => 'Pasirinkti albumą';

  @override
  String get albumCamera => 'Kamera';

  @override
  String get albumDownload => 'Atsiuntimai';

  @override
  String get albumScreenshots => 'Ekrano nuotraukos';

  @override
  String get albumScreenRecordings => 'Ekrano vaizdo įrašai';

  @override
  String get albumVideoCaptures => 'Vaizdo įrašai';

  @override
  String get albumPageTitle => 'Albumai';

  @override
  String get albumEmpty => 'Nėra albumų';

  @override
  String get createAlbumButtonLabel => 'KURTI';

  @override
  String get newFilterBanner => 'nauja';

  @override
  String get countryPageTitle => 'Šalys';

  @override
  String get countryEmpty => 'Nėra šalių';

  @override
  String get statePageTitle => 'Valstybės';

  @override
  String get stateEmpty => 'Jokių valstybių';

  @override
  String get placePageTitle => 'Vietos';

  @override
  String get placeEmpty => 'Jokių vietų';

  @override
  String get tagPageTitle => 'Žymos';

  @override
  String get tagEmpty => 'Nėra žymų';

  @override
  String get binPageTitle => 'Šiukšlinė';

  @override
  String get explorerPageTitle => 'Naršyklė';

  @override
  String get explorerActionSelectStorageVolume => 'Pasirinkite saugyklą';

  @override
  String get selectStorageVolumeDialogTitle => 'Pasirinkti saugyklą';

  @override
  String get searchCollectionFieldHint => 'Ieškoti kolekcijoje';

  @override
  String get searchRecentSectionTitle => 'Naujausia';

  @override
  String get searchDateSectionTitle => 'Datos';

  @override
  String get searchFormatSectionTitle => 'Formats';

  @override
  String get searchAlbumsSectionTitle => 'Albumai';

  @override
  String get searchCountriesSectionTitle => 'Šalys';

  @override
  String get searchStatesSectionTitle => 'Valstybės';

  @override
  String get searchPlacesSectionTitle => 'Vietos';

  @override
  String get searchTagsSectionTitle => 'Žymos';

  @override
  String get searchRatingSectionTitle => 'Įvertinimai';

  @override
  String get searchMetadataSectionTitle => 'Metaduomenys';

  @override
  String get settingsPageTitle => 'Nustatymai';

  @override
  String get settingsSystemDefault => 'Sistemos numatyta';

  @override
  String get settingsDefault => 'Numatyta';

  @override
  String get settingsDisabled => 'Išjungta';

  @override
  String get settingsAskEverytime => 'Klausti kiekvieną kartą';

  @override
  String get settingsModificationWarningDialogMessage => 'Kiti nustatymai bus pakeisti.';

  @override
  String get settingsSearchFieldLabel => 'Paieškos nustatymai';

  @override
  String get settingsSearchEmpty => 'Nėra atitinkančio nustatymo';

  @override
  String get settingsActionExport => 'Eksportuoti';

  @override
  String get settingsActionExportDialogTitle => 'Eksportuoti';

  @override
  String get settingsActionImport => 'Importuoti';

  @override
  String get settingsActionImportDialogTitle => 'Importuoti';

  @override
  String get appExportCovers => 'Viršeliai';

  @override
  String get appExportDynamicAlbums => 'Dynamic albums';

  @override
  String get appExportFavourites => 'Mėgstamiausi';

  @override
  String get appExportSettings => 'Nustatymai';

  @override
  String get settingsNavigationSectionTitle => 'Naršymas';

  @override
  String get settingsHomeTile => 'Pagrindinis';

  @override
  String get settingsHomeDialogTitle => 'Pagrindinis';

  @override
  String get setHomeCustom => 'Pritaikytas';

  @override
  String get settingsShowBottomNavigationBar => 'Rodyti apatinę naršymo juostą';

  @override
  String get settingsKeepScreenOnTile => 'Laikyti ekraną įjungtą';

  @override
  String get settingsKeepScreenOnDialogTitle => 'Laikyti ekraną įjungtą';

  @override
  String get settingsDoubleBackExit => 'Du kart bakstelėti „atgal“, kad išeiti';

  @override
  String get settingsConfirmationTile => 'Patvirtinimo dialogo langai';

  @override
  String get settingsConfirmationDialogTitle => 'Patvirtinimo dialogo langai';

  @override
  String get settingsConfirmationBeforeDeleteItems => 'Klausti prieš ištrinanti elementus visam laikui';

  @override
  String get settingsConfirmationBeforeMoveToBinItems => 'Klausti prieš perkeliant elementus į šiukšlinę';

  @override
  String get settingsConfirmationBeforeMoveUndatedItems => 'Klausti prieš perkeliant elementus be datos';

  @override
  String get settingsConfirmationAfterMoveToBinItems => 'Rodyti pranešimą perkėlus elementus į šiukšlinę';

  @override
  String get settingsConfirmationVaultDataLoss => 'Rodyti saugyklos duomenų praradimo ispėjimą';

  @override
  String get settingsNavigationDrawerTile => 'Naršymo meniu';

  @override
  String get settingsNavigationDrawerEditorPageTitle => 'Naršymo meniu';

  @override
  String get settingsNavigationDrawerBanner => 'Palieskite ir palaikykite, kad perkeltumėte ir pakeistumėte meniu elementų eiliškumą.';

  @override
  String get settingsNavigationDrawerTabTypes => 'Tipai';

  @override
  String get settingsNavigationDrawerTabAlbums => 'Albumai';

  @override
  String get settingsNavigationDrawerTabPages => 'Puslapiai';

  @override
  String get settingsNavigationDrawerAddAlbum => 'Pridėti albumą';

  @override
  String get settingsThumbnailSectionTitle => 'Miniatiūros';

  @override
  String get settingsThumbnailOverlayTile => 'Uždanga';

  @override
  String get settingsThumbnailOverlayPageTitle => 'Uždanga';

  @override
  String get settingsThumbnailShowHdrIcon => 'Rodyti HDR ikoną';

  @override
  String get settingsThumbnailShowFavouriteIcon => 'Rodyti mėgstamiausių piktogramą';

  @override
  String get settingsThumbnailShowTagIcon => 'Rodyti žymos piktogramą';

  @override
  String get settingsThumbnailShowLocationIcon => 'Rodyti vietos piktogramą';

  @override
  String get settingsThumbnailShowMotionPhotoIcon => 'Rodyti judančios nuotraukos piktogramą';

  @override
  String get settingsThumbnailShowRating => 'Rodyti įvertinimą';

  @override
  String get settingsThumbnailShowRawIcon => 'Rodyti Raw piktogramą';

  @override
  String get settingsThumbnailShowVideoDuration => 'Rodyti vaizdo įrašo trukmę';

  @override
  String get settingsCollectionQuickActionsTile => 'Spartieji veiksmai';

  @override
  String get settingsCollectionQuickActionEditorPageTitle => 'Spartieji veiksmai';

  @override
  String get settingsCollectionQuickActionTabBrowsing => 'Naršymas';

  @override
  String get settingsCollectionQuickActionTabSelecting => 'Pasirinkimas';

  @override
  String get settingsCollectionBrowsingQuickActionEditorBanner => 'Palieskite ir palaikykite norėdami perkelti mygtukus ir pasirinkti, kokie veiksmai bus rodomi naršant elementus.';

  @override
  String get settingsCollectionSelectionQuickActionEditorBanner => 'Palieskite ir palaikykite norėdami perkelti mygtukus ir pasirinkti, kokie veiksmai bus rodomi pasirenkant elementus.';

  @override
  String get settingsCollectionBurstPatternsTile => 'Burst modeliai';

  @override
  String get settingsCollectionBurstPatternsNone => 'Jokio';

  @override
  String get settingsViewerSectionTitle => 'Peržiūra';

  @override
  String get settingsViewerGestureSideTapNext => 'Bakstelėti ekrano kraštus, kad būtų rodomas ankstesnis / kitas elementas';

  @override
  String get settingsViewerUseCutout => 'Naudoti iškirpimo sritį';

  @override
  String get settingsViewerMaximumBrightness => 'Didžiausias ryškumas';

  @override
  String get settingsMotionPhotoAutoPlay => 'Automatiškai paleisti judančias nuotraukas';

  @override
  String get settingsImageBackground => 'Paveikslėlio fonas';

  @override
  String get settingsViewerQuickActionsTile => 'Spartieji veiksmai';

  @override
  String get settingsViewerQuickActionEditorPageTitle => 'Spartieji veiksmai';

  @override
  String get settingsViewerQuickActionEditorBanner => 'Palieskite ir palaikykite norėdami perkelti mygtukus ir pasirinkti, kurie veiksmai bus rodomi peržiūroje.';

  @override
  String get settingsViewerQuickActionEditorDisplayedButtonsSectionTitle => 'Rodomi mygtukai';

  @override
  String get settingsViewerQuickActionEditorAvailableButtonsSectionTitle => 'Galimi mygtukai';

  @override
  String get settingsViewerQuickActionEmpty => 'Nėra mygtukų';

  @override
  String get settingsViewerOverlayTile => 'Uždanga';

  @override
  String get settingsViewerOverlayPageTitle => 'Uždanga';

  @override
  String get settingsViewerShowOverlayOnOpening => 'Rodyti atidarymo metu';

  @override
  String get settingsViewerShowHistogram => 'Rodyti histogramą';

  @override
  String get settingsViewerShowMinimap => 'Rodyti mini žemėlapį';

  @override
  String get settingsViewerShowInformation => 'Rodyti informaciją';

  @override
  String get settingsViewerShowInformationSubtitle => 'Rodyti pavadinimą, datą, vietą ir kt.';

  @override
  String get settingsViewerShowRatingTags => 'Rodyti įvertinimus ir žymas';

  @override
  String get settingsViewerShowShootingDetails => 'Rodyti išsamią fotografavimo informaciją';

  @override
  String get settingsViewerShowDescription => 'Rodyti aprašymą';

  @override
  String get settingsViewerShowOverlayThumbnails => 'Rodyti miniatiūras';

  @override
  String get settingsViewerEnableOverlayBlurEffect => 'Suliejimo efektas';

  @override
  String get settingsViewerSlideshowTile => 'Skaidrių demonstravimas';

  @override
  String get settingsViewerSlideshowPageTitle => 'Skaidrių demonstravimas';

  @override
  String get settingsSlideshowRepeat => 'Kartoti';

  @override
  String get settingsSlideshowShuffle => 'Maišyti';

  @override
  String get settingsSlideshowFillScreen => 'Užpildyti ekraną';

  @override
  String get settingsSlideshowAnimatedZoomEffect => 'Animuotas priartinimo efektas';

  @override
  String get settingsSlideshowTransitionTile => 'Perėjimas efektas';

  @override
  String get settingsSlideshowIntervalTile => 'Intervalas';

  @override
  String get settingsSlideshowVideoPlaybackTile => 'Vaizdo įrašų atkūrimas';

  @override
  String get settingsSlideshowVideoPlaybackDialogTitle => 'Vaizdo įrašų atkūrimas';

  @override
  String get settingsVideoPageTitle => 'Vaizdo įrašų nustatymai';

  @override
  String get settingsVideoSectionTitle => 'Vaizdo įrašai';

  @override
  String get settingsVideoShowVideos => 'Rodyti vaizdo įrašus';

  @override
  String get settingsVideoPlaybackTile => 'Atkūrimas';

  @override
  String get settingsVideoPlaybackPageTitle => 'Atkūrimas';

  @override
  String get settingsVideoEnableHardwareAcceleration => 'Aparatinės įrangos spartintuvas';

  @override
  String get settingsVideoAutoPlay => 'Automatinis atkūrimas';

  @override
  String get settingsVideoLoopModeTile => 'Kartojimo režimas';

  @override
  String get settingsVideoLoopModeDialogTitle => 'Kartojimo režimas';

  @override
  String get settingsVideoResumptionModeTile => 'Tęsti atkūrimą';

  @override
  String get settingsVideoResumptionModeDialogTitle => 'Tęsti atkūrimą';

  @override
  String get settingsVideoBackgroundMode => 'Fono grojimas';

  @override
  String get settingsVideoBackgroundModeDialogTitle => 'Fono grojimas';

  @override
  String get settingsVideoControlsTile => 'Valdymas';

  @override
  String get settingsVideoControlsPageTitle => 'Valdymas';

  @override
  String get settingsVideoButtonsTile => 'Mygtukai';

  @override
  String get settingsVideoGestureDoubleTapTogglePlay => 'Dukart bakstelėti, kad groti / pristabdyti';

  @override
  String get settingsVideoGestureSideDoubleTapSeek => 'Dukart bakstelėti ekrano kraštus, kad peršokti pirmyn/atgal';

  @override
  String get settingsVideoGestureVerticalDragBrightnessVolume => 'Braukite į viršų ar apačią kad keisti šviesumą/garsumą';

  @override
  String get settingsSubtitleThemeTile => 'Subtitrai';

  @override
  String get settingsSubtitleThemePageTitle => 'Subtitrai';

  @override
  String get settingsSubtitleThemeSample => 'Tai yra pavyzdys.';

  @override
  String get settingsSubtitleThemeTextAlignmentTile => 'Teksto lygiavimas';

  @override
  String get settingsSubtitleThemeTextAlignmentDialogTitle => 'Teksto lygiavimas';

  @override
  String get settingsSubtitleThemeTextPositionTile => 'Teksto padėtis';

  @override
  String get settingsSubtitleThemeTextPositionDialogTitle => 'Teksto padėtis';

  @override
  String get settingsSubtitleThemeTextSize => 'Teksto dydis';

  @override
  String get settingsSubtitleThemeShowOutline => 'Rodyti kontūrą ir šešėlį';

  @override
  String get settingsSubtitleThemeTextColor => 'Teksto spalva';

  @override
  String get settingsSubtitleThemeTextOpacity => 'Teksto skaidrumas';

  @override
  String get settingsSubtitleThemeBackgroundColor => 'Fono spalva';

  @override
  String get settingsSubtitleThemeBackgroundOpacity => 'Fono skaidrumas';

  @override
  String get settingsSubtitleThemeTextAlignmentLeft => 'Į kairę';

  @override
  String get settingsSubtitleThemeTextAlignmentCenter => 'Centruoti';

  @override
  String get settingsSubtitleThemeTextAlignmentRight => 'Į dešinę';

  @override
  String get settingsPrivacySectionTitle => 'Privatumas';

  @override
  String get settingsAllowInstalledAppAccess => 'Leisti prieigą prie programėlių inventoriaus';

  @override
  String get settingsAllowInstalledAppAccessSubtitle => 'Naudojamas albumo rodymui pagerinti';

  @override
  String get settingsAllowErrorReporting => 'Leisti anonimiškai pranešti apie klaidas';

  @override
  String get settingsSaveSearchHistory => 'Išsaugoti paieškos istoriją';

  @override
  String get settingsEnableBin => 'Naudoti šiukšlinę';

  @override
  String get settingsEnableBinSubtitle => 'Išlaikyti panaikintus elementus 30 dienų';

  @override
  String get settingsDisablingBinWarningDialogMessage => 'Daiktai šiukšlių dėžėje bus ištrinti visam laikui.';

  @override
  String get settingsAllowMediaManagement => 'Leisti valdyti mediją';

  @override
  String get settingsHiddenItemsTile => 'Paslėpti elementai';

  @override
  String get settingsHiddenItemsPageTitle => 'Paslėpti elementai';

  @override
  String get settingsHiddenFiltersBanner => 'Nuotraukos ir vaizdo įrašai, atitinkantys paslėptus filtrus, nebus rodomi jūsų kolekcijoje.';

  @override
  String get settingsHiddenFiltersEmpty => 'Nėra paslėptų filtrų';

  @override
  String get settingsStorageAccessTile => 'Prieiga prie saugyklos';

  @override
  String get settingsStorageAccessPageTitle => 'Prieiga prie saugyklos';

  @override
  String get settingsStorageAccessBanner => 'Norint keisti kai kuriuos katalogus, reikia aiškios tiesioginės prieigos teisės, kad būtų galima keisti juose esančius failus. Čia galite peržiūrėti katalogus, prie kurių anksčiau suteikėte prieigą.';

  @override
  String get settingsStorageAccessEmpty => 'Prieigos teisių nesuteikta';

  @override
  String get settingsStorageAccessRevokeTooltip => 'Atšaukti leidimą';

  @override
  String get settingsAccessibilitySectionTitle => 'Pritaikymas neįgaliesiems';

  @override
  String get settingsRemoveAnimationsTile => 'Pašalinti animacijas';

  @override
  String get settingsRemoveAnimationsDialogTitle => 'Pašalinti animacijas';

  @override
  String get settingsTimeToTakeActionTile => 'Laikas iki veiksmo atlikimo';

  @override
  String get settingsAccessibilityShowPinchGestureAlternatives => 'Rodyti kelių palietimų gestų alternatyvas';

  @override
  String get settingsDisplaySectionTitle => 'Ekranas';

  @override
  String get settingsThemeBrightnessTile => 'Tema';

  @override
  String get settingsThemeBrightnessDialogTitle => 'Tema';

  @override
  String get settingsThemeColorHighlights => 'Spalvų akcentai';

  @override
  String get settingsThemeEnableDynamicColor => 'Dinaminė spalva';

  @override
  String get settingsDisplayRefreshRateModeTile => 'Ekrano atnaujinimo dažnis';

  @override
  String get settingsDisplayRefreshRateModeDialogTitle => 'Atnaujinimo dažnis';

  @override
  String get settingsDisplayUseTvInterface => 'Android TV vaizdas';

  @override
  String get settingsLanguageSectionTitle => 'Kalba ir formatai';

  @override
  String get settingsLanguageTile => 'Kalba';

  @override
  String get settingsLanguagePageTitle => 'Kalba';

  @override
  String get settingsCoordinateFormatTile => 'Koordinačių formatas';

  @override
  String get settingsCoordinateFormatDialogTitle => 'Koordinačių formatas';

  @override
  String get settingsUnitSystemTile => 'Vienetai';

  @override
  String get settingsUnitSystemDialogTitle => 'Vienetai';

  @override
  String get settingsForceWesternArabicNumeralsTile => 'Priversti arabų skaitmenys';

  @override
  String get settingsScreenSaverPageTitle => 'Ekrano užsklanda';

  @override
  String get settingsWidgetPageTitle => 'Nuotraukų rėmelis';

  @override
  String get settingsWidgetShowOutline => 'Kontūras';

  @override
  String get settingsWidgetOpenPage => 'Bakstelėjus valdiklį';

  @override
  String get settingsWidgetDisplayedItem => 'Rodomas elementas';

  @override
  String get settingsCollectionTile => 'Kolekcija';

  @override
  String get statsPageTitle => 'Statistika';

  @override
  String statsWithGps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementai su vieta',
      one: '1 elementas su vieta',
    );
    return '$_temp0';
  }

  @override
  String get statsTopCountriesSectionTitle => 'Populiariausios šalys';

  @override
  String get statsTopStatesSectionTitle => 'Pagrindinės valstybės';

  @override
  String get statsTopPlacesSectionTitle => 'Populiariausios vietos';

  @override
  String get statsTopTagsSectionTitle => 'Populiariausios žymos';

  @override
  String get statsTopAlbumsSectionTitle => 'Populiariausi albumai';

  @override
  String get viewerOpenPanoramaButtonLabel => 'ATIDARYTI PANORAMĄ';

  @override
  String get viewerSetWallpaperButtonLabel => 'NUSTATYTI EKRANO FONĄ';

  @override
  String get viewerErrorUnknown => 'Oi!';

  @override
  String get viewerErrorDoesNotExist => 'Failas nebeegzistuoja.';

  @override
  String get viewerInfoPageTitle => 'Informacija';

  @override
  String get viewerInfoBackToViewerTooltip => 'Atgal į peržiūrą';

  @override
  String get viewerInfoUnknown => 'nežinoma';

  @override
  String get viewerInfoLabelDescription => 'Aprašymas';

  @override
  String get viewerInfoLabelTitle => 'Pavadinimas';

  @override
  String get viewerInfoLabelDate => 'Data';

  @override
  String get viewerInfoLabelResolution => 'Rezoliucija';

  @override
  String get viewerInfoLabelSize => 'Dydis';

  @override
  String get viewerInfoLabelUri => 'URI';

  @override
  String get viewerInfoLabelPath => 'Kelias';

  @override
  String get viewerInfoLabelDuration => 'Trukmė';

  @override
  String get viewerInfoLabelOwner => 'Savininkas';

  @override
  String get viewerInfoLabelCoordinates => 'Koordinatės';

  @override
  String get viewerInfoLabelAddress => 'Adresas';

  @override
  String get mapStyleDialogTitle => 'Žemėlapio stilius';

  @override
  String get mapStyleTooltip => 'Pasirinkti žemėlapio stilių';

  @override
  String get mapZoomInTooltip => 'Pritraukti';

  @override
  String get mapZoomOutTooltip => 'Atitolinti';

  @override
  String get mapPointNorthUpTooltip => 'Centruoti pagal šiaurę';

  @override
  String get mapAttributionOsmData => 'Žemėlapio duomenys © [OpenStreetMap](https://www.openstreetmap.org/copyright) bendradarbiai';

  @override
  String get mapAttributionOsmLiberty => 'Tiles by [OpenMapTiles](https://www.openmaptiles.org/), [CC BY](http://creativecommons.org/licenses/by/4.0) • Hosted by [OSM Americana](https://tile.ourmap.us)';

  @override
  String get mapAttributionOpenTopoMap => '[SRTM](https://www.earthdata.nasa.gov/sensors/srtm) | Tiles by [OpenTopoMap](https://opentopomap.org/), [CC BY-SA](https://creativecommons.org/licenses/by-sa/3.0/)';

  @override
  String get mapAttributionOsmHot => 'Sluoksniai [HOT](https://www.hotosm.org/) • Priegloba [OSM France](https://openstreetmap.fr/)';

  @override
  String get mapAttributionStamen => 'Sluoksniai [Stamen Design](https://stamen.com), [CC BY 3.0](https://creativecommons.org/licenses/by/3.0)';

  @override
  String get openMapPageTooltip => 'Peržiūrėti žemėlapio puslapyje';

  @override
  String get mapEmptyRegion => 'Šiame regione paveikslėlių nėra';

  @override
  String get viewerInfoOpenEmbeddedFailureFeedback => 'Nepavyko išskleisti įterptųjų duomenų';

  @override
  String get viewerInfoOpenLinkText => 'Atidaryti';

  @override
  String get viewerInfoViewXmlLinkText => 'Peržiūrėti XML';

  @override
  String get viewerInfoSearchFieldLabel => 'Ieškoti metaduomenyse';

  @override
  String get viewerInfoSearchEmpty => 'Nėra atitinkančių raktų';

  @override
  String get viewerInfoSearchSuggestionDate => 'Data ir laikas';

  @override
  String get viewerInfoSearchSuggestionDescription => 'Aprašymas';

  @override
  String get viewerInfoSearchSuggestionDimensions => 'Matmenys';

  @override
  String get viewerInfoSearchSuggestionResolution => 'Rezoliucija';

  @override
  String get viewerInfoSearchSuggestionRights => 'Teisės';

  @override
  String get wallpaperUseScrollEffect => 'Naudoti slinkties efektą pagrindiniame ekrane';

  @override
  String get tagEditorPageTitle => 'Redaguoti žymas';

  @override
  String get tagEditorPageNewTagFieldLabel => 'Nauja žyma';

  @override
  String get tagEditorPageAddTagTooltip => 'Pridėti žymą';

  @override
  String get tagEditorSectionRecent => 'Naujausia';

  @override
  String get tagEditorSectionPlaceholders => 'Vietos rezervavimo ženklai';

  @override
  String get tagEditorDiscardDialogMessage => 'Do you want to discard changes?';

  @override
  String get tagPlaceholderCountry => 'Šalis';

  @override
  String get tagPlaceholderState => 'State';

  @override
  String get tagPlaceholderPlace => 'Vieta';

  @override
  String get panoramaEnableSensorControl => 'Įjungti jutiklio valdymą';

  @override
  String get panoramaDisableSensorControl => 'Išjungti jutiklio valdymą';

  @override
  String get sourceViewerPageTitle => 'Šaltinis';

  @override
  String get filePickerShowHiddenFiles => 'Rodyti paslėptus failus';

  @override
  String get filePickerDoNotShowHiddenFiles => 'Nerodyti paslėptų failų';

  @override
  String get filePickerOpenFrom => 'Atidaryti iš';

  @override
  String get filePickerNoItems => 'Nėra elementų';

  @override
  String get filePickerUseThisFolder => 'Naudoti šį aplanką';
}
