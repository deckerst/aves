// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Modern Greek (`el`).
class AppLocalizationsEl extends AppLocalizations {
  AppLocalizationsEl([String locale = 'el']) : super(locale);

  @override
  String get appName => 'Aves';

  @override
  String get welcomeMessage => 'Καλωσορίσατε στην εφαρμογή Aves';

  @override
  String get welcomeOptional => 'Προαιρετικό';

  @override
  String get welcomeTermsToggle => 'Συμφωνώ με τους όρους και τις προυποθέσεις';

  @override
  String itemCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString στοιχεία',
      one: '$countString στοιχείο',
    );
    return '$_temp0';
  }

  @override
  String columnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count στήλες',
      one: '$count στήλη',
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
      other: '$countString δευτερόλεπτα',
      one: '$countString δευτερόλεπτο',
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
      other: '$countString λεπτά',
      one: '$countString λεπτό',
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
      other: '$countString ημέρες',
      one: '$countString ημέρα',
    );
    return '$_temp0';
  }

  @override
  String focalLength(String length) {
    return '$length mm';
  }

  @override
  String get applyButtonLabel => 'ΕΦΑΡΜΟΓΗ';

  @override
  String get deleteButtonLabel => 'ΔΙΑΓΡΑΦΗ';

  @override
  String get nextButtonLabel => 'ΕΠΟΜΕΝΟ';

  @override
  String get showButtonLabel => 'ΕΜΦΑΝΙΣΗ';

  @override
  String get hideButtonLabel => 'ΑΠΟΚΡΥΨΗ';

  @override
  String get continueButtonLabel => 'ΣΥΝΕΧΕΙΑ';

  @override
  String get saveCopyButtonLabel => 'ΑΠΟΘΗΚΕΥΣΗ ΑΝΤΙΓΡΑΦΟΥ';

  @override
  String get applyTooltip => 'Εφαρμογή';

  @override
  String get cancelTooltip => 'Ακύρωση';

  @override
  String get changeTooltip => 'Αλλαγή';

  @override
  String get clearTooltip => 'Εκκαθάριση';

  @override
  String get previousTooltip => 'Προηγούμενο';

  @override
  String get nextTooltip => 'Επόμενο';

  @override
  String get showTooltip => 'Εμφάνιση';

  @override
  String get hideTooltip => 'Απόκρυψη';

  @override
  String get actionRemove => 'Αφαίρεση';

  @override
  String get resetTooltip => 'Επαναφορά';

  @override
  String get saveTooltip => 'Αποθήκευση';

  @override
  String get stopTooltip => 'Stop';

  @override
  String get pickTooltip => 'Διαλέξτε';

  @override
  String get doubleBackExitMessage => 'Αγγίξτε ξανά το «πίσω» για έξοδο.';

  @override
  String get doNotAskAgain => 'Να μην ερωτηθώ ξανά';

  @override
  String get sourceStateLoading => 'Φόρτωση';

  @override
  String get sourceStateCataloguing => 'Καταλογογράφηση';

  @override
  String get sourceStateLocatingCountries => 'Εντοπισμός χωρών';

  @override
  String get sourceStateLocatingPlaces => 'Εντοπισμός τοποθεσιών';

  @override
  String get chipActionDelete => 'Διαγραφή';

  @override
  String get chipActionRemove => 'Remove';

  @override
  String get chipActionShowCollection => 'Εμφάνιση στη Συλλογή';

  @override
  String get chipActionGoToAlbumPage => 'Εμφάνιση στα Άλμπουμ';

  @override
  String get chipActionGoToCountryPage => 'Εμφάνιση στις χώρες';

  @override
  String get chipActionGoToPlacePage => 'Εμφάνιση στα μέρη';

  @override
  String get chipActionGoToTagPage => 'Εμφάνιση στις ετικέτες';

  @override
  String get chipActionGoToExplorerPage => 'Show in Explorer';

  @override
  String get chipActionDecompose => 'Split';

  @override
  String get chipActionFilterOut => 'Χωρίς φιλτράρισμα';

  @override
  String get chipActionFilterIn => 'Με φιλτράρισμα';

  @override
  String get chipActionHide => 'Απόκρυψη';

  @override
  String get chipActionLock => 'Κλείδωμα';

  @override
  String get chipActionPin => 'Καρφίτσωμα στην κορυφή';

  @override
  String get chipActionUnpin => 'Ξέκαρφίτσωμα από την κορυφή';

  @override
  String get chipActionRename => 'Μετονομασία';

  @override
  String get chipActionSetCover => 'Ορισμός ως εξώφυλλο';

  @override
  String get chipActionShowCountryStates => 'Εμφάνιση πολιτειών';

  @override
  String get chipActionCreateAlbum => 'Δημιουργία άλμπουμ';

  @override
  String get chipActionCreateVault => 'Δημιουργήστε θησαυροφυλάκιο';

  @override
  String get chipActionConfigureVault => 'Διαμορφώστε το θησαυροφυλάκιο';

  @override
  String get entryActionCopyToClipboard => 'Αντιγραφή στο πρόχειρο';

  @override
  String get entryActionDelete => 'Διαγραφή';

  @override
  String get entryActionConvert => 'Μετατροπή';

  @override
  String get entryActionExport => 'Εξαγωγή';

  @override
  String get entryActionInfo => 'Λεπτομέρειες';

  @override
  String get entryActionRename => 'Μετονομασία';

  @override
  String get entryActionRestore => 'Επαναφορά';

  @override
  String get entryActionRotateCCW => 'Περιστροφή προς τα αριστερά';

  @override
  String get entryActionRotateCW => 'Περιστροφή προς τα δεξιά';

  @override
  String get entryActionFlip => 'Αντανάκλαση καθρέφτη';

  @override
  String get entryActionPrint => 'Εκτύπωση';

  @override
  String get entryActionShare => 'Κοινοποίηση';

  @override
  String get entryActionShareImageOnly => 'Κοινοποίηση μόνο την εικόνα';

  @override
  String get entryActionShareVideoOnly => 'Κοινοποίηση μόνο το βίντεο';

  @override
  String get entryActionViewSource => 'Προβολή πηγής';

  @override
  String get entryActionShowGeoTiffOnMap => 'Εμφάνιση ως επικάλυψη στον χάρτη';

  @override
  String get entryActionConvertMotionPhotoToStillImage => 'Μετατροπή σε στατική εικόνα';

  @override
  String get entryActionViewMotionPhotoVideo => 'Άνοιγμα του βίντεο';

  @override
  String get entryActionEdit => 'Επεξεργασία';

  @override
  String get entryActionOpen => 'Άνοιγμα με';

  @override
  String get entryActionSetAs => 'Ορισμός ως';

  @override
  String get entryActionCast => 'Cast';

  @override
  String get entryActionOpenMap => 'Εμφάνιση στην εφαρμογή χάρτες';

  @override
  String get entryActionRotateScreen => 'Περιστροφή οθόνης';

  @override
  String get entryActionAddFavourite => 'Προσθήκη στα αγαπημένα';

  @override
  String get entryActionRemoveFavourite => 'Αφαίρεση από τα αγαπημένα';

  @override
  String get videoActionCaptureFrame => 'Λήψη στιγμιότυπου';

  @override
  String get videoActionMute => 'Σίγαση';

  @override
  String get videoActionUnmute => 'Αναίρεση σίγασης';

  @override
  String get videoActionPause => 'Παύση';

  @override
  String get videoActionPlay => 'Αναπαραγωγή';

  @override
  String get videoActionReplay10 => '10 δευτερόλεπτα πίσω';

  @override
  String get videoActionSkip10 => '10 δευτερόλεπτα μπροστά';

  @override
  String get videoActionShowPreviousFrame => 'Show previous frame';

  @override
  String get videoActionShowNextFrame => 'Show next frame';

  @override
  String get videoActionSelectStreams => 'Επιλογή γλώσσας';

  @override
  String get videoActionSetSpeed => 'Ταχύτητα αναπαραγωγής';

  @override
  String get videoActionABRepeat => 'A-B repeat';

  @override
  String get videoRepeatActionSetStart => 'Set start';

  @override
  String get videoRepeatActionSetEnd => 'Set end';

  @override
  String get viewerActionSettings => 'Ρυθμίσεις';

  @override
  String get viewerActionLock => 'Κλείδωμα προβολής';

  @override
  String get viewerActionUnlock => 'Ξεκλείδωμα προβολής';

  @override
  String get slideshowActionResume => 'Συνέχιση';

  @override
  String get slideshowActionShowInCollection => 'Εμφάνιση στη Συλλογή';

  @override
  String get entryInfoActionEditDate => 'Επεξεργασία ημερομηνίας και ώρας';

  @override
  String get entryInfoActionEditLocation => 'Επεξεργασία τοποθεσίας';

  @override
  String get entryInfoActionEditTitleDescription => 'Επεξεργασία ονομασίας & περιγραφής';

  @override
  String get entryInfoActionEditRating => 'Επεξεργασία βαθμολογίας';

  @override
  String get entryInfoActionEditTags => 'Επεξεργασία ετικετών';

  @override
  String get entryInfoActionRemoveMetadata => 'Κατάργηση μεταδεδομένων';

  @override
  String get entryInfoActionExportMetadata => 'Εξαγωγή μεταδεδομένων';

  @override
  String get entryInfoActionRemoveLocation => 'Αφαίρεση τοποθεσίας';

  @override
  String get editorActionTransform => 'Μετατροπή';

  @override
  String get editorTransformCrop => 'Περικοπή';

  @override
  String get editorTransformRotate => 'Περιστροφή';

  @override
  String get cropAspectRatioFree => 'Ελεύθερη μορφή';

  @override
  String get cropAspectRatioOriginal => 'Αρχικό';

  @override
  String get cropAspectRatioSquare => 'Τετράγωνο';

  @override
  String get filterAspectRatioLandscapeLabel => 'Oριζόντιες εικόνες';

  @override
  String get filterAspectRatioPortraitLabel => 'Κατακόρυφες εικόνες';

  @override
  String get filterBinLabel => 'Κάδος ανακύκλωσης';

  @override
  String get filterFavouriteLabel => 'Αγαπημένα';

  @override
  String get filterNoDateLabel => 'Χωρίς ημερομηνία';

  @override
  String get filterNoAddressLabel => 'Χωρίς διεύθυνση';

  @override
  String get filterLocatedLabel => 'Με τοποθεσία';

  @override
  String get filterNoLocationLabel => 'Χωρίς τοποθεσία';

  @override
  String get filterNoRatingLabel => 'Χωρίς βαθμολογία';

  @override
  String get filterTaggedLabel => 'Με ετικέτα';

  @override
  String get filterNoTagLabel => 'Χωρίς ετικέτα';

  @override
  String get filterNoTitleLabel => 'Χωρίς ονομασία';

  @override
  String get filterOnThisDayLabel => 'Αυτή τη μέρα';

  @override
  String get filterRecentlyAddedLabel => 'Προστέθηκαν πρόσφατα';

  @override
  String get filterRatingRejectedLabel => 'Απορριφθέντα';

  @override
  String get filterTypeAnimatedLabel => 'Κινούμενα';

  @override
  String get filterTypeMotionPhotoLabel => 'Φωτογραφίες με κίνηση';

  @override
  String get filterTypePanoramaLabel => 'Πανοραμικές';

  @override
  String get filterTypeRawLabel => 'Raw';

  @override
  String get filterTypeSphericalVideoLabel => 'Βίντεο 360°';

  @override
  String get filterTypeGeotiffLabel => 'GeoTIFF';

  @override
  String get filterMimeImageLabel => 'Εικόνα';

  @override
  String get filterMimeVideoLabel => 'Βίντεο';

  @override
  String get accessibilityAnimationsRemove => 'Απενεργοποίηση εφέ οθόνης';

  @override
  String get accessibilityAnimationsKeep => 'Διατήρηση εφέ οθόνης';

  @override
  String get albumTierNew => 'Νέα';

  @override
  String get albumTierPinned => 'Καρφιτσωμένα';

  @override
  String get albumTierSpecial => 'Συστήματος';

  @override
  String get albumTierApps => 'Εφαρμογές';

  @override
  String get albumTierVaults => 'Θησαυροφυλακια';

  @override
  String get albumTierDynamic => 'Dynamic';

  @override
  String get albumTierRegular => 'Προσωπικά';

  @override
  String get coordinateFormatDms => 'DMS';

  @override
  String get coordinateFormatDdm => 'DDM';

  @override
  String get coordinateFormatDecimal => 'Δεκαδικές μοίρες';

  @override
  String coordinateDms(String coordinate, String direction) {
    return '$coordinate $direction';
  }

  @override
  String get coordinateDmsNorth => 'Β';

  @override
  String get coordinateDmsSouth => 'Ν';

  @override
  String get coordinateDmsEast => 'Α';

  @override
  String get coordinateDmsWest => 'Δ';

  @override
  String get displayRefreshRatePreferHighest => 'Υψηλότερος ρυθμός';

  @override
  String get displayRefreshRatePreferLowest => 'Χαμηλότερος ρυθμός';

  @override
  String get keepScreenOnNever => 'Ποτέ';

  @override
  String get keepScreenOnVideoPlayback => 'Κατά την αναπαραγωγή βίντεο';

  @override
  String get keepScreenOnViewerOnly => 'Μόνο όταν πραγματοποιείται προβολή στοιχείων';

  @override
  String get keepScreenOnAlways => 'Πάντα';

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
  String get maxBrightnessNever => 'Ποτέ';

  @override
  String get maxBrightnessAlways => 'Πάντα';

  @override
  String get nameConflictStrategyRename => 'Μετονομασία';

  @override
  String get nameConflictStrategyReplace => 'Αντικατάσταση';

  @override
  String get nameConflictStrategySkip => 'Παράλειψη';

  @override
  String get overlayHistogramNone => 'Τίποτα';

  @override
  String get overlayHistogramRGB => 'RGB';

  @override
  String get overlayHistogramLuminance => 'Φωτεινότητα';

  @override
  String get subtitlePositionTop => 'Πάνω';

  @override
  String get subtitlePositionBottom => 'Κάτω';

  @override
  String get themeBrightnessLight => 'Φωτεινό';

  @override
  String get themeBrightnessDark => 'Σκούρο';

  @override
  String get themeBrightnessBlack => 'Μαύρο';

  @override
  String get unitSystemMetric => 'Μετρικό';

  @override
  String get unitSystemImperial => 'Aγγλοσαξονικό';

  @override
  String get vaultLockTypePattern => 'Μοτίβο';

  @override
  String get vaultLockTypePin => 'PIN';

  @override
  String get vaultLockTypePassword => 'Κωδικός πρόσβασης';

  @override
  String get settingsVideoEnablePip => 'Picture-in-picture';

  @override
  String get videoControlsPlayOutside => 'Άνοιγμα με άλλη εφαρμογή';

  @override
  String get videoLoopModeNever => 'Ποτέ';

  @override
  String get videoLoopModeShortOnly => 'Μόνο για βίντεο σύντομης διάρκειας';

  @override
  String get videoLoopModeAlways => 'Πάντα';

  @override
  String get videoPlaybackSkip => 'Παράλειψη';

  @override
  String get videoPlaybackMuted => 'Αναπαραγωγή σε σίγαση';

  @override
  String get videoPlaybackWithSound => 'Αναπαραγωγή με ήχο';

  @override
  String get videoResumptionModeNever => 'Ποτέ';

  @override
  String get videoResumptionModeAlways => 'Πάντα';

  @override
  String get viewerTransitionSlide => 'Ολίσθηση';

  @override
  String get viewerTransitionParallax => 'Παράλλαξη';

  @override
  String get viewerTransitionFade => 'Ξεθώριασμα';

  @override
  String get viewerTransitionZoomIn => 'Μεγέθυνση';

  @override
  String get viewerTransitionNone => 'Καμία';

  @override
  String get wallpaperTargetHome => 'Αρχική οθόνη';

  @override
  String get wallpaperTargetLock => 'Οθόνη κλειδώματος';

  @override
  String get wallpaperTargetHomeLock => 'Αρχική οθόνη και οθόνη κλειδώματος';

  @override
  String get widgetDisplayedItemRandom => 'Τυχαίο';

  @override
  String get widgetDisplayedItemMostRecent => 'Πιο πρόσφατο';

  @override
  String get widgetOpenPageHome => 'Άνοιγμα αρχικής σελίδας';

  @override
  String get widgetOpenPageCollection => 'Ανοιχτή συλλογή';

  @override
  String get widgetOpenPageViewer => 'Άνοιγμα προβολέα αρχείων';

  @override
  String get widgetTapUpdateWidget => 'Ενημέρωση γραφικού στοιχείου';

  @override
  String get storageVolumeDescriptionFallbackPrimary => 'Εσωτερικός χώρος αποθήκευσης';

  @override
  String get storageVolumeDescriptionFallbackNonPrimary => 'SD card/Εξωτερικός χώρος αποθήκευσης';

  @override
  String get rootDirectoryDescription => 'Κατάλογος ρίζας';

  @override
  String otherDirectoryDescription(String name) {
    return '«$name» κατάλογος';
  }

  @override
  String storageAccessDialogMessage(String directory, String volume) {
    return 'Παρακαλώ επιλέξτε τον $directory του «$volume» στην επόμενη οθόνη για να δώσετε πρόσβαση στην εφαρμογή.';
  }

  @override
  String restrictedAccessDialogMessage(String directory, String volume) {
    return 'Αυτή η εφαρμογή δεν επιτρέπεται να τροποποιεί αρχεία στο $directory του «$volume».\n\nΠαρακαλώ χρησιμοποιήστε μια άλλη εφαρμογή διαχείρισης αρχείων ή συλλογή φωτογραφιών για να μετακινήσετε τα στοιχεία αλλού.';
  }

  @override
  String notEnoughSpaceDialogMessage(String neededSize, String freeSize, String volume) {
    return 'Αυτή η λειτουργία χρειάζεται $neededSize ελεύθερου χώρου στο «$volume» για να ολοκληρωθεί, αλλά μόνο $freeSize απομένουν ελεύθερα.';
  }

  @override
  String get missingSystemFilePickerDialogMessage => 'Η εφαρμογή επιλογής αρχείων του δεν βρέθηκε ή είναι απενεργοποιημένη. Ενεργοποιήστε την και δοκιμάστε ξανά.';

  @override
  String unsupportedTypeDialogMessage(int count, String types) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Αυτή η λειτουργία δεν υποστηρίζεται για τα ακόλουθα αρχεία: $types.',
      one: 'Αυτή η λειτουργία δεν υποστηρίζεται για το ακόλουθο αρχείο: $types.',
    );
    return '$_temp0';
  }

  @override
  String get nameConflictDialogSingleSourceMessage => 'Ορισμένα αρχεία στον φάκελο προορισμού έχουν το ίδιο όνομα.';

  @override
  String get nameConflictDialogMultipleSourceMessage => 'Ορισμένα αρχεία έχουν το ίδιο όνομα.';

  @override
  String get addShortcutDialogLabel => 'Ετικέτα συντόμευσης';

  @override
  String get addShortcutButtonLabel => 'ΠΡΟΣΘΗΚΗ';

  @override
  String get noMatchingAppDialogMessage => 'Δεν βρέθηκαν εγκατεστημένες εφαρμογές που μπορούν να το κάνουν αυτό.';

  @override
  String binEntriesConfirmationDialogMessage(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Μετακίνηση αυτών των $countString στοιχείων στον κάδο ανακύκλωσης;',
      one: 'Μετακίνηση αυτού του στοιχείου στον κάδο ανακύκλωσης;',
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
      other: 'Διαγραφή αυτών των $countString στοιχείων;',
      one: 'Διαγραφή αυτού του στοιχείου;',
    );
    return '$_temp0';
  }

  @override
  String get moveUndatedConfirmationDialogMessage => 'Αποθήκευση ημερομηνιών στοιχείων πριν συνεχίσετε;';

  @override
  String get moveUndatedConfirmationDialogSetDate => 'Αποθήκευση ημερομηνιών';

  @override
  String videoResumeDialogMessage(String time) {
    return 'Συνέχεια αναπαραγωγής από $time?';
  }

  @override
  String get videoStartOverButtonLabel => 'ΑΝΑΠΑΡΑΓΩΓΗ ΑΠΟ ΤΗΝ ΑΡΧΗ';

  @override
  String get videoResumeButtonLabel => 'ΣΥΝΕΧΙΣΗ ΑΝΑΠΑΡΑΓΩΓΗΣ';

  @override
  String get setCoverDialogLatest => 'Πιο πρόσφατο στοιχείο';

  @override
  String get setCoverDialogAuto => 'Αυτόματο';

  @override
  String get setCoverDialogCustom => 'Προσαρμοσμένο';

  @override
  String get hideFilterConfirmationDialogMessage => 'Οι φωτογραφίες και τα βίντεο που ταιριάζουν θα κρυφτούν από τη συλλογή σας. Μπορείτε να τα εμφανίσετε ξανά από τις ρυθμίσεις «Απόρρητο».\n\nΕίστε σίγουροι ότι θέλετε να τα κρύψετε;';

  @override
  String get newAlbumDialogTitle => 'Νεο αλμπουμ';

  @override
  String get newAlbumDialogNameLabel => 'Όνομα άλμπουμ';

  @override
  String get newAlbumDialogAlbumAlreadyExistsHelper => 'Album already exists';

  @override
  String get newAlbumDialogNameLabelAlreadyExistsHelper => 'Η ονομασία υπάρχει ήδη';

  @override
  String get newAlbumDialogStorageLabel => 'Aποθηκευτικός χώρος:';

  @override
  String get newDynamicAlbumDialogTitle => 'New Dynamic Album';

  @override
  String get dynamicAlbumAlreadyExists => 'Dynamic album already exists';

  @override
  String get newVaultWarningDialogMessage => 'Τα αρχεία στα θησαυροφυλάκια είναι διαθέσιμα μόνο σε αυτή την εφαρμογή και σε καμία άλλη.\n\nΑν απεγκαταστήσετε την εφαρμογή ή έστω διαγράψετε τα δεδομένα της εφαρμογής, θα χάσετε όλα σας τα κρυφά αρχεία.';

  @override
  String get newVaultDialogTitle => 'Νεο Θησαυροφυλακιο';

  @override
  String get configureVaultDialogTitle => 'Διαμορφωστε το θησαυροφυλακιο';

  @override
  String get vaultDialogLockModeWhenScreenOff => 'Κλείδωμα όταν σβήνει η οθόνη';

  @override
  String get vaultDialogLockTypeLabel => 'Τύπος κλειδώματος';

  @override
  String get patternDialogEnter => 'Εισάγετε το μοτίβο';

  @override
  String get patternDialogConfirm => 'Επιβεβαιώστε το μοτίβο';

  @override
  String get pinDialogEnter => 'Εισάγετε το PIN';

  @override
  String get pinDialogConfirm => 'Επιβεβαιώστε το PIN';

  @override
  String get passwordDialogEnter => 'Εισάγετε τον κωδικό πρόσβασης';

  @override
  String get passwordDialogConfirm => 'Επιβεβαιώστε τον κωδικό πρόσβασης';

  @override
  String get authenticateToConfigureVault => 'Πιστοποίηση ταυτότητας για τη διαμόρφωση του θησαυροφυλακίου';

  @override
  String get authenticateToUnlockVault => 'Πιστοποίηση ταυτότητας για να ξεκλειδώσετε το θησαυροφυλάκιο';

  @override
  String get vaultBinUsageDialogMessage => 'Ορισμένα θησαυροφυλάκια χρησιμοποιούν τον κάδο ανακύκλωσης.';

  @override
  String get renameAlbumDialogLabel => 'Νέο όνομα';

  @override
  String get renameAlbumDialogLabelAlreadyExistsHelper => 'Ο κατάλογος υπάρχει ήδη';

  @override
  String get renameEntrySetPageTitle => 'Μετονομασια';

  @override
  String get renameEntrySetPagePatternFieldLabel => 'Μοτίβο ονομασίας';

  @override
  String get renameEntrySetPageInsertTooltip => 'Εισαγωγή πεδίου';

  @override
  String get renameEntrySetPagePreviewSectionTitle => 'Προεπισκοπηση';

  @override
  String get renameProcessorCounter => 'Μετρητής';

  @override
  String get renameProcessorHash => 'Hash';

  @override
  String get renameProcessorName => 'Όνομα';

  @override
  String deleteSingleAlbumConfirmationDialogMessage(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Διαγράψτε αυτό το άλμπουμ και όλα τα $countString στοιχεία του;',
      one: 'Διαγραφή αυτού του άλμπουμ και του περιεχομένου του;',
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
      other: 'Διαγράψτε αυτά τα άλμπουμ και όλα τα $countString στοιχεία τους;',
      one: 'Διαγράψτε αυτά τα άλμπουμ και το περιεχόμενό τους;',
    );
    return '$_temp0';
  }

  @override
  String get exportEntryDialogFormat => 'Μορφή:';

  @override
  String get exportEntryDialogWidth => 'Πλάτος';

  @override
  String get exportEntryDialogHeight => 'Ύψος';

  @override
  String get exportEntryDialogQuality => 'Ποιότητα';

  @override
  String get exportEntryDialogWriteMetadata => 'Εγγραφή μεταδεδομένων';

  @override
  String get renameEntryDialogLabel => 'Νέο όνομα';

  @override
  String get editEntryDialogCopyFromItem => 'Αντιγραφή από άλλο στοιχείο';

  @override
  String get editEntryDialogTargetFieldsHeader => 'Πεδία προς τροποποίηση';

  @override
  String get editEntryDateDialogTitle => 'Ημερομηνια & Ώρα';

  @override
  String get editEntryDateDialogSetCustom => 'Ορισμός προσαρμοσμένης ημερομηνίας';

  @override
  String get editEntryDateDialogCopyField => 'Αντιγραφή από άλλη ημερομηνία';

  @override
  String get editEntryDateDialogExtractFromTitle => 'Εξαγωγή από το όνομα του κάθε αρχείου';

  @override
  String get editEntryDateDialogShift => 'Μετατόπιση';

  @override
  String get editEntryDateDialogSourceFileModifiedDate => 'Ημερομηνία τροποποίησης αρχείου';

  @override
  String get durationDialogHours => 'Ώρες';

  @override
  String get durationDialogMinutes => 'Λεπτά';

  @override
  String get durationDialogSeconds => 'Δευτερόλεπτα';

  @override
  String get editEntryLocationDialogTitle => 'Τοποθεσια';

  @override
  String get editEntryLocationDialogSetCustom => 'Ορισμός προσαρμοσμένης τοποθεσίας';

  @override
  String get editEntryLocationDialogChooseOnMap => 'Επιλογή στο χάρτη';

  @override
  String get editEntryLocationDialogImportGpx => 'Import GPX';

  @override
  String get editEntryLocationDialogLatitude => 'Γεωγραφικό πλάτος';

  @override
  String get editEntryLocationDialogLongitude => 'Γεωγραφικό μήκος';

  @override
  String get editEntryLocationDialogTimeShift => 'Time shift';

  @override
  String get locationPickerUseThisLocationButton => 'Χρησιμοποίηση της τοποθεσίας';

  @override
  String get editEntryRatingDialogTitle => 'Βαθμολογια';

  @override
  String get removeEntryMetadataDialogTitle => 'Αφαιρεση μεταδεδομενων';

  @override
  String get removeEntryMetadataDialogAll => 'All';

  @override
  String get removeEntryMetadataDialogMore => 'Περισσότερα';

  @override
  String get removeEntryMetadataMotionPhotoXmpWarningDialogMessage => 'Απαιτείται XMP για την αναπαραγωγή του βίντεο μέσα σε μια κινούμενη φωτογραφία.\n\nΕίστε βέβαιοι ότι θέλετε να αφαιρεθεί;';

  @override
  String get videoSpeedDialogLabel => 'Ταχύτητα αναπαραγωγής';

  @override
  String get videoStreamSelectionDialogVideo => 'Βίντεο';

  @override
  String get videoStreamSelectionDialogAudio => 'Ήχος';

  @override
  String get videoStreamSelectionDialogText => 'Υπότιτλοι';

  @override
  String get videoStreamSelectionDialogOff => 'Απενεργοποίηση';

  @override
  String get videoStreamSelectionDialogTrack => 'Κομμάτι';

  @override
  String get videoStreamSelectionDialogNoSelection => 'Δεν υπάρχουν άλλα κομμάτια.';

  @override
  String get genericSuccessFeedback => 'Ολοκληρώθηκε!';

  @override
  String get genericFailureFeedback => 'Απέτυχε';

  @override
  String get genericDangerWarningDialogMessage => 'Είστε βέβαιοι;';

  @override
  String get tooManyItemsErrorDialogMessage => 'Δοκιμάστε ξανά με λιγότερα αρχεία.';

  @override
  String get menuActionConfigureView => 'Προβολή';

  @override
  String get menuActionSelect => 'Επιλογή';

  @override
  String get menuActionSelectAll => 'Επιλογή όλων';

  @override
  String get menuActionSelectNone => 'Να μην επιλεγεί κανένα';

  @override
  String get menuActionMap => 'Χάρτης';

  @override
  String get menuActionSlideshow => 'Παρουσίαση φωτογραφιών';

  @override
  String get menuActionStats => 'Στατιστικά';

  @override
  String get viewDialogSortSectionTitle => 'Ταξινομηση';

  @override
  String get viewDialogGroupSectionTitle => 'Ομαδοποιηση';

  @override
  String get viewDialogLayoutSectionTitle => 'Διαταξη';

  @override
  String get viewDialogReverseSortOrder => 'Αντίστροφη σειρά ταξινόμησης';

  @override
  String get tileLayoutMosaic => 'Ψηφιδωτό';

  @override
  String get tileLayoutGrid => 'Πλέγμα';

  @override
  String get tileLayoutList => 'Λίστα';

  @override
  String get castDialogTitle => 'Cast Devices';

  @override
  String get coverDialogTabCover => 'Εξώφυλλο';

  @override
  String get coverDialogTabApp => 'Εφαρμογή';

  @override
  String get coverDialogTabColor => 'Χρώμα';

  @override
  String get appPickDialogTitle => 'Επιλογη εφαρμογης';

  @override
  String get appPickDialogNone => 'Καμία επιλογή';

  @override
  String get aboutPageTitle => 'Διαφορα';

  @override
  String get aboutLinkLicense => 'Άδειες';

  @override
  String get aboutLinkPolicy => 'Πολιτική Απορρήτου';

  @override
  String get aboutBugSectionTitle => 'Αναφορα σφαλματος';

  @override
  String get aboutBugSaveLogInstruction => 'Αποθήκευση των αρχείων καταγραφής της εφαρμογής σε ένα ξεχωριστό αρχείο';

  @override
  String get aboutBugCopyInfoInstruction => 'Αντιγραφή πληροφοριών του συστήματος';

  @override
  String get aboutBugCopyInfoButton => 'Αντιγραφή';

  @override
  String get aboutBugReportInstruction => 'Αναφορά στο GitHub με τα αρχεία καταγραφής και τις πληροφορίες του συστήματος';

  @override
  String get aboutBugReportButton => 'Αναφορά';

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
  String get aboutCreditsSectionTitle => 'Αναφορες';

  @override
  String get aboutCreditsWorldAtlas1 => 'Αυτή η εφαρμογή χρησιμοποιεί ένα αρχείο TopoJSON από';

  @override
  String get aboutCreditsWorldAtlas2 => 'υπό την άδεια ISC.';

  @override
  String get aboutTranslatorsSectionTitle => 'Μεταφραστες';

  @override
  String get aboutLicensesSectionTitle => 'Αδειες ανοιχτου κωδικα';

  @override
  String get aboutLicensesBanner => 'Αυτή η εφαρμογή χρησιμοποιεί τα ακόλουθα πακέτα και βιβλιοθήκες ανοιχτού κώδικα.';

  @override
  String get aboutLicensesAndroidLibrariesSectionTitle => 'Βιβλιοθηκες Android';

  @override
  String get aboutLicensesFlutterPluginsSectionTitle => 'Προσθετα Flutter';

  @override
  String get aboutLicensesFlutterPackagesSectionTitle => 'Πακετα Flutter';

  @override
  String get aboutLicensesDartPackagesSectionTitle => 'Πακετα Dart';

  @override
  String get aboutLicensesShowAllButtonLabel => 'Εμφάνιση όλων των αδειών';

  @override
  String get policyPageTitle => 'Πολιτικη απορρητου';

  @override
  String get collectionPageTitle => 'Συλλογη';

  @override
  String get collectionPickPageTitle => 'Διαλεξτε';

  @override
  String get collectionSelectPageTitle => 'Επιλογη στοιχειων';

  @override
  String get collectionActionShowTitleSearch => 'Εμφάνιση φίλτρου τίτλου';

  @override
  String get collectionActionHideTitleSearch => 'Απόκρυψη φίλτρου τίτλου';

  @override
  String get collectionActionAddDynamicAlbum => 'Add dynamic album';

  @override
  String get collectionActionAddShortcut => 'Προσθήκη συντόμευσης';

  @override
  String get collectionActionSetHome => 'Set as home';

  @override
  String get collectionActionEmptyBin => 'Καθαρισμός του κάδου ανακύκλωσης';

  @override
  String get collectionActionCopy => 'Αντιγραφή στο άλμπουμ';

  @override
  String get collectionActionMove => 'Μετακίνηση στο άλμπουμ';

  @override
  String get collectionActionRescan => 'Εκ νέου σάρωση';

  @override
  String get collectionActionEdit => 'Επεξεργασία';

  @override
  String get collectionSearchTitlesHintText => 'Αναζήτηση τίτλων';

  @override
  String get collectionGroupAlbum => 'Ανά άλμπουμ';

  @override
  String get collectionGroupMonth => 'Ανά μήνα';

  @override
  String get collectionGroupDay => 'Ανά ημέρα';

  @override
  String get collectionGroupNone => 'Να μην γίνει ομαδοποίηση';

  @override
  String get sectionUnknown => 'Χωρίς λεπτομέρειες';

  @override
  String get dateToday => 'Σήμερα';

  @override
  String get dateYesterday => 'Εχθές';

  @override
  String get dateThisMonth => 'Αυτό το μήνα';

  @override
  String collectionDeleteFailureFeedback(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Αποτυχία διαγραφής των $countString στοιχείων',
      one: 'Αποτυχία διαγραφής του στοιχείου',
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
      other: 'Αποτυχία αντιγραφής των $countString στοιχείων',
      one: 'Αποτυχία αντιγραφής του στοιχείου',
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
      other: 'Αποτυχία μετακίνησης των $countString στοιχείων',
      one: 'Αποτυχία μετακίνησης του στοιχείου',
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
      other: 'Αποτυχία μετονομασίας των $countString στοιχείων',
      one: 'Αποτυχία μετονομασίας του στοιχείου',
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
      other: 'Απέτυχε η επεξεργασία των $countString στοιχείων',
      one: 'Απέτυχε η επεξεργασία του στοιχείου',
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
      other: 'Απέτυχε η εξαγωγή των $countString σελίδων',
      one: 'Απέτυχε η εξαγωγή της σελίδας',
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
      other: 'Αντιγράφηκαν τα $countString στοιχεία',
      one: 'Αντιγράφηκε το στοιχείο',
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
      other: 'Μετακινήθηκαν τα $countString στοιχεία',
      one: 'Μετακινήθηκε το στοιχείο',
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
      other: 'Μετονομάστηκαν τα $countString στοιχεία',
      one: 'Μετονομάστηκε το στοιχείο',
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
      other: 'Επεξεργάστηκαν τα $countString στοιχεία',
      one: 'Επεξεργάστηκε το στοιχείο',
    );
    return '$_temp0';
  }

  @override
  String get collectionEmptyFavourites => 'Δεν έχουν καταχωρηθεί αγαπημένα στοιχεία';

  @override
  String get collectionEmptyVideos => 'Δεν υπάρχουν βίντεο';

  @override
  String get collectionEmptyImages => 'Δεν υπάρχουν εικόνες';

  @override
  String get collectionEmptyGrantAccessButtonLabel => 'Παραχώρηση πρόσβασης';

  @override
  String get collectionSelectSectionTooltip => 'Επιλέξτε ενότητα';

  @override
  String get collectionDeselectSectionTooltip => 'Αφαιρέστε ενότητα';

  @override
  String get drawerAboutButton => 'Διάφορα';

  @override
  String get drawerSettingsButton => 'Ρυθμίσεις';

  @override
  String get drawerCollectionAll => 'Όλη η συλλογή';

  @override
  String get drawerCollectionFavourites => 'Αγαπημένα';

  @override
  String get drawerCollectionImages => 'Εικόνες';

  @override
  String get drawerCollectionVideos => 'Βίντεο';

  @override
  String get drawerCollectionAnimated => 'Κινούμενα';

  @override
  String get drawerCollectionMotionPhotos => 'Φωτογραφίες με κίνηση';

  @override
  String get drawerCollectionPanoramas => 'Πανοραμικές';

  @override
  String get drawerCollectionRaws => 'Raw φωτογραφίες';

  @override
  String get drawerCollectionSphericalVideos => 'Βίντεο 360°';

  @override
  String get drawerAlbumPage => 'Άλμπουμ';

  @override
  String get drawerCountryPage => 'Χώρες';

  @override
  String get drawerPlacePage => 'Μέρη';

  @override
  String get drawerTagPage => 'Ετικέτες';

  @override
  String get sortByDate => 'Ανά ημερομηνία';

  @override
  String get sortByName => 'Ανά όνομα';

  @override
  String get sortByItemCount => 'Ανά μέτρηση στοιχείων';

  @override
  String get sortBySize => 'Ανά μέγεθος';

  @override
  String get sortByAlbumFileName => 'Ανά άλμπουμ και όνομα αρχείου';

  @override
  String get sortByRating => 'Ανά βαθμολογία';

  @override
  String get sortByDuration => 'By duration';

  @override
  String get sortOrderNewestFirst => 'Τα πιο πρόσφατα πρώτα';

  @override
  String get sortOrderOldestFirst => 'Τα παλαιότερα πρώτα';

  @override
  String get sortOrderAtoZ => 'Α έως Ω';

  @override
  String get sortOrderZtoA => 'Ω έως Α';

  @override
  String get sortOrderHighestFirst => 'Υψηλότερη βαθμολογία πρώτα';

  @override
  String get sortOrderLowestFirst => 'Χαμηλότερη βαθμολογία πρώτα';

  @override
  String get sortOrderLargestFirst => 'Τα μεγαλύτερα πρώτα';

  @override
  String get sortOrderSmallestFirst => 'Τα μικρότερα πρώτα';

  @override
  String get sortOrderShortestFirst => 'Shortest first';

  @override
  String get sortOrderLongestFirst => 'Longest first';

  @override
  String get albumGroupTier => 'Ανά βαθμίδα';

  @override
  String get albumGroupType => 'Ανά τύπο';

  @override
  String get albumGroupVolume => 'Ανά αποθηκευτική μονάδα';

  @override
  String get albumGroupNone => 'Να μην γίνει ομαδοποίηση';

  @override
  String get albumMimeTypeMixed => 'Μικτα';

  @override
  String get albumPickPageTitleCopy => 'Αντιγραφή στο άλμπουμ';

  @override
  String get albumPickPageTitleExport => 'Εξαγωγή στο άλμπουμ';

  @override
  String get albumPickPageTitleMove => 'Μετακίνηση στο άλμπουμ';

  @override
  String get albumPickPageTitlePick => 'Επιλογή άλμπουμ';

  @override
  String get albumCamera => 'Κάμερα';

  @override
  String get albumDownload => 'Λήψεις';

  @override
  String get albumScreenshots => 'Στιγμιότυπα οθόνης';

  @override
  String get albumScreenRecordings => 'Εγγραφές οθόνης';

  @override
  String get albumVideoCaptures => 'Στιγμιότυπα οθόνης από βίντεο';

  @override
  String get albumPageTitle => 'Άλμπουμ';

  @override
  String get albumEmpty => 'Δεν υπάρχουν άλμπουμ';

  @override
  String get createAlbumButtonLabel => 'ΔΗΜΙΟΥΡΓΙΑ';

  @override
  String get newFilterBanner => 'Νέα';

  @override
  String get countryPageTitle => 'Χωρες';

  @override
  String get countryEmpty => 'Δεν έχουν καταχωρηθεί χώρες';

  @override
  String get statePageTitle => 'Πολιτειες';

  @override
  String get stateEmpty => 'Χωρίς πολιτεία';

  @override
  String get placePageTitle => 'Μερη';

  @override
  String get placeEmpty => 'Χωρίς μέρος';

  @override
  String get tagPageTitle => 'Ετικετες';

  @override
  String get tagEmpty => 'Δεν έχουν καταχωρηθεί ετικέτες';

  @override
  String get binPageTitle => 'Καδος ανακυκλωσης';

  @override
  String get explorerPageTitle => 'Explorer';

  @override
  String get explorerActionSelectStorageVolume => 'Select storage';

  @override
  String get selectStorageVolumeDialogTitle => 'Select Storage';

  @override
  String get searchCollectionFieldHint => 'Αναζήτηση στην συλλογή';

  @override
  String get searchRecentSectionTitle => 'Προσφατα';

  @override
  String get searchDateSectionTitle => 'Ημερομηνια';

  @override
  String get searchFormatSectionTitle => 'Formats';

  @override
  String get searchAlbumsSectionTitle => 'Άλμπουμ';

  @override
  String get searchCountriesSectionTitle => 'Χωρες';

  @override
  String get searchStatesSectionTitle => 'Πολιτειες';

  @override
  String get searchPlacesSectionTitle => 'Μερη';

  @override
  String get searchTagsSectionTitle => 'Ετικετες';

  @override
  String get searchRatingSectionTitle => 'Βαθμολογιες';

  @override
  String get searchMetadataSectionTitle => 'Μεταδεδομενα';

  @override
  String get settingsPageTitle => 'Ρυθμισεις';

  @override
  String get settingsSystemDefault => 'Σύστημα';

  @override
  String get settingsDefault => 'Προεπιλογή';

  @override
  String get settingsDisabled => 'Απενεργοποιημένο';

  @override
  String get settingsAskEverytime => 'Ρωτήστε με κάθε φορά';

  @override
  String get settingsModificationWarningDialogMessage => 'Άλλες ρυθμίσεις θα τροποποιηθούν.';

  @override
  String get settingsSearchFieldLabel => 'Αναζήτηση ρυθμίσεων';

  @override
  String get settingsSearchEmpty => 'Δεν υπάρχει αντίστοιχη ρύθμιση';

  @override
  String get settingsActionExport => 'Εξαγωγή';

  @override
  String get settingsActionExportDialogTitle => 'Εξαγωγη';

  @override
  String get settingsActionImport => 'Εισαγωγή';

  @override
  String get settingsActionImportDialogTitle => 'Εισαγωγη';

  @override
  String get appExportCovers => 'Εξώφυλλα';

  @override
  String get appExportDynamicAlbums => 'Dynamic albums';

  @override
  String get appExportFavourites => 'Αγαπημένα';

  @override
  String get appExportSettings => 'Ρυθμίσεις';

  @override
  String get settingsNavigationSectionTitle => 'Πλοηγηση';

  @override
  String get settingsHomeTile => 'Αρχική σελίδα της εφαρμογής';

  @override
  String get settingsHomeDialogTitle => 'Αρχικη σελιδα της εφαρμογης';

  @override
  String get setHomeCustom => 'Custom';

  @override
  String get settingsShowBottomNavigationBar => 'Εμφάνιση κάτω γραμμής πλοήγησης';

  @override
  String get settingsKeepScreenOnTile => 'Διατήρηση της οθόνης ενεργοποιημένη';

  @override
  String get settingsKeepScreenOnDialogTitle => 'Διατηρηση της Οθονης Ενεργοποιημενη';

  @override
  String get settingsDoubleBackExit => 'Αγγίξτε το «πίσω» δύο φορές για έξοδο';

  @override
  String get settingsConfirmationTile => 'Παράθυρα επιβεβαίωσης';

  @override
  String get settingsConfirmationDialogTitle => 'Παραθυρα Επιβεβαιωσης';

  @override
  String get settingsConfirmationBeforeDeleteItems => 'Ερώτηση πριν διαγραφούν στοιχεία οριστικά';

  @override
  String get settingsConfirmationBeforeMoveToBinItems => 'Ερώτηση πριν μεταφερθούν στοιχεία στον κάδο ανακύκλωσης';

  @override
  String get settingsConfirmationBeforeMoveUndatedItems => 'Ερώτηση πριν μεταφερθούν στοιχεία χωρίς ημερομηνία';

  @override
  String get settingsConfirmationAfterMoveToBinItems => 'Εμφάνιση μηνύματος μετά τη μεταφορά στοιχείων στον κάδο ανακύκλωσης';

  @override
  String get settingsConfirmationVaultDataLoss => 'Εμφάνιση προειδοποίησης απώλειας δεδομένων θησαυροφυλακίου';

  @override
  String get settingsNavigationDrawerTile => 'Μενού πλοήγησης';

  @override
  String get settingsNavigationDrawerEditorPageTitle => 'Μενου Πλοηγησης';

  @override
  String get settingsNavigationDrawerBanner => 'Αγγίξτε παρατεταμένα για να μετακινήσετε και να αναδιατάξετε τα στοιχεία του μενού.';

  @override
  String get settingsNavigationDrawerTabTypes => 'Τύποι';

  @override
  String get settingsNavigationDrawerTabAlbums => 'Άλμπουμ';

  @override
  String get settingsNavigationDrawerTabPages => 'Σελίδες';

  @override
  String get settingsNavigationDrawerAddAlbum => 'Προσθήκη άλμπουμ';

  @override
  String get settingsThumbnailSectionTitle => 'Μικρογραφιες';

  @override
  String get settingsThumbnailOverlayTile => 'Βοηθητικές πληροφορίες';

  @override
  String get settingsThumbnailOverlayPageTitle => 'Βοηθητικές πληροφοριες';

  @override
  String get settingsThumbnailShowHdrIcon => 'Show HDR icon';

  @override
  String get settingsThumbnailShowFavouriteIcon => 'Εμφάνιση εικονιδίου για αγαπημένο';

  @override
  String get settingsThumbnailShowTagIcon => 'Εμφάνιση εικονιδίου για ετικέτα';

  @override
  String get settingsThumbnailShowLocationIcon => 'Εμφάνιση εικονιδίου για τοποθεσία';

  @override
  String get settingsThumbnailShowMotionPhotoIcon => 'Εμφάνιση εικονιδίου για φωτογραφία με κίνηση';

  @override
  String get settingsThumbnailShowRating => 'Εμφάνιση βαθμολογίας';

  @override
  String get settingsThumbnailShowRawIcon => 'Εμφάνιση εικονιδίου για raw στοιχεία';

  @override
  String get settingsThumbnailShowVideoDuration => 'Εμφάνιση διάρκειας βίντεο';

  @override
  String get settingsCollectionQuickActionsTile => 'Γρήγορες ενέργειες';

  @override
  String get settingsCollectionQuickActionEditorPageTitle => 'Γρηγορες Ενεργειες';

  @override
  String get settingsCollectionQuickActionTabBrowsing => 'Περιήγηση';

  @override
  String get settingsCollectionQuickActionTabSelecting => 'Επιλογή';

  @override
  String get settingsCollectionBrowsingQuickActionEditorBanner => 'Αγγίξτε παρατεταμένα για να μετακινήσετε τα κουμπιά και επιλέξτε ποιες ενέργειες θα εμφανίζονται κατά την περιήγηση στοιχείων.';

  @override
  String get settingsCollectionSelectionQuickActionEditorBanner => 'Αγγίξτε παρατεταμένα για να μετακινήσετε τα κουμπιά και επιλέξτε ποιες ενέργειες θα εμφανίζονται κατά την επιλογή στοιχείων.';

  @override
  String get settingsCollectionBurstPatternsTile => 'Εμφάνιση μοτίβων';

  @override
  String get settingsCollectionBurstPatternsNone => 'Χωρίς';

  @override
  String get settingsViewerSectionTitle => 'Προβολη';

  @override
  String get settingsViewerGestureSideTapNext => 'Πατήστε στις άκρες της οθόνης για να εμφανίσετε το προηγούμενο/επόμενο στοιχείο';

  @override
  String get settingsViewerUseCutout => 'Χρησιμοποιήστε την περιοχή αποκοπής';

  @override
  String get settingsViewerMaximumBrightness => 'Μέγιστη φωτεινότητα';

  @override
  String get settingsMotionPhotoAutoPlay => 'Αυτόματη αναπαραγωγή φωτογραφιών κίνησης';

  @override
  String get settingsImageBackground => 'Φόντο κατά την προβολή στοιχείων';

  @override
  String get settingsViewerQuickActionsTile => 'Γρήγορες ενέργειες';

  @override
  String get settingsViewerQuickActionEditorPageTitle => 'Γρηγορες Ενεργειες';

  @override
  String get settingsViewerQuickActionEditorBanner => 'Αγγίξτε παρατεταμένα για να μετακινήσετε τα κουμπιά και επιλέξτε ποιες ενέργειες θα εμφανίζονται κατά την προβολή.';

  @override
  String get settingsViewerQuickActionEditorDisplayedButtonsSectionTitle => 'Εμφανιζομενα κουμπια';

  @override
  String get settingsViewerQuickActionEditorAvailableButtonsSectionTitle => 'Διαθεσιμα κουμπια';

  @override
  String get settingsViewerQuickActionEmpty => 'Χωρίς κουμπιά';

  @override
  String get settingsViewerOverlayTile => 'Επικάλυψη';

  @override
  String get settingsViewerOverlayPageTitle => 'Επικαλυψη';

  @override
  String get settingsViewerShowOverlayOnOpening => 'Εμφάνιση κατά το άνοιγμα';

  @override
  String get settingsViewerShowHistogram => 'Show histogram';

  @override
  String get settingsViewerShowMinimap => 'Εμφάνιση μικρού χάρτη';

  @override
  String get settingsViewerShowInformation => 'Εμφάνιση πληροφοριών';

  @override
  String get settingsViewerShowInformationSubtitle => 'Εμφάνιση ονομασίας, ημερομηνίας, τοποθεσίας κ.λπ.';

  @override
  String get settingsViewerShowRatingTags => 'Εμφάνιση βαθμολογίας & ετικετών';

  @override
  String get settingsViewerShowShootingDetails => 'Εμφάνιση λεπτομερειών λήψης';

  @override
  String get settingsViewerShowDescription => 'Εμφάνιση περιγραφής';

  @override
  String get settingsViewerShowOverlayThumbnails => 'Εμφάνιση μικρογραφιών';

  @override
  String get settingsViewerEnableOverlayBlurEffect => 'Εφέ θαμπώματος';

  @override
  String get settingsViewerSlideshowTile => 'Παρουσίαση φωτογραφιών';

  @override
  String get settingsViewerSlideshowPageTitle => 'Παρουσιαση φωτογραφιων';

  @override
  String get settingsSlideshowRepeat => 'Επανάληψη';

  @override
  String get settingsSlideshowShuffle => 'Τυχαία σειρά';

  @override
  String get settingsSlideshowFillScreen => 'Χρησιμοποίηση πλήρης οθόνης';

  @override
  String get settingsSlideshowAnimatedZoomEffect => 'Εφέ κινούμενου ζουμ';

  @override
  String get settingsSlideshowTransitionTile => 'Μετάβαση';

  @override
  String get settingsSlideshowIntervalTile => 'Διάρκεια';

  @override
  String get settingsSlideshowVideoPlaybackTile => 'Αναπαραγωγή βίντεο';

  @override
  String get settingsSlideshowVideoPlaybackDialogTitle => 'Αναπαραγωγη Βιντεο';

  @override
  String get settingsVideoPageTitle => 'Ρυθμισεις Βιντεο';

  @override
  String get settingsVideoSectionTitle => 'Βιντεο';

  @override
  String get settingsVideoShowVideos => 'Εμφάνιση των βίντεο στη συλλογή';

  @override
  String get settingsVideoPlaybackTile => 'Αναπαραγωγή';

  @override
  String get settingsVideoPlaybackPageTitle => 'Αναπαραγωγη';

  @override
  String get settingsVideoEnableHardwareAcceleration => 'Επιτάχυνση υλισμικού';

  @override
  String get settingsVideoAutoPlay => 'Αυτόματη αναπαραγωγή κατά το άνοιγμα';

  @override
  String get settingsVideoLoopModeTile => 'Επανάληψη αυτόματα στο τέλος κάθε βίντεο';

  @override
  String get settingsVideoLoopModeDialogTitle => 'Επαναληψη Αυτοματα στο Τελος Καθε Βιντεο';

  @override
  String get settingsVideoResumptionModeTile => 'Συνέχιση αναπαραγωγής';

  @override
  String get settingsVideoResumptionModeDialogTitle => 'Συνεχιση αναπαραγωγης';

  @override
  String get settingsVideoBackgroundMode => 'Αναπαραγωγή στο παρασκήνιο';

  @override
  String get settingsVideoBackgroundModeDialogTitle => 'Αναπαραγωγη στο παρασκηνιο';

  @override
  String get settingsVideoControlsTile => 'Έλεγχος';

  @override
  String get settingsVideoControlsPageTitle => 'Ελεγχος';

  @override
  String get settingsVideoButtonsTile => 'Κουμπιά';

  @override
  String get settingsVideoGestureDoubleTapTogglePlay => 'Αγγίξτε την οθόνη δύο φορές για αναπαραγωγή/παύση';

  @override
  String get settingsVideoGestureSideDoubleTapSeek => 'Αγγίξτε δύο φορές τις άκρες της οθόνης για να πάτε πίσω/εμπρός';

  @override
  String get settingsVideoGestureVerticalDragBrightnessVolume => 'Σύρετε προς τα πάνω ή προς τα κάτω για να ρυθμίσετε τη φωτεινότητα/την ένταση του ήχου';

  @override
  String get settingsSubtitleThemeTile => 'Υπότιτλοι';

  @override
  String get settingsSubtitleThemePageTitle => 'Υποτιτλοι';

  @override
  String get settingsSubtitleThemeSample => 'Αυτό είναι ένα δείγμα.';

  @override
  String get settingsSubtitleThemeTextAlignmentTile => 'Στοίχιση κειμένου';

  @override
  String get settingsSubtitleThemeTextAlignmentDialogTitle => 'Στοιχιση Κειμενου';

  @override
  String get settingsSubtitleThemeTextPositionTile => 'Θέση κειμένου';

  @override
  String get settingsSubtitleThemeTextPositionDialogTitle => 'Θεση κειμενου';

  @override
  String get settingsSubtitleThemeTextSize => 'Μέγεθος κειμένου';

  @override
  String get settingsSubtitleThemeShowOutline => 'Εμφάνιση περιγράμματος και σκιάς';

  @override
  String get settingsSubtitleThemeTextColor => 'Χρώμα κειμένου';

  @override
  String get settingsSubtitleThemeTextOpacity => 'Αδιαφάνεια κειμένου';

  @override
  String get settingsSubtitleThemeBackgroundColor => 'Χρώμα του φόντου';

  @override
  String get settingsSubtitleThemeBackgroundOpacity => 'Αδιαφάνεια φόντου';

  @override
  String get settingsSubtitleThemeTextAlignmentLeft => 'Αριστερά';

  @override
  String get settingsSubtitleThemeTextAlignmentCenter => 'Κέντρο';

  @override
  String get settingsSubtitleThemeTextAlignmentRight => 'Δεξιά';

  @override
  String get settingsPrivacySectionTitle => 'Απορρητο';

  @override
  String get settingsAllowInstalledAppAccess => 'Να επιτρέπεται η πρόσβαση στον κατάλογο εγκατεστημένων εφαρμογών της συσκευής';

  @override
  String get settingsAllowInstalledAppAccessSubtitle => 'Χρησιμοποιείται για τη βελτίωση της εμφάνισης των στοιχείων από τα άλμπουμ';

  @override
  String get settingsAllowErrorReporting => 'Να επιτρέπεται η ανώνυμη αναφορά σφαλμάτων';

  @override
  String get settingsSaveSearchHistory => 'Αποθήκευση ιστορικού αναζήτησης';

  @override
  String get settingsEnableBin => 'Χρησιμοποίηση κάδου ανακύκλωσης';

  @override
  String get settingsEnableBinSubtitle => 'Διατήρηση των διαγραμμένων στοιχείων για 30 ημέρες';

  @override
  String get settingsDisablingBinWarningDialogMessage => 'Τα αρχεία στον κάδο ανακύκλωσης θα διαγραφούν για πάντα.';

  @override
  String get settingsAllowMediaManagement => 'Επιτρέψτε την πλήρη διαχείριση των αρχείων σας';

  @override
  String get settingsHiddenItemsTile => 'Κρυφά στοιχεία';

  @override
  String get settingsHiddenItemsPageTitle => 'Κρυφα Στοιχεια';

  @override
  String get settingsHiddenFiltersBanner => 'Οι φωτογραφίες και τα βίντεο που είναι κρυφά δεν θα εμφανίζονται στη συλλογή σας.';

  @override
  String get settingsHiddenFiltersEmpty => 'Χωρίς κρυφά φίλτρα';

  @override
  String get settingsStorageAccessTile => 'Πρόσβαση στον χώρο αποθήκευσης';

  @override
  String get settingsStorageAccessPageTitle => 'Προσβαση στον Χωρο Αποθηκευσης';

  @override
  String get settingsStorageAccessBanner => 'Ορισμένοι κατάλογοι απαιτούν ρητή άδεια πρόσβασης για την τροποποίηση των αρχείων που βρίσκονται σε αυτούς. Μπορείτε να δείτε εδώ τους καταλόγους στους οποίους έχετε ήδη χορηγήσει πρόσβαση.';

  @override
  String get settingsStorageAccessEmpty => 'Δεν έχει χορηγηθεί πρόσβαση';

  @override
  String get settingsStorageAccessRevokeTooltip => 'Ανάκληση χορήγησης πρόσβασης';

  @override
  String get settingsAccessibilitySectionTitle => 'Προσβασιμοτητα';

  @override
  String get settingsRemoveAnimationsTile => 'Κατάργηση κινούμενων εικόνων';

  @override
  String get settingsRemoveAnimationsDialogTitle => 'Καταργηση Κινουμενων Εικονων';

  @override
  String get settingsTimeToTakeActionTile => 'Χρόνος λήψης ενεργειών';

  @override
  String get settingsAccessibilityShowPinchGestureAlternatives => 'Εμφάνιση χειρονομιών πολλαπλής αφής';

  @override
  String get settingsDisplaySectionTitle => 'Οθονη';

  @override
  String get settingsThemeBrightnessTile => 'Θέμα';

  @override
  String get settingsThemeBrightnessDialogTitle => 'Θεμα';

  @override
  String get settingsThemeColorHighlights => 'Χρωματιστά εικονίδια';

  @override
  String get settingsThemeEnableDynamicColor => 'Έντονο χρώμα';

  @override
  String get settingsDisplayRefreshRateModeTile => 'Εμφάνιση ρυθμού ανανέωσης';

  @override
  String get settingsDisplayRefreshRateModeDialogTitle => 'Ρυθμος ανανεωσης';

  @override
  String get settingsDisplayUseTvInterface => 'Χρήση του Android TV περιβάλλον';

  @override
  String get settingsLanguageSectionTitle => 'Γλωσσα & Μορφες';

  @override
  String get settingsLanguageTile => 'Γλώσσα';

  @override
  String get settingsLanguagePageTitle => 'Γλωσσα';

  @override
  String get settingsCoordinateFormatTile => 'Μορφή συντεταγμένων';

  @override
  String get settingsCoordinateFormatDialogTitle => 'Μορφη Συντεταγμενων';

  @override
  String get settingsUnitSystemTile => 'Σύστημα μέτρησης';

  @override
  String get settingsUnitSystemDialogTitle => 'Συστημα μετρησης';

  @override
  String get settingsForceWesternArabicNumeralsTile => 'Force Arabic numerals';

  @override
  String get settingsScreenSaverPageTitle => 'Προφυλαξη οθονης';

  @override
  String get settingsWidgetPageTitle => 'Κορνιζα';

  @override
  String get settingsWidgetShowOutline => 'Περίγραμμα';

  @override
  String get settingsWidgetOpenPage => 'Όταν πατάτε στο γραφικό στοιχείο';

  @override
  String get settingsWidgetDisplayedItem => 'Εμφανιζόμενο αρχείο';

  @override
  String get settingsCollectionTile => 'Συλλογή';

  @override
  String get statsPageTitle => 'Στατιστικα';

  @override
  String statsWithGps(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString στοιχεία με τοποθεσία',
      one: '1 στοιχείο με τοποθεσία',
    );
    return '$_temp0';
  }

  @override
  String get statsTopCountriesSectionTitle => 'Κορυφαιες Χωρες';

  @override
  String get statsTopStatesSectionTitle => 'Κορυφαιες Πολιτειες';

  @override
  String get statsTopPlacesSectionTitle => 'Κορυφαια Μερη';

  @override
  String get statsTopTagsSectionTitle => 'Κορυφαιες Ετικετες';

  @override
  String get statsTopAlbumsSectionTitle => 'Κορυφαια Αλμπουμ';

  @override
  String get viewerOpenPanoramaButtonLabel => 'Άνοιγμα πανοραμικών';

  @override
  String get viewerSetWallpaperButtonLabel => 'ΟΡΙΣΜΟΣ ΤΑΠΕΤΣΑΡΙΑΣ';

  @override
  String get viewerErrorUnknown => 'Ωχ!';

  @override
  String get viewerErrorDoesNotExist => 'Το αρχείο δεν υπάρχει πλέον.';

  @override
  String get viewerInfoPageTitle => 'Πληροφοριες';

  @override
  String get viewerInfoBackToViewerTooltip => 'Επιστροφή στην προβολή';

  @override
  String get viewerInfoUnknown => 'Άγνωστο';

  @override
  String get viewerInfoLabelDescription => 'Περιγραφή';

  @override
  String get viewerInfoLabelTitle => 'Όνομα';

  @override
  String get viewerInfoLabelDate => 'Ημερομηνία';

  @override
  String get viewerInfoLabelResolution => 'Ανάλυση';

  @override
  String get viewerInfoLabelSize => 'Μέγεθος';

  @override
  String get viewerInfoLabelUri => 'URI';

  @override
  String get viewerInfoLabelPath => 'Διαδρομή';

  @override
  String get viewerInfoLabelDuration => 'Διάρκεια';

  @override
  String get viewerInfoLabelOwner => 'Κάτοχος';

  @override
  String get viewerInfoLabelCoordinates => 'Συντεταγμένες';

  @override
  String get viewerInfoLabelAddress => 'Διεύθυνση';

  @override
  String get mapStyleDialogTitle => 'Στυλ χαρτη';

  @override
  String get mapStyleTooltip => 'Επιλέξτε στυλ χάρτη';

  @override
  String get mapZoomInTooltip => 'Μεγέθυνση';

  @override
  String get mapZoomOutTooltip => 'Σμίκρυνση';

  @override
  String get mapPointNorthUpTooltip => 'Εμφάνιση του βορρά στην κορυφή';

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
  String get openMapPageTooltip => 'Προβολή στη σελίδα του χάρτη';

  @override
  String get mapEmptyRegion => 'Δεν υπάρχουν εικόνες σε αυτήν την περιοχή';

  @override
  String get viewerInfoOpenEmbeddedFailureFeedback => 'Αποτυχία εξαγωγής ενσωματωμένων δεδομένων';

  @override
  String get viewerInfoOpenLinkText => 'Άνοιγμα';

  @override
  String get viewerInfoViewXmlLinkText => 'Προβολή του αρχείου XML';

  @override
  String get viewerInfoSearchFieldLabel => 'Αναζήτηση μεταδεδομένων';

  @override
  String get viewerInfoSearchEmpty => 'Δεν ταιριάζουν τα κλειδιά';

  @override
  String get viewerInfoSearchSuggestionDate => 'Ημερομηνία & Ώρα';

  @override
  String get viewerInfoSearchSuggestionDescription => 'Περιγραφή';

  @override
  String get viewerInfoSearchSuggestionDimensions => 'Διαστάσεις';

  @override
  String get viewerInfoSearchSuggestionResolution => 'Ανάλυση';

  @override
  String get viewerInfoSearchSuggestionRights => 'Δικαιώματα';

  @override
  String get wallpaperUseScrollEffect => 'Εφέ κύλισης στην αρχική οθόνη';

  @override
  String get tagEditorPageTitle => 'Επεξεργασια Ετικετων';

  @override
  String get tagEditorPageNewTagFieldLabel => 'Νέα ετικέτα';

  @override
  String get tagEditorPageAddTagTooltip => 'Προσθήκη ετικέτας';

  @override
  String get tagEditorSectionRecent => 'Πρόσφατα';

  @override
  String get tagEditorSectionPlaceholders => 'Καταχώρηση τοποθεσίας';

  @override
  String get tagEditorDiscardDialogMessage => 'Θέλετε να απορρίψετε τις αλλαγές;';

  @override
  String get tagPlaceholderCountry => 'Χώρα';

  @override
  String get tagPlaceholderState => 'Πολιτεία';

  @override
  String get tagPlaceholderPlace => 'Μέρος';

  @override
  String get panoramaEnableSensorControl => 'Ενεργοποίηση ελέγχου αισθητήρα';

  @override
  String get panoramaDisableSensorControl => 'Απενεργοποίηση ελέγχου αισθητήρα';

  @override
  String get sourceViewerPageTitle => 'Πηγη';

  @override
  String get filePickerShowHiddenFiles => 'Εμφάνιση κρυφών αρχείων';

  @override
  String get filePickerDoNotShowHiddenFiles => 'Να μην εμφανίζονται τα κρυφά αρχεία';

  @override
  String get filePickerOpenFrom => 'Άνοιγμα από';

  @override
  String get filePickerNoItems => 'Κανένα στοιχείο';

  @override
  String get filePickerUseThisFolder => 'Χρησιμοποιήστε αυτόν τον φάκελο';
}
