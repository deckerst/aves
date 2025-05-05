// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kannada (`kn`).
class AppLocalizationsKn extends AppLocalizations {
  AppLocalizationsKn([String locale = 'kn']) : super(locale);

  @override
  String get appName => 'ಎವೀಸ್';

  @override
  String get welcomeMessage => 'ಎವೀಸ್ ಗೆ ಸ್ವಾಗತ';

  @override
  String get welcomeOptional => 'ಐಚ್ಛಿಕ';

  @override
  String get welcomeTermsToggle => 'ನಾನು ನಿಯಮಗಳು ಮತ್ತು ಷರತ್ತುಗಳನ್ನು ಒಪ್ಪುತ್ತೇನೆ';

  @override
  String itemCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString ವಸ್ತುಗಳು',
      one: '$countString ವಸ್ತು',
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
      other: '$countString ಕಂಬಸಾಲುಗಳು',
      one: '$countString ಕಂಬಸಾಲು',
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
      other: '$countString ಕ್ಷಣಗಳು',
      one: '$countString ಕ್ಷಣ',
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
      other: '$countString ನಿಮಿಷಗಳು',
      one: '$countString ನಿಮಿಷ',
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
      other: '$countString ದಿನಗಳು',
      one: '$countString ದಿನ',
    );
    return '$_temp0';
  }

  @override
  String focalLength(String length) {
    return '$length ಮಿಮಿ';
  }

  @override
  String get applyButtonLabel => 'ಅನ್ವಯಿಸು';

  @override
  String get createButtonLabel => 'CREATE';

  @override
  String get deleteButtonLabel => 'ಅಳಿಸಿ';

  @override
  String get nextButtonLabel => 'ಮುಂದೆ';

  @override
  String get showButtonLabel => 'ತೋರಿಸು';

  @override
  String get hideButtonLabel => 'ಅಡಗಿಸು';

  @override
  String get continueButtonLabel => 'ಮುಂದುವರಿಸು';

  @override
  String get saveCopyButtonLabel => 'ನಕಲು ಉಳಿಸಿ';

  @override
  String get applyTooltip => 'ಅನ್ವಯಿಸು';

  @override
  String get cancelTooltip => 'ರದ್ದುಗೊಳಿಸಿ';

  @override
  String get changeTooltip => 'ಬದಲಿಸು';

  @override
  String get clearTooltip => 'ಖಾಲಿ ಮಾಡು';

  @override
  String get previousTooltip => 'ಹಿಂದಿನ';

  @override
  String get nextTooltip => 'ಮುಂದಿನ';

  @override
  String get showTooltip => 'ತೋರಿಸು';

  @override
  String get hideTooltip => 'ಮರೆಮಾಡಿ';

  @override
  String get actionRemove => 'ತೆಗೆದುಹಾಕಿ';

  @override
  String get resetTooltip => 'ರೀಸೆಟ್ ಮಾಡಿ';

  @override
  String get saveTooltip => 'ಉಳಿಸಿ';

  @override
  String get stopTooltip => 'ನಿಲ್ಲಿಸು';

  @override
  String get pickTooltip => 'ಆಯ್ಕೆ';

  @override
  String get doubleBackExitMessage => 'ನಿರ್ಗಮಿಸಲು ಮತ್ತೊಮ್ಮೆ “ಹಿಂದೆ” ಒತ್ತಿ.';

  @override
  String get doNotAskAgain => 'ಇನ್ನೊಮ್ಮೆ ಕೇಳಬೇಡಿ';

  @override
  String get sourceStateLoading => 'ಲೋಡ್ ಆಗುತ್ತಿದೆ';

  @override
  String get sourceStateCataloguing => 'ಪಟ್ಟಿಮಾಡುವುದು';

  @override
  String get sourceStateLocatingCountries => 'ದೇಶಗಳನ್ನು ಪತ್ತೆ ಮಾಡಲಾಗುತ್ತಿದೆ';

  @override
  String get sourceStateLocatingPlaces => 'ಸ್ಥಳಗಳನ್ನು ಪತ್ತೆ ಮಾಡಲಾಗುತ್ತಿದೆ';

  @override
  String get chipActionDelete => 'ಅಳಿಸಿ';

  @override
  String get chipActionRemove => 'ತೆಗೆದುಹಾಕು';

  @override
  String get chipActionShowCollection => 'ಸಂಗ್ರಹದಲ್ಲಿ ತೋರಿಸು';

  @override
  String get chipActionGoToAlbumPage => 'ಆಲ್ಬಮ್‌ಗಳಲ್ಲಿ ತೋರಿಸು';

  @override
  String get chipActionGoToCountryPage => 'ದೇಶಗಳಲ್ಲಿ ತೋರಿಸು';

  @override
  String get chipActionGoToPlacePage => 'ಸ್ಥಳಗಳಲ್ಲಿ ತೋರಿಸು';

  @override
  String get chipActionGoToTagPage => 'Tagಗಳಲ್ಲಿ ತೋರಿಸು';

  @override
  String get chipActionGoToExplorerPage => 'ಪರಿಶೋಧಕದಲ್ಲಿ ತೋರಿಸು';

  @override
  String get chipActionDecompose => 'ವಿಭಜಿಸು';

  @override
  String get chipActionFilterOut => 'ಪ್ರತ್ಯೇಕಿಸು';

  @override
  String get chipActionFilterIn => 'ಶೋಧಿಸು';

  @override
  String get chipActionHide => 'ಅಡಗಿಸು';

  @override
  String get chipActionLock => 'ಬಂಧಿಸು';

  @override
  String get chipActionPin => 'ಮೇಲೆ ಸಿಕ್ಕಿಸು';

  @override
  String get chipActionUnpin => 'ಪಿನ್ ತೆಗೆಯಿರಿ';

  @override
  String get chipActionGroup => 'Group';

  @override
  String get chipActionRename => 'ಮರುನಾಮಕರಣ';

  @override
  String get chipActionSetCover => 'ರಕ್ಷಾಕವಚ ಹೊಂದಿಸು';

  @override
  String get chipActionShowCountryStates => 'ಅಂಕಿಅಂಶಗಳನ್ನು ತೋರಿಸಿ';

  @override
  String get chipActionCreateGroup => 'Create group';

  @override
  String get chipActionCreateAlbum => 'ಆಲ್ಬಮ್ ರಚಿಸಿ';

  @override
  String get chipActionCreateVault => 'ನೆಲಮಾಳಿಗೆ ರಚಿಸಿ';

  @override
  String get chipActionConfigureVault => 'ನೆಲಮಾಳಿಗೆ ಸಂರಚಿಸಿ';

  @override
  String get entryActionCopyToClipboard => 'ಕ್ಲಿಪ್‌ಬೋರ್ಡ್ ಗೆ ನಕಲಿಸಿ';

  @override
  String get entryActionDelete => 'ಅಳಿಸಿ';

  @override
  String get entryActionConvert => 'ಪರಿವರ್ತಿಸಿ';

  @override
  String get entryActionExport => 'ರಫ್ತು';

  @override
  String get entryActionInfo => 'ಮಾಹಿತಿ';

  @override
  String get entryActionRename => 'ಮರುನಾಮಕರಣ';

  @override
  String get entryActionRestore => 'ಮರುಸ್ಥಾಪಿಸಿ';

  @override
  String get entryActionRotateCCW => 'ಅಪ್ರದಕ್ಷಿಣಾಕಾರವಾಗಿ ತಿರುಗಿಸಿ';

  @override
  String get entryActionRotateCW => 'ಪ್ರದಕ್ಷಿಣಾಕಾರವಾಗಿ ತಿರುಗಿಸಿ';

  @override
  String get entryActionFlip => 'ಅಡ್ಡ ಮಗುಚು';

  @override
  String get entryActionPrint => 'ಮುದ್ರಿಸು';

  @override
  String get entryActionShare => 'ಹಂಚಿಕೊಳ್ಳಿ';

  @override
  String get entryActionShareImageOnly => 'ಚಿತ್ರವನ್ನು ಮಾತ್ರ ಹಂಚಿಕೊಳ್ಳಿ';

  @override
  String get entryActionShareVideoOnly => 'ವಿಡಿಯೋವನ್ನು ಮಾತ್ರ ಹಂಚಿಕೊಳ್ಳಿ';

  @override
  String get entryActionViewSource => 'ಮೂಲವನ್ನು ನೋಡಿ';

  @override
  String get entryActionShowGeoTiffOnMap => 'ನಕ್ಷೆಯ ಮೇಲ್ಪದರದಲ್ಲಿ ತೋರಿಸಿ';

  @override
  String get entryActionConvertMotionPhotoToStillImage => 'ಸ್ಥಿರ ಚಿತ್ರವಾಗಿ ಮಾರ್ಪಡಿಸಿ';

  @override
  String get entryActionViewMotionPhotoVideo => 'ವಿಡಿಯೋ ತೆರೆಯಿರಿ';

  @override
  String get entryActionEdit => 'ಸಂಪಾದಿಸಿ';

  @override
  String get entryActionOpen => '..ಇಂದ ತೆರೆಯಿರಿ';

  @override
  String get entryActionSetAs => 'ಇದಾಗಿ ಸೆಟ್ ಮಾಡಿ';

  @override
  String get entryActionCast => 'ಕ್ಯಾಸ್ಟ್';

  @override
  String get entryActionOpenMap => 'ನಕ್ಷೆಯ ಆಪ್ ನಲ್ಲಿ ತೋರಿಸಿ';

  @override
  String get entryActionRotateScreen => 'ಪರದೆಯನ್ನು ತಿರುಗಿಸಿ';

  @override
  String get entryActionAddFavourite => 'ನೆಚ್ಚಿನದಕ್ಕೆ ಸೇರಿಸಿ';

  @override
  String get entryActionRemoveFavourite => 'ನೆಚ್ಚಿನವುಗಳಿಂದ ತೆಗೆಯಿರಿ';

  @override
  String get videoActionCaptureFrame => 'ಫ್ರೇಮ್ ಸೆರೆಹಿಡಿಯಿರಿ';

  @override
  String get videoActionMute => 'ಸದ್ದಡಗಿಸಿ';

  @override
  String get videoActionUnmute => 'ಸದ್ದಾಗಿಸಿ';

  @override
  String get videoActionPause => 'ತಾಳು';

  @override
  String get videoActionPlay => 'ಪ್ಲೇ ಮಾಡಿ';

  @override
  String get videoActionReplay10 => '೧೦ ಕ್ಷಣ ಹಿಂದೆ ಓಡಿಸಿ';

  @override
  String get videoActionSkip10 => '೧೦ ಕ್ಷಣ ಮುಂದೆ ಓಡಿಸಿ';

  @override
  String get videoActionShowPreviousFrame => 'ಹಿಂದಿನ ಫ್ರೇಮ್ ತೋರಿಸಿ';

  @override
  String get videoActionShowNextFrame => 'ಮುಂದಿನ ಫ್ರೇಮ್ ತೋರಿಸಿ';

  @override
  String get videoActionSelectStreams => 'ಟ್ರ್ಯಾಕ್ ಆರಿಸಿ';

  @override
  String get videoActionSetSpeed => 'ಚಲನೆಯ ವೇಗ';

  @override
  String get videoActionABRepeat => 'A-B ಪುನರಾವರ್ತನೆ';

  @override
  String get videoRepeatActionSetStart => 'ಪ್ರಾರಂಭವನ್ನು ಹೊಂದಿಸಿ';

  @override
  String get videoRepeatActionSetEnd => 'ಅಂತ್ಯವನ್ನು ಹೊಂದಿಸಿ';

  @override
  String get viewerActionSettings => 'ಸಂಯೋಜನೆಗಳು';

  @override
  String get viewerActionLock => 'ನೋಟವನ್ನು ಬಂಧಿಸಿ';

  @override
  String get viewerActionUnlock => 'ನೋಟವನ್ನು ಬಿಡುಗಡೆಗೊಳಿಸಿ';

  @override
  String get slideshowActionResume => 'ಪುನರಾರಂಭಿಸಿ';

  @override
  String get slideshowActionShowInCollection => 'ಸಂಗ್ರಹದಲ್ಲಿ ತೋರಿಸಿ';

  @override
  String get entryInfoActionEditDate => 'ದಿನಾಂಕ ಮತ್ತು ಸಮಯವನ್ನು ತಿದ್ದಿ';

  @override
  String get entryInfoActionEditLocation => 'ಸ್ಥಳವನ್ನು ತಿದ್ದಿ';

  @override
  String get entryInfoActionEditTitleDescription => 'ಶೀರ್ಷಿಕೆ ಮತ್ತು ವಿವರಣೆಯನ್ನು ತಿದ್ದಿ';

  @override
  String get entryInfoActionEditRating => 'ಮೌಲ್ಯವನ್ನು ತಿದ್ದಿ';

  @override
  String get entryInfoActionEditTags => 'Tagಗಳನ್ನು ತಿದ್ದಿ';

  @override
  String get entryInfoActionRemoveMetadata => 'metadata ತೆಗೆಯಿರಿ';

  @override
  String get entryInfoActionExportMetadata => 'metadata ರಪ್ತು ಮಾಡಿ';

  @override
  String get entryInfoActionRemoveLocation => 'ಸ್ಥಳದ ವಿವರಗಳನ್ನು ತೆಗೆಯಿರಿ';

  @override
  String get editorActionTransform => 'ರೂಪಾಂತರ';

  @override
  String get editorTransformCrop => 'ಕತ್ತರಿಸು';

  @override
  String get editorTransformRotate => 'ತಿರುಗಿಸು';

  @override
  String get cropAspectRatioFree => 'ಉಚಿತ';

  @override
  String get cropAspectRatioOriginal => 'ಮೂಲ';

  @override
  String get cropAspectRatioSquare => 'ಚೌಕ';

  @override
  String get filterAspectRatioLandscapeLabel => 'ಭೂದೃಶ್ಯ';

  @override
  String get filterAspectRatioPortraitLabel => 'ಭಾವಚಿತ್ರ';

  @override
  String get filterBinLabel => 'ಮರುಬಳಕೆ ತೊಟ್ಟಿ';

  @override
  String get filterFavouriteLabel => 'ಅಚ್ಚುಮೆಚ್ಚು';

  @override
  String get filterNoDateLabel => 'ದಿನಾಂಕವಿಲ್ಲ';

  @override
  String get filterNoAddressLabel => 'ವಿಳಾಸವಿಲ್ಲ';

  @override
  String get filterLocatedLabel => 'ನೆಲೆಗೊಳಿಸಿದ್ದು';

  @override
  String get filterNoLocationLabel => 'ನೆಲೆ ಇಲ್ಲದ್ದು';

  @override
  String get filterNoRatingLabel => 'ಮೌಲ್ಯ ರಹಿತ';

  @override
  String get filterTaggedLabel => 'ಮೌಲ್ಯ ಸಹಿತ';

  @override
  String get filterNoTagLabel => 'ಮೌಲ್ಯವಿಲ್ಲದ್ದು';

  @override
  String get filterNoTitleLabel => 'ಶೀರ್ಷಿಕೆ ರಹಿತ';

  @override
  String get filterOnThisDayLabel => 'ಈ ದಿನದಂದು';

  @override
  String get filterRecentlyAddedLabel => 'ಇತ್ತೀಚಿಗೆ ಸೇರಿಸಿದ್ದು';

  @override
  String get filterRatingRejectedLabel => 'ತಿರಸ್ಕರಿಸಿದ್ದು';

  @override
  String get filterTypeAnimatedLabel => 'ಆನಿಮೇಟೆಡ್';

  @override
  String get filterTypeMotionPhotoLabel => 'ಚಲಿಸುವ ಚಿತ್ರ';

  @override
  String get filterTypePanoramaLabel => 'ಪನೋರಮಾ';

  @override
  String get filterTypeRawLabel => 'Raw';

  @override
  String get filterTypeSphericalVideoLabel => '360° ವಿಡಿಯೋ';

  @override
  String get filterTypeGeotiffLabel => 'GeoTIFF';

  @override
  String get filterMimeImageLabel => 'ಚಿತ್ರ';

  @override
  String get filterMimeVideoLabel => 'ವಿಡಿಯೋ';

  @override
  String get accessibilityAnimationsRemove => 'ಪರದೆಯ ಪರಿಣಾಮಗಳನ್ನು ತಡೆಯಿರಿ';

  @override
  String get accessibilityAnimationsKeep => 'ಪರದೆಯ ಪರಿಣಾಮಗಳನ್ನು ಇರಿಸಿ';

  @override
  String get albumTierNew => 'ಹೊಸ';

  @override
  String get albumTierPinned => 'ಚುಚ್ಚಿರುವುದು';

  @override
  String get albumTierGroups => 'Groups';

  @override
  String get albumTierSpecial => 'ಸಾಮಾನ್ಯ';

  @override
  String get albumTierApps => 'ಅಪ್ಲಿಕೇಶನ್‌ಗಳು';

  @override
  String get albumTierVaults => 'ನೆಲಮಾಳಿಗೆಗಳು';

  @override
  String get albumTierDynamic => 'ಕ್ರಿಯಾಶೀಲ';

  @override
  String get albumTierRegular => 'ಇತರೆ';

  @override
  String get coordinateFormatDms => 'DMS';

  @override
  String get coordinateFormatDdm => 'DDM';

  @override
  String get coordinateFormatDecimal => 'ದಶಮಾಂಶ ಡಿಗ್ರಿಗಳು';

  @override
  String coordinateDms(String coordinate, String direction) {
    return '$coordinate $direction';
  }

  @override
  String get coordinateDmsNorth => 'ಉ';

  @override
  String get coordinateDmsSouth => 'ದ';

  @override
  String get coordinateDmsEast => 'ಪೂ';

  @override
  String get coordinateDmsWest => 'ಪ';

  @override
  String get displayRefreshRatePreferHighest => 'ಗರಿಷ್ಠ ದರ';

  @override
  String get displayRefreshRatePreferLowest => 'ಕನಿಷ್ಠ ದರ';

  @override
  String get keepScreenOnNever => 'ಎಂದಿಗೂ ಇಲ್ಲ';

  @override
  String get keepScreenOnVideoPlayback => 'ವಿಡಿಯೋ ಚಲನೆಯಲ್ಲಿರುವಾಗ';

  @override
  String get keepScreenOnViewerOnly => 'ವೀಕ್ಷಣಾ ಪುಟದಲ್ಲಿ ಮಾತ್ರ';

  @override
  String get keepScreenOnAlways => 'ಯಾವಾಗಲೂ';

  @override
  String get lengthUnitPixel => 'px';

  @override
  String get lengthUnitPercent => '%';

  @override
  String get mapStyleGoogleNormal => 'ಗೂಗಲ್ ನಕಾಶೆಗಳು';

  @override
  String get mapStyleGoogleHybrid => 'ಗೂಗಲ್ ನಕಾಶೆಗಳು (ಹೈಬ್ರಿಡ್)';

  @override
  String get mapStyleGoogleTerrain => 'ಗೂಗಲ್ ನಕಾಶೆಗಳು (ಭೂ ಪ್ರದೇಶ)';

  @override
  String get mapStyleOsmLiberty => 'OSM ಸ್ವಾತಂತ್ರ್ಯ';

  @override
  String get mapStyleOpenTopoMap => 'ಓಪನ್ ಟೊಪೊ ಮ್ಯಾಪ್';

  @override
  String get mapStyleOsmHot => 'ಮಾನವೀಯ OSM';

  @override
  String get mapStyleStamenWatercolor => 'Stamen ಜಲವರ್ಣ';

  @override
  String get maxBrightnessNever => 'ಎಂದಿಗೂ ಇಲ್ಲ';

  @override
  String get maxBrightnessAlways => 'ಯಾವಾಗಲೂ';

  @override
  String get nameConflictStrategyRename => 'ಮರುನಾಮಕರಣ';

  @override
  String get nameConflictStrategyReplace => 'ಬದಲಾಯಿಸು';

  @override
  String get nameConflictStrategySkip => 'ಬಿಟ್ಟುಬಿಡು';

  @override
  String get overlayHistogramNone => 'ಏನಿಲ್ಲ';

  @override
  String get overlayHistogramRGB => 'RGB';

  @override
  String get overlayHistogramLuminance => 'ಪ್ರಕಾಶ';

  @override
  String get subtitlePositionTop => 'ಮೇಲ್ತುದಿ';

  @override
  String get subtitlePositionBottom => 'ಬುಡ';

  @override
  String get themeBrightnessLight => 'ತಿಳಿ ಬಣ್ಣ';

  @override
  String get themeBrightnessDark => 'ಗಾಢ ಬಣ್ಣ';

  @override
  String get themeBrightnessBlack => 'ಕಡುಕಪ್ಪು';

  @override
  String get unitSystemMetric => 'ಮೆಟ್ರಿಕ್';

  @override
  String get unitSystemImperial => 'ಇಂಪೀರಿಯಲ್';

  @override
  String get vaultLockTypePattern => 'ಪ್ಯಾಟರ್ನ್';

  @override
  String get vaultLockTypePin => 'ಪಿನ್';

  @override
  String get vaultLockTypePassword => 'ಕೀಲಿಪದ';

  @override
  String get settingsVideoEnablePip => 'ಚಿತ್ರದೊಳಗಿನ ಚಿತ್ರಣ';

  @override
  String get videoControlsPlayOutside => 'ಇನ್ನೊಂದು ಪ್ಲೇಯರ್ ನಲ್ಲಿ ತೆರೆಯಿರಿ';

  @override
  String get videoLoopModeNever => 'ಇಂದಿಗೂ ಇಲ್ಲ';

  @override
  String get videoLoopModeShortOnly => 'ಚಿಕ್ಕ ವಿಡಿಯೋಗಳನ್ನು ಮಾತ್ರ';

  @override
  String get videoLoopModeAlways => 'ಯಾವಾಗಲೂ';

  @override
  String get videoPlaybackSkip => 'ಬಿಟ್ಟುಬಿಡು';

  @override
  String get videoPlaybackMuted => 'ಶಬ್ದರಹಿತವಾಗಿ ಪ್ಲೇ ಮಾಡಿ';

  @override
  String get videoPlaybackWithSound => 'ಶಬ್ದಸಹಿತವಾಗಿ ಪ್ಲೇ ಮಾಡಿ';

  @override
  String get videoResumptionModeNever => 'ಎಂದಿಗೂ ಇಲ್ಲ';

  @override
  String get videoResumptionModeAlways => 'ಯಾವಾಗಲೂ';

  @override
  String get viewerTransitionSlide => 'ಜಾರಿಸು';

  @override
  String get viewerTransitionParallax => 'ಪ್ಯಾರಾಲಾಕ್ಸ್';

  @override
  String get viewerTransitionFade => 'ಮರೆಯಾಗಿಸು';

  @override
  String get viewerTransitionZoomIn => 'ಹಿಗ್ಗಿಸು';

  @override
  String get viewerTransitionNone => 'ಏನಿಲ್ಲ';

  @override
  String get wallpaperTargetHome => 'ಮುಖ ಪರದೆ';

  @override
  String get wallpaperTargetLock => 'ಲಾಕ್ ಪರದೆ';

  @override
  String get wallpaperTargetHomeLock => 'ಮುಖ ಮತ್ತು ಲಾಕ್ ಪರದೆ';

  @override
  String get widgetDisplayedItemRandom => 'ಇಷ್ಟಬಂದಂತೆ';

  @override
  String get widgetDisplayedItemMostRecent => 'ಅತ್ಯಂತ ಇತ್ತೀಚಿನ';

  @override
  String get widgetOpenPageHome => 'ಮುಖ್ಯಪರದೆ ತೆರೆಯಿರಿ';

  @override
  String get widgetOpenPageCollection => 'ಸಂಗ್ರಹವನ್ನು ತೆರೆಯಿರಿ';

  @override
  String get widgetOpenPageViewer => 'ವೀಕ್ಷಕವನ್ನು ತೆರೆಯಿರಿ';

  @override
  String get widgetTapUpdateWidget => 'ವಿಜೆಟ್ ನವೀಕರಿಸಿ';

  @override
  String get storageVolumeDescriptionFallbackPrimary => 'ಆಂತರಿಕ ಸಂಗ್ರಹಣೆ';

  @override
  String get storageVolumeDescriptionFallbackNonPrimary => 'ಎಸ್ ಡಿ ಕಾರ್ಡ್';

  @override
  String get rootDirectoryDescription => 'ಮೂಲ ಕೋಶ';

  @override
  String otherDirectoryDescription(String name) {
    return '“$name” ಕೋಶ';
  }

  @override
  String storageAccessDialogMessage(String directory, String volume) {
    return 'ಈ ಅಪ್ಲಿಕೇಶನ್‌ಗೆ ಪ್ರವೇಶವನ್ನು ನೀಡಲು ಮುಂದಿನ ಪರದೆಯಲ್ಲಿ “$volume” ದ $directory ಅನ್ನು ಆಯ್ಕೆ ಮಾಡಿ.';
  }

  @override
  String restrictedAccessDialogMessage(String directory, String volume) {
    return '$directory ನ “$volume”ನಲ್ಲಿರುವ ಕಡತಗಳನ್ನು ಮಾರ್ಪಡಿಸಲು ಈ ಅಪ್ಲಿಕೇಶನ್‌ಗೆ ಅನುಮತಿಸಲಾಗಿಲ್ಲ.\n\nದಯವಿಟ್ಟು ವಸ್ತುಗಳನ್ನು ಮತ್ತೊಂದು ಕೋಶಕ್ಕೆ ಸ್ಥಳಾಂತರಿಸಲು ಮೊದಲೇ ಸ್ಥಾಪಿಸಲಾದ ಕಡತ ನಿರ್ವಾಹಕ ಅಥವಾ ಗ್ಯಾಲರಿ ಅಪ್ಲಿಕೇಶನ್ ಬಳಸಿ.';
  }

  @override
  String notEnoughSpaceDialogMessage(String neededSize, String freeSize, String volume) {
    return 'ಈ ಕಾರ್ಯಾಚರಣೆಗೆ ಪೂರ್ಣಗೊಳ್ಳಲು “$volume” ನಲ್ಲಿ $neededSize ಉಚಿತ ಸ್ಥಳಾವಕಾಶದ ಅಗತ್ಯವಿದೆ, ಆದರೆ ಕೇವಲ $freeSize ಮಾತ್ರ ಲಭ್ಯವಿದೆ.';
  }

  @override
  String get missingSystemFilePickerDialogMessage => 'ವ್ಯವಸ್ಥೆಯ ಕಡತ ಆರಿಸುವಿಕೆ ಕಾಣೆಯಾಗಿದೆ ಅಥವಾ ನಿಷ್ಕ್ರಿಯಗೊಳಿಸಲಾಗಿದೆ. ದಯವಿಟ್ಟು ಅದನ್ನು ಸಕ್ರಿಯಗೊಳಿಸಿ ಮತ್ತು ಪುನಃ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String unsupportedTypeDialogMessage(int count, String types) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ಈ ಕಾರ್ಯಾಚರಣೆಯು ಈ ವಿಧದ ವಸ್ತುಗಳಿಗೆ ಬೆಂಬಲಿಸುವುದಿಲ್ಲ: $types.',
      one: 'ಈ ಕಾರ್ಯಾಚರಣೆಯು ಈ ವಿಧದ ವಸ್ತುವಿಗೆ ಬೆಂಬಲಿಸುವುದಿಲ್ಲ: $types.',
    );
    return '$_temp0';
  }

  @override
  String get nameConflictDialogSingleSourceMessage => 'ಗಮ್ಯಸ್ಥಾನ ಕೋಶದಲ್ಲಿರುವ ಕೆಲವು ಕಡತಗಳು ಒಂದೇ ಹೆಸರನ್ನು ಹೊಂದಿವೆ.';

  @override
  String get nameConflictDialogMultipleSourceMessage => 'ಕೆಲವು ಕಡತಗಳು ಒಂದೇ ಹೆಸರನ್ನು ಹೊಂದಿವೆ.';

  @override
  String get addShortcutDialogLabel => 'ಶಾರ್ಟ್ಕಟ್ ಹೆಸರು';

  @override
  String get addShortcutButtonLabel => 'ಸೇರಿಸು';

  @override
  String get noMatchingAppDialogMessage => 'ಇದನ್ನು ನಿಭಾಯಿಸಬಲ್ಲ ಯಾವುದೇ ಅಪ್ಲಿಕೇಶನ್‌ಗಳಿಲ್ಲ.';

  @override
  String binEntriesConfirmationDialogMessage(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString ವಸ್ತುಗಳನ್ನು ಮರುಬಳಕೆ ತೊಟ್ಟಿಗೆ ಸ್ಥಳಾಂತರಿಸುವುದೇ?',
      one: 'ಇದನ್ನು ಮರುಬಳಕೆ ತೊಟ್ಟಿಗೆ ಸ್ಥಳಾಂತರಿಸುವುದೇ?',
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
      other: '$countString ವಸ್ತುಗಳನ್ನು ಅಳಿಸುವುದೇ?',
      one: 'ಇದನ್ನು ಅಳಿಸುವುದೇ?',
    );
    return '$_temp0';
  }

  @override
  String get moveUndatedConfirmationDialogMessage => 'ಮುಂದುವರಿಯುವ ಮೊದಲು ವಸ್ತುವಿನ ದಿನಾಂಕಗಳನ್ನು ಉಳಿಸುವುದೇ?';

  @override
  String get moveUndatedConfirmationDialogSetDate => 'ದಿನಾಂಕಗಳನ್ನು ಉಳಿಸಿ';

  @override
  String videoResumeDialogMessage(String time) {
    return '$timeಕ್ಕೆ ಪುನರಾರಂಭಿಸಲು ನೀವು ಬಯಸುವಿರಾ?';
  }

  @override
  String get videoStartOverButtonLabel => 'ಬುಡದಿಂದ ಪ್ರಾರಂಭಿಸಿ';

  @override
  String get videoResumeButtonLabel => 'ಮುಂದುವರೆಸಿ';

  @override
  String get setCoverDialogLatest => 'ಹೊಚ್ಚಹೊಸ ವಸ್ತುಗಳು';

  @override
  String get setCoverDialogAuto => 'ಸ್ವಯಂಚಾಲಿತ';

  @override
  String get setCoverDialogCustom => 'ಇಚ್ಛಾನುಸಾರ';

  @override
  String get hideFilterConfirmationDialogMessage => 'ಹೊಂದಿಕೆಯ ಚಿತ್ರಗಳನ್ನು ಮತ್ತು ವೀಡಿಯೊಗಳನ್ನು ನಿಮ್ಮ ಸಂಗ್ರಹದಿಂದ ಮರೆಮಾಡಲಾಗುತ್ತದೆ. “ಗೌಪ್ಯತೆ” ಸಂಯೋಜನೆಗಳಿಂದ ನೀವು ಅವುಗಳನ್ನು ಮತ್ತೆ ತೋರಿಸಬಹುದು.\n\nನೀವು ಅವುಗಳನ್ನು ಮರೆಮಾಡಲು ಬಯಸುತ್ತೀರಾ?';

  @override
  String get newAlbumDialogTitle => 'ಹೊಸ ಆಲ್ಬಮ್';

  @override
  String get newAlbumDialogNameLabel => 'ಆಲ್ಬಮ್ ಹೆಸರು';

  @override
  String get newAlbumDialogAlbumAlreadyExistsHelper => 'ಆಲ್ಬಮ್ ಈಗಾಗಲೇ ಅಸ್ತಿತ್ವದಲ್ಲಿದೆ';

  @override
  String get newAlbumDialogNameLabelAlreadyExistsHelper => 'ಕೋಶವು ಈಗಾಗಲೇ ಅಸ್ತಿತ್ವದಲ್ಲಿದೆ';

  @override
  String get newAlbumDialogStorageLabel => 'ಸಂಗ್ರಹಣೆ:';

  @override
  String get newDynamicAlbumDialogTitle => 'ಹೊಸ ಡೈನಾಮಿಕ್ ಆಲ್ಬಮ್';

  @override
  String get dynamicAlbumAlreadyExists => 'ಡೈನಾಮಿಕ್ ಆಲ್ಬಮ್ ಈಗಾಗಲೇ ಅಸ್ತಿತ್ವದಲ್ಲಿದೆ';

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
  String get newVaultWarningDialogMessage => 'ನೆಲಮಾಳಿಗೆಯಲ್ಲಿನ ವಸ್ತುಗಳು ಈ ಅಪ್ಲಿಕೇಶನ್‌ನಲ್ಲಿ ಮಾತ್ರ ಲಭ್ಯವಿದೆ ಮತ್ತು ಇತರ ಅಪ್ಲಿಕೇಶನ್‌ಗಳಲ್ಲಿ ಇರುವುದಿಲ್ಲ.\n\nನೀವು ಈ ಅಪ್ಲಿಕೇಶನ್ ನನ್ನು ಅಸ್ಥಾಪಿಸಿದರೆ ಅಥವಾ ಈ ಅಪ್ಲಿಕೇಶನ್ ದತ್ತಾಂಶಗಳನ್ನು ತೆರವುಗೊಳಿಸಿದರೆ, ನೀವು ಈ ಎಲ್ಲ ವಸ್ತುಗಳನ್ನು ಕಳೆದುಕೊಳ್ಳುತ್ತೀರಿ.';

  @override
  String get newVaultDialogTitle => 'ಹೊಸ ನೆಲಮಾಳಿಗೆ';

  @override
  String get configureVaultDialogTitle => 'ನೆಲಮಾಳಿಗೆಯನ್ನು ಸಂರಚಿಸಿ';

  @override
  String get vaultDialogLockModeWhenScreenOff => 'ಪರದೆ ಬಂದಾದಾಗ ಲಾಕ್ ಮಾಡಿ';

  @override
  String get vaultDialogLockTypeLabel => 'ಲಾಕ್ ವಿಧ';

  @override
  String get patternDialogEnter => 'ಪ್ಯಾಟರ್ನ್ ನಮೂದಿಸಿ';

  @override
  String get patternDialogConfirm => 'ಪ್ಯಾಟರ್ನ್ ಖಚಿತಪಡಿಸಿ';

  @override
  String get pinDialogEnter => 'PIN ನಮೂದಿಸಿ';

  @override
  String get pinDialogConfirm => 'PIN ಖಚಿತಪಡಿಸಿ';

  @override
  String get passwordDialogEnter => 'ಕೀಲಿಪದ ನಮೂದಿಸಿ';

  @override
  String get passwordDialogConfirm => 'ಕೀಲಿಪದ ಖಚಿತಪಡಿಸಿ';

  @override
  String get authenticateToConfigureVault => 'ನೆಲಮಾಳಿಗೆಯನ್ನು ಸಂರಚಿಸಲು ಧೃಡೀಕರಿಸಿ';

  @override
  String get authenticateToUnlockVault => 'ನೆಲಮಾಳಿಗೆಯ ಲಾಕ್ ತೆಗೆಯಲು ಧೃಡೀಕರಿಸಿ';

  @override
  String get vaultBinUsageDialogMessage => 'ಕೆಲವು ನೆಲಮಾಳಿಗೆಗಳು ಮರುಬಳಕೆ ತೊಟ್ಟಿಯನ್ನು ಬಳಸುತ್ತಿವೆ.';

  @override
  String get renameAlbumDialogLabel => 'ಹೊಸ ಹೆಸರು';

  @override
  String get renameAlbumDialogLabelAlreadyExistsHelper => 'ಕೋಶವು ಈಗಾಗಲೇ ಅಸ್ತಿತ್ವದಲ್ಲಿದೆ';

  @override
  String get renameEntrySetPageTitle => 'ಮರುಹೆಸರಿಸಿ';

  @override
  String get renameEntrySetPagePatternFieldLabel => 'ಹೆಸರಿಸುವ ಮಾದರಿ';

  @override
  String get renameEntrySetPageInsertTooltip => 'ಕ್ಷೇತ್ರವನ್ನು ಸೇರಿಸಿ';

  @override
  String get renameEntrySetPagePreviewSectionTitle => 'ಮುನ್ನೋಟ';

  @override
  String get renameProcessorCounter => 'ಗಣಕ';

  @override
  String get renameProcessorHash => 'ಹ್ಯಾಷ್';

  @override
  String get renameProcessorName => 'ಹೆಸರು';

  @override
  String deleteSingleAlbumConfirmationDialogMessage(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ಈ ಆಲ್ಬಮ್ ಮತ್ತು ಅದರಲ್ಲಿರುವ $countString ವಸ್ತುಗಳನ್ನು ಅಳಿಸುವುದೇ?',
      one: 'ಈ ಆಲ್ಬಮ್ ಮತ್ತು ಅದರಲ್ಲಿರುವ ವಸ್ತುವನ್ನು ಅಳಿಸುವುದೇ?',
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
      other: 'ಈ ಆಲ್ಬಮ್ ಗಳನ್ನು ಮತ್ತು ಅದರಲ್ಲಿರುವ $countString ವಸ್ತುಗಳನ್ನು ಅಳಿಸುವುದೇ?',
      one: 'ಈ ಆಲ್ಬಮ್ ಗಳನ್ನು ಮತ್ತು ಅದರಲ್ಲಿರುವ ವಸ್ತುವನ್ನು ಅಳಿಸುವುದೇ?',
    );
    return '$_temp0';
  }

  @override
  String get exportEntryDialogFormat => 'ಸ್ವರೂಪ:';

  @override
  String get exportEntryDialogWidth => 'ಅಗಲ';

  @override
  String get exportEntryDialogHeight => 'ಎತ್ತರ';

  @override
  String get exportEntryDialogQuality => 'ಗುಣಮಟ್ಟ';

  @override
  String get exportEntryDialogWriteMetadata => 'ಮೆಟಾಡೇಟಾ ಬರೆಯಿರಿ';

  @override
  String get renameEntryDialogLabel => 'ಹೊಸ ಹೆಸರು';

  @override
  String get editEntryDialogCopyFromItem => 'ಇತರ ವಸ್ತುವಿನಿಂದ ನಕಲಿಸಿ';

  @override
  String get editEntryDialogTargetFieldsHeader => 'ಮಾರ್ಪಡಿಸುವ ಕ್ಷೇತ್ರಗಳು';

  @override
  String get editEntryDateDialogTitle => 'ದಿನಾಂಕ ಮತ್ತು ಸಮಯ';

  @override
  String get editEntryDateDialogSetCustom => 'ನಿಗದಿತ ದಿನಾಂಕವನ್ನು ಹೊಂದಿಸಿ';

  @override
  String get editEntryDateDialogCopyField => 'ಬೇರೆಯ ದಿನಾಂಕದಿಂದ ನಕಲಿಸಿ';

  @override
  String get editEntryDateDialogExtractFromTitle => 'ಶೀರ್ಷಿಕೆಯಿಂದ ಆಯ್ದು ತೆಗೆಯಿರಿ';

  @override
  String get editEntryDateDialogShift => 'ಸ್ಥಳಾಂತರಿಸು';

  @override
  String get editEntryDateDialogSourceFileModifiedDate => 'ಕಡತ ಮಾರ್ಪಡಿಸಿದ ದಿನಾಂಕ';

  @override
  String get durationDialogHours => 'ಘಂಟೆಗಳು';

  @override
  String get durationDialogMinutes => 'ನಿಮಿಷಗಳು';

  @override
  String get durationDialogSeconds => 'ಕ್ಷಣಗಳು';

  @override
  String get editEntryLocationDialogTitle => 'ಸ್ಥಳ';

  @override
  String get editEntryLocationDialogSetCustom => 'ನಿಗದಿತ ಸ್ಥಳವನ್ನು ಹೊಂದಿಸಿ';

  @override
  String get editEntryLocationDialogChooseOnMap => 'ನಕ್ಷೆಯಲ್ಲಿ ಆರಿಸಿ';

  @override
  String get editEntryLocationDialogImportGpx => 'ಜಿಪಿಎಕ್ಸ್ ಆಮದು ಮಾಡಿ';

  @override
  String get editEntryLocationDialogLatitude => 'ಅಕ್ಷಾಂಶ';

  @override
  String get editEntryLocationDialogLongitude => 'ರೇಖಾಂಶ';

  @override
  String get editEntryLocationDialogTimeShift => 'ಸಮಯ ಸ್ಥಳಾಂತರ';

  @override
  String get locationPickerUseThisLocationButton => 'ಈ ಸ್ಥಳವನ್ನು ಬಳಸಿ';

  @override
  String get editEntryRatingDialogTitle => 'ರೇಟಿಂಗ್';

  @override
  String get removeEntryMetadataDialogTitle => 'ಮೆಟಾಡೇಟಾ ತೆಗೆಯುವಿಕೆ';

  @override
  String get removeEntryMetadataDialogAll => 'ಎಲ್ಲವೂ';

  @override
  String get removeEntryMetadataDialogMore => 'ಇನ್ನಷ್ಟು';

  @override
  String get removeEntryMetadataMotionPhotoXmpWarningDialogMessage => 'ಚಲನೆಯ ಚಿತ್ರದ ಒಳಗೆ ವೀಡಿಯೊವನ್ನು ಚಾಲನೆ ಮಾಡಲು XMP ಅಗತ್ಯವಿದೆ.\n\nನೀವು ಅದನ್ನು ತೆಗೆದುಹಾಕಲು ಬಯಸುತ್ತೀರಾ?';

  @override
  String get videoSpeedDialogLabel => 'ಚಾಲನೆಯ ವೇಗ';

  @override
  String get videoStreamSelectionDialogVideo => 'ವಿಡಿಯೋ';

  @override
  String get videoStreamSelectionDialogAudio => 'ಆಡಿಯೋ';

  @override
  String get videoStreamSelectionDialogText => 'ಅಡಿಬರಹ';

  @override
  String get videoStreamSelectionDialogOff => 'ನಂದಿಸು';

  @override
  String get videoStreamSelectionDialogTrack => 'ಜಾಡು';

  @override
  String get videoStreamSelectionDialogNoSelection => 'ಬೇರೆ ಯಾವುದೇ ಹಾಡುಗಳಿಲ್ಲ.';

  @override
  String get genericSuccessFeedback => 'ಮುಗಿದಿದೆ!';

  @override
  String get genericFailureFeedback => 'ವಿಫಲವಾಗಿದೆ';

  @override
  String get genericDangerWarningDialogMessage => 'ನೀವು ಖಚಿತಪಡಿಸುವಿರೇ?';

  @override
  String get tooManyItemsErrorDialogMessage => 'ಕಡಿಮೆ ವಸ್ತುಗಳೊಂದಿಗೆ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get menuActionConfigureView => 'ನೋಟ';

  @override
  String get menuActionSelect => 'ಆರಿಸು';

  @override
  String get menuActionSelectAll => 'ಎಲ್ಲವನ್ನು ಆರಿಸು';

  @override
  String get menuActionSelectNone => 'ಏನನ್ನು ಆರಿಸಬೇಡಿ';

  @override
  String get menuActionMap => 'ನಕ್ಷೆ';

  @override
  String get menuActionSlideshow => 'ಸ್ಲೈಡ್ ಶೋ';

  @override
  String get menuActionStats => 'ಅಂಕಿಅಂಶಗಳು';

  @override
  String get viewDialogSortSectionTitle => 'ವಿಂಗಡಿಸಿ';

  @override
  String get viewDialogGroupSectionTitle => 'ಗುಂಪು';

  @override
  String get viewDialogLayoutSectionTitle => 'ವಿನ್ಯಾಸ';

  @override
  String get viewDialogReverseSortOrder => 'ಹಿಮ್ಮುಖ ವಿಂಗಡಣೆ ಕ್ರಮ';

  @override
  String get tileLayoutMosaic => 'ಮೊಸಾಯಿಕ್';

  @override
  String get tileLayoutGrid => 'ಜಾಲ';

  @override
  String get tileLayoutList => 'ಪಟ್ಟಿ';

  @override
  String get castDialogTitle => 'ಬಿತ್ತರಿಸುವ ಸಾಧನಗಳು';

  @override
  String get coverDialogTabCover => 'ರಕ್ಷಾಕವಚ';

  @override
  String get coverDialogTabApp => 'ಅಪ್ಲಿಕೇಶನ್';

  @override
  String get coverDialogTabColor => 'ವರ್ಣ';

  @override
  String get appPickDialogTitle => 'ಅಪ್ಲಿಕೇಶನ್ ಆರಿಸಿ';

  @override
  String get appPickDialogNone => 'ಏನಿಲ್ಲ';

  @override
  String get aboutPageTitle => 'ಕುರಿತು';

  @override
  String get aboutLinkLicense => 'ಪರವಾನಗಿ';

  @override
  String get aboutLinkPolicy => 'ಗೌಪ್ಯತೆ ನೀತಿ';

  @override
  String get aboutBugSectionTitle => 'ದೋಷದ ವರದಿ';

  @override
  String get aboutBugSaveLogInstruction => 'ಅಪ್ಲಿಕೇಶನ್ ದಾಖಲೆಗಳನ್ನು ಕಡತಕ್ಕೆ ಉಳಿಸಿ';

  @override
  String get aboutBugCopyInfoInstruction => 'ಸಾಧನದ ಮಾಹಿತಿಯನ್ನು ನಕಲಿಸಿ';

  @override
  String get aboutBugCopyInfoButton => 'ನಕಲಿಸಿ';

  @override
  String get aboutBugReportInstruction => 'ದಾಖಲೆಗಳು ಮತ್ತು ಸಾಧನದ ಮಾಹಿತಿಯ ಜೊತೆಗೆ Githubನಲ್ಲಿ ವರದಿ ಮಾಡಿ';

  @override
  String get aboutBugReportButton => 'ವರದಿ';

  @override
  String get aboutDataUsageSectionTitle => 'ದತ್ತಾಂಶ ಬಳಕೆ';

  @override
  String get aboutDataUsageData => 'ದತ್ತಾಂಶ';

  @override
  String get aboutDataUsageCache => 'ತಾತ್ಕಾಲಿಕ ಸಂಗ್ರಹ';

  @override
  String get aboutDataUsageDatabase => 'ದತ್ತಾಂಶ ಸಂಚಯ';

  @override
  String get aboutDataUsageMisc => 'ನಾನಾ ರೀತಿಯ';

  @override
  String get aboutDataUsageInternal => 'ಆಂತರಿಕ';

  @override
  String get aboutDataUsageExternal => 'ಬಾಹ್ಯ';

  @override
  String get aboutDataUsageClearCache => 'ಕ್ಯಾಶೆ ಸಂಗ್ರಹ ಅಳಿಸಿ';

  @override
  String get aboutCreditsSectionTitle => 'ಮನ್ನಣೆಗಳು';

  @override
  String get aboutCreditsWorldAtlas1 => 'ಈ ಅಪ್ಲಿಕೇಶನ್ TopoJSON ಕಡತವನ್ನು ಇವರಿಂದ ಬಳಸುತ್ತದೆ';

  @override
  String get aboutCreditsWorldAtlas2 => 'ISC ಪರವಾನಗಿ ಅಡಿಯಲ್ಲಿ.';

  @override
  String get aboutTranslatorsSectionTitle => 'ಅನುವಾದಕರು';

  @override
  String get aboutLicensesSectionTitle => 'ಮುಕ್ತ-ಮೂಲ ಪರವಾನಗಿಗಳು';

  @override
  String get aboutLicensesBanner => 'ಈ ಅಪ್ಲಿಕೇಶನ್ ಈ ಕೆಳಗಿನ ಮುಕ್ತ-ಮೂಲ ಪೊಟ್ಟಣಗಳು ಮತ್ತು ಭಂಡಾರಗಳನ್ನು ಬಳಸುತ್ತದೆ.';

  @override
  String get aboutLicensesAndroidLibrariesSectionTitle => 'ಆಂಡ್ರಾಯ್ಡ್ ಭಂಡಾರಗಳು';

  @override
  String get aboutLicensesFlutterPluginsSectionTitle => 'ಫ್ಲಟರ್ ಪ್ಲಗಿನ್‌ಗಳು';

  @override
  String get aboutLicensesFlutterPackagesSectionTitle => 'ಫ್ಲಟರ್ ಪ್ಯಾಕೇಜುಗಳು';

  @override
  String get aboutLicensesDartPackagesSectionTitle => 'ಡಾರ್ಟ್ ಪ್ಯಾಕೇಜುಗಳು';

  @override
  String get aboutLicensesShowAllButtonLabel => 'ಎಲ್ಲಾ ಪರವಾನಗಿಗಳನ್ನು ತೋರಿಸಿ';

  @override
  String get policyPageTitle => 'ಗೌಪ್ಯತೆ ನೀತಿ';

  @override
  String get collectionPageTitle => 'ಸಂಗ್ರಹ';

  @override
  String get collectionPickPageTitle => 'ಆರಿಸಿ';

  @override
  String get collectionSelectPageTitle => 'ವಸ್ತುಗಳನ್ನು ಆರಿಸಿ';

  @override
  String get collectionActionShowTitleSearch => 'ಶೀರ್ಷಿಕೆ ಸೋಸುಕ ತೋರಿಸಿ';

  @override
  String get collectionActionHideTitleSearch => 'ಶೀರ್ಷಿಕೆ ಸೋಸುಕ ಅಡಗಿಸಿ';

  @override
  String get collectionActionAddDynamicAlbum => 'ಡೈನಾಮಿಕ್ ಆಲ್ಬಮ್ ಸೇರಿಸಿ';

  @override
  String get collectionActionAddShortcut => 'ಶಾರ್ಟ್‌ಕಟ್ ಸೇರಿಸಿ';

  @override
  String get collectionActionSetHome => 'ಮುಖಪುಟವಾಗಿ ಹೊಂದಿಸಿ';

  @override
  String get collectionActionEmptyBin => 'ತೊಟ್ಟಿಯನ್ನು ಖಾಲಿಮಾಡಿ';

  @override
  String get collectionActionCopy => 'ಆಲ್ಬಮ್‌ಗೆ ನಕಲಿಸಿ';

  @override
  String get collectionActionMove => 'ಆಲ್ಬಮ್‌ಗೆ ಸರಿಸಿ';

  @override
  String get collectionActionRescan => 'ಪುನಃ ಸ್ಕ್ಯಾನ್ ಮಾಡಿ';

  @override
  String get collectionActionEdit => 'ಸಂಪಾದಿಸು';

  @override
  String get collectionSearchTitlesHintText => 'ಶೀರ್ಷಿಕೆಗಳನ್ನು ಹುಡುಕಿ';

  @override
  String get collectionGroupAlbum => 'ಆಲ್ಬಮ್ ನಂತೆ';

  @override
  String get collectionGroupMonth => 'ತಿಂಗಳಿನಂತೆ';

  @override
  String get collectionGroupDay => 'ದಿನದಂತೆ';

  @override
  String get sectionNone => 'No sections';

  @override
  String get sectionUnknown => 'ಅಜ್ಞಾತ';

  @override
  String get dateToday => 'ಇಂದು';

  @override
  String get dateYesterday => 'ನಿನ್ನೆ';

  @override
  String get dateThisMonth => 'ಈ ತಿಂಗಳು';

  @override
  String collectionDeleteFailureFeedback(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString ವಸ್ತುಗಳನ್ನು ಅಳಿಸಲು ವಿಫಲವಾಗಿದೆ',
      one: '1 ವಸ್ತುವನ್ನು ಅಳಿಸಲು ವಿಫಲವಾಗಿದೆ',
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
      other: '$countString ವಸ್ತುಗಳನ್ನು ನಕಲಿಸಲು ವಿಫಲವಾಗಿದೆ',
      one: '1 ವಸ್ತುವನ್ನು ನಕಲಿಸಲು ವಿಫಲವಾಗಿದೆ',
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
      other: '$countString ವಸ್ತುಗಳನ್ನು ಸ್ಥಳಾಂತರಿಸಲು ವಿಫಲವಾಗಿದೆ',
      one: '1 ವಸ್ತುವನ್ನು ಸ್ಥಳಾಂತರಿಸಲು ವಿಫಲವಾಗಿದೆ',
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
      other: '$countString ವಸ್ತುಗಳನ್ನು ಮರುಹೆಸರಿಸಲು ವಿಫಲವಾಗಿದೆ',
      one: '1 ವಸ್ತುವನ್ನು ಮರುಹೆಸರಿಸಲು ವಿಫಲವಾಗಿದೆ',
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
      other: '$countString ವಸ್ತುಗಳನ್ನು ಸಂಪಾದಿಸಲು ವಿಫಲವಾಗಿದೆ',
      one: '1 ವಸ್ತುವನ್ನು ಸಂಪಾದಿಸಲು ವಿಫಲವಾಗಿದೆ',
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
      other: '$countString ಪುಟಗಳನ್ನು ರಫ್ತು ಮಾಡಲು ವಿಫಲವಾಗಿದೆ',
      one: '1 ಪುಟವನ್ನು ರಫ್ತು ಮಾಡಲು ವಿಫಲವಾಗಿದೆ',
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
      other: '$countString ವಸ್ತುಗಳನ್ನು ನಕಲಿಸಲಾಗಿದೆ',
      one: '1 ವಸ್ತುವನ್ನು ನಕಲಿಸಲಾಗಿದೆ',
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
      other: '$countString ವಸ್ತುಗಳನ್ನು ಸ್ಥಳಾಂತರಿಸಲಾಗಿದೆ',
      one: '1 ವಸ್ತುವನ್ನು ಸ್ಥಳಾಂತರಿಸಲಾಗಿದೆ',
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
      other: '$countString ವಸ್ತುಗಳನ್ನು ಮರುಹೆಸರಿಸಲಾಗಿದೆ',
      one: '1 ವಸ್ತುವನ್ನು ಮರುಹೆಸರಿಸಲಾಗಿದೆ',
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
      other: '$countString ವಸ್ತುಗಳನ್ನು ಸಂಪಾದಿಸಲಾಗಿದೆ',
      one: '1 ವಸ್ತುವನ್ನು ಸಂಪಾದಿಸಲಾಗಿದೆ',
    );
    return '$_temp0';
  }

  @override
  String get collectionEmptyFavourites => 'ಮೆಚ್ಚಿನವುಗಳಿಲ್ಲ';

  @override
  String get collectionEmptyVideos => 'ವೀಡಿಯೊಗಳಿಲ್ಲ';

  @override
  String get collectionEmptyImages => 'ಚಿತ್ರಗಳಿಲ್ಲ';

  @override
  String get collectionEmptyGrantAccessButtonLabel => 'ಪ್ರವೇಶವನ್ನು ನೀಡಿ';

  @override
  String get collectionSelectSectionTooltip => 'ವಿಭಾಗವನ್ನು ಆಯ್ಕೆಮಾಡಿ';

  @override
  String get collectionDeselectSectionTooltip => 'ವಿಭಾಗ ಆಯ್ಕೆ ರದ್ದುಮಾಡಿ';

  @override
  String get drawerAboutButton => 'ಕುರಿತು';

  @override
  String get drawerSettingsButton => 'ಸಂಯೋಜನೆಗಳು';

  @override
  String get drawerCollectionAll => 'ಎಲ್ಲಾ ಸಂಗ್ರಹ';

  @override
  String get drawerCollectionFavourites => 'ಮೆಚ್ಚಿನವುಗಳು';

  @override
  String get drawerCollectionImages => 'ಚಿತ್ರಗಳು';

  @override
  String get drawerCollectionVideos => 'ವೀಡಿಯೊಗಳು';

  @override
  String get drawerCollectionAnimated => 'ಅನಿಮೇಟೆಡ್';

  @override
  String get drawerCollectionMotionPhotos => 'ಚಲಿಸುವ ಚಿತ್ರಗಳು';

  @override
  String get drawerCollectionPanoramas => 'ಪನೋರಮಾಗಳು';

  @override
  String get drawerCollectionRaws => 'Raw ಚಿತ್ರಗಳು';

  @override
  String get drawerCollectionSphericalVideos => '360° ವಿಡಿಯೋಗಳು';

  @override
  String get drawerAlbumPage => 'ಆಲ್ಬಮ್ ಗಳು';

  @override
  String get drawerCountryPage => 'ದೇಶಗಳು';

  @override
  String get drawerPlacePage => 'ಸ್ಥಳಗಳು';

  @override
  String get drawerTagPage => 'ಟ್ಯಾಗುಗಳು';

  @override
  String get sortByDate => 'ದಿನಾಂಕದಂತೆ';

  @override
  String get sortByName => 'ಹೆಸರಿನಂತೆ';

  @override
  String get sortByItemCount => 'ವಸ್ತುಗಳ ಎಣಿಕೆಯಂತೆ';

  @override
  String get sortBySize => 'ಗಾತ್ರದಂತೆ';

  @override
  String get sortByAlbumFileName => 'ಆಲ್ಬಮ್ ಮತ್ತು ಕಡತದ ಹೆಸರಿನಂತೆ';

  @override
  String get sortByRating => 'ದರದಂತೆ';

  @override
  String get sortByDuration => 'ಅವಧಿಯಂತೆ';

  @override
  String get sortByPath => 'By path';

  @override
  String get sortOrderNewestFirst => 'ಹೊಸದು ಮೊದಲು';

  @override
  String get sortOrderOldestFirst => 'ಹಳೆಯದು ಮೊದಲು';

  @override
  String get sortOrderAtoZ => 'ವರ್ಣಮಾಲೆಯಂತೆ (A to Z)';

  @override
  String get sortOrderZtoA => 'ವರ್ಣಮಾಲೆಯ ವಿರುದ್ಧವಾಗಿ (Z to A)';

  @override
  String get sortOrderHighestFirst => 'ಹೆಚ್ಚಿನದು ಮೊದಲು';

  @override
  String get sortOrderLowestFirst => 'ಕಡಿಮೆಯದು ಮೊದಲು';

  @override
  String get sortOrderLargestFirst => 'ದೊಡ್ಡದು ಮೊದಲು';

  @override
  String get sortOrderSmallestFirst => 'ಚಿಕ್ಕದು ಮೊದಲು';

  @override
  String get sortOrderShortestFirst => 'ಗಿಡ್ಡದ್ದು ಮೊದಲು';

  @override
  String get sortOrderLongestFirst => 'ಉದ್ದದ್ದು ಮೊದಲು';

  @override
  String get albumGroupTier => 'ಶ್ರೇಣಿಯಂತೆ';

  @override
  String get albumGroupType => 'ಪ್ರಕಾರದಂತೆ';

  @override
  String get albumGroupVolume => 'ಸಂಗ್ರಹಣೆಯ ಗಾತ್ರದಂತೆ';

  @override
  String get albumMimeTypeMixed => 'ಮಿಶ್ರಿತ';

  @override
  String get albumPickPageTitleCopy => 'ಆಲ್ಬಮ್‌ಗೆ ನಕಲಿಸಿ';

  @override
  String get albumPickPageTitleExport => 'ಆಲ್ಬಮ್‌ಗೆ ರಫ್ತು ಮಾಡಿ';

  @override
  String get albumPickPageTitleMove => 'ಆಲ್ಬಮ್‌ಗೆ ಸ್ಥಳಾಂತರಿಸಿ';

  @override
  String get albumPickPageTitlePick => 'ಆಲ್ಬಮ್ ಆಯ್ಕೆಮಾಡಿ';

  @override
  String get albumCamera => 'ಕ್ಯಾಮೆರಾ';

  @override
  String get albumDownload => 'ಇಳಿಸು';

  @override
  String get albumScreenshots => 'ಸ್ಕ್ರೀನ್‌ಶಾಟ್‌ಗಳು';

  @override
  String get albumScreenRecordings => 'ಪರದೆ ಮುದ್ರಿಕೆಗಳು';

  @override
  String get albumVideoCaptures => 'ವಿಡಿಯೋ ಕೈಸೆರೆಗಳು';

  @override
  String get albumPageTitle => 'ಆಲ್ಬಮ್ ಗಳು';

  @override
  String get albumEmpty => 'ಆಲ್ಬಮ್‌ಗಳಿಲ್ಲ';

  @override
  String get createAlbumButtonLabel => 'ರಚಿಸು';

  @override
  String get newFilterBanner => 'ಹೊಸ';

  @override
  String get countryPageTitle => 'ದೇಶಗಳು';

  @override
  String get countryEmpty => 'ದೇಶಗಳಿಲ್ಲ';

  @override
  String get statePageTitle => 'ರಾಜ್ಯಗಳು';

  @override
  String get stateEmpty => 'ರಾಜ್ಯಗಳಿಲ್ಲ';

  @override
  String get placePageTitle => 'ಸ್ಥಳಗಳು';

  @override
  String get placeEmpty => 'ಸ್ಥಳಗಳಿಲ್ಲ';

  @override
  String get tagPageTitle => 'ಟ್ಯಾಗುಗಳು';

  @override
  String get tagEmpty => 'ಟ್ಯಾಗುಗಳಿಲ್ಲ';

  @override
  String get binPageTitle => 'ಮರುಬಳಕೆ ತೊಟ್ಟಿ';

  @override
  String get explorerPageTitle => 'ಪರಿಶೋಧಕ';

  @override
  String get explorerActionSelectStorageVolume => 'ಸಂಗ್ರಹಣೆ ಆಯ್ಕೆ ಮಾಡಿ';

  @override
  String get selectStorageVolumeDialogTitle => 'ಸಂಗ್ರಹಣೆ ಆಯ್ಕೆ ಮಾಡಿ';

  @override
  String get searchCollectionFieldHint => 'ಸಂಗ್ರಹದಲ್ಲಿ ಹುಡುಕಿ';

  @override
  String get searchRecentSectionTitle => 'ಇತ್ತೀಚಿನವು';

  @override
  String get searchDateSectionTitle => 'ದಿನಾಂಕ';

  @override
  String get searchFormatSectionTitle => 'Formats';

  @override
  String get searchAlbumsSectionTitle => 'ಆಲ್ಬಮ್ ಗಳು';

  @override
  String get searchCountriesSectionTitle => 'ದೇಶಗಳು';

  @override
  String get searchStatesSectionTitle => 'ರಾಜ್ಯಗಳು';

  @override
  String get searchPlacesSectionTitle => 'ಸ್ಥಳಗಳು';

  @override
  String get searchTagsSectionTitle => 'ಟ್ಯಾಗುಗಳು';

  @override
  String get searchRatingSectionTitle => 'ದರಗಳು';

  @override
  String get searchMetadataSectionTitle => 'ಮೆಟಾಡೇಟಾ';

  @override
  String get settingsPageTitle => 'ಸಂಯೋಜನೆಗಳು';

  @override
  String get settingsSystemDefault => 'ಸಿಸ್ಟಮ್ ಡೀಫಾಲ್ಟ್';

  @override
  String get settingsDefault => 'ಡೀಫಾಲ್ಟ್';

  @override
  String get settingsDisabled => 'ನಿಷ್ಕ್ರಿಯಗೊಳಿಸಲಾಗಿದೆ';

  @override
  String get settingsAskEverytime => 'ಪ್ರತಿಬಾರಿಯೂ ಕೇಳಿ';

  @override
  String get settingsModificationWarningDialogMessage => 'ಇತರ ಸಂಯೋಜನೆಗಳನ್ನು ಮಾರ್ಪಡಿಸಲಾಗುತ್ತದೆ.';

  @override
  String get settingsSearchFieldLabel => 'ಸಂಯೋಜನೆಗಳಲ್ಲಿ ಹುಡುಕಿ';

  @override
  String get settingsSearchEmpty => 'ಹೊಂದುವ ಸಂಯೋಜನೆಗಳಿಲ್ಲ';

  @override
  String get settingsActionExport => 'ರಫ್ತು';

  @override
  String get settingsActionExportDialogTitle => 'ರಫ್ತು';

  @override
  String get settingsActionImport => 'ಆಮದು';

  @override
  String get settingsActionImportDialogTitle => 'ಆಮದು';

  @override
  String get appExportCovers => 'ರಕ್ಷಾಕವಚಗಳು';

  @override
  String get appExportDynamicAlbums => 'ಡೈನಾಮಿಕ್ ಆಲ್ಬಮ್ ಗಳು';

  @override
  String get appExportFavourites => 'ಮೆಚ್ಚಿನವುಗಳು';

  @override
  String get appExportSettings => 'ಸಂಯೋಜನೆಗಳು';

  @override
  String get settingsNavigationSectionTitle => 'ಸಂಚಾರ';

  @override
  String get settingsHomeTile => 'ಮುಖಪುಟ';

  @override
  String get settingsHomeDialogTitle => 'ಮುಖಪುಟ';

  @override
  String get setHomeCustom => 'ಇಚ್ಛಾನುಸಾರ';

  @override
  String get settingsShowBottomNavigationBar => 'ಕೆಳಗಿನ ಸಂಚಾರಪಟ್ಟೆಯನ್ನು ತೋರಿಸಿ';

  @override
  String get settingsKeepScreenOnTile => 'ಪರದೆಯನ್ನು ಚಾಲೂ ಇಡಿ';

  @override
  String get settingsKeepScreenOnDialogTitle => 'ಪರದೆಯನ್ನು ಚಾಲೂ ಇಡಿ';

  @override
  String get settingsDoubleBackExit => 'ನಿರ್ಗಮಿಸಲು “ಹಿಂದೆ” ಎರಡು ಬಾರಿ ತಟ್ಟಿ';

  @override
  String get settingsConfirmationTile => 'ದೃಢೀಕರಣ ಸಂವಾದಗಳು';

  @override
  String get settingsConfirmationDialogTitle => 'ದೃಢೀಕರಣ ಸಂವಾದಗಳು';

  @override
  String get settingsConfirmationBeforeDeleteItems => 'ವಸ್ತುಗಳನ್ನು ಶಾಶ್ವತವಾಗಿ ಅಳಿಸುವ ಮೊದಲು ವಿಚಾರಿಸಿ';

  @override
  String get settingsConfirmationBeforeMoveToBinItems => 'ವಸ್ತುಗಳನ್ನು ಮರುಬಳಕೆ ತೊಟ್ಟಿಗೆ ಸ್ಥಳಾಂತರಿಸುವ ಮೊದಲು ವಿಚಾರಿಸಿ';

  @override
  String get settingsConfirmationBeforeMoveUndatedItems => 'ದಿನಾಂಕವಿಲ್ಲದ ವಸ್ತುಗಳನ್ನು ಸ್ಥಳಾಂತರಿಸುವ ಮೊದಲು ವಿಚಾರಿಸಿ';

  @override
  String get settingsConfirmationAfterMoveToBinItems => 'ವಸ್ತುಗಳನ್ನು ಮರುಬಳಕೆ ತೊಟ್ಟಿಗೆ ಸ್ಥಳಾಂತರಿಸಿದ ನಂತರ ಸಂದೇಶವನ್ನು ತೋರಿಸಿ';

  @override
  String get settingsConfirmationVaultDataLoss => 'ನೆಲಮಾಳಿಗೆಯ ದತ್ತಾಂಶ ನಷ್ಟವಾಗುವುದನ್ನು ಎಚ್ಚರಿಸಿ';

  @override
  String get settingsNavigationDrawerTile => 'ನ್ಯಾವಿಗೇಷನ್ ಮೆನು';

  @override
  String get settingsNavigationDrawerEditorPageTitle => 'ನ್ಯಾವಿಗೇಷನ್ ಮೆನು';

  @override
  String get settingsNavigationDrawerBanner => 'ಮೆನು ವಸ್ತುಗಳನ್ನು ಸ್ಥಳಾಂತರಿಸಲು ಮತ್ತು ಮರುಕ್ರಮಗೊಳಿಸಲು ಸ್ಪರ್ಶಿಸಿ ಮತ್ತು ಹಿಡಿದುಕೊಳ್ಳಿ.';

  @override
  String get settingsNavigationDrawerTabTypes => 'ಪ್ರಕಾರಗಳು';

  @override
  String get settingsNavigationDrawerTabAlbums => 'ಆಲ್ಬಮ್ ಗಳು';

  @override
  String get settingsNavigationDrawerTabPages => 'ಪುಟಗಳು';

  @override
  String get settingsNavigationDrawerAddAlbum => 'ಆಲ್ಬಮ್ ಸೇರಿಸಿ';

  @override
  String get settingsThumbnailSectionTitle => 'ಥಂಬ್‌ನೇಲ್‌ಗಳು';

  @override
  String get settingsThumbnailOverlayTile => 'ಮೇಲ್ಪದರ';

  @override
  String get settingsThumbnailOverlayPageTitle => 'ಮೇಲ್ಪದರ';

  @override
  String get settingsThumbnailShowHdrIcon => 'HDR ಸಂಕೇತ ತೋರಿಸಿ';

  @override
  String get settingsThumbnailShowFavouriteIcon => 'ಮೆಚ್ಚಿನ ಸಂಕೇತ ತೋರಿಸಿ';

  @override
  String get settingsThumbnailShowTagIcon => 'ಟ್ಯಾಗು ಸಂಕೇತ ತೋರಿಸಿ';

  @override
  String get settingsThumbnailShowLocationIcon => 'ಸ್ಥಳದ ಚಿನ್ಹೆಯನ್ನು ತೋರಿಸಿ';

  @override
  String get settingsThumbnailShowMotionPhotoIcon => 'ಚಲನಾ ಚಿತ್ರದ ಚಿನ್ಹೆಯನ್ನು ತೋರಿಸಿ';

  @override
  String get settingsThumbnailShowRating => 'ದರವನ್ನು ತೋರಿಸಿ';

  @override
  String get settingsThumbnailShowRawIcon => 'Raw ಚಿನ್ಹೆಯನ್ನು ತೋರಿಸಿ';

  @override
  String get settingsThumbnailShowVideoDuration => 'ವಿಡಿಯೋ ಕಾಲಾವಧಿಯನ್ನು ತೋರಿಸಿ';

  @override
  String get settingsCollectionQuickActionsTile => 'ತ್ವರಿತ ಕ್ರಮಗಳು';

  @override
  String get settingsCollectionQuickActionEditorPageTitle => 'ತ್ವರಿತ ಕ್ರಮಗಳು';

  @override
  String get settingsCollectionQuickActionTabBrowsing => 'ತಡಕಾಟ';

  @override
  String get settingsCollectionQuickActionTabSelecting => 'ಆರಿಸು';

  @override
  String get settingsCollectionBrowsingQuickActionEditorBanner => 'ಗುಂಡಿಗಳನ್ನು ಸ್ಥಳಾಂತರಿಸಲು ಸ್ಪರ್ಶಿಸಿ ಮತ್ತು ಹಿಡಿದುಕೊಳ್ಳಿ ಮತ್ತು ವಸ್ತುಗಳನ್ನು ತಡಕಾಡುವಾಗ ಯಾವ ಕ್ರಿಯೆಗಳನ್ನು ಪ್ರದರ್ಶಿಸಬೇಕು ಎಂಬುದನ್ನು ಆರಿಸಿ.';

  @override
  String get settingsCollectionSelectionQuickActionEditorBanner => 'ಗುಂಡಿಗಳನ್ನು ಸ್ಥಳಾಂತರಿಸಲು ಸ್ಪರ್ಶಿಸಿ ಮತ್ತು ಹಿಡಿದುಕೊಳ್ಳಿ ಮತ್ತು ವಸ್ತುಗಳನ್ನು ತಡಕಾಡುವಾಗ ಯಾವ ಕ್ರಿಯೆಗಳನ್ನು ಪ್ರದರ್ಶಿಸಬೇಕು ಎಂಬುದನ್ನು ಆರಿಸಿಕೊಳ್ಳಿ.';

  @override
  String get settingsCollectionBurstPatternsTile => 'ಬರ್ಸ್ಟ್ ಪ್ರಕಾರಗಳು';

  @override
  String get settingsCollectionBurstPatternsNone => 'ಏನಿಲ್ಲ';

  @override
  String get settingsViewerSectionTitle => 'ವೀಕ್ಷಕ';

  @override
  String get settingsViewerGestureSideTapNext => 'ಹಿಂದಿನ/ಮುಂದಿನ ವಸ್ತುವನ್ನು ತೋರಿಸಲು ಪರದೆಯ ಅಂಚಿನ ಮೇಲೆ ತಟ್ಟಿ';

  @override
  String get settingsViewerUseCutout => 'ಕಟೌಟ್ ಪ್ರದೇಶವನ್ನು ಬಳಸಿರಿ';

  @override
  String get settingsViewerMaximumBrightness => 'ಗರಿಷ್ಟ ಪ್ರಕಾಶಮಯ';

  @override
  String get settingsMotionPhotoAutoPlay => 'ಚಾಲನಾ ಚಿತ್ರಗಳ ಸ್ವಯಂಚಾಲನೆ';

  @override
  String get settingsImageBackground => 'ಚಿತ್ರದ ಹಿನ್ನೆಲೆ';

  @override
  String get settingsViewerQuickActionsTile => 'ತ್ವರಿತ ಕ್ರಮಗಳು';

  @override
  String get settingsViewerQuickActionEditorPageTitle => 'ತ್ವರಿತ ಕ್ರಮಗಳು';

  @override
  String get settingsViewerQuickActionEditorBanner => 'ಗುಂಡಿಗಳನ್ನು ಸ್ಥಳಾಂತರಿಸಲು ಸ್ಪರ್ಶಿಸಿ ಮತ್ತು ಹಿಡಿದುಕೊಳ್ಳಿ ಮತ್ತು ವೀಕ್ಷಕದಲ್ಲಿ ಯಾವ ಕ್ರಿಯೆಗಳನ್ನು ಪ್ರದರ್ಶಿಸಬೇಕು ಎಂಬುದನ್ನು ಆರಿಸಿ.';

  @override
  String get settingsViewerQuickActionEditorDisplayedButtonsSectionTitle => 'ಪ್ರದರ್ಶಿತ ಗುಂಡಿಗಳು';

  @override
  String get settingsViewerQuickActionEditorAvailableButtonsSectionTitle => 'ಲಭ್ಯವಿರುವ ಗುಂಡಿಗಳು';

  @override
  String get settingsViewerQuickActionEmpty => 'ಗುಂಡಿಗಳಿಲ್ಲ';

  @override
  String get settingsViewerOverlayTile => 'ಮೇಲ್ಪದರ';

  @override
  String get settingsViewerOverlayPageTitle => 'ಮೇಲ್ಪದರ';

  @override
  String get settingsViewerShowOverlayOnOpening => 'ಪ್ರಾರಂಭದಲ್ಲಿ ತೋರಿಸಿ';

  @override
  String get settingsViewerShowHistogram => 'ಹಿಸ್ಟೋಗ್ರಾಮ್ ತೋರಿಸಿ';

  @override
  String get settingsViewerShowMinimap => 'ಚಿಕ್ಕನಕ್ಷೆಯನ್ನು ತೋರಿಸಿ';

  @override
  String get settingsViewerShowInformation => 'ಮಾಹಿತಿಯನ್ನು ತೋರಿಸಿ';

  @override
  String get settingsViewerShowInformationSubtitle => 'ಶೀರ್ಷಿಕೆ, ದಿನಾಂಕ, ಸ್ಥಳ ಇತ್ಯಾದಿಗಳನ್ನು ತೋರಿಸಿ.';

  @override
  String get settingsViewerShowRatingTags => 'ದರಗಳು ಮತ್ತು ಟ್ಯಾಗುಗಳನ್ನು ತೋರಿಸಿ';

  @override
  String get settingsViewerShowShootingDetails => 'ಸೆರೆಹಿಡಿದ ವಿವರಗಳನ್ನು ತೋರಿಸಿ';

  @override
  String get settingsViewerShowDescription => 'ವಿವರಣೆಗಳನ್ನು ತೋರಿಸಿ';

  @override
  String get settingsViewerShowOverlayThumbnails => 'ಅಡಕವನ್ನು ತೋರಿಸಿ';

  @override
  String get settingsViewerEnableOverlayBlurEffect => 'ಮಸುಕು ಪರಿಣಾಮ';

  @override
  String get settingsViewerSlideshowTile => 'ಜಾರುಫಲಕ';

  @override
  String get settingsViewerSlideshowPageTitle => 'ಜಾರುಫಲಕ';

  @override
  String get settingsSlideshowRepeat => 'ಪುನರಾವರ್ತನೆ';

  @override
  String get settingsSlideshowShuffle => 'ಕಲಸು';

  @override
  String get settingsSlideshowFillScreen => 'ಪೂರ್ಣ ಪರದೆ';

  @override
  String get settingsSlideshowAnimatedZoomEffect => 'ಅನಿಮೇಟೆಡ್ ಹಿಗ್ಗಿಸಿದ ಪರಿಣಾಮ';

  @override
  String get settingsSlideshowTransitionTile => 'ಪರಿವರ್ತನೆ';

  @override
  String get settingsSlideshowIntervalTile => 'ಮಧ್ಯಂತರ';

  @override
  String get settingsSlideshowVideoPlaybackTile => 'ವಿಡಿಯೋ ಪ್ಲೇಬ್ಯಾಕ್';

  @override
  String get settingsSlideshowVideoPlaybackDialogTitle => 'ವಿಡಿಯೋ ಪ್ಲೇಬ್ಯಾಕ್';

  @override
  String get settingsVideoPageTitle => 'ವಿಡಿಯೋ ಸಂಯೋಜನೆಗಳು';

  @override
  String get settingsVideoSectionTitle => 'ವಿಡಿಯೋ';

  @override
  String get settingsVideoShowVideos => 'ವಿಡಿಯೋಗಳನ್ನು ತೋರಿಸಿ';

  @override
  String get settingsVideoPlaybackTile => 'ಪ್ಲೇಬ್ಯಾಕ್';

  @override
  String get settingsVideoPlaybackPageTitle => 'ಪ್ಲೇಬ್ಯಾಕ್';

  @override
  String get settingsVideoEnableHardwareAcceleration => 'ಯಂತ್ರಾಂಶ ವೇಗವರ್ಧನೆ';

  @override
  String get settingsVideoAutoPlay => 'ಸ್ವಯಂ ಚಾಲನೆ';

  @override
  String get settingsVideoLoopModeTile => 'ಆವರ್ತನ ಕ್ರಮ';

  @override
  String get settingsVideoLoopModeDialogTitle => 'ಆವರ್ತನ ಕ್ರಮ';

  @override
  String get settingsVideoResumptionModeTile => 'ಮುಂದುವರೆಸು';

  @override
  String get settingsVideoResumptionModeDialogTitle => 'ಮುಂದುವರೆಸು';

  @override
  String get settingsVideoBackgroundMode => 'ಹಿನ್ನೆಲೆ ಕ್ರಮ';

  @override
  String get settingsVideoBackgroundModeDialogTitle => 'ಹಿನ್ನೆಲೆ ಕ್ರಮ';

  @override
  String get settingsVideoControlsTile => 'ನಿಯಂತ್ರಣಗಳು';

  @override
  String get settingsVideoControlsPageTitle => 'ನಿಯಂತ್ರಣಗಳು';

  @override
  String get settingsVideoButtonsTile => 'ಒತ್ತುಗುಂಡಿಗಳು';

  @override
  String get settingsVideoGestureDoubleTapTogglePlay => 'ಚಾಲನೆ/ವಿರಾಮ ಮಾಡಲು ದ್ವಿಗುಣ ತಟ್ಟಿ';

  @override
  String get settingsVideoGestureSideDoubleTapSeek => 'ಮುಂದೆ/ಹಿಂದೆ ಚಲಿಸಲು ಪರದೆಯ ಅಂಚಿನಲ್ಲಿ ಮಾಡಲು ದ್ವಿಗುಣ ತಟ್ಟಿ';

  @override
  String get settingsVideoGestureVerticalDragBrightnessVolume => 'ಪ್ರಕಾಶ/ಶಬ್ದಪ್ರಮಾಣ ಹೊಂದಿಸಲು ಮೇಲಕ್ಕೆ ಅಥವಾ ಕೆಳಕ್ಕೆ ಜಾರಿಸಿ';

  @override
  String get settingsSubtitleThemeTile => 'ಅಡಿಬರಹ';

  @override
  String get settingsSubtitleThemePageTitle => 'ಅಡಿಬರಹ';

  @override
  String get settingsSubtitleThemeSample => 'ಇದು ಒಂದು ನಮೂನೆ.';

  @override
  String get settingsSubtitleThemeTextAlignmentTile => 'ಪಠ್ಯ ಜೋಡಣೆ';

  @override
  String get settingsSubtitleThemeTextAlignmentDialogTitle => 'ಪಠ್ಯ ಜೋಡಣೆ';

  @override
  String get settingsSubtitleThemeTextPositionTile => 'ಪಠ್ಯ ಸ್ಥಾನ';

  @override
  String get settingsSubtitleThemeTextPositionDialogTitle => 'ಪಠ್ಯ ಸ್ಥಾನ';

  @override
  String get settingsSubtitleThemeTextSize => 'ಪಠ್ಯದ ಗಾತ್ರ';

  @override
  String get settingsSubtitleThemeShowOutline => 'ಬಾಹ್ಯರೇಖೆ ಮತ್ತು ನೆರಳನ್ನು ತೋರಿಸಿ';

  @override
  String get settingsSubtitleThemeTextColor => 'ಪಠ್ಯದ ಬಣ್ಣ';

  @override
  String get settingsSubtitleThemeTextOpacity => 'ಪಠ್ಯದ ಪಾರದರ್ಶಕತೆ';

  @override
  String get settingsSubtitleThemeBackgroundColor => 'ಹಿನ್ನೆಲೆ ಬಣ್ಣ';

  @override
  String get settingsSubtitleThemeBackgroundOpacity => 'ಹಿನ್ನೆಲೆ ಪಾರದರ್ಶಕತೆ';

  @override
  String get settingsSubtitleThemeTextAlignmentLeft => 'ಎಡ';

  @override
  String get settingsSubtitleThemeTextAlignmentCenter => 'ಮಧ್ಯ';

  @override
  String get settingsSubtitleThemeTextAlignmentRight => 'ಬಲ';

  @override
  String get settingsPrivacySectionTitle => 'ಗೌಪ್ಯತೆ';

  @override
  String get settingsAllowInstalledAppAccess => 'ಅಪ್ಲಿಕೇಶನ್ ಯಾದಿಗೆ ಪ್ರವೇಶವನ್ನು ಅನುಮತಿಸಿ';

  @override
  String get settingsAllowInstalledAppAccessSubtitle => 'ಆಲ್ಬಮ್ ಪ್ರದರ್ಶನವನ್ನು ಸುಧಾರಿಸಲು ಬಳಸಲಾಗುತ್ತದೆ';

  @override
  String get settingsAllowErrorReporting => 'ಅನಾಮಧೇಯ ದೋಷ ವರದಿಯನ್ನು ಅನುಮತಿಸಿ';

  @override
  String get settingsSaveSearchHistory => 'ಹುಡುಕಾಟದ ಇತಿಹಾಸವನ್ನು ಉಳಿಸಿ';

  @override
  String get settingsEnableBin => 'ಮರುಬಳಕೆಯ ತೊಟ್ಟಿಯನ್ನು ಬಳಸಿ';

  @override
  String get settingsEnableBinSubtitle => 'ಅಳಿಸಿದ ವಸ್ತುಗಳನ್ನು 30 ದಿನಗಳವರೆಗೆ ಇರಿಸಿ';

  @override
  String get settingsDisablingBinWarningDialogMessage => 'ಮರುಬಳಕೆ ತೊಟ್ಟಿಯಲ್ಲಿರುವ ವಸ್ತುಗಳನ್ನು ಶಾಶ್ವತವಾಗಿ ಅಳಿಸಲಾಗುತ್ತಿದೆ.';

  @override
  String get settingsAllowMediaManagement => 'ಮಾಧ್ಯಮ ನಿರ್ವಹಣೆಯನ್ನು ಅನುಮತಿಸಿ';

  @override
  String get settingsHiddenItemsTile => 'ಮರೆಮಾಡಿದ ವಸ್ತುಗಳು';

  @override
  String get settingsHiddenItemsPageTitle => 'ಮರೆಮಾಡಿದ ವಸ್ತುಗಳು';

  @override
  String get settingsHiddenFiltersBanner => 'ಮರೆಮಾಡಿದ ಫಿಲ್ಟರ್‌ಗಳಿಗೆ ಹೊಂದಿಕೆಯಾಗುವ ಚಿತ್ರಗಳು ಮತ್ತು ವೀಡಿಯೊಗಳು ನಿಮ್ಮ ಸಂಗ್ರಹಣೆಯಲ್ಲಿ ಗೋಚರಿಸುವುದಿಲ್ಲ.';

  @override
  String get settingsHiddenFiltersEmpty => 'ಮರೆಮಾಡಿದ ಫಿಲ್ಟರ್‌ಗಳಿಲ್ಲ';

  @override
  String get settingsStorageAccessTile => 'ಸಂಗ್ರಹಣೆ ಪ್ರವೇಶಾಧಿಕಾರ';

  @override
  String get settingsStorageAccessPageTitle => 'ಸಂಗ್ರಹಣೆ ಪ್ರವೇಶಾಧಿಕಾರ';

  @override
  String get settingsStorageAccessBanner => 'ಕೆಲವು ಕೋಶಗಳಿಗೆ ಕಡತಗಳನ್ನು ಮಾರ್ಪಡಿಸಲು ಸ್ಪಷ್ಟ ಪ್ರವೇಶವನ್ನು ಅನುಮತಿಸುವ ಅಗತ್ಯವಿದೆ. ನೀವು ಈ ಹಿಂದೆ ಪ್ರವೇಶವನ್ನು ನೀಡಿದ ಕೋಶಗಳನ್ನು ನೀವು ಇಲ್ಲಿ ಪರಿಶೀಲಿಸಬಹುದು.';

  @override
  String get settingsStorageAccessEmpty => 'ಪ್ರವೇಶ ಅನುಮತಿಸಿಲ್ಲ';

  @override
  String get settingsStorageAccessRevokeTooltip => 'ಹಿಂಪಡೆಯಿರಿ';

  @override
  String get settingsAccessibilitySectionTitle => 'ಎಟುಕು';

  @override
  String get settingsRemoveAnimationsTile => 'ಅನಿಮೇಷನ್‌ಗಳನ್ನು ತೆಗೆದುಹಾಕಿ';

  @override
  String get settingsRemoveAnimationsDialogTitle => 'ಅನಿಮೇಷನ್‌ಗಳನ್ನು ತೆಗೆಯಿರಿ';

  @override
  String get settingsTimeToTakeActionTile => 'ಕ್ರಮ ತೆಗೆದುಕೊಳ್ಳಲು ಸಮಯ';

  @override
  String get settingsAccessibilityShowPinchGestureAlternatives => 'ಬಹುಸ್ಪರ್ಶ ಗೆಸ್ಚರ್ ಪರ್ಯಾಯಗಳನ್ನು ತೋರಿಸಿ';

  @override
  String get settingsDisplaySectionTitle => 'ಪ್ರದರ್ಶಕ';

  @override
  String get settingsThemeBrightnessTile => 'ಅಲಂಕಾರ';

  @override
  String get settingsThemeBrightnessDialogTitle => 'ಅಲಂಕಾರ';

  @override
  String get settingsThemeColorHighlights => 'ಬಣ್ಣದ ಮುಖ್ಯಾಂಶಗಳು';

  @override
  String get settingsThemeEnableDynamicColor => 'ಡೈನಾಮಿಕ್ ಬಣ್ಣ';

  @override
  String get settingsDisplayRefreshRateModeTile => 'ರಿಫ್ರೆಶ್ ದರವನ್ನು ಪ್ರದರ್ಶಿಸಿ';

  @override
  String get settingsDisplayRefreshRateModeDialogTitle => 'ರಿಫ್ರೆಶ್ ದರ';

  @override
  String get settingsDisplayUseTvInterface => 'ಆಂಡ್ರಾಯ್ಡ್ ಟಿವಿ ಇಂಟರ್ಫೇಸ್';

  @override
  String get settingsLanguageSectionTitle => 'ಭಾಷೆ ಮತ್ತು ಸ್ವರೂಪಗಳು';

  @override
  String get settingsLanguageTile => 'ಭಾಷೆ';

  @override
  String get settingsLanguagePageTitle => 'ಭಾಷೆ';

  @override
  String get settingsCoordinateFormatTile => 'ನಿರ್ದೇಶಾಂಕ ಸ್ವರೂಪ';

  @override
  String get settingsCoordinateFormatDialogTitle => 'ನಿರ್ದೇಶಾಂಕ ಸ್ವರೂಪ';

  @override
  String get settingsUnitSystemTile => 'ಏಕಮಾನಗಳು';

  @override
  String get settingsUnitSystemDialogTitle => 'ಏಕಮಾನಗಳು';

  @override
  String get settingsForceWesternArabicNumeralsTile => 'ಅರೇಬಿಕ್ ಅಂಕಿಗಳನ್ನು ಒತ್ತಾಯಿಸಿ';

  @override
  String get settingsScreenSaverPageTitle => 'ಪರದೆ ರಕ್ಷಕ';

  @override
  String get settingsWidgetPageTitle => 'ಚಿತ್ರ ಚೌಕಟ್ಟು';

  @override
  String get settingsWidgetShowOutline => 'ರೂಪರೇಖೆ';

  @override
  String get settingsWidgetOpenPage => 'ವಿಜೆಟ್ ಮೇಲೆ ಸ್ಪರ್ಶಿಸುವಾಗ';

  @override
  String get settingsWidgetDisplayedItem => 'ಪ್ರದರ್ಶಿಸಲಾದ ವಸ್ತು';

  @override
  String get settingsCollectionTile => 'ಸಂಗ್ರಹ';

  @override
  String get statsPageTitle => 'ಅಂಕಿಅಂಶಗಳು';

  @override
  String statsWithGps(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ಸ್ಥಳ ಮಾಹಿತಿಯನ್ನು $countString ವಸ್ತುಗಳು ಹೊಂದಿವೆ',
      one: 'ಸ್ಥಳ ಮಾಹಿತಿಯನ್ನು 1 ವಸ್ತು ಹೊಂದಿದೆ ',
    );
    return '$_temp0';
  }

  @override
  String get statsTopCountriesSectionTitle => 'ಅಗ್ರ ದೇಶಗಳು';

  @override
  String get statsTopStatesSectionTitle => 'ಅಗ್ರ ರಾಜ್ಯಗಳು';

  @override
  String get statsTopPlacesSectionTitle => 'ಅಗ್ರ ಸ್ಥಳಗಳು';

  @override
  String get statsTopTagsSectionTitle => 'ಅಗ್ರ ಟ್ಯಾಗುಗಳು';

  @override
  String get statsTopAlbumsSectionTitle => 'ಅಗ್ರ ಆಲ್ಬಮ್ ಗಳು';

  @override
  String get viewerOpenPanoramaButtonLabel => 'ಪನೋರಮಾ ತೆರೆಯಿರಿ';

  @override
  String get viewerSetWallpaperButtonLabel => 'ಭಿತ್ತಿಚಿತ್ರ ಹೊಂದಿಸಿ';

  @override
  String get viewerErrorUnknown => 'ಅಯ್ಯೋ!';

  @override
  String get viewerErrorDoesNotExist => 'ಕಡತವು ಇನ್ಮುಂದೆ ಅಸ್ತಿತ್ವದಲ್ಲಿಲ್ಲ.';

  @override
  String get viewerInfoPageTitle => 'ವಿವರ';

  @override
  String get viewerInfoBackToViewerTooltip => 'ವೀಕ್ಷಕಕ್ಕೆ ಹಿಂದಿರುಗಿ';

  @override
  String get viewerInfoUnknown => 'ಅಜ್ಞಾತ';

  @override
  String get viewerInfoLabelDescription => 'ವಿವರಣೆ';

  @override
  String get viewerInfoLabelTitle => 'ಶೀರ್ಷಿಕೆ';

  @override
  String get viewerInfoLabelDate => 'ದಿನಾಂಕ';

  @override
  String get viewerInfoLabelResolution => 'ಅಳತೆ';

  @override
  String get viewerInfoLabelSize => 'ಪ್ರಮಾಣ';

  @override
  String get viewerInfoLabelUri => 'ಯು ಆರ್ ಐ';

  @override
  String get viewerInfoLabelPath => 'ಹಾದಿ';

  @override
  String get viewerInfoLabelDuration => 'ಅವಧಿ';

  @override
  String get viewerInfoLabelOwner => 'ಒಡೆಯ';

  @override
  String get viewerInfoLabelCoordinates => 'ನಿರ್ದೇಶಾಂಕ';

  @override
  String get viewerInfoLabelAddress => 'ವಿಳಾಸ';

  @override
  String get mapStyleDialogTitle => 'ನಕ್ಷೆಯ ಪ್ರಕಾರ';

  @override
  String get mapStyleTooltip => 'ನಕ್ಷೆಯ ಶೈಲಿಯನ್ನು ಆಯ್ಕೆಮಾಡಿ';

  @override
  String get mapZoomInTooltip => 'ಹಿಗ್ಗಿಸು';

  @override
  String get mapZoomOutTooltip => 'ಕುಗ್ಗಿಸು';

  @override
  String get mapPointNorthUpTooltip => 'ಉತ್ತರದಿಕ್ಕನ್ನು ಮೇಲ್ಮುಖವಾಗಿ ಸೂಚಿಸು';

  @override
  String get mapAttributionOsmData => 'ನಕ್ಷೆಯ ದತ್ತಾಂಶ © [OpenStreetMap](https://www.openstreetmap.org/copyright) ಕೊಡುಗೆದಾರರು';

  @override
  String get mapAttributionOsmLiberty => 'ಬಿಲ್ಲೆಗಳನ್ನು ಒದಗಿಸಿದವರು [OpenMapTiles](https://www.openmaptiles.org/), [CC BY](http://creativecommons.org/licenses/by/4.0) • ಆಶ್ರಯದಾತರು [OSM Americana](https://tile.ourmap.us)';

  @override
  String get mapAttributionOpenTopoMap => '[SRTM](https://www.earthdata.nasa.gov/sensors/srtm) | ಬಿಲ್ಲೆಗಳನ್ನು ಒದಗಿಸಿದವರು [OpenTopoMap](https://opentopomap.org/), [CC BY-SA](https://creativecommons.org/licenses/by-sa/3.0/)';

  @override
  String get mapAttributionOsmHot => 'ಬಿಲ್ಲೆಗಳನ್ನು ಒದಗಿಸಿದವರು [HOT](https://www.hotosm.org/) • ಆಶ್ರಯದಾತರು [OSM France](https://openstreetmap.fr/)';

  @override
  String get mapAttributionStamen => 'ಬಿಲ್ಲೆಗಳನ್ನು ಒದಗಿಸಿದವರು [Stamen Design](https://stamen.com), [CC BY 3.0](https://creativecommons.org/licenses/by/3.0)';

  @override
  String get openMapPageTooltip => 'ನಕ್ಷೆ ಪುಟದಲ್ಲಿ ವೀಕ್ಷಿಸಿ';

  @override
  String get mapEmptyRegion => 'ಈ ಪ್ರದೇಶದಲ್ಲಿ ಯಾವುದೇ ಚಿತ್ರಗಳಿಲ್ಲ';

  @override
  String get viewerInfoOpenEmbeddedFailureFeedback => 'ಹುದುಗಿಸಿದ ದತ್ತಾಂಶವನ್ನು ಹೊರತೆಗೆಯಲು ವಿಫಲವಾಗಿದೆ';

  @override
  String get viewerInfoOpenLinkText => 'ತೆರೆಯಿರಿ';

  @override
  String get viewerInfoViewXmlLinkText => 'XML ನೋಡಿ';

  @override
  String get viewerInfoSearchFieldLabel => 'ಹುದುಗಿಸಿದ ದತ್ತಾಂಶವನ್ನು ಹುಡುಕಿ';

  @override
  String get viewerInfoSearchEmpty => 'ಹೊಂದಾಣಿಕೆಯ ಕೀಲಿಗಳಿಲ್ಲ';

  @override
  String get viewerInfoSearchSuggestionDate => 'ದಿನಾಂಕ ಮತ್ತು ಸಮಯ';

  @override
  String get viewerInfoSearchSuggestionDescription => 'ವಿವರಣೆ';

  @override
  String get viewerInfoSearchSuggestionDimensions => 'ಆಯಾಮ';

  @override
  String get viewerInfoSearchSuggestionResolution => 'ಅಳತೆ';

  @override
  String get viewerInfoSearchSuggestionRights => 'ಹಕ್ಕುಗಳು';

  @override
  String get wallpaperUseScrollEffect => 'ಮುಖಪುಟದಲ್ಲಿ ಸುರುಳಿ ಪರಿಣಾಮವನ್ನು ಬಳಸಿ';

  @override
  String get tagEditorPageTitle => 'Tagಗಳನ್ನು ತಿದ್ದಿ';

  @override
  String get tagEditorPageNewTagFieldLabel => 'ಹೊಸ ಟ್ಯಾಗು';

  @override
  String get tagEditorPageAddTagTooltip => 'ಟ್ಯಾಗು ಸೇರಿಸಿ';

  @override
  String get tagEditorSectionRecent => 'ಇತ್ತೀಚಿನವು';

  @override
  String get tagEditorSectionPlaceholders => 'ಪ್ಲೇಸ್‌ಹೋಲ್ಡರ್‌ಗಳು';

  @override
  String get tagEditorDiscardDialogMessage => 'ನೀವು ಬದಲಾವಣೆಗಳನ್ನು ತ್ಯಜಿಸಲು ಬಯಸುವಿರಾ?';

  @override
  String get tagPlaceholderCountry => 'ದೇಶ';

  @override
  String get tagPlaceholderState => 'ರಾಜ್ಯ';

  @override
  String get tagPlaceholderPlace => 'ಸ್ಥಳ';

  @override
  String get panoramaEnableSensorControl => 'ಸಂವೇದಕ ನಿಯಂತ್ರಣವನ್ನು ಸಕ್ರಿಯಗೊಳಿಸಿ';

  @override
  String get panoramaDisableSensorControl => 'ಸಂವೇದಕ ನಿಯಂತ್ರಣವನ್ನು ನಿಷ್ಕ್ರಿಯಗೊಳಿಸಿ';

  @override
  String get sourceViewerPageTitle => 'ಮೂಲ';
}
