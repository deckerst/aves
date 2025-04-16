// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'Aves';

  @override
  String get welcomeMessage => 'Aves\'e Hoş Geldiniz';

  @override
  String get welcomeOptional => 'İsteğe bağlı';

  @override
  String get welcomeTermsToggle => 'Hüküm ve koşulları kabul ediyorum';

  @override
  String itemCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString öge',
    );
    return '$_temp0';
  }

  @override
  String columnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sütun',
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
      other: '$countString saniye',
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
      other: '$countString dakika',
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
      other: '$countString gün',
    );
    return '$_temp0';
  }

  @override
  String focalLength(String length) {
    return '$length mm';
  }

  @override
  String get applyButtonLabel => 'UYGULA';

  @override
  String get deleteButtonLabel => 'SİL';

  @override
  String get nextButtonLabel => 'SONRAKİ';

  @override
  String get showButtonLabel => 'GÖSTER';

  @override
  String get hideButtonLabel => 'GİZLE';

  @override
  String get continueButtonLabel => 'DEVAM ET';

  @override
  String get saveCopyButtonLabel => 'KOPYAYI KAYDET';

  @override
  String get applyTooltip => 'Uygula';

  @override
  String get cancelTooltip => 'İptal';

  @override
  String get changeTooltip => 'Değiştir';

  @override
  String get clearTooltip => 'Temizle';

  @override
  String get previousTooltip => 'Önceki';

  @override
  String get nextTooltip => 'Sonraki';

  @override
  String get showTooltip => 'Göster';

  @override
  String get hideTooltip => 'Gizle';

  @override
  String get actionRemove => 'Kaldır';

  @override
  String get resetTooltip => 'Sıfırla';

  @override
  String get saveTooltip => 'Kaydet';

  @override
  String get stopTooltip => 'Bitir';

  @override
  String get pickTooltip => 'Seç';

  @override
  String get doubleBackExitMessage => 'Çıkmak için tekrar “geri”, düğmesine dokunun.';

  @override
  String get doNotAskAgain => 'Bir daha sorma';

  @override
  String get sourceStateLoading => 'Yükleniyor';

  @override
  String get sourceStateCataloguing => 'Kataloglanıyor';

  @override
  String get sourceStateLocatingCountries => 'Ülkeler konumlandırılıyor';

  @override
  String get sourceStateLocatingPlaces => 'Konum belirleniyor';

  @override
  String get chipActionDelete => 'Sil';

  @override
  String get chipActionRemove => 'Kaldır';

  @override
  String get chipActionShowCollection => 'Koleksiyonda göster';

  @override
  String get chipActionGoToAlbumPage => 'Albümlerde göster';

  @override
  String get chipActionGoToCountryPage => 'Ülkelerde göster';

  @override
  String get chipActionGoToPlacePage => 'Yerler\'de Göster';

  @override
  String get chipActionGoToTagPage => 'Etiketlerde göster';

  @override
  String get chipActionGoToExplorerPage => 'Gezginde göster';

  @override
  String get chipActionDecompose => 'Böl';

  @override
  String get chipActionFilterOut => 'Dışarıda bırak';

  @override
  String get chipActionFilterIn => 'İçeriye al';

  @override
  String get chipActionHide => 'Gizle';

  @override
  String get chipActionLock => 'Kilitle';

  @override
  String get chipActionPin => 'Başa sabitle';

  @override
  String get chipActionUnpin => 'Sabitlemeyi kaldır';

  @override
  String get chipActionRename => 'Yeniden adlandır';

  @override
  String get chipActionSetCover => 'Kapağı ayarla';

  @override
  String get chipActionShowCountryStates => 'Eyaletleri göster';

  @override
  String get chipActionCreateAlbum => 'Albüm oluştur';

  @override
  String get chipActionCreateVault => 'Kilitli albüm oluştur';

  @override
  String get chipActionConfigureVault => 'Kilitli albüm ayarları';

  @override
  String get entryActionCopyToClipboard => 'Panoya kopyala';

  @override
  String get entryActionDelete => 'Sil';

  @override
  String get entryActionConvert => 'Dönüştür';

  @override
  String get entryActionExport => 'Dışa aktar';

  @override
  String get entryActionInfo => 'Bilgi';

  @override
  String get entryActionRename => 'Yeniden adlandır';

  @override
  String get entryActionRestore => 'Geri getir';

  @override
  String get entryActionRotateCCW => 'Saat yönünün tersine döndür';

  @override
  String get entryActionRotateCW => 'Saat yönünde döndür';

  @override
  String get entryActionFlip => 'Yatay olarak çevir';

  @override
  String get entryActionPrint => 'Yazdır';

  @override
  String get entryActionShare => 'Paylaş';

  @override
  String get entryActionShareImageOnly => 'Yalnızca resim paylaş';

  @override
  String get entryActionShareVideoOnly => 'Yalnızca video paylaş';

  @override
  String get entryActionViewSource => 'Kaynağı görüntüle';

  @override
  String get entryActionShowGeoTiffOnMap => 'Harita katmanı olarak göster';

  @override
  String get entryActionConvertMotionPhotoToStillImage => 'Hareketsiz görüntüye dönüştür';

  @override
  String get entryActionViewMotionPhotoVideo => 'Videoyu aç';

  @override
  String get entryActionEdit => 'Düzenle';

  @override
  String get entryActionOpen => 'Şununla aç';

  @override
  String get entryActionSetAs => 'Olarak ayarla';

  @override
  String get entryActionCast => 'Yansıt';

  @override
  String get entryActionOpenMap => 'Harita uygulamasında göster';

  @override
  String get entryActionRotateScreen => 'Ekranı döndür';

  @override
  String get entryActionAddFavourite => 'Favorilere ekle';

  @override
  String get entryActionRemoveFavourite => 'Favorilerden kaldır';

  @override
  String get videoActionCaptureFrame => 'Kareyi yakala';

  @override
  String get videoActionMute => 'Sessize al';

  @override
  String get videoActionUnmute => 'Sesi aç';

  @override
  String get videoActionPause => 'Duraklat';

  @override
  String get videoActionPlay => 'Oynat';

  @override
  String get videoActionReplay10 => '10 saniye geri git';

  @override
  String get videoActionSkip10 => '10 saniye ileri git';

  @override
  String get videoActionShowPreviousFrame => 'Önceki kareyi göster';

  @override
  String get videoActionShowNextFrame => 'Sonraki kareyi göster';

  @override
  String get videoActionSelectStreams => 'Ses parçası seç';

  @override
  String get videoActionSetSpeed => 'Oynatma hızı';

  @override
  String get videoActionABRepeat => 'A-B döngü';

  @override
  String get videoRepeatActionSetStart => 'Başlangıç noktası seç';

  @override
  String get videoRepeatActionSetEnd => 'Bitiş noktası seç';

  @override
  String get viewerActionSettings => 'Ayarlar';

  @override
  String get viewerActionLock => 'Kontrolleri kilitle';

  @override
  String get viewerActionUnlock => 'Kontrollerin kilidini aç';

  @override
  String get slideshowActionResume => 'Sürdür';

  @override
  String get slideshowActionShowInCollection => 'Koleksiyonda göster';

  @override
  String get entryInfoActionEditDate => 'Tarih ve saati düzenle';

  @override
  String get entryInfoActionEditLocation => 'Konumu düzenle';

  @override
  String get entryInfoActionEditTitleDescription => 'Başlık ve açıklamayı düzenle';

  @override
  String get entryInfoActionEditRating => 'Derecelendirmeyi düzenle';

  @override
  String get entryInfoActionEditTags => 'Etiketleri düzenle';

  @override
  String get entryInfoActionRemoveMetadata => 'Üst verileri kaldır';

  @override
  String get entryInfoActionExportMetadata => 'Üst verileri dışa aktar';

  @override
  String get entryInfoActionRemoveLocation => 'Konumu kaldır';

  @override
  String get editorActionTransform => 'Dönüştür';

  @override
  String get editorTransformCrop => 'Kırp';

  @override
  String get editorTransformRotate => 'Döndür';

  @override
  String get cropAspectRatioFree => 'Özgür';

  @override
  String get cropAspectRatioOriginal => 'Orijinal';

  @override
  String get cropAspectRatioSquare => 'Kare';

  @override
  String get filterAspectRatioLandscapeLabel => 'Yatay';

  @override
  String get filterAspectRatioPortraitLabel => 'Dikey';

  @override
  String get filterBinLabel => 'Geri dönüşüm kutusu';

  @override
  String get filterFavouriteLabel => 'Favori';

  @override
  String get filterNoDateLabel => 'Tarihsiz';

  @override
  String get filterNoAddressLabel => 'Adressiz';

  @override
  String get filterLocatedLabel => 'Konumlu';

  @override
  String get filterNoLocationLabel => 'Konumsuz';

  @override
  String get filterNoRatingLabel => 'Derecelendirilmemiş';

  @override
  String get filterTaggedLabel => 'Etiketli';

  @override
  String get filterNoTagLabel => 'Etiketsiz';

  @override
  String get filterNoTitleLabel => 'İsimsiz';

  @override
  String get filterOnThisDayLabel => 'Bugün';

  @override
  String get filterRecentlyAddedLabel => 'Son eklenen';

  @override
  String get filterRatingRejectedLabel => 'Reddedilmiş';

  @override
  String get filterTypeAnimatedLabel => 'Hareketli';

  @override
  String get filterTypeMotionPhotoLabel => 'Hareketli Fotoğraf';

  @override
  String get filterTypePanoramaLabel => 'Panorama';

  @override
  String get filterTypeRawLabel => 'Raw';

  @override
  String get filterTypeSphericalVideoLabel => '360° Video';

  @override
  String get filterTypeGeotiffLabel => 'GeoTIFF';

  @override
  String get filterMimeImageLabel => 'Resim';

  @override
  String get filterMimeVideoLabel => 'Video';

  @override
  String get accessibilityAnimationsRemove => 'Ekran efektlerini önle';

  @override
  String get accessibilityAnimationsKeep => 'Ekran efektlerini koru';

  @override
  String get albumTierNew => 'Yeni';

  @override
  String get albumTierPinned => 'Sabitlenmiş';

  @override
  String get albumTierSpecial => 'Genel';

  @override
  String get albumTierApps => 'Uygulamalar';

  @override
  String get albumTierVaults => 'Kilitli albümler';

  @override
  String get albumTierDynamic => 'Dinamik';

  @override
  String get albumTierRegular => 'Diğer';

  @override
  String get coordinateFormatDms => 'DMS';

  @override
  String get coordinateFormatDdm => 'DDM';

  @override
  String get coordinateFormatDecimal => 'Ondalık dereceler';

  @override
  String coordinateDms(String coordinate, String direction) {
    return '$coordinate $direction';
  }

  @override
  String get coordinateDmsNorth => 'K';

  @override
  String get coordinateDmsSouth => 'G';

  @override
  String get coordinateDmsEast => 'D';

  @override
  String get coordinateDmsWest => 'B';

  @override
  String get displayRefreshRatePreferHighest => 'En yüksek oran';

  @override
  String get displayRefreshRatePreferLowest => 'En düşük oran';

  @override
  String get keepScreenOnNever => 'Asla';

  @override
  String get keepScreenOnVideoPlayback => 'Video oynatma sırasında';

  @override
  String get keepScreenOnViewerOnly => 'Yalnızca görüntüleyici sayfasında';

  @override
  String get keepScreenOnAlways => 'Her zaman';

  @override
  String get lengthUnitPixel => 'px';

  @override
  String get lengthUnitPercent => '%';

  @override
  String get mapStyleGoogleNormal => 'Google Haritalar';

  @override
  String get mapStyleGoogleHybrid => 'Google Haritalar (Hibrit)';

  @override
  String get mapStyleGoogleTerrain => 'Google Haritalar (Arazi)';

  @override
  String get mapStyleOsmLiberty => 'OSM Liberty';

  @override
  String get mapStyleOpenTopoMap => 'OpenTopoMap';

  @override
  String get mapStyleOsmHot => 'İnsancıl OSM';

  @override
  String get mapStyleStamenWatercolor => 'Stamen Suluboya';

  @override
  String get maxBrightnessNever => 'Asla';

  @override
  String get maxBrightnessAlways => 'Her zaman';

  @override
  String get nameConflictStrategyRename => 'Yeniden adlandır';

  @override
  String get nameConflictStrategyReplace => 'Değiştir';

  @override
  String get nameConflictStrategySkip => 'Atla';

  @override
  String get overlayHistogramNone => 'Hiçbiri';

  @override
  String get overlayHistogramRGB => 'RGB';

  @override
  String get overlayHistogramLuminance => 'Parlaklık';

  @override
  String get subtitlePositionTop => 'Üst';

  @override
  String get subtitlePositionBottom => 'Alt';

  @override
  String get themeBrightnessLight => 'Açık';

  @override
  String get themeBrightnessDark => 'Koyu';

  @override
  String get themeBrightnessBlack => 'Siyah';

  @override
  String get unitSystemMetric => 'Metrik';

  @override
  String get unitSystemImperial => 'İngiliz';

  @override
  String get vaultLockTypePattern => 'Desen';

  @override
  String get vaultLockTypePin => 'PIN';

  @override
  String get vaultLockTypePassword => 'Şifre';

  @override
  String get settingsVideoEnablePip => 'Resim içinde resim';

  @override
  String get videoControlsPlayOutside => 'Başka bir oynatıcı ile aç';

  @override
  String get videoLoopModeNever => 'Asla';

  @override
  String get videoLoopModeShortOnly => 'Yalnızca kısa videolar';

  @override
  String get videoLoopModeAlways => 'Her zaman';

  @override
  String get videoPlaybackSkip => 'Atla';

  @override
  String get videoPlaybackMuted => 'Sessiz oynat';

  @override
  String get videoPlaybackWithSound => 'Sesli oynat';

  @override
  String get videoResumptionModeNever => 'Asla';

  @override
  String get videoResumptionModeAlways => 'Her zaman';

  @override
  String get viewerTransitionSlide => 'Kaydır';

  @override
  String get viewerTransitionParallax => 'Paralaks';

  @override
  String get viewerTransitionFade => 'Soldur';

  @override
  String get viewerTransitionZoomIn => 'Yakınlaştır';

  @override
  String get viewerTransitionNone => 'Hiçbiri';

  @override
  String get wallpaperTargetHome => 'Ana ekran';

  @override
  String get wallpaperTargetLock => 'Kilit ekranı';

  @override
  String get wallpaperTargetHomeLock => 'Ana ve kilit ekranları';

  @override
  String get widgetDisplayedItemRandom => 'Rastgele';

  @override
  String get widgetDisplayedItemMostRecent => 'En son';

  @override
  String get widgetOpenPageHome => 'Ana sayfayı aç';

  @override
  String get widgetOpenPageCollection => 'Koleksiyonu aç';

  @override
  String get widgetOpenPageViewer => 'Görüntüleyiciyi aç';

  @override
  String get widgetTapUpdateWidget => 'Widget\'i güncelle';

  @override
  String get storageVolumeDescriptionFallbackPrimary => 'Dahili depolama';

  @override
  String get storageVolumeDescriptionFallbackNonPrimary => 'SD kart';

  @override
  String get rootDirectoryDescription => 'kök dizin';

  @override
  String otherDirectoryDescription(String name) {
    return '“$name” dizin';
  }

  @override
  String storageAccessDialogMessage(String directory, String volume) {
    return 'Bir sonraki ekranda \"$volume\" içindeki $directory dizinini seçerek bu uygulamaya erişim izni verin.';
  }

  @override
  String restrictedAccessDialogMessage(String directory, String volume) {
    return 'Bu uygulamanın “$volume” içindeki $directory dosyaları değiştirmesine izin verilmiyor.\n\nÖğeleri başka bir dizine taşımak için lütfen önceden yüklenmiş bir dosya yöneticisi veya galeri uygulaması kullanın.';
  }

  @override
  String notEnoughSpaceDialogMessage(String neededSize, String freeSize, String volume) {
    return 'Bu işlemin tamamlanması için “$volume” üzerinde $neededSize boş alana ihtiyaç var, ancak yalnızca $freeSize kaldı.';
  }

  @override
  String get missingSystemFilePickerDialogMessage => 'Sistem dosya seçicisi eksik veya devre dışı. Lütfen etkinleştirin ve tekrar deneyin.';

  @override
  String unsupportedTypeDialogMessage(int count, String types) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Bu işlem şu türlerdeki ögeler için desteklenmez: $types.',
      one: 'Bu işlem şu türdeki ögeler için desteklenmez: $types.',
    );
    return '$_temp0';
  }

  @override
  String get nameConflictDialogSingleSourceMessage => 'Hedef klasördeki bazı dosyalar aynı ada sahip.';

  @override
  String get nameConflictDialogMultipleSourceMessage => 'Bazı dosyalar aynı ada sahip.';

  @override
  String get addShortcutDialogLabel => 'Kısayol etiketi';

  @override
  String get addShortcutButtonLabel => 'EKLE';

  @override
  String get noMatchingAppDialogMessage => 'Bununla ilgilenebilecek bir uygulama yok.';

  @override
  String binEntriesConfirmationDialogMessage(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Bu $countString öge geri dönüşüm kutusuna atılsın mı?',
      one: 'Bu öge geri dönüşüm kutusuna taşınsın mı?',
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
      other: 'Bu $countString öge silinsin mi?',
      one: 'Bu öge silinsin mi?',
    );
    return '$_temp0';
  }

  @override
  String get moveUndatedConfirmationDialogMessage => 'Devam etmeden önce öge tarihleri kaydedilsin mi?';

  @override
  String get moveUndatedConfirmationDialogSetDate => 'Tarihleri kaydet';

  @override
  String videoResumeDialogMessage(String time) {
    return '$time itibarıyla oynatmaya devam etmek istiyor musunuz?';
  }

  @override
  String get videoStartOverButtonLabel => 'BAŞTAN BAŞLA';

  @override
  String get videoResumeButtonLabel => 'SÜRDÜR';

  @override
  String get setCoverDialogLatest => 'Son öge';

  @override
  String get setCoverDialogAuto => 'Otomatik';

  @override
  String get setCoverDialogCustom => 'Özel';

  @override
  String get hideFilterConfirmationDialogMessage => 'Eşleşen fotoğraf ve videolar koleksiyonunuzdan gizlenecektir. Bunları “Gizlilik”, ayarlarından tekrar gösterebilirsiniz.\n\nBunları gizlemek istediğinizden emin misiniz?';

  @override
  String get newAlbumDialogTitle => 'Yeni Albüm';

  @override
  String get newAlbumDialogNameLabel => 'Albüm adı';

  @override
  String get newAlbumDialogAlbumAlreadyExistsHelper => 'Böyle bir albüm zaten var';

  @override
  String get newAlbumDialogNameLabelAlreadyExistsHelper => 'Dizin zaten var';

  @override
  String get newAlbumDialogStorageLabel => 'Depolama:';

  @override
  String get newDynamicAlbumDialogTitle => 'Yeni dinamik albüm';

  @override
  String get dynamicAlbumAlreadyExists => 'Dinamik albüm zaten var';

  @override
  String get newVaultWarningDialogMessage => 'Kilitli albümlere yalnızca bu uygulama erişebilir, başka herhangi bir uygulama erişemez.\n\nBu uygulamayı kaldırır veya verilerini silerseniz kilitli albümlerdeki bütün ögeleri kaybedersiniz.';

  @override
  String get newVaultDialogTitle => 'Kilitli Albüm Oluştur';

  @override
  String get configureVaultDialogTitle => 'Kilitli Albüm Ayarları';

  @override
  String get vaultDialogLockModeWhenScreenOff => 'Ekran kapatıldığında kilitle';

  @override
  String get vaultDialogLockTypeLabel => 'Kilit türü';

  @override
  String get patternDialogEnter => 'Deseninizi çizin';

  @override
  String get patternDialogConfirm => 'Deseninizi tekrar çizin';

  @override
  String get pinDialogEnter => 'PIN girin';

  @override
  String get pinDialogConfirm => 'PIN\'inizi tekrar girin';

  @override
  String get passwordDialogEnter => 'Şifre girin';

  @override
  String get passwordDialogConfirm => 'Şifrenizi tekrar girin';

  @override
  String get authenticateToConfigureVault => 'Kilitli albümü ayarlamak için kimliğinizi doğrulayın';

  @override
  String get authenticateToUnlockVault => 'Albümün kilidini açmak için kimliğinizi doğrulayın';

  @override
  String get vaultBinUsageDialogMessage => 'Bazı kilitli albümler çöp kutusunu kullanıyor.';

  @override
  String get renameAlbumDialogLabel => 'Yeni ad';

  @override
  String get renameAlbumDialogLabelAlreadyExistsHelper => 'Dizin zaten var';

  @override
  String get renameEntrySetPageTitle => 'Yeniden adlandır';

  @override
  String get renameEntrySetPagePatternFieldLabel => 'İsimlendirme şekli';

  @override
  String get renameEntrySetPageInsertTooltip => 'Alan ekle';

  @override
  String get renameEntrySetPagePreviewSectionTitle => 'Önizleme';

  @override
  String get renameProcessorCounter => 'Sayaç';

  @override
  String get renameProcessorHash => 'Sağlama';

  @override
  String get renameProcessorName => 'Ad';

  @override
  String deleteSingleAlbumConfirmationDialogMessage(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Bu albüm ve içindeki $countString öge silinsin mi?',
      one: 'Bu albüm ve içindeki öge silinsin mi?',
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
      other: 'Bu albümler ve içindeki $countString ögesi silinsin mi?',
      one: 'Bu albümler ve içindeki öge silinsin mi?',
    );
    return '$_temp0';
  }

  @override
  String get exportEntryDialogFormat => 'Biçim:';

  @override
  String get exportEntryDialogWidth => 'Genişlik';

  @override
  String get exportEntryDialogHeight => 'Yükseklik';

  @override
  String get exportEntryDialogQuality => 'Kalite';

  @override
  String get exportEntryDialogWriteMetadata => 'Metaverileri ekle';

  @override
  String get renameEntryDialogLabel => 'Yeni ad';

  @override
  String get editEntryDialogCopyFromItem => 'Başka bir ögeden kopyala';

  @override
  String get editEntryDialogTargetFieldsHeader => 'Değiştirilecek alanlar';

  @override
  String get editEntryDateDialogTitle => 'Tarih ve Saat';

  @override
  String get editEntryDateDialogSetCustom => 'Özel tarih ayarla';

  @override
  String get editEntryDateDialogCopyField => 'Başka bir tarihten kopyala';

  @override
  String get editEntryDateDialogExtractFromTitle => 'Başlıktan ayıkla';

  @override
  String get editEntryDateDialogShift => 'Değiştir';

  @override
  String get editEntryDateDialogSourceFileModifiedDate => 'Dosya değiştirilme tarihi';

  @override
  String get durationDialogHours => 'Saat';

  @override
  String get durationDialogMinutes => 'Dakika';

  @override
  String get durationDialogSeconds => 'Saniye';

  @override
  String get editEntryLocationDialogTitle => 'Konum';

  @override
  String get editEntryLocationDialogSetCustom => 'Özel konum ayarla';

  @override
  String get editEntryLocationDialogChooseOnMap => 'Harita üzerinde seç';

  @override
  String get editEntryLocationDialogImportGpx => 'GPX\'i içe aktar';

  @override
  String get editEntryLocationDialogLatitude => 'Enlem';

  @override
  String get editEntryLocationDialogLongitude => 'Boylam';

  @override
  String get editEntryLocationDialogTimeShift => 'Time shift';

  @override
  String get locationPickerUseThisLocationButton => 'Bu konumu kullan';

  @override
  String get editEntryRatingDialogTitle => 'Derecelendirme';

  @override
  String get removeEntryMetadataDialogTitle => 'Üst Veri Kaldırma';

  @override
  String get removeEntryMetadataDialogAll => 'Tümü';

  @override
  String get removeEntryMetadataDialogMore => 'Daha fazla';

  @override
  String get removeEntryMetadataMotionPhotoXmpWarningDialogMessage => 'Hareketli bir fotoğrafın içindeki videoyu oynatmak için XMP gereklidir.\n\nKaldırmak istediğinizden emin misiniz?';

  @override
  String get videoSpeedDialogLabel => 'Oynatma hızı';

  @override
  String get videoStreamSelectionDialogVideo => 'Video';

  @override
  String get videoStreamSelectionDialogAudio => 'Ses';

  @override
  String get videoStreamSelectionDialogText => 'Altyazı';

  @override
  String get videoStreamSelectionDialogOff => 'Kapalı';

  @override
  String get videoStreamSelectionDialogTrack => 'Parça';

  @override
  String get videoStreamSelectionDialogNoSelection => 'Başka parça yok.';

  @override
  String get genericSuccessFeedback => 'Başarılı!';

  @override
  String get genericFailureFeedback => 'Başarısız';

  @override
  String get genericDangerWarningDialogMessage => 'Emin misiniz?';

  @override
  String get tooManyItemsErrorDialogMessage => 'Daha az ögeyle tekrar deneyin.';

  @override
  String get menuActionConfigureView => 'Görünüm';

  @override
  String get menuActionSelect => 'Seç';

  @override
  String get menuActionSelectAll => 'Hepsini seç';

  @override
  String get menuActionSelectNone => 'Hiçbirini seçme';

  @override
  String get menuActionMap => 'Harita';

  @override
  String get menuActionSlideshow => 'Slayt gösterisi';

  @override
  String get menuActionStats => 'İstatistikler';

  @override
  String get viewDialogSortSectionTitle => 'Sırala';

  @override
  String get viewDialogGroupSectionTitle => 'Grup';

  @override
  String get viewDialogLayoutSectionTitle => 'Düzen';

  @override
  String get viewDialogReverseSortOrder => 'Ters sıralama düzeni';

  @override
  String get tileLayoutMosaic => 'Mozaik';

  @override
  String get tileLayoutGrid => 'Izgara';

  @override
  String get tileLayoutList => 'Liste';

  @override
  String get castDialogTitle => 'Yakındaki Cihazlar';

  @override
  String get coverDialogTabCover => 'Kapak';

  @override
  String get coverDialogTabApp => 'Uygulama';

  @override
  String get coverDialogTabColor => 'Renk';

  @override
  String get appPickDialogTitle => 'Uygulama seç';

  @override
  String get appPickDialogNone => 'Yok';

  @override
  String get aboutPageTitle => 'Hakkında';

  @override
  String get aboutLinkLicense => 'Lisans';

  @override
  String get aboutLinkPolicy => 'Gizlilik Politikası';

  @override
  String get aboutBugSectionTitle => 'Hata Bildirimi';

  @override
  String get aboutBugSaveLogInstruction => 'Uygulama günlüklerini bir dosyaya kaydet';

  @override
  String get aboutBugCopyInfoInstruction => 'Sistem bilgilerini kopyala';

  @override
  String get aboutBugCopyInfoButton => 'Kopyala';

  @override
  String get aboutBugReportInstruction => 'GitHub\'da günlükleri ve sistem bilgilerini içeren bir rapor oluştur';

  @override
  String get aboutBugReportButton => 'Raporla';

  @override
  String get aboutDataUsageSectionTitle => 'Kullanılan Alan';

  @override
  String get aboutDataUsageData => 'Veriler';

  @override
  String get aboutDataUsageCache => 'Önbellek';

  @override
  String get aboutDataUsageDatabase => 'Veritabanı';

  @override
  String get aboutDataUsageMisc => 'Diğer';

  @override
  String get aboutDataUsageInternal => 'Dahili';

  @override
  String get aboutDataUsageExternal => 'Harici';

  @override
  String get aboutDataUsageClearCache => 'Önbelleği Temizle';

  @override
  String get aboutCreditsSectionTitle => 'Kredi';

  @override
  String get aboutCreditsWorldAtlas1 => 'Bu uygulama bir TopoJSON dosyası kullanır';

  @override
  String get aboutCreditsWorldAtlas2 => 'ISC Lisansı kapsamında.';

  @override
  String get aboutTranslatorsSectionTitle => 'Tercümanlar';

  @override
  String get aboutLicensesSectionTitle => 'Açık Kaynak Lisansları';

  @override
  String get aboutLicensesBanner => 'Bu uygulama aşağıdaki açık kaynaklı paketleri ve kütüphaneleri kullanır.';

  @override
  String get aboutLicensesAndroidLibrariesSectionTitle => 'Android Kütüphaneleri';

  @override
  String get aboutLicensesFlutterPluginsSectionTitle => 'Flutter Eklentileri';

  @override
  String get aboutLicensesFlutterPackagesSectionTitle => 'Flutter Paketleri';

  @override
  String get aboutLicensesDartPackagesSectionTitle => 'Dart Paketleri';

  @override
  String get aboutLicensesShowAllButtonLabel => 'Tüm Lisansları Göster';

  @override
  String get policyPageTitle => 'Gizlilik Politikası';

  @override
  String get collectionPageTitle => 'Koleksiyon';

  @override
  String get collectionPickPageTitle => 'Seç';

  @override
  String get collectionSelectPageTitle => 'Öğeleri seç';

  @override
  String get collectionActionShowTitleSearch => 'Başlık filtresini göster';

  @override
  String get collectionActionHideTitleSearch => 'Başlık filtresini gizle';

  @override
  String get collectionActionAddDynamicAlbum => 'Dinamik albüm ekle';

  @override
  String get collectionActionAddShortcut => 'Kısayol ekle';

  @override
  String get collectionActionSetHome => 'Ana ekran olarak ayarla';

  @override
  String get collectionActionEmptyBin => 'Boş çöp kutusu';

  @override
  String get collectionActionCopy => 'Albüme kopyala';

  @override
  String get collectionActionMove => 'Albüme taşı';

  @override
  String get collectionActionRescan => 'Yeniden tara';

  @override
  String get collectionActionEdit => 'Düzenle';

  @override
  String get collectionSearchTitlesHintText => 'Başlıkları ara';

  @override
  String get collectionGroupAlbum => 'Albüme göre';

  @override
  String get collectionGroupMonth => 'Aya göre';

  @override
  String get collectionGroupDay => 'Güne göre';

  @override
  String get collectionGroupNone => 'Gruplama';

  @override
  String get sectionUnknown => 'Bilinmeyen';

  @override
  String get dateToday => 'Bugün';

  @override
  String get dateYesterday => 'Dün';

  @override
  String get dateThisMonth => 'Bu ay';

  @override
  String collectionDeleteFailureFeedback(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString öge silinemedi',
      one: '1 öge silinemedi',
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
      other: '$countString öge kopyalanamadı',
      one: '1 öge kopyalanamadı',
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
      other: '$countString öge taşınamadı',
      one: '1 öge taşınamadı',
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
      other: '$countString ögenin adı değiştirilemedi',
      one: '1 ögenin adı değiştirilemedi',
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
      other: '$countString öge düzenlenemedi',
      one: '1 öge düzenlenemedi',
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
      other: '$countString sayfa dışa aktarılamadı',
      one: '1 sayfa dışa aktarılamadı',
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
      other: '$countString öge kopyalandı',
      one: '1 öge kopyalandı',
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
      other: '$countString öge taşındı',
      one: '1 öge taşındı',
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
      other: '$countString ögenin adı değiştirildi',
      one: '1 ögenin adı değiştirildi',
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
      other: '$countString öge düzenlendi',
      one: '1 öge düzenlendi',
    );
    return '$_temp0';
  }

  @override
  String get collectionEmptyFavourites => 'Favori yok';

  @override
  String get collectionEmptyVideos => 'Video yok';

  @override
  String get collectionEmptyImages => 'Resim yok';

  @override
  String get collectionEmptyGrantAccessButtonLabel => 'Erişim izni';

  @override
  String get collectionSelectSectionTooltip => 'Bölüm seç';

  @override
  String get collectionDeselectSectionTooltip => 'Bölüm seçimini kaldır';

  @override
  String get drawerAboutButton => 'Hakkında';

  @override
  String get drawerSettingsButton => 'Ayarlar';

  @override
  String get drawerCollectionAll => 'Tüm koleksiyon';

  @override
  String get drawerCollectionFavourites => 'Favoriler';

  @override
  String get drawerCollectionImages => 'Resimler';

  @override
  String get drawerCollectionVideos => 'Videolar';

  @override
  String get drawerCollectionAnimated => 'Hareketli';

  @override
  String get drawerCollectionMotionPhotos => 'Hareketli fotoğraflar';

  @override
  String get drawerCollectionPanoramas => 'Panoramalar';

  @override
  String get drawerCollectionRaws => 'Raw fotoğraflar';

  @override
  String get drawerCollectionSphericalVideos => '360° Videolar';

  @override
  String get drawerAlbumPage => 'Albümler';

  @override
  String get drawerCountryPage => 'Ülkeler';

  @override
  String get drawerPlacePage => 'Yerler';

  @override
  String get drawerTagPage => 'Etiketler';

  @override
  String get sortByDate => 'Tarihe göre';

  @override
  String get sortByName => 'Adına göre';

  @override
  String get sortByItemCount => 'Öğe sayısına göre';

  @override
  String get sortBySize => 'Boyuta göre';

  @override
  String get sortByAlbumFileName => 'Albüm ve dosya adına göre';

  @override
  String get sortByRating => 'Derecelendirmeye göre';

  @override
  String get sortByDuration => 'Süreye göre';

  @override
  String get sortByPath => 'By path';

  @override
  String get sortOrderNewestFirst => 'Önce en yeni';

  @override
  String get sortOrderOldestFirst => 'Önce en eski';

  @override
  String get sortOrderAtoZ => 'A\'dan Z\'ye';

  @override
  String get sortOrderZtoA => 'Z\'den A\'ya';

  @override
  String get sortOrderHighestFirst => 'Önce en yüksek';

  @override
  String get sortOrderLowestFirst => 'Önce en düşük';

  @override
  String get sortOrderLargestFirst => 'Önce en büyük';

  @override
  String get sortOrderSmallestFirst => 'Önce en küçük';

  @override
  String get sortOrderShortestFirst => 'Önce en kısa';

  @override
  String get sortOrderLongestFirst => 'Önce en uzun';

  @override
  String get albumGroupTier => 'Kademeye göre';

  @override
  String get albumGroupType => 'Türe göre';

  @override
  String get albumGroupVolume => 'Depolama hacmine göre';

  @override
  String get albumGroupNone => 'Gruplama';

  @override
  String get albumMimeTypeMixed => 'Karışık';

  @override
  String get albumPickPageTitleCopy => 'Albüme kopyala';

  @override
  String get albumPickPageTitleExport => 'Albüme aktar';

  @override
  String get albumPickPageTitleMove => 'Albüme taşı';

  @override
  String get albumPickPageTitlePick => 'Albüm seç';

  @override
  String get albumCamera => 'Kamera';

  @override
  String get albumDownload => 'İndir';

  @override
  String get albumScreenshots => 'Ekran görüntüleri';

  @override
  String get albumScreenRecordings => 'Ekran kayıtları';

  @override
  String get albumVideoCaptures => 'Video çekimleri';

  @override
  String get albumPageTitle => 'Albümler';

  @override
  String get albumEmpty => 'Albüm yok';

  @override
  String get createAlbumButtonLabel => 'OLUŞTUR';

  @override
  String get newFilterBanner => 'yeni';

  @override
  String get countryPageTitle => 'Ülkeler';

  @override
  String get countryEmpty => 'Ülke yok';

  @override
  String get statePageTitle => 'Eyaletler';

  @override
  String get stateEmpty => 'Hiç eyalet bulunamadı';

  @override
  String get placePageTitle => 'Yerler';

  @override
  String get placeEmpty => 'Hiç yer bulunamadı';

  @override
  String get tagPageTitle => 'Etiketler';

  @override
  String get tagEmpty => 'Etiket yok';

  @override
  String get binPageTitle => 'Geri Dönüşüm Kutusu';

  @override
  String get explorerPageTitle => 'Gezgin';

  @override
  String get explorerActionSelectStorageVolume => 'Depolama alanı seç';

  @override
  String get selectStorageVolumeDialogTitle => 'Depolama Alanı Seç';

  @override
  String get searchCollectionFieldHint => 'Koleksiyonda ara';

  @override
  String get searchRecentSectionTitle => 'Yakın zamanda';

  @override
  String get searchDateSectionTitle => 'Tarih';

  @override
  String get searchFormatSectionTitle => 'Biçimler';

  @override
  String get searchAlbumsSectionTitle => 'Albümler';

  @override
  String get searchCountriesSectionTitle => 'Ülkeler';

  @override
  String get searchStatesSectionTitle => 'Eyaletler';

  @override
  String get searchPlacesSectionTitle => 'Yerler';

  @override
  String get searchTagsSectionTitle => 'Etiketler';

  @override
  String get searchRatingSectionTitle => 'Derecelendirmeler';

  @override
  String get searchMetadataSectionTitle => 'Üstveri';

  @override
  String get settingsPageTitle => 'Ayarlar';

  @override
  String get settingsSystemDefault => 'Sistem';

  @override
  String get settingsDefault => 'Varsayılan';

  @override
  String get settingsDisabled => 'Devre dışı';

  @override
  String get settingsAskEverytime => 'Her seferinde sor';

  @override
  String get settingsModificationWarningDialogMessage => 'Diğer ayarlar değiştirilecektir.';

  @override
  String get settingsSearchFieldLabel => 'Ayarlarda ara';

  @override
  String get settingsSearchEmpty => 'Eşleşen ayar bulunamadı';

  @override
  String get settingsActionExport => 'Dışa aktar';

  @override
  String get settingsActionExportDialogTitle => 'Dışa aktar';

  @override
  String get settingsActionImport => 'İçe aktar';

  @override
  String get settingsActionImportDialogTitle => 'İçe aktar';

  @override
  String get appExportCovers => 'Kapaklar';

  @override
  String get appExportDynamicAlbums => 'Dinamik albümler';

  @override
  String get appExportFavourites => 'Favoriler';

  @override
  String get appExportSettings => 'Ayarlar';

  @override
  String get settingsNavigationSectionTitle => 'Gezinti';

  @override
  String get settingsHomeTile => 'Anasayfa';

  @override
  String get settingsHomeDialogTitle => 'Anasayfa';

  @override
  String get setHomeCustom => 'Özel';

  @override
  String get settingsShowBottomNavigationBar => 'Alt gezinti çubuğunu göster';

  @override
  String get settingsKeepScreenOnTile => 'Ekranı açık tut';

  @override
  String get settingsKeepScreenOnDialogTitle => 'Ekranı Açık Tut';

  @override
  String get settingsDoubleBackExit => 'Çıkmak için iki kez “geri” düğmesine dokun';

  @override
  String get settingsConfirmationTile => 'Onaylama diyalogları';

  @override
  String get settingsConfirmationDialogTitle => 'Onaylama Diyalogları';

  @override
  String get settingsConfirmationBeforeDeleteItems => 'Öğeleri sonsuza dek silmeden önce sor';

  @override
  String get settingsConfirmationBeforeMoveToBinItems => 'Eşyaları geri dönüşüm kutusuna atmadan önce sor';

  @override
  String get settingsConfirmationBeforeMoveUndatedItems => 'Tarihsiz eşyaları taşımadan önce sor';

  @override
  String get settingsConfirmationAfterMoveToBinItems => 'Öğeleri geri dönüşüm kutusuna taşıdıktan sonra mesaj göster';

  @override
  String get settingsConfirmationVaultDataLoss => 'Kilitli albüm veri kaybı uyarısını göster';

  @override
  String get settingsNavigationDrawerTile => 'Gezinti menüsü';

  @override
  String get settingsNavigationDrawerEditorPageTitle => 'Gezinti Menüsü';

  @override
  String get settingsNavigationDrawerBanner => 'Menü ögelerini taşımak ve yeniden sıralamak için dokunun ve basılı tutun.';

  @override
  String get settingsNavigationDrawerTabTypes => 'Türler';

  @override
  String get settingsNavigationDrawerTabAlbums => 'Albümler';

  @override
  String get settingsNavigationDrawerTabPages => 'Sayfalar';

  @override
  String get settingsNavigationDrawerAddAlbum => 'Albüm ekle';

  @override
  String get settingsThumbnailSectionTitle => 'Küçük resimler';

  @override
  String get settingsThumbnailOverlayTile => 'Kaplama';

  @override
  String get settingsThumbnailOverlayPageTitle => 'Kaplama';

  @override
  String get settingsThumbnailShowHdrIcon => 'HDR simgesini göster';

  @override
  String get settingsThumbnailShowFavouriteIcon => 'Favori simgeyi göster';

  @override
  String get settingsThumbnailShowTagIcon => 'Etiket simgesini göster';

  @override
  String get settingsThumbnailShowLocationIcon => 'Konum simgesini göster';

  @override
  String get settingsThumbnailShowMotionPhotoIcon => 'Hareketli fotoğraf simgesini göster';

  @override
  String get settingsThumbnailShowRating => 'Derecelendirmeyi göster';

  @override
  String get settingsThumbnailShowRawIcon => 'Raw simgesini göster';

  @override
  String get settingsThumbnailShowVideoDuration => 'Video süresini göster';

  @override
  String get settingsCollectionQuickActionsTile => 'Hızlı eylemler';

  @override
  String get settingsCollectionQuickActionEditorPageTitle => 'Hızlı Eylemler';

  @override
  String get settingsCollectionQuickActionTabBrowsing => 'Gözatma';

  @override
  String get settingsCollectionQuickActionTabSelecting => 'Seçme';

  @override
  String get settingsCollectionBrowsingQuickActionEditorBanner => 'Düğmeleri hareket ettirmek ve ögelere göz atarken hangi eylemlerin görüntüleneceğini seçmek için dokunun ve basılı tutun.';

  @override
  String get settingsCollectionSelectionQuickActionEditorBanner => 'Düğmeleri hareket ettirmek ve ögeleri seçerken hangi eylemlerin görüntüleneceğini seçmek için dokunun ve basılı tutun.';

  @override
  String get settingsCollectionBurstPatternsTile => 'Seri fotoğraf çekme biçimleri';

  @override
  String get settingsCollectionBurstPatternsNone => 'Hiçbiri';

  @override
  String get settingsViewerSectionTitle => 'Görüntüleyici';

  @override
  String get settingsViewerGestureSideTapNext => 'Önceki/sonraki ögeyi göstermek için ekran kenarlarına dokunun';

  @override
  String get settingsViewerUseCutout => 'Kesim alanını kullan';

  @override
  String get settingsViewerMaximumBrightness => 'Maksimum parlaklık';

  @override
  String get settingsMotionPhotoAutoPlay => 'Hareketli fotoğrafları otomatik oynat';

  @override
  String get settingsImageBackground => 'Resim arka planı';

  @override
  String get settingsViewerQuickActionsTile => 'Hızlı eylemler';

  @override
  String get settingsViewerQuickActionEditorPageTitle => 'Hızlı Eylemler';

  @override
  String get settingsViewerQuickActionEditorBanner => 'Düğmeleri hareket ettirmek ve görüntüleyicide hangi eylemlerin görüntüleneceğini seçmek için dokunun ve basılı tutun.';

  @override
  String get settingsViewerQuickActionEditorDisplayedButtonsSectionTitle => 'Gösterilen Düğmeler';

  @override
  String get settingsViewerQuickActionEditorAvailableButtonsSectionTitle => 'Mevcut Düğmeler';

  @override
  String get settingsViewerQuickActionEmpty => 'Düğme yok';

  @override
  String get settingsViewerOverlayTile => 'Kaplama';

  @override
  String get settingsViewerOverlayPageTitle => 'Kaplama';

  @override
  String get settingsViewerShowOverlayOnOpening => 'Açılışta göster';

  @override
  String get settingsViewerShowHistogram => 'Çubuk grafiğini göster';

  @override
  String get settingsViewerShowMinimap => 'Mini haritayı göster';

  @override
  String get settingsViewerShowInformation => 'Bilgileri göster';

  @override
  String get settingsViewerShowInformationSubtitle => 'Başlığı, tarihi, konumu vb. göster.';

  @override
  String get settingsViewerShowRatingTags => 'Derecelendirme ve etiketleri göster';

  @override
  String get settingsViewerShowShootingDetails => 'Çekim ayrıntılarını göster';

  @override
  String get settingsViewerShowDescription => 'Açıklamayı göster';

  @override
  String get settingsViewerShowOverlayThumbnails => 'Küçük resimleri göster';

  @override
  String get settingsViewerEnableOverlayBlurEffect => 'Bulanıklık efekti';

  @override
  String get settingsViewerSlideshowTile => 'Slayt gösterisi';

  @override
  String get settingsViewerSlideshowPageTitle => 'Slayt gösterisi';

  @override
  String get settingsSlideshowRepeat => 'Tekrarla';

  @override
  String get settingsSlideshowShuffle => 'Karıştır';

  @override
  String get settingsSlideshowFillScreen => 'Ekranı doldur';

  @override
  String get settingsSlideshowAnimatedZoomEffect => 'Animasyonlu yakınlaştırma efekti';

  @override
  String get settingsSlideshowTransitionTile => 'Geçiş';

  @override
  String get settingsSlideshowIntervalTile => 'Aralık';

  @override
  String get settingsSlideshowVideoPlaybackTile => 'Video oynatma';

  @override
  String get settingsSlideshowVideoPlaybackDialogTitle => 'Video Oynatma';

  @override
  String get settingsVideoPageTitle => 'Video Ayarları';

  @override
  String get settingsVideoSectionTitle => 'Video';

  @override
  String get settingsVideoShowVideos => 'Videoları göster';

  @override
  String get settingsVideoPlaybackTile => 'Oynatma';

  @override
  String get settingsVideoPlaybackPageTitle => 'Oynatma';

  @override
  String get settingsVideoEnableHardwareAcceleration => 'Donanım hızlandırma';

  @override
  String get settingsVideoAutoPlay => 'Otomatik oynatma';

  @override
  String get settingsVideoLoopModeTile => 'Döngü modu';

  @override
  String get settingsVideoLoopModeDialogTitle => 'Döngü Modu';

  @override
  String get settingsVideoResumptionModeTile => 'Oynatmaya devam et';

  @override
  String get settingsVideoResumptionModeDialogTitle => 'Oynatmaya Devam Et';

  @override
  String get settingsVideoBackgroundMode => 'Arkaplan modu';

  @override
  String get settingsVideoBackgroundModeDialogTitle => 'Arkaplan Modu';

  @override
  String get settingsVideoControlsTile => 'Kontroller';

  @override
  String get settingsVideoControlsPageTitle => 'Kontroller';

  @override
  String get settingsVideoButtonsTile => 'Düğmeler';

  @override
  String get settingsVideoGestureDoubleTapTogglePlay => 'Oynatmak/duraklatmak için çift dokunun';

  @override
  String get settingsVideoGestureSideDoubleTapSeek => 'İleri/geri gitmek için ekran kenarlarına çift dokunun';

  @override
  String get settingsVideoGestureVerticalDragBrightnessVolume => 'Parlaklığı/ses seviyesini ayarlamak için yukarı veya aşağı kaydırın';

  @override
  String get settingsSubtitleThemeTile => 'Altyazılar';

  @override
  String get settingsSubtitleThemePageTitle => 'Altyazılar';

  @override
  String get settingsSubtitleThemeSample => 'Bu bir örnek.';

  @override
  String get settingsSubtitleThemeTextAlignmentTile => 'Metin hizalama';

  @override
  String get settingsSubtitleThemeTextAlignmentDialogTitle => 'Metin Hizalama';

  @override
  String get settingsSubtitleThemeTextPositionTile => 'Metin konumu';

  @override
  String get settingsSubtitleThemeTextPositionDialogTitle => 'Metin Konumu';

  @override
  String get settingsSubtitleThemeTextSize => 'Metin boyutu';

  @override
  String get settingsSubtitleThemeShowOutline => 'Dış çizgiyi ve gölgeyi göster';

  @override
  String get settingsSubtitleThemeTextColor => 'Metin rengi';

  @override
  String get settingsSubtitleThemeTextOpacity => 'Metin opaklığı';

  @override
  String get settingsSubtitleThemeBackgroundColor => 'Arka plan rengi';

  @override
  String get settingsSubtitleThemeBackgroundOpacity => 'Arka plan opaklığı';

  @override
  String get settingsSubtitleThemeTextAlignmentLeft => 'Sol';

  @override
  String get settingsSubtitleThemeTextAlignmentCenter => 'Merkez';

  @override
  String get settingsSubtitleThemeTextAlignmentRight => 'Sağ';

  @override
  String get settingsPrivacySectionTitle => 'Gizlilik';

  @override
  String get settingsAllowInstalledAppAccess => 'Uygulama envanterine erişime izin ver';

  @override
  String get settingsAllowInstalledAppAccessSubtitle => 'Albüm görüntüsünü iyileştirmek için kullanılır';

  @override
  String get settingsAllowErrorReporting => 'Anonim hata raporlamasına izin ver';

  @override
  String get settingsSaveSearchHistory => 'Arama geçmişini kaydet';

  @override
  String get settingsEnableBin => 'Geri dönüşüm kutusunu kullan';

  @override
  String get settingsEnableBinSubtitle => 'Silinen ögeleri 30 gün boyunca saklar';

  @override
  String get settingsDisablingBinWarningDialogMessage => 'Çöp kutusundaki ögeler sonsuza dek silinecektir.';

  @override
  String get settingsAllowMediaManagement => 'Medya yönetimine izin ver';

  @override
  String get settingsHiddenItemsTile => 'Gizli ögeler';

  @override
  String get settingsHiddenItemsPageTitle => 'Gizli Öğeler';

  @override
  String get settingsHiddenFiltersBanner => 'Gizli filtrelerle eşleşen fotoğraflar ve videolar koleksiyonunuzda görünmeyecektir.';

  @override
  String get settingsHiddenFiltersEmpty => 'Gizli filtre yok';

  @override
  String get settingsStorageAccessTile => 'Depolama erişimi';

  @override
  String get settingsStorageAccessPageTitle => 'Depolama Erişimi';

  @override
  String get settingsStorageAccessBanner => 'Bazı dizinler, içlerindeki dosyaları değiştirmek için açık bir erişim izni gerektirir. Daha önce erişim izni verdiğiniz dizinleri buradan inceleyebilirsiniz.';

  @override
  String get settingsStorageAccessEmpty => 'Erişim izni yok';

  @override
  String get settingsStorageAccessRevokeTooltip => 'Geri al';

  @override
  String get settingsAccessibilitySectionTitle => 'Erişilebilirlik';

  @override
  String get settingsRemoveAnimationsTile => 'Animasyonları kaldır';

  @override
  String get settingsRemoveAnimationsDialogTitle => 'Animasyonları Kaldır';

  @override
  String get settingsTimeToTakeActionTile => 'Harekete geçme zamanı';

  @override
  String get settingsAccessibilityShowPinchGestureAlternatives => 'Çoklu dokunma hareketi alternatiflerini göster';

  @override
  String get settingsDisplaySectionTitle => 'Ekran';

  @override
  String get settingsThemeBrightnessTile => 'Tema';

  @override
  String get settingsThemeBrightnessDialogTitle => 'Tema';

  @override
  String get settingsThemeColorHighlights => 'Renk vurguları';

  @override
  String get settingsThemeEnableDynamicColor => 'Dinamik renk';

  @override
  String get settingsDisplayRefreshRateModeTile => 'Görüntü yenileme hızı';

  @override
  String get settingsDisplayRefreshRateModeDialogTitle => 'Yenileme Hızı';

  @override
  String get settingsDisplayUseTvInterface => 'Android TV arayüzü';

  @override
  String get settingsLanguageSectionTitle => 'Dil ve Biçim';

  @override
  String get settingsLanguageTile => 'Dil';

  @override
  String get settingsLanguagePageTitle => 'Dil';

  @override
  String get settingsCoordinateFormatTile => 'Koordinat formatı';

  @override
  String get settingsCoordinateFormatDialogTitle => 'Koordinat Formatı';

  @override
  String get settingsUnitSystemTile => 'Birimler';

  @override
  String get settingsUnitSystemDialogTitle => 'Birimler';

  @override
  String get settingsForceWesternArabicNumeralsTile => 'Arap rakamlarını zorla';

  @override
  String get settingsScreenSaverPageTitle => 'Ekran Koruyucu';

  @override
  String get settingsWidgetPageTitle => 'Fotoğraf Çerçevesi';

  @override
  String get settingsWidgetShowOutline => 'Anahat';

  @override
  String get settingsWidgetOpenPage => 'Widget\'a dokunulduğunda';

  @override
  String get settingsWidgetDisplayedItem => 'Görüntülenen öge';

  @override
  String get settingsCollectionTile => 'Koleksiyon';

  @override
  String get statsPageTitle => 'İstatistikler';

  @override
  String statsWithGps(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString öge konuma sahip',
      one: '1 öge konuma sahip',
    );
    return '$_temp0';
  }

  @override
  String get statsTopCountriesSectionTitle => 'Öne Çıkan Ülkeler';

  @override
  String get statsTopStatesSectionTitle => 'Baş Eyaletler';

  @override
  String get statsTopPlacesSectionTitle => 'Öne Çıkan Yerler';

  @override
  String get statsTopTagsSectionTitle => 'Öne Çıkan Etiketler';

  @override
  String get statsTopAlbumsSectionTitle => 'Öne Çıkan Albümler';

  @override
  String get viewerOpenPanoramaButtonLabel => 'PANORAMAYI AÇ';

  @override
  String get viewerSetWallpaperButtonLabel => 'DUVAR KAĞIDI AYARLA';

  @override
  String get viewerErrorUnknown => 'Tüh!';

  @override
  String get viewerErrorDoesNotExist => 'Dosya artık mevcut değil.';

  @override
  String get viewerInfoPageTitle => 'Bilgi';

  @override
  String get viewerInfoBackToViewerTooltip => 'Görüntüleyiciye geri dön';

  @override
  String get viewerInfoUnknown => 'bilinmeyen';

  @override
  String get viewerInfoLabelDescription => 'Açıklama';

  @override
  String get viewerInfoLabelTitle => 'Başlık';

  @override
  String get viewerInfoLabelDate => 'Tarih';

  @override
  String get viewerInfoLabelResolution => 'Çözünürlük';

  @override
  String get viewerInfoLabelSize => 'Boyut';

  @override
  String get viewerInfoLabelUri => 'URI';

  @override
  String get viewerInfoLabelPath => 'Yol';

  @override
  String get viewerInfoLabelDuration => 'Süre';

  @override
  String get viewerInfoLabelOwner => 'Sahibi';

  @override
  String get viewerInfoLabelCoordinates => 'Koordinatlar';

  @override
  String get viewerInfoLabelAddress => 'Adres';

  @override
  String get mapStyleDialogTitle => 'Harita Şekli';

  @override
  String get mapStyleTooltip => 'Harita şeklini seç';

  @override
  String get mapZoomInTooltip => 'Yakınlaştır';

  @override
  String get mapZoomOutTooltip => 'Uzaklaştır';

  @override
  String get mapPointNorthUpTooltip => 'Kuzeyi göster';

  @override
  String get mapAttributionOsmData => 'Harita verileri © [OpenStreetMap](https://www.openstreetmap.org/copyright) katkıda bulunanlar';

  @override
  String get mapAttributionOsmLiberty => 'Döşemeler [OpenMapTiles](https://www.openmaptiles.org/), [CC BY](http://creativecommons.org/licenses/by/4.0) • Barındıran [OSM Americana](https://tile.ourmap.us)';

  @override
  String get mapAttributionOpenTopoMap => '[SRTM](https://www.earthdata.nasa.gov/sensors/srtm) | Döşemeler [OpenTopoMap](https://opentopomap.org/), [CC BY-SA](https://creativecommons.org/licenses/by-sa/3.0/)';

  @override
  String get mapAttributionOsmHot => 'Döşemeler [HOT](https://www.hotosm.org/) • Barındıran [OSM France](https://openstreetmap.fr/)';

  @override
  String get mapAttributionStamen => 'Döşemeler [Stamen Design](https://stamen.com), [CC BY 3.0](https://creativecommons.org/licenses/by/3.0)';

  @override
  String get openMapPageTooltip => 'Harita sayfasında görüntüle';

  @override
  String get mapEmptyRegion => 'Bu bölgede resim yok';

  @override
  String get viewerInfoOpenEmbeddedFailureFeedback => 'Gömülü veriler ayıklanamadı';

  @override
  String get viewerInfoOpenLinkText => 'Aç';

  @override
  String get viewerInfoViewXmlLinkText => 'XML\'i Görüntüle';

  @override
  String get viewerInfoSearchFieldLabel => 'Meta verileri ara';

  @override
  String get viewerInfoSearchEmpty => 'Eşleşen anahtar yok';

  @override
  String get viewerInfoSearchSuggestionDate => 'Tarih ve saat';

  @override
  String get viewerInfoSearchSuggestionDescription => 'Açıklama';

  @override
  String get viewerInfoSearchSuggestionDimensions => 'Boyutlar';

  @override
  String get viewerInfoSearchSuggestionResolution => 'Çözünürlük';

  @override
  String get viewerInfoSearchSuggestionRights => 'Haklar';

  @override
  String get wallpaperUseScrollEffect => 'Ana ekranda kaydırma efektini kullan';

  @override
  String get tagEditorPageTitle => 'Etiketleri Düzenle';

  @override
  String get tagEditorPageNewTagFieldLabel => 'Yeni etiket';

  @override
  String get tagEditorPageAddTagTooltip => 'Etiket ekle';

  @override
  String get tagEditorSectionRecent => 'Yakın zamanda';

  @override
  String get tagEditorSectionPlaceholders => 'Yer Tutucular';

  @override
  String get tagEditorDiscardDialogMessage => 'Değişikliklerden vazgeçmek istiyor musunuz?';

  @override
  String get tagPlaceholderCountry => 'Ülke';

  @override
  String get tagPlaceholderState => 'Eyalet';

  @override
  String get tagPlaceholderPlace => 'Yer';

  @override
  String get panoramaEnableSensorControl => 'Sensör kontrolünü etkinleştir';

  @override
  String get panoramaDisableSensorControl => 'Sensör kontrolünü devre dışı bırak';

  @override
  String get sourceViewerPageTitle => 'Kaynak';

  @override
  String get filePickerShowHiddenFiles => 'Gizli dosyaları göster';

  @override
  String get filePickerDoNotShowHiddenFiles => 'Gizli dosyaları gösterme';

  @override
  String get filePickerOpenFrom => 'Şuradan aç';

  @override
  String get filePickerNoItems => 'Öge yok';

  @override
  String get filePickerUseThisFolder => 'Bu klasörü kullan';
}
