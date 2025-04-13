// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Aves';

  @override
  String get welcomeMessage => 'Welcome to Aves';

  @override
  String get welcomeOptional => 'Optional';

  @override
  String get welcomeTermsToggle => 'I agree to the terms and conditions';

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
      other: '$countString columns',
      one: '$countString column',
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
      other: '$countString seconds',
      one: '$countString second',
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
      other: '$countString minutes',
      one: '$countString minute',
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
      other: '$countString days',
      one: '$countString day',
    );
    return '$_temp0';
  }

  @override
  String focalLength(String length) {
    return '$length mm';
  }

  @override
  String get applyButtonLabel => 'APPLY';

  @override
  String get deleteButtonLabel => 'DELETE';

  @override
  String get nextButtonLabel => 'NEXT';

  @override
  String get showButtonLabel => 'SHOW';

  @override
  String get hideButtonLabel => 'HIDE';

  @override
  String get continueButtonLabel => 'CONTINUE';

  @override
  String get saveCopyButtonLabel => 'SAVE COPY';

  @override
  String get applyTooltip => 'Apply';

  @override
  String get cancelTooltip => 'Cancel';

  @override
  String get changeTooltip => 'Change';

  @override
  String get clearTooltip => 'Clear';

  @override
  String get previousTooltip => 'Previous';

  @override
  String get nextTooltip => 'Next';

  @override
  String get showTooltip => 'Show';

  @override
  String get hideTooltip => 'Hide';

  @override
  String get actionRemove => 'Remove';

  @override
  String get resetTooltip => 'Reset';

  @override
  String get saveTooltip => 'Save';

  @override
  String get stopTooltip => 'Stop';

  @override
  String get pickTooltip => 'Pick';

  @override
  String get doubleBackExitMessage => 'Tap “back” again to exit.';

  @override
  String get doNotAskAgain => 'Do not ask again';

  @override
  String get sourceStateLoading => 'Loading';

  @override
  String get sourceStateCataloguing => 'Cataloguing';

  @override
  String get sourceStateLocatingCountries => 'Locating countries';

  @override
  String get sourceStateLocatingPlaces => 'Locating places';

  @override
  String get chipActionDelete => 'Delete';

  @override
  String get chipActionRemove => 'Remove';

  @override
  String get chipActionShowCollection => 'Show in Collection';

  @override
  String get chipActionGoToAlbumPage => 'Show in Albums';

  @override
  String get chipActionGoToCountryPage => 'Show in Countries';

  @override
  String get chipActionGoToPlacePage => 'Show in Places';

  @override
  String get chipActionGoToTagPage => 'Show in Tags';

  @override
  String get chipActionGoToExplorerPage => 'Show in Explorer';

  @override
  String get chipActionDecompose => 'Split';

  @override
  String get chipActionFilterOut => 'Filter out';

  @override
  String get chipActionFilterIn => 'Filter in';

  @override
  String get chipActionHide => 'Hide';

  @override
  String get chipActionLock => 'Lock';

  @override
  String get chipActionPin => 'Pin to top';

  @override
  String get chipActionUnpin => 'Unpin from top';

  @override
  String get chipActionRename => 'Rename';

  @override
  String get chipActionSetCover => 'Set cover';

  @override
  String get chipActionShowCountryStates => 'Show states';

  @override
  String get chipActionCreateAlbum => 'Create album';

  @override
  String get chipActionCreateVault => 'Create vault';

  @override
  String get chipActionConfigureVault => 'Configure vault';

  @override
  String get entryActionCopyToClipboard => 'Copy to clipboard';

  @override
  String get entryActionDelete => 'Delete';

  @override
  String get entryActionConvert => 'Convert';

  @override
  String get entryActionExport => 'Export';

  @override
  String get entryActionInfo => 'Info';

  @override
  String get entryActionRename => 'Rename';

  @override
  String get entryActionRestore => 'Restore';

  @override
  String get entryActionRotateCCW => 'Rotate counterclockwise';

  @override
  String get entryActionRotateCW => 'Rotate clockwise';

  @override
  String get entryActionFlip => 'Flip horizontally';

  @override
  String get entryActionPrint => 'Print';

  @override
  String get entryActionShare => 'Share';

  @override
  String get entryActionShareImageOnly => 'Share image only';

  @override
  String get entryActionShareVideoOnly => 'Share video only';

  @override
  String get entryActionViewSource => 'View source';

  @override
  String get entryActionShowGeoTiffOnMap => 'Show as map overlay';

  @override
  String get entryActionConvertMotionPhotoToStillImage => 'Convert to still image';

  @override
  String get entryActionViewMotionPhotoVideo => 'Open video';

  @override
  String get entryActionEdit => 'Edit';

  @override
  String get entryActionOpen => 'Open with';

  @override
  String get entryActionSetAs => 'Set as';

  @override
  String get entryActionCast => 'Cast';

  @override
  String get entryActionOpenMap => 'Show in map app';

  @override
  String get entryActionRotateScreen => 'Rotate screen';

  @override
  String get entryActionAddFavourite => 'Add to favorites';

  @override
  String get entryActionRemoveFavourite => 'Remove from favorites';

  @override
  String get videoActionCaptureFrame => 'Capture frame';

  @override
  String get videoActionMute => 'Mute';

  @override
  String get videoActionUnmute => 'Unmute';

  @override
  String get videoActionPause => 'Pause';

  @override
  String get videoActionPlay => 'Play';

  @override
  String get videoActionReplay10 => 'Seek backward 10 seconds';

  @override
  String get videoActionSkip10 => 'Seek forward 10 seconds';

  @override
  String get videoActionShowPreviousFrame => 'Show previous frame';

  @override
  String get videoActionShowNextFrame => 'Show next frame';

  @override
  String get videoActionSelectStreams => 'Select tracks';

  @override
  String get videoActionSetSpeed => 'Playback speed';

  @override
  String get videoActionABRepeat => 'A-B repeat';

  @override
  String get videoRepeatActionSetStart => 'Set start';

  @override
  String get videoRepeatActionSetEnd => 'Set end';

  @override
  String get viewerActionSettings => 'Settings';

  @override
  String get viewerActionLock => 'Lock viewer';

  @override
  String get viewerActionUnlock => 'Unlock viewer';

  @override
  String get slideshowActionResume => 'Resume';

  @override
  String get slideshowActionShowInCollection => 'Show in Collection';

  @override
  String get entryInfoActionEditDate => 'Edit date & time';

  @override
  String get entryInfoActionEditLocation => 'Edit location';

  @override
  String get entryInfoActionEditTitleDescription => 'Edit title & description';

  @override
  String get entryInfoActionEditRating => 'Edit rating';

  @override
  String get entryInfoActionEditTags => 'Edit tags';

  @override
  String get entryInfoActionRemoveMetadata => 'Remove metadata';

  @override
  String get entryInfoActionExportMetadata => 'Export metadata';

  @override
  String get entryInfoActionRemoveLocation => 'Remove location';

  @override
  String get editorActionTransform => 'Transform';

  @override
  String get editorTransformCrop => 'Crop';

  @override
  String get editorTransformRotate => 'Rotate';

  @override
  String get cropAspectRatioFree => 'Free';

  @override
  String get cropAspectRatioOriginal => 'Original';

  @override
  String get cropAspectRatioSquare => 'Square';

  @override
  String get filterAspectRatioLandscapeLabel => 'Landscape';

  @override
  String get filterAspectRatioPortraitLabel => 'Portrait';

  @override
  String get filterBinLabel => 'Recycle bin';

  @override
  String get filterFavouriteLabel => 'Favorite';

  @override
  String get filterNoDateLabel => 'Undated';

  @override
  String get filterNoAddressLabel => 'No address';

  @override
  String get filterLocatedLabel => 'Located';

  @override
  String get filterNoLocationLabel => 'Unlocated';

  @override
  String get filterNoRatingLabel => 'Unrated';

  @override
  String get filterTaggedLabel => 'Tagged';

  @override
  String get filterNoTagLabel => 'Untagged';

  @override
  String get filterNoTitleLabel => 'Untitled';

  @override
  String get filterOnThisDayLabel => 'On this day';

  @override
  String get filterRecentlyAddedLabel => 'Recently added';

  @override
  String get filterRatingRejectedLabel => 'Rejected';

  @override
  String get filterTypeAnimatedLabel => 'Animated';

  @override
  String get filterTypeMotionPhotoLabel => 'Motion Photo';

  @override
  String get filterTypePanoramaLabel => 'Panorama';

  @override
  String get filterTypeRawLabel => 'Raw';

  @override
  String get filterTypeSphericalVideoLabel => '360° Video';

  @override
  String get filterTypeGeotiffLabel => 'GeoTIFF';

  @override
  String get filterMimeImageLabel => 'Image';

  @override
  String get filterMimeVideoLabel => 'Video';

  @override
  String get accessibilityAnimationsRemove => 'Prevent screen effects';

  @override
  String get accessibilityAnimationsKeep => 'Keep screen effects';

  @override
  String get albumTierNew => 'New';

  @override
  String get albumTierPinned => 'Pinned';

  @override
  String get albumTierSpecial => 'Common';

  @override
  String get albumTierApps => 'Apps';

  @override
  String get albumTierVaults => 'Vaults';

  @override
  String get albumTierDynamic => 'Dynamic';

  @override
  String get albumTierRegular => 'Others';

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
  String get coordinateDmsNorth => 'N';

  @override
  String get coordinateDmsSouth => 'S';

  @override
  String get coordinateDmsEast => 'E';

  @override
  String get coordinateDmsWest => 'W';

  @override
  String get displayRefreshRatePreferHighest => 'Highest rate';

  @override
  String get displayRefreshRatePreferLowest => 'Lowest rate';

  @override
  String get keepScreenOnNever => 'Never';

  @override
  String get keepScreenOnVideoPlayback => 'During video playback';

  @override
  String get keepScreenOnViewerOnly => 'Viewer page only';

  @override
  String get keepScreenOnAlways => 'Always';

  @override
  String get lengthUnitPixel => 'px';

  @override
  String get lengthUnitPercent => '%';

  @override
  String get mapStyleGoogleNormal => 'Google Maps';

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
  String get maxBrightnessNever => 'Never';

  @override
  String get maxBrightnessAlways => 'Always';

  @override
  String get nameConflictStrategyRename => 'Rename';

  @override
  String get nameConflictStrategyReplace => 'Replace';

  @override
  String get nameConflictStrategySkip => 'Skip';

  @override
  String get overlayHistogramNone => 'None';

  @override
  String get overlayHistogramRGB => 'RGB';

  @override
  String get overlayHistogramLuminance => 'Luminance';

  @override
  String get subtitlePositionTop => 'Top';

  @override
  String get subtitlePositionBottom => 'Bottom';

  @override
  String get themeBrightnessLight => 'Light';

  @override
  String get themeBrightnessDark => 'Dark';

  @override
  String get themeBrightnessBlack => 'Black';

  @override
  String get unitSystemMetric => 'Metric';

  @override
  String get unitSystemImperial => 'Imperial';

  @override
  String get vaultLockTypePattern => 'Pattern';

  @override
  String get vaultLockTypePin => 'PIN';

  @override
  String get vaultLockTypePassword => 'Password';

  @override
  String get settingsVideoEnablePip => 'Picture-in-picture';

  @override
  String get videoControlsPlayOutside => 'Open with other player';

  @override
  String get videoLoopModeNever => 'Never';

  @override
  String get videoLoopModeShortOnly => 'Short videos only';

  @override
  String get videoLoopModeAlways => 'Always';

  @override
  String get videoPlaybackSkip => 'Skip';

  @override
  String get videoPlaybackMuted => 'Play muted';

  @override
  String get videoPlaybackWithSound => 'Play with sound';

  @override
  String get videoResumptionModeNever => 'Never';

  @override
  String get videoResumptionModeAlways => 'Always';

  @override
  String get viewerTransitionSlide => 'Slide';

  @override
  String get viewerTransitionParallax => 'Parallax';

  @override
  String get viewerTransitionFade => 'Fade';

  @override
  String get viewerTransitionZoomIn => 'Zoom in';

  @override
  String get viewerTransitionNone => 'None';

  @override
  String get wallpaperTargetHome => 'Home screen';

  @override
  String get wallpaperTargetLock => 'Lock screen';

  @override
  String get wallpaperTargetHomeLock => 'Home and lock screens';

  @override
  String get widgetDisplayedItemRandom => 'Random';

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
  String get storageVolumeDescriptionFallbackPrimary => 'Internal storage';

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
  String get nameConflictDialogMultipleSourceMessage => 'Some files have the same name.';

  @override
  String get addShortcutDialogLabel => 'Shortcut label';

  @override
  String get addShortcutButtonLabel => 'ADD';

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

/// The translations for English, using the Shavian Shaw script (`en_Shaw`).
class AppLocalizationsEnShaw extends AppLocalizationsEn {
  AppLocalizationsEnShaw(): super('en_Shaw');

  @override
  String get appName => '𐑱𐑝𐑰𐑟';

  @override
  String get welcomeMessage => '𐑢𐑧𐑤𐑒𐑩𐑥 𐑑 ·𐑱𐑝𐑰𐑟';

  @override
  String get welcomeOptional => '𐑪𐑐𐑖𐑩𐑯𐑩𐑤';

  @override
  String get welcomeTermsToggle => '𐑲 𐑩𐑜𐑮𐑰 𐑑 𐑞 𐑑𐑻𐑥𐑟 𐑯 𐑒𐑩𐑯𐑛𐑦𐑖𐑩𐑯𐑟';

