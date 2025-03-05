// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'Aves';

  @override
  String get welcomeMessage => '欢迎使用 Aves';

  @override
  String get welcomeOptional => '可选';

  @override
  String get welcomeTermsToggle => '我同意这些使用条款和条件';

  @override
  String itemCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString 项',
    );
    return '$_temp0';
  }

  @override
  String columnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 列',
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
      other: '$countString 秒',
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
      other: '$countString 分',
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
      other: '$countString 天',
    );
    return '$_temp0';
  }

  @override
  String focalLength(String length) {
    return '$length mm';
  }

  @override
  String get applyButtonLabel => '应用';

  @override
  String get deleteButtonLabel => '删除';

  @override
  String get nextButtonLabel => '下一步';

  @override
  String get showButtonLabel => '显示';

  @override
  String get hideButtonLabel => '隐藏';

  @override
  String get continueButtonLabel => '继续';

  @override
  String get saveCopyButtonLabel => '保存副本';

  @override
  String get applyTooltip => '应用';

  @override
  String get cancelTooltip => '取消';

  @override
  String get changeTooltip => '更改';

  @override
  String get clearTooltip => '清除';

  @override
  String get previousTooltip => '上一组';

  @override
  String get nextTooltip => '下一组';

  @override
  String get showTooltip => '显示';

  @override
  String get hideTooltip => '隐藏';

  @override
  String get actionRemove => '移除';

  @override
  String get resetTooltip => '重置';

  @override
  String get saveTooltip => '保存';

  @override
  String get stopTooltip => '停止';

  @override
  String get pickTooltip => '挑选';

  @override
  String get doubleBackExitMessage => '再按一次退出';

  @override
  String get doNotAskAgain => '不再询问';

  @override
  String get sourceStateLoading => '加载中';

  @override
  String get sourceStateCataloguing => '正在进行编目';

  @override
  String get sourceStateLocatingCountries => '正在定位地区';

  @override
  String get sourceStateLocatingPlaces => '正在定位地点';

  @override
  String get chipActionDelete => '删除';

  @override
  String get chipActionRemove => '删除';

  @override
  String get chipActionShowCollection => '在媒体集中显示';

  @override
  String get chipActionGoToAlbumPage => '在相册中显示';

  @override
  String get chipActionGoToCountryPage => '在地区中显示';

  @override
  String get chipActionGoToPlacePage => '在地点中显示';

  @override
  String get chipActionGoToTagPage => '在标签中显示';

  @override
  String get chipActionGoToExplorerPage => '在资源管理器中显示';

  @override
  String get chipActionDecompose => '分割';

  @override
  String get chipActionFilterOut => '筛除';

  @override
  String get chipActionFilterIn => '筛选';

  @override
  String get chipActionHide => '隐藏';

  @override
  String get chipActionLock => '锁定';

  @override
  String get chipActionPin => '置顶';

  @override
  String get chipActionUnpin => '取消置顶';

  @override
  String get chipActionRename => '重命名';

  @override
  String get chipActionSetCover => '设置封面';

  @override
  String get chipActionShowCountryStates => '显示区域';

  @override
  String get chipActionCreateAlbum => '创建相册';

  @override
  String get chipActionCreateVault => '创建保险库';

  @override
  String get chipActionConfigureVault => '配置保险库';

  @override
  String get entryActionCopyToClipboard => '复制到剪贴板';

  @override
  String get entryActionDelete => '删除';

  @override
  String get entryActionConvert => '转换';

  @override
  String get entryActionExport => '导出';

  @override
  String get entryActionInfo => '信息';

  @override
  String get entryActionRename => '重命名';

  @override
  String get entryActionRestore => '恢复';

  @override
  String get entryActionRotateCCW => '逆时针旋转';

  @override
  String get entryActionRotateCW => '顺时针旋转';

  @override
  String get entryActionFlip => '水平翻转';

  @override
  String get entryActionPrint => '打印';

  @override
  String get entryActionShare => '分享';

  @override
  String get entryActionShareImageOnly => '仅分享图片';

  @override
  String get entryActionShareVideoOnly => '仅分享视频';

  @override
  String get entryActionViewSource => '查看源码';

  @override
  String get entryActionShowGeoTiffOnMap => '显示为地图叠加层';

  @override
  String get entryActionConvertMotionPhotoToStillImage => '转换为静态图像';

  @override
  String get entryActionViewMotionPhotoVideo => '打开视频';

  @override
  String get entryActionEdit => '编辑';

  @override
  String get entryActionOpen => '打开方式';

  @override
  String get entryActionSetAs => '设置为';

  @override
  String get entryActionCast => '投屏';

  @override
  String get entryActionOpenMap => '在地图应用中显示';

  @override
  String get entryActionRotateScreen => '旋转屏幕';

  @override
  String get entryActionAddFavourite => '加为收藏';

  @override
  String get entryActionRemoveFavourite => '取消收藏';

  @override
  String get videoActionCaptureFrame => '捕获帧';

  @override
  String get videoActionMute => '静音';

  @override
  String get videoActionUnmute => '取消静音';

  @override
  String get videoActionPause => '暂停';

  @override
  String get videoActionPlay => '播放';

  @override
  String get videoActionReplay10 => '前进 10 秒';

  @override
  String get videoActionSkip10 => '后退 10 秒';

  @override
  String get videoActionShowPreviousFrame => '显示上一帧';

  @override
  String get videoActionShowNextFrame => '显示下一帧';

  @override
  String get videoActionSelectStreams => '选择音轨';

  @override
  String get videoActionSetSpeed => '播放速度';

  @override
  String get videoActionABRepeat => 'A-B 循环播放';

  @override
  String get videoRepeatActionSetStart => '设置起点';

  @override
  String get videoRepeatActionSetEnd => '设置终点';

  @override
  String get viewerActionSettings => '设置';

  @override
  String get viewerActionLock => '锁定查看器';

  @override
  String get viewerActionUnlock => '解锁查看器';

  @override
  String get slideshowActionResume => '继续';

  @override
  String get slideshowActionShowInCollection => '在媒体集中显示';

  @override
  String get entryInfoActionEditDate => '编辑日期和时间';

  @override
  String get entryInfoActionEditLocation => '编辑位置';

  @override
  String get entryInfoActionEditTitleDescription => '编辑标题和描述';

  @override
  String get entryInfoActionEditRating => '修改评分';

  @override
  String get entryInfoActionEditTags => '编辑标签';

  @override
  String get entryInfoActionRemoveMetadata => '移除元数据';

  @override
  String get entryInfoActionExportMetadata => '导出元数据';

  @override
  String get entryInfoActionRemoveLocation => '移除位置';

  @override
  String get editorActionTransform => '转换';

  @override
  String get editorTransformCrop => '裁剪';

  @override
  String get editorTransformRotate => '旋转';

  @override
  String get cropAspectRatioFree => '自由';

  @override
  String get cropAspectRatioOriginal => '原始';

  @override
  String get cropAspectRatioSquare => '方形';

  @override
  String get filterAspectRatioLandscapeLabel => '横向';

  @override
  String get filterAspectRatioPortraitLabel => '纵向';

  @override
  String get filterBinLabel => '回收站';

  @override
  String get filterFavouriteLabel => '收藏夹';

  @override
  String get filterNoDateLabel => '未注明日期';

  @override
  String get filterNoAddressLabel => '无地址';

  @override
  String get filterLocatedLabel => '有定位';

  @override
  String get filterNoLocationLabel => '无定位';

  @override
  String get filterNoRatingLabel => '未评分';

  @override
  String get filterTaggedLabel => '有标签';

  @override
  String get filterNoTagLabel => '无标签';

  @override
  String get filterNoTitleLabel => '无标题';

  @override
  String get filterOnThisDayLabel => '选择日期';

  @override
  String get filterRecentlyAddedLabel => '最近添加';

  @override
  String get filterRatingRejectedLabel => '拒绝评分';

  @override
  String get filterTypeAnimatedLabel => '动图';

  @override
  String get filterTypeMotionPhotoLabel => '动态照片';

  @override
  String get filterTypePanoramaLabel => '全景图';

  @override
  String get filterTypeRawLabel => 'Raw';

  @override
  String get filterTypeSphericalVideoLabel => '360° 视频';

  @override
  String get filterTypeGeotiffLabel => 'GeoTIFF';

  @override
  String get filterMimeImageLabel => '图像';

  @override
  String get filterMimeVideoLabel => '视频';

  @override
  String get accessibilityAnimationsRemove => '禁用屏幕效果';

  @override
  String get accessibilityAnimationsKeep => '保留屏幕效果';

  @override
  String get albumTierNew => '新的';

  @override
  String get albumTierPinned => '钉选';

  @override
  String get albumTierSpecial => '普通';

  @override
  String get albumTierApps => '应用';

  @override
  String get albumTierVaults => '保险库';

  @override
  String get albumTierDynamic => '动态';

  @override
  String get albumTierRegular => '其他';

  @override
  String get coordinateFormatDms => 'DMS';

  @override
  String get coordinateFormatDdm => 'DDM';

  @override
  String get coordinateFormatDecimal => '十进制度';

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
  String get displayRefreshRatePreferHighest => '最高刷新率';

  @override
  String get displayRefreshRatePreferLowest => '最低刷新率';

  @override
  String get keepScreenOnNever => '从不';

  @override
  String get keepScreenOnVideoPlayback => '视频播放期间';

  @override
  String get keepScreenOnViewerOnly => '仅查看器页面';

  @override
  String get keepScreenOnAlways => '始终';

  @override
  String get lengthUnitPixel => '像素';

  @override
  String get lengthUnitPercent => '百分比';

  @override
  String get mapStyleGoogleNormal => 'Google 地图';

  @override
  String get mapStyleGoogleHybrid => 'Google 地图 (卫星图像)';

  @override
  String get mapStyleGoogleTerrain => 'Google 地图 (地形)';

  @override
  String get mapStyleOsmLiberty => 'OSM Liberty';

  @override
  String get mapStyleOpenTopoMap => 'OpenTopoMap';

  @override
  String get mapStyleOsmHot => 'Humanitarian OSM';

  @override
  String get mapStyleStamenWatercolor => 'Stamen Watercolor';

  @override
  String get maxBrightnessNever => '从不';

  @override
  String get maxBrightnessAlways => '始终';

  @override
  String get nameConflictStrategyRename => '重命名';

  @override
  String get nameConflictStrategyReplace => '替换';

  @override
  String get nameConflictStrategySkip => '跳过';

  @override
  String get overlayHistogramNone => '无';

  @override
  String get overlayHistogramRGB => 'RGB';

  @override
  String get overlayHistogramLuminance => '亮度';

  @override
  String get subtitlePositionTop => '顶部';

  @override
  String get subtitlePositionBottom => '底部';

  @override
  String get themeBrightnessLight => '浅色';

  @override
  String get themeBrightnessDark => '深色';

  @override
  String get themeBrightnessBlack => '黑色';

  @override
  String get unitSystemMetric => '公制';

  @override
  String get unitSystemImperial => '英制';

  @override
  String get vaultLockTypePattern => '图案';

  @override
  String get vaultLockTypePin => 'PIN';

  @override
  String get vaultLockTypePassword => '密码';

  @override
  String get settingsVideoEnablePip => '画中画';

  @override
  String get videoControlsPlayOutside => '用其他播放器打开';

  @override
  String get videoLoopModeNever => '从不';

  @override
  String get videoLoopModeShortOnly => '仅短视频';

  @override
  String get videoLoopModeAlways => '始终';

  @override
  String get videoPlaybackSkip => '跳过';

  @override
  String get videoPlaybackMuted => '静音播放';

  @override
  String get videoPlaybackWithSound => '有声播放';

  @override
  String get videoResumptionModeNever => '从不';

  @override
  String get videoResumptionModeAlways => '始终';

  @override
  String get viewerTransitionSlide => '滑动';

  @override
  String get viewerTransitionParallax => '视差滚动';

  @override
  String get viewerTransitionFade => '淡入淡出';

  @override
  String get viewerTransitionZoomIn => '放大';

  @override
  String get viewerTransitionNone => '无';

  @override
  String get wallpaperTargetHome => '主屏幕';

  @override
  String get wallpaperTargetLock => '锁屏界面';

  @override
  String get wallpaperTargetHomeLock => '主屏幕 + 锁屏界面';

  @override
  String get widgetDisplayedItemRandom => '随机';

  @override
  String get widgetDisplayedItemMostRecent => '最新';

  @override
  String get widgetOpenPageHome => '打开主页';

  @override
  String get widgetOpenPageCollection => '打开媒体集';

  @override
  String get widgetOpenPageViewer => '打开查看器';

  @override
  String get widgetTapUpdateWidget => '更新小工具';

  @override
  String get storageVolumeDescriptionFallbackPrimary => '内部存储';

  @override
  String get storageVolumeDescriptionFallbackNonPrimary => 'SD 卡';

  @override
  String get rootDirectoryDescription => '根目录';

  @override
  String otherDirectoryDescription(String name) {
    return '“$name” 目录';
  }

  @override
  String storageAccessDialogMessage(String directory, String volume) {
    return '请在下一屏幕中选择“$volume”的$directory，以授予本应用对其的访问权限';
  }

  @override
  String restrictedAccessDialogMessage(String directory, String volume) {
    return '本应用无权修改“$volume”的$directory中的文件\n\n请使用预装的文件管理器或图库应用将项目移至其他目录';
  }

  @override
  String notEnoughSpaceDialogMessage(String neededSize, String freeSize, String volume) {
    return '此操作需要“$volume”上具有 $neededSize 可用空间才能完成，实际仅剩 $freeSize';
  }

  @override
  String get missingSystemFilePickerDialogMessage => '系统文件选择器缺失或被禁用，请将其启用后再试';

  @override
  String unsupportedTypeDialogMessage(int count, String types) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '此操作不支持以下类型的项目: $types.',
    );
    return '$_temp0';
  }

  @override
  String get nameConflictDialogSingleSourceMessage => '目标文件夹中具有同名文件';

  @override
  String get nameConflictDialogMultipleSourceMessage => '存在同名文件';

  @override
  String get addShortcutDialogLabel => '快捷方式标签';

  @override
  String get addShortcutButtonLabel => '添加';

  @override
  String get noMatchingAppDialogMessage => '无对应的处理程序';

  @override
  String binEntriesConfirmationDialogMessage(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '将这 $countString 项移至回收站？',
      one: '将此项移至回收站？',
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
      other: '删除这 $countString 项？',
      one: '删除此项？',
    );
    return '$_temp0';
  }

  @override
  String get moveUndatedConfirmationDialogMessage => '继续之前保存项目日期？';

  @override
  String get moveUndatedConfirmationDialogSetDate => '保存日期';

  @override
  String videoResumeDialogMessage(String time) {
    return '想接着在 $time 继续播放吗？';
  }

  @override
  String get videoStartOverButtonLabel => '从头播放';

  @override
  String get videoResumeButtonLabel => '继续';

  @override
  String get setCoverDialogLatest => '最新项';

  @override
  String get setCoverDialogAuto => '自动';

  @override
  String get setCoverDialogCustom => '自定义';

  @override
  String get hideFilterConfirmationDialogMessage => '匹配的照片和视频将从收藏中隐藏，你可以通过“隐私”设置中再次显示它们\n\n确定要将其隐藏吗？';

  @override
  String get newAlbumDialogTitle => '新相册';

  @override
  String get newAlbumDialogNameLabel => '相册名称';

  @override
  String get newAlbumDialogAlbumAlreadyExistsHelper => '相册已存在';

  @override
  String get newAlbumDialogNameLabelAlreadyExistsHelper => '目录已存在';

  @override
  String get newAlbumDialogStorageLabel => '存储：';

  @override
  String get newDynamicAlbumDialogTitle => '新动态专辑';

  @override
  String get dynamicAlbumAlreadyExists => '动态专辑已存在';

  @override
  String get newVaultWarningDialogMessage => '保险库中的项目仅供此应用使用，其他应用不可用。\n\n如果您卸载此应用或清除此应用数据，您将丢失所有这些项目。';

  @override
  String get newVaultDialogTitle => '新保险库';

  @override
  String get configureVaultDialogTitle => '设置保险库';

  @override
  String get vaultDialogLockModeWhenScreenOff => '屏幕关闭时锁定';

  @override
  String get vaultDialogLockTypeLabel => '锁定类型';

  @override
  String get patternDialogEnter => '输入图形';

  @override
  String get patternDialogConfirm => '确认图案';

  @override
  String get pinDialogEnter => '输入PIN';

  @override
  String get pinDialogConfirm => '确认PIN';

  @override
  String get passwordDialogEnter => '输入密码';

  @override
  String get passwordDialogConfirm => '确认密码';

  @override
  String get authenticateToConfigureVault => '验证以设置保险库';

  @override
  String get authenticateToUnlockVault => '验证以解锁保险库';

  @override
  String get vaultBinUsageDialogMessage => '有些保险库正在使用资源回收站。';

  @override
  String get renameAlbumDialogLabel => '新名称';

  @override
  String get renameAlbumDialogLabelAlreadyExistsHelper => '目录已存在';

  @override
  String get renameEntrySetPageTitle => '重命名';

  @override
  String get renameEntrySetPagePatternFieldLabel => '命名模式';

  @override
  String get renameEntrySetPageInsertTooltip => '插入字段';

  @override
  String get renameEntrySetPagePreviewSectionTitle => '预览';

  @override
  String get renameProcessorCounter => '计数器';

  @override
  String get renameProcessorHash => '哈希';

  @override
  String get renameProcessorName => '名称';

  @override
  String deleteSingleAlbumConfirmationDialogMessage(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '删除此相册及其中的 $countString 个项目？',
      one: '删除此相册及其中的一个项目？',
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
      other: '删除这些相册及其中的 $countString 个项目？',
      one: '删除这些相册及其中的一个项目？',
    );
    return '$_temp0';
  }

  @override
  String get exportEntryDialogFormat => '格式：';

  @override
  String get exportEntryDialogWidth => '宽度';

  @override
  String get exportEntryDialogHeight => '高度';

  @override
  String get exportEntryDialogQuality => '画质';

  @override
  String get exportEntryDialogWriteMetadata => '写入元数据';

  @override
  String get renameEntryDialogLabel => '新名称';

  @override
  String get editEntryDialogCopyFromItem => '复制自其他项目';

  @override
  String get editEntryDialogTargetFieldsHeader => '待修改的字段';

  @override
  String get editEntryDateDialogTitle => '日期和时间';

  @override
  String get editEntryDateDialogSetCustom => '设置自定义日期';

  @override
  String get editEntryDateDialogCopyField => '复制自其他日期';

  @override
  String get editEntryDateDialogExtractFromTitle => '从标题提取';

  @override
  String get editEntryDateDialogShift => '转移';

  @override
  String get editEntryDateDialogSourceFileModifiedDate => '文件修改日期';

  @override
  String get durationDialogHours => '时';

  @override
  String get durationDialogMinutes => '分';

  @override
  String get durationDialogSeconds => '秒';

  @override
  String get editEntryLocationDialogTitle => '位置';

  @override
  String get editEntryLocationDialogSetCustom => '设置自定义位置';

  @override
  String get editEntryLocationDialogChooseOnMap => '从地图上选择';

  @override
  String get editEntryLocationDialogImportGpx => '导入 GPX';

  @override
  String get editEntryLocationDialogLatitude => '纬度';

  @override
  String get editEntryLocationDialogLongitude => '经度';

  @override
  String get editEntryLocationDialogTimeShift => '时间时移';

  @override
  String get locationPickerUseThisLocationButton => '使用此位置';

  @override
  String get editEntryRatingDialogTitle => '评分';

  @override
  String get removeEntryMetadataDialogTitle => '元数据移除工具';

  @override
  String get removeEntryMetadataDialogAll => '全部';

  @override
  String get removeEntryMetadataDialogMore => '更多';

  @override
  String get removeEntryMetadataMotionPhotoXmpWarningDialogMessage => '播放动态照片中的视频需要 XMP\n\n确定要删除它吗？';

  @override
  String get videoSpeedDialogLabel => '播放速度';

  @override
  String get videoStreamSelectionDialogVideo => '视频';

  @override
  String get videoStreamSelectionDialogAudio => '音频';

  @override
  String get videoStreamSelectionDialogText => '字幕';

  @override
  String get videoStreamSelectionDialogOff => '关';

  @override
  String get videoStreamSelectionDialogTrack => '音轨';

  @override
  String get videoStreamSelectionDialogNoSelection => '无其他音轨';

  @override
  String get genericSuccessFeedback => '完成！';

  @override
  String get genericFailureFeedback => '失败';

  @override
  String get genericDangerWarningDialogMessage => '你确定吗？';

  @override
  String get tooManyItemsErrorDialogMessage => '用较少的项目重试。';

  @override
  String get menuActionConfigureView => '查看';

  @override
  String get menuActionSelect => '选择';

  @override
  String get menuActionSelectAll => '全选';

  @override
  String get menuActionSelectNone => '全不选';

  @override
  String get menuActionMap => '地图';

  @override
  String get menuActionSlideshow => '幻灯片';

  @override
  String get menuActionStats => '统计';

  @override
  String get viewDialogSortSectionTitle => '排序';

  @override
  String get viewDialogGroupSectionTitle => '分组';

  @override
  String get viewDialogLayoutSectionTitle => '布局';

  @override
  String get viewDialogReverseSortOrder => '反向排序';

  @override
  String get tileLayoutMosaic => '马赛克';

  @override
  String get tileLayoutGrid => '网格';

  @override
  String get tileLayoutList => '列表';

  @override
  String get castDialogTitle => '投屏设备';

  @override
  String get coverDialogTabCover => '封面';

  @override
  String get coverDialogTabApp => '应用';

  @override
  String get coverDialogTabColor => '颜色';

  @override
  String get appPickDialogTitle => '选择应用';

  @override
  String get appPickDialogNone => '无';

  @override
  String get aboutPageTitle => '关于';

  @override
  String get aboutLinkLicense => '许可协议';

  @override
  String get aboutLinkPolicy => '隐私政策';

  @override
  String get aboutBugSectionTitle => '报告错误';

  @override
  String get aboutBugSaveLogInstruction => '将应用日志保存到文件';

  @override
  String get aboutBugCopyInfoInstruction => '复制系统信息';

  @override
  String get aboutBugCopyInfoButton => '复制';

  @override
  String get aboutBugReportInstruction => '在 GitHub 上报告日志和系统信息';

  @override
  String get aboutBugReportButton => '报告';

  @override
  String get aboutDataUsageSectionTitle => '数据使用量';

  @override
  String get aboutDataUsageData => '数据';

  @override
  String get aboutDataUsageCache => '缓存';

  @override
  String get aboutDataUsageDatabase => '数据库';

  @override
  String get aboutDataUsageMisc => '其他';

  @override
  String get aboutDataUsageInternal => '内部存储';

  @override
  String get aboutDataUsageExternal => '外部存储';

  @override
  String get aboutDataUsageClearCache => '清理缓存';

  @override
  String get aboutCreditsSectionTitle => '鸣谢';

  @override
  String get aboutCreditsWorldAtlas1 => '本应用使用的 TopoJSON 文件来自';

  @override
  String get aboutCreditsWorldAtlas2 => '符合 ISC 许可协议';

  @override
  String get aboutTranslatorsSectionTitle => '翻译人员';

  @override
  String get aboutLicensesSectionTitle => '开源许可协议';

  @override
  String get aboutLicensesBanner => '本应用使用以下开源软件包和库。';

  @override
  String get aboutLicensesAndroidLibrariesSectionTitle => 'Android 库';

  @override
  String get aboutLicensesFlutterPluginsSectionTitle => 'Flutter 插件';

  @override
  String get aboutLicensesFlutterPackagesSectionTitle => 'Flutter 软件包';

  @override
  String get aboutLicensesDartPackagesSectionTitle => 'Dart 软件包';

  @override
  String get aboutLicensesShowAllButtonLabel => '显示所有许可协议';

  @override
  String get policyPageTitle => '隐私政策';

  @override
  String get collectionPageTitle => '媒体集';

  @override
  String get collectionPickPageTitle => '挑选';

  @override
  String get collectionSelectPageTitle => '选择项目';

  @override
  String get collectionActionShowTitleSearch => '显示标题过滤器';

  @override
  String get collectionActionHideTitleSearch => '隐藏标题过滤器';

  @override
  String get collectionActionAddDynamicAlbum => '添加动态专辑';

  @override
  String get collectionActionAddShortcut => '添加快捷方式';

  @override
  String get collectionActionSetHome => '设置为首页';

  @override
  String get collectionActionEmptyBin => '清空回收站';

  @override
  String get collectionActionCopy => '复制到相册';

  @override
  String get collectionActionMove => '移至相册';

  @override
  String get collectionActionRescan => '重新扫描';

  @override
  String get collectionActionEdit => '编辑';

  @override
  String get collectionSearchTitlesHintText => '搜索标题';

  @override
  String get collectionGroupAlbum => '按相册';

  @override
  String get collectionGroupMonth => '按月份';

  @override
  String get collectionGroupDay => '按天';

  @override
  String get collectionGroupNone => '不分组';

  @override
  String get sectionUnknown => '未知';

  @override
  String get dateToday => '今天';

  @override
  String get dateYesterday => '昨天';

  @override
  String get dateThisMonth => '本月';

  @override
  String collectionDeleteFailureFeedback(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString 项删除失败',
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
      other: '$countString 项复制失败',
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
      other: '$countString 项移动失败',
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
      other: '$countString 项重命名失败',
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
      other: '$countString 项编辑失败',
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
      other: '$countString 页导出失败',
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
      other: '已复制 $countString 项',
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
      other: '已移动 $countString 项',
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
      other: '已重命名 $countString 项',
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
      other: '已编辑 $countString 项',
    );
    return '$_temp0';
  }

  @override
  String get collectionEmptyFavourites => '无收藏项';

  @override
  String get collectionEmptyVideos => '无视频';

  @override
  String get collectionEmptyImages => '无图像';

  @override
  String get collectionEmptyGrantAccessButtonLabel => '授予访问权限';

  @override
  String get collectionSelectSectionTooltip => '选择部分';

  @override
  String get collectionDeselectSectionTooltip => '取消选择部分';

  @override
  String get drawerAboutButton => '关于';

  @override
  String get drawerSettingsButton => '设置';

  @override
  String get drawerCollectionAll => '所有媒体集';

  @override
  String get drawerCollectionFavourites => '收藏夹';

  @override
  String get drawerCollectionImages => '图像';

  @override
  String get drawerCollectionVideos => '视频';

  @override
  String get drawerCollectionAnimated => '动图';

  @override
  String get drawerCollectionMotionPhotos => '动态照片';

  @override
  String get drawerCollectionPanoramas => '全景图';

  @override
  String get drawerCollectionRaws => 'Raw 照片';

  @override
  String get drawerCollectionSphericalVideos => '360° 视频';

  @override
  String get drawerAlbumPage => '相册';

  @override
  String get drawerCountryPage => '地区';

  @override
  String get drawerPlacePage => '地点';

  @override
  String get drawerTagPage => '标签';

  @override
  String get sortByDate => '按日期';

  @override
  String get sortByName => '按名称';

  @override
  String get sortByItemCount => '按数量';

  @override
  String get sortBySize => '按大小';

  @override
  String get sortByAlbumFileName => '按相册和文件名';

  @override
  String get sortByRating => '按评分';

  @override
  String get sortByDuration => '按时长';

  @override
  String get sortOrderNewestFirst => '降序';

  @override
  String get sortOrderOldestFirst => '升序';

  @override
  String get sortOrderAtoZ => 'A — Z';

  @override
  String get sortOrderZtoA => 'Z — A';

  @override
  String get sortOrderHighestFirst => '由高到低';

  @override
  String get sortOrderLowestFirst => '由低到高';

  @override
  String get sortOrderLargestFirst => '由大到小';

  @override
  String get sortOrderSmallestFirst => '由小到大';

  @override
  String get sortOrderShortestFirst => '先短后长';

  @override
  String get sortOrderLongestFirst => '先长后短';

  @override
  String get albumGroupTier => '按层级';

  @override
  String get albumGroupType => '按类型';

  @override
  String get albumGroupVolume => '按存储卷';

  @override
  String get albumGroupNone => '不分组';

  @override
  String get albumMimeTypeMixed => '混合';

  @override
  String get albumPickPageTitleCopy => '复制到相册';

  @override
  String get albumPickPageTitleExport => '导出到相册';

  @override
  String get albumPickPageTitleMove => '移至相册';

  @override
  String get albumPickPageTitlePick => '选择相册';

  @override
  String get albumCamera => '相机';

  @override
  String get albumDownload => '下载';

  @override
  String get albumScreenshots => '截图';

  @override
  String get albumScreenRecordings => '屏幕录制';

  @override
  String get albumVideoCaptures => '视频捕获';

  @override
  String get albumPageTitle => '相册';

  @override
  String get albumEmpty => '无相册';

  @override
  String get createAlbumButtonLabel => '创建';

  @override
  String get newFilterBanner => '新的';

  @override
  String get countryPageTitle => '地区';

  @override
  String get countryEmpty => '无地区';

  @override
  String get statePageTitle => '区域';

  @override
  String get stateEmpty => '没有区域';

  @override
  String get placePageTitle => '地点';

  @override
  String get placeEmpty => '没有地点';

  @override
  String get tagPageTitle => '标签';

  @override
  String get tagEmpty => '无标签';

  @override
  String get binPageTitle => '回收站';

  @override
  String get explorerPageTitle => '资源管理器';

  @override
  String get explorerActionSelectStorageVolume => '选择存储器';

  @override
  String get selectStorageVolumeDialogTitle => '选择存储器';

  @override
  String get searchCollectionFieldHint => '搜索媒体集';

  @override
  String get searchRecentSectionTitle => '最近';

  @override
  String get searchDateSectionTitle => '日期';

  @override
  String get searchAlbumsSectionTitle => '相册';

  @override
  String get searchCountriesSectionTitle => '地区';

  @override
  String get searchStatesSectionTitle => '区域';

  @override
  String get searchPlacesSectionTitle => '地点';

  @override
  String get searchTagsSectionTitle => '标签';

  @override
  String get searchRatingSectionTitle => '评分';

  @override
  String get searchMetadataSectionTitle => '元数据';

  @override
  String get settingsPageTitle => '设置';

  @override
  String get settingsSystemDefault => '系统默认';

  @override
  String get settingsDefault => '默认';

  @override
  String get settingsDisabled => '禁用';

  @override
  String get settingsAskEverytime => '每次都询问';

  @override
  String get settingsModificationWarningDialogMessage => '其他设置将被修改。';

  @override
  String get settingsSearchFieldLabel => '搜索设置';

  @override
  String get settingsSearchEmpty => '无匹配设置项';

  @override
  String get settingsActionExport => '导出';

  @override
  String get settingsActionExportDialogTitle => '导出';

  @override
  String get settingsActionImport => '导入';

  @override
  String get settingsActionImportDialogTitle => '导入';

  @override
  String get appExportCovers => '封面';

  @override
  String get appExportDynamicAlbums => '动态专辑';

  @override
  String get appExportFavourites => '收藏夹';

  @override
  String get appExportSettings => '设置';

  @override
  String get settingsNavigationSectionTitle => '导航';

  @override
  String get settingsHomeTile => '主页';

  @override
  String get settingsHomeDialogTitle => '主页';

  @override
  String get setHomeCustom => '自定义';

  @override
  String get settingsShowBottomNavigationBar => '显示底部导航栏';

  @override
  String get settingsKeepScreenOnTile => '保持亮屏';

  @override
  String get settingsKeepScreenOnDialogTitle => '保持亮屏';

  @override
  String get settingsDoubleBackExit => '按两次返回键退出';

  @override
  String get settingsConfirmationTile => '确认对话框';

  @override
  String get settingsConfirmationDialogTitle => '确认对话框';

  @override
  String get settingsConfirmationBeforeDeleteItems => '永久删除项目之前询问';

  @override
  String get settingsConfirmationBeforeMoveToBinItems => '移至回收站之前询问';

  @override
  String get settingsConfirmationBeforeMoveUndatedItems => '移动未注明日期的项目之前询问';

  @override
  String get settingsConfirmationAfterMoveToBinItems => '移至回收站后显示消息';

  @override
  String get settingsConfirmationVaultDataLoss => '显示保险库数据丢失警报';

  @override
  String get settingsNavigationDrawerTile => '导航栏菜单';

  @override
  String get settingsNavigationDrawerEditorPageTitle => '导航栏菜单';

  @override
  String get settingsNavigationDrawerBanner => '长按移动和重新排序菜单项';

  @override
  String get settingsNavigationDrawerTabTypes => '类型';

  @override
  String get settingsNavigationDrawerTabAlbums => '相册';

  @override
  String get settingsNavigationDrawerTabPages => '页面';

  @override
  String get settingsNavigationDrawerAddAlbum => '添加相册';

  @override
  String get settingsThumbnailSectionTitle => '缩略图';

  @override
  String get settingsThumbnailOverlayTile => '叠加层';

  @override
  String get settingsThumbnailOverlayPageTitle => '叠加层';

  @override
  String get settingsThumbnailShowHdrIcon => '显示 HDR 图标';

  @override
  String get settingsThumbnailShowFavouriteIcon => '显示收藏图标';

  @override
  String get settingsThumbnailShowTagIcon => '显示标签图标';

  @override
  String get settingsThumbnailShowLocationIcon => '显示位置图标';

  @override
  String get settingsThumbnailShowMotionPhotoIcon => '显示动态照片图标';

  @override
  String get settingsThumbnailShowRating => '显示评分';

  @override
  String get settingsThumbnailShowRawIcon => '显示 raw 图标';

  @override
  String get settingsThumbnailShowVideoDuration => '显示视频时长';

  @override
  String get settingsCollectionQuickActionsTile => '快速操作';

  @override
  String get settingsCollectionQuickActionEditorPageTitle => '快速操作';

  @override
  String get settingsCollectionQuickActionTabBrowsing => '浏览';

  @override
  String get settingsCollectionQuickActionTabSelecting => '选择';

  @override
  String get settingsCollectionBrowsingQuickActionEditorBanner => '按住并拖拽可移动按钮并选择浏览项目时显示的操作';

  @override
  String get settingsCollectionSelectionQuickActionEditorBanner => '按住并拖拽可移动按钮并选择选择项目时显示的操作';

  @override
  String get settingsCollectionBurstPatternsTile => '连拍模式';

  @override
  String get settingsCollectionBurstPatternsNone => '无';

  @override
  String get settingsViewerSectionTitle => '查看器';

  @override
  String get settingsViewerGestureSideTapNext => '轻触屏幕边缘显示上/下一个项目';

  @override
  String get settingsViewerUseCutout => '使用刘海/挖孔区域';

  @override
  String get settingsViewerMaximumBrightness => '最大亮度';

  @override
  String get settingsMotionPhotoAutoPlay => '自动播放动态照片';

  @override
  String get settingsImageBackground => '图像背景';

  @override
  String get settingsViewerQuickActionsTile => '快速操作';

  @override
  String get settingsViewerQuickActionEditorPageTitle => '快速操作';

  @override
  String get settingsViewerQuickActionEditorBanner => '按住并拖拽可移动按钮并选择查看器中显示的操作';

  @override
  String get settingsViewerQuickActionEditorDisplayedButtonsSectionTitle => '显示的按钮';

  @override
  String get settingsViewerQuickActionEditorAvailableButtonsSectionTitle => '可用按钮';

  @override
  String get settingsViewerQuickActionEmpty => '无按钮';

  @override
  String get settingsViewerOverlayTile => '叠加层';

  @override
  String get settingsViewerOverlayPageTitle => '叠加层';

  @override
  String get settingsViewerShowOverlayOnOpening => '打开时显示';

  @override
  String get settingsViewerShowHistogram => '显示直方图';

  @override
  String get settingsViewerShowMinimap => '显示小地图';

  @override
  String get settingsViewerShowInformation => '显示信息';

  @override
  String get settingsViewerShowInformationSubtitle => '显示标题、日期、位置等';

  @override
  String get settingsViewerShowRatingTags => '显示评分和标签';

  @override
  String get settingsViewerShowShootingDetails => '显示拍摄详情';

  @override
  String get settingsViewerShowDescription => '显示描述';

  @override
  String get settingsViewerShowOverlayThumbnails => '显示缩略图';

  @override
  String get settingsViewerEnableOverlayBlurEffect => '模糊特效';

  @override
  String get settingsViewerSlideshowTile => '幻灯片';

  @override
  String get settingsViewerSlideshowPageTitle => '幻灯片';

  @override
  String get settingsSlideshowRepeat => '重复';

  @override
  String get settingsSlideshowShuffle => '随机播放';

  @override
  String get settingsSlideshowFillScreen => '填充屏幕';

  @override
  String get settingsSlideshowAnimatedZoomEffect => '动画缩放效果';

  @override
  String get settingsSlideshowTransitionTile => '过渡动画';

  @override
  String get settingsSlideshowIntervalTile => '时间间隔';

  @override
  String get settingsSlideshowVideoPlaybackTile => '视频播放';

  @override
  String get settingsSlideshowVideoPlaybackDialogTitle => '视频播放';

  @override
  String get settingsVideoPageTitle => '视频设置';

  @override
  String get settingsVideoSectionTitle => '视频';

  @override
  String get settingsVideoShowVideos => '显示视频';

  @override
  String get settingsVideoPlaybackTile => '播放';

  @override
  String get settingsVideoPlaybackPageTitle => '播放';

  @override
  String get settingsVideoEnableHardwareAcceleration => '硬件加速';

  @override
  String get settingsVideoAutoPlay => '自动播放';

  @override
  String get settingsVideoLoopModeTile => '循环模式';

  @override
  String get settingsVideoLoopModeDialogTitle => '循环模式';

  @override
  String get settingsVideoResumptionModeTile => '恢复播放';

  @override
  String get settingsVideoResumptionModeDialogTitle => '恢复播放';

  @override
  String get settingsVideoBackgroundMode => '后台模式';

  @override
  String get settingsVideoBackgroundModeDialogTitle => '后台模式';

  @override
  String get settingsVideoControlsTile => '控件';

  @override
  String get settingsVideoControlsPageTitle => '控件';

  @override
  String get settingsVideoButtonsTile => '按钮';

  @override
  String get settingsVideoGestureDoubleTapTogglePlay => '双击播放/暂停';

  @override
  String get settingsVideoGestureSideDoubleTapSeek => '双击屏幕边缘步进/步退';

  @override
  String get settingsVideoGestureVerticalDragBrightnessVolume => '上下滑动屏幕调整亮度或音量';

  @override
  String get settingsSubtitleThemeTile => '字幕';

  @override
  String get settingsSubtitleThemePageTitle => '字幕';

  @override
  String get settingsSubtitleThemeSample => '这是一个字幕示例。';

  @override
  String get settingsSubtitleThemeTextAlignmentTile => '对齐方式';

  @override
  String get settingsSubtitleThemeTextAlignmentDialogTitle => '对齐方式';

  @override
  String get settingsSubtitleThemeTextPositionTile => '文本位置';

  @override
  String get settingsSubtitleThemeTextPositionDialogTitle => '文本位置';

  @override
  String get settingsSubtitleThemeTextSize => '文本大小';

  @override
  String get settingsSubtitleThemeShowOutline => '显示轮廓和阴影';

  @override
  String get settingsSubtitleThemeTextColor => '文本颜色';

  @override
  String get settingsSubtitleThemeTextOpacity => '文本透明度';

  @override
  String get settingsSubtitleThemeBackgroundColor => '背景色';

  @override
  String get settingsSubtitleThemeBackgroundOpacity => '背景透明度';

  @override
  String get settingsSubtitleThemeTextAlignmentLeft => '居左';

  @override
  String get settingsSubtitleThemeTextAlignmentCenter => '居中';

  @override
  String get settingsSubtitleThemeTextAlignmentRight => '居右';

  @override
  String get settingsPrivacySectionTitle => '隐私';

  @override
  String get settingsAllowInstalledAppAccess => '允许访问应用清单';

  @override
  String get settingsAllowInstalledAppAccessSubtitle => '用于改善相册显示结果';

  @override
  String get settingsAllowErrorReporting => '允许匿名错误报告';

  @override
  String get settingsSaveSearchHistory => '保存搜索历史记录';

  @override
  String get settingsEnableBin => '启用回收站';

  @override
  String get settingsEnableBinSubtitle => '将删除项保留 30 天';

  @override
  String get settingsDisablingBinWarningDialogMessage => '回收站中的项目将被永久删除。';

  @override
  String get settingsAllowMediaManagement => '允许媒体管理';

  @override
  String get settingsHiddenItemsTile => '隐藏项';

  @override
  String get settingsHiddenItemsPageTitle => '隐藏项';

  @override
  String get settingsHiddenFiltersBanner => '匹配隐藏过滤器的照片和视频将不会出现在你的媒体集中';

  @override
  String get settingsHiddenFiltersEmpty => '无隐藏过滤器';

  @override
  String get settingsStorageAccessTile => '存储访问';

  @override
  String get settingsStorageAccessPageTitle => '存储访问';

  @override
  String get settingsStorageAccessBanner => '某些目录需要具有明确的访问权限才能修改其中的文件，你可以在此处查看你之前已授予访问权限的目录';

  @override
  String get settingsStorageAccessEmpty => '尚未授予访问权限';

  @override
  String get settingsStorageAccessRevokeTooltip => '撤消';

  @override
  String get settingsAccessibilitySectionTitle => '无障碍';

  @override
  String get settingsRemoveAnimationsTile => '移除动画';

  @override
  String get settingsRemoveAnimationsDialogTitle => '移除动画';

  @override
  String get settingsTimeToTakeActionTile => '生效时间';

  @override
  String get settingsAccessibilityShowPinchGestureAlternatives => '显示触屏手势可选方案';

  @override
  String get settingsDisplaySectionTitle => '显示';

  @override
  String get settingsThemeBrightnessTile => '主题';

  @override
  String get settingsThemeBrightnessDialogTitle => '主题';

  @override
  String get settingsThemeColorHighlights => '色彩强调';

  @override
  String get settingsThemeEnableDynamicColor => '动态色彩';

  @override
  String get settingsDisplayRefreshRateModeTile => '显示刷新率';

  @override
  String get settingsDisplayRefreshRateModeDialogTitle => '刷新率';

  @override
  String get settingsDisplayUseTvInterface => 'Android TV 界面';

  @override
  String get settingsLanguageSectionTitle => '语言和格式';

  @override
  String get settingsLanguageTile => '界面语言';

  @override
  String get settingsLanguagePageTitle => '界面语言';

  @override
  String get settingsCoordinateFormatTile => '坐标格式';

  @override
  String get settingsCoordinateFormatDialogTitle => '坐标格式';

  @override
  String get settingsUnitSystemTile => '单位';

  @override
  String get settingsUnitSystemDialogTitle => '单位';

  @override
  String get settingsForceWesternArabicNumeralsTile => '强制使用阿拉伯数字';

  @override
  String get settingsScreenSaverPageTitle => '屏保';

  @override
  String get settingsWidgetPageTitle => '相框';

  @override
  String get settingsWidgetShowOutline => '轮廓';

  @override
  String get settingsWidgetOpenPage => '轻触小部件时';

  @override
  String get settingsWidgetDisplayedItem => '显示的内容';

  @override
  String get settingsCollectionTile => '媒体集';

  @override
  String get statsPageTitle => '统计';

  @override
  String statsWithGps(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString 项带位置信息',
    );
    return '$_temp0';
  }

  @override
  String get statsTopCountriesSectionTitle => '热门地区';

  @override
  String get statsTopStatesSectionTitle => '最多项的区域';

  @override
  String get statsTopPlacesSectionTitle => '热门地点';

  @override
  String get statsTopTagsSectionTitle => '热门标签';

  @override
  String get statsTopAlbumsSectionTitle => '热门相册';

  @override
  String get viewerOpenPanoramaButtonLabel => '打开全景';

  @override
  String get viewerSetWallpaperButtonLabel => '设置壁纸';

  @override
  String get viewerErrorUnknown => '糟糕！';

  @override
  String get viewerErrorDoesNotExist => '该文件不存在';

  @override
  String get viewerInfoPageTitle => '信息';

  @override
  String get viewerInfoBackToViewerTooltip => '返回查看器';

  @override
  String get viewerInfoUnknown => '未知';

  @override
  String get viewerInfoLabelDescription => '描述';

  @override
  String get viewerInfoLabelTitle => '标题';

  @override
  String get viewerInfoLabelDate => '日期';

  @override
  String get viewerInfoLabelResolution => '分辨率';

  @override
  String get viewerInfoLabelSize => '大小';

  @override
  String get viewerInfoLabelUri => 'URI';

  @override
  String get viewerInfoLabelPath => '路径';

  @override
  String get viewerInfoLabelDuration => '时长';

  @override
  String get viewerInfoLabelOwner => '所有者';

  @override
  String get viewerInfoLabelCoordinates => '坐标';

  @override
  String get viewerInfoLabelAddress => '地址';

  @override
  String get mapStyleDialogTitle => '地图样式';

  @override
  String get mapStyleTooltip => '选择地图样式';

  @override
  String get mapZoomInTooltip => '放大';

  @override
  String get mapZoomOutTooltip => '缩小';

  @override
  String get mapPointNorthUpTooltip => '上北下南';

  @override
  String get mapAttributionOsmData => '地图数据由 © [OpenStreetMap](https://www.openstreetmap.org/copyright) 贡献';

  @override
  String get mapAttributionOsmLiberty => '绘制于 [OpenMapTiles](https://www.openmaptiles.org/), [CC BY](http://creativecommons.org/licenses/by/4.0) • 主办方 [OSM Americana](https://tile.ourmap.us)';

  @override
  String get mapAttributionOpenTopoMap => '[SRTM](https://www.earthdata.nasa.gov/sensors/srtm) | 图块由 [OpenTopoMap](https://opentopomap.org/)提供，[CC BY-SA](https://creativecommons.org/licenses/by-sa/3.0/)';

  @override
  String get mapAttributionOsmHot => '绘制于 [HOT](https://www.hotosm.org/) • 主办方 [OSM France](https://openstreetmap.fr/)';

  @override
  String get mapAttributionStamen => '绘制于 [Stamen Design](https://stamen.com), [CC BY 3.0](https://creativecommons.org/licenses/by/3.0)';

  @override
  String get openMapPageTooltip => '在地图页面上查看';

  @override
  String get mapEmptyRegion => '该地区没有图片';

  @override
  String get viewerInfoOpenEmbeddedFailureFeedback => '提取嵌入数据失败';

  @override
  String get viewerInfoOpenLinkText => '打开';

  @override
  String get viewerInfoViewXmlLinkText => '查看 XML';

  @override
  String get viewerInfoSearchFieldLabel => '搜索元数据';

  @override
  String get viewerInfoSearchEmpty => '无匹配键';

  @override
  String get viewerInfoSearchSuggestionDate => '日期和时间';

  @override
  String get viewerInfoSearchSuggestionDescription => '描述';

  @override
  String get viewerInfoSearchSuggestionDimensions => '尺寸';

  @override
  String get viewerInfoSearchSuggestionResolution => '分辨率';

  @override
  String get viewerInfoSearchSuggestionRights => '所有权';

  @override
  String get wallpaperUseScrollEffect => '在主屏幕上使用滚动效果';

  @override
  String get tagEditorPageTitle => '编辑标签';

  @override
  String get tagEditorPageNewTagFieldLabel => '新标签';

  @override
  String get tagEditorPageAddTagTooltip => '添加标签';

  @override
  String get tagEditorSectionRecent => '最近';

  @override
  String get tagEditorSectionPlaceholders => '占位符';

  @override
  String get tagEditorDiscardDialogMessage => '是否放弃更改？';

  @override
  String get tagPlaceholderCountry => '国家';

  @override
  String get tagPlaceholderState => '区域';

  @override
  String get tagPlaceholderPlace => '地方';

  @override
  String get panoramaEnableSensorControl => '启用传感器控制';

  @override
  String get panoramaDisableSensorControl => '禁用传感器控制';

  @override
  String get sourceViewerPageTitle => '源码';

  @override
  String get filePickerShowHiddenFiles => '显示隐藏文件';

  @override
  String get filePickerDoNotShowHiddenFiles => '不显示隐藏文件';

  @override
  String get filePickerOpenFrom => '打开自';

  @override
  String get filePickerNoItems => '无项目';

  @override
  String get filePickerUseThisFolder => '使用此文件夹';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant(): super('zh_Hant');

  @override
  String get appName => 'Aves';

  @override
  String get welcomeMessage => '歡迎使用 Aves';

  @override
  String get welcomeOptional => '可選擇的';

  @override
  String get welcomeTermsToggle => '我同意這些使用條款及狀況';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 項',
    );
    return '$_temp0';
  }

  @override
  String columnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 列',
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
      other: '$countString 秒',
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
      other: '$countString 分',
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
      other: '$countString 天',
    );
    return '$_temp0';
  }

  @override
  String focalLength(String length) {
    return '$length mm';
  }

  @override
  String get applyButtonLabel => '套用';

  @override
  String get deleteButtonLabel => '刪除';

  @override
  String get nextButtonLabel => '下一步';

  @override
  String get showButtonLabel => '顯示';

  @override
  String get hideButtonLabel => '隱藏';

  @override
  String get continueButtonLabel => '繼續';

  @override
  String get saveCopyButtonLabel => '保存副本';

  @override
  String get applyTooltip => '應用';

  @override
  String get cancelTooltip => '取消';

  @override
  String get changeTooltip => '更改';

  @override
  String get clearTooltip => '清除';

  @override
  String get previousTooltip => '上一個';

  @override
  String get nextTooltip => '下一個';

  @override
  String get showTooltip => '顯示';

  @override
  String get hideTooltip => '隱藏';

  @override
  String get actionRemove => '刪除';

  @override
  String get resetTooltip => '重置';

  @override
  String get saveTooltip => '儲存';

  @override
  String get stopTooltip => '停止';

  @override
  String get pickTooltip => '挑選';

  @override
  String get doubleBackExitMessage => '再按一次 “上一頁” 離開.';

  @override
  String get doNotAskAgain => '不再詢問';

  @override
  String get sourceStateLoading => '載入中';

  @override
  String get sourceStateCataloguing => '正在整理目錄中';

  @override
  String get sourceStateLocatingCountries => '正在定位國家';

  @override
  String get sourceStateLocatingPlaces => '正在定位地點';

  @override
  String get chipActionDelete => '刪除';

  @override
  String get chipActionRemove => '移除';

  @override
  String get chipActionShowCollection => '在收藏品中顯示';

  @override
  String get chipActionGoToAlbumPage => '在相簿中顯示';

  @override
  String get chipActionGoToCountryPage => '在國家中顯示';

  @override
  String get chipActionGoToPlacePage => '在地點中顯示';

  @override
  String get chipActionGoToTagPage => '在標籤中顯示';

  @override
  String get chipActionGoToExplorerPage => '在檔案總管裡顯示';

  @override
  String get chipActionDecompose => '分割';

  @override
  String get chipActionFilterOut => '過濾掉';

  @override
  String get chipActionFilterIn => '篩選';

  @override
  String get chipActionHide => '隱藏';

  @override
  String get chipActionLock => '鎖定';

  @override
  String get chipActionPin => '置頂';

  @override
  String get chipActionUnpin => '取消置頂';

  @override
  String get chipActionRename => '重新命名';

  @override
  String get chipActionSetCover => '設定封面';

  @override
  String get chipActionShowCountryStates => '顯示地區';

  @override
  String get chipActionCreateAlbum => '建立相簿';

  @override
  String get chipActionCreateVault => '建立保險庫';

  @override
  String get chipActionConfigureVault => '設訂保險庫';

  @override
  String get entryActionCopyToClipboard => '複製到剪貼簿';

  @override
  String get entryActionDelete => '刪除';

  @override
  String get entryActionConvert => '轉換';

  @override
  String get entryActionExport => '匯出';

  @override
  String get entryActionInfo => '訊息';

  @override
  String get entryActionRename => '重新命名';

  @override
  String get entryActionRestore => '還原';

  @override
  String get entryActionRotateCCW => '逆時鐘旋轉';

  @override
  String get entryActionRotateCW => '順時鐘旋轉';

  @override
  String get entryActionFlip => '水平翻轉';

  @override
  String get entryActionPrint => '列印';

  @override
  String get entryActionShare => '分享';

  @override
  String get entryActionShareImageOnly => '只分享圖片';

  @override
  String get entryActionShareVideoOnly => '只分享影片';

  @override
  String get entryActionViewSource => '查看原始碼';

  @override
  String get entryActionShowGeoTiffOnMap => '顯示為地圖疊加層';

  @override
  String get entryActionConvertMotionPhotoToStillImage => '轉換為靜態圖片';

  @override
  String get entryActionViewMotionPhotoVideo => '打開影片';

  @override
  String get entryActionEdit => '編輯';

  @override
  String get entryActionOpen => '開始方式';

  @override
  String get entryActionSetAs => '設定為';

  @override
  String get entryActionCast => '投放';

  @override
  String get entryActionOpenMap => '在地圖應用中顯示';

  @override
  String get entryActionRotateScreen => '旋轉螢幕';

  @override
  String get entryActionAddFavourite => '加入我的最愛';

  @override
  String get entryActionRemoveFavourite => '移除我的最愛';

  @override
  String get videoActionCaptureFrame => '獲取幀數';

  @override
  String get videoActionMute => '靜音';

  @override
  String get videoActionUnmute => '取消靜音';

  @override
  String get videoActionPause => '暫停';

  @override
  String get videoActionPlay => '播放';

  @override
  String get videoActionReplay10 => '退回 10 秒';

  @override
  String get videoActionSkip10 => '前進 10 秒';

  @override
  String get videoActionSelectStreams => '選擇音軌';

  @override
  String get videoActionSetSpeed => '播放速度';

  @override
  String get videoActionABRepeat => 'A-B 重複播放';

  @override
  String get videoRepeatActionSetStart => '設置起點';

  @override
  String get videoRepeatActionSetEnd => '設置終點';

  @override
  String get viewerActionSettings => '設定';

  @override
  String get viewerActionLock => '鎖定瀏覽器';

  @override
  String get viewerActionUnlock => '解鎖瀏覽器';

  @override
  String get slideshowActionResume => '繼續';

  @override
  String get slideshowActionShowInCollection => '在收藏品中顯示';

  @override
  String get entryInfoActionEditDate => '編輯日期和時間';

  @override
  String get entryInfoActionEditLocation => '編輯座標';

  @override
  String get entryInfoActionEditTitleDescription => '編輯標題和描述';

  @override
  String get entryInfoActionEditRating => '編輯評分';

  @override
  String get entryInfoActionEditTags => '編輯標籤';

  @override
  String get entryInfoActionRemoveMetadata => '移除元資料';

  @override
  String get entryInfoActionExportMetadata => '匯出元資料';

  @override
  String get entryInfoActionRemoveLocation => '移除座標';

  @override
  String get editorActionTransform => '轉換';

  @override
  String get editorTransformCrop => '剪裁';

  @override
  String get editorTransformRotate => '轉向';

  @override
  String get cropAspectRatioFree => '自由';

  @override
  String get cropAspectRatioOriginal => '原始';

  @override
  String get cropAspectRatioSquare => '方形';

  @override
  String get filterAspectRatioLandscapeLabel => '橫向';

  @override
  String get filterAspectRatioPortraitLabel => '縱向';

  @override
  String get filterBinLabel => '資源回收桶';

  @override
  String get filterFavouriteLabel => '我的最愛';

  @override
  String get filterNoDateLabel => '未註明日期';

  @override
  String get filterNoAddressLabel => '無地址';

  @override
  String get filterLocatedLabel => '位於';

  @override
  String get filterNoLocationLabel => '未定位';

  @override
  String get filterNoRatingLabel => '未評分';

  @override
  String get filterTaggedLabel => '已標籤';

  @override
  String get filterNoTagLabel => '無標籤';

  @override
  String get filterNoTitleLabel => '無標題';

  @override
  String get filterOnThisDayLabel => '在這一天';

  @override
  String get filterRecentlyAddedLabel => '最近新增';

  @override
  String get filterRatingRejectedLabel => '駁回';

  @override
  String get filterTypeAnimatedLabel => '動畫';

  @override
  String get filterTypeMotionPhotoLabel => '動態相片';

  @override
  String get filterTypePanoramaLabel => '全景圖';

  @override
  String get filterTypeRawLabel => 'Raw';

  @override
  String get filterTypeSphericalVideoLabel => '360° 影片';

  @override
  String get filterTypeGeotiffLabel => 'GeoTIFF';

  @override
  String get filterMimeImageLabel => '圖片';

  @override
  String get filterMimeVideoLabel => '影片';

  @override
  String get accessibilityAnimationsRemove => '阻止螢幕特效';

  @override
  String get accessibilityAnimationsKeep => '保留螢幕特效';

  @override
  String get albumTierNew => '新的';

  @override
  String get albumTierPinned => '釘選';

  @override
  String get albumTierSpecial => '一般';

  @override
  String get albumTierApps => 'Apps';

  @override
  String get albumTierVaults => '保險庫';

  @override
  String get albumTierDynamic => '動態';

  @override
  String get albumTierRegular => '其他';

  @override
  String get coordinateFormatDms => 'DMS';

  @override
  String get coordinateFormatDecimal => '十進制度數';

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
  String get displayRefreshRatePreferHighest => '最高更新率';

  @override
  String get displayRefreshRatePreferLowest => '最低更新率';

  @override
  String get keepScreenOnNever => '永不';

  @override
  String get keepScreenOnVideoPlayback => '播放影片期間';

  @override
  String get keepScreenOnViewerOnly => '只有瀏覽頁面';

  @override
  String get keepScreenOnAlways => '總是';

  @override
  String get lengthUnitPixel => 'px';

  @override
  String get lengthUnitPercent => '%';

  @override
  String get mapStyleGoogleNormal => 'Google 地圖';

  @override
  String get mapStyleGoogleHybrid => 'Google 地圖 (衛星影像)';

  @override
  String get mapStyleGoogleTerrain => 'Google 地圖 (地形)';

  @override
  String get mapStyleOsmHot => 'Humanitarian OSM';

  @override
  String get mapStyleStamenWatercolor => 'Stamen Watercolor';

  @override
  String get maxBrightnessNever => '從不';

  @override
  String get maxBrightnessAlways => '總是';

  @override
  String get nameConflictStrategyRename => '重新命名';

  @override
  String get nameConflictStrategyReplace => '取代';

  @override
  String get nameConflictStrategySkip => '跳過';

  @override
  String get overlayHistogramNone => '無';

  @override
  String get overlayHistogramRGB => 'RGB';

  @override
  String get overlayHistogramLuminance => '亮度';

  @override
  String get subtitlePositionTop => '頂端';

  @override
  String get subtitlePositionBottom => '底端';

  @override
  String get themeBrightnessLight => '淺色';

  @override
  String get themeBrightnessDark => '深色';

  @override
  String get themeBrightnessBlack => '黑色';

  @override
  String get unitSystemMetric => '公制';

  @override
  String get unitSystemImperial => '英制';

  @override
  String get vaultLockTypePattern => '圖案';

  @override
  String get vaultLockTypePin => 'PIN';

  @override
  String get vaultLockTypePassword => '密碼';

  @override
  String get settingsVideoEnablePip => '畫中畫';

  @override
  String get videoControlsPlayOutside => '用其他播放器打開';

  @override
  String get videoLoopModeNever => '永不';

  @override
  String get videoLoopModeShortOnly => '僅短影片';

  @override
  String get videoLoopModeAlways => '總是';

  @override
  String get videoPlaybackSkip => '跳過';

  @override
  String get videoPlaybackMuted => '靜音播放';

  @override
  String get videoPlaybackWithSound => '帶音播放';

  @override
  String get videoResumptionModeNever => '從不';

  @override
  String get videoResumptionModeAlways => '總是';

  @override
  String get viewerTransitionSlide => '滑動';

  @override
  String get viewerTransitionParallax => '視差滾動';

  @override
  String get viewerTransitionFade => '淡入淡出';

  @override
  String get viewerTransitionZoomIn => '放大';

  @override
  String get viewerTransitionNone => '無';

  @override
  String get wallpaperTargetHome => '主畫面';

  @override
  String get wallpaperTargetLock => '鎖定畫面';

  @override
  String get wallpaperTargetHomeLock => '主畫面和鎖定畫面';

  @override
  String get widgetDisplayedItemRandom => '隨機';

  @override
  String get widgetDisplayedItemMostRecent => '最新';

  @override
  String get widgetOpenPageHome => '打開主畫面';

  @override
  String get widgetOpenPageCollection => '打開收藏品';

  @override
  String get widgetOpenPageViewer => '打開瀏覽器';

  @override
  String get widgetTapUpdateWidget => '更新小工具';

  @override
  String get storageVolumeDescriptionFallbackPrimary => '內部儲存空間';

  @override
  String get storageVolumeDescriptionFallbackNonPrimary => 'SD 卡';

  @override
  String get rootDirectoryDescription => '根目錄';

  @override
  String otherDirectoryDescription(String name) {
    return '“$name” 目錄';
  }

  @override
  String storageAccessDialogMessage(String directory, String volume) {
    return '請在下一畫面中選擇 “$volume” 的 $directory，以授予本程式存取權限.';
  }

  @override
  String restrictedAccessDialogMessage(String directory, String volume) {
    return '這 app 不允許修改 “$volume” 的 $directory 中的檔案.\n\n請使用預先安裝的檔案總管或圖片檢視器來將項目搬到另一個目錄.';
  }

  @override
  String notEnoughSpaceDialogMessage(String neededSize, String freeSize, String volume) {
    return '此操作需要“$volume”上具有 $neededSize 可用空間才能完成，實際只剩 $freeSize.';
  }

  @override
  String get missingSystemFilePickerDialogMessage => '系統檔案選擇器遺失或停用. 請啟用他並再試一次.';

  @override
  String unsupportedTypeDialogMessage(int count, String types) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '此操作不支援以下類型的項目: $types.',
    );
    return '$_temp0';
  }

  @override
  String get nameConflictDialogSingleSourceMessage => '目標資料夾中有同名稱檔案.';

  @override
  String get nameConflictDialogMultipleSourceMessage => '存在同名稱檔案.';

  @override
  String get addShortcutDialogLabel => '捷徑標籤';

  @override
  String get addShortcutButtonLabel => '新增';

  @override
  String get noMatchingAppDialogMessage => '無對應的 app 能處理.';

  @override
  String binEntriesConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '移動這 $count 項目到資源回收桶?',
      one: '移動這個項目到資源回收桶?',
    );
    return '$_temp0';
  }

  @override
  String deleteEntriesConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '刪除這 $count 項目?',
      one: '刪除這個項目?',
    );
    return '$_temp0';
  }

  @override
  String get moveUndatedConfirmationDialogMessage => '處理前儲存項目日期?';

  @override
  String get moveUndatedConfirmationDialogSetDate => '儲存日期';

  @override
  String videoResumeDialogMessage(String time) {
    return '想要在 $time 繼續播放?';
  }

  @override
  String get videoStartOverButtonLabel => '重新播放';

  @override
  String get videoResumeButtonLabel => '繼續';

  @override
  String get setCoverDialogLatest => '最新項目';

  @override
  String get setCoverDialogAuto => '自動';

  @override
  String get setCoverDialogCustom => '自定';

  @override
  String get hideFilterConfirmationDialogMessage => '符合的照片和影片將從收藏品中隱藏，你可以從 “隱私” 設定中再次顯示.\n\n確定要隱藏嗎？';

  @override
  String get newAlbumDialogTitle => '新相簿';

  @override
  String get newAlbumDialogNameLabel => '相簿名稱';

  @override
  String get newAlbumDialogNameLabelAlreadyExistsHelper => '目錄已存在';

  @override
  String get newAlbumDialogStorageLabel => '儲存空間:';

  @override
  String get newVaultWarningDialogMessage => '保險庫中的項目僅供此應用使用，其他應用不可用。\n\n如果您卸載此應用程序或清除此應用程序數據，您將丟失所有這些項目。';

  @override
  String get newVaultDialogTitle => '新保險庫';

  @override
  String get configureVaultDialogTitle => '設置保險庫';

  @override
  String get vaultDialogLockModeWhenScreenOff => '螢幕關閉時鎖定';

  @override
  String get vaultDialogLockTypeLabel => '鎖定形式';

  @override
  String get patternDialogEnter => '輸入圖形';

  @override
  String get patternDialogConfirm => '確認圖形';

  @override
  String get pinDialogEnter => '輸入PIN';

  @override
  String get pinDialogConfirm => '確認PIN';

  @override
  String get passwordDialogEnter => '輸入密碼';

  @override
  String get passwordDialogConfirm => '確認密碼';

  @override
  String get authenticateToConfigureVault => '驗證以設置保險庫';

  @override
  String get authenticateToUnlockVault => '驗證以解鎖保險庫';

  @override
  String get vaultBinUsageDialogMessage => '有些保險庫正在使用資源回收桶。';

  @override
  String get renameAlbumDialogLabel => '新名稱';

  @override
  String get renameAlbumDialogLabelAlreadyExistsHelper => '目錄已存在';

  @override
  String get renameEntrySetPageTitle => '重新命名';

  @override
  String get renameEntrySetPagePatternFieldLabel => '命名樣式';

  @override
  String get renameEntrySetPageInsertTooltip => '插入欄位';

  @override
  String get renameEntrySetPagePreviewSectionTitle => '預覽';

  @override
  String get renameProcessorCounter => '計數器';

  @override
  String get renameProcessorHash => '雜湊';

  @override
  String get renameProcessorName => '名稱';

  @override
  String deleteSingleAlbumConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '刪除此相簿及其中的$count個項目？',
      one: '刪除此相簿及其中的項目？',
    );
    return '$_temp0';
  }

  @override
  String deleteMultiAlbumConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '刪除這些相簿及其中的$count個項目？',
      one: '刪除這些相簿及其內部的項目？',
    );
    return '$_temp0';
  }

  @override
  String get exportEntryDialogFormat => '格式：';

  @override
  String get exportEntryDialogWidth => '寬度';

  @override
  String get exportEntryDialogHeight => '高度';

  @override
  String get exportEntryDialogQuality => '畫質';

  @override
  String get exportEntryDialogWriteMetadata => '寫入元資料';

  @override
  String get renameEntryDialogLabel => '新名稱';

  @override
  String get editEntryDialogCopyFromItem => '從其他項目複製';

  @override
  String get editEntryDialogTargetFieldsHeader => '修改欄位';

  @override
  String get editEntryDateDialogTitle => '日期和時間';

  @override
  String get editEntryDateDialogSetCustom => '設置自定日期';

  @override
  String get editEntryDateDialogCopyField => '從其他日期複製';

  @override
  String get editEntryDateDialogExtractFromTitle => '從標題獲得';

  @override
  String get editEntryDateDialogShift => '轉移';

  @override
  String get editEntryDateDialogSourceFileModifiedDate => '檔案修改日期';

  @override
  String get durationDialogHours => '小時';

  @override
  String get durationDialogMinutes => '分鐘';

  @override
  String get durationDialogSeconds => '秒鐘';

  @override
  String get editEntryLocationDialogTitle => '座標';

  @override
  String get editEntryLocationDialogSetCustom => '安置自定座標';

  @override
  String get editEntryLocationDialogChooseOnMap => '從地圖上選擇';

  @override
  String get editEntryLocationDialogLatitude => '緯度';

  @override
  String get editEntryLocationDialogLongitude => '經度';

  @override
  String get locationPickerUseThisLocationButton => '使用此座標';

  @override
  String get editEntryRatingDialogTitle => '評分';

  @override
  String get removeEntryMetadataDialogTitle => '移除元資料';

  @override
  String get removeEntryMetadataDialogMore => '更多';

  @override
  String get removeEntryMetadataMotionPhotoXmpWarningDialogMessage => '播放動態相片中的影片需要 XMP\n\n確定要刪除他嗎？';

  @override
  String get videoSpeedDialogLabel => '播放速度';

  @override
  String get videoStreamSelectionDialogVideo => '影片';

  @override
  String get videoStreamSelectionDialogAudio => '音頻';

  @override
  String get videoStreamSelectionDialogText => '字幕';

  @override
  String get videoStreamSelectionDialogOff => '關閉';

  @override
  String get videoStreamSelectionDialogTrack => '軌道';

  @override
  String get videoStreamSelectionDialogNoSelection => '沒有其他音軌.';

  @override
  String get genericSuccessFeedback => '完成！';

  @override
  String get genericFailureFeedback => '失敗';

  @override
  String get genericDangerWarningDialogMessage => '你確定嗎？';

  @override
  String get tooManyItemsErrorDialogMessage => '用更少的項目重試。';

  @override
  String get menuActionConfigureView => '檢視';

  @override
  String get menuActionSelect => '選擇';

  @override
  String get menuActionSelectAll => '選擇全部';

  @override
  String get menuActionSelectNone => '全部不選';

  @override
  String get menuActionMap => '地圖';

  @override
  String get menuActionSlideshow => '幻燈片';

  @override
  String get menuActionStats => '統計資料';

  @override
  String get viewDialogSortSectionTitle => '排序';

  @override
  String get viewDialogGroupSectionTitle => '群組';

  @override
  String get viewDialogLayoutSectionTitle => '佈局';

  @override
  String get viewDialogReverseSortOrder => '反向排序';

  @override
  String get tileLayoutMosaic => '混合';

  @override
  String get tileLayoutGrid => '網格';

  @override
  String get tileLayoutList => '列表';

  @override
  String get castDialogTitle => '投放裝置';

  @override
  String get coverDialogTabCover => '封面';

  @override
  String get coverDialogTabApp => 'App';

  @override
  String get coverDialogTabColor => '顏色';

  @override
  String get appPickDialogTitle => '選擇 App';

  @override
  String get appPickDialogNone => '無';

  @override
  String get aboutPageTitle => '關於';

  @override
  String get aboutLinkLicense => '授權條款';

  @override
  String get aboutLinkPolicy => '隱私政策';

  @override
  String get aboutBugSectionTitle => '回報錯誤';

  @override
  String get aboutBugSaveLogInstruction => '將 App 日誌儲存到檔案';

  @override
  String get aboutBugCopyInfoInstruction => '複製系統資訊';

  @override
  String get aboutBugCopyInfoButton => '複製';

  @override
  String get aboutBugReportInstruction => '回報日誌和系統資訊到 GitHub';

  @override
  String get aboutBugReportButton => '回報';

  @override
  String get aboutDataUsageSectionTitle => '資料用量';

  @override
  String get aboutDataUsageData => '資料';

  @override
  String get aboutDataUsageCache => '快取記憶體';

  @override
  String get aboutDataUsageDatabase => '資料庫';

  @override
  String get aboutDataUsageMisc => '雜項';

  @override
  String get aboutDataUsageInternal => '內部儲存';

  @override
  String get aboutDataUsageExternal => '外部儲存';

  @override
  String get aboutDataUsageClearCache => '清除快取';

  @override
  String get aboutCreditsSectionTitle => '感謝名單';

  @override
  String get aboutCreditsWorldAtlas1 => '本 App 使用的 TopoJSON 檔案來自';

  @override
  String get aboutCreditsWorldAtlas2 => '符合 ISC 授權條款.';

  @override
  String get aboutTranslatorsSectionTitle => '翻譯人員';

  @override
  String get aboutLicensesSectionTitle => '開放原始碼授權條款';

  @override
  String get aboutLicensesBanner => '本 App 使用下列開放原始碼套件和函式庫.';

  @override
  String get aboutLicensesAndroidLibrariesSectionTitle => 'Android 函式庫';

  @override
  String get aboutLicensesFlutterPluginsSectionTitle => 'Flutter 外掛';

  @override
  String get aboutLicensesFlutterPackagesSectionTitle => 'Flutter 套件';

  @override
  String get aboutLicensesDartPackagesSectionTitle => 'Dart 套件';

  @override
  String get aboutLicensesShowAllButtonLabel => '顯示所有授權條款';

  @override
  String get policyPageTitle => '隱私政策';

  @override
  String get collectionPageTitle => '收藏品';

  @override
  String get collectionPickPageTitle => '挑選';

  @override
  String get collectionSelectPageTitle => '選擇項目';

  @override
  String get collectionActionShowTitleSearch => '顯示標題過濾器';

  @override
  String get collectionActionHideTitleSearch => '隱藏標題過濾器';

  @override
  String get collectionActionAddShortcut => '新增捷徑';

  @override
  String get collectionActionSetHome => '設為首頁';

  @override
  String get collectionActionEmptyBin => '清空資源回收筒';

  @override
  String get collectionActionCopy => '複製到相簿';

  @override
  String get collectionActionMove => '移動到相簿';

  @override
  String get collectionActionRescan => '重新掃描';

  @override
  String get collectionActionEdit => '編輯';

  @override
  String get collectionSearchTitlesHintText => '搜尋標題';

  @override
  String get collectionGroupAlbum => '依照相簿';

  @override
  String get collectionGroupMonth => '依照月份';

  @override
  String get collectionGroupDay => '依照日期';

  @override
  String get collectionGroupNone => '不分群組';

  @override
  String get sectionUnknown => '未知';

  @override
  String get dateToday => '今天';

  @override
  String get dateYesterday => '昨天';

  @override
  String get dateThisMonth => '本月';

  @override
  String collectionDeleteFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '刪除 $count 項目失敗',
    );
    return '$_temp0';
  }

  @override
  String collectionCopyFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '複製 $count 項目失敗',
    );
    return '$_temp0';
  }

  @override
  String collectionMoveFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '移動 $count 項目失敗',
    );
    return '$_temp0';
  }

  @override
  String collectionRenameFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '改名 $count 項目失敗',
    );
    return '$_temp0';
  }

  @override
  String collectionEditFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '編輯 $count 項目失敗',
    );
    return '$_temp0';
  }

  @override
  String collectionExportFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '匯出 $count 頁',
    );
    return '$_temp0';
  }

  @override
  String collectionCopySuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '複製 $count 項目',
    );
    return '$_temp0';
  }

  @override
  String collectionMoveSuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '移動 $count 項目',
    );
    return '$_temp0';
  }

  @override
  String collectionRenameSuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '改名 $count 項目',
    );
    return '$_temp0';
  }

  @override
  String collectionEditSuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '編輯 $count 項目',
    );
    return '$_temp0';
  }

  @override
  String get collectionEmptyFavourites => '沒有我的最愛';

  @override
  String get collectionEmptyVideos => '沒有影片';

  @override
  String get collectionEmptyImages => '沒有圖片';

  @override
  String get collectionEmptyGrantAccessButtonLabel => '允許存取';

  @override
  String get collectionSelectSectionTooltip => '選擇部份';

  @override
  String get collectionDeselectSectionTooltip => '取消選擇部份';

  @override
  String get drawerAboutButton => '關於';

  @override
  String get drawerSettingsButton => '設定';

  @override
  String get drawerCollectionAll => '所有收藏品';

  @override
  String get drawerCollectionFavourites => '我的最愛';

  @override
  String get drawerCollectionImages => '圖片';

  @override
  String get drawerCollectionVideos => '影片';

  @override
  String get drawerCollectionAnimated => '動畫';

  @override
  String get drawerCollectionMotionPhotos => '動態相片';

  @override
  String get drawerCollectionPanoramas => '全景圖';

  @override
  String get drawerCollectionRaws => 'Raw 相片';

  @override
  String get drawerCollectionSphericalVideos => '360° 影片';

  @override
  String get drawerAlbumPage => '相簿';

  @override
  String get drawerCountryPage => '國家';

  @override
  String get drawerPlacePage => '地點';

  @override
  String get drawerTagPage => '標籤';

  @override
  String get sortByDate => '依日期';

  @override
  String get sortByName => '依名稱';

  @override
  String get sortByItemCount => '依項目數量';

  @override
  String get sortBySize => '依尺寸';

  @override
  String get sortByAlbumFileName => '依相簿和檔案名稱';

  @override
  String get sortByRating => '依評分';

  @override
  String get sortOrderNewestFirst => '由新至舊';

  @override
  String get sortOrderOldestFirst => '由舊至新';

  @override
  String get sortOrderAtoZ => 'A — Z';

  @override
  String get sortOrderZtoA => 'Z — A';

  @override
  String get sortOrderHighestFirst => '由高到低';

  @override
  String get sortOrderLowestFirst => '由低到高';

  @override
  String get sortOrderLargestFirst => '由大到小';

  @override
  String get sortOrderSmallestFirst => '由小到大';

  @override
  String get albumGroupTier => '依層級';

  @override
  String get albumGroupType => '依類型';

  @override
  String get albumGroupVolume => '依儲存容量';

  @override
  String get albumGroupNone => '不分群組';

  @override
  String get albumMimeTypeMixed => '混合的';

  @override
  String get albumPickPageTitleCopy => '複製到相簿';

  @override
  String get albumPickPageTitleExport => '匯出到相簿';

  @override
  String get albumPickPageTitleMove => '移動到相簿';

  @override
  String get albumPickPageTitlePick => '選擇相簿';

  @override
  String get albumCamera => '相機';

  @override
  String get albumDownload => '下載';

  @override
  String get albumScreenshots => '截圖';

  @override
  String get albumScreenRecordings => '螢幕錄影';

  @override
  String get albumVideoCaptures => '影像截取';

  @override
  String get albumPageTitle => '相簿';

  @override
  String get albumEmpty => '沒有相簿';

  @override
  String get createAlbumButtonLabel => '建立';

  @override
  String get newFilterBanner => '新的';

  @override
  String get countryPageTitle => '國家';

  @override
  String get countryEmpty => '沒有國家';

  @override
  String get statePageTitle => '地區';

  @override
  String get stateEmpty => '無地區';

  @override
  String get placePageTitle => '地點';

  @override
  String get placeEmpty => '無地點';

  @override
  String get tagPageTitle => '標籤';

  @override
  String get tagEmpty => '沒有標籤';

  @override
  String get binPageTitle => '資源回收桶';

  @override
  String get explorerPageTitle => '檔案總管';

  @override
  String get searchCollectionFieldHint => '搜尋收藏品';

  @override
  String get searchRecentSectionTitle => '最近';

  @override
  String get searchDateSectionTitle => '日期';

  @override
  String get searchAlbumsSectionTitle => '相簿';

  @override
  String get searchCountriesSectionTitle => '國家';

  @override
  String get searchStatesSectionTitle => '地區';

  @override
  String get searchPlacesSectionTitle => '地點';

  @override
  String get searchTagsSectionTitle => '標籤';

  @override
  String get searchRatingSectionTitle => '評分';

  @override
  String get searchMetadataSectionTitle => '元資料';

  @override
  String get settingsPageTitle => '設定';

  @override
  String get settingsSystemDefault => '系統預設';

  @override
  String get settingsDefault => '預設';

  @override
  String get settingsDisabled => '停用';

  @override
  String get settingsAskEverytime => '每次詢問';

  @override
  String get settingsModificationWarningDialogMessage => '其他設置將被修改。';

  @override
  String get settingsSearchFieldLabel => '搜尋設定';

  @override
  String get settingsSearchEmpty => '沒有符合的設定';

  @override
  String get settingsActionExport => '匯出';

  @override
  String get settingsActionExportDialogTitle => '匯出';

  @override
  String get settingsActionImport => '匯入';

  @override
  String get settingsActionImportDialogTitle => '匯入';

  @override
  String get appExportCovers => '封面';

  @override
  String get appExportFavourites => '我的最愛';

  @override
  String get appExportSettings => '設定';

  @override
  String get settingsNavigationSectionTitle => '導航';

  @override
  String get settingsHomeTile => '主畫面';

  @override
  String get settingsHomeDialogTitle => '主畫面';

  @override
  String get settingsShowBottomNavigationBar => '顯示底部操作條';

  @override
  String get settingsKeepScreenOnTile => '保持螢幕開啟';

  @override
  String get settingsKeepScreenOnDialogTitle => '保持螢幕開啟';

  @override
  String get settingsDoubleBackExit => '按 “上一頁” 鍵二次離開';

  @override
  String get settingsConfirmationTile => '確認對話框';

  @override
  String get settingsConfirmationDialogTitle => '確認對話框';

  @override
  String get settingsConfirmationBeforeDeleteItems => '永久刪除項目前先詢問';

  @override
  String get settingsConfirmationBeforeMoveToBinItems => '移動項目到資源回收桶前先詢問';

  @override
  String get settingsConfirmationBeforeMoveUndatedItems => '日期不詳的項目移動前先詢問';

  @override
  String get settingsConfirmationAfterMoveToBinItems => '移動項目到資源回收桶後顯示訊息';

  @override
  String get settingsConfirmationVaultDataLoss => '顯示保險庫數據洩漏警告';

  @override
  String get settingsNavigationDrawerTile => '操作選單';

  @override
  String get settingsNavigationDrawerEditorPageTitle => '操作選單';

  @override
  String get settingsNavigationDrawerBanner => '長按來移動以重新排序選單項目。';

  @override
  String get settingsNavigationDrawerTabTypes => '類型';

  @override
  String get settingsNavigationDrawerTabAlbums => '相簿';

  @override
  String get settingsNavigationDrawerTabPages => '頁面';

  @override
  String get settingsNavigationDrawerAddAlbum => '新增相簿';

  @override
  String get settingsThumbnailSectionTitle => '縮圖';

  @override
  String get settingsThumbnailOverlayTile => '疊加層';

  @override
  String get settingsThumbnailOverlayPageTitle => '疊加層';

  @override
  String get settingsThumbnailShowHdrIcon => '顯示 HDR 圖示';

  @override
  String get settingsThumbnailShowFavouriteIcon => '顯示我的最愛圖示';

  @override
  String get settingsThumbnailShowTagIcon => '顯示標籤圖示';

  @override
  String get settingsThumbnailShowLocationIcon => '顯示座標圖示';

  @override
  String get settingsThumbnailShowMotionPhotoIcon => '顯示動態相片圖示';

  @override
  String get settingsThumbnailShowRating => '顯示評分';

  @override
  String get settingsThumbnailShowRawIcon => '顯示 raw 圖示';

  @override
  String get settingsThumbnailShowVideoDuration => '顯示影片時間長度';

  @override
  String get settingsCollectionQuickActionsTile => '快速操作';

  @override
  String get settingsCollectionQuickActionEditorPageTitle => '快速操作';

  @override
  String get settingsCollectionQuickActionTabBrowsing => '瀏覽';

  @override
  String get settingsCollectionQuickActionTabSelecting => '選擇';

  @override
  String get settingsCollectionBrowsingQuickActionEditorBanner => '長按來移動按鈕，以選擇在瀏覽項目時顯示哪些操作項。';

  @override
  String get settingsCollectionSelectionQuickActionEditorBanner => '長按來移動按鈕，以選擇在選擇項目時顯示的操作項。';

  @override
  String get settingsCollectionBurstPatternsTile => '連拍形式';

  @override
  String get settingsCollectionBurstPatternsNone => '無';

  @override
  String get settingsViewerSectionTitle => '瀏覽器';

  @override
  String get settingsViewerGestureSideTapNext => '點擊螢幕邊緣以顯示上一個/下一個項目';

  @override
  String get settingsViewerUseCutout => '使用鏤空區域';

  @override
  String get settingsViewerMaximumBrightness => '最大亮度';

  @override
  String get settingsMotionPhotoAutoPlay => '自動播放動態相片';

  @override
  String get settingsImageBackground => '圖片背景';

  @override
  String get settingsViewerQuickActionsTile => '快速操作';

  @override
  String get settingsViewerQuickActionEditorPageTitle => '快速操作';

  @override
  String get settingsViewerQuickActionEditorBanner => '長按來移動按鈕，以選擇瀏覽器中顯示的操作項。';

  @override
  String get settingsViewerQuickActionEditorDisplayedButtonsSectionTitle => '顯示的按鈕';

  @override
  String get settingsViewerQuickActionEditorAvailableButtonsSectionTitle => '可用按鈕';

  @override
  String get settingsViewerQuickActionEmpty => '沒有按鈕';

  @override
  String get settingsViewerOverlayTile => '疊加層';

  @override
  String get settingsViewerOverlayPageTitle => '疊加層';

  @override
  String get settingsViewerShowOverlayOnOpening => '開啟時顯示';

  @override
  String get settingsViewerShowHistogram => '顯示直方圖';

  @override
  String get settingsViewerShowMinimap => '顯示小地圖';

  @override
  String get settingsViewerShowInformation => '顯示資訊';

  @override
  String get settingsViewerShowInformationSubtitle => '顯示標題、日期、座標…等';

  @override
  String get settingsViewerShowRatingTags => '顯示評分和標籤';

  @override
  String get settingsViewerShowShootingDetails => '顯示拍攝細節';

  @override
  String get settingsViewerShowDescription => '顯示描述';

  @override
  String get settingsViewerShowOverlayThumbnails => '顯示縮圖';

  @override
  String get settingsViewerEnableOverlayBlurEffect => '模糊特效';

  @override
  String get settingsViewerSlideshowTile => '幻燈片';

  @override
  String get settingsViewerSlideshowPageTitle => '幻燈片';

  @override
  String get settingsSlideshowRepeat => '重複';

  @override
  String get settingsSlideshowShuffle => '隨機播放';

  @override
  String get settingsSlideshowFillScreen => '全螢幕';

  @override
  String get settingsSlideshowAnimatedZoomEffect => '動畫縮放效果';

  @override
  String get settingsSlideshowTransitionTile => '轉換';

  @override
  String get settingsSlideshowIntervalTile => '時間間隔';

  @override
  String get settingsSlideshowVideoPlaybackTile => '影片播放';

  @override
  String get settingsSlideshowVideoPlaybackDialogTitle => '影片播放';

  @override
  String get settingsVideoPageTitle => '影片設定';

  @override
  String get settingsVideoSectionTitle => '影片';

  @override
  String get settingsVideoShowVideos => '顯示影片';

  @override
  String get settingsVideoPlaybackTile => '重播';

  @override
  String get settingsVideoPlaybackPageTitle => '重播';

  @override
  String get settingsVideoEnableHardwareAcceleration => '硬體加速';

  @override
  String get settingsVideoAutoPlay => '自動播放';

  @override
  String get settingsVideoLoopModeTile => '循環模式';

  @override
  String get settingsVideoLoopModeDialogTitle => '循環模式';

  @override
  String get settingsVideoResumptionModeTile => '再次重播';

  @override
  String get settingsVideoResumptionModeDialogTitle => '再次重播';

  @override
  String get settingsVideoBackgroundMode => '後臺模式';

  @override
  String get settingsVideoBackgroundModeDialogTitle => '後臺模式';

  @override
  String get settingsVideoControlsTile => '控制';

  @override
  String get settingsVideoControlsPageTitle => '控制';

  @override
  String get settingsVideoButtonsTile => '按鈕';

  @override
  String get settingsVideoGestureDoubleTapTogglePlay => '點擊二次以播放/暫停';

  @override
  String get settingsVideoGestureSideDoubleTapSeek => '螢幕邊緣點擊二次以後退/前進';

  @override
  String get settingsVideoGestureVerticalDragBrightnessVolume => '上下滑動以調整亮度/音量';

  @override
  String get settingsSubtitleThemeTile => '字幕';

  @override
  String get settingsSubtitleThemePageTitle => '字幕';

  @override
  String get settingsSubtitleThemeSample => '這是一個樣本.';

  @override
  String get settingsSubtitleThemeTextAlignmentTile => '文字對齊';

  @override
  String get settingsSubtitleThemeTextAlignmentDialogTitle => '文字對齊';

  @override
  String get settingsSubtitleThemeTextPositionTile => '文字位置';

  @override
  String get settingsSubtitleThemeTextPositionDialogTitle => '文字位置';

  @override
  String get settingsSubtitleThemeTextSize => '文字大小';

  @override
  String get settingsSubtitleThemeShowOutline => '顯示輪廓和陰影';

  @override
  String get settingsSubtitleThemeTextColor => '文字顏色';

  @override
  String get settingsSubtitleThemeTextOpacity => '文字透明度';

  @override
  String get settingsSubtitleThemeBackgroundColor => '背景顏色';

  @override
  String get settingsSubtitleThemeBackgroundOpacity => '背景透明度';

  @override
  String get settingsSubtitleThemeTextAlignmentLeft => '左邊';

  @override
  String get settingsSubtitleThemeTextAlignmentCenter => '置中';

  @override
  String get settingsSubtitleThemeTextAlignmentRight => '右邊';

  @override
  String get settingsPrivacySectionTitle => '隱私';

  @override
  String get settingsAllowInstalledAppAccess => '允許存取應用程式清單';

  @override
  String get settingsAllowInstalledAppAccessSubtitle => '用於改進相簿顯示';

  @override
  String get settingsAllowErrorReporting => '允許匿名錯誤報告';

  @override
  String get settingsSaveSearchHistory => '儲存搜尋歷史記錄';

  @override
  String get settingsEnableBin => '啟用資源回收桶';

  @override
  String get settingsEnableBinSubtitle => '刪除項目保留 30 天';

  @override
  String get settingsDisablingBinWarningDialogMessage => '資源回收桶中的項目將被永久刪除。';

  @override
  String get settingsAllowMediaManagement => '允許媒體管理';

  @override
  String get settingsHiddenItemsTile => '隱藏項目';

  @override
  String get settingsHiddenItemsPageTitle => '隱藏項目';

  @override
  String get settingsHiddenFiltersBanner => '符合過濾器的相片和影片將不會顯示在你的收藏品中.';

  @override
  String get settingsHiddenFiltersEmpty => '沒有隱藏過濾器';

  @override
  String get settingsStorageAccessTile => '儲存空間存取';

  @override
  String get settingsStorageAccessPageTitle => '儲存空間存取';

  @override
  String get settingsStorageAccessBanner => '某些目錄要求明確存取權限才能修改裡面的檔案. 你可以查看先前得到權限的目錄.';

  @override
  String get settingsStorageAccessEmpty => '沒有存取權限';

  @override
  String get settingsStorageAccessRevokeTooltip => '撤銷';

  @override
  String get settingsAccessibilitySectionTitle => '無障礙';

  @override
  String get settingsRemoveAnimationsTile => '移除動畫';

  @override
  String get settingsRemoveAnimationsDialogTitle => '移除動畫';

  @override
  String get settingsTimeToTakeActionTile => '是時候採取行動';

  @override
  String get settingsAccessibilityShowPinchGestureAlternatives => '顯示多點觸控手勢的備選方案';

  @override
  String get settingsDisplaySectionTitle => '顯示';

  @override
  String get settingsThemeBrightnessTile => '佈景主題';

  @override
  String get settingsThemeBrightnessDialogTitle => '佈景主題';

  @override
  String get settingsThemeColorHighlights => '色彩強調';

  @override
  String get settingsThemeEnableDynamicColor => '動態色彩';

  @override
  String get settingsDisplayRefreshRateModeTile => '顯示更新率';

  @override
  String get settingsDisplayRefreshRateModeDialogTitle => '更新率';

  @override
  String get settingsDisplayUseTvInterface => 'Android TV介面';

  @override
  String get settingsLanguageSectionTitle => '語言和格式';

  @override
  String get settingsLanguageTile => '語言';

  @override
  String get settingsLanguagePageTitle => '語言';

  @override
  String get settingsCoordinateFormatTile => '座標格式';

  @override
  String get settingsCoordinateFormatDialogTitle => '座標格式';

  @override
  String get settingsUnitSystemTile => '單位';

  @override
  String get settingsUnitSystemDialogTitle => '單位';

  @override
  String get settingsForceWesternArabicNumeralsTile => '強制使用阿拉伯數字';

  @override
  String get settingsScreenSaverPageTitle => '螢幕保護程式';

  @override
  String get settingsWidgetPageTitle => '相框';

  @override
  String get settingsWidgetShowOutline => '輪廓';

  @override
  String get settingsWidgetOpenPage => '點擊小工具時';

  @override
  String get settingsWidgetDisplayedItem => '顯示項目';

  @override
  String get settingsCollectionTile => '收藏品';

  @override
  String get statsPageTitle => '統計資料';

  @override
  String statsWithGps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count條座標資訊',
      one: '1條座標資訊',
    );
    return '$_temp0';
  }

  @override
  String get statsTopCountriesSectionTitle => '熱門國家';

  @override
  String get statsTopStatesSectionTitle => '最多項的地區';

  @override
  String get statsTopPlacesSectionTitle => '熱門地點';

  @override
  String get statsTopTagsSectionTitle => '熱門標籤';

  @override
  String get statsTopAlbumsSectionTitle => '熱門相簿';

  @override
  String get viewerOpenPanoramaButtonLabel => '打開全景圖';

  @override
  String get viewerSetWallpaperButtonLabel => '設定桌布';

  @override
  String get viewerErrorUnknown => '哎呀!';

  @override
  String get viewerErrorDoesNotExist => '這檔案已不存在.';

  @override
  String get viewerInfoPageTitle => '訊息';

  @override
  String get viewerInfoBackToViewerTooltip => '回到瀏覽器';

  @override
  String get viewerInfoUnknown => '未知';

  @override
  String get viewerInfoLabelDescription => '描述';

  @override
  String get viewerInfoLabelTitle => '標題';

  @override
  String get viewerInfoLabelDate => '日期';

  @override
  String get viewerInfoLabelResolution => '解析度';

  @override
  String get viewerInfoLabelSize => '大小';

  @override
  String get viewerInfoLabelUri => 'URI';

  @override
  String get viewerInfoLabelPath => '路徑';

  @override
  String get viewerInfoLabelDuration => '時間長度';

  @override
  String get viewerInfoLabelOwner => '擁有者';

  @override
  String get viewerInfoLabelCoordinates => '座標';

  @override
  String get viewerInfoLabelAddress => '地址';

  @override
  String get mapStyleDialogTitle => '地圖樣式';

  @override
  String get mapStyleTooltip => '選擇地圖樣式';

  @override
  String get mapZoomInTooltip => '放大';

  @override
  String get mapZoomOutTooltip => '縮小';

  @override
  String get mapPointNorthUpTooltip => '北方向上';

  @override
  String get mapAttributionOsmData => '地圖資料由 © [OpenStreetMap](https://www.openstreetmap.org/copyright) 貢獻';

  @override
  String get mapAttributionOsmHot => '繪製於 [HOT](https://www.hotosm.org/) • 主辦方 [OSM France](https://openstreetmap.fr/)';

  @override
  String get mapAttributionStamen => '繪製於 [Stamen Design](https://stamen.com), [CC BY 3.0](https://creativecommons.org/licenses/by/3.0)';

  @override
  String get openMapPageTooltip => '在地圖頁面上檢視';

  @override
  String get mapEmptyRegion => '該區域沒有圖片';

  @override
  String get viewerInfoOpenEmbeddedFailureFeedback => '解開嵌入資料失敗';

  @override
  String get viewerInfoOpenLinkText => '開啟';

  @override
  String get viewerInfoViewXmlLinkText => '檢視 XML';

  @override
  String get viewerInfoSearchFieldLabel => '搜尋元資料';

  @override
  String get viewerInfoSearchEmpty => '沒有符合的關鍵字';

  @override
  String get viewerInfoSearchSuggestionDate => '日期和時間';

  @override
  String get viewerInfoSearchSuggestionDescription => '描述';

  @override
  String get viewerInfoSearchSuggestionDimensions => '範圍';

  @override
  String get viewerInfoSearchSuggestionResolution => '解析度';

  @override
  String get viewerInfoSearchSuggestionRights => '權限';

  @override
  String get wallpaperUseScrollEffect => '在主畫面上使用滾動效果';

  @override
  String get tagEditorPageTitle => '編輯標籤';

  @override
  String get tagEditorPageNewTagFieldLabel => '新標籤';

  @override
  String get tagEditorPageAddTagTooltip => '新增標籤';

  @override
  String get tagEditorSectionRecent => '最近';

  @override
  String get tagEditorSectionPlaceholders => '占位符';

  @override
  String get tagEditorDiscardDialogMessage => '是否要放棄更改？';

  @override
  String get tagPlaceholderCountry => '國家';

  @override
  String get tagPlaceholderState => '地區';

  @override
  String get tagPlaceholderPlace => '地方';

  @override
  String get panoramaEnableSensorControl => '啟用感測器控制';

  @override
  String get panoramaDisableSensorControl => '停用感測器控制';

  @override
  String get sourceViewerPageTitle => '原始碼';

  @override
  String get filePickerShowHiddenFiles => '顯示隱藏檔案';

  @override
  String get filePickerDoNotShowHiddenFiles => '不顯示隱藏檔案';

  @override
  String get filePickerOpenFrom => '開啟自';

  @override
  String get filePickerNoItems => '沒有項目';

  @override
  String get filePickerUseThisFolder => '使用此資料夾';
}
