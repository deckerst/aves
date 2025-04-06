// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'Aves';

  @override
  String get welcomeMessage => 'Willkommen bei Aves';

  @override
  String get welcomeOptional => 'Optional';

  @override
  String get welcomeTermsToggle => 'Ich stimme den Bedingungen und Konditionen zu';

  @override
  String itemCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString Elemente',
      one: '$countString Element',
    );
    return '$_temp0';
  }

  @override
  String columnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Spalten',
      one: '$count Spalte',
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
      other: '$countString Sekunde',
      one: '$countString Sekunde',
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
      other: '$countString Minuten',
      one: '$countString Minute',
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
      other: '$countString Tage',
      one: '$countString Tag',
    );
    return '$_temp0';
  }

  @override
  String focalLength(String length) {
    return '$length mm';
  }

  @override
  String get applyButtonLabel => 'ANWENDEN';

  @override
  String get deleteButtonLabel => 'LÖSCHEN';

  @override
  String get nextButtonLabel => 'NÄCHSTE';

  @override
  String get showButtonLabel => 'ANZEIGEN';

  @override
  String get hideButtonLabel => 'VERBERGEN';

  @override
  String get continueButtonLabel => 'WEITER';

  @override
  String get saveCopyButtonLabel => 'KOPIE SPEICHERN';

  @override
  String get applyTooltip => 'Anwenden';

  @override
  String get cancelTooltip => 'Abbrechen';

  @override
  String get changeTooltip => 'Ändern';

  @override
  String get clearTooltip => 'Aufräumen';

  @override
  String get previousTooltip => 'Vorherige';

  @override
  String get nextTooltip => 'Nächste';

  @override
  String get showTooltip => 'Anzeigen';

  @override
  String get hideTooltip => 'Ausblenden';

  @override
  String get actionRemove => 'Entfernen';

  @override
  String get resetTooltip => 'Zurücksetzen';

  @override
  String get saveTooltip => 'Speichern';

  @override
  String get stopTooltip => 'Stoppen';

  @override
  String get pickTooltip => 'Wähle';

  @override
  String get doubleBackExitMessage => 'Zum Verlassen erneut auf „Zurück“ tippen.';

  @override
  String get doNotAskAgain => 'Nicht noch einmal fragen';

  @override
  String get sourceStateLoading => 'Laden';

  @override
  String get sourceStateCataloguing => 'Katalogisierung';

  @override
  String get sourceStateLocatingCountries => 'Länder lokalisieren';

  @override
  String get sourceStateLocatingPlaces => 'Lokalisierung von Orten';

  @override
  String get chipActionDelete => 'Löschen';

  @override
  String get chipActionRemove => 'Entfernen';

  @override
  String get chipActionShowCollection => 'In Sammlung anzeigen';

  @override
  String get chipActionGoToAlbumPage => 'Anzeigen in Alben';

  @override
  String get chipActionGoToCountryPage => 'Anzeigen in Ländern';

  @override
  String get chipActionGoToPlacePage => 'In Orten anzeigen';

  @override
  String get chipActionGoToTagPage => 'Zeige in Tags';

  @override
  String get chipActionGoToExplorerPage => 'Im Explorer anzeigen';

  @override
  String get chipActionDecompose => 'Aufschlüsseln';

  @override
  String get chipActionFilterOut => 'Filtern ohne';

  @override
  String get chipActionFilterIn => 'Filtern mit';

  @override
  String get chipActionHide => 'Ausblenden';

  @override
  String get chipActionLock => 'Sperren';

  @override
  String get chipActionPin => 'Oben Anpinnen';

  @override
  String get chipActionUnpin => 'Nicht mehr Anpinen';

  @override
  String get chipActionRename => 'Umbenennen';

  @override
  String get chipActionSetCover => 'Titelbild bestimmen';

  @override
  String get chipActionShowCountryStates => 'Staaten anzeigen';

  @override
  String get chipActionCreateAlbum => 'Album erstellen';

  @override
  String get chipActionCreateVault => 'Tresor anlegen';

  @override
  String get chipActionConfigureVault => 'Tresor konfigurieren';

  @override
  String get entryActionCopyToClipboard => 'In die Zwischenablage kopieren';

  @override
  String get entryActionDelete => 'Löschen';

  @override
  String get entryActionConvert => 'Konvertieren';

  @override
  String get entryActionExport => 'Exportieren';

  @override
  String get entryActionInfo => 'Info';

  @override
  String get entryActionRename => 'Umbenennen';

  @override
  String get entryActionRestore => 'Wiederherstellen';

  @override
  String get entryActionRotateCCW => 'Gegen den Uhrzeigersinn drehen';

  @override
  String get entryActionRotateCW => 'Im Uhrzeigersinn drehen';

  @override
  String get entryActionFlip => 'Horizontal spiegeln';

  @override
  String get entryActionPrint => 'Drucken';

  @override
  String get entryActionShare => 'Teilen';

  @override
  String get entryActionShareImageOnly => 'Nur das Bild teilen';

  @override
  String get entryActionShareVideoOnly => 'Nur das Video teilen';

  @override
  String get entryActionViewSource => 'Quelle anzeigen';

  @override
  String get entryActionShowGeoTiffOnMap => 'Als Karten-Overlay anzeigen';

  @override
  String get entryActionConvertMotionPhotoToStillImage => 'In ein Standbild umwandeln';

  @override
  String get entryActionViewMotionPhotoVideo => 'Video öffnen';

  @override
  String get entryActionEdit => 'Bearbeiten';

  @override
  String get entryActionOpen => 'Öffnen mit';

  @override
  String get entryActionSetAs => 'Einstellen als';

  @override
  String get entryActionCast => 'Übertragen';

  @override
  String get entryActionOpenMap => 'In der Karten-App anzeigen';

  @override
  String get entryActionRotateScreen => 'Bildschirm rotieren';

  @override
  String get entryActionAddFavourite => 'Zu Favoriten hinzufügen';

  @override
  String get entryActionRemoveFavourite => 'Aus Favoriten entfernen';

  @override
  String get videoActionCaptureFrame => 'Frame aufnehmen';

  @override
  String get videoActionMute => 'Audio deaktivieren';

  @override
  String get videoActionUnmute => 'Audio aktiveren';

  @override
  String get videoActionPause => 'Pause';

  @override
  String get videoActionPlay => 'Spielen';

  @override
  String get videoActionReplay10 => '10 Sekunden rückwärts springen';

  @override
  String get videoActionSkip10 => '10 Sekunden vorwärts springen';

  @override
  String get videoActionShowPreviousFrame => 'Vorigen Frame zeigen';

  @override
  String get videoActionShowNextFrame => 'Nächsten Frame zeigen';

  @override
  String get videoActionSelectStreams => 'Titel auswählen';

  @override
  String get videoActionSetSpeed => 'Wiedergabegeschwindigkeit';

  @override
  String get videoActionABRepeat => 'A-B-Wiederholung';

  @override
  String get videoRepeatActionSetStart => 'Start festlegen';

  @override
  String get videoRepeatActionSetEnd => 'Ende festlegen';

  @override
  String get viewerActionSettings => 'Einstellungen';

  @override
  String get viewerActionLock => 'Anzeige sperren';

  @override
  String get viewerActionUnlock => 'Anzeige entsperren';

  @override
  String get slideshowActionResume => 'Wiedergabe';

  @override
  String get slideshowActionShowInCollection => 'In Sammlung anzeigen';

  @override
  String get entryInfoActionEditDate => 'Datum & Uhrzeit bearbeiten';

  @override
  String get entryInfoActionEditLocation => 'Standort bearbeiten';

  @override
  String get entryInfoActionEditTitleDescription => 'Titel und Beschreibung bearbeiten';

  @override
  String get entryInfoActionEditRating => 'Bewertung bearbeiten';

  @override
  String get entryInfoActionEditTags => 'Tags bearbeiten';

  @override
  String get entryInfoActionRemoveMetadata => 'Metadaten entfernen';

  @override
  String get entryInfoActionExportMetadata => 'Metadaten exportieren';

  @override
  String get entryInfoActionRemoveLocation => 'Standort entfernen';

  @override
  String get editorActionTransform => 'Umwandeln';

  @override
  String get editorTransformCrop => 'Zuschneiden';

  @override
  String get editorTransformRotate => 'Drehen';

  @override
  String get cropAspectRatioFree => 'Frei';

  @override
  String get cropAspectRatioOriginal => 'Original';

  @override
  String get cropAspectRatioSquare => 'Quadrat';

  @override
  String get filterAspectRatioLandscapeLabel => 'Querformat';

  @override
  String get filterAspectRatioPortraitLabel => 'Hochformat';

  @override
  String get filterBinLabel => 'Papierkorb';

  @override
  String get filterFavouriteLabel => 'Favorit';

  @override
  String get filterNoDateLabel => 'Undatiert';

  @override
  String get filterNoAddressLabel => 'Keine Adresse';

  @override
  String get filterLocatedLabel => 'Mit Standort';

  @override
  String get filterNoLocationLabel => 'Ungeortet';

  @override
  String get filterNoRatingLabel => 'Nicht bewertet';

  @override
  String get filterTaggedLabel => 'Getaggt';

  @override
  String get filterNoTagLabel => 'Unmarkiert';

  @override
  String get filterNoTitleLabel => 'Unbenannt';

  @override
  String get filterOnThisDayLabel => 'Am heutigen Tag';

  @override
  String get filterRecentlyAddedLabel => 'Kürzlich hinzugefügt';

  @override
  String get filterRatingRejectedLabel => 'Verworfen';

  @override
  String get filterTypeAnimatedLabel => 'Animationen';

  @override
  String get filterTypeMotionPhotoLabel => 'Bewegtes Foto';

  @override
  String get filterTypePanoramaLabel => 'Panorama';

  @override
  String get filterTypeRawLabel => 'Rohdaten';

  @override
  String get filterTypeSphericalVideoLabel => '360° Video';

  @override
  String get filterTypeGeotiffLabel => 'GeoTIFF';

  @override
  String get filterMimeImageLabel => 'Bild';

  @override
  String get filterMimeVideoLabel => 'Video';

  @override
  String get accessibilityAnimationsRemove => 'Verhinderung von Bildschirmeffekten';

  @override
  String get accessibilityAnimationsKeep => 'Bildschirmeffekte beibehalten';

  @override
  String get albumTierNew => 'Neu';

  @override
  String get albumTierPinned => 'Angeheftet';

  @override
  String get albumTierSpecial => 'Häufig verwendet';

  @override
  String get albumTierApps => 'Apps';

  @override
  String get albumTierVaults => 'Tresore';

  @override
  String get albumTierDynamic => 'Dynamisch';

  @override
  String get albumTierRegular => 'Andere';

  @override
  String get coordinateFormatDms => 'GMS';

  @override
  String get coordinateFormatDdm => 'DDM';

  @override
  String get coordinateFormatDecimal => 'Dezimalgrad';

  @override
  String coordinateDms(String coordinate, String direction) {
    return '$coordinate $direction';
  }

  @override
  String get coordinateDmsNorth => 'N';

  @override
  String get coordinateDmsSouth => 's';

  @override
  String get coordinateDmsEast => 'O';

  @override
  String get coordinateDmsWest => 'W';

  @override
  String get displayRefreshRatePreferHighest => 'Höchste Rate';

  @override
  String get displayRefreshRatePreferLowest => 'Niedrigste Rate';

  @override
  String get keepScreenOnNever => 'Niemals';

  @override
  String get keepScreenOnVideoPlayback => 'Während der Videowiedergabe';

  @override
  String get keepScreenOnViewerOnly => 'Nur bei Bildbetrachtung';

  @override
  String get keepScreenOnAlways => 'Immer';

  @override
  String get lengthUnitPixel => 'px';

  @override
  String get lengthUnitPercent => '%';

  @override
  String get mapStyleGoogleNormal => 'Google Maps';

  @override
  String get mapStyleGoogleHybrid => 'Google Maps (Hybrid)';

  @override
  String get mapStyleGoogleTerrain => 'Google Maps (Gelände)';

  @override
  String get mapStyleOsmLiberty => 'OSM Liberty';

  @override
  String get mapStyleOpenTopoMap => 'OpenTopoMap';

  @override
  String get mapStyleOsmHot => 'Humanitäres OSM';

  @override
  String get mapStyleStamenWatercolor => 'Stamen Watercolor (Aquarell)';

  @override
  String get maxBrightnessNever => 'Nie';

  @override
  String get maxBrightnessAlways => 'Immer';

  @override
  String get nameConflictStrategyRename => 'Umbenennen';

  @override
  String get nameConflictStrategyReplace => 'Ersetzen';

  @override
  String get nameConflictStrategySkip => 'Überspringen';

  @override
  String get overlayHistogramNone => 'Keines';

  @override
  String get overlayHistogramRGB => 'RGB';

  @override
  String get overlayHistogramLuminance => 'Leuchtdichte';

  @override
  String get subtitlePositionTop => 'Oben';

  @override
  String get subtitlePositionBottom => 'Unten';

  @override
  String get themeBrightnessLight => 'Hell';

  @override
  String get themeBrightnessDark => 'Dunkel';

  @override
  String get themeBrightnessBlack => 'Schwarz';

  @override
  String get unitSystemMetric => 'Metrisch';

  @override
  String get unitSystemImperial => 'Imperiale';

  @override
  String get vaultLockTypePattern => 'Muster';

  @override
  String get vaultLockTypePin => 'PIN';

  @override
  String get vaultLockTypePassword => 'Passwort';

  @override
  String get settingsVideoEnablePip => 'Bild-in-Bild';

  @override
  String get videoControlsPlayOutside => 'Mit anderem Video-Player öffnen';

  @override
  String get videoLoopModeNever => 'Niemals';

  @override
  String get videoLoopModeShortOnly => 'Nur kurze Videos';

  @override
  String get videoLoopModeAlways => 'Immer';

  @override
  String get videoPlaybackSkip => 'Überspringen';

  @override
  String get videoPlaybackMuted => 'Stumm abspielen';

  @override
  String get videoPlaybackWithSound => 'Mit Ton abspielen';

  @override
  String get videoResumptionModeNever => 'Nie';

  @override
  String get videoResumptionModeAlways => 'Immer';

  @override
  String get viewerTransitionSlide => 'Dia';

  @override
  String get viewerTransitionParallax => 'Parallaxe';

  @override
  String get viewerTransitionFade => 'Ausblenden';

  @override
  String get viewerTransitionZoomIn => 'Heranzoomen';

  @override
  String get viewerTransitionNone => 'Keine';

  @override
  String get wallpaperTargetHome => 'Startbildschirm';

  @override
  String get wallpaperTargetLock => 'Sperrbildschirm';

  @override
  String get wallpaperTargetHomeLock => 'Start- und Sperrbildschirm';

  @override
  String get widgetDisplayedItemRandom => 'Zufällig';

  @override
  String get widgetDisplayedItemMostRecent => 'Neueste';

  @override
  String get widgetOpenPageHome => 'Startseite öffnen';

  @override
  String get widgetOpenPageCollection => 'Sammlung öffnen';

  @override
  String get widgetOpenPageViewer => 'Betrachter öffnen';

  @override
  String get widgetTapUpdateWidget => 'Widget aktualisieren';

  @override
  String get storageVolumeDescriptionFallbackPrimary => 'Interner Speicher';

  @override
  String get storageVolumeDescriptionFallbackNonPrimary => 'SD-Karte';

  @override
  String get rootDirectoryDescription => 'Hauptverzeichnis';

  @override
  String otherDirectoryDescription(String name) {
    return '„$name“ Verzeichnis';
  }

  @override
  String storageAccessDialogMessage(String directory, String volume) {
    return 'Bitte den $directory von „$volume“ auf dem nächsten Bildschirm auswählen, um dieser App Zugriff darauf zu geben.';
  }

  @override
  String restrictedAccessDialogMessage(String directory, String volume) {
    return 'Diese Anwendung darf keine Dateien im $directory von „$volume“ verändern.\n\nBitte einen vorinstallierten Dateimanager verwenden oder eine Galerie-App, um die Objekte in ein anderes Verzeichnis zu verschieben.';
  }

  @override
  String notEnoughSpaceDialogMessage(String neededSize, String freeSize, String volume) {
    return 'Diese Operation benötigt $neededSize freien Platz auf „$volume“, um abgeschlossen zu werden, aber es ist nur noch $freeSize übrig.';
  }

  @override
  String get missingSystemFilePickerDialogMessage => 'Der System-Dateiauswahldialog fehlt oder ist deaktiviert. Bitte aktivieren und es erneut versuchen.';

  @override
  String unsupportedTypeDialogMessage(int count, String types) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dieser Vorgang wird für Elemente der folgenden Typen nicht unterstützt: $types.',
      one: 'Dieser Vorgang wird für Elemente des folgenden Typs nicht unterstützt: $types.',
    );
    return '$_temp0';
  }

  @override
  String get nameConflictDialogSingleSourceMessage => 'Einige Dateien im Zielordner haben den gleichen Namen.';

  @override
  String get nameConflictDialogMultipleSourceMessage => 'Einige Dateien haben denselben Namen.';

  @override
  String get addShortcutDialogLabel => 'Shortcut-Etikett';

  @override
  String get addShortcutButtonLabel => 'Hinzufügen';

  @override
  String get noMatchingAppDialogMessage => 'Es gibt keine Anwendungen, die dies bewältigen können.';

  @override
  String binEntriesConfirmationDialogMessage(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Diese $countString Elemente in den Papierkorb verschieben?',
      one: 'Dieses Element in den Papierkorb verschieben?',
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
      other: 'Sicher, dass diese $countString Elemente gelöscht werden sollen?',
      one: 'Sicher, dass dieses Element gelöscht werden soll?',
    );
    return '$_temp0';
  }

  @override
  String get moveUndatedConfirmationDialogMessage => 'Daten speichern, bevor es weitergeht?';

  @override
  String get moveUndatedConfirmationDialogSetDate => 'Datum einstellen';

  @override
  String videoResumeDialogMessage(String time) {
    return 'Soll bei $time weiter abspielt werden?';
  }

  @override
  String get videoStartOverButtonLabel => 'NEU BEGINNEN';

  @override
  String get videoResumeButtonLabel => 'FORTSETZTEN';

  @override
  String get setCoverDialogLatest => 'Letzter Artikel';

  @override
  String get setCoverDialogAuto => 'Auto';

  @override
  String get setCoverDialogCustom => 'Benutzerdefiniert';

  @override
  String get hideFilterConfirmationDialogMessage => 'Passende Fotos und Videos werden aus Ihrer Sammlung ausgeblendet. Dies kann in den „Datenschutz“-Einstellungen wieder eingeblendet werden.\n\nSicher, dass diese ausblendet werden sollen?';

  @override
  String get newAlbumDialogTitle => 'Neues Album';

  @override
  String get newAlbumDialogNameLabel => 'Album Name';

  @override
  String get newAlbumDialogAlbumAlreadyExistsHelper => 'Album existiert bereits';

  @override
  String get newAlbumDialogNameLabelAlreadyExistsHelper => 'Verzeichnis existiert bereits';

  @override
  String get newAlbumDialogStorageLabel => 'Speicher:';

  @override
  String get newDynamicAlbumDialogTitle => 'Neues Dynamisches Album';

  @override
  String get dynamicAlbumAlreadyExists => 'Dynamisches Album existiert bereits';

  @override
  String get newVaultWarningDialogMessage => 'Elemente in Tresoren sind nur für diese App verfügbar und nicht in anderen.\n\nWenn Sie diese App deinstallieren oder die Daten dieser App löschen, gehen alle diese Elemente verloren.';

  @override
  String get newVaultDialogTitle => 'Neuer Tresor';

  @override
  String get configureVaultDialogTitle => 'Tresor konfigurieren';

  @override
  String get vaultDialogLockModeWhenScreenOff => 'Sperren beim Ausschalten des Bildschirms';

  @override
  String get vaultDialogLockTypeLabel => 'Schloss-Typ';

  @override
  String get patternDialogEnter => 'Muster eingeben';

  @override
  String get patternDialogConfirm => 'Muster bestätigen';

  @override
  String get pinDialogEnter => 'PIN eingeben';

  @override
  String get pinDialogConfirm => 'PIN bestätigen';

  @override
  String get passwordDialogEnter => 'Passwort eingeben';

  @override
  String get passwordDialogConfirm => 'Passwort bestätigen';

  @override
  String get authenticateToConfigureVault => 'Authentifizierung zum Konfigurieren des Tresors';

  @override
  String get authenticateToUnlockVault => 'Authentifizierung zum Entsperren des Tresors';

  @override
  String get vaultBinUsageDialogMessage => 'Einige Tresore verwenden den Papierkorb.';

  @override
  String get renameAlbumDialogLabel => 'Neuer Name';

  @override
  String get renameAlbumDialogLabelAlreadyExistsHelper => 'Verzeichnis existiert bereits';

  @override
  String get renameEntrySetPageTitle => 'Umbenennen';

  @override
  String get renameEntrySetPagePatternFieldLabel => 'Benennungsmuster';

  @override
  String get renameEntrySetPageInsertTooltip => 'Feld einfügen';

  @override
  String get renameEntrySetPagePreviewSectionTitle => 'Vorschau';

  @override
  String get renameProcessorCounter => 'Zähler';

  @override
  String get renameProcessorHash => 'Raute';

  @override
  String get renameProcessorName => 'Name';

  @override
  String deleteSingleAlbumConfirmationDialogMessage(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Das Album und die $countString darin enthaltenen Elemente löschen?',
      one: 'Das Album und das darin enthaltene Element löschen?',
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
      other: 'Diese Alben und die darin enthaltenen $countString Objekte löschen?',
      one: 'Diese Alben und die darin enthaltenen Elemente löschen?',
    );
    return '$_temp0';
  }

  @override
  String get exportEntryDialogFormat => 'Format:';

  @override
  String get exportEntryDialogWidth => 'Breite';

  @override
  String get exportEntryDialogHeight => 'Höhe';

  @override
  String get exportEntryDialogQuality => 'Qualität';

  @override
  String get exportEntryDialogWriteMetadata => 'Metadaten schreiben';

  @override
  String get renameEntryDialogLabel => 'Neuer Name';

  @override
  String get editEntryDialogCopyFromItem => 'Von einem anderen Element kopieren';

  @override
  String get editEntryDialogTargetFieldsHeader => 'Zu ändernde Felder';

  @override
  String get editEntryDateDialogTitle => 'Datum & Uhrzeit';

  @override
  String get editEntryDateDialogSetCustom => 'Datum einstellen';

  @override
  String get editEntryDateDialogCopyField => 'Von anderem Datum kopieren';

  @override
  String get editEntryDateDialogExtractFromTitle => 'Auszug aus dem Titel';

  @override
  String get editEntryDateDialogShift => 'Verschieben';

  @override
  String get editEntryDateDialogSourceFileModifiedDate => 'Änderungsdatum der Datei';

  @override
  String get durationDialogHours => 'Stunden';

  @override
  String get durationDialogMinutes => 'Minuten';

  @override
  String get durationDialogSeconds => 'Sekunden';

  @override
  String get editEntryLocationDialogTitle => 'Standort';

  @override
  String get editEntryLocationDialogSetCustom => 'Benutzerdefinierten Standort festlegen';

  @override
  String get editEntryLocationDialogChooseOnMap => 'Auf Karte wählen';

  @override
  String get editEntryLocationDialogImportGpx => 'GPX importieren';

  @override
  String get editEntryLocationDialogLatitude => 'Breitengrad';

  @override
  String get editEntryLocationDialogLongitude => 'Längengrad';

  @override
  String get editEntryLocationDialogTimeShift => 'Zeitverschiebung';

  @override
  String get locationPickerUseThisLocationButton => 'Diesen Standort verwenden';

  @override
  String get editEntryRatingDialogTitle => 'Bewertung';

  @override
  String get removeEntryMetadataDialogTitle => 'Entfernung von Metadaten';

  @override
  String get removeEntryMetadataDialogAll => 'Alle';

  @override
  String get removeEntryMetadataDialogMore => 'Mehr';

  @override
  String get removeEntryMetadataMotionPhotoXmpWarningDialogMessage => 'XMP ist erforderlich, um das Video innerhalb eines bewegten Bildes abzuspielen.\n\nSicher, dass es entfernt werden soll?';

  @override
  String get videoSpeedDialogLabel => 'Wiedergabegeschwindigkeit';

  @override
  String get videoStreamSelectionDialogVideo => 'Video';

  @override
  String get videoStreamSelectionDialogAudio => 'Audio';

  @override
  String get videoStreamSelectionDialogText => 'Untertitel';

  @override
  String get videoStreamSelectionDialogOff => 'Aus';

  @override
  String get videoStreamSelectionDialogTrack => 'Spur';

  @override
  String get videoStreamSelectionDialogNoSelection => 'Es gibt keine anderen Spuren.';

  @override
  String get genericSuccessFeedback => 'Erledigt!';

  @override
  String get genericFailureFeedback => 'Gescheitert';

  @override
  String get genericDangerWarningDialogMessage => 'Sicher?';

  @override
  String get tooManyItemsErrorDialogMessage => 'Noch einmal mit weniger Elementen versuchen.';

  @override
  String get menuActionConfigureView => 'Sortierung';

  @override
  String get menuActionSelect => 'Auswahl';

  @override
  String get menuActionSelectAll => 'Alle auswählen';

  @override
  String get menuActionSelectNone => 'Keine auswählen';

  @override
  String get menuActionMap => 'Karte';

  @override
  String get menuActionSlideshow => 'Diashow';

  @override
  String get menuActionStats => 'Statistiken';

  @override
  String get viewDialogSortSectionTitle => 'Sortieren';

  @override
  String get viewDialogGroupSectionTitle => 'Gruppe';

  @override
  String get viewDialogLayoutSectionTitle => 'Layout';

  @override
  String get viewDialogReverseSortOrder => 'Umgekehrte Sortierung';

  @override
  String get tileLayoutMosaic => 'Mosaik';

  @override
  String get tileLayoutGrid => 'Kacheln';

  @override
  String get tileLayoutList => 'Liste';

  @override
  String get castDialogTitle => 'Geräte zur Übertragung';

  @override
  String get coverDialogTabCover => 'Titelbild';

  @override
  String get coverDialogTabApp => 'App';

  @override
  String get coverDialogTabColor => 'Farbe';

  @override
  String get appPickDialogTitle => 'Wähle App';

  @override
  String get appPickDialogNone => 'Nichts';

  @override
  String get aboutPageTitle => 'Über';

  @override
  String get aboutLinkLicense => 'Lizenz';

  @override
  String get aboutLinkPolicy => 'Datenschutzrichtlinie';

  @override
  String get aboutBugSectionTitle => 'Fehlerbericht';

  @override
  String get aboutBugSaveLogInstruction => 'Anwendungsprotokolle in einer Datei speichern';

  @override
  String get aboutBugCopyInfoInstruction => 'Systeminformationen kopieren';

  @override
  String get aboutBugCopyInfoButton => 'Kopieren';

  @override
  String get aboutBugReportInstruction => 'Bericht auf GitHub mit den Protokollen und Systeminformationen';

  @override
  String get aboutBugReportButton => 'Bericht';

  @override
  String get aboutDataUsageSectionTitle => 'Datennutzung';

  @override
  String get aboutDataUsageData => 'Daten';

  @override
  String get aboutDataUsageCache => 'Cache';

  @override
  String get aboutDataUsageDatabase => 'Datenbank';

  @override
  String get aboutDataUsageMisc => 'Sonstiges';

  @override
  String get aboutDataUsageInternal => 'Intern';

  @override
  String get aboutDataUsageExternal => 'Extern';

  @override
  String get aboutDataUsageClearCache => 'Cache leeren';

  @override
  String get aboutCreditsSectionTitle => 'Kredite';

  @override
  String get aboutCreditsWorldAtlas1 => 'Diese Anwendung verwendet eine TopoJSON-Datei von';

  @override
  String get aboutCreditsWorldAtlas2 => 'unter ISC-Lizenz.';

  @override
  String get aboutTranslatorsSectionTitle => 'Übersetzer';

  @override
  String get aboutLicensesSectionTitle => 'Open-Source-Lizenzen';

  @override
  String get aboutLicensesBanner => 'Diese Anwendung verwendet die folgenden Open-Source-Pakete und -Bibliotheken.';

  @override
  String get aboutLicensesAndroidLibrariesSectionTitle => 'Android-Bibliotheken';

  @override
  String get aboutLicensesFlutterPluginsSectionTitle => 'Flutter-Plugins';

  @override
  String get aboutLicensesFlutterPackagesSectionTitle => 'Flatter-Pakete';

  @override
  String get aboutLicensesDartPackagesSectionTitle => 'Dart-Pakete';

  @override
  String get aboutLicensesShowAllButtonLabel => 'Alle Lizenzen anzeigen';

  @override
  String get policyPageTitle => 'Datenschutzrichtlinie';

  @override
  String get collectionPageTitle => 'Sammlung';

  @override
  String get collectionPickPageTitle => 'Wähle';

  @override
  String get collectionSelectPageTitle => 'Elemente auswählen';

  @override
  String get collectionActionShowTitleSearch => 'Titelfilter anzeigen';

  @override
  String get collectionActionHideTitleSearch => 'Titelfilter ausblenden';

  @override
  String get collectionActionAddDynamicAlbum => 'Dynamisches Album hinzufügen';

  @override
  String get collectionActionAddShortcut => 'Verknüpfung hinzufügen';

  @override
  String get collectionActionSetHome => 'Als Startseite setzen';

  @override
  String get collectionActionEmptyBin => 'Papierkorb leeren';

  @override
  String get collectionActionCopy => 'In Album kopieren';

  @override
  String get collectionActionMove => 'Zum Album verschieben';

  @override
  String get collectionActionRescan => 'Neu scannen';

  @override
  String get collectionActionEdit => 'Bearbeiten';

  @override
  String get collectionSearchTitlesHintText => 'Titel suchen';

  @override
  String get collectionGroupAlbum => 'Nach Album';

  @override
  String get collectionGroupMonth => 'Nach Monat';

  @override
  String get collectionGroupDay => 'Nach Tag';

  @override
  String get collectionGroupNone => 'Nicht gruppieren';

  @override
  String get sectionUnknown => 'Unbekannt';

  @override
  String get dateToday => 'Heute';

  @override
  String get dateYesterday => 'Gestern';

  @override
  String get dateThisMonth => 'Diesen Monat';

  @override
  String collectionDeleteFailureFeedback(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString Elemente konnten nicht gelöscht werden',
      one: '1 Element konnte nicht gelöscht werden',
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
      other: '$countString Element konnten nicht kopiert werden',
      one: '1 Element konnte nicht kopiert werden',
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
      other: '$countString Elemente konnten nicht verschoben werden',
      one: '1 Element konnte nicht verschoben werden',
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
      other: 'Fehler beim Umbenennen $countString Elemente',
      one: 'Fehler beim Umbenennen eines Elements',
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
      other: '$countString 1 Elemente konnten nicht bearbeitet werden',
      one: '1 Element konnte nicht bearbeitet werden',
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
      other: '$countString Seiten konnten nicht exportiert werden',
      one: '1 Seite konnte nicht exportiert werden',
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
      other: ' $countString Elemente kopiert',
      one: '1 Element kopier',
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
      other: '$countString Elemente verschoben',
      one: '1 Element verschoben',
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
      other: '$countString Elemente umbenannt',
      one: '1 Element umbenannt',
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
      other: ' $countString Elemente bearbeitet',
      one: '1 Element bearbeitet',
    );
    return '$_temp0';
  }

  @override
  String get collectionEmptyFavourites => 'Keine Favoriten';

  @override
  String get collectionEmptyVideos => 'Keine Videos';

  @override
  String get collectionEmptyImages => 'Keine Bilder';

  @override
  String get collectionEmptyGrantAccessButtonLabel => 'Zugriff gewähren';

  @override
  String get collectionSelectSectionTooltip => 'Bereich auswählen';

  @override
  String get collectionDeselectSectionTooltip => 'Bereich abwählen';

  @override
  String get drawerAboutButton => 'Über';

  @override
  String get drawerSettingsButton => 'Einstellungen';

  @override
  String get drawerCollectionAll => 'Alle Bilder';

  @override
  String get drawerCollectionFavourites => 'Favoriten';

  @override
  String get drawerCollectionImages => 'Bilder';

  @override
  String get drawerCollectionVideos => 'Videos';

  @override
  String get drawerCollectionAnimated => 'Animationen';

  @override
  String get drawerCollectionMotionPhotos => 'Bewegte Fotos';

  @override
  String get drawerCollectionPanoramas => 'Panoramen';

  @override
  String get drawerCollectionRaws => 'Rohdaten Fotos';

  @override
  String get drawerCollectionSphericalVideos => '360°-Videos';

  @override
  String get drawerAlbumPage => 'Alben';

  @override
  String get drawerCountryPage => 'Länder';

  @override
  String get drawerPlacePage => 'Orte';

  @override
  String get drawerTagPage => 'Tags';

  @override
  String get sortByDate => 'Nach Datum';

  @override
  String get sortByName => 'Nach Name';

  @override
  String get sortByItemCount => 'Nach Anzahl';

  @override
  String get sortBySize => 'Nach Größe';

  @override
  String get sortByAlbumFileName => 'Nach Album & Dateiname';

  @override
  String get sortByRating => 'Nach Bewertung';

  @override
  String get sortByDuration => 'Nach Dauer';

  @override
  String get sortOrderNewestFirst => 'Neueste zuerst';

  @override
  String get sortOrderOldestFirst => 'Älteste zuerst';

  @override
  String get sortOrderAtoZ => 'A zu Z';

  @override
  String get sortOrderZtoA => 'Z zu A';

  @override
  String get sortOrderHighestFirst => 'Höchste zuerst';

  @override
  String get sortOrderLowestFirst => 'Niedrigste zuerst';

  @override
  String get sortOrderLargestFirst => 'Größtes zuerst';

  @override
  String get sortOrderSmallestFirst => 'Kleinste zuerst';

  @override
  String get sortOrderShortestFirst => 'Kurze zuerst';

  @override
  String get sortOrderLongestFirst => 'Lange zuerst';

  @override
  String get albumGroupTier => 'Nach Ebene';

  @override
  String get albumGroupType => 'Nach Typ';

  @override
  String get albumGroupVolume => 'Nach Speichervolumen';

  @override
  String get albumGroupNone => 'Nicht gruppieren';

  @override
  String get albumMimeTypeMixed => 'Gemischt';

  @override
  String get albumPickPageTitleCopy => 'In Album kopieren';

  @override
  String get albumPickPageTitleExport => 'In Album exportieren';

  @override
  String get albumPickPageTitleMove => 'Zum Album verschieben';

  @override
  String get albumPickPageTitlePick => 'Album auswählen';

  @override
  String get albumCamera => 'Kamera';

  @override
  String get albumDownload => 'Heruntergeladen';

  @override
  String get albumScreenshots => 'Bildschirmfotos';

  @override
  String get albumScreenRecordings => 'Bildschirmaufnahmen';

  @override
  String get albumVideoCaptures => 'Video-Aufnahmen';

  @override
  String get albumPageTitle => 'Alben';

  @override
  String get albumEmpty => 'Keine Alben';

  @override
  String get createAlbumButtonLabel => 'ERSTELLE';

  @override
  String get newFilterBanner => 'Neu';

  @override
  String get countryPageTitle => 'Länder';

  @override
  String get countryEmpty => 'Keine Länder';

  @override
  String get statePageTitle => 'Staaten';

  @override
  String get stateEmpty => 'Keine Staaten';

  @override
  String get placePageTitle => 'Orte';

  @override
  String get placeEmpty => 'Keine Orte';

  @override
  String get tagPageTitle => 'Tags';

  @override
  String get tagEmpty => 'Keine Tags';

  @override
  String get binPageTitle => 'Papierkorb';

  @override
  String get explorerPageTitle => 'Explorer';

  @override
  String get explorerActionSelectStorageVolume => 'Speicher auswählen';

  @override
  String get selectStorageVolumeDialogTitle => 'Speicher auswählen';

  @override
  String get searchCollectionFieldHint => 'Sammlung durchsuchen';

  @override
  String get searchRecentSectionTitle => 'Neueste';

  @override
  String get searchDateSectionTitle => 'Datum';

  @override
  String get searchAlbumsSectionTitle => 'Alben';

  @override
  String get searchCountriesSectionTitle => 'Länder';

  @override
  String get searchStatesSectionTitle => 'Staaten';

  @override
  String get searchPlacesSectionTitle => 'Orte';

  @override
  String get searchTagsSectionTitle => 'Tags';

  @override
  String get searchRatingSectionTitle => 'Bewertungen';

  @override
  String get searchMetadataSectionTitle => 'Metadaten';

  @override
  String get settingsPageTitle => 'Einstellungen';

  @override
  String get settingsSystemDefault => 'System';

  @override
  String get settingsDefault => 'Standard';

  @override
  String get settingsDisabled => 'Deaktiviert';

  @override
  String get settingsAskEverytime => 'Jedes Mal nachfragen';

  @override
  String get settingsModificationWarningDialogMessage => 'Andere Einstellungen werden angepasst.';

  @override
  String get settingsSearchFieldLabel => 'Einstellungen durchsuchen';

  @override
  String get settingsSearchEmpty => 'Keine passende Einstellung';

  @override
  String get settingsActionExport => 'Exportieren';

  @override
  String get settingsActionExportDialogTitle => 'Exportieren';

  @override
  String get settingsActionImport => 'Importieren';

  @override
  String get settingsActionImportDialogTitle => 'Importieren';

  @override
  String get appExportCovers => 'Titelbilder';

  @override
  String get appExportDynamicAlbums => 'Dynamische Alben';

  @override
  String get appExportFavourites => 'Favoriten';

  @override
  String get appExportSettings => 'Einstellungen';

  @override
  String get settingsNavigationSectionTitle => 'Navigation';

  @override
  String get settingsHomeTile => 'Startseite';

  @override
  String get settingsHomeDialogTitle => 'Startseite';

  @override
  String get setHomeCustom => 'Benutzerdefiniert';

  @override
  String get settingsShowBottomNavigationBar => 'Untere Navigationsleiste anzeigen';

  @override
  String get settingsKeepScreenOnTile => 'Bildschirm eingeschaltet lassen';

  @override
  String get settingsKeepScreenOnDialogTitle => 'Bildschirm eingeschaltet lassen';

  @override
  String get settingsDoubleBackExit => 'Zum Verlassen zweimal „zurück“ tippen';

  @override
  String get settingsConfirmationTile => 'Bestätigungsdialoge';

  @override
  String get settingsConfirmationDialogTitle => 'Bestätigungsdialoge';

  @override
  String get settingsConfirmationBeforeDeleteItems => 'Vor dem endgültigen Löschen von Elementen fragen';

  @override
  String get settingsConfirmationBeforeMoveToBinItems => 'Vor dem Verschieben von Elementen in den Papierkorb fragen';

  @override
  String get settingsConfirmationBeforeMoveUndatedItems => 'Vor Verschiebung von Objekten ohne Metadaten-Datum fragen';

  @override
  String get settingsConfirmationAfterMoveToBinItems => 'Nachricht nach dem Verschieben von Elementen in den Papierkorb anzeigen';

  @override
  String get settingsConfirmationVaultDataLoss => 'Warnung vor Tresordatenverlust anzeigen';

  @override
  String get settingsNavigationDrawerTile => 'Menü Navigation';

  @override
  String get settingsNavigationDrawerEditorPageTitle => 'Menü Navigation';

  @override
  String get settingsNavigationDrawerBanner => 'Die Taste berühren und halten, um Menüpunkte zu verschieben und neu anzuordnen.';

  @override
  String get settingsNavigationDrawerTabTypes => 'Typen';

  @override
  String get settingsNavigationDrawerTabAlbums => 'Alben';

  @override
  String get settingsNavigationDrawerTabPages => 'Seiten';

  @override
  String get settingsNavigationDrawerAddAlbum => 'Album hinzufügen';

  @override
  String get settingsThumbnailSectionTitle => 'Vorschaubilder';

  @override
  String get settingsThumbnailOverlayTile => 'Überlagerung';

  @override
  String get settingsThumbnailOverlayPageTitle => 'Überlagerung';

  @override
  String get settingsThumbnailShowHdrIcon => 'HDR-Symbol anzeigen';

  @override
  String get settingsThumbnailShowFavouriteIcon => 'Favoriten-Symbol anzeigen';

  @override
  String get settingsThumbnailShowTagIcon => 'Tag-Symbol anzeigen';

  @override
  String get settingsThumbnailShowLocationIcon => 'Standort-Symbol anzeigen';

  @override
  String get settingsThumbnailShowMotionPhotoIcon => 'Bewegungsfoto-Symbol anzeigen';

  @override
  String get settingsThumbnailShowRating => 'Bewertung anzeigen';

  @override
  String get settingsThumbnailShowRawIcon => 'Rohdaten-Symbol anzeigen';

  @override
  String get settingsThumbnailShowVideoDuration => 'Videodauer anzeigen';

  @override
  String get settingsCollectionQuickActionsTile => 'Schnelle Aktionen';

  @override
  String get settingsCollectionQuickActionEditorPageTitle => 'Schnelle Aktionen';

  @override
  String get settingsCollectionQuickActionTabBrowsing => 'Durchsuchen';

  @override
  String get settingsCollectionQuickActionTabSelecting => 'Auswahl';

  @override
  String get settingsCollectionBrowsingQuickActionEditorBanner => 'Die Taste gedrückt halten, um die Schaltflächen zu bewegen und auszuwählen, welche Aktionen beim Durchsuchen von Elementen angezeigt werden.';

  @override
  String get settingsCollectionSelectionQuickActionEditorBanner => 'Die Taste gedrückt halten, um die Schaltflächen zu bewegen und auszuwählen, welche Aktionen beim Durchsuchen von Elementen angezeigt werden.';

  @override
  String get settingsCollectionBurstPatternsTile => 'Berstmuster';

  @override
  String get settingsCollectionBurstPatternsNone => 'Nichts';

  @override
  String get settingsViewerSectionTitle => 'Anzeige';

  @override
  String get settingsViewerGestureSideTapNext => 'Tippen auf den Bildschirmrand, um das vorheriges/nächstes Element anzuzeigen';

  @override
  String get settingsViewerUseCutout => 'Ausgeschnittenen Bereich verwenden';

  @override
  String get settingsViewerMaximumBrightness => 'Maximale Helligkeit';

  @override
  String get settingsMotionPhotoAutoPlay => 'Automatische Wiedergabe bewegter Fotos';

  @override
  String get settingsImageBackground => 'Bild-Hintergrund';

  @override
  String get settingsViewerQuickActionsTile => 'Schnelle Aktionen';

  @override
  String get settingsViewerQuickActionEditorPageTitle => 'Schnelle Aktionen';

  @override
  String get settingsViewerQuickActionEditorBanner => 'Die Taste gedrückt halten, um die Schaltflächen zu bewegen und auszuwählen, welche Aktionen im Viewer angezeigt werden sollen.';

  @override
  String get settingsViewerQuickActionEditorDisplayedButtonsSectionTitle => 'Angezeigte Schaltflächen';

  @override
  String get settingsViewerQuickActionEditorAvailableButtonsSectionTitle => 'Verfügbare Schaltflächen';

  @override
  String get settingsViewerQuickActionEmpty => 'Keine Tasten';

  @override
  String get settingsViewerOverlayTile => 'Überlagerung';

  @override
  String get settingsViewerOverlayPageTitle => 'Überlagerung';

  @override
  String get settingsViewerShowOverlayOnOpening => 'Bei Eröffnung anzeigen';

  @override
  String get settingsViewerShowHistogram => 'Histogramm anzeigen';

  @override
  String get settingsViewerShowMinimap => 'Minimap anzeigen';

  @override
  String get settingsViewerShowInformation => 'Informationen anzeigen';

  @override
  String get settingsViewerShowInformationSubtitle => 'Titel, Datum, Ort, etc. anzeigen.';

  @override
  String get settingsViewerShowRatingTags => 'Bewertung & Tags anzeigen';

  @override
  String get settingsViewerShowShootingDetails => 'Aufnahmedetails anzeigen';

  @override
  String get settingsViewerShowDescription => 'Beschreibung anzeigen';

  @override
  String get settingsViewerShowOverlayThumbnails => 'Vorschaubilder anzeigen';

  @override
  String get settingsViewerEnableOverlayBlurEffect => 'Unschärfe-Effekt';

  @override
  String get settingsViewerSlideshowTile => 'Diashow';

  @override
  String get settingsViewerSlideshowPageTitle => 'Diashow';

  @override
  String get settingsSlideshowRepeat => 'Wiederholung';

  @override
  String get settingsSlideshowShuffle => 'Mischen';

  @override
  String get settingsSlideshowFillScreen => 'Bildschirm ausfüllen';

  @override
  String get settingsSlideshowAnimatedZoomEffect => 'Animierter Zoomeffekt';

  @override
  String get settingsSlideshowTransitionTile => 'Übergang';

  @override
  String get settingsSlideshowIntervalTile => 'Intervall';

  @override
  String get settingsSlideshowVideoPlaybackTile => 'Videowiedergabe';

  @override
  String get settingsSlideshowVideoPlaybackDialogTitle => 'Videowiedergabe';

  @override
  String get settingsVideoPageTitle => 'Video-Einstellungen';

  @override
  String get settingsVideoSectionTitle => 'Video';

  @override
  String get settingsVideoShowVideos => 'Videos anzeigen';

  @override
  String get settingsVideoPlaybackTile => 'Wiedergabe';

  @override
  String get settingsVideoPlaybackPageTitle => 'Wiedergabe';

  @override
  String get settingsVideoEnableHardwareAcceleration => 'Hardware-Beschleunigung';

  @override
  String get settingsVideoAutoPlay => 'Automatische Wiedergabe';

  @override
  String get settingsVideoLoopModeTile => 'Schleifen-Modus';

  @override
  String get settingsVideoLoopModeDialogTitle => 'Schleifen-Modus';

  @override
  String get settingsVideoResumptionModeTile => 'Wiedergabe fortsetzen';

  @override
  String get settingsVideoResumptionModeDialogTitle => 'Wiedergabe fortsetzen';

  @override
  String get settingsVideoBackgroundMode => 'Hintergrund-Modus';

  @override
  String get settingsVideoBackgroundModeDialogTitle => 'Hintergrund-Modus';

  @override
  String get settingsVideoControlsTile => 'Steuerung';

  @override
  String get settingsVideoControlsPageTitle => 'Steuerung';

  @override
  String get settingsVideoButtonsTile => 'Schaltflächen';

  @override
  String get settingsVideoGestureDoubleTapTogglePlay => 'Doppeltippen zum Abspielen/Pausieren';

  @override
  String get settingsVideoGestureSideDoubleTapSeek => 'Doppeltippen auf die Bildschirmränder zum Rückwärts-/Vorwärtsspringen';

  @override
  String get settingsVideoGestureVerticalDragBrightnessVolume => 'Nach oben oder unten wischen, um die Helligkeit/Lautstärke einzustellen';

  @override
  String get settingsSubtitleThemeTile => 'Untertitel';

  @override
  String get settingsSubtitleThemePageTitle => 'Untertitel';

  @override
  String get settingsSubtitleThemeSample => 'Dies ist ein Beispiel.';

  @override
  String get settingsSubtitleThemeTextAlignmentTile => 'Textausrichtung';

  @override
  String get settingsSubtitleThemeTextAlignmentDialogTitle => 'Textausrichtung';

  @override
  String get settingsSubtitleThemeTextPositionTile => 'Textposition';

  @override
  String get settingsSubtitleThemeTextPositionDialogTitle => 'Textposition';

  @override
  String get settingsSubtitleThemeTextSize => 'Textgröße';

  @override
  String get settingsSubtitleThemeShowOutline => 'Umriss und Schatten anzeigen';

  @override
  String get settingsSubtitleThemeTextColor => 'Textfarbe';

  @override
  String get settingsSubtitleThemeTextOpacity => 'Opazität des Textes';

  @override
  String get settingsSubtitleThemeBackgroundColor => 'Hintergrundfarbe';

  @override
  String get settingsSubtitleThemeBackgroundOpacity => 'Hintergrund-Opazität';

  @override
  String get settingsSubtitleThemeTextAlignmentLeft => 'Links';

  @override
  String get settingsSubtitleThemeTextAlignmentCenter => 'Zentrum';

  @override
  String get settingsSubtitleThemeTextAlignmentRight => 'Rechts';

  @override
  String get settingsPrivacySectionTitle => 'Datenschutz';

  @override
  String get settingsAllowInstalledAppAccess => 'Zugriff auf die Liste der installierten Apps';

  @override
  String get settingsAllowInstalledAppAccessSubtitle => 'zur Gruppierung von Bildern nach Apps';

  @override
  String get settingsAllowErrorReporting => 'Anonyme Fehlermeldungen zulassen';

  @override
  String get settingsSaveSearchHistory => 'Suchverlauf speichern';

  @override
  String get settingsEnableBin => 'Papierkorb verwenden';

  @override
  String get settingsEnableBinSubtitle => 'Gelöschte Elemente 30 Tage lang aufbewahren';

  @override
  String get settingsDisablingBinWarningDialogMessage => 'Die Elemente im Papierkorb werden für immer gelöscht.';

  @override
  String get settingsAllowMediaManagement => 'Medienverwaltung zulassen';

  @override
  String get settingsHiddenItemsTile => 'Versteckte Elemente';

  @override
  String get settingsHiddenItemsPageTitle => 'Versteckte Elemente';

  @override
  String get settingsHiddenFiltersBanner => 'Fotos und Videos, die versteckten Filtern entsprechen, werden nicht in Ihrer Sammlung angezeigt.';

  @override
  String get settingsHiddenFiltersEmpty => 'Keine versteckten Filter';

  @override
  String get settingsStorageAccessTile => 'Speicherzugriff';

  @override
  String get settingsStorageAccessPageTitle => 'Speicherzugriff';

  @override
  String get settingsStorageAccessBanner => 'Einige Verzeichnisse erfordern eine explizite Zugriffsberechtigung, um Dateien darin zu ändern. Hier können Verzeichnisse überprüft werden, auf die zuvor Zugriff gewährt wurde.';

  @override
  String get settingsStorageAccessEmpty => 'Keine Zugangsberechtigungen';

  @override
  String get settingsStorageAccessRevokeTooltip => 'Widerrufen';

  @override
  String get settingsAccessibilitySectionTitle => 'Barrierefreiheit';

  @override
  String get settingsRemoveAnimationsTile => 'Animationen entfernen';

  @override
  String get settingsRemoveAnimationsDialogTitle => 'Animationen entfernen';

  @override
  String get settingsTimeToTakeActionTile => 'Zeit zum Reagieren';

  @override
  String get settingsAccessibilityShowPinchGestureAlternatives => 'Alternativen für Multi-Touch-Gesten anzeigen';

  @override
  String get settingsDisplaySectionTitle => 'Darstellung';

  @override
  String get settingsThemeBrightnessTile => 'Thema';

  @override
  String get settingsThemeBrightnessDialogTitle => 'Thema';

  @override
  String get settingsThemeColorHighlights => 'Farbige Highlights';

  @override
  String get settingsThemeEnableDynamicColor => 'Dynamische Farben';

  @override
  String get settingsDisplayRefreshRateModeTile => 'Bildwiederholrate der Anzeige';

  @override
  String get settingsDisplayRefreshRateModeDialogTitle => 'Bildwiederholrate';

  @override
  String get settingsDisplayUseTvInterface => 'Android-TV Oberfläche';

  @override
  String get settingsLanguageSectionTitle => 'Sprache & Formate';

  @override
  String get settingsLanguageTile => 'Sprache';

  @override
  String get settingsLanguagePageTitle => 'Sprache';

  @override
  String get settingsCoordinateFormatTile => 'Koordinatenformat';

  @override
  String get settingsCoordinateFormatDialogTitle => 'Koordinatenformat';

  @override
  String get settingsUnitSystemTile => 'Einheiten';

  @override
  String get settingsUnitSystemDialogTitle => 'Einheiten';

  @override
  String get settingsForceWesternArabicNumeralsTile => 'Arabische Ziffern erzwingen';

  @override
  String get settingsScreenSaverPageTitle => 'Bildschirmschoner';

  @override
  String get settingsWidgetPageTitle => 'Bilderrahmen';

  @override
  String get settingsWidgetShowOutline => 'Umrandung';

  @override
  String get settingsWidgetOpenPage => 'Beim Tippen auf das Widget';

  @override
  String get settingsWidgetDisplayedItem => 'Angezeigtes Element';

  @override
  String get settingsCollectionTile => 'Sammlung';

  @override
  String get statsPageTitle => 'Statistiken';

  @override
  String statsWithGps(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString Elemente mit Standort',
      one: '1 Element mit Standort',
    );
    return '$_temp0';
  }

  @override
  String get statsTopCountriesSectionTitle => 'Top-Länder';

  @override
  String get statsTopStatesSectionTitle => 'Top Staaten';

  @override
  String get statsTopPlacesSectionTitle => 'Top-Plätze';

  @override
  String get statsTopTagsSectionTitle => 'Top-Tags';

  @override
  String get statsTopAlbumsSectionTitle => 'Top-Alben';

  @override
  String get viewerOpenPanoramaButtonLabel => 'ÖFFNE PANORAMA';

  @override
  String get viewerSetWallpaperButtonLabel => 'HINTERGRUNDBILD EINSTELLEN';

  @override
  String get viewerErrorUnknown => 'Ups!';

  @override
  String get viewerErrorDoesNotExist => 'Die Datei existiert nicht mehr.';

  @override
  String get viewerInfoPageTitle => 'Info';

  @override
  String get viewerInfoBackToViewerTooltip => 'Zurück zum Betrachter';

  @override
  String get viewerInfoUnknown => 'Unbekannt';

  @override
  String get viewerInfoLabelDescription => 'Beschreibung';

  @override
  String get viewerInfoLabelTitle => 'Titel';

  @override
  String get viewerInfoLabelDate => 'Datum';

  @override
  String get viewerInfoLabelResolution => 'Auflösung';

  @override
  String get viewerInfoLabelSize => 'Größe';

  @override
  String get viewerInfoLabelUri => 'URL';

  @override
  String get viewerInfoLabelPath => 'Pfad';

  @override
  String get viewerInfoLabelDuration => 'Dauer';

  @override
  String get viewerInfoLabelOwner => 'Im Besitz von';

  @override
  String get viewerInfoLabelCoordinates => 'Koordinaten';

  @override
  String get viewerInfoLabelAddress => 'Adresse';

  @override
  String get mapStyleDialogTitle => 'Kartenstil';

  @override
  String get mapStyleTooltip => 'Kartenstil auswählen';

  @override
  String get mapZoomInTooltip => 'Vergrößern';

  @override
  String get mapZoomOutTooltip => 'Verkleinern';

  @override
  String get mapPointNorthUpTooltip => 'Richtung Norden aufwärts';

  @override
  String get mapAttributionOsmData => 'Kartendaten © [OpenStreetMap](https://www.openstreetmap.org/copyright) Mitwirkende';

  @override
  String get mapAttributionOsmLiberty => 'Kacheln von [OpenMapTiles](https://www.openmaptiles.org/), [CC BY](http://creativecommons.org/licenses/by/4.0) • Gehostet von [OSM Americana](https://tile.ourmap.us)';

  @override
  String get mapAttributionOpenTopoMap => '[SRTM](https://www.earthdata.nasa.gov/sensors/srtm) | Kacheln von [OpenTopoMap](https://opentopomap.org/), [CC BY-SA](https://creativecommons.org/licenses/by-sa/3.0/)';

  @override
  String get mapAttributionOsmHot => 'Kacheln von [HOT](https://www.hotosm.org/) • Gehostet von [OSM France](https://openstreetmap.fr/)';

  @override
  String get mapAttributionStamen => 'Kacheln von [Stamen Design](https://stamen.com), [CC BY 3.0](https://creativecommons.org/licenses/by/3.0)';

  @override
  String get openMapPageTooltip => 'Auf der Karte anzeigen';

  @override
  String get mapEmptyRegion => 'Keine Bilder in dieser Region';

  @override
  String get viewerInfoOpenEmbeddedFailureFeedback => 'Eingebettete Daten konnten nicht extrahiert werden';

  @override
  String get viewerInfoOpenLinkText => 'Öffnen';

  @override
  String get viewerInfoViewXmlLinkText => 'Ansicht XML';

  @override
  String get viewerInfoSearchFieldLabel => 'Metadaten suchen';

  @override
  String get viewerInfoSearchEmpty => 'Keine passenden Schlüssel';

  @override
  String get viewerInfoSearchSuggestionDate => 'Datum & Uhrzeit';

  @override
  String get viewerInfoSearchSuggestionDescription => 'Beschreibung';

  @override
  String get viewerInfoSearchSuggestionDimensions => 'Abmessungen';

  @override
  String get viewerInfoSearchSuggestionResolution => 'Auflösung';

  @override
  String get viewerInfoSearchSuggestionRights => 'Rechte';

  @override
  String get wallpaperUseScrollEffect => 'Scroll-Effekt auf dem Startbildschirm verwenden';

  @override
  String get tagEditorPageTitle => 'Tags bearbeiten';

  @override
  String get tagEditorPageNewTagFieldLabel => 'Neuer Tag';

  @override
  String get tagEditorPageAddTagTooltip => 'Tag hinzufügen';

  @override
  String get tagEditorSectionRecent => 'Neueste';

  @override
  String get tagEditorSectionPlaceholders => 'Platzhalter';

  @override
  String get tagEditorDiscardDialogMessage => 'Möchten Sie die Änderungen verwerfen?';

  @override
  String get tagPlaceholderCountry => 'Land';

  @override
  String get tagPlaceholderState => 'Staat';

  @override
  String get tagPlaceholderPlace => 'Ort';

  @override
  String get panoramaEnableSensorControl => 'Aktivieren der Sensorsteuerung';

  @override
  String get panoramaDisableSensorControl => 'Sensorsteuerung deaktivieren';

  @override
  String get sourceViewerPageTitle => 'Quelle';

  @override
  String get filePickerShowHiddenFiles => 'Versteckte Dateien anzeigen';

  @override
  String get filePickerDoNotShowHiddenFiles => 'Versteckte Dateien nicht anzeigen';

  @override
  String get filePickerOpenFrom => 'Öffnen von';

  @override
  String get filePickerNoItems => 'Keine Elemente';

  @override
  String get filePickerUseThisFolder => 'Diesen Ordner verwenden';
}
