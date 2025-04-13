// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Basque (`eu`).
class AppLocalizationsEu extends AppLocalizations {
  AppLocalizationsEu([String locale = 'eu']) : super(locale);

  @override
  String get appName => 'Aves';

  @override
  String get welcomeMessage => 'Ongi etorri';

  @override
  String get welcomeOptional => 'Aukerazkoa';

  @override
  String get welcomeTermsToggle => 'Termino eta baldintzekin ados nago';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementu',
      one: 'elementu $count',
    );
    return '$_temp0';
  }

  @override
  String columnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count zutabe',
      one: 'zutabe $count',
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
      other: '$countString segundu',
      one: 'segundu $countString',
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
      other: '$countString minutu',
      one: 'minutu $countString',
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
      other: '$countString egun',
      one: 'egun $countString',
    );
    return '$_temp0';
  }

  @override
  String focalLength(String length) {
    return '$length mm';
  }

  @override
  String get applyButtonLabel => 'APLIKATU';

  @override
  String get deleteButtonLabel => 'EZABATU';

  @override
  String get nextButtonLabel => 'HURRENGOA';

  @override
  String get showButtonLabel => 'ERAKUTSI';

  @override
  String get hideButtonLabel => 'EZKUTATU';

  @override
  String get continueButtonLabel => 'JARRAITU';

  @override
  String get saveCopyButtonLabel => 'GORDE KOPIA';

  @override
  String get applyTooltip => 'Aplikatu';

  @override
  String get cancelTooltip => 'Utzi';

  @override
  String get changeTooltip => 'Aldatu';

  @override
  String get clearTooltip => 'Garbitu';

  @override
  String get previousTooltip => 'Aurrekoa';

  @override
  String get nextTooltip => 'Hurrengoa';

  @override
  String get showTooltip => 'Erakutsi';

  @override
  String get hideTooltip => 'Ezkutatu';

  @override
  String get actionRemove => 'Ezabatu';

  @override
  String get resetTooltip => 'Berrezarri';

  @override
  String get saveTooltip => 'Gorde';

  @override
  String get stopTooltip => 'Gelditu';

  @override
  String get pickTooltip => 'Aukeratu';

  @override
  String get doubleBackExitMessage => 'Sakatu «itzuli» berriro irteteko.';

  @override
  String get doNotAskAgain => 'Ez galdetu berriro';

  @override
  String get sourceStateLoading => 'Kargatzen';

  @override
  String get sourceStateCataloguing => 'Katalogatzen';

  @override
  String get sourceStateLocatingCountries => 'Herrialdeak kokatzen';

  @override
  String get sourceStateLocatingPlaces => 'Lekuak kokatzen';

  @override
  String get chipActionDelete => 'Ezabatu';

  @override
  String get chipActionRemove => 'Remove';

  @override
  String get chipActionShowCollection => 'Erakutsi bilduman';

  @override
  String get chipActionGoToAlbumPage => 'Erakutsi albumetan';

  @override
  String get chipActionGoToCountryPage => 'Erakutsi herrialdeetan';

  @override
  String get chipActionGoToPlacePage => 'Erakutsi lekuetan';

  @override
  String get chipActionGoToTagPage => 'Erakutsi etiketetan';

  @override
  String get chipActionGoToExplorerPage => 'Erakutsi arakatzailean';

  @override
  String get chipActionDecompose => 'Split';

  @override
  String get chipActionFilterOut => 'Ez iragazi';

  @override
  String get chipActionFilterIn => 'Iragazi';

  @override
  String get chipActionHide => 'Ezkutatu';

  @override
  String get chipActionLock => 'Blokeatu';

  @override
  String get chipActionPin => 'Finkatu goran';

  @override
  String get chipActionUnpin => 'Desfinkatu goitik';

  @override
  String get chipActionRename => 'Aldatu izena';

  @override
  String get chipActionSetCover => 'Ezarri azala';

  @override
  String get chipActionShowCountryStates => 'Erakutsi egoerak';

  @override
  String get chipActionCreateAlbum => 'Sortu albuma';

  @override
  String get chipActionCreateVault => 'Sortu kutxa gotorra';

  @override
  String get chipActionConfigureVault => 'Konfiguratu kutxa gotorra';

  @override
  String get entryActionCopyToClipboard => 'Kopiatu arbelera';

  @override
  String get entryActionDelete => 'Ezabatu';

  @override
  String get entryActionConvert => 'Bihurtu';

  @override
  String get entryActionExport => 'Esportatu';

  @override
  String get entryActionInfo => 'Informazioa';

  @override
  String get entryActionRename => 'Aldatu izena';

  @override
  String get entryActionRestore => 'Berrezarri';

  @override
  String get entryActionRotateCCW => 'Biratu erlojuaren orratzen kontrako noranzkoan';

  @override
  String get entryActionRotateCW => 'Biratu erlojuaren orratzen noranzkoan';

  @override
  String get entryActionFlip => 'Buelta eman horizontalki';

  @override
  String get entryActionPrint => 'Inprimatu';

  @override
  String get entryActionShare => 'Partekatu';

  @override
  String get entryActionShareImageOnly => 'Partekatu irudia soilik';

  @override
  String get entryActionShareVideoOnly => 'Partekatu bideoa soilik';

  @override
  String get entryActionViewSource => 'Ikusi iturria';

  @override
  String get entryActionShowGeoTiffOnMap => 'Erakutsi gainjarritako mapa bezala';

  @override
  String get entryActionConvertMotionPhotoToStillImage => 'Bihurtu irudi finko batean';

  @override
  String get entryActionViewMotionPhotoVideo => 'Ireki bideoa';

  @override
  String get entryActionEdit => 'Editatu';

  @override
  String get entryActionOpen => 'Ireki honekin';

  @override
  String get entryActionSetAs => 'Ezarri hau bezala';

  @override
  String get entryActionCast => 'Igorri';

  @override
  String get entryActionOpenMap => 'Erakutsi mapako aplikazioan';

  @override
  String get entryActionRotateScreen => 'Biratu pantaila';

  @override
  String get entryActionAddFavourite => 'Gehitu gogokoetara';

  @override
  String get entryActionRemoveFavourite => 'Kendu gogokoetatik';

  @override
  String get videoActionCaptureFrame => 'Atzitu fotograma';

  @override
  String get videoActionMute => 'Mututu';

  @override
  String get videoActionUnmute => 'Ez mututu';

  @override
  String get videoActionPause => 'Eten';

  @override
  String get videoActionPlay => 'Erreproduzitu';

  @override
  String get videoActionReplay10 => 'Atzera 10 segundu egin';

  @override
  String get videoActionSkip10 => 'Aurrera 10 segundu egin';

  @override
  String get videoActionShowPreviousFrame => 'Show previous frame';

  @override
  String get videoActionShowNextFrame => 'Show next frame';

  @override
  String get videoActionSelectStreams => 'Hautatu pistak';

  @override
  String get videoActionSetSpeed => 'Erreproduzitze-abiadura';

  @override
  String get videoActionABRepeat => 'Atik Brako errepikapena';

  @override
  String get videoRepeatActionSetStart => 'Ezarri hasiera';

  @override
  String get videoRepeatActionSetEnd => 'Ezarri amaiera';

  @override
  String get viewerActionSettings => 'Ezarpenak';

  @override
  String get viewerActionLock => 'Blokeatu bisorea';

  @override
  String get viewerActionUnlock => 'Deskblokeatu bisorea';

  @override
  String get slideshowActionResume => 'Jarraitu';

  @override
  String get slideshowActionShowInCollection => 'Erakutsi bilduman';

  @override
  String get entryInfoActionEditDate => 'Editatu data eta ordua';

  @override
  String get entryInfoActionEditLocation => 'Editatu kokapena';

  @override
  String get entryInfoActionEditTitleDescription => 'Editatu izenburua eta deskribapena';

  @override
  String get entryInfoActionEditRating => 'Editatu balorazioa';

  @override
  String get entryInfoActionEditTags => 'Editatu etiketak';

  @override
  String get entryInfoActionRemoveMetadata => 'Kendu metadatuak';

  @override
  String get entryInfoActionExportMetadata => 'Esportatu metadatuak';

  @override
  String get entryInfoActionRemoveLocation => 'Ezabatu kokapena';

  @override
  String get editorActionTransform => 'Eraldatu';

  @override
  String get editorTransformCrop => 'Moztu';

  @override
  String get editorTransformRotate => 'Biratu';

  @override
  String get cropAspectRatioFree => 'Librea';

  @override
  String get cropAspectRatioOriginal => 'Jatorrizkoa';

  @override
  String get cropAspectRatioSquare => 'Karratua';

  @override
  String get filterAspectRatioLandscapeLabel => 'Formatu horizontala';

  @override
  String get filterAspectRatioPortraitLabel => 'Formatu bertikala';

  @override
  String get filterBinLabel => 'Zakarrontzia';

  @override
  String get filterFavouriteLabel => 'Gogokoa';

  @override
  String get filterNoDateLabel => 'Datarik gabe';

  @override
  String get filterNoAddressLabel => 'Helbiderik ez';

  @override
  String get filterLocatedLabel => 'Kokatua';

  @override
  String get filterNoLocationLabel => 'Kokatu gabe';

  @override
  String get filterNoRatingLabel => 'Kalifikaziorik gabe';

  @override
  String get filterTaggedLabel => 'Etiketatua';

  @override
  String get filterNoTagLabel => 'Etiketatu gabe';

  @override
  String get filterNoTitleLabel => 'Izenbururik gabe';

  @override
  String get filterOnThisDayLabel => 'Egun honetan';

  @override
  String get filterRecentlyAddedLabel => 'Duela gutxi gehitua';

  @override
  String get filterRatingRejectedLabel => 'Baztertua';

  @override
  String get filterTypeAnimatedLabel => 'Animatua';

  @override
  String get filterTypeMotionPhotoLabel => 'Argazki-mugikorra';

  @override
  String get filterTypePanoramaLabel => 'Panoramika';

  @override
  String get filterTypeRawLabel => 'Raw';

  @override
  String get filterTypeSphericalVideoLabel => '360°-ko bideoa';

  @override
  String get filterTypeGeotiffLabel => 'GeoTIFF';

  @override
  String get filterMimeImageLabel => 'Irudi';

  @override
  String get filterMimeVideoLabel => 'Bideo';

  @override
  String get accessibilityAnimationsRemove => 'Pantaila-efektuak ekidin';

  @override
  String get accessibilityAnimationsKeep => 'Pantaila-efektuak mantendu';

  @override
  String get albumTierNew => 'Berria';

  @override
  String get albumTierPinned => 'Finkatua';

  @override
  String get albumTierSpecial => 'Ohiko';

  @override
  String get albumTierApps => 'Aplikazioak';

  @override
  String get albumTierVaults => 'Kutxa gotorrak';

  @override
  String get albumTierDynamic => 'Dynamic';

  @override
  String get albumTierRegular => 'Besteak';

  @override
  String get coordinateFormatDms => 'DMS (Dokumentuak kudeatzeko sistema)';

  @override
  String get coordinateFormatDdm => 'DDM';

  @override
  String get coordinateFormatDecimal => 'Gradu hamartarrak';

  @override
  String coordinateDms(String coordinate, String direction) {
    return '$coordinate $direction';
  }

  @override
  String get coordinateDmsNorth => 'I';

  @override
  String get coordinateDmsSouth => 'H';

  @override
  String get coordinateDmsEast => 'E';

  @override
  String get coordinateDmsWest => 'M';

  @override
  String get displayRefreshRatePreferHighest => 'Kalifikazio gorena';

  @override
  String get displayRefreshRatePreferLowest => 'Kalifikazio baxuena';

  @override
  String get keepScreenOnNever => 'Inoiz';

  @override
  String get keepScreenOnVideoPlayback => 'Bideoa erreproduzitzean';

  @override
  String get keepScreenOnViewerOnly => 'Bisorea soilik';

  @override
  String get keepScreenOnAlways => 'Beti';

  @override
  String get lengthUnitPixel => 'px';

  @override
  String get lengthUnitPercent => '%';

  @override
  String get mapStyleGoogleNormal => 'Google Maps';

  @override
  String get mapStyleGoogleHybrid => 'Google Maps (higikorra)';

  @override
  String get mapStyleGoogleTerrain => 'Google Maps (lurra)';

  @override
  String get mapStyleOsmLiberty => 'OSM Liberty';

  @override
  String get mapStyleOpenTopoMap => 'OpenTopoMap';

  @override
  String get mapStyleOsmHot => 'OSM humanitarioa';

  @override
  String get mapStyleStamenWatercolor => 'Stamen Watercolor (akuarela)';

  @override
  String get maxBrightnessNever => 'Inoiz';

  @override
  String get maxBrightnessAlways => 'Beti';

  @override
  String get nameConflictStrategyRename => 'Berrizendatu';

  @override
  String get nameConflictStrategyReplace => 'Ordezkatu';

  @override
  String get nameConflictStrategySkip => 'Jauzi';

  @override
  String get overlayHistogramNone => 'Bat ere ez';

  @override
  String get overlayHistogramRGB => 'RGB';

  @override
  String get overlayHistogramLuminance => 'Luminantzia';

  @override
  String get subtitlePositionTop => 'Goran';

  @override
  String get subtitlePositionBottom => 'Behean';

  @override
  String get themeBrightnessLight => 'Argi';

  @override
  String get themeBrightnessDark => 'Ilun';

  @override
  String get themeBrightnessBlack => 'Beltz';

  @override
  String get unitSystemMetric => 'Metriko';

  @override
  String get unitSystemImperial => 'Inperial';

  @override
  String get vaultLockTypePattern => 'Patroia';

  @override
  String get vaultLockTypePin => 'PIN kodea';

  @override
  String get vaultLockTypePassword => 'Pasahitza';

  @override
  String get settingsVideoEnablePip => 'Bideoa leihotxoan';

  @override
  String get videoControlsPlayOutside => 'Ireki beste erreproduzitzaile batekin';

  @override
  String get videoLoopModeNever => 'Inoiz';

  @override
  String get videoLoopModeShortOnly => 'Bideo laburrak soilik';

  @override
  String get videoLoopModeAlways => 'Beti';

  @override
  String get videoPlaybackSkip => 'Jauzi';

  @override
  String get videoPlaybackMuted => 'Mutututa erreproduzitu';

  @override
  String get videoPlaybackWithSound => 'Soinuarekin erreproduzitu';

  @override
  String get videoResumptionModeNever => 'Inoiz';

  @override
  String get videoResumptionModeAlways => 'Beti';

  @override
  String get viewerTransitionSlide => 'Diapositiba';

  @override
  String get viewerTransitionParallax => 'Paralaxi';

  @override
  String get viewerTransitionFade => 'Desagertu';

  @override
  String get viewerTransitionZoomIn => 'Hurbildu';

  @override
  String get viewerTransitionNone => 'Bat ere ez';

  @override
  String get wallpaperTargetHome => 'Hasierako pantaila';

  @override
  String get wallpaperTargetLock => 'Blokeo-pantaila';

  @override
  String get wallpaperTargetHomeLock => 'Hasiera- eta blokeo-pantaila';

  @override
  String get widgetDisplayedItemRandom => 'Ausazko';

  @override
  String get widgetDisplayedItemMostRecent => 'Berrienak';

  @override
  String get widgetOpenPageHome => 'Ireki hasierako pantaila';

  @override
  String get widgetOpenPageCollection => 'Ireki bilduma';

  @override
  String get widgetOpenPageViewer => 'Ireki bisorea';

  @override
  String get widgetTapUpdateWidget => 'Eguneratu widgeta';

  @override
  String get storageVolumeDescriptionFallbackPrimary => 'Barne-biltegiratzea';

  @override
  String get storageVolumeDescriptionFallbackNonPrimary => 'SD txartela';

  @override
  String get rootDirectoryDescription => 'Erro-karpeta';

  @override
  String otherDirectoryDescription(String name) {
    return '«$name» karpeta';
  }

  @override
  String storageAccessDialogMessage(String directory, String volume) {
    return 'Mesedez, «$volume»-(e)n $directory aukera ezazu hurrengo pantailan aplikazio honi sarrera baimentzeko.';
  }

  @override
  String restrictedAccessDialogMessage(String directory, String volume) {
    return 'Aplikazio honek ez du baimenik «$volume»-(e)ko $directory-(e)n fitxategiak aldatzeko.\n\nMesedez, aurreinstalatutako fitxategi-kudeatzaile edo galeriaren aplikazio bat erabili itemak beste karpeta batera mugitzeko.';
  }

  @override
  String notEnoughSpaceDialogMessage(String neededSize, String freeSize, String volume) {
    return 'Eragiketa hau burutzeko $neededSize-eko leku librea behar da «$volume»-(e)n, baina, $freeSize-eko lekua dago soilik.';
  }

  @override
  String get missingSystemFilePickerDialogMessage => 'Sistemako fitxategien bilatzailea falta da edo desaktibatua dago. Mesedez, aktiba ezazu eta saia zaitez berriro.';

  @override
  String unsupportedTypeDialogMessage(int count, String types) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Eragiketa hau ez da bateragarria aukeratutako hurrengo elementu-motentzako: $types.',
      one: 'Eragiketa hau ez da bateragarria aukeratutako hurrengo elementu-motarentzako: $types.',
    );
    return '$_temp0';
  }

  @override
  String get nameConflictDialogSingleSourceMessage => 'Helburuko karpetan dauden fitxategi batzuek izen bera dute.';

  @override
  String get nameConflictDialogMultipleSourceMessage => 'Fitxategi batzuek izen bera dute.';

  @override
  String get addShortcutDialogLabel => 'Laster-bidearen etiketa';

  @override
  String get addShortcutButtonLabel => 'GEHITU';

  @override
  String get noMatchingAppDialogMessage => 'Hau maneiatu dezakeen aplikaziorik ez dago.';

  @override
  String binEntriesConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementu hauek zakarrontzira bidali nahi al dituzu?',
      one: 'Elementu hau zakarrontzira bidali nahi al duzu?',
    );
    return '$_temp0';
  }

  @override
  String deleteEntriesConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementu hauek ezaba nahi al dituzu?',
      one: 'Elementu hau ezaba nahi al duzu?',
    );
    return '$_temp0';
  }

  @override
  String get moveUndatedConfirmationDialogMessage => 'Elementuen datak gorde nahi al dituzu aurrera egin aurretik?';

  @override
  String get moveUndatedConfirmationDialogSetDate => 'Gorde datak';

  @override
  String videoResumeDialogMessage(String time) {
    return 'Erreprodukzioa $time denboran jarraitzea nahi al duzu?';
  }

  @override
  String get videoStartOverButtonLabel => 'BERRIRO HASI';

  @override
  String get videoResumeButtonLabel => 'JARRAITU';

  @override
  String get setCoverDialogLatest => 'Azkeneko elementua';

  @override
  String get setCoverDialogAuto => 'Automatikoa';

  @override
  String get setCoverDialogCustom => 'Pertsonalizatua';

  @override
  String get hideFilterConfirmationDialogMessage => 'Bat-etortzen diren argazki eta bideoak zure bildumatik ezkutatuko dira. Berriro agerrarazi ditzakezu «Pribatutasuna» ezarpenetatik.\n\nZiur al zaude ezkuta nahi al dituzula?';

  @override
  String get newAlbumDialogTitle => 'Album berria';

  @override
  String get newAlbumDialogNameLabel => 'Albumaren izena';

  @override
  String get newAlbumDialogAlbumAlreadyExistsHelper => 'Album already exists';

  @override
  String get newAlbumDialogNameLabelAlreadyExistsHelper => 'Karpeta jada badago';

  @override
  String get newAlbumDialogStorageLabel => 'Biltegiratzea:';

  @override
  String get newDynamicAlbumDialogTitle => 'New Dynamic Album';

  @override
  String get dynamicAlbumAlreadyExists => 'Dynamic album already exists';

  @override
  String get newVaultWarningDialogMessage => 'Kutxa gotorreko elementuak aplikazio honetarako soilik daude eskuragarri eta ez beste edozeinetarako.\n\nAplikazio hau desinstalatzen baduzu, edo aplikazio honen datuak garbitu, elementu guzti hauek galduko dituzu.';

  @override
  String get newVaultDialogTitle => 'Kutxa gotor berria';

  @override
  String get configureVaultDialogTitle => 'Konfiguratu kutxa gotorra';

  @override
  String get vaultDialogLockModeWhenScreenOff => 'Blokeatu pantaila itzaltzean';

  @override
  String get vaultDialogLockTypeLabel => 'Blokeatze modua';

  @override
  String get patternDialogEnter => 'Sartu patroia';

  @override
  String get patternDialogConfirm => 'Konfirmatu patroia';

  @override
  String get pinDialogEnter => 'Sartu PINa';

  @override
  String get pinDialogConfirm => 'Konfirmatu PINa';

  @override
  String get passwordDialogEnter => 'Sartu pasahitza';

  @override
  String get passwordDialogConfirm => 'Berretsi pasahitza';

  @override
  String get authenticateToConfigureVault => 'Autentifikatu kutxa gotorra konfiguratzeko';

  @override
  String get authenticateToUnlockVault => 'Autentifikatu kutxa gotorra desblokeatzeko';

  @override
  String get vaultBinUsageDialogMessage => 'Kutxa gotor batzuk zakarrontzia erabiltzen ari dira.';

  @override
  String get renameAlbumDialogLabel => 'Izen berria';

  @override
  String get renameAlbumDialogLabelAlreadyExistsHelper => 'Direktorioa jada badago';

  @override
  String get renameEntrySetPageTitle => 'Aldatu izena';

  @override
  String get renameEntrySetPagePatternFieldLabel => 'Izendapen-eredua';

  @override
  String get renameEntrySetPageInsertTooltip => 'Txertatu eremua';

  @override
  String get renameEntrySetPagePreviewSectionTitle => 'Aurrebista';

  @override
  String get renameProcessorCounter => 'Kontagailu';

  @override
  String get renameProcessorHash => 'Hash-a';

  @override
  String get renameProcessorName => 'Izena';

  @override
  String deleteSingleAlbumConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Album hau eta bertako $count elementuak ezaba nahi al dituzu?',
      one: 'Album hau eta bertako elementua ezaba nahi al dituzu?',
    );
    return '$_temp0';
  }

  @override
  String deleteMultiAlbumConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Album hauek eta hauetan dauden $count elementuak ezaba nahi al dituzu?',
      one: 'Album hauek eta hauetan dagoen elementua ezaba nahi al dituzu?',
    );
    return '$_temp0';
  }

  @override
  String get exportEntryDialogFormat => 'Formatua:';

  @override
  String get exportEntryDialogWidth => 'Zabalera';

  @override
  String get exportEntryDialogHeight => 'Altuera';

  @override
  String get exportEntryDialogQuality => 'Kalitatea';

  @override
  String get exportEntryDialogWriteMetadata => 'Idatzi metadatuak';

  @override
  String get renameEntryDialogLabel => 'Izen berria';

  @override
  String get editEntryDialogCopyFromItem => 'Kopiatu beste elementu batetik';

  @override
  String get editEntryDialogTargetFieldsHeader => 'Aldatzeko eremuak';

  @override
  String get editEntryDateDialogTitle => 'Data eta ordua';

  @override
  String get editEntryDateDialogSetCustom => 'Ezarri data pertsonalizatua';

  @override
  String get editEntryDateDialogCopyField => 'Kopiatu beste data batetik';

  @override
  String get editEntryDateDialogExtractFromTitle => 'Atera izenburutik';

  @override
  String get editEntryDateDialogShift => 'Aldatu';

  @override
  String get editEntryDateDialogSourceFileModifiedDate => 'Fitxategia aldatu zeneko data';

  @override
  String get durationDialogHours => 'Orduak';

  @override
  String get durationDialogMinutes => 'Minutuak';

  @override
  String get durationDialogSeconds => 'Segunduak';

  @override
  String get editEntryLocationDialogTitle => 'Kokapena';

  @override
  String get editEntryLocationDialogSetCustom => 'Ezarri kokapen pertsonalizatua';

  @override
  String get editEntryLocationDialogChooseOnMap => 'Aukeratu mapan';

  @override
  String get editEntryLocationDialogImportGpx => 'Import GPX';

  @override
  String get editEntryLocationDialogLatitude => 'Latitudea';

  @override
  String get editEntryLocationDialogLongitude => 'Longitudea';

  @override
  String get editEntryLocationDialogTimeShift => 'Time shift';

  @override
  String get locationPickerUseThisLocationButton => 'Erabili kokapen hau';

  @override
  String get editEntryRatingDialogTitle => 'Balorazioa';

  @override
  String get removeEntryMetadataDialogTitle => 'Metadatuen ezabapena';

  @override
  String get removeEntryMetadataDialogAll => 'All';

  @override
  String get removeEntryMetadataDialogMore => 'Gehiago';

  @override
  String get removeEntryMetadataMotionPhotoXmpWarningDialogMessage => 'Mugimendu-argazkiko bideoa erreproduzitzeko XMP behar da.\n\nZiur al zaude ezabatu nahi duzula?';

  @override
  String get videoSpeedDialogLabel => 'Erreprodukzio-abiadura';

  @override
  String get videoStreamSelectionDialogVideo => 'Bideoa';

  @override
  String get videoStreamSelectionDialogAudio => 'Audioa';

  @override
  String get videoStreamSelectionDialogText => 'Azpitituluak';

  @override
  String get videoStreamSelectionDialogOff => 'Desgaitua';

  @override
  String get videoStreamSelectionDialogTrack => 'Pista';

  @override
  String get videoStreamSelectionDialogNoSelection => 'Ez dago pista gehiagorik.';

  @override
  String get genericSuccessFeedback => 'Egina!';

  @override
  String get genericFailureFeedback => 'Huts egin du';

  @override
  String get genericDangerWarningDialogMessage => 'Ziur al zaude?';

  @override
  String get tooManyItemsErrorDialogMessage => 'Elementu gutxiagorekin saia zaitez berriro.';

  @override
  String get menuActionConfigureView => 'Ikusi';

  @override
  String get menuActionSelect => 'Hautatu';

  @override
  String get menuActionSelectAll => 'Guztiak hautatu';

  @override
  String get menuActionSelectNone => 'Bat ere ez hautatu';

  @override
  String get menuActionMap => 'Mapa';

  @override
  String get menuActionSlideshow => 'Aurkezpena';

  @override
  String get menuActionStats => 'Estatistikak';

  @override
  String get viewDialogSortSectionTitle => 'Ordenatu';

  @override
  String get viewDialogGroupSectionTitle => 'Taldea';

  @override
  String get viewDialogLayoutSectionTitle => 'Diseinua';

  @override
  String get viewDialogReverseSortOrder => 'Sailkapen-ordena alderantzikatu';

  @override
  String get tileLayoutMosaic => 'Mosaikoa';

  @override
  String get tileLayoutGrid => 'Sareta';

  @override
  String get tileLayoutList => 'Zerrenda';

  @override
  String get castDialogTitle => 'Igortzeko gailuak';

  @override
  String get coverDialogTabCover => 'Azala';

  @override
  String get coverDialogTabApp => 'Aplikazioa';

  @override
  String get coverDialogTabColor => 'Kolorea';

  @override
  String get appPickDialogTitle => 'Aplikazioa aukeratu';

  @override
  String get appPickDialogNone => 'Bat ere ez';

  @override
  String get aboutPageTitle => 'Honi buruz';

  @override
  String get aboutLinkLicense => 'Lizentzia';

  @override
  String get aboutLinkPolicy => 'Pribatutasun-politika';

  @override
  String get aboutBugSectionTitle => 'Akatsen berri eman';

  @override
  String get aboutBugSaveLogInstruction => 'Aplikazioaren erregistroak fitxategi batean gorde';

  @override
  String get aboutBugCopyInfoInstruction => 'Sistemako informazioa kopiatu';

  @override
  String get aboutBugCopyInfoButton => 'Kopiatu';

  @override
  String get aboutBugReportInstruction => 'GitHubera txostena erregistro eta sistemako informazioarekin bidali';

  @override
  String get aboutBugReportButton => 'Txostena bidali';

  @override
  String get aboutDataUsageSectionTitle => 'Datuen erabilera';

  @override
  String get aboutDataUsageData => 'Datuak';

  @override
  String get aboutDataUsageCache => 'Cachea';

  @override
  String get aboutDataUsageDatabase => 'Datu-basea';

  @override
  String get aboutDataUsageMisc => 'Askotariko';

  @override
  String get aboutDataUsageInternal => 'Barnekoa';

  @override
  String get aboutDataUsageExternal => 'Kanpokoa';

  @override
  String get aboutDataUsageClearCache => 'Garbitu cachea';

  @override
  String get aboutCreditsSectionTitle => 'Kredituak';

  @override
  String get aboutCreditsWorldAtlas1 => 'Aplikazio honek TopoJSON fitxategi bat erabiltzen du';

  @override
  String get aboutCreditsWorldAtlas2 => 'ISC lizentziapekoa.';

  @override
  String get aboutTranslatorsSectionTitle => 'Itzultzaileak';

  @override
  String get aboutLicensesSectionTitle => 'Kode-irekiko lizentziak';

  @override
  String get aboutLicensesBanner => 'Aplikazio honek hurrengo kode-irekiko pakete eta liburutegiak erabiltzen ditu.';

  @override
  String get aboutLicensesAndroidLibrariesSectionTitle => 'Androideko liburutegiak';

  @override
  String get aboutLicensesFlutterPluginsSectionTitle => 'Flutterreko pluginak';

  @override
  String get aboutLicensesFlutterPackagesSectionTitle => 'Flutterreko paketeak';

  @override
  String get aboutLicensesDartPackagesSectionTitle => 'Darteko paketeak';

  @override
  String get aboutLicensesShowAllButtonLabel => 'Lizentzia guztiak erakutsi';

  @override
  String get policyPageTitle => 'Pribatutasun-politika';

  @override
  String get collectionPageTitle => 'Bilduma';

  @override
  String get collectionPickPageTitle => 'Aukeratu';

  @override
  String get collectionSelectPageTitle => 'Elementuak hautatu';

  @override
  String get collectionActionShowTitleSearch => 'Izenburuen iragazkiak erakutsi';

  @override
  String get collectionActionHideTitleSearch => 'Izenburuen iragazkiak ezkutatu';

  @override
  String get collectionActionAddDynamicAlbum => 'Add dynamic album';

  @override
  String get collectionActionAddShortcut => 'Lasterbidea gehitu';

  @override
  String get collectionActionSetHome => 'Ezarri hasiera gisa';

  @override
  String get collectionActionEmptyBin => 'Zakarrontzia hustu';

  @override
  String get collectionActionCopy => 'Kopiatu albumera';

  @override
  String get collectionActionMove => 'Albumera mugitu';

  @override
  String get collectionActionRescan => 'Berreskaneatu';

  @override
  String get collectionActionEdit => 'Editatu';

  @override
  String get collectionSearchTitlesHintText => 'Izenburuak bilatu';

  @override
  String get collectionGroupAlbum => 'Albumaren arabera';

  @override
  String get collectionGroupMonth => 'Hilabetearen arabera';

  @override
  String get collectionGroupDay => 'Egunaren arabera';

  @override
  String get collectionGroupNone => 'Ez taldekatu';

  @override
  String get sectionUnknown => 'Ezezaguna';

  @override
  String get dateToday => 'Gaur';

  @override
  String get dateYesterday => 'Atzo';

  @override
  String get dateThisMonth => 'Hilabete honetan';

  @override
  String collectionDeleteFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Akatsa $count elementu ezabatzean',
      one: 'Akatsa elementu 1 ezabatzean',
    );
    return '$_temp0';
  }

  @override
  String collectionCopyFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Akatsa $count elementu kopiatzean',
      one: 'Akatsa elementu 1 kopiatzean',
    );
    return '$_temp0';
  }

  @override
  String collectionMoveFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Akatsa $count elementu mugitzean',
      one: 'Akatsa elementu 1 mugitzean',
    );
    return '$_temp0';
  }

  @override
  String collectionRenameFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Akatsa $count elementu berrizendatzean',
      one: 'Akatsa elementu 1 berrizendatzean',
    );
    return '$_temp0';
  }

  @override
  String collectionEditFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Akatsa $count elementu editatzean',
      one: 'Akatsa elementu 1 editatzean',
    );
    return '$_temp0';
  }

  @override
  String collectionExportFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Akatsa $count orri esportatzean',
      one: 'Akatsa orri 1 esportatzean',
    );
    return '$_temp0';
  }

  @override
  String collectionCopySuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementu kopiatuta',
      one: 'Elementu 1 kopiatuta',
    );
    return '$_temp0';
  }

  @override
  String collectionMoveSuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementu mugituta',
      one: 'Elementu 1 mugituta',
    );
    return '$_temp0';
  }

  @override
  String collectionRenameSuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementu berrizendatuta',
      one: 'Elementu 1 berrizendatuta',
    );
    return '$_temp0';
  }

  @override
  String collectionEditSuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementu editatuta',
      one: 'Elementu 1 editatuta',
    );
    return '$_temp0';
  }

  @override
  String get collectionEmptyFavourites => 'Gogokorik ez';

  @override
  String get collectionEmptyVideos => 'Bideorik ez';

  @override
  String get collectionEmptyImages => 'Irudirik ez';

  @override
  String get collectionEmptyGrantAccessButtonLabel => 'Sarrera baimendu';

  @override
  String get collectionSelectSectionTooltip => 'Atala aukeratu';

  @override
  String get collectionDeselectSectionTooltip => 'Atala baztertu';

  @override
  String get drawerAboutButton => 'Honi buruz';

  @override
  String get drawerSettingsButton => 'Ezarpenak';

  @override
  String get drawerCollectionAll => 'Bilduma osoa';

  @override
  String get drawerCollectionFavourites => 'Gogokoak';

  @override
  String get drawerCollectionImages => 'Irudiak';

  @override
  String get drawerCollectionVideos => 'Bideoak';

  @override
  String get drawerCollectionAnimated => 'Animazioak';

  @override
  String get drawerCollectionMotionPhotos => 'Mugimendu-argazkiak';

  @override
  String get drawerCollectionPanoramas => 'Panoramikak';

  @override
  String get drawerCollectionRaws => 'Raw argazkiak';

  @override
  String get drawerCollectionSphericalVideos => '360°-ko bideoak';

  @override
  String get drawerAlbumPage => 'Albumak';

  @override
  String get drawerCountryPage => 'Herrialdeak';

  @override
  String get drawerPlacePage => 'Lekuak';

  @override
  String get drawerTagPage => 'Etiketak';

  @override
  String get sortByDate => 'Dataren arabera';

  @override
  String get sortByName => 'Izenaren arabera';

  @override
  String get sortByItemCount => 'Elementuen kopuruaren arabera';

  @override
  String get sortBySize => 'Tamainaren arabera';

  @override
  String get sortByAlbumFileName => 'Album eta fitxategien izenaren arabera';

  @override
  String get sortByRating => 'Balorazioaren arabera';

  @override
  String get sortByDuration => 'Iraupenaren arabera';

  @override
  String get sortOrderNewestFirst => 'Berriena lehenengo';

  @override
  String get sortOrderOldestFirst => 'Zaharrena lehenengo';

  @override
  String get sortOrderAtoZ => 'Atik Zra';

  @override
  String get sortOrderZtoA => 'Ztik Ara';

  @override
  String get sortOrderHighestFirst => 'Altuena lehenengo';

  @override
  String get sortOrderLowestFirst => 'Baxuena lehenengo';

  @override
  String get sortOrderLargestFirst => 'Handiena lehenengo';

  @override
  String get sortOrderSmallestFirst => 'Txikiena lehenengo';

  @override
  String get sortOrderShortestFirst => 'Laburrena lehenik';

  @override
  String get sortOrderLongestFirst => 'Luzeena lehenik';

  @override
  String get albumGroupTier => 'Mailaren arabera';

  @override
  String get albumGroupType => 'Motaren arabera';

  @override
  String get albumGroupVolume => 'Biltegiratze-tamainaren arabera';

  @override
  String get albumGroupNone => 'Ez taldekatu';

  @override
  String get albumMimeTypeMixed => 'Nahastua';

  @override
  String get albumPickPageTitleCopy => 'Kopiatu albumera';

  @override
  String get albumPickPageTitleExport => 'Albumera esportatu';

  @override
  String get albumPickPageTitleMove => 'Albumera mugitu';

  @override
  String get albumPickPageTitlePick => 'Albuma aukeratu';

  @override
  String get albumCamera => 'Kamera';

  @override
  String get albumDownload => 'Deskargatu';

  @override
  String get albumScreenshots => 'Pantaila-argazkiak';

  @override
  String get albumScreenRecordings => 'Pantaila-grabaketak';

  @override
  String get albumVideoCaptures => 'Bideotako argazkiak';

  @override
  String get albumPageTitle => 'Albumak';

  @override
  String get albumEmpty => 'Albumik ez';

  @override
  String get createAlbumButtonLabel => 'SORTU';

  @override
  String get newFilterBanner => 'berria';

  @override
  String get countryPageTitle => 'Herrialdeak';

  @override
  String get countryEmpty => 'Herrialderik ez';

  @override
  String get statePageTitle => 'Egoerak';

  @override
  String get stateEmpty => 'Egoerarik ez';

  @override
  String get placePageTitle => 'Lekuak';

  @override
  String get placeEmpty => 'Lekurik ez';

  @override
  String get tagPageTitle => 'Etiketak';

  @override
  String get tagEmpty => 'Etiketarik ez';

  @override
  String get binPageTitle => 'Zakarrontzia';

  @override
  String get explorerPageTitle => 'Arakatzailea';

  @override
  String get explorerActionSelectStorageVolume => 'Hautatu biltegia';

  @override
  String get selectStorageVolumeDialogTitle => 'Hautatu biltegia';

  @override
  String get searchCollectionFieldHint => 'Bilduman bilatu';

  @override
  String get searchRecentSectionTitle => 'Berria';

  @override
  String get searchDateSectionTitle => 'Data';

  @override
  String get searchFormatSectionTitle => 'Formats';

  @override
  String get searchAlbumsSectionTitle => 'Albumak';

  @override
  String get searchCountriesSectionTitle => 'Herrialdeak';

  @override
  String get searchStatesSectionTitle => 'Egoerak';

  @override
  String get searchPlacesSectionTitle => 'Lekuak';

  @override
  String get searchTagsSectionTitle => 'Etiketak';

  @override
  String get searchRatingSectionTitle => 'Balorazioak';

  @override
  String get searchMetadataSectionTitle => 'Metadatuak';

  @override
  String get settingsPageTitle => 'Ezarpenak';

  @override
  String get settingsSystemDefault => 'Sistemakoa';

  @override
  String get settingsDefault => 'Lehenetsia';

  @override
  String get settingsDisabled => 'Desgaitua';

  @override
  String get settingsAskEverytime => 'Galdetu aldi oro';

  @override
  String get settingsModificationWarningDialogMessage => 'Beste ezarpenak aldatuko dira.';

  @override
  String get settingsSearchFieldLabel => 'Bilaketaren ezarpenak';

  @override
  String get settingsSearchEmpty => 'Kointzidentziarik gabe';

  @override
  String get settingsActionExport => 'Esportatu';

  @override
  String get settingsActionExportDialogTitle => 'Esportazio';

  @override
  String get settingsActionImport => 'Inportatu';

  @override
  String get settingsActionImportDialogTitle => 'Inportazio';

  @override
  String get appExportCovers => 'Azalak';

  @override
  String get appExportDynamicAlbums => 'Dynamic albums';

  @override
  String get appExportFavourites => 'Gogokoak';

  @override
  String get appExportSettings => 'Ezarpenak';

  @override
  String get settingsNavigationSectionTitle => 'Nabigazio';

  @override
  String get settingsHomeTile => 'Hasiera';

  @override
  String get settingsHomeDialogTitle => 'Hasiera';

  @override
  String get setHomeCustom => 'Pertsonalizatua';

  @override
  String get settingsShowBottomNavigationBar => 'Azpiko nabigazio-barra erakutsi';

  @override
  String get settingsKeepScreenOnTile => 'Mantendu pantaila piztuta';

  @override
  String get settingsKeepScreenOnDialogTitle => 'Mantendu pantaila piztuta';

  @override
  String get settingsDoubleBackExit => 'Sakatu «atzera» bi aldiz irteteko';

  @override
  String get settingsConfirmationTile => 'Baieztapen-leihoak';

  @override
  String get settingsConfirmationDialogTitle => 'Baieztapen-leihoak';

  @override
  String get settingsConfirmationBeforeDeleteItems => 'Galdetu elementuak betirako ezabatu aurretik';

  @override
  String get settingsConfirmationBeforeMoveToBinItems => 'Galdetu elementuak zakarrontzira bidali aurretik';

  @override
  String get settingsConfirmationBeforeMoveUndatedItems => 'Galdetu data ez duten elementuak mugitu aurretik';

  @override
  String get settingsConfirmationAfterMoveToBinItems => 'Mezua erakutsi elementuak zakarrontzira bidali ondoren';

  @override
  String get settingsConfirmationVaultDataLoss => 'Erakutsi kutxa gotorreko datuen galeraren inguruko abisua';

  @override
  String get settingsNavigationDrawerTile => 'Nabigazio-menua';

  @override
  String get settingsNavigationDrawerEditorPageTitle => 'Nabigazio-menua';

  @override
  String get settingsNavigationDrawerBanner => 'Sakatu eta mantendu menuko elementuak mugitu edo berrordenatzeko.';

  @override
  String get settingsNavigationDrawerTabTypes => 'Motak';

  @override
  String get settingsNavigationDrawerTabAlbums => 'Albumak';

  @override
  String get settingsNavigationDrawerTabPages => 'Orriak';

  @override
  String get settingsNavigationDrawerAddAlbum => 'Albuma gehitu';

  @override
  String get settingsThumbnailSectionTitle => 'Miniaturak';

  @override
  String get settingsThumbnailOverlayTile => 'Inkrustazioak';

  @override
  String get settingsThumbnailOverlayPageTitle => 'Inkrustazioak';

  @override
  String get settingsThumbnailShowHdrIcon => 'Erakutsi HDR ikonoa';

  @override
  String get settingsThumbnailShowFavouriteIcon => 'Erakutsi gogokoen ikonoa';

  @override
  String get settingsThumbnailShowTagIcon => 'Erakutsi etiketaren ikonoa';

  @override
  String get settingsThumbnailShowLocationIcon => 'Erakutsi kokalekuaren ikonoa';

  @override
  String get settingsThumbnailShowMotionPhotoIcon => 'Erakutsi mugimendu-argazkiaren ikonoa';

  @override
  String get settingsThumbnailShowRating => 'Erakutsi balorazioa';

  @override
  String get settingsThumbnailShowRawIcon => 'Erakutsi raw ikonoa';

  @override
  String get settingsThumbnailShowVideoDuration => 'Erakutsi bideoaren iraupena';

  @override
  String get settingsCollectionQuickActionsTile => 'Ekintza azkarrak';

  @override
  String get settingsCollectionQuickActionEditorPageTitle => 'Ekintza azkarrak';

  @override
  String get settingsCollectionQuickActionTabBrowsing => 'Araketa';

  @override
  String get settingsCollectionQuickActionTabSelecting => 'Hautapena';

  @override
  String get settingsCollectionBrowsingQuickActionEditorBanner => 'Sakatu eta luze mantendu botoiak mugitzeko eta elementuak arakatzean zein ekintza bistaratuko diren aukeratzeko.';

  @override
  String get settingsCollectionSelectionQuickActionEditorBanner => 'Sakatu eta luze mantendu botoiak mugitzeko eta elementuak aukeratzerakoan zein ekintza bistaratuko diren aukeratzeko.';

  @override
  String get settingsCollectionBurstPatternsTile => 'Segida ereduak';

  @override
  String get settingsCollectionBurstPatternsNone => 'Bat ere ez';

  @override
  String get settingsViewerSectionTitle => 'Bisorea';

  @override
  String get settingsViewerGestureSideTapNext => 'Pantailaren ertzetan sakatu aurreko/hurrengo elementua bistaratzeko';

  @override
  String get settingsViewerUseCutout => 'Erabili moztutako eremua';

  @override
  String get settingsViewerMaximumBrightness => 'Gehienezko distira';

  @override
  String get settingsMotionPhotoAutoPlay => 'Automatikoki erreproduzitu mugimendu-argazkiak';

  @override
  String get settingsImageBackground => 'Atzeko irudia';

  @override
  String get settingsViewerQuickActionsTile => 'Ekintza azkarrak';

  @override
  String get settingsViewerQuickActionEditorPageTitle => 'Ekintza azkarrak';

  @override
  String get settingsViewerQuickActionEditorBanner => 'Sakatu eta luze mantendu botoiak mugitzeko eta bisorean zein ekintza bistaratuko diren aukeratzeko.';

  @override
  String get settingsViewerQuickActionEditorDisplayedButtonsSectionTitle => 'Bistaratutako botoiak';

  @override
  String get settingsViewerQuickActionEditorAvailableButtonsSectionTitle => 'Botoi erabilgarriak';

  @override
  String get settingsViewerQuickActionEmpty => 'Botoirik ez';

  @override
  String get settingsViewerOverlayTile => 'Inkrustazioak';

  @override
  String get settingsViewerOverlayPageTitle => 'Inkrustazioak';

  @override
  String get settingsViewerShowOverlayOnOpening => 'Erakutsi irekitzean';

  @override
  String get settingsViewerShowHistogram => 'Erakutsi histograma';

  @override
  String get settingsViewerShowMinimap => 'Erakutsi minimapa';

  @override
  String get settingsViewerShowInformation => 'Erakutsi informazioa';

  @override
  String get settingsViewerShowInformationSubtitle => 'Erakutsi izenburua, data, kokalekua, etab.';

  @override
  String get settingsViewerShowRatingTags => 'Erakutsi balorazioa eta etiketak';

  @override
  String get settingsViewerShowShootingDetails => 'Erakutsi hartualdiaren xehetasunak';

  @override
  String get settingsViewerShowDescription => 'Erakutsi azalpena';

  @override
  String get settingsViewerShowOverlayThumbnails => 'Erakutsi miniaturak';

  @override
  String get settingsViewerEnableOverlayBlurEffect => 'Lausotze efektua';

  @override
  String get settingsViewerSlideshowTile => 'Aurkezpena';

  @override
  String get settingsViewerSlideshowPageTitle => 'Aurkezpena';

  @override
  String get settingsSlideshowRepeat => 'Errepikatu';

  @override
  String get settingsSlideshowShuffle => 'Nahastu';

  @override
  String get settingsSlideshowFillScreen => 'Bete pantaila';

  @override
  String get settingsSlideshowAnimatedZoomEffect => 'Zoom animatuaren efektua';

  @override
  String get settingsSlideshowTransitionTile => 'Trantsizioa';

  @override
  String get settingsSlideshowIntervalTile => 'Tartea';

  @override
  String get settingsSlideshowVideoPlaybackTile => 'Bideo-erreprodukzioa';

  @override
  String get settingsSlideshowVideoPlaybackDialogTitle => 'Bideo-erreprodukzioa';

  @override
  String get settingsVideoPageTitle => 'Bideoaren ezarpenak';

  @override
  String get settingsVideoSectionTitle => 'Bideoa';

  @override
  String get settingsVideoShowVideos => 'Erakutsi bideoak';

  @override
  String get settingsVideoPlaybackTile => 'Erreprodukzioa';

  @override
  String get settingsVideoPlaybackPageTitle => 'Erreprodukzioa';

  @override
  String get settingsVideoEnableHardwareAcceleration => 'Hardwarearen azelerazioa';

  @override
  String get settingsVideoAutoPlay => 'Autoerreprodukzioa';

  @override
  String get settingsVideoLoopModeTile => 'Begizta modua';

  @override
  String get settingsVideoLoopModeDialogTitle => 'Begizta modua';

  @override
  String get settingsVideoResumptionModeTile => 'Jarraitu erreprodukzioa';

  @override
  String get settingsVideoResumptionModeDialogTitle => 'Jarraitu erreprodukzioa';

  @override
  String get settingsVideoBackgroundMode => 'Atzeko planoko modua';

  @override
  String get settingsVideoBackgroundModeDialogTitle => 'Atzeko planoko modua';

  @override
  String get settingsVideoControlsTile => 'Aginteak';

  @override
  String get settingsVideoControlsPageTitle => 'Aginteak';

  @override
  String get settingsVideoButtonsTile => 'Botoiak';

  @override
  String get settingsVideoGestureDoubleTapTogglePlay => 'Bi aldiz sakatu erreproduzitzeko/gelditzeko';

  @override
  String get settingsVideoGestureSideDoubleTapSeek => 'Pantailaren ertzetan bi aldiz sakatu aurrera/atzera egiteko';

  @override
  String get settingsVideoGestureVerticalDragBrightnessVolume => 'Gora edo behera irristatu distira/bolumena egokitzeko';

  @override
  String get settingsSubtitleThemeTile => 'Azpitituluak';

  @override
  String get settingsSubtitleThemePageTitle => 'Azpitituluak';

  @override
  String get settingsSubtitleThemeSample => 'Hau adibide bat da.';

  @override
  String get settingsSubtitleThemeTextAlignmentTile => 'Testuaren lerrokatzea';

  @override
  String get settingsSubtitleThemeTextAlignmentDialogTitle => 'Testuaren lerrokatzea';

  @override
  String get settingsSubtitleThemeTextPositionTile => 'Testuaren posizioa';

  @override
  String get settingsSubtitleThemeTextPositionDialogTitle => 'Testuaren posizioa';

  @override
  String get settingsSubtitleThemeTextSize => 'Testuaren tamaina';

  @override
  String get settingsSubtitleThemeShowOutline => 'Bistaratu ingerada eta itzala';

  @override
  String get settingsSubtitleThemeTextColor => 'Testuaren kolorea';

  @override
  String get settingsSubtitleThemeTextOpacity => 'Testuaren opakutasuna';

  @override
  String get settingsSubtitleThemeBackgroundColor => 'Atzeko kolorea';

  @override
  String get settingsSubtitleThemeBackgroundOpacity => 'Atzeko opakutasuna';

  @override
  String get settingsSubtitleThemeTextAlignmentLeft => 'Ezkerra';

  @override
  String get settingsSubtitleThemeTextAlignmentCenter => 'Erdigune';

  @override
  String get settingsSubtitleThemeTextAlignmentRight => 'Eskuina';

  @override
  String get settingsPrivacySectionTitle => 'Pribatutasuna';

  @override
  String get settingsAllowInstalledAppAccess => 'Aplikazioen zerrendarako sarrera baimendu';

  @override
  String get settingsAllowInstalledAppAccessSubtitle => 'Albumen bistaratzea hobetzeko erabilia';

  @override
  String get settingsAllowErrorReporting => 'Onartu akatsen txosten anonimoa';

  @override
  String get settingsSaveSearchHistory => 'Gorde bilaketen historia';

  @override
  String get settingsEnableBin => 'Erabili zakarrontzia';

  @override
  String get settingsEnableBinSubtitle => 'Mantendu ezabatutako elementuak 30 egunez';

  @override
  String get settingsDisablingBinWarningDialogMessage => 'Zakarrontziko elementuak betirako ezabatuko dira.';

  @override
  String get settingsAllowMediaManagement => 'Baimendu mediaren kudeaketa';

  @override
  String get settingsHiddenItemsTile => 'Ezkutuko elementuak';

  @override
  String get settingsHiddenItemsPageTitle => 'Ezkutuko elementuak';

  @override
  String get settingsHiddenFiltersBanner => 'Iragazkiekin bat datozen argazki eta bideoak ez dira zure bilduman agertuko.';

  @override
  String get settingsHiddenFiltersEmpty => 'Ezkutuko iragazkirik ez';

  @override
  String get settingsStorageAccessTile => 'Biltegiratzerako sarrera';

  @override
  String get settingsStorageAccessPageTitle => 'Biltegiratzerako sarrera';

  @override
  String get settingsStorageAccessBanner => 'Karpeta batzuek baimen berezi bat behar dute bertak fitxategiak edita ahal izateko. Hemen, lehendik baimena eman diezun karpetak ikus ditzakezu.';

  @override
  String get settingsStorageAccessEmpty => 'Baimenik ez';

  @override
  String get settingsStorageAccessRevokeTooltip => 'Ezeztatu';

  @override
  String get settingsAccessibilitySectionTitle => 'Irisgarritasuna';

  @override
  String get settingsRemoveAnimationsTile => 'Kendu animazioak';

  @override
  String get settingsRemoveAnimationsDialogTitle => 'Kendu animazioak';

  @override
  String get settingsTimeToTakeActionTile => 'Ekintza aurretik igarotako denbora';

  @override
  String get settingsAccessibilityShowPinchGestureAlternatives => 'Ukimen ugariko keinu alternatiboak erakutsi';

  @override
  String get settingsDisplaySectionTitle => 'Pantaila';

  @override
  String get settingsThemeBrightnessTile => 'Gaia';

  @override
  String get settingsThemeBrightnessDialogTitle => 'Gaia';

  @override
  String get settingsThemeColorHighlights => 'Nabarmen koloreak';

  @override
  String get settingsThemeEnableDynamicColor => 'Kolore dinamikoa';

  @override
  String get settingsDisplayRefreshRateModeTile => 'Pantailaren freskatze-maiztasuna';

  @override
  String get settingsDisplayRefreshRateModeDialogTitle => 'Freskatze-maiztasuna';

  @override
  String get settingsDisplayUseTvInterface => 'Android TV interfazea';

  @override
  String get settingsLanguageSectionTitle => 'Hizkuntza eta formatuak';

  @override
  String get settingsLanguageTile => 'Hizkuntza';

  @override
  String get settingsLanguagePageTitle => 'Hizkuntza';

  @override
  String get settingsCoordinateFormatTile => 'Koordenatuen formatua';

  @override
  String get settingsCoordinateFormatDialogTitle => 'Koordenatuen formatua';

  @override
  String get settingsUnitSystemTile => 'Unitateak';

  @override
  String get settingsUnitSystemDialogTitle => 'Unitateak';

  @override
  String get settingsForceWesternArabicNumeralsTile => 'Behartu arabiar zifrak';

  @override
  String get settingsScreenSaverPageTitle => 'Pantaila-babeslea';

  @override
  String get settingsWidgetPageTitle => 'Argazki-markoa';

  @override
  String get settingsWidgetShowOutline => 'Ingerada';

  @override
  String get settingsWidgetOpenPage => 'Widgetan sakatzean';

  @override
  String get settingsWidgetDisplayedItem => 'Bistaratutako elementua';

  @override
  String get settingsCollectionTile => 'Bilduma';

  @override
  String get statsPageTitle => 'Estatistikak';

  @override
  String statsWithGps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementu kokapenarekin',
      one: 'Elementu 1 kokapenarekin',
    );
    return '$_temp0';
  }

  @override
  String get statsTopCountriesSectionTitle => 'Herrialde nagusiak';

  @override
  String get statsTopStatesSectionTitle => 'Egoera Nagusiak';

  @override
  String get statsTopPlacesSectionTitle => 'Leku nagusiak';

  @override
  String get statsTopTagsSectionTitle => 'Etiketa nagusiak';

  @override
  String get statsTopAlbumsSectionTitle => 'Album nagusiak';

  @override
  String get viewerOpenPanoramaButtonLabel => 'IREKI PANORAMIKA';

  @override
  String get viewerSetWallpaperButtonLabel => 'EZARRI HORMA-PAPERA';

  @override
  String get viewerErrorUnknown => 'Ui!';

  @override
  String get viewerErrorDoesNotExist => 'Fitxategia jada ez da existitzen.';

  @override
  String get viewerInfoPageTitle => 'Informazioa';

  @override
  String get viewerInfoBackToViewerTooltip => 'Itzuli bisorera';

  @override
  String get viewerInfoUnknown => 'ezezaguna';

  @override
  String get viewerInfoLabelDescription => 'Deskribapena';

  @override
  String get viewerInfoLabelTitle => 'Izenburua';

  @override
  String get viewerInfoLabelDate => 'Data';

  @override
  String get viewerInfoLabelResolution => 'Bereizmena';

  @override
  String get viewerInfoLabelSize => 'Tamaina';

  @override
  String get viewerInfoLabelUri => 'URI';

  @override
  String get viewerInfoLabelPath => 'Bidea';

  @override
  String get viewerInfoLabelDuration => 'Iraupena';

  @override
  String get viewerInfoLabelOwner => 'Jabea';

  @override
  String get viewerInfoLabelCoordinates => 'Koordenatuak';

  @override
  String get viewerInfoLabelAddress => 'Helbidea';

  @override
  String get mapStyleDialogTitle => 'Maparen estiloa';

  @override
  String get mapStyleTooltip => 'Hautatu maparen estiloa';

  @override
  String get mapZoomInTooltip => 'Hurreratu';

  @override
  String get mapZoomOutTooltip => 'Aldendu';

  @override
  String get mapPointNorthUpTooltip => 'Zuzendu iparra gorantz';

  @override
  String get mapAttributionOsmData => 'Maparen datuak © [OpenStreetMap](https://www.openstreetmap.org/copyright)-en laguntzaileak';

  @override
  String get mapAttributionOsmLiberty => 'Lauzak: [OpenMapTiles](https://www.openmaptiles.org/), [CC BY](http://creativecommons.org/licenses/by/4.0) • Ostalaria: [OSM Americana](https://tile.ourmap.us)';

  @override
  String get mapAttributionOpenTopoMap => '[SRTM](https://www.earthdata.nasa.gov/sensors/srtm) | Lauzak: [OpenTopoMap](https://opentopomap.org/), [CC BY-SA](https://creativecommons.org/licenses/by-sa/3.0/)';

  @override
  String get mapAttributionOsmHot => 'Lauzak: [HOT](https://www.hotosm.org/) • Ostalaria: [OSM France](https://openstreetmap.fr/)';

  @override
  String get mapAttributionStamen => 'Lauzak: [Stamen Design](https://stamen.com), [CC BY 3.0](https://creativecommons.org/licenses/by/3.0)';

  @override
  String get openMapPageTooltip => 'Ikusi maparen gunean';

  @override
  String get mapEmptyRegion => 'Irudirik ez eskualde honetan';

  @override
  String get viewerInfoOpenEmbeddedFailureFeedback => 'Huts egitea erantsitako data ateratzean';

  @override
  String get viewerInfoOpenLinkText => 'Ireki';

  @override
  String get viewerInfoViewXmlLinkText => 'Ikusi XML';

  @override
  String get viewerInfoSearchFieldLabel => 'Bilatu metadatuak';

  @override
  String get viewerInfoSearchEmpty => 'Bat datozen gakorik ez';

  @override
  String get viewerInfoSearchSuggestionDate => 'Data eta ordua';

  @override
  String get viewerInfoSearchSuggestionDescription => 'Deskribapena';

  @override
  String get viewerInfoSearchSuggestionDimensions => 'Dimentsioak';

  @override
  String get viewerInfoSearchSuggestionResolution => 'Bereizmena';

  @override
  String get viewerInfoSearchSuggestionRights => 'Eskubideak';

  @override
  String get wallpaperUseScrollEffect => 'Erabili lekualdatze-efektua hasierako pantailan';

  @override
  String get tagEditorPageTitle => 'Editatu etiketak';

  @override
  String get tagEditorPageNewTagFieldLabel => 'Etiketa berria';

  @override
  String get tagEditorPageAddTagTooltip => 'Gehitu etiketa';

  @override
  String get tagEditorSectionRecent => 'Berrienak';

  @override
  String get tagEditorSectionPlaceholders => 'Leku-markak';

  @override
  String get tagEditorDiscardDialogMessage => 'Aldaketak baztertu nahi dituzu?';

  @override
  String get tagPlaceholderCountry => 'Herrialdea';

  @override
  String get tagPlaceholderState => 'Egoera';

  @override
  String get tagPlaceholderPlace => 'Lekua';

  @override
  String get panoramaEnableSensorControl => 'Gaitu sentsoreen agintea';

  @override
  String get panoramaDisableSensorControl => 'Desgaitu sentsoreen agintea';

  @override
  String get sourceViewerPageTitle => 'Iturria';

  @override
  String get filePickerShowHiddenFiles => 'Erakutsi ezkutuko fitxategiak';

  @override
  String get filePickerDoNotShowHiddenFiles => 'Ez erakutsi ezkutuko fitxategiak';

  @override
  String get filePickerOpenFrom => 'Ireki hemendik';

  @override
  String get filePickerNoItems => 'Elementurik ez';

  @override
  String get filePickerUseThisFolder => 'Erabili karpeta hau';
}
