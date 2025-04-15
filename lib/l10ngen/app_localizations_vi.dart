// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appName => 'Aves';

  @override
  String get welcomeMessage => 'Chào mừng đến với Aves';

  @override
  String get welcomeOptional => 'Không bắt buộc';

  @override
  String get welcomeTermsToggle => 'Tôi đồng ý với các Điều khoản và Điều kiện';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mục',
    );
    return '$_temp0';
  }

  @override
  String columnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cột',
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
      other: '$countString giây',
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
      other: '$countString phút',
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
      other: '$countString ngày',
    );
    return '$_temp0';
  }

  @override
  String focalLength(String length) {
    return '$length pp';
  }

  @override
  String get applyButtonLabel => 'ÁP DỤNG';

  @override
  String get deleteButtonLabel => 'XÓA BỎ';

  @override
  String get nextButtonLabel => 'KẾ TIẾP';

  @override
  String get showButtonLabel => 'HIỂN THỊ';

  @override
  String get hideButtonLabel => 'ẨN';

  @override
  String get continueButtonLabel => 'TIẾP TỤC';

  @override
  String get saveCopyButtonLabel => 'LƯU BẢN SAO';

  @override
  String get applyTooltip => 'Áp dụng';

  @override
  String get cancelTooltip => 'Hủy bỏ';

  @override
  String get changeTooltip => 'Thay đổi';

  @override
  String get clearTooltip => 'Xóa';

  @override
  String get previousTooltip => 'Trước đó';

  @override
  String get nextTooltip => 'Kế tiếp';

  @override
  String get showTooltip => 'Hiển thị';

  @override
  String get hideTooltip => 'Ẩn';

  @override
  String get actionRemove => 'Loại bỏ';

  @override
  String get resetTooltip => 'Đặt lại';

  @override
  String get saveTooltip => 'Lưu';

  @override
  String get stopTooltip => 'Dừng';

  @override
  String get pickTooltip => 'Chọn';

  @override
  String get doubleBackExitMessage => 'Nhấn “quay lại” lần nữa để thoát.';

  @override
  String get doNotAskAgain => 'Đừng hỏi nữa';

  @override
  String get sourceStateLoading => 'Đang tải';

  @override
  String get sourceStateCataloguing => 'Biên mục';

  @override
  String get sourceStateLocatingCountries => 'Định vị quốc gia';

  @override
  String get sourceStateLocatingPlaces => 'Định vị địa điểm';

  @override
  String get chipActionDelete => 'Xóa';

  @override
  String get chipActionRemove => 'Loại bỏ';

  @override
  String get chipActionShowCollection => 'Hiển thị trong Bộ sưu tập';

  @override
  String get chipActionGoToAlbumPage => 'Hiển thị trong bộ sưu tập';

  @override
  String get chipActionGoToCountryPage => 'Hiển thị ở các quốc gia';

  @override
  String get chipActionGoToPlacePage => 'Hiển thị ở địa điểm';

  @override
  String get chipActionGoToTagPage => 'Hiển thị trong các thẻ';

  @override
  String get chipActionGoToExplorerPage => 'Hiển thị ở Explorer';

  @override
  String get chipActionDecompose => 'Split';

  @override
  String get chipActionFilterOut => 'Lọc đầu ra';

  @override
  String get chipActionFilterIn => 'Lọc đầu vào';

  @override
  String get chipActionHide => 'Ẩn';

  @override
  String get chipActionLock => 'Khóa';

  @override
  String get chipActionPin => 'Ghim đầu trang';

  @override
  String get chipActionUnpin => 'Bỏ ghim khỏi đầu';

  @override
  String get chipActionRename => 'Đổi tên';

  @override
  String get chipActionSetCover => 'Đặt ảnh bìa';

  @override
  String get chipActionShowCountryStates => 'Hiển thị tỉnh';

  @override
  String get chipActionCreateAlbum => 'Tạo bộ sưu tập';

  @override
  String get chipActionCreateVault => 'Tạo két sắt';

  @override
  String get chipActionConfigureVault => 'Định cấu hình két sắt';

  @override
  String get entryActionCopyToClipboard => 'Sao chép vào clipboard';

  @override
  String get entryActionDelete => 'Xóa';

  @override
  String get entryActionConvert => 'Chuyển thành';

  @override
  String get entryActionExport => 'Xuất';

  @override
  String get entryActionInfo => 'Thông tin';

  @override
  String get entryActionRename => 'Đổi tên';

  @override
  String get entryActionRestore => 'Khôi phục';

  @override
  String get entryActionRotateCCW => 'Xoay ngược chiều kim đồng hồ';

  @override
  String get entryActionRotateCW => 'Xoay theo chiều kim đồng hồ';

  @override
  String get entryActionFlip => 'Lật theo chiều ngang';

  @override
  String get entryActionPrint => 'In ấn';

  @override
  String get entryActionShare => 'Chia sẻ';

  @override
  String get entryActionShareImageOnly => 'Chỉ chia sẻ hình ảnh';

  @override
  String get entryActionShareVideoOnly => 'Chỉ chia sẻ video';

  @override
  String get entryActionViewSource => 'Xem nguồn';

  @override
  String get entryActionShowGeoTiffOnMap => 'Hiển thị dưới dạng lớp phủ bản đồ';

  @override
  String get entryActionConvertMotionPhotoToStillImage => 'Chuyển đổi sang hình ảnh tĩnh';

  @override
  String get entryActionViewMotionPhotoVideo => 'Mở video';

  @override
  String get entryActionEdit => 'Biên tập';

  @override
  String get entryActionOpen => 'Mở với';

  @override
  String get entryActionSetAs => 'Đặt làm';

  @override
  String get entryActionCast => 'Truyền';

  @override
  String get entryActionOpenMap => 'Hiển thị trong ứng dụng bản đồ';

  @override
  String get entryActionRotateScreen => 'Xoay màn hình';

  @override
  String get entryActionAddFavourite => 'Thêm vào mục yêu thích';

  @override
  String get entryActionRemoveFavourite => 'Loại bỏ khỏi mục ưa thích';

  @override
  String get videoActionCaptureFrame => 'Chụp khung hình';

  @override
  String get videoActionMute => 'Tắt tiếng';

  @override
  String get videoActionUnmute => 'Bật tiếng';

  @override
  String get videoActionPause => 'Tạm ngừng';

  @override
  String get videoActionPlay => 'Phát';

  @override
  String get videoActionReplay10 => 'Tua lùi 10 giây';

  @override
  String get videoActionSkip10 => 'Tua tới 10 giây';

  @override
  String get videoActionShowPreviousFrame => 'Hiển thị khung hình trước đó';

  @override
  String get videoActionShowNextFrame => 'Hiển thị khung hình tiếp theo';

  @override
  String get videoActionSelectStreams => 'Chọn bài hát';

  @override
  String get videoActionSetSpeed => 'Tốc độ phát lại';

  @override
  String get videoActionABRepeat => 'Lặp lại A-B';

  @override
  String get videoRepeatActionSetStart => 'Đặt bắt đầu';

  @override
  String get videoRepeatActionSetEnd => 'Đặt kết thúc';

  @override
  String get viewerActionSettings => 'Cài đặt';

  @override
  String get viewerActionLock => 'Khóa trình xem';

  @override
  String get viewerActionUnlock => 'Mở khóa trình xem';

  @override
  String get slideshowActionResume => 'Tiếp tục';

  @override
  String get slideshowActionShowInCollection => 'Hiển thị trong Bộ sưu tập';

  @override
  String get entryInfoActionEditDate => 'Chỉnh sửa ngày & giờ';

  @override
  String get entryInfoActionEditLocation => 'Chỉnh sửa vị trí';

  @override
  String get entryInfoActionEditTitleDescription => 'Chỉnh sửa tiêu đề & mô tả';

  @override
  String get entryInfoActionEditRating => 'Chỉnh sửa xếp hạng';

  @override
  String get entryInfoActionEditTags => 'Chỉnh sửa thẻ';

  @override
  String get entryInfoActionRemoveMetadata => 'Loại bỏ siêu dữ liệu';

  @override
  String get entryInfoActionExportMetadata => 'Xuất siêu dữ liệu';

  @override
  String get entryInfoActionRemoveLocation => 'Loại bỏ vị trí';

  @override
  String get editorActionTransform => 'Biến đổi';

  @override
  String get editorTransformCrop => 'Cắt xén';

  @override
  String get editorTransformRotate => 'Xoay';

  @override
  String get cropAspectRatioFree => 'Tự do';

  @override
  String get cropAspectRatioOriginal => 'Nguyên bản';

  @override
  String get cropAspectRatioSquare => 'Vuông';

  @override
  String get filterAspectRatioLandscapeLabel => 'Ngang';

  @override
  String get filterAspectRatioPortraitLabel => 'Dọc';

  @override
  String get filterBinLabel => 'Thùng rác';

  @override
  String get filterFavouriteLabel => 'Yêu thích';

  @override
  String get filterNoDateLabel => 'không ghi ngày tháng';

  @override
  String get filterNoAddressLabel => 'Không có địa chỉ';

  @override
  String get filterLocatedLabel => 'Đã định vị';

  @override
  String get filterNoLocationLabel => 'Chưa định vị';

  @override
  String get filterNoRatingLabel => 'Chưa được xếp hạng';

  @override
  String get filterTaggedLabel => 'Đã gắn thẻ';

  @override
  String get filterNoTagLabel => 'Đã gỡ thẻ';

  @override
  String get filterNoTitleLabel => 'Không có tiêu đề';

  @override
  String get filterOnThisDayLabel => 'Vào ngày này';

  @override
  String get filterRecentlyAddedLabel => 'Đã thêm gần đây';

  @override
  String get filterRatingRejectedLabel => 'Đã loại bỏ';

  @override
  String get filterTypeAnimatedLabel => 'Hoạt ảnh';

  @override
  String get filterTypeMotionPhotoLabel => 'Ảnh động';

  @override
  String get filterTypePanoramaLabel => 'Toàn cảnh';

  @override
  String get filterTypeRawLabel => 'RAW';

  @override
  String get filterTypeSphericalVideoLabel => '360° Video';

  @override
  String get filterTypeGeotiffLabel => 'GeoTIFF';

  @override
  String get filterMimeImageLabel => 'Ảnh';

  @override
  String get filterMimeVideoLabel => 'Video';

  @override
  String get accessibilityAnimationsRemove => 'Chặn hiệu ứng màn hình';

  @override
  String get accessibilityAnimationsKeep => 'Giữ hiệu ứng màn hình';

  @override
  String get albumTierNew => 'Mới';

  @override
  String get albumTierPinned => 'Đã ghim';

  @override
  String get albumTierSpecial => 'Phổ biến';

  @override
  String get albumTierApps => 'Ứng dụng';

  @override
  String get albumTierVaults => 'Két sắt';

  @override
  String get albumTierDynamic => 'Động';

  @override
  String get albumTierRegular => 'Khác';

  @override
  String get coordinateFormatDms => 'DMS';

  @override
  String get coordinateFormatDdm => 'DDM';

  @override
  String get coordinateFormatDecimal => 'Thập phân';

  @override
  String coordinateDms(String coordinate, String direction) {
    return '$coordinate $direction';
  }

  @override
  String get coordinateDmsNorth => 'Bắc';

  @override
  String get coordinateDmsSouth => 'Nam';

  @override
  String get coordinateDmsEast => 'Đông';

  @override
  String get coordinateDmsWest => 'Tây';

  @override
  String get displayRefreshRatePreferHighest => 'Giá trị cao nhất';

  @override
  String get displayRefreshRatePreferLowest => 'Giá trị thấp nhất';

  @override
  String get keepScreenOnNever => 'Không bao giờ';

  @override
  String get keepScreenOnVideoPlayback => 'Khi phát lại video';

  @override
  String get keepScreenOnViewerOnly => 'Chỉ trang người xem';

  @override
  String get keepScreenOnAlways => 'Luôn luôn';

  @override
  String get lengthUnitPixel => 'px';

  @override
  String get lengthUnitPercent => '%';

  @override
  String get mapStyleGoogleNormal => 'Google Maps';

  @override
  String get mapStyleGoogleHybrid => 'Google Maps (Hỗn hợp)';

  @override
  String get mapStyleGoogleTerrain => 'Google Maps (Địa hình)';

  @override
  String get mapStyleOsmLiberty => 'OSM Liberty';

  @override
  String get mapStyleOpenTopoMap => 'OpenTopoMap';

  @override
  String get mapStyleOsmHot => 'Humanitarian OSM';

  @override
  String get mapStyleStamenWatercolor => 'Stamen Watercolor (Màu)';

  @override
  String get maxBrightnessNever => 'Không bao giờ';

  @override
  String get maxBrightnessAlways => 'Luôn luôn';

  @override
  String get nameConflictStrategyRename => 'Sửa tên';

  @override
  String get nameConflictStrategyReplace => 'Thay thế';

  @override
  String get nameConflictStrategySkip => 'Bỏ qua';

  @override
  String get overlayHistogramNone => 'Không có';

  @override
  String get overlayHistogramRGB => 'RGB';

  @override
  String get overlayHistogramLuminance => 'Độ sáng';

  @override
  String get subtitlePositionTop => 'Trên';

  @override
  String get subtitlePositionBottom => 'Dưới';

  @override
  String get themeBrightnessLight => 'Sáng';

  @override
  String get themeBrightnessDark => 'Tối';

  @override
  String get themeBrightnessBlack => 'Đen';

  @override
  String get unitSystemMetric => 'Hệ mét';

  @override
  String get unitSystemImperial => 'Hệ ft';

  @override
  String get vaultLockTypePattern => 'Mẫu';

  @override
  String get vaultLockTypePin => 'PIN';

  @override
  String get vaultLockTypePassword => 'Mật khẩu';

  @override
  String get settingsVideoEnablePip => 'Ảnh trong ảnh';

  @override
  String get videoControlsPlayOutside => 'Mở với trình phát khác';

  @override
  String get videoLoopModeNever => 'Không bao giờ';

  @override
  String get videoLoopModeShortOnly => 'Chỉ video ngắn';

  @override
  String get videoLoopModeAlways => 'Luôn luôn';

  @override
  String get videoPlaybackSkip => 'Bỏ qua';

  @override
  String get videoPlaybackMuted => 'Phát với chế độ im lặng';

  @override
  String get videoPlaybackWithSound => 'Phát với âm thanh';

  @override
  String get videoResumptionModeNever => 'Không bao giờ';

  @override
  String get videoResumptionModeAlways => 'Luôn luôn';

  @override
  String get viewerTransitionSlide => 'Trình chiếu';

  @override
  String get viewerTransitionParallax => 'Thị sai';

  @override
  String get viewerTransitionFade => 'Phai nhạt';

  @override
  String get viewerTransitionZoomIn => 'Phóng to';

  @override
  String get viewerTransitionNone => 'Không có';

  @override
  String get wallpaperTargetHome => 'Màn hình chính';

  @override
  String get wallpaperTargetLock => 'Màn hình khóa';

  @override
  String get wallpaperTargetHomeLock => 'Màn hình chính và màn hình khóa';

  @override
  String get widgetDisplayedItemRandom => 'Ngẫu nhiên';

  @override
  String get widgetDisplayedItemMostRecent => 'Gần đây';

  @override
  String get widgetOpenPageHome => 'Mở trang chủ';

  @override
  String get widgetOpenPageCollection => 'Mở bộ sưu tập';

  @override
  String get widgetOpenPageViewer => 'Mở chế độ xem';

  @override
  String get widgetTapUpdateWidget => 'Cập nhật widget';

  @override
  String get storageVolumeDescriptionFallbackPrimary => 'Bộ nhớ trong';

  @override
  String get storageVolumeDescriptionFallbackNonPrimary => 'Thẻ nhớ';

  @override
  String get rootDirectoryDescription => 'Thư mục root';

  @override
  String otherDirectoryDescription(String name) {
    return '“$name” thư mục';
  }

  @override
  String storageAccessDialogMessage(String directory, String volume) {
    return 'Vui lòng chọn $directory của “$volume” trong màn hình tiếp theo để cấp cho ứng dụng này quyền truy cập vào nó.';
  }

  @override
  String restrictedAccessDialogMessage(String directory, String volume) {
    return 'Ứng dụng này không được phép sửa đổi các tệp trong $directory của “$volume”.\n\n Vui lòng sử dụng trình quản lý tệp hoặc ứng dụng thư viện được cài đặt sẵn để di chuyển các mục sang thư mục khác.';
  }

  @override
  String notEnoughSpaceDialogMessage(String neededSize, String freeSize, String volume) {
    return 'Thao tác này cần có $neededSize dung lượng trống trên “$volume” để hoàn thành nhưng chỉ còn lại $freeSize.';
  }

  @override
  String get missingSystemFilePickerDialogMessage => 'Tệp hệ thống bị thiếu hoặc bị vô hiệu hóa. Vui lòng kích hoạt nó và thử lại.';

  @override
  String unsupportedTypeDialogMessage(int count, String types) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Thao tác này không hỗ trợ cho kiểu tệp: $types.',
      one: 'Thao tác này không hỗ trợ cho kiểu tệp: $types.',
    );
    return '$_temp0';
  }

  @override
  String get nameConflictDialogSingleSourceMessage => 'Một số tệp trong thư mục có cùng tên.';

  @override
  String get nameConflictDialogMultipleSourceMessage => 'Một số tệp có cùng tên.';

  @override
  String get addShortcutDialogLabel => 'Nhãn phím tắt';

  @override
  String get addShortcutButtonLabel => 'NHẬP';

  @override
  String get noMatchingAppDialogMessage => 'Không có ứng dụng nào có thể xử lý việc này.';

  @override
  String binEntriesConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Chuyển $count mục vào thùng rác?',
      one: 'Chuyển vào thùng rác?',
    );
    return '$_temp0';
  }

  @override
  String deleteEntriesConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Xóa$count mục?',
      one: 'Xóa mục này? ',
    );
    return '$_temp0';
  }

  @override
  String get moveUndatedConfirmationDialogMessage => 'Lưu thời gian của mục trước khi tiếp tục?';

  @override
  String get moveUndatedConfirmationDialogSetDate => 'Lưu thời gian';

  @override
  String videoResumeDialogMessage(String time) {
    return 'Phát lại ngay $time không?';
  }

  @override
  String get videoStartOverButtonLabel => 'Bắt đầu lại';

  @override
  String get videoResumeButtonLabel => 'Phát lại';

  @override
  String get setCoverDialogLatest => 'Mục mới nhất';

  @override
  String get setCoverDialogAuto => 'Tự động';

  @override
  String get setCoverDialogCustom => 'Tùy chỉnh';

  @override
  String get hideFilterConfirmationDialogMessage => 'Ảnh và video trùng khớp sẽ bị ẩn khỏi bộ sưu tập của bạn. Bạn có thể hiển thị lại chúng từ cài đặt “Quyền riêng tư”.\n\nBạn có chắc chắn muốn ẩn chúng không?';

  @override
  String get newAlbumDialogTitle => 'Bộ sưu tập mới';

  @override
  String get newAlbumDialogNameLabel => 'Tên bộ sưu tập';

  @override
  String get newAlbumDialogAlbumAlreadyExistsHelper => 'Album đã tồn tại';

  @override
  String get newAlbumDialogNameLabelAlreadyExistsHelper => 'Thư mục đã tồn tại';

  @override
  String get newAlbumDialogStorageLabel => 'Lưu trữ:';

  @override
  String get newDynamicAlbumDialogTitle => 'Album động mới';

  @override
  String get dynamicAlbumAlreadyExists => 'Album động đã tồn tại';

  @override
  String get newVaultWarningDialogMessage => 'Các mục trong kho bí mật chỉ có sẵn cho ứng dụng này và không có sẵn cho ứng dụng khác.\n\nNếu bạn gỡ cài đặt ứng dụng này hoặc xóa dữ liệu ứng dụng này, bạn sẽ mất tất cả các mục này.';

  @override
  String get newVaultDialogTitle => 'Két sắt mới';

  @override
  String get configureVaultDialogTitle => 'Cấu hình Két sắt';

  @override
  String get vaultDialogLockModeWhenScreenOff => 'Khóa khi màn hình tắt';

  @override
  String get vaultDialogLockTypeLabel => 'Loại khóa';

  @override
  String get patternDialogEnter => 'Nhập mẫu';

  @override
  String get patternDialogConfirm => 'Xác nhận mẫu';

  @override
  String get pinDialogEnter => 'Nhập PIN';

  @override
  String get pinDialogConfirm => 'Xác nhận PIN';

  @override
  String get passwordDialogEnter => 'Nhập mật khẩu';

  @override
  String get passwordDialogConfirm => 'Xác nhận mật khẩu';

  @override
  String get authenticateToConfigureVault => 'Xác thực để định cấu hình két sắt';

  @override
  String get authenticateToUnlockVault => 'Xác thực để mở khóa két sắt';

  @override
  String get vaultBinUsageDialogMessage => 'Một số két sắt đang sử dụng thùng rác.';

  @override
  String get renameAlbumDialogLabel => 'Tên mới';

  @override
  String get renameAlbumDialogLabelAlreadyExistsHelper => 'Thư mục đã tồn tại';

  @override
  String get renameEntrySetPageTitle => 'Đổi tên';

  @override
  String get renameEntrySetPagePatternFieldLabel => 'Mẫu đặt tên';

  @override
  String get renameEntrySetPageInsertTooltip => 'Chèn thêm trường';

  @override
  String get renameEntrySetPagePreviewSectionTitle => 'Xem trước';

  @override
  String get renameProcessorCounter => 'Đếm';

  @override
  String get renameProcessorHash => 'Băm';

  @override
  String get renameProcessorName => 'Tên';

  @override
  String deleteSingleAlbumConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Xóa bộ sưu tập này với $count mục bên trong?',
      one: 'Xóa bộ sưu tập này và các mục bên trong',
    );
    return '$_temp0';
  }

  @override
  String deleteMultiAlbumConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Xóa các Album này với $count mục bên trong?',
      one: 'Xóa các Album này và các mục bên trong',
    );
    return '$_temp0';
  }

  @override
  String get exportEntryDialogFormat => 'Định dạng:';

  @override
  String get exportEntryDialogWidth => 'Rộng';

  @override
  String get exportEntryDialogHeight => 'Cao';

  @override
  String get exportEntryDialogQuality => 'Chất lượng';

  @override
  String get exportEntryDialogWriteMetadata => 'Viết metadata';

  @override
  String get renameEntryDialogLabel => 'Tên mới';

  @override
  String get editEntryDialogCopyFromItem => 'Sao chép từ mục khác';

  @override
  String get editEntryDialogTargetFieldsHeader => 'Các trường cần sửa';

  @override
  String get editEntryDateDialogTitle => 'Ngày & Giờ';

  @override
  String get editEntryDateDialogSetCustom => 'Đặt thời gian tùy chọn';

  @override
  String get editEntryDateDialogCopyField => 'Sao chép từ ngày khác';

  @override
  String get editEntryDateDialogExtractFromTitle => 'Trích xuất từ tiêu đề';

  @override
  String get editEntryDateDialogShift => 'Ca';

  @override
  String get editEntryDateDialogSourceFileModifiedDate => 'Ngày sửa đổi tệp tin';

  @override
  String get durationDialogHours => 'Giờ';

  @override
  String get durationDialogMinutes => 'Phút';

  @override
  String get durationDialogSeconds => 'Giây';

  @override
  String get editEntryLocationDialogTitle => 'Vị trí';

  @override
  String get editEntryLocationDialogSetCustom => 'Đặt vị trí tùy chọn';

  @override
  String get editEntryLocationDialogChooseOnMap => 'Chọn trên bản đồ';

  @override
  String get editEntryLocationDialogImportGpx => 'Import GPX';

  @override
  String get editEntryLocationDialogLatitude => 'Vĩ độ';

  @override
  String get editEntryLocationDialogLongitude => 'Kinh độ';

  @override
  String get editEntryLocationDialogTimeShift => 'Time shift';

  @override
  String get locationPickerUseThisLocationButton => 'Dùng vị trí này';

  @override
  String get editEntryRatingDialogTitle => 'Xếp hạng';

  @override
  String get removeEntryMetadataDialogTitle => 'Xóa Metadata';

  @override
  String get removeEntryMetadataDialogAll => 'All';

  @override
  String get removeEntryMetadataDialogMore => 'Thêm';

  @override
  String get removeEntryMetadataMotionPhotoXmpWarningDialogMessage => 'Cần có XMP để phát video bên trong ảnh chuyển động.\n\nBạn có chắc chắn muốn xóa nó không?';

  @override
  String get videoSpeedDialogLabel => 'Tốc độ phát';

  @override
  String get videoStreamSelectionDialogVideo => 'Video';

  @override
  String get videoStreamSelectionDialogAudio => 'Âm thanh';

  @override
  String get videoStreamSelectionDialogText => 'Phụ đề';

  @override
  String get videoStreamSelectionDialogOff => 'Tắt';

  @override
  String get videoStreamSelectionDialogTrack => 'Bài hát';

  @override
  String get videoStreamSelectionDialogNoSelection => 'Không có bài hát nào.';

  @override
  String get genericSuccessFeedback => 'Xong!';

  @override
  String get genericFailureFeedback => 'Bị lỗi';

  @override
  String get genericDangerWarningDialogMessage => 'Bạn chắc chứ?';

  @override
  String get tooManyItemsErrorDialogMessage => 'Hãy thử lại với ít mục hơn.';

  @override
  String get menuActionConfigureView => 'Xem';

  @override
  String get menuActionSelect => 'Chọn';

  @override
  String get menuActionSelectAll => 'Chọn hết';

  @override
  String get menuActionSelectNone => 'Chọn không có';

  @override
  String get menuActionMap => 'Bản đồ';

  @override
  String get menuActionSlideshow => 'Trình chiếu';

  @override
  String get menuActionStats => 'Thống kê';

  @override
  String get viewDialogSortSectionTitle => 'Sắp xếp';

  @override
  String get viewDialogGroupSectionTitle => 'Nhóm';

  @override
  String get viewDialogLayoutSectionTitle => 'Trình bày';

  @override
  String get viewDialogReverseSortOrder => 'Đảo ngược thứ tự sắp xếp';

  @override
  String get tileLayoutMosaic => 'Khảm';

  @override
  String get tileLayoutGrid => 'Lưới';

  @override
  String get tileLayoutList => 'Danh sách';

  @override
  String get castDialogTitle => 'Thiết bị truyền';

  @override
  String get coverDialogTabCover => 'Ảnh bìa';

  @override
  String get coverDialogTabApp => 'Ứng dụng';

  @override
  String get coverDialogTabColor => 'Màu sắc';

  @override
  String get appPickDialogTitle => 'Chọn ứng dụng';

  @override
  String get appPickDialogNone => 'Không có';

  @override
  String get aboutPageTitle => 'Giới thiệu';

  @override
  String get aboutLinkLicense => 'Giấy phép';

  @override
  String get aboutLinkPolicy => 'Chính sách bảo mật';

  @override
  String get aboutBugSectionTitle => 'Báo cáo lỗi';

  @override
  String get aboutBugSaveLogInstruction => 'Lưu log thành file';

  @override
  String get aboutBugCopyInfoInstruction => 'Sao chép thông tin hệ thống';

  @override
  String get aboutBugCopyInfoButton => 'Sao chép';

  @override
  String get aboutBugReportInstruction => 'Báo cáo trên GitHub với nhật ký và thông tin hệ thống';

  @override
  String get aboutBugReportButton => 'Báo cáo';

  @override
  String get aboutDataUsageSectionTitle => 'Sử dụng dữ liệu';

  @override
  String get aboutDataUsageData => 'Dữ liệu';

  @override
  String get aboutDataUsageCache => 'Cache';

  @override
  String get aboutDataUsageDatabase => 'Database';

  @override
  String get aboutDataUsageMisc => 'Khác';

  @override
  String get aboutDataUsageInternal => 'Nội bộ';

  @override
  String get aboutDataUsageExternal => 'Ngoại tuyến';

  @override
  String get aboutDataUsageClearCache => 'Xóa bộ nhớ đệm';

  @override
  String get aboutCreditsSectionTitle => 'Đóng góp';

  @override
  String get aboutCreditsWorldAtlas1 => 'Ứng dụng này dùng tệp TopoJSON từ';

  @override
  String get aboutCreditsWorldAtlas2 => 'dưới bản quyền ISC.';

  @override
  String get aboutTranslatorsSectionTitle => 'Dịch';

  @override
  String get aboutLicensesSectionTitle => 'Giấy phép mã nguồn mở';

  @override
  String get aboutLicensesBanner => 'Ứng dụng này sử dụng các gói và thư viện nguồn mở.';

  @override
  String get aboutLicensesAndroidLibrariesSectionTitle => 'Thư viện Android';

  @override
  String get aboutLicensesFlutterPluginsSectionTitle => 'Các bổ sung Flutter';

  @override
  String get aboutLicensesFlutterPackagesSectionTitle => 'Các gói Flutter';

  @override
  String get aboutLicensesDartPackagesSectionTitle => 'Các gói Dart';

  @override
  String get aboutLicensesShowAllButtonLabel => 'Hiển thị tất cả giấy phép';

  @override
  String get policyPageTitle => 'Chính sách bảo mật';

  @override
  String get collectionPageTitle => 'Bộ sưu tập';

  @override
  String get collectionPickPageTitle => 'Chọn';

  @override
  String get collectionSelectPageTitle => 'Chọn mục';

  @override
  String get collectionActionShowTitleSearch => 'Hiển thị tên filter';

  @override
  String get collectionActionHideTitleSearch => 'Ẩn tên filter';

  @override
  String get collectionActionAddDynamicAlbum => 'Thêm album động';

  @override
  String get collectionActionAddShortcut => 'Thêm lối tắt';

  @override
  String get collectionActionSetHome => 'Đặt làm nhà';

  @override
  String get collectionActionEmptyBin => 'Trống rỗng';

  @override
  String get collectionActionCopy => 'Sao chép vào bộ sưu tập';

  @override
  String get collectionActionMove => 'Di chuyển tới bộ sưu tập';

  @override
  String get collectionActionRescan => 'Quét lại';

  @override
  String get collectionActionEdit => 'Chỉnh sửa';

  @override
  String get collectionSearchTitlesHintText => 'Tìm tiêu đề';

  @override
  String get collectionGroupAlbum => 'Theo bộ sưu tập';

  @override
  String get collectionGroupMonth => 'Theo tháng';

  @override
  String get collectionGroupDay => 'Theo ngày';

  @override
  String get collectionGroupNone => 'Không kết hợp';

  @override
  String get sectionUnknown => 'Không biết';

  @override
  String get dateToday => 'Hôm nay';

  @override
  String get dateYesterday => 'Hôm qua';

  @override
  String get dateThisMonth => 'Tháng này';

  @override
  String collectionDeleteFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Lỗi khi xóa $count tệp',
      one: 'Lỗi khi xóa tệp',
    );
    return '$_temp0';
  }

  @override
  String collectionCopyFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Lỗi khi sao chép $count tệp',
      one: 'Lỗi khi sao chép tệp',
    );
    return '$_temp0';
  }

  @override
  String collectionMoveFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Lỗi khi di chuyển $count tệp',
      one: 'Lỗi khi di chuyển tệp',
    );
    return '$_temp0';
  }

  @override
  String collectionRenameFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Lỗi khi đặt lại tên $count tệp',
      one: 'Lỗi khi đặt lại tên tệp',
    );
    return '$_temp0';
  }

  @override
  String collectionEditFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Lỗi khi chỉnh sửa $count tệp',
      one: 'Lỗi khi chỉnh sửa tệp',
    );
    return '$_temp0';
  }

  @override
  String collectionExportFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Lỗi khi xuất $count tệp',
      one: 'Lỗi khi xuất tệp',
    );
    return '$_temp0';
  }

  @override
  String collectionCopySuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Đã sao chép $count mục',
      one: 'Đã sao chép',
    );
    return '$_temp0';
  }

  @override
  String collectionMoveSuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Đã di chuyển $count mục',
      one: 'Đã di chuyển',
    );
    return '$_temp0';
  }

  @override
  String collectionRenameSuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Đã thay tên $count mục',
      one: 'Đã đặt lại tên',
    );
    return '$_temp0';
  }

  @override
  String collectionEditSuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Đã chỉnh sửa $count mục',
      one: 'Đã chỉnh sửa',
    );
    return '$_temp0';
  }

  @override
  String get collectionEmptyFavourites => 'Không có mục Yêu thích nào';

  @override
  String get collectionEmptyVideos => 'Không có Video nào';

  @override
  String get collectionEmptyImages => 'Không có Ảnh nào';

  @override
  String get collectionEmptyGrantAccessButtonLabel => 'Quyền truy cập';

  @override
  String get collectionSelectSectionTooltip => 'Chọn phần';

  @override
  String get collectionDeselectSectionTooltip => 'Bỏ chọn phần';

  @override
  String get drawerAboutButton => 'Giới thiệu';

  @override
  String get drawerSettingsButton => 'Cài đặt';

  @override
  String get drawerCollectionAll => 'Tất cả bộ sưu tập';

  @override
  String get drawerCollectionFavourites => 'Yêu thích';

  @override
  String get drawerCollectionImages => 'Ảnh';

  @override
  String get drawerCollectionVideos => 'Video';

  @override
  String get drawerCollectionAnimated => 'Hoạt ảnh';

  @override
  String get drawerCollectionMotionPhotos => 'Ảnh động';

  @override
  String get drawerCollectionPanoramas => 'Toàn cảnh';

  @override
  String get drawerCollectionRaws => 'Ảnh RAW';

  @override
  String get drawerCollectionSphericalVideos => 'Video 360 độ';

  @override
  String get drawerAlbumPage => 'Bộ sưu tập';

  @override
  String get drawerCountryPage => 'Quốc gia';

  @override
  String get drawerPlacePage => 'Địa điểm';

  @override
  String get drawerTagPage => 'Thẻ';

  @override
  String get sortByDate => 'Theo thời gian';

  @override
  String get sortByName => 'Theo tên';

  @override
  String get sortByItemCount => 'Theo số mục';

  @override
  String get sortBySize => 'Theo kích cỡ';

  @override
  String get sortByAlbumFileName => 'Theo bộ sưu tập & tên tệp';

  @override
  String get sortByRating => 'Theo xếp hạng';

  @override
  String get sortByDuration => 'Theo thời lượng';

  @override
  String get sortByPath => 'By path';

  @override
  String get sortOrderNewestFirst => 'Mới nhất trước';

  @override
  String get sortOrderOldestFirst => 'Cũ nhất trước';

  @override
  String get sortOrderAtoZ => 'Từ A đến Z';

  @override
  String get sortOrderZtoA => 'Từ Z về A';

  @override
  String get sortOrderHighestFirst => 'Cao nhất trước';

  @override
  String get sortOrderLowestFirst => 'Thấp nhất trước';

  @override
  String get sortOrderLargestFirst => 'Lớn trước';

  @override
  String get sortOrderSmallestFirst => 'Nhỏ trước';

  @override
  String get sortOrderShortestFirst => 'Ngắn nhất trước';

  @override
  String get sortOrderLongestFirst => 'Dài nhất trước';

  @override
  String get albumGroupTier => 'Theo tầng';

  @override
  String get albumGroupType => 'Theo loại';

  @override
  String get albumGroupVolume => 'Theo dung lượng lưu trữ';

  @override
  String get albumGroupNone => 'Không nhóm các mục';

  @override
  String get albumMimeTypeMixed => 'Trộn';

  @override
  String get albumPickPageTitleCopy => 'Sao chép đến bộ sưu tập';

  @override
  String get albumPickPageTitleExport => 'Xuất đến bộ sưu tập';

  @override
  String get albumPickPageTitleMove => 'Di chuyển đến bộ sưu tập';

  @override
  String get albumPickPageTitlePick => 'Chọn bộ sưu tập';

  @override
  String get albumCamera => 'Máy Ảnh';

  @override
  String get albumDownload => 'Tải về';

  @override
  String get albumScreenshots => 'Ảnh chụp màn hình';

  @override
  String get albumScreenRecordings => 'Ghi màn hình';

  @override
  String get albumVideoCaptures => 'Ảnh chụp trong Video';

  @override
  String get albumPageTitle => 'Bộ sưu tập';

  @override
  String get albumEmpty => 'Không có bộ sưu tập nào';

  @override
  String get createAlbumButtonLabel => 'TẠO';

  @override
  String get newFilterBanner => 'mới';

  @override
  String get countryPageTitle => 'Quốc gia';

  @override
  String get countryEmpty => 'Không tìm thấy quốc gia';

  @override
  String get statePageTitle => 'Bang/Tỉnh';

  @override
  String get stateEmpty => 'Không tìm thấy Bang/Tỉnh';

  @override
  String get placePageTitle => 'Địa điểm';

  @override
  String get placeEmpty => 'Không có địa điểm';

  @override
  String get tagPageTitle => 'Thẻ';

  @override
  String get tagEmpty => 'Không được gắn thẻ';

  @override
  String get binPageTitle => 'Thùng rác';

  @override
  String get explorerPageTitle => 'Khám phá';

  @override
  String get explorerActionSelectStorageVolume => 'Chọn dung lượng';

  @override
  String get selectStorageVolumeDialogTitle => 'Chọn bộ nhớ';

  @override
  String get searchCollectionFieldHint => 'Tìm bộ sưu tập';

  @override
  String get searchRecentSectionTitle => 'Gần đây';

  @override
  String get searchDateSectionTitle => 'Thời gian';

  @override
  String get searchFormatSectionTitle => 'Formats';

  @override
  String get searchAlbumsSectionTitle => 'Bộ sưu tập';

  @override
  String get searchCountriesSectionTitle => 'Quốc gia';

  @override
  String get searchStatesSectionTitle => 'Bang/Tỉnh';

  @override
  String get searchPlacesSectionTitle => 'Địa điểm';

  @override
  String get searchTagsSectionTitle => 'Thẻ';

  @override
  String get searchRatingSectionTitle => 'Xếp hạng';

  @override
  String get searchMetadataSectionTitle => 'Siêu dữ liệu';

  @override
  String get settingsPageTitle => 'Cài đặt';

  @override
  String get settingsSystemDefault => 'Mặc định hệ thống';

  @override
  String get settingsDefault => 'Mặc định';

  @override
  String get settingsDisabled => 'Vô hiệu hóa';

  @override
  String get settingsAskEverytime => 'Hỏi mỗi lần';

  @override
  String get settingsModificationWarningDialogMessage => 'Các cài đặt khác sẽ được sửa đổi.';

  @override
  String get settingsSearchFieldLabel => 'Cài đặt tìm kiếm';

  @override
  String get settingsSearchEmpty => 'Không có cài đặt phù hợp';

  @override
  String get settingsActionExport => 'Xuất';

  @override
  String get settingsActionExportDialogTitle => 'Xuất';

  @override
  String get settingsActionImport => 'Nhập';

  @override
  String get settingsActionImportDialogTitle => 'Nhập';

  @override
  String get appExportCovers => 'Ảnh bìa';

  @override
  String get appExportDynamicAlbums => 'Album động';

  @override
  String get appExportFavourites => 'Yêu thích';

  @override
  String get appExportSettings => 'Cài đặt';

  @override
  String get settingsNavigationSectionTitle => 'Điều hướng';

  @override
  String get settingsHomeTile => 'Trang chủ';

  @override
  String get settingsHomeDialogTitle => 'Trang chủ';

  @override
  String get setHomeCustom => 'Tùy chỉnh';

  @override
  String get settingsShowBottomNavigationBar => 'Hiển thị thanh điều hướng phía dưới';

  @override
  String get settingsKeepScreenOnTile => 'Giữ màn hình luôn bật';

  @override
  String get settingsKeepScreenOnDialogTitle => 'Giữ màn hình luôn bật';

  @override
  String get settingsDoubleBackExit => 'Gõ “quay lại” hai lần để thoát';

  @override
  String get settingsConfirmationTile => 'Hộp thoại xác nhận';

  @override
  String get settingsConfirmationDialogTitle => 'Hộp thoại xác nhận';

  @override
  String get settingsConfirmationBeforeDeleteItems => 'Hỏi trước khi xóa các mục vĩnh viễn';

  @override
  String get settingsConfirmationBeforeMoveToBinItems => 'Hỏi trước khi chuyển các mục vào thùng rác';

  @override
  String get settingsConfirmationBeforeMoveUndatedItems => 'Hỏi trước khi di chuyển các mục không ghi ngày tháng';

  @override
  String get settingsConfirmationAfterMoveToBinItems => 'Hiển thị thông báo sau khi di chuyển mục vào thùng rác';

  @override
  String get settingsConfirmationVaultDataLoss => 'Hiển thị cảnh báo mất dữ liệu két sắt';

  @override
  String get settingsNavigationDrawerTile => 'Menu điều hướng';

  @override
  String get settingsNavigationDrawerEditorPageTitle => 'Menu điều hướng';

  @override
  String get settingsNavigationDrawerBanner => 'Nhấn và giữ để di chuyển và sắp xếp lại các mục menu.';

  @override
  String get settingsNavigationDrawerTabTypes => 'Loại';

  @override
  String get settingsNavigationDrawerTabAlbums => 'Bộ sưu tập';

  @override
  String get settingsNavigationDrawerTabPages => 'Trang';

  @override
  String get settingsNavigationDrawerAddAlbum => 'Thêm bộ sưu tập';

  @override
  String get settingsThumbnailSectionTitle => 'Ảnh thu nhỏ';

  @override
  String get settingsThumbnailOverlayTile => 'Lớp phủ';

  @override
  String get settingsThumbnailOverlayPageTitle => 'Lớp phủ';

  @override
  String get settingsThumbnailShowHdrIcon => 'Hiển thị biểu tượng HDR';

  @override
  String get settingsThumbnailShowFavouriteIcon => 'Hiện icon Yêu thích';

  @override
  String get settingsThumbnailShowTagIcon => 'Hiện icon Thẻ';

  @override
  String get settingsThumbnailShowLocationIcon => 'Hiện icon Vị trí';

  @override
  String get settingsThumbnailShowMotionPhotoIcon => 'Hiện icon Ảnh động';

  @override
  String get settingsThumbnailShowRating => 'Hiển thị xếp hạng';

  @override
  String get settingsThumbnailShowRawIcon => 'Hiện icon RAW';

  @override
  String get settingsThumbnailShowVideoDuration => 'Hiển thị thời lượng video';

  @override
  String get settingsCollectionQuickActionsTile => 'Hành động nhanh';

  @override
  String get settingsCollectionQuickActionEditorPageTitle => 'Hành động nhanh';

  @override
  String get settingsCollectionQuickActionTabBrowsing => 'Duyệt';

  @override
  String get settingsCollectionQuickActionTabSelecting => 'Chọn';

  @override
  String get settingsCollectionBrowsingQuickActionEditorBanner => 'Nhấn và giữ để di chuyển các nút và chọn hành động nào sẽ được hiển thị khi duyệt các mục.';

  @override
  String get settingsCollectionSelectionQuickActionEditorBanner => 'Nhấn và giữ để di chuyển các nút và chọn hành động nào sẽ được hiển thị khi chọn mục.';

  @override
  String get settingsCollectionBurstPatternsTile => 'Mẫu Burst';

  @override
  String get settingsCollectionBurstPatternsNone => 'Không có';

  @override
  String get settingsViewerSectionTitle => 'Chế độ xem';

  @override
  String get settingsViewerGestureSideTapNext => 'Chạm vào các cạnh màn hình để hiển thị mục trước/tiếp theo';

  @override
  String get settingsViewerUseCutout => 'Sử dụng vùng cắt';

  @override
  String get settingsViewerMaximumBrightness => 'Độ sáng tối đa';

  @override
  String get settingsMotionPhotoAutoPlay => 'Tự động phát Ảnh động';

  @override
  String get settingsImageBackground => 'Hình nền';

  @override
  String get settingsViewerQuickActionsTile => 'Hành động nhanh';

  @override
  String get settingsViewerQuickActionEditorPageTitle => 'Hành động nhanh';

  @override
  String get settingsViewerQuickActionEditorBanner => 'Chạm và giữ để di chuyển các nút và chọn hành động nào được hiển thị trong trình xem.';

  @override
  String get settingsViewerQuickActionEditorDisplayedButtonsSectionTitle => 'Các nút được hiển thị';

  @override
  String get settingsViewerQuickActionEditorAvailableButtonsSectionTitle => 'Các nút có sẵn';

  @override
  String get settingsViewerQuickActionEmpty => 'Không có nút nào';

  @override
  String get settingsViewerOverlayTile => 'Lớp phủ';

  @override
  String get settingsViewerOverlayPageTitle => 'Lớp phủ';

  @override
  String get settingsViewerShowOverlayOnOpening => 'Hiển thị khi mở';

  @override
  String get settingsViewerShowHistogram => 'Hiển thị biểu đồ';

  @override
  String get settingsViewerShowMinimap => 'Hiển thị bản đồ thu nhỏ';

  @override
  String get settingsViewerShowInformation => 'Hiển thị thông tin';

  @override
  String get settingsViewerShowInformationSubtitle => 'Hiển thị tiêu đề, thời gian, vị trí v..v..';

  @override
  String get settingsViewerShowRatingTags => 'Hiển thị thẻ và xếp hạng';

  @override
  String get settingsViewerShowShootingDetails => 'Hiển thị mục shooting';

  @override
  String get settingsViewerShowDescription => 'Hiển thị mô tả';

  @override
  String get settingsViewerShowOverlayThumbnails => 'Hiển thị ảnh thu nhỏ';

  @override
  String get settingsViewerEnableOverlayBlurEffect => 'Hiệu ứng làm mờ';

  @override
  String get settingsViewerSlideshowTile => 'Trình chiếu';

  @override
  String get settingsViewerSlideshowPageTitle => 'Trình chiếu';

  @override
  String get settingsSlideshowRepeat => 'Lặp lại';

  @override
  String get settingsSlideshowShuffle => 'Xáo trộn';

  @override
  String get settingsSlideshowFillScreen => 'Lắp đầy màn hình';

  @override
  String get settingsSlideshowAnimatedZoomEffect => 'Hiệu ứng phóng to';

  @override
  String get settingsSlideshowTransitionTile => 'Chuyển tiếp';

  @override
  String get settingsSlideshowIntervalTile => 'Khoảng thời gian';

  @override
  String get settingsSlideshowVideoPlaybackTile => 'Xem lại video';

  @override
  String get settingsSlideshowVideoPlaybackDialogTitle => 'Phát lại video';

  @override
  String get settingsVideoPageTitle => 'Cài đặt video';

  @override
  String get settingsVideoSectionTitle => 'Video';

  @override
  String get settingsVideoShowVideos => 'Hiển thị các Video';

  @override
  String get settingsVideoPlaybackTile => 'Phát lại';

  @override
  String get settingsVideoPlaybackPageTitle => 'Phát lại';

  @override
  String get settingsVideoEnableHardwareAcceleration => 'Tăng tốc phần cứng';

  @override
  String get settingsVideoAutoPlay => 'Tự động phát';

  @override
  String get settingsVideoLoopModeTile => 'Vòng lặp';

  @override
  String get settingsVideoLoopModeDialogTitle => 'Vòng lặp';

  @override
  String get settingsVideoResumptionModeTile => 'Quay lại playback';

  @override
  String get settingsVideoResumptionModeDialogTitle => 'Quay lại playback';

  @override
  String get settingsVideoBackgroundMode => 'Chế độ nền';

  @override
  String get settingsVideoBackgroundModeDialogTitle => 'Chế độ nền';

  @override
  String get settingsVideoControlsTile => 'Điều khiển';

  @override
  String get settingsVideoControlsPageTitle => 'Điều khiển';

  @override
  String get settingsVideoButtonsTile => 'Nút';

  @override
  String get settingsVideoGestureDoubleTapTogglePlay => 'Nhấn đúp để phát/tạm dừng';

  @override
  String get settingsVideoGestureSideDoubleTapSeek => 'Nhấn đúp vào các cạnh màn hình để lùi lại/tiến tới';

  @override
  String get settingsVideoGestureVerticalDragBrightnessVolume => 'Vuốt lên hoặc xuống để điều chỉnh độ sáng/âm lượng';

  @override
  String get settingsSubtitleThemeTile => 'Phụ đề';

  @override
  String get settingsSubtitleThemePageTitle => 'Phụ đề';

  @override
  String get settingsSubtitleThemeSample => 'Đây là ví dụ.';

  @override
  String get settingsSubtitleThemeTextAlignmentTile => 'Căn chỉnh văn bản';

  @override
  String get settingsSubtitleThemeTextAlignmentDialogTitle => 'Căn chỉnh văn bản';

  @override
  String get settingsSubtitleThemeTextPositionTile => 'Vị trí văn bản';

  @override
  String get settingsSubtitleThemeTextPositionDialogTitle => 'Vị trí văn bản';

  @override
  String get settingsSubtitleThemeTextSize => 'Kích thước văn bản';

  @override
  String get settingsSubtitleThemeShowOutline => 'Hiển thị viền và bóng mờ';

  @override
  String get settingsSubtitleThemeTextColor => 'Màu văn bản';

  @override
  String get settingsSubtitleThemeTextOpacity => 'Độ mờ văn bản';

  @override
  String get settingsSubtitleThemeBackgroundColor => 'Màu nền';

  @override
  String get settingsSubtitleThemeBackgroundOpacity => 'Độ mờ nền';

  @override
  String get settingsSubtitleThemeTextAlignmentLeft => 'Trái';

  @override
  String get settingsSubtitleThemeTextAlignmentCenter => 'Trung tâm';

  @override
  String get settingsSubtitleThemeTextAlignmentRight => 'Phải';

  @override
  String get settingsPrivacySectionTitle => 'Riêng tư';

  @override
  String get settingsAllowInstalledAppAccess => 'Cho phép truy cập vào kho ứng dụng';

  @override
  String get settingsAllowInstalledAppAccessSubtitle => 'Được sử dụng để cải thiện hiển thị bộ sưu tập';

  @override
  String get settingsAllowErrorReporting => 'Cho phép báo cáo lỗi ẩn danh';

  @override
  String get settingsSaveSearchHistory => 'Lưu lịch sử tìm kiếm';

  @override
  String get settingsEnableBin => 'Dùng thùng rác';

  @override
  String get settingsEnableBinSubtitle => 'Giữ các mục đã xóa 30 ngày';

  @override
  String get settingsDisablingBinWarningDialogMessage => 'Các mục trong thùng rác sẽ bị xóa vĩnh viễn.';

  @override
  String get settingsAllowMediaManagement => 'Cho phép quản lí phương tiện';

  @override
  String get settingsHiddenItemsTile => 'Các mục đã ẩn';

  @override
  String get settingsHiddenItemsPageTitle => 'Mục đã ẩn';

  @override
  String get settingsHiddenFiltersBanner => 'Ảnh và video phù hợp với bộ lọc ẩn sẽ không xuất hiện trong bộ sưu tập của bạn.';

  @override
  String get settingsHiddenFiltersEmpty => 'Không có bộ lọc ẩn nào';

  @override
  String get settingsStorageAccessTile => 'Quyền truy cập bộ nhớ';

  @override
  String get settingsStorageAccessPageTitle => 'Quyền truy cập bộ nhớ';

  @override
  String get settingsStorageAccessBanner => 'Một số thư mục yêu cầu cấp quyền truy cập rõ ràng để sửa đổi các tệp trong đó. Bạn có thể xem lại các thư mục mà trước đây bạn đã cấp quyền truy cập tại đây.';

  @override
  String get settingsStorageAccessEmpty => 'Không có quyền nào được cấp';

  @override
  String get settingsStorageAccessRevokeTooltip => 'Thu hồi';

  @override
  String get settingsAccessibilitySectionTitle => 'Khả năng tiếp cận';

  @override
  String get settingsRemoveAnimationsTile => 'Xóa hiệu ứng ảnh động';

  @override
  String get settingsRemoveAnimationsDialogTitle => 'Xóa hoạt ảnh';

  @override
  String get settingsTimeToTakeActionTile => 'Thời gian hành động';

  @override
  String get settingsAccessibilityShowPinchGestureAlternatives => 'Hiển thị các lựa chọn thay thế cử chỉ đa chạm';

  @override
  String get settingsDisplaySectionTitle => 'Hiển thị';

  @override
  String get settingsThemeBrightnessTile => 'Chủ đề';

  @override
  String get settingsThemeBrightnessDialogTitle => 'Chủ đề';

  @override
  String get settingsThemeColorHighlights => 'Màu sắc nổi bật';

  @override
  String get settingsThemeEnableDynamicColor => 'Màu sắc Dynamic';

  @override
  String get settingsDisplayRefreshRateModeTile => 'Tốc độ làm mới màn hình';

  @override
  String get settingsDisplayRefreshRateModeDialogTitle => 'Tốc độ làm mới';

  @override
  String get settingsDisplayUseTvInterface => 'Giao diện Android TV';

  @override
  String get settingsLanguageSectionTitle => 'Ngôn ngữ và Định dạng';

  @override
  String get settingsLanguageTile => 'Ngôn ngữ';

  @override
  String get settingsLanguagePageTitle => 'Ngôn ngữ';

  @override
  String get settingsCoordinateFormatTile => 'Định dạng tọa độ';

  @override
  String get settingsCoordinateFormatDialogTitle => 'Định dạng tọa độ';

  @override
  String get settingsUnitSystemTile => 'Đơn vị';

  @override
  String get settingsUnitSystemDialogTitle => 'Đơn vị';

  @override
  String get settingsForceWesternArabicNumeralsTile => 'Buộc chữ số Ả Rập';

  @override
  String get settingsScreenSaverPageTitle => 'Bảo vệ màn hình';

  @override
  String get settingsWidgetPageTitle => 'Khung ảnh';

  @override
  String get settingsWidgetShowOutline => 'Đường viền';

  @override
  String get settingsWidgetOpenPage => 'Khi nhấn vào tiện ích';

  @override
  String get settingsWidgetDisplayedItem => 'Mục hiển thị';

  @override
  String get settingsCollectionTile => 'Bộ sưu tập';

  @override
  String get statsPageTitle => 'Thống kê';

  @override
  String statsWithGps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '${count}mục với thông tin vị trí',
      one: '1 mục với thông tin vị trí',
    );
    return '$_temp0';
  }

  @override
  String get statsTopCountriesSectionTitle => 'Quốc gia';

  @override
  String get statsTopStatesSectionTitle => 'Bang/Tỉnh';

  @override
  String get statsTopPlacesSectionTitle => 'Địa điểm';

  @override
  String get statsTopTagsSectionTitle => 'Thẻ';

  @override
  String get statsTopAlbumsSectionTitle => 'Bộ sưu tập hàng đầu';

  @override
  String get viewerOpenPanoramaButtonLabel => 'MỞ CHẾ ĐỘ TOÀN CẢNH';

  @override
  String get viewerSetWallpaperButtonLabel => 'CÀI HÌNH NỀN';

  @override
  String get viewerErrorUnknown => 'Ôi!';

  @override
  String get viewerErrorDoesNotExist => 'Tệp không còn tồn tại.';

  @override
  String get viewerInfoPageTitle => 'Thông tin';

  @override
  String get viewerInfoBackToViewerTooltip => 'Trở lại chế độ xem';

  @override
  String get viewerInfoUnknown => 'Không biết';

  @override
  String get viewerInfoLabelDescription => 'Mô tả';

  @override
  String get viewerInfoLabelTitle => 'Tiêu đề';

  @override
  String get viewerInfoLabelDate => 'Thời gian';

  @override
  String get viewerInfoLabelResolution => 'Phân tích';

  @override
  String get viewerInfoLabelSize => 'Kích cỡ';

  @override
  String get viewerInfoLabelUri => 'URI';

  @override
  String get viewerInfoLabelPath => 'Đường dẫn';

  @override
  String get viewerInfoLabelDuration => 'Thời lượng';

  @override
  String get viewerInfoLabelOwner => 'Chủ sở hữu';

  @override
  String get viewerInfoLabelCoordinates => 'Tọa độ';

  @override
  String get viewerInfoLabelAddress => 'Địa chỉ';

  @override
  String get mapStyleDialogTitle => 'Kiểu bản đồ';

  @override
  String get mapStyleTooltip => 'Chọn kiểu bản đồ';

  @override
  String get mapZoomInTooltip => 'Phóng to';

  @override
  String get mapZoomOutTooltip => 'Thu nhỏ';

  @override
  String get mapPointNorthUpTooltip => 'Hướng về phía bắc';

  @override
  String get mapAttributionOsmData => 'Dữ liệu bản đồ © [OpenStreetMap](https://www.openstreetmap.org/copyright) đóng góp';

  @override
  String get mapAttributionOsmLiberty => 'Cung cấp bởi [OpenMapTiles](https://www.openmaptiles.org/), [CC BY](http://creativecommons.org/licenses/by/4.0) • Được lưu trữ bởi [OSM Americana](https://tile.ourmap.us)';

  @override
  String get mapAttributionOpenTopoMap => '[SRTM](https://www.earthdata.nasa.gov/sensors/srtm) | Cung cấp bởi [OpenTopoMap](https://opentopomap.org/), [CC BY-SA](https://creativecommons.org/licenses/by-sa/3.0/)';

  @override
  String get mapAttributionOsmHot => 'Cung cấp bởi [HOT](https://www.hotosm.org/) • Lưu trữ bởi [OSM France](https://openstreetmap.fr/)';

  @override
  String get mapAttributionStamen => 'Cung cấp bởi [Stamen Design](https://stamen.com), [CC BY 3.0](https://creativecommons.org/licenses/by/3.0)';

  @override
  String get openMapPageTooltip => 'Xen trên Bản đồ';

  @override
  String get mapEmptyRegion => 'Không có ảnh nào tại khu vực này';

  @override
  String get viewerInfoOpenEmbeddedFailureFeedback => 'Không thể trích xuất dữ liệu được nhúng';

  @override
  String get viewerInfoOpenLinkText => 'Mở';

  @override
  String get viewerInfoViewXmlLinkText => 'Xem XML';

  @override
  String get viewerInfoSearchFieldLabel => 'Tìm kiếm metadata';

  @override
  String get viewerInfoSearchEmpty => 'Không phù hợp';

  @override
  String get viewerInfoSearchSuggestionDate => 'Ngày & Giờ';

  @override
  String get viewerInfoSearchSuggestionDescription => 'Mô tả';

  @override
  String get viewerInfoSearchSuggestionDimensions => 'Kích thước';

  @override
  String get viewerInfoSearchSuggestionResolution => 'Phân tích';

  @override
  String get viewerInfoSearchSuggestionRights => 'Luật';

  @override
  String get wallpaperUseScrollEffect => 'Sử dụng hiệu ứng cuộn trên màn hình chính';

  @override
  String get tagEditorPageTitle => 'Chỉnh sửa thẻ';

  @override
  String get tagEditorPageNewTagFieldLabel => 'Tag mới';

  @override
  String get tagEditorPageAddTagTooltip => 'Thêm tag';

  @override
  String get tagEditorSectionRecent => 'Gần đây';

  @override
  String get tagEditorSectionPlaceholders => 'Trình giữ chổ';

  @override
  String get tagEditorDiscardDialogMessage => 'Bạn có muốn hủy các thay đổi không?';

  @override
  String get tagPlaceholderCountry => 'Quốc gia';

  @override
  String get tagPlaceholderState => 'Bang/Tỉnh thành';

  @override
  String get tagPlaceholderPlace => 'Địa điểm';

  @override
  String get panoramaEnableSensorControl => 'Bật điều khiển cảm biến';

  @override
  String get panoramaDisableSensorControl => 'Tắt điều khiển cảm biến';

  @override
  String get sourceViewerPageTitle => 'Nguồn';

  @override
  String get filePickerShowHiddenFiles => 'Hiển thị tệp ẩn';

  @override
  String get filePickerDoNotShowHiddenFiles => 'Đừng hiển thị tệp ẩn';

  @override
  String get filePickerOpenFrom => 'Mở từ';

  @override
  String get filePickerNoItems => 'Không có mục nào';

  @override
  String get filePickerUseThisFolder => 'Dùng thư mục này';
}
