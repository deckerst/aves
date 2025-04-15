// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Central Kurdish (`ckb`).
class AppLocalizationsCkb extends AppLocalizations {
  AppLocalizationsCkb([String locale = 'ckb']) : super(locale);

  @override
  String get appName => 'ئاڤیس';

  @override
  String get welcomeMessage => 'بەخێربێی بۆ ئاڤیس';

  @override
  String get welcomeOptional => 'ئارەزومەندانە';

  @override
  String get welcomeTermsToggle => 'ڕازیم بە مەرج و یاساکانی بەکارهێنان';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'دانە $count',
    );
    return '$_temp0';
  }

  @override
  String columnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ڕیز $count',
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
      other: 'چرکە $countString',
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
      other: 'خولەک $countString',
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
      other: 'ڕۆژ $countString',
    );
    return '$_temp0';
  }

  @override
  String focalLength(String length) {
    return '$length ملی‌مەتر';
  }

  @override
  String get applyButtonLabel => 'جێبەجێکردن';

  @override
  String get deleteButtonLabel => 'سڕینەوە';

  @override
  String get nextButtonLabel => 'دواتر';

  @override
  String get showButtonLabel => 'پیشاندان';

  @override
  String get hideButtonLabel => 'شاردنەوە';

  @override
  String get continueButtonLabel => 'بەردەوامبون';

  @override
  String get saveCopyButtonLabel => 'وێنەکی لێ پاشەکەوت بکە';

  @override
  String get applyTooltip => 'جێبەجێ کردن';

  @override
  String get cancelTooltip => 'پاشگەزبونەوە';

  @override
  String get changeTooltip => 'گۆڕین';

  @override
  String get clearTooltip => 'لابردن';

  @override
  String get previousTooltip => 'پێشوتر';

  @override
  String get nextTooltip => 'دواتر';

  @override
  String get showTooltip => 'پیشاندان';

  @override
  String get hideTooltip => 'شاردنەوە';

  @override
  String get actionRemove => 'لابردن';

  @override
  String get resetTooltip => 'سفرکردنەوە';

  @override
  String get saveTooltip => 'پاراستن';

  @override
  String get stopTooltip => 'Stop';

  @override
  String get pickTooltip => 'هەڵبژاردن';

  @override
  String get doubleBackExitMessage => 'دووبارە پەنجەبنێ بە گەڕانەوە ”back“ دا بۆ دەرچوون';

  @override
  String get doNotAskAgain => 'دووبارە مەپرسەوە';

  @override
  String get sourceStateLoading => 'چاوەڕوانبە';

  @override
  String get sourceStateCataloguing => 'تۆماری زانیاری';

  @override
  String get sourceStateLocatingCountries => 'دۆزینەوەی ووڵات';

  @override
  String get sourceStateLocatingPlaces => 'دۆزینەوەی شوێن';

  @override
  String get chipActionDelete => 'سڕینەوە';

  @override
  String get chipActionRemove => 'Remove';

  @override
  String get chipActionShowCollection => 'Show in Collection';

  @override
  String get chipActionGoToAlbumPage => 'بینین لە ئەلبومدا';

  @override
  String get chipActionGoToCountryPage => 'پیشاندان لە ووڵاتەکاندا';

  @override
  String get chipActionGoToPlacePage => 'Show in Places';

  @override
  String get chipActionGoToTagPage => 'پیشاندانی نیشانەکراوەکان';

  @override
  String get chipActionGoToExplorerPage => 'Show in Explorer';

  @override
  String get chipActionDecompose => 'Split';

  @override
  String get chipActionFilterOut => 'کاریگەرییەکان';

  @override
  String get chipActionFilterIn => 'کاریگەرییەکان';

  @override
  String get chipActionHide => 'شاردنەوە';

  @override
  String get chipActionLock => 'قفڵکردن';

  @override
  String get chipActionPin => 'جێگیرکردن لە سەرەوە';

  @override
  String get chipActionUnpin => 'لابردنی جێگیری';

  @override
  String get chipActionRename => 'ناوگۆڕین';

  @override
  String get chipActionSetCover => 'وێنەی بەرگ';

  @override
  String get chipActionShowCountryStates => 'Show states';

  @override
  String get chipActionCreateAlbum => 'دروستکردنی ئەلبوم';

  @override
  String get chipActionCreateVault => 'دروستکردنی تایبەت';

  @override
  String get chipActionConfigureVault => 'ڕێکخستنی قفڵکراو';

  @override
  String get entryActionCopyToClipboard => 'لەبەرگرتنەوە';

  @override
  String get entryActionDelete => 'سڕینەوە';

  @override
  String get entryActionConvert => 'گۆڕینی جۆر';

  @override
  String get entryActionExport => 'هەڵگرتن';

  @override
  String get entryActionInfo => 'زانیاری';

  @override
  String get entryActionRename => 'ناوگۆڕین';

  @override
  String get entryActionRestore => 'گێڕانەوە';

  @override
  String get entryActionRotateCCW => 'سوڕاندن بە پێچەوانەی میلی کاتژمێر';

  @override
  String get entryActionRotateCW => 'سوڕاندن بە ئاڕاستەی میلی کاتژمێر';

  @override
  String get entryActionFlip => 'Flip horizontally';

  @override
  String get entryActionPrint => 'چاپکردن';

  @override
  String get entryActionShare => 'بڵاوکردنەوە';

  @override
  String get entryActionShareImageOnly => 'بە تەنیا وێنە هاوبەش بکە';

  @override
  String get entryActionShareVideoOnly => 'بە تەنیا ڤیدیۆ هاوبەش بکە';

  @override
  String get entryActionViewSource => 'بینینی سەرچاوە';

  @override
  String get entryActionShowGeoTiffOnMap => 'Show as map overlay';

  @override
  String get entryActionConvertMotionPhotoToStillImage => 'Convert to still image';

  @override
  String get entryActionViewMotionPhotoVideo => 'کردنەوەی ڤیدیۆ';

  @override
  String get entryActionEdit => 'دەستکاریکردن';

  @override
  String get entryActionOpen => 'کردنەوە لەڕێی';

  @override
  String get entryActionSetAs => 'دانان وەک';

  @override
  String get entryActionCast => 'Cast';

  @override
  String get entryActionOpenMap => 'لە نەرمەواڵەی نەخشە پیشانی بدە';

  @override
  String get entryActionRotateScreen => 'سوڕانەوەی خۆکار';

  @override
  String get entryActionAddFavourite => 'زیادکردن بۆ دڵخواز';

  @override
  String get entryActionRemoveFavourite => 'لابردن لە دڵخواز';

  @override
  String get videoActionCaptureFrame => 'Capture frame';

  @override
  String get videoActionMute => 'بێدەنگکردن';

  @override
  String get videoActionUnmute => 'کاراکردنی دەنگ';

  @override
  String get videoActionPause => 'ڕاگرتن';

  @override
  String get videoActionPlay => 'لێدان';

  @override
  String get videoActionReplay10 => '١٠ چرکە بیبە پاش';

  @override
  String get videoActionSkip10 => '١٠ چرکە بیبە پێش';

  @override
  String get videoActionShowPreviousFrame => 'Show previous frame';

  @override
  String get videoActionShowNextFrame => 'Show next frame';

  @override
  String get videoActionSelectStreams => 'Select tracks';

  @override
  String get videoActionSetSpeed => 'خێرایی لێدان';

  @override
  String get videoActionABRepeat => 'A-B repeat';

  @override
  String get videoRepeatActionSetStart => 'Set start';

  @override
  String get videoRepeatActionSetEnd => 'Set end';

  @override
  String get viewerActionSettings => 'ڕێکخستنەکان';

  @override
  String get viewerActionLock => 'Lock viewer';

  @override
  String get viewerActionUnlock => 'Unlock viewer';

  @override
  String get slideshowActionResume => 'Resume';

  @override
  String get slideshowActionShowInCollection => 'Show in Collection';

  @override
  String get entryInfoActionEditDate => 'دەستکاری کردنی کات و ڕێکەوت';

  @override
  String get entryInfoActionEditLocation => 'دەستکاری کردنی شوێن';

  @override
  String get entryInfoActionEditTitleDescription => 'دەستکاری کردنی سەرناو و پێناس';

  @override
  String get entryInfoActionEditRating => 'دەستکاری کردنی هەڵسەنگاندن';

  @override
  String get entryInfoActionEditTags => 'Edit tags';

  @override
  String get entryInfoActionRemoveMetadata => 'Remove metadata';

  @override
  String get entryInfoActionExportMetadata => 'Export metadata';

  @override
  String get entryInfoActionRemoveLocation => 'سڕینەوەی شوێن';

  @override
  String get editorActionTransform => 'گواستنەوە';

  @override
  String get editorTransformCrop => 'Crop';

  @override
  String get editorTransformRotate => 'سوڕاندن';

  @override
  String get cropAspectRatioFree => 'ئازادانە';

  @override
  String get cropAspectRatioOriginal => 'Original';

  @override
  String get cropAspectRatioSquare => 'چوارگۆشە';

  @override
  String get filterAspectRatioLandscapeLabel => 'لاکێشە';

  @override
  String get filterAspectRatioPortraitLabel => 'Portrait';

  @override
  String get filterBinLabel => 'Recycle bin';

  @override
  String get filterFavouriteLabel => 'دڵخواز';

  @override
  String get filterNoDateLabel => 'بەڕۆژ کراوەتەوە';

  @override
  String get filterNoAddressLabel => 'بێ ناونیشان';

  @override
  String get filterLocatedLabel => 'Located';

  @override
  String get filterNoLocationLabel => 'Unlocated';

  @override
  String get filterNoRatingLabel => 'هەڵنەسەنگێنراو';

  @override
  String get filterTaggedLabel => 'Tagged';

  @override
  String get filterNoTagLabel => 'Untagged';

  @override
  String get filterNoTitleLabel => 'بێ سەرناو';

  @override
  String get filterOnThisDayLabel => 'لەم ڕۆژەدا';

  @override
  String get filterRecentlyAddedLabel => 'بەم دواییە زیاد کراو';

  @override
  String get filterRatingRejectedLabel => 'Rejected';

  @override
  String get filterTypeAnimatedLabel => 'Animated';

  @override
  String get filterTypeMotionPhotoLabel => 'وێنەی جوڵاو';

  @override
  String get filterTypePanoramaLabel => 'Panorama';

  @override
  String get filterTypeRawLabel => 'Raw';

  @override
  String get filterTypeSphericalVideoLabel => 'ڤیدیۆی سێ ڕەهەندی';

  @override
  String get filterTypeGeotiffLabel => 'GeoTIFF';

  @override
  String get filterMimeImageLabel => 'وێنە';

  @override
  String get filterMimeVideoLabel => 'ڤیدیۆ';

  @override
  String get accessibilityAnimationsRemove => 'Prevent screen effects';

  @override
  String get accessibilityAnimationsKeep => 'Keep screen effects';

  @override
  String get albumTierNew => 'نوێ';

  @override
  String get albumTierPinned => 'Pinned';

  @override
  String get albumTierSpecial => 'باو';

  @override
  String get albumTierApps => 'نەرمەواڵەکان';

  @override
  String get albumTierVaults => 'Vaults';

  @override
  String get albumTierDynamic => 'Dynamic';

  @override
  String get albumTierRegular => 'هی دیکە';

  @override
  String get coordinateFormatDms => 'DMS';

  @override
  String get coordinateFormatDdm => 'DDM';

  @override
  String get coordinateFormatDecimal => 'Decimal degrees';

  @override
  String coordinateDms(String coordinate, String direction) {
    return '$coordinate $direction';
  }

  @override
  String get coordinateDmsNorth => 'باکوور';

  @override
  String get coordinateDmsSouth => 'باشوور';

  @override
  String get coordinateDmsEast => 'ڕۆژهەڵات';

  @override
  String get coordinateDmsWest => 'ڕۆژاوا';

  @override
  String get displayRefreshRatePreferHighest => 'Highest rate';

  @override
  String get displayRefreshRatePreferLowest => 'Lowest rate';

  @override
  String get keepScreenOnNever => 'هەرگیز';

  @override
  String get keepScreenOnVideoPlayback => 'During video playback';

  @override
  String get keepScreenOnViewerOnly => 'Viewer page only';

  @override
  String get keepScreenOnAlways => 'بەردەوام';

  @override
  String get lengthUnitPixel => 'پیسکڵ';

  @override
  String get lengthUnitPercent => '٪';

  @override
  String get mapStyleGoogleNormal => 'نەخشەی گۆگڵ';

  @override
  String get mapStyleGoogleHybrid => 'Google Maps (Hybrid)';

  @override
  String get mapStyleGoogleTerrain => 'Google Maps (Terrain)';

  @override
  String get mapStyleOsmLiberty => 'OSM Liberty';

  @override
  String get mapStyleOpenTopoMap => 'OpenTopoMap';

  @override
  String get mapStyleOsmHot => 'Humanitarian OSM';

  @override
  String get mapStyleStamenWatercolor => 'Stamen Watercolor';

  @override
  String get maxBrightnessNever => 'هەرگیز';

  @override
  String get maxBrightnessAlways => 'بەردەوام';

  @override
  String get nameConflictStrategyRename => 'ناونانەوە';

  @override
  String get nameConflictStrategyReplace => 'جێگرتنەوە';

  @override
  String get nameConflictStrategySkip => 'بازدان';

  @override
  String get overlayHistogramNone => 'هیچیان';

  @override
  String get overlayHistogramRGB => 'RGB';

  @override
  String get overlayHistogramLuminance => 'Luminance';

  @override
  String get subtitlePositionTop => 'سەرەوە';

  @override
  String get subtitlePositionBottom => 'خوارەوە';

  @override
  String get themeBrightnessLight => 'ڕوون';

  @override
  String get themeBrightnessDark => 'تاریک';

  @override
  String get themeBrightnessBlack => 'ڕەش';

  @override
  String get unitSystemMetric => 'مەتری';

  @override
  String get unitSystemImperial => 'Imperial';

  @override
  String get vaultLockTypePattern => 'Pattern';

  @override
  String get vaultLockTypePin => 'PIN';

  @override
  String get vaultLockTypePassword => 'تێپەڕەوشە';

  @override
  String get settingsVideoEnablePip => 'وێنە لە وێنە';

  @override
  String get videoControlsPlayOutside => 'کردنەوە بە لێدەرێکی تر';

  @override
  String get videoLoopModeNever => 'هەرگیز';

  @override
  String get videoLoopModeShortOnly => 'تەنیا ڤیدیۆ کورتەکان';

  @override
  String get videoLoopModeAlways => 'بەردەوام';

  @override
  String get videoPlaybackSkip => 'بازدان';

  @override
  String get videoPlaybackMuted => 'بەبێ دەنگی لێبدە';

  @override
  String get videoPlaybackWithSound => 'بە دەنگەوە لێبدە';

  @override
  String get videoResumptionModeNever => 'هەرگیز';

  @override
  String get videoResumptionModeAlways => 'بەردەوام';

  @override
  String get viewerTransitionSlide => 'Slide';

  @override
  String get viewerTransitionParallax => 'Parallax';

  @override
  String get viewerTransitionFade => 'Fade';

  @override
  String get viewerTransitionZoomIn => 'Zoom in';

  @override
  String get viewerTransitionNone => 'هیچیان';

  @override
  String get wallpaperTargetHome => 'Home screen';

  @override
  String get wallpaperTargetLock => 'Lock screen';

  @override
  String get wallpaperTargetHomeLock => 'Home and lock screens';

  @override
  String get widgetDisplayedItemRandom => 'هەڕەمەکی';

  @override
  String get widgetDisplayedItemMostRecent => 'Most recent';

  @override
  String get widgetOpenPageHome => 'Open home';

  @override
  String get widgetOpenPageCollection => 'Open collection';

  @override
  String get widgetOpenPageViewer => 'Open viewer';

  @override
  String get widgetTapUpdateWidget => 'Update widget';

  @override
  String get storageVolumeDescriptionFallbackPrimary => 'بیرگەی ناوەکی';

  @override
  String get storageVolumeDescriptionFallbackNonPrimary => 'SD card';

  @override
  String get rootDirectoryDescription => 'root directory';

  @override
  String otherDirectoryDescription(String name) {
    return '“$name” directory';
  }

  @override
  String storageAccessDialogMessage(String directory, String volume) {
    return 'Please select the $directory of “$volume” in the next screen to give this app access to it.';
  }

  @override
  String restrictedAccessDialogMessage(String directory, String volume) {
    return 'This app is not allowed to modify files in the $directory of “$volume”.\n\nPlease use a pre-installed file manager or gallery app to move the items to another directory.';
  }

  @override
  String notEnoughSpaceDialogMessage(String neededSize, String freeSize, String volume) {
    return 'This operation needs $neededSize of free space on “$volume” to complete, but there is only $freeSize left.';
  }

  @override
  String get missingSystemFilePickerDialogMessage => 'The system file picker is missing or disabled. Please enable it and try again.';

  @override
  String unsupportedTypeDialogMessage(int count, String types) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'This operation is not supported for items of the following types: $types.',
      one: 'This operation is not supported for items of the following type: $types.',
    );
    return '$_temp0';
  }

  @override
  String get nameConflictDialogSingleSourceMessage => 'Some files in the destination folder have the same name.';

  @override
  String get nameConflictDialogMultipleSourceMessage => 'هەندێک لە پەڕگەکان هەمان ناویان هەیە.';

  @override
  String get addShortcutDialogLabel => 'Shortcut label';

  @override
  String get addShortcutButtonLabel => 'زیادکردن';

  @override
  String get noMatchingAppDialogMessage => 'There are no apps that can handle this.';

  @override
  String binEntriesConfirmationDialogMessage(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Move these $countString items to the recycle bin?',
      one: 'Move this item to the recycle bin?',
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
      other: 'Delete these $countString items?',
      one: 'Delete this item?',
    );
    return '$_temp0';
  }

  @override
  String get moveUndatedConfirmationDialogMessage => 'Save item dates before proceeding?';

  @override
  String get moveUndatedConfirmationDialogSetDate => 'Save dates';

  @override
  String videoResumeDialogMessage(String time) {
    return 'Do you want to resume playing at $time?';
  }

  @override
  String get videoStartOverButtonLabel => 'START OVER';

  @override
  String get videoResumeButtonLabel => 'RESUME';

  @override
  String get setCoverDialogLatest => 'Latest item';

  @override
  String get setCoverDialogAuto => 'Auto';

  @override
  String get setCoverDialogCustom => 'Custom';

  @override
  String get hideFilterConfirmationDialogMessage => 'Matching photos and videos will be hidden from your collection. You can show them again from the “Privacy” settings.\n\nAre you sure you want to hide them?';

  @override
  String get newAlbumDialogTitle => 'New Album';

  @override
  String get newAlbumDialogNameLabel => 'Album name';

  @override
  String get newAlbumDialogAlbumAlreadyExistsHelper => 'Album already exists';

  @override
  String get newAlbumDialogNameLabelAlreadyExistsHelper => 'Directory already exists';

  @override
  String get newAlbumDialogStorageLabel => 'Storage:';

  @override
  String get newDynamicAlbumDialogTitle => 'New Dynamic Album';

  @override
  String get dynamicAlbumAlreadyExists => 'Dynamic album already exists';

  @override
  String get newVaultWarningDialogMessage => 'Items in vaults are only available to this app and no others.\n\nIf you uninstall this app, or clear this app data, you will lose all these items.';

  @override
  String get newVaultDialogTitle => 'New Vault';

  @override
  String get configureVaultDialogTitle => 'Configure Vault';

  @override
  String get vaultDialogLockModeWhenScreenOff => 'Lock when screen turns off';

  @override
  String get vaultDialogLockTypeLabel => 'Lock type';

  @override
  String get patternDialogEnter => 'Enter pattern';

  @override
  String get patternDialogConfirm => 'Confirm pattern';

  @override
  String get pinDialogEnter => 'Enter PIN';

  @override
  String get pinDialogConfirm => 'Confirm PIN';

  @override
  String get passwordDialogEnter => 'Enter password';

  @override
  String get passwordDialogConfirm => 'Confirm password';

  @override
  String get authenticateToConfigureVault => 'Authenticate to configure vault';

  @override
  String get authenticateToUnlockVault => 'Authenticate to unlock vault';

  @override
  String get vaultBinUsageDialogMessage => 'Some vaults are using the recycle bin.';

  @override
  String get renameAlbumDialogLabel => 'New name';

  @override
  String get renameAlbumDialogLabelAlreadyExistsHelper => 'Directory already exists';

  @override
  String get renameEntrySetPageTitle => 'Rename';

  @override
  String get renameEntrySetPagePatternFieldLabel => 'Naming pattern';

  @override
  String get renameEntrySetPageInsertTooltip => 'Insert field';

  @override
  String get renameEntrySetPagePreviewSectionTitle => 'Preview';

  @override
  String get renameProcessorCounter => 'Counter';

  @override
  String get renameProcessorHash => 'Hash';

  @override
  String get renameProcessorName => 'Name';

  @override
  String deleteSingleAlbumConfirmationDialogMessage(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Delete this album and the $countString items in it?',
      one: 'Delete this album and the item in it?',
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
      other: 'Delete these albums and the $countString items in them?',
      one: 'Delete these albums and the item in them?',
    );
    return '$_temp0';
  }

  @override
  String get exportEntryDialogFormat => 'Format:';

  @override
  String get exportEntryDialogWidth => 'Width';

  @override
  String get exportEntryDialogHeight => 'Height';

  @override
  String get exportEntryDialogQuality => 'Quality';

  @override
  String get exportEntryDialogWriteMetadata => 'Write metadata';

  @override
  String get renameEntryDialogLabel => 'New name';

  @override
  String get editEntryDialogCopyFromItem => 'Copy from other item';

  @override
  String get editEntryDialogTargetFieldsHeader => 'Fields to modify';

  @override
  String get editEntryDateDialogTitle => 'Date & Time';

  @override
  String get editEntryDateDialogSetCustom => 'Set custom date';

  @override
  String get editEntryDateDialogCopyField => 'Copy from other date';

  @override
  String get editEntryDateDialogExtractFromTitle => 'Extract from title';

  @override
  String get editEntryDateDialogShift => 'Shift';

  @override
  String get editEntryDateDialogSourceFileModifiedDate => 'File modified date';

  @override
  String get durationDialogHours => 'Hours';

  @override
  String get durationDialogMinutes => 'Minutes';

  @override
  String get durationDialogSeconds => 'Seconds';

  @override
  String get editEntryLocationDialogTitle => 'Location';

  @override
  String get editEntryLocationDialogSetCustom => 'Set custom location';

  @override
  String get editEntryLocationDialogChooseOnMap => 'Choose on map';

  @override
  String get editEntryLocationDialogImportGpx => 'Import GPX';

  @override
  String get editEntryLocationDialogLatitude => 'Latitude';

  @override
  String get editEntryLocationDialogLongitude => 'Longitude';

  @override
  String get editEntryLocationDialogTimeShift => 'Time shift';

  @override
  String get locationPickerUseThisLocationButton => 'Use this location';

  @override
  String get editEntryRatingDialogTitle => 'Rating';

  @override
  String get removeEntryMetadataDialogTitle => 'Metadata Removal';

  @override
  String get removeEntryMetadataDialogAll => 'All';

  @override
  String get removeEntryMetadataDialogMore => 'More';

  @override
  String get removeEntryMetadataMotionPhotoXmpWarningDialogMessage => 'XMP is required to play the video inside a motion photo.\n\nAre you sure you want to remove it?';

  @override
  String get videoSpeedDialogLabel => 'Playback speed';

  @override
  String get videoStreamSelectionDialogVideo => 'Video';

  @override
  String get videoStreamSelectionDialogAudio => 'Audio';

  @override
  String get videoStreamSelectionDialogText => 'Subtitles';

  @override
  String get videoStreamSelectionDialogOff => 'Off';

  @override
  String get videoStreamSelectionDialogTrack => 'Track';

  @override
  String get videoStreamSelectionDialogNoSelection => 'There are no other tracks.';

  @override
  String get genericSuccessFeedback => 'Done!';

  @override
  String get genericFailureFeedback => 'Failed';

  @override
  String get genericDangerWarningDialogMessage => 'Are you sure?';

  @override
  String get tooManyItemsErrorDialogMessage => 'Try again with fewer items.';

  @override
  String get menuActionConfigureView => 'View';

  @override
  String get menuActionSelect => 'Select';

  @override
  String get menuActionSelectAll => 'Select all';

  @override
  String get menuActionSelectNone => 'Select none';

  @override
  String get menuActionMap => 'Map';

  @override
  String get menuActionSlideshow => 'Slideshow';

  @override
  String get menuActionStats => 'Stats';

  @override
  String get viewDialogSortSectionTitle => 'Sort';

  @override
  String get viewDialogGroupSectionTitle => 'Group';

  @override
  String get viewDialogLayoutSectionTitle => 'Layout';

  @override
  String get viewDialogReverseSortOrder => 'Reverse sort order';

  @override
  String get tileLayoutMosaic => 'Mosaic';

  @override
  String get tileLayoutGrid => 'Grid';

  @override
  String get tileLayoutList => 'List';

  @override
  String get castDialogTitle => 'Cast Devices';

  @override
  String get coverDialogTabCover => 'Cover';

  @override
  String get coverDialogTabApp => 'App';

  @override
  String get coverDialogTabColor => 'Color';

  @override
  String get appPickDialogTitle => 'Pick App';

  @override
  String get appPickDialogNone => 'None';

  @override
  String get aboutPageTitle => 'About';

  @override
  String get aboutLinkLicense => 'License';

  @override
  String get aboutLinkPolicy => 'Privacy Policy';

  @override
  String get aboutBugSectionTitle => 'Bug Report';

  @override
  String get aboutBugSaveLogInstruction => 'Save app logs to a file';

  @override
  String get aboutBugCopyInfoInstruction => 'Copy system information';

  @override
  String get aboutBugCopyInfoButton => 'Copy';

  @override
  String get aboutBugReportInstruction => 'Report on GitHub with the logs and system information';

  @override
  String get aboutBugReportButton => 'Report';

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
  String get aboutCreditsWorldAtlas1 => 'This app uses a TopoJSON file from';

  @override
  String get aboutCreditsWorldAtlas2 => 'under ISC License.';

  @override
  String get aboutTranslatorsSectionTitle => 'Translators';

  @override
  String get aboutLicensesSectionTitle => 'Open-Source Licenses';

  @override
  String get aboutLicensesBanner => 'This app uses the following open-source packages and libraries.';

  @override
  String get aboutLicensesAndroidLibrariesSectionTitle => 'Android Libraries';

  @override
  String get aboutLicensesFlutterPluginsSectionTitle => 'Flutter Plugins';

  @override
  String get aboutLicensesFlutterPackagesSectionTitle => 'Flutter Packages';

  @override
  String get aboutLicensesDartPackagesSectionTitle => 'Dart Packages';

  @override
  String get aboutLicensesShowAllButtonLabel => 'Show All Licenses';

  @override
  String get policyPageTitle => 'Privacy Policy';

  @override
  String get collectionPageTitle => 'Collection';

  @override
  String get collectionPickPageTitle => 'Pick';

  @override
  String get collectionSelectPageTitle => 'Select items';

  @override
  String get collectionActionShowTitleSearch => 'Show title filter';

  @override
  String get collectionActionHideTitleSearch => 'Hide title filter';

  @override
  String get collectionActionAddDynamicAlbum => 'Add dynamic album';

  @override
  String get collectionActionAddShortcut => 'Add shortcut';

  @override
  String get collectionActionSetHome => 'Set as home';

  @override
  String get collectionActionEmptyBin => 'Empty bin';

  @override
  String get collectionActionCopy => 'Copy to album';

  @override
  String get collectionActionMove => 'Move to album';

  @override
  String get collectionActionRescan => 'Rescan';

  @override
  String get collectionActionEdit => 'Edit';

  @override
  String get collectionSearchTitlesHintText => 'Search titles';

  @override
  String get collectionGroupAlbum => 'By album';

  @override
  String get collectionGroupMonth => 'By month';

  @override
  String get collectionGroupDay => 'By day';

  @override
  String get collectionGroupNone => 'Do not group';

  @override
  String get sectionUnknown => 'Unknown';

  @override
  String get dateToday => 'Today';

  @override
  String get dateYesterday => 'Yesterday';

  @override
  String get dateThisMonth => 'This month';

  @override
  String collectionDeleteFailureFeedback(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Failed to delete $countString items',
      one: 'Failed to delete 1 item',
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
      other: 'Failed to copy $countString items',
      one: 'Failed to copy 1 item',
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
      other: 'Failed to move $countString items',
      one: 'Failed to move 1 item',
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
      other: 'Failed to rename $countString items',
      one: 'Failed to rename 1 item',
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
      other: 'Failed to edit $countString items',
      one: 'Failed to edit 1 item',
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
      other: 'Failed to export $countString pages',
      one: 'Failed to export 1 page',
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
      other: 'Copied $countString items',
      one: 'Copied 1 item',
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
      other: 'Moved $countString items',
      one: 'Moved 1 item',
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
      other: 'Renamed $countString items',
      one: 'Renamed 1 item',
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
      other: 'Edited $countString items',
      one: 'Edited 1 item',
    );
    return '$_temp0';
  }

  @override
  String get collectionEmptyFavourites => 'No favorites';

  @override
  String get collectionEmptyVideos => 'No videos';

  @override
  String get collectionEmptyImages => 'No images';

  @override
  String get collectionEmptyGrantAccessButtonLabel => 'Grant access';

  @override
  String get collectionSelectSectionTooltip => 'Select section';

  @override
  String get collectionDeselectSectionTooltip => 'Deselect section';

  @override
  String get drawerAboutButton => 'About';

  @override
  String get drawerSettingsButton => 'Settings';

  @override
  String get drawerCollectionAll => 'All collection';

  @override
  String get drawerCollectionFavourites => 'Favorites';

  @override
  String get drawerCollectionImages => 'Images';

  @override
  String get drawerCollectionVideos => 'Videos';

  @override
  String get drawerCollectionAnimated => 'Animated';

  @override
  String get drawerCollectionMotionPhotos => 'Motion photos';

  @override
  String get drawerCollectionPanoramas => 'Panoramas';

  @override
  String get drawerCollectionRaws => 'Raw photos';

  @override
  String get drawerCollectionSphericalVideos => '360° Videos';

  @override
  String get drawerAlbumPage => 'Albums';

  @override
  String get drawerCountryPage => 'Countries';

  @override
  String get drawerPlacePage => 'Places';

  @override
  String get drawerTagPage => 'Tags';

  @override
  String get sortByDate => 'By date';

  @override
  String get sortByName => 'By name';

  @override
  String get sortByItemCount => 'By item count';

  @override
  String get sortBySize => 'By size';

  @override
  String get sortByAlbumFileName => 'By album & file name';

  @override
  String get sortByRating => 'By rating';

  @override
  String get sortByDuration => 'By duration';

  @override
  String get sortByPath => 'By path';

  @override
  String get sortOrderNewestFirst => 'Newest first';

  @override
  String get sortOrderOldestFirst => 'Oldest first';

  @override
  String get sortOrderAtoZ => 'A to Z';

  @override
  String get sortOrderZtoA => 'Z to A';

  @override
  String get sortOrderHighestFirst => 'Highest first';

  @override
  String get sortOrderLowestFirst => 'Lowest first';

  @override
  String get sortOrderLargestFirst => 'Largest first';

  @override
  String get sortOrderSmallestFirst => 'Smallest first';

  @override
  String get sortOrderShortestFirst => 'Shortest first';

  @override
  String get sortOrderLongestFirst => 'Longest first';

  @override
  String get albumGroupTier => 'By tier';

  @override
  String get albumGroupType => 'By type';

  @override
  String get albumGroupVolume => 'By storage volume';

  @override
  String get albumGroupNone => 'Do not group';

  @override
  String get albumMimeTypeMixed => 'Mixed';

  @override
  String get albumPickPageTitleCopy => 'Copy to Album';

  @override
  String get albumPickPageTitleExport => 'Export to Album';

  @override
  String get albumPickPageTitleMove => 'Move to Album';

  @override
  String get albumPickPageTitlePick => 'Pick Album';

  @override
  String get albumCamera => 'Camera';

  @override
  String get albumDownload => 'Download';

  @override
  String get albumScreenshots => 'Screenshots';

  @override
  String get albumScreenRecordings => 'Screen recordings';

  @override
  String get albumVideoCaptures => 'Video Captures';

  @override
  String get albumPageTitle => 'Albums';

  @override
  String get albumEmpty => 'No albums';

  @override
  String get createAlbumButtonLabel => 'CREATE';

  @override
  String get newFilterBanner => 'new';

  @override
  String get countryPageTitle => 'Countries';

  @override
  String get countryEmpty => 'No countries';

  @override
  String get statePageTitle => 'States';

  @override
  String get stateEmpty => 'No states';

  @override
  String get placePageTitle => 'Places';

  @override
  String get placeEmpty => 'No places';

  @override
  String get tagPageTitle => 'Tags';

  @override
  String get tagEmpty => 'No tags';

  @override
  String get binPageTitle => 'Recycle Bin';

  @override
  String get explorerPageTitle => 'Explorer';

  @override
  String get explorerActionSelectStorageVolume => 'Select storage';

  @override
  String get selectStorageVolumeDialogTitle => 'Select Storage';

  @override
  String get searchCollectionFieldHint => 'Search collection';

  @override
  String get searchRecentSectionTitle => 'Recent';

  @override
  String get searchDateSectionTitle => 'Date';

  @override
  String get searchFormatSectionTitle => 'Formats';

  @override
  String get searchAlbumsSectionTitle => 'Albums';

  @override
  String get searchCountriesSectionTitle => 'Countries';

  @override
  String get searchStatesSectionTitle => 'States';

  @override
  String get searchPlacesSectionTitle => 'Places';

  @override
  String get searchTagsSectionTitle => 'Tags';

  @override
  String get searchRatingSectionTitle => 'Ratings';

  @override
  String get searchMetadataSectionTitle => 'Metadata';

  @override
  String get settingsPageTitle => 'Settings';

  @override
  String get settingsSystemDefault => 'System default';

  @override
  String get settingsDefault => 'Default';

  @override
  String get settingsDisabled => 'Disabled';

  @override
  String get settingsAskEverytime => 'Ask everytime';

  @override
  String get settingsModificationWarningDialogMessage => 'Other settings will be modified.';

  @override
  String get settingsSearchFieldLabel => 'Search settings';

  @override
  String get settingsSearchEmpty => 'No matching setting';

  @override
  String get settingsActionExport => 'Export';

  @override
  String get settingsActionExportDialogTitle => 'Export';

  @override
  String get settingsActionImport => 'Import';

  @override
  String get settingsActionImportDialogTitle => 'Import';

  @override
  String get appExportCovers => 'Covers';

  @override
  String get appExportDynamicAlbums => 'Dynamic albums';

  @override
  String get appExportFavourites => 'Favorites';

  @override
  String get appExportSettings => 'Settings';

  @override
  String get settingsNavigationSectionTitle => 'Navigation';

  @override
  String get settingsHomeTile => 'Home';

  @override
  String get settingsHomeDialogTitle => 'Home';

  @override
  String get setHomeCustom => 'Custom';

  @override
  String get settingsShowBottomNavigationBar => 'Show bottom navigation bar';

  @override
  String get settingsKeepScreenOnTile => 'Keep screen on';

  @override
  String get settingsKeepScreenOnDialogTitle => 'Keep Screen On';

  @override
  String get settingsDoubleBackExit => 'Tap “back” twice to exit';

  @override
  String get settingsConfirmationTile => 'Confirmation dialogs';

  @override
  String get settingsConfirmationDialogTitle => 'Confirmation Dialogs';

  @override
  String get settingsConfirmationBeforeDeleteItems => 'Ask before deleting items forever';

  @override
  String get settingsConfirmationBeforeMoveToBinItems => 'Ask before moving items to the recycle bin';

  @override
  String get settingsConfirmationBeforeMoveUndatedItems => 'Ask before moving undated items';

  @override
  String get settingsConfirmationAfterMoveToBinItems => 'Show message after moving items to the recycle bin';

  @override
  String get settingsConfirmationVaultDataLoss => 'Show vault data loss warning';

  @override
  String get settingsNavigationDrawerTile => 'Navigation menu';

  @override
  String get settingsNavigationDrawerEditorPageTitle => 'Navigation Menu';

  @override
  String get settingsNavigationDrawerBanner => 'Touch and hold to move and reorder menu items.';

  @override
  String get settingsNavigationDrawerTabTypes => 'Types';

  @override
  String get settingsNavigationDrawerTabAlbums => 'Albums';

  @override
  String get settingsNavigationDrawerTabPages => 'Pages';

  @override
  String get settingsNavigationDrawerAddAlbum => 'Add album';

  @override
  String get settingsThumbnailSectionTitle => 'Thumbnails';

  @override
  String get settingsThumbnailOverlayTile => 'Overlay';

  @override
  String get settingsThumbnailOverlayPageTitle => 'Overlay';

  @override
  String get settingsThumbnailShowHdrIcon => 'Show HDR icon';

  @override
  String get settingsThumbnailShowFavouriteIcon => 'Show favorite icon';

  @override
  String get settingsThumbnailShowTagIcon => 'Show tag icon';

  @override
  String get settingsThumbnailShowLocationIcon => 'Show location icon';

  @override
  String get settingsThumbnailShowMotionPhotoIcon => 'Show motion photo icon';

  @override
  String get settingsThumbnailShowRating => 'Show rating';

  @override
  String get settingsThumbnailShowRawIcon => 'Show raw icon';

  @override
  String get settingsThumbnailShowVideoDuration => 'Show video duration';

  @override
  String get settingsCollectionQuickActionsTile => 'Quick actions';

  @override
  String get settingsCollectionQuickActionEditorPageTitle => 'Quick Actions';

  @override
  String get settingsCollectionQuickActionTabBrowsing => 'Browsing';

  @override
  String get settingsCollectionQuickActionTabSelecting => 'Selecting';

  @override
  String get settingsCollectionBrowsingQuickActionEditorBanner => 'Touch and hold to move buttons and select which actions are displayed when browsing items.';

  @override
  String get settingsCollectionSelectionQuickActionEditorBanner => 'Touch and hold to move buttons and select which actions are displayed when selecting items.';

  @override
  String get settingsCollectionBurstPatternsTile => 'Burst patterns';

  @override
  String get settingsCollectionBurstPatternsNone => 'None';

  @override
  String get settingsViewerSectionTitle => 'Viewer';

  @override
  String get settingsViewerGestureSideTapNext => 'Tap on screen edges to show previous/next item';

  @override
  String get settingsViewerUseCutout => 'Use cutout area';

  @override
  String get settingsViewerMaximumBrightness => 'Maximum brightness';

  @override
  String get settingsMotionPhotoAutoPlay => 'Auto play motion photos';

  @override
  String get settingsImageBackground => 'Image background';

  @override
  String get settingsViewerQuickActionsTile => 'Quick actions';

  @override
  String get settingsViewerQuickActionEditorPageTitle => 'Quick Actions';

  @override
  String get settingsViewerQuickActionEditorBanner => 'Touch and hold to move buttons and select which actions are displayed in the viewer.';

  @override
  String get settingsViewerQuickActionEditorDisplayedButtonsSectionTitle => 'Displayed Buttons';

  @override
  String get settingsViewerQuickActionEditorAvailableButtonsSectionTitle => 'Available Buttons';

  @override
  String get settingsViewerQuickActionEmpty => 'No buttons';

  @override
  String get settingsViewerOverlayTile => 'Overlay';

  @override
  String get settingsViewerOverlayPageTitle => 'Overlay';

  @override
  String get settingsViewerShowOverlayOnOpening => 'Show on opening';

  @override
  String get settingsViewerShowHistogram => 'Show histogram';

  @override
  String get settingsViewerShowMinimap => 'Show minimap';

  @override
  String get settingsViewerShowInformation => 'Show information';

  @override
  String get settingsViewerShowInformationSubtitle => 'Show title, date, location, etc.';

  @override
  String get settingsViewerShowRatingTags => 'Show rating & tags';

  @override
  String get settingsViewerShowShootingDetails => 'Show shooting details';

  @override
  String get settingsViewerShowDescription => 'Show description';

  @override
  String get settingsViewerShowOverlayThumbnails => 'Show thumbnails';

  @override
  String get settingsViewerEnableOverlayBlurEffect => 'Blur effect';

  @override
  String get settingsViewerSlideshowTile => 'Slideshow';

  @override
  String get settingsViewerSlideshowPageTitle => 'Slideshow';

  @override
  String get settingsSlideshowRepeat => 'Repeat';

  @override
  String get settingsSlideshowShuffle => 'Shuffle';

  @override
  String get settingsSlideshowFillScreen => 'Fill screen';

  @override
  String get settingsSlideshowAnimatedZoomEffect => 'Animated zoom effect';

  @override
  String get settingsSlideshowTransitionTile => 'Transition';

  @override
  String get settingsSlideshowIntervalTile => 'Interval';

  @override
  String get settingsSlideshowVideoPlaybackTile => 'Video playback';

  @override
  String get settingsSlideshowVideoPlaybackDialogTitle => 'Video Playback';

  @override
  String get settingsVideoPageTitle => 'Video Settings';

  @override
  String get settingsVideoSectionTitle => 'Video';

  @override
  String get settingsVideoShowVideos => 'Show videos';

  @override
  String get settingsVideoPlaybackTile => 'Playback';

  @override
  String get settingsVideoPlaybackPageTitle => 'Playback';

  @override
  String get settingsVideoEnableHardwareAcceleration => 'Hardware acceleration';

  @override
  String get settingsVideoAutoPlay => 'Auto play';

  @override
  String get settingsVideoLoopModeTile => 'Loop mode';

  @override
  String get settingsVideoLoopModeDialogTitle => 'Loop Mode';

  @override
  String get settingsVideoResumptionModeTile => 'Resume playback';

  @override
  String get settingsVideoResumptionModeDialogTitle => 'Resume Playback';

  @override
  String get settingsVideoBackgroundMode => 'Background mode';

  @override
  String get settingsVideoBackgroundModeDialogTitle => 'Background Mode';

  @override
  String get settingsVideoControlsTile => 'Controls';

  @override
  String get settingsVideoControlsPageTitle => 'Controls';

  @override
  String get settingsVideoButtonsTile => 'Buttons';

  @override
  String get settingsVideoGestureDoubleTapTogglePlay => 'Double tap to play/pause';

  @override
  String get settingsVideoGestureSideDoubleTapSeek => 'Double tap on screen edges to seek backward/forward';

  @override
  String get settingsVideoGestureVerticalDragBrightnessVolume => 'Swipe up or down to adjust brightness/volume';

  @override
  String get settingsSubtitleThemeTile => 'Subtitles';

  @override
  String get settingsSubtitleThemePageTitle => 'Subtitles';

  @override
  String get settingsSubtitleThemeSample => 'This is a sample.';

  @override
  String get settingsSubtitleThemeTextAlignmentTile => 'Text alignment';

  @override
  String get settingsSubtitleThemeTextAlignmentDialogTitle => 'Text Alignment';

  @override
  String get settingsSubtitleThemeTextPositionTile => 'Text position';

  @override
  String get settingsSubtitleThemeTextPositionDialogTitle => 'Text Position';

  @override
  String get settingsSubtitleThemeTextSize => 'Text size';

  @override
  String get settingsSubtitleThemeShowOutline => 'Show outline and shadow';

  @override
  String get settingsSubtitleThemeTextColor => 'Text color';

  @override
  String get settingsSubtitleThemeTextOpacity => 'Text opacity';

  @override
  String get settingsSubtitleThemeBackgroundColor => 'Background color';

  @override
  String get settingsSubtitleThemeBackgroundOpacity => 'Background opacity';

  @override
  String get settingsSubtitleThemeTextAlignmentLeft => 'Left';

  @override
  String get settingsSubtitleThemeTextAlignmentCenter => 'Center';

  @override
  String get settingsSubtitleThemeTextAlignmentRight => 'Right';

  @override
  String get settingsPrivacySectionTitle => 'Privacy';

  @override
  String get settingsAllowInstalledAppAccess => 'Allow access to app inventory';

  @override
  String get settingsAllowInstalledAppAccessSubtitle => 'Used to improve album display';

  @override
  String get settingsAllowErrorReporting => 'Allow anonymous error reporting';

  @override
  String get settingsSaveSearchHistory => 'Save search history';

  @override
  String get settingsEnableBin => 'Use recycle bin';

  @override
  String get settingsEnableBinSubtitle => 'Keep deleted items for 30 days';

  @override
  String get settingsDisablingBinWarningDialogMessage => 'Items in the recycle bin will be deleted forever.';

  @override
  String get settingsAllowMediaManagement => 'Allow media management';

  @override
  String get settingsHiddenItemsTile => 'Hidden items';

  @override
  String get settingsHiddenItemsPageTitle => 'Hidden Items';

  @override
  String get settingsHiddenFiltersBanner => 'Photos and videos matching hidden filters will not appear in your collection.';

  @override
  String get settingsHiddenFiltersEmpty => 'No hidden filters';

  @override
  String get settingsStorageAccessTile => 'Storage access';

  @override
  String get settingsStorageAccessPageTitle => 'Storage Access';

  @override
  String get settingsStorageAccessBanner => 'Some directories require an explicit access grant to modify files in them. You can review here directories to which you previously gave access.';

  @override
  String get settingsStorageAccessEmpty => 'No access grants';

  @override
  String get settingsStorageAccessRevokeTooltip => 'Revoke';

  @override
  String get settingsAccessibilitySectionTitle => 'Accessibility';

  @override
  String get settingsRemoveAnimationsTile => 'Remove animations';

  @override
  String get settingsRemoveAnimationsDialogTitle => 'Remove Animations';

  @override
  String get settingsTimeToTakeActionTile => 'Time to take action';

  @override
  String get settingsAccessibilityShowPinchGestureAlternatives => 'Show multi-touch gesture alternatives';

  @override
  String get settingsDisplaySectionTitle => 'Display';

  @override
  String get settingsThemeBrightnessTile => 'Theme';

  @override
  String get settingsThemeBrightnessDialogTitle => 'Theme';

  @override
  String get settingsThemeColorHighlights => 'Color highlights';

  @override
  String get settingsThemeEnableDynamicColor => 'Dynamic color';

  @override
  String get settingsDisplayRefreshRateModeTile => 'Display refresh rate';

  @override
  String get settingsDisplayRefreshRateModeDialogTitle => 'Refresh Rate';

  @override
  String get settingsDisplayUseTvInterface => 'Android TV interface';

  @override
  String get settingsLanguageSectionTitle => 'Language & Formats';

  @override
  String get settingsLanguageTile => 'Language';

  @override
  String get settingsLanguagePageTitle => 'Language';

  @override
  String get settingsCoordinateFormatTile => 'Coordinate format';

  @override
  String get settingsCoordinateFormatDialogTitle => 'Coordinate Format';

  @override
  String get settingsUnitSystemTile => 'Units';

  @override
  String get settingsUnitSystemDialogTitle => 'Units';

  @override
  String get settingsForceWesternArabicNumeralsTile => 'Force Arabic numerals';

  @override
  String get settingsScreenSaverPageTitle => 'Screen Saver';

  @override
  String get settingsWidgetPageTitle => 'Photo Frame';

  @override
  String get settingsWidgetShowOutline => 'Outline';

  @override
  String get settingsWidgetOpenPage => 'When tapping on the widget';

  @override
  String get settingsWidgetDisplayedItem => 'Displayed item';

  @override
  String get settingsCollectionTile => 'Collection';

  @override
  String get statsPageTitle => 'Stats';

  @override
  String statsWithGps(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString items with location',
      one: '1 item with location',
    );
    return '$_temp0';
  }

  @override
  String get statsTopCountriesSectionTitle => 'Top Countries';

  @override
  String get statsTopStatesSectionTitle => 'Top States';

  @override
  String get statsTopPlacesSectionTitle => 'Top Places';

  @override
  String get statsTopTagsSectionTitle => 'Top Tags';

  @override
  String get statsTopAlbumsSectionTitle => 'Top Albums';

  @override
  String get viewerOpenPanoramaButtonLabel => 'OPEN PANORAMA';

  @override
  String get viewerSetWallpaperButtonLabel => 'SET WALLPAPER';

  @override
  String get viewerErrorUnknown => 'Oops!';

  @override
  String get viewerErrorDoesNotExist => 'The file no longer exists.';

  @override
  String get viewerInfoPageTitle => 'Info';

  @override
  String get viewerInfoBackToViewerTooltip => 'Back to viewer';

  @override
  String get viewerInfoUnknown => 'unknown';

  @override
  String get viewerInfoLabelDescription => 'Description';

  @override
  String get viewerInfoLabelTitle => 'Title';

  @override
  String get viewerInfoLabelDate => 'Date';

  @override
  String get viewerInfoLabelResolution => 'Resolution';

  @override
  String get viewerInfoLabelSize => 'Size';

  @override
  String get viewerInfoLabelUri => 'URI';

  @override
  String get viewerInfoLabelPath => 'Path';

  @override
  String get viewerInfoLabelDuration => 'Duration';

  @override
  String get viewerInfoLabelOwner => 'Owner';

  @override
  String get viewerInfoLabelCoordinates => 'Coordinates';

  @override
  String get viewerInfoLabelAddress => 'Address';

  @override
  String get mapStyleDialogTitle => 'Map Style';

  @override
  String get mapStyleTooltip => 'Select map style';

  @override
  String get mapZoomInTooltip => 'Zoom in';

  @override
  String get mapZoomOutTooltip => 'Zoom out';

  @override
  String get mapPointNorthUpTooltip => 'Point north up';

  @override
  String get mapAttributionOsmData => 'Map data © [OpenStreetMap](https://www.openstreetmap.org/copyright) contributors';

  @override
  String get mapAttributionOsmLiberty => 'Tiles by [OpenMapTiles](https://www.openmaptiles.org/), [CC BY](http://creativecommons.org/licenses/by/4.0) • Hosted by [OSM Americana](https://tile.ourmap.us)';

  @override
  String get mapAttributionOpenTopoMap => '[SRTM](https://www.earthdata.nasa.gov/sensors/srtm) | Tiles by [OpenTopoMap](https://opentopomap.org/), [CC BY-SA](https://creativecommons.org/licenses/by-sa/3.0/)';

  @override
  String get mapAttributionOsmHot => 'Tiles by [HOT](https://www.hotosm.org/) • Hosted by [OSM France](https://openstreetmap.fr/)';

  @override
  String get mapAttributionStamen => 'Tiles by [Stamen Design](https://stamen.com), [CC BY 3.0](https://creativecommons.org/licenses/by/3.0)';

  @override
  String get openMapPageTooltip => 'View on Map page';

  @override
  String get mapEmptyRegion => 'No images in this region';

  @override
  String get viewerInfoOpenEmbeddedFailureFeedback => 'Failed to extract embedded data';

  @override
  String get viewerInfoOpenLinkText => 'Open';

  @override
  String get viewerInfoViewXmlLinkText => 'View XML';

  @override
  String get viewerInfoSearchFieldLabel => 'Search metadata';

  @override
  String get viewerInfoSearchEmpty => 'No matching keys';

  @override
  String get viewerInfoSearchSuggestionDate => 'Date & time';

  @override
  String get viewerInfoSearchSuggestionDescription => 'Description';

  @override
  String get viewerInfoSearchSuggestionDimensions => 'Dimensions';

  @override
  String get viewerInfoSearchSuggestionResolution => 'Resolution';

  @override
  String get viewerInfoSearchSuggestionRights => 'Rights';

  @override
  String get wallpaperUseScrollEffect => 'Use scroll effect on home screen';

  @override
  String get tagEditorPageTitle => 'Edit Tags';

  @override
  String get tagEditorPageNewTagFieldLabel => 'New tag';

  @override
  String get tagEditorPageAddTagTooltip => 'Add tag';

  @override
  String get tagEditorSectionRecent => 'Recent';

  @override
  String get tagEditorSectionPlaceholders => 'Placeholders';

  @override
  String get tagEditorDiscardDialogMessage => 'Do you want to discard changes?';

  @override
  String get tagPlaceholderCountry => 'Country';

  @override
  String get tagPlaceholderState => 'State';

  @override
  String get tagPlaceholderPlace => 'Place';

  @override
  String get panoramaEnableSensorControl => 'Enable sensor control';

  @override
  String get panoramaDisableSensorControl => 'Disable sensor control';

  @override
  String get sourceViewerPageTitle => 'Source';

  @override
  String get filePickerShowHiddenFiles => 'Show hidden files';

  @override
  String get filePickerDoNotShowHiddenFiles => 'Don’t show hidden files';

  @override
  String get filePickerOpenFrom => 'Open from';

  @override
  String get filePickerNoItems => 'No items';

  @override
  String get filePickerUseThisFolder => 'Use this folder';
}
