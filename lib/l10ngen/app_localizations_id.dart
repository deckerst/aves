// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appName => 'Aves';

  @override
  String get welcomeMessage => 'Selamat datang di Aves';

  @override
  String get welcomeOptional => 'Opsional';

  @override
  String get welcomeTermsToggle => 'Saya menyetujui syarat dan ketentuan';

  @override
  String itemCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString benda',
    );
    return '$_temp0';
  }

  @override
  String columnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kolom',
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
      other: '$countString detik',
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
      other: '$countString menit',
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
      other: '$countString hari',
    );
    return '$_temp0';
  }

  @override
  String focalLength(String length) {
    return '$length mm';
  }

  @override
  String get applyButtonLabel => 'TERAPKAN';

  @override
  String get deleteButtonLabel => 'BUANG';

  @override
  String get nextButtonLabel => 'SELANJUTNYA';

  @override
  String get showButtonLabel => 'TAMPILKAN';

  @override
  String get hideButtonLabel => 'SEMBUNYIKAN';

  @override
  String get continueButtonLabel => 'SELANJUTNYA';

  @override
  String get saveCopyButtonLabel => 'SIMPAN SALINAN';

  @override
  String get applyTooltip => 'Terapkan';

  @override
  String get cancelTooltip => 'Batal';

  @override
  String get changeTooltip => 'Ganti';

  @override
  String get clearTooltip => 'Hapus';

  @override
  String get previousTooltip => 'Sebelumnya';

  @override
  String get nextTooltip => 'Selanjutnya';

  @override
  String get showTooltip => 'Tampilkan';

  @override
  String get hideTooltip => 'Sembunyikan';

  @override
  String get actionRemove => 'Hapus';

  @override
  String get resetTooltip => 'Ulang';

  @override
  String get saveTooltip => 'Simpan';

  @override
  String get stopTooltip => 'Berhenti';

  @override
  String get pickTooltip => 'Pilih';

  @override
  String get doubleBackExitMessage => 'Ketuk “kembali” lagi untuk keluar.';

  @override
  String get doNotAskAgain => 'Jangan tanya lagi';

  @override
  String get sourceStateLoading => 'Memuat';

  @override
  String get sourceStateCataloguing => 'Mengkataloging';

  @override
  String get sourceStateLocatingCountries => 'Mencari negara';

  @override
  String get sourceStateLocatingPlaces => 'Mencari tempat';

  @override
  String get chipActionDelete => 'Hapus';

  @override
  String get chipActionRemove => 'Hapus';

  @override
  String get chipActionShowCollection => 'Tampilkan di Koleksi';

  @override
  String get chipActionGoToAlbumPage => 'Tampilkan di Album';

  @override
  String get chipActionGoToCountryPage => 'Tampilkan di Negara';

  @override
  String get chipActionGoToPlacePage => 'Tampilkan di Tempat';

  @override
  String get chipActionGoToTagPage => 'Tampilkan di Label';

  @override
  String get chipActionGoToExplorerPage => 'Tampilkan di Penjelajah';

  @override
  String get chipActionDecompose => 'Pisah';

  @override
  String get chipActionFilterOut => 'Filter keluar';

  @override
  String get chipActionFilterIn => 'Filter masuk';

  @override
  String get chipActionHide => 'Sembunyikan';

  @override
  String get chipActionLock => 'Kunci';

  @override
  String get chipActionPin => 'Sematkan ke atas';

  @override
  String get chipActionUnpin => 'Lepas sematan dari atas';

  @override
  String get chipActionRename => 'Ganti nama';

  @override
  String get chipActionSetCover => 'Setel sampul';

  @override
  String get chipActionShowCountryStates => 'Tampilkan wilayah';

  @override
  String get chipActionCreateAlbum => 'Buat album';

  @override
  String get chipActionCreateVault => 'Buat brankas';

  @override
  String get chipActionConfigureVault => 'Atur brankas';

  @override
  String get entryActionCopyToClipboard => 'Salin ke papan klip';

  @override
  String get entryActionDelete => 'Hapus';

  @override
  String get entryActionConvert => 'Ubah';

  @override
  String get entryActionExport => 'Ekspor';

  @override
  String get entryActionInfo => 'Info';

  @override
  String get entryActionRename => 'Ganti nama';

  @override
  String get entryActionRestore => 'Pulihkan';

  @override
  String get entryActionRotateCCW => 'Putar berlawanan arah jarum jam';

  @override
  String get entryActionRotateCW => 'Putar searah jarum jam';

  @override
  String get entryActionFlip => 'Balik secara horisontal';

  @override
  String get entryActionPrint => 'Cetak';

  @override
  String get entryActionShare => 'Bagikan';

  @override
  String get entryActionShareImageOnly => 'Bagikan gambar saja';

  @override
  String get entryActionShareVideoOnly => 'Bagikan video saja';

  @override
  String get entryActionViewSource => 'Lihat sumber';

  @override
  String get entryActionShowGeoTiffOnMap => 'Tampilkan sebagai hamparan peta';

  @override
  String get entryActionConvertMotionPhotoToStillImage => 'Ubah ke gambar tetap';

  @override
  String get entryActionViewMotionPhotoVideo => 'Buka video';

  @override
  String get entryActionEdit => 'Ubah';

  @override
  String get entryActionOpen => 'Buka dengan';

  @override
  String get entryActionSetAs => 'Tetapkan sebagai';

  @override
  String get entryActionCast => 'Siarkan';

  @override
  String get entryActionOpenMap => 'Tampilkan di peta';

  @override
  String get entryActionRotateScreen => 'Putar layar';

  @override
  String get entryActionAddFavourite => 'Tambahkan ke favorit';

  @override
  String get entryActionRemoveFavourite => 'Hapus dari favorit';

  @override
  String get videoActionCaptureFrame => 'Tangkap bingkai';

  @override
  String get videoActionMute => 'Matikan Suara';

  @override
  String get videoActionUnmute => 'Hidupkan Suara';

  @override
  String get videoActionPause => 'Hentikan';

  @override
  String get videoActionPlay => 'Mainkan';

  @override
  String get videoActionReplay10 => 'Mundurkan 10 detik';

  @override
  String get videoActionSkip10 => 'Majukan 10 detik';

  @override
  String get videoActionShowPreviousFrame => 'Tampilkan bingkai sebelumnya';

  @override
  String get videoActionShowNextFrame => 'Tampilkan bingkai berikutnya';

  @override
  String get videoActionSelectStreams => 'Pilih trek';

  @override
  String get videoActionSetSpeed => 'Kecepatan pemutaran';

  @override
  String get videoActionABRepeat => 'Ulang A-B';

  @override
  String get videoRepeatActionSetStart => 'Tetapkan awal';

  @override
  String get videoRepeatActionSetEnd => 'Tetapkan akhir';

  @override
  String get viewerActionSettings => 'Pengaturan';

  @override
  String get viewerActionLock => 'Kunci penampil';

  @override
  String get viewerActionUnlock => 'Buka kunci penampil';

  @override
  String get slideshowActionResume => 'Lanjutkan';

  @override
  String get slideshowActionShowInCollection => 'Tampilkan di Koleksi';

  @override
  String get entryInfoActionEditDate => 'Ubah tanggal & waktu';

  @override
  String get entryInfoActionEditLocation => 'Ubah lokasi';

  @override
  String get entryInfoActionEditTitleDescription => 'Ubah judul & deskripsi';

  @override
  String get entryInfoActionEditRating => 'Ubah nilai';

  @override
  String get entryInfoActionEditTags => 'Ubah label';

  @override
  String get entryInfoActionRemoveMetadata => 'Hapus metadata';

  @override
  String get entryInfoActionExportMetadata => 'Ekspor metadata';

  @override
  String get entryInfoActionRemoveLocation => 'Hapus lokasi';

  @override
  String get editorActionTransform => 'Transformasi';

  @override
  String get editorTransformCrop => 'Potong';

  @override
  String get editorTransformRotate => 'Putar';

  @override
  String get cropAspectRatioFree => 'Bebas';

  @override
  String get cropAspectRatioOriginal => 'Asli';

  @override
  String get cropAspectRatioSquare => 'Kotak';

  @override
  String get filterAspectRatioLandscapeLabel => 'Lanskap';

  @override
  String get filterAspectRatioPortraitLabel => 'Potret';

  @override
  String get filterBinLabel => 'Tong sampah';

  @override
  String get filterFavouriteLabel => 'Favorit';

  @override
  String get filterNoDateLabel => 'Tak ada tanggal';

  @override
  String get filterNoAddressLabel => 'Tidak ada alamat';

  @override
  String get filterLocatedLabel => 'Terletak';

  @override
  String get filterNoLocationLabel => 'Lokasi yang tidak ditemukan';

  @override
  String get filterNoRatingLabel => 'Belum diberi nilai';

  @override
  String get filterTaggedLabel => 'Dilabel';

  @override
  String get filterNoTagLabel => 'Tidak dilabel';

  @override
  String get filterNoTitleLabel => 'Tak ada judul';

  @override
  String get filterOnThisDayLabel => 'Di hari ini';

  @override
  String get filterRecentlyAddedLabel => 'Baru-baru ini ditambahkan';

  @override
  String get filterRatingRejectedLabel => 'Ditolak';

  @override
  String get filterTypeAnimatedLabel => 'Teranimasi';

  @override
  String get filterTypeMotionPhotoLabel => 'Foto bergerak';

  @override
  String get filterTypePanoramaLabel => 'Panorama';

  @override
  String get filterTypeRawLabel => 'Raw';

  @override
  String get filterTypeSphericalVideoLabel => 'Vidio 360°';

  @override
  String get filterTypeGeotiffLabel => 'GeoTIFF';

  @override
  String get filterMimeImageLabel => 'Gambar';

  @override
  String get filterMimeVideoLabel => 'Video';

  @override
  String get accessibilityAnimationsRemove => 'Cegah efek layar';

  @override
  String get accessibilityAnimationsKeep => 'Simpan efek layar';

  @override
  String get albumTierNew => 'Baru';

  @override
  String get albumTierPinned => 'Disemat';

  @override
  String get albumTierSpecial => 'Biasa';

  @override
  String get albumTierApps => 'Aplikasi';

  @override
  String get albumTierVaults => 'Brankas';

  @override
  String get albumTierDynamic => 'Dinamis';

  @override
  String get albumTierRegular => 'Lainnya';

  @override
  String get coordinateFormatDms => 'DMS';

  @override
  String get coordinateFormatDdm => 'DDM';

  @override
  String get coordinateFormatDecimal => 'Derajat desimal';

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
  String get displayRefreshRatePreferHighest => 'Penyegaran tertinggi';

  @override
  String get displayRefreshRatePreferLowest => 'Penyegaran terendah';

  @override
  String get keepScreenOnNever => 'Jangan pernah';

  @override
  String get keepScreenOnVideoPlayback => 'Saat pemutaran video';

  @override
  String get keepScreenOnViewerOnly => 'Hanya halaman penampil';

  @override
  String get keepScreenOnAlways => 'Selalu';

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
  String get maxBrightnessNever => 'Tidak pernah';

  @override
  String get maxBrightnessAlways => 'Selalu';

  @override
  String get nameConflictStrategyRename => 'Ganti nama';

  @override
  String get nameConflictStrategyReplace => 'Ganti';

  @override
  String get nameConflictStrategySkip => 'Lewati';

  @override
  String get overlayHistogramNone => 'Tidak ada';

  @override
  String get overlayHistogramRGB => 'RGB';

  @override
  String get overlayHistogramLuminance => 'Kecerahan';

  @override
  String get subtitlePositionTop => 'Teratas';

  @override
  String get subtitlePositionBottom => 'Bawah';

  @override
  String get themeBrightnessLight => 'Terang';

  @override
  String get themeBrightnessDark => 'Gelap';

  @override
  String get themeBrightnessBlack => 'Hitam';

  @override
  String get unitSystemMetric => 'Metrik';

  @override
  String get unitSystemImperial => 'Imperial';

  @override
  String get vaultLockTypePattern => 'Pola';

  @override
  String get vaultLockTypePin => 'Pin';

  @override
  String get vaultLockTypePassword => 'Kata sandi';

  @override
  String get settingsVideoEnablePip => 'Gambar dalam gambar';

  @override
  String get videoControlsPlayOutside => 'Buka dengan pemutar lain';

  @override
  String get videoLoopModeNever => 'Jangan pernah';

  @override
  String get videoLoopModeShortOnly => 'Hanya video pendek';

  @override
  String get videoLoopModeAlways => 'Selalu';

  @override
  String get videoPlaybackSkip => 'Lewati';

  @override
  String get videoPlaybackMuted => 'Mainkan bisu';

  @override
  String get videoPlaybackWithSound => 'Mainkan dengan suara';

  @override
  String get videoResumptionModeNever => 'Tidak pernah';

  @override
  String get videoResumptionModeAlways => 'Selalu';

  @override
  String get viewerTransitionSlide => 'Menggeser';

  @override
  String get viewerTransitionParallax => 'Paralaks';

  @override
  String get viewerTransitionFade => 'Memudar';

  @override
  String get viewerTransitionZoomIn => 'Membesar';

  @override
  String get viewerTransitionNone => 'Tidak ada';

  @override
  String get wallpaperTargetHome => 'Tampilan depan';

  @override
  String get wallpaperTargetLock => 'Tampilan kunci';

  @override
  String get wallpaperTargetHomeLock => 'Tampilan depan dan kunci';

  @override
  String get widgetDisplayedItemRandom => 'Acak';

  @override
  String get widgetDisplayedItemMostRecent => 'Terkini';

  @override
  String get widgetOpenPageHome => 'Buka beranda';

  @override
  String get widgetOpenPageCollection => 'Buka koleksi';

  @override
  String get widgetOpenPageViewer => 'Buka penampil';

  @override
  String get widgetTapUpdateWidget => 'Perbarui widget';

  @override
  String get storageVolumeDescriptionFallbackPrimary => 'Penyimpanan internal';

  @override
  String get storageVolumeDescriptionFallbackNonPrimary => 'kartu SD';

  @override
  String get rootDirectoryDescription => 'direktori root';

  @override
  String otherDirectoryDescription(String name) {
    return 'direktori “$name”';
  }

  @override
  String storageAccessDialogMessage(String directory, String volume) {
    return 'Silahkan pilih $directory dari “$volume” di layar berikutnya untuk memberikan akses aplikasi ini ke sana.';
  }

  @override
  String restrictedAccessDialogMessage(String directory, String volume) {
    return 'Aplikasi ini tidak diizinkan untuk mengubah file di $directory dari “$volume”.\n\nSilahkan pakai aplikasi Manager File atau aplikasi gallery untuk gerakkan benda ke direktori lain.';
  }

  @override
  String notEnoughSpaceDialogMessage(String neededSize, String freeSize, String volume) {
    return 'Operasi ini memerlukan $neededSize ruang kosong di “$volume” untuk menyelesaikan, tetapi hanya ada $freeSize tersisa.';
  }

  @override
  String get missingSystemFilePickerDialogMessage => 'Pemilih file sistem tidak ada atau dinonaktifkan. Harap aktifkan dan coba lagi.';

  @override
  String unsupportedTypeDialogMessage(int count, String types) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Operasi ini tidak didukung untuk benda dari jenis berikut: $types.',
    );
    return '$_temp0';
  }

  @override
  String get nameConflictDialogSingleSourceMessage => 'Beberapa file di folder tujuan memiliki nama yang sama.';

  @override
  String get nameConflictDialogMultipleSourceMessage => 'Beberapa file memiliki nama yang sama.';

  @override
  String get addShortcutDialogLabel => 'Label pintasan';

  @override
  String get addShortcutButtonLabel => 'TAMBAH';

  @override
  String get noMatchingAppDialogMessage => 'Tidak ada aplikasi yang cocok untuk menangani ini.';

  @override
  String binEntriesConfirmationDialogMessage(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Pindahkan $countString benda ke tempat sampah?',
      one: 'Pindahkan benda ini ke tong sampah?',
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
      other: 'Apakah Anda yakin ingin menghapus $countString benda?',
      one: 'Anda yakin ingin menghapus benda ini?',
    );
    return '$_temp0';
  }

  @override
  String get moveUndatedConfirmationDialogMessage => 'Simpan tanggal benda sebelum melanjutkan?';

  @override
  String get moveUndatedConfirmationDialogSetDate => 'Atur tanggal';

  @override
  String videoResumeDialogMessage(String time) {
    return 'Apakah Anda ingin melanjutkan di $time?';
  }

  @override
  String get videoStartOverButtonLabel => 'ULANG DARI AWAL';

  @override
  String get videoResumeButtonLabel => 'LANJUT';

  @override
  String get setCoverDialogLatest => 'Benda terbaru';

  @override
  String get setCoverDialogAuto => 'Otomatis';

  @override
  String get setCoverDialogCustom => 'Kustom';

  @override
  String get hideFilterConfirmationDialogMessage => 'Foto dan video yang cocok akan disembunyikan dari koleksi Anda. Anda dapat menampilkannya lagi dari pengaturan “Privasi”.\n\nApakah Anda yakin ingin menyembunyikannya?';

  @override
  String get newAlbumDialogTitle => 'Album Baru';

  @override
  String get newAlbumDialogNameLabel => 'Nama album';

  @override
  String get newAlbumDialogAlbumAlreadyExistsHelper => 'Album sudah ada';

  @override
  String get newAlbumDialogNameLabelAlreadyExistsHelper => 'Direktori sudah ada';

  @override
  String get newAlbumDialogStorageLabel => 'Penyimpanan:';

  @override
  String get newDynamicAlbumDialogTitle => 'Album Dinamis Baru';

  @override
  String get dynamicAlbumAlreadyExists => 'Album dinamis sudah ada';

  @override
  String get newVaultWarningDialogMessage => 'Item dalam brankas hanya tersedia untuk aplikasi ini dan bukan yang lain.\n\nJika Anda menghapus aplikasi ini, atau menghapus data aplikasi ini, Anda akan kehilangan semua item tersebut.';

  @override
  String get newVaultDialogTitle => 'Brankas Baru';

  @override
  String get configureVaultDialogTitle => 'Atur Brankas';

  @override
  String get vaultDialogLockModeWhenScreenOff => 'Kunci ketika layar mati';

  @override
  String get vaultDialogLockTypeLabel => 'Jenis penguncian';

  @override
  String get patternDialogEnter => 'Masukkan pola';

  @override
  String get patternDialogConfirm => 'Konfirmasi pola';

  @override
  String get pinDialogEnter => 'Masukkan pin';

  @override
  String get pinDialogConfirm => 'Konfirmasi pin';

  @override
  String get passwordDialogEnter => 'Masukkan kata sandi';

  @override
  String get passwordDialogConfirm => 'Konfirmasi kata sandi';

  @override
  String get authenticateToConfigureVault => 'Autentikasi untuk mengatur brankas';

  @override
  String get authenticateToUnlockVault => 'Autentikasi untuk membuka brankas';

  @override
  String get vaultBinUsageDialogMessage => 'Beberapa brankas menggunakan tong sampah.';

  @override
  String get renameAlbumDialogLabel => 'Nama baru';

  @override
  String get renameAlbumDialogLabelAlreadyExistsHelper => 'Direktori sudah ada';

  @override
  String get renameEntrySetPageTitle => 'Ganti nama';

  @override
  String get renameEntrySetPagePatternFieldLabel => 'Pola penamaan';

  @override
  String get renameEntrySetPageInsertTooltip => 'Masukkan bidang';

  @override
  String get renameEntrySetPagePreviewSectionTitle => 'Pratinjau';

  @override
  String get renameProcessorCounter => 'Penghitungan';

  @override
  String get renameProcessorHash => 'Hash';

  @override
  String get renameProcessorName => 'Nama';

  @override
  String deleteSingleAlbumConfirmationDialogMessage(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hapus album ini dan $countString item yang ada di dalam?',
      one: 'Hapus album ini dan item yang ada di dalam?',
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
      other: 'Hapus album ini dan $countString item yang ada di dalam?',
      one: 'Hapus album ini dan item yang ada di dalam?',
    );
    return '$_temp0';
  }

  @override
  String get exportEntryDialogFormat => 'Format:';

  @override
  String get exportEntryDialogWidth => 'Lebar';

  @override
  String get exportEntryDialogHeight => 'Tinggi';

  @override
  String get exportEntryDialogQuality => 'Kualitas';

  @override
  String get exportEntryDialogWriteMetadata => 'Tulis metadata';

  @override
  String get renameEntryDialogLabel => 'Nama baru';

  @override
  String get editEntryDialogCopyFromItem => 'Salin dari benda lain';

  @override
  String get editEntryDialogTargetFieldsHeader => 'Bidang untuk dimodifikasikan';

  @override
  String get editEntryDateDialogTitle => 'Tanggal & Waktu';

  @override
  String get editEntryDateDialogSetCustom => 'Atur tanggal khusus';

  @override
  String get editEntryDateDialogCopyField => 'Salin dari tanggal lain';

  @override
  String get editEntryDateDialogExtractFromTitle => 'Ekstrak dari judul';

  @override
  String get editEntryDateDialogShift => 'Geser';

  @override
  String get editEntryDateDialogSourceFileModifiedDate => 'Tanggal modifikasi file';

  @override
  String get durationDialogHours => 'Jam';

  @override
  String get durationDialogMinutes => 'Menit';

  @override
  String get durationDialogSeconds => 'Detik';

  @override
  String get editEntryLocationDialogTitle => 'Lokasi';

  @override
  String get editEntryLocationDialogSetCustom => 'Terapkan lokasi kustom';

  @override
  String get editEntryLocationDialogChooseOnMap => 'Pilih di peta';

  @override
  String get editEntryLocationDialogImportGpx => 'Impor GPX';

  @override
  String get editEntryLocationDialogLatitude => 'Garis lintang';

  @override
  String get editEntryLocationDialogLongitude => 'Garis bujur';

  @override
  String get editEntryLocationDialogTimeShift => 'Pergeseran waktu';

  @override
  String get locationPickerUseThisLocationButton => 'Gunakan lokasi ini';

  @override
  String get editEntryRatingDialogTitle => 'Nilai';

  @override
  String get removeEntryMetadataDialogTitle => 'Penghapusan Metadata';

  @override
  String get removeEntryMetadataDialogAll => 'Semua';

  @override
  String get removeEntryMetadataDialogMore => 'Lebih Banyak';

  @override
  String get removeEntryMetadataMotionPhotoXmpWarningDialogMessage => 'XMP diperlukan untuk memutar video di dalam Foto bergerak.\n\nAnda yakin ingin menghapusnya?';

  @override
  String get videoSpeedDialogLabel => 'Kecepatan pemutaran';

  @override
  String get videoStreamSelectionDialogVideo => 'Video';

  @override
  String get videoStreamSelectionDialogAudio => 'Audio';

  @override
  String get videoStreamSelectionDialogText => 'Subjudul';

  @override
  String get videoStreamSelectionDialogOff => 'Mati';

  @override
  String get videoStreamSelectionDialogTrack => 'Trek';

  @override
  String get videoStreamSelectionDialogNoSelection => 'Tidak ada Trek yang lain.';

  @override
  String get genericSuccessFeedback => 'Selesai!';

  @override
  String get genericFailureFeedback => 'Gagal';

  @override
  String get genericDangerWarningDialogMessage => 'Apakah kamu yakin?';

  @override
  String get tooManyItemsErrorDialogMessage => 'Coba lagi dengan item yang lebih sedikit.';

  @override
  String get menuActionConfigureView => 'Tata letak';

  @override
  String get menuActionSelect => 'Pilih';

  @override
  String get menuActionSelectAll => 'Pilih semua';

  @override
  String get menuActionSelectNone => 'Pilih tidak ada';

  @override
  String get menuActionMap => 'Peta';

  @override
  String get menuActionSlideshow => 'Tampilan slide';

  @override
  String get menuActionStats => 'Statistik';

  @override
  String get viewDialogSortSectionTitle => 'Sortir';

  @override
  String get viewDialogGroupSectionTitle => 'Grup';

  @override
  String get viewDialogLayoutSectionTitle => 'Tata letak';

  @override
  String get viewDialogReverseSortOrder => 'Urutan pengurutan terbalik';

  @override
  String get tileLayoutMosaic => 'Mosaik';

  @override
  String get tileLayoutGrid => 'Grid';

  @override
  String get tileLayoutList => 'Daftar';

  @override
  String get castDialogTitle => 'Siarkan Perangkat';

  @override
  String get coverDialogTabCover => 'Kover';

  @override
  String get coverDialogTabApp => 'Aplikasi';

  @override
  String get coverDialogTabColor => 'Warna';

  @override
  String get appPickDialogTitle => 'Pilih Aplikasi';

  @override
  String get appPickDialogNone => 'Tidak ada';

  @override
  String get aboutPageTitle => 'Tentang';

  @override
  String get aboutLinkLicense => 'Lisensi';

  @override
  String get aboutLinkPolicy => 'Aturan Privasi';

  @override
  String get aboutBugSectionTitle => 'Lapor Bug';

  @override
  String get aboutBugSaveLogInstruction => 'Simpan log aplikasi ke file';

  @override
  String get aboutBugCopyInfoInstruction => 'Salin informasi sistem';

  @override
  String get aboutBugCopyInfoButton => 'Salin';

  @override
  String get aboutBugReportInstruction => 'Laporkan ke GitHub dengan log dan informasi sistem';

  @override
  String get aboutBugReportButton => 'Rapor';

  @override
  String get aboutDataUsageSectionTitle => 'Penggunaan Data';

  @override
  String get aboutDataUsageData => 'Data';

  @override
  String get aboutDataUsageCache => 'Tembolok';

  @override
  String get aboutDataUsageDatabase => 'Basis Data';

  @override
  String get aboutDataUsageMisc => 'Lainnya';

  @override
  String get aboutDataUsageInternal => 'Internal';

  @override
  String get aboutDataUsageExternal => 'Eksternal';

  @override
  String get aboutDataUsageClearCache => 'Bersihkan cache';

  @override
  String get aboutCreditsSectionTitle => 'Kredit';

  @override
  String get aboutCreditsWorldAtlas1 => 'Aplikasi ini menggunakan file TopoJSON dari';

  @override
  String get aboutCreditsWorldAtlas2 => 'dibawah Lisensi ISC.';

  @override
  String get aboutTranslatorsSectionTitle => 'Penerjemah';

  @override
  String get aboutLicensesSectionTitle => 'Lisensi Sumber Terbuka';

  @override
  String get aboutLicensesBanner => 'Aplikasi ini menggunakan paket dan perpustakaan sumber terbuka berikut.';

  @override
  String get aboutLicensesAndroidLibrariesSectionTitle => 'Perpustakaan Android';

  @override
  String get aboutLicensesFlutterPluginsSectionTitle => 'Plugin Flutter';

  @override
  String get aboutLicensesFlutterPackagesSectionTitle => 'Paket Flutter';

  @override
  String get aboutLicensesDartPackagesSectionTitle => 'Paket Dart';

  @override
  String get aboutLicensesShowAllButtonLabel => 'Tampilkan Semua Lisensi';

  @override
  String get policyPageTitle => 'Aturan Privasi';

  @override
  String get collectionPageTitle => 'Koleksi';

  @override
  String get collectionPickPageTitle => 'Pilih';

  @override
  String get collectionSelectPageTitle => 'Pilih benda';

  @override
  String get collectionActionShowTitleSearch => 'Tampilkan filter judul';

  @override
  String get collectionActionHideTitleSearch => 'Sembunyikan filter judul';

  @override
  String get collectionActionAddDynamicAlbum => 'Tambahkan album dinamis';

  @override
  String get collectionActionAddShortcut => 'Tambahkan pintasan';

  @override
  String get collectionActionSetHome => 'Tetapkan sebagai beranda';

  @override
  String get collectionActionEmptyBin => 'Kosongkan tong sampah';

  @override
  String get collectionActionCopy => 'Salin ke album';

  @override
  String get collectionActionMove => 'Pindah ke album';

  @override
  String get collectionActionRescan => 'Pindai ulang';

  @override
  String get collectionActionEdit => 'Ubah';

  @override
  String get collectionSearchTitlesHintText => 'Cari judul';

  @override
  String get collectionGroupAlbum => 'Lewat album';

  @override
  String get collectionGroupMonth => 'Lewat bulan';

  @override
  String get collectionGroupDay => 'Lewat hari';

  @override
  String get collectionGroupNone => 'Jangan kelompokkan';

  @override
  String get sectionUnknown => 'Tidak dikenal';

  @override
  String get dateToday => 'Hari ini';

  @override
  String get dateYesterday => 'Kemaren';

  @override
  String get dateThisMonth => 'Bulan ini';

  @override
  String collectionDeleteFailureFeedback(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Gagal untuk menghapus $countString benda',
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
      other: 'Gagal untuk menyalin $countString benda',
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
      other: 'Gagal untuk menggerakkan $countString benda',
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
      other: 'Gagal untuk menggantikan nama $countString benda',
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
      other: 'Gagal untuk mengubah $countString benda',
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
      other: 'Gagal untuk mengekspor $countString halaman',
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
      other: 'Menyalin $countString benda',
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
      other: '$countString benda terpindah',
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
      other: 'Tergantikan nama untuk $countString benda',
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
      other: 'Mengubah $countString benda',
    );
    return '$_temp0';
  }

  @override
  String get collectionEmptyFavourites => 'Tidak ada favorit';

  @override
  String get collectionEmptyVideos => 'Tidak ada video';

  @override
  String get collectionEmptyImages => 'Tidak ada gambar';

  @override
  String get collectionEmptyGrantAccessButtonLabel => 'Berikan akses';

  @override
  String get collectionSelectSectionTooltip => 'Pilih bagian';

  @override
  String get collectionDeselectSectionTooltip => 'Batalkan pilihan bagian';

  @override
  String get drawerAboutButton => 'Tentang';

  @override
  String get drawerSettingsButton => 'Pengaturan';

  @override
  String get drawerCollectionAll => 'Semua koleksi';

  @override
  String get drawerCollectionFavourites => 'Favorit';

  @override
  String get drawerCollectionImages => 'Gambar';

  @override
  String get drawerCollectionVideos => 'Video';

  @override
  String get drawerCollectionAnimated => 'Teranimasi';

  @override
  String get drawerCollectionMotionPhotos => 'Foto bergerak';

  @override
  String get drawerCollectionPanoramas => 'Panorama';

  @override
  String get drawerCollectionRaws => 'Foto Raw';

  @override
  String get drawerCollectionSphericalVideos => 'Video 360°';

  @override
  String get drawerAlbumPage => 'Album';

  @override
  String get drawerCountryPage => 'Negara';

  @override
  String get drawerPlacePage => 'Tempat';

  @override
  String get drawerTagPage => 'Label';

  @override
  String get sortByDate => 'Lewat tanggal';

  @override
  String get sortByName => 'Lewat nama';

  @override
  String get sortByItemCount => 'Lewat jumlah benda';

  @override
  String get sortBySize => 'Lewat ukuran';

  @override
  String get sortByAlbumFileName => 'Lewat nama album & file';

  @override
  String get sortByRating => 'Lewat nilai';

  @override
  String get sortByDuration => 'Berdasarkan durasi';

  @override
  String get sortByPath => 'By path';

  @override
  String get sortOrderNewestFirst => 'Terbaru pertama';

  @override
  String get sortOrderOldestFirst => 'Tertua pertama';

  @override
  String get sortOrderAtoZ => 'A ke Z';

  @override
  String get sortOrderZtoA => 'Z ke A';

  @override
  String get sortOrderHighestFirst => 'Tertinggi pertama';

  @override
  String get sortOrderLowestFirst => 'Terendah pertama';

  @override
  String get sortOrderLargestFirst => 'Terbesar pertama';

  @override
  String get sortOrderSmallestFirst => 'Terkecil pertama';

  @override
  String get sortOrderShortestFirst => 'Yang terpendek dulu';

  @override
  String get sortOrderLongestFirst => 'Yang terpanjang dulu';

  @override
  String get albumGroupTier => 'Lewat tingkat';

  @override
  String get albumGroupType => 'Berdasarkan tipe';

  @override
  String get albumGroupVolume => 'Lewat volume penyimpanan';

  @override
  String get albumGroupNone => 'Jangan kelompokkan';

  @override
  String get albumMimeTypeMixed => 'Tercampur';

  @override
  String get albumPickPageTitleCopy => 'Salin ke Album';

  @override
  String get albumPickPageTitleExport => 'Ekspor ke Album';

  @override
  String get albumPickPageTitleMove => 'Pindah ke Album';

  @override
  String get albumPickPageTitlePick => 'Pilih Album';

  @override
  String get albumCamera => 'Kamera';

  @override
  String get albumDownload => 'Download';

  @override
  String get albumScreenshots => 'Tangkapan layar';

  @override
  String get albumScreenRecordings => 'Rekaman layar';

  @override
  String get albumVideoCaptures => 'Tangkapan Video';

  @override
  String get albumPageTitle => 'Album';

  @override
  String get albumEmpty => 'Tidak ada album';

  @override
  String get createAlbumButtonLabel => 'BUAT';

  @override
  String get newFilterBanner => 'baru';

  @override
  String get countryPageTitle => 'Negara';

  @override
  String get countryEmpty => 'Tidak ada negara';

  @override
  String get statePageTitle => 'Wilayah';

  @override
  String get stateEmpty => 'Tidak ada wilayah';

  @override
  String get placePageTitle => 'Tempat';

  @override
  String get placeEmpty => 'Tidak ada tempat';

  @override
  String get tagPageTitle => 'Label';

  @override
  String get tagEmpty => 'Tidak ada label';

  @override
  String get binPageTitle => 'Tong Sampah';

  @override
  String get explorerPageTitle => 'Penjelajah';

  @override
  String get explorerActionSelectStorageVolume => 'Pilih penyimpanan';

  @override
  String get selectStorageVolumeDialogTitle => 'Pilih Penyimpanan';

  @override
  String get searchCollectionFieldHint => 'Cari koleksi';

  @override
  String get searchRecentSectionTitle => 'Terkini';

  @override
  String get searchDateSectionTitle => 'Tanggal';

  @override
  String get searchFormatSectionTitle => 'Formats';

  @override
  String get searchAlbumsSectionTitle => 'Album';

  @override
  String get searchCountriesSectionTitle => 'Negara';

  @override
  String get searchStatesSectionTitle => 'Wilayah';

  @override
  String get searchPlacesSectionTitle => 'Tempat';

  @override
  String get searchTagsSectionTitle => 'Label';

  @override
  String get searchRatingSectionTitle => 'Nilai';

  @override
  String get searchMetadataSectionTitle => 'Metadata';

  @override
  String get settingsPageTitle => 'Pengaturan';

  @override
  String get settingsSystemDefault => 'Sistem';

  @override
  String get settingsDefault => 'Default';

  @override
  String get settingsDisabled => 'Nonaktif';

  @override
  String get settingsAskEverytime => 'Ta za';

  @override
  String get settingsModificationWarningDialogMessage => 'Pengaturan lain akan diubah.';

  @override
  String get settingsSearchFieldLabel => 'Cari peraturan';

  @override
  String get settingsSearchEmpty => 'Tidak ada peraturan yang cocok';

  @override
  String get settingsActionExport => 'Ekspor';

  @override
  String get settingsActionExportDialogTitle => 'Ekspor';

  @override
  String get settingsActionImport => 'Impor';

  @override
  String get settingsActionImportDialogTitle => 'Impor';

  @override
  String get appExportCovers => 'Sampul';

  @override
  String get appExportDynamicAlbums => 'Album dinamis';

  @override
  String get appExportFavourites => 'Favorit';

  @override
  String get appExportSettings => 'Pengaturan';

  @override
  String get settingsNavigationSectionTitle => 'Navigasi';

  @override
  String get settingsHomeTile => 'Beranda';

  @override
  String get settingsHomeDialogTitle => 'Beranda';

  @override
  String get setHomeCustom => 'Kustom';

  @override
  String get settingsShowBottomNavigationBar => 'Tampilkan bilah navigasi bawah';

  @override
  String get settingsKeepScreenOnTile => 'Biarkan layarnya menyala';

  @override
  String get settingsKeepScreenOnDialogTitle => 'Biarkan Layarnya Menyala';

  @override
  String get settingsDoubleBackExit => 'Ketuk “kembali” dua kali untuk keluar';

  @override
  String get settingsConfirmationTile => 'Dialog konfirmasi';

  @override
  String get settingsConfirmationDialogTitle => 'Dialog Konfirmasi';

  @override
  String get settingsConfirmationBeforeDeleteItems => 'Tanya sebelum menghapus benda selamanya';

  @override
  String get settingsConfirmationBeforeMoveToBinItems => 'Tanya sebelum memindahkan benda ke tong sampah';

  @override
  String get settingsConfirmationBeforeMoveUndatedItems => 'Tanyakan sebelum memindahkan barang tanpa metadata tanggal';

  @override
  String get settingsConfirmationAfterMoveToBinItems => 'Tampilkan pesan setelah menggerakkan barang ke tong sampah';

  @override
  String get settingsConfirmationVaultDataLoss => 'Tampilkan peringatan kehilangan data brankas';

  @override
  String get settingsNavigationDrawerTile => 'Menu navigasi';

  @override
  String get settingsNavigationDrawerEditorPageTitle => 'Menu Navigasi';

  @override
  String get settingsNavigationDrawerBanner => 'Sentuh dan tahan untuk memindahkan dan menyusun ulang benda menu.';

  @override
  String get settingsNavigationDrawerTabTypes => 'Tipe';

  @override
  String get settingsNavigationDrawerTabAlbums => 'Album';

  @override
  String get settingsNavigationDrawerTabPages => 'Halaman';

  @override
  String get settingsNavigationDrawerAddAlbum => 'Tambahkan album';

  @override
  String get settingsThumbnailSectionTitle => 'Thumbnail';

  @override
  String get settingsThumbnailOverlayTile => 'Hamparan';

  @override
  String get settingsThumbnailOverlayPageTitle => 'Hamparan';

  @override
  String get settingsThumbnailShowHdrIcon => 'Tampilkan ikon HDR';

  @override
  String get settingsThumbnailShowFavouriteIcon => 'Tampilkan ikon favorit';

  @override
  String get settingsThumbnailShowTagIcon => 'Tampilkan ikon label';

  @override
  String get settingsThumbnailShowLocationIcon => 'Tampilkan ikon lokasi';

  @override
  String get settingsThumbnailShowMotionPhotoIcon => 'Tampilkan ikon Foto bergerak';

  @override
  String get settingsThumbnailShowRating => 'Tampilkan nilai';

  @override
  String get settingsThumbnailShowRawIcon => 'Tampilkan ikon raw';

  @override
  String get settingsThumbnailShowVideoDuration => 'Tampilkan durasi video';

  @override
  String get settingsCollectionQuickActionsTile => 'Aksi cepat';

  @override
  String get settingsCollectionQuickActionEditorPageTitle => 'Aksi Cepat';

  @override
  String get settingsCollectionQuickActionTabBrowsing => 'Menjelajah';

  @override
  String get settingsCollectionQuickActionTabSelecting => 'Memilih';

  @override
  String get settingsCollectionBrowsingQuickActionEditorBanner => 'Sentuh dan tahan untuk memindahkan tombol dan memilih tindakan yang ditampilkan saat menelusuri benda.';

  @override
  String get settingsCollectionSelectionQuickActionEditorBanner => 'Sentuh dan tahan untuk memindahkan tombol dan memilih tindakan yang ditampilkan saat memilih benda.';

  @override
  String get settingsCollectionBurstPatternsTile => 'Pola semburan';

  @override
  String get settingsCollectionBurstPatternsNone => 'Tidak ada';

  @override
  String get settingsViewerSectionTitle => 'Penampil';

  @override
  String get settingsViewerGestureSideTapNext => 'Ketuk tepi layar untuk menampilkan benda sebelumnya/berikutnya';

  @override
  String get settingsViewerUseCutout => 'Gunakan area potongan';

  @override
  String get settingsViewerMaximumBrightness => 'Kecerahan maksimum';

  @override
  String get settingsMotionPhotoAutoPlay => 'Putar foto bergerak otomatis';

  @override
  String get settingsImageBackground => 'Latar belakang gambar';

  @override
  String get settingsViewerQuickActionsTile => 'Aksi cepat';

  @override
  String get settingsViewerQuickActionEditorPageTitle => 'Aksi Cepat';

  @override
  String get settingsViewerQuickActionEditorBanner => 'Sentuh dan tahan untuk memindahkan tombol dan memilih tindakan yang ditampilkan di penampil.';

  @override
  String get settingsViewerQuickActionEditorDisplayedButtonsSectionTitle => 'Tombol yang Ditampilkan';

  @override
  String get settingsViewerQuickActionEditorAvailableButtonsSectionTitle => 'Tombol yang tersedia';

  @override
  String get settingsViewerQuickActionEmpty => 'Tidak ada tombol';

  @override
  String get settingsViewerOverlayTile => 'Hamparan';

  @override
  String get settingsViewerOverlayPageTitle => 'Hamparan';

  @override
  String get settingsViewerShowOverlayOnOpening => 'Tampilkan saat pembukaan';

  @override
  String get settingsViewerShowHistogram => 'Tampilkan histogram';

  @override
  String get settingsViewerShowMinimap => 'Tampilkan minimap';

  @override
  String get settingsViewerShowInformation => 'Tampilkan informasi';

  @override
  String get settingsViewerShowInformationSubtitle => 'Tampilkan judul, tanggal, lokasi, dll.';

  @override
  String get settingsViewerShowRatingTags => 'Tampilkan peringkat & tag';

  @override
  String get settingsViewerShowShootingDetails => 'Tampilkan detail pemotretan';

  @override
  String get settingsViewerShowDescription => 'Tampilkan deskripsi';

  @override
  String get settingsViewerShowOverlayThumbnails => 'Tampilkan thumbnail';

  @override
  String get settingsViewerEnableOverlayBlurEffect => 'Efek Kabur';

  @override
  String get settingsViewerSlideshowTile => 'Tampilan slide';

  @override
  String get settingsViewerSlideshowPageTitle => 'Tampilan Slide';

  @override
  String get settingsSlideshowRepeat => 'Ulangi';

  @override
  String get settingsSlideshowShuffle => 'Acak';

  @override
  String get settingsSlideshowFillScreen => 'Isi layar';

  @override
  String get settingsSlideshowAnimatedZoomEffect => 'Efek zoom bergerak';

  @override
  String get settingsSlideshowTransitionTile => 'Transisi';

  @override
  String get settingsSlideshowIntervalTile => 'Jarak waktu';

  @override
  String get settingsSlideshowVideoPlaybackTile => 'Putaran ulang video';

  @override
  String get settingsSlideshowVideoPlaybackDialogTitle => 'Putaran Ulang Video';

  @override
  String get settingsVideoPageTitle => 'Pengaturan Video';

  @override
  String get settingsVideoSectionTitle => 'Video';

  @override
  String get settingsVideoShowVideos => 'Tampilkan video';

  @override
  String get settingsVideoPlaybackTile => 'Pemutaran';

  @override
  String get settingsVideoPlaybackPageTitle => 'Pemutaran';

  @override
  String get settingsVideoEnableHardwareAcceleration => 'Akselerasi perangkat keras';

  @override
  String get settingsVideoAutoPlay => 'Putar otomatis';

  @override
  String get settingsVideoLoopModeTile => 'Putar ulang';

  @override
  String get settingsVideoLoopModeDialogTitle => 'Putar Ulang';

  @override
  String get settingsVideoResumptionModeTile => 'Lanjutkan pemutaran';

  @override
  String get settingsVideoResumptionModeDialogTitle => 'Lanjutkan Pemutaran';

  @override
  String get settingsVideoBackgroundMode => 'Mode latar belakang';

  @override
  String get settingsVideoBackgroundModeDialogTitle => 'Mode Latar Belakang';

  @override
  String get settingsVideoControlsTile => 'Kontrol';

  @override
  String get settingsVideoControlsPageTitle => 'Kontrol';

  @override
  String get settingsVideoButtonsTile => 'Tombol';

  @override
  String get settingsVideoGestureDoubleTapTogglePlay => 'Ketuk dua kali untuk mainkan/hentikan';

  @override
  String get settingsVideoGestureSideDoubleTapSeek => 'Ketuk dua kali di tepi layar untuk mencari kebelakang/kedepan';

  @override
  String get settingsVideoGestureVerticalDragBrightnessVolume => 'Usap ke atas atau bawah untuk mengatur kecerahan/volume';

  @override
  String get settingsSubtitleThemeTile => 'Subjudul';

  @override
  String get settingsSubtitleThemePageTitle => 'Subjudul';

  @override
  String get settingsSubtitleThemeSample => 'Ini adalah sampel.';

  @override
  String get settingsSubtitleThemeTextAlignmentTile => 'Perataan teks';

  @override
  String get settingsSubtitleThemeTextAlignmentDialogTitle => 'Perataan Teks';

  @override
  String get settingsSubtitleThemeTextPositionTile => 'Posisi teks';

  @override
  String get settingsSubtitleThemeTextPositionDialogTitle => 'Posisi Teks';

  @override
  String get settingsSubtitleThemeTextSize => 'Ukuran teks';

  @override
  String get settingsSubtitleThemeShowOutline => 'Tampilkan garis besar dan bayangan';

  @override
  String get settingsSubtitleThemeTextColor => 'Warna teks';

  @override
  String get settingsSubtitleThemeTextOpacity => 'Opasitas teks';

  @override
  String get settingsSubtitleThemeBackgroundColor => 'Warna latar belakang';

  @override
  String get settingsSubtitleThemeBackgroundOpacity => 'Opasitas latar belakang';

  @override
  String get settingsSubtitleThemeTextAlignmentLeft => 'Kiri';

  @override
  String get settingsSubtitleThemeTextAlignmentCenter => 'Tengah';

  @override
  String get settingsSubtitleThemeTextAlignmentRight => 'Kanan';

  @override
  String get settingsPrivacySectionTitle => 'Privasi';

  @override
  String get settingsAllowInstalledAppAccess => 'Izinkan akses ke inventori aplikasi';

  @override
  String get settingsAllowInstalledAppAccessSubtitle => 'Digunakan untuk meningkatkan tampilan album';

  @override
  String get settingsAllowErrorReporting => 'Izinkan pelaporan kesalahan secara anonim';

  @override
  String get settingsSaveSearchHistory => 'Simpan riwayat pencarian';

  @override
  String get settingsEnableBin => 'Gunakan tong sampah';

  @override
  String get settingsEnableBinSubtitle => 'Simpan benda yang dihapus selama 30 hari';

  @override
  String get settingsDisablingBinWarningDialogMessage => 'Item dalam tong sampah akan hilang selamanya.';

  @override
  String get settingsAllowMediaManagement => 'Izinkan pengelolaan media';

  @override
  String get settingsHiddenItemsTile => 'Benda tersembunyi';

  @override
  String get settingsHiddenItemsPageTitle => 'Benda Tersembunyi';

  @override
  String get settingsHiddenFiltersBanner => 'Foto dan video filter tersembunyi yang cocok tidak akan muncul di koleksi Anda.';

  @override
  String get settingsHiddenFiltersEmpty => 'Tidak ada filter tersembunyi';

  @override
  String get settingsStorageAccessTile => 'Akses penyimpanan';

  @override
  String get settingsStorageAccessPageTitle => 'Akses Penyimpanan';

  @override
  String get settingsStorageAccessBanner => 'Beberapa direktori memerlukan pemberian akses eksplisit untuk memodifikasi file di dalamnya. Anda dapat meninjau direktori yang anda beri akses sebelumnya di sini.';

  @override
  String get settingsStorageAccessEmpty => 'Tidak ada akses';

  @override
  String get settingsStorageAccessRevokeTooltip => 'Tarik kembali';

  @override
  String get settingsAccessibilitySectionTitle => 'Aksesibilitas';

  @override
  String get settingsRemoveAnimationsTile => 'Hapus animasi';

  @override
  String get settingsRemoveAnimationsDialogTitle => 'Hapus Animasi';

  @override
  String get settingsTimeToTakeActionTile => 'Waktu untuk mengambil tindakan';

  @override
  String get settingsAccessibilityShowPinchGestureAlternatives => 'Tampilkan alternatif gestur multisentuh';

  @override
  String get settingsDisplaySectionTitle => 'Tampilan';

  @override
  String get settingsThemeBrightnessTile => 'Tema';

  @override
  String get settingsThemeBrightnessDialogTitle => 'Tema';

  @override
  String get settingsThemeColorHighlights => 'Highlight warna';

  @override
  String get settingsThemeEnableDynamicColor => 'Warna dinamis';

  @override
  String get settingsDisplayRefreshRateModeTile => 'Tingkat penyegaran tampilan';

  @override
  String get settingsDisplayRefreshRateModeDialogTitle => 'Tingkat Penyegaran';

  @override
  String get settingsDisplayUseTvInterface => 'Antarmuka Android TV';

  @override
  String get settingsLanguageSectionTitle => 'Bahasa & Format';

  @override
  String get settingsLanguageTile => 'Bahasa';

  @override
  String get settingsLanguagePageTitle => 'Bahasa';

  @override
  String get settingsCoordinateFormatTile => 'Format koordinat';

  @override
  String get settingsCoordinateFormatDialogTitle => 'Format Koordinat';

  @override
  String get settingsUnitSystemTile => 'Unit';

  @override
  String get settingsUnitSystemDialogTitle => 'Unit';

  @override
  String get settingsForceWesternArabicNumeralsTile => 'Paksa angka Arab';

  @override
  String get settingsScreenSaverPageTitle => 'Screensaver';

  @override
  String get settingsWidgetPageTitle => 'Bingkai Foto';

  @override
  String get settingsWidgetShowOutline => 'Garis luar';

  @override
  String get settingsWidgetOpenPage => 'Saat mengetuk di sebuah widget';

  @override
  String get settingsWidgetDisplayedItem => 'Barang yang ditampilkan';

  @override
  String get settingsCollectionTile => 'Koleksi';

  @override
  String get statsPageTitle => 'Statistik';

  @override
  String statsWithGps(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString benda dengan lokasi',
    );
    return '$_temp0';
  }

  @override
  String get statsTopCountriesSectionTitle => 'Negara Teratas';

  @override
  String get statsTopStatesSectionTitle => 'Wilayah Teratas';

  @override
  String get statsTopPlacesSectionTitle => 'Tempat Teratas';

  @override
  String get statsTopTagsSectionTitle => 'Label Teratas';

  @override
  String get statsTopAlbumsSectionTitle => 'Album Teratas';

  @override
  String get viewerOpenPanoramaButtonLabel => 'BUKA PANORAMA';

  @override
  String get viewerSetWallpaperButtonLabel => 'TETAPKAN SEBAGAI WALLPAPER';

  @override
  String get viewerErrorUnknown => 'Ups!';

  @override
  String get viewerErrorDoesNotExist => 'File tidak ada lagi.';

  @override
  String get viewerInfoPageTitle => 'Info';

  @override
  String get viewerInfoBackToViewerTooltip => 'Kembali ke penampil';

  @override
  String get viewerInfoUnknown => 'tidak dikenal';

  @override
  String get viewerInfoLabelDescription => 'Deskripsi';

  @override
  String get viewerInfoLabelTitle => 'Judul';

  @override
  String get viewerInfoLabelDate => 'Tanggal';

  @override
  String get viewerInfoLabelResolution => 'Resolusi';

  @override
  String get viewerInfoLabelSize => 'Ukuran';

  @override
  String get viewerInfoLabelUri => 'URI';

  @override
  String get viewerInfoLabelPath => 'Jalan';

  @override
  String get viewerInfoLabelDuration => 'Durasi';

  @override
  String get viewerInfoLabelOwner => 'Dimiliki oleh';

  @override
  String get viewerInfoLabelCoordinates => 'Koordinat';

  @override
  String get viewerInfoLabelAddress => 'Alamat';

  @override
  String get mapStyleDialogTitle => 'Gaya Peta';

  @override
  String get mapStyleTooltip => 'Pilih gaya peta';

  @override
  String get mapZoomInTooltip => 'Perbesar';

  @override
  String get mapZoomOutTooltip => 'Perkecil';

  @override
  String get mapPointNorthUpTooltip => 'Arahkan ke utara ke atas';

  @override
  String get mapAttributionOsmData => 'Data peta © [OpenStreetMap](https://www.openstreetmap.org/copyright) kontributor';

  @override
  String get mapAttributionOsmLiberty => 'Ubin oleh [OpenMapTiles](https://www.openmaptiles.org/), [CC BY](http://creativecommons.org/licenses/by/4.0) • Disediakan oleh [OSM Americana](https://tile.ourmap.us)';

  @override
  String get mapAttributionOpenTopoMap => '[SRTM](https://www.earthdata.nasa.gov/sensors/srtm) | Ubin oleh [OpenTopoMap](https://opentopomap.org/), [CC BY-SA](https://creativecommons.org/licenses/by-sa/3.0/)';

  @override
  String get mapAttributionOsmHot => 'Tile oleh [HOT](https://www.hotosm.org/) • Diselenggarakan oleh [OSM France](https://openstreetmap.fr/)';

  @override
  String get mapAttributionStamen => 'Tile oleh [Stamen Design](https://stamen.com), [CC BY 3.0](https://creativecommons.org/licenses/by/3.0)';

  @override
  String get openMapPageTooltip => 'Lihat di halaman Peta';

  @override
  String get mapEmptyRegion => 'Tidak ada gambar di wilayah ini';

  @override
  String get viewerInfoOpenEmbeddedFailureFeedback => 'Gagal mengekstrak data yang disematkan';

  @override
  String get viewerInfoOpenLinkText => 'Buka';

  @override
  String get viewerInfoViewXmlLinkText => 'Tampilkan XML';

  @override
  String get viewerInfoSearchFieldLabel => 'Cari metadata';

  @override
  String get viewerInfoSearchEmpty => 'Tidak ada kata kunci yang cocok';

  @override
  String get viewerInfoSearchSuggestionDate => 'Tanggal & waktu';

  @override
  String get viewerInfoSearchSuggestionDescription => 'Deskripsi';

  @override
  String get viewerInfoSearchSuggestionDimensions => 'Dimensi';

  @override
  String get viewerInfoSearchSuggestionResolution => 'Resolusi';

  @override
  String get viewerInfoSearchSuggestionRights => 'Hak';

  @override
  String get wallpaperUseScrollEffect => 'Gunakan efek scroll di layar beranda';

  @override
  String get tagEditorPageTitle => 'Ubah Label';

  @override
  String get tagEditorPageNewTagFieldLabel => 'Label baru';

  @override
  String get tagEditorPageAddTagTooltip => 'Tambah label';

  @override
  String get tagEditorSectionRecent => 'Terkini';

  @override
  String get tagEditorSectionPlaceholders => 'Placeholder';

  @override
  String get tagEditorDiscardDialogMessage => 'Apakah Anda ingin membuang perubahan?';

  @override
  String get tagPlaceholderCountry => 'Negara';

  @override
  String get tagPlaceholderState => 'Wilayah';

  @override
  String get tagPlaceholderPlace => 'Tempat';

  @override
  String get panoramaEnableSensorControl => 'Aktifkan kontrol sensor';

  @override
  String get panoramaDisableSensorControl => 'Nonaktifkan kontrol sensor';

  @override
  String get sourceViewerPageTitle => 'Sumber';

  @override
  String get filePickerShowHiddenFiles => 'Tampilkan file tersembunyi';

  @override
  String get filePickerDoNotShowHiddenFiles => 'Jangan tampilkan file tersembunyi';

  @override
  String get filePickerOpenFrom => 'Buka dari';

  @override
  String get filePickerNoItems => 'Tidak ada benda';

  @override
  String get filePickerUseThisFolder => 'Gunakan folder ini';
}
