// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => '아베스';

  @override
  String get welcomeMessage => '아베스 사용을 환영합니다';

  @override
  String get welcomeOptional => '선택';

  @override
  String get welcomeTermsToggle => '이용약관에 동의합니다';

  @override
  String itemCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString개',
    );
    return '$_temp0';
  }

  @override
  String columnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count열',
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
      other: '$countString초',
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
      other: '$countString분',
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
      other: '$countString일',
    );
    return '$_temp0';
  }

  @override
  String focalLength(String length) {
    return '$length mm';
  }

  @override
  String get applyButtonLabel => '적용';

  @override
  String get createButtonLabel => 'CREATE';

  @override
  String get deleteButtonLabel => '삭제';

  @override
  String get nextButtonLabel => '다음';

  @override
  String get showButtonLabel => '보기';

  @override
  String get hideButtonLabel => '숨기기';

  @override
  String get continueButtonLabel => '다음';

  @override
  String get saveCopyButtonLabel => '사본 저장';

  @override
  String get applyTooltip => '적용';

  @override
  String get cancelTooltip => '취소';

  @override
  String get changeTooltip => '변경';

  @override
  String get clearTooltip => '초기화';

  @override
  String get previousTooltip => '이전';

  @override
  String get nextTooltip => '다음';

  @override
  String get showTooltip => '보기';

  @override
  String get hideTooltip => '숨기기';

  @override
  String get actionRemove => '제거';

  @override
  String get resetTooltip => '복원';

  @override
  String get saveTooltip => '저장';

  @override
  String get stopTooltip => '취소';

  @override
  String get pickTooltip => '선택';

  @override
  String get doubleBackExitMessage => '종료하려면 한번 더 누르세요.';

  @override
  String get doNotAskAgain => '다시 묻지 않기';

  @override
  String get sourceStateLoading => '로딩 중';

  @override
  String get sourceStateCataloguing => '분석 중';

  @override
  String get sourceStateLocatingCountries => '국가 찾는 중';

  @override
  String get sourceStateLocatingPlaces => '장소 찾는 중';

  @override
  String get chipActionDelete => '삭제';

  @override
  String get chipActionRemove => '제거';

  @override
  String get chipActionShowCollection => '미디어 페이지에서 보기';

  @override
  String get chipActionGoToAlbumPage => '앨범 페이지에서 보기';

  @override
  String get chipActionGoToCountryPage => '국가 페이지에서 보기';

  @override
  String get chipActionGoToPlacePage => '장소 페이지에서 보기';

  @override
  String get chipActionGoToTagPage => '태그 페이지에서 보기';

  @override
  String get chipActionGoToExplorerPage => '탐색기 페이지에서 보기';

  @override
  String get chipActionDecompose => '나누기';

  @override
  String get chipActionFilterOut => '제외하기';

  @override
  String get chipActionFilterIn => '포함시키기';

  @override
  String get chipActionHide => '숨기기';

  @override
  String get chipActionLock => '잠금';

  @override
  String get chipActionPin => '고정';

  @override
  String get chipActionUnpin => '고정 해제';

  @override
  String get chipActionGroup => 'Group';

  @override
  String get chipActionRename => '이름 변경';

  @override
  String get chipActionSetCover => '대표 이미지 변경';

  @override
  String get chipActionShowCountryStates => '주 보기';

  @override
  String get chipActionCreateGroup => 'Create group';

  @override
  String get chipActionCreateAlbum => '앨범 만들기';

  @override
  String get chipActionCreateVault => '금고 만들기';

  @override
  String get chipActionConfigureVault => '금고 설정';

  @override
  String get entryActionCopyToClipboard => '클립보드에 복사';

  @override
  String get entryActionDelete => '삭제';

  @override
  String get entryActionConvert => '변환';

  @override
  String get entryActionExport => '내보내기';

  @override
  String get entryActionInfo => '상세정보';

  @override
  String get entryActionRename => '이름 변경';

  @override
  String get entryActionRestore => '복원';

  @override
  String get entryActionRotateCCW => '좌회전';

  @override
  String get entryActionRotateCW => '우회전';

  @override
  String get entryActionFlip => '좌우 뒤집기';

  @override
  String get entryActionPrint => '인쇄';

  @override
  String get entryActionShare => '공유';

  @override
  String get entryActionShareImageOnly => '사진만 공유';

  @override
  String get entryActionShareVideoOnly => '동영상만 공유';

  @override
  String get entryActionViewSource => '소스 코드 보기';

  @override
  String get entryActionShowGeoTiffOnMap => '지도에 겹쳐그리기';

  @override
  String get entryActionConvertMotionPhotoToStillImage => '스틸 사진으로 변환';

  @override
  String get entryActionViewMotionPhotoVideo => '동영상 보기';

  @override
  String get entryActionEdit => '편집';

  @override
  String get entryActionOpen => '다른 앱에서 열기';

  @override
  String get entryActionSetAs => '다음 용도로 사용';

  @override
  String get entryActionCast => '전송';

  @override
  String get entryActionOpenMap => '지도 앱에서 보기';

  @override
  String get entryActionRotateScreen => '화면 회전';

  @override
  String get entryActionAddFavourite => '즐겨찾기에 추가';

  @override
  String get entryActionRemoveFavourite => '즐겨찾기에서 삭제';

  @override
  String get videoActionCaptureFrame => '프레임 캡처';

  @override
  String get videoActionMute => '음소거';

  @override
  String get videoActionUnmute => '음소거 해제';

  @override
  String get videoActionPause => '일시정지';

  @override
  String get videoActionPlay => '재생';

  @override
  String get videoActionReplay10 => '10초 뒤로 탐색';

  @override
  String get videoActionSkip10 => '10초 앞으로 탐색';

  @override
  String get videoActionShowPreviousFrame => '이전 프레임 보기';

  @override
  String get videoActionShowNextFrame => '다음 프레임 보기';

  @override
  String get videoActionSelectStreams => '트랙 선택';

  @override
  String get videoActionSetSpeed => '재생 배속';

  @override
  String get videoActionABRepeat => 'A-B 반복';

  @override
  String get videoRepeatActionSetStart => '시작 지점 설정';

  @override
  String get videoRepeatActionSetEnd => '종료 지점 설정';

  @override
  String get viewerActionSettings => '설정';

  @override
  String get viewerActionLock => '뷰어 잠금';

  @override
  String get viewerActionUnlock => '뷰어 잠금 해제';

  @override
  String get slideshowActionResume => '이어서';

  @override
  String get slideshowActionShowInCollection => '미디어 페이지에서 보기';

  @override
  String get entryInfoActionEditDate => '날짜 및 시간 수정';

  @override
  String get entryInfoActionEditLocation => '위치 수정';

  @override
  String get entryInfoActionEditTitleDescription => '제목 및 설명 수정';

  @override
  String get entryInfoActionEditRating => '별점 수정';

  @override
  String get entryInfoActionEditTags => '태그 수정';

  @override
  String get entryInfoActionRemoveMetadata => '메타데이터 삭제';

  @override
  String get entryInfoActionExportMetadata => '메타데이터 내보내기';

  @override
  String get entryInfoActionRemoveLocation => '위치 삭제';

  @override
  String get editorActionTransform => '변형';

  @override
  String get editorTransformCrop => '자르기';

  @override
  String get editorTransformRotate => '회전';

  @override
  String get cropAspectRatioFree => '사용자 맞춤 비율';

  @override
  String get cropAspectRatioOriginal => '원본';

  @override
  String get cropAspectRatioSquare => '정사각형';

  @override
  String get filterAspectRatioLandscapeLabel => '가로';

  @override
  String get filterAspectRatioPortraitLabel => '세로';

  @override
  String get filterBinLabel => '휴지통';

  @override
  String get filterFavouriteLabel => '즐겨찾기';

  @override
  String get filterNoDateLabel => '날짜 없음';

  @override
  String get filterNoAddressLabel => '주소 없음';

  @override
  String get filterLocatedLabel => '위치 있음';

  @override
  String get filterNoLocationLabel => '위치 없음';

  @override
  String get filterNoRatingLabel => '별점 없음';

  @override
  String get filterTaggedLabel => '태그 있음';

  @override
  String get filterNoTagLabel => '태그 없음';

  @override
  String get filterNoTitleLabel => '제목 없음';

  @override
  String get filterOnThisDayLabel => '이 날';

  @override
  String get filterRecentlyAddedLabel => '최근 추가된';

  @override
  String get filterRatingRejectedLabel => '거부됨';

  @override
  String get filterTypeAnimatedLabel => '애니메이션';

  @override
  String get filterTypeMotionPhotoLabel => '모션 사진';

  @override
  String get filterTypePanoramaLabel => '파노라마';

  @override
  String get filterTypeRawLabel => 'Raw';

  @override
  String get filterTypeSphericalVideoLabel => '360° 동영상';

  @override
  String get filterTypeGeotiffLabel => 'GeoTIFF';

  @override
  String get filterMimeImageLabel => '사진';

  @override
  String get filterMimeVideoLabel => '동영상';

  @override
  String get accessibilityAnimationsRemove => '화면 효과 제한';

  @override
  String get accessibilityAnimationsKeep => '화면 효과 유지';

  @override
  String get albumTierNew => '신규';

  @override
  String get albumTierPinned => '고정';

  @override
  String get albumTierGroups => 'Groups';

  @override
  String get albumTierSpecial => '기본';

  @override
  String get albumTierApps => '앱';

  @override
  String get albumTierVaults => '금고';

  @override
  String get albumTierDynamic => '동적';

  @override
  String get albumTierRegular => '일반';

  @override
  String get coordinateFormatDms => '도, 분, 초';

  @override
  String get coordinateFormatDdm => '도, 십진 분';

  @override
  String get coordinateFormatDecimal => '십신 도';

  @override
  String coordinateDms(String coordinate, String direction) {
    return '$direction $coordinate';
  }

  @override
  String get coordinateDmsNorth => '북위';

  @override
  String get coordinateDmsSouth => '남위';

  @override
  String get coordinateDmsEast => '동경';

  @override
  String get coordinateDmsWest => '서경';

  @override
  String get displayRefreshRatePreferHighest => '가장 높은 재생률';

  @override
  String get displayRefreshRatePreferLowest => '가장 낮은 재생률';

  @override
  String get keepScreenOnNever => '자동 꺼짐';

  @override
  String get keepScreenOnVideoPlayback => '동영상 재생 시 작동';

  @override
  String get keepScreenOnViewerOnly => '뷰어 이용 시 작동';

  @override
  String get keepScreenOnAlways => '항상 켜짐';

  @override
  String get lengthUnitPixel => 'px';

  @override
  String get lengthUnitPercent => '%';

  @override
  String get mapStyleGoogleNormal => 'Google 지도';

  @override
  String get mapStyleGoogleHybrid => 'Google 지도 (위성)';

  @override
  String get mapStyleGoogleTerrain => 'Google 지도 (지형)';

  @override
  String get mapStyleOsmLiberty => 'OSM Liberty';

  @override
  String get mapStyleOpenTopoMap => 'OpenTopoMap';

  @override
  String get mapStyleOsmHot => 'Humanitarian OSM';

  @override
  String get mapStyleStamenWatercolor => 'Stamen Watercolor (수채화)';

  @override
  String get maxBrightnessNever => '작동 안 함';

  @override
  String get maxBrightnessAlways => '항상 켜짐';

  @override
  String get nameConflictStrategyRename => '이름 변경';

  @override
  String get nameConflictStrategyReplace => '대체';

  @override
  String get nameConflictStrategySkip => '건너뛰기';

  @override
  String get overlayHistogramNone => '없음';

  @override
  String get overlayHistogramRGB => 'RGB';

  @override
  String get overlayHistogramLuminance => '휘도';

  @override
  String get subtitlePositionTop => '위';

  @override
  String get subtitlePositionBottom => '아래';

  @override
  String get themeBrightnessLight => '라이트';

  @override
  String get themeBrightnessDark => '다크';

  @override
  String get themeBrightnessBlack => '검은색';

  @override
  String get unitSystemMetric => '미터법';

  @override
  String get unitSystemImperial => '야드파운드법';

  @override
  String get vaultLockTypePattern => '패턴';

  @override
  String get vaultLockTypePin => 'PIN';

  @override
  String get vaultLockTypePassword => '비밀번호';

  @override
  String get settingsVideoEnablePip => 'PIP (화면 속 화면)';

  @override
  String get videoControlsPlayOutside => '다른 앱에서 열기';

  @override
  String get videoLoopModeNever => '반복 안 함';

  @override
  String get videoLoopModeShortOnly => '짧은 동영상만 반복';

  @override
  String get videoLoopModeAlways => '항상 반복';

  @override
  String get videoPlaybackSkip => '생략';

  @override
  String get videoPlaybackMuted => '음소거 재생';

  @override
  String get videoPlaybackWithSound => '일반 재생';

  @override
  String get videoResumptionModeNever => '재개 안 함';

  @override
  String get videoResumptionModeAlways => '항상 재개';

  @override
  String get viewerTransitionSlide => '좌우';

  @override
  String get viewerTransitionParallax => '시차';

  @override
  String get viewerTransitionFade => '페이드';

  @override
  String get viewerTransitionZoomIn => '확대';

  @override
  String get viewerTransitionNone => '없음';

  @override
  String get wallpaperTargetHome => '홈 화면';

  @override
  String get wallpaperTargetLock => '잠금화면';

  @override
  String get wallpaperTargetHomeLock => '홈 및 잠금화면';

  @override
  String get widgetDisplayedItemRandom => '무작위로';

  @override
  String get widgetDisplayedItemMostRecent => '최신';

  @override
  String get widgetOpenPageHome => '홈 열기';

  @override
  String get widgetOpenPageCollection => '미디어 열기';

  @override
  String get widgetOpenPageViewer => '뷰어 열기';

  @override
  String get widgetTapUpdateWidget => '위젯 갱신';

  @override
  String get storageVolumeDescriptionFallbackPrimary => '내장 메모리';

  @override
  String get storageVolumeDescriptionFallbackNonPrimary => 'SD 카드';

  @override
  String get rootDirectoryDescription => '루트 폴더';

  @override
  String otherDirectoryDescription(String name) {
    return '“$name” 폴더';
  }

  @override
  String storageAccessDialogMessage(String directory, String volume) {
    return '파일에 접근하도록 다음 화면에서 “$volume”의 $directory를 선택하세요.';
  }

  @override
  String restrictedAccessDialogMessage(String directory, String volume) {
    return '“$volume”의 $directory에 있는 파일의 접근이 제한됩니다.\n\n기본으로 설치된 갤러리나 파일 관리 앱을 사용해서 다른 폴더로 파일을 이동하세요.';
  }

  @override
  String notEnoughSpaceDialogMessage(String neededSize, String freeSize, String volume) {
    return '“$volume”에 필요 공간은 $neededSize인데 사용 가능한 용량은 $freeSize만 남아있습니다.';
  }

  @override
  String get missingSystemFilePickerDialogMessage => '기본 파일 선택기가 없거나 비활성화딥니다. 파일 선택기를 켜고 다시 시도하세요.';

  @override
  String unsupportedTypeDialogMessage(int count, String types) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '이 작업은 다음 항목의 형식을 지원하지 않습니다: $types.',
    );
    return '$_temp0';
  }

  @override
  String get nameConflictDialogSingleSourceMessage => '이동할 폴더에 이름이 같은 파일이 있습니다.';

  @override
  String get nameConflictDialogMultipleSourceMessage => '이름이 같은 파일이 있습니다.';

  @override
  String get addShortcutDialogLabel => '바로가기 라벨';

  @override
  String get addShortcutButtonLabel => '추가';

  @override
  String get noMatchingAppDialogMessage => '이 작업을 처리할 수 있는 앱이 없습니다.';

  @override
  String binEntriesConfirmationDialogMessage(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '항목 $countString개를 휴지통으로 이동하시겠습니까?',
      one: '이 항목을 휴지통으로 이동하시겠습니까?',
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
      other: '항목 $countString개를 삭제하시겠습니까?',
      one: '이 항목을 삭제하시겠습니까?',
    );
    return '$_temp0';
  }

  @override
  String get moveUndatedConfirmationDialogMessage => '이 작업을 계속하기 전에 항목의 날짜를 지정하시겠습니까?';

  @override
  String get moveUndatedConfirmationDialogSetDate => '날짜 지정하기';

  @override
  String videoResumeDialogMessage(String time) {
    return '$time부터 재개하시겠습니까?';
  }

  @override
  String get videoStartOverButtonLabel => '처음부터';

  @override
  String get videoResumeButtonLabel => '이어서';

  @override
  String get setCoverDialogLatest => '최근 항목';

  @override
  String get setCoverDialogAuto => '자동 설정';

  @override
  String get setCoverDialogCustom => '직접 설정';

  @override
  String get hideFilterConfirmationDialogMessage => '이 필터에 맞는 사진과 동영상이 보이지 않을 것입니다. “개인정보 보호” 설정을 수정하면 다시 보일 수 있습니다.\n\n이 필터를 숨기시겠습니까?';

  @override
  String get newAlbumDialogTitle => '새 앨범 만들기';

  @override
  String get newAlbumDialogNameLabel => '앨범 이름';

  @override
  String get newAlbumDialogAlbumAlreadyExistsHelper => '앨범이 이미 있습니다';

  @override
  String get newAlbumDialogNameLabelAlreadyExistsHelper => '사용 중인 이름입니다';

  @override
  String get newAlbumDialogStorageLabel => '저장공간:';

  @override
  String get newDynamicAlbumDialogTitle => '새 동적 앨범';

  @override
  String get dynamicAlbumAlreadyExists => '동적 앨범이 이미 있습니다';

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
  String get newVaultWarningDialogMessage => '금고에 있는 항목들은 이 앱에서만 볼 수 있습니다.\n\n이 앱을 삭제 시, 또한 이 앱의 데이터를 삭제 시, 항목을 완전히 삭제될 것입니다.';

  @override
  String get newVaultDialogTitle => '새 금고 만들기';

  @override
  String get configureVaultDialogTitle => '금고 설정';

  @override
  String get vaultDialogLockModeWhenScreenOff => '화면이 꺼진 후 자동으로 잠김';

  @override
  String get vaultDialogLockTypeLabel => '잠금 방식';

  @override
  String get patternDialogEnter => '패턴을 입력하세요';

  @override
  String get patternDialogConfirm => '패턴을 확인하세요';

  @override
  String get pinDialogEnter => 'PIN을 입력하세요';

  @override
  String get pinDialogConfirm => 'PIN을 확인하세요';

  @override
  String get passwordDialogEnter => '비밀번호를 입력하세요';

  @override
  String get passwordDialogConfirm => '비밀번호를 확인하세요';

  @override
  String get authenticateToConfigureVault => '금고 설정을 위한 인증';

  @override
  String get authenticateToUnlockVault => '금고 잠금 해제를 위한 인증';

  @override
  String get vaultBinUsageDialogMessage => '휴지통을 사용하는 금고가 있습니다.';

  @override
  String get renameAlbumDialogLabel => '앨범 이름';

  @override
  String get renameAlbumDialogLabelAlreadyExistsHelper => '사용 중인 이름입니다';

  @override
  String get renameEntrySetPageTitle => '이름 변경';

  @override
  String get renameEntrySetPagePatternFieldLabel => '이름 양식';

  @override
  String get renameEntrySetPageInsertTooltip => '필드 추가';

  @override
  String get renameEntrySetPagePreviewSectionTitle => '미리보기';

  @override
  String get renameProcessorCounter => '숫자 증가';

  @override
  String get renameProcessorHash => '해시';

  @override
  String get renameProcessorName => '이름';

  @override
  String deleteSingleAlbumConfirmationDialogMessage(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '이 앨범의 항목 $countString개를 삭제하시겠습니까?',
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
      other: '이 앨범들의 항목 $countString개를 삭제하시겠습니까?',
    );
    return '$_temp0';
  }

  @override
  String get exportEntryDialogFormat => '형식:';

  @override
  String get exportEntryDialogWidth => '가로';

  @override
  String get exportEntryDialogHeight => '세로';

  @override
  String get exportEntryDialogQuality => '품질';

  @override
  String get exportEntryDialogWriteMetadata => '메타데이터 저장';

  @override
  String get renameEntryDialogLabel => '이름';

  @override
  String get editEntryDialogCopyFromItem => '다른 항목에서 지정';

  @override
  String get editEntryDialogTargetFieldsHeader => '수정할 필드';

  @override
  String get editEntryDateDialogTitle => '날짜 및 시간';

  @override
  String get editEntryDateDialogSetCustom => '지정 날짜로 편집';

  @override
  String get editEntryDateDialogCopyField => '다른 날짜에서 지정';

  @override
  String get editEntryDateDialogExtractFromTitle => '제목에서 추출';

  @override
  String get editEntryDateDialogShift => '시간 이동';

  @override
  String get editEntryDateDialogSourceFileModifiedDate => '파일 수정한 날짜';

  @override
  String get durationDialogHours => '시간';

  @override
  String get durationDialogMinutes => '분';

  @override
  String get durationDialogSeconds => '초';

  @override
  String get editEntryLocationDialogTitle => '위치';

  @override
  String get editEntryLocationDialogSetCustom => '지정 장소로 편집';

  @override
  String get editEntryLocationDialogChooseOnMap => '지도에서 선택';

  @override
  String get editEntryLocationDialogImportGpx => 'GPX 가져오기';

  @override
  String get editEntryLocationDialogLatitude => '위도';

  @override
  String get editEntryLocationDialogLongitude => '경도';

  @override
  String get editEntryLocationDialogTimeShift => '시간 이동';

  @override
  String get locationPickerUseThisLocationButton => '이 위치 사용';

  @override
  String get editEntryRatingDialogTitle => '별점';

  @override
  String get removeEntryMetadataDialogTitle => '메타데이터 삭제';

  @override
  String get removeEntryMetadataDialogAll => '모두';

  @override
  String get removeEntryMetadataDialogMore => '더 보기';

  @override
  String get removeEntryMetadataMotionPhotoXmpWarningDialogMessage => 'XMP가 있어야 모션 사진에 포함되는 동영상을 재생할 수 있습니다.\n\n삭제하시겠습니까?';

  @override
  String get videoSpeedDialogLabel => '재생 배속';

  @override
  String get videoStreamSelectionDialogVideo => '동영상';

  @override
  String get videoStreamSelectionDialogAudio => '오디오';

  @override
  String get videoStreamSelectionDialogText => '자막';

  @override
  String get videoStreamSelectionDialogOff => '해제';

  @override
  String get videoStreamSelectionDialogTrack => '트랙';

  @override
  String get videoStreamSelectionDialogNoSelection => '다른 트랙이 없습니다.';

  @override
  String get genericSuccessFeedback => '정상 처리됐습니다';

  @override
  String get genericFailureFeedback => '오류가 발생했습니다';

  @override
  String get genericDangerWarningDialogMessage => '확실합니까?';

  @override
  String get tooManyItemsErrorDialogMessage => '항목 수를 줄이고 다시 시도하세요.';

  @override
  String get menuActionConfigureView => '보기 설정';

  @override
  String get menuActionSelect => '선택';

  @override
  String get menuActionSelectAll => '모두 선택';

  @override
  String get menuActionSelectNone => '모두 해제';

  @override
  String get menuActionMap => '지도';

  @override
  String get menuActionSlideshow => '슬라이드쇼';

  @override
  String get menuActionStats => '통계';

  @override
  String get viewDialogSortSectionTitle => '정렬';

  @override
  String get viewDialogGroupSectionTitle => '묶음';

  @override
  String get viewDialogLayoutSectionTitle => '배치';

  @override
  String get viewDialogReverseSortOrder => '순서를 뒤바꾸기';

  @override
  String get tileLayoutMosaic => '모자이크';

  @override
  String get tileLayoutGrid => '바둑판';

  @override
  String get tileLayoutList => '목록';

  @override
  String get castDialogTitle => '전송 대상';

  @override
  String get coverDialogTabCover => '이미지';

  @override
  String get coverDialogTabApp => '앱';

  @override
  String get coverDialogTabColor => '색깔';

  @override
  String get appPickDialogTitle => '앱 선택';

  @override
  String get appPickDialogNone => '없음';

  @override
  String get aboutPageTitle => '앱 정보';

  @override
  String get aboutLinkLicense => '라이선스';

  @override
  String get aboutLinkPolicy => '개인정보 보호정책';

  @override
  String get aboutBugSectionTitle => '버그 보고';

  @override
  String get aboutBugSaveLogInstruction => '앱 로그를 파일에 저장하기';

  @override
  String get aboutBugCopyInfoInstruction => '시스템 정보를 복사하기';

  @override
  String get aboutBugCopyInfoButton => '복사';

  @override
  String get aboutBugReportInstruction => '로그와 시스템 정보를 첨부하여 GitHub에서 이슈를 제출하기';

  @override
  String get aboutBugReportButton => '제출';

  @override
  String get aboutDataUsageSectionTitle => '사용 중인 저장공간';

  @override
  String get aboutDataUsageData => '데이터';

  @override
  String get aboutDataUsageCache => '캐시';

  @override
  String get aboutDataUsageDatabase => '데이터베이스';

  @override
  String get aboutDataUsageMisc => '기타';

  @override
  String get aboutDataUsageInternal => '내부 저장소';

  @override
  String get aboutDataUsageExternal => '외부 저장소';

  @override
  String get aboutDataUsageClearCache => '캐시 삭제';

  @override
  String get aboutCreditsSectionTitle => '크레딧';

  @override
  String get aboutCreditsWorldAtlas1 => '이 앱은';

  @override
  String get aboutCreditsWorldAtlas2 => '의 TopoJSON 파일(ISC 라이선스)을 이용합니다.';

  @override
  String get aboutTranslatorsSectionTitle => '번역가';

  @override
  String get aboutLicensesSectionTitle => '오픈 소스 라이선스';

  @override
  String get aboutLicensesBanner => '이 앱은 다음의 오픈 소스 패키지와 라이브러리를 이용합니다.';

  @override
  String get aboutLicensesAndroidLibrariesSectionTitle => '안드로이드 라이브러리';

  @override
  String get aboutLicensesFlutterPluginsSectionTitle => '플러터 플러그인';

  @override
  String get aboutLicensesFlutterPackagesSectionTitle => '플러터 패키지';

  @override
  String get aboutLicensesDartPackagesSectionTitle => '다트 패키지';

  @override
  String get aboutLicensesShowAllButtonLabel => '라이선스 모두 보기';

  @override
  String get policyPageTitle => '개인정보 보호정책';

  @override
  String get collectionPageTitle => '미디어';

  @override
  String get collectionPickPageTitle => '항목 선택';

  @override
  String get collectionSelectPageTitle => '항목 선택';

  @override
  String get collectionActionShowTitleSearch => '제목 필터 보기';

  @override
  String get collectionActionHideTitleSearch => '제목 필터 숨기기';

  @override
  String get collectionActionAddDynamicAlbum => '동적 앨범 추가';

  @override
  String get collectionActionAddShortcut => '홈 화면에 추가';

  @override
  String get collectionActionSetHome => '홈으로 설정';

  @override
  String get collectionActionEmptyBin => '휴지통 비우기';

  @override
  String get collectionActionCopy => '앨범으로 복사';

  @override
  String get collectionActionMove => '앨범으로 이동';

  @override
  String get collectionActionRescan => '새로 분석';

  @override
  String get collectionActionEdit => '편집';

  @override
  String get collectionSearchTitlesHintText => '제목 검색';

  @override
  String get collectionGroupAlbum => '앨범별로';

  @override
  String get collectionGroupMonth => '월별로';

  @override
  String get collectionGroupDay => '날짜별로';

  @override
  String get sectionNone => 'No sections';

  @override
  String get sectionUnknown => '없음';

  @override
  String get dateToday => '오늘';

  @override
  String get dateYesterday => '어제';

  @override
  String get dateThisMonth => '이번 달';

  @override
  String collectionDeleteFailureFeedback(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '항목 $countString개를 삭제하지 못했습니다',
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
      other: '항목 $countString개를 복사하지 못했습니다',
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
      other: '항목 $countString개를 이동하지 못했습니다',
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
      other: '항목 $countString개의 이름을 변경하지 못했습니다',
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
      other: '항목 $countString개를 편집하지 못했습니다',
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
      other: '항목 $countString개를 내보내지 못했습니다',
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
      other: '항목 $countString개를 복사했습니다',
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
      other: '항목 $countString개를 이동했습니다',
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
      other: '항목 $countString개의 이름을 변경했습니다',
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
      other: '항목 $countString개를 편집했습니다',
    );
    return '$_temp0';
  }

  @override
  String get collectionEmptyFavourites => '즐겨찾기가 없습니다';

  @override
  String get collectionEmptyVideos => '동영상이 없습니다';

  @override
  String get collectionEmptyImages => '사진이 없습니다';

  @override
  String get collectionEmptyGrantAccessButtonLabel => '접근 허용';

  @override
  String get collectionSelectSectionTooltip => '묶음 선택';

  @override
  String get collectionDeselectSectionTooltip => '묶음 선택 해제';

  @override
  String get drawerAboutButton => '앱 정보';

  @override
  String get drawerSettingsButton => '설정';

  @override
  String get drawerCollectionAll => '모든 미디어';

  @override
  String get drawerCollectionFavourites => '즐겨찾기';

  @override
  String get drawerCollectionImages => '사진';

  @override
  String get drawerCollectionVideos => '동영상';

  @override
  String get drawerCollectionAnimated => '애니메이션';

  @override
  String get drawerCollectionMotionPhotos => '모션 사진';

  @override
  String get drawerCollectionPanoramas => '파노라마';

  @override
  String get drawerCollectionRaws => 'Raw 이미지';

  @override
  String get drawerCollectionSphericalVideos => '360° 동영상';

  @override
  String get drawerAlbumPage => '앨범';

  @override
  String get drawerCountryPage => '국가';

  @override
  String get drawerPlacePage => '장소';

  @override
  String get drawerTagPage => '태그';

  @override
  String get sortByDate => '날짜';

  @override
  String get sortByName => '이름';

  @override
  String get sortByItemCount => '항목수';

  @override
  String get sortBySize => '크기';

  @override
  String get sortByAlbumFileName => '이름';

  @override
  String get sortByRating => '별점';

  @override
  String get sortByDuration => '길이';

  @override
  String get sortByPath => '경로';

  @override
  String get sortOrderNewestFirst => '최근 날짜순';

  @override
  String get sortOrderOldestFirst => '오래된 날짜순';

  @override
  String get sortOrderAtoZ => 'A~Z';

  @override
  String get sortOrderZtoA => 'Z~A';

  @override
  String get sortOrderHighestFirst => '높은 별점순';

  @override
  String get sortOrderLowestFirst => '낮은 별점순';

  @override
  String get sortOrderLargestFirst => '큰 파일순';

  @override
  String get sortOrderSmallestFirst => '작은 파일순';

  @override
  String get sortOrderShortestFirst => '짧은 순';

  @override
  String get sortOrderLongestFirst => '긴 순';

  @override
  String get albumGroupTier => '단계별로';

  @override
  String get albumGroupType => '유형별로';

  @override
  String get albumGroupVolume => '저장공간별로';

  @override
  String get albumMimeTypeMixed => '혼합';

  @override
  String get albumPickPageTitleCopy => '앨범으로 복사';

  @override
  String get albumPickPageTitleExport => '앨범으로 내보내기';

  @override
  String get albumPickPageTitleMove => '앨범으로 이동';

  @override
  String get albumPickPageTitlePick => '앨범 선택';

  @override
  String get albumCamera => '카메라';

  @override
  String get albumDownload => '다운로드';

  @override
  String get albumScreenshots => '스크린샷';

  @override
  String get albumScreenRecordings => '화면 녹화 파일';

  @override
  String get albumVideoCaptures => '동영상 캡처';

  @override
  String get albumPageTitle => '앨범';

  @override
  String get albumEmpty => '앨범이 없습니다';

  @override
  String get createAlbumButtonLabel => '추가';

  @override
  String get newFilterBanner => '신규';

  @override
  String get countryPageTitle => '국가';

  @override
  String get countryEmpty => '국가가 없습니다';

  @override
  String get statePageTitle => '주';

  @override
  String get stateEmpty => '주가 없습니다';

  @override
  String get placePageTitle => '장소';

  @override
  String get placeEmpty => '장소가 없습니다';

  @override
  String get tagPageTitle => '태그';

  @override
  String get tagEmpty => '태그가 없습니다';

  @override
  String get binPageTitle => '휴지통';

  @override
  String get explorerPageTitle => '탐색기';

  @override
  String get explorerActionSelectStorageVolume => '저장공간 선택';

  @override
  String get selectStorageVolumeDialogTitle => '저장공간';

  @override
  String get searchCollectionFieldHint => '미디어 검색';

  @override
  String get searchRecentSectionTitle => '최근 검색기록';

  @override
  String get searchDateSectionTitle => '날짜';

  @override
  String get searchFormatSectionTitle => '형식';

  @override
  String get searchAlbumsSectionTitle => '앨범';

  @override
  String get searchCountriesSectionTitle => '국가';

  @override
  String get searchStatesSectionTitle => '주';

  @override
  String get searchPlacesSectionTitle => '장소';

  @override
  String get searchTagsSectionTitle => '태그';

  @override
  String get searchRatingSectionTitle => '별점';

  @override
  String get searchMetadataSectionTitle => '메타데이터';

  @override
  String get settingsPageTitle => '설정';

  @override
  String get settingsSystemDefault => '시스템 기본값';

  @override
  String get settingsDefault => '기본';

  @override
  String get settingsDisabled => '사용 안함';

  @override
  String get settingsAskEverytime => '매번 물어보기';

  @override
  String get settingsModificationWarningDialogMessage => '다른 설정도 변경될 것입니다.';

  @override
  String get settingsSearchFieldLabel => '설정 검색';

  @override
  String get settingsSearchEmpty => '결과가 없습니다';

  @override
  String get settingsActionExport => '내보내기';

  @override
  String get settingsActionExportDialogTitle => '내보내기';

  @override
  String get settingsActionImport => '가져오기';

  @override
  String get settingsActionImportDialogTitle => '가져오기';

  @override
  String get appExportCovers => '대표 이미지';

  @override
  String get appExportDynamicAlbums => '동적 앨범';

  @override
  String get appExportFavourites => '즐겨찾기';

  @override
  String get appExportSettings => '설정';

  @override
  String get settingsNavigationSectionTitle => '탐색';

  @override
  String get settingsHomeTile => '홈';

  @override
  String get settingsHomeDialogTitle => '홈';

  @override
  String get setHomeCustom => '직접 설정';

  @override
  String get settingsShowBottomNavigationBar => '하단 탐색 모음 표시';

  @override
  String get settingsKeepScreenOnTile => '화면 자동 꺼짐 방지';

  @override
  String get settingsKeepScreenOnDialogTitle => '화면 자동 꺼짐 방지';

  @override
  String get settingsDoubleBackExit => '뒤로가기 두번 눌러 앱 종료하기';

  @override
  String get settingsConfirmationTile => '확정 대화상자';

  @override
  String get settingsConfirmationDialogTitle => '확정 대화상자';

  @override
  String get settingsConfirmationBeforeDeleteItems => '항목을 완전히 삭제 시';

  @override
  String get settingsConfirmationBeforeMoveToBinItems => '항목을 휴지통으로 이동 시';

  @override
  String get settingsConfirmationBeforeMoveUndatedItems => '날짜가 지정되지 않은 항목을 이동 시';

  @override
  String get settingsConfirmationAfterMoveToBinItems => '항목을 휴지통으로 이동 후';

  @override
  String get settingsConfirmationVaultDataLoss => '금고에 관한 데이터 손실 경고';

  @override
  String get settingsNavigationDrawerTile => '탐색 메뉴';

  @override
  String get settingsNavigationDrawerEditorPageTitle => '탐색 메뉴';

  @override
  String get settingsNavigationDrawerBanner => '항목을 길게 누른 후 이동하여 탐색 메뉴에 표시될 항목의 순서를 수정하세요.';

  @override
  String get settingsNavigationDrawerTabTypes => '유형';

  @override
  String get settingsNavigationDrawerTabAlbums => '앨범';

  @override
  String get settingsNavigationDrawerTabPages => '페이지';

  @override
  String get settingsNavigationDrawerAddAlbum => '앨범 추가';

  @override
  String get settingsThumbnailSectionTitle => '섬네일';

  @override
  String get settingsThumbnailOverlayTile => '오버레이';

  @override
  String get settingsThumbnailOverlayPageTitle => '오버레이';

  @override
  String get settingsThumbnailShowHdrIcon => 'HDR 아이콘 표시';

  @override
  String get settingsThumbnailShowFavouriteIcon => '즐겨찾기 아이콘 표시';

  @override
  String get settingsThumbnailShowTagIcon => '태그 아이콘 표시';

  @override
  String get settingsThumbnailShowLocationIcon => '위치 아이콘 표시';

  @override
  String get settingsThumbnailShowMotionPhotoIcon => '모션 사진 아이콘 표시';

  @override
  String get settingsThumbnailShowRating => '별점 표시';

  @override
  String get settingsThumbnailShowRawIcon => 'Raw 아이콘 표시';

  @override
  String get settingsThumbnailShowVideoDuration => '동영상 길이 표시';

  @override
  String get settingsCollectionQuickActionsTile => '빠른 작업';

  @override
  String get settingsCollectionQuickActionEditorPageTitle => '빠른 작업';

  @override
  String get settingsCollectionQuickActionTabBrowsing => '탐색 시';

  @override
  String get settingsCollectionQuickActionTabSelecting => '선택 시';

  @override
  String get settingsCollectionBrowsingQuickActionEditorBanner => '버튼을 길게 누른 후 이동하여 항목 탐색할 때 표시될 버튼을 선택하세요.';

  @override
  String get settingsCollectionSelectionQuickActionEditorBanner => '버튼을 길게 누른 후 이동하여 항목 선택할 때 표시될 버튼을 선택하세요.';

  @override
  String get settingsCollectionBurstPatternsTile => '연속 촬영 양식';

  @override
  String get settingsCollectionBurstPatternsNone => '없음';

  @override
  String get settingsViewerSectionTitle => '뷰어';

  @override
  String get settingsViewerGestureSideTapNext => '화면 측면에서 탭해서 이전/다음 항목 보기';

  @override
  String get settingsViewerUseCutout => '컷아웃 영역 사용';

  @override
  String get settingsViewerMaximumBrightness => '최대 밝기';

  @override
  String get settingsMotionPhotoAutoPlay => '모션 사진 자동 재생';

  @override
  String get settingsImageBackground => '이미지 배경';

  @override
  String get settingsViewerQuickActionsTile => '빠른 작업';

  @override
  String get settingsViewerQuickActionEditorPageTitle => '빠른 작업';

  @override
  String get settingsViewerQuickActionEditorBanner => '버튼을 길게 누른 후 이동하여 뷰어에 표시될 버튼을 선택하세요.';

  @override
  String get settingsViewerQuickActionEditorDisplayedButtonsSectionTitle => '표시될 버튼';

  @override
  String get settingsViewerQuickActionEditorAvailableButtonsSectionTitle => '추가 가능한 버튼';

  @override
  String get settingsViewerQuickActionEmpty => '버튼이 없습니다';

  @override
  String get settingsViewerOverlayTile => '오버레이';

  @override
  String get settingsViewerOverlayPageTitle => '오버레이';

  @override
  String get settingsViewerShowOverlayOnOpening => '열릴 때 표시';

  @override
  String get settingsViewerShowHistogram => '히스토그램 표시';

  @override
  String get settingsViewerShowMinimap => '미니맵 표시';

  @override
  String get settingsViewerShowInformation => '상세 정보 표시';

  @override
  String get settingsViewerShowInformationSubtitle => '제목, 날짜, 장소 등 표시';

  @override
  String get settingsViewerShowRatingTags => '별점 및 태그 표시';

  @override
  String get settingsViewerShowShootingDetails => '촬영 정보 표시';

  @override
  String get settingsViewerShowDescription => '설명 표시';

  @override
  String get settingsViewerShowOverlayThumbnails => '섬네일 표시';

  @override
  String get settingsViewerEnableOverlayBlurEffect => '흐림 효과';

  @override
  String get settingsViewerSlideshowTile => '슬라이드쇼';

  @override
  String get settingsViewerSlideshowPageTitle => '슬라이드쇼';

  @override
  String get settingsSlideshowRepeat => '반복';

  @override
  String get settingsSlideshowShuffle => '순서섞기';

  @override
  String get settingsSlideshowFillScreen => '화면 채우기';

  @override
  String get settingsSlideshowAnimatedZoomEffect => '애니메이션 확대/축소 효과';

  @override
  String get settingsSlideshowTransitionTile => '전환 효과';

  @override
  String get settingsSlideshowIntervalTile => '교체 주기';

  @override
  String get settingsSlideshowVideoPlaybackTile => '동영상 재생';

  @override
  String get settingsSlideshowVideoPlaybackDialogTitle => '동영상 재생';

  @override
  String get settingsVideoPageTitle => '동영상 설정';

  @override
  String get settingsVideoSectionTitle => '동영상';

  @override
  String get settingsVideoShowVideos => '미디어에 동영상 표시';

  @override
  String get settingsVideoPlaybackTile => '재생';

  @override
  String get settingsVideoPlaybackPageTitle => '재생';

  @override
  String get settingsVideoEnableHardwareAcceleration => '하드웨어 가속';

  @override
  String get settingsVideoAutoPlay => '자동 재생';

  @override
  String get settingsVideoLoopModeTile => '반복 모드';

  @override
  String get settingsVideoLoopModeDialogTitle => '반복 모드';

  @override
  String get settingsVideoResumptionModeTile => '재생 재개';

  @override
  String get settingsVideoResumptionModeDialogTitle => '재생 재개';

  @override
  String get settingsVideoBackgroundMode => '백그라운드 재생';

  @override
  String get settingsVideoBackgroundModeDialogTitle => '백그라운드 재생';

  @override
  String get settingsVideoControlsTile => '제어';

  @override
  String get settingsVideoControlsPageTitle => '제어';

  @override
  String get settingsVideoButtonsTile => '버튼';

  @override
  String get settingsVideoGestureDoubleTapTogglePlay => '두 번 탭해서 재생이나 일시정지하기';

  @override
  String get settingsVideoGestureSideDoubleTapSeek => '화면 측면에서 두 번 탭해서 앞뒤로 가기';

  @override
  String get settingsVideoGestureVerticalDragBrightnessVolume => '위아래로 스와이프해서 밝기/음량을 조절하기';

  @override
  String get settingsSubtitleThemeTile => '자막';

  @override
  String get settingsSubtitleThemePageTitle => '자막';

  @override
  String get settingsSubtitleThemeSample => '샘플입니다.';

  @override
  String get settingsSubtitleThemeTextAlignmentTile => '정렬';

  @override
  String get settingsSubtitleThemeTextAlignmentDialogTitle => '정렬';

  @override
  String get settingsSubtitleThemeTextPositionTile => '수직 정렬';

  @override
  String get settingsSubtitleThemeTextPositionDialogTitle => '수직 정렬';

  @override
  String get settingsSubtitleThemeTextSize => '글자 크기';

  @override
  String get settingsSubtitleThemeShowOutline => '윤곽 및 그림자 표시';

  @override
  String get settingsSubtitleThemeTextColor => '글자 색상';

  @override
  String get settingsSubtitleThemeTextOpacity => '글자 투명도';

  @override
  String get settingsSubtitleThemeBackgroundColor => '배경 색상';

  @override
  String get settingsSubtitleThemeBackgroundOpacity => '배경 투명도';

  @override
  String get settingsSubtitleThemeTextAlignmentLeft => '왼쪽';

  @override
  String get settingsSubtitleThemeTextAlignmentCenter => '가운데';

  @override
  String get settingsSubtitleThemeTextAlignmentRight => '오른쪽';

  @override
  String get settingsPrivacySectionTitle => '개인정보 보호';

  @override
  String get settingsAllowInstalledAppAccess => '설치된 앱의 목록 접근 허용';

  @override
  String get settingsAllowInstalledAppAccessSubtitle => '앨범 표시 개선을 위해';

  @override
  String get settingsAllowErrorReporting => '오류 보고서 보내기';

  @override
  String get settingsSaveSearchHistory => '검색기록';

  @override
  String get settingsEnableBin => '휴지통 사용';

  @override
  String get settingsEnableBinSubtitle => '삭제한 항목을 30일 동안 보관하기';

  @override
  String get settingsDisablingBinWarningDialogMessage => '휴지통에 있는 항목들이 완전히 삭제될 것입니다.';

  @override
  String get settingsAllowMediaManagement => '미디어 관리 허용';

  @override
  String get settingsHiddenItemsTile => '숨겨진 항목';

  @override
  String get settingsHiddenItemsPageTitle => '숨겨진 항목';

  @override
  String get settingsHiddenFiltersBanner => '이 필터에 맞는 사진과 동영상이 숨겨지고 있으며 이 앱에서 보여지지 않을 것입니다.';

  @override
  String get settingsHiddenFiltersEmpty => '숨겨진 필터가 없습니다';

  @override
  String get settingsStorageAccessTile => '저장공간 접근';

  @override
  String get settingsStorageAccessPageTitle => '저장공간 접근';

  @override
  String get settingsStorageAccessBanner => '어떤 폴더는 사용자의 허용을 받아야만 앱이 파일에 접근이 가능합니다. 이 화면에 허용을 받은 폴더를 확인할 수 있으며 원하지 않으면 취소할 수 있습니다.';

  @override
  String get settingsStorageAccessEmpty => '접근 허용이 없습니다';

  @override
  String get settingsStorageAccessRevokeTooltip => '취소';

  @override
  String get settingsAccessibilitySectionTitle => '접근성';

  @override
  String get settingsRemoveAnimationsTile => '애니메이션 삭제';

  @override
  String get settingsRemoveAnimationsDialogTitle => '애니메이션 삭제';

  @override
  String get settingsTimeToTakeActionTile => '액션 취하기 전 대기 시간';

  @override
  String get settingsAccessibilityShowPinchGestureAlternatives => '멀티터치의 대안 표시';

  @override
  String get settingsDisplaySectionTitle => '디스플레이';

  @override
  String get settingsThemeBrightnessTile => '테마';

  @override
  String get settingsThemeBrightnessDialogTitle => '테마';

  @override
  String get settingsThemeColorHighlights => '색 강조';

  @override
  String get settingsThemeEnableDynamicColor => '동적 색상';

  @override
  String get settingsDisplayRefreshRateModeTile => '화면 재생률';

  @override
  String get settingsDisplayRefreshRateModeDialogTitle => '화면 재생률';

  @override
  String get settingsDisplayUseTvInterface => '안드로이드 TV 인터페이스 사용하기';

  @override
  String get settingsLanguageSectionTitle => '언어 및 표시 형식';

  @override
  String get settingsLanguageTile => '언어';

  @override
  String get settingsLanguagePageTitle => '언어';

  @override
  String get settingsCoordinateFormatTile => '좌표 표현';

  @override
  String get settingsCoordinateFormatDialogTitle => '좌표 표현';

  @override
  String get settingsUnitSystemTile => '단위법';

  @override
  String get settingsUnitSystemDialogTitle => '단위법';

  @override
  String get settingsForceWesternArabicNumeralsTile => '아라비아 숫자 항상 사용';

  @override
  String get settingsScreenSaverPageTitle => '화면보호기';

  @override
  String get settingsWidgetPageTitle => '사진 액자';

  @override
  String get settingsWidgetShowOutline => '윤곽';

  @override
  String get settingsWidgetOpenPage => '위젯을 탭하면';

  @override
  String get settingsWidgetDisplayedItem => '표시될 항목';

  @override
  String get settingsCollectionTile => '미디어';

  @override
  String get statsPageTitle => '통계';

  @override
  String statsWithGps(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString개 위치가 있음',
    );
    return '$_temp0';
  }

  @override
  String get statsTopCountriesSectionTitle => '국가 랭킹';

  @override
  String get statsTopStatesSectionTitle => '주 랭킹';

  @override
  String get statsTopPlacesSectionTitle => '장소 랭킹';

  @override
  String get statsTopTagsSectionTitle => '태그 랭킹';

  @override
  String get statsTopAlbumsSectionTitle => '앨범 랭킹';

  @override
  String get viewerOpenPanoramaButtonLabel => '파노라마 열기';

  @override
  String get viewerSetWallpaperButtonLabel => '설정';

  @override
  String get viewerErrorUnknown => '아이구!';

  @override
  String get viewerErrorDoesNotExist => '파일이 존재하지 않습니다.';

  @override
  String get viewerInfoPageTitle => '상세정보';

  @override
  String get viewerInfoBackToViewerTooltip => '뷰어로';

  @override
  String get viewerInfoUnknown => '알 수 없음';

  @override
  String get viewerInfoLabelDescription => '설명';

  @override
  String get viewerInfoLabelTitle => '제목';

  @override
  String get viewerInfoLabelDate => '날짜';

  @override
  String get viewerInfoLabelResolution => '해상도';

  @override
  String get viewerInfoLabelSize => '크기';

  @override
  String get viewerInfoLabelUri => 'URI';

  @override
  String get viewerInfoLabelPath => '경로';

  @override
  String get viewerInfoLabelDuration => '길이';

  @override
  String get viewerInfoLabelOwner => '패키지';

  @override
  String get viewerInfoLabelCoordinates => '좌표';

  @override
  String get viewerInfoLabelAddress => '주소';

  @override
  String get mapStyleDialogTitle => '지도 유형';

  @override
  String get mapStyleTooltip => '지도 유형 선택';

  @override
  String get mapZoomInTooltip => '확대';

  @override
  String get mapZoomOutTooltip => '축소';

  @override
  String get mapPointNorthUpTooltip => '북쪽을 위로 가리키기';

  @override
  String get mapAttributionOsmData => '지도 데이터 © [OpenStreetMap](https://www.openstreetmap.org/copyright) 기여자';

  @override
  String get mapAttributionOsmLiberty => '타일 [OpenMapTiles](https://www.openmaptiles.org/), [CC BY](http://creativecommons.org/licenses/by/4.0) • 호스팅 [OSM Americana](https://tile.ourmap.us)';

  @override
  String get mapAttributionOpenTopoMap => '[SRTM](https://www.earthdata.nasa.gov/sensors/srtm) | 타일 [OpenTopoMap](https://opentopomap.org/), [CC BY-SA](https://creativecommons.org/licenses/by-sa/3.0/)';

  @override
  String get mapAttributionOsmHot => '타일 [HOT](https://www.hotosm.org/) • 호스팅 [OSM France](https://openstreetmap.fr/)';

  @override
  String get mapAttributionStamen => '타일 [Stamen Design](https://stamen.com), [CC BY 3.0](https://creativecommons.org/licenses/by/3.0)';

  @override
  String get openMapPageTooltip => '지도 페이지에서 보기';

  @override
  String get mapEmptyRegion => '이 지역의 사진이 없습니다';

  @override
  String get viewerInfoOpenEmbeddedFailureFeedback => '첨부 데이터 추출 오류';

  @override
  String get viewerInfoOpenLinkText => '열기';

  @override
  String get viewerInfoViewXmlLinkText => 'XML 보기';

  @override
  String get viewerInfoSearchFieldLabel => '메타데이터 검색';

  @override
  String get viewerInfoSearchEmpty => '결과가 없습니다';

  @override
  String get viewerInfoSearchSuggestionDate => '날짜 및 시간';

  @override
  String get viewerInfoSearchSuggestionDescription => '설명';

  @override
  String get viewerInfoSearchSuggestionDimensions => '크기';

  @override
  String get viewerInfoSearchSuggestionResolution => '해상도';

  @override
  String get viewerInfoSearchSuggestionRights => '권리';

  @override
  String get wallpaperUseScrollEffect => '홈 화면에 스크롤 효과 사용';

  @override
  String get tagEditorPageTitle => '태그 수정';

  @override
  String get tagEditorPageNewTagFieldLabel => '새 태그';

  @override
  String get tagEditorPageAddTagTooltip => '태그 추가';

  @override
  String get tagEditorSectionRecent => '최근 이용기록';

  @override
  String get tagEditorSectionPlaceholders => '자리 표시자';

  @override
  String get tagEditorDiscardDialogMessage => '변경 사항을 취소하시겠습니까?';

  @override
  String get tagPlaceholderCountry => '국가';

  @override
  String get tagPlaceholderState => '주';

  @override
  String get tagPlaceholderPlace => '장소';

  @override
  String get panoramaEnableSensorControl => '센서 제어 활성화';

  @override
  String get panoramaDisableSensorControl => '센서 제어 비활성화';

  @override
  String get sourceViewerPageTitle => '소스 코드';
}
