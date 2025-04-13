// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get appName => 'Aves';

  @override
  String get welcomeMessage => 'ยินดีต้อนรับสู่ Aves';

  @override
  String get welcomeOptional => 'ทางเลือกอื่น';

  @override
  String get welcomeTermsToggle => 'ฉันยินยอมในเงื่อนไขและข้อตกลง';

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
  String get deleteButtonLabel => 'ลบ';

  @override
  String get nextButtonLabel => 'ถัดไป';

  @override
  String get showButtonLabel => 'แสดง';

  @override
  String get hideButtonLabel => 'ซ่อน';

  @override
  String get continueButtonLabel => 'ต่อไป';

  @override
  String get saveCopyButtonLabel => 'SAVE COPY';

  @override
  String get applyTooltip => 'Apply';

  @override
  String get cancelTooltip => 'ยกเลิก';

  @override
  String get changeTooltip => 'เปลี่ยน';

  @override
  String get clearTooltip => 'ล้าง';

  @override
  String get previousTooltip => 'ก่อนหน้า';

  @override
  String get nextTooltip => 'ถัดไป';

  @override
  String get showTooltip => 'แสดง';

  @override
  String get hideTooltip => 'ซ่อน';

  @override
  String get actionRemove => 'ลบ';

  @override
  String get resetTooltip => 'ตั้งใหม่';

  @override
  String get saveTooltip => 'บันทึก';

  @override
  String get stopTooltip => 'Stop';

  @override
  String get pickTooltip => 'เลือก';

  @override
  String get doubleBackExitMessage => 'กดถอยหลังอีกครั้งเพื่อออก';

  @override
  String get doNotAskAgain => 'ไม่ต้องถามอีก';

  @override
  String get sourceStateLoading => 'กำลังโหลด';

  @override
  String get sourceStateCataloguing => 'กำลังจัดทำรายการ';

  @override
  String get sourceStateLocatingCountries => 'กำลังค้นหาประเทศ';

  @override
  String get sourceStateLocatingPlaces => 'กำลังค้นหาสถานที่';

  @override
  String get chipActionDelete => 'ลบ';

  @override
  String get chipActionRemove => 'Remove';

  @override
  String get chipActionShowCollection => 'แสดงคอลเลกชัน';

  @override
  String get chipActionGoToAlbumPage => 'แสดงในหน้าอัลบั้ม';

  @override
  String get chipActionGoToCountryPage => 'แสดงในหน้าประเทศ';

  @override
  String get chipActionGoToPlacePage => 'Show in Places';

  @override
  String get chipActionGoToTagPage => 'แสดงในหน้าแท็ก';

  @override
  String get chipActionGoToExplorerPage => 'Show in Explorer';

  @override
  String get chipActionDecompose => 'Split';

  @override
  String get chipActionFilterOut => 'กรองออก';

  @override
  String get chipActionFilterIn => 'กรองเข้า';

  @override
  String get chipActionHide => 'ซ่อน';

  @override
  String get chipActionLock => 'Lock';

  @override
  String get chipActionPin => 'ปักหมุดไว้บนสุด';

  @override
  String get chipActionUnpin => 'ถอนหมุดออก';

  @override
  String get chipActionRename => 'เปลี่ยนชื่อใหม่';

  @override
  String get chipActionSetCover => 'ตั้งเป็นภาพหน้าปก';

  @override
  String get chipActionShowCountryStates => 'Show states';

  @override
  String get chipActionCreateAlbum => 'สร้างอัลบั้ม';

  @override
  String get chipActionCreateVault => 'Create vault';

  @override
  String get chipActionConfigureVault => 'Configure vault';

  @override
  String get entryActionCopyToClipboard => 'คัดลอกไว้ในคลิปบอร์ด';

  @override
  String get entryActionDelete => 'ลบ';

  @override
  String get entryActionConvert => 'แปลงไฟล์';

  @override
  String get entryActionExport => 'เอกซ์ปอตส์';

  @override
  String get entryActionInfo => 'ข้อมูล';

  @override
  String get entryActionRename => 'เปลี่ยนชื่อใหม่';

  @override
  String get entryActionRestore => 'กู้คืน';

  @override
  String get entryActionRotateCCW => 'หมุนทวนเข็มนาฬิกา';

  @override
  String get entryActionRotateCW => 'หมุนตามเข็มนาฬิกา';

  @override
  String get entryActionFlip => 'พลิกแนวนอน';

  @override
  String get entryActionPrint => 'พิมพ์';

  @override
  String get entryActionShare => 'แชร์';

  @override
  String get entryActionShareImageOnly => 'แชร์รูปภาพเท่านั้น';

  @override
  String get entryActionShareVideoOnly => 'แชร์วิดีโอเท่านั้น';

  @override
  String get entryActionViewSource => 'ดูแหล่งข้อมูล';

  @override
  String get entryActionShowGeoTiffOnMap => 'แสดงแผนที่ซ้อน';

  @override
  String get entryActionConvertMotionPhotoToStillImage => 'แปลงเป็นภาพนิ่ง';

  @override
  String get entryActionViewMotionPhotoVideo => 'เปิดวิดีโอ';

  @override
  String get entryActionEdit => 'แก้ไข';

  @override
  String get entryActionOpen => 'เปิดด้วย';

  @override
  String get entryActionSetAs => 'ตั้งเป็น';

  @override
  String get entryActionCast => 'Cast';

  @override
  String get entryActionOpenMap => 'เปิดในแอพฯแผนที่';

  @override
  String get entryActionRotateScreen => 'หมุนจอ';

  @override
  String get entryActionAddFavourite => 'ใส่ในรายการโปรด';

  @override
  String get entryActionRemoveFavourite => 'ลบออกจากรายการโปรด';

  @override
  String get videoActionCaptureFrame => 'จับภาพเฟรม';

  @override
  String get videoActionMute => 'ปิดเสียง';

  @override
  String get videoActionUnmute => 'เปิดเสียง';

  @override
  String get videoActionPause => 'หยุดชั่วคราว';

  @override
  String get videoActionPlay => 'เล่น';

  @override
  String get videoActionReplay10 => 'ย้อนกลับ 10 วินาที';

  @override
  String get videoActionSkip10 => 'เดินหน้า 10 วินาที';

  @override
  String get videoActionShowPreviousFrame => 'Show previous frame';

  @override
  String get videoActionShowNextFrame => 'Show next frame';

  @override
  String get videoActionSelectStreams => 'เลือกภาษา';

  @override
  String get videoActionSetSpeed => 'ความเร็วในการเล่น';

  @override
  String get videoActionABRepeat => 'A-B repeat';

  @override
  String get videoRepeatActionSetStart => 'Set start';

  @override
  String get videoRepeatActionSetEnd => 'Set end';

  @override
  String get viewerActionSettings => 'ตั้งค่า';

  @override
  String get viewerActionLock => 'Lock viewer';

  @override
  String get viewerActionUnlock => 'Unlock viewer';

  @override
  String get slideshowActionResume => 'เล่นต่อ';

  @override
  String get slideshowActionShowInCollection => 'แสดงคอลเลกชัน';

  @override
  String get entryInfoActionEditDate => 'แก้ไขวันที่และเวลา';

  @override
  String get entryInfoActionEditLocation => 'แก้ไขสถานที่';

  @override
  String get entryInfoActionEditTitleDescription => 'แก้ไขชื่อและคำบรรยาย';

  @override
  String get entryInfoActionEditRating => 'แก้ไขระดับเรตติ้ง';

  @override
  String get entryInfoActionEditTags => 'แก้ไขแท็ก';

  @override
  String get entryInfoActionRemoveMetadata => 'ลบ metadata';

  @override
  String get entryInfoActionExportMetadata => 'เอกซ์ปอตส์ metadata';

  @override
  String get entryInfoActionRemoveLocation => 'ลบสถานที่';

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
  String get filterAspectRatioLandscapeLabel => 'ภาพแนวนอน';

  @override
  String get filterAspectRatioPortraitLabel => 'ภาพแนวตั้ง';

  @override
  String get filterBinLabel => 'ถังขยะ';

  @override
  String get filterFavouriteLabel => 'รายการโปรด';

  @override
  String get filterNoDateLabel => 'ไม่ระบุวันที่';

  @override
  String get filterNoAddressLabel => 'ไม่มีที่อยู่';

  @override
  String get filterLocatedLabel => 'ระบุสถานที่';

  @override
  String get filterNoLocationLabel => 'ไม่ระบุสถานที่';

  @override
  String get filterNoRatingLabel => 'ไม่ระบุระดับ';

  @override
  String get filterTaggedLabel => 'ระบุแท็ก';

  @override
  String get filterNoTagLabel => 'ไม่ระบุแท็ก';

  @override
  String get filterNoTitleLabel => 'ไม่ระบุชื่อ';

  @override
  String get filterOnThisDayLabel => 'ในวันนี้';

  @override
  String get filterRecentlyAddedLabel => 'รายการที่เพิ่มเมื่อเร็วๆนี้';

  @override
  String get filterRatingRejectedLabel => 'ปฏิเสธ';

  @override
  String get filterTypeAnimatedLabel => 'การเคลื่อนไหว';

  @override
  String get filterTypeMotionPhotoLabel => 'ภาพเคลื่อนไหว';

  @override
  String get filterTypePanoramaLabel => 'ภาพปริทัศน์ / แพโนรามา';

  @override
  String get filterTypeRawLabel => 'ไฟล์ดิบ';

  @override
  String get filterTypeSphericalVideoLabel => 'วิดีโอ 360°';

  @override
  String get filterTypeGeotiffLabel => 'GeoTIFF';

  @override
  String get filterMimeImageLabel => 'รูปภาพ';

  @override
  String get filterMimeVideoLabel => 'วิดีโอ';

  @override
  String get accessibilityAnimationsRemove => 'ปิดการเคลื่อนไหว';

  @override
  String get accessibilityAnimationsKeep => 'เปิดการเคลื่อนไหว';

  @override
  String get albumTierNew => 'ใหม่';

  @override
  String get albumTierPinned => 'ปักหมุด';

  @override
  String get albumTierSpecial => 'ทั่วไป';

  @override
  String get albumTierApps => 'แอพฯ';

  @override
  String get albumTierVaults => 'Vaults';

  @override
  String get albumTierDynamic => 'Dynamic';

  @override
  String get albumTierRegular => 'อื่นๆ';

  @override
  String get coordinateFormatDms => 'องศา, นาที, วินาที';

  @override
  String get coordinateFormatDdm => 'DDM';

  @override
  String get coordinateFormatDecimal => 'องศาทศนิยม';

  @override
  String coordinateDms(String coordinate, String direction) {
    return '$coordinate $direction';
  }

  @override
  String get coordinateDmsNorth => 'ทิศเหนือ';

  @override
  String get coordinateDmsSouth => 'ทิศใต้';

  @override
  String get coordinateDmsEast => 'ทิศตะวันออก';

  @override
  String get coordinateDmsWest => 'ทิศตะวันตก';

  @override
  String get displayRefreshRatePreferHighest => 'อัตราสูงสุด';

  @override
  String get displayRefreshRatePreferLowest => 'อัตราต่ำสุด';

  @override
  String get keepScreenOnNever => 'ปิด';

  @override
  String get keepScreenOnVideoPlayback => 'ระหว่างการเล่นวิดีโอ';

  @override
  String get keepScreenOnViewerOnly => 'หน้า Viewer เท่านั้น';

  @override
  String get keepScreenOnAlways => 'เปิดตลอด';

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
  String get nameConflictStrategyRename => 'เปลี่ยนชื่อใหม่';

  @override
  String get nameConflictStrategyReplace => 'แทนที่';

  @override
  String get nameConflictStrategySkip => 'ข้าม';

  @override
  String get overlayHistogramNone => 'None';

  @override
  String get overlayHistogramRGB => 'RGB';

  @override
  String get overlayHistogramLuminance => 'Luminance';

  @override
  String get subtitlePositionTop => 'ข้างบน';

  @override
  String get subtitlePositionBottom => 'ข้างล่าง';

  @override
  String get themeBrightnessLight => 'สว่าง';

  @override
  String get themeBrightnessDark => 'มืด';

  @override
  String get themeBrightnessBlack => 'ดำ';

  @override
  String get unitSystemMetric => 'เมตริก';

  @override
  String get unitSystemImperial => 'อิมพีเรียล';

  @override
  String get vaultLockTypePattern => 'Pattern';

  @override
  String get vaultLockTypePin => 'PIN';

  @override
  String get vaultLockTypePassword => 'Password';

  @override
  String get settingsVideoEnablePip => 'Picture-in-picture';

  @override
  String get videoControlsPlayOutside => 'เปิดด้วยตัวเล่นอื่น';

  @override
  String get videoLoopModeNever => 'ปิด';

  @override
  String get videoLoopModeShortOnly => 'เฉพาะคลิปสั้น';

  @override
  String get videoLoopModeAlways => 'เปิดตลอด';

  @override
  String get videoPlaybackSkip => 'ข้าม';

  @override
  String get videoPlaybackMuted => 'เล่นปิดเสียง';

  @override
  String get videoPlaybackWithSound => 'เล่นเปิดเสียง';

  @override
  String get videoResumptionModeNever => 'Never';

  @override
  String get videoResumptionModeAlways => 'Always';

  @override
  String get viewerTransitionSlide => 'เลื่อน';

  @override
  String get viewerTransitionParallax => 'แพรัลแลกซ์';

  @override
  String get viewerTransitionFade => 'เลือนหาย';

  @override
  String get viewerTransitionZoomIn => 'ซูมเข้า';

  @override
  String get viewerTransitionNone => 'ไม่มี';

  @override
  String get wallpaperTargetHome => 'โฮมสกรีน';

  @override
  String get wallpaperTargetLock => 'ล็อกสกรีน';

  @override
  String get wallpaperTargetHomeLock => 'ทั้งสองอย่าง';

  @override
  String get widgetDisplayedItemRandom => 'สุ่ม';

  @override
  String get widgetDisplayedItemMostRecent => 'ล่าสุด';

  @override
  String get widgetOpenPageHome => 'เปิดหน้าหลัก';

  @override
  String get widgetOpenPageCollection => 'เปิดคอลเลกชัน';

  @override
  String get widgetOpenPageViewer => 'เปิดหน้า Viewer';

  @override
  String get widgetTapUpdateWidget => 'Update widget';

  @override
  String get storageVolumeDescriptionFallbackPrimary => 'หน่วยความจำภายใน';

  @override
  String get storageVolumeDescriptionFallbackNonPrimary => 'SD การ์ด';

  @override
  String get rootDirectoryDescription => 'สารบบราก';

  @override
  String otherDirectoryDescription(String name) {
    return '\"$name\" ไดเรกทอรี';
  }

  @override
  String storageAccessDialogMessage(String directory, String volume) {
    return 'โปรดเลือก $directory ของ \"$volume\" ในหน้าถัดไปเพื่อให้แอพฯทำการเข้าถึง';
  }

  @override
  String restrictedAccessDialogMessage(String directory, String volume) {
    return 'แอพฯนี้ไม่ได้รับสิทธิ์ในการแก้ไขข้อมูลใน $directory ของ \"$volume\".\n\nกรุณาเลือกใช้ แอพฯจัดการไฟล์หรือแกลเลอรีอื่นๆ เพื่อย้ายข้อมูลไปไดเรกทอรีอื่น';
  }

  @override
  String notEnoughSpaceDialogMessage(String neededSize, String freeSize, String volume) {
    return 'การดำเนินการนี้ต้องการพื้นที่ว่าง $neededSize ของ “$volume” เพื่อให้เสร็จ แต่ตอนนี้มีพื้นที่เหลือแค่ $freeSize';
  }

  @override
  String get missingSystemFilePickerDialogMessage => 'ตัวเลือกไฟล์ระบบหายไป หรือปิดใช้งาน โปรดเปิดใช้งานและลองอีกครั้ง';

  @override
  String unsupportedTypeDialogMessage(int count, String types) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'การดำเนินการนี้ไม่รองรับรายการประเภทต่อไปนี้: $types.',
      one: 'การดำเนินการนี้ไม่รองรับรายการประเภทต่อไปนี้: $types.',
    );
    return '$_temp0';
  }

  @override
  String get nameConflictDialogSingleSourceMessage => 'มีไฟล์ที่ชื่อซ้ำในโฟลเดอร์ปลายทาง';

  @override
  String get nameConflictDialogMultipleSourceMessage => 'มีบางไฟล์ที่มีชื่อเหมือนกัน';

  @override
  String get addShortcutDialogLabel => 'ป้ายทางลัด';

  @override
  String get addShortcutButtonLabel => 'เพิ่ม';

  @override
  String get noMatchingAppDialogMessage => 'ไม่มีแอพฯที่จะจัดการสิ่งนี้ได้';

  @override
  String binEntriesConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ย้าย $count รายการนี้ไปยังถังขยะ?',
      one: 'ย้ายรายการนี้ไปยังถังขยะ?',
    );
    return '$_temp0';
  }

  @override
  String deleteEntriesConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ลบ $count รายการนี้?',
      one: 'ลบรายการนี้?',
    );
    return '$_temp0';
  }

  @override
  String get moveUndatedConfirmationDialogMessage => 'บันทึกวันที่ของไอเทมก่อนดำเนินการต่อไหม?';

  @override
  String get moveUndatedConfirmationDialogSetDate => 'บันทึกวันที่';

  @override
  String videoResumeDialogMessage(String time) {
    return 'คุณต้องการที่จะเล่นต่อจาก $time ไหม?';
  }

  @override
  String get videoStartOverButtonLabel => 'เริ่มใหม่';

  @override
  String get videoResumeButtonLabel => 'เล่นต่อ';

  @override
  String get setCoverDialogLatest => 'รายการล่าสุด';

  @override
  String get setCoverDialogAuto => 'อัตโนมัติ';

  @override
  String get setCoverDialogCustom => 'กำหนดเอง';

  @override
  String get hideFilterConfirmationDialogMessage => 'รูปภาพและวิดีโอที่ซ้ำกัน จะถูกซ่อนจากคอลเลกชันของคุณ คุณสามารถตั้งค่าให้แสดงได้ใน \"การตั้งค่าความเป็นส่วนตัว\"\n\nคุณแน่ใจหรือไม่ว่าต้องการซ่อน?';

  @override
  String get newAlbumDialogTitle => 'อัลบั้มใหม่';

  @override
  String get newAlbumDialogNameLabel => 'ชื่ออัลบั้ม';

  @override
  String get newAlbumDialogAlbumAlreadyExistsHelper => 'Album already exists';

  @override
  String get newAlbumDialogNameLabelAlreadyExistsHelper => 'มีไดเรกทอรีนี้อยู่แล้ว';

  @override
  String get newAlbumDialogStorageLabel => 'พื้นที่จัดเก็บ:';

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
  String get renameAlbumDialogLabel => 'ตั้งชื่อใหม่';

  @override
  String get renameAlbumDialogLabelAlreadyExistsHelper => 'มีไดเรกทอรีนี้อยู่แล้ว';

  @override
  String get renameEntrySetPageTitle => 'เปลี่ยนชื่อใหม่';

  @override
  String get renameEntrySetPagePatternFieldLabel => 'รูปแบบการตั้งชื่อ';

  @override
  String get renameEntrySetPageInsertTooltip => 'แทรกฟิลด์';

  @override
  String get renameEntrySetPagePreviewSectionTitle => 'ดูตัวอย่าง';

  @override
  String get renameProcessorCounter => 'ตัวนับ';

  @override
  String get renameProcessorHash => 'Hash';

  @override
  String get renameProcessorName => 'ชื่อ';

  @override
  String deleteSingleAlbumConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ลบอัลบั้มนี้และ $count รายการในอัลบั้ม?',
      one: 'ลบอัลบั้มนี้และรายการในอัลบั้มทั้งหมด?',
    );
    return '$_temp0';
  }

  @override
  String deleteMultiAlbumConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ลบอัลบั้มเหล่านี้และ $count รายการในอัลบั้ม?',
      one: 'ลบอัลบั้มเหล่านี้และรายการในอัลบั้มทั้งหมด?',
    );
    return '$_temp0';
  }

  @override
  String get exportEntryDialogFormat => 'รูปแบบ:';

  @override
  String get exportEntryDialogWidth => 'ความกว้าง';

  @override
  String get exportEntryDialogHeight => 'ความสูง';

  @override
  String get exportEntryDialogQuality => 'Quality';

  @override
  String get exportEntryDialogWriteMetadata => 'Write metadata';

  @override
  String get renameEntryDialogLabel => 'ตั้งชื่อใหม่';

  @override
  String get editEntryDialogCopyFromItem => 'คัดลอกจากรายการอื่น';

  @override
  String get editEntryDialogTargetFieldsHeader => 'ฟิลด์ที่จะแก้ไข';

  @override
  String get editEntryDateDialogTitle => 'วันที่ & เวลา';

  @override
  String get editEntryDateDialogSetCustom => 'กำหนดวันที่เอง';

  @override
  String get editEntryDateDialogCopyField => 'คัดลอกจากวันอื่นๆ';

  @override
  String get editEntryDateDialogExtractFromTitle => 'Extract from title';

  @override
  String get editEntryDateDialogShift => 'Shift';

  @override
  String get editEntryDateDialogSourceFileModifiedDate => 'วันที่แก้ไขไฟล์';

  @override
  String get durationDialogHours => 'ชั่วโมง';

  @override
  String get durationDialogMinutes => 'นาที';

  @override
  String get durationDialogSeconds => 'วินาที';

  @override
  String get editEntryLocationDialogTitle => 'สถานที่';

  @override
  String get editEntryLocationDialogSetCustom => 'กำหนดสถานที่เอง';

  @override
  String get editEntryLocationDialogChooseOnMap => 'เลือกบนแผนที่';

  @override
  String get editEntryLocationDialogImportGpx => 'Import GPX';

  @override
  String get editEntryLocationDialogLatitude => 'ละติจูด';

  @override
  String get editEntryLocationDialogLongitude => 'ลองจิจูด';

  @override
  String get editEntryLocationDialogTimeShift => 'Time shift';

  @override
  String get locationPickerUseThisLocationButton => 'ใช้ตําแหน่งนี้';

  @override
  String get editEntryRatingDialogTitle => 'คะแนน';

  @override
  String get removeEntryMetadataDialogTitle => 'Metadata Removal';

  @override
  String get removeEntryMetadataDialogAll => 'All';

  @override
  String get removeEntryMetadataDialogMore => 'เพิ่มเติม';

  @override
  String get removeEntryMetadataMotionPhotoXmpWarningDialogMessage => 'จำเป็นต้องใช้ XMP ในการเล่นวิดีโอในภาพเคลื่อนไหว\n\nคุณแน่ใจว่าต้องการลบออก?';

  @override
  String get videoSpeedDialogLabel => 'ความเร็วในการเล่น';

  @override
  String get videoStreamSelectionDialogVideo => 'วิดีโอ';

  @override
  String get videoStreamSelectionDialogAudio => 'เสียง';

  @override
  String get videoStreamSelectionDialogText => 'คำบรรยาย';

  @override
  String get videoStreamSelectionDialogOff => 'ปิด';

  @override
  String get videoStreamSelectionDialogTrack => 'แทร็ก';

  @override
  String get videoStreamSelectionDialogNoSelection => 'ไม่มีแทร็กอื่น';

  @override
  String get genericSuccessFeedback => 'เสร็จแล้ว!';

  @override
  String get genericFailureFeedback => 'ล้มเหลว';

  @override
  String get genericDangerWarningDialogMessage => 'คุณแน่ใจไหม?';

  @override
  String get tooManyItemsErrorDialogMessage => 'Try again with fewer items.';

  @override
  String get menuActionConfigureView => 'ดู';

  @override
  String get menuActionSelect => 'เลือก';

  @override
  String get menuActionSelectAll => 'เลือกทั้งหมด';

  @override
  String get menuActionSelectNone => 'ไม่เลือกทั้งหมด';

  @override
  String get menuActionMap => 'แผนที่';

  @override
  String get menuActionSlideshow => 'สไลด์โชว์';

  @override
  String get menuActionStats => 'สถิติ';

  @override
  String get viewDialogSortSectionTitle => 'เรียงลำดับ';

  @override
  String get viewDialogGroupSectionTitle => 'กลุ่ม';

  @override
  String get viewDialogLayoutSectionTitle => 'เค้าโครง';

  @override
  String get viewDialogReverseSortOrder => 'เรียงลำดับย้อนกลับ';

  @override
  String get tileLayoutMosaic => 'โมเสก';

  @override
  String get tileLayoutGrid => 'ตาราง';

  @override
  String get tileLayoutList => 'รายการ';

  @override
  String get castDialogTitle => 'Cast Devices';

  @override
  String get coverDialogTabCover => 'หน้าปก';

  @override
  String get coverDialogTabApp => 'แอพฯ';

  @override
  String get coverDialogTabColor => 'สี';

  @override
  String get appPickDialogTitle => 'เลือกแอพฯ';

  @override
  String get appPickDialogNone => 'ไม่มี';

  @override
  String get aboutPageTitle => 'เกี่ยวกับ';

  @override
  String get aboutLinkLicense => 'ใบอนุญาต';

  @override
  String get aboutLinkPolicy => 'นโยบายความเป็นส่วนตัว';

  @override
  String get aboutBugSectionTitle => 'รายงานข้อผิดพลาด';

  @override
  String get aboutBugSaveLogInstruction => 'บันทึกล็อกของแอพฯเป็นไฟล์';

  @override
  String get aboutBugCopyInfoInstruction => 'คัดลอกข้อมูลระบบ';

  @override
  String get aboutBugCopyInfoButton => 'คัดลอก';

  @override
  String get aboutBugReportInstruction => 'รายงาน GitHub พร้อมบันทึกและข้อมูลระบบ';

  @override
  String get aboutBugReportButton => 'รายงาน';

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
  String get aboutCreditsSectionTitle => 'เครดิต';

  @override
  String get aboutCreditsWorldAtlas1 => 'แอพฯนี้ใช้ไฟล์ TopoJSON จาก';

  @override
  String get aboutCreditsWorldAtlas2 => 'ภายใต้ใบอนุญาต ISC';

  @override
  String get aboutTranslatorsSectionTitle => 'ผู้แปล';

  @override
  String get aboutLicensesSectionTitle => 'ใบอนุญาตโอเพนซอร์ส';

  @override
  String get aboutLicensesBanner => 'แอพฯนี้ใช้แพ็คเกจและไลบรารีโอเพ่นซอร์ส ดังนี้';

  @override
  String get aboutLicensesAndroidLibrariesSectionTitle => 'ไลบรารีแอนดรอยด์';

  @override
  String get aboutLicensesFlutterPluginsSectionTitle => 'ปลั๊กอิน Flutter';

  @override
  String get aboutLicensesFlutterPackagesSectionTitle => 'แพ็คเกจ Flutter';

  @override
  String get aboutLicensesDartPackagesSectionTitle => 'แพ็คเกจ Dart';

  @override
  String get aboutLicensesShowAllButtonLabel => 'แสดงใบอนุญาตทั้งหมด';

  @override
  String get policyPageTitle => 'นโยบายความเป็นส่วนตัว';

  @override
  String get collectionPageTitle => 'คอลเลกชัน';

  @override
  String get collectionPickPageTitle => 'เลือก';

  @override
  String get collectionSelectPageTitle => 'เลือกรายการ';

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
