// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Burmese (`my`).
class AppLocalizationsMy extends AppLocalizations {
  AppLocalizationsMy([String locale = 'my']) : super(locale);

  @override
  String get appName => 'Aves';

  @override
  String get welcomeMessage => 'Aves မှ ကြိုဆိုပါတယ်';

  @override
  String get welcomeOptional => 'မရွေးဘဲထားနိုင်သည်';

  @override
  String get welcomeTermsToggle => 'စည်းမျဥ်းစည်းကမ်းနှင့် သတ်မှတ်ချက်များကို သဘောတူပါသည်';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ခု',
    );
    return '$_temp0';
  }

  @override
  String columnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ကော်လံ',
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
      other: '$countString စက္ကန့်',
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
      other: '$countString မိနစ်',
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
      other: '$countString ရက်',
    );
    return '$_temp0';
  }

  @override
  String focalLength(String length) {
    return '$length မီလီမီတာ';
  }

  @override
  String get applyButtonLabel => 'လုပ်ဆောင်မည်';

  @override
  String get deleteButtonLabel => 'ဖျက်မည်';

  @override
  String get nextButtonLabel => 'ရှေ့သို့';

  @override
  String get showButtonLabel => 'ပြရန်';

  @override
  String get hideButtonLabel => 'ဝှက်ရန်';

  @override
  String get continueButtonLabel => 'ရှေ့ဆက်သွားရန်';

  @override
  String get saveCopyButtonLabel => 'မိတ္တူကိုသိမ်းမည်';

  @override
  String get applyTooltip => 'လုပ်ဆောင်မည်';

  @override
  String get cancelTooltip => 'မလုပ်တော့ပါ';

  @override
  String get changeTooltip => 'ပြောင်းမည်';

  @override
  String get clearTooltip => 'ရှင်းလင်းမည်';

  @override
  String get previousTooltip => 'နောက်သို့';

  @override
  String get nextTooltip => 'ရှေ့သို့';

  @override
  String get showTooltip => 'ပြရန်';

  @override
  String get hideTooltip => 'ဝှက်ရန်';

  @override
  String get actionRemove => 'ဖယ်ရှားမည်';

  @override
  String get resetTooltip => 'အရင်အတိုင်းပြန်ထားမည်';

  @override
  String get saveTooltip => 'သိမ်းမည်';

  @override
  String get stopTooltip => 'Stop';

  @override
  String get pickTooltip => 'ရွေးရန်';

  @override
  String get doubleBackExitMessage => 'ထွက်ရန် \"နောက်သို့\" ခလုတ်ကို ထပ်နှိပ်ပါ။';

  @override
  String get doNotAskAgain => 'ထပ်မမေးပါနှင့်';

  @override
  String get sourceStateLoading => 'လုပ်ဆောင်နေသည်';

  @override
  String get sourceStateCataloguing => 'မက်တာဒေတာများ ဖန်တီးနေသည်';

  @override
  String get sourceStateLocatingCountries => 'နိုင်ငံတည်နေရာများ';

  @override
  String get sourceStateLocatingPlaces => 'နေရာ တည်နေရာများ';

  @override
  String get chipActionDelete => 'ဖျက်ရန်';

  @override
  String get chipActionRemove => 'Remove';

  @override
  String get chipActionShowCollection => 'စုစည်းမှုထဲမှာ ပြရန်';

  @override
  String get chipActionGoToAlbumPage => 'အယ်လ်ဘမ်တွေထဲမှာပြရန်';

  @override
  String get chipActionGoToCountryPage => 'နိုင်ငံတွေထဲမှာပြရန်';

  @override
  String get chipActionGoToPlacePage => 'နေရာများထဲတွင်ပြရန်';

  @override
  String get chipActionGoToTagPage => 'အမှတ်အသားများတွင်ပြရန်';

  @override
  String get chipActionGoToExplorerPage => 'Show in Explorer';

  @override
  String get chipActionDecompose => 'Split';

  @override
  String get chipActionFilterOut => 'စစ်ထုတ်ရန်';

  @override
  String get chipActionFilterIn => 'စစ်သွင်းရန်';

  @override
  String get chipActionHide => 'ဝှက်';

  @override
  String get chipActionLock => 'သော့ခတ်';

  @override
  String get chipActionPin => 'ထိပ်ဆုံးသို့ပင်တွဲရန်';

  @override
  String get chipActionUnpin => 'ထိပ်ဆုံးမှပင်ဖြုတ်ရန်';

  @override
  String get chipActionRename => 'အမည်ပြောင်းရန်';

  @override
  String get chipActionSetCover => 'ကာဗာပုံအဖြစ်ထားရန်';

  @override
  String get chipActionShowCountryStates => 'နိုင်ငံများပြရန်';

  @override
  String get chipActionCreateAlbum => 'အယ်လ်ဘမ်ဖန်တီးရန်';

  @override
  String get chipActionCreateVault => 'လျှို့ဝှက်သိုလှောင်ခန်း ဖန်တီးရန်';

  @override
  String get chipActionConfigureVault => 'လျှို့ဝှက်သိုလှောင်ခန်းကို ပြင်ဆင်ရန်';

  @override
  String get entryActionCopyToClipboard => 'ကလစ်ဘုတ်သို့ကော်ပီကူးရန်';

  @override
  String get entryActionDelete => 'ဖျက်ရန်';

  @override
  String get entryActionConvert => 'ဖိုင်ပုံစံပြောင်းရန်';

  @override
  String get entryActionExport => 'ပို့ရန်';

  @override
  String get entryActionInfo => 'ဖိုင်အချက်အလက်';

  @override
  String get entryActionRename => 'အမည်ပြောင်းရန်';

  @override
  String get entryActionRestore => 'ပြန်ယူရန်';

  @override
  String get entryActionRotateCCW => 'နာရီလက်တံပြောင်းပြန်အတိုင်း လှည့်ရန်';

  @override
  String get entryActionRotateCW => 'နာရီလက်တံအတိုင်း လှည့်ရန်';

  @override
  String get entryActionFlip => 'အလျားလိုက် လှန်ရန်';

  @override
  String get entryActionPrint => 'ပရင့်ထုတ်ရန်';

  @override
  String get entryActionShare => 'မျှဝေရန်';

  @override
  String get entryActionShareImageOnly => 'ပုံကိုသာ မျှဝေမည်';

  @override
  String get entryActionShareVideoOnly => 'ဗီဒီယိုကိုသာ မျှဝေမည်';

  @override
  String get entryActionViewSource => 'ရင်းမြစ်ကို ကြည့်ရန်';

  @override
  String get entryActionShowGeoTiffOnMap => 'မြေပုံ overlay အဖြစ် ပြရန်';

  @override
  String get entryActionConvertMotionPhotoToStillImage => 'ပုံအသေသို့ ပြောင်းရန်';

  @override
  String get entryActionViewMotionPhotoVideo => 'ဗီဒီယိုဖွင့်ရန်';

  @override
  String get entryActionEdit => 'ပြင်ဆင်ရန်';

  @override
  String get entryActionOpen => 'တခြားအက်ပ်ဖြင့် ဖွင့်ရန်';

  @override
  String get entryActionSetAs => '…ပုံအဖြစ် ထားရန်';

  @override
  String get entryActionCast => 'Cast';

  @override
  String get entryActionOpenMap => 'မြေပုံကြည့်အက်ပ်တွင် ပြရန်';

  @override
  String get entryActionRotateScreen => 'စကရင်ကို လှည့်ရန်';

  @override
  String get entryActionAddFavourite => 'အကြိုက်ဆုံးများသို့ ထည့်ရန်';

  @override
  String get entryActionRemoveFavourite => 'အကြိုက်ဆုံးများမှ ဖယ်ရှားရန်';

  @override
  String get videoActionCaptureFrame => 'လက်ရှိဖရိန်ကိုဖမ်းယူရန်';

  @override
  String get videoActionMute => 'အသံပိတ်ရန်';

  @override
  String get videoActionUnmute => 'အသံပြန်ဖွင့်ရန်';

  @override
  String get videoActionPause => 'ခဏရပ်ရန်';

  @override
  String get videoActionPlay => 'ဖွင့်ရန်';

  @override
  String get videoActionReplay10 => 'နောက်သို့ ၁၀ စက္ကန့်ဆုတ်';

  @override
  String get videoActionSkip10 => 'ရှေ့သို့ ၁၀ စက္ကန့်သွား';

  @override
  String get videoActionShowPreviousFrame => 'Show previous frame';

  @override
  String get videoActionShowNextFrame => 'Show next frame';

  @override
  String get videoActionSelectStreams => 'အသံဖိုင်ရွေးရန်';

  @override
  String get videoActionSetSpeed => 'ဖွင့်ကြည့်မှု အမြန်နှုန်း';

  @override
  String get videoActionABRepeat => 'A-B repeat';

  @override
  String get videoRepeatActionSetStart => 'Set start';

  @override
  String get videoRepeatActionSetEnd => 'Set end';

  @override
  String get viewerActionSettings => 'ဆက်တင်များ';

  @override
  String get viewerActionLock => 'ကြည့်ရှုမှုကို လော့ခ်ခတ်ရန်';

  @override
  String get viewerActionUnlock => 'ကြည့်ရှုမှုကို လော့ခ်ပြန်ဖွင့်ရန်';

  @override
  String get slideshowActionResume => 'ဆက်ကြည့်ရန်';

  @override
  String get slideshowActionShowInCollection => 'စုစည်းမှုထဲမှာ ပြရန်';

  @override
  String get entryInfoActionEditDate => 'ရက်စွဲနှင့်အချိန်ကို ပြင်ရန်';

  @override
  String get entryInfoActionEditLocation => 'တည်နေရာပြင်ရန်';

  @override
  String get entryInfoActionEditTitleDescription => 'ခေါင်းစဥ်နှင့်ဖော်ပြချက်ကို ပြင်ရန်';

  @override
  String get entryInfoActionEditRating => 'အဆင့်သတ်မှတ်ချက်ကို ပြင်ရန်';

  @override
  String get entryInfoActionEditTags => 'Tag များကိုပြင်ရန်';

  @override
  String get entryInfoActionRemoveMetadata => 'မက်တာဒေတာများ ဖယ်ရှားရန်';

  @override
  String get entryInfoActionExportMetadata => 'မက်တာဒေတာများ ပို့ရန်';

  @override
  String get entryInfoActionRemoveLocation => 'တည်နေရာကို ဖယ်ရှားမည်';

  @override
  String get editorActionTransform => 'အသွင်ပြောင်းရန်';

  @override
  String get editorTransformCrop => 'ဖြတ်တောက်ရန်';

  @override
  String get editorTransformRotate => 'လှည့်ရန်';

  @override
  String get cropAspectRatioFree => 'ကန့်သတ်မထား';

  @override
  String get cropAspectRatioOriginal => 'မူလအတိုင်း';

  @override
  String get cropAspectRatioSquare => 'လေးထောင့်ပုံစံ';

  @override
  String get filterAspectRatioLandscapeLabel => 'တစောင်း';

  @override
  String get filterAspectRatioPortraitLabel => 'အတည့်';

  @override
  String get filterBinLabel => 'ပြန်သုံးအမှိုက်ပုံး';

  @override
  String get filterFavouriteLabel => 'အကြိုက်ဆုံး';

  @override
  String get filterNoDateLabel => 'ရက်သတ်မှတ်မထား';

  @override
  String get filterNoAddressLabel => 'လိပ်စာမပါရှိ';

  @override
  String get filterLocatedLabel => 'တည်နေရာပါရှိ';

  @override
  String get filterNoLocationLabel => 'တည်နေရာမပါရှိ';

  @override
  String get filterNoRatingLabel => 'အဆင့်သတ်မှတ်မထား';

  @override
  String get filterTaggedLabel => 'Tag တွဲထား';

  @override
  String get filterNoTagLabel => 'Tag မတွဲထား';

  @override
  String get filterNoTitleLabel => 'ခေါင်းစဥ်မပေးထား';

  @override
  String get filterOnThisDayLabel => 'ယနေ့';

  @override
  String get filterRecentlyAddedLabel => 'ထည့်ထားတာ မကြာသေး';

  @override
  String get filterRatingRejectedLabel => 'ပယ်ချထား';

  @override
  String get filterTypeAnimatedLabel => 'လှုပ်ရှားနေသောပုံ';

  @override
  String get filterTypeMotionPhotoLabel => 'လှုပ်ရှားမှုပါသောပုံ';

  @override
  String get filterTypePanoramaLabel => 'မြင်ကွင်းကျယ်ဓာတ်ပုံ';

  @override
  String get filterTypeRawLabel => 'Raw ပုံ';

  @override
  String get filterTypeSphericalVideoLabel => '၃၆၀° ဗီဒီယို';

  @override
  String get filterTypeGeotiffLabel => 'GeoTIFF';

  @override
  String get filterMimeImageLabel => 'ဓာတ်ပုံ';

  @override
  String get filterMimeVideoLabel => 'ဗီဒီယို';

  @override
  String get accessibilityAnimationsRemove => 'Prevent screen effects';

  @override
  String get accessibilityAnimationsKeep => 'Keep screen effects';

  @override
  String get albumTierNew => 'အသစ်';

  @override
  String get albumTierPinned => 'ပင်တွဲထား';

  @override
  String get albumTierSpecial => 'အကြည့်များ';

  @override
  String get albumTierApps => 'အက်ပ်အလိုက်';

  @override
  String get albumTierVaults => 'လျှို့ဝှက်သိုလှောင်ခန်းများ';

  @override
  String get albumTierDynamic => 'Dynamic';

  @override
  String get albumTierRegular => 'အခြား';

  @override
  String get coordinateFormatDms => 'DMS (ဒီဂရီ၊ မိနစ်၊ စက္ကန့်)';

  @override
  String get coordinateFormatDdm => 'DDM';

  @override
  String get coordinateFormatDecimal => 'DD (လတ္တီတွဒ်၊ လောင်ဂျီတွဒ်)';

  @override
  String coordinateDms(String coordinate, String direction) {
    return '$coordinate $direction';
  }

  @override
  String get coordinateDmsNorth => 'မြောက်';

  @override
  String get coordinateDmsSouth => 'တောင်';

  @override
  String get coordinateDmsEast => 'အရှေ့';

  @override
  String get coordinateDmsWest => 'အနောက်';

  @override
  String get displayRefreshRatePreferHighest => 'အမြင့်ဆုံးနှုန်း';

  @override
  String get displayRefreshRatePreferLowest => 'အနိမ့်ဆုံးနှုန်း';

  @override
  String get keepScreenOnNever => 'ဘယ်တော့မှမလုပ်ပါနှင့်';

  @override
  String get keepScreenOnVideoPlayback => 'ဗီဒီယိုကြည့်နေသည့်အချိန်အတွင်း';

  @override
  String get keepScreenOnViewerOnly => 'ဓာတ်ပုံ/ဗီဒီယိုကြည့်သည့်စာမျက်နှာတွင်သာ';

  @override
  String get keepScreenOnAlways => 'အမြဲတမ်း';

  @override
  String get lengthUnitPixel => 'px';

  @override
  String get lengthUnitPercent => '%';

  @override
  String get mapStyleGoogleNormal => 'Google မြေပုံ';

  @override
  String get mapStyleGoogleHybrid => 'Google မြေပုံ (ဂြိုဟ်တု)';

  @override
  String get mapStyleGoogleTerrain => 'Google မြေပုံ (မြေအနေအထားပြ)';

  @override
  String get mapStyleOsmLiberty => 'OSM Liberty';

  @override
  String get mapStyleOpenTopoMap => 'OpenTopoMap';

  @override
  String get mapStyleOsmHot => 'Humanitarian OSM';

  @override
  String get mapStyleStamenWatercolor => 'Stamen Watercolor (ရေဆေး)';

  @override
  String get maxBrightnessNever => 'ဘယ်တော့မှမလုပ်ပါနှင့်';

  @override
  String get maxBrightnessAlways => 'အမြဲတမ်း';

  @override
  String get nameConflictStrategyRename => 'အမည်ပြောင်းလိုက်ပါ';

  @override
  String get nameConflictStrategyReplace => 'အစားထိုးလိုက်ပါ';

  @override
  String get nameConflictStrategySkip => 'ကျော်လိုက်ပါ';

  @override
  String get overlayHistogramNone => 'မထား';

  @override
  String get overlayHistogramRGB => 'RGB';

  @override
  String get overlayHistogramLuminance => 'Luminance';

  @override
  String get subtitlePositionTop => 'အပေါ်ဘက်';

  @override
  String get subtitlePositionBottom => 'အောက်ဘက်';

  @override
  String get themeBrightnessLight => 'အလင်း';

  @override
  String get themeBrightnessDark => 'အမှောင်';

  @override
  String get themeBrightnessBlack => 'အနက်ရောင်';

  @override
  String get unitSystemMetric => 'မက်ထရစ်ယူနစ်';

  @override
  String get unitSystemImperial => 'ဗြိတိသျှအင်ပါယာယူနစ် (မြန်မာနိုင်ငံသုံးစနစ်)';

  @override
  String get vaultLockTypePattern => 'Pattern';

  @override
  String get vaultLockTypePin => 'PIN နံပါတ်';

  @override
  String get vaultLockTypePassword => 'စကားဝှက်';

  @override
  String get settingsVideoEnablePip => 'PiP (အခြားအက်ပ်တစ်ခုပေါ်တွင် ထပ်ပြခြင်း)';

  @override
  String get videoControlsPlayOutside => 'တခြား player နဲ့ဖွင့်တဲ့ခလုတ်';

  @override
  String get videoLoopModeNever => 'ဘယ်တော့မှမလုပ်ပါနှင့်';

  @override
  String get videoLoopModeShortOnly => 'ဗီဒီယိုအတိုလေးတွေတွင်သာ';

  @override
  String get videoLoopModeAlways => 'အမြဲတမ်း';

  @override
  String get videoPlaybackSkip => 'ကျော်လိုက်ပါ';

  @override
  String get videoPlaybackMuted => 'အသံပိတ်ပြီးဖွင့်မည်';

  @override
  String get videoPlaybackWithSound => 'အသံဖြင့်ဖွင့်မည်';

  @override
  String get videoResumptionModeNever => 'ဘယ်တော့မှမလုပ်ပါနှင့်';

  @override
  String get videoResumptionModeAlways => 'အမြဲတမ်း';

  @override
  String get viewerTransitionSlide => 'Slide';

  @override
  String get viewerTransitionParallax => 'Parallax';

  @override
  String get viewerTransitionFade => 'မှိန်သွားခြင်း';

  @override
  String get viewerTransitionZoomIn => 'ချဲ့ကားလာခြင်း';

  @override
  String get viewerTransitionNone => 'ဘာမှမထား';

  @override
  String get wallpaperTargetHome => 'ပင်မစကရင်';

  @override
  String get wallpaperTargetLock => 'လော့ခ်စကရင်';

  @override
  String get wallpaperTargetHomeLock => 'ပင်မစကရင်နှင့် လော့ခ်စကရင်';

  @override
  String get widgetDisplayedItemRandom => 'ဗျောက်သောက်';

  @override
  String get widgetDisplayedItemMostRecent => 'အသစ်အဖြစ်ဆုံး';

  @override
  String get widgetOpenPageHome => 'Open home';

  @override
  String get widgetOpenPageCollection => 'Open collection';

  @override
  String get widgetOpenPageViewer => 'Open viewer';

  @override
  String get widgetTapUpdateWidget => 'ဝစ်ဂျက်ကို အပ်ဒိတ်လုပ်ရန်';

  @override
  String get storageVolumeDescriptionFallbackPrimary => 'စက်တွင်းသိုလှောင်မှု';

  @override
  String get storageVolumeDescriptionFallbackNonPrimary => 'SD ကတ်တွင် သိုလှောင်မှု';

  @override
  String get rootDirectoryDescription => 'ထိပ်ဆုံး directory';

  @override
  String otherDirectoryDescription(String name) {
    return '“$name” directory';
  }

  @override
  String storageAccessDialogMessage(String directory, String volume) {
    return 'ယခုအက်ပ်ကို ဖိုင်ဝင်ရောက်ကြည့်ရှုခွင့်ပေးရန်အတွက် အရှေ့စကရင်သို့ရောက်လျှင် “$volume” ၏ $directory ကို ရွေးချယ်ပေးပါ။';
  }

  @override
  String restrictedAccessDialogMessage(String directory, String volume) {
    return 'ယခုအက်ပ်သည် “$volume” ၏ $directory ရှိဖိုင်များကို ပြင်ဆင်ပြောင်းလဲခွင့်မရှိပါ။\n\nကျေးဇူးပြု၍ ၎င်းဓာတ်ပုံ/ဗီဒီယိုများကို စက်တွင်းပါဝင်ပြီးသားဖိုင်မန်နေဂျာ (သို့မဟုတ်) ဓာတ်ပုံကြည့်အက်ပ်တစ်ခုခုဖြင့် အခြား directory တစ်ခုကို ရွှေ့ပြောင်းပေးပါ။';
  }

  @override
  String notEnoughSpaceDialogMessage(String neededSize, String freeSize, String volume) {
    return 'ယခုလုပ်ဆောင်ချက်ပြီးမြောက်ရန် “$volume” တွင် နေရာလွတ် $neededSize ရှိဖို့ လိုအပ်တာကြောင့် လက်ရှိနေရာလွတ် $freeSize ဖြင့် လုပ်ဆောင်၍မရနိုင်ပါ။';
  }

  @override
  String get missingSystemFilePickerDialogMessage => 'စစ်စတမ်၏ ဖိုင်ရွေးအက်ပ်ကို ပိတ်ထားပါသည် (သို့မဟုတ်) ရှာမတွေ့ပါ။ ပြန်ဖွင့်ပေးပြီးမှ ထပ်စမ်းကြည့်ပါ။';

  @override
  String unsupportedTypeDialogMessage(int count, String types) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ယခုလုပ်ဆောင်ချက်ကို ဤအမျိုးအစားများပါဖိုင်များအတွက် အထောက်အပံ့မပေးထားပါ - $types',
      one: 'ယခုလုပ်ဆောင်ချက်ကို ဤအမျိုးအစားဖိုင်များအတွက် အထောက်အပံ့မပေးထားပါ - $types',
    );
    return '$_temp0';
  }

  @override
  String get nameConflictDialogSingleSourceMessage => 'ထည့်သွင်းလိုသော folder တွင် အမည်တူဖိုင်များရှိနေသည်။';

  @override
  String get nameConflictDialogMultipleSourceMessage => 'အမည်တူဖိုင်များရှိနေသည်။';

  @override
  String get addShortcutDialogLabel => 'ဖြတ်လမ်းတိုအမည်';

  @override
  String get addShortcutButtonLabel => 'ဖန်တီးမည်';

  @override
  String get noMatchingAppDialogMessage => 'ယခုလုပ်ဆောင်ချက်ကို ကိုင်တွယ်နိုင်သောအက်ပ် ရှာမတွေ့ပါ။';

  @override
  String binEntriesConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ဒီ $count ခုကို ပြန်သုံးအမှိုက်ထဲထည့်မှာလား?',
      two: 'ဒီနှစ်ခုကို ပြန်သုံးအမှိုက်ပုံးထဲ ထည့်မှာလား?',
      one: 'ဒီတစ်ခုကို ပြန်သုံးအမှိုက်ပုံးထဲ ထည့်မှာလား?',
    );
    return '$_temp0';
  }

  @override
  String deleteEntriesConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ဒီ $count ခုကို ဖျက်မှာလား?',
      two: 'ဒီနှစ်ခုကိုဖျက်မှာလား?',
      one: 'ဒီတစ်ခုကိုဖျက်မှာလား?',
    );
    return '$_temp0';
  }

  @override
  String get moveUndatedConfirmationDialogMessage => 'ရှေ့မဆက်ခင် ဓာတ်ပုံ/ဗီဒီယိုပါ ရက်စွဲတွေကို သိမ်းမှာလား?';

  @override
  String get moveUndatedConfirmationDialogSetDate => 'သိမ်းမည်';

  @override
  String videoResumeDialogMessage(String time) {
    return 'ကြည့်လက်စ $time မိနစ်ကနေ ဆက်ကြည့်ချင်ပါသလား?';
  }

  @override
  String get videoStartOverButtonLabel => 'အစကပဲပြန်စမည်';

  @override
  String get videoResumeButtonLabel => 'ဆက်ကြည့်မည်';

  @override
  String get setCoverDialogLatest => 'နောက်ဆုံးပုံ/ဗီဒီယို';

  @override
  String get setCoverDialogAuto => 'အလိုအလျောက်';

  @override
  String get setCoverDialogCustom => 'စိတ်ကြိုက်';

  @override
  String get hideFilterConfirmationDialogMessage => 'ယခုစစ်ထုတ်မှုနှင့် ကိုက်ညီသော ဓာတ်ပုံနှင့်ဗီဒီယိုများကို စုစည်းမှုထဲမှ ဝှက်ထားမည်ဖြစ်ပါသည်။ ပြန်ဖော်ချင်ပါက “ကိုယ်ရေးကိုယ်တာလုံခြုံမှု” ဆက်တင်ထဲကနေ ပြန်ဖော်နိုင်ပါသည်။\n\nဝှက်ထားချင်တာ သေချာပါသလား?';

  @override
  String get newAlbumDialogTitle => 'အယ်လ်ဘမ်အသစ်';

  @override
  String get newAlbumDialogNameLabel => 'အယ်လ်ဘမ်အမည်';

  @override
  String get newAlbumDialogAlbumAlreadyExistsHelper => 'Album already exists';

  @override
  String get newAlbumDialogNameLabelAlreadyExistsHelper => 'Directory ရှိပြီးသားဖြစ်သည်';

  @override
  String get newAlbumDialogStorageLabel => 'သိုလှောင်မှု -';

  @override
  String get newDynamicAlbumDialogTitle => 'New Dynamic Album';

  @override
  String get dynamicAlbumAlreadyExists => 'Dynamic album already exists';

  @override
  String get newVaultWarningDialogMessage => 'လျှို့ဝှက်သိုလှောင်ခန်းရှိ ဓာတ်ပုံနှင့်ဗီဒီယိုများကို ဤအက်ပ်တွင်သာမြင်ရမည်ဖြစ်ပြီး အခြားအက်ပ်များတွင် မမြင်ရနိုင်ပါ။\n\nဤအက်ပ်ကိုဖျက်လိုက်သည်ဖြစ်စေ၊ အက်ပ်ဒေတာကိုရှင်းလင်းလိုက်သည်ဖြစ်စေ ၎င်းဓာတ်ပုံနှင့်ဗီဒီယိုအားလုံးကို ဆုံးရှုံးသွားမည်ဖြစ်ပါသည်။';

  @override
  String get newVaultDialogTitle => 'လျှို့ဝှက်သိုလှောင်ခန်းအသစ်';

  @override
  String get configureVaultDialogTitle => 'လျှို့ဝှက်သိုလှောင်ခန်းကို ပြင်ဆင်ခြင်း';

  @override
  String get vaultDialogLockModeWhenScreenOff => 'စကရင်ပိတ်လျှင် လော့ခ်ခတ်ရန်';

  @override
  String get vaultDialogLockTypeLabel => 'လော့ခ်အမျိုးအစား';

  @override
  String get patternDialogEnter => 'Pattern ဆွဲပါ';

  @override
  String get patternDialogConfirm => 'Pattern ကို အတည်ပြုပါ';

  @override
  String get pinDialogEnter => 'PIN နံပါတ် ရိုက်ထည့်ပါ';

  @override
  String get pinDialogConfirm => 'PIN နံပါတ်ကို အတည်ပြုပါ';

  @override
  String get passwordDialogEnter => 'စကားဝှက်ရိုက်ထည့်ပါ';

  @override
  String get passwordDialogConfirm => 'စကားဝှက်ကို အတည်ပြုပါ';

  @override
  String get authenticateToConfigureVault => 'လျှို့ဝှက်သိုလှောင်ခန်းကိုပြင်ဆင်ရန် သင်ဖြစ်ကြောင်းသက်သေပြပါ';

  @override
  String get authenticateToUnlockVault => 'လျှို့ဝှက်သိုလှောင်ခန်းကိုဖွင့်ရန် သင်ဖြစ်ကြောင်းသက်သေပြပါ';

  @override
  String get vaultBinUsageDialogMessage => 'ပြန်သုံးအမှိုက်ပုံးကိုအသုံးပြုနေသော လျှို့ဝှက်သိုလှောင်ခန်းများရှိသည်။';

  @override
  String get renameAlbumDialogLabel => 'အမည်အသစ်';

  @override
  String get renameAlbumDialogLabelAlreadyExistsHelper => 'Directory ရှိပြီးသားဖြစ်သည်';

  @override
  String get renameEntrySetPageTitle => 'အမည်ပြောင်းခြင်း';

  @override
  String get renameEntrySetPagePatternFieldLabel => 'အမည်ပေးခြင်းပုံစံ';

  @override
  String get renameEntrySetPageInsertTooltip => 'အကွက်ထည့်မည်';

  @override
  String get renameEntrySetPagePreviewSectionTitle => 'အစမ်းကြည့်ခြင်း';

  @override
  String get renameProcessorCounter => 'ရေတွက်မှု';

  @override
  String get renameProcessorHash => 'Hash';

  @override
  String get renameProcessorName => 'အမည်';

  @override
  String deleteSingleAlbumConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ယခုအယ်လ်ဘမ်နဲ့ အဲ့ဒီထဲက ဓာတ်ပုံ/ဗီဒီယို $count ခုကို ဖျက်မှာလား?',
      two: 'ယခုအယ်လ်ဘမ်နဲ့ အဲ့ဒီထဲက ဓာတ်ပုံ/ဗီဒီယိုနှစ်ခုကိုဖျက်မှာလား?',
      one: 'ယခုအယ်လ်ဘမ်နဲ့ အဲ့ဒီထဲက ဓာတ်ပုံ/ဗီဒီယိုကိုဖျက်မှာလား?',
    );
    return '$_temp0';
  }

  @override
  String deleteMultiAlbumConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ဒီအယ်လ်ဘမ်တွေနဲ့ အဲ့ဒီထဲက ဓာတ်ပုံ/ဗီဒီယို $count ခုကို ဖျက်မှာလား?',
      two: 'ဒီအယ်လ်ဘမ်တွေနဲ့ အဲ့ဒီထဲက ဓာတ်ပုံ/ဗီဒီယိုနှစ်ခုကိုဖျက်မှာလား?',
      one: 'ဒီအယ်လ်ဘမ်တွေနဲ့ အဲ့ဒီထဲက ဓာတ်ပုံ/ဗီဒီယိုကိုဖျက်မှာလား?',
    );
    return '$_temp0';
  }

  @override
  String get exportEntryDialogFormat => 'Format:';

  @override
  String get exportEntryDialogWidth => 'အလျား';

  @override
  String get exportEntryDialogHeight => 'အနံ';

  @override
  String get exportEntryDialogQuality => 'အရည်အသွေး';

  @override
  String get exportEntryDialogWriteMetadata => 'မက်တာဒေတာများပါ ကော်ပီကူးရန်';

  @override
  String get renameEntryDialogLabel => 'အမည်အသစ်';

  @override
  String get editEntryDialogCopyFromItem => 'တခြားပုံကနေ ကော်ပီကူးမည်';

  @override
  String get editEntryDialogTargetFieldsHeader => 'ပြင်ဆင်မည့် အကွက်များ';

  @override
  String get editEntryDateDialogTitle => 'ရက်စွဲနှင့် အချိန်';

  @override
  String get editEntryDateDialogSetCustom => 'စိတ်ကြိုက်ရက်စွဲထားမည်';

  @override
  String get editEntryDateDialogCopyField => 'တခြားရက်စွဲက ကော်ပီကူးမည်';

  @override
  String get editEntryDateDialogExtractFromTitle => 'ခေါင်းစဥ်က ယူမည်';

  @override
  String get editEntryDateDialogShift => 'အတိုးအလျှော့လုပ်မည်';

  @override
  String get editEntryDateDialogSourceFileModifiedDate => 'ဖိုင်ပြင်ဆင်ခဲ့သည့်ရက်စွဲ';

  @override
  String get durationDialogHours => 'နာရီ';

  @override
  String get durationDialogMinutes => 'မိနစ်';

  @override
  String get durationDialogSeconds => 'စက္ကန့်';

  @override
  String get editEntryLocationDialogTitle => 'တည်နေရာ';

  @override
  String get editEntryLocationDialogSetCustom => 'စိတ်ကြိုက်တည်နေရာထားမည်';

  @override
  String get editEntryLocationDialogChooseOnMap => 'မြေပုံပေါ်ကရွေးမည်';

  @override
  String get editEntryLocationDialogImportGpx => 'Import GPX';

  @override
  String get editEntryLocationDialogLatitude => 'လတ္တီတွဒ်';

  @override
  String get editEntryLocationDialogLongitude => 'လောင်ဂျီတွဒ်';

  @override
  String get editEntryLocationDialogTimeShift => 'Time shift';

  @override
  String get locationPickerUseThisLocationButton => 'ဒီနေရာကိုသုံးမည်';

  @override
  String get editEntryRatingDialogTitle => 'အဆင့်သတ်မှတ်ချက်';

  @override
  String get removeEntryMetadataDialogTitle => 'မက်တာဒေတာဖယ်ရှားခြင်း';

  @override
  String get removeEntryMetadataDialogAll => 'All';

  @override
  String get removeEntryMetadataDialogMore => 'နောက်ထပ်';

  @override
  String get removeEntryMetadataMotionPhotoXmpWarningDialogMessage => 'လှုပ်ရှားမှုပါသောပုံအတွင်းက ဗီဒီယိုကိုဖွင့်ရန် XMP ကို လိုအပ်ပါသည်။\n\nဖျက်ချင်တာသေချာပါသလား?';

  @override
  String get videoSpeedDialogLabel => 'ဖွင့်ကြည့်မှု အမြန်နှုန်း';

  @override
  String get videoStreamSelectionDialogVideo => 'ဗီဒီယို';

  @override
  String get videoStreamSelectionDialogAudio => 'အသံ';

  @override
  String get videoStreamSelectionDialogText => 'စာတန်းထိုး';

  @override
  String get videoStreamSelectionDialogOff => 'ပိတ်ထား';

  @override
  String get videoStreamSelectionDialogTrack => 'အပုဒ်';

  @override
  String get videoStreamSelectionDialogNoSelection => 'တခြားအပုဒ်မရှိပါ။';

  @override
  String get genericSuccessFeedback => 'လုပ်ဆောင်ပြီးပါပြီ!';

  @override
  String get genericFailureFeedback => 'လုပ်ဆောင်မှုမအောင်မြင်ပါ';

  @override
  String get genericDangerWarningDialogMessage => 'သေချာပါသလား?';

  @override
  String get tooManyItemsErrorDialogMessage => 'ဓာတ်ပုံ/ဗီဒီယိုနည်းနည်းလေးနဲ့ ပြန်စမ်းကြည့်ပါ။';

  @override
  String get menuActionConfigureView => 'View';

  @override
  String get menuActionSelect => 'ရွေးချယ်ရန်';

  @override
  String get menuActionSelectAll => 'အားလုံးရွေးချယ်မည်';

  @override
  String get menuActionSelectNone => 'ဘာမှမရွေးပါ';

  @override
  String get menuActionMap => 'မြေပုံ';

  @override
  String get menuActionSlideshow => 'ဆလိုက်ရှိုး';

  @override
  String get menuActionStats => 'စာရင်းအင်း';

  @override
  String get viewDialogSortSectionTitle => 'အပေါ်အောက် စီခြင်း';

  @override
  String get viewDialogGroupSectionTitle => 'စုပြခြင်း';

  @override
  String get viewDialogLayoutSectionTitle => 'အပြင်အဆင်';

  @override
  String get viewDialogReverseSortOrder => 'ပြောင်းပြန်စီရန်';

  @override
  String get tileLayoutMosaic => 'Mosaic ပုံစံ';

  @override
  String get tileLayoutGrid => 'ဇယားကွက်ပုံစံ';

  @override
  String get tileLayoutList => 'စာရင်းပုံစံ';

  @override
  String get castDialogTitle => 'Cast Devices';

  @override
  String get coverDialogTabCover => 'ကာဗာပိုင်း';

  @override
  String get coverDialogTabApp => 'အက်ပ်ပိုင်း';

  @override
  String get coverDialogTabColor => 'ကာလာပိုင်း';

  @override
  String get appPickDialogTitle => 'အက်ပ်ရွေးချယ်ပါ';

  @override
  String get appPickDialogNone => 'ဘာမှမရွေး';

  @override
  String get aboutPageTitle => 'ဤအက်ပ်အကြောင်း';

  @override
  String get aboutLinkLicense => 'လိုင်စင်';

  @override
  String get aboutLinkPolicy => 'ကိုယ်ရေးကိုယ်တာလုံခြုံမှု မူဝါဒ';

  @override
  String get aboutBugSectionTitle => 'Bug တင်ပြခြင်း';

  @override
  String get aboutBugSaveLogInstruction => 'အက်ပ်မှတ်တမ်းကို ဖိုင်တစ်ဖိုင်ထဲသို့သိမ်းပါ';

  @override
  String get aboutBugCopyInfoInstruction => 'စစ်စတမ်အချက်အလက်များကို ကော်ပီကူးပါ';

  @override
  String get aboutBugCopyInfoButton => 'ကော်ပီ';

  @override
  String get aboutBugReportInstruction => 'မှတ်တမ်းနှင့် စစ်စတမ်အချက်အလက်များကို GitHub တွင် တင်ပြပါ';

  @override
  String get aboutBugReportButton => 'တင်ပြမည်';

  @override
  String get aboutDataUsageSectionTitle => 'ဒေတာသုံးစွဲမှု';

  @override
  String get aboutDataUsageData => 'ဒေတာ';

  @override
  String get aboutDataUsageCache => 'Cache';

  @override
  String get aboutDataUsageDatabase => 'ဒေတာဘေ့စ်';

  @override
  String get aboutDataUsageMisc => 'အခြား';

  @override
  String get aboutDataUsageInternal => 'စက်တွင်း';

  @override
  String get aboutDataUsageExternal => 'စက်ပြင်ပ';

  @override
  String get aboutDataUsageClearCache => 'Clear Cache';

  @override
  String get aboutCreditsSectionTitle => 'ခရက်ဒစ်';

  @override
  String get aboutCreditsWorldAtlas1 => 'ဤအက်ပ်သည်';

  @override
  String get aboutCreditsWorldAtlas2 => 'မှ TopoJSON ဖိုင်ကို ISC လိုင်စင်အောက်တွင် အသုံးပြုထားသည်။';

  @override
  String get aboutTranslatorsSectionTitle => 'ဘာသာပြန်သူများ';

  @override
  String get aboutLicensesSectionTitle => 'Open-Source လိုင်စင်များ';

  @override
  String get aboutLicensesBanner => 'ဤအက်ပ်သည် အောက်ပါ open-source package များနှင့် library များကို အသုံးပြုထားသည်။';

  @override
  String get aboutLicensesAndroidLibrariesSectionTitle => 'Android Library များ';

  @override
  String get aboutLicensesFlutterPluginsSectionTitle => 'Flutter Plugin များ';

  @override
  String get aboutLicensesFlutterPackagesSectionTitle => 'Flutter Package များ';

  @override
  String get aboutLicensesDartPackagesSectionTitle => 'Dart Package များ';

  @override
  String get aboutLicensesShowAllButtonLabel => 'လိုင်စင်အားလုံးကြည့်ရန်';

  @override
  String get policyPageTitle => 'ကိုယ်ရေးကိုယ်တာလုံခြုံမှု မူဝါဒ';

  @override
  String get collectionPageTitle => 'စုစည်းမှု';

  @override
  String get collectionPickPageTitle => 'ရွေးချယ်ပါ';

  @override
  String get collectionSelectPageTitle => 'ပုံ/ဗီဒီယိုရွေးချယ်ပါ';

  @override
  String get collectionActionShowTitleSearch => 'ခေါင်းစဥ်စစ်ထုတ်ရန်';

  @override
  String get collectionActionHideTitleSearch => 'ခေါင်းစဥ်မစစ်ထုတ်တော့ပါ';

  @override
  String get collectionActionAddDynamicAlbum => 'Add dynamic album';

  @override
  String get collectionActionAddShortcut => 'ဖြတ်လမ်းတိုဖန်တီးရန်';

  @override
  String get collectionActionSetHome => 'Set as home';

  @override
  String get collectionActionEmptyBin => 'အမှိုက်ပုံးရှင်းလင်းရန်';

  @override
  String get collectionActionCopy => 'အယ်လ်ဘမ်သို့ကော်ပီကူးရန်';

  @override
  String get collectionActionMove => 'အယ်လ်ဘမ်သို့ရွှေ့ရန်';

  @override
  String get collectionActionRescan => 'ပြန်စကင်ဖတ်ရန်';

  @override
  String get collectionActionEdit => 'ပြင်ဆင်ရန်';

  @override
  String get collectionSearchTitlesHintText => 'ခေါင်းစဥ်ကို ရှာဖွေပါ';

  @override
  String get collectionGroupAlbum => 'အယ်လ်ဘမ်အလိုက်';

  @override
  String get collectionGroupMonth => 'လအလိုက်';

  @override
  String get collectionGroupDay => 'ရက်အလိုက်';

  @override
  String get collectionGroupNone => 'စုမပြပါနှင့်';

  @override
  String get sectionUnknown => 'မသိထားသည်များ';

  @override
  String get dateToday => 'ယနေ့';

  @override
  String get dateYesterday => 'မနေ့က';

  @override
  String get dateThisMonth => 'ယခုလ';

  @override
  String collectionDeleteFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ပုံ/ဗီဒီယို $count ခုကို ဖျက်လို့မရခဲ့ပါ',
      two: 'ပုံ/ဗီဒီယိုနှစ်ခုကို ဖျက်လို့မရခဲ့ပါ',
      one: 'ပုံ/ဗီဒီယိုတစ်ခုကို ဖျက်လို့မရခဲ့ပါ',
    );
    return '$_temp0';
  }

  @override
  String collectionCopyFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ပုံ/ဗီဒီယို $count ခုကို ကော်ပီကူးလို့မရခဲ့ပါ',
      two: 'ပုံ/ဗီဒီယိုနှစ်ခုကို ကော်ပီကူးလို့မရခဲ့ပါ',
      one: 'ပုံ/ဗီဒီယိုတစ်ခုကို ကော်ပီကူးလို့မရခဲ့ပါ',
    );
    return '$_temp0';
  }

  @override
  String collectionMoveFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ပုံ/ဗီဒီယို $count ခုကို ရွှေ့လို့မရခဲ့ပါ',
      two: 'ပုံ/ဗီဒီယိုနှစ်ခုကို ရွှေ့လို့မရခဲ့ပါ',
      one: 'ပုံ/ဗီဒီယိုတစ်ခုကို ရွှေ့လို့မရခဲ့ပါ',
    );
    return '$_temp0';
  }

  @override
  String collectionRenameFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ပုံ/ဗီဒီယို $count ခုကို အမည်ပြောင်းလို့ မရခဲ့ပါ',
      two: 'ပုံ/ဗီဒီယိုနှစ်ခုကို အမည်ပြောင်းလို့ မရခဲ့ပါ',
      one: 'ပုံ/ဗီဒီယိုတစ်ခုကို အမည်ပြောင်းလို့ မရခဲ့ပါ',
    );
    return '$_temp0';
  }

  @override
  String collectionEditFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ပုံ/ဗီဒီယို $count ခုကို ပြင်ဆင်လို့မရခဲ့ပါ',
      two: 'ပုံ/ဗီဒီယိုနှစ်ခုကို ပြင်ဆင်လို့မရခဲ့ပါ',
      one: 'ပုံ/ဗီဒီယိုတစ်ခုကို ပြင်ဆင်လို့မရခဲ့ပါ',
    );
    return '$_temp0';
  }

  @override
  String collectionExportFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'စာမျက်နှာ $count မျက်နှာကို ပို့လို့မရခဲ့ပါ',
      two: 'စာမျက်နှာနှစ်မျက်နှာကို ပို့လို့မရခဲ့ပါ',
      one: 'စာမျက်နှာတစ်မျက်နှာကို ပို့လို့မရခဲ့ပါ',
    );
    return '$_temp0';
  }

  @override
  String collectionCopySuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ပုံ/ဗီဒီယို $count ခုကို ကော်ပီကူးလိုက်သည်',
      two: 'ပုံ/ဗီဒီယိုနှစ်ခုကို ကော်ပီကူးလိုက်သည်',
      one: 'ပုံ/ဗီဒီယိုတစ်ခုကို ကော်ပီကူးလိုက်သည်',
    );
    return '$_temp0';
  }

  @override
  String collectionMoveSuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ပုံ/ဗီဒီယို $count ခုကို ရွှေ့လိုက်သည်',
      two: 'ပုံ/ဗီဒီယိုနှစ်ခုကို ရွှေ့လိုက်သည်',
      one: 'ပုံ/ဗီဒီယိုတစ်ခုကို ရွှေ့လိုက်သည်',
    );
    return '$_temp0';
  }

  @override
  String collectionRenameSuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ပုံ/ဗီဒီယို $count ခုကို အမည်ပြောင်းလိုက်သည်',
      two: 'ပုံ/ဗီဒီယိုနှစ်ခုကို အမည်ပြောင်းလိုက်သည်',
      one: 'ပုံ/ဗီဒီယိုတစ်ခုကို အမည်ပြောင်းလိုက်သည်',
    );
    return '$_temp0';
  }

  @override
  String collectionEditSuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ပုံ/ဗီဒီယို $count ခုကို ပြင်ဆင်လိုက်သည်',
      two: 'ပုံ/ဗီဒီယိုနှစ်ခုကို ပြင်ဆင်လိုက်သည်',
      one: 'ပုံ/ဗီဒီယိုတစ်ခုကို ပြင်ဆင်လိုက်သည်',
    );
    return '$_temp0';
  }

  @override
  String get collectionEmptyFavourites => 'အကြိုက်ဆုံးတစ်ခုမှ မရှိပါ';

  @override
  String get collectionEmptyVideos => 'ဗီဒီယိုတစ်ခုမှမရှိပါ';

  @override
  String get collectionEmptyImages => 'ပုံတစ်ပုံမှမရှိပါ';

  @override
  String get collectionEmptyGrantAccessButtonLabel => 'ဖိုင်ဝင်ရောက်ကြည့်ရှုခွင့်ပေးရန်';

  @override
  String get collectionSelectSectionTooltip => 'အစိတ်အပိုင်းရွေးချယ်ပါ';

  @override
  String get collectionDeselectSectionTooltip => 'အစိတ်အပိုင်းကို မရွေးတော့ပါ';

  @override
  String get drawerAboutButton => 'အက်ပ်အကြောင်း';

  @override
  String get drawerSettingsButton => 'ဆက်တင်များ';

  @override
  String get drawerCollectionAll => 'စုစည်းမှုအားလုံး';

  @override
  String get drawerCollectionFavourites => 'အကြိုက်ဆုံး';

  @override
  String get drawerCollectionImages => 'ဓာတ်ပုံ';

  @override
  String get drawerCollectionVideos => 'ဗီဒီယို';

  @override
  String get drawerCollectionAnimated => 'လှုပ်ရှားနေသောပုံ';

  @override
  String get drawerCollectionMotionPhotos => 'လှုပ်ရှားမှုပါသောပုံ';

  @override
  String get drawerCollectionPanoramas => 'မြင်ကွင်းကျယ်ဓာတ်ပုံ';

  @override
  String get drawerCollectionRaws => 'Raw ပုံ';

  @override
  String get drawerCollectionSphericalVideos => '၃၆၀° ဗီဒီယို';

  @override
  String get drawerAlbumPage => 'အယ်လ်ဘမ်';

  @override
  String get drawerCountryPage => 'နိုင်ငံ';

  @override
  String get drawerPlacePage => 'နေရာ';

  @override
  String get drawerTagPage => 'Tags';

  @override
  String get sortByDate => 'ရက်စွဲအလိုက်';

  @override
  String get sortByName => 'အမည်အလိုက်';

  @override
  String get sortByItemCount => 'ပုံအရေအတွက်အလိုက်';

  @override
  String get sortBySize => 'အရွယ်အစားအလိုက်';

  @override
  String get sortByAlbumFileName => 'အယ်လ်ဘမ်နှင့် ဖိုင်အမည်အလိုက်';

  @override
  String get sortByRating => 'အဆင့်သတ်မှတ်ချက်အလိုက်';

  @override
  String get sortByDuration => 'By duration';

  @override
  String get sortOrderNewestFirst => 'အသစ်ဆုံးက ထိပ်ဆုံး';

  @override
  String get sortOrderOldestFirst => 'အဟောင်းဆုံးက ထိပ်ဆုံး';

  @override
  String get sortOrderAtoZ => 'A ကနေ Z';

  @override
  String get sortOrderZtoA => 'Z ကနေ A';

  @override
  String get sortOrderHighestFirst => 'အမြင့်ဆုံးက ထိပ်ဆုံး';

  @override
  String get sortOrderLowestFirst => 'အနိမ့်ဆုံးက ထိပ်ဆုံး';

  @override
  String get sortOrderLargestFirst => 'အကြီးဆုံးက ထိပ်ဆုံး';

  @override
  String get sortOrderSmallestFirst => 'အသေးဆုံးက ထိပ်ဆုံး';

  @override
  String get sortOrderShortestFirst => 'Shortest first';

  @override
  String get sortOrderLongestFirst => 'Longest first';

  @override
  String get albumGroupTier => 'အဆင့်အလိုက်';

  @override
  String get albumGroupType => 'အမျိုးအစားအလိုက်';

  @override
  String get albumGroupVolume => 'သိုလှောင်မှုပမာဏအလိုက်';

  @override
  String get albumGroupNone => 'စုမပြပါနှင့်';

  @override
  String get albumMimeTypeMixed => 'ရောထား';

  @override
  String get albumPickPageTitleCopy => 'အယ်လ်ဘမ်သို့ ကော်ပီကူးခြင်း';

  @override
  String get albumPickPageTitleExport => 'အယ်လ်ဘမ်သို့ ပို့ခြင်း';

  @override
  String get albumPickPageTitleMove => 'အယ်လ်ဘမ်သို့ ရွှေ့ခြင်း';

  @override
  String get albumPickPageTitlePick => 'အယ်လ်ဘမ်ရွေးချယ်ပါ';

  @override
  String get albumCamera => 'ကင်မရာ';

  @override
  String get albumDownload => 'ဒေါင်းလုဒ်';

  @override
  String get albumScreenshots => 'Screenshot များ';

  @override
  String get albumScreenRecordings => 'စကရင် recording များ';

  @override
  String get albumVideoCaptures => 'ဗီဒီယိုဖမ်းယူထားသည်များ';

  @override
  String get albumPageTitle => 'အယ်လ်ဘမ်များ';

  @override
  String get albumEmpty => 'အယ်လ်ဘမ်တစ်ခုမှ မရှိပါ';

  @override
  String get createAlbumButtonLabel => 'ဖန်တီးမည်';

  @override
  String get newFilterBanner => 'new';

  @override
  String get countryPageTitle => 'နိုင်ငံများ';

  @override
  String get countryEmpty => 'နိုင်ငံတစ်ခုမှ မရှိပါ';

  @override
  String get statePageTitle => 'ပြည်နယ်များ';

  @override
  String get stateEmpty => 'ပြည်နယ်တစ်ခုမှ မရှိပါ';

  @override
  String get placePageTitle => 'နေရာများ';

  @override
  String get placeEmpty => 'နေရာတစ်ခုမှ မရှိပါ';

  @override
  String get tagPageTitle => 'Tag များ';

  @override
  String get tagEmpty => 'Tag တစ်ခုမှ မရှိပါ';

  @override
  String get binPageTitle => 'ပြန်သုံးအမှိုက်ပုံး';

  @override
  String get explorerPageTitle => 'Explorer';

  @override
  String get explorerActionSelectStorageVolume => 'Select storage';

  @override
  String get selectStorageVolumeDialogTitle => 'Select Storage';

  @override
  String get searchCollectionFieldHint => 'စုစည်းမှုအတွင်း ရှာဖွေပါ';

  @override
  String get searchRecentSectionTitle => 'ရှာထားတာ မကြာသေး';

  @override
  String get searchDateSectionTitle => 'ရက်စွဲ';

  @override
  String get searchFormatSectionTitle => 'Formats';

  @override
  String get searchAlbumsSectionTitle => 'အယ်လ်ဘမ်များ';

  @override
  String get searchCountriesSectionTitle => 'နိုင်ငံများ';

  @override
  String get searchStatesSectionTitle => 'ပြည်နယ်များ';

  @override
  String get searchPlacesSectionTitle => 'နေရာများ';

  @override
  String get searchTagsSectionTitle => 'Tag များ';

  @override
  String get searchRatingSectionTitle => 'အဆင့်သတ်မှတ်ချက်များ';

  @override
  String get searchMetadataSectionTitle => 'မက်တာဒေတာ';

  @override
  String get settingsPageTitle => 'ဆက်တင်များ';

  @override
  String get settingsSystemDefault => 'စစ်စတမ်အတိုင်း';

  @override
  String get settingsDefault => 'Default';

  @override
  String get settingsDisabled => 'ပိတ်ထား';

  @override
  String get settingsAskEverytime => 'အမြဲတမ်းပြန်မေးရန်';

  @override
  String get settingsModificationWarningDialogMessage => 'အခြားဆက်တင်များကိုပါ ပြင်ဆင်မည်ဖြစ်ပါသည်။';

  @override
  String get settingsSearchFieldLabel => 'ဆက်တင်များအတွင်း ရှာဖွေပါ';

  @override
  String get settingsSearchEmpty => 'ကိုက်ညီသောဆက်တင် မရှိပါ';

  @override
  String get settingsActionExport => 'ဆက်တင်များပို့ရန်';

  @override
  String get settingsActionExportDialogTitle => 'ဆက်တင်များပို့ခြင်း';

  @override
  String get settingsActionImport => 'ဆက်တင်များသွင်းရန်';

  @override
  String get settingsActionImportDialogTitle => 'ဆက်တင်များသွင်းခြင်း';

  @override
  String get appExportCovers => 'ကာဗာပုံများ';

  @override
  String get appExportDynamicAlbums => 'Dynamic albums';

  @override
  String get appExportFavourites => 'အကြိုက်ဆုံးများ';

  @override
  String get appExportSettings => 'ဆက်တင်များ';

  @override
  String get settingsNavigationSectionTitle => 'နေရာချခြင်း';

  @override
  String get settingsHomeTile => 'မူလအဖြစ်';

  @override
  String get settingsHomeDialogTitle => 'မူလအဖြစ်';

  @override
  String get setHomeCustom => 'Custom';

  @override
  String get settingsShowBottomNavigationBar => 'အောက်ဘက် navigation bar ကိုပြရန်';

  @override
  String get settingsKeepScreenOnTile => 'စကရင်မပိတ်ပါနှင့်';

  @override
  String get settingsKeepScreenOnDialogTitle => 'စကရင်မပိတ်ပါနှင့်';

  @override
  String get settingsDoubleBackExit => '“နောက်သို့” ခလုတ်ကိုထပ်နှိပ်မှ ထွက်ရန်';

  @override
  String get settingsConfirmationTile => 'အတည်ပြုဒိုင်ယာလော့ခ်များ';

  @override
  String get settingsConfirmationDialogTitle => 'အတည်ပြုဒိုင်ယာလော့ခ်များ';

  @override
  String get settingsConfirmationBeforeDeleteItems => 'ပုံများကို အပြီးမဖျက်ခင်ပြန်မေးရန်';

  @override
  String get settingsConfirmationBeforeMoveToBinItems => 'ပြန်သုံးအမှိုက်ပုံးသို့မရွှေ့ခင် ပြန်မေးရန်';

  @override
  String get settingsConfirmationBeforeMoveUndatedItems => 'ရက်စွဲမပါသောပုံများကိုမရွှေ့ခင် ပြန်မေးရန်';

  @override
  String get settingsConfirmationAfterMoveToBinItems => 'ပြန်သုံးအမှိုက်ပုံးထဲထည့်ပြီးလျှင် ပြီးကြောင်း စာဖြင့်ပြပေးရန်';

  @override
  String get settingsConfirmationVaultDataLoss => 'လျှို့ဝှက်သိုလှောင်ခန်းရှိ ဒေတာဆုံးရှုံးမှုသတိပေးချက်များ ပြပေးရန်';

  @override
  String get settingsNavigationDrawerTile => 'Navigation menu';

  @override
  String get settingsNavigationDrawerEditorPageTitle => 'Navigation Menu';

  @override
  String get settingsNavigationDrawerBanner => 'မီနူးပစ္စည်းများကိုရွှေ့ရန်နှင့်စီရန် ဆက်တိုက်ထိထားပါ။';

  @override
  String get settingsNavigationDrawerTabTypes => 'အမျိုးအစားများ';

  @override
  String get settingsNavigationDrawerTabAlbums => 'အယ်လ်ဘမ်များ';

  @override
  String get settingsNavigationDrawerTabPages => 'စာမျက်နှာများ';

  @override
  String get settingsNavigationDrawerAddAlbum => 'အယ်လ်ဘမ်ထပ်ထည့်ရန်';

  @override
  String get settingsThumbnailSectionTitle => 'Thumbnails';

  @override
  String get settingsThumbnailOverlayTile => 'Overlay';

  @override
  String get settingsThumbnailOverlayPageTitle => 'Overlay';

  @override
  String get settingsThumbnailShowHdrIcon => 'Show HDR icon';

  @override
  String get settingsThumbnailShowFavouriteIcon => 'အကြိုက်ဆုံးအိုင်ကွန်ကို ပြရန်';

  @override
  String get settingsThumbnailShowTagIcon => 'Tag အိုင်ကွန်ကိုပြရန်';

  @override
  String get settingsThumbnailShowLocationIcon => 'တည်နေရာအိုင်ကွန်ကိုပြရန်';

  @override
  String get settingsThumbnailShowMotionPhotoIcon => 'လှုပ်ရှားမှုပါသောပုံ အိုင်ကွန်ကိုပြရန်';

  @override
  String get settingsThumbnailShowRating => 'အဆင့်သတ်မှတ်ချက်ကို ပြရန်';

  @override
  String get settingsThumbnailShowRawIcon => 'Raw အိုင်ကွန်ကိုပြရန်';

  @override
  String get settingsThumbnailShowVideoDuration => 'ဗီဒီယိုကြာချိန်ကို ပြရန်';

  @override
  String get settingsCollectionQuickActionsTile => 'အမြန်လုပ်ဆောင်မှု';

  @override
  String get settingsCollectionQuickActionEditorPageTitle => 'အမြန်လုပ်ဆောင်မှု';

  @override
  String get settingsCollectionQuickActionTabBrowsing => 'ရှာဖွေကြည့်ရှုရာမှာ';

  @override
  String get settingsCollectionQuickActionTabSelecting => 'ရွေးချယ်ရာမှာ';

  @override
  String get settingsCollectionBrowsingQuickActionEditorBanner => 'ပုံတွေကိုရှာဖွေကြည့်ရှုရာမှာ ပြသမယ့်လုပ်ဆောင်မှုတွေကို ရွေးချယ်ပါ။ ခလုတ်တွေကိုရွှေ့လျှင် ဆက်တိုက်ထိထားပြီးရွှေ့ပါ။';

  @override
  String get settingsCollectionSelectionQuickActionEditorBanner => 'ပုံတွေကိုရွေးချယ်ရာမှာ ပြသမယ့်လုပ်ဆောင်မှုတွေကို ရွေးချယ်ပါ။ ခလုတ်တွေကိုရွှေ့လျှင် ဆက်တိုက်ထိထားပြီးရွှေ့ပါ။';

  @override
  String get settingsCollectionBurstPatternsTile => 'ဆက်တိုက်ရိုက်ဓာတ်ပုံများ၏ ဖိုင်ပုံစံ';

  @override
  String get settingsCollectionBurstPatternsNone => 'ဘာမှမထား';

  @override
  String get settingsViewerSectionTitle => 'ကြည့်ရှုသည့်စာမျက်နှာ';

  @override
  String get settingsViewerGestureSideTapNext => 'စကရင်အစွန်းကို ထိလိုက်လျှင် အရှေ့/အနောက်ကတစ်ပုံကိုပြရန်';

  @override
  String get settingsViewerUseCutout => 'Notch နေရာပါ သုံးရန်';

  @override
  String get settingsViewerMaximumBrightness => 'Brightness အမြင့်ဆုံးထားရန်';

  @override
  String get settingsMotionPhotoAutoPlay => 'လှုပ်ရှားမှုပါသောပုံတွေကို အလိုအလျောက်ပလေးရန်';

  @override
  String get settingsImageBackground => 'ဓာတ်ပုံနောက်ခံ';

  @override
  String get settingsViewerQuickActionsTile => 'အမြန်လုပ်ဆောင်မှု';

  @override
  String get settingsViewerQuickActionEditorPageTitle => 'အမြန်လုပ်ဆောင်မှု';

  @override
  String get settingsViewerQuickActionEditorBanner => 'ပုံတွေကိုကြည့်ရှုချိန် ပြသမယ့်လုပ်ဆောင်မှုတွေကို ရွေးချယ်ပါ။ ခလုတ်တွေကိုရွှေ့လျှင် ဆက်တိုက်ထိထားပြီးရွှေ့ပါ။';

  @override
  String get settingsViewerQuickActionEditorDisplayedButtonsSectionTitle => 'ပြသမည့်ခလုတ်များ';

  @override
  String get settingsViewerQuickActionEditorAvailableButtonsSectionTitle => 'ရရှိနိုင်သော ခလုတ်များ';

  @override
  String get settingsViewerQuickActionEmpty => 'ခလုတ်တစ်ခုမှမရှိပါ';

  @override
  String get settingsViewerOverlayTile => 'Overlay';

  @override
  String get settingsViewerOverlayPageTitle => 'Overlay';

  @override
  String get settingsViewerShowOverlayOnOpening => 'အဖွင့်တွင် ပြရန်';

  @override
  String get settingsViewerShowHistogram => 'Histogram ကို ပြရန်';

  @override
  String get settingsViewerShowMinimap => 'မြေပုံအသေးစားလေးကို ပြရန်';

  @override
  String get settingsViewerShowInformation => 'အချက်အလက်များကို ပြရန်';

  @override
  String get settingsViewerShowInformationSubtitle => 'ခေါင်းစဥ်၊ ရက်စွဲ၊ တည်နေရာ စသဖြင့်';

  @override
  String get settingsViewerShowRatingTags => 'အဆင့်သတ်မှတ်ချက်နှင့် tag များကို ပြရန်';

  @override
  String get settingsViewerShowShootingDetails => 'ရိုက်ကူးမှုအသေးစိတ်ကို ပြရန်';

  @override
  String get settingsViewerShowDescription => 'ဖော်ပြချက်ကိုပြရန်';

  @override
  String get settingsViewerShowOverlayThumbnails => 'Thumbnail ကို ပြရန်';

  @override
  String get settingsViewerEnableOverlayBlurEffect => 'Blur effect';

  @override
  String get settingsViewerSlideshowTile => 'ဆလိုက်ရှိုး';

  @override
  String get settingsViewerSlideshowPageTitle => 'ဆလိုက်ရှိုး';

  @override
  String get settingsSlideshowRepeat => 'ပြန်ကျော့ရန်';

  @override
  String get settingsSlideshowShuffle => 'ဟိုရောက်လိုက် ဒီရောက်လိုက်';

  @override
  String get settingsSlideshowFillScreen => 'စကရင်အပြည့်';

  @override
  String get settingsSlideshowAnimatedZoomEffect => 'ချဲ့ကားလာသည့် effect';

  @override
  String get settingsSlideshowTransitionTile => 'အကူးအပြောင်း';

  @override
  String get settingsSlideshowIntervalTile => 'အကူးအပြောင်းမလုပ်ခင် ကြားအချိန်';

  @override
  String get settingsSlideshowVideoPlaybackTile => 'ဗီဒီယိုဖွင့်ကြည့်ခြင်း';

  @override
  String get settingsSlideshowVideoPlaybackDialogTitle => 'ဗီဒီယိုဖွင့်ကြည့်ခြင်း';

  @override
  String get settingsVideoPageTitle => 'ဗီဒီယိုဆက်တင်များ';

  @override
  String get settingsVideoSectionTitle => 'ဗီဒီယို';

  @override
  String get settingsVideoShowVideos => 'ဗီဒီယိုများပါ ပြရန်';

  @override
  String get settingsVideoPlaybackTile => 'ဖွင့်ကြည့်ခြင်း';

  @override
  String get settingsVideoPlaybackPageTitle => 'ဖွင့်ကြည့်ခြင်း';

  @override
  String get settingsVideoEnableHardwareAcceleration => 'Hardware အသုံးပြုအရှိန်မြှင့်တင်ခြင်း';

  @override
  String get settingsVideoAutoPlay => 'အလိုအလျောက်ဖွင့်ခြင်း';

  @override
  String get settingsVideoLoopModeTile => 'ပြန်ကျော့ခြင်း';

  @override
  String get settingsVideoLoopModeDialogTitle => 'ပြန်ကျော့ခြင်း';

  @override
  String get settingsVideoResumptionModeTile => 'ကြည့်လက်စ ဆက်ကြည့်ခြင်း';

  @override
  String get settingsVideoResumptionModeDialogTitle => 'ကြည့်လက်စ ဆက်ကြည့်ခြင်း';

  @override
  String get settingsVideoBackgroundMode => 'နောက်ခံတွင် ဖွင့်ထားခြင်း';

  @override
  String get settingsVideoBackgroundModeDialogTitle => 'နောက်ခံတွင် ဖွင့်ထားခြင်း';

  @override
  String get settingsVideoControlsTile => 'ထိန်းချုပ်မှုများ';

  @override
  String get settingsVideoControlsPageTitle => 'ထိန်းချုပ်မှုများ';

  @override
  String get settingsVideoButtonsTile => 'ခလုတ်';

  @override
  String get settingsVideoGestureDoubleTapTogglePlay => 'နှစ်ချက်ထိလျှင် ဖွင့်ကြည့်/ရပ်ရန်';

  @override
  String get settingsVideoGestureSideDoubleTapSeek => 'စကရင်အစွန်းကို နှစ်ချက်ထိလျှင် ရှေ့သွား/နောက်ဆုတ်ရန်';

  @override
  String get settingsVideoGestureVerticalDragBrightnessVolume => 'အပေါ်အောက်ပွတ်ဆွဲလျှင် brightness/အသံ အတိုးအလျှော့လုပ်ရန်';

  @override
  String get settingsSubtitleThemeTile => 'စာတန်းထိုး';

  @override
  String get settingsSubtitleThemePageTitle => 'စာတန်းထိုး';

  @override
  String get settingsSubtitleThemeSample => 'ဒါက ဥပမာပြတာပါ။';

  @override
  String get settingsSubtitleThemeTextAlignmentTile => 'အလျားလိုက် စာသားနေရာ';

  @override
  String get settingsSubtitleThemeTextAlignmentDialogTitle => 'အလျားလိုက် စာသားနေရာ';

  @override
  String get settingsSubtitleThemeTextPositionTile => 'ဒေါင်လိုက် စာသားနေရာ';

  @override
  String get settingsSubtitleThemeTextPositionDialogTitle => 'ဒေါင်လိုက် စာသားနေရာ';

  @override
  String get settingsSubtitleThemeTextSize => 'စာသားအရွယ်အစား';

  @override
  String get settingsSubtitleThemeShowOutline => 'စာသားကောက်ကြောင်းနှင့် အရိပ်ကို ပြရန်';

  @override
  String get settingsSubtitleThemeTextColor => 'စာသားအရောင်';

  @override
  String get settingsSubtitleThemeTextOpacity => 'စာသားထင်ရှားမှု';

  @override
  String get settingsSubtitleThemeBackgroundColor => 'နောက်ခံအရောင်';

  @override
  String get settingsSubtitleThemeBackgroundOpacity => 'နောက်ခံထင်ရှားမှု';

  @override
  String get settingsSubtitleThemeTextAlignmentLeft => 'ဘယ်ဘက်';

  @override
  String get settingsSubtitleThemeTextAlignmentCenter => 'အလယ်';

  @override
  String get settingsSubtitleThemeTextAlignmentRight => 'ညာဘက်';

  @override
  String get settingsPrivacySectionTitle => 'ကိုယ်ရေးအချက်အလက်လုံခြုံမှု';

  @override
  String get settingsAllowInstalledAppAccess => 'စက်တွင်းထည့်သွင်းထားသည့် အက်ပ်စာရင်း ကြည့်ရှုခွင့်ပေးရန်';

  @override
  String get settingsAllowInstalledAppAccessSubtitle => 'အယ်လ်ဘမ်ပြသမှုပိုမိုကောင်းမွန်စေဖို့ အသုံးပြုပါသည်';

  @override
  String get settingsAllowErrorReporting => 'အမည်မဲ့ error တင်ပြမှုများကို ခွင့်ပြုရန်';

  @override
  String get settingsSaveSearchHistory => 'ရှာဖွေမှုမှတ်တမ်းကို သိမ်းထားရန်';

  @override
  String get settingsEnableBin => 'ပြန်သုံးအမှိုက်ပုံးကို သုံးရန်';

  @override
  String get settingsEnableBinSubtitle => 'ဖျက်ထားသည့်ပုံများကို ရက် ၃၀ အထိ ဆက်သိမ်းထားပါမည်';

  @override
  String get settingsDisablingBinWarningDialogMessage => 'ပြန်သုံးအမှိုက်ပုံးထဲက ဓာတ်ပုံနဲ့ ဗီဒီယိုတွေကို အပြီးဖျက်လိုက်မှာပါ။';

  @override
  String get settingsAllowMediaManagement => 'မီဒီယာစီမံခန့်ခွဲခွင့် ပေးရန်';

  @override
  String get settingsHiddenItemsTile => 'ဝှက်ထားသည့်ပုံများ';

  @override
  String get settingsHiddenItemsPageTitle => 'ဝှက်ထားသည့်ပုံများ';

  @override
  String get settingsHiddenFiltersBanner => 'Photos and videos matching hidden filters will not appear in your collection.';

  @override
  String get settingsHiddenFiltersEmpty => 'No hidden filters';

  @override
  String get settingsStorageAccessTile => 'သိုလှောင်ခန်းဝင်ရောက်ကြည့်ရှုခွင့်';

  @override
  String get settingsStorageAccessPageTitle => 'သိုလှောင်ခန်းဝင်ရောက်ကြည့်ရှုခွင့်';

  @override
  String get settingsStorageAccessBanner => 'တချို့ directory တွေဟာ သူတို့ထဲကဖိုင်တွေကို ပြင်ဆင်ဖို့ ဝင်ရောက်ကြည့်ရှုခွင့်အတိအကျပေးဖို့ လိုအပ်ပါတယ်။ သင်အရင်က ဝင်ရောက်ကြည့်ရှုခွင့်ပေးခဲ့တဲ့ directory တွေကို ဒီနေရာမှာ သုံးသပ်နိုင်ပါတယ်။';

  @override
  String get settingsStorageAccessEmpty => 'ဝင်ရောက်ကြည့်ရှုခွင့်ပေးထားတာမရှိပါ';

  @override
  String get settingsStorageAccessRevokeTooltip => 'ပြန်ရုပ်သိမ်းမည်';

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
