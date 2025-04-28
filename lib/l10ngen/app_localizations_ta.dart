// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appName => 'ஏவ்சு';

  @override
  String get welcomeMessage => 'ஏவ்சுக்கு வருக';

  @override
  String get welcomeOptional => 'விரும்பினால்';

  @override
  String get welcomeTermsToggle => 'விதிமுறைகள் மற்றும் நிபந்தனைகளை நான் ஒப்புக்கொள்கிறேன்';

  @override
  String itemCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString உருப்படிகள்',
      one: '$countString உருப்படி',
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
      other: '$countString நெடுவரிசைகள்',
      one: '$countString நெடுவரிசை',
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
      other: '$countString விநாடிகள்',
      one: '$countString இரண்டாவது',
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
      other: '$countString நிமிடங்கள்',
      one: '$countString நிமிடம்',
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
      other: '$countString நாட்கள்',
      one: '$countString நாள்',
    );
    return '$_temp0';
  }

  @override
  String focalLength(String length) {
    return '$length மிமீ';
  }

  @override
  String get applyButtonLabel => 'இடு';

  @override
  String get deleteButtonLabel => 'நீக்கு';

  @override
  String get nextButtonLabel => 'அடுத்தது';

  @override
  String get showButtonLabel => 'காட்டு';

  @override
  String get hideButtonLabel => 'மறை';

  @override
  String get continueButtonLabel => 'தொடரவும்';

  @override
  String get saveCopyButtonLabel => 'நகலைச் சேமி';

  @override
  String get applyTooltip => 'இடு';

  @override
  String get cancelTooltip => 'விலக்கு';

  @override
  String get changeTooltip => 'மாற்று';

  @override
  String get clearTooltip => 'துடை';

  @override
  String get previousTooltip => 'முந்தைய';

  @override
  String get nextTooltip => 'அடுத்தது';

  @override
  String get showTooltip => 'காட்டு';

  @override
  String get hideTooltip => 'மறை';

  @override
  String get actionRemove => 'அகற்று';

  @override
  String get resetTooltip => 'மீட்டமை';

  @override
  String get saveTooltip => 'சேமி';

  @override
  String get stopTooltip => 'நிறுத்து';

  @override
  String get pickTooltip => 'தேர்ந்தெடு';

  @override
  String get doubleBackExitMessage => 'வெளியேற “பின்” என்பதைத் தட்டவும்.';

  @override
  String get doNotAskAgain => 'மீண்டும் கேட்க வேண்டாம்';

  @override
  String get sourceStateLoading => 'ஏற்றுகிறது';

  @override
  String get sourceStateCataloguing => 'பட்டியலிடுதல்';

  @override
  String get sourceStateLocatingCountries => 'நாடுகளைக் கண்டறிதல்';

  @override
  String get sourceStateLocatingPlaces => 'இடங்களைக் கண்டறிதல்';

  @override
  String get chipActionDelete => 'நீக்கு';

  @override
  String get chipActionRemove => 'அகற்று';

  @override
  String get chipActionShowCollection => 'சேகரிப்பில் காட்டு';

  @override
  String get chipActionGoToAlbumPage => 'ஆல்பங்களில் காட்டு';

  @override
  String get chipActionGoToCountryPage => 'நாடுகளில் காட்டு';

  @override
  String get chipActionGoToPlacePage => 'இடங்களில் காண்பி';

  @override
  String get chipActionGoToTagPage => 'குறிச்சொற்களில் காட்டு';

  @override
  String get chipActionGoToExplorerPage => 'உலாவில் காட்டு';

  @override
  String get chipActionDecompose => 'பிளவு';

  @override
  String get chipActionFilterOut => 'வடிகட்டி நீக்கு';

  @override
  String get chipActionFilterIn => 'வடிகட்டி வை';

  @override
  String get chipActionHide => 'மறை';

  @override
  String get chipActionLock => 'பூட்டு';

  @override
  String get chipActionPin => 'மேலே முள்';

  @override
  String get chipActionUnpin => 'மேலே இருந்து அவிழ்த்து விடு';

  @override
  String get chipActionRename => 'மறுபெயரிடு';

  @override
  String get chipActionSetCover => 'அட்டை அமை';

  @override
  String get chipActionShowCountryStates => 'நிலைகளைக் காட்டு';

  @override
  String get chipActionCreateAlbum => 'ஆல்பத்தை உருவாக்கு';

  @override
  String get chipActionCreateVault => 'பெட்டகத்தை உருவாக்கு';

  @override
  String get chipActionConfigureVault => 'பெட்டகத்தை உள்ளமை';

  @override
  String get entryActionCopyToClipboard => 'இடைநிலைப் பலகைக்கு நகலெடு';

  @override
  String get entryActionDelete => 'நீக்கு';

  @override
  String get entryActionConvert => 'நிலைமாற்று';

  @override
  String get entryActionExport => 'ஏற்றுமதி';

  @override
  String get entryActionInfo => 'தகவல்';

  @override
  String get entryActionRename => 'மறுபெயரிடு';

  @override
  String get entryActionRestore => 'மீட்டெடு';

  @override
  String get entryActionRotateCCW => 'எதிரெதிர் திசையில் சுழற்று';

  @override
  String get entryActionRotateCW => 'கடிகார திசையில் சுழற்று';

  @override
  String get entryActionFlip => 'கிடைமட்டமாகப் புரட்டு';

  @override
  String get entryActionPrint => 'அச்சிடு';

  @override
  String get entryActionShare => 'பங்கு';

  @override
  String get entryActionShareImageOnly => 'படத்தை மட்டும் பகிர்';

  @override
  String get entryActionShareVideoOnly => 'காணொளியைப் பகிர்';

  @override
  String get entryActionViewSource => 'மூலத்தைக் காண்க';

  @override
  String get entryActionShowGeoTiffOnMap => 'வரைபட மேலடுக்கு எனக் காட்டு';

  @override
  String get entryActionConvertMotionPhotoToStillImage => 'நிலை படத்திற்கு மாற்று';

  @override
  String get entryActionViewMotionPhotoVideo => 'திறந்த காணொளி';

  @override
  String get entryActionEdit => 'தொகு';

  @override
  String get entryActionOpen => 'உடன் திற';

  @override
  String get entryActionSetAs => 'என அமை';

  @override
  String get entryActionCast => 'நடிகர்கள்';

  @override
  String get entryActionOpenMap => 'வரைபட பயன்பாட்டில் காண்பி';

  @override
  String get entryActionRotateScreen => 'திரை சுழற்று';

  @override
  String get entryActionAddFavourite => 'பிடித்தவைகளில் சேர்';

  @override
  String get entryActionRemoveFavourite => 'பிடித்தவைகளிலிருந்து அகற்று';

  @override
  String get videoActionCaptureFrame => 'பிடிப்பு சட்டகம்';

  @override
  String get videoActionMute => 'முடக்கு';

  @override
  String get videoActionUnmute => 'ஒலித்தடையை நீக்கு';

  @override
  String get videoActionPause => 'இடைநிறுத்தம்';

  @override
  String get videoActionPlay => 'இயக்கு';

  @override
  String get videoActionReplay10 => '10 வினாடிகள் பின்தங்கியபடி நாடிச்செல்';

  @override
  String get videoActionSkip10 => '10 வினாடிகள் முன்னோக்கி நாடிச்செல்';

  @override
  String get videoActionShowPreviousFrame => 'முந்தைய சட்டத்தைக் காட்டு';

  @override
  String get videoActionShowNextFrame => 'அடுத்த சட்டகத்தைக் காட்டு';

  @override
  String get videoActionSelectStreams => 'தடங்களைத் தேர்ந்தெடு';

  @override
  String get videoActionSetSpeed => 'பின்னணி விரைவு';

  @override
  String get videoActionABRepeat => 'அ-ஆ மீண்டும்';

  @override
  String get videoRepeatActionSetStart => 'தொடக்கத்தை அமை';

  @override
  String get videoRepeatActionSetEnd => 'முடிவை அமை';

  @override
  String get viewerActionSettings => 'அமைப்புகள்';

  @override
  String get viewerActionLock => 'பூட்டு பார்வையாளர்';

  @override
  String get viewerActionUnlock => 'பார்வையாளர்பூட்டைத் திற';

  @override
  String get slideshowActionResume => 'மீண்டும் தொடங்குங்கள்';

  @override
  String get slideshowActionShowInCollection => 'சேகரிப்பில் காட்டு';

  @override
  String get entryInfoActionEditDate => 'தேதி & நேரத்தைத் திருத்து';

  @override
  String get entryInfoActionEditLocation => 'இருப்பிடத்தைத் திருத்து';

  @override
  String get entryInfoActionEditTitleDescription => 'தலைப்பு & விளக்கத்தைத் திருத்து';

  @override
  String get entryInfoActionEditRating => 'மதிப்பீட்டைத் திருத்து';

  @override
  String get entryInfoActionEditTags => 'குறிச்சொற்களைத் திருத்து';

  @override
  String get entryInfoActionRemoveMetadata => 'மேனிலை தரவை அகற்று';

  @override
  String get entryInfoActionExportMetadata => 'ஏற்றுமதி மேனிலை தரவு';

  @override
  String get entryInfoActionRemoveLocation => 'இருப்பிடத்தை அகற்று';

  @override
  String get editorActionTransform => 'உருமாற்று';

  @override
  String get editorTransformCrop => 'வெட்டி எடு';

  @override
  String get editorTransformRotate => 'சுழற்று';

  @override
  String get cropAspectRatioFree => 'கட்டற்ற';

  @override
  String get cropAspectRatioOriginal => 'அசல்';

  @override
  String get cropAspectRatioSquare => 'நாற்கை';

  @override
  String get filterAspectRatioLandscapeLabel => 'நிலப்பரப்பு';

  @override
  String get filterAspectRatioPortraitLabel => 'உருவப்படம்';

  @override
  String get filterBinLabel => 'மறுசுழற்சி கூடை';

  @override
  String get filterFavouriteLabel => 'பிடித்த';

  @override
  String get filterNoDateLabel => 'மதிப்பிடப்படாதது';

  @override
  String get filterNoAddressLabel => 'முகவரி இல்லை';

  @override
  String get filterLocatedLabel => 'அமைந்துள்ளது';

  @override
  String get filterNoLocationLabel => 'திறக்கப்படாதது';

  @override
  String get filterNoRatingLabel => 'மதிப்பிடப்படாதது';

  @override
  String get filterTaggedLabel => 'குறிச்சொல்இடப்பட்டது';

  @override
  String get filterNoTagLabel => 'குறிச்சொல்இடப்படாதது';

  @override
  String get filterNoTitleLabel => 'தலைப்பில்லாத';

  @override
  String get filterOnThisDayLabel => 'இந்த நாளில்';

  @override
  String get filterRecentlyAddedLabel => 'அண்மைக் காலத்தில் சேர்க்கப்பட்டது';

  @override
  String get filterRatingRejectedLabel => 'நிராகரிக்கப்பட்டது';

  @override
  String get filterTypeAnimatedLabel => 'உயிருள்ளதுபோல';

  @override
  String get filterTypeMotionPhotoLabel => 'இயக்கப் புகைப்படம்';

  @override
  String get filterTypePanoramaLabel => 'பரந்ததோற்றம்';

  @override
  String get filterTypeRawLabel => 'பச்சையான';

  @override
  String get filterTypeSphericalVideoLabel => '360 ° காணொளி';

  @override
  String get filterTypeGeotiffLabel => 'புவிடிஃப்';

  @override
  String get filterMimeImageLabel => 'படம்';

  @override
  String get filterMimeVideoLabel => 'காணொளி';

  @override
  String get accessibilityAnimationsRemove => 'திரை விளைவுகளைத் தடு';

  @override
  String get accessibilityAnimationsKeep => 'திரை விளைவுகளை வைத்திரு';

  @override
  String get albumTierNew => 'புதிய';

  @override
  String get albumTierPinned => 'பின்செய்த்து';

  @override
  String get albumTierSpecial => 'பொது';

  @override
  String get albumTierApps => 'பயன்பாடுகள்';

  @override
  String get albumTierVaults => 'நிலவறைகள்';

  @override
  String get albumTierDynamic => 'மாறும்';

  @override
  String get albumTierRegular => 'மற்றவைகள்';

  @override
  String get coordinateFormatDms => 'டிமிவி';

  @override
  String get coordinateFormatDdm => 'டிடிஎம்';

  @override
  String get coordinateFormatDecimal => 'தசம டிகிரி';

  @override
  String coordinateDms(String coordinate, String direction) {
    return '$coordinate $direction';
  }

  @override
  String get coordinateDmsNorth => 'வ';

  @override
  String get coordinateDmsSouth => 'தெ';

  @override
  String get coordinateDmsEast => 'கி';

  @override
  String get coordinateDmsWest => 'மே';

  @override
  String get displayRefreshRatePreferHighest => 'அதிக விகிதம்';

  @override
  String get displayRefreshRatePreferLowest => 'குறைந்த விகிதம்';

  @override
  String get keepScreenOnNever => 'ஒருபோதும்';

  @override
  String get keepScreenOnVideoPlayback => 'காணொளி இயக்கத்தின்போது';

  @override
  String get keepScreenOnViewerOnly => 'பார்வையாளர் பக்கம் மட்டுமே';

  @override
  String get keepScreenOnAlways => 'எப்போதும்';

  @override
  String get lengthUnitPixel => 'புள்ளி';

  @override
  String get lengthUnitPercent => '%';

  @override
  String get mapStyleGoogleNormal => 'கூகிள் வரைபடங்கள்';

  @override
  String get mapStyleGoogleHybrid => 'கூகிள் வரைபடங்கள் (கலப்பின)';

  @override
  String get mapStyleGoogleTerrain => 'கூகிள் வரைபடங்கள் (நிலப்பரப்பு)';

  @override
  String get mapStyleOsmLiberty => 'திதெவ விடுதலை';

  @override
  String get mapStyleOpenTopoMap => 'திறடோபோவரைபடம்';

  @override
  String get mapStyleOsmHot => 'மனிதாபிமான திதெவ';

  @override
  String get mapStyleStamenWatercolor => 'மகரந்தம் நீர்நிறம்';

  @override
  String get maxBrightnessNever => 'ஒருபோதும்';

  @override
  String get maxBrightnessAlways => 'எப்போதும்';

  @override
  String get nameConflictStrategyRename => 'மறுபெயரிடு';

  @override
  String get nameConflictStrategyReplace => 'மாற்று';

  @override
  String get nameConflictStrategySkip => 'தவிர்';

  @override
  String get overlayHistogramNone => 'எதுவுமில்லை';

  @override
  String get overlayHistogramRGB => 'சிபநீ';

  @override
  String get overlayHistogramLuminance => 'ஒளிர்மை';

  @override
  String get subtitlePositionTop => 'மேலே';

  @override
  String get subtitlePositionBottom => 'கீழே';

  @override
  String get themeBrightnessLight => 'ஒளி';

  @override
  String get themeBrightnessDark => 'இருண்ட';

  @override
  String get themeBrightnessBlack => 'கருப்பு';

  @override
  String get unitSystemMetric => 'மீட்டர் முறை';

  @override
  String get unitSystemImperial => 'ஏகாதிபத்திய';

  @override
  String get vaultLockTypePattern => 'வரைவடிவம்';

  @override
  String get vaultLockTypePin => 'தன்எண்';

  @override
  String get vaultLockTypePassword => 'கடவுச்சொல்';

  @override
  String get settingsVideoEnablePip => 'படத்துள்-படம்';

  @override
  String get videoControlsPlayOutside => 'மற்ற இயக்கியுடன் திற';

  @override
  String get videoLoopModeNever => 'ஒருபோதும்';

  @override
  String get videoLoopModeShortOnly => 'குறுகிய காணொளிகள் மட்டுமே';

  @override
  String get videoLoopModeAlways => 'எப்போதும்';

  @override
  String get videoPlaybackSkip => 'தவிர்';

  @override
  String get videoPlaybackMuted => 'ஒலிமுடக்கி இயக்கு';

  @override
  String get videoPlaybackWithSound => 'ஒலியுடன் இயக்கு';

  @override
  String get videoResumptionModeNever => 'ஒருபோதும்';

  @override
  String get videoResumptionModeAlways => 'எப்போதும்';

  @override
  String get viewerTransitionSlide => 'படவில்லை';

  @override
  String get viewerTransitionParallax => 'இடமாறு தோற்றம்';

  @override
  String get viewerTransitionFade => 'மங்கல்';

  @override
  String get viewerTransitionZoomIn => 'பெரிதாக்கு';

  @override
  String get viewerTransitionNone => 'எதுவுமில்லை';

  @override
  String get wallpaperTargetHome => 'முகப்புத் திரை';

  @override
  String get wallpaperTargetLock => 'பூட்டுத் திரை';

  @override
  String get wallpaperTargetHomeLock => 'முகப்பு மற்றும் பூட்டு திரைகள்';

  @override
  String get widgetDisplayedItemRandom => 'சீரற்ற';

  @override
  String get widgetDisplayedItemMostRecent => 'மிக அண்மைக் கால';

  @override
  String get widgetOpenPageHome => 'திறந்த வீடு';

  @override
  String get widgetOpenPageCollection => 'திறந்த சேகரிப்பு';

  @override
  String get widgetOpenPageViewer => 'திறந்த பார்வையாளர்';

  @override
  String get widgetTapUpdateWidget => 'நிரல் பலகையைப் புதுப்பி';

  @override
  String get storageVolumeDescriptionFallbackPrimary => 'உள் சேமிப்பு';

  @override
  String get storageVolumeDescriptionFallbackNonPrimary => 'நினைவு அட்டை';

  @override
  String get rootDirectoryDescription => 'வேர் அடைவு';

  @override
  String otherDirectoryDescription(String name) {
    return '“$name” அடைவு';
  }

  @override
  String storageAccessDialogMessage(String directory, String volume) {
    return 'இந்தப் பயன்பாட்டுக்கு அணுகலை வழங்க அடுத்த திரையில் உள்ள “$volume” இன் $directory ஐத் தேர்ந்தெடு.';
  }

  @override
  String restrictedAccessDialogMessage(String directory, String volume) {
    return 'இந்தப் பயன்பாடு “$volume” இன் $directory இல் உள்ள கோப்புகளை மாற்ற அனுமதிக்கப்படவில்லை.\n\nஉருப்படிகளை மற்றொரு கோப்பகத்திற்கு நகர்த்துவதற்கு முன்பே நிறுவப்பட்ட கோப்பு மேலாளர் அல்லது கேலரி பயன்பாட்டைப் பயன்படுத்தவும்.';
  }

  @override
  String notEnoughSpaceDialogMessage(String neededSize, String freeSize, String volume) {
    return 'இந்தச் செயல்பாட்டிற்கு “$volume” இல் இலவச இடத்தின் $neededSize தேவை, ஆனால் $freeSize மட்டுமே உள்ளது.';
  }

  @override
  String get missingSystemFilePickerDialogMessage => 'கணினி கோப்பு பிக்கர் காணவில்லை அல்லது முடக்கப்பட்டுள்ளது. தயவுசெய்து அதை இயக்கி மீண்டும் முயற்சிக்கவும்.';

  @override
  String unsupportedTypeDialogMessage(int count, String types) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'இந்தச் செயல்பாடு பின்வரும் வகைகளின் உருப்படிகளுக்கு ஆதரிக்கப்படவில்லை: $types.',
      one: 'இந்தச் செயல்பாடு பின்வரும் வகையின் உருப்படிகளுக்கு ஆதரிக்கப்படவில்லை: $types.',
    );
    return '$_temp0';
  }

  @override
  String get nameConflictDialogSingleSourceMessage => 'இலக்கு கோப்புறையில் உள்ள சில கோப்புகளுக்கு ஒரே பெயர் உள்ளது.';

  @override
  String get nameConflictDialogMultipleSourceMessage => 'சில கோப்புகளுக்கு ஒரே பெயர் உள்ளது.';

  @override
  String get addShortcutDialogLabel => 'குறுக்குவழி சிட்டை';

  @override
  String get addShortcutButtonLabel => 'கூட்டு';

  @override
  String get noMatchingAppDialogMessage => 'இதைக் கையாளக்கூடிய பயன்பாடுகள் எதுவும் இல்லை.';

  @override
  String binEntriesConfirmationDialogMessage(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'இந்த $countString உருப்படிகளை மறுசுழற்சி தொட்டியில் நகர்த்தவா?',
      one: 'இந்த உருப்படியை மறுசுழற்சி தொட்டியில் நகர்த்தவா?',
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
      other: 'இந்த $countString உருப்படிகளை நீக்கு?',
      one: 'இந்த உருப்படியை நீக்கு?',
    );
    return '$_temp0';
  }

  @override
  String get moveUndatedConfirmationDialogMessage => 'தொடர்வதற்கு முன் உருப்படி தேதிகளைச் சேமிக்கவா?';

  @override
  String get moveUndatedConfirmationDialogSetDate => 'தேதிகளைச் சேமி';

  @override
  String videoResumeDialogMessage(String time) {
    return '$time இல் மீண்டும் இயக்குவதை விரும்புகிறீர்களா?';
  }

  @override
  String get videoStartOverButtonLabel => 'மறுதொடக்கம்';

  @override
  String get videoResumeButtonLabel => 'மீண்டும் தொடங்குங்கள்';

  @override
  String get setCoverDialogLatest => 'அண்மைக் கால உருப்படி';

  @override
  String get setCoverDialogAuto => 'தானி';

  @override
  String get setCoverDialogCustom => 'தனிப்பயன்';

  @override
  String get hideFilterConfirmationDialogMessage => 'பொருந்தக்கூடிய புகைப்படங்கள் மற்றும் காணொளிகள் உங்கள் சேகரிப்பிலிருந்து மறைக்கப்படும். “தனியுரிமை” அமைப்புகளிலிருந்து அவற்றை மீண்டும் காட்டலாம்.\n\n அவற்றை மறைக்க விரும்புகிறீர்களா?';

  @override
  String get newAlbumDialogTitle => 'புதிய தொகுப்பு';

  @override
  String get newAlbumDialogNameLabel => 'தொகுப்பின் பெயர்';

  @override
  String get newAlbumDialogAlbumAlreadyExistsHelper => 'தொகுப்பு ஏற்கனவே உள்ளது';

  @override
  String get newAlbumDialogNameLabelAlreadyExistsHelper => 'அடைவு ஏற்கனவே உள்ளது';

  @override
  String get newAlbumDialogStorageLabel => 'சேமிப்பு:';

  @override
  String get newDynamicAlbumDialogTitle => 'புதிய மாறும் தொகுப்பு';

  @override
  String get dynamicAlbumAlreadyExists => 'மாறும் தொகுப்பு ஏற்கனவே உள்ளது';

  @override
  String get newVaultWarningDialogMessage => 'பெட்டகங்களில் உள்ள உருப்படிகள் இந்தப் பயன்பாட்டிற்கு மட்டுமே கிடைக்கின்றன, மற்றவைகளுக்கு இல்லை.\n\n இந்தப் பயன்பாட்டை நிறுவல் நீக்கினால் அல்லது இந்தப் பயன்பாட்டு தரவை அழித்தால், இந்த உருப்படிகள் அனைத்தையும் இழப்பீர்கள்.';

  @override
  String get newVaultDialogTitle => 'புதிய பெட்டகம்';

  @override
  String get configureVaultDialogTitle => 'பெட்டகத்தை உள்ளமை';

  @override
  String get vaultDialogLockModeWhenScreenOff => 'திரை அணைக்கப்படும்போது பூட்டு';

  @override
  String get vaultDialogLockTypeLabel => 'பூட்டு வகை';

  @override
  String get patternDialogEnter => 'வடிவத்தை உள்ளிடு';

  @override
  String get patternDialogConfirm => 'முறை உறுதிப்படுத்து';

  @override
  String get pinDialogEnter => 'தன்எண் உள்ளிடவும்';

  @override
  String get pinDialogConfirm => 'தன்எண் உறுதிப்படுத்து';

  @override
  String get passwordDialogEnter => 'கடவுச்சொல்லை உள்ளிடு';

  @override
  String get passwordDialogConfirm => 'கடவுச்சொல்லை உறுதிப்படுத்து';

  @override
  String get authenticateToConfigureVault => 'பெட்டகத்தை உள்ளமைக்க ஏற்பு';

  @override
  String get authenticateToUnlockVault => 'பெட்டகத்தைத் திறக்க ஏற்பு';

  @override
  String get vaultBinUsageDialogMessage => 'சில பெட்டகங்கள் மறுசுழற்சி தொட்டியைப் பயன்படுத்துகின்றன.';

  @override
  String get renameAlbumDialogLabel => 'புதிய பெயர்';

  @override
  String get renameAlbumDialogLabelAlreadyExistsHelper => 'அடைவு ஏற்கனவே உள்ளது';

  @override
  String get renameEntrySetPageTitle => 'மறுபெயரிடு';

  @override
  String get renameEntrySetPagePatternFieldLabel => 'பெயரிடும் முறை';

  @override
  String get renameEntrySetPageInsertTooltip => 'புலம் செருகவும்';

  @override
  String get renameEntrySetPagePreviewSectionTitle => 'முன்னோட்டம்';

  @override
  String get renameProcessorCounter => 'கணக்கிடு';

  @override
  String get renameProcessorHash => 'கொத்து';

  @override
  String get renameProcessorName => 'பெயர்';

  @override
  String deleteSingleAlbumConfirmationDialogMessage(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'இந்தத் தொகுப்பையும் அதில் உள்ள $countString உருப்படிகளையும் நீக்கு?',
      one: 'இந்தத் தொகுப்பையும் அதில் உள்ள உருப்படியையும் நீக்கு?',
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
      other: 'இந்தத் தொகுப்பையும் அவற்றில் உள்ள $countString உருப்படிகளையும் நீக்கு?',
      one: 'இந்தத் தொகுப்பையும் அவற்றில் உள்ள உருப்படியையும் நீக்கு?',
    );
    return '$_temp0';
  }

  @override
  String get exportEntryDialogFormat => 'வடிவம்:';

  @override
  String get exportEntryDialogWidth => 'அகலம்';

  @override
  String get exportEntryDialogHeight => 'உயரம்';

  @override
  String get exportEntryDialogQuality => 'தரம்';

  @override
  String get exportEntryDialogWriteMetadata => 'மேனிலை தரவை எழுதுங்கள்';

  @override
  String get renameEntryDialogLabel => 'புதிய பெயர்';

  @override
  String get editEntryDialogCopyFromItem => 'பிற உருப்படியிலிருந்து நகலெடு';

  @override
  String get editEntryDialogTargetFieldsHeader => 'மாற்றுவதற்கான புலங்கள்';

  @override
  String get editEntryDateDialogTitle => 'தேதி & நேரம்';

  @override
  String get editEntryDateDialogSetCustom => 'தனிப்பயன் தேதியை அமை';

  @override
  String get editEntryDateDialogCopyField => 'மற்ற தேதியிலிருந்து நகலெடு';

  @override
  String get editEntryDateDialogExtractFromTitle => 'தலைப்பிலிருந்து பிரித்தெடு';

  @override
  String get editEntryDateDialogShift => 'பெயர்வு';

  @override
  String get editEntryDateDialogSourceFileModifiedDate => 'கோப்பு மாற்றியமைக்கப்பட்ட தேதி';

  @override
  String get durationDialogHours => 'மணிகள்';

  @override
  String get durationDialogMinutes => 'நிமையங்கள்';

  @override
  String get durationDialogSeconds => 'விநாடிகள்';

  @override
  String get editEntryLocationDialogTitle => 'இடம்';

  @override
  String get editEntryLocationDialogSetCustom => 'தனிப்பயன் இருப்பிடத்தை அமை';

  @override
  String get editEntryLocationDialogChooseOnMap => 'வரைபடத்தில் தேர்வு செய்';

  @override
  String get editEntryLocationDialogImportGpx => 'சிபிஎக்சு இறக்குமதி';

  @override
  String get editEntryLocationDialogLatitude => 'அகலாங்கு';

  @override
  String get editEntryLocationDialogLongitude => 'நெட்டாங்கு';

  @override
  String get editEntryLocationDialogTimeShift => 'நேர மாற்றம்';

  @override
  String get locationPickerUseThisLocationButton => 'இந்த இருப்பிடத்தைப் பயன்படுத்து';

  @override
  String get editEntryRatingDialogTitle => 'மதிப்பிடு';

  @override
  String get removeEntryMetadataDialogTitle => 'மேனிலை தரவு அகற்றுதல்';

  @override
  String get removeEntryMetadataDialogAll => 'அனைத்தும்';

  @override
  String get removeEntryMetadataDialogMore => 'மேலும்';

  @override
  String get removeEntryMetadataMotionPhotoXmpWarningDialogMessage => 'இயக்கபுகைப்படத்திற்குள் காணொளியை இயக்க எக்ச்எம்பி தேவை.\n\n நீங்கள் அதை அகற்ற விரும்புகிறீர்களா?';

  @override
  String get videoSpeedDialogLabel => 'பின்னணி விரைவு';

  @override
  String get videoStreamSelectionDialogVideo => 'காணொளி';

  @override
  String get videoStreamSelectionDialogAudio => 'ஒலிதம்';

  @override
  String get videoStreamSelectionDialogText => 'வசன வரிகள்';

  @override
  String get videoStreamSelectionDialogOff => 'அணை';

  @override
  String get videoStreamSelectionDialogTrack => 'தடம்';

  @override
  String get videoStreamSelectionDialogNoSelection => 'வேறு தடங்கள் இல்லை.';

  @override
  String get genericSuccessFeedback => 'முடிந்தது!';

  @override
  String get genericFailureFeedback => 'தோல்வியுற்றது';

  @override
  String get genericDangerWarningDialogMessage => 'நீங்கள் உறுதியாக இருக்கிறீர்களா?';

  @override
  String get tooManyItemsErrorDialogMessage => 'குறைவான உருப்படிகளுடன் மீண்டும் முயற்சி.';

  @override
  String get menuActionConfigureView => 'பார்வை';

  @override
  String get menuActionSelect => 'தேர்ந்தெடு';

  @override
  String get menuActionSelectAll => 'அனைத்தையும் தெரிவுசெய்';

  @override
  String get menuActionSelectNone => 'எதுவுமில்லை என்பதைத் தேர்ந்தெடு';

  @override
  String get menuActionMap => 'வரைபடம்';

  @override
  String get menuActionSlideshow => 'வில்லைக்காட்சி';

  @override
  String get menuActionStats => 'புள்ளிவிவரங்கள்';

  @override
  String get viewDialogSortSectionTitle => 'வரிசைப்படுத்து';

  @override
  String get viewDialogGroupSectionTitle => 'குழு';

  @override
  String get viewDialogLayoutSectionTitle => 'இடுவெளி';

  @override
  String get viewDialogReverseSortOrder => 'தலைகீழ் வரிசை முறை';

  @override
  String get tileLayoutMosaic => 'மொசைக்';

  @override
  String get tileLayoutGrid => 'சல்லடை';

  @override
  String get tileLayoutList => 'பட்டியல்';

  @override
  String get castDialogTitle => 'தூக்கிஎறி சாதனங்கள்';

  @override
  String get coverDialogTabCover => 'அட்டை';

  @override
  String get coverDialogTabApp => 'பயன்பாடு';

  @override
  String get coverDialogTabColor => 'நிறம்';

  @override
  String get appPickDialogTitle => 'பயன்பாட்டை எடு';

  @override
  String get appPickDialogNone => 'எதுவுமில்லை';

  @override
  String get aboutPageTitle => 'பற்றி';

  @override
  String get aboutLinkLicense => 'உரிமம்';

  @override
  String get aboutLinkPolicy => 'தனியுரிமைக் கொள்கை';

  @override
  String get aboutBugSectionTitle => 'பிழை அறிக்கை';

  @override
  String get aboutBugSaveLogInstruction => 'பயன்பாட்டு பதிவுகளை ஒரு கோப்பில் சேமி';

  @override
  String get aboutBugCopyInfoInstruction => 'கணினி தகவல்களை நகலெடு';

  @override
  String get aboutBugCopyInfoButton => 'நகலெடு';

  @override
  String get aboutBugReportInstruction => 'பதிவுகள் மற்றும் கணினி தகவல்களுடன் அறிவிலிமையம் குறித்த அறிக்கை';

  @override
  String get aboutBugReportButton => 'அறிக்கை';

  @override
  String get aboutDataUsageSectionTitle => 'தரவுப் பயன்பாடு';

  @override
  String get aboutDataUsageData => 'தரவு';

  @override
  String get aboutDataUsageCache => 'தேக்ககம்';

  @override
  String get aboutDataUsageDatabase => 'தரவுத்தளம்';

  @override
  String get aboutDataUsageMisc => 'இதர';

  @override
  String get aboutDataUsageInternal => 'உள்';

  @override
  String get aboutDataUsageExternal => 'வெளிப்புறம்';

  @override
  String get aboutDataUsageClearCache => 'தற்காலிக சேமிப்பு துடை';

  @override
  String get aboutCreditsSectionTitle => 'நன்றி';

  @override
  String get aboutCreditsWorldAtlas1 => 'இந்தப் பயன்பாடு ஒரு டோபோச்சன் கோப்பைப் பயன்படுத்துகிறது';

  @override
  String get aboutCreditsWorldAtlas2 => 'ஐஎச்சி உரிமத்தின் கீழ்.';

  @override
  String get aboutTranslatorsSectionTitle => 'மொழிபெயர்ப்பாளர்கள்';

  @override
  String get aboutLicensesSectionTitle => 'திறந்த மூல உரிமங்கள்';

  @override
  String get aboutLicensesBanner => 'இந்தப் பயன்பாடு பின்வரும் திறந்த மூல தொகுப்புகள் மற்றும் நூலகங்களைப் பயன்படுத்துகிறது.';

  @override
  String get aboutLicensesAndroidLibrariesSectionTitle => 'ஆண்ட்ராய்டு நூலகங்கள்';

  @override
  String get aboutLicensesFlutterPluginsSectionTitle => 'ப்லுட்டர் செருகுநிரல்கள்';

  @override
  String get aboutLicensesFlutterPackagesSectionTitle => 'ப்லுட்டர் தொகுப்புகள்';

  @override
  String get aboutLicensesDartPackagesSectionTitle => 'டார்ட் தொகுப்புகள்';

  @override
  String get aboutLicensesShowAllButtonLabel => 'அனைத்து உரிமங்களையும் காட்டு';

  @override
  String get policyPageTitle => 'தனியுரிமைக் கொள்கை';

  @override
  String get collectionPageTitle => 'சேகரிப்பு';

  @override
  String get collectionPickPageTitle => 'எடு';

  @override
  String get collectionSelectPageTitle => 'உருப்படிகளைத் தேர்ந்தெடு';

  @override
  String get collectionActionShowTitleSearch => 'தலைப்பு வடிகட்டியைக் காட்டு';

  @override
  String get collectionActionHideTitleSearch => 'தலைப்பு வடிகட்டியை மறை';

  @override
  String get collectionActionAddDynamicAlbum => 'மாறும் தொகுப்பைச் சேர்';

  @override
  String get collectionActionAddShortcut => 'குறுக்குவழியைச் சேர்';

  @override
  String get collectionActionSetHome => 'வீட்டாக அமை';

  @override
  String get collectionActionEmptyBin => 'வெற்று தொட்டி';

  @override
  String get collectionActionCopy => 'தொகுப்பிற்கு நகலெடு';

  @override
  String get collectionActionMove => 'தொகுப்பிற்கு நகர்த்து';

  @override
  String get collectionActionRescan => 'மறுவருடல்';

  @override
  String get collectionActionEdit => 'தொகு';

  @override
  String get collectionSearchTitlesHintText => 'தலைப்புகளைத் தேடு';

  @override
  String get collectionGroupAlbum => 'தொகுப்பால்';

  @override
  String get collectionGroupMonth => 'திங்களால்';

  @override
  String get collectionGroupDay => 'நாளால்';

  @override
  String get collectionGroupNone => 'குழு வேண்டாம்';

  @override
  String get sectionUnknown => 'தெரியாத';

  @override
  String get dateToday => 'இன்று';

  @override
  String get dateYesterday => 'நேற்று';

  @override
  String get dateThisMonth => 'இந்தத் திங்கள்';

  @override
  String collectionDeleteFailureFeedback(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'நீக்குவதில் தோல்வி $countString உருப்படிகள்',
      one: 'நீக்குவதில் தோல்வி 1 உருப்படி',
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
      other: 'நகலெடுப்பதில் தோல்வி $countString உருப்படிகள்',
      one: 'நகலெடுப்பதில் தோல்வி 1 உருப்படி',
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
      other: 'நகர்த்துவதில் தோல்வி $countString உருப்படிகள்',
      one: 'நகர்த்துவதில் தோல்வி 1 உருப்படி',
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
      other: 'மறுபெயரிடுவதில் தோல்வி $countString உருப்படிகள்',
      one: 'மறுபெயரிடுவதில் தோல்வி 1 உருப்படி',
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
      other: 'திருத்துவதில் தோல்வியுற்றது $countString உருப்படிகள்',
      one: 'திருத்துவதில் தோல்வியுற்றது 1 உருப்படி',
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
      other: 'ஏற்றுமதி செய்வதில் தோல்வி $countString பக்கங்கள்',
      one: 'ஏற்றுமதி செய்வதில் தோல்வி 1 பக்கம்',
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
      other: 'நகலெடுக்கப்பட்டது $countString உருப்படிகள்',
      one: 'நகலெடுக்கப்பட்டது 1 உருப்படி',
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
      other: 'நகர்த்தப்பட்ட $countString உருப்படிகள்',
      one: 'நகர்த்தப்பட்ட 1 உருப்படி',
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
      other: 'மறுபெயரிடப்பட்டது $countString உருப்படிகள்',
      one: 'மறுபெயரிடப்பட்டது 1 உருப்படி',
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
      other: 'திருத்தப்பட்ட $countString உருப்படிகள்',
      one: 'திருத்தப்பட்ட 1 உருப்படி',
    );
    return '$_temp0';
  }

  @override
  String get collectionEmptyFavourites => 'பிடித்தவை இல்லை';

  @override
  String get collectionEmptyVideos => 'காணொளிகள் இல்லை';

  @override
  String get collectionEmptyImages => 'படங்கள் இல்லை';

  @override
  String get collectionEmptyGrantAccessButtonLabel => 'அணுகல் வழங்கு';

  @override
  String get collectionSelectSectionTooltip => 'பிரிவைத் தேர்ந்தெடு';

  @override
  String get collectionDeselectSectionTooltip => 'தேர்வு நீக்கு';

  @override
  String get drawerAboutButton => 'பற்றி';

  @override
  String get drawerSettingsButton => 'அமைப்புகள்';

  @override
  String get drawerCollectionAll => 'அனைத்து சேகரிப்பு';

  @override
  String get drawerCollectionFavourites => 'பிடித்தவை';

  @override
  String get drawerCollectionImages => 'படங்கள்';

  @override
  String get drawerCollectionVideos => 'காணொளிகள்';

  @override
  String get drawerCollectionAnimated => 'அசைவூட்டபட்டது';

  @override
  String get drawerCollectionMotionPhotos => 'இயக்கப் புகைப்படங்கள்';

  @override
  String get drawerCollectionPanoramas => 'பனோரமாக்கள்';

  @override
  String get drawerCollectionRaws => 'மூல புகைப்படங்கள்';

  @override
  String get drawerCollectionSphericalVideos => '360° காணொளிகள்';

  @override
  String get drawerAlbumPage => 'தொகுப்புகள்';

  @override
  String get drawerCountryPage => 'நாடுகள்';

  @override
  String get drawerPlacePage => 'இடங்கள்';

  @override
  String get drawerTagPage => 'குறிச்சொற்கள்';

  @override
  String get sortByDate => 'தேதிமூலம்';

  @override
  String get sortByName => 'பெயரால்';

  @override
  String get sortByItemCount => 'உருப்படி எண்ணிக்கைமூலம்';

  @override
  String get sortBySize => 'அளவுமூலம்';

  @override
  String get sortByAlbumFileName => 'தொகுப்பு & கோப்புப் பெயர்மூலம்';

  @override
  String get sortByRating => 'மதிப்பீடுமூலம்';

  @override
  String get sortByDuration => 'காலப்படி';

  @override
  String get sortByPath => 'பாதைமூலம்';

  @override
  String get sortOrderNewestFirst => 'முதலில் புதியது';

  @override
  String get sortOrderOldestFirst => 'முதலில் பழமையானது';

  @override
  String get sortOrderAtoZ => 'அ இருந்து ஔ';

  @override
  String get sortOrderZtoA => 'ஔ இருந்து அ';

  @override
  String get sortOrderHighestFirst => 'முதலில் அதிகபட்சம்';

  @override
  String get sortOrderLowestFirst => 'முதலில் மிகக் குறைவு';

  @override
  String get sortOrderLargestFirst => 'பெரியது முதலில்';

  @override
  String get sortOrderSmallestFirst => 'சிறியது முதலில்';

  @override
  String get sortOrderShortestFirst => 'சின்னது முதலில்';

  @override
  String get sortOrderLongestFirst => 'முதலில் நீளமானது';

  @override
  String get albumGroupTier => 'அடுக்குமூலம்';

  @override
  String get albumGroupType => 'வகைமூலம்';

  @override
  String get albumGroupVolume => 'சேமிப்பக அளவுமூலம்';

  @override
  String get albumGroupNone => 'குழு வேண்டாம்';

  @override
  String get albumMimeTypeMixed => 'கலப்பு';

  @override
  String get albumPickPageTitleCopy => 'ஆல்பத்திற்கு நகலெடு';

  @override
  String get albumPickPageTitleExport => 'தொகுப்பிற்கு ஏற்றுமதி';

  @override
  String get albumPickPageTitleMove => 'தொகுப்பிற்கு நகர்த்து';

  @override
  String get albumPickPageTitlePick => 'தொகுப்பைத் தேர்ந்தெடு';

  @override
  String get albumCamera => 'ஒளிப்படக்கருவி';

  @override
  String get albumDownload => 'பதிவிறக்கம்';

  @override
  String get albumScreenshots => 'திரைக்காட்சிகள்';

  @override
  String get albumScreenRecordings => 'திரை பதிவுகள்';

  @override
  String get albumVideoCaptures => 'காணொளி பதிவுகள்';

  @override
  String get albumPageTitle => 'தொகுப்புகள்';

  @override
  String get albumEmpty => 'தொகுப்புகள் இல்லை';

  @override
  String get createAlbumButtonLabel => 'உருவாக்கு';

  @override
  String get newFilterBanner => 'புதிய';

  @override
  String get countryPageTitle => 'நாடுகள்';

  @override
  String get countryEmpty => 'எந்த நாடுகளும் இல்லை';

  @override
  String get statePageTitle => 'மாநிலங்கள்';

  @override
  String get stateEmpty => 'மாநிலங்கள் இல்லை';

  @override
  String get placePageTitle => 'இடங்கள்';

  @override
  String get placeEmpty => 'இடங்கள் இல்லை';

  @override
  String get tagPageTitle => 'குறிச்சொற்கள்';

  @override
  String get tagEmpty => 'குறிச்சொற்கள் இல்லை';

  @override
  String get binPageTitle => 'மறுசுழற்சி தொட்டி';

  @override
  String get explorerPageTitle => 'உலாவி';

  @override
  String get explorerActionSelectStorageVolume => 'சேமிப்பிடத்தைத் தேர்ந்தெடு';

  @override
  String get selectStorageVolumeDialogTitle => 'சேமிப்பிடத்தைத் தேர்ந்தெடு';

  @override
  String get searchCollectionFieldHint => 'சேகரிப்பு தேடல்';

  @override
  String get searchRecentSectionTitle => 'அண்மைக் கால';

  @override
  String get searchDateSectionTitle => 'திகதி';

  @override
  String get searchFormatSectionTitle => 'வடிவங்கள்';

  @override
  String get searchAlbumsSectionTitle => 'தொகுப்புகள்';

  @override
  String get searchCountriesSectionTitle => 'நாடுகள்';

  @override
  String get searchStatesSectionTitle => 'மாநிலங்கள்';

  @override
  String get searchPlacesSectionTitle => 'இடங்கள்';

  @override
  String get searchTagsSectionTitle => 'குறிச்சொற்கள்';

  @override
  String get searchRatingSectionTitle => 'மதிப்பீடுகள்';

  @override
  String get searchMetadataSectionTitle => 'மேனிலை தரவு';

  @override
  String get settingsPageTitle => 'அமைப்புகள்';

  @override
  String get settingsSystemDefault => 'கணினி இயல்புநிலை';

  @override
  String get settingsDefault => 'இயல்புநிலை';

  @override
  String get settingsDisabled => 'முடக்கப்பட்டது';

  @override
  String get settingsAskEverytime => 'ஒவ்வொருமுறையும் கேளு';

  @override
  String get settingsModificationWarningDialogMessage => 'மற்ற அமைப்புகள் மாற்றப்படும்.';

  @override
  String get settingsSearchFieldLabel => 'அமைப்புகளைத் தேடு';

  @override
  String get settingsSearchEmpty => 'பொருந்தக்கூடிய அமைப்பு இல்லை';

  @override
  String get settingsActionExport => 'ஏற்றுமதி';

  @override
  String get settingsActionExportDialogTitle => 'ஏற்றுமதி';

  @override
  String get settingsActionImport => 'இறக்குமதி';

  @override
  String get settingsActionImportDialogTitle => 'இறக்குமதி';

  @override
  String get appExportCovers => 'அட்டைகள்';

  @override
  String get appExportDynamicAlbums => 'மாறும் தொகுப்புகள்';

  @override
  String get appExportFavourites => 'பிடித்தவைகள்';

  @override
  String get appExportSettings => 'அமைப்புகள்';

  @override
  String get settingsNavigationSectionTitle => 'வழிசெலுத்தல்';

  @override
  String get settingsHomeTile => 'வீடு';

  @override
  String get settingsHomeDialogTitle => 'வீடு';

  @override
  String get setHomeCustom => 'தனிப்பயன்';

  @override
  String get settingsShowBottomNavigationBar => 'கீழே உள்ள வழிசெலுத்தல் பட்டியைக் காட்டு';

  @override
  String get settingsKeepScreenOnTile => 'திரையைத் தொடர்ந்து வைத்திரு';

  @override
  String get settingsKeepScreenOnDialogTitle => 'திரையைத் தொடர்ந்து வைத்திரு';

  @override
  String get settingsDoubleBackExit => 'வெளியேற “பின்” என்பதை இரண்டு முறை தட்டு';

  @override
  String get settingsConfirmationTile => 'உறுதிப்படுத்தல் உரையாடல்கள்';

  @override
  String get settingsConfirmationDialogTitle => 'உறுதிப்படுத்தல் உரையாடல்கள்';

  @override
  String get settingsConfirmationBeforeDeleteItems => 'பொருட்களை எப்போதும் நீக்குவதற்கு முன் கேளு';

  @override
  String get settingsConfirmationBeforeMoveToBinItems => 'மறுசுழற்சி தொட்டியில் பொருட்களை நகர்த்துவதற்கு முன் கேளு';

  @override
  String get settingsConfirmationBeforeMoveUndatedItems => 'மதிப்பிடப்படாத பொருட்களை நகர்த்துவதற்கு முன் கேளு';

  @override
  String get settingsConfirmationAfterMoveToBinItems => 'மறுசுழற்சி தொட்டியில் உருப்படிகளை நகர்த்திய பின் செய்தியைக் காட்டு';

  @override
  String get settingsConfirmationVaultDataLoss => 'பெட்டக தரவு இழப்பு எச்சரிக்கையைக் காட்டு';

  @override
  String get settingsNavigationDrawerTile => 'வழிசெலுத்தல் பட்டியல்';

  @override
  String get settingsNavigationDrawerEditorPageTitle => 'வழிசெலுத்தல் பட்டியல்';

  @override
  String get settingsNavigationDrawerBanner => 'பட்டியல் உருப்படிகளை நகர்த்தவும் மறுவரிசைப்படுத்தவும் தொட்டுப் பிடிக்கவும்.';

  @override
  String get settingsNavigationDrawerTabTypes => 'வகைகள்';

  @override
  String get settingsNavigationDrawerTabAlbums => 'தொகுப்புகள்';

  @override
  String get settingsNavigationDrawerTabPages => 'பக்கங்கள்';

  @override
  String get settingsNavigationDrawerAddAlbum => 'தொகுப்பைச் சேர்';

  @override
  String get settingsThumbnailSectionTitle => 'சிறு உருவங்கள்';

  @override
  String get settingsThumbnailOverlayTile => 'மேலடுக்கு';

  @override
  String get settingsThumbnailOverlayPageTitle => 'மேலடுக்கு';

  @override
  String get settingsThumbnailShowHdrIcon => 'எச்டிஆர் படவுருவைக் காட்டு';

  @override
  String get settingsThumbnailShowFavouriteIcon => 'பிடித்த படவுருவைக் காட்டு';

  @override
  String get settingsThumbnailShowTagIcon => 'குறிச்சொல் படவுருவைக் காட்டு';

  @override
  String get settingsThumbnailShowLocationIcon => 'இருப்பிட படவுருவைக் காட்டு';

  @override
  String get settingsThumbnailShowMotionPhotoIcon => 'இயக்கப் படப் படவுருவைக் காட்டு';

  @override
  String get settingsThumbnailShowRating => 'மதிப்பீட்டைக் காட்டு';

  @override
  String get settingsThumbnailShowRawIcon => 'மூல படவுருவைக் காட்டு';

  @override
  String get settingsThumbnailShowVideoDuration => 'காணொளி காலம் காட்டு';

  @override
  String get settingsCollectionQuickActionsTile => 'விரைவான செயல்கள்';

  @override
  String get settingsCollectionQuickActionEditorPageTitle => 'விரைவான செயல்கள்';

  @override
  String get settingsCollectionQuickActionTabBrowsing => 'உலாவுதல்';

  @override
  String get settingsCollectionQuickActionTabSelecting => 'தேர்ந்தெடுப்பது';

  @override
  String get settingsCollectionBrowsingQuickActionEditorBanner => 'பொத்தான்களை நகர்த்தவும், உருப்படிகளை உலாவும்போது எந்த நடவடிக்கைகள் காண்பிக்கப்படுகின்றன என்பதைத் தேர்ந்தெடு.';

  @override
  String get settingsCollectionSelectionQuickActionEditorBanner => 'பொத்தான்களை நகர்த்தவும், உருப்படிகளைத் தேர்ந்தெடுக்கும்போது எந்த நடவடிக்கைகள் காண்பிக்கப்படுகின்றன என்பதைத் தேர்ந்தெடு.';

  @override
  String get settingsCollectionBurstPatternsTile => 'வடிவங்கள் வெடிப்பு';

  @override
  String get settingsCollectionBurstPatternsNone => 'எதுவுமில்லை';

  @override
  String get settingsViewerSectionTitle => 'பார்வையாளர்';

  @override
  String get settingsViewerGestureSideTapNext => 'முந்தைய/அடுத்த உருப்படியைக் காட்ட திரை விளிம்புகளில் தட்டு';

  @override
  String get settingsViewerUseCutout => 'வெட்டு வெளியைப் பயன்படுத்து';

  @override
  String get settingsViewerMaximumBrightness => 'அதிகபட்ச ஒளி';

  @override
  String get settingsMotionPhotoAutoPlay => 'தானியங்கு இயக்கப் புகைப்படங்கள்';

  @override
  String get settingsImageBackground => 'படப் பின்னணி';

  @override
  String get settingsViewerQuickActionsTile => 'விரைவான செயல்கள்';

  @override
  String get settingsViewerQuickActionEditorPageTitle => 'விரைவான செயல்கள்';

  @override
  String get settingsViewerQuickActionEditorBanner => 'பொத்தான்களை நகர்த்தவும், பார்வையாளரில் எந்த நடவடிக்கைகள் காண்பிக்கப்படுகின்றன என்பதைத் தேர்ந்தெடு.';

  @override
  String get settingsViewerQuickActionEditorDisplayedButtonsSectionTitle => 'காட்டப்பட்ட பொத்தான்கள்';

  @override
  String get settingsViewerQuickActionEditorAvailableButtonsSectionTitle => 'கிடைக்கும் பொத்தான்கள்';

  @override
  String get settingsViewerQuickActionEmpty => 'பொத்தான்கள் இல்லை';

  @override
  String get settingsViewerOverlayTile => 'மேலடுக்கு';

  @override
  String get settingsViewerOverlayPageTitle => 'மேலடுக்கு';

  @override
  String get settingsViewerShowOverlayOnOpening => 'திறக்கையில் காட்டு';

  @override
  String get settingsViewerShowHistogram => 'அலைவெண் செவ்வகப் படம் காட்டு';

  @override
  String get settingsViewerShowMinimap => 'சிறுவரைப்படம் காட்டு';

  @override
  String get settingsViewerShowInformation => 'தகவலைக் காட்டு';

  @override
  String get settingsViewerShowInformationSubtitle => 'தலைப்பு, தேதி, இடம், போன்றவற்றைக் காட்டு.';

  @override
  String get settingsViewerShowRatingTags => 'மதிப்பீடு மற்றும் குறிச்சொற்களைக் காட்டு';

  @override
  String get settingsViewerShowShootingDetails => 'படப்பிடிப்பு விவரங்களைக் காட்டு';

  @override
  String get settingsViewerShowDescription => 'விளக்கத்தைக் காட்டு';

  @override
  String get settingsViewerShowOverlayThumbnails => 'சிறு உருவங்களைக் காட்டு';

  @override
  String get settingsViewerEnableOverlayBlurEffect => 'மங்கலான விளைவு';

  @override
  String get settingsViewerSlideshowTile => 'படவில்லைக் காட்சி';

  @override
  String get settingsViewerSlideshowPageTitle => 'படவில்லைக் காட்சி';

  @override
  String get settingsSlideshowRepeat => 'மறுசெய்கை';

  @override
  String get settingsSlideshowShuffle => 'கலக்கு';

  @override
  String get settingsSlideshowFillScreen => 'திரை நிரப்பு';

  @override
  String get settingsSlideshowAnimatedZoomEffect => 'அசைவூட்டம் மலர்ச்சி விளைவு';

  @override
  String get settingsSlideshowTransitionTile => 'மாற்றம்';

  @override
  String get settingsSlideshowIntervalTile => 'இடைவேளை';

  @override
  String get settingsSlideshowVideoPlaybackTile => 'காணொளி மீட்பொலி';

  @override
  String get settingsSlideshowVideoPlaybackDialogTitle => 'காணொளி மீட்பொலி';

  @override
  String get settingsVideoPageTitle => 'காணொளி அமைப்புகள்';

  @override
  String get settingsVideoSectionTitle => 'காணொளி';

  @override
  String get settingsVideoShowVideos => 'காணொளிகளைக் காட்டு';

  @override
  String get settingsVideoPlaybackTile => 'மீட்பொலி';

  @override
  String get settingsVideoPlaybackPageTitle => 'மீட்பொலி';

  @override
  String get settingsVideoEnableHardwareAcceleration => 'வன்பொருள் முடுக்கம்';

  @override
  String get settingsVideoAutoPlay => 'தானியங்கு';

  @override
  String get settingsVideoLoopModeTile => 'சுழல் பயன்முறை';

  @override
  String get settingsVideoLoopModeDialogTitle => 'சுழல் பயன்முறை';

  @override
  String get settingsVideoResumptionModeTile => 'காணொளி மீட்பொலி';

  @override
  String get settingsVideoResumptionModeDialogTitle => 'மீட்பொலியை மீண்டும் தொடங்கு';

  @override
  String get settingsVideoBackgroundMode => 'பின்னணி முறை';

  @override
  String get settingsVideoBackgroundModeDialogTitle => 'பின்னணி முறை';

  @override
  String get settingsVideoControlsTile => 'கட்டுப்பாடுகள்';

  @override
  String get settingsVideoControlsPageTitle => 'கட்டுப்பாடுகள்';

  @override
  String get settingsVideoButtonsTile => 'பொத்தான்கள்';

  @override
  String get settingsVideoGestureDoubleTapTogglePlay => 'விளையாட/இடைநிறுத்த இரட்டை தட்டவும்';

  @override
  String get settingsVideoGestureSideDoubleTapSeek => 'பின்தங்கிய/முன்னோக்கி தேட திரை விளிம்புகளில் இரட்டை தட்டவும்';

  @override
  String get settingsVideoGestureVerticalDragBrightnessVolume => 'பொலிவு/அளவை சரிசெய்ய மேலே அல்லது கீழே தேய்';

  @override
  String get settingsSubtitleThemeTile => 'வசன வரிகள்';

  @override
  String get settingsSubtitleThemePageTitle => 'வசன வரிகள்';

  @override
  String get settingsSubtitleThemeSample => 'இது ஒரு மாதிரி.';

  @override
  String get settingsSubtitleThemeTextAlignmentTile => 'உரை சீரமைப்பு';

  @override
  String get settingsSubtitleThemeTextAlignmentDialogTitle => 'உரை சீரமைப்பு';

  @override
  String get settingsSubtitleThemeTextPositionTile => 'உரை நிலை';

  @override
  String get settingsSubtitleThemeTextPositionDialogTitle => 'உரை நிலை';

  @override
  String get settingsSubtitleThemeTextSize => 'உரை அளவு';

  @override
  String get settingsSubtitleThemeShowOutline => 'சுருக்கம் மற்றும் நிழலைக் காட்டுங்கள்';

  @override
  String get settingsSubtitleThemeTextColor => 'உரை நிறம்';

  @override
  String get settingsSubtitleThemeTextOpacity => 'உரை ஒளிபுகாநிலை';

  @override
  String get settingsSubtitleThemeBackgroundColor => 'பின்னணி நிறம்';

  @override
  String get settingsSubtitleThemeBackgroundOpacity => 'பின்னணி ஒளிபுகாநிலை';

  @override
  String get settingsSubtitleThemeTextAlignmentLeft => 'இடது';

  @override
  String get settingsSubtitleThemeTextAlignmentCenter => 'நடுவண்';

  @override
  String get settingsSubtitleThemeTextAlignmentRight => 'வலது';

  @override
  String get settingsPrivacySectionTitle => 'தனியுரிமை';

  @override
  String get settingsAllowInstalledAppAccess => 'பயன்பாட்டு சரக்குகளுக்கான அணுகலை அனுமதி';

  @override
  String get settingsAllowInstalledAppAccessSubtitle => 'தொகுப்புக் காட்சியை மேம்படுத்தப் பயன்படுகிறது';

  @override
  String get settingsAllowErrorReporting => 'பெயரிலி பிழை அறிக்கையை அனுமதி';

  @override
  String get settingsSaveSearchHistory => 'தேடல் வரலாற்றைச் சேமி';

  @override
  String get settingsEnableBin => 'மறுசுழற்சி தொட்டியைப் பயன்படுத்து';

  @override
  String get settingsEnableBinSubtitle => 'நீக்கப்பட்ட பொருட்களை 30 நாட்களுக்கு வைத்திரு';

  @override
  String get settingsDisablingBinWarningDialogMessage => 'மறுசுழற்சி தொட்டியில் உள்ள உருப்படிகள் என்றென்றும் நீக்கப்படும்.';

  @override
  String get settingsAllowMediaManagement => 'ஊடக நிர்வாகத்தை அனுமதி';

  @override
  String get settingsHiddenItemsTile => 'மறைக்கப்பட்ட உருப்படிகள்';

  @override
  String get settingsHiddenItemsPageTitle => 'மறைக்கப்பட்ட உருப்படிகள்';

  @override
  String get settingsHiddenFiltersBanner => 'மறைக்கப்பட்ட வடிப்பான்களுடன் பொருந்தக்கூடிய புகைப்படங்கள் மற்றும் காணொளிகள் உங்கள் சேகரிப்பில் தோன்றாது.';

  @override
  String get settingsHiddenFiltersEmpty => 'மறைக்கப்பட்ட வடிப்பான்கள் இல்லை';

  @override
  String get settingsStorageAccessTile => 'சேமிப்பக அணுகல்';

  @override
  String get settingsStorageAccessPageTitle => 'சேமிப்பக அணுகல்';

  @override
  String get settingsStorageAccessBanner => 'சில கோப்பகங்களுக்கு அவற்றில் உள்ள கோப்புகளை மாற்ற வெளிப்படையான அணுகல் மானியம் தேவைப்படுகிறது. நீங்கள் முன்பு அணுகலை வழங்கிய கோப்பகங்களை இங்கே மதிப்பாய்வு செய்யலாம்.';

  @override
  String get settingsStorageAccessEmpty => 'அணுகல் மானியங்கள் இல்லை';

  @override
  String get settingsStorageAccessRevokeTooltip => 'திரும்பப்பெறு';

  @override
  String get settingsAccessibilitySectionTitle => 'அணுகுதிறன்';

  @override
  String get settingsRemoveAnimationsTile => 'அசைவூட்டங்களை அகற்று';

  @override
  String get settingsRemoveAnimationsDialogTitle => 'அசைவூட்டங்களை அகற்று';

  @override
  String get settingsTimeToTakeActionTile => 'நடவடிக்கை எடுக்க வேண்டிய நேரம்';

  @override
  String get settingsAccessibilityShowPinchGestureAlternatives => 'பல-தொடு சைகை மாற்றுகளைக் காட்டு';

  @override
  String get settingsDisplaySectionTitle => 'காட்சி';

  @override
  String get settingsThemeBrightnessTile => 'கருப்பொருள்';

  @override
  String get settingsThemeBrightnessDialogTitle => 'கருப்பொருள்';

  @override
  String get settingsThemeColorHighlights => 'வண்ண சிறப்பம்சங்கள்';

  @override
  String get settingsThemeEnableDynamicColor => 'மாறும் நிறம்';

  @override
  String get settingsDisplayRefreshRateModeTile => 'புதுப்பிப்பு வீதத்தைக் காண்பி';

  @override
  String get settingsDisplayRefreshRateModeDialogTitle => 'புதுப்பிப்பு வீதம்';

  @override
  String get settingsDisplayUseTvInterface => 'ஆண்ட்ராய்டு தொலைகாட்சி இடைமுகம்';

  @override
  String get settingsLanguageSectionTitle => 'மொழி & வடிவங்கள்';

  @override
  String get settingsLanguageTile => 'மொழி';

  @override
  String get settingsLanguagePageTitle => 'மொழி';

  @override
  String get settingsCoordinateFormatTile => 'ஆய வடிவம்';

  @override
  String get settingsCoordinateFormatDialogTitle => 'ஆய வடிவம்';

  @override
  String get settingsUnitSystemTile => 'அலகுகள்';

  @override
  String get settingsUnitSystemDialogTitle => 'அலகுகள்';

  @override
  String get settingsForceWesternArabicNumeralsTile => 'அரபு எண்களைக் கட்டாயப்படுத்துங்கள்';

  @override
  String get settingsScreenSaverPageTitle => 'திரை சேமிப்பான்';

  @override
  String get settingsWidgetPageTitle => 'புகைப்பட சட்டகம்';

  @override
  String get settingsWidgetShowOutline => 'சுருக்கம்';

  @override
  String get settingsWidgetOpenPage => 'நிரல் பலகையில் தட்டும்போது';

  @override
  String get settingsWidgetDisplayedItem => 'காட்டப்பட்ட உருப்படி';

  @override
  String get settingsCollectionTile => 'சேகரிப்பு';

  @override
  String get statsPageTitle => 'புள்ளிவிவரங்கள்';

  @override
  String statsWithGps(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString இருப்பிடத்துடன் உருப்படிகள்',
      one: '1 இடம் கொண்ட உருப்படி',
    );
    return '$_temp0';
  }

  @override
  String get statsTopCountriesSectionTitle => 'மேல் நாடுகள்';

  @override
  String get statsTopStatesSectionTitle => 'மேல் மாநிலங்கள்';

  @override
  String get statsTopPlacesSectionTitle => 'மேல் இடங்கள்';

  @override
  String get statsTopTagsSectionTitle => 'மேல் குறிச்சொற்கள்';

  @override
  String get statsTopAlbumsSectionTitle => 'மேல் தொகுப்புகள்';

  @override
  String get viewerOpenPanoramaButtonLabel => 'பனோரமா திற';

  @override
  String get viewerSetWallpaperButtonLabel => 'சுவர்த்தாளை அமை';

  @override
  String get viewerErrorUnknown => 'அச்சச்சோ!';

  @override
  String get viewerErrorDoesNotExist => 'கோப்பு இனி இல்லை.';

  @override
  String get viewerInfoPageTitle => 'தகவல்';

  @override
  String get viewerInfoBackToViewerTooltip => 'பார்வையாளருக்குத் திரும்பு';

  @override
  String get viewerInfoUnknown => 'தெரியாத';

  @override
  String get viewerInfoLabelDescription => 'விவரம்';

  @override
  String get viewerInfoLabelTitle => 'தலைப்பு';

  @override
  String get viewerInfoLabelDate => 'திகதி';

  @override
  String get viewerInfoLabelResolution => 'பகுத்தல்';

  @override
  String get viewerInfoLabelSize => 'அளவு';

  @override
  String get viewerInfoLabelUri => 'இணையமுகவரி';

  @override
  String get viewerInfoLabelPath => 'பாதை';

  @override
  String get viewerInfoLabelDuration => 'காலம்';

  @override
  String get viewerInfoLabelOwner => 'உரிமையாளர்';

  @override
  String get viewerInfoLabelCoordinates => 'அச்சுத்தூரங்கள்';

  @override
  String get viewerInfoLabelAddress => 'முகவரி';

  @override
  String get mapStyleDialogTitle => 'வரைபட நடை';

  @override
  String get mapStyleTooltip => 'வரைபட பாணியைத் தேர்ந்தெடு';

  @override
  String get mapZoomInTooltip => 'பெரிதாக்கு';

  @override
  String get mapZoomOutTooltip => 'சிறிதாக்கு';

  @override
  String get mapPointNorthUpTooltip => 'வடக்கு மேலே காட்டு';

  @override
  String get mapAttributionOsmData => 'வரைபட தரவு © [OpenStreetMap](https://www.openstreetmap.org/copyright) பங்களிப்பாளர்கள்';

  @override
  String get mapAttributionOsmLiberty => '[OpenMapTiles](https://www.openmaptiles.org/) மூலம் ஓடுகள், [CC BY](http://creativecommons.org/licenses/by/4.0) • [OSM Americana](https://tile.ourmap.us) மூலம் புரவலசேவை';

  @override
  String get mapAttributionOpenTopoMap => '[SRTM](https://www.earthdata.nasa.gov/sensors/srtm) | [OpenTopoMap](https://opentopomap.org/) மூலம் ஓடுகள், [CC BY-SA](https://creativecommons.org/licenses/by-sa/3.0/)';

  @override
  String get mapAttributionOsmHot => '[HOT](https://www.hotosm.org/) மூலம் ஓடுகள் • [OSM France](https://openstreetmap.fr/) மூலம் புரவலசேவை';

  @override
  String get mapAttributionStamen => '[Stamen Design](https://stamen.com) மூலம் ஓடுகள், [CC BY 3.0](https://creativecommons.org/licenses/by/3.0)';

  @override
  String get openMapPageTooltip => 'வரைபட பக்கத்தில் காண்க';

  @override
  String get mapEmptyRegion => 'இந்தப் வட்டாரத்தில் படங்கள் இல்லை';

  @override
  String get viewerInfoOpenEmbeddedFailureFeedback => 'உட்பொதிக்கப்பட்ட தரவைப் பிரித்தெடுப்பதில் தோல்வி';

  @override
  String get viewerInfoOpenLinkText => 'திற';

  @override
  String get viewerInfoViewXmlLinkText => 'நீகுமொ காண்க';

  @override
  String get viewerInfoSearchFieldLabel => 'மேனிலை தரவைத் தேடு';

  @override
  String get viewerInfoSearchEmpty => 'பொருந்தக்கூடிய திறவுகோல்கள் இல்லை';

  @override
  String get viewerInfoSearchSuggestionDate => 'தேதி & நேரம்';

  @override
  String get viewerInfoSearchSuggestionDescription => 'விவரம்';

  @override
  String get viewerInfoSearchSuggestionDimensions => 'பரிமாணங்கள்';

  @override
  String get viewerInfoSearchSuggestionResolution => 'பகுத்தல்';

  @override
  String get viewerInfoSearchSuggestionRights => 'உரிமைகள்';

  @override
  String get wallpaperUseScrollEffect => 'முகப்புத் திரையில் உருள் விளைவைப் பயன்படுத்து';

  @override
  String get tagEditorPageTitle => 'குறிச்சொற்களைத் திருத்து';

  @override
  String get tagEditorPageNewTagFieldLabel => 'புதிய குறிச்சொல்';

  @override
  String get tagEditorPageAddTagTooltip => 'குறிச்சொல்லைச் சேர்';

  @override
  String get tagEditorSectionRecent => 'அண்மைக் கால';

  @override
  String get tagEditorSectionPlaceholders => 'இடம் வைத்திருப்பவர்கள்';

  @override
  String get tagEditorDiscardDialogMessage => 'மாற்றங்களை நிராகரிக்க விரும்புகிறீர்களா?';

  @override
  String get tagPlaceholderCountry => 'நாடு';

  @override
  String get tagPlaceholderState => 'மாநிலம்';

  @override
  String get tagPlaceholderPlace => 'இடம்';

  @override
  String get panoramaEnableSensorControl => 'உணரி கட்டுப்பாட்டை இயக்கு';

  @override
  String get panoramaDisableSensorControl => 'உணரி கட்டுப்பாட்டை முடக்கு';

  @override
  String get sourceViewerPageTitle => 'மூலம்';

  @override
  String get filePickerShowHiddenFiles => 'மறைக்கப்பட்ட கோப்புகளைக் காட்டு';

  @override
  String get filePickerDoNotShowHiddenFiles => 'மறைக்கப்பட்ட கோப்புகளைக் காட்ட வேண்டாம்';

  @override
  String get filePickerOpenFrom => 'இருந்து திறந்திருக்கும்';

  @override
  String get filePickerNoItems => 'உருப்படிகள் இல்லை';

  @override
  String get filePickerUseThisFolder => 'இந்தக் கோப்புறையைப் பயன்படுத்து';
}
