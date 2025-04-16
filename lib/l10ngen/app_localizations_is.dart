// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Icelandic (`is`).
class AppLocalizationsIs extends AppLocalizations {
  AppLocalizationsIs([String locale = 'is']) : super(locale);

  @override
  String get appName => 'Aves';

  @override
  String get welcomeMessage => 'Velkomin í Aves';

  @override
  String get welcomeOptional => 'Valfrjálst';

  @override
  String get welcomeTermsToggle => 'Ég samþykki skilmálana og kvaðir';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count atriðum',
      one: '$count atriði',
    );
    return '$_temp0';
  }

  @override
  String columnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dálkar',
      one: '$count dálkur',
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
      other: '$countString sekúndur',
      one: '$countString sekúnda',
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
      other: '$countString mínútur',
      one: '$countString mínúta',
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
      one: '$countString dagur',
    );
    return '$_temp0';
  }

  @override
  String focalLength(String length) {
    return '$length mm';
  }

  @override
  String get applyButtonLabel => 'VIRKJA';

  @override
  String get deleteButtonLabel => 'EYÐA';

  @override
  String get nextButtonLabel => 'NÆSTA';

  @override
  String get showButtonLabel => 'BIRTA';

  @override
  String get hideButtonLabel => 'FELA';

  @override
  String get continueButtonLabel => 'HALDA ÁFRAM';

  @override
  String get saveCopyButtonLabel => 'VISTA AFRIT';

  @override
  String get applyTooltip => 'Virkja';

  @override
  String get cancelTooltip => 'Hætta við';

  @override
  String get changeTooltip => 'Breyta';

  @override
  String get clearTooltip => 'Hreinsa';

  @override
  String get previousTooltip => 'Fyrra';

  @override
  String get nextTooltip => 'Næsta';

  @override
  String get showTooltip => 'Birta';

  @override
  String get hideTooltip => 'Fela';

  @override
  String get actionRemove => 'Fjarlægja';

  @override
  String get resetTooltip => 'Endurstilla';

  @override
  String get saveTooltip => 'Vista';

  @override
  String get stopTooltip => 'Stöðva';

  @override
  String get pickTooltip => 'Veldu';

  @override
  String get doubleBackExitMessage => 'Ýttu aftur á „Til baka“ til að hætta.';

  @override
  String get doNotAskAgain => 'Ekki spyrja aftur';

  @override
  String get sourceStateLoading => 'Innhleðsla';

  @override
  String get sourceStateCataloguing => 'Gerð efnisyfirlits';

  @override
  String get sourceStateLocatingCountries => 'Staðset lönd';

  @override
  String get sourceStateLocatingPlaces => 'Staðset staði';

  @override
  String get chipActionDelete => 'Eyða';

  @override
  String get chipActionRemove => 'Fjarlægja';

  @override
  String get chipActionShowCollection => 'Sýna í safni';

  @override
  String get chipActionGoToAlbumPage => 'Birta í Albúm';

  @override
  String get chipActionGoToCountryPage => 'Birta í Lönd';

  @override
  String get chipActionGoToPlacePage => 'Birta í Staðir';

  @override
  String get chipActionGoToTagPage => 'Birta í Merki';

  @override
  String get chipActionGoToExplorerPage => 'Sýna í skráastjóra';

  @override
  String get chipActionDecompose => 'Skipta upp';

  @override
  String get chipActionFilterOut => 'Sía út';

  @override
  String get chipActionFilterIn => 'Sía inn';

  @override
  String get chipActionHide => 'Fela';

  @override
  String get chipActionLock => 'Læsa';

  @override
  String get chipActionPin => 'Festa efst';

  @override
  String get chipActionUnpin => 'Losa af efri hluta';

  @override
  String get chipActionRename => 'Endurnefna';

  @override
  String get chipActionSetCover => 'Setja umslag';

  @override
  String get chipActionShowCountryStates => 'Birta héruð';

  @override
  String get chipActionCreateAlbum => 'Búa til albúm';

  @override
  String get chipActionCreateVault => 'Búa til öryggisgeymslu';

  @override
  String get chipActionConfigureVault => 'Stilla öryggisgeymslu';

  @override
  String get entryActionCopyToClipboard => 'Afrita á klippispjald';

  @override
  String get entryActionDelete => 'Eyða';

  @override
  String get entryActionConvert => 'Umbreyta';

  @override
  String get entryActionExport => 'Flytja út';

  @override
  String get entryActionInfo => 'Upplýsingar';

  @override
  String get entryActionRename => 'Endurnefna';

  @override
  String get entryActionRestore => 'Endurheimta';

  @override
  String get entryActionRotateCCW => 'Snúa rangsælis';

  @override
  String get entryActionRotateCW => 'Snúa réttsælis';

  @override
  String get entryActionFlip => 'Fletta lárétt';

  @override
  String get entryActionPrint => 'Prenta';

  @override
  String get entryActionShare => 'Deila';

  @override
  String get entryActionShareImageOnly => 'Deila einungis mynd';

  @override
  String get entryActionShareVideoOnly => 'Deila einungis myndskeiði';

  @override
  String get entryActionViewSource => 'Skoða uppruna';

  @override
  String get entryActionShowGeoTiffOnMap => 'Birta sem yfirlag á korti';

  @override
  String get entryActionConvertMotionPhotoToStillImage => 'Umbreyta í kyrrmynd';

  @override
  String get entryActionViewMotionPhotoVideo => 'Opna myndskeið';

  @override
  String get entryActionEdit => 'Breyta';

  @override
  String get entryActionOpen => 'Opna með';

  @override
  String get entryActionSetAs => 'Setja sem';

  @override
  String get entryActionCast => 'Leikarar';

  @override
  String get entryActionOpenMap => 'Birta í landakortaforriti';

  @override
  String get entryActionRotateScreen => 'Snúa skjánum';

  @override
  String get entryActionAddFavourite => 'Bæta í eftirlæti';

  @override
  String get entryActionRemoveFavourite => 'Fjarlægja úr eftirlætum';

  @override
  String get videoActionCaptureFrame => 'Taka ramma';

  @override
  String get videoActionMute => 'Hljóð af';

  @override
  String get videoActionUnmute => 'Hljóð á';

  @override
  String get videoActionPause => 'Í bið';

  @override
  String get videoActionPlay => 'Afspilun';

  @override
  String get videoActionReplay10 => 'Fara afturábak um 10 sekúndur';

  @override
  String get videoActionSkip10 => 'Fara áfram um 10 sekúndur';

  @override
  String get videoActionShowPreviousFrame => 'Sýna fyrri ramma';

  @override
  String get videoActionShowNextFrame => 'Sýna næsta ramma';

  @override
  String get videoActionSelectStreams => 'Veldu ferla';

  @override
  String get videoActionSetSpeed => 'Afspilunarhraði';

  @override
  String get videoActionABRepeat => 'Endurtekning A-B';

  @override
  String get videoRepeatActionSetStart => 'Stilla byrjun';

  @override
  String get videoRepeatActionSetEnd => 'Stilla endi';

  @override
  String get viewerActionSettings => 'Stillingar';

  @override
  String get viewerActionLock => 'Læsa skoðara';

  @override
  String get viewerActionUnlock => 'Aflæsa skoðara';

  @override
  String get slideshowActionResume => 'Halda áfram';

  @override
  String get slideshowActionShowInCollection => 'Sýna í safni';

  @override
  String get entryInfoActionEditDate => 'Breyta dagsetningu og tíma';

  @override
  String get entryInfoActionEditLocation => 'Breyta staðsetningu';

  @override
  String get entryInfoActionEditTitleDescription => 'Breyta titli og lýsingu';

  @override
  String get entryInfoActionEditRating => 'Breyta einkunn';

  @override
  String get entryInfoActionEditTags => 'Breyta merkjum';

  @override
  String get entryInfoActionRemoveMetadata => 'Fjarlægja lýsigögn';

  @override
  String get entryInfoActionExportMetadata => 'Flytja út lýsigögn';

  @override
  String get entryInfoActionRemoveLocation => 'Fjarlægja staðsetningu';

  @override
  String get editorActionTransform => 'Ummyndun';

  @override
  String get editorTransformCrop => 'Utansníða';

  @override
  String get editorTransformRotate => 'Snúa';

  @override
  String get cropAspectRatioFree => 'Frjálst';

  @override
  String get cropAspectRatioOriginal => 'Upprunaleg';

  @override
  String get cropAspectRatioSquare => 'Ferningur';

  @override
  String get filterAspectRatioLandscapeLabel => 'Lárétt';

  @override
  String get filterAspectRatioPortraitLabel => 'Lóðrétt';

  @override
  String get filterBinLabel => 'Ruslmappa';

  @override
  String get filterFavouriteLabel => 'Eftirlæti';

  @override
  String get filterNoDateLabel => 'Ódagsett';

  @override
  String get filterNoAddressLabel => 'Ekkert heimilisfang';

  @override
  String get filterLocatedLabel => 'Staðsett';

  @override
  String get filterNoLocationLabel => 'Óstaðsett';

  @override
  String get filterNoRatingLabel => 'Án einkunnar';

  @override
  String get filterTaggedLabel => 'Merkt';

  @override
  String get filterNoTagLabel => 'Ómerkt';

  @override
  String get filterNoTitleLabel => 'Án titils';

  @override
  String get filterOnThisDayLabel => 'Á þessum degi';

  @override
  String get filterRecentlyAddedLabel => 'Nýlega bætt við';

  @override
  String get filterRatingRejectedLabel => 'Hafnað';

  @override
  String get filterTypeAnimatedLabel => 'Með hreyfingu';

  @override
  String get filterTypeMotionPhotoLabel => 'Hreyfiljósmynd';

  @override
  String get filterTypePanoramaLabel => 'Víðmynd';

  @override
  String get filterTypeRawLabel => 'RAW';

  @override
  String get filterTypeSphericalVideoLabel => '360° myndskeið';

  @override
  String get filterTypeGeotiffLabel => 'GeoTIFF';

  @override
  String get filterMimeImageLabel => 'Mynd';

  @override
  String get filterMimeVideoLabel => 'Myndskeið';

  @override
  String get accessibilityAnimationsRemove => 'Koma í veg fyrir skjábrellur';

  @override
  String get accessibilityAnimationsKeep => 'Halda skjábrellum';

  @override
  String get albumTierNew => 'Nýtt';

  @override
  String get albumTierPinned => 'Fest';

  @override
  String get albumTierSpecial => 'Algengt';

  @override
  String get albumTierApps => 'Forrit';

  @override
  String get albumTierVaults => 'Öryggisgeymslur';

  @override
  String get albumTierDynamic => 'Breytilegt';

  @override
  String get albumTierRegular => 'Annað';

  @override
  String get coordinateFormatDms => 'DMS';

  @override
  String get coordinateFormatDdm => 'DDM';

  @override
  String get coordinateFormatDecimal => 'Gráður í tugakerfi';

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
  String get displayRefreshRatePreferHighest => 'Hæsti hraði';

  @override
  String get displayRefreshRatePreferLowest => 'Lægsti hraði';

  @override
  String get keepScreenOnNever => 'Aldrei';

  @override
  String get keepScreenOnVideoPlayback => 'Á meðan myndskeið er í spilun';

  @override
  String get keepScreenOnViewerOnly => 'Aðeins síða skoðara';

  @override
  String get keepScreenOnAlways => 'Alltaf';

  @override
  String get lengthUnitPixel => 'px';

  @override
  String get lengthUnitPercent => '%';

  @override
  String get mapStyleGoogleNormal => 'Google Maps';

  @override
  String get mapStyleGoogleHybrid => 'Google Maps (blandað)';

  @override
  String get mapStyleGoogleTerrain => 'Google Maps (yfirborð)';

  @override
  String get mapStyleOsmLiberty => 'OSM Liberty';

  @override
  String get mapStyleOpenTopoMap => 'OpenTopoMap';

  @override
  String get mapStyleOsmHot => 'OSM fyrir hjálparstarf';

  @override
  String get mapStyleStamenWatercolor => 'Stamen-vatnslitir';

  @override
  String get maxBrightnessNever => 'Aldrei';

  @override
  String get maxBrightnessAlways => 'Alltaf';

  @override
  String get nameConflictStrategyRename => 'Endurnefna';

  @override
  String get nameConflictStrategyReplace => 'Skipta út';

  @override
  String get nameConflictStrategySkip => 'Sleppa';

  @override
  String get overlayHistogramNone => 'Ekkert';

  @override
  String get overlayHistogramRGB => 'RGB';

  @override
  String get overlayHistogramLuminance => 'Ljómi';

  @override
  String get subtitlePositionTop => 'Efst';

  @override
  String get subtitlePositionBottom => 'Neðst';

  @override
  String get themeBrightnessLight => 'Ljóst';

  @override
  String get themeBrightnessDark => 'Dökkt';

  @override
  String get themeBrightnessBlack => 'Svart';

  @override
  String get unitSystemMetric => 'Metrakerfi';

  @override
  String get unitSystemImperial => 'Breskt Imperial kerfi';

  @override
  String get vaultLockTypePattern => 'Mynstur';

  @override
  String get vaultLockTypePin => 'PIN-númer';

  @override
  String get vaultLockTypePassword => 'Lykilorð';

  @override
  String get settingsVideoEnablePip => 'Mynd-í-mynd';

  @override
  String get videoControlsPlayOutside => 'Opna með öðrum spilara';

  @override
  String get videoLoopModeNever => 'Aldrei';

  @override
  String get videoLoopModeShortOnly => 'Einungis stutt myndskeið';

  @override
  String get videoLoopModeAlways => 'Alltaf';

  @override
  String get videoPlaybackSkip => 'Sleppa';

  @override
  String get videoPlaybackMuted => 'Afspilun án hljóðs';

  @override
  String get videoPlaybackWithSound => 'Afspilun með hljóði';

  @override
  String get videoResumptionModeNever => 'Aldrei';

  @override
  String get videoResumptionModeAlways => 'Alltaf';

  @override
  String get viewerTransitionSlide => 'Renna';

  @override
  String get viewerTransitionParallax => 'Hliðrun';

  @override
  String get viewerTransitionFade => 'Deyfing';

  @override
  String get viewerTransitionZoomIn => 'Renna að';

  @override
  String get viewerTransitionNone => 'Ekkert';

  @override
  String get wallpaperTargetHome => 'Upphafsskjár';

  @override
  String get wallpaperTargetLock => 'Læsa skjá';

  @override
  String get wallpaperTargetHomeLock => 'Upphafs- og lásskjáir';

  @override
  String get widgetDisplayedItemRandom => 'Handahóf';

  @override
  String get widgetDisplayedItemMostRecent => 'Nýlegast';

  @override
  String get widgetOpenPageHome => 'Opna upphafsskjá';

  @override
  String get widgetOpenPageCollection => 'Opna myndasafn';

  @override
  String get widgetOpenPageViewer => 'Opna skoðara';

  @override
  String get widgetTapUpdateWidget => 'Uppfæra viðmótshluta';

  @override
  String get storageVolumeDescriptionFallbackPrimary => 'innbyggðri geymslu';

  @override
  String get storageVolumeDescriptionFallbackNonPrimary => 'SD-minniskorti';

  @override
  String get rootDirectoryDescription => 'rótarmöppu';

  @override
  String otherDirectoryDescription(String name) {
    return '„$name“ möppu';
  }

  @override
  String storageAccessDialogMessage(String directory, String volume) {
    return 'Veldu $directory á „$volume“ í næsta skjá til að gefa forritinu aðgang að henni.';
  }

  @override
  String restrictedAccessDialogMessage(String directory, String volume) {
    return 'Þessu forriti er ekki heimilt að breyta skrám í $directory á „$volume“.\n\nNotaðu for-uppsettan skráastjóra eða myndasafnsforrit til að færa atriðin í aðra möppu.';
  }

  @override
  String notEnoughSpaceDialogMessage(String neededSize, String freeSize, String volume) {
    return 'Þessi aðgerð þarfnast $neededSize af lausu plássi á „$volume“ til að geta klárað, en einungis $freeSize eru eftir.';
  }

  @override
  String get missingSystemFilePickerDialogMessage => 'Skráaveljari kerfisins er óvirkur eða hann vantar. Virkjaðu hann og reydu síðan aftur.';

  @override
  String unsupportedTypeDialogMessage(int count, String types) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Þessi aðgerð er ekki studd fyrir atriði af eftirfarandi tegundum: $types.',
      one: 'Þessi aðgerð er ekki studd fyrir atriði af tegundinni: $types.',
    );
    return '$_temp0';
  }

  @override
  String get nameConflictDialogSingleSourceMessage => 'Sumar skrár í móttökumöppunni eru með sama heiti.';

  @override
  String get nameConflictDialogMultipleSourceMessage => 'Einhverjar skrár eru með sama heiti.';

  @override
  String get addShortcutDialogLabel => 'Skýring flýtilykils';

  @override
  String get addShortcutButtonLabel => 'BÆTA VIÐ';

  @override
  String get noMatchingAppDialogMessage => 'Ekkert forrit fannst sem getur meðhöndlað þessa aðgerð.';

  @override
  String binEntriesConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Færa þessi $count atriði í ruslmöppuna?',
      one: 'Færa þetta atriði í ruslmöppuna?',
    );
    return '$_temp0';
  }

  @override
  String deleteEntriesConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Eyða þessum $count atriðum?',
      one: 'Eyða þessu atriði?',
    );
    return '$_temp0';
  }

  @override
  String get moveUndatedConfirmationDialogMessage => 'Vista dagsetningar atriðis áður en haldið er áfram?';

  @override
  String get moveUndatedConfirmationDialogSetDate => 'Vista dagsetningar';

  @override
  String videoResumeDialogMessage(String time) {
    return 'Viltu halda afspilun áfram frá $time?';
  }

  @override
  String get videoStartOverButtonLabel => 'BYRJA AFTUR';

  @override
  String get videoResumeButtonLabel => 'HALDA ÁFRAM';

  @override
  String get setCoverDialogLatest => 'Síðasta atriðið';

  @override
  String get setCoverDialogAuto => 'Sjálfvirkt';

  @override
  String get setCoverDialogCustom => 'Sérsniðið';

  @override
  String get hideFilterConfirmationDialogMessage => 'Samsvarandi ljósmyndir og myndskeið verða falin frá safninu þínu. Þú getur látið þetta birtast aftur með því að fara í „Persónuvernd“-stillingarnar.\n\nErtu viss um að þú viljir fela þetta?';

  @override
  String get newAlbumDialogTitle => 'Nýtt albúm';

  @override
  String get newAlbumDialogNameLabel => 'Heiti albúms';

  @override
  String get newAlbumDialogAlbumAlreadyExistsHelper => 'Albúm er þegar til staðar';

  @override
  String get newAlbumDialogNameLabelAlreadyExistsHelper => 'Mappa er þegar til staðar';

  @override
  String get newAlbumDialogStorageLabel => 'Geymslurými:';

  @override
  String get newDynamicAlbumDialogTitle => 'Nýtt breytilegt albúm';

  @override
  String get dynamicAlbumAlreadyExists => 'Breytilegt albúm er þegar til staðar';

  @override
  String get newVaultWarningDialogMessage => 'Atriði í öryggisgeymslum eru einungis aðgengileg í þessu forriti og engum öðrum.\n\nEf þú fjarlægir þetta forrit, eða hreinsar gögn forritsins, muntu tapa öllum þessum atriðum.';

  @override
  String get newVaultDialogTitle => 'Ný öryggisgeymsla';

  @override
  String get configureVaultDialogTitle => 'Stilla öryggisgeymslu';

  @override
  String get vaultDialogLockModeWhenScreenOff => 'Læsa þegar skjárinn slekkur á sér';

  @override
  String get vaultDialogLockTypeLabel => 'Tegund læsingar';

  @override
  String get patternDialogEnter => 'Settu inn mynstur';

  @override
  String get patternDialogConfirm => 'Staðfestu mynstrið';

  @override
  String get pinDialogEnter => 'Settu inn PIN-númer';

  @override
  String get pinDialogConfirm => 'Staðfestu PIN-númer';

  @override
  String get passwordDialogEnter => 'Settu inn lykilorð';

  @override
  String get passwordDialogConfirm => 'Staðfestu lykilorð';

  @override
  String get authenticateToConfigureVault => 'Auðkenndu til að stilla öryggisgeymslu';

  @override
  String get authenticateToUnlockVault => 'Auðkenndu til að aflæsa öryggisgeymslu';

  @override
  String get vaultBinUsageDialogMessage => 'Sumar öryggisgeymslur nota ruslmöppuna.';

  @override
  String get renameAlbumDialogLabel => 'Nýtt heiti';

  @override
  String get renameAlbumDialogLabelAlreadyExistsHelper => 'Mappa er þegar til staðar';

  @override
  String get renameEntrySetPageTitle => 'Endurnefna';

  @override
  String get renameEntrySetPagePatternFieldLabel => 'Nefningarmynstur';

  @override
  String get renameEntrySetPageInsertTooltip => 'Setja inn gagnasvið';

  @override
  String get renameEntrySetPagePreviewSectionTitle => 'Forskoðun';

  @override
  String get renameProcessorCounter => 'Teljari';

  @override
  String get renameProcessorHash => 'Tætigildi';

  @override
  String get renameProcessorName => 'Heiti';

  @override
  String deleteSingleAlbumConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Eyða þessu albúmi og $count atriðum í því??',
      one: 'Eyða þessu albúmi og atriðinu í því?',
    );
    return '$_temp0';
  }

  @override
  String deleteMultiAlbumConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Eyða þessum albúmum og $count atriðum í þeim??',
      one: 'Eyða þessum albúmum og atriðinu í þeim?',
    );
    return '$_temp0';
  }

  @override
  String get exportEntryDialogFormat => 'Snið:';

  @override
  String get exportEntryDialogWidth => 'Breidd';

  @override
  String get exportEntryDialogHeight => 'Hæð';

  @override
  String get exportEntryDialogQuality => 'Gæði';

  @override
  String get exportEntryDialogWriteMetadata => 'Skrifa lýsigögn';

  @override
  String get renameEntryDialogLabel => 'Nýtt heiti';

  @override
  String get editEntryDialogCopyFromItem => 'Afrita úr öðru atriði';

  @override
  String get editEntryDialogTargetFieldsHeader => 'Gagnasvið sem á að breyta';

  @override
  String get editEntryDateDialogTitle => 'Dagsetning og tími';

  @override
  String get editEntryDateDialogSetCustom => 'Stilla sérsniðna dagsetningu';

  @override
  String get editEntryDateDialogCopyField => 'Afrita úr annarri dagsetningu';

  @override
  String get editEntryDateDialogExtractFromTitle => 'Veiða úr titli';

  @override
  String get editEntryDateDialogShift => 'Hliðra';

  @override
  String get editEntryDateDialogSourceFileModifiedDate => 'Breytingardagsetning skráar';

  @override
  String get durationDialogHours => 'Klukkustundir';

  @override
  String get durationDialogMinutes => 'Mínútur';

  @override
  String get durationDialogSeconds => 'Sekúndur';

  @override
  String get editEntryLocationDialogTitle => 'Staðsetning';

  @override
  String get editEntryLocationDialogSetCustom => 'Stilla sérsniðna staðsetningu';

  @override
  String get editEntryLocationDialogChooseOnMap => 'Velja á korti';

  @override
  String get editEntryLocationDialogImportGpx => 'Flytja inn GPX';

  @override
  String get editEntryLocationDialogLatitude => 'Breiddargráða';

  @override
  String get editEntryLocationDialogLongitude => 'Lengdargráða';

  @override
  String get editEntryLocationDialogTimeShift => 'Tímahliðrun';

  @override
  String get locationPickerUseThisLocationButton => 'Nota þessa staðsetningu';

  @override
  String get editEntryRatingDialogTitle => 'Einkunn';

  @override
  String get removeEntryMetadataDialogTitle => 'Fjarlæging lýsigagna';

  @override
  String get removeEntryMetadataDialogAll => 'Allt';

  @override
  String get removeEntryMetadataDialogMore => 'Meira';

  @override
  String get removeEntryMetadataMotionPhotoXmpWarningDialogMessage => 'XMP er nauðsynlegt til að geta spilað myndskeið inni í hreyfiljósmynd.\n\nErtu viss um að þú viljir fjarlægja það?';

  @override
  String get videoSpeedDialogLabel => 'Afspilunarhraði';

  @override
  String get videoStreamSelectionDialogVideo => 'Myndskeið';

  @override
  String get videoStreamSelectionDialogAudio => 'Hljóð';

  @override
  String get videoStreamSelectionDialogText => 'Skjátextar';

  @override
  String get videoStreamSelectionDialogOff => 'Slökkt';

  @override
  String get videoStreamSelectionDialogTrack => 'Ferill';

  @override
  String get videoStreamSelectionDialogNoSelection => 'Það eru engir aðrir ferlar.';

  @override
  String get genericSuccessFeedback => 'Lokið!';

  @override
  String get genericFailureFeedback => 'Mistókst';

  @override
  String get genericDangerWarningDialogMessage => 'Ertu viss?';

  @override
  String get tooManyItemsErrorDialogMessage => 'Reyndu aftur með færri atriðum.';

  @override
  String get menuActionConfigureView => 'Skoða';

  @override
  String get menuActionSelect => 'Velja';

  @override
  String get menuActionSelectAll => 'Velja allt';

  @override
  String get menuActionSelectNone => 'Velja ekkert';

  @override
  String get menuActionMap => 'Kort';

  @override
  String get menuActionSlideshow => 'Skyggnusýning';

  @override
  String get menuActionStats => 'Tölfræði';

  @override
  String get viewDialogSortSectionTitle => 'Raða';

  @override
  String get viewDialogGroupSectionTitle => 'Hópur';

  @override
  String get viewDialogLayoutSectionTitle => 'Framsetning';

  @override
  String get viewDialogReverseSortOrder => 'Öfug röð';

  @override
  String get tileLayoutMosaic => 'Mósaík';

  @override
  String get tileLayoutGrid => 'Reitir';

  @override
  String get tileLayoutList => 'Listi';

  @override
  String get castDialogTitle => 'Útvörpunartæki';

  @override
  String get coverDialogTabCover => 'Umslag';

  @override
  String get coverDialogTabApp => 'Forrit';

  @override
  String get coverDialogTabColor => 'Litur';

  @override
  String get appPickDialogTitle => 'Veldu forrit';

  @override
  String get appPickDialogNone => 'Ekkert';

  @override
  String get aboutPageTitle => 'Um hugbúnaðinn';

  @override
  String get aboutLinkLicense => 'Notkunarleyfi';

  @override
  String get aboutLinkPolicy => 'Meðferð persónuupplýsinga';

  @override
  String get aboutBugSectionTitle => 'Villuskýrsla';

  @override
  String get aboutBugSaveLogInstruction => 'Vista atvikaskráningu forrits í skrá';

  @override
  String get aboutBugCopyInfoInstruction => 'Afrita kerfisupplýsingar';

  @override
  String get aboutBugCopyInfoButton => 'Afrita';

  @override
  String get aboutBugReportInstruction => 'Tilkynna á GitHub með atvikaskrám og kerfisupplýsingum';

  @override
  String get aboutBugReportButton => 'Tilkynna';

  @override
  String get aboutDataUsageSectionTitle => 'Gagnanotkun';

  @override
  String get aboutDataUsageData => 'Gögn';

  @override
  String get aboutDataUsageCache => 'Skyndiminni';

  @override
  String get aboutDataUsageDatabase => 'Gagnagrunnur';

  @override
  String get aboutDataUsageMisc => 'Ýmislegt';

  @override
  String get aboutDataUsageInternal => 'Innri';

  @override
  String get aboutDataUsageExternal => 'Utanaðkomandi';

  @override
  String get aboutDataUsageClearCache => 'Hreinsa skyndiminni';

  @override
  String get aboutCreditsSectionTitle => 'Framlög';

  @override
  String get aboutCreditsWorldAtlas1 => 'Þetta forrit notar TopoJSON-skrá frá';

  @override
  String get aboutCreditsWorldAtlas2 => 'með ISC-notkunarleyfi.';

  @override
  String get aboutTranslatorsSectionTitle => 'Þýðendur';

  @override
  String get aboutLicensesSectionTitle => 'Notkunarleyfi opins hugbúnaðar';

  @override
  String get aboutLicensesBanner => 'Þetta forrit notar eftirfarandi pakka og aðgerðasöfn með opnum grunnkóða.';

  @override
  String get aboutLicensesAndroidLibrariesSectionTitle => 'Android-aðgerðasöfn';

  @override
  String get aboutLicensesFlutterPluginsSectionTitle => 'Flutter-viðbætur';

  @override
  String get aboutLicensesFlutterPackagesSectionTitle => 'Flutter-pakkar';

  @override
  String get aboutLicensesDartPackagesSectionTitle => 'Dart-pakkar';

  @override
  String get aboutLicensesShowAllButtonLabel => 'Sýna öll notkunarleyfi';

  @override
  String get policyPageTitle => 'Meðferð persónuupplýsinga';

  @override
  String get collectionPageTitle => 'Safn';

  @override
  String get collectionPickPageTitle => 'Veldu';

  @override
  String get collectionSelectPageTitle => 'Veldu atriði';

  @override
  String get collectionActionShowTitleSearch => 'Birta titilsíu';

  @override
  String get collectionActionHideTitleSearch => 'Fela titilsíu';

  @override
  String get collectionActionAddDynamicAlbum => 'Bæta við breytilegu albúmi';

  @override
  String get collectionActionAddShortcut => 'Bæta við flýtileið';

  @override
  String get collectionActionSetHome => 'Setja sem upphafsskjá';

  @override
  String get collectionActionEmptyBin => 'Tæma ruslið';

  @override
  String get collectionActionCopy => 'Afrita í albúm';

  @override
  String get collectionActionMove => 'Færa í albúm';

  @override
  String get collectionActionRescan => 'Endurskanna';

  @override
  String get collectionActionEdit => 'Breyta';

  @override
  String get collectionSearchTitlesHintText => 'Leita í lagatitlum';

  @override
  String get collectionGroupAlbum => 'Eftir albúmum';

  @override
  String get collectionGroupMonth => 'Eftir mánuðum';

  @override
  String get collectionGroupDay => 'Eftir dögum';

  @override
  String get collectionGroupNone => 'Ekki hópa';

  @override
  String get sectionUnknown => 'Óþekkt';

  @override
  String get dateToday => 'Í dag';

  @override
  String get dateYesterday => 'Í gær';

  @override
  String get dateThisMonth => 'Í þessum mánuði';

  @override
  String collectionDeleteFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mistókst að eyða $count atriðum',
      one: 'Mistókst að eyða 1 atriði',
    );
    return '$_temp0';
  }

  @override
  String collectionCopyFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mistókst að afrita $count atriðum',
      one: 'Mistókst að afrita 1 atriði',
    );
    return '$_temp0';
  }

  @override
  String collectionMoveFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mistókst að flytja $count atriðum',
      one: 'Mistókst að flytja 1 atriði',
    );
    return '$_temp0';
  }

  @override
  String collectionRenameFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mistókst að endurnefna $count atriðum',
      one: 'Mistókst að endurnefna 1 atriði',
    );
    return '$_temp0';
  }

  @override
  String collectionEditFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mistókst að breyta $count atriðum',
      one: 'Mistókst að breyta 1 atriði',
    );
    return '$_temp0';
  }

  @override
  String collectionExportFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mistókst að flytja út $count atriðum',
      one: 'Mistókst að flytja út 1 atriði',
    );
    return '$_temp0';
  }

  @override
  String collectionCopySuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Afritaði $count atriðum',
      one: 'Afritaði 1 atriði',
    );
    return '$_temp0';
  }

  @override
  String collectionMoveSuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Færði $count atriðum',
      one: 'Færði 1 atriði',
    );
    return '$_temp0';
  }

  @override
  String collectionRenameSuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Endurnefndi $count atriðum',
      one: 'Endurnefndi 1 atriði',
    );
    return '$_temp0';
  }

  @override
  String collectionEditSuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Breytti $count atriðum',
      one: 'Breytti 1 atriði',
    );
    return '$_temp0';
  }

  @override
  String get collectionEmptyFavourites => 'Engin eftirlæti';

  @override
  String get collectionEmptyVideos => 'Engin myndskeið';

  @override
  String get collectionEmptyImages => 'Engar myndir';

  @override
  String get collectionEmptyGrantAccessButtonLabel => 'Veita aðgang';

  @override
  String get collectionSelectSectionTooltip => 'Velja hluta';

  @override
  String get collectionDeselectSectionTooltip => 'Afvelja hluta';

  @override
  String get drawerAboutButton => 'Um hugbúnaðinn';

  @override
  String get drawerSettingsButton => 'Stillingar';

  @override
  String get drawerCollectionAll => 'Allt safnið';

  @override
  String get drawerCollectionFavourites => 'Eftirlæti';

  @override
  String get drawerCollectionImages => 'Myndir';

  @override
  String get drawerCollectionVideos => 'Myndskeið';

  @override
  String get drawerCollectionAnimated => 'Með hreyfingu';

  @override
  String get drawerCollectionMotionPhotos => 'Hreyfiljósmyndir';

  @override
  String get drawerCollectionPanoramas => 'Víðmyndir';

  @override
  String get drawerCollectionRaws => 'RAW-myndir';

  @override
  String get drawerCollectionSphericalVideos => '360° myndskeið';

  @override
  String get drawerAlbumPage => 'Albúm';

  @override
  String get drawerCountryPage => 'Lönd';

  @override
  String get drawerPlacePage => 'Staðir';

  @override
  String get drawerTagPage => 'Merki';

  @override
  String get sortByDate => 'Eftir dagsetningu';

  @override
  String get sortByName => 'Eftir nafni';

  @override
  String get sortByItemCount => 'Eftir fjölda atriða';

  @override
  String get sortBySize => 'Eftir stærð';

  @override
  String get sortByAlbumFileName => 'Eftir heiti albúma og skráa';

  @override
  String get sortByRating => 'Eftir einkunn';

  @override
  String get sortByDuration => 'Eftir tímalengd';

  @override
  String get sortByPath => 'Eftir slóð';

  @override
  String get sortOrderNewestFirst => 'Nýjast fyrst';

  @override
  String get sortOrderOldestFirst => 'Elsta fyrst';

  @override
  String get sortOrderAtoZ => 'A til Ö';

  @override
  String get sortOrderZtoA => 'Ö til A';

  @override
  String get sortOrderHighestFirst => 'Hæsta fyrst';

  @override
  String get sortOrderLowestFirst => 'Lægsta fyrst';

  @override
  String get sortOrderLargestFirst => 'Stærst fyrst';

  @override
  String get sortOrderSmallestFirst => 'Minnsta fyrst';

  @override
  String get sortOrderShortestFirst => 'Stysta fyrst';

  @override
  String get sortOrderLongestFirst => 'Lengsta fyrst';

  @override
  String get albumGroupTier => 'Eftir flokki';

  @override
  String get albumGroupType => 'Eftir gerð';

  @override
  String get albumGroupVolume => 'Eftir gagnageymslu';

  @override
  String get albumGroupNone => 'Ekki hópa';

  @override
  String get albumMimeTypeMixed => 'Blandað';

  @override
  String get albumPickPageTitleCopy => 'Afrita í albúm';

  @override
  String get albumPickPageTitleExport => 'Flytja út í albúm';

  @override
  String get albumPickPageTitleMove => 'Færa í albúm';

  @override
  String get albumPickPageTitlePick => 'Veldu albúm';

  @override
  String get albumCamera => 'Myndavél';

  @override
  String get albumDownload => 'Sækja';

  @override
  String get albumScreenshots => 'Skjámyndir';

  @override
  String get albumScreenRecordings => 'Skjáupptökur';

  @override
  String get albumVideoCaptures => 'Upptökur myndskeiða';

  @override
  String get albumPageTitle => 'Albúm';

  @override
  String get albumEmpty => 'Engin albúm';

  @override
  String get createAlbumButtonLabel => 'BÚA TIL';

  @override
  String get newFilterBanner => 'nýtt';

  @override
  String get countryPageTitle => 'Lönd';

  @override
  String get countryEmpty => 'Engin lönd';

  @override
  String get statePageTitle => 'Héruð';

  @override
  String get stateEmpty => 'Engin héruð';

  @override
  String get placePageTitle => 'Staðir';

  @override
  String get placeEmpty => 'Engir staðir';

  @override
  String get tagPageTitle => 'Merki';

  @override
  String get tagEmpty => 'Engin merki';

  @override
  String get binPageTitle => 'Ruslmappa';

  @override
  String get explorerPageTitle => 'Skráastjóri';

  @override
  String get explorerActionSelectStorageVolume => 'Veldu geymslu';

  @override
  String get selectStorageVolumeDialogTitle => 'Veldu geymslu';

  @override
  String get searchCollectionFieldHint => 'Leita í safni';

  @override
  String get searchRecentSectionTitle => 'Nýlegt';

  @override
  String get searchDateSectionTitle => 'Dagsetning';

  @override
  String get searchFormatSectionTitle => 'Snið';

  @override
  String get searchAlbumsSectionTitle => 'Albúm';

  @override
  String get searchCountriesSectionTitle => 'Lönd';

  @override
  String get searchStatesSectionTitle => 'Héruð';

  @override
  String get searchPlacesSectionTitle => 'Staðir';

  @override
  String get searchTagsSectionTitle => 'Merki';

  @override
  String get searchRatingSectionTitle => 'Einkunnir';

  @override
  String get searchMetadataSectionTitle => 'Lýsigögn';

  @override
  String get settingsPageTitle => 'Stillingar';

  @override
  String get settingsSystemDefault => 'Sjálfgefið í kerfinu';

  @override
  String get settingsDefault => 'Sjálfgefið';

  @override
  String get settingsDisabled => 'Óvirkt';

  @override
  String get settingsAskEverytime => 'Spyrja í hvert skipti';

  @override
  String get settingsModificationWarningDialogMessage => 'Aðrar stillingar munu breytast.';

  @override
  String get settingsSearchFieldLabel => 'Leita í stillingum';

  @override
  String get settingsSearchEmpty => 'Engin samsvarandi stilling';

  @override
  String get settingsActionExport => 'Flytja út';

  @override
  String get settingsActionExportDialogTitle => 'Flytja út';

  @override
  String get settingsActionImport => 'Flytja inn';

  @override
  String get settingsActionImportDialogTitle => 'Flytja inn';

  @override
  String get appExportCovers => 'Umslög';

  @override
  String get appExportDynamicAlbums => 'Breytileg albúm';

  @override
  String get appExportFavourites => 'Eftirlæti';

  @override
  String get appExportSettings => 'Stillingar';

  @override
  String get settingsNavigationSectionTitle => 'Flakk';

  @override
  String get settingsHomeTile => 'Heim';

  @override
  String get settingsHomeDialogTitle => 'Heim';

  @override
  String get setHomeCustom => 'Sérsniðið';

  @override
  String get settingsShowBottomNavigationBar => 'Birta flakkstiku neðst';

  @override
  String get settingsKeepScreenOnTile => 'Halda skjá í gangi';

  @override
  String get settingsKeepScreenOnDialogTitle => 'Halda skjá í gangi';

  @override
  String get settingsDoubleBackExit => 'Ýttu tvisvar á „Til baka“ til að hætta';

  @override
  String get settingsConfirmationTile => 'Staðfestingargluggar';

  @override
  String get settingsConfirmationDialogTitle => 'Staðfestingargluggar';

  @override
  String get settingsConfirmationBeforeDeleteItems => 'Spyrja áður en atriðum er endanlega eytt';

  @override
  String get settingsConfirmationBeforeMoveToBinItems => 'Spyrja áður en atriði eru færð í ruslmöppuna';

  @override
  String get settingsConfirmationBeforeMoveUndatedItems => 'Spyrja áður en ódagsett atriði eru færð';

  @override
  String get settingsConfirmationAfterMoveToBinItems => 'Sýna skilaboð eftir að atriði eru færð í ruslmöppuna';

  @override
  String get settingsConfirmationVaultDataLoss => 'Birta aðvörun um gagnatap öryggisgeymslu';

  @override
  String get settingsNavigationDrawerTile => 'Leiðsagnarval';

  @override
  String get settingsNavigationDrawerEditorPageTitle => 'Flakkvalmynd';

  @override
  String get settingsNavigationDrawerBanner => 'Ýttu og haltu niðri til að endurraða valmyndaratriðum.';

  @override
  String get settingsNavigationDrawerTabTypes => 'Tegundir';

  @override
  String get settingsNavigationDrawerTabAlbums => 'Albúm';

  @override
  String get settingsNavigationDrawerTabPages => 'Síður';

  @override
  String get settingsNavigationDrawerAddAlbum => 'Bæta við albúmi';

  @override
  String get settingsThumbnailSectionTitle => 'Smámyndir';

  @override
  String get settingsThumbnailOverlayTile => 'Yfirlag';

  @override
  String get settingsThumbnailOverlayPageTitle => 'Yfirlag';

  @override
  String get settingsThumbnailShowHdrIcon => 'Birta HDR-táknmynd';

  @override
  String get settingsThumbnailShowFavouriteIcon => 'Birta tákn fyrir eftirlæti';

  @override
  String get settingsThumbnailShowTagIcon => 'Birta tákn fyrir merki';

  @override
  String get settingsThumbnailShowLocationIcon => 'Birta tákn fyrir staðsetningu';

  @override
  String get settingsThumbnailShowMotionPhotoIcon => 'Birta tákn fyrir hreyfiljósmyndir';

  @override
  String get settingsThumbnailShowRating => 'Birta einkunn';

  @override
  String get settingsThumbnailShowRawIcon => 'Birta tákn fyrir RAW';

  @override
  String get settingsThumbnailShowVideoDuration => 'Birta tímalengd myndskeiða';

  @override
  String get settingsCollectionQuickActionsTile => 'Flýtiaðgerðir';

  @override
  String get settingsCollectionQuickActionEditorPageTitle => 'Flýtiaðgerðir';

  @override
  String get settingsCollectionQuickActionTabBrowsing => 'Vafur';

  @override
  String get settingsCollectionQuickActionTabSelecting => 'Val';

  @override
  String get settingsCollectionBrowsingQuickActionEditorBanner => 'Ýttu og haltu niðri til að færa hnappa og velja hvaða aðgerðir séu birtar þegar verið er að fletta í gegnum atriði.';

  @override
  String get settingsCollectionSelectionQuickActionEditorBanner => 'Ýttu og haltu niðri til að færa hnappa og velja hvaða aðgerðir séu birtar þegar verið er að velja atriði.';

  @override
  String get settingsCollectionBurstPatternsTile => 'Mynstur runu';

  @override
  String get settingsCollectionBurstPatternsNone => 'Ekkert';

  @override
  String get settingsViewerSectionTitle => 'Skoðari';

  @override
  String get settingsViewerGestureSideTapNext => 'Ýttu á skjájaðra til að birta fyrra/næsta atriði';

  @override
  String get settingsViewerUseCutout => 'Nota útklippt svæði';

  @override
  String get settingsViewerMaximumBrightness => 'Hámarksbirtustig';

  @override
  String get settingsMotionPhotoAutoPlay => 'Spila hreyfiljósmyndir sjálfkrafa';

  @override
  String get settingsImageBackground => 'Bakgrunnur mynda';

  @override
  String get settingsViewerQuickActionsTile => 'Flýtiaðgerðir';

  @override
  String get settingsViewerQuickActionEditorPageTitle => 'Flýtiaðgerðir';

  @override
  String get settingsViewerQuickActionEditorBanner => 'Ýttu og haltu niðri til að færa hnappa og velja hvaða aðgerðir séu birtar í skoðaranum.';

  @override
  String get settingsViewerQuickActionEditorDisplayedButtonsSectionTitle => 'Birtir hnappar';

  @override
  String get settingsViewerQuickActionEditorAvailableButtonsSectionTitle => 'Tiltækir hnappar';

  @override
  String get settingsViewerQuickActionEmpty => 'Engir hnappar';

  @override
  String get settingsViewerOverlayTile => 'Yfirlag';

  @override
  String get settingsViewerOverlayPageTitle => 'Yfirlag';

  @override
  String get settingsViewerShowOverlayOnOpening => 'Birta við opnun';

  @override
  String get settingsViewerShowHistogram => 'Birta litatíðnirit';

  @override
  String get settingsViewerShowMinimap => 'Birta smákort';

  @override
  String get settingsViewerShowInformation => 'Birta upplýsingar';

  @override
  String get settingsViewerShowInformationSubtitle => 'Birta titil, dagsetningu, staðsetningu, o.s.frv.';

  @override
  String get settingsViewerShowRatingTags => 'Birta einkunn og merki';

  @override
  String get settingsViewerShowShootingDetails => 'Sýna ítarlegri upplýsingar um myndatöku';

  @override
  String get settingsViewerShowDescription => 'Birta lýsingu';

  @override
  String get settingsViewerShowOverlayThumbnails => 'Birta smámyndir';

  @override
  String get settingsViewerEnableOverlayBlurEffect => 'Móðunarbrella';

  @override
  String get settingsViewerSlideshowTile => 'Skyggnusýning';

  @override
  String get settingsViewerSlideshowPageTitle => 'Skyggnusýning';

  @override
  String get settingsSlideshowRepeat => 'Endurtaka';

  @override
  String get settingsSlideshowShuffle => 'Stokka';

  @override
  String get settingsSlideshowFillScreen => 'Fylla skjá';

  @override
  String get settingsSlideshowAnimatedZoomEffect => 'Aðdráttur með hreyfingu';

  @override
  String get settingsSlideshowTransitionTile => 'Millifærsla';

  @override
  String get settingsSlideshowIntervalTile => 'Millibil';

  @override
  String get settingsSlideshowVideoPlaybackTile => 'Afspilun myndskeiða';

  @override
  String get settingsSlideshowVideoPlaybackDialogTitle => 'Afspilun myndskeiða';

  @override
  String get settingsVideoPageTitle => 'Myndstillingar';

  @override
  String get settingsVideoSectionTitle => 'Myndskeið';

  @override
  String get settingsVideoShowVideos => 'Sýna myndskeið';

  @override
  String get settingsVideoPlaybackTile => 'Afspilun';

  @override
  String get settingsVideoPlaybackPageTitle => 'Afspilun';

  @override
  String get settingsVideoEnableHardwareAcceleration => 'Vélbúnaðarhröðun';

  @override
  String get settingsVideoAutoPlay => 'Sjálfvirk spilun';

  @override
  String get settingsVideoLoopModeTile => 'Endurtekningarhamur';

  @override
  String get settingsVideoLoopModeDialogTitle => 'Endurtekningarhamur';

  @override
  String get settingsVideoResumptionModeTile => 'Halda afspilun áfram';

  @override
  String get settingsVideoResumptionModeDialogTitle => 'Halda afspilun áfram';

  @override
  String get settingsVideoBackgroundMode => 'Bakgrunnshamur';

  @override
  String get settingsVideoBackgroundModeDialogTitle => 'Bakgrunnshamur';

  @override
  String get settingsVideoControlsTile => 'Stýringar';

  @override
  String get settingsVideoControlsPageTitle => 'Stýringar';

  @override
  String get settingsVideoButtonsTile => 'Hnappar';

  @override
  String get settingsVideoGestureDoubleTapTogglePlay => 'Tvíbankaðu til að spila/setja í bið';

  @override
  String get settingsVideoGestureSideDoubleTapSeek => 'Tvíbankaðu á skjájaðra leita afturábak/áfram';

  @override
  String get settingsVideoGestureVerticalDragBrightnessVolume => 'Strjúktu upp/niður til að breyta birtustigi/hljóðstyrk';

  @override
  String get settingsSubtitleThemeTile => 'Skjátextar';

  @override
  String get settingsSubtitleThemePageTitle => 'Skjátextar';

  @override
  String get settingsSubtitleThemeSample => 'Þetta er dæmi.';

  @override
  String get settingsSubtitleThemeTextAlignmentTile => 'Jöfnun texta';

  @override
  String get settingsSubtitleThemeTextAlignmentDialogTitle => 'Jöfnun texta';

  @override
  String get settingsSubtitleThemeTextPositionTile => 'Textastaðsetning';

  @override
  String get settingsSubtitleThemeTextPositionDialogTitle => 'Textastaða';

  @override
  String get settingsSubtitleThemeTextSize => 'Stærð texta';

  @override
  String get settingsSubtitleThemeShowOutline => 'Sýna útlínur og skugga';

  @override
  String get settingsSubtitleThemeTextColor => 'Litur texta';

  @override
  String get settingsSubtitleThemeTextOpacity => 'Ógegnsæi texta';

  @override
  String get settingsSubtitleThemeBackgroundColor => 'Litur bakgrunns';

  @override
  String get settingsSubtitleThemeBackgroundOpacity => 'Ógegnsæi bakgrunns';

  @override
  String get settingsSubtitleThemeTextAlignmentLeft => 'Vinstri';

  @override
  String get settingsSubtitleThemeTextAlignmentCenter => 'Miðjað';

  @override
  String get settingsSubtitleThemeTextAlignmentRight => 'Hægri';

  @override
  String get settingsPrivacySectionTitle => 'Persónuvernd';

  @override
  String get settingsAllowInstalledAppAccess => 'Leyfa aðgang að forritaskrá';

  @override
  String get settingsAllowInstalledAppAccessSubtitle => 'Notað til að bæta birtingu albúma';

  @override
  String get settingsAllowErrorReporting => 'Leyfa nafnlausar villutilkynningar';

  @override
  String get settingsSaveSearchHistory => 'Vista leitarferil';

  @override
  String get settingsEnableBin => 'Nota ruslmöppu';

  @override
  String get settingsEnableBinSubtitle => 'Halda eyddum atriðum í 30 daga';

  @override
  String get settingsDisablingBinWarningDialogMessage => 'Atriðum í ruslinu verður endanlega eytt.';

  @override
  String get settingsAllowMediaManagement => 'Leyfa stýringu gagnamiðla';

  @override
  String get settingsHiddenItemsTile => 'Falin atriði';

  @override
  String get settingsHiddenItemsPageTitle => 'Falin atriði';

  @override
  String get settingsHiddenFiltersBanner => 'Myndir og myndskeið sem samsvara felusíum, munu ekki birtast í safninu þínu.';

  @override
  String get settingsHiddenFiltersEmpty => 'Engar felusíur';

  @override
  String get settingsStorageAccessTile => 'Aðgengi geymslu';

  @override
  String get settingsStorageAccessPageTitle => 'Aðgengi geymslu';

  @override
  String get settingsStorageAccessBanner => 'Sumar möppur krefjast þess að gefin sé sérstök heimild til að breyta skrám í þeim. Þú getur yfirfarið hér þær möppur sem þú hefur gefið aðgangaheimildir fyrir.';

  @override
  String get settingsStorageAccessEmpty => 'Engiar aðgangsheimildir';

  @override
  String get settingsStorageAccessRevokeTooltip => 'Afturkalla';

  @override
  String get settingsAccessibilitySectionTitle => 'Auðveldað aðgengi';

  @override
  String get settingsRemoveAnimationsTile => 'Fjarlægja hreyfimyndir';

  @override
  String get settingsRemoveAnimationsDialogTitle => 'Fjarlægja hreyfimyndir';

  @override
  String get settingsTimeToTakeActionTile => 'Tími til að grípa til aðgerða';

  @override
  String get settingsAccessibilityShowPinchGestureAlternatives => 'Sýna aðra valkosti með mörgum bendingum';

  @override
  String get settingsDisplaySectionTitle => 'Birting';

  @override
  String get settingsThemeBrightnessTile => 'Þema';

  @override
  String get settingsThemeBrightnessDialogTitle => 'Þema';

  @override
  String get settingsThemeColorHighlights => 'Hátónalitun';

  @override
  String get settingsThemeEnableDynamicColor => 'Breytilegur litur';

  @override
  String get settingsDisplayRefreshRateModeTile => 'Birta uppfærslutíðni';

  @override
  String get settingsDisplayRefreshRateModeDialogTitle => 'Uppfærslutíðni';

  @override
  String get settingsDisplayUseTvInterface => 'Android TV viðmót';

  @override
  String get settingsLanguageSectionTitle => 'Tungumál og snið';

  @override
  String get settingsLanguageTile => 'Tungumál';

  @override
  String get settingsLanguagePageTitle => 'Tungumál';

  @override
  String get settingsCoordinateFormatTile => 'Snið hnita';

  @override
  String get settingsCoordinateFormatDialogTitle => 'Snið hnita';

  @override
  String get settingsUnitSystemTile => 'Einingar';

  @override
  String get settingsUnitSystemDialogTitle => 'Einingar';

  @override
  String get settingsForceWesternArabicNumeralsTile => 'Þvinga arabískar tölur';

  @override
  String get settingsScreenSaverPageTitle => 'Skjáhvíla';

  @override
  String get settingsWidgetPageTitle => 'Myndarammi';

  @override
  String get settingsWidgetShowOutline => 'Útlínur';

  @override
  String get settingsWidgetOpenPage => 'Þegar ýtt er á viðmótshlutann';

  @override
  String get settingsWidgetDisplayedItem => 'Birt atriði';

  @override
  String get settingsCollectionTile => 'Safn';

  @override
  String get statsPageTitle => 'Tölfræði';

  @override
  String statsWithGps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count atriði með staðsetningum',
      one: '1 atriði með staðsetningu',
    );
    return '$_temp0';
  }

  @override
  String get statsTopCountriesSectionTitle => 'Algengustu lönd';

  @override
  String get statsTopStatesSectionTitle => 'Algengustu héruð';

  @override
  String get statsTopPlacesSectionTitle => 'Algengustu staðir';

  @override
  String get statsTopTagsSectionTitle => 'Algengustu merki';

  @override
  String get statsTopAlbumsSectionTitle => 'Vinsælustu albúm';

  @override
  String get viewerOpenPanoramaButtonLabel => 'OPNA VÍÐMYND';

  @override
  String get viewerSetWallpaperButtonLabel => 'SETJA BAKGRUNN';

  @override
  String get viewerErrorUnknown => 'Úbbs!';

  @override
  String get viewerErrorDoesNotExist => 'Skráin er ekki lengur til.';

  @override
  String get viewerInfoPageTitle => 'Upplýsingar';

  @override
  String get viewerInfoBackToViewerTooltip => 'Til baka í skoðara';

  @override
  String get viewerInfoUnknown => 'óþekkt';

  @override
  String get viewerInfoLabelDescription => 'Lýsing';

  @override
  String get viewerInfoLabelTitle => 'Titill';

  @override
  String get viewerInfoLabelDate => 'Dagsetning';

  @override
  String get viewerInfoLabelResolution => 'Upplausn';

  @override
  String get viewerInfoLabelSize => 'Stærð';

  @override
  String get viewerInfoLabelUri => 'Vefslóð';

  @override
  String get viewerInfoLabelPath => 'Slóð';

  @override
  String get viewerInfoLabelDuration => 'Tímalengd';

  @override
  String get viewerInfoLabelOwner => 'Eigandi';

  @override
  String get viewerInfoLabelCoordinates => 'Hnit';

  @override
  String get viewerInfoLabelAddress => 'Heimilisfang';

  @override
  String get mapStyleDialogTitle => 'Stíll korts';

  @override
  String get mapStyleTooltip => 'Veldu stíl korts';

  @override
  String get mapZoomInTooltip => 'Renna að';

  @override
  String get mapZoomOutTooltip => 'Renna frá';

  @override
  String get mapPointNorthUpTooltip => 'Norður beint upp';

  @override
  String get mapAttributionOsmData => 'Kortagögn frá © [OpenStreetMap](https://www.openstreetmap.org/copyright) þátttakendum';

  @override
  String get mapAttributionOsmLiberty => 'Kortaflísar frá [OpenMapTiles](https://www.openmaptiles.org/), [CC BY](http://creativecommons.org/licenses/by/4.0) • Hýst hjá [OSM Americana](https://tile.ourmap.us)';

  @override
  String get mapAttributionOpenTopoMap => '[SRTM](https://www.earthdata.nasa.gov/sensors/srtm) | Kortaflísar frá [OpenTopoMap](https://opentopomap.org/), [CC BY-SA](https://creativecommons.org/licenses/by-sa/3.0/)';

  @override
  String get mapAttributionOsmHot => 'Kortatíglar frá [HOT](https://www.hotosm.org/) • Hýst af [OSM France](https://openstreetmap.fr/)';

  @override
  String get mapAttributionStamen => 'Kortatíglar frá [Stamen Design](https://stamen.com), [CC BY 3.0](https://creativecommons.org/licenses/by/3.0)';

  @override
  String get openMapPageTooltip => 'Skoða á kortasíðu';

  @override
  String get mapEmptyRegion => 'Engar myndir á þessu svæði';

  @override
  String get viewerInfoOpenEmbeddedFailureFeedback => 'Mistókst að ná í ívafin gögn';

  @override
  String get viewerInfoOpenLinkText => 'Opna';

  @override
  String get viewerInfoViewXmlLinkText => 'Skoða XML';

  @override
  String get viewerInfoSearchFieldLabel => 'Leita í lýsigögnum';

  @override
  String get viewerInfoSearchEmpty => 'Engir samsvarandi lyklar';

  @override
  String get viewerInfoSearchSuggestionDate => 'Dagsetning og tími';

  @override
  String get viewerInfoSearchSuggestionDescription => 'Lýsing';

  @override
  String get viewerInfoSearchSuggestionDimensions => 'Stærðir';

  @override
  String get viewerInfoSearchSuggestionResolution => 'Upplausn';

  @override
  String get viewerInfoSearchSuggestionRights => 'Réttindi';

  @override
  String get wallpaperUseScrollEffect => 'Nota skrunbrellur á upphafsskjá';

  @override
  String get tagEditorPageTitle => 'Breyta merkjum';

  @override
  String get tagEditorPageNewTagFieldLabel => 'Nýtt merki';

  @override
  String get tagEditorPageAddTagTooltip => 'Bæta við merki';

  @override
  String get tagEditorSectionRecent => 'Nýlegt';

  @override
  String get tagEditorSectionPlaceholders => 'Ígildisbreytur';

  @override
  String get tagEditorDiscardDialogMessage => 'Viltu henda breytingum?';

  @override
  String get tagPlaceholderCountry => 'Land';

  @override
  String get tagPlaceholderState => 'Hérað';

  @override
  String get tagPlaceholderPlace => 'Staður';

  @override
  String get panoramaEnableSensorControl => 'Virkja skynjarastýringu';

  @override
  String get panoramaDisableSensorControl => 'Gera skynjarastýringu óvirka';

  @override
  String get sourceViewerPageTitle => 'Uppruni';

  @override
  String get filePickerShowHiddenFiles => 'Birta faldar skrár';

  @override
  String get filePickerDoNotShowHiddenFiles => 'Ekki birta faldar skrár';

  @override
  String get filePickerOpenFrom => 'Opið frá';

  @override
  String get filePickerNoItems => 'Engir hlutir';

  @override
  String get filePickerUseThisFolder => 'Nota þessa möppu';
}
