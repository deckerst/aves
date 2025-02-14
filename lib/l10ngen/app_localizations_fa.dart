// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get appName => 'اِیوز';

  @override
  String get welcomeMessage => 'به اِیوْز خوش آمدید';

  @override
  String get welcomeOptional => 'اختیاری';

  @override
  String get welcomeTermsToggle => 'من با شرایط و مقررات استفاده از خدمات موافق هستم';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count فایل',
      one: '$count فایل',
    );
    return '$_temp0';
  }

  @override
  String columnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ستون',
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
      other: '$countString ثانیه',
      one: '$countString ثانیع',
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
      other: '$countString دقیقه',
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
      other: '$countString روز',
    );
    return '$_temp0';
  }

  @override
  String focalLength(String length) {
    return '$length میلی‌متر';
  }

  @override
  String get applyButtonLabel => 'اعمال';

  @override
  String get deleteButtonLabel => 'پاک کردن';

  @override
  String get nextButtonLabel => 'بعدی';

  @override
  String get showButtonLabel => 'نمایش';

  @override
  String get hideButtonLabel => 'پنهان';

  @override
  String get continueButtonLabel => 'ادامه';

  @override
  String get saveCopyButtonLabel => 'ذخیرهٔ رونوشت';

  @override
  String get applyTooltip => 'اعمال';

  @override
  String get cancelTooltip => 'لغو';

  @override
  String get changeTooltip => 'تغییر';

  @override
  String get clearTooltip => 'پاک‌کردن';

  @override
  String get previousTooltip => 'قبلی';

  @override
  String get nextTooltip => 'بعدی';

  @override
  String get showTooltip => 'نمایش';

  @override
  String get hideTooltip => 'پنهان';

  @override
  String get actionRemove => 'پاک‌کردن';

  @override
  String get resetTooltip => 'بازنشانی';

  @override
  String get saveTooltip => 'ذخیره';

  @override
  String get stopTooltip => 'ایست';

  @override
  String get pickTooltip => 'انتخاب';

  @override
  String get doubleBackExitMessage => 'دوباره «عقب» را فشار دهید تا خارج شوید.';

  @override
  String get doNotAskAgain => 'دوباره نپرس';

  @override
  String get sourceStateLoading => 'در حال بارگیری';

  @override
  String get sourceStateCataloguing => 'در حال فهرست سازی';

  @override
  String get sourceStateLocatingCountries => 'در حال مکان یابی کشور ها';

  @override
  String get sourceStateLocatingPlaces => 'در حال مکان یابی';

  @override
  String get chipActionDelete => 'پاک‌کردن';

  @override
  String get chipActionRemove => 'Remove';

  @override
  String get chipActionShowCollection => 'نمایش در مجموعه';

  @override
  String get chipActionGoToAlbumPage => 'نمایش در البوم‌ها';

  @override
  String get chipActionGoToCountryPage => 'نمایش در کشورها';

  @override
  String get chipActionGoToPlacePage => 'نمایش در مکان‌ها';

  @override
  String get chipActionGoToTagPage => 'نمایش در برچسب‌ها';

  @override
  String get chipActionGoToExplorerPage => 'Show in Explorer';

  @override
  String get chipActionDecompose => 'Split';

  @override
  String get chipActionFilterOut => 'پاک‌کردن از پالایش';

  @override
  String get chipActionFilterIn => 'اضافه به فیلتر';

  @override
  String get chipActionHide => 'پنهان کردن';

  @override
  String get chipActionLock => 'قفل';

  @override
  String get chipActionPin => 'سنجاق به بالا';

  @override
  String get chipActionUnpin => 'برداشتن سنجاق از بالا';

  @override
  String get chipActionRename => 'تغییر نام فایل';

  @override
  String get chipActionSetCover => 'گذاشتن به عنوان سرپوش';

  @override
  String get chipActionShowCountryStates => 'نمایش شهر‌ها';

  @override
  String get chipActionCreateAlbum => 'ایجاد البوم';

  @override
  String get chipActionCreateVault => 'ایجاد گاوصندوق';

  @override
  String get chipActionConfigureVault => 'پیکربندی گاوصندوق';

  @override
  String get entryActionCopyToClipboard => 'کپی به کلیپ بورد';

  @override
  String get entryActionDelete => 'پاک‌کردن';

  @override
  String get entryActionConvert => 'تبدیل فایل';

  @override
  String get entryActionExport => 'خروجی';

  @override
  String get entryActionInfo => 'اطلاعات';

  @override
  String get entryActionRename => 'تغییر نام';

  @override
  String get entryActionRestore => 'برگرداندن';

  @override
  String get entryActionRotateCCW => 'چرخش پادساعت‌گرد';

  @override
  String get entryActionRotateCW => 'چرخش ساعت‌گرد';

  @override
  String get entryActionFlip => 'آینه کردن افقی';

  @override
  String get entryActionPrint => 'چاپ';

  @override
  String get entryActionShare => 'اشتراک گذاری';

  @override
  String get entryActionShareImageOnly => 'فقط اشتراک گذاری عکس';

  @override
  String get entryActionShareVideoOnly => 'فقط اشتراک گذاری ویدئو';

  @override
  String get entryActionViewSource => 'مشاهده منبع';

  @override
  String get entryActionShowGeoTiffOnMap => 'نمایش بر روی نقشه';

  @override
  String get entryActionConvertMotionPhotoToStillImage => 'تبدیل به عکس ثابت';

  @override
  String get entryActionViewMotionPhotoVideo => 'باز کردن ویدئو';

  @override
  String get entryActionEdit => 'ویرایش';

  @override
  String get entryActionOpen => 'باز کردن با برنامه ای دیگر';

  @override
  String get entryActionSetAs => 'قرار دادن به عنوان';

  @override
  String get entryActionCast => 'بازتاب';

  @override
  String get entryActionOpenMap => 'نمایش در برنامه نقشه';

  @override
  String get entryActionRotateScreen => 'چرخش صفحه';

  @override
  String get entryActionAddFavourite => 'اضافه کردن به مورد علاقه ها';

  @override
  String get entryActionRemoveFavourite => 'پاک‌کردن از مورد علاقه ها';

  @override
  String get videoActionCaptureFrame => 'ذخیره فریم';

  @override
  String get videoActionMute => 'بی صدا کردن';

  @override
  String get videoActionUnmute => 'با صدا کردن';

  @override
  String get videoActionPause => 'مکث';

  @override
  String get videoActionPlay => 'پخش';

  @override
  String get videoActionReplay10 => 'برگشت 10 ثانیه به عقب';

  @override
  String get videoActionSkip10 => 'جلو رفتن 10 ثانیه';

  @override
  String get videoActionShowPreviousFrame => 'Show previous frame';

  @override
  String get videoActionShowNextFrame => 'Show next frame';

  @override
  String get videoActionSelectStreams => 'انتخاب قطعه‌ٔ صوتی';

  @override
  String get videoActionSetSpeed => 'سرعت پخش';

  @override
  String get videoActionABRepeat => 'آ-ب تکرار';

  @override
  String get videoRepeatActionSetStart => 'تنظیم آغاز';

  @override
  String get videoRepeatActionSetEnd => 'تنظیم پایان';

  @override
  String get viewerActionSettings => 'تنظیمات';

  @override
  String get viewerActionLock => 'قفل پخش‌کننده';

  @override
  String get viewerActionUnlock => 'باز کردن قفل پخش‌کننده';

  @override
  String get slideshowActionResume => 'ادامه';

  @override
  String get slideshowActionShowInCollection => 'نمایش در مجموعه';

  @override
  String get entryInfoActionEditDate => 'ویرایش تاریخ';

  @override
  String get entryInfoActionEditLocation => 'ویرایش مکان';

  @override
  String get entryInfoActionEditTitleDescription => 'ویرایش عنوان و توضیحات';

  @override
  String get entryInfoActionEditRating => 'ویرایش امتیاز';

  @override
  String get entryInfoActionEditTags => 'ویرایش برچسب ها';

  @override
  String get entryInfoActionRemoveMetadata => 'پاک‌کردن فراداده';

  @override
  String get entryInfoActionExportMetadata => 'خروجی گرفتن از فراداده';

  @override
  String get entryInfoActionRemoveLocation => 'پاک‌کردن مکان';

  @override
  String get editorActionTransform => 'تبدیل';

  @override
  String get editorTransformCrop => 'برش';

  @override
  String get editorTransformRotate => 'چرخش';

  @override
  String get cropAspectRatioFree => 'آزاد';

  @override
  String get cropAspectRatioOriginal => 'اصلی';

  @override
  String get cropAspectRatioSquare => 'مربع';

  @override
  String get filterAspectRatioLandscapeLabel => 'افقی';

  @override
  String get filterAspectRatioPortraitLabel => 'عمودی';

  @override
  String get filterBinLabel => 'سطل اشغال';

  @override
  String get filterFavouriteLabel => 'مورد علاقه';

  @override
  String get filterNoDateLabel => 'بدون تاریخ';

  @override
  String get filterNoAddressLabel => 'بدون نشانی';

  @override
  String get filterLocatedLabel => 'واقع شده';

  @override
  String get filterNoLocationLabel => 'بدون مکان';

  @override
  String get filterNoRatingLabel => 'بدون امتیاز';

  @override
  String get filterTaggedLabel => 'نشان شده';

  @override
  String get filterNoTagLabel => 'بدون برچسب';

  @override
  String get filterNoTitleLabel => 'بدون نام';

  @override
  String get filterOnThisDayLabel => 'در امروز';

  @override
  String get filterRecentlyAddedLabel => 'تازه اضافه شده';

  @override
  String get filterRatingRejectedLabel => 'رد شده';

  @override
  String get filterTypeAnimatedLabel => 'متحرک';

  @override
  String get filterTypeMotionPhotoLabel => 'تصویر متحرک';

  @override
  String get filterTypePanoramaLabel => 'پاناروما';

  @override
  String get filterTypeRawLabel => 'خام';

  @override
  String get filterTypeSphericalVideoLabel => 'ویدئو 360°';

  @override
  String get filterTypeGeotiffLabel => 'GeoTIFF';

  @override
  String get filterMimeImageLabel => 'عکس';

  @override
  String get filterMimeVideoLabel => 'ویدئو';

  @override
  String get accessibilityAnimationsRemove => 'جلوگیری از جلوه‌های نمایشگر';

  @override
  String get accessibilityAnimationsKeep => 'نمایش از جلوه‌های نمایشگر';

  @override
  String get albumTierNew => 'جدید';

  @override
  String get albumTierPinned => 'سنجاق شده';

  @override
  String get albumTierSpecial => 'مشترک';

  @override
  String get albumTierApps => 'برنامه ها';

  @override
  String get albumTierVaults => 'گاوصندوق‌ها';

  @override
  String get albumTierDynamic => 'Dynamic';

  @override
  String get albumTierRegular => 'سایر';

  @override
  String get coordinateFormatDms => 'DMS';

  @override
  String get coordinateFormatDdm => 'DDM';

  @override
  String get coordinateFormatDecimal => 'درجه‌های اعشاری';

  @override
  String coordinateDms(String coordinate, String direction) {
    return '$coordinate $direction';
  }

  @override
  String get coordinateDmsNorth => 'شمال';

  @override
  String get coordinateDmsSouth => 'جنوب';

  @override
  String get coordinateDmsEast => 'شرق';

  @override
  String get coordinateDmsWest => 'غرب';

  @override
  String get displayRefreshRatePreferHighest => 'بیشترین مقدار';

  @override
  String get displayRefreshRatePreferLowest => 'کمترین مقدار';

  @override
  String get keepScreenOnNever => 'هیچ‌وقت';

  @override
  String get keepScreenOnVideoPlayback => 'هنگام پخش ویدیو';

  @override
  String get keepScreenOnViewerOnly => 'فقط در صفحهٔ مشاهده‌ٔ تصویر';

  @override
  String get keepScreenOnAlways => 'همیشه';

  @override
  String get lengthUnitPixel => 'پیکسل';

  @override
  String get lengthUnitPercent => '٪';

  @override
  String get mapStyleGoogleNormal => 'نقشه گوگل';

  @override
  String get mapStyleGoogleHybrid => 'نقشه گوگل (نمایش هیبریدی)';

  @override
  String get mapStyleGoogleTerrain => 'نقشه گوگل (نمایش زمین)';

  @override
  String get mapStyleOsmLiberty => 'OSM Liberty';

  @override
  String get mapStyleOpenTopoMap => 'OpenTopoMap';

  @override
  String get mapStyleOsmHot => 'اوپن‌استریت‌مپ بشردوستانه';

  @override
  String get mapStyleStamenWatercolor => 'استامن (نمایش نقشه کشیده شده)';

  @override
  String get maxBrightnessNever => 'هرگز';

  @override
  String get maxBrightnessAlways => 'همیشه';

  @override
  String get nameConflictStrategyRename => 'تغییر نام';

  @override
  String get nameConflictStrategyReplace => 'جایگزین کردن';

  @override
  String get nameConflictStrategySkip => 'رد شدن';

  @override
  String get overlayHistogramNone => 'هیچکدام';

  @override
  String get overlayHistogramRGB => 'RGB';

  @override
  String get overlayHistogramLuminance => 'درخشش';

  @override
  String get subtitlePositionTop => 'بالا';

  @override
  String get subtitlePositionBottom => 'پایین';

  @override
  String get themeBrightnessLight => 'روشن';

  @override
  String get themeBrightnessDark => 'تاریک';

  @override
  String get themeBrightnessBlack => 'سیاه';

  @override
  String get unitSystemMetric => 'متری';

  @override
  String get unitSystemImperial => 'مایلی';

  @override
  String get vaultLockTypePattern => 'الگو';

  @override
  String get vaultLockTypePin => 'PIN';

  @override
  String get vaultLockTypePassword => 'گذرواژه';

  @override
  String get settingsVideoEnablePip => 'تصویر در تصویر';

  @override
  String get videoControlsPlayOutside => 'باز کردن با برنامه‌ای دیگر';

  @override
  String get videoLoopModeNever => 'هیچ وقت';

  @override
  String get videoLoopModeShortOnly => 'فقط برای ویدئوهای کوتاه';

  @override
  String get videoLoopModeAlways => 'همیشه';

  @override
  String get videoPlaybackSkip => 'رد کردن';

  @override
  String get videoPlaybackMuted => 'پخش بی صدا';

  @override
  String get videoPlaybackWithSound => 'پخش با صدا';

  @override
  String get videoResumptionModeNever => 'هیچ‌وقت';

  @override
  String get videoResumptionModeAlways => 'همیشه';

  @override
  String get viewerTransitionSlide => 'اسلاید';

  @override
  String get viewerTransitionParallax => 'انطباق';

  @override
  String get viewerTransitionFade => 'محو شدن';

  @override
  String get viewerTransitionZoomIn => 'زوم‌پیش';

  @override
  String get viewerTransitionNone => 'هیچ‌کدام';

  @override
  String get wallpaperTargetHome => 'صفحهٔ خانه';

  @override
  String get wallpaperTargetLock => 'صفحهٔ قفل';

  @override
  String get wallpaperTargetHomeLock => 'صفحهٔ خانه و صفحهٔ قفل';

  @override
  String get widgetDisplayedItemRandom => 'تصادفی';

  @override
  String get widgetDisplayedItemMostRecent => 'جدید‌ترین';

  @override
  String get widgetOpenPageHome => 'باز کردن خانه';

  @override
  String get widgetOpenPageCollection => 'باز کردن مجموعه';

  @override
  String get widgetOpenPageViewer => 'باز کردن مشاهده‌گر';

  @override
  String get widgetTapUpdateWidget => 'به‌روز رسانی ابزارک';

  @override
  String get storageVolumeDescriptionFallbackPrimary => 'حافظه داخلی';

  @override
  String get storageVolumeDescriptionFallbackNonPrimary => 'کارت حافظه';

  @override
  String get rootDirectoryDescription => 'شاخهٔ ریشه';

  @override
  String otherDirectoryDescription(String name) {
    return 'شاخهٔ «$name»';
  }

  @override
  String storageAccessDialogMessage(String directory, String volume) {
    return 'لطفا شاخهٔ $directory در «$volume» را در صفحه بعد انتخاب کنید و به برنامه اجازه بدهید.';
  }

  @override
  String restrictedAccessDialogMessage(String directory, String volume) {
    return 'این برنامه اجازهٔ ویرایش پرونده‌ها ی پوشه $directory در «$volume» را ندارد.\n\nلطفا از یک برنامهٔ نگارخانه یا مدیر پروندهٔ از پیش نصب شده استفاده کنید.';
  }

  @override
  String notEnoughSpaceDialogMessage(String neededSize, String freeSize, String volume) {
    return 'این کار برای کامل شدن به $neededSize فضای خالی در «$volume» نیاز دارد اما فقط $freeSize وجود دارد.';
  }

  @override
  String get missingSystemFilePickerDialogMessage => 'انتخابگر پرونده سامانه وجود ندارد یا غیرفعال است. لطفا آن را فعال کنید و دوباره امتحان کنید.';

  @override
  String unsupportedTypeDialogMessage(int count, String types) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'این عملکرد برای موارد از این نوع پشتیبانی نمیشود: $types.',
      one: 'این عملکرد برای موارد از این نوع ممکن نیست: $types.',
    );
    return '$_temp0';
  }

  @override
  String get nameConflictDialogSingleSourceMessage => 'برخی از پرونده‌های موجود در پوشه مقصد به همین نام هستند.';

  @override
  String get nameConflictDialogMultipleSourceMessage => 'برخی پرونده ها نام های یکسانی دارند.';

  @override
  String get addShortcutDialogLabel => 'عنوان میانبر';

  @override
  String get addShortcutButtonLabel => 'افزودن';

  @override
  String get noMatchingAppDialogMessage => 'هیچ کاره ای وجود ندارد که بتواند این موضوع را مدیریت کند.';

  @override
  String binEntriesConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'این $countمورد به سطل زباله منتقل شوند؟',
      one: 'این مورد به سطل زباله منتقل شود؟',
    );
    return '$_temp0';
  }

  @override
  String deleteEntriesConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'این $count مورد پاک شوند؟',
      one: 'این مورد پاک شود؟',
    );
    return '$_temp0';
  }

  @override
  String get moveUndatedConfirmationDialogMessage => 'پیش از ادامه دادن تاریخ موارد نگه‌داری شود؟';

  @override
  String get moveUndatedConfirmationDialogSetDate => 'نگه‌داری تاریخ ها';

  @override
  String videoResumeDialogMessage(String time) {
    return 'ادامه پخش از زمان $time؟';
  }

  @override
  String get videoStartOverButtonLabel => 'شروع از اول';

  @override
  String get videoResumeButtonLabel => 'ادامه';

  @override
  String get setCoverDialogLatest => 'آخرین مورد';

  @override
  String get setCoverDialogAuto => 'خودکار';

  @override
  String get setCoverDialogCustom => 'شخصی';

  @override
  String get hideFilterConfirmationDialogMessage => 'تطبیق عکس ها و فیلم ها از مجموعه شما پنهان خواهد ماند. می توانید دوباره آنها را از تنظیمات «حریم خصوصی» نشان دهید.\n\nاز پنهان سازی آنها اطمینان دارید?';

  @override
  String get newAlbumDialogTitle => 'آلبوم جدید';

  @override
  String get newAlbumDialogNameLabel => 'نام آلبوم';

  @override
  String get newAlbumDialogAlbumAlreadyExistsHelper => 'Album already exists';

  @override
  String get newAlbumDialogNameLabelAlreadyExistsHelper => 'پوشه از پیش موجود است';

  @override
  String get newAlbumDialogStorageLabel => 'حافظه:';

  @override
  String get newDynamicAlbumDialogTitle => 'New Dynamic Album';

  @override
  String get dynamicAlbumAlreadyExists => 'Dynamic album already exists';

  @override
  String get newVaultWarningDialogMessage => 'موارد موجود در گاوصندوق تنها برای این برنامه در دسترس هستند و در هیچ برنامه دیگری وجود ندارد.\n\nاگر این برنامه را پاک کنید، یا داده‌های برنامه را پاک کنید، همه این موارد را از دست خواهید داد.';

  @override
  String get newVaultDialogTitle => 'گاوصندوق جدید';

  @override
  String get configureVaultDialogTitle => 'پیکربندی گاوصندوق';

  @override
  String get vaultDialogLockModeWhenScreenOff => 'وقتی دستگاه خاموش شد قفل شود';

  @override
  String get vaultDialogLockTypeLabel => 'نوع قفل';

  @override
  String get patternDialogEnter => 'وارد کردن الگو';

  @override
  String get patternDialogConfirm => 'تایید الگو';

  @override
  String get pinDialogEnter => 'وارد کردن PIN';

  @override
  String get pinDialogConfirm => 'تایید PIN';

  @override
  String get passwordDialogEnter => 'وارد کردن گذرواژه';

  @override
  String get passwordDialogConfirm => 'تایید گذرواژه';

  @override
  String get authenticateToConfigureVault => 'احرازهویت برای پیکربندی گاو صندوق';

  @override
  String get authenticateToUnlockVault => 'احرازهویت برای قفل گشایی گاو صندوق';

  @override
  String get vaultBinUsageDialogMessage => 'برخی از خزانه ها از سطل زباله استفاده می کنند.';

  @override
  String get renameAlbumDialogLabel => 'نام جدید';

  @override
  String get renameAlbumDialogLabelAlreadyExistsHelper => 'پوشه از پیش موجود است';

  @override
  String get renameEntrySetPageTitle => 'تغییرنام';

  @override
  String get renameEntrySetPagePatternFieldLabel => 'الگو نام گذاری';

  @override
  String get renameEntrySetPageInsertTooltip => 'قسمتی وارد کنید';

  @override
  String get renameEntrySetPagePreviewSectionTitle => 'پیش‌نمایش';

  @override
  String get renameProcessorCounter => 'شمارنده';

  @override
  String get renameProcessorHash => 'هش';

  @override
  String get renameProcessorName => 'نام';

  @override
  String deleteSingleAlbumConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'این آلبوم و $count مورد موجود در آن پاک شود؟',
      one: 'این آلبوم و مورد موجود در آن پاک شود؟',
    );
    return '$_temp0';
  }

  @override
  String deleteMultiAlbumConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'این آلبوم ها و $count مورد موجود در آنها پاک شود؟',
      one: 'این آلبوم ها و مورد موجود در آنها پاک شود؟',
    );
    return '$_temp0';
  }

  @override
  String get exportEntryDialogFormat => 'فرمت:';

  @override
  String get exportEntryDialogWidth => 'عرض';

  @override
  String get exportEntryDialogHeight => 'طول';

  @override
  String get exportEntryDialogQuality => 'کیفیت';

  @override
  String get exportEntryDialogWriteMetadata => 'نوشتن فراداده';

  @override
  String get renameEntryDialogLabel => 'نام جدید';

  @override
  String get editEntryDialogCopyFromItem => 'هم‌مانند دیگر مورد کن';

  @override
  String get editEntryDialogTargetFieldsHeader => 'قسمت هایی برای تغییر';

  @override
  String get editEntryDateDialogTitle => 'تاریخ و زمان';

  @override
  String get editEntryDateDialogSetCustom => 'تنظیم تاریخ سفارشی';

  @override
  String get editEntryDateDialogCopyField => 'رونوشت از تاریخی دیگر';

  @override
  String get editEntryDateDialogExtractFromTitle => 'استخراج از عنوان';

  @override
  String get editEntryDateDialogShift => 'جابه‌جایی';

  @override
  String get editEntryDateDialogSourceFileModifiedDate => 'تاریخ تغییر پرونده';

  @override
  String get durationDialogHours => 'ساعت';

  @override
  String get durationDialogMinutes => 'دقیقه';

  @override
  String get durationDialogSeconds => 'ثانیه';

  @override
  String get editEntryLocationDialogTitle => 'مکان';

  @override
  String get editEntryLocationDialogSetCustom => 'تنظیم موقعیت سفارشی';

  @override
  String get editEntryLocationDialogChooseOnMap => 'انتخاب در نقشه';

  @override
  String get editEntryLocationDialogImportGpx => 'Import GPX';

  @override
  String get editEntryLocationDialogLatitude => 'عرض جغرافیایی';

  @override
  String get editEntryLocationDialogLongitude => 'طول جغرافیایی';

  @override
  String get editEntryLocationDialogTimeShift => 'Time shift';

  @override
  String get locationPickerUseThisLocationButton => 'استفاده از این مکان';

  @override
  String get editEntryRatingDialogTitle => 'امتیاز';

  @override
  String get removeEntryMetadataDialogTitle => 'پاک‌کردن فراداده';

  @override
  String get removeEntryMetadataDialogAll => 'All';

  @override
  String get removeEntryMetadataDialogMore => 'بیشتر';

  @override
  String get removeEntryMetadataMotionPhotoXmpWarningDialogMessage => 'XMP برای پخش ویدیو در داخل یک عکس متحرک مورد نیاز است.\n\nار پاک‌سازی آن اطمینان دارید?';

  @override
  String get videoSpeedDialogLabel => 'سرعت پخش';

  @override
  String get videoStreamSelectionDialogVideo => 'ویدیو';

  @override
  String get videoStreamSelectionDialogAudio => 'صدا';

  @override
  String get videoStreamSelectionDialogText => 'زیرنویس';

  @override
  String get videoStreamSelectionDialogOff => 'خاموش';

  @override
  String get videoStreamSelectionDialogTrack => 'صوت';

  @override
  String get videoStreamSelectionDialogNoSelection => 'هیچ صدا دیگری وجود ندارد.';

  @override
  String get genericSuccessFeedback => 'انجام شد!';

  @override
  String get genericFailureFeedback => 'ناموفق';

  @override
  String get genericDangerWarningDialogMessage => 'اطمینان دارید؟';

  @override
  String get tooManyItemsErrorDialogMessage => 'دوباره با موارد کمتر تلاش کنید.';

  @override
  String get menuActionConfigureView => 'تماشا';

  @override
  String get menuActionSelect => 'انتخاب';

  @override
  String get menuActionSelectAll => 'انتخاب همه';

  @override
  String get menuActionSelectNone => 'انتخاب هیچکدام';

  @override
  String get menuActionMap => 'نقشه';

  @override
  String get menuActionSlideshow => 'نمایش اسلایدی';

  @override
  String get menuActionStats => 'آمار';

  @override
  String get viewDialogSortSectionTitle => 'ترتیب بندی';

  @override
  String get viewDialogGroupSectionTitle => 'گروه بندی';

  @override
  String get viewDialogLayoutSectionTitle => 'چیدمان';

  @override
  String get viewDialogReverseSortOrder => 'ترتیب مرتب سازی معکوس';

  @override
  String get tileLayoutMosaic => 'موزائیک';

  @override
  String get tileLayoutGrid => 'شبکه';

  @override
  String get tileLayoutList => 'فهرست';

  @override
  String get castDialogTitle => 'پخش دستگاه ها';

  @override
  String get coverDialogTabCover => 'جلد';

  @override
  String get coverDialogTabApp => 'برنامه';

  @override
  String get coverDialogTabColor => 'رنگ';

  @override
  String get appPickDialogTitle => 'انتخاب برنامه';

  @override
  String get appPickDialogNone => 'هیچکدام';

  @override
  String get aboutPageTitle => 'درباره';

  @override
  String get aboutLinkLicense => 'مجوز';

  @override
  String get aboutLinkPolicy => 'سیاست حفظ حریم خصوصی';

  @override
  String get aboutBugSectionTitle => 'گزارشات خرابی';

  @override
  String get aboutBugSaveLogInstruction => 'ذخیره گزارش‌های برنامه در یک پرونده';

  @override
  String get aboutBugCopyInfoInstruction => 'رونوشت اطلاعات سامانه';

  @override
  String get aboutBugCopyInfoButton => 'کپی';

  @override
  String get aboutBugReportInstruction => 'در گیت‌هاب با گزارش ها و ریزگان دستگاه گزارش کنید';

  @override
  String get aboutBugReportButton => 'گزارش';

  @override
  String get aboutDataUsageSectionTitle => 'مصرف داده';

  @override
  String get aboutDataUsageData => 'داده';

  @override
  String get aboutDataUsageCache => 'حافظه پنهان';

  @override
  String get aboutDataUsageDatabase => 'پایگاه داده';

  @override
  String get aboutDataUsageMisc => 'متفرقه';

  @override
  String get aboutDataUsageInternal => 'داخلی';

  @override
  String get aboutDataUsageExternal => 'خارجی';

  @override
  String get aboutDataUsageClearCache => 'پاک ساری حافظه موقت';

  @override
  String get aboutCreditsSectionTitle => 'اعتبار';

  @override
  String get aboutCreditsWorldAtlas1 => 'این برنامه یک پرونده TopoJSON استفاده میکند از';

  @override
  String get aboutCreditsWorldAtlas2 => 'زیر مجوز ISC.';

  @override
  String get aboutTranslatorsSectionTitle => 'مترجم ها';

  @override
  String get aboutLicensesSectionTitle => 'مجوز متن-باز';

  @override
  String get aboutLicensesBanner => 'این برنامه از بسته‌ها و کتابخانه‌های منبع باز زیر استفاده می کند.';

  @override
  String get aboutLicensesAndroidLibrariesSectionTitle => 'کتابخانه‌های اندروید';

  @override
  String get aboutLicensesFlutterPluginsSectionTitle => 'افزونه‌های Flutter';

  @override
  String get aboutLicensesFlutterPackagesSectionTitle => 'بسته‌های Flutter';

  @override
  String get aboutLicensesDartPackagesSectionTitle => 'بسته‌های Dart';

  @override
  String get aboutLicensesShowAllButtonLabel => 'نمایش تمام مجوز ها';

  @override
  String get policyPageTitle => 'سیاست حفظ حریم خصوصی';

  @override
  String get collectionPageTitle => 'مجموعه';

  @override
  String get collectionPickPageTitle => 'انتخاب';

  @override
  String get collectionSelectPageTitle => 'انتخاب موارد';

  @override
  String get collectionActionShowTitleSearch => 'نمایش پالایش عنوان';

  @override
  String get collectionActionHideTitleSearch => 'پنهان سازی پالایش عنوان';

  @override
  String get collectionActionAddDynamicAlbum => 'Add dynamic album';

  @override
  String get collectionActionAddShortcut => 'افزودن میانبر';

  @override
  String get collectionActionSetHome => 'تنظیم به عنوان خانه';

  @override
  String get collectionActionEmptyBin => 'سطل خالی';

  @override
  String get collectionActionCopy => 'رونوشت به آلبوم';

  @override
  String get collectionActionMove => 'هدایت به آلبوم';

  @override
  String get collectionActionRescan => 'بررسی مجدد';

  @override
  String get collectionActionEdit => 'ویرایش';

  @override
  String get collectionSearchTitlesHintText => 'جستجو عناوین';

  @override
  String get collectionGroupAlbum => 'با آلبوم';

  @override
  String get collectionGroupMonth => 'با ماه';

  @override
  String get collectionGroupDay => 'با روز';

  @override
  String get collectionGroupNone => 'گروه نکن';

  @override
  String get sectionUnknown => 'ناشناس';

  @override
  String get dateToday => 'امروز';

  @override
  String get dateYesterday => 'دیروز';

  @override
  String get dateThisMonth => 'این ماه';

  @override
  String collectionDeleteFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'پاک‌کردن $count مورد ناموفق بود',
      one: 'پاک‌کردن ۱ مورد ناموفق بود',
    );
    return '$_temp0';
  }

  @override
  String collectionCopyFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'رونوشت $count مورد ناموفق بود',
      one: 'رونوشت ۱ مورد ناموفق بود',
    );
    return '$_temp0';
  }

  @override
  String collectionMoveFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'هدایت $count مورد ناموفق بود',
      one: 'هدایت ۱ مورد ناموفق بود',
    );
    return '$_temp0';
  }

  @override
  String collectionRenameFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تغییرنام $count مورد ناموفق بود',
      one: 'تغییرنام ۱ مورد ناموفق بود',
    );
    return '$_temp0';
  }

  @override
  String collectionEditFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ویرایش $count مورد ناموفق بود',
      one: 'ویرایش ۱ مورد ناموفق بود',
    );
    return '$_temp0';
  }

  @override
  String collectionExportFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'استخراج $count صفحه ناموفق',
      one: 'استخراج صفحه ناموفق',
    );
    return '$_temp0';
  }

  @override
  String collectionCopySuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مورد رونوشت شد',
      one: '۱ مورد رونوشت شد',
    );
    return '$_temp0';
  }

  @override
  String collectionMoveSuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مورد هدایت شد',
      one: '۱ مورد هدایت شد',
    );
    return '$_temp0';
  }

  @override
  String collectionRenameSuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مورد تغییرنام یافت',
      one: '۱ مورد تغییرنام یافت',
    );
    return '$_temp0';
  }

  @override
  String collectionEditSuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مورد ویرایش شد',
      one: '۱ مورد ویرایش شد',
    );
    return '$_temp0';
  }

  @override
  String get collectionEmptyFavourites => 'هیچ مورد علاقه ای وجود ندارد';

  @override
  String get collectionEmptyVideos => 'بدون ویدیو';

  @override
  String get collectionEmptyImages => 'بدون تصویر';

  @override
  String get collectionEmptyGrantAccessButtonLabel => 'گرفتن دسترسی';

  @override
  String get collectionSelectSectionTooltip => 'انتخاب بخش';

  @override
  String get collectionDeselectSectionTooltip => 'عدم‌انتخاب بخش';

  @override
  String get drawerAboutButton => 'درباره';

  @override
  String get drawerSettingsButton => 'تنظیمات';

  @override
  String get drawerCollectionAll => 'تمام مجموعه';

  @override
  String get drawerCollectionFavourites => 'مورد علاقه ها';

  @override
  String get drawerCollectionImages => 'تصاویر';

  @override
  String get drawerCollectionVideos => 'ویدیوها';

  @override
  String get drawerCollectionAnimated => 'پویانمایی شده';

  @override
  String get drawerCollectionMotionPhotos => 'تصاویر متحرک';

  @override
  String get drawerCollectionPanoramas => 'پانوراما';

  @override
  String get drawerCollectionRaws => 'تصاویر خام';

  @override
  String get drawerCollectionSphericalVideos => 'ویدیو‌های 360°';

  @override
  String get drawerAlbumPage => 'آلبوم ها';

  @override
  String get drawerCountryPage => 'کشور ها';

  @override
  String get drawerPlacePage => 'مکان ها';

  @override
  String get drawerTagPage => 'برچسب ها';

  @override
  String get sortByDate => 'با تاریخ';

  @override
  String get sortByName => 'با نام';

  @override
  String get sortByItemCount => 'با تعداد موارد';

  @override
  String get sortBySize => 'با اندازه';

  @override
  String get sortByAlbumFileName => 'با آلبوم و نام پرونده';

  @override
  String get sortByRating => 'با امتیازبندی';

  @override
  String get sortByDuration => 'By duration';

  @override
  String get sortOrderNewestFirst => 'اول جدیدترین';

  @override
  String get sortOrderOldestFirst => 'اول قدیمی‌ترین';

  @override
  String get sortOrderAtoZ => 'ا تا ی';

  @override
  String get sortOrderZtoA => 'ی تا ا';

  @override
  String get sortOrderHighestFirst => 'اول بالاترین';

  @override
  String get sortOrderLowestFirst => 'اول پایین‌ترین';

  @override
  String get sortOrderLargestFirst => 'اول بزرگترین';

  @override
  String get sortOrderSmallestFirst => 'اول کوچکترین';

  @override
  String get sortOrderShortestFirst => 'Shortest first';

  @override
  String get sortOrderLongestFirst => 'Longest first';

  @override
  String get albumGroupTier => 'با امتیاز';

  @override
  String get albumGroupType => 'با نوع';

  @override
  String get albumGroupVolume => 'با حجم ذخیره سازی';

  @override
  String get albumGroupNone => 'گروه نکن';

  @override
  String get albumMimeTypeMixed => 'ترکیبی';

  @override
  String get albumPickPageTitleCopy => 'رونوشت به آلبوم';

  @override
  String get albumPickPageTitleExport => 'خروجی گرفتن به البوم';

  @override
  String get albumPickPageTitleMove => 'هدایت به آلبوم';

  @override
  String get albumPickPageTitlePick => 'انتخاب آلبوم';

  @override
  String get albumCamera => 'دوربین';

  @override
  String get albumDownload => 'دریافت';

  @override
  String get albumScreenshots => 'تصاویر از صفحه';

  @override
  String get albumScreenRecordings => 'ضبط‌های از صفحه';

  @override
  String get albumVideoCaptures => 'ویدیو‌های ضبط شده';

  @override
  String get albumPageTitle => 'آلبوم ها';

  @override
  String get albumEmpty => 'بدون آلبوم';

  @override
  String get createAlbumButtonLabel => 'ساخت';

  @override
  String get newFilterBanner => 'جدید';

  @override
  String get countryPageTitle => 'کشور ها';

  @override
  String get countryEmpty => 'بدون کشور ها';

  @override
  String get statePageTitle => 'آمار ها';

  @override
  String get stateEmpty => 'داده‌ای نیست';

  @override
  String get placePageTitle => 'مکان ها';

  @override
  String get placeEmpty => 'مکانی نیست';

  @override
  String get tagPageTitle => 'برچسب ها';

  @override
  String get tagEmpty => 'بدون برچسب ها';

  @override
  String get binPageTitle => 'سطل زباله';

  @override
  String get explorerPageTitle => 'Explorer';

  @override
  String get explorerActionSelectStorageVolume => 'Select storage';

  @override
  String get selectStorageVolumeDialogTitle => 'Select Storage';

  @override
  String get searchCollectionFieldHint => 'جستجو مجموعه';

  @override
  String get searchRecentSectionTitle => 'اخیر';

  @override
  String get searchDateSectionTitle => 'تاریخ';

  @override
  String get searchAlbumsSectionTitle => 'آلبوم ها';

  @override
  String get searchCountriesSectionTitle => 'کشور ها';

  @override
  String get searchStatesSectionTitle => 'آمار ها';

  @override
  String get searchPlacesSectionTitle => 'مکان ها';

  @override
  String get searchTagsSectionTitle => 'برچسب ها';

  @override
  String get searchRatingSectionTitle => 'امتیازات';

  @override
  String get searchMetadataSectionTitle => 'فراداده';

  @override
  String get settingsPageTitle => 'تنظیمات';

  @override
  String get settingsSystemDefault => 'پیشفرض سامانه';

  @override
  String get settingsDefault => 'پیشفرض';

  @override
  String get settingsDisabled => 'خاموش';

  @override
  String get settingsAskEverytime => 'هر بار پرسیده شود';

  @override
  String get settingsModificationWarningDialogMessage => 'دیگر تنظیمات اصلاح خواهد شد.';

  @override
  String get settingsSearchFieldLabel => 'تنظیمات جستجو';

  @override
  String get settingsSearchEmpty => 'تنظیمی منطبق نشد';

  @override
  String get settingsActionExport => 'خروجی گرفتن';

  @override
  String get settingsActionExportDialogTitle => 'خروجی گرفتن';

  @override
  String get settingsActionImport => 'وارد کردن';

  @override
  String get settingsActionImportDialogTitle => 'وارد کردن';

  @override
  String get appExportCovers => 'جلد ها';

  @override
  String get appExportDynamicAlbums => 'Dynamic albums';

  @override
  String get appExportFavourites => 'مورد علاقه ها';

  @override
  String get appExportSettings => 'تنظیمات';

  @override
  String get settingsNavigationSectionTitle => 'پیمایش';

  @override
  String get settingsHomeTile => 'خانه';

  @override
  String get settingsHomeDialogTitle => 'خانه';

  @override
  String get setHomeCustom => 'Custom';

  @override
  String get settingsShowBottomNavigationBar => 'نمایش گزینه‌های پیمایش پایین';

  @override
  String get settingsKeepScreenOnTile => 'صفحه را روشن نگه دار';

  @override
  String get settingsKeepScreenOnDialogTitle => 'صفحه را روشن نگه دار';

  @override
  String get settingsDoubleBackExit => 'برای خروج دوبار روی «بازگشت» ضربه بزنید';

  @override
  String get settingsConfirmationTile => 'درخواست‌های تایید';

  @override
  String get settingsConfirmationDialogTitle => 'درخواست‌های‌ تایید';

  @override
  String get settingsConfirmationBeforeDeleteItems => 'همیشه پیش از پاک‌سازی موارد بپرس';

  @override
  String get settingsConfirmationBeforeMoveToBinItems => 'پیش از هدایت موارد به سطل زباله بپرسید';

  @override
  String get settingsConfirmationBeforeMoveUndatedItems => 'پیش از جابجایی موارد بدون تاریخ بپرسید';

  @override
  String get settingsConfirmationAfterMoveToBinItems => 'نمایش پیام پس از هدایت موارد به سطل زباله';

  @override
  String get settingsConfirmationVaultDataLoss => 'نمایش هشدار از دست دادن داده‌های گاوصندوق';

  @override
  String get settingsNavigationDrawerTile => 'گزینه‌های پیمایش';

  @override
  String get settingsNavigationDrawerEditorPageTitle => 'گزینه‌های پیمایش';

  @override
  String get settingsNavigationDrawerBanner => 'برای جابجایی و مرتب کردن مجدد موارد، لمس کنید و نگه دارید.';

  @override
  String get settingsNavigationDrawerTabTypes => 'انواع';

  @override
  String get settingsNavigationDrawerTabAlbums => 'آلبوم ها';

  @override
  String get settingsNavigationDrawerTabPages => 'صفحات';

  @override
  String get settingsNavigationDrawerAddAlbum => 'افزودن آلبوم';

  @override
  String get settingsThumbnailSectionTitle => 'ریز عکس ها';

  @override
  String get settingsThumbnailOverlayTile => 'روکش';

  @override
  String get settingsThumbnailOverlayPageTitle => 'روکش';

  @override
  String get settingsThumbnailShowHdrIcon => 'نمایش نماد HDR';

  @override
  String get settingsThumbnailShowFavouriteIcon => 'نمایش نماد علاقه‌مندی';

  @override
  String get settingsThumbnailShowTagIcon => 'نمایش نماد برچسب';

  @override
  String get settingsThumbnailShowLocationIcon => 'نمایش نماد مکان';

  @override
  String get settingsThumbnailShowMotionPhotoIcon => 'نمایش نماد تصویر متحرک';

  @override
  String get settingsThumbnailShowRating => 'نمایش امتیازبندی';

  @override
  String get settingsThumbnailShowRawIcon => 'نمایش نماد خامی';

  @override
  String get settingsThumbnailShowVideoDuration => 'نمایش مدت زمان ویدیو';

  @override
  String get settingsCollectionQuickActionsTile => 'کنش‌های سریع';

  @override
  String get settingsCollectionQuickActionEditorPageTitle => 'کنش‌های سریع';

  @override
  String get settingsCollectionQuickActionTabBrowsing => 'مرور کردن';

  @override
  String get settingsCollectionQuickActionTabSelecting => 'انتخاب کردن';

  @override
  String get settingsCollectionBrowsingQuickActionEditorBanner => 'برای جابجایی دکمه ها لمس کنید و نگه دارید و انتخاب کنید که کدام اقدامات هنگام مرور موارد نمایش داده شوند.';

  @override
  String get settingsCollectionSelectionQuickActionEditorBanner => 'برای جابجایی دکمه ها لمس کنید و نگه دارید و انتخاب کنید که کدام اقدامات هنگام انتخاب موارد نمایش داده شوند.';

  @override
  String get settingsCollectionBurstPatternsTile => 'الگوهای تصاویر چندتایی';

  @override
  String get settingsCollectionBurstPatternsNone => 'هیچکدام';

  @override
  String get settingsViewerSectionTitle => 'بیننده';

  @override
  String get settingsViewerGestureSideTapNext => 'روی لبه‌های صفحه ضربه بزنید تا مورد قبلی/بعدی نشان داده شود';

  @override
  String get settingsViewerUseCutout => 'ناحیه برش را بکار بگیر';

  @override
  String get settingsViewerMaximumBrightness => 'روشنایی حداکثری';

  @override
  String get settingsMotionPhotoAutoPlay => 'پخش خودکار تصویر متحرک';

  @override
  String get settingsImageBackground => 'پس‌زمینه تصاویر';

  @override
  String get settingsViewerQuickActionsTile => 'کنش‌های سریع';

  @override
  String get settingsViewerQuickActionEditorPageTitle => 'کنش‌های سریع';

  @override
  String get settingsViewerQuickActionEditorBanner => 'لمس کنید و نگه دارید تا دکمه ها را حرکت دهید و انتخاب کنید که کدام کنش ها در بیننده نمایش داده می شود.';

  @override
  String get settingsViewerQuickActionEditorDisplayedButtonsSectionTitle => 'دکمه‌های نمایش داده شده';

  @override
  String get settingsViewerQuickActionEditorAvailableButtonsSectionTitle => 'دکمه‌های در دسترس';

  @override
  String get settingsViewerQuickActionEmpty => 'بدون دکمه';

  @override
  String get settingsViewerOverlayTile => 'روکش';

  @override
  String get settingsViewerOverlayPageTitle => 'روکش';

  @override
  String get settingsViewerShowOverlayOnOpening => 'پس از باز شدن نمایش داده شود';

  @override
  String get settingsViewerShowHistogram => 'نمایش نمودار';

  @override
  String get settingsViewerShowMinimap => 'نمایش نقشه‌کوچک';

  @override
  String get settingsViewerShowInformation => 'نمایش درباره';

  @override
  String get settingsViewerShowInformationSubtitle => 'نمایش عنوان، تاریخ، مکان، و...';

  @override
  String get settingsViewerShowRatingTags => 'نمایش امتیازات و برچسب ها';

  @override
  String get settingsViewerShowShootingDetails => 'نمایش ریزگان تصویربرداری';

  @override
  String get settingsViewerShowDescription => 'نمایش ریزگان';

  @override
  String get settingsViewerShowOverlayThumbnails => 'نمایش ریزعکس ها';

  @override
  String get settingsViewerEnableOverlayBlurEffect => 'جلوه محو';

  @override
  String get settingsViewerSlideshowTile => 'تصاویر گردان';

  @override
  String get settingsViewerSlideshowPageTitle => 'تصاویر گردان';

  @override
  String get settingsSlideshowRepeat => 'تکرار';

  @override
  String get settingsSlideshowShuffle => 'در هم';

  @override
  String get settingsSlideshowFillScreen => 'پر کردن صفحه';

  @override
  String get settingsSlideshowAnimatedZoomEffect => 'جلوه بزرگنمایی پویانمایی شده';

  @override
  String get settingsSlideshowTransitionTile => 'هدایت';

  @override
  String get settingsSlideshowIntervalTile => 'فاصله';

  @override
  String get settingsSlideshowVideoPlaybackTile => 'پخش ویدیو';

  @override
  String get settingsSlideshowVideoPlaybackDialogTitle => 'پخش ویدیو';

  @override
  String get settingsVideoPageTitle => 'تنظیمات ویدیو';

  @override
  String get settingsVideoSectionTitle => 'ویدیو';

  @override
  String get settingsVideoShowVideos => 'نمایش ویدیو ها';

  @override
  String get settingsVideoPlaybackTile => 'پخش';

  @override
  String get settingsVideoPlaybackPageTitle => 'پخش';

  @override
  String get settingsVideoEnableHardwareAcceleration => 'شتاب سخت‌افزاری';

  @override
  String get settingsVideoAutoPlay => 'پخش خودکار';

  @override
  String get settingsVideoLoopModeTile => 'حالت حلقه';

  @override
  String get settingsVideoLoopModeDialogTitle => 'حالت حلقه';

  @override
  String get settingsVideoResumptionModeTile => 'ادامه پخش';

  @override
  String get settingsVideoResumptionModeDialogTitle => 'ادامه پخش';

  @override
  String get settingsVideoBackgroundMode => 'حالت پس‌زمینه';

  @override
  String get settingsVideoBackgroundModeDialogTitle => 'حالت پس‌زمینه‌';

  @override
  String get settingsVideoControlsTile => 'هدایت کننده ها';

  @override
  String get settingsVideoControlsPageTitle => 'هدایت کننده ها';

  @override
  String get settingsVideoButtonsTile => 'دکمه ها';

  @override
  String get settingsVideoGestureDoubleTapTogglePlay => 'برای پخش/ایست دوبار ضربه زدن';

  @override
  String get settingsVideoGestureSideDoubleTapSeek => 'روی لبه‌های صفحه دوبار ضربه بزنید تا به عقب/جلو بروید';

  @override
  String get settingsVideoGestureVerticalDragBrightnessVolume => 'برای تنظیم نور/صدا به بالا و پایین بکشید';

  @override
  String get settingsSubtitleThemeTile => 'زیرنویس ها';

  @override
  String get settingsSubtitleThemePageTitle => 'زیرنویس ها';

  @override
  String get settingsSubtitleThemeSample => 'این یک نمونه است.';

  @override
  String get settingsSubtitleThemeTextAlignmentTile => 'تراز متن';

  @override
  String get settingsSubtitleThemeTextAlignmentDialogTitle => 'تراز متن';

  @override
  String get settingsSubtitleThemeTextPositionTile => 'موقعیت متن';

  @override
  String get settingsSubtitleThemeTextPositionDialogTitle => 'موقعیت متن‌';

  @override
  String get settingsSubtitleThemeTextSize => 'اندازه متن';

  @override
  String get settingsSubtitleThemeShowOutline => 'نمایش نوار حاشیه و سایه';

  @override
  String get settingsSubtitleThemeTextColor => 'رنگ متن';

  @override
  String get settingsSubtitleThemeTextOpacity => 'شفافیت متن';

  @override
  String get settingsSubtitleThemeBackgroundColor => 'رنگ پس‌زمینه';

  @override
  String get settingsSubtitleThemeBackgroundOpacity => 'شفافیت پس‌زمینه';

  @override
  String get settingsSubtitleThemeTextAlignmentLeft => 'چپ';

  @override
  String get settingsSubtitleThemeTextAlignmentCenter => 'مرکز';

  @override
  String get settingsSubtitleThemeTextAlignmentRight => 'راست';

  @override
  String get settingsPrivacySectionTitle => 'حریم خصوصی';

  @override
  String get settingsAllowInstalledAppAccess => 'اجازه دسترسی به دارایی برنامه';

  @override
  String get settingsAllowInstalledAppAccessSubtitle => 'برای بهبود نمایش آلبوم به‌کارگرفته میشود';

  @override
  String get settingsAllowErrorReporting => 'اجازه به گزارش خطا ناشناس';

  @override
  String get settingsSaveSearchHistory => 'نگهداری تاریخچه جستجو';

  @override
  String get settingsEnableBin => 'به‌کارگیری سطل زباله';

  @override
  String get settingsEnableBinSubtitle => 'موارد پاک شده را به مدت 30 روز نگه دارید';

  @override
  String get settingsDisablingBinWarningDialogMessage => 'موارد موجود در سطل زباله برای همیشه نابود خواهند شد.';

  @override
  String get settingsAllowMediaManagement => 'اجازه مدیریت محتوا';

  @override
  String get settingsHiddenItemsTile => 'موارد پنهان';

  @override
  String get settingsHiddenItemsPageTitle => 'موارد پنهان';

  @override
  String get settingsHiddenFiltersBanner => 'تصاویر و ویدیوهایی که با پالایش‌های مخفی سازگار نیستند در مجموعه شما دیده نمیشوند.';

  @override
  String get settingsHiddenFiltersEmpty => 'پالایشی پنهان نیست';

  @override
  String get settingsStorageAccessTile => 'دسترسی حافظه';

  @override
  String get settingsStorageAccessPageTitle => 'دسترسی حافظه';

  @override
  String get settingsStorageAccessBanner => 'برخی پوشه ها برای اصلاح پرونده‌های موجود در آنها به یک مجوز دسترسی نیاز دارند. در اینجا می توانید پوشه هایی را که قبلاً به آنها دسترسی داشته اید، مرور کنید.';

  @override
  String get settingsStorageAccessEmpty => 'دسترسی اهدا نشد';

  @override
  String get settingsStorageAccessRevokeTooltip => 'لغو';

  @override
  String get settingsAccessibilitySectionTitle => 'دسترسی پذیری';

  @override
  String get settingsRemoveAnimationsTile => 'بدون پویانمایی';

  @override
  String get settingsRemoveAnimationsDialogTitle => 'بدون پویانمایی‌';

  @override
  String get settingsTimeToTakeActionTile => 'زمان اقدام';

  @override
  String get settingsAccessibilityShowPinchGestureAlternatives => 'نمایش جایگزین‌های چند لمس همزمان';

  @override
  String get settingsDisplaySectionTitle => 'نمایش';

  @override
  String get settingsThemeBrightnessTile => 'پوسته';

  @override
  String get settingsThemeBrightnessDialogTitle => 'پوسته';

  @override
  String get settingsThemeColorHighlights => 'رنگ متون برجسته';

  @override
  String get settingsThemeEnableDynamicColor => 'رنگ‌های پویا';

  @override
  String get settingsDisplayRefreshRateModeTile => 'نمایش نرخ تازه‌سازی';

  @override
  String get settingsDisplayRefreshRateModeDialogTitle => 'نرخ تازه‌سازی';

  @override
  String get settingsDisplayUseTvInterface => 'رابط تلویزیون اندروید';

  @override
  String get settingsLanguageSectionTitle => 'زبان و قالب ها';

  @override
  String get settingsLanguageTile => 'زبان';

  @override
  String get settingsLanguagePageTitle => 'زبان';

  @override
  String get settingsCoordinateFormatTile => 'قالب مختصات';

  @override
  String get settingsCoordinateFormatDialogTitle => 'قالب مختصات‌';

  @override
  String get settingsUnitSystemTile => 'واحد ها';

  @override
  String get settingsUnitSystemDialogTitle => 'واحد ها';

  @override
  String get settingsForceWesternArabicNumeralsTile => 'اجبار به اعداد عربی';

  @override
  String get settingsScreenSaverPageTitle => 'ذخیره کننده صفحه';

  @override
  String get settingsWidgetPageTitle => 'قاب تصویر';

  @override
  String get settingsWidgetShowOutline => 'نوار حاشیه';

  @override
  String get settingsWidgetOpenPage => 'هنگام ضربه زدن بر روی ابزارک';

  @override
  String get settingsWidgetDisplayedItem => 'موارد نمایش داده شده';

  @override
  String get settingsCollectionTile => 'مجموعه';

  @override
  String get statsPageTitle => 'آمار';

  @override
  String statsWithGps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مورد دارای مکان',
      one: '1 مورد دارای مکان',
    );
    return '$_temp0';
  }

  @override
  String get statsTopCountriesSectionTitle => 'کشور‌های ممتاز';

  @override
  String get statsTopStatesSectionTitle => 'آمارهای ممتاز';

  @override
  String get statsTopPlacesSectionTitle => 'مکان‌های ممتاز';

  @override
  String get statsTopTagsSectionTitle => 'برچسب‌های ممتاز';

  @override
  String get statsTopAlbumsSectionTitle => 'آلبوم‌های ممتاز';

  @override
  String get viewerOpenPanoramaButtonLabel => 'بازکردن پانوراما';

  @override
  String get viewerSetWallpaperButtonLabel => 'تنظیم کاغذدیواری';

  @override
  String get viewerErrorUnknown => 'اوه!';

  @override
  String get viewerErrorDoesNotExist => 'پرونده دیگر موجود نیست.';

  @override
  String get viewerInfoPageTitle => 'ریزگان';

  @override
  String get viewerInfoBackToViewerTooltip => 'بازگشت به نمایش‌گر';

  @override
  String get viewerInfoUnknown => 'ناشناخته';

  @override
  String get viewerInfoLabelDescription => 'پاورقی';

  @override
  String get viewerInfoLabelTitle => 'عنوان';

  @override
  String get viewerInfoLabelDate => 'تاریخ';

  @override
  String get viewerInfoLabelResolution => 'وضوح';

  @override
  String get viewerInfoLabelSize => 'اندازه';

  @override
  String get viewerInfoLabelUri => 'URI';

  @override
  String get viewerInfoLabelPath => 'مسیر';

  @override
  String get viewerInfoLabelDuration => 'مدت';

  @override
  String get viewerInfoLabelOwner => 'مالک';

  @override
  String get viewerInfoLabelCoordinates => 'مختصات';

  @override
  String get viewerInfoLabelAddress => 'نشانی';

  @override
  String get mapStyleDialogTitle => 'حالت نقشه';

  @override
  String get mapStyleTooltip => 'انتخاب حالت نقشه';

  @override
  String get mapZoomInTooltip => 'بزرگ نمایی';

  @override
  String get mapZoomOutTooltip => 'کوچک نمایی';

  @override
  String get mapPointNorthUpTooltip => 'نقطه شمال در بالا';

  @override
  String get mapAttributionOsmData => 'داده‌های نقشه © [OpenStreetMap](https:www.openstreetmap.org/copyright) مشارکت‌کنندگان';

  @override
  String get mapAttributionOsmLiberty => 'Tiles by [OpenMapTiles](https://www.openmaptiles.org/), [CC BY](http://creativecommons.org/licenses/by/4.0) • Hosted by [OSM Americana](https://tile.ourmap.us)';

  @override
  String get mapAttributionOpenTopoMap => '[SRTM](https://www.earthdata.nasa.gov/sensors/srtm) | Tiles by [OpenTopoMap](https://opentopomap.org/), [CC BY-SA](https://creativecommons.org/licenses/by-sa/3.0/)';

  @override
  String get mapAttributionOsmHot => 'کاشی ها توسط [HOT](https:www.hotosm.org) • میزبانی شده به دست [OSM France](https:openstreetmap.fr)';

  @override
  String get mapAttributionStamen => 'کاشی ها بدست [Stamen Design](https:stamen.com)، [CC BY 3.0](https:creativecommons.orglicensesby3.0)';

  @override
  String get openMapPageTooltip => 'نمایش در صفحه نقشه';

  @override
  String get mapEmptyRegion => 'تصویری در این ناحیه وجود ندارد';

  @override
  String get viewerInfoOpenEmbeddedFailureFeedback => 'هیچ تصویری در این منطقه وجود ندارد';

  @override
  String get viewerInfoOpenLinkText => 'بازکردن';

  @override
  String get viewerInfoViewXmlLinkText => 'نمایش XML';

  @override
  String get viewerInfoSearchFieldLabel => 'جستجو فراداده';

  @override
  String get viewerInfoSearchEmpty => 'کلیدی منطبق نشد';

  @override
  String get viewerInfoSearchSuggestionDate => 'تاریخ و زمان';

  @override
  String get viewerInfoSearchSuggestionDescription => 'پاورقی';

  @override
  String get viewerInfoSearchSuggestionDimensions => 'ابعاد';

  @override
  String get viewerInfoSearchSuggestionResolution => 'وضوح';

  @override
  String get viewerInfoSearchSuggestionRights => 'حقوق';

  @override
  String get wallpaperUseScrollEffect => 'استفاده از جلوه پیمایش در صفحه اصلی';

  @override
  String get tagEditorPageTitle => 'ویرایش برچسب ها‌';

  @override
  String get tagEditorPageNewTagFieldLabel => 'برسب جدید';

  @override
  String get tagEditorPageAddTagTooltip => 'افزودن برچسب';

  @override
  String get tagEditorSectionRecent => 'اخیر';

  @override
  String get tagEditorSectionPlaceholders => 'جایگاه متن';

  @override
  String get tagEditorDiscardDialogMessage => 'آیا می خواهید تغییرات را نادیده بگیرید?';

  @override
  String get tagPlaceholderCountry => 'کشور';

  @override
  String get tagPlaceholderState => 'آمار';

  @override
  String get tagPlaceholderPlace => 'مکان';

  @override
  String get panoramaEnableSensorControl => 'روشن کردن هدایت حسگر';

  @override
  String get panoramaDisableSensorControl => 'خاموش کردن هدایت حسگر';

  @override
  String get sourceViewerPageTitle => 'منبع';

  @override
  String get filePickerShowHiddenFiles => 'نمایش پرونده‌های پنهان';

  @override
  String get filePickerDoNotShowHiddenFiles => 'پرونده‌های پنهان را نمایش نده';

  @override
  String get filePickerOpenFrom => 'بازکردن از';

  @override
  String get filePickerNoItems => 'چیزی نیست';

  @override
  String get filePickerUseThisFolder => 'استفاده از این پوشه';
}