  @override
  String itemCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString 𐑲𐑑𐑩𐑥𐑟',
      one: '$countString 𐑲𐑑𐑩𐑥',
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
      other: '$countString 𐑒𐑪𐑤𐑩𐑥𐑟',
      one: '$countString 𐑒𐑪𐑤𐑩𐑥',
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
      other: '$countString 𐑕𐑧𐑒𐑩𐑯𐑛𐑟',
      one: '$countString 𐑕𐑧𐑒𐑩𐑯𐑛',
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
      other: '$countString 𐑥𐑦𐑯𐑦𐑑𐑕',
      one: '$countString 𐑥𐑦𐑯𐑦𐑑',
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
      other: '$countString 𐑛𐑱𐑟',
      one: '$countString 𐑛𐑱',
    );
    return '$_temp0';
  }

  @override
  String focalLength(String length) {
    return '$length 𐑥𐑥';
  }

  @override
  String get applyButtonLabel => '𐑩𐑐𐑤𐑲';

  @override
  String get deleteButtonLabel => '𐑛𐑦𐑤𐑰𐑑';

  @override
  String get nextButtonLabel => '𐑯𐑧𐑒𐑕𐑑';

  @override
  String get showButtonLabel => '𐑖𐑴';

  @override
  String get hideButtonLabel => '𐑣𐑲𐑛';

  @override
  String get continueButtonLabel => '𐑒𐑩𐑯𐑑𐑦𐑯𐑿';

  @override
  String get saveCopyButtonLabel => '𐑕𐑱𐑝 𐑒𐑪𐑐𐑦';

  @override
  String get applyTooltip => '𐑩𐑐𐑤𐑲';

  @override
  String get cancelTooltip => '𐑒𐑨𐑯𐑕𐑩𐑤';

  @override
  String get changeTooltip => '𐑗𐑱𐑯𐑡';

  @override
  String get clearTooltip => '𐑒𐑤𐑽';

  @override
  String get previousTooltip => '𐑐𐑮𐑰𐑝𐑾𐑕';

  @override
  String get nextTooltip => '𐑯𐑧𐑒𐑕𐑑';

  @override
  String get showTooltip => '𐑖𐑴';

  @override
  String get hideTooltip => '𐑣𐑲𐑛';

  @override
  String get actionRemove => '𐑮𐑦𐑥𐑵𐑝';

  @override
  String get resetTooltip => '𐑮𐑰𐑕𐑧𐑑';

  @override
  String get saveTooltip => '𐑕𐑱𐑝';

  @override
  String get stopTooltip => '𐑕𐑑𐑪𐑐';

  @override
  String get pickTooltip => '𐑐𐑦𐑒';

  @override
  String get doubleBackExitMessage => '𐑑𐑨𐑐 «𐑚𐑨𐑒» 𐑩𐑜𐑧𐑯 𐑑 𐑧𐑒𐑕𐑦𐑑.';

  @override
  String get doNotAskAgain => '𐑛𐑵 𐑯𐑪𐑑 𐑭𐑕𐑒 𐑩𐑜𐑧𐑯';

  @override
  String get sourceStateLoading => '𐑤𐑴𐑛𐑦𐑙';

  @override
  String get sourceStateCataloguing => '𐑒𐑨𐑑𐑩𐑤𐑪𐑜𐑦𐑙';

  @override
  String get sourceStateLocatingCountries => '𐑤𐑴𐑒𐑱𐑑𐑦𐑙 𐑒𐑳𐑯𐑑𐑮𐑦𐑟';

  @override
  String get sourceStateLocatingPlaces => '𐑤𐑴𐑒𐑱𐑑𐑦𐑙 𐑐𐑤𐑱𐑕𐑩𐑟';

  @override
  String get chipActionDelete => '𐑛𐑦𐑤𐑰𐑑';

  @override
  String get chipActionShowCollection => '𐑖𐑴 𐑦𐑯 ·𐑒𐑩𐑤𐑧𐑒𐑖𐑩𐑯';

  @override
  String get chipActionGoToAlbumPage => '𐑖𐑴 𐑦𐑯 ·𐑨𐑤𐑚𐑩𐑥𐑟';

  @override
  String get chipActionGoToCountryPage => '𐑖𐑴 𐑦𐑯 ·𐑒𐑳𐑯𐑑𐑮𐑦𐑟';

  @override
  String get chipActionGoToPlacePage => '𐑖𐑴 𐑦𐑯 ·𐑐𐑤𐑱𐑕𐑩𐑟';

  @override
  String get chipActionGoToTagPage => '𐑖𐑴 𐑦𐑯 ·𐑑𐑨𐑜𐑟';

  @override
  String get chipActionGoToExplorerPage => '𐑖𐑴 𐑦𐑯 ·𐑦𐑒𐑕𐑐𐑤𐑹𐑼';

  @override
  String get chipActionFilterOut => '𐑓𐑦𐑤𐑑𐑼 𐑬𐑑';

  @override
  String get chipActionFilterIn => '𐑓𐑦𐑤𐑑𐑼 𐑦𐑯';

  @override
  String get chipActionHide => '𐑣𐑲𐑛';

  @override
  String get chipActionLock => '𐑤𐑪𐑒';

  @override
  String get chipActionPin => '𐑐𐑦𐑯 𐑑 𐑑𐑪𐑐';

  @override
  String get chipActionUnpin => '𐑳𐑯𐑐𐑦𐑯 𐑑 𐑑𐑪𐑐';

  @override
  String get chipActionRename => '𐑮𐑰𐑯𐑱𐑥';

  @override
  String get chipActionSetCover => '𐑕𐑧𐑑 𐑒𐑳𐑝𐑼';

  @override
  String get chipActionShowCountryStates => '𐑖𐑴 𐑕𐑑𐑱𐑑𐑕';

  @override
  String get chipActionCreateAlbum => '𐑒𐑮𐑦𐑱𐑑 𐑨𐑤𐑚𐑩𐑥';

  @override
  String get chipActionCreateVault => '𐑒𐑮𐑦𐑱𐑑 𐑝𐑷𐑤𐑑';

  @override
  String get chipActionConfigureVault => '𐑒𐑩𐑯𐑓𐑦𐑜𐑼 𐑝𐑷𐑤𐑑';

  @override
  String get entryActionCopyToClipboard => '𐑒𐑪𐑐𐑦 𐑑 𐑒𐑤𐑦𐑐𐑚𐑹𐑛';

  @override
  String get entryActionDelete => '𐑛𐑦𐑤𐑰𐑑';

  @override
  String get entryActionConvert => '𐑒𐑪𐑯𐑝𐑻𐑑';

  @override
  String get entryActionExport => '𐑦𐑒𐑕𐑐𐑹𐑑';

  @override
  String get entryActionInfo => '𐑦𐑯𐑓𐑴';

  @override
  String get entryActionRename => '𐑮𐑰𐑯𐑱𐑥';

  @override
  String get entryActionRestore => '𐑮𐑦𐑕𐑑𐑹';

  @override
  String get entryActionRotateCCW => '𐑮𐑴𐑑𐑱𐑑 𐑒𐑬𐑯𐑑𐑼𐑒𐑤𐑪𐑒𐑢𐑲𐑟';

  @override
  String get entryActionRotateCW => '𐑮𐑴𐑑𐑱𐑑 𐑒𐑤𐑪𐑒𐑢𐑲𐑟';

  @override
  String get entryActionFlip => '𐑓𐑤𐑦𐑐 𐑣𐑪𐑮𐑦𐑟𐑪𐑯𐑑𐑩𐑤𐑦';

  @override
  String get entryActionPrint => '𐑐𐑮𐑦𐑯𐑑';

  @override
  String get entryActionShare => '𐑖𐑺';

  @override
  String get entryActionShareImageOnly => '𐑖𐑺 𐑦𐑥𐑦𐑡 𐑴𐑯𐑤𐑦';

  @override
  String get entryActionShareVideoOnly => '𐑖𐑺 𐑝𐑦𐑛𐑦𐑴 𐑴𐑯𐑤𐑦';

  @override
  String get entryActionViewSource => '𐑝𐑿 𐑕𐑹𐑕';

  @override
  String get entryActionShowGeoTiffOnMap => '𐑖𐑴 𐑨𐑟 𐑥𐑨𐑐 𐑴𐑝𐑼𐑤𐑱';

  @override
  String get entryActionConvertMotionPhotoToStillImage => '𐑒𐑪𐑯𐑝𐑻𐑑 𐑑 𐑕𐑑𐑦𐑤 𐑦𐑥𐑦𐑡';

  @override
  String get entryActionViewMotionPhotoVideo => '𐑴𐑐𐑩𐑯 𐑝𐑦𐑛𐑦𐑴';

  @override
  String get entryActionEdit => '𐑧𐑛𐑦𐑑';

  @override
  String get entryActionOpen => '𐑴𐑐𐑩𐑯 𐑢𐑦𐑞';

  @override
  String get entryActionSetAs => '𐑕𐑧𐑑 𐑨𐑟';

  @override
  String get entryActionCast => '𐑒𐑭𐑕𐑑';

  @override
  String get entryActionOpenMap => '𐑖𐑴 𐑦𐑯 𐑥𐑨𐑐 𐑨𐑐';

  @override
  String get entryActionRotateScreen => '𐑮𐑴𐑑𐑱𐑑 𐑕𐑒𐑮𐑰𐑯';

  @override
  String get entryActionAddFavourite => '𐑨𐑛 𐑑 𐑓𐑱𐑝𐑼𐑦𐑑𐑕';

  @override
  String get entryActionRemoveFavourite => '𐑮𐑦𐑥𐑵𐑝 𐑓𐑮𐑪𐑥 𐑓𐑱𐑝𐑼𐑦𐑑𐑕';

  @override
  String get videoActionCaptureFrame => '𐑒𐑨𐑐𐑗𐑼 𐑓𐑮𐑱𐑥';

  @override
  String get videoActionMute => '𐑥𐑿𐑑';

  @override
  String get videoActionUnmute => '𐑳𐑯𐑥𐑿𐑑';

  @override
  String get videoActionPause => '𐑐𐑷𐑟';

  @override
  String get videoActionPlay => '𐑐𐑤𐑱';

  @override
  String get videoActionReplay10 => '𐑕𐑰𐑒 𐑚𐑨𐑒𐑢𐑼𐑛 10 𐑕𐑧𐑒𐑩𐑯𐑛𐑟';

  @override
  String get videoActionSkip10 => '𐑕𐑰𐑒 𐑓𐑹𐑢𐑼𐑛 10 𐑕𐑧𐑒𐑩𐑯𐑛𐑟';

  @override
  String get videoActionShowPreviousFrame => '𐑖𐑴 𐑐𐑮𐑰𐑝𐑾𐑕 𐑓𐑮𐑱𐑥';

  @override
  String get videoActionShowNextFrame => '𐑖𐑴 𐑯𐑧𐑒𐑕𐑑 𐑓𐑮𐑱𐑥';

  @override
  String get videoActionSelectStreams => '𐑕𐑦𐑤𐑧𐑒𐑑 𐑑𐑮𐑨𐑒𐑕';

  @override
  String get videoActionSetSpeed => '𐑐𐑤𐑱𐑚𐑨𐑒 𐑕𐑐𐑰𐑛';

  @override
  String get videoActionABRepeat => '𐑐–𐑚 𐑮𐑦𐑐𐑰𐑑';

  @override
  String get videoRepeatActionSetStart => '𐑕𐑧𐑑 𐑕𐑑𐑸𐑑';

  @override
  String get videoRepeatActionSetEnd => '𐑕𐑧𐑑 𐑧𐑯𐑛';

  @override
  String get viewerActionSettings => '𐑕𐑧𐑑𐑦𐑙𐑟';

  @override
  String get viewerActionLock => '𐑤𐑪𐑒 𐑝𐑿𐑼';

  @override
  String get viewerActionUnlock => '𐑳𐑯𐑤𐑪𐑒 𐑝𐑿𐑼';

  @override
  String get slideshowActionResume => '𐑮𐑦𐑟𐑿𐑥';

  @override
  String get slideshowActionShowInCollection => '𐑖𐑴 𐑦𐑯 ·𐑒𐑩𐑤𐑧𐑒𐑖𐑩𐑯';

  @override
  String get entryInfoActionEditDate => '𐑧𐑛𐑦𐑑 𐑛𐑱𐑑 𐑯 𐑑𐑲𐑥';

  @override
  String get entryInfoActionEditLocation => '𐑧𐑛𐑦𐑑 𐑤𐑴𐑒𐑱𐑖𐑩𐑯';

  @override
  String get entryInfoActionEditTitleDescription => '𐑧𐑛𐑦𐑑 𐑑𐑲𐑑𐑩𐑤 𐑯 𐑛𐑦𐑕𐑒𐑮𐑦𐑐𐑖𐑩𐑯';

  @override
  String get entryInfoActionEditRating => '𐑧𐑛𐑦𐑑 𐑮𐑱𐑑𐑦𐑙';

  @override
  String get entryInfoActionEditTags => '𐑧𐑛𐑦𐑑 𐑑𐑨𐑜𐑟';

  @override
  String get entryInfoActionRemoveMetadata => '𐑮𐑦𐑥𐑵𐑝 𐑥𐑧𐑑𐑩𐑛𐑱𐑑𐑩';

  @override
  String get entryInfoActionExportMetadata => '𐑦𐑒𐑕𐑐𐑹𐑑 𐑥𐑧𐑑𐑩𐑛𐑱𐑑𐑩';

  @override
  String get entryInfoActionRemoveLocation => '𐑮𐑦𐑥𐑵𐑝 𐑤𐑴𐑒𐑱𐑖𐑩𐑯';

  @override
  String get editorActionTransform => '𐑑𐑮𐑨𐑯𐑕𐑓𐑹𐑥';

  @override
  String get editorTransformCrop => '𐑒𐑮𐑪𐑐';

  @override
  String get editorTransformRotate => '𐑮𐑴𐑑𐑱𐑑';

  @override
  String get cropAspectRatioFree => '𐑓𐑮𐑰';

  @override
  String get cropAspectRatioOriginal => '𐑼𐑦𐑡𐑦𐑯𐑩𐑤';

  @override
  String get cropAspectRatioSquare => '𐑕𐑒𐑢𐑺';

  @override
  String get filterAspectRatioLandscapeLabel => '𐑤𐑨𐑯𐑛𐑕𐑒𐑱𐑐';

  @override
  String get filterAspectRatioPortraitLabel => '𐑐𐑹𐑑𐑮𐑦𐑑';

  @override
  String get filterBinLabel => '𐑮𐑰𐑕𐑲𐑒𐑩𐑤 𐑚𐑦𐑯';

  @override
  String get filterFavouriteLabel => '𐑓𐑱𐑝𐑼𐑦𐑑';

  @override
  String get filterNoDateLabel => '𐑳𐑯𐑛𐑱𐑑𐑩𐑛';

  @override
  String get filterNoAddressLabel => '𐑯𐑴 𐑩𐑛𐑮𐑧𐑕';

  @override
  String get filterLocatedLabel => '𐑤𐑴𐑒𐑱𐑑𐑩𐑛';

  @override
  String get filterNoLocationLabel => '𐑳𐑯𐑤𐑴𐑒𐑱𐑑𐑩𐑛';

  @override
  String get filterNoRatingLabel => '𐑳𐑯𐑮𐑱𐑑𐑩𐑛';

  @override
  String get filterTaggedLabel => '𐑑𐑨𐑜𐑛';

  @override
  String get filterNoTagLabel => '𐑳𐑯𐑑𐑨𐑜𐑛';

  @override
  String get filterNoTitleLabel => '𐑳𐑯𐑑𐑲𐑑𐑩𐑤𐑛';

  @override
  String get filterOnThisDayLabel => '𐑪𐑯 𐑞𐑦𐑕 𐑛𐑱';

  @override
  String get filterRecentlyAddedLabel => '𐑮𐑰𐑕𐑩𐑯𐑑𐑤𐑦 𐑨𐑛𐑩𐑛';

  @override
  String get filterRatingRejectedLabel => '𐑮𐑦𐑡𐑧𐑒𐑑𐑩𐑛';

  @override
  String get filterTypeAnimatedLabel => '𐑨𐑯𐑦𐑥𐑱𐑑𐑩𐑛';

  @override
  String get filterTypeMotionPhotoLabel => '𐑥𐑴𐑖𐑩𐑯 𐑓𐑴𐑑𐑴';

  @override
  String get filterTypePanoramaLabel => '𐑐𐑨𐑯𐑼𐑭𐑥𐑩';

  @override
  String get filterTypeRawLabel => '𐑮𐑷';

  @override
  String get filterTypeSphericalVideoLabel => '360° 𐑝𐑦𐑛𐑦𐑴';

  @override
  String get filterTypeGeotiffLabel => '⸰𐑡𐑰𐑴𐑑𐑦𐑓𐑓';

  @override
  String get filterMimeImageLabel => '𐑦𐑥𐑦𐑡';

  @override
  String get filterMimeVideoLabel => '𐑝𐑦𐑛𐑦𐑴';

  @override
  String get accessibilityAnimationsRemove => '𐑐𐑮𐑦𐑝𐑧𐑯𐑑 𐑕𐑒𐑮𐑰𐑯 𐑦𐑓𐑧𐑒𐑑𐑕';

  @override
  String get accessibilityAnimationsKeep => '𐑒𐑰𐑐 𐑕𐑒𐑮𐑰𐑯 𐑦𐑓𐑧𐑒𐑑𐑕';

  @override
  String get albumTierNew => '𐑯𐑿';

  @override
  String get albumTierPinned => '𐑐𐑦𐑯𐑛';

  @override
  String get albumTierSpecial => '𐑒𐑪𐑥𐑩𐑯';

  @override
  String get albumTierApps => '𐑨𐑐𐑕';

  @override
  String get albumTierVaults => '𐑝𐑷𐑤𐑑𐑕';

  @override
  String get albumTierRegular => '𐑳𐑞𐑼𐑟';

  @override
  String get coordinateFormatDms => '⸰𐑛𐑥𐑕';

  @override
  String get coordinateFormatDecimal => '𐑛𐑧𐑕𐑦𐑥𐑩𐑤 𐑛𐑦𐑜𐑮𐑰𐑟';

  @override
  String coordinateDms(String coordinate, String direction) {
    return '$coordinate $direction';
  }

  @override
  String get coordinateDmsNorth => '𐑯';

  @override
  String get coordinateDmsSouth => '𐑕';

  @override
  String get coordinateDmsEast => '𐑰';

  @override
  String get coordinateDmsWest => '𐑢';

  @override
  String get displayRefreshRatePreferHighest => '𐑣𐑲𐑩𐑕𐑑 𐑮𐑱𐑑';

  @override
  String get displayRefreshRatePreferLowest => '𐑤𐑴𐑩𐑕𐑑 𐑮𐑱𐑑';

  @override
  String get keepScreenOnNever => '𐑯𐑧𐑝𐑼';

  @override
  String get keepScreenOnVideoPlayback => '𐑛𐑘𐑫𐑼𐑦𐑙 𐑝𐑦𐑛𐑦𐑴 𐑐𐑤𐑱𐑚𐑨𐑒';

  @override
  String get keepScreenOnViewerOnly => '𐑝𐑿𐑼 𐑐𐑱𐑡 𐑴𐑯𐑤𐑦';

  @override
  String get keepScreenOnAlways => '𐑷𐑤𐑢𐑱𐑟';

  @override
  String get lengthUnitPixel => '𐑐𐑒𐑕';

  @override
  String get lengthUnitPercent => '%';

  @override
  String get mapStyleGoogleNormal => '·𐑜𐑵𐑜𐑩𐑤 𐑥𐑨𐑐𐑕';

  @override
  String get mapStyleGoogleHybrid => '·𐑜𐑵𐑜𐑩𐑤 𐑥𐑨𐑐𐑕 (𐑣𐑲𐑚𐑮𐑦𐑛)';

  @override
  String get mapStyleGoogleTerrain => '·𐑜𐑵𐑜𐑩𐑤 𐑥𐑨𐑐𐑕 (𐑑𐑼𐑱𐑯)';

  @override
  String get mapStyleOsmLiberty => '⸰𐑴𐑕𐑥 ·𐑤𐑦𐑚𐑼𐑑𐑦';

  @override
  String get mapStyleOpenTopoMap => '·𐑴𐑐𐑩𐑯𐑑𐑪𐑐𐑩𐑥𐑨𐑐';

  @override
  String get mapStyleOsmHot => '·𐑣𐑿𐑥𐑨𐑯𐑦𐑑𐑺𐑾𐑯 ⸰𐑴𐑕𐑥';

  @override
  String get mapStyleStamenWatercolor => '·𐑕𐑑𐑱𐑥𐑩𐑯 𐑢𐑷𐑑𐑼𐑒𐑳𐑤𐑼';

  @override
  String get maxBrightnessNever => '𐑯𐑧𐑝𐑼';

  @override
  String get maxBrightnessAlways => '𐑷𐑤𐑢𐑱𐑟';

  @override
  String get nameConflictStrategyRename => '𐑮𐑰𐑯𐑱𐑥';

  @override
  String get nameConflictStrategyReplace => '𐑮𐑦𐑐𐑤𐑱𐑕';

  @override
  String get nameConflictStrategySkip => '𐑕𐑒𐑦𐑐';

  @override
  String get overlayHistogramNone => '𐑯𐑳𐑯';

  @override
  String get overlayHistogramRGB => '⸰𐑮𐑜𐑚';

  @override
  String get overlayHistogramLuminance => '𐑤𐑵𐑥𐑦𐑯𐑩𐑯𐑕';

  @override
  String get subtitlePositionTop => '𐑑𐑪𐑐';

  @override
  String get subtitlePositionBottom => '𐑚𐑪𐑑𐑩𐑥';

  @override
  String get themeBrightnessLight => '𐑤𐑲𐑑';

  @override
  String get themeBrightnessDark => '𐑛𐑸𐑒';

  @override
  String get themeBrightnessBlack => '𐑚𐑤𐑨𐑒';

  @override
  String get unitSystemMetric => '𐑥𐑧𐑑𐑮𐑦𐑒';

  @override
  String get unitSystemImperial => '𐑦𐑥𐑐𐑽𐑾𐑤';

  @override
  String get vaultLockTypePattern => '𐑐𐑨𐑑𐑼𐑯';

  @override
  String get vaultLockTypePin => '⸰𐑐𐑲𐑯';

  @override
  String get vaultLockTypePassword => '𐑐𐑭𐑕𐑢𐑻𐑛';

  @override
  String get settingsVideoEnablePip => '𐑐𐑦𐑒𐑗𐑼-𐑦𐑯-𐑐𐑦𐑒𐑗𐑼';

  @override
  String get videoControlsPlayOutside => '𐑴𐑐𐑩𐑯 𐑢𐑦𐑞 𐑳𐑞𐑼 𐑐𐑤𐑱𐑼';

  @override
  String get videoLoopModeNever => '𐑯𐑧𐑝𐑼';

  @override
  String get videoLoopModeShortOnly => '𐑖𐑹𐑑 𐑝𐑦𐑛𐑦𐑴𐑟 𐑴𐑯𐑤𐑦';

  @override
  String get videoLoopModeAlways => '𐑷𐑤𐑢𐑱𐑟';

  @override
  String get videoPlaybackSkip => '𐑕𐑒𐑦𐑐';

  @override
  String get videoPlaybackMuted => '𐑐𐑤𐑱 𐑥𐑿𐑑𐑩𐑛';

  @override
  String get videoPlaybackWithSound => '𐑐𐑤𐑱 𐑢𐑦𐑞 𐑕𐑬𐑯𐑛';

  @override
  String get videoResumptionModeNever => '𐑯𐑧𐑝𐑼';

  @override
  String get videoResumptionModeAlways => '𐑷𐑤𐑢𐑱𐑟';

  @override
  String get viewerTransitionSlide => '𐑕𐑤𐑲𐑛';

  @override
  String get viewerTransitionParallax => '𐑐𐑨𐑮𐑩𐑤𐑨𐑒𐑕';

  @override
  String get viewerTransitionFade => '𐑓𐑱𐑛';

  @override
  String get viewerTransitionZoomIn => '𐑟𐑵𐑥 𐑦𐑯';

  @override
  String get viewerTransitionNone => '𐑯𐑳𐑯';

  @override
  String get wallpaperTargetHome => '𐑣𐑴𐑥 𐑕𐑒𐑮𐑰𐑯';

  @override
  String get wallpaperTargetLock => '𐑤𐑪𐑒 𐑕𐑒𐑮𐑰𐑯';

  @override
  String get wallpaperTargetHomeLock => '𐑣𐑴𐑥 𐑯 𐑤𐑪𐑒 𐑕𐑒𐑮𐑰𐑯𐑟';

  @override
  String get widgetDisplayedItemRandom => '𐑮𐑨𐑯𐑛𐑩𐑥';

  @override
  String get widgetDisplayedItemMostRecent => '𐑥𐑴𐑕𐑑 𐑮𐑰𐑕𐑩𐑯𐑑';

  @override
  String get widgetOpenPageHome => '𐑴𐑐𐑩𐑯 𐑣𐑴𐑥';

  @override
  String get widgetOpenPageCollection => '𐑴𐑐𐑩𐑯 𐑒𐑩𐑤𐑧𐑒𐑖𐑩𐑯';

  @override
  String get widgetOpenPageViewer => '𐑴𐑐𐑩𐑯 𐑝𐑿𐑼';

  @override
  String get widgetTapUpdateWidget => '𐑳𐑐𐑛𐑱𐑑 𐑢𐑦𐑡𐑩𐑑';

  @override
  String get storageVolumeDescriptionFallbackPrimary => '𐑦𐑯𐑑𐑻𐑯𐑩𐑤 𐑕𐑑𐑹𐑦𐑡';

  @override
  String get storageVolumeDescriptionFallbackNonPrimary => '⸰𐑕𐑛 𐑒𐑸𐑛';

  @override
  String get rootDirectoryDescription => '𐑮𐑵𐑑 𐑛𐑦𐑮𐑧𐑒𐑑𐑼𐑦';

  @override
  String otherDirectoryDescription(String name) {
    return '«$name» 𐑛𐑦𐑮𐑧𐑒𐑑𐑼𐑦';
  }

  @override
  String storageAccessDialogMessage(String directory, String volume) {
    return '𐑐𐑤𐑰𐑟 𐑕𐑦𐑤𐑧𐑒𐑑 𐑞 $directory 𐑝 «$volume» 𐑦𐑯 𐑞 𐑯𐑧𐑒𐑕𐑑 𐑕𐑒𐑮𐑰𐑯 𐑑 𐑜𐑦𐑝 𐑞𐑦𐑕 𐑨𐑐 𐑨𐑒𐑕𐑧𐑕 𐑑 𐑦𐑑.';
  }

  @override
  String restrictedAccessDialogMessage(String directory, String volume) {
    return '𐑞𐑦𐑕 𐑨𐑐 𐑦𐑟 𐑯𐑪𐑑 𐑩𐑤𐑬𐑛 𐑑 𐑥𐑪𐑛𐑦𐑓𐑲 𐑓𐑲𐑤𐑟 𐑦𐑯 𐑞 $directory 𐑝 «$volume».\n\n𐑐𐑤𐑰𐑟 𐑿𐑟 𐑩 𐑐𐑮𐑰-𐑦𐑯𐑕𐑑𐑷𐑤𐑛 𐑓𐑲𐑤 𐑥𐑨𐑯𐑦𐑡𐑼 𐑹 𐑜𐑨𐑤𐑼𐑦 𐑨𐑐 𐑑 𐑥𐑵𐑝 𐑞 𐑲𐑑𐑩𐑥𐑟 𐑑 𐑩𐑯𐑳𐑞𐑼 𐑛𐑦𐑮𐑧𐑒𐑑𐑼𐑦.';
  }

  @override
  String notEnoughSpaceDialogMessage(String neededSize, String freeSize, String volume) {
    return '𐑞𐑦𐑕 𐑪𐑐𐑼𐑱𐑖𐑩𐑯 𐑯𐑰𐑛𐑟 $neededSize 𐑝 𐑓𐑮𐑰 𐑕𐑐𐑱𐑕 𐑪𐑯 «$volume» 𐑑 𐑒𐑩𐑥𐑐𐑤𐑰𐑑, 𐑚𐑳𐑑 𐑞𐑺 𐑦𐑟 𐑴𐑯𐑤𐑦 $freeSize 𐑤𐑧𐑓𐑑.';
  }

  @override
  String get missingSystemFilePickerDialogMessage => '𐑞 𐑕𐑦𐑕𐑑𐑩𐑥 𐑓𐑲𐑤 𐑐𐑦𐑒𐑼 𐑦𐑟 𐑥𐑦𐑕𐑦𐑙 𐑹 𐑛𐑦𐑕𐑱𐑚𐑩𐑤𐑛. 𐑐𐑤𐑰𐑟 𐑦𐑯𐑱𐑚𐑩𐑤 𐑦𐑑 𐑯 𐑑𐑮𐑲 𐑩𐑜𐑧𐑯.';

  @override
  String unsupportedTypeDialogMessage(int count, String types) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '𐑞𐑦𐑕 𐑪𐑐𐑼𐑱𐑖𐑩𐑯 𐑦𐑟 𐑯𐑪𐑑 𐑕𐑩𐑐𐑹𐑑𐑩𐑛 𐑓 𐑲𐑑𐑩𐑥𐑟 𐑝 𐑞 𐑓𐑪𐑤𐑴𐑦𐑙 𐑑𐑲𐑐𐑕: $types.',
      one: '𐑞𐑦𐑕 𐑪𐑐𐑼𐑱𐑖𐑩𐑯 𐑦𐑟 𐑯𐑪𐑑 𐑕𐑩𐑐𐑹𐑑𐑩𐑛 𐑓 𐑲𐑑𐑩𐑥𐑟 𐑝 𐑞 𐑓𐑪𐑤𐑴𐑦𐑙 𐑑𐑲𐑐: $types.',
    );
    return '$_temp0';
  }

  @override
  String get nameConflictDialogSingleSourceMessage => '𐑕𐑳𐑥 𐑓𐑲𐑤𐑟 𐑦𐑯 𐑞 𐑛𐑧𐑕𐑑𐑦𐑯𐑱𐑖𐑩𐑯 𐑓𐑴𐑤𐑛𐑼 𐑣𐑨𐑝 𐑞 𐑕𐑱𐑥 𐑯𐑱𐑥.';

  @override
  String get nameConflictDialogMultipleSourceMessage => '𐑕𐑳𐑥 𐑓𐑲𐑤𐑟 𐑣𐑨𐑝 𐑞 𐑕𐑱𐑥 𐑯𐑱𐑥.';

  @override
  String get addShortcutDialogLabel => '𐑖𐑹𐑑𐑒𐑳𐑑 𐑤𐑱𐑚𐑩𐑤';

  @override
  String get addShortcutButtonLabel => '𐑨𐑛';

  @override
  String get noMatchingAppDialogMessage => '𐑞𐑺 𐑸 𐑯𐑴 𐑨𐑐𐑕 𐑞𐑨𐑑 𐑒𐑨𐑯 𐑣𐑨𐑯𐑛𐑩𐑤 𐑞𐑦𐑕.';

  @override
  String binEntriesConfirmationDialogMessage(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '¿𐑥𐑵𐑝 𐑞𐑰𐑟 $countString 𐑲𐑑𐑩𐑥𐑟 𐑑 𐑞 𐑮𐑰𐑕𐑲𐑒𐑩𐑤 𐑚𐑦𐑯?',
      one: '¿𐑥𐑵𐑝 𐑞𐑦𐑕 𐑲𐑑𐑩𐑥 𐑑 𐑞 𐑮𐑰𐑕𐑲𐑒𐑩𐑤 𐑚𐑦𐑯?',
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
      other: '¿𐑛𐑦𐑤𐑰𐑑 𐑞𐑰𐑟 $countString 𐑲𐑑𐑩𐑥𐑟?',
      one: '¿𐑛𐑦𐑤𐑰𐑑 𐑞𐑦𐑕 𐑲𐑑𐑩𐑥?',
    );
    return '$_temp0';
  }

  @override
  String get moveUndatedConfirmationDialogMessage => '¿𐑕𐑱𐑝 𐑲𐑑𐑩𐑥 𐑛𐑱𐑑𐑕 𐑚𐑦𐑓𐑹 𐑐𐑮𐑩𐑕𐑰𐑛𐑦𐑙?';

  @override
  String get moveUndatedConfirmationDialogSetDate => '𐑕𐑱𐑝 𐑛𐑱𐑑𐑕';

  @override
  String videoResumeDialogMessage(String time) {
    return '¿𐑛𐑵 𐑿 𐑢𐑪𐑯𐑑 𐑑 𐑮𐑦𐑟𐑿𐑥 𐑨𐑑 $time?';
  }

  @override
  String get videoStartOverButtonLabel => '𐑕𐑑𐑸𐑑 𐑴𐑝𐑼';

  @override
  String get videoResumeButtonLabel => '𐑮𐑦𐑟𐑿𐑥';

  @override
  String get setCoverDialogLatest => '𐑤𐑱𐑑𐑩𐑕𐑑 𐑲𐑑𐑩𐑥';

  @override
  String get setCoverDialogAuto => '𐑷𐑑𐑴';

  @override
  String get setCoverDialogCustom => '𐑒𐑳𐑕𐑑𐑩𐑥';

  @override
  String get hideFilterConfirmationDialogMessage => '𐑥𐑨𐑗𐑦𐑙 𐑓𐑴𐑑𐑴𐑟 𐑯 𐑝𐑦𐑛𐑦𐑴𐑟 𐑢𐑦𐑤 𐑚𐑰 𐑣𐑦𐑛𐑩𐑯 𐑓𐑮𐑪𐑥 𐑘𐑹 𐑒𐑩𐑤𐑧𐑒𐑖𐑩𐑯. 𐑿 𐑒𐑨𐑯 𐑖𐑴 𐑞𐑧𐑥 𐑩𐑜𐑧𐑯 𐑓𐑮𐑪𐑥 𐑞 «𐑐𐑮𐑦𐑝𐑩𐑕𐑦» 𐑕𐑧𐑑𐑦𐑙𐑟.\n\n¿𐑸 𐑿 𐑖𐑫𐑼 𐑿 𐑢𐑪𐑯𐑑 𐑑 𐑣𐑲𐑛 𐑞𐑧𐑥?';

  @override
  String get newAlbumDialogTitle => '𐑯𐑿 𐑨𐑤𐑚𐑩𐑥';

  @override
  String get newAlbumDialogNameLabel => '𐑨𐑤𐑚𐑩𐑥 𐑯𐑱𐑥';

  @override
  String get newAlbumDialogAlbumAlreadyExistsHelper => '𐑨𐑤𐑚𐑩𐑥 𐑷𐑤𐑮𐑧𐑛𐑦 𐑦𐑜𐑟𐑦𐑕𐑑𐑕';

  @override
  String get newAlbumDialogNameLabelAlreadyExistsHelper => '𐑛𐑦𐑮𐑧𐑒𐑑𐑼𐑦 𐑷𐑤𐑮𐑧𐑛𐑦 𐑦𐑜𐑟𐑦𐑕𐑑𐑕';

  @override
  String get newAlbumDialogStorageLabel => '𐑕𐑑𐑹𐑦𐑡:';

  @override
  String get newVaultWarningDialogMessage => '𐑲𐑑𐑩𐑥𐑟 𐑦𐑯 𐑝𐑷𐑤𐑑𐑕 𐑸 𐑴𐑯𐑤𐑦 𐑩𐑝𐑱𐑤𐑩𐑚𐑩𐑤 𐑑 𐑞𐑦𐑕 𐑨𐑐 𐑯 𐑯𐑴 𐑳𐑞𐑼𐑟.\n\n𐑦𐑓 𐑿 𐑳𐑯𐑦𐑯𐑕𐑑𐑷𐑤 𐑞𐑦𐑕 𐑨𐑐, 𐑹 𐑒𐑤𐑽 𐑞𐑦𐑕 𐑨𐑐 𐑛𐑱𐑑𐑩, 𐑿 𐑢𐑦𐑤 𐑤𐑵𐑟 𐑷𐑤 𐑞𐑰𐑟 𐑲𐑑𐑩𐑥𐑟.';

  @override
  String get newVaultDialogTitle => '𐑯𐑿 𐑝𐑷𐑤𐑑';

  @override
  String get configureVaultDialogTitle => '𐑒𐑩𐑯𐑓𐑦𐑜𐑼 𐑝𐑷𐑤𐑑';

  @override
  String get vaultDialogLockModeWhenScreenOff => '𐑤𐑪𐑒 𐑢𐑧𐑯 𐑕𐑒𐑮𐑰𐑯 𐑑𐑻𐑯𐑟 𐑪𐑓';

  @override
  String get vaultDialogLockTypeLabel => '𐑤𐑪𐑒 𐑑𐑲𐑐';

  @override
  String get patternDialogEnter => '𐑧𐑯𐑑𐑼 𐑐𐑨𐑑𐑼𐑯';

  @override
  String get patternDialogConfirm => '𐑒𐑩𐑯𐑓𐑻𐑥 𐑐𐑨𐑑𐑼𐑯';

  @override
  String get pinDialogEnter => '𐑧𐑯𐑑𐑼 ⸰𐑐𐑲𐑯';

  @override
  String get pinDialogConfirm => '𐑒𐑩𐑯𐑓𐑻𐑥 ⸰𐑐𐑲𐑯';

  @override
  String get passwordDialogEnter => '𐑧𐑯𐑑𐑼 𐑐𐑭𐑕𐑢𐑻𐑛';

  @override
  String get passwordDialogConfirm => '𐑒𐑩𐑯𐑓𐑻𐑥 𐑐𐑭𐑕𐑢𐑻𐑛';

  @override
  String get authenticateToConfigureVault => '𐑷𐑔𐑧𐑯𐑑𐑦𐑒𐑱𐑑 𐑑 𐑒𐑩𐑯𐑓𐑦𐑜𐑼 𐑝𐑷𐑤𐑑';

  @override
  String get authenticateToUnlockVault => '𐑷𐑔𐑧𐑯𐑑𐑦𐑒𐑱𐑑 𐑑 𐑳𐑯𐑤𐑪𐑒 𐑝𐑷𐑤𐑑';

  @override
  String get vaultBinUsageDialogMessage => '𐑕𐑳𐑥 𐑝𐑷𐑤𐑑𐑕 𐑸 𐑿𐑟𐑦𐑙 𐑞 𐑮𐑰𐑕𐑲𐑒𐑩𐑤 𐑚𐑦𐑯.';

  @override
  String get renameAlbumDialogLabel => '𐑯𐑿 𐑯𐑱𐑥';

  @override
  String get renameAlbumDialogLabelAlreadyExistsHelper => '𐑛𐑦𐑮𐑧𐑒𐑑𐑼𐑦 𐑷𐑤𐑮𐑧𐑛𐑦 𐑦𐑜𐑟𐑦𐑕𐑑𐑕';

  @override
  String get renameEntrySetPageTitle => '𐑮𐑰𐑯𐑱𐑥';

  @override
  String get renameEntrySetPagePatternFieldLabel => '𐑯𐑱𐑥𐑦𐑙 𐑐𐑨𐑑𐑼𐑯';

  @override
  String get renameEntrySetPageInsertTooltip => '𐑦𐑯𐑕𐑻𐑑 𐑓𐑰𐑤𐑛';

  @override
  String get renameEntrySetPagePreviewSectionTitle => '𐑐𐑮𐑰𐑝𐑿';

  @override
  String get renameProcessorCounter => '𐑒𐑬𐑯𐑑𐑼';

  @override
  String get renameProcessorHash => '𐑣𐑨𐑖';

  @override
  String get renameProcessorName => '𐑯𐑱𐑥';

  @override
  String deleteSingleAlbumConfirmationDialogMessage(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '¿𐑛𐑦𐑤𐑰𐑑 𐑞𐑦𐑕 𐑨𐑤𐑚𐑩𐑥 𐑯 𐑞 $countString 𐑲𐑑𐑩𐑥𐑟 𐑦𐑯 𐑦𐑑?',
      one: '¿𐑛𐑦𐑤𐑰𐑑 𐑞𐑦𐑕 𐑨𐑤𐑚𐑩𐑥 𐑯 𐑞 𐑲𐑑𐑩𐑥 𐑦𐑯 𐑦𐑑?',
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
      other: '¿𐑛𐑦𐑤𐑰𐑑 𐑞𐑰𐑟 𐑨𐑤𐑚𐑩𐑥𐑟 𐑯 𐑞 $countString 𐑲𐑑𐑩𐑥𐑟 𐑦𐑯 𐑞𐑧𐑥?',
      one: '¿𐑛𐑦𐑤𐑰𐑑 𐑞𐑰𐑟 𐑨𐑤𐑚𐑩𐑥𐑟 𐑯 𐑞 𐑲𐑑𐑩𐑥 𐑦𐑯 𐑞𐑧𐑥?',
    );
    return '$_temp0';
  }

  @override
  String get exportEntryDialogFormat => '𐑓𐑹𐑥𐑨𐑑:';

  @override
  String get exportEntryDialogWidth => '𐑢𐑦𐑛𐑔';

  @override
  String get exportEntryDialogHeight => '𐑣𐑲𐑑';

  @override
  String get exportEntryDialogQuality => '𐑒𐑢𐑪𐑤𐑦𐑑𐑦';

  @override
  String get exportEntryDialogWriteMetadata => '𐑮𐑲𐑑 𐑥𐑧𐑑𐑩𐑛𐑱𐑑𐑩';

  @override
  String get renameEntryDialogLabel => '𐑯𐑿 𐑯𐑱𐑥';

  @override
  String get editEntryDialogCopyFromItem => '𐑒𐑪𐑐𐑦 𐑓𐑮𐑪𐑥 𐑳𐑞𐑼 𐑲𐑑𐑩𐑥';

  @override
  String get editEntryDialogTargetFieldsHeader => '𐑓𐑰𐑤𐑛𐑟 𐑑 𐑥𐑪𐑛𐑦𐑓𐑲';

  @override
  String get editEntryDateDialogTitle => '𐑛𐑱𐑑 𐑯 𐑑𐑲𐑥';

  @override
  String get editEntryDateDialogSetCustom => '𐑕𐑧𐑑 𐑒𐑳𐑕𐑑𐑩𐑥 𐑛𐑱𐑑';

  @override
  String get editEntryDateDialogCopyField => '𐑒𐑪𐑐𐑦 𐑓𐑮𐑪𐑥 𐑳𐑞𐑼 𐑛𐑱𐑑';

  @override
  String get editEntryDateDialogExtractFromTitle => '𐑦𐑒𐑕𐑑𐑮𐑨𐑒𐑑 𐑓𐑮𐑪𐑥 𐑑𐑲𐑑𐑩𐑤';

  @override
  String get editEntryDateDialogShift => '𐑖𐑦𐑓𐑑';

  @override
  String get editEntryDateDialogSourceFileModifiedDate => '𐑓𐑲𐑤 𐑥𐑪𐑛𐑦𐑓𐑲𐑛 𐑛𐑱𐑑';

  @override
  String get durationDialogHours => '𐑬𐑼𐑟';

  @override
  String get durationDialogMinutes => '𐑥𐑦𐑯𐑦𐑑𐑕';

  @override
  String get durationDialogSeconds => '𐑕𐑧𐑒𐑩𐑯𐑛𐑟';

  @override
  String get editEntryLocationDialogTitle => '𐑤𐑴𐑒𐑱𐑖𐑩𐑯';

  @override
  String get editEntryLocationDialogSetCustom => '𐑕𐑧𐑑 𐑒𐑳𐑕𐑑𐑩𐑥 𐑤𐑴𐑒𐑱𐑖𐑩𐑯';

  @override
  String get editEntryLocationDialogChooseOnMap => '𐑗𐑵𐑟 𐑪𐑯 𐑥𐑨𐑐';

  @override
  String get editEntryLocationDialogLatitude => '𐑤𐑨𐑑𐑦𐑑𐑿𐑛';

  @override
  String get editEntryLocationDialogLongitude => '𐑤𐑪𐑯𐑡𐑦𐑑𐑿𐑛';

  @override
  String get locationPickerUseThisLocationButton => '𐑿𐑟 𐑞𐑦𐑕 𐑤𐑴𐑒𐑱𐑖𐑩𐑯';

  @override
  String get editEntryRatingDialogTitle => '𐑮𐑱𐑑𐑦𐑙';

  @override
  String get removeEntryMetadataDialogTitle => '𐑥𐑧𐑑𐑩𐑛𐑱𐑑𐑩 𐑮𐑦𐑥𐑵𐑝𐑩𐑤';

  @override
  String get removeEntryMetadataDialogMore => '𐑥𐑹';

  @override
  String get removeEntryMetadataMotionPhotoXmpWarningDialogMessage => '⸰𐑦𐑥𐑐 𐑦𐑟 𐑮𐑦𐑒𐑢𐑲𐑼𐑛 𐑑 𐑐𐑤𐑱 𐑞 𐑝𐑦𐑛𐑦𐑴 𐑦𐑯𐑕𐑲𐑛 𐑩 𐑥𐑴𐑖𐑩𐑯 𐑓𐑴𐑑𐑴.\n\n¿𐑸 𐑿 𐑖𐑫𐑼 𐑿 𐑢𐑪𐑯𐑑 𐑑 𐑮𐑦𐑥𐑵𐑝 𐑦𐑑?';

  @override
  String get videoSpeedDialogLabel => '𐑐𐑤𐑱𐑚𐑨𐑒 𐑕𐑐𐑰𐑛';

  @override
  String get videoStreamSelectionDialogVideo => '𐑝𐑦𐑛𐑦𐑴';

  @override
  String get videoStreamSelectionDialogAudio => '𐑷𐑛𐑦𐑴';

  @override
  String get videoStreamSelectionDialogText => '𐑕𐑳𐑚𐑑𐑲𐑑𐑩𐑤𐑟';

  @override
  String get videoStreamSelectionDialogOff => '𐑪𐑓';

  @override
  String get videoStreamSelectionDialogTrack => '𐑑𐑮𐑨𐑒';

  @override
  String get videoStreamSelectionDialogNoSelection => '𐑞𐑺 𐑸 𐑯𐑴 𐑳𐑞𐑼 𐑑𐑮𐑨𐑒𐑕.';

  @override
  String get genericSuccessFeedback => '¡𐑛𐑳𐑯!';

  @override
  String get genericFailureFeedback => '𐑓𐑱𐑤𐑛';

  @override
  String get genericDangerWarningDialogMessage => '¿𐑸 𐑿 𐑖𐑫𐑼?';

  @override
  String get tooManyItemsErrorDialogMessage => '𐑑𐑮𐑲 𐑩𐑜𐑧𐑯 𐑢𐑦𐑞 𐑓𐑿𐑼 𐑲𐑑𐑩𐑥𐑟.';

  @override
  String get menuActionConfigureView => '𐑝𐑿';

  @override
  String get menuActionSelect => '𐑕𐑦𐑤𐑧𐑒𐑑';

  @override
  String get menuActionSelectAll => '𐑕𐑦𐑤𐑧𐑒𐑑 𐑷𐑤';

  @override
  String get menuActionSelectNone => '𐑕𐑦𐑤𐑧𐑒𐑑 𐑯𐑳𐑯';

  @override
  String get menuActionMap => '𐑥𐑨𐑐';

  @override
  String get menuActionSlideshow => '𐑕𐑤𐑲𐑛𐑖𐑴';

  @override
  String get menuActionStats => '𐑕𐑑𐑨𐑑𐑕';

  @override
  String get viewDialogSortSectionTitle => '𐑕𐑹𐑑';

  @override
  String get viewDialogGroupSectionTitle => '𐑜𐑮𐑵𐑐';

  @override
  String get viewDialogLayoutSectionTitle => '𐑤𐑱𐑬𐑑';

  @override
  String get viewDialogReverseSortOrder => '𐑮𐑦𐑝𐑻𐑕 𐑕𐑹𐑑 𐑹𐑛𐑼';

  @override
  String get tileLayoutMosaic => '𐑥𐑴𐑟𐑱𐑦𐑒';

  @override
  String get tileLayoutGrid => '𐑜𐑮𐑦𐑛';

  @override
  String get tileLayoutList => '𐑤𐑦𐑕𐑑';

  @override
  String get castDialogTitle => '𐑒𐑭𐑕𐑑 𐑛𐑦𐑝𐑲𐑕𐑩𐑟';

  @override
  String get coverDialogTabCover => '𐑒𐑳𐑝𐑼';

  @override
  String get coverDialogTabApp => '𐑨𐑐';

  @override
  String get coverDialogTabColor => '𐑒𐑳𐑤𐑼';

  @override
  String get appPickDialogTitle => '𐑐𐑦𐑒 𐑨𐑐';

  @override
  String get appPickDialogNone => '𐑯𐑳𐑯';

  @override
  String get aboutPageTitle => '𐑩𐑚𐑬𐑑';

  @override
  String get aboutLinkLicense => '𐑤𐑲𐑕𐑩𐑯𐑕';

  @override
  String get aboutLinkPolicy => '𐑐𐑮𐑦𐑝𐑩𐑕𐑦 𐑐𐑪𐑤𐑩𐑕𐑦';

  @override
  String get aboutBugSectionTitle => '𐑚𐑳𐑜 𐑮𐑦𐑐𐑹𐑑';

  @override
  String get aboutBugSaveLogInstruction => '𐑕𐑱𐑝 𐑨𐑐 𐑤𐑪𐑜𐑟 𐑑 𐑩 𐑓𐑲𐑤';

  @override
  String get aboutBugCopyInfoInstruction => '𐑒𐑪𐑐𐑦 𐑕𐑦𐑕𐑑𐑩𐑥 𐑦𐑯𐑓𐑼𐑥𐑱𐑖𐑩𐑯';

  @override
  String get aboutBugCopyInfoButton => '𐑒𐑪𐑐𐑦';

  @override
  String get aboutBugReportInstruction => '𐑮𐑦𐑐𐑹𐑑 𐑪𐑯 ·𐑜𐑦𐑑𐑣𐑳𐑚 𐑢𐑦𐑞 𐑞 𐑤𐑪𐑜𐑟 𐑯 𐑕𐑦𐑕𐑑𐑩𐑥 𐑦𐑯𐑓𐑼𐑥𐑱𐑖𐑩𐑯';

  @override
  String get aboutBugReportButton => '𐑮𐑦𐑐𐑹𐑑';

  @override
  String get aboutDataUsageSectionTitle => '𐑛𐑱𐑑𐑩 𐑿𐑕𐑦𐑡';

  @override
  String get aboutDataUsageData => '𐑛𐑱𐑑𐑩';

  @override
  String get aboutDataUsageCache => '𐑒𐑨𐑖';

  @override
  String get aboutDataUsageDatabase => '𐑛𐑱𐑑𐑩𐑚𐑱𐑕';

  @override
  String get aboutDataUsageMisc => '𐑥𐑦𐑕𐑤.';

  @override
  String get aboutDataUsageInternal => '𐑦𐑯𐑑𐑻𐑯𐑩𐑤';

  @override
  String get aboutDataUsageExternal => '𐑦𐑒𐑕𐑑𐑻𐑯𐑩𐑤';

  @override
  String get aboutDataUsageClearCache => '𐑒𐑤𐑽 𐑒𐑨𐑖';

  @override
  String get aboutCreditsSectionTitle => '𐑒𐑮𐑧𐑛𐑦𐑑𐑕';

  @override
  String get aboutCreditsWorldAtlas1 => '𐑞𐑦𐑕 𐑨𐑐 𐑿𐑟𐑩𐑟 𐑩 ⸰𐑑𐑪𐑐𐑩𐑡𐑕𐑪𐑯 𐑓𐑲𐑤 𐑓𐑮𐑪𐑥';

  @override
  String get aboutCreditsWorldAtlas2 => '𐑳𐑯𐑛𐑼 ⸰𐑦𐑕𐑒 𐑤𐑲𐑕𐑩𐑯𐑕.';

  @override
  String get aboutTranslatorsSectionTitle => '𐑑𐑮𐑨𐑯𐑟𐑤𐑱𐑑𐑼𐑟';

  @override
  String get aboutLicensesSectionTitle => '𐑴𐑐𐑩𐑯-𐑕𐑹𐑕 𐑤𐑲𐑕𐑩𐑯𐑕𐑩𐑟';

  @override
  String get aboutLicensesBanner => '𐑞𐑦𐑕 𐑨𐑐 𐑿𐑟𐑩𐑟 𐑞 𐑓𐑪𐑤𐑴𐑦𐑙 𐑴𐑐𐑩𐑯-𐑕𐑹𐑕 𐑐𐑨𐑒𐑦𐑡𐑩𐑟 𐑯 𐑤𐑲𐑚𐑮𐑼𐑦𐑟.';

  @override
  String get aboutLicensesAndroidLibrariesSectionTitle => '·𐑨𐑯𐑛𐑮𐑶𐑛 𐑤𐑲𐑚𐑮𐑼𐑦𐑟';

  @override
  String get aboutLicensesFlutterPluginsSectionTitle => '·𐑓𐑤𐑳𐑑𐑼 𐑐𐑤𐑳𐑜𐑦𐑯𐑟';

  @override
  String get aboutLicensesFlutterPackagesSectionTitle => '·𐑓𐑤𐑳𐑑𐑼 𐑐𐑨𐑒𐑦𐑡𐑩𐑟';

  @override
  String get aboutLicensesDartPackagesSectionTitle => '·𐑛𐑸𐑑 𐑐𐑨𐑒𐑦𐑡𐑩𐑟';

  @override
  String get aboutLicensesShowAllButtonLabel => '𐑖𐑴 𐑷𐑤 𐑤𐑲𐑕𐑩𐑯𐑕𐑩𐑟';

  @override
  String get policyPageTitle => '𐑐𐑮𐑦𐑝𐑩𐑕𐑦 𐑐𐑪𐑤𐑩𐑕𐑦';

  @override
  String get collectionPageTitle => '𐑒𐑩𐑤𐑧𐑒𐑖𐑩𐑯';

  @override
  String get collectionPickPageTitle => '𐑐𐑦𐑒';

  @override
  String get collectionSelectPageTitle => '𐑕𐑦𐑤𐑧𐑒𐑑 𐑲𐑑𐑩𐑥𐑟';

  @override
  String get collectionActionShowTitleSearch => '𐑖𐑴 𐑑𐑲𐑑𐑩𐑤 𐑓𐑦𐑤𐑑𐑼';

  @override
  String get collectionActionHideTitleSearch => '𐑣𐑲𐑛 𐑑𐑲𐑑𐑩𐑤 𐑓𐑦𐑤𐑑𐑼';

  @override
  String get collectionActionAddShortcut => '𐑨𐑛 𐑖𐑹𐑑𐑒𐑳𐑑';

  @override
  String get collectionActionSetHome => '𐑕𐑧𐑑 𐑨𐑟 𐑣𐑴𐑥';

  @override
  String get collectionActionEmptyBin => '𐑧𐑥𐑐𐑑𐑦 𐑚𐑦𐑯';

  @override
  String get collectionActionCopy => '𐑒𐑪𐑐𐑦 𐑑 𐑨𐑤𐑚𐑩𐑥';

  @override
  String get collectionActionMove => '𐑥𐑵𐑝 𐑑 𐑨𐑤𐑚𐑩𐑥';

  @override
  String get collectionActionRescan => '𐑮𐑰𐑕𐑒𐑨𐑯';

  @override
  String get collectionActionEdit => '𐑧𐑛𐑦𐑑';

  @override
  String get collectionSearchTitlesHintText => '𐑕𐑻𐑗 𐑑𐑲𐑑𐑩𐑤𐑟';

  @override
  String get collectionGroupAlbum => '𐑚𐑲 𐑨𐑤𐑚𐑩𐑥';

  @override
  String get collectionGroupMonth => '𐑚𐑲 𐑥𐑳𐑯𐑔';

  @override
  String get collectionGroupDay => '𐑚𐑲 𐑛𐑱';

  @override
  String get collectionGroupNone => '𐑛𐑵 𐑯𐑪𐑑 𐑜𐑮𐑵𐑐';

  @override
  String get sectionUnknown => '𐑳𐑯𐑯𐑴𐑯';

  @override
  String get dateToday => '𐑑𐑫𐑛𐑱';

  @override
  String get dateYesterday => '𐑘𐑧𐑕𐑑𐑼𐑛𐑱';

  @override
  String get dateThisMonth => '𐑞𐑦𐑕 𐑥𐑳𐑯𐑔';

  @override
  String collectionDeleteFailureFeedback(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '𐑓𐑱𐑤𐑛 𐑑 𐑛𐑦𐑤𐑰𐑑 $countString 𐑲𐑑𐑩𐑥𐑟',
      one: '𐑓𐑱𐑤𐑛 𐑑 𐑛𐑦𐑤𐑰𐑑 1 𐑲𐑑𐑩𐑥',
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
      other: '𐑓𐑱𐑤𐑛 𐑑 𐑒𐑪𐑐𐑦 $countString 𐑲𐑑𐑩𐑥𐑟',
      one: '𐑓𐑱𐑤𐑛 𐑑 𐑒𐑪𐑐𐑦 1 𐑲𐑑𐑩𐑥',
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
      other: '𐑓𐑱𐑤𐑛 𐑑 𐑥𐑵𐑝 $countString 𐑲𐑑𐑩𐑥𐑟',
      one: '𐑓𐑱𐑤𐑛 𐑑 𐑥𐑵𐑝 1 𐑲𐑑𐑩𐑥',
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
      other: '𐑓𐑱𐑤𐑛 𐑑 𐑮𐑰𐑯𐑱𐑥 $countString 𐑲𐑑𐑩𐑥𐑟',
      one: '𐑓𐑱𐑤𐑛 𐑑 𐑮𐑰𐑯𐑱𐑥 1 𐑲𐑑𐑩𐑥',
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
      other: '𐑓𐑱𐑤𐑛 𐑑 𐑧𐑛𐑦𐑑 $countString 𐑲𐑑𐑩𐑥𐑟',
      one: '𐑓𐑱𐑤𐑛 𐑑 𐑧𐑛𐑦𐑑 1 𐑲𐑑𐑩𐑥',
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
      other: '𐑓𐑱𐑤𐑛 𐑑 𐑦𐑒𐑕𐑐𐑹𐑑 $countString 𐑐𐑱𐑡𐑩𐑟',
      one: '𐑓𐑱𐑤𐑛 𐑑 𐑦𐑒𐑕𐑐𐑹𐑑 1 𐑐𐑱𐑡',
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
      other: '𐑒𐑪𐑐𐑦𐑛 $countString 𐑲𐑑𐑩𐑥𐑟',
      one: '𐑒𐑪𐑐𐑦𐑛 1 𐑲𐑑𐑩𐑥',
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
      other: '𐑥𐑵𐑝𐑛 $countString 𐑲𐑑𐑩𐑥𐑟',
      one: '𐑥𐑵𐑝𐑛 1 𐑲𐑑𐑩𐑥',
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
      other: '𐑮𐑰𐑯𐑱𐑥𐑛 $countString 𐑲𐑑𐑩𐑥𐑟',
      one: '𐑮𐑰𐑯𐑱𐑥𐑛 1 𐑲𐑑𐑩𐑥',
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
      other: '𐑧𐑛𐑦𐑑𐑩𐑛 $countString 𐑲𐑑𐑩𐑥𐑟',
      one: '𐑧𐑛𐑦𐑑𐑩𐑛 1 𐑲𐑑𐑩𐑥',
    );
    return '$_temp0';
  }

  @override
  String get collectionEmptyFavourites => '𐑯𐑴 𐑓𐑱𐑝𐑼𐑦𐑑𐑕';

  @override
  String get collectionEmptyVideos => '𐑯𐑴 𐑝𐑦𐑛𐑦𐑴𐑟';

  @override
  String get collectionEmptyImages => '𐑯𐑴 𐑦𐑥𐑦𐑡𐑩𐑟';

  @override
  String get collectionEmptyGrantAccessButtonLabel => '𐑜𐑮𐑭𐑯𐑑 𐑨𐑒𐑕𐑧𐑕';

  @override
  String get collectionSelectSectionTooltip => '𐑕𐑦𐑤𐑧𐑒𐑑 𐑕𐑧𐑒𐑖𐑩𐑯';

  @override
  String get collectionDeselectSectionTooltip => '𐑛𐑰𐑕𐑦𐑤𐑧𐑒𐑑 𐑕𐑧𐑒𐑖𐑩𐑯';

  @override
  String get drawerAboutButton => '𐑩𐑚𐑬𐑑';

  @override
  String get drawerSettingsButton => '𐑕𐑧𐑑𐑦𐑙𐑟';

  @override
  String get drawerCollectionAll => '𐑷𐑤 𐑒𐑩𐑤𐑧𐑒𐑖𐑩𐑯';

  @override
  String get drawerCollectionFavourites => '𐑓𐑱𐑝𐑼𐑦𐑑𐑕';

  @override
  String get drawerCollectionImages => '𐑦𐑥𐑦𐑡𐑩𐑟';

  @override
  String get drawerCollectionVideos => '𐑝𐑦𐑛𐑦𐑴𐑟';

  @override
  String get drawerCollectionAnimated => '𐑨𐑯𐑦𐑥𐑱𐑑𐑩𐑛';

  @override
  String get drawerCollectionMotionPhotos => '𐑥𐑴𐑖𐑩𐑯 𐑓𐑴𐑑𐑴𐑟';

  @override
  String get drawerCollectionPanoramas => '𐑐𐑨𐑯𐑼𐑭𐑥𐑩𐑟';

  @override
  String get drawerCollectionRaws => '𐑮𐑷 𐑓𐑴𐑑𐑴𐑟';

  @override
  String get drawerCollectionSphericalVideos => '360° 𐑝𐑦𐑛𐑦𐑴𐑟';

  @override
  String get drawerAlbumPage => '𐑨𐑤𐑚𐑩𐑥𐑟';

  @override
  String get drawerCountryPage => '𐑒𐑳𐑯𐑑𐑮𐑦𐑟';

  @override
  String get drawerPlacePage => '𐑐𐑤𐑱𐑕𐑩𐑟';

  @override
  String get drawerTagPage => '𐑑𐑨𐑜𐑟';

  @override
  String get sortByDate => '𐑚𐑲 𐑛𐑱𐑑';

  @override
  String get sortByName => '𐑚𐑲 𐑯𐑱𐑥';

  @override
  String get sortByItemCount => '𐑚𐑲 𐑲𐑑𐑩𐑥 𐑒𐑬𐑯𐑑';

  @override
  String get sortBySize => '𐑚𐑲 𐑕𐑲𐑟';

  @override
  String get sortByAlbumFileName => '𐑚𐑲 𐑨𐑤𐑚𐑩𐑥 𐑯 𐑓𐑲𐑤 𐑯𐑱𐑥';

  @override
  String get sortByRating => '𐑚𐑲 𐑮𐑱𐑑𐑦𐑙';

  @override
  String get sortByDuration => '𐑚𐑲 𐑛𐑘𐑫𐑼𐑱𐑖𐑩𐑯';

  @override
  String get sortOrderNewestFirst => '𐑯𐑿𐑩𐑕𐑑 𐑓𐑻𐑕𐑑';

  @override
  String get sortOrderOldestFirst => '𐑴𐑤𐑛𐑩𐑕𐑑 𐑓𐑻𐑕𐑑';

  @override
  String get sortOrderAtoZ => '·𐑐 𐑑 ·𐑿';

  @override
  String get sortOrderZtoA => '·𐑿 𐑑 ·𐑐';

  @override
  String get sortOrderHighestFirst => '𐑣𐑲𐑩𐑕𐑑 𐑓𐑻𐑕𐑑';

  @override
  String get sortOrderLowestFirst => '𐑤𐑴𐑩𐑕𐑑 𐑓𐑻𐑕𐑑';

  @override
  String get sortOrderLargestFirst => '𐑤𐑸𐑡𐑩𐑕𐑑 𐑓𐑻𐑕𐑑';

  @override
  String get sortOrderSmallestFirst => '𐑕𐑥𐑷𐑤𐑩𐑕𐑑 𐑓𐑻𐑕𐑑';

  @override
  String get sortOrderShortestFirst => '𐑖𐑹𐑑𐑩𐑕𐑑 𐑓𐑻𐑕𐑑';

  @override
  String get sortOrderLongestFirst => '𐑤𐑪𐑙𐑜𐑩𐑕𐑑 𐑓𐑻𐑕𐑑';

  @override
  String get albumGroupTier => '𐑚𐑲 𐑑𐑽';

  @override
  String get albumGroupType => '𐑚𐑲 𐑑𐑲𐑐';

  @override
  String get albumGroupVolume => '𐑚𐑲 𐑕𐑑𐑹𐑦𐑡 𐑝𐑪𐑤𐑿𐑥';

  @override
  String get albumGroupNone => '𐑛𐑵 𐑯𐑪𐑑 𐑜𐑮𐑵𐑐';

  @override
  String get albumMimeTypeMixed => '𐑥𐑦𐑒𐑕𐑑';

  @override
  String get albumPickPageTitleCopy => '𐑒𐑪𐑐𐑦 𐑑 𐑨𐑤𐑚𐑩𐑥';

  @override
  String get albumPickPageTitleExport => '𐑦𐑒𐑕𐑐𐑹𐑑 𐑑 𐑨𐑤𐑚𐑩𐑥';

  @override
  String get albumPickPageTitleMove => '𐑥𐑵𐑝 𐑑 𐑨𐑤𐑚𐑩𐑥';

  @override
  String get albumPickPageTitlePick => '𐑐𐑦𐑒 𐑨𐑤𐑚𐑩𐑥';

  @override
  String get albumCamera => '𐑒𐑨𐑥𐑼𐑩';

  @override
  String get albumDownload => '𐑛𐑬𐑯𐑤𐑴𐑛';

  @override
  String get albumScreenshots => '𐑕𐑒𐑮𐑰𐑯𐑖𐑪𐑑𐑕';

  @override
  String get albumScreenRecordings => '𐑕𐑒𐑮𐑰𐑯 𐑮𐑦𐑒𐑹𐑛𐑦𐑙𐑟';

  @override
  String get albumVideoCaptures => '𐑝𐑦𐑛𐑦𐑴 𐑒𐑨𐑐𐑗𐑼𐑟';

  @override
  String get albumPageTitle => '𐑨𐑤𐑚𐑩𐑥𐑟';

  @override
  String get albumEmpty => '𐑯𐑴 𐑨𐑤𐑚𐑩𐑥𐑟';

  @override
  String get createAlbumButtonLabel => '𐑒𐑮𐑦𐑱𐑑';

  @override
  String get newFilterBanner => '𐑯𐑿';

  @override
  String get countryPageTitle => '𐑒𐑳𐑯𐑑𐑮𐑦𐑟';

  @override
  String get countryEmpty => '𐑯𐑴 𐑒𐑳𐑯𐑑𐑮𐑦𐑟';

  @override
  String get statePageTitle => '𐑕𐑑𐑱𐑑𐑕';

  @override
  String get stateEmpty => '𐑯𐑴 𐑕𐑑𐑱𐑑𐑕';

  @override
  String get placePageTitle => '𐑐𐑤𐑱𐑕𐑩𐑟';

  @override
  String get placeEmpty => '𐑯𐑴 𐑐𐑤𐑱𐑕𐑩𐑟';

  @override
  String get tagPageTitle => '𐑑𐑨𐑜𐑟';

  @override
  String get tagEmpty => '𐑯𐑴 𐑑𐑨𐑜𐑟';

  @override
  String get binPageTitle => '𐑮𐑰𐑕𐑲𐑒𐑩𐑤 𐑚𐑦𐑯';

  @override
  String get explorerPageTitle => '𐑦𐑒𐑕𐑐𐑤𐑹𐑼';

  @override
  String get explorerActionSelectStorageVolume => '𐑕𐑦𐑤𐑧𐑒𐑑 𐑕𐑑𐑹𐑦𐑡';

  @override
  String get selectStorageVolumeDialogTitle => '𐑕𐑦𐑤𐑧𐑒𐑑 𐑕𐑑𐑹𐑦𐑡';

  @override
  String get searchCollectionFieldHint => '𐑕𐑻𐑗 𐑒𐑩𐑤𐑧𐑒𐑖𐑩𐑯';

  @override
  String get searchRecentSectionTitle => '𐑮𐑰𐑕𐑩𐑯𐑑';

  @override
  String get searchDateSectionTitle => '𐑛𐑱𐑑';

  @override
  String get searchAlbumsSectionTitle => '𐑨𐑤𐑚𐑩𐑥𐑟';

  @override
  String get searchCountriesSectionTitle => '𐑒𐑳𐑯𐑑𐑮𐑦𐑟';

  @override
  String get searchStatesSectionTitle => '𐑕𐑑𐑱𐑑𐑕';

  @override
  String get searchPlacesSectionTitle => '𐑐𐑤𐑱𐑕𐑩𐑟';

  @override
  String get searchTagsSectionTitle => '𐑑𐑨𐑜𐑟';

  @override
  String get searchRatingSectionTitle => '𐑮𐑱𐑑𐑦𐑙𐑟';

  @override
  String get searchMetadataSectionTitle => '𐑥𐑧𐑑𐑩𐑛𐑱𐑑𐑩';

  @override
  String get settingsPageTitle => '𐑕𐑧𐑑𐑦𐑙𐑟';

  @override
  String get settingsSystemDefault => '𐑕𐑦𐑕𐑑𐑩𐑥 𐑛𐑦𐑓𐑷𐑤𐑑';

  @override
  String get settingsDefault => '𐑛𐑦𐑓𐑷𐑤𐑑';

  @override
  String get settingsDisabled => '𐑛𐑦𐑕𐑱𐑚𐑩𐑤𐑛';

  @override
  String get settingsAskEverytime => '𐑭𐑕𐑒 𐑧𐑝𐑮𐑦𐑑𐑲𐑥';

  @override
  String get settingsModificationWarningDialogMessage => '𐑳𐑞𐑼 𐑕𐑧𐑑𐑦𐑙𐑟 𐑢𐑦𐑤 𐑚𐑰 𐑥𐑪𐑛𐑦𐑓𐑲𐑛.';

  @override
  String get settingsSearchFieldLabel => '𐑕𐑻𐑗 𐑕𐑧𐑑𐑦𐑙𐑟';

  @override
  String get settingsSearchEmpty => '𐑯𐑴 𐑥𐑨𐑗𐑦𐑙 𐑕𐑧𐑑𐑦𐑙';

  @override
  String get settingsActionExport => '𐑦𐑒𐑕𐑐𐑹𐑑';

  @override
  String get settingsActionExportDialogTitle => '𐑦𐑒𐑕𐑐𐑹𐑑';

  @override
  String get settingsActionImport => '𐑦𐑥𐑐𐑹𐑑';

  @override
  String get settingsActionImportDialogTitle => '𐑦𐑥𐑐𐑹𐑑';

  @override
  String get appExportCovers => '𐑒𐑳𐑝𐑼𐑟';

  @override
  String get appExportFavourites => '𐑓𐑱𐑝𐑼𐑦𐑑𐑕';

  @override
  String get appExportSettings => '𐑕𐑧𐑑𐑦𐑙𐑟';

  @override
  String get settingsNavigationSectionTitle => '𐑯𐑨𐑝𐑦𐑜𐑱𐑖𐑩𐑯';

  @override
  String get settingsHomeTile => '𐑣𐑴𐑥';

  @override
  String get settingsHomeDialogTitle => '𐑣𐑴𐑥';

  @override
  String get setHomeCustom => '𐑒𐑳𐑕𐑑𐑩𐑥';

  @override
  String get settingsShowBottomNavigationBar => '𐑖𐑴 𐑚𐑳𐑑𐑩𐑯 𐑯𐑨𐑝𐑦𐑜𐑱𐑖𐑩𐑯 𐑚𐑸';

  @override
  String get settingsKeepScreenOnTile => '𐑒𐑰𐑐 𐑕𐑒𐑮𐑰𐑯 𐑪𐑯';

  @override
  String get settingsKeepScreenOnDialogTitle => '𐑒𐑰𐑐 𐑕𐑒𐑮𐑰𐑯 𐑪𐑯';

  @override
  String get settingsDoubleBackExit => '𐑑𐑨𐑐 «𐑚𐑨𐑒» 𐑑𐑢𐑲𐑕 𐑑 𐑧𐑒𐑕𐑦𐑑';

  @override
  String get settingsConfirmationTile => '𐑒𐑪𐑯𐑓𐑼𐑥𐑱𐑖𐑩𐑯 𐑛𐑲𐑩𐑤𐑪𐑜𐑟';

  @override
  String get settingsConfirmationDialogTitle => '𐑒𐑪𐑯𐑓𐑼𐑥𐑱𐑖𐑩𐑯 𐑛𐑲𐑩𐑤𐑪𐑜𐑟';

  @override
  String get settingsConfirmationBeforeDeleteItems => '𐑭𐑕𐑒 𐑚𐑦𐑓𐑹 𐑛𐑦𐑤𐑰𐑑𐑦𐑙 𐑲𐑑𐑩𐑥𐑟 𐑓𐑼𐑧𐑝𐑼';

  @override
  String get settingsConfirmationBeforeMoveToBinItems => '𐑭𐑕𐑒 𐑚𐑦𐑓𐑹 𐑥𐑵𐑝𐑦𐑙 𐑲𐑑𐑩𐑥𐑟 𐑑 𐑞 𐑮𐑰𐑕𐑲𐑒𐑩𐑤 𐑚𐑦𐑯';

  @override
  String get settingsConfirmationBeforeMoveUndatedItems => '𐑭𐑕𐑒 𐑚𐑦𐑓𐑹 𐑥𐑵𐑝𐑦𐑙 𐑳𐑯𐑛𐑱𐑑𐑩𐑛 𐑲𐑑𐑩𐑥𐑟';

  @override
  String get settingsConfirmationAfterMoveToBinItems => '𐑖𐑴 𐑥𐑧𐑕𐑦𐑡 𐑭𐑓𐑑𐑼 𐑥𐑵𐑝𐑦𐑙 𐑲𐑑𐑩𐑥𐑟 𐑑 𐑞 𐑮𐑰𐑕𐑲𐑒𐑩𐑤 𐑚𐑦𐑯';

  @override
  String get settingsConfirmationVaultDataLoss => '𐑖𐑴 𐑝𐑷𐑤𐑑 𐑛𐑱𐑑𐑩 𐑤𐑪𐑕 𐑢𐑹𐑯𐑦𐑙';

  @override
  String get settingsNavigationDrawerTile => '𐑯𐑨𐑝𐑦𐑜𐑱𐑖𐑩𐑯 𐑥𐑧𐑯𐑿';

  @override
  String get settingsNavigationDrawerEditorPageTitle => '𐑯𐑨𐑝𐑦𐑜𐑱𐑖𐑩𐑯 𐑥𐑧𐑯𐑿';

  @override
  String get settingsNavigationDrawerBanner => '𐑑𐑳𐑗 𐑯 𐑣𐑴𐑤𐑛 𐑑 𐑥𐑵𐑝 𐑯 𐑮𐑰𐑹𐑛𐑼 𐑥𐑧𐑯𐑿 𐑲𐑑𐑩𐑥𐑟.';

  @override
  String get settingsNavigationDrawerTabTypes => '𐑑𐑲𐑐𐑕';

  @override
  String get settingsNavigationDrawerTabAlbums => '𐑨𐑤𐑚𐑩𐑥𐑟';

  @override
  String get settingsNavigationDrawerTabPages => '𐑐𐑱𐑡𐑩𐑟';

  @override
  String get settingsNavigationDrawerAddAlbum => '𐑨𐑛 𐑨𐑤𐑚𐑩𐑥';

  @override
  String get settingsThumbnailSectionTitle => '𐑔𐑳𐑥𐑯𐑱𐑤𐑟';

  @override
  String get settingsThumbnailOverlayTile => '𐑴𐑝𐑼𐑤𐑱';

  @override
  String get settingsThumbnailOverlayPageTitle => '𐑴𐑝𐑼𐑤𐑱';

  @override
  String get settingsThumbnailShowHdrIcon => '𐑖𐑴 ⸰𐑣𐑛𐑮 𐑲𐑒𐑪𐑯';

  @override
  String get settingsThumbnailShowFavouriteIcon => '𐑖𐑴 𐑓𐑱𐑝𐑼𐑦𐑑 𐑲𐑒𐑪𐑯';

  @override
  String get settingsThumbnailShowTagIcon => '𐑖𐑴 𐑑𐑨𐑜 𐑲𐑒𐑪𐑯';

  @override
  String get settingsThumbnailShowLocationIcon => '𐑖𐑴 𐑤𐑴𐑒𐑱𐑖𐑩𐑯 𐑲𐑒𐑪𐑯';

  @override
  String get settingsThumbnailShowMotionPhotoIcon => '𐑖𐑴 𐑥𐑴𐑖𐑩𐑯 𐑓𐑴𐑑𐑴 𐑲𐑒𐑪𐑯';

  @override
  String get settingsThumbnailShowRating => '𐑖𐑴 𐑮𐑱𐑑𐑦𐑙';

  @override
  String get settingsThumbnailShowRawIcon => '𐑖𐑴 𐑮𐑷 𐑲𐑒𐑪𐑯';

  @override
  String get settingsThumbnailShowVideoDuration => '𐑖𐑴 𐑝𐑦𐑛𐑦𐑴 𐑛𐑘𐑫𐑼𐑱𐑖𐑩𐑯';

  @override
  String get settingsCollectionQuickActionsTile => '𐑒𐑢𐑦𐑒 𐑨𐑒𐑖𐑩𐑯𐑟';

  @override
  String get settingsCollectionQuickActionEditorPageTitle => '𐑒𐑢𐑦𐑒 𐑨𐑒𐑖𐑩𐑯𐑟';

  @override
  String get settingsCollectionQuickActionTabBrowsing => '𐑚𐑮𐑬𐑟𐑦𐑙';

  @override
  String get settingsCollectionQuickActionTabSelecting => '𐑕𐑦𐑤𐑧𐑒𐑑𐑦𐑙';

  @override
  String get settingsCollectionBrowsingQuickActionEditorBanner => '𐑑𐑳𐑗 𐑯 𐑣𐑴𐑤𐑛 𐑑 𐑥𐑵𐑝 𐑚𐑳𐑑𐑩𐑯𐑟 𐑯 𐑕𐑦𐑤𐑧𐑒𐑑 𐑢𐑦𐑗 𐑨𐑒𐑖𐑩𐑯𐑟 𐑸 𐑛𐑦𐑕𐑐𐑤𐑱𐑛 𐑢𐑧𐑯 𐑚𐑮𐑬𐑟𐑦𐑙 𐑲𐑑𐑩𐑥𐑟.';

  @override
  String get settingsCollectionSelectionQuickActionEditorBanner => '𐑑𐑳𐑗 𐑯 𐑣𐑴𐑤𐑛 𐑑 𐑥𐑵𐑝 𐑚𐑳𐑑𐑩𐑯𐑟 𐑯 𐑕𐑦𐑤𐑧𐑒𐑑 𐑢𐑦𐑗 𐑨𐑒𐑖𐑩𐑯𐑟 𐑸 𐑛𐑦𐑕𐑐𐑤𐑱𐑛 𐑢𐑧𐑯 𐑕𐑦𐑤𐑧𐑒𐑑𐑦𐑙 𐑲𐑑𐑩𐑥𐑟.';

  @override
  String get settingsCollectionBurstPatternsTile => '𐑚𐑻𐑕𐑑 𐑐𐑨𐑑𐑼𐑯𐑟';

  @override
  String get settingsCollectionBurstPatternsNone => '𐑯𐑳𐑯';

  @override
  String get settingsViewerSectionTitle => '𐑝𐑿𐑼';

  @override
  String get settingsViewerGestureSideTapNext => '𐑑𐑨𐑐 𐑪𐑯 𐑕𐑒𐑮𐑰𐑯 𐑧𐑡𐑩𐑟 𐑑 𐑖𐑴 𐑐𐑮𐑰𐑝𐑾𐑕/𐑯𐑧𐑒𐑕𐑑 𐑲𐑑𐑩𐑥';

  @override
  String get settingsViewerUseCutout => '𐑿𐑟 𐑒𐑳𐑑𐑬𐑑 𐑺𐑾';

  @override
  String get settingsViewerMaximumBrightness => '𐑥𐑨𐑒𐑕𐑦𐑥𐑩𐑥 𐑚𐑮𐑲𐑑𐑯𐑩𐑕';

  @override
  String get settingsMotionPhotoAutoPlay => '𐑷𐑑𐑴 𐑐𐑤𐑱 𐑥𐑴𐑖𐑩𐑯 𐑓𐑴𐑑𐑴𐑟';

  @override
  String get settingsImageBackground => '𐑦𐑥𐑦𐑡 𐑚𐑨𐑒𐑜𐑮𐑬𐑯𐑛';

  @override
  String get settingsViewerQuickActionsTile => '𐑒𐑢𐑦𐑒 𐑨𐑒𐑖𐑩𐑯𐑟';

  @override
  String get settingsViewerQuickActionEditorPageTitle => '𐑒𐑢𐑦𐑒 𐑨𐑒𐑖𐑩𐑯𐑟';

  @override
  String get settingsViewerQuickActionEditorBanner => '𐑑𐑳𐑗 𐑯 𐑣𐑴𐑤𐑛 𐑑 𐑥𐑵𐑝 𐑚𐑳𐑑𐑩𐑯𐑟 𐑯 𐑕𐑦𐑤𐑧𐑒𐑑 𐑢𐑦𐑗 𐑨𐑒𐑖𐑩𐑯𐑟 𐑸 𐑛𐑦𐑕𐑐𐑤𐑱𐑛 𐑦𐑯 𐑞 𐑝𐑿𐑼.';

  @override
  String get settingsViewerQuickActionEditorDisplayedButtonsSectionTitle => '𐑛𐑦𐑕𐑐𐑤𐑱𐑛 𐑚𐑳𐑑𐑩𐑯𐑟';

  @override
  String get settingsViewerQuickActionEditorAvailableButtonsSectionTitle => '𐑩𐑝𐑱𐑤𐑩𐑚𐑩𐑤 𐑚𐑳𐑑𐑩𐑯𐑟';

  @override
  String get settingsViewerQuickActionEmpty => '𐑯𐑴 𐑚𐑳𐑑𐑩𐑯𐑟';

  @override
  String get settingsViewerOverlayTile => '𐑴𐑝𐑼𐑤𐑱';

  @override
  String get settingsViewerOverlayPageTitle => '𐑴𐑝𐑼𐑤𐑱';

  @override
  String get settingsViewerShowOverlayOnOpening => '𐑖𐑴 𐑪𐑯 𐑴𐑐𐑩𐑯𐑦𐑙';

  @override
  String get settingsViewerShowHistogram => '𐑖𐑴 𐑣𐑦𐑕𐑑𐑩𐑜𐑮𐑨𐑥';

  @override
  String get settingsViewerShowMinimap => '𐑖𐑴 𐑥𐑦𐑯𐑦𐑥𐑨𐑐';

  @override
  String get settingsViewerShowInformation => '𐑖𐑴 𐑦𐑯𐑓𐑼𐑥𐑱𐑖𐑩𐑯';

  @override
  String get settingsViewerShowInformationSubtitle => '𐑖𐑴 𐑑𐑲𐑑𐑩𐑤, 𐑛𐑱𐑑, 𐑤𐑴𐑒𐑱𐑖𐑩𐑯, 𐑯𐑯𐑯';

  @override
  String get settingsViewerShowRatingTags => '𐑖𐑴 𐑮𐑱𐑑𐑦𐑙 𐑯 𐑑𐑨𐑜𐑟';

  @override
  String get settingsViewerShowShootingDetails => '𐑖𐑴 𐑖𐑵𐑑𐑦𐑙 𐑛𐑰𐑑𐑱𐑤𐑟';

  @override
  String get settingsViewerShowDescription => '𐑖𐑴 𐑛𐑦𐑕𐑒𐑮𐑦𐑐𐑖𐑩𐑯';

  @override
  String get settingsViewerShowOverlayThumbnails => '𐑖𐑴 𐑔𐑳𐑥𐑯𐑱𐑤𐑟';

  @override
  String get settingsViewerEnableOverlayBlurEffect => '𐑚𐑤𐑻 𐑦𐑓𐑧𐑒𐑑';

  @override
  String get settingsViewerSlideshowTile => '𐑕𐑤𐑲𐑛𐑖𐑴';

  @override
  String get settingsViewerSlideshowPageTitle => '𐑕𐑤𐑲𐑛𐑖𐑴';

  @override
  String get settingsSlideshowRepeat => '𐑮𐑦𐑐𐑰𐑑';

  @override
  String get settingsSlideshowShuffle => '𐑖𐑳𐑓𐑩𐑤';

  @override
  String get settingsSlideshowFillScreen => '𐑓𐑦𐑤 𐑕𐑒𐑮𐑰𐑯';

  @override
  String get settingsSlideshowAnimatedZoomEffect => '𐑨𐑯𐑦𐑥𐑱𐑑𐑩𐑛 𐑟𐑵𐑥 𐑦𐑓𐑧𐑒𐑑';

  @override
  String get settingsSlideshowTransitionTile => '𐑑𐑮𐑨𐑯𐑟𐑦𐑖𐑩𐑯';

  @override
  String get settingsSlideshowIntervalTile => '𐑦𐑯𐑑𐑼𐑝𐑩𐑤';

  @override
  String get settingsSlideshowVideoPlaybackTile => '𐑝𐑦𐑛𐑦𐑴 𐑐𐑤𐑱𐑚𐑨𐑒';

  @override
  String get settingsSlideshowVideoPlaybackDialogTitle => '𐑝𐑦𐑛𐑦𐑴 𐑐𐑤𐑱𐑚𐑨𐑒';

  @override
  String get settingsVideoPageTitle => '𐑝𐑦𐑛𐑦𐑴 𐑕𐑧𐑑𐑦𐑙𐑟';

  @override
  String get settingsVideoSectionTitle => '𐑝𐑦𐑛𐑦𐑴';

  @override
  String get settingsVideoShowVideos => '𐑖𐑴 𐑝𐑦𐑛𐑦𐑴𐑟';

  @override
  String get settingsVideoPlaybackTile => '𐑐𐑤𐑱𐑚𐑨𐑒';

  @override
  String get settingsVideoPlaybackPageTitle => '𐑐𐑤𐑱𐑚𐑨𐑒';

  @override
  String get settingsVideoEnableHardwareAcceleration => '𐑣𐑸𐑛𐑢𐑺 𐑩𐑒𐑕𐑧𐑤𐑼𐑱𐑖𐑩𐑯';

  @override
  String get settingsVideoAutoPlay => '𐑷𐑑𐑴 𐑐𐑤𐑱';

  @override
  String get settingsVideoLoopModeTile => '𐑤𐑵𐑐 𐑥𐑴𐑛';

  @override
  String get settingsVideoLoopModeDialogTitle => '𐑤𐑵𐑐 𐑥𐑴𐑛';

  @override
  String get settingsVideoResumptionModeTile => '𐑮𐑦𐑟𐑿𐑥 𐑐𐑤𐑱𐑚𐑨𐑒';

  @override
  String get settingsVideoResumptionModeDialogTitle => '𐑮𐑦𐑟𐑿𐑥 𐑐𐑤𐑱𐑚𐑨𐑒';

  @override
  String get settingsVideoBackgroundMode => '𐑚𐑨𐑒𐑜𐑮𐑬𐑯𐑛 𐑥𐑴𐑛';

  @override
  String get settingsVideoBackgroundModeDialogTitle => '𐑚𐑨𐑒𐑜𐑮𐑬𐑯𐑛 𐑥𐑴𐑛';

  @override
  String get settingsVideoControlsTile => '𐑒𐑩𐑯𐑑𐑮𐑴𐑤𐑟';

  @override
  String get settingsVideoControlsPageTitle => '𐑒𐑩𐑯𐑑𐑮𐑴𐑤𐑟';

  @override
  String get settingsVideoButtonsTile => '𐑚𐑳𐑑𐑩𐑯𐑟';

  @override
  String get settingsVideoGestureDoubleTapTogglePlay => '𐑛𐑳𐑚𐑩𐑤 𐑑𐑨𐑐 𐑑 𐑐𐑤𐑱/𐑐𐑷𐑟';

  @override
  String get settingsVideoGestureSideDoubleTapSeek => '𐑛𐑳𐑚𐑩𐑤 𐑑𐑨𐑐 𐑪𐑯 𐑕𐑒𐑮𐑰𐑯 𐑧𐑡𐑩𐑟 𐑑 𐑕𐑰𐑒 𐑚𐑨𐑒𐑢𐑼𐑛/𐑓𐑹𐑢𐑼𐑛';

  @override
  String get settingsVideoGestureVerticalDragBrightnessVolume => '𐑕𐑢𐑲𐑐 𐑳𐑐 𐑹 𐑛𐑬𐑯 𐑑 𐑩𐑡𐑳𐑕𐑑 𐑚𐑮𐑲𐑑𐑯𐑩𐑕/𐑝𐑪𐑤𐑿𐑥';

  @override
  String get settingsSubtitleThemeTile => '𐑕𐑳𐑚𐑑𐑲𐑑𐑩𐑤𐑟';

  @override
  String get settingsSubtitleThemePageTitle => '𐑕𐑳𐑚𐑑𐑲𐑑𐑩𐑤𐑟';

  @override
  String get settingsSubtitleThemeSample => '𐑞𐑦𐑕 𐑦𐑟 𐑩 𐑕𐑭𐑥𐑐𐑩𐑤.';

  @override
  String get settingsSubtitleThemeTextAlignmentTile => '𐑑𐑧𐑒𐑕𐑑 𐑩𐑤𐑲𐑯𐑥𐑩𐑯𐑑';

  @override
  String get settingsSubtitleThemeTextAlignmentDialogTitle => '𐑑𐑧𐑒𐑕𐑑 𐑩𐑤𐑲𐑯𐑥𐑩𐑯𐑑';

  @override
  String get settingsSubtitleThemeTextPositionTile => '𐑑𐑧𐑒𐑕𐑑 𐑐𐑩𐑟𐑦𐑖𐑩𐑯';

  @override
  String get settingsSubtitleThemeTextPositionDialogTitle => '𐑑𐑧𐑒𐑕𐑑 𐑐𐑩𐑟𐑦𐑖𐑩𐑯';

  @override
  String get settingsSubtitleThemeTextSize => '𐑑𐑧𐑒𐑕𐑑 𐑕𐑲𐑟';

  @override
  String get settingsSubtitleThemeShowOutline => '𐑖𐑴 𐑬𐑑𐑤𐑲𐑯 𐑯 𐑖𐑨𐑛𐑴';

  @override
  String get settingsSubtitleThemeTextColor => '𐑑𐑧𐑒𐑕𐑑 𐑒𐑳𐑤𐑼';

  @override
  String get settingsSubtitleThemeTextOpacity => '𐑑𐑧𐑒𐑕𐑑 𐑴𐑐𐑨𐑕𐑦𐑑𐑦';

  @override
  String get settingsSubtitleThemeBackgroundColor => '𐑚𐑨𐑒𐑜𐑮𐑬𐑯𐑛 𐑒𐑳𐑤𐑼';

  @override
  String get settingsSubtitleThemeBackgroundOpacity => '𐑚𐑨𐑒𐑜𐑮𐑬𐑯𐑛 𐑴𐑐𐑨𐑕𐑦𐑑𐑦';

  @override
  String get settingsSubtitleThemeTextAlignmentLeft => '𐑤𐑧𐑓𐑑';

  @override
  String get settingsSubtitleThemeTextAlignmentCenter => '𐑕𐑧𐑯𐑑𐑼';

  @override
  String get settingsSubtitleThemeTextAlignmentRight => '𐑮𐑲𐑑';

  @override
  String get settingsPrivacySectionTitle => '𐑐𐑮𐑦𐑝𐑩𐑕𐑦';

  @override
  String get settingsAllowInstalledAppAccess => '𐑩𐑤𐑬 𐑨𐑒𐑕𐑧𐑕 𐑑 𐑨𐑐 𐑦𐑯𐑝𐑩𐑯𐑑𐑼𐑦';

  @override
  String get settingsAllowInstalledAppAccessSubtitle => '𐑿𐑟𐑛 𐑑 𐑦𐑥𐑐𐑮𐑵𐑝 𐑨𐑤𐑚𐑩𐑥 𐑛𐑦𐑕𐑐𐑤𐑱';

  @override
  String get settingsAllowErrorReporting => '𐑩𐑤𐑬 𐑩𐑯𐑪𐑯𐑦𐑥𐑩𐑕 𐑧𐑮𐑼 𐑮𐑦𐑐𐑹𐑑𐑦𐑙';

  @override
  String get settingsSaveSearchHistory => '𐑕𐑱𐑝 𐑕𐑻𐑗 𐑣𐑦𐑕𐑑𐑼𐑦';

  @override
  String get settingsEnableBin => '𐑿𐑟 𐑮𐑰𐑕𐑲𐑒𐑩𐑤 𐑚𐑦𐑯';

  @override
  String get settingsEnableBinSubtitle => '𐑒𐑰𐑐 𐑛𐑦𐑤𐑰𐑑𐑩𐑛 𐑲𐑑𐑩𐑥𐑟 𐑓 30 𐑛𐑱𐑟';

  @override
  String get settingsDisablingBinWarningDialogMessage => '𐑲𐑑𐑩𐑥𐑟 𐑦𐑯 𐑞 𐑮𐑰𐑕𐑲𐑒𐑩𐑤 𐑚𐑦𐑯 𐑢𐑦𐑤 𐑚𐑰 𐑛𐑦𐑤𐑰𐑑𐑩𐑛 𐑓𐑼𐑧𐑝𐑼.';

  @override
  String get settingsAllowMediaManagement => '𐑩𐑤𐑬 𐑥𐑰𐑛𐑾 𐑥𐑨𐑯𐑦𐑡𐑥𐑩𐑯𐑑';

  @override
  String get settingsHiddenItemsTile => '𐑣𐑦𐑛𐑩𐑯 𐑲𐑑𐑩𐑥𐑟';

  @override
  String get settingsHiddenItemsPageTitle => '𐑣𐑦𐑛𐑩𐑯 𐑲𐑑𐑩𐑥𐑟';

  @override
  String get settingsHiddenFiltersBanner => '𐑓𐑴𐑑𐑴𐑟 𐑯 𐑝𐑦𐑛𐑦𐑴𐑟 𐑥𐑨𐑗𐑦𐑙 𐑣𐑦𐑛𐑩𐑯 𐑓𐑦𐑤𐑑𐑼𐑟 𐑢𐑦𐑤 𐑯𐑪𐑑 𐑩𐑐𐑽 𐑦𐑯 𐑘𐑹 𐑒𐑩𐑤𐑧𐑒𐑖𐑩𐑯.';

  @override
  String get settingsHiddenFiltersEmpty => '𐑯𐑴 𐑣𐑦𐑛𐑩𐑯 𐑓𐑦𐑤𐑑𐑼𐑟';

  @override
  String get settingsStorageAccessTile => '𐑕𐑑𐑹𐑦𐑡 𐑨𐑒𐑕𐑧𐑕';

  @override
  String get settingsStorageAccessPageTitle => '𐑕𐑑𐑹𐑦𐑡 𐑨𐑒𐑕𐑧𐑕';

  @override
  String get settingsStorageAccessBanner => '𐑕𐑳𐑥 𐑛𐑦𐑮𐑧𐑒𐑑𐑼𐑦𐑟 𐑮𐑦𐑒𐑢𐑲𐑼 𐑩𐑯 𐑦𐑒𐑕𐑐𐑤𐑦𐑕𐑦𐑑 𐑨𐑒𐑕𐑧𐑕 𐑜𐑮𐑭𐑯𐑑 𐑑 𐑥𐑪𐑛𐑦𐑓𐑲 𐑓𐑲𐑤𐑟 𐑦𐑯 𐑞𐑧𐑥. 𐑿 𐑒𐑨𐑯 𐑮𐑦𐑝𐑿 𐑣𐑽 𐑛𐑦𐑮𐑧𐑒𐑑𐑼𐑦𐑟 𐑑 𐑢𐑦𐑗 𐑿 𐑐𐑮𐑰𐑝𐑾𐑕𐑤𐑦 𐑜𐑱𐑝 𐑨𐑒𐑕𐑧𐑕.';

  @override
  String get settingsStorageAccessEmpty => '𐑯𐑴 𐑨𐑒𐑕𐑧𐑕 𐑜𐑮𐑭𐑯𐑑𐑕';

  @override
  String get settingsStorageAccessRevokeTooltip => '𐑮𐑦𐑝𐑴𐑒';

  @override
  String get settingsAccessibilitySectionTitle => '𐑩𐑒𐑕𐑧𐑕𐑩𐑚𐑦𐑤𐑦𐑑𐑦';

  @override
  String get settingsRemoveAnimationsTile => '𐑮𐑦𐑥𐑵𐑝 𐑨𐑯𐑦𐑥𐑱𐑖𐑩𐑯𐑟';

  @override
  String get settingsRemoveAnimationsDialogTitle => '𐑮𐑦𐑥𐑵𐑝 𐑨𐑯𐑦𐑥𐑱𐑖𐑩𐑯𐑟';

  @override
  String get settingsTimeToTakeActionTile => '𐑑𐑲𐑥 𐑑 𐑑𐑱𐑒 𐑨𐑒𐑖𐑩𐑯';

  @override
  String get settingsAccessibilityShowPinchGestureAlternatives => '𐑖𐑴 𐑥𐑳𐑤𐑑𐑦-𐑑𐑳𐑗 𐑡𐑧𐑕𐑗𐑼 𐑷𐑤𐑑𐑻𐑯𐑩𐑑𐑦𐑝𐑟';

  @override
  String get settingsDisplaySectionTitle => '𐑛𐑦𐑕𐑐𐑤𐑱';

  @override
  String get settingsThemeBrightnessTile => '𐑔𐑰𐑥';

  @override
  String get settingsThemeBrightnessDialogTitle => '𐑔𐑰𐑥';

  @override
  String get settingsThemeColorHighlights => '𐑒𐑳𐑤𐑼 𐑣𐑲𐑤𐑲𐑑𐑕';

  @override
  String get settingsThemeEnableDynamicColor => '𐑛𐑲𐑯𐑨𐑥𐑦𐑒 𐑒𐑳𐑤𐑼';

  @override
  String get settingsDisplayRefreshRateModeTile => '𐑛𐑦𐑕𐑐𐑤𐑱 𐑮𐑦𐑓𐑮𐑧𐑖 𐑮𐑱𐑑';

  @override
  String get settingsDisplayRefreshRateModeDialogTitle => '𐑮𐑦𐑓𐑮𐑧𐑖 𐑮𐑱𐑑';

  @override
  String get settingsDisplayUseTvInterface => '·𐑨𐑯𐑛𐑮𐑶𐑛 ⸰𐑑𐑝 𐑦𐑯𐑑𐑼𐑓𐑱𐑕';

  @override
  String get settingsLanguageSectionTitle => '𐑤𐑨𐑙𐑜𐑢𐑦𐑡 𐑯 𐑓𐑹𐑥𐑨𐑑𐑕';

  @override
  String get settingsLanguageTile => '𐑤𐑨𐑙𐑜𐑢𐑦𐑡';

  @override
  String get settingsLanguagePageTitle => '𐑤𐑨𐑙𐑜𐑢𐑦𐑡';

  @override
  String get settingsCoordinateFormatTile => '𐑒𐑴𐑹𐑛𐑦𐑯𐑩𐑑 𐑓𐑹𐑥𐑨𐑑';

  @override
  String get settingsCoordinateFormatDialogTitle => '𐑒𐑴𐑹𐑛𐑦𐑯𐑩𐑑 𐑓𐑹𐑥𐑨𐑑';

  @override
  String get settingsUnitSystemTile => '𐑿𐑯𐑦𐑑𐑕';

  @override
  String get settingsUnitSystemDialogTitle => '𐑿𐑯𐑦𐑑𐑕';

  @override
  String get settingsForceWesternArabicNumeralsTile => '𐑓𐑹𐑕 ·𐑨𐑮𐑩𐑚𐑦𐑒 𐑯𐑿𐑥𐑼𐑩𐑤𐑟';

  @override
  String get settingsScreenSaverPageTitle => '𐑕𐑒𐑮𐑰𐑯 𐑕𐑱𐑝𐑼';

  @override
  String get settingsWidgetPageTitle => '𐑓𐑴𐑑𐑴 𐑓𐑮𐑱𐑥';

  @override
  String get settingsWidgetShowOutline => '𐑬𐑑𐑤𐑲𐑯';

  @override
  String get settingsWidgetOpenPage => '𐑢𐑧𐑯 𐑑𐑨𐑐𐑦𐑙 𐑪𐑯 𐑞 𐑢𐑦𐑡𐑩𐑑';

  @override
  String get settingsWidgetDisplayedItem => '𐑛𐑦𐑕𐑐𐑤𐑱𐑛 𐑲𐑑𐑩𐑥';

  @override
  String get settingsCollectionTile => '𐑒𐑩𐑤𐑧𐑒𐑖𐑩𐑯';

  @override
  String get statsPageTitle => '𐑕𐑑𐑨𐑑𐑕';

  @override
  String statsWithGps(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString 𐑲𐑑𐑩𐑥𐑟 𐑢𐑦𐑞 𐑤𐑴𐑒𐑱𐑖𐑩𐑯',
      one: '1 𐑲𐑑𐑩𐑥 𐑢𐑦𐑞 𐑤𐑴𐑒𐑱𐑖𐑩𐑯',
    );
    return '$_temp0';
  }

  @override
  String get statsTopCountriesSectionTitle => '𐑑𐑪𐑐 𐑒𐑳𐑯𐑑𐑮𐑦𐑟';

  @override
  String get statsTopStatesSectionTitle => '𐑑𐑪𐑐 𐑕𐑑𐑱𐑑𐑕';

  @override
  String get statsTopPlacesSectionTitle => '𐑑𐑪𐑐 𐑐𐑤𐑱𐑕𐑩𐑟';

  @override
  String get statsTopTagsSectionTitle => '𐑑𐑪𐑐 𐑑𐑨𐑜𐑟';

  @override
  String get statsTopAlbumsSectionTitle => '𐑑𐑪𐑐 𐑨𐑤𐑚𐑩𐑥𐑟';

  @override
  String get viewerOpenPanoramaButtonLabel => '𐑴𐑐𐑩𐑯 𐑐𐑨𐑯𐑼𐑭𐑥𐑩';

  @override
  String get viewerSetWallpaperButtonLabel => '𐑕𐑧𐑑 𐑢𐑷𐑤𐑐𐑱𐑐𐑼';

  @override
  String get viewerErrorUnknown => '¡𐑵𐑐𐑕!';

  @override
  String get viewerErrorDoesNotExist => '𐑞 𐑓𐑲𐑤 𐑯𐑴 𐑤𐑪𐑙𐑜𐑼 𐑦𐑜𐑟𐑦𐑕𐑑𐑕.';

  @override
  String get viewerInfoPageTitle => '𐑦𐑯𐑓𐑴';

  @override
  String get viewerInfoBackToViewerTooltip => '𐑚𐑨𐑒 𐑑 𐑝𐑿𐑼';

  @override
  String get viewerInfoUnknown => '𐑳𐑯𐑯𐑴𐑯';

  @override
  String get viewerInfoLabelDescription => '𐑛𐑦𐑕𐑒𐑮𐑦𐑐𐑖𐑩𐑯';

  @override
  String get viewerInfoLabelTitle => '𐑑𐑲𐑑𐑩𐑤';

  @override
  String get viewerInfoLabelDate => '𐑛𐑱𐑑';

  @override
  String get viewerInfoLabelResolution => '𐑮𐑧𐑟𐑩𐑤𐑵𐑖𐑩𐑯';

  @override
  String get viewerInfoLabelSize => '𐑕𐑲𐑟';

  @override
  String get viewerInfoLabelUri => '⸰𐑿𐑮𐑲';

  @override
  String get viewerInfoLabelPath => '𐑐𐑭𐑔';

  @override
  String get viewerInfoLabelDuration => '𐑛𐑘𐑫𐑼𐑱𐑖𐑩𐑯';

  @override
  String get viewerInfoLabelOwner => '𐑴𐑯𐑼';

  @override
  String get viewerInfoLabelCoordinates => '𐑒𐑴𐑹𐑛𐑦𐑯𐑩𐑑𐑕';

  @override
  String get viewerInfoLabelAddress => '𐑩𐑛𐑮𐑧𐑕';

  @override
  String get mapStyleDialogTitle => '𐑥𐑨𐑐 𐑕𐑑𐑲𐑤';

  @override
  String get mapStyleTooltip => '𐑕𐑦𐑤𐑧𐑒𐑑 𐑥𐑨𐑐 𐑕𐑑𐑲𐑤';

  @override
  String get mapZoomInTooltip => '𐑟𐑵𐑥 𐑦𐑯';

  @override
  String get mapZoomOutTooltip => '𐑟𐑵𐑥 𐑬𐑑';

  @override
  String get mapPointNorthUpTooltip => '𐑐𐑶𐑯𐑑 𐑯𐑹𐑔 𐑳𐑐';

  @override
  String get mapAttributionOsmData => '𐑥𐑨𐑐 𐑛𐑱𐑑𐑩 © [·𐑴𐑐𐑩𐑯𐑕𐑑𐑮𐑰𐑑𐑥𐑨𐑐](https://www.openstreetmap.org/copyright) 𐑒𐑩𐑯𐑑𐑮𐑦𐑚𐑘𐑩𐑑𐑼𐑟';

  @override
  String get mapAttributionOsmLiberty => '𐑑𐑲𐑤𐑟 𐑚𐑲 [·𐑴𐑐𐑩𐑯𐑥𐑨𐑐𐑑𐑲𐑤𐑟](https://www.openmaptiles.org), [⸰𐑒𐑒 𐑚𐑲](https://creativecommons.org/licenses/by/4.0) • 𐑣𐑴𐑕𐑑𐑩𐑛 𐑚𐑲 [⸰𐑴𐑕𐑥 ·𐑩𐑥𐑧𐑮𐑦𐑒𐑭𐑯𐑩](https://tile.ourmap.us)';

  @override
  String get mapAttributionOpenTopoMap => '[⸰𐑖𐑮𐑑𐑥](https://www.earthdata.nasa.gov/sensors/srtm) | 𐑑𐑲𐑤𐑟 𐑚𐑲 [·𐑴𐑐𐑩𐑯𐑑𐑪𐑐𐑩𐑥𐑨𐑐](https://opentopomap.org), [⸰𐑒𐑒 𐑚𐑲-𐑖𐑩](https://creativecommons.org/licenses/by-sa/3.0)';

  @override
  String get mapAttributionOsmHot => '𐑑𐑲𐑤𐑟 𐑚𐑲 [⸰𐑣𐑴𐑑](https://www.hotosm.org) • 𐑣𐑴𐑕𐑑𐑩𐑛 𐑚𐑲 [⸰𐑴𐑕𐑥 ·𐑓𐑮𐑭𐑯𐑕](https://openstreetmap.fr)';

  @override
  String get mapAttributionStamen => '𐑑𐑲𐑤𐑟 𐑚𐑲 [·𐑕𐑑𐑱𐑥𐑩𐑯 𐑛𐑦𐑟𐑲𐑯](https://stamen.com), [⸰𐑒𐑒 𐑚𐑲 3.0](https://creativecommons.org/licenses/by/3.0)';

  @override
  String get openMapPageTooltip => '𐑝𐑿 𐑪𐑯 ·𐑥𐑨𐑐 𐑐𐑱𐑡';

  @override
  String get mapEmptyRegion => '𐑯𐑴 𐑦𐑥𐑦𐑡𐑩𐑟 𐑦𐑯 𐑞𐑦𐑕 𐑮𐑰𐑡𐑩𐑯';

  @override
  String get viewerInfoOpenEmbeddedFailureFeedback => '𐑓𐑱𐑤𐑛 𐑑 𐑦𐑒𐑕𐑑𐑮𐑨𐑒𐑑 𐑦𐑥𐑚𐑧𐑛𐑩𐑛 𐑛𐑱𐑑𐑩';

  @override
  String get viewerInfoOpenLinkText => '𐑴𐑐𐑩𐑯';

  @override
  String get viewerInfoViewXmlLinkText => '𐑝𐑿 ⸰𐑦𐑥𐑤';

  @override
  String get viewerInfoSearchFieldLabel => '𐑕𐑻𐑗 𐑥𐑧𐑑𐑩𐑛𐑱𐑑𐑩';

  @override
  String get viewerInfoSearchEmpty => '𐑯𐑴 𐑥𐑨𐑗𐑦𐑙 𐑒𐑰𐑟';

  @override
  String get viewerInfoSearchSuggestionDate => '𐑛𐑱𐑑 𐑯 𐑑𐑲𐑥';

  @override
  String get viewerInfoSearchSuggestionDescription => '𐑛𐑦𐑕𐑒𐑮𐑦𐑐𐑖𐑩𐑯';

  @override
  String get viewerInfoSearchSuggestionDimensions => '𐑛𐑦𐑥𐑧𐑯𐑖𐑩𐑯𐑟';

  @override
  String get viewerInfoSearchSuggestionResolution => '𐑮𐑧𐑟𐑩𐑤𐑵𐑖𐑩𐑯';

  @override
  String get viewerInfoSearchSuggestionRights => '𐑮𐑲𐑑𐑕';

  @override
  String get wallpaperUseScrollEffect => '𐑿𐑟 𐑕𐑒𐑮𐑴𐑤 𐑦𐑓𐑧𐑒𐑑 𐑪𐑯 𐑣𐑴𐑥 𐑕𐑒𐑮𐑰𐑯';

  @override
  String get tagEditorPageTitle => '𐑧𐑛𐑦𐑑 𐑑𐑨𐑜𐑟';

  @override
  String get tagEditorPageNewTagFieldLabel => '𐑯𐑿 𐑑𐑨𐑜';

  @override
  String get tagEditorPageAddTagTooltip => '𐑨𐑛 𐑑𐑨𐑜';

  @override
  String get tagEditorSectionRecent => '𐑮𐑰𐑕𐑩𐑯𐑑';

  @override
  String get tagEditorSectionPlaceholders => '𐑐𐑤𐑱𐑕𐑣𐑴𐑤𐑛𐑼𐑟';

  @override
  String get tagEditorDiscardDialogMessage => '¿𐑛𐑵 𐑿 𐑢𐑪𐑯𐑑 𐑑 𐑛𐑦𐑕𐑒𐑸𐑛 𐑗𐑱𐑯𐑡𐑩𐑟?';

  @override
  String get tagPlaceholderCountry => '𐑒𐑳𐑯𐑑𐑮𐑦';

  @override
  String get tagPlaceholderState => '𐑕𐑑𐑱𐑑';

  @override
  String get tagPlaceholderPlace => '𐑐𐑤𐑱𐑕';

  @override
  String get panoramaEnableSensorControl => '𐑦𐑯𐑱𐑚𐑩𐑤 𐑕𐑧𐑯𐑕𐑼 𐑒𐑩𐑯𐑑𐑮𐑴𐑤';

  @override
  String get panoramaDisableSensorControl => '𐑛𐑦𐑕𐑱𐑚𐑩𐑤 𐑕𐑧𐑯𐑕𐑼 𐑒𐑩𐑯𐑑𐑮𐑴𐑤';

  @override
  String get sourceViewerPageTitle => '𐑕𐑹𐑕';

  @override
  String get filePickerShowHiddenFiles => '𐑖𐑴 𐑣𐑦𐑛𐑩𐑯 𐑓𐑲𐑤𐑟';

  @override
  String get filePickerDoNotShowHiddenFiles => '𐑛𐑴𐑯\'𐑑 𐑖𐑴 𐑣𐑦𐑛𐑩𐑯 𐑓𐑲𐑤𐑟';

  @override
  String get filePickerOpenFrom => '𐑴𐑐𐑩𐑯 𐑓𐑮𐑪𐑥';

  @override
  String get filePickerNoItems => '𐑯𐑴 𐑲𐑑𐑩𐑥𐑟';

  @override
  String get filePickerUseThisFolder => '𐑿𐑟 𐑞𐑦𐑕 𐑓𐑴𐑤𐑛𐑼';
}
