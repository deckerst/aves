// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'ऐवीज';

  @override
  String get welcomeMessage => 'ऐवीज मे आपका स्वागत है';

  @override
  String get welcomeOptional => 'वैकल्पिक';

  @override
  String get welcomeTermsToggle => 'मैं नियमों और शर्तों से सहमत हूं';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count चीजे',
      one: '$count चीज',
    );
    return '$_temp0';
  }

  @override
  String columnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count कॉलम',
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
      other: '$countString सेकंडस',
      one: '$countString सेकंड',
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
      other: '$countString मिनट',
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
      other: '$countString दिन',
    );
    return '$_temp0';
  }

  @override
  String focalLength(String length) {
    return '$length एम एम';
  }

  @override
  String get applyButtonLabel => 'लगाऐ';

  @override
  String get deleteButtonLabel => 'मिटाए';

  @override
  String get nextButtonLabel => 'आगे';

  @override
  String get showButtonLabel => 'देखे';

  @override
  String get hideButtonLabel => 'छिपाए';

  @override
  String get continueButtonLabel => 'जारी रखे';

  @override
  String get saveCopyButtonLabel => 'सेव कॉपी';

  @override
  String get applyTooltip => 'लगाए';

  @override
  String get cancelTooltip => 'रद्द करें';

  @override
  String get changeTooltip => 'बदलें';

  @override
  String get clearTooltip => 'मिटाएं';

  @override
  String get previousTooltip => 'पिछे';

  @override
  String get nextTooltip => 'आगे';

  @override
  String get showTooltip => 'देखें';

  @override
  String get hideTooltip => 'छिपाए';

  @override
  String get actionRemove => 'हटाएं';

  @override
  String get resetTooltip => 'रिसेट';

  @override
  String get saveTooltip => 'सहेजें';

  @override
  String get stopTooltip => 'रोके';

  @override
  String get pickTooltip => 'चुनें';

  @override
  String get doubleBackExitMessage => 'बाहर जाने के लिए दोबारा \"पीछे\" पर टैप करें';

  @override
  String get doNotAskAgain => 'दोबारा मत पूछो';

  @override
  String get sourceStateLoading => 'लोड हो रहा है';

  @override
  String get sourceStateCataloguing => 'Cataloguing';

  @override
  String get sourceStateLocatingCountries => 'देश खोज रहे हैं';

  @override
  String get sourceStateLocatingPlaces => 'स्थान खोज रहें हैं';

  @override
  String get chipActionDelete => 'मिटाएं';

  @override
  String get chipActionRemove => 'हटाएं';

  @override
  String get chipActionShowCollection => 'कोलेक्शन में दिखाए';

  @override
  String get chipActionGoToAlbumPage => 'एल्बम में दिखाए';

  @override
  String get chipActionGoToCountryPage => 'देशों में दिखाएं';

  @override
  String get chipActionGoToPlacePage => 'स्थानों में दिखाएं';

  @override
  String get chipActionGoToTagPage => 'टैग्स में दिखाएं';

  @override
  String get chipActionGoToExplorerPage => 'एक्सप्लोरर में दिखाए';

  @override
  String get chipActionDecompose => 'स्प्लिट करे';

  @override
  String get chipActionFilterOut => 'फिल्टर करें';

  @override
  String get chipActionFilterIn => 'में फिल्टर करें';

  @override
  String get chipActionHide => 'छिपाए';

  @override
  String get chipActionLock => 'लॉक';

  @override
  String get chipActionPin => 'शीर्ष पर पिन करें';

  @override
  String get chipActionUnpin => 'शीर्ष से अनपिन करें';

  @override
  String get chipActionRename => 'नाम बदले';

  @override
  String get chipActionSetCover => 'कवर सेट करें';

  @override
  String get chipActionShowCountryStates => 'राज्यों को दिखाएं';

  @override
  String get chipActionCreateAlbum => 'एल्बम बनाएं';

  @override
  String get chipActionCreateVault => 'वॉल्ट बनाएं';

  @override
  String get chipActionConfigureVault => 'वॉल्ट को कॉन्फ़िगर करें';

  @override
  String get entryActionCopyToClipboard => 'क्लिपबोर्ड पर कॉपी करें';

  @override
  String get entryActionDelete => 'मिटाएं';

  @override
  String get entryActionConvert => 'बदले';

  @override
  String get entryActionExport => 'एक्सपोर्ट करें';

  @override
  String get entryActionInfo => 'जानकारी';

  @override
  String get entryActionRename => 'नाम बदलें';

  @override
  String get entryActionRestore => 'रिस्टोर करे';

  @override
  String get entryActionRotateCCW => 'वामावर्त स्थिति में घुमाएं';

  @override
  String get entryActionRotateCW => 'दक्षिणावर्त घुमाएं';

  @override
  String get entryActionFlip => 'क्षैतिज फ्लिप करे';

  @override
  String get entryActionPrint => 'प्रिंट करे';

  @override
  String get entryActionShare => 'शेयर करे';

  @override
  String get entryActionShareImageOnly => 'केवल इमेज शेयर करें';

  @override
  String get entryActionShareVideoOnly => 'केवल वीडियो शेयर करें';

  @override
  String get entryActionViewSource => 'सोर्स देखें';

  @override
  String get entryActionShowGeoTiffOnMap => 'मैप ओवरले के रूप में देखे';

  @override
  String get entryActionConvertMotionPhotoToStillImage => 'स्थिर छवि में परिवर्तित करें';

  @override
  String get entryActionViewMotionPhotoVideo => 'वीडियो खोलें';

  @override
  String get entryActionEdit => 'एडिट करें';

  @override
  String get entryActionOpen => 'के साथ खोलें';

  @override
  String get entryActionSetAs => 'के रूप में सेट करें';

  @override
  String get entryActionCast => 'कास्ट करें';

  @override
  String get entryActionOpenMap => 'मैप एप में दिखाएं';

  @override
  String get entryActionRotateScreen => 'स्क्रीन घुमाएँ';

  @override
  String get entryActionAddFavourite => 'पसंदीदा में जोड़े';

  @override
  String get entryActionRemoveFavourite => 'पसंदीदा से निकालें';

  @override
  String get videoActionCaptureFrame => 'फ्रेम कैप्चर करें';

  @override
  String get videoActionMute => 'म्यूट करे';

  @override
  String get videoActionUnmute => 'अनम्यूट करे';

  @override
  String get videoActionPause => 'रोके';

  @override
  String get videoActionPlay => 'चलाएं';

  @override
  String get videoActionReplay10 => '10 सेकंड्स पीछे ले';

  @override
  String get videoActionSkip10 => '10 सेकंड्स आगे लें';

  @override
  String get videoActionShowPreviousFrame => 'पिछला फ्रेम दिखाए';

  @override
  String get videoActionShowNextFrame => 'अगला फ्रेम दिखाए';

  @override
  String get videoActionSelectStreams => 'ट्रैक्स को चुने';

  @override
  String get videoActionSetSpeed => 'चलाने की गति';

  @override
  String get videoActionABRepeat => 'A-B दोहराव';

  @override
  String get videoRepeatActionSetStart => 'स्टार्ट सेट करे';

  @override
  String get videoRepeatActionSetEnd => 'एण्ड सेट करे';

  @override
  String get viewerActionSettings => 'सैटिंग';

  @override
  String get viewerActionLock => 'व्यूअर को लॉक करे';

  @override
  String get viewerActionUnlock => 'व्यूअर को अनलॉक करे';

  @override
  String get slideshowActionResume => 'रिज्यूम करें';

  @override
  String get slideshowActionShowInCollection => 'संग्रह में दिखाएं';

  @override
  String get entryInfoActionEditDate => 'दिनांक व समय एडिट करे';

  @override
  String get entryInfoActionEditLocation => 'लोकेशन एडिट करे';

  @override
  String get entryInfoActionEditTitleDescription => 'शीर्षक और विवरण संपादित करें';

  @override
  String get entryInfoActionEditRating => 'रेटिंग एडिट करे';

  @override
  String get entryInfoActionEditTags => 'टैग्स एडिट करे';

  @override
  String get entryInfoActionRemoveMetadata => 'मेटाडाटा हटाएं';

  @override
  String get entryInfoActionExportMetadata => 'मेटाडाटा एक्सपोर्ट करें';

  @override
  String get entryInfoActionRemoveLocation => 'लोकेशन हटाएं';

  @override
  String get editorActionTransform => 'परिवर्तन';

  @override
  String get editorTransformCrop => 'क्रॉप';

  @override
  String get editorTransformRotate => 'घुमाएं';

  @override
  String get cropAspectRatioFree => 'फ्री';

  @override
  String get cropAspectRatioOriginal => 'ओरिजनल';

  @override
  String get cropAspectRatioSquare => 'वर्ग';

  @override
  String get filterAspectRatioLandscapeLabel => 'लैंडस्केप';

  @override
  String get filterAspectRatioPortraitLabel => 'पोर्ट्रेट';

  @override
  String get filterBinLabel => 'रीसाइकल बिन';

  @override
  String get filterFavouriteLabel => 'पसंदीदा';

  @override
  String get filterNoDateLabel => 'अदिनांकित';

  @override
  String get filterNoAddressLabel => 'एड्रेस रहित';

  @override
  String get filterLocatedLabel => 'लोकेट किया गया';

  @override
  String get filterNoLocationLabel => 'लॉकेट नही किया गया';

  @override
  String get filterNoRatingLabel => 'रेट नहीं किया गया';

  @override
  String get filterTaggedLabel => 'टैग किया गया';

  @override
  String get filterNoTagLabel => 'टैग नहीं किया गया';

  @override
  String get filterNoTitleLabel => 'शीर्षकहीन';

  @override
  String get filterOnThisDayLabel => 'इस दिन पर';

  @override
  String get filterRecentlyAddedLabel => 'हाल ही में शामिल की गई';

  @override
  String get filterRatingRejectedLabel => 'अस्वीकृत';

  @override
  String get filterTypeAnimatedLabel => 'एनिमेटेड';

  @override
  String get filterTypeMotionPhotoLabel => 'मोशन फोटो';

  @override
  String get filterTypePanoramaLabel => 'पैनोरमा';

  @override
  String get filterTypeRawLabel => 'Raw';

  @override
  String get filterTypeSphericalVideoLabel => '360° वीडियो';

  @override
  String get filterTypeGeotiffLabel => 'GeoTIFF';

  @override
  String get filterMimeImageLabel => 'इमेज';

  @override
  String get filterMimeVideoLabel => 'वीडियो';

  @override
  String get accessibilityAnimationsRemove => 'स्क्रीन प्रभाव को रोकें';

  @override
  String get accessibilityAnimationsKeep => 'स्क्रीन प्रभाव रखें';

  @override
  String get albumTierNew => 'नया';

  @override
  String get albumTierPinned => 'पिन किया गया';

  @override
  String get albumTierSpecial => 'कॉमन';

  @override
  String get albumTierApps => 'ऐप्स';

  @override
  String get albumTierVaults => 'संदूक';

  @override
  String get albumTierDynamic => 'डायनेमिक';

  @override
  String get albumTierRegular => 'अन्य';

  @override
  String get coordinateFormatDms => 'DMS';

  @override
  String get coordinateFormatDdm => 'DDM';

  @override
  String get coordinateFormatDecimal => 'दशमलव डिग्री';

  @override
  String coordinateDms(String coordinate, String direction) {
    return '$coordinate $direction';
  }

  @override
  String get coordinateDmsNorth => 'उ';

  @override
  String get coordinateDmsSouth => 'द';

  @override
  String get coordinateDmsEast => 'पू';

  @override
  String get coordinateDmsWest => 'प';

  @override
  String get displayRefreshRatePreferHighest => 'उच्चतम दर';

  @override
  String get displayRefreshRatePreferLowest => 'न्यूनतम दर';

  @override
  String get keepScreenOnNever => 'कभी नहीं';

  @override
  String get keepScreenOnVideoPlayback => 'वीडियो प्लेबैक के दौरान';

  @override
  String get keepScreenOnViewerOnly => 'केवल व्यूअर पेज';

  @override
  String get keepScreenOnAlways => 'हमेशा';

  @override
  String get lengthUnitPixel => 'px';

  @override
  String get lengthUnitPercent => '%';

  @override
  String get mapStyleGoogleNormal => 'गूगल मैप्स';

  @override
  String get mapStyleGoogleHybrid => 'गूगल मैप्स (हाइब्रिड)';

  @override
  String get mapStyleGoogleTerrain => 'गूगल मैप्स (टेरेन)';

  @override
  String get mapStyleOsmLiberty => 'OSM Liberty';

  @override
  String get mapStyleOpenTopoMap => 'ओपनटॉपोमैप';

  @override
  String get mapStyleOsmHot => 'Humanitarian OSM';

  @override
  String get mapStyleStamenWatercolor => 'Stamen Watercolor';

  @override
  String get maxBrightnessNever => 'कभी नहीं';

  @override
  String get maxBrightnessAlways => 'हमेशा';

  @override
  String get nameConflictStrategyRename => 'नाम बदलें';

  @override
  String get nameConflictStrategyReplace => 'बदलें';

  @override
  String get nameConflictStrategySkip => 'छोड़े';

  @override
  String get overlayHistogramNone => 'कोई नहीं';

  @override
  String get overlayHistogramRGB => 'RGB';

  @override
  String get overlayHistogramLuminance => 'चमक';

  @override
  String get subtitlePositionTop => 'शीर्ष';

  @override
  String get subtitlePositionBottom => 'नीचे';

  @override
  String get themeBrightnessLight => 'लाइट';

  @override
  String get themeBrightnessDark => 'डार्क';

  @override
  String get themeBrightnessBlack => 'काला';

  @override
  String get unitSystemMetric => 'मात्रिक';

  @override
  String get unitSystemImperial => 'इम्पीरियल';

  @override
  String get vaultLockTypePattern => 'पैटर्न';

  @override
  String get vaultLockTypePin => 'पिन';

  @override
  String get vaultLockTypePassword => 'पासवर्ड';

  @override
  String get settingsVideoEnablePip => 'पिक्चर-इन-पिक्चर';

  @override
  String get videoControlsPlayOutside => 'अन्य प्लेयर के साथ खोलें';

  @override
  String get videoLoopModeNever => 'कभी नहीं';

  @override
  String get videoLoopModeShortOnly => 'केवल लघु वीडियो';

  @override
  String get videoLoopModeAlways => 'हमेशा';

  @override
  String get videoPlaybackSkip => 'छोड़े';

  @override
  String get videoPlaybackMuted => 'बिना ध्वनि के चलाएं';

  @override
  String get videoPlaybackWithSound => 'ध्वनि के साथ चलाए';

  @override
  String get videoResumptionModeNever => 'कभी नहीं';

  @override
  String get videoResumptionModeAlways => 'हमेशा';

  @override
  String get viewerTransitionSlide => 'स्लाइड';

  @override
  String get viewerTransitionParallax => 'पैरालैक्स';

  @override
  String get viewerTransitionFade => 'फेड';

  @override
  String get viewerTransitionZoomIn => 'ज़ूम इन';

  @override
  String get viewerTransitionNone => 'कोई नहीं';

  @override
  String get wallpaperTargetHome => 'होम स्क्रीन';

  @override
  String get wallpaperTargetLock => 'लॉक स्क्रीन';

  @override
  String get wallpaperTargetHomeLock => 'होम और लॉक स्क्रीन';

  @override
  String get widgetDisplayedItemRandom => 'यादृच्छिक';

  @override
  String get widgetDisplayedItemMostRecent => 'हाल ही के';

  @override
  String get widgetOpenPageHome => 'घर खोलें';

  @override
  String get widgetOpenPageCollection => 'संग्रह खोलें';

  @override
  String get widgetOpenPageViewer => 'व्यूअर खोलें';

  @override
  String get widgetTapUpdateWidget => 'विजेट अपडेट करें';

  @override
  String get storageVolumeDescriptionFallbackPrimary => 'आंतरिक भंडारण';

  @override
  String get storageVolumeDescriptionFallbackNonPrimary => 'एसडी कार्ड';

  @override
  String get rootDirectoryDescription => 'root directory';

  @override
  String otherDirectoryDescription(String name) {
    return '“$name” directory';
  }

  @override
  String storageAccessDialogMessage(String directory, String volume) {
    return 'अगले स्क्रीन में \"$volume\" के $directory का चयन करें ताकि यह ऐप इसके लिए पहुंच सके।।';
  }

  @override
  String restrictedAccessDialogMessage(String directory, String volume) {
    return 'इस एप्लिकेशन को \"$volume\" की $directory में फ़ाइलों को संशोधित करने की अनुमति नहीं है।\n\nकृपया किसी अन्य directory में आइटम स्थानांतरित करने के लिए एक पूर्व-स्थापित फ़ाइल प्रबंधक या गैलरी ऐप का उपयोग करें।।';
  }

  @override
  String notEnoughSpaceDialogMessage(String neededSize, String freeSize, String volume) {
    return 'इस ऑपरेशन को पूरा करने के लिए \"$volume\" पर “$neededSize” खाली जगह की आवश्यकता है, लेकिन केवल $freeSize जगह है।।';
  }

  @override
  String get missingSystemFilePickerDialogMessage => 'सिस्टम फ़ाइल पिकर लापता या अक्षम है। कृपया इसे सक्षम करें और फिर से प्रयास करें।।';

  @override
  String unsupportedTypeDialogMessage(int count, String types) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'यह ऑपरेशन निम्न प्रकार के आइटम के लिए समर्थित नहीं है: $types.',
      one: 'यह ऑपरेशन निम्न प्रकार के आइटम के लिए समर्थित नहीं है: $types.',
    );
    return '$_temp0';
  }

  @override
  String get nameConflictDialogSingleSourceMessage => 'गंतव्य फ़ोल्डर में कुछ फ़ाइलों का नाम समान है।।';

  @override
  String get nameConflictDialogMultipleSourceMessage => 'कुछ फ़ाइलों का नाम समान है।।';

  @override
  String get addShortcutDialogLabel => 'शॉर्टकट लेबल';

  @override
  String get addShortcutButtonLabel => 'ADD';

  @override
  String get noMatchingAppDialogMessage => 'इसमें कोई ऐप नहीं है जो इसे संभाल सकता है।।';

  @override
  String binEntriesConfirmationDialogMessage(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'इन $countString आइटम को रीसायकल बिन में ले जाएं?',
      one: 'इस आइटम को रीसायकल बिन में ले जाएं?',
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
      other: 'इन $countString आइटमो को हटाएं?',
      one: 'इस आइटम को हटाए?',
    );
    return '$_temp0';
  }

  @override
  String get moveUndatedConfirmationDialogMessage => 'आगे बढ़ने से पहले आइटम की तारीख सेव करे?';

  @override
  String get moveUndatedConfirmationDialogSetDate => 'तारीख सहेजें';

  @override
  String videoResumeDialogMessage(String time) {
    return 'क्या आप $time पर पुन: चलाना चाहते हैं?';
  }

  @override
  String get videoStartOverButtonLabel => 'पुन: प्रारंभ करें';

  @override
  String get videoResumeButtonLabel => 'पुन: चलाएं';

  @override
  String get setCoverDialogLatest => 'नवीनतम आइटम';

  @override
  String get setCoverDialogAuto => 'ऑटो';

  @override
  String get setCoverDialogCustom => 'कस्टम';

  @override
  String get hideFilterConfirmationDialogMessage => 'मैचिंग तस्वीरें और वीडियो आपके कलेक्शन से छिपे होंगे। आप उन्हें फिर से \"गोपनीयता\" सेटिंग्स से दिखा सकते हैं।\n\nक्या आप उन्हें छिपाना चाहते हैं?';

  @override
  String get newAlbumDialogTitle => 'नया एल्बम';

  @override
  String get newAlbumDialogNameLabel => 'एल्बम का नाम';

  @override
  String get newAlbumDialogAlbumAlreadyExistsHelper => 'एल्बम पहले से उपलब्ध हैं';

  @override
  String get newAlbumDialogNameLabelAlreadyExistsHelper => 'डायरेक्टरी पहले से मौजूद';

  @override
  String get newAlbumDialogStorageLabel => 'स्टोरेज:';

  @override
  String get newDynamicAlbumDialogTitle => 'नया डायनेमिक एल्बम';

  @override
  String get dynamicAlbumAlreadyExists => 'डायनेमिक एल्बम पहले से ही मौजूद है';

  @override
  String get newVaultWarningDialogMessage => 'वॉल्ट में आइटम केवल इस ऐप के लिए व अन्य के लिए नहीं उपलब्ध हैं।\n\nयदि आप इस ऐप को अनइंस्टॉल करते हैं, या इस ऐप डेटा को साफ़ करते हैं, तो आप इन सभी आइटम को खो देंगे।।';

  @override
  String get newVaultDialogTitle => 'नया वॉल्ट';

  @override
  String get configureVaultDialogTitle => 'वॉल्ट को कॉन्फ़िगर करना';

  @override
  String get vaultDialogLockModeWhenScreenOff => 'लॉक करे,जब स्क्रीन बंद हो जाती है';

  @override
  String get vaultDialogLockTypeLabel => 'लॉक प्रकार';

  @override
  String get patternDialogEnter => 'पैटर्न दर्ज करें';

  @override
  String get patternDialogConfirm => 'पैटर्न कन्फर्म करे';

  @override
  String get pinDialogEnter => 'पिन दर्ज करें';

  @override
  String get pinDialogConfirm => 'पिन कन्फर्म करें';

  @override
  String get passwordDialogEnter => 'पासवर्ड दर्ज करें';

  @override
  String get passwordDialogConfirm => 'पासवर्ड कन्फर्म करें';

  @override
  String get authenticateToConfigureVault => 'वॉल्ट को कॉन्फ़िगर करने के लिए प्रमाणीकरण करें';

  @override
  String get authenticateToUnlockVault => 'वॉल्ट को अनलॉक करने के लिए प्रमाणीकरण करें';

  @override
  String get vaultBinUsageDialogMessage => 'कुछ वॉल्ट्स रीसायकल बिन का उपयोग कर रहे हैं।।';

  @override
  String get renameAlbumDialogLabel => 'नया नाम';

  @override
  String get renameAlbumDialogLabelAlreadyExistsHelper => 'डायरेक्टरी पहले से मौजूद';

  @override
  String get renameEntrySetPageTitle => 'नाम बदलें';

  @override
  String get renameEntrySetPagePatternFieldLabel => 'नामकरण पैटर्न';

  @override
  String get renameEntrySetPageInsertTooltip => 'फ़ील्ड डालें';

  @override
  String get renameEntrySetPagePreviewSectionTitle => 'पूर्वावलोकन';

  @override
  String get renameProcessorCounter => 'काउंटर';

  @override
  String get renameProcessorHash => 'हैश';

  @override
  String get renameProcessorName => 'नाम';

  @override
  String deleteSingleAlbumConfirmationDialogMessage(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'यह एल्बम और इसमें मौजूद $countString हटाएं?',
      one: 'यह एल्बम और इसमें मौजूद आइटम हटाएं?',
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
      other: 'ये एल्बम और उनमें मौजूद $countString आइटम हटाएं?',
      one: 'ये एल्बम और उनमें मौजूद आइटम हटाएं?',
    );
    return '$_temp0';
  }

  @override
  String get exportEntryDialogFormat => 'फॉर्मेट:';

  @override
  String get exportEntryDialogWidth => 'चौड़ाई';

  @override
  String get exportEntryDialogHeight => 'ऊंचाई';

  @override
  String get exportEntryDialogQuality => 'गुणवत्ता';

  @override
  String get exportEntryDialogWriteMetadata => 'मेटाडाटा लिखें';

  @override
  String get renameEntryDialogLabel => 'नया नाम';

  @override
  String get editEntryDialogCopyFromItem => 'अन्य आइटम से कॉपी करें';

  @override
  String get editEntryDialogTargetFieldsHeader => 'संशोधित करने के लिए फ़ील्ड';

  @override
  String get editEntryDateDialogTitle => 'तारीख और समय';

  @override
  String get editEntryDateDialogSetCustom => 'कस्टम तिथि सेट करें';

  @override
  String get editEntryDateDialogCopyField => 'अन्य तारीख से कॉपी करें';

  @override
  String get editEntryDateDialogExtractFromTitle => 'शीर्षक से निकालें';

  @override
  String get editEntryDateDialogShift => 'शिफ्ट';

  @override
  String get editEntryDateDialogSourceFileModifiedDate => 'फ़ाइल संशोधित दिनांक';

  @override
  String get durationDialogHours => 'घंटे';

  @override
  String get durationDialogMinutes => 'मिनट';

  @override
  String get durationDialogSeconds => 'सेकंड';

  @override
  String get editEntryLocationDialogTitle => 'स्थान';

  @override
  String get editEntryLocationDialogSetCustom => 'कस्टम स्थान सेट करें';

  @override
  String get editEntryLocationDialogChooseOnMap => 'मानचित्र पर चुनें';

  @override
  String get editEntryLocationDialogImportGpx => 'GPX इंपोर्ट करे';

  @override
  String get editEntryLocationDialogLatitude => 'अक्षांश';

  @override
  String get editEntryLocationDialogLongitude => 'देशांतर';

  @override
  String get editEntryLocationDialogTimeShift => 'टाइम शिफ्ट';

  @override
  String get locationPickerUseThisLocationButton => 'इस स्थान का उपयोग करें';

  @override
  String get editEntryRatingDialogTitle => 'रेटिंग';

  @override
  String get removeEntryMetadataDialogTitle => 'मेटाडाटा हटाना';

  @override
  String get removeEntryMetadataDialogAll => 'सभी';

  @override
  String get removeEntryMetadataDialogMore => 'अधिक';

  @override
  String get removeEntryMetadataMotionPhotoXmpWarningDialogMessage => 'मोशन फोटो के अंदर वीडियो चलाने के लिए XMP की जरूरत है\n\nक्या आप वास्तव में इसे हटाना चाहते हैं?';

  @override
  String get videoSpeedDialogLabel => 'चलाने की गति';

  @override
  String get videoStreamSelectionDialogVideo => 'वीडियो';

  @override
  String get videoStreamSelectionDialogAudio => 'ऑडियो';

  @override
  String get videoStreamSelectionDialogText => 'उपशीर्षक';

  @override
  String get videoStreamSelectionDialogOff => 'बंद';

  @override
  String get videoStreamSelectionDialogTrack => 'ट्रैक';

  @override
  String get videoStreamSelectionDialogNoSelection => 'कोई अन्य ट्रैक नहीं हैं।';

  @override
  String get genericSuccessFeedback => 'हो गया!';

  @override
  String get genericFailureFeedback => 'असफल';

  @override
  String get genericDangerWarningDialogMessage => 'क्या आपको यकीन है?';

  @override
  String get tooManyItemsErrorDialogMessage => 'कम आइटम के साथ पुनः प्रयास करें।';

  @override
  String get menuActionConfigureView => 'देखें';

  @override
  String get menuActionSelect => 'चूने';

  @override
  String get menuActionSelectAll => 'सभी चुने';

  @override
  String get menuActionSelectNone => 'कुछ मत चुने';

  @override
  String get menuActionMap => 'मैप';

  @override
  String get menuActionSlideshow => 'स्लाइड शो';

  @override
  String get menuActionStats => 'आँकड़े';

  @override
  String get viewDialogSortSectionTitle => 'क्रम से लगाए';

  @override
  String get viewDialogGroupSectionTitle => 'समूह में रखे';

  @override
  String get viewDialogLayoutSectionTitle => 'लेआउट';

  @override
  String get viewDialogReverseSortOrder => 'क्रम उलटा करे';

  @override
  String get tileLayoutMosaic => 'मौज़ेक';

  @override
  String get tileLayoutGrid => 'ग्रिड';

  @override
  String get tileLayoutList => 'सूची';

  @override
  String get castDialogTitle => 'कास्ट डिवाइस';

  @override
  String get coverDialogTabCover => 'ढखें';

  @override
  String get coverDialogTabApp => 'ऐप';

  @override
  String get coverDialogTabColor => 'रंग';

  @override
  String get appPickDialogTitle => 'ऐप चुनें';

  @override
  String get appPickDialogNone => 'कोई नहीं';

  @override
  String get aboutPageTitle => 'बारे में';

  @override
  String get aboutLinkLicense => 'लाइसेंस';

  @override
  String get aboutLinkPolicy => 'गोपनीयता नीति';

  @override
  String get aboutBugSectionTitle => 'बग रिपोर्ट';

  @override
  String get aboutBugSaveLogInstruction => 'ऐप लॉग को फ़ाइल में सहेजें';

  @override
  String get aboutBugCopyInfoInstruction => 'सिस्टम जानकारी कॉपी करें';

  @override
  String get aboutBugCopyInfoButton => 'कोपी';

  @override
  String get aboutBugReportInstruction => 'लॉग और सिस्टम जानकारी के साथ GitHub पर रिपोर्ट करें';

  @override
  String get aboutBugReportButton => 'रिपोर्ट दे';

  @override
  String get aboutDataUsageSectionTitle => 'डेटा उपयोग';

  @override
  String get aboutDataUsageData => 'डेटा';

  @override
  String get aboutDataUsageCache => 'कैश';

  @override
  String get aboutDataUsageDatabase => 'डेटाबेस';

  @override
  String get aboutDataUsageMisc => 'विविध';

  @override
  String get aboutDataUsageInternal => 'आंतरिक';

  @override
  String get aboutDataUsageExternal => 'बाहरी';

  @override
  String get aboutDataUsageClearCache => 'कैश साफ़ करें';

  @override
  String get aboutCreditsSectionTitle => 'क्रेडिट';

  @override
  String get aboutCreditsWorldAtlas1 => 'यह ऐप TopoJSON फ़ाइल का उपयोग करता है';

  @override
  String get aboutCreditsWorldAtlas2 => 'आईएससी लाइसेंस के तहत।';

  @override
  String get aboutTranslatorsSectionTitle => 'अनुवादक';

  @override
  String get aboutLicensesSectionTitle => 'ओपन सोर्स लाइसेंस';

  @override
  String get aboutLicensesBanner => 'यह ऐप निम्नलिखित ओपन सोर्स पैकेज और पुस्तकालयों का उपयोग करता है।';

  @override
  String get aboutLicensesAndroidLibrariesSectionTitle => 'एंड्रॉइड लाइब्रेरीज़';

  @override
  String get aboutLicensesFlutterPluginsSectionTitle => 'फ्लटर प्लगइन्स';

  @override
  String get aboutLicensesFlutterPackagesSectionTitle => 'फ्लटर पैकेज';

  @override
  String get aboutLicensesDartPackagesSectionTitle => 'डार्ट पैकेज';

  @override
  String get aboutLicensesShowAllButtonLabel => 'सभी लाइसेंस दिखाएं';

  @override
  String get policyPageTitle => 'गोपनीयता नीति';

  @override
  String get collectionPageTitle => 'संग्रह';

  @override
  String get collectionPickPageTitle => 'चुने';

  @override
  String get collectionSelectPageTitle => 'आइटम चुनें';

  @override
  String get collectionActionShowTitleSearch => 'शीर्षक फ़िल्टर दिखाएं';

  @override
  String get collectionActionHideTitleSearch => 'शीर्षक फ़िल्टर छुपाएं';

  @override
  String get collectionActionAddDynamicAlbum => 'डायनेमिक एल्बम जोड़े';

  @override
  String get collectionActionAddShortcut => 'शॉर्टकट जोड़ें';

  @override
  String get collectionActionSetHome => 'घर के रूप में सेट करें';

  @override
  String get collectionActionEmptyBin => 'बीन खाली करे';

  @override
  String get collectionActionCopy => 'एल्बम में कॉपी करें';

  @override
  String get collectionActionMove => 'एल्बम पर जाएँ';

  @override
  String get collectionActionRescan => 'पुन: स्कैन करे';

  @override
  String get collectionActionEdit => 'एडिट करे';

  @override
  String get collectionSearchTitlesHintText => 'शीर्षक खोजें';

  @override
  String get collectionGroupAlbum => 'एल्बम के अनुसार';

  @override
  String get collectionGroupMonth => 'महीने के अनुसार';

  @override
  String get collectionGroupDay => 'दिन के अनुसार';

  @override
  String get collectionGroupNone => 'समूह न बनाएं';

  @override
  String get sectionUnknown => 'अज्ञात';

  @override
  String get dateToday => 'आज';

  @override
  String get dateYesterday => 'कल';

  @override
  String get dateThisMonth => 'इस महीने';

  @override
  String collectionDeleteFailureFeedback(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString आइटम हटाने में विफल',
      one: '1 आइटम हटाने में विफल',
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
      other: '$countString आइटम कॉपी करने में विफल',
      one: '1 आइटम कॉपी करने में विफल',
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
      other: '$countString आइटम ले जाने में विफल',
      one: '1 आइटम ले जाने में विफल',
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
      other: '$countString आइटम का नाम बदलने में विफल',
      one: '1 आइटम का नाम बदलने में विफल',
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
      other: '$countString आइटम एडिट करने में विफल',
      one: '1 आइटम एडिट करने में विफल',
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
      other: '$countString पन्ने निर्यात करने में विफल',
      one: '1 पन्ना निर्यात करने में विफल',
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
      other: '$countString आइटम कॉपी किए गए',
      one: '1 आइटम कॉपी किया गया',
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
      other: '$countString आइटम स्थानांतरित किए गए',
      one: '1 आइटम स्थानांतरित किया गया',
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
      other: '$countString आइटम का नाम बदला गया',
      one: '1 आइटम का नाम बदला गया',
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
      other: '$countString आइटम संपादित किए गए',
      one: '1 आइटम संपादित किया गया',
    );
    return '$_temp0';
  }

  @override
  String get collectionEmptyFavourites => 'कोई पसंदीदा नहीं';

  @override
  String get collectionEmptyVideos => 'कोई वीडियो नहीं';

  @override
  String get collectionEmptyImages => 'कोई इमेज नहीं';

  @override
  String get collectionEmptyGrantAccessButtonLabel => 'पहुंच प्रदान करें';

  @override
  String get collectionSelectSectionTooltip => 'अनुभाग चुनें';

  @override
  String get collectionDeselectSectionTooltip => 'अनुभाग का चयन रद्द करें';

  @override
  String get drawerAboutButton => 'के बारे में';

  @override
  String get drawerSettingsButton => 'सेटिंग्स';

  @override
  String get drawerCollectionAll => 'सभी संग्रह';

  @override
  String get drawerCollectionFavourites => 'पसंदीदा';

  @override
  String get drawerCollectionImages => 'इमेजेस';

  @override
  String get drawerCollectionVideos => 'वीडियो';

  @override
  String get drawerCollectionAnimated => 'एनिमेटेड';

  @override
  String get drawerCollectionMotionPhotos => 'मोशन तस्वीरें';

  @override
  String get drawerCollectionPanoramas => 'पैनोरामा';

  @override
  String get drawerCollectionRaws => 'रॉ फ़ोटो';

  @override
  String get drawerCollectionSphericalVideos => '360⁰ वीडियो';

  @override
  String get drawerAlbumPage => 'एल्बम';

  @override
  String get drawerCountryPage => 'देश';

  @override
  String get drawerPlacePage => 'स्थान';

  @override
  String get drawerTagPage => 'टैग्स';

  @override
  String get sortByDate => 'दिनांक से';

  @override
  String get sortByName => 'नाम से';

  @override
  String get sortByItemCount => 'आइटम गणना के द्वारा';

  @override
  String get sortBySize => 'साइज से';

  @override
  String get sortByAlbumFileName => 'एल्बम और फाइल नाम से';

  @override
  String get sortByRating => 'रेटिंग से';

  @override
  String get sortByDuration => 'समय के अनुसार';

  @override
  String get sortOrderNewestFirst => 'नए पहले';

  @override
  String get sortOrderOldestFirst => 'पूराने पहले';

  @override
  String get sortOrderAtoZ => 'A से Z';

  @override
  String get sortOrderZtoA => 'Z से A';

  @override
  String get sortOrderHighestFirst => 'उच्चतम पहले';

  @override
  String get sortOrderLowestFirst => 'निम्नतम पहले';

  @override
  String get sortOrderLargestFirst => 'सबसे बड़ा पहले';

  @override
  String get sortOrderSmallestFirst => 'सबसे छोटा पहले';

  @override
  String get sortOrderShortestFirst => 'छोटा पहले';

  @override
  String get sortOrderLongestFirst => 'सबसे लंबा पहले';

  @override
  String get albumGroupTier => 'टियर से';

  @override
  String get albumGroupType => 'टाइप द्वारा';

  @override
  String get albumGroupVolume => 'स्टोरेज मात्रा के अनुसार';

  @override
  String get albumGroupNone => 'ग्रुप न बनाए';

  @override
  String get albumMimeTypeMixed => 'मिक्सड';

  @override
  String get albumPickPageTitleCopy => 'एल्बम में कॉपी करे';

  @override
  String get albumPickPageTitleExport => 'एल्बम में एक्सपोर्ट करे';

  @override
  String get albumPickPageTitleMove => 'एल्बम में स्थानांतरित करे';

  @override
  String get albumPickPageTitlePick => 'एल्बम चुने';

  @override
  String get albumCamera => 'कैमरा';

  @override
  String get albumDownload => 'डाउनलोड';

  @override
  String get albumScreenshots => 'स्क्रीनशॉट';

  @override
  String get albumScreenRecordings => 'स्क्रीन रिकॉर्डिंग';

  @override
  String get albumVideoCaptures => 'वीडियो कैप्चर';

  @override
  String get albumPageTitle => 'एल्बम';

  @override
  String get albumEmpty => 'कोई एल्बम नहीं l';

  @override
  String get createAlbumButtonLabel => 'बनाए';

  @override
  String get newFilterBanner => 'नया';

  @override
  String get countryPageTitle => 'देशों';

  @override
  String get countryEmpty => 'कोई देश नहीं';

  @override
  String get statePageTitle => 'राज्य/देश';

  @override
  String get stateEmpty => 'कौन राज्य नहीं';

  @override
  String get placePageTitle => 'स्थान';

  @override
  String get placeEmpty => 'कोई स्थान नहीं';

  @override
  String get tagPageTitle => 'टैग्स';

  @override
  String get tagEmpty => 'कोई टैग नहीं';

  @override
  String get binPageTitle => 'रिसाइकल बिन';

  @override
  String get explorerPageTitle => 'एक्सप्लोरर';

  @override
  String get explorerActionSelectStorageVolume => 'स्टोरेज चुने';

  @override
  String get selectStorageVolumeDialogTitle => 'स्टोरेज';

  @override
  String get searchCollectionFieldHint => 'कलेक्शन खोजें';

  @override
  String get searchRecentSectionTitle => 'हाल ही का';

  @override
  String get searchDateSectionTitle => 'दिनांक';

  @override
  String get searchFormatSectionTitle => 'Formats';

  @override
  String get searchAlbumsSectionTitle => 'एल्बम';

  @override
  String get searchCountriesSectionTitle => 'देशों';

  @override
  String get searchStatesSectionTitle => 'राज्य/देश';

  @override
  String get searchPlacesSectionTitle => 'स्थान';

  @override
  String get searchTagsSectionTitle => 'टैग';

  @override
  String get searchRatingSectionTitle => 'रेटिंग';

  @override
  String get searchMetadataSectionTitle => 'मेटाडाटा';

  @override
  String get settingsPageTitle => 'सेटिंग्स';

  @override
  String get settingsSystemDefault => 'सिस्टम डिफॉल्ट';

  @override
  String get settingsDefault => 'डिफॉल्ट';

  @override
  String get settingsDisabled => 'डिसेबल किया गया';

  @override
  String get settingsAskEverytime => 'हर बार पूछे';

  @override
  String get settingsModificationWarningDialogMessage => 'अन्य सेटिंग्स परिवर्तित की जाएगी';

  @override
  String get settingsSearchFieldLabel => 'सेटिंग्स खोजें';

  @override
  String get settingsSearchEmpty => 'कोई सेटिंग्स नहीं मिली';

  @override
  String get settingsActionExport => 'एक्सपोर्ट';

  @override
  String get settingsActionExportDialogTitle => 'एक्सपोर्ट';

  @override
  String get settingsActionImport => 'इंपोर्ट';

  @override
  String get settingsActionImportDialogTitle => 'इंपोर्ट';

  @override
  String get appExportCovers => 'कवर';

  @override
  String get appExportDynamicAlbums => 'डायनेमिक एल्बम';

  @override
  String get appExportFavourites => 'पसंदीदा';

  @override
  String get appExportSettings => 'सेटिंग्स';

  @override
  String get settingsNavigationSectionTitle => 'नेविगेशन';

  @override
  String get settingsHomeTile => 'होम';

  @override
  String get settingsHomeDialogTitle => 'होम';

  @override
  String get setHomeCustom => 'कस्टम';

  @override
  String get settingsShowBottomNavigationBar => 'नेविगेशन बार दिखाए';

  @override
  String get settingsKeepScreenOnTile => 'स्क्रीन को चालू रखें';

  @override
  String get settingsKeepScreenOnDialogTitle => 'स्क्रीन को चालू रखें';

  @override
  String get settingsDoubleBackExit => 'बाहर जाने के लिए \"पीछे\" दो बार दबाए';

  @override
  String get settingsConfirmationTile => 'पुष्टीकरण डायलॉग';

  @override
  String get settingsConfirmationDialogTitle => 'पुष्टीकरण डायलॉग';

  @override
  String get settingsConfirmationBeforeDeleteItems => 'आइटम को हमेशा के लिए डीलीट करने से पहले पूछे';

  @override
  String get settingsConfirmationBeforeMoveToBinItems => 'आइटम को रिसाइकल बिन में ले जाने से पहले पूछे';

  @override
  String get settingsConfirmationBeforeMoveUndatedItems => 'अदिनांकित आइटम को ले जाने से पहले पूछे';

  @override
  String get settingsConfirmationAfterMoveToBinItems => 'आइटम को रिसाइकिल बिन में ले जाने के बाद संदेश दिखाए';

  @override
  String get settingsConfirmationVaultDataLoss => 'वोल्ट (संदूक) के डाटा लॉस की चेतावनी दिखाए';

  @override
  String get settingsNavigationDrawerTile => 'नेविगेशन मेनू';

  @override
  String get settingsNavigationDrawerEditorPageTitle => 'नेविगेशन मेनू';

  @override
  String get settingsNavigationDrawerBanner => 'मेनू आइटम को ले जाने व रिआर्डर करने के लिए टच और होल्ड करें';

  @override
  String get settingsNavigationDrawerTabTypes => 'टाइप्स';

  @override
  String get settingsNavigationDrawerTabAlbums => 'एल्बम';

  @override
  String get settingsNavigationDrawerTabPages => 'पेज़';

  @override
  String get settingsNavigationDrawerAddAlbum => 'एल्बम जोड़े';

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
