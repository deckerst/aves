// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'Aves';

  @override
  String get welcomeMessage => 'Avesへようこそ';

  @override
  String get welcomeOptional => 'オプション';

  @override
  String get welcomeTermsToggle => '利用規約に同意する';

  @override
  String itemCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString 件のアイテム',
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
      other: '$countString 日',
    );
    return '$_temp0';
  }

  @override
  String focalLength(String length) {
    return '$length mm';
  }

  @override
  String get applyButtonLabel => '適用';

  @override
  String get createButtonLabel => 'CREATE';

  @override
  String get deleteButtonLabel => '削除';

  @override
  String get nextButtonLabel => '次へ';

  @override
  String get showButtonLabel => '表示';

  @override
  String get hideButtonLabel => '非表示';

  @override
  String get continueButtonLabel => '続ける';

  @override
  String get saveCopyButtonLabel => 'コピーを保存';

  @override
  String get applyTooltip => '適用する';

  @override
  String get cancelTooltip => 'キャンセル';

  @override
  String get changeTooltip => '変更';

  @override
  String get clearTooltip => 'クリア';

  @override
  String get previousTooltip => '前へ';

  @override
  String get nextTooltip => '次へ';

  @override
  String get showTooltip => '表示する';

  @override
  String get hideTooltip => '非表示にする';

  @override
  String get actionRemove => '削除';

  @override
  String get resetTooltip => 'リセット';

  @override
  String get saveTooltip => '保存';

  @override
  String get stopTooltip => '停止';

  @override
  String get pickTooltip => 'ピック';

  @override
  String get doubleBackExitMessage => '終了するには「戻る」をもう一度タップしてください。';

  @override
  String get doNotAskAgain => '今後このメッセージを表示しない';

  @override
  String get sourceStateLoading => '読み込み中';

  @override
  String get sourceStateCataloguing => '分類中';

  @override
  String get sourceStateLocatingCountries => '国、地域を確認中';

  @override
  String get sourceStateLocatingPlaces => '場所を確認中';

  @override
  String get chipActionDelete => '削除';

  @override
  String get chipActionRemove => '削除';

  @override
  String get chipActionShowCollection => 'コレクションで表示';

  @override
  String get chipActionGoToAlbumPage => 'アルバム別に表示';

  @override
  String get chipActionGoToCountryPage => '国地域別に表示';

  @override
  String get chipActionGoToPlacePage => '場所別に表示';

  @override
  String get chipActionGoToTagPage => 'タグ別に表示';

  @override
  String get chipActionGoToExplorerPage => 'エクスプローラーで表示';

  @override
  String get chipActionDecompose => 'Split';

  @override
  String get chipActionFilterOut => '除外する';

  @override
  String get chipActionFilterIn => 'フィルター';

  @override
  String get chipActionHide => '非表示';

  @override
  String get chipActionLock => 'ロック';

  @override
  String get chipActionPin => '一番上に固定';

  @override
  String get chipActionUnpin => '一番上への固定を解除';

  @override
  String get chipActionGroup => 'Group';

  @override
  String get chipActionRename => '名前を変更';

  @override
  String get chipActionSetCover => 'カバーを設定';

  @override
  String get chipActionShowCountryStates => '地域を表示';

  @override
  String get chipActionCreateGroup => 'Create group';

  @override
  String get chipActionCreateAlbum => 'アルバムを作成';

  @override
  String get chipActionCreateVault => '保管庫を作成';

  @override
  String get chipActionConfigureVault => '保管庫を設定';

  @override
  String get entryActionCopyToClipboard => 'クリップボードにコピー';

  @override
  String get entryActionDelete => '削除';

  @override
  String get entryActionConvert => '変換';

  @override
  String get entryActionExport => 'エクスポート';

  @override
  String get entryActionInfo => '情報';

  @override
  String get entryActionRename => '名前を変更';

  @override
  String get entryActionRestore => '元に戻す';

  @override
  String get entryActionRotateCCW => '反時計回りに回転';

  @override
  String get entryActionRotateCW => '時計回りに回転';

  @override
  String get entryActionFlip => '水平方向に反転';

  @override
  String get entryActionPrint => '印刷';

  @override
  String get entryActionShare => '共有';

  @override
  String get entryActionShareImageOnly => '画像のみ共有';

  @override
  String get entryActionShareVideoOnly => '動画のみ共有';

  @override
  String get entryActionViewSource => 'ソースを表示';

  @override
  String get entryActionShowGeoTiffOnMap => '地図のオーバーレイとして表示';

  @override
  String get entryActionConvertMotionPhotoToStillImage => '静止画に変換';

  @override
  String get entryActionViewMotionPhotoVideo => '動画を開く';

  @override
  String get entryActionEdit => '編集';

  @override
  String get entryActionOpen => 'アプリで開く';

  @override
  String get entryActionSetAs => '登録';

  @override
  String get entryActionCast => 'キャスト';

  @override
  String get entryActionOpenMap => '地図アプリで表示';

  @override
  String get entryActionRotateScreen => '画面を回転';

  @override
  String get entryActionAddFavourite => 'お気に入りに追加';

  @override
  String get entryActionRemoveFavourite => 'お気に入りから削除';

  @override
  String get videoActionCaptureFrame => 'フレームをキャプチャ';

  @override
  String get videoActionMute => 'ミュート';

  @override
  String get videoActionUnmute => 'ミュート解除';

  @override
  String get videoActionPause => '一時停止';

  @override
  String get videoActionPlay => '再生';

  @override
  String get videoActionReplay10 => '10 秒前に戻る';

  @override
  String get videoActionSkip10 => '10 秒前に進む';

  @override
  String get videoActionShowPreviousFrame => '前のフレームを表示';

  @override
  String get videoActionShowNextFrame => '次のフレームを表示';

  @override
  String get videoActionSelectStreams => 'トラックを選択';

  @override
  String get videoActionSetSpeed => '再生速度';

  @override
  String get videoActionABRepeat => 'A-B リピート';

  @override
  String get videoRepeatActionSetStart => '開始点を設定';

  @override
  String get videoRepeatActionSetEnd => '終点を設定';

  @override
  String get viewerActionSettings => '設定';

  @override
  String get viewerActionLock => 'ビューをロック';

  @override
  String get viewerActionUnlock => 'ビューをアンロック';

  @override
  String get slideshowActionResume => '再開';

  @override
  String get slideshowActionShowInCollection => 'コレクションで表示';

  @override
  String get entryInfoActionEditDate => '日時を編集';

  @override
  String get entryInfoActionEditLocation => '位置情報を編集';

  @override
  String get entryInfoActionEditTitleDescription => 'タイトルと説明を編集';

  @override
  String get entryInfoActionEditRating => '評価を編集';

  @override
  String get entryInfoActionEditTags => 'タグを編集';

  @override
  String get entryInfoActionRemoveMetadata => 'メタデータを削除';

  @override
  String get entryInfoActionExportMetadata => 'メタデータをエクスポート';

  @override
  String get entryInfoActionRemoveLocation => '位置情報を削除';

  @override
  String get editorActionTransform => '変換';

  @override
  String get editorTransformCrop => '切り取り';

  @override
  String get editorTransformRotate => '回転';

  @override
  String get cropAspectRatioFree => 'フリー';

  @override
  String get cropAspectRatioOriginal => 'オリジナル';

  @override
  String get cropAspectRatioSquare => '正方形';

  @override
  String get filterAspectRatioLandscapeLabel => '横向き';

  @override
  String get filterAspectRatioPortraitLabel => '縦向き';

  @override
  String get filterBinLabel => 'ごみ箱';

  @override
  String get filterFavouriteLabel => 'お気に入り';

  @override
  String get filterNoDateLabel => '日付なし';

  @override
  String get filterNoAddressLabel => 'アドレスなし';

  @override
  String get filterLocatedLabel => '位置情報あり';

  @override
  String get filterNoLocationLabel => '位置情報なし';

  @override
  String get filterNoRatingLabel => '評価情報なし';

  @override
  String get filterTaggedLabel => 'タグ付き';

  @override
  String get filterNoTagLabel => 'タグ情報なし';

  @override
  String get filterNoTitleLabel => 'タイトルなし';

  @override
  String get filterOnThisDayLabel => '過去のこの日';

  @override
  String get filterRecentlyAddedLabel => '最近追加';

  @override
  String get filterRatingRejectedLabel => '拒否';

  @override
  String get filterTypeAnimatedLabel => 'アニメーション';

  @override
  String get filterTypeMotionPhotoLabel => 'モーションフォト';

  @override
  String get filterTypePanoramaLabel => 'パノラマ';

  @override
  String get filterTypeRawLabel => 'Raw';

  @override
  String get filterTypeSphericalVideoLabel => '360° 動画';

  @override
  String get filterTypeGeotiffLabel => 'GeoTIFF';

  @override
  String get filterMimeImageLabel => '画像';

  @override
  String get filterMimeVideoLabel => '動画';

  @override
  String get accessibilityAnimationsRemove => '画面効果を表示しない';

  @override
  String get accessibilityAnimationsKeep => '画面効果を表示';

  @override
  String get albumTierNew => '新規';

  @override
  String get albumTierPinned => '固定';

  @override
  String get albumTierGroups => 'Groups';

  @override
  String get albumTierSpecial => '全体';

  @override
  String get albumTierApps => 'アプリ';

  @override
  String get albumTierVaults => '保管庫';

  @override
  String get albumTierDynamic => 'ダイナミック';

  @override
  String get albumTierRegular => 'その他';

  @override
  String get coordinateFormatDms => '度分秒';

  @override
  String get coordinateFormatDdm => 'DDM';

  @override
  String get coordinateFormatDecimal => '十進角';

  @override
  String coordinateDms(String coordinate, String direction) {
    return '$direction$coordinate';
  }

  @override
  String get coordinateDmsNorth => '北緯';

  @override
  String get coordinateDmsSouth => '南緯';

  @override
  String get coordinateDmsEast => '東経';

  @override
  String get coordinateDmsWest => '西経';

  @override
  String get displayRefreshRatePreferHighest => '高レート';

  @override
  String get displayRefreshRatePreferLowest => '低レート';

  @override
  String get keepScreenOnNever => '自動オフ';

  @override
  String get keepScreenOnVideoPlayback => '動画再生時';

  @override
  String get keepScreenOnViewerOnly => 'ビューアー表示中のみ';

  @override
  String get keepScreenOnAlways => '常にオン';

  @override
  String get lengthUnitPixel => 'px';

  @override
  String get lengthUnitPercent => '%';

  @override
  String get mapStyleGoogleNormal => 'Google マップ';

  @override
  String get mapStyleGoogleHybrid => 'Google マップ（ハイブリッド）';

  @override
  String get mapStyleGoogleTerrain => 'Google マップ（地形）';

  @override
  String get mapStyleOsmLiberty => 'OSM Liberty';

  @override
  String get mapStyleOpenTopoMap => 'OpenTopoMap';

  @override
  String get mapStyleOsmHot => 'Humanitarian OSM';

  @override
  String get mapStyleStamenWatercolor => 'Stamen Watercolor';

  @override
  String get maxBrightnessNever => '無効';

  @override
  String get maxBrightnessAlways => '常時有効';

  @override
  String get nameConflictStrategyRename => '名前を変更';

  @override
  String get nameConflictStrategyReplace => '置換';

  @override
  String get nameConflictStrategySkip => 'スキップ';

  @override
  String get overlayHistogramNone => 'なし';

  @override
  String get overlayHistogramRGB => 'RGB';

  @override
  String get overlayHistogramLuminance => '明るさ';

  @override
  String get subtitlePositionTop => 'トップ';

  @override
  String get subtitlePositionBottom => '下';

  @override
  String get themeBrightnessLight => 'ライト';

  @override
  String get themeBrightnessDark => 'ダーク';

  @override
  String get themeBrightnessBlack => 'ブラック';

  @override
  String get unitSystemMetric => 'メートル法';

  @override
  String get unitSystemImperial => 'ヤード・ポンド法';

  @override
  String get vaultLockTypePattern => 'パターン';

  @override
  String get vaultLockTypePin => 'PIN';

  @override
  String get vaultLockTypePassword => 'パスワード';

  @override
  String get settingsVideoEnablePip => 'ピクチャインピクチャ';

  @override
  String get videoControlsPlayOutside => '他のプレイヤーで開く';

  @override
  String get videoLoopModeNever => 'ループ再生しない';

  @override
  String get videoLoopModeShortOnly => '短い動画のみ';

  @override
  String get videoLoopModeAlways => '常にループ再生';

  @override
  String get videoPlaybackSkip => 'スキップ';

  @override
  String get videoPlaybackMuted => 'ミュート再生';

  @override
  String get videoPlaybackWithSound => '音声あり再生';

  @override
  String get videoResumptionModeNever => '無効';

  @override
  String get videoResumptionModeAlways => '常にオン';

  @override
  String get viewerTransitionSlide => 'スライド';

  @override
  String get viewerTransitionParallax => 'パララックス';

  @override
  String get viewerTransitionFade => 'フェード';

  @override
  String get viewerTransitionZoomIn => 'ズームイン';

  @override
  String get viewerTransitionNone => 'なし';

  @override
  String get wallpaperTargetHome => 'ホーム画面';

  @override
  String get wallpaperTargetLock => 'ロック画面';

  @override
  String get wallpaperTargetHomeLock => 'ホームおよびロック画面';

  @override
  String get widgetDisplayedItemRandom => 'ランダム';

  @override
  String get widgetDisplayedItemMostRecent => '最新';

  @override
  String get widgetOpenPageHome => 'ホームを開く';

  @override
  String get widgetOpenPageCollection => 'コレクションを開く';

  @override
  String get widgetOpenPageViewer => 'ビューワーを開く';

  @override
  String get widgetTapUpdateWidget => 'ウィジェットを更新';

  @override
  String get storageVolumeDescriptionFallbackPrimary => '内蔵ストレージ';

  @override
  String get storageVolumeDescriptionFallbackNonPrimary => 'SD カード';

  @override
  String get rootDirectoryDescription => 'ルート ディレクトリ';

  @override
  String otherDirectoryDescription(String name) {
    return '“$name” ディレクトリ';
  }

  @override
  String storageAccessDialogMessage(String directory, String volume) {
    return 'このアプリにアクセスを許可するために次の画面で $directory の “$volume” を選択してください。';
  }

  @override
  String restrictedAccessDialogMessage(String directory, String volume) {
    return 'このアプリは $directory の “$volume” にあるファイルを変更できません。\n\nプリインストールされているファイル マネージャまたはギャラリー アプリを使用して他のディレクトリに移動してください。';
  }

  @override
  String notEnoughSpaceDialogMessage(String neededSize, String freeSize, String volume) {
    return 'この操作には “$volume” に $neededSize の容量が必要ですが、 残り $freeSize のみ利用可能です。';
  }

  @override
  String get missingSystemFilePickerDialogMessage => 'システム ファイル ピッカーが見つからないか、利用できません。利用可能にしてから再度お試しください。';

  @override
  String unsupportedTypeDialogMessage(int count, String types) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'この操作は次のタイプのアイテムには対応していません: $types.',
    );
    return '$_temp0';
  }

  @override
  String get nameConflictDialogSingleSourceMessage => '目的フォルダに同じ名前のファイルが存在しています。';

  @override
  String get nameConflictDialogMultipleSourceMessage => '同じ名前のファイルが存在しています。';

  @override
  String get addShortcutDialogLabel => 'ショートカット ラベル';

  @override
  String get addShortcutButtonLabel => '追加';

  @override
  String get noMatchingAppDialogMessage => '処理できるアプリが見つかりません。';

  @override
  String binEntriesConfirmationDialogMessage(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString 件のアイテムをごみ箱に移動しますか？',
      one: 'このアイテムをごみ箱に移動しますか？',
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
      other: '$countString 件のアイテムを削除しますか？',
      one: 'このアイテムを削除しますか？',
    );
    return '$_temp0';
  }

  @override
  String get moveUndatedConfirmationDialogMessage => 'いくつかのアイテムはメタデータ上に日付がありません。メタデータ上の日付が設定されない場合、この操作によりこれらの現在の日付はリセットされます';

  @override
  String get moveUndatedConfirmationDialogSetDate => '日付を設定';

  @override
  String videoResumeDialogMessage(String time) {
    return '$time の時点から再生を再開しますか?';
  }

  @override
  String get videoStartOverButtonLabel => '最初から再生';

  @override
  String get videoResumeButtonLabel => '再開';

  @override
  String get setCoverDialogLatest => '最新のアイテム';

  @override
  String get setCoverDialogAuto => '自動';

  @override
  String get setCoverDialogCustom => 'カスタム';

  @override
  String get hideFilterConfirmationDialogMessage => '一致する写真と動画はコレクションに表示されなくなります。「プライバシー」設定からいつでもアイテムを表示できます。\n\nこれらのアイテムを非表示にしますか？';

  @override
  String get newAlbumDialogTitle => '新規アルバム';

  @override
  String get newAlbumDialogNameLabel => 'アルバム名';

  @override
  String get newAlbumDialogAlbumAlreadyExistsHelper => 'アルバムはすでに存在します';

  @override
  String get newAlbumDialogNameLabelAlreadyExistsHelper => 'ディレクトリが既に存在します';

  @override
  String get newAlbumDialogStorageLabel => 'ストレージ:';

  @override
  String get newDynamicAlbumDialogTitle => '新規ダイナミックアルバム';

  @override
  String get dynamicAlbumAlreadyExists => 'ダイナミックアルバムはすでに存在します';

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
  String get newVaultWarningDialogMessage => '保管庫のアイテムはアプリ内のみで保存しているため、他のアプリでは利用できません。\n\nこのアプリをアンインストールしたり、データを消去したりすると、これらのアイテムはすべて失われます。';

  @override
  String get newVaultDialogTitle => '新しい保管庫';

  @override
  String get configureVaultDialogTitle => '保管庫の設定';

  @override
  String get vaultDialogLockModeWhenScreenOff => '画面オフ時にロック';

  @override
  String get vaultDialogLockTypeLabel => 'ロックの種類';

  @override
  String get patternDialogEnter => 'パターンを入力';

  @override
  String get patternDialogConfirm => 'パターンの確認';

  @override
  String get pinDialogEnter => 'PINを入力';

  @override
  String get pinDialogConfirm => 'PINの確認';

  @override
  String get passwordDialogEnter => 'パスワードを入力';

  @override
  String get passwordDialogConfirm => 'パスワードの確認';

  @override
  String get authenticateToConfigureVault => '認証して保管庫を設定';

  @override
  String get authenticateToUnlockVault => '認証して保管庫を解除';

  @override
  String get vaultBinUsageDialogMessage => 'ゴミ箱を使用している保管庫があります。';

  @override
  String get renameAlbumDialogLabel => '新しい名前';

  @override
  String get renameAlbumDialogLabelAlreadyExistsHelper => 'ディレクトリが既に存在します';

  @override
  String get renameEntrySetPageTitle => '名前を変更';

  @override
  String get renameEntrySetPagePatternFieldLabel => '名前付けのパターン';

  @override
  String get renameEntrySetPageInsertTooltip => 'フィールドを挿入';

  @override
  String get renameEntrySetPagePreviewSectionTitle => 'プレビュー';

  @override
  String get renameProcessorCounter => '連番';

  @override
  String get renameProcessorHash => 'ハッシュ';

  @override
  String get renameProcessorName => '名前';

  @override
  String deleteSingleAlbumConfirmationDialogMessage(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'このアルバムとアルバム内の $countString 件のアイテムを削除しますか？',
      one: 'このアルバムとアルバム内のアイテムを削除しますか？',
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
      other: 'これらのアルバムとアルバム内の $countString 件のアイテムを削除しますか？',
      one: 'これらのアルバムとアルバム内のアイテムを削除しますか？',
    );
    return '$_temp0';
  }

  @override
  String get exportEntryDialogFormat => '形式:';

  @override
  String get exportEntryDialogWidth => '幅';

  @override
  String get exportEntryDialogHeight => '高さ';

  @override
  String get exportEntryDialogQuality => '画質';

  @override
  String get exportEntryDialogWriteMetadata => 'メタデータを書き込む';

  @override
  String get renameEntryDialogLabel => '新しい名前';

  @override
  String get editEntryDialogCopyFromItem => '他のアイテムからコピーする';

  @override
  String get editEntryDialogTargetFieldsHeader => '更新するフィールド';

  @override
  String get editEntryDateDialogTitle => '日時';

  @override
  String get editEntryDateDialogSetCustom => '日を設定する';

  @override
  String get editEntryDateDialogCopyField => '他の日からコピーする';

  @override
  String get editEntryDateDialogExtractFromTitle => 'タイトルから抽出する';

  @override
  String get editEntryDateDialogShift => 'シフト';

  @override
  String get editEntryDateDialogSourceFileModifiedDate => 'ファイル更新日';

  @override
  String get durationDialogHours => '時';

  @override
  String get durationDialogMinutes => '分';

  @override
  String get durationDialogSeconds => '秒';

  @override
  String get editEntryLocationDialogTitle => '位置情報';

  @override
  String get editEntryLocationDialogSetCustom => 'カスタムの場所を設定する';

  @override
  String get editEntryLocationDialogChooseOnMap => '地図上で選択';

  @override
  String get editEntryLocationDialogImportGpx => 'Import GPX';

  @override
  String get editEntryLocationDialogLatitude => '緯度';

  @override
  String get editEntryLocationDialogLongitude => '経度';

  @override
  String get editEntryLocationDialogTimeShift => 'Time shift';

  @override
  String get locationPickerUseThisLocationButton => 'この位置情報を使用';

  @override
  String get editEntryRatingDialogTitle => '評価';

  @override
  String get removeEntryMetadataDialogTitle => 'メタデータの削除';

  @override
  String get removeEntryMetadataDialogAll => 'All';

  @override
  String get removeEntryMetadataDialogMore => 'もっと見る';

  @override
  String get removeEntryMetadataMotionPhotoXmpWarningDialogMessage => 'モーションフォト内の動画を再生するには XMP が必要です。\n\n削除しますか？';

  @override
  String get videoSpeedDialogLabel => '再生速度';

  @override
  String get videoStreamSelectionDialogVideo => '動画';

  @override
  String get videoStreamSelectionDialogAudio => '音声';

  @override
  String get videoStreamSelectionDialogText => '字幕';

  @override
  String get videoStreamSelectionDialogOff => 'オフ';

  @override
  String get videoStreamSelectionDialogTrack => 'トラック';

  @override
  String get videoStreamSelectionDialogNoSelection => '他にトラックはありません。';

  @override
  String get genericSuccessFeedback => '完了しました！';

  @override
  String get genericFailureFeedback => 'エラー';

  @override
  String get genericDangerWarningDialogMessage => '適用しますか？';

  @override
  String get tooManyItemsErrorDialogMessage => '少ないアイテムで再度試してください。';

  @override
  String get menuActionConfigureView => '表示';

  @override
  String get menuActionSelect => '選択';

  @override
  String get menuActionSelectAll => 'すべて選択';

  @override
  String get menuActionSelectNone => '選択を解除';

  @override
  String get menuActionMap => '地図';

  @override
  String get menuActionSlideshow => 'スライドショー';

  @override
  String get menuActionStats => '統計';

  @override
  String get viewDialogSortSectionTitle => '並べ替え';

  @override
  String get viewDialogGroupSectionTitle => 'グループ';

  @override
  String get viewDialogLayoutSectionTitle => 'レイアウト';

  @override
  String get viewDialogReverseSortOrder => '並び順を反転';

  @override
  String get tileLayoutMosaic => 'モザイク';

  @override
  String get tileLayoutGrid => 'グリッド表示';

  @override
  String get tileLayoutList => 'リスト表示';

  @override
  String get castDialogTitle => 'キャストデバイス';

  @override
  String get coverDialogTabCover => 'カバー';

  @override
  String get coverDialogTabApp => 'アプリ';

  @override
  String get coverDialogTabColor => 'カラー';

  @override
  String get appPickDialogTitle => 'アプリを選ぶ';

  @override
  String get appPickDialogNone => 'なし';

  @override
  String get aboutPageTitle => 'アプリについて';

  @override
  String get aboutLinkLicense => 'ライセンス';

  @override
  String get aboutLinkPolicy => 'プライバシー ポリシー';

  @override
  String get aboutBugSectionTitle => 'バグの報告';

  @override
  String get aboutBugSaveLogInstruction => 'アプリのログをファイルに保存';

  @override
  String get aboutBugCopyInfoInstruction => 'システム情報をコピー';

  @override
  String get aboutBugCopyInfoButton => 'コピー';

  @override
  String get aboutBugReportInstruction => 'ログとシステム情報とともに GitHub で報告';

  @override
  String get aboutBugReportButton => '報告';

  @override
  String get aboutDataUsageSectionTitle => 'データ使用量';

  @override
  String get aboutDataUsageData => 'データ';

  @override
  String get aboutDataUsageCache => 'キャッシュ';

  @override
  String get aboutDataUsageDatabase => 'データベース';

  @override
  String get aboutDataUsageMisc => 'その他';

  @override
  String get aboutDataUsageInternal => '内部ストレージ';

  @override
  String get aboutDataUsageExternal => '外部ストレージ';

  @override
  String get aboutDataUsageClearCache => 'キャッシュを削除';

  @override
  String get aboutCreditsSectionTitle => 'クレジット';

  @override
  String get aboutCreditsWorldAtlas1 => 'このアプリは TopoJSON ファイルを';

  @override
  String get aboutCreditsWorldAtlas2 => 'ISC License の下使用しています。';

  @override
  String get aboutTranslatorsSectionTitle => '翻訳';

  @override
  String get aboutLicensesSectionTitle => 'オープンソース ライセンス';

  @override
  String get aboutLicensesBanner => 'このアプリは下記のオープンソース パッケージおよびライブラリを使用しています。';

  @override
  String get aboutLicensesAndroidLibrariesSectionTitle => 'Android ライブラリ';

  @override
  String get aboutLicensesFlutterPluginsSectionTitle => 'Flutter プラグイン';

  @override
  String get aboutLicensesFlutterPackagesSectionTitle => 'Flutter パッケージ';

  @override
  String get aboutLicensesDartPackagesSectionTitle => 'Dart パッケージ';

  @override
  String get aboutLicensesShowAllButtonLabel => 'すべてのライセンスを表示';

  @override
  String get policyPageTitle => 'プライバシー ポリシー';

  @override
  String get collectionPageTitle => 'コレクション';

  @override
  String get collectionPickPageTitle => 'ピック';

  @override
  String get collectionSelectPageTitle => 'アイテムを選択';

  @override
  String get collectionActionShowTitleSearch => 'タイトル名フィルターを表示';

  @override
  String get collectionActionHideTitleSearch => 'タイトル名フィルターを非表示';

  @override
  String get collectionActionAddDynamicAlbum => 'ダイナミックアルバムを追加';

  @override
  String get collectionActionAddShortcut => 'ショートカットを追加';

  @override
  String get collectionActionSetHome => 'ホームに設定';

  @override
  String get collectionActionEmptyBin => 'ごみ箱を空にする';

  @override
  String get collectionActionCopy => 'アルバムにコピー';

  @override
  String get collectionActionMove => 'アルバムに移動';

  @override
  String get collectionActionRescan => '再スキャン';

  @override
  String get collectionActionEdit => '編集';

  @override
  String get collectionSearchTitlesHintText => 'タイトルを検索';

  @override
  String get collectionGroupAlbum => 'アルバム別';

  @override
  String get collectionGroupMonth => '月別';

  @override
  String get collectionGroupDay => '日別';

  @override
  String get sectionNone => 'No sections';

  @override
  String get sectionUnknown => '不明';

  @override
  String get dateToday => '今日';

  @override
  String get dateYesterday => '昨日';

  @override
  String get dateThisMonth => '今月';

  @override
  String collectionDeleteFailureFeedback(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString 件のアイテムを削除できませんでした',
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
      other: '$countString 件のアイテムをコピーできませんでした',
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
      other: '$countString 件のアイテムを移動できませんでした',
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
      other: '$countString 件のアイテム名を変更できませんでした',
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
      other: '$countString 件のアイテムを編集できませんでした',
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
      other: '$countString ページをエクスポートできませんでした',
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
      other: '$countString 件のアイテムをコピーしました',
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
      other: '$countString 件のアイテムを移動しました',
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
      other: '$countString 件のアイテム名を変更しました',
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
      other: '$countString 件のアイテムを編集しました',
    );
    return '$_temp0';
  }

  @override
  String get collectionEmptyFavourites => 'お気に入りはありません';

  @override
  String get collectionEmptyVideos => '動画はありません';

  @override
  String get collectionEmptyImages => '画像はありません';

  @override
  String get collectionEmptyGrantAccessButtonLabel => 'アクセスを許可';

  @override
  String get collectionSelectSectionTooltip => 'セクションを選択';

  @override
  String get collectionDeselectSectionTooltip => 'セクションの選択を解除';

  @override
  String get drawerAboutButton => 'アプリについて';

  @override
  String get drawerSettingsButton => '設定';

  @override
  String get drawerCollectionAll => 'すべてのコレクション';

  @override
  String get drawerCollectionFavourites => 'お気に入り';

  @override
  String get drawerCollectionImages => '画像';

  @override
  String get drawerCollectionVideos => '動画';

  @override
  String get drawerCollectionAnimated => 'アニメーション';

  @override
  String get drawerCollectionMotionPhotos => 'モーションフォト';

  @override
  String get drawerCollectionPanoramas => 'パノラマ';

  @override
  String get drawerCollectionRaws => 'Raw 写真';

  @override
  String get drawerCollectionSphericalVideos => '360° 動画';

  @override
  String get drawerAlbumPage => 'アルバム';

  @override
  String get drawerCountryPage => '国';

  @override
  String get drawerPlacePage => '場所';

  @override
  String get drawerTagPage => 'タグ';

  @override
  String get sortByDate => '日付';

  @override
  String get sortByName => '名前';

  @override
  String get sortByItemCount => 'アイテム件数';

  @override
  String get sortBySize => 'サイズ';

  @override
  String get sortByAlbumFileName => 'アルバムとファイル名';

  @override
  String get sortByRating => '評価';

  @override
  String get sortByDuration => '期間順';

  @override
  String get sortByPath => 'By path';

  @override
  String get sortOrderNewestFirst => '新しいものから表示';

  @override
  String get sortOrderOldestFirst => '古いものから表示';

  @override
  String get sortOrderAtoZ => 'AからZ';

  @override
  String get sortOrderZtoA => 'ZからA';

  @override
  String get sortOrderHighestFirst => '高いものから表示';

  @override
  String get sortOrderLowestFirst => '低いものから表示';

  @override
  String get sortOrderLargestFirst => '大きいものから表示';

  @override
  String get sortOrderSmallestFirst => '小さいものから表示';

  @override
  String get sortOrderShortestFirst => '短いものから表示';

  @override
  String get sortOrderLongestFirst => '長いものから表示';

  @override
  String get albumGroupTier => '階層別';

  @override
  String get albumGroupType => 'タイプ別';

  @override
  String get albumGroupVolume => 'ストレージ ボリューム別';

  @override
  String get albumMimeTypeMixed => '混合';

  @override
  String get albumPickPageTitleCopy => 'アルバムにコピー';

  @override
  String get albumPickPageTitleExport => 'アルバムにエクスポート';

  @override
  String get albumPickPageTitleMove => 'アルバムに移動';

  @override
  String get albumPickPageTitlePick => 'アルバムを選択';

  @override
  String get albumCamera => 'カメラ';

  @override
  String get albumDownload => 'ダウンロード';

  @override
  String get albumScreenshots => 'スクリーンショット';

  @override
  String get albumScreenRecordings => '画面録画';

  @override
  String get albumVideoCaptures => '動画キャプチャ';

  @override
  String get albumPageTitle => 'アルバム';

  @override
  String get albumEmpty => 'アルバムはありません';

  @override
  String get createAlbumButtonLabel => '作成';

  @override
  String get newFilterBanner => '新規';

  @override
  String get countryPageTitle => '国';

  @override
  String get countryEmpty => '国はありません';

  @override
  String get statePageTitle => '州';

  @override
  String get stateEmpty => '州なし';

  @override
  String get placePageTitle => '場所';

  @override
  String get placeEmpty => '場所なし';

  @override
  String get tagPageTitle => 'タグ';

  @override
  String get tagEmpty => 'タグはありません';

  @override
  String get binPageTitle => 'ごみ箱';

  @override
  String get explorerPageTitle => 'エクスプローラー';

  @override
  String get explorerActionSelectStorageVolume => 'ストレージを選択';

  @override
  String get selectStorageVolumeDialogTitle => 'ストレージを選択';

  @override
  String get searchCollectionFieldHint => 'コレクションを検索';

  @override
  String get searchRecentSectionTitle => '最近';

  @override
  String get searchDateSectionTitle => '日付';

  @override
  String get searchFormatSectionTitle => 'Formats';

  @override
  String get searchAlbumsSectionTitle => 'アルバム';

  @override
  String get searchCountriesSectionTitle => '国';

  @override
  String get searchStatesSectionTitle => '地域';

  @override
  String get searchPlacesSectionTitle => '場所';

  @override
  String get searchTagsSectionTitle => 'タグ';

  @override
  String get searchRatingSectionTitle => '評価';

  @override
  String get searchMetadataSectionTitle => 'メタデータ';

  @override
  String get settingsPageTitle => '設定';

  @override
  String get settingsSystemDefault => 'システム';

  @override
  String get settingsDefault => 'デフォルト';

  @override
  String get settingsDisabled => '無効';

  @override
  String get settingsAskEverytime => '都度選択';

  @override
  String get settingsModificationWarningDialogMessage => '他の設定は変更されます。';

  @override
  String get settingsSearchFieldLabel => '検索設定';

  @override
  String get settingsSearchEmpty => '一致する設定なし';

  @override
  String get settingsActionExport => 'エクスポート';

  @override
  String get settingsActionExportDialogTitle => 'エクスポート';

  @override
  String get settingsActionImport => 'インポート';

  @override
  String get settingsActionImportDialogTitle => 'インポート';

  @override
  String get appExportCovers => 'カバー';

  @override
  String get appExportDynamicAlbums => 'ダイナミックアルバム';

  @override
  String get appExportFavourites => 'お気に入り';

  @override
  String get appExportSettings => '設定';

  @override
  String get settingsNavigationSectionTitle => 'ナビゲーション';

  @override
  String get settingsHomeTile => 'ホーム';

  @override
  String get settingsHomeDialogTitle => 'ホーム';

  @override
  String get setHomeCustom => 'カスタム';

  @override
  String get settingsShowBottomNavigationBar => '下部のナビゲーションバーを表示';

  @override
  String get settingsKeepScreenOnTile => '画面をオンのままにする';

  @override
  String get settingsKeepScreenOnDialogTitle => '画面をオンのままにする';

  @override
  String get settingsDoubleBackExit => '「戻る」を２回タップして終了';

  @override
  String get settingsConfirmationTile => '確認メッセージ';

  @override
  String get settingsConfirmationDialogTitle => '確認メッセージ';

  @override
  String get settingsConfirmationBeforeDeleteItems => 'アイテムを完全に削除する前に確認';

  @override
  String get settingsConfirmationBeforeMoveToBinItems => 'アイテムをごみ箱に移動する前に確認';

  @override
  String get settingsConfirmationBeforeMoveUndatedItems => 'メタデータ上に日付のないアイテムを移動する前に確認';

  @override
  String get settingsConfirmationAfterMoveToBinItems => 'ゴミ箱に移動したらメッセージを表示';

  @override
  String get settingsConfirmationVaultDataLoss => '保管庫のデータ損失警告を表示する';

  @override
  String get settingsNavigationDrawerTile => 'ナビゲーション メニュー';

  @override
  String get settingsNavigationDrawerEditorPageTitle => 'ナビゲーション メニュー';

  @override
  String get settingsNavigationDrawerBanner => 'メニュー項目を長押しして、移動および並べ替え';

  @override
  String get settingsNavigationDrawerTabTypes => 'タイプ';

  @override
  String get settingsNavigationDrawerTabAlbums => 'アルバム';

  @override
  String get settingsNavigationDrawerTabPages => 'ページ';

  @override
  String get settingsNavigationDrawerAddAlbum => 'アルバムを追加';

  @override
  String get settingsThumbnailSectionTitle => 'サムネイル';

  @override
  String get settingsThumbnailOverlayTile => 'オーバーレイ';

  @override
  String get settingsThumbnailOverlayPageTitle => 'オーバーレイ';

  @override
  String get settingsThumbnailShowHdrIcon => 'HDRアイコンを表示';

  @override
  String get settingsThumbnailShowFavouriteIcon => 'お気に入りアイコンを表示';

  @override
  String get settingsThumbnailShowTagIcon => 'タグアイコンを表示';

  @override
  String get settingsThumbnailShowLocationIcon => '位置情報アイコンを表示';

  @override
  String get settingsThumbnailShowMotionPhotoIcon => 'モーションフォトアイコンを表示';

  @override
  String get settingsThumbnailShowRating => '評価情報を表示';

  @override
  String get settingsThumbnailShowRawIcon => 'Raw アイコンを表示';

  @override
  String get settingsThumbnailShowVideoDuration => '動画の再生時間を表示';

  @override
  String get settingsCollectionQuickActionsTile => 'クイック アクション';

  @override
  String get settingsCollectionQuickActionEditorPageTitle => 'クイック アクション';

  @override
  String get settingsCollectionQuickActionTabBrowsing => 'ブラウズ中';

  @override
  String get settingsCollectionQuickActionTabSelecting => '選択中';

  @override
  String get settingsCollectionBrowsingQuickActionEditorBanner => '長押ししてボタンを移動しアイテムを閲覧中に表示されるアクションを選択します。';

  @override
  String get settingsCollectionSelectionQuickActionEditorBanner => '長押ししてボタンを移動しアイテムを選択中に表示されるアクションを選択します。';

  @override
  String get settingsCollectionBurstPatternsTile => 'バーストパターン';

  @override
  String get settingsCollectionBurstPatternsNone => 'なし';

  @override
  String get settingsViewerSectionTitle => 'ビューアー';

  @override
  String get settingsViewerGestureSideTapNext => '画面の端をタップして進む/戻る';

  @override
  String get settingsViewerUseCutout => '切り取り領域を使用';

  @override
  String get settingsViewerMaximumBrightness => '明るさ最大';

  @override
  String get settingsMotionPhotoAutoPlay => 'モーションフォトを自動再生';

  @override
  String get settingsImageBackground => '画像の背景';

  @override
  String get settingsViewerQuickActionsTile => 'クイックアクション';

  @override
  String get settingsViewerQuickActionEditorPageTitle => 'クイックアクション';

  @override
  String get settingsViewerQuickActionEditorBanner => '長押ししてボタンを移動しビューアーで表示されるアクションを選択します。';

  @override
  String get settingsViewerQuickActionEditorDisplayedButtonsSectionTitle => '表示ボタン';

  @override
  String get settingsViewerQuickActionEditorAvailableButtonsSectionTitle => '利用可能なボタン';

  @override
  String get settingsViewerQuickActionEmpty => 'ボタンなし';

  @override
  String get settingsViewerOverlayTile => 'オーバーレイ';

  @override
  String get settingsViewerOverlayPageTitle => 'オーバーレイ';

  @override
  String get settingsViewerShowOverlayOnOpening => '起動時に表示';

  @override
  String get settingsViewerShowHistogram => 'ヒストグラムを表示';

  @override
  String get settingsViewerShowMinimap => '小さな地図を表示';

  @override
  String get settingsViewerShowInformation => '情報を表示';

  @override
  String get settingsViewerShowInformationSubtitle => 'タイトル、日付、位置情報、その他を表示';

  @override
  String get settingsViewerShowRatingTags => '評価とタグを表示';

  @override
  String get settingsViewerShowShootingDetails => '撮影詳細を表示';

  @override
  String get settingsViewerShowDescription => '説明を表示';

  @override
  String get settingsViewerShowOverlayThumbnails => 'サムネイルを表示';

  @override
  String get settingsViewerEnableOverlayBlurEffect => 'ぼかし効果';

  @override
  String get settingsViewerSlideshowTile => 'スライドショー';

  @override
  String get settingsViewerSlideshowPageTitle => 'スライドショー';

  @override
  String get settingsSlideshowRepeat => '繰り返し';

  @override
  String get settingsSlideshowShuffle => 'シャッフル';

  @override
  String get settingsSlideshowFillScreen => '画面いっぱいに表示';

  @override
  String get settingsSlideshowAnimatedZoomEffect => 'アニメーション付きのズーム効果';

  @override
  String get settingsSlideshowTransitionTile => 'トランジション';

  @override
  String get settingsSlideshowIntervalTile => '間隔';

  @override
  String get settingsSlideshowVideoPlaybackTile => '動画を再生';

  @override
  String get settingsSlideshowVideoPlaybackDialogTitle => '動画再生';

  @override
  String get settingsVideoPageTitle => '動画設定';

  @override
  String get settingsVideoSectionTitle => '動画';

  @override
  String get settingsVideoShowVideos => '動画を表示';

  @override
  String get settingsVideoPlaybackTile => '再生';

  @override
  String get settingsVideoPlaybackPageTitle => '再生';

  @override
  String get settingsVideoEnableHardwareAcceleration => 'ハードウェア アクセラレーション';

  @override
  String get settingsVideoAutoPlay => '自動再生';

  @override
  String get settingsVideoLoopModeTile => 'ループ モード';

  @override
  String get settingsVideoLoopModeDialogTitle => 'ループ モード';

  @override
  String get settingsVideoResumptionModeTile => '前回の位置からの再生';

  @override
  String get settingsVideoResumptionModeDialogTitle => '前回の位置からの再生';

  @override
  String get settingsVideoBackgroundMode => 'バックグラウンド再生';

  @override
  String get settingsVideoBackgroundModeDialogTitle => 'バックグラウンド再生';

  @override
  String get settingsVideoControlsTile => '操作';

  @override
  String get settingsVideoControlsPageTitle => '操作';

  @override
  String get settingsVideoButtonsTile => 'ボタン';

  @override
  String get settingsVideoGestureDoubleTapTogglePlay => '２回タップして再生/一時停止';

  @override
  String get settingsVideoGestureSideDoubleTapSeek => '画面の角を２回タップして早送り/早戻し';

  @override
  String get settingsVideoGestureVerticalDragBrightnessVolume => '左右で上下にスワイプして輝度と音量を調節';

  @override
  String get settingsSubtitleThemeTile => '字幕';

  @override
  String get settingsSubtitleThemePageTitle => '字幕';

  @override
  String get settingsSubtitleThemeSample => 'これはサンプルです。';

  @override
  String get settingsSubtitleThemeTextAlignmentTile => 'テキストの配置';

  @override
  String get settingsSubtitleThemeTextAlignmentDialogTitle => 'テキストの配置';

  @override
  String get settingsSubtitleThemeTextPositionTile => 'テキストの位置';

  @override
  String get settingsSubtitleThemeTextPositionDialogTitle => 'テキストの位置';

  @override
  String get settingsSubtitleThemeTextSize => 'テキストのサイズ';

  @override
  String get settingsSubtitleThemeShowOutline => 'アウトラインと影を表示';

  @override
  String get settingsSubtitleThemeTextColor => 'テキストの色';

  @override
  String get settingsSubtitleThemeTextOpacity => 'テキストの不透明度';

  @override
  String get settingsSubtitleThemeBackgroundColor => '背景色';

  @override
  String get settingsSubtitleThemeBackgroundOpacity => '背景の不透明度';

  @override
  String get settingsSubtitleThemeTextAlignmentLeft => '左揃え';

  @override
  String get settingsSubtitleThemeTextAlignmentCenter => '中央揃え';

  @override
  String get settingsSubtitleThemeTextAlignmentRight => '右揃え';

  @override
  String get settingsPrivacySectionTitle => 'プライバシー';

  @override
  String get settingsAllowInstalledAppAccess => 'アプリのインベントリへのアクセスを許可する';

  @override
  String get settingsAllowInstalledAppAccessSubtitle => 'アルバム表示の改善に使用されます';

  @override
  String get settingsAllowErrorReporting => '匿名でのエラー報告を許可する';

  @override
  String get settingsSaveSearchHistory => '検索履歴を保存';

  @override
  String get settingsEnableBin => 'ごみ箱を使用';

  @override
  String get settingsEnableBinSubtitle => '削除したアイテムを30日間保持します';

  @override
  String get settingsDisablingBinWarningDialogMessage => 'ごみ箱の中のアイテムは永久に削除されます。';

  @override
  String get settingsAllowMediaManagement => 'メディア管理を許可';

  @override
  String get settingsHiddenItemsTile => '非表示アイテム';

  @override
  String get settingsHiddenItemsPageTitle => '非表示アイテム';

  @override
  String get settingsHiddenFiltersBanner => '非表示のフィルターに一致する写真と動画は、コレクションに表示されません。';

  @override
  String get settingsHiddenFiltersEmpty => '非表示フィルターがありません';

  @override
  String get settingsStorageAccessTile => 'ストレージへのアクセス';

  @override
  String get settingsStorageAccessPageTitle => 'ストレージへのアクセス';

  @override
  String get settingsStorageAccessBanner => 'ディレクトリによっては、ファイルの編集のためにアクセス許可が必要です。ここには、これまでにアクセスを許可したディレクトリが表示されます。';

  @override
  String get settingsStorageAccessEmpty => '許可したアクセスはありません';

  @override
  String get settingsStorageAccessRevokeTooltip => '許可を取り消し';

  @override
  String get settingsAccessibilitySectionTitle => 'アクセシビリティ';

  @override
  String get settingsRemoveAnimationsTile => 'アニメーションの削除';

  @override
  String get settingsRemoveAnimationsDialogTitle => 'アニメーションの削除';

  @override
  String get settingsTimeToTakeActionTile => '操作までの時間';

  @override
  String get settingsAccessibilityShowPinchGestureAlternatives => 'マルチタッチジェスチャーの選択肢を表示する';

  @override
  String get settingsDisplaySectionTitle => 'ディスプレイ';

  @override
  String get settingsThemeBrightnessTile => 'テーマ';

  @override
  String get settingsThemeBrightnessDialogTitle => 'テーマ';

  @override
  String get settingsThemeColorHighlights => 'カラー強調表示';

  @override
  String get settingsThemeEnableDynamicColor => 'ダイナミックカラー';

  @override
  String get settingsDisplayRefreshRateModeTile => 'ディスプレイ リフレッシュ レート';

  @override
  String get settingsDisplayRefreshRateModeDialogTitle => 'リフレッシュ レート';

  @override
  String get settingsDisplayUseTvInterface => 'Android TV インターフェイス';

  @override
  String get settingsLanguageSectionTitle => '言語と形式';

  @override
  String get settingsLanguageTile => '言語';

  @override
  String get settingsLanguagePageTitle => '言語';

  @override
  String get settingsCoordinateFormatTile => '座標形式';

  @override
  String get settingsCoordinateFormatDialogTitle => '座標形式';

  @override
  String get settingsUnitSystemTile => '単位';

  @override
  String get settingsUnitSystemDialogTitle => '単位';

  @override
  String get settingsForceWesternArabicNumeralsTile => 'アラビア数字を強制する';

  @override
  String get settingsScreenSaverPageTitle => 'スクリーンセーバー';

  @override
  String get settingsWidgetPageTitle => 'フォトフレーム';

  @override
  String get settingsWidgetShowOutline => '枠';

  @override
  String get settingsWidgetOpenPage => 'ウィジェットをタップしたとき';

  @override
  String get settingsWidgetDisplayedItem => '表示アイテム';

  @override
  String get settingsCollectionTile => 'コレクション';

  @override
  String get statsPageTitle => '統計';

  @override
  String statsWithGps(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '位置情報のあるアイテム $countString 件',
    );
    return '$_temp0';
  }

  @override
  String get statsTopCountriesSectionTitle => '上位の国';

  @override
  String get statsTopStatesSectionTitle => 'トップ地域';

  @override
  String get statsTopPlacesSectionTitle => '上位の場所';

  @override
  String get statsTopTagsSectionTitle => '上位のタグ';

  @override
  String get statsTopAlbumsSectionTitle => 'トップアルバム';

  @override
  String get viewerOpenPanoramaButtonLabel => 'パノラマを開く';

  @override
  String get viewerSetWallpaperButtonLabel => '壁紙設定';

  @override
  String get viewerErrorUnknown => 'エラー!';

  @override
  String get viewerErrorDoesNotExist => 'ファイルが存在しません。';

  @override
  String get viewerInfoPageTitle => '情報';

  @override
  String get viewerInfoBackToViewerTooltip => 'ビューアーに戻る';

  @override
  String get viewerInfoUnknown => '不明';

  @override
  String get viewerInfoLabelDescription => '説明';

  @override
  String get viewerInfoLabelTitle => 'タイトル';

  @override
  String get viewerInfoLabelDate => '日付';

  @override
  String get viewerInfoLabelResolution => '解像度';

  @override
  String get viewerInfoLabelSize => 'サイズ';

  @override
  String get viewerInfoLabelUri => 'URI';

  @override
  String get viewerInfoLabelPath => 'パス';

  @override
  String get viewerInfoLabelDuration => '再生時間';

  @override
  String get viewerInfoLabelOwner => '所有者';

  @override
  String get viewerInfoLabelCoordinates => '座標';

  @override
  String get viewerInfoLabelAddress => 'アドレス';

  @override
  String get mapStyleDialogTitle => '地図のスタイル';

  @override
  String get mapStyleTooltip => '地図のスタイルを選択';

  @override
  String get mapZoomInTooltip => 'ズームイン';

  @override
  String get mapZoomOutTooltip => 'ズームアウト';

  @override
  String get mapPointNorthUpTooltip => '北が上になるように表示';

  @override
  String get mapAttributionOsmData => '地図データ © [OpenStreetMap](https://www.openstreetmap.org/copyright) contributors';

  @override
  String get mapAttributionOsmLiberty => 'Tiles by [OpenMapTiles](https://www.openmaptiles.org/), [CC BY](http://creativecommons.org/licenses/by/4.0) • Hosted by [OSM Americana](https://tile.ourmap.us)';

  @override
  String get mapAttributionOpenTopoMap => '[SRTM](https://www.earthdata.nasa.gov/sensors/srtm) | Tiles by [OpenTopoMap](https://opentopomap.org/), [CC BY-SA](https://creativecommons.org/licenses/by-sa/3.0/)';

  @override
  String get mapAttributionOsmHot => 'Tiles by [HOT](https://www.hotosm.org/) • Hosted by [OSM France](https://openstreetmap.fr/)';

  @override
  String get mapAttributionStamen => 'Tiles by [Stamen Design](https://stamen.com), [CC BY 3.0](https://creativecommons.org/licenses/by/3.0)';

  @override
  String get openMapPageTooltip => '地図ページで表示';

  @override
  String get mapEmptyRegion => 'この地域の画像はありません';

  @override
  String get viewerInfoOpenEmbeddedFailureFeedback => '埋め込みデータを抽出できませんでした';

  @override
  String get viewerInfoOpenLinkText => '開く';

  @override
  String get viewerInfoViewXmlLinkText => 'XML を表示';

  @override
  String get viewerInfoSearchFieldLabel => 'メタデータを検索';

  @override
  String get viewerInfoSearchEmpty => '一致するキーはありません';

  @override
  String get viewerInfoSearchSuggestionDate => '日時';

  @override
  String get viewerInfoSearchSuggestionDescription => '説明';

  @override
  String get viewerInfoSearchSuggestionDimensions => '寸法';

  @override
  String get viewerInfoSearchSuggestionResolution => '解像度';

  @override
  String get viewerInfoSearchSuggestionRights => '権限';

  @override
  String get wallpaperUseScrollEffect => 'ホーム画面でスクロール効果を使う';

  @override
  String get tagEditorPageTitle => 'タグの編集';

  @override
  String get tagEditorPageNewTagFieldLabel => '新しいタグ';

  @override
  String get tagEditorPageAddTagTooltip => 'タグを追加';

  @override
  String get tagEditorSectionRecent => '最近';

  @override
  String get tagEditorSectionPlaceholders => 'プレースホルダー';

  @override
  String get tagEditorDiscardDialogMessage => '変更を破棄しますか？';

  @override
  String get tagPlaceholderCountry => '国';

  @override
  String get tagPlaceholderState => '州';

  @override
  String get tagPlaceholderPlace => '場所';

  @override
  String get panoramaEnableSensorControl => 'センサー制御を有効にする';

  @override
  String get panoramaDisableSensorControl => 'センサー制御を無効にする';

  @override
  String get sourceViewerPageTitle => 'ソース';
}
