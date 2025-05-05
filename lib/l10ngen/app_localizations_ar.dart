// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'Aves';

  @override
  String get welcomeMessage => 'مرحبا بكم في Aves';

  @override
  String get welcomeOptional => 'اختياري';

  @override
  String get welcomeTermsToggle => 'أوافق على الشروط';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عناصر',
      one: '$count عنصر',
    );
    return '$_temp0';
  }

  @override
  String columnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أعمدة',
      one: '$count عمود',
    );
    return '$_temp0$count';
  }

  @override
  String timeSeconds(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString ثواني',
      one: '$countString ثانية',
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
      other: '$countString دقائق',
      one: '$countString دقيقة',
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
      other: '$countString أيام',
      one: '$countString يوم',
    );
    return '$_temp0';
  }

  @override
  String focalLength(String length) {
    return '$length mm';
  }

  @override
  String get applyButtonLabel => 'تأكيد';

  @override
  String get createButtonLabel => 'CREATE';

  @override
  String get deleteButtonLabel => 'حذف';

  @override
  String get nextButtonLabel => 'التالي';

  @override
  String get showButtonLabel => 'إظهار';

  @override
  String get hideButtonLabel => 'إخفاء';

  @override
  String get continueButtonLabel => 'إستمرار';

  @override
  String get saveCopyButtonLabel => 'حفظ نسخة';

  @override
  String get applyTooltip => 'تأكيد';

  @override
  String get cancelTooltip => 'إلغاء';

  @override
  String get changeTooltip => 'تغيير';

  @override
  String get clearTooltip => 'تنظيف';

  @override
  String get previousTooltip => 'السابق';

  @override
  String get nextTooltip => 'التالي';

  @override
  String get showTooltip => 'إظهار';

  @override
  String get hideTooltip => 'إخفاء';

  @override
  String get actionRemove => 'إزالة';

  @override
  String get resetTooltip => 'إعادة';

  @override
  String get saveTooltip => 'حفظ';

  @override
  String get stopTooltip => 'توقف';

  @override
  String get pickTooltip => 'اختيار';

  @override
  String get doubleBackExitMessage => 'اضغط على «رجوع» مرة أخرى للخروج.';

  @override
  String get doNotAskAgain => 'عدم السؤال مرة أخرى';

  @override
  String get sourceStateLoading => 'تحميل';

  @override
  String get sourceStateCataloguing => 'تصنيف';

  @override
  String get sourceStateLocatingCountries => 'تحديد مواقع الدول';

  @override
  String get sourceStateLocatingPlaces => 'تحديد المواقع';

  @override
  String get chipActionDelete => 'حَذف';

  @override
  String get chipActionRemove => 'إزالة';

  @override
  String get chipActionShowCollection => 'عرض في المجموعة';

  @override
  String get chipActionGoToAlbumPage => 'عرض في الألبومات';

  @override
  String get chipActionGoToCountryPage => 'عرض في الدول';

  @override
  String get chipActionGoToPlacePage => 'عرض في الأماكن';

  @override
  String get chipActionGoToTagPage => 'عرض في الوسوم';

  @override
  String get chipActionGoToExplorerPage => 'عرض في المستكشف';

  @override
  String get chipActionDecompose => 'فصل';

  @override
  String get chipActionFilterOut => 'تصفية أو استبعاد';

  @override
  String get chipActionFilterIn => 'تصفية أو اختيار';

  @override
  String get chipActionHide => 'إخفاء';

  @override
  String get chipActionLock => 'قَفل';

  @override
  String get chipActionPin => 'تثبيت في الأعلى';

  @override
  String get chipActionUnpin => 'إلغاء التثبيت في الأعلى';

  @override
  String get chipActionGroup => 'Group';

  @override
  String get chipActionRename => 'إعادة تسمية';

  @override
  String get chipActionSetCover => 'تعيين كغلاف';

  @override
  String get chipActionShowCountryStates => 'عرض الولايات';

  @override
  String get chipActionCreateGroup => 'Create group';

  @override
  String get chipActionCreateAlbum => 'إنشاء ألبوم';

  @override
  String get chipActionCreateVault => 'إنشاء خزنة';

  @override
  String get chipActionConfigureVault => 'تكوين الخزنة';

  @override
  String get entryActionCopyToClipboard => 'نسخ إلى الحافظة';

  @override
  String get entryActionDelete => 'حذف';

  @override
  String get entryActionConvert => 'تحويل';

  @override
  String get entryActionExport => 'المزيد';

  @override
  String get entryActionInfo => 'معلومات';

  @override
  String get entryActionRename => 'إعادة تسمية';

  @override
  String get entryActionRestore => 'استعادة';

  @override
  String get entryActionRotateCCW => 'تدوير عكس عقارب الساعة';

  @override
  String get entryActionRotateCW => 'تدوير في اتجاه عقارب الساعة';

  @override
  String get entryActionFlip => 'عكس أفقيًا';

  @override
  String get entryActionPrint => 'طباعة';

  @override
  String get entryActionShare => 'مشاركة';

  @override
  String get entryActionShareImageOnly => 'مشاركة الصورة فقط';

  @override
  String get entryActionShareVideoOnly => 'مشاركة الفيديوهات فقط';

  @override
  String get entryActionViewSource => 'عرض المصدر';

  @override
  String get entryActionShowGeoTiffOnMap => 'عرض كتراكب على الخريطة';

  @override
  String get entryActionConvertMotionPhotoToStillImage => 'تحويل إلى صورة ثابتة';

  @override
  String get entryActionViewMotionPhotoVideo => 'فتح الفيديو';

  @override
  String get entryActionEdit => 'تحرير';

  @override
  String get entryActionOpen => 'فتح باستخدام';

  @override
  String get entryActionSetAs => 'تعيين كـ';

  @override
  String get entryActionCast => 'البث';

  @override
  String get entryActionOpenMap => 'عرض في تطبيق الخرائط';

  @override
  String get entryActionRotateScreen => 'تدوير الشاشة';

  @override
  String get entryActionAddFavourite => 'إضافة إلى المفضلة';

  @override
  String get entryActionRemoveFavourite => 'إزالة من المفضلة';

  @override
  String get videoActionCaptureFrame => 'التقاط الإطار';

  @override
  String get videoActionMute => 'كتم الصوت';

  @override
  String get videoActionUnmute => 'إلغاء كتم الصوت';

  @override
  String get videoActionPause => 'إيقاف مؤقت';

  @override
  String get videoActionPlay => 'تشغيل';

  @override
  String get videoActionReplay10 => 'الرجوع للخلف لمدة 10 ثوانٍ';

  @override
  String get videoActionSkip10 => 'تقدم إلى الأمام لمدة 10 ثوانٍ';

  @override
  String get videoActionShowPreviousFrame => 'إظهار الإطار السابق';

  @override
  String get videoActionShowNextFrame => 'إظهار الإطار التالي';

  @override
  String get videoActionSelectStreams => 'اختيار المسارات';

  @override
  String get videoActionSetSpeed => 'سرعة التشغيل';

  @override
  String get videoActionABRepeat => 'تكرار A-B';

  @override
  String get videoRepeatActionSetStart => 'تعيين بداية التشغيل';

  @override
  String get videoRepeatActionSetEnd => 'تعيين نهاية التشغيل';

  @override
  String get viewerActionSettings => 'الإعدادات';

  @override
  String get viewerActionLock => 'قفل المعاينة';

  @override
  String get viewerActionUnlock => 'إلغاء قفل المعاينة';

  @override
  String get slideshowActionResume => 'استئناف';

  @override
  String get slideshowActionShowInCollection => 'عرض في المجموعة';

  @override
  String get entryInfoActionEditDate => 'تعديل التاريخ والوقت';

  @override
  String get entryInfoActionEditLocation => 'تحديد الوجهة';

  @override
  String get entryInfoActionEditTitleDescription => 'تحرير العنوان والوصف';

  @override
  String get entryInfoActionEditRating => 'تحرير التقييم';

  @override
  String get entryInfoActionEditTags => 'تعديل العلامات';

  @override
  String get entryInfoActionRemoveMetadata => 'إزالة البيانات الوصفية';

  @override
  String get entryInfoActionExportMetadata => 'تصدير البيانات الوصفية';

  @override
  String get entryInfoActionRemoveLocation => 'إزالة الموقع';

  @override
  String get editorActionTransform => 'تحويل';

  @override
  String get editorTransformCrop => 'قص';

  @override
  String get editorTransformRotate => 'تدوير';

  @override
  String get cropAspectRatioFree => 'حر';

  @override
  String get cropAspectRatioOriginal => 'الأصل';

  @override
  String get cropAspectRatioSquare => 'مربع';

  @override
  String get filterAspectRatioLandscapeLabel => 'طبيعي';

  @override
  String get filterAspectRatioPortraitLabel => 'لوحة';

  @override
  String get filterBinLabel => 'سلة المَحذوفات';

  @override
  String get filterFavouriteLabel => 'مفضل';

  @override
  String get filterNoDateLabel => 'غير مؤرخ';

  @override
  String get filterNoAddressLabel => 'لا يوجد عنوان';

  @override
  String get filterLocatedLabel => 'متواجد';

  @override
  String get filterNoLocationLabel => 'غير محدد';

  @override
  String get filterNoRatingLabel => 'غير مصنف';

  @override
  String get filterTaggedLabel => 'الموسومة';

  @override
  String get filterNoTagLabel => 'بدون علامات';

  @override
  String get filterNoTitleLabel => 'بدون عنوان';

  @override
  String get filterOnThisDayLabel => 'في هذا اليوم';

  @override
  String get filterRecentlyAddedLabel => 'أضيف مؤخرا';

  @override
  String get filterRatingRejectedLabel => 'مرفوض';

  @override
  String get filterTypeAnimatedLabel => 'متحرك';

  @override
  String get filterTypeMotionPhotoLabel => 'الصور المتحركة';

  @override
  String get filterTypePanoramaLabel => 'بانوراما';

  @override
  String get filterTypeRawLabel => 'خام';

  @override
  String get filterTypeSphericalVideoLabel => 'فيديو 360 درجة';

  @override
  String get filterTypeGeotiffLabel => 'GeoTIFF';

  @override
  String get filterMimeImageLabel => 'صورة';

  @override
  String get filterMimeVideoLabel => 'فيديو';

  @override
  String get accessibilityAnimationsRemove => 'منع تأثيرات الشاشة';

  @override
  String get accessibilityAnimationsKeep => 'الحفاظ على تأثيرات الشاشة';

  @override
  String get albumTierNew => 'جديد';

  @override
  String get albumTierPinned => 'مثبت';

  @override
  String get albumTierGroups => 'Groups';

  @override
  String get albumTierSpecial => 'شائع';

  @override
  String get albumTierApps => 'تطبيقات';

  @override
  String get albumTierVaults => 'خزائن';

  @override
  String get albumTierDynamic => 'ديناميكي';

  @override
  String get albumTierRegular => 'آخرون';

  @override
  String get coordinateFormatDms => 'نظام إدارة الوجهة';

  @override
  String get coordinateFormatDdm => 'DDM';

  @override
  String get coordinateFormatDecimal => 'الدرجات العشرية';

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
  String get displayRefreshRatePreferHighest => 'أعلى معدل';

  @override
  String get displayRefreshRatePreferLowest => 'أدنى معدل';

  @override
  String get keepScreenOnNever => 'أبداً';

  @override
  String get keepScreenOnVideoPlayback => 'أثناء تشغيل الفيديو';

  @override
  String get keepScreenOnViewerOnly => 'صفحة المشاهدة فقط';

  @override
  String get keepScreenOnAlways => 'دائما';

  @override
  String get lengthUnitPixel => 'بكسل';

  @override
  String get lengthUnitPercent => '%';

  @override
  String get mapStyleGoogleNormal => 'خرائط جوجل';

  @override
  String get mapStyleGoogleHybrid => 'خرائط جوجل (الهجينة)';

  @override
  String get mapStyleGoogleTerrain => 'خرائط جوجل (التضاريس)';

  @override
  String get mapStyleOsmLiberty => 'حرية خرائط OSM';

  @override
  String get mapStyleOpenTopoMap => 'الخريطة الطبوغرافية المفتوحة';

  @override
  String get mapStyleOsmHot => 'خرائط OSM';

  @override
  String get mapStyleStamenWatercolor => 'ستايمن بالألوان المائية';

  @override
  String get maxBrightnessNever => 'أبداً';

  @override
  String get maxBrightnessAlways => 'دائماً';

  @override
  String get nameConflictStrategyRename => 'إعادة تسمية';

  @override
  String get nameConflictStrategyReplace => 'إستبدال';

  @override
  String get nameConflictStrategySkip => 'تخطي';

  @override
  String get overlayHistogramNone => 'لا شيء';

  @override
  String get overlayHistogramRGB => 'RGB';

  @override
  String get overlayHistogramLuminance => 'الانارة';

  @override
  String get subtitlePositionTop => 'أعلى';

  @override
  String get subtitlePositionBottom => 'أسفل';

  @override
  String get themeBrightnessLight => 'مضيء';

  @override
  String get themeBrightnessDark => 'مظلم';

  @override
  String get themeBrightnessBlack => 'أسود';

  @override
  String get unitSystemMetric => 'النظام المتري';

  @override
  String get unitSystemImperial => 'النظام الإنشي';

  @override
  String get vaultLockTypePattern => 'نمط';

  @override
  String get vaultLockTypePin => 'رمز سري';

  @override
  String get vaultLockTypePassword => 'كلمة سر';

  @override
  String get settingsVideoEnablePip => 'صورة في صورة';

  @override
  String get videoControlsPlayOutside => 'فتح في مشغل آخر';

  @override
  String get videoLoopModeNever => 'أبداً';

  @override
  String get videoLoopModeShortOnly => 'فيديوهات قصيرة فقط';

  @override
  String get videoLoopModeAlways => 'دائماً';

  @override
  String get videoPlaybackSkip => 'تخطي';

  @override
  String get videoPlaybackMuted => 'تشغيل بدون صوت';

  @override
  String get videoPlaybackWithSound => 'تشغيل بالصوت';

  @override
  String get videoResumptionModeNever => 'أبداً';

  @override
  String get videoResumptionModeAlways => 'دائماً';

  @override
  String get viewerTransitionSlide => 'الإنزلاق';

  @override
  String get viewerTransitionParallax => 'تأثير الشبكية';

  @override
  String get viewerTransitionFade => 'تلاشي';

  @override
  String get viewerTransitionZoomIn => 'تكبير';

  @override
  String get viewerTransitionNone => 'لا شيء';

  @override
  String get wallpaperTargetHome => 'الشاشة الرئيسية';

  @override
  String get wallpaperTargetLock => 'شاشة القفل';

  @override
  String get wallpaperTargetHomeLock => 'الشاشة الرئيسية وشاشة القفل';

  @override
  String get widgetDisplayedItemRandom => 'عشوائي';

  @override
  String get widgetDisplayedItemMostRecent => 'الأحدث';

  @override
  String get widgetOpenPageHome => 'إفتح الرئيسية';

  @override
  String get widgetOpenPageCollection => 'فتح المجموعة';

  @override
  String get widgetOpenPageViewer => 'افتح العارض';

  @override
  String get widgetTapUpdateWidget => 'تحديث الويدجت';

  @override
  String get storageVolumeDescriptionFallbackPrimary => 'التخزين الداخلي';

  @override
  String get storageVolumeDescriptionFallbackNonPrimary => 'بطاقة الذاكرة';

  @override
  String get rootDirectoryDescription => 'دليل الجذر';

  @override
  String otherDirectoryDescription(String name) {
    return 'دليل «$name»';
  }

  @override
  String storageAccessDialogMessage(String directory, String volume) {
    return 'يرجى تحديد $directory لـ «$volume» في الشاشة التالية لمنح هذا التطبيق حق الوصول إليه.';
  }

  @override
  String restrictedAccessDialogMessage(String directory, String volume) {
    return 'لا يُسمح لهذا التطبيق بتعديل الملفات في $directory لـ «$volume»\n\nالرجاء استخدام مدير الملفات أو تطبيق المعرض المثبت مسبقًا لنقل العناصر إلى دليل آخر.';
  }

  @override
  String notEnoughSpaceDialogMessage(String neededSize, String freeSize, String volume) {
    return 'تحتاج هذه العملية إلى $neededSize من المساحة الحرة على «$volume» لإكمالها، ولكن لم يتبق سوى $freeSize.';
  }

  @override
  String get missingSystemFilePickerDialogMessage => 'منتقي ملفات النظام مفقود أو معطل. يرجى تمكينه والمحاولة مرة أخرى.';

  @override
  String unsupportedTypeDialogMessage(int count, String types) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'هذه العملية غير معتمدة لعناصر الأنواع التالية: $types.',
      one: 'هذه العملية غير مدعومة للعناصر من النوع التالي: $types.',
    );
    return '$_temp0';
  }

  @override
  String get nameConflictDialogSingleSourceMessage => 'بعض الملفات الموجودة في مجلد الوجهة لها نفس الاسم.';

  @override
  String get nameConflictDialogMultipleSourceMessage => 'بعض الملفات لها نفس الاسم.';

  @override
  String get addShortcutDialogLabel => 'تسمية الاختصار';

  @override
  String get addShortcutButtonLabel => 'إضافة';

  @override
  String get noMatchingAppDialogMessage => 'لا توجد تطبيقات يمكنها التعامل مع هذا.';

  @override
  String binEntriesConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'حرك هذه $countالعناصر إلى سلة المحذوفات؟',
      one: 'هل تريد نقل هذا العنصر إلى سلة المحذوفات؟',
    );
    return '$_temp0';
  }

  @override
  String deleteEntriesConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'احذف هذه $count أغراض؟',
      one: 'هل تريد حذف هذا العنصر؟',
    );
    return '$_temp0';
  }

  @override
  String get moveUndatedConfirmationDialogMessage => 'هل تريد حفظ تواريخ العناصر قبل المتابعة؟';

  @override
  String get moveUndatedConfirmationDialogSetDate => 'حفظ التواريخ';

  @override
  String videoResumeDialogMessage(String time) {
    return 'هل ترغب في استئناف التشغيل في $time؟';
  }

  @override
  String get videoStartOverButtonLabel => 'ابدأ من جديد';

  @override
  String get videoResumeButtonLabel => 'إستئناف';

  @override
  String get setCoverDialogLatest => 'أحدث عنصر';

  @override
  String get setCoverDialogAuto => 'آلي';

  @override
  String get setCoverDialogCustom => 'مخصص';

  @override
  String get hideFilterConfirmationDialogMessage => 'سيتم إخفاء الصور ومقاطع الفيديو المطابقة من مجموعتك. ويمكنك إظهارها مرة أخرى من إعدادات «الخصوصية».\n\nهل أنت متأكد أنك تريد إخفاءهم؟';

  @override
  String get newAlbumDialogTitle => 'البوم جديد';

  @override
  String get newAlbumDialogNameLabel => 'اسم الألبوم';

  @override
  String get newAlbumDialogAlbumAlreadyExistsHelper => 'الألبوم موجود بالفعل';

  @override
  String get newAlbumDialogNameLabelAlreadyExistsHelper => 'الدليل موجود بالفعل';

  @override
  String get newAlbumDialogStorageLabel => 'تخزين:';

  @override
  String get newDynamicAlbumDialogTitle => 'ألبوم ديناميكي جديد';

  @override
  String get dynamicAlbumAlreadyExists => 'الألبوم الديناميكي موجود بالفعل';

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
  String get newVaultWarningDialogMessage => 'العناصر الموجودة في الخزائن متاحة فقط لهذا التطبيق وليس للتطبيقات الأخرى.\n\nإذا قمت بإلغاء تثبيت هذا التطبيق، أو قمت بحذف بيانات هذا التطبيق، فسوف تفقد كل هذه العناصر.';

  @override
  String get newVaultDialogTitle => 'خزنة جديدة';

  @override
  String get configureVaultDialogTitle => 'تكوين خزنة';

  @override
  String get vaultDialogLockModeWhenScreenOff => 'القفل عند إيقاف تشغيل الشاشة';

  @override
  String get vaultDialogLockTypeLabel => 'نوع القفل';

  @override
  String get patternDialogEnter => 'أدخل النمط';

  @override
  String get patternDialogConfirm => 'تأكيد النمط';

  @override
  String get pinDialogEnter => 'أدخل الرمز السري';

  @override
  String get pinDialogConfirm => 'تأكيد الرمز السري';

  @override
  String get passwordDialogEnter => 'أدخل كلمة السر';

  @override
  String get passwordDialogConfirm => 'تأكيد كلمة السر';

  @override
  String get authenticateToConfigureVault => 'قم بالمصادقة لتكوين الخزنة';

  @override
  String get authenticateToUnlockVault => 'المصادقة لفتح الخزنة';

  @override
  String get vaultBinUsageDialogMessage => 'تستخدم بعض الخزائن سلة المحذوفات.';

  @override
  String get renameAlbumDialogLabel => 'إسم جديد';

  @override
  String get renameAlbumDialogLabelAlreadyExistsHelper => 'الدليل موجود بالفعل';

  @override
  String get renameEntrySetPageTitle => 'إعادة تسمية';

  @override
  String get renameEntrySetPagePatternFieldLabel => 'نمط التسمية';

  @override
  String get renameEntrySetPageInsertTooltip => 'أدخل الحقل';

  @override
  String get renameEntrySetPagePreviewSectionTitle => 'معاينة';

  @override
  String get renameProcessorCounter => 'عداد';

  @override
  String get renameProcessorHash => 'تجزئة';

  @override
  String get renameProcessorName => 'اسم';

  @override
  String deleteSingleAlbumConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'احذف هذا الألبوم و $count العناصر فيه؟',
      one: 'هل تريد حذف هذا الألبوم والعنصر الموجود فيه؟',
    );
    return '$_temp0';
  }

  @override
  String deleteMultiAlbumConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'احذف هذه الألبومات و $count العناصر فيها؟',
      one: 'هل تريد حذف هذه الألبومات والعنصر الموجود فيها؟',
    );
    return '$_temp0';
  }

  @override
  String get exportEntryDialogFormat => 'شكل:';

  @override
  String get exportEntryDialogWidth => 'عرض';

  @override
  String get exportEntryDialogHeight => 'ارتفاع';

  @override
  String get exportEntryDialogQuality => 'جودة';

  @override
  String get exportEntryDialogWriteMetadata => 'كتابة البيانات الوصفية';

  @override
  String get renameEntryDialogLabel => 'اسم جديد';

  @override
  String get editEntryDialogCopyFromItem => 'نسخ من عنصر آخر';

  @override
  String get editEntryDialogTargetFieldsHeader => 'الحقول المراد تعديلها';

  @override
  String get editEntryDateDialogTitle => 'التاريخ والوقت';

  @override
  String get editEntryDateDialogSetCustom => 'تحديد تاريخ مخصص';

  @override
  String get editEntryDateDialogCopyField => 'نسخة من تاريخ آخر';

  @override
  String get editEntryDateDialogExtractFromTitle => 'استخراج من العنوان';

  @override
  String get editEntryDateDialogShift => 'تغيير';

  @override
  String get editEntryDateDialogSourceFileModifiedDate => 'تاريخ تعديل الملف';

  @override
  String get durationDialogHours => 'ساعات';

  @override
  String get durationDialogMinutes => 'دقائق';

  @override
  String get durationDialogSeconds => 'ثواني';

  @override
  String get editEntryLocationDialogTitle => 'موقع';

  @override
  String get editEntryLocationDialogSetCustom => 'تعيين الموقع المخصص';

  @override
  String get editEntryLocationDialogChooseOnMap => 'اختر على الخريطة';

  @override
  String get editEntryLocationDialogImportGpx => 'استيراد GPX';

  @override
  String get editEntryLocationDialogLatitude => 'خط العرض';

  @override
  String get editEntryLocationDialogLongitude => 'خط الطول';

  @override
  String get editEntryLocationDialogTimeShift => 'التحول الزمني';

  @override
  String get locationPickerUseThisLocationButton => 'استخدم هذا الموقع';

  @override
  String get editEntryRatingDialogTitle => 'تقييم';

  @override
  String get removeEntryMetadataDialogTitle => 'ازالة البيانات الوصفية';

  @override
  String get removeEntryMetadataDialogAll => 'الكل';

  @override
  String get removeEntryMetadataDialogMore => 'أكثر';

  @override
  String get removeEntryMetadataMotionPhotoXmpWarningDialogMessage => 'مطلوب XMP لتشغيل الفيديو داخل الصورة المتحركة.\n\nهل أنت متأكد أنك تريد إزالته؟';

  @override
  String get videoSpeedDialogLabel => 'سرعة التشغيل';

  @override
  String get videoStreamSelectionDialogVideo => 'فيديو';

  @override
  String get videoStreamSelectionDialogAudio => 'صوت';

  @override
  String get videoStreamSelectionDialogText => 'ترجمات';

  @override
  String get videoStreamSelectionDialogOff => 'ايقاف';

  @override
  String get videoStreamSelectionDialogTrack => 'مسار';

  @override
  String get videoStreamSelectionDialogNoSelection => 'لا توجد مسارات أخرى.';

  @override
  String get genericSuccessFeedback => 'إنتهى!';

  @override
  String get genericFailureFeedback => 'فشل';

  @override
  String get genericDangerWarningDialogMessage => 'هل أنت متأكد؟';

  @override
  String get tooManyItemsErrorDialogMessage => 'حاول مرة أخرى باستخدام عدد أقل من العناصر.';

  @override
  String get menuActionConfigureView => 'العرض';

  @override
  String get menuActionSelect => 'تحديد';

  @override
  String get menuActionSelectAll => 'تحديد الكل';

  @override
  String get menuActionSelectNone => 'لا تحدد شيء';

  @override
  String get menuActionMap => 'خريطة';

  @override
  String get menuActionSlideshow => 'عرض الشرائح';

  @override
  String get menuActionStats => 'احصائيات';

  @override
  String get viewDialogSortSectionTitle => 'نوع';

  @override
  String get viewDialogGroupSectionTitle => 'مجموعة';

  @override
  String get viewDialogLayoutSectionTitle => 'تخطيط';

  @override
  String get viewDialogReverseSortOrder => 'عكس ترتيب الفرز';

  @override
  String get tileLayoutMosaic => 'فسيفساء';

  @override
  String get tileLayoutGrid => 'شبكة';

  @override
  String get tileLayoutList => 'قائمة';

  @override
  String get castDialogTitle => 'أجهزة البث';

  @override
  String get coverDialogTabCover => 'غلاف';

  @override
  String get coverDialogTabApp => 'التطبيق';

  @override
  String get coverDialogTabColor => 'اللون';

  @override
  String get appPickDialogTitle => 'اختر التطبيق';

  @override
  String get appPickDialogNone => 'لاشيء';

  @override
  String get aboutPageTitle => 'حول';

  @override
  String get aboutLinkLicense => 'رخصة';

  @override
  String get aboutLinkPolicy => 'سياسة الخصوصية';

  @override
  String get aboutBugSectionTitle => 'تقرير الأخطاء';

  @override
  String get aboutBugSaveLogInstruction => 'حفظ سجلات التطبيق في ملف';

  @override
  String get aboutBugCopyInfoInstruction => 'نسخ معلومات النظام';

  @override
  String get aboutBugCopyInfoButton => 'نسخ';

  @override
  String get aboutBugReportInstruction => 'تقرير على GitHub مع السجلات ومعلومات النظام';

  @override
  String get aboutBugReportButton => 'تقرير';

  @override
  String get aboutDataUsageSectionTitle => 'استخدام البيانات';

  @override
  String get aboutDataUsageData => 'بيانات';

  @override
  String get aboutDataUsageCache => 'التخزين المؤقت';

  @override
  String get aboutDataUsageDatabase => 'قاعدة البيانات';

  @override
  String get aboutDataUsageMisc => 'منوعات';

  @override
  String get aboutDataUsageInternal => 'داخلي';

  @override
  String get aboutDataUsageExternal => 'خارجي';

  @override
  String get aboutDataUsageClearCache => 'مسح ذاكرة التخزين المؤقت';

  @override
  String get aboutCreditsSectionTitle => 'الاعتمادات';

  @override
  String get aboutCreditsWorldAtlas1 => 'يستخدم هذا التطبيق ملف TopoJSON من';

  @override
  String get aboutCreditsWorldAtlas2 => 'بموجب ترخيص ISC.';

  @override
  String get aboutTranslatorsSectionTitle => 'المترجمين';

  @override
  String get aboutLicensesSectionTitle => 'تراخيص مفتوحة المصدر';

  @override
  String get aboutLicensesBanner => 'يستخدم هذا التطبيق الحزم والمكتبات مفتوحة المصدر التالية.';

  @override
  String get aboutLicensesAndroidLibrariesSectionTitle => 'مكتبات أندرويد';

  @override
  String get aboutLicensesFlutterPluginsSectionTitle => 'مكونات إضافية';

  @override
  String get aboutLicensesFlutterPackagesSectionTitle => 'حزم إضافية';

  @override
  String get aboutLicensesDartPackagesSectionTitle => 'حزم البرمجة';

  @override
  String get aboutLicensesShowAllButtonLabel => 'عرض كافة التراخيص';

  @override
  String get policyPageTitle => 'سياسة الخصوصية';

  @override
  String get collectionPageTitle => 'مجموعة بيانات';

  @override
  String get collectionPickPageTitle => 'اختيار';

  @override
  String get collectionSelectPageTitle => 'اختيار العناصر';

  @override
  String get collectionActionShowTitleSearch => 'إظهار مرشح العنوان';

  @override
  String get collectionActionHideTitleSearch => 'إخفاء مرشح العنوان';

  @override
  String get collectionActionAddDynamicAlbum => 'إضافة ألبوم ديناميكي';

  @override
  String get collectionActionAddShortcut => 'إضافة اختصار';

  @override
  String get collectionActionSetHome => 'تعيين كخلفية';

  @override
  String get collectionActionEmptyBin => 'سلة فارغة';

  @override
  String get collectionActionCopy => 'نسخ إلى الألبوم';

  @override
  String get collectionActionMove => 'نقل إلى الألبوم';

  @override
  String get collectionActionRescan => 'إعادة المسح';

  @override
  String get collectionActionEdit => 'تحرير';

  @override
  String get collectionSearchTitlesHintText => 'عناوين البحث';

  @override
  String get collectionGroupAlbum => 'حسب الألبوم';

  @override
  String get collectionGroupMonth => 'حسب الشهر';

  @override
  String get collectionGroupDay => 'حسب اليوم';

  @override
  String get sectionNone => 'No sections';

  @override
  String get sectionUnknown => 'مجهول';

  @override
  String get dateToday => 'اليوم';

  @override
  String get dateYesterday => 'أمس';

  @override
  String get dateThisMonth => 'هذا الشهر';

  @override
  String collectionDeleteFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'فشل الحذف $count items',
      one: 'فشل حذف عنصر واحد',
    );
    return '$_temp0';
  }

  @override
  String collectionCopyFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'فشل النسخ $count items',
      one: 'فشل نسخ عنصر واحد',
    );
    return '$_temp0';
  }

  @override
  String collectionMoveFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'فشل في النقل $count items',
      one: 'فشل في نقل عنصر واحد',
    );
    return '$_temp0';
  }

  @override
  String collectionRenameFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'فشلت إعادة التسمية $count items',
      one: 'فشلت إعادة تسمية عنصر واحد',
    );
    return '$_temp0';
  }

  @override
  String collectionEditFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'فشل التحرير $count items',
      one: 'فشل تحرير عنصر واحد',
    );
    return '$_temp0';
  }

  @override
  String collectionExportFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'فشل التصدير $count pages',
      one: 'فشل تصدير صفحة واحدة',
    );
    return '$_temp0';
  }

  @override
  String collectionCopySuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'نسخ $count أغراض',
      one: 'تم نسخ عنصر واحد',
    );
    return '$_temp0';
  }

  @override
  String collectionMoveSuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'نقل $count عناصر',
      one: 'تم نقل عنصر واحد',
    );
    return '$_temp0';
  }

  @override
  String collectionRenameSuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'أعادة تسمية $count عناصر',
      one: 'تمت إعادة تسمية عنصر واحد',
    );
    return '$_temp0';
  }

  @override
  String collectionEditSuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تحرير $count عناصر',
      one: 'تم تحريرعنصر واحد',
    );
    return '$_temp0';
  }

  @override
  String get collectionEmptyFavourites => 'لا يوجد مفضلة';

  @override
  String get collectionEmptyVideos => 'لا توجد فيديوهات';

  @override
  String get collectionEmptyImages => 'لا توجد صور';

  @override
  String get collectionEmptyGrantAccessButtonLabel => 'منح الوصول';

  @override
  String get collectionSelectSectionTooltip => 'اختر القسم';

  @override
  String get collectionDeselectSectionTooltip => 'قم بإلغاء تحديد القسم';

  @override
  String get drawerAboutButton => 'حول';

  @override
  String get drawerSettingsButton => 'إعدادات';

  @override
  String get drawerCollectionAll => 'كافة الوسائط';

  @override
  String get drawerCollectionFavourites => 'المفضلة';

  @override
  String get drawerCollectionImages => 'الصور';

  @override
  String get drawerCollectionVideos => 'الفيديوهات';

  @override
  String get drawerCollectionAnimated => 'متحرك';

  @override
  String get drawerCollectionMotionPhotos => 'صور متحركة';

  @override
  String get drawerCollectionPanoramas => 'لقطات بانورامية';

  @override
  String get drawerCollectionRaws => 'الصور الخام';

  @override
  String get drawerCollectionSphericalVideos => 'فيديوهات 360 درجة';

  @override
  String get drawerAlbumPage => 'الألبومات';

  @override
  String get drawerCountryPage => 'البلدان';

  @override
  String get drawerPlacePage => 'الأماكن';

  @override
  String get drawerTagPage => 'العلامات';

  @override
  String get sortByDate => 'حسب التاريخ';

  @override
  String get sortByName => 'حسب الإسم';

  @override
  String get sortByItemCount => 'حسب عدد العناصر';

  @override
  String get sortBySize => 'حسب الحجم';

  @override
  String get sortByAlbumFileName => 'حسب الألبوم واسم الملف';

  @override
  String get sortByRating => 'حسب التصنيف';

  @override
  String get sortByDuration => 'حسب المدة';

  @override
  String get sortByPath => 'حسب المسار';

  @override
  String get sortOrderNewestFirst => 'الأحدث أولاً';

  @override
  String get sortOrderOldestFirst => 'الأقدم أولا';

  @override
  String get sortOrderAtoZ => 'من الألف إلى الياء';

  @override
  String get sortOrderZtoA => 'من الياء إلى الألف';

  @override
  String get sortOrderHighestFirst => 'الاعلى اولا';

  @override
  String get sortOrderLowestFirst => 'الأدنى أولاً';

  @override
  String get sortOrderLargestFirst => 'الأكبر أولاً';

  @override
  String get sortOrderSmallestFirst => 'الأصغر أولاً';

  @override
  String get sortOrderShortestFirst => 'الأقصر أولاً';

  @override
  String get sortOrderLongestFirst => 'الأطول أولاً';

  @override
  String get albumGroupTier => 'حسب الطبقة';

  @override
  String get albumGroupType => 'حسب النوع';

  @override
  String get albumGroupVolume => 'حسب حجم التخزين';

  @override
  String get albumMimeTypeMixed => 'مختلط';

  @override
  String get albumPickPageTitleCopy => 'نسخ إلى ألبوم';

  @override
  String get albumPickPageTitleExport => 'تصدير إلى الألبوم';

  @override
  String get albumPickPageTitleMove => 'انتقل إلى الألبوم';

  @override
  String get albumPickPageTitlePick => 'اختر الألبوم';

  @override
  String get albumCamera => 'الكاميرا';

  @override
  String get albumDownload => 'التحميل';

  @override
  String get albumScreenshots => 'لقطات الشاشة';

  @override
  String get albumScreenRecordings => 'تسجيل الشاشة';

  @override
  String get albumVideoCaptures => 'الفيديوهات الملتقطة';

  @override
  String get albumPageTitle => 'الألبومات';

  @override
  String get albumEmpty => 'لا توجد ألبومات';

  @override
  String get createAlbumButtonLabel => 'إنشاء';

  @override
  String get newFilterBanner => 'الجديد';

  @override
  String get countryPageTitle => 'دول';

  @override
  String get countryEmpty => 'لا توجد دول';

  @override
  String get statePageTitle => 'الولايات';

  @override
  String get stateEmpty => 'لا توجد ولايات';

  @override
  String get placePageTitle => 'أماكن';

  @override
  String get placeEmpty => 'لا توجد أماكن';

  @override
  String get tagPageTitle => 'العلامات';

  @override
  String get tagEmpty => 'لا توجد العلامات';

  @override
  String get binPageTitle => 'سلة المحذوفات';

  @override
  String get explorerPageTitle => 'المستكشف';

  @override
  String get explorerActionSelectStorageVolume => 'حدد التخزين';

  @override
  String get selectStorageVolumeDialogTitle => 'حدد التَخزين';

  @override
  String get searchCollectionFieldHint => 'البحث في المجموعة';

  @override
  String get searchRecentSectionTitle => 'مؤخرًا';

  @override
  String get searchDateSectionTitle => 'تاريخ';

  @override
  String get searchFormatSectionTitle => 'التنسيقات';

  @override
  String get searchAlbumsSectionTitle => 'الألبومات';

  @override
  String get searchCountriesSectionTitle => 'البلدان';

  @override
  String get searchStatesSectionTitle => 'الولايات';

  @override
  String get searchPlacesSectionTitle => 'الأماكن';

  @override
  String get searchTagsSectionTitle => 'العلامات';

  @override
  String get searchRatingSectionTitle => 'التقييمات';

  @override
  String get searchMetadataSectionTitle => 'البيانات الوصفية';

  @override
  String get settingsPageTitle => 'إعدادات';

  @override
  String get settingsSystemDefault => 'الإعداد الافتراضي للنظام';

  @override
  String get settingsDefault => 'افتراضي';

  @override
  String get settingsDisabled => 'غير مفعل';

  @override
  String get settingsAskEverytime => 'اسأل كل مرة';

  @override
  String get settingsModificationWarningDialogMessage => 'سيتم تعديل الإعدادات الأخرى.';

  @override
  String get settingsSearchFieldLabel => 'إعدادات البحث';

  @override
  String get settingsSearchEmpty => 'لا يوجد إعداد مطابق';

  @override
  String get settingsActionExport => 'تصدير';

  @override
  String get settingsActionExportDialogTitle => 'تصدير';

  @override
  String get settingsActionImport => 'إستيراد';

  @override
  String get settingsActionImportDialogTitle => 'يستورد';

  @override
  String get appExportCovers => 'أغلفة';

  @override
  String get appExportDynamicAlbums => 'الألبومات الديناميكية';

  @override
  String get appExportFavourites => 'المفضلة';

  @override
  String get appExportSettings => 'إعدادات';

  @override
  String get settingsNavigationSectionTitle => 'التنقل';

  @override
  String get settingsHomeTile => 'الرئيسية';

  @override
  String get settingsHomeDialogTitle => 'الرئيسية';

  @override
  String get setHomeCustom => 'مخصص';

  @override
  String get settingsShowBottomNavigationBar => 'إظهار شريط التنقل السفلي';

  @override
  String get settingsKeepScreenOnTile => 'إبقاء الشاشة قيد التشغيل';

  @override
  String get settingsKeepScreenOnDialogTitle => 'ابقاء الشَاشة قيد التشغيل';

  @override
  String get settingsDoubleBackExit => 'اضغط على «رجوع» مرتين للخروج';

  @override
  String get settingsConfirmationTile => 'نوافذ التأكيد';

  @override
  String get settingsConfirmationDialogTitle => 'نوافذ تأكيد الحوار';

  @override
  String get settingsConfirmationBeforeDeleteItems => 'اسأل قبل حذف العناصر إلى الأبد';

  @override
  String get settingsConfirmationBeforeMoveToBinItems => 'اسأل قبل نقل العناصر إلى سلة المحذوفات';

  @override
  String get settingsConfirmationBeforeMoveUndatedItems => 'اسأل قبل نقل العناصر غير المؤرخة';

  @override
  String get settingsConfirmationAfterMoveToBinItems => 'إظهار الرسالة بعد نقل العناصر إلى سلة المحذوفات';

  @override
  String get settingsConfirmationVaultDataLoss => 'إظهار تحذير فقدان بيانات المخزن';

  @override
  String get settingsNavigationDrawerTile => 'قائمة تنقل';

  @override
  String get settingsNavigationDrawerEditorPageTitle => 'قائمة التنقل';

  @override
  String get settingsNavigationDrawerBanner => 'إلمس مع الاستمرار لنقل عناصر القائمة وإعادة ترتيبها.';

  @override
  String get settingsNavigationDrawerTabTypes => 'أنواع';

  @override
  String get settingsNavigationDrawerTabAlbums => 'الألبومات';

  @override
  String get settingsNavigationDrawerTabPages => 'الصفحات';

  @override
  String get settingsNavigationDrawerAddAlbum => 'إضافة ألبوم';

  @override
  String get settingsThumbnailSectionTitle => 'الصور المصغرة';

  @override
  String get settingsThumbnailOverlayTile => 'التراكب';

  @override
  String get settingsThumbnailOverlayPageTitle => 'التراكب';

  @override
  String get settingsThumbnailShowHdrIcon => 'إظهار أيقونة HDR';

  @override
  String get settingsThumbnailShowFavouriteIcon => 'إظهار الأيقونة المفضلة';

  @override
  String get settingsThumbnailShowTagIcon => 'إظهار رمز العلامة';

  @override
  String get settingsThumbnailShowLocationIcon => 'إظهار رمز الموقع';

  @override
  String get settingsThumbnailShowMotionPhotoIcon => 'إظهار أيقونة الصورة المتحركة';

  @override
  String get settingsThumbnailShowRating => 'عرض التقييم';

  @override
  String get settingsThumbnailShowRawIcon => 'إظهار أيقونة الخام';

  @override
  String get settingsThumbnailShowVideoDuration => 'عرض مدة الفيديو';

  @override
  String get settingsCollectionQuickActionsTile => 'إجراءات سريعة';

  @override
  String get settingsCollectionQuickActionEditorPageTitle => 'اجراءات سريعة';

  @override
  String get settingsCollectionQuickActionTabBrowsing => 'التصفح';

  @override
  String get settingsCollectionQuickActionTabSelecting => 'إختيار';

  @override
  String get settingsCollectionBrowsingQuickActionEditorBanner => 'المس مع الاستمرار لتحريك الأزرار وتحديد الإجراءات التي يتم عرضها عند تصفح العناصر.';

  @override
  String get settingsCollectionSelectionQuickActionEditorBanner => 'المس مع الاستمرار لتحريك الأزرار وتحديد الإجراءات التي يتم عرضها عند تحديد العناصر.';

  @override
  String get settingsCollectionBurstPatternsTile => 'أنماط الصور المتتابعة';

  @override
  String get settingsCollectionBurstPatternsNone => 'لا شيء';

  @override
  String get settingsViewerSectionTitle => 'المعرض';

  @override
  String get settingsViewerGestureSideTapNext => 'اضغط على حواف الشاشة لإظهار العنصر السابق/التالي';

  @override
  String get settingsViewerUseCutout => 'استخدام منطقة القص';

  @override
  String get settingsViewerMaximumBrightness => 'أقصى سطوع';

  @override
  String get settingsMotionPhotoAutoPlay => 'التشغيل التلقائي للصور المتحركة';

  @override
  String get settingsImageBackground => 'خلفية الصورة';

  @override
  String get settingsViewerQuickActionsTile => 'إجراءات سريعة';

  @override
  String get settingsViewerQuickActionEditorPageTitle => 'اجراءات سريعة';

  @override
  String get settingsViewerQuickActionEditorBanner => 'المس مع الاستمرار لتحريك الأزرار وتحديد الإجراءات التي سيتم عرضها في العارض.';

  @override
  String get settingsViewerQuickActionEditorDisplayedButtonsSectionTitle => 'الأزرار المعروضة';

  @override
  String get settingsViewerQuickActionEditorAvailableButtonsSectionTitle => 'الأزرار المتاحة';

  @override
  String get settingsViewerQuickActionEmpty => 'لا يوجد أزرار';

  @override
  String get settingsViewerOverlayTile => 'تراكب';

  @override
  String get settingsViewerOverlayPageTitle => 'تراكب';

  @override
  String get settingsViewerShowOverlayOnOpening => 'عرض عند الفتح';

  @override
  String get settingsViewerShowHistogram => 'إظهار الرسم البياني';

  @override
  String get settingsViewerShowMinimap => 'إظهار الخريطة المصغرة';

  @override
  String get settingsViewerShowInformation => 'مزيد من المعلومات';

  @override
  String get settingsViewerShowInformationSubtitle => 'إظهار العنوان والتاريخ والموقع وما إلى ذلك.';

  @override
  String get settingsViewerShowRatingTags => 'عرض التصنيف والعلامات';

  @override
  String get settingsViewerShowShootingDetails => 'عرض تفاصيل التصوير';

  @override
  String get settingsViewerShowDescription => 'إظهار الوصف';

  @override
  String get settingsViewerShowOverlayThumbnails => 'عرض الصور المصغرة';

  @override
  String get settingsViewerEnableOverlayBlurEffect => 'تأثير الضبابية';

  @override
  String get settingsViewerSlideshowTile => 'عرض الشرائح';

  @override
  String get settingsViewerSlideshowPageTitle => 'عرض الشرائح';

  @override
  String get settingsSlideshowRepeat => 'تكرار';

  @override
  String get settingsSlideshowShuffle => 'تشغيل عشوائي';

  @override
  String get settingsSlideshowFillScreen => 'ملء الشاشة';

  @override
  String get settingsSlideshowAnimatedZoomEffect => 'تأثير التكبير المتحرك';

  @override
  String get settingsSlideshowTransitionTile => 'انتقال';

  @override
  String get settingsSlideshowIntervalTile => 'فاصلة';

  @override
  String get settingsSlideshowVideoPlaybackTile => 'تشغيل الفيديو';

  @override
  String get settingsSlideshowVideoPlaybackDialogTitle => 'تَشغيل الفيديو';

  @override
  String get settingsVideoPageTitle => 'اعدادات الفيديو';

  @override
  String get settingsVideoSectionTitle => 'الفيديو';

  @override
  String get settingsVideoShowVideos => 'عرض الفيديوهات';

  @override
  String get settingsVideoPlaybackTile => 'التشغيل';

  @override
  String get settingsVideoPlaybackPageTitle => 'التشغيل';

  @override
  String get settingsVideoEnableHardwareAcceleration => 'تسريع الأجهزة';

  @override
  String get settingsVideoAutoPlay => 'تشغيل تلقائي';

  @override
  String get settingsVideoLoopModeTile => 'وضع التكرار';

  @override
  String get settingsVideoLoopModeDialogTitle => 'وضع التَكرار';

  @override
  String get settingsVideoResumptionModeTile => 'استئناف التشغيل';

  @override
  String get settingsVideoResumptionModeDialogTitle => 'إستئناف التشغيل';

  @override
  String get settingsVideoBackgroundMode => 'وضع الخلفية';

  @override
  String get settingsVideoBackgroundModeDialogTitle => 'وضع الخلـفية';

  @override
  String get settingsVideoControlsTile => 'ضوابط';

  @override
  String get settingsVideoControlsPageTitle => 'ضوابط';

  @override
  String get settingsVideoButtonsTile => 'أزرار';

  @override
  String get settingsVideoGestureDoubleTapTogglePlay => 'انقر نقرًا مزدوجًا للتشغيل/الإيقاف';

  @override
  String get settingsVideoGestureSideDoubleTapSeek => 'انقر نقرًا مزدوجًا على حواف الشاشة للتقدم للأمام/للخلف';

  @override
  String get settingsVideoGestureVerticalDragBrightnessVolume => 'اسحب لأعلى أو لأسفل لضبط مستوى السطوع/الصوت';

  @override
  String get settingsSubtitleThemeTile => 'ترجمات';

  @override
  String get settingsSubtitleThemePageTitle => 'ترجمات';

  @override
  String get settingsSubtitleThemeSample => 'هذه عينة بسيطة.';

  @override
  String get settingsSubtitleThemeTextAlignmentTile => 'محاذاة النص';

  @override
  String get settingsSubtitleThemeTextAlignmentDialogTitle => 'مُحاذاة النص';

  @override
  String get settingsSubtitleThemeTextPositionTile => 'موضع النص';

  @override
  String get settingsSubtitleThemeTextPositionDialogTitle => 'موضع النَص';

  @override
  String get settingsSubtitleThemeTextSize => 'حجم الخط';

  @override
  String get settingsSubtitleThemeShowOutline => 'إظهار الخطوط العريضة والظل';

  @override
  String get settingsSubtitleThemeTextColor => 'لون الخط';

  @override
  String get settingsSubtitleThemeTextOpacity => 'عتامة النص';

  @override
  String get settingsSubtitleThemeBackgroundColor => 'لون الخلفية';

  @override
  String get settingsSubtitleThemeBackgroundOpacity => 'عتامة الخلفية';

  @override
  String get settingsSubtitleThemeTextAlignmentLeft => 'يسار';

  @override
  String get settingsSubtitleThemeTextAlignmentCenter => 'وسط';

  @override
  String get settingsSubtitleThemeTextAlignmentRight => 'يمين';

  @override
  String get settingsPrivacySectionTitle => 'الخصوصية';

  @override
  String get settingsAllowInstalledAppAccess => 'السماح بالوصول إلى مخزون التطبيق';

  @override
  String get settingsAllowInstalledAppAccessSubtitle => 'يستخدم لتحسين عرض الألبوم';

  @override
  String get settingsAllowErrorReporting => 'السماح بالإبلاغ عن الأخطاء المجهولة';

  @override
  String get settingsSaveSearchHistory => 'حفظ سجل البحث';

  @override
  String get settingsEnableBin => 'استخدم سلة المحذوفات';

  @override
  String get settingsEnableBinSubtitle => 'الاحتفاظ بالعناصر المحذوفة لمدة 30 يومًا';

  @override
  String get settingsDisablingBinWarningDialogMessage => 'سيتم حذف العناصر الموجودة في سلة المحذوفات إلى الأبد.';

  @override
  String get settingsAllowMediaManagement => 'السماح بإدارة الوسائط';

  @override
  String get settingsHiddenItemsTile => 'العناصر المخفية';

  @override
  String get settingsHiddenItemsPageTitle => 'العناصر المَخفية';

  @override
  String get settingsHiddenFiltersBanner => 'لن تظهر الصور ومقاطع الفيديو المطابقة للمرشحات المخفية في مجموعتك.';

  @override
  String get settingsHiddenFiltersEmpty => 'لا يوجد مرشحات مخفية';

  @override
  String get settingsStorageAccessTile => 'الوصول إلى التخزين';

  @override
  String get settingsStorageAccessPageTitle => 'الوصُول إلى التخزين';

  @override
  String get settingsStorageAccessBanner => 'تتطلب بعض المسارات منح وصول صريح لتعديل الملفات الموجودة فيها. يمكنك هنا مراجعة المسارات التي منحتها حق الوصول إليها مسبقًا.';

  @override
  String get settingsStorageAccessEmpty => 'عدم منح الوصول';

  @override
  String get settingsStorageAccessRevokeTooltip => 'إبطال';

  @override
  String get settingsAccessibilitySectionTitle => 'إمكانية الوصول';

  @override
  String get settingsRemoveAnimationsTile => 'إزالة الرسوم المتحركة';

  @override
  String get settingsRemoveAnimationsDialogTitle => 'ازالة الرسوم المتحركة';

  @override
  String get settingsTimeToTakeActionTile => 'وقت إتخاذ الإجراءات';

  @override
  String get settingsAccessibilityShowPinchGestureAlternatives => 'عرض بدائل إيماءات اللمس المتعدد';

  @override
  String get settingsDisplaySectionTitle => 'عَرض';

  @override
  String get settingsThemeBrightnessTile => 'السمَة';

  @override
  String get settingsThemeBrightnessDialogTitle => 'السمة';

  @override
  String get settingsThemeColorHighlights => 'تحديد الألوان';

  @override
  String get settingsThemeEnableDynamicColor => 'اللون الديناميكي';

  @override
  String get settingsDisplayRefreshRateModeTile => 'عرض معدل التحديث';

  @override
  String get settingsDisplayRefreshRateModeDialogTitle => 'معدل التحديث';

  @override
  String get settingsDisplayUseTvInterface => 'واجهة أندرويد TV';

  @override
  String get settingsLanguageSectionTitle => 'اللغة والتنسيقات';

  @override
  String get settingsLanguageTile => 'اللغة';

  @override
  String get settingsLanguagePageTitle => 'اللغة';

  @override
  String get settingsCoordinateFormatTile => 'تنسيق الإحداثيات';

  @override
  String get settingsCoordinateFormatDialogTitle => 'تنسيق الاحداثيات';

  @override
  String get settingsUnitSystemTile => 'الوحدات';

  @override
  String get settingsUnitSystemDialogTitle => 'الوحدات';

  @override
  String get settingsForceWesternArabicNumeralsTile => 'فرض الأرقام العربية';

  @override
  String get settingsScreenSaverPageTitle => 'شاشة التوقف';

  @override
  String get settingsWidgetPageTitle => 'إطار الصورة';

  @override
  String get settingsWidgetShowOutline => 'الخطوط العريضة';

  @override
  String get settingsWidgetOpenPage => 'عند النقر على الويدجت';

  @override
  String get settingsWidgetDisplayedItem => 'العنصر المعروض';

  @override
  String get settingsCollectionTile => 'مجمُوعة';

  @override
  String get statsPageTitle => 'احصائيات';

  @override
  String statsWithGps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count العناصر مع الموقع',
      one: '1 عنصر مع الموقع',
    );
    return '$_temp0';
  }

  @override
  String get statsTopCountriesSectionTitle => 'أهم الدول';

  @override
  String get statsTopStatesSectionTitle => 'أهم الولايات';

  @override
  String get statsTopPlacesSectionTitle => 'أهم المواقع';

  @override
  String get statsTopTagsSectionTitle => 'أهم العلامات';

  @override
  String get statsTopAlbumsSectionTitle => 'أهم الألبومات';

  @override
  String get viewerOpenPanoramaButtonLabel => 'فتح البانوراما';

  @override
  String get viewerSetWallpaperButtonLabel => 'تعيين خلفية';

  @override
  String get viewerErrorUnknown => 'آسف!';

  @override
  String get viewerErrorDoesNotExist => 'الملف لم يعد موجودا.';

  @override
  String get viewerInfoPageTitle => 'معلومات';

  @override
  String get viewerInfoBackToViewerTooltip => 'العودة إلى العارض';

  @override
  String get viewerInfoUnknown => 'مَجهول';

  @override
  String get viewerInfoLabelDescription => 'وصف';

  @override
  String get viewerInfoLabelTitle => 'العنوان';

  @override
  String get viewerInfoLabelDate => 'التاريخ';

  @override
  String get viewerInfoLabelResolution => 'الدقة';

  @override
  String get viewerInfoLabelSize => 'الحجم';

  @override
  String get viewerInfoLabelUri => 'URI';

  @override
  String get viewerInfoLabelPath => 'المسار';

  @override
  String get viewerInfoLabelDuration => 'المدة';

  @override
  String get viewerInfoLabelOwner => 'المالك';

  @override
  String get viewerInfoLabelCoordinates => 'الإحداثيات';

  @override
  String get viewerInfoLabelAddress => 'العنوان';

  @override
  String get mapStyleDialogTitle => 'نمط الخريطة';

  @override
  String get mapStyleTooltip => 'حدد نمط الخريطة';

  @override
  String get mapZoomInTooltip => 'تكبير';

  @override
  String get mapZoomOutTooltip => 'تصغير';

  @override
  String get mapPointNorthUpTooltip => 'نقطة الشمال لأعلى';

  @override
  String get mapAttributionOsmData => 'بيانات الخريطة © [OpenStreetMap](https://www.openstreetmap.org/copyright) المساهمين';

  @override
  String get mapAttributionOsmLiberty => 'البلاط بواسطة [OpenMapTiles](https://www.openmaptiles.org/), [CC BY](http://creativecommons.org/licenses/by/4.0) • مُستضاف بواسطة [OSM Americana](https://tile.ourmap.us)';

  @override
  String get mapAttributionOpenTopoMap => '[SRTM](https://www.earthdata.nasa.gov/sensors/srtm) | البلاط بواسطة [OpenTopoMap](https://opentopomap.org/), [CC BY-SA](https://creativecommons.org/licenses/by-sa/3.0/)';

  @override
  String get mapAttributionOsmHot => 'البلاط بواسطة [HOT](https://www.hotosm.org/) • استضافة بواسطة [OSM France](https://openstreetmap.fr/)';

  @override
  String get mapAttributionStamen => 'البلاط بواسطة [Stamen Design](https://stamen.com), [CC BY 3.0](https://creativecommons.org/licenses/by/3.0)';

  @override
  String get openMapPageTooltip => 'عرض على صفحة الخريطة';

  @override
  String get mapEmptyRegion => 'لا توجد صور في هذه المنطقة';

  @override
  String get viewerInfoOpenEmbeddedFailureFeedback => 'فشل في استخراج البيانات المضمنة';

  @override
  String get viewerInfoOpenLinkText => 'فتح';

  @override
  String get viewerInfoViewXmlLinkText => 'عرض ملف XML';

  @override
  String get viewerInfoSearchFieldLabel => 'البحث في البيانات الوصفية';

  @override
  String get viewerInfoSearchEmpty => 'لا توجد مفاتيح مطابقة';

  @override
  String get viewerInfoSearchSuggestionDate => 'التَاريخ والوقت';

  @override
  String get viewerInfoSearchSuggestionDescription => 'الوصف';

  @override
  String get viewerInfoSearchSuggestionDimensions => 'الأبعاد';

  @override
  String get viewerInfoSearchSuggestionResolution => 'الدقة';

  @override
  String get viewerInfoSearchSuggestionRights => 'الحقوق';

  @override
  String get wallpaperUseScrollEffect => 'استخدم تأثير التمرير على الشاشة الرئيسية';

  @override
  String get tagEditorPageTitle => 'تحريرالعلامات';

  @override
  String get tagEditorPageNewTagFieldLabel => 'علامة جديدة';

  @override
  String get tagEditorPageAddTagTooltip => 'إضافة علامة';

  @override
  String get tagEditorSectionRecent => 'الأخيرة';

  @override
  String get tagEditorSectionPlaceholders => 'العناصر النائبة';

  @override
  String get tagEditorDiscardDialogMessage => 'هل تريد تجاهل التغييرات؟';

  @override
  String get tagPlaceholderCountry => 'البلد';

  @override
  String get tagPlaceholderState => 'الولاية';

  @override
  String get tagPlaceholderPlace => 'المكان';

  @override
  String get panoramaEnableSensorControl => 'تمكين التحكم في المستشعر';

  @override
  String get panoramaDisableSensorControl => 'تعطيل التحكم في المستشعر';

  @override
  String get sourceViewerPageTitle => 'المصدر';
}
