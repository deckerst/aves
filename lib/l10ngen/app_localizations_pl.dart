// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appName => 'Aves';

  @override
  String get welcomeMessage => 'Witaj w Aves';

  @override
  String get welcomeOptional => 'Opcjonalnie';

  @override
  String get welcomeTermsToggle => 'Akceptuję warunki i zasady';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elelmentów',
      few: '$count elementy',
      one: '$count element',
    );
    return '$_temp0';
  }

  @override
  String columnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rzędów',
      few: '$count rzędy',
      one: '$count rząd',
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
      other: '$countString sekund',
      few: '$countString sekundy',
      one: '$countString sekunda',
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
      other: '$countString minut',
      few: '$countString minuty',
      one: '$countString minuta',
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
      other: '$countString dni',
      few: '$countString dni',
      one: '$countString dzień',
    );
    return '$_temp0';
  }

  @override
  String focalLength(String length) {
    return '$length mm';
  }

  @override
  String get applyButtonLabel => 'ZASTOSUJ';

  @override
  String get deleteButtonLabel => 'USUŃ';

  @override
  String get nextButtonLabel => 'NASTĘPNY';

  @override
  String get showButtonLabel => 'POKAŻ';

  @override
  String get hideButtonLabel => 'UKRYJ';

  @override
  String get continueButtonLabel => 'KONTYNUUJ';

  @override
  String get saveCopyButtonLabel => 'ZAPISZ KOPIĘ';

  @override
  String get applyTooltip => 'Zastosuj';

  @override
  String get cancelTooltip => 'Anuluj';

  @override
  String get changeTooltip => 'Zmień';

  @override
  String get clearTooltip => 'Wyczyść';

  @override
  String get previousTooltip => 'Poprzedni';

  @override
  String get nextTooltip => 'Następny';

  @override
  String get showTooltip => 'Pokaż';

  @override
  String get hideTooltip => 'Ukryj';

  @override
  String get actionRemove => 'Usuń';

  @override
  String get resetTooltip => 'Zresetuj';

  @override
  String get saveTooltip => 'Zapisz';

  @override
  String get stopTooltip => 'Zatrzymaj';

  @override
  String get pickTooltip => 'Wybierz';

  @override
  String get doubleBackExitMessage => 'Dotknij ponownie „wstecz”, aby wyjść.';

  @override
  String get doNotAskAgain => 'Nie pytaj ponownie';

  @override
  String get sourceStateLoading => 'Ładowanie';

  @override
  String get sourceStateCataloguing => 'Katalogowanie';

  @override
  String get sourceStateLocatingCountries => 'Lokowanie krajów';

  @override
  String get sourceStateLocatingPlaces => 'Lokalizowanie miejsc';

  @override
  String get chipActionDelete => 'Usuń';

  @override
  String get chipActionRemove => 'Usuń';

  @override
  String get chipActionShowCollection => 'Pokaż w Kolekcji';

  @override
  String get chipActionGoToAlbumPage => 'Pokaż w Albumach';

  @override
  String get chipActionGoToCountryPage => 'Pokaż w Krajach';

  @override
  String get chipActionGoToPlacePage => 'Pokaż w Miejscach';

  @override
  String get chipActionGoToTagPage => 'Pokaż w Tagach';

  @override
  String get chipActionGoToExplorerPage => 'Pokaż w przeglądarce';

  @override
  String get chipActionDecompose => 'Podziel';

  @override
  String get chipActionFilterOut => 'Odfiltruj';

  @override
  String get chipActionFilterIn => 'Filtrować';

  @override
  String get chipActionHide => 'Schowaj';

  @override
  String get chipActionLock => 'Zablokuj';

  @override
  String get chipActionPin => 'Przypnij na górze';

  @override
  String get chipActionUnpin => 'Odepnij z góry';

  @override
  String get chipActionRename => 'Zmień nazwę';

  @override
  String get chipActionSetCover => 'Ustaw okładkę';

  @override
  String get chipActionShowCountryStates => 'Pokaż stany';

  @override
  String get chipActionCreateAlbum => 'Utwórz album';

  @override
  String get chipActionCreateVault => 'Utwórz skarbiec';

  @override
  String get chipActionConfigureVault => 'Konfiguruj Skarbiec';

  @override
  String get entryActionCopyToClipboard => 'Skopiuj do schowka';

  @override
  String get entryActionDelete => 'Usuń';

  @override
  String get entryActionConvert => 'Konwertuj';

  @override
  String get entryActionExport => 'Eksport';

  @override
  String get entryActionInfo => 'Informacje';

  @override
  String get entryActionRename => 'Zmień nazwę';

  @override
  String get entryActionRestore => 'Przywróć';

  @override
  String get entryActionRotateCCW => 'Obróć w lewo';

  @override
  String get entryActionRotateCW => 'Obróć w prawo';

  @override
  String get entryActionFlip => 'Obróć w poziomie';

  @override
  String get entryActionPrint => 'Drukuj';

  @override
  String get entryActionShare => 'Udostępnij';

  @override
  String get entryActionShareImageOnly => 'Udostępnij tylko zdjęcia';

  @override
  String get entryActionShareVideoOnly => 'Udostępnij tylko wideo';

  @override
  String get entryActionViewSource => 'Pokaż źródło';

  @override
  String get entryActionShowGeoTiffOnMap => 'Pokaż jako nakładkę mapy';

  @override
  String get entryActionConvertMotionPhotoToStillImage => 'Konwertuj na nieruchomy obraz';

  @override
  String get entryActionViewMotionPhotoVideo => 'Otwórz film';

  @override
  String get entryActionEdit => 'Edycja';

  @override
  String get entryActionOpen => 'Otwórz z';

  @override
  String get entryActionSetAs => 'Ustaw jako';

  @override
  String get entryActionCast => 'Cast';

  @override
  String get entryActionOpenMap => 'Pokaż w aplikacji mapy';

  @override
  String get entryActionRotateScreen => 'Obróć ekran';

  @override
  String get entryActionAddFavourite => 'Dodaj do ulubionych';

  @override
  String get entryActionRemoveFavourite => 'Usuń z ulubionych';

  @override
  String get videoActionCaptureFrame => 'Ramka do przechwytywania';

  @override
  String get videoActionMute => 'Wycisz';

  @override
  String get videoActionUnmute => 'Wyłącz wyciszenie';

  @override
  String get videoActionPause => 'Pauza';

  @override
  String get videoActionPlay => 'Graj';

  @override
  String get videoActionReplay10 => 'Przewiń do tyłu 10 sekund';

  @override
  String get videoActionSkip10 => 'Przewiń do przodu 10 sekund';

  @override
  String get videoActionShowPreviousFrame => 'Pokaż poprzednią klatkę';

  @override
  String get videoActionShowNextFrame => 'Pokaż kolejną klatkę';

  @override
  String get videoActionSelectStreams => 'Wybierz ścieżki';

  @override
  String get videoActionSetSpeed => 'Prędkość odtwarzania';

  @override
  String get videoActionABRepeat => 'Powtarzanie A-B';

  @override
  String get videoRepeatActionSetStart => 'Ustaw początek';

  @override
  String get videoRepeatActionSetEnd => 'Ustaw koniec';

  @override
  String get viewerActionSettings => 'Ustawienia';

  @override
  String get viewerActionLock => 'Zablokuj przeglądarkę';

  @override
  String get viewerActionUnlock => 'Odblokuj przeglądarkę';

  @override
  String get slideshowActionResume => 'Wznów';

  @override
  String get slideshowActionShowInCollection => 'Pokaż w Kolekcji';

  @override
  String get entryInfoActionEditDate => 'Edytuj datę & godzinę';

  @override
  String get entryInfoActionEditLocation => 'Edytuj lokalizację';

  @override
  String get entryInfoActionEditTitleDescription => 'Edytuj tytuł & opis';

  @override
  String get entryInfoActionEditRating => 'Edytuj ocenę';

  @override
  String get entryInfoActionEditTags => 'Edytuj znaczniki';

  @override
  String get entryInfoActionRemoveMetadata => 'Usuń metadane';

  @override
  String get entryInfoActionExportMetadata => 'Wyeksportuj metadane';

  @override
  String get entryInfoActionRemoveLocation => 'Usuń lokalizację';

  @override
  String get editorActionTransform => 'Przekształć';

  @override
  String get editorTransformCrop => 'Przytnij';

  @override
  String get editorTransformRotate => 'Obróć';

  @override
  String get cropAspectRatioFree => 'Dowolnie';

  @override
  String get cropAspectRatioOriginal => 'Oryginał';

  @override
  String get cropAspectRatioSquare => 'Kwadrat';

  @override
  String get filterAspectRatioLandscapeLabel => 'Pejzaż';

  @override
  String get filterAspectRatioPortraitLabel => 'Portret';

  @override
  String get filterBinLabel => 'Kosz';

  @override
  String get filterFavouriteLabel => 'Ulubione';

  @override
  String get filterNoDateLabel => 'Niedatowany';

  @override
  String get filterNoAddressLabel => 'Brak adresu';

  @override
  String get filterLocatedLabel => 'Umiejscowione';

  @override
  String get filterNoLocationLabel => 'Nieumiejscowione';

  @override
  String get filterNoRatingLabel => 'Nieoceniony';

  @override
  String get filterTaggedLabel => 'Oznaczone';

  @override
  String get filterNoTagLabel => 'Nieoznaczone';

  @override
  String get filterNoTitleLabel => 'Bez tytułu';

  @override
  String get filterOnThisDayLabel => 'Tego dnia';

  @override
  String get filterRecentlyAddedLabel => 'Ostatnio dodane';

  @override
  String get filterRatingRejectedLabel => 'Odrzucony';

  @override
  String get filterTypeAnimatedLabel => 'Animowany';

  @override
  String get filterTypeMotionPhotoLabel => 'Ruchome Zdjęcie';

  @override
  String get filterTypePanoramaLabel => 'Zdjęcie panoramiczne';

  @override
  String get filterTypeRawLabel => 'Raw';

  @override
  String get filterTypeSphericalVideoLabel => 'Wideo 360°';

  @override
  String get filterTypeGeotiffLabel => 'GeoTIFF';

  @override
  String get filterMimeImageLabel => 'Obraz';

  @override
  String get filterMimeVideoLabel => 'Wideo';

  @override
  String get accessibilityAnimationsRemove => 'Zapobiegaj efektom ekranu';

  @override
  String get accessibilityAnimationsKeep => 'Zachowaj efekty ekranu';

  @override
  String get albumTierNew => 'Nowy';

  @override
  String get albumTierPinned => 'Przypięty';

  @override
  String get albumTierSpecial => 'Wspólne';

  @override
  String get albumTierApps => 'Aplikacje';

  @override
  String get albumTierVaults => 'Skarbce';

  @override
  String get albumTierDynamic => 'Dynamiczny';

  @override
  String get albumTierRegular => 'Inne';

  @override
  String get coordinateFormatDms => 'Stopnie, Minuty, Sekundy';

  @override
  String get coordinateFormatDdm => 'DDM';

  @override
  String get coordinateFormatDecimal => 'Stopnie z miejscami dziesiętnymi';

  @override
  String coordinateDms(String coordinate, String direction) {
    return '$coordinate $direction';
  }

  @override
  String get coordinateDmsNorth => 'Pn';

  @override
  String get coordinateDmsSouth => 'Pd';

  @override
  String get coordinateDmsEast => 'Ws';

  @override
  String get coordinateDmsWest => 'Z';

  @override
  String get displayRefreshRatePreferHighest => 'Najwyższa';

  @override
  String get displayRefreshRatePreferLowest => 'Najniższa';

  @override
  String get keepScreenOnNever => 'Nigdy';

  @override
  String get keepScreenOnVideoPlayback => 'Przy odtwarzaniu wideo';

  @override
  String get keepScreenOnViewerOnly => 'Na stronie przeglądarki';

  @override
  String get keepScreenOnAlways => 'Zawsze';

  @override
  String get lengthUnitPixel => 'px';

  @override
  String get lengthUnitPercent => '%';

  @override
  String get mapStyleGoogleNormal => 'Mapy Google';

  @override
  String get mapStyleGoogleHybrid => 'Mapy Google (hybrydowe)';

  @override
  String get mapStyleGoogleTerrain => 'Mapy Google (teren)';

  @override
  String get mapStyleOsmLiberty => 'OSM Liberty';

  @override
  String get mapStyleOpenTopoMap => 'Otwórz TopoMap';

  @override
  String get mapStyleOsmHot => 'Humanitarny OSM';

  @override
  String get mapStyleStamenWatercolor => 'Stamen Watercolor (kolory wody)';

  @override
  String get maxBrightnessNever => 'Nigdy';

  @override
  String get maxBrightnessAlways => 'Zawsze';

  @override
  String get nameConflictStrategyRename => 'Zmień nazwę';

  @override
  String get nameConflictStrategyReplace => 'Zastąp';

  @override
  String get nameConflictStrategySkip => 'Pomiń';

  @override
  String get overlayHistogramNone => 'Brak';

  @override
  String get overlayHistogramRGB => 'RGB';

  @override
  String get overlayHistogramLuminance => 'Jasność';

  @override
  String get subtitlePositionTop => 'Na górze';

  @override
  String get subtitlePositionBottom => 'Na dole';

  @override
  String get themeBrightnessLight => 'Jasny';

  @override
  String get themeBrightnessDark => 'Ciemny';

  @override
  String get themeBrightnessBlack => 'Czarny';

  @override
  String get unitSystemMetric => 'Metryczne';

  @override
  String get unitSystemImperial => 'Imperialne';

  @override
  String get vaultLockTypePattern => 'Wzór';

  @override
  String get vaultLockTypePin => 'PIN';

  @override
  String get vaultLockTypePassword => 'Hasło';

  @override
  String get settingsVideoEnablePip => 'Obraz w obrazie';

  @override
  String get videoControlsPlayOutside => 'Odtwórz innym odtwarzaczem';

  @override
  String get videoLoopModeNever => 'Nigdy';

  @override
  String get videoLoopModeShortOnly => 'Tylko krótkie wideo';

  @override
  String get videoLoopModeAlways => 'Zawsze';

  @override
  String get videoPlaybackSkip => 'Pomiń';

  @override
  String get videoPlaybackMuted => 'Odtwarzaj bez dźwięku';

  @override
  String get videoPlaybackWithSound => 'Odtwarzaj z dźwiękiem';

  @override
  String get videoResumptionModeNever => 'Nigdy';

  @override
  String get videoResumptionModeAlways => 'Zawsze';

  @override
  String get viewerTransitionSlide => 'Slajd';

  @override
  String get viewerTransitionParallax => 'Paralaksa';

  @override
  String get viewerTransitionFade => 'Zanikanie';

  @override
  String get viewerTransitionZoomIn => 'Powiększanie';

  @override
  String get viewerTransitionNone => 'Brak';

  @override
  String get wallpaperTargetHome => 'Ekran główny';

  @override
  String get wallpaperTargetLock => 'Ekran blokady';

  @override
  String get wallpaperTargetHomeLock => 'Ekran główny i blokady';

  @override
  String get widgetDisplayedItemRandom => 'Losowo';

  @override
  String get widgetDisplayedItemMostRecent => 'Najnowszy';

  @override
  String get widgetOpenPageHome => 'Otwórz stronę główną';

  @override
  String get widgetOpenPageCollection => 'Otwórz kolekcję';

  @override
  String get widgetOpenPageViewer => 'Otwórz przeglądarkę';

  @override
  String get widgetTapUpdateWidget => 'Zaktualizuj widżet';

  @override
  String get storageVolumeDescriptionFallbackPrimary => 'Pamięć wewnętrzna';

  @override
  String get storageVolumeDescriptionFallbackNonPrimary => 'Karta SD';

  @override
  String get rootDirectoryDescription => 'katalog główny';

  @override
  String otherDirectoryDescription(String name) {
    return 'katalog „$name”';
  }

  @override
  String storageAccessDialogMessage(String directory, String volume) {
    return 'Wybierz $directory lub „$volume” na następnym ekranie, aby dać tej aplikacji dostęp do niego.';
  }

  @override
  String restrictedAccessDialogMessage(String directory, String volume) {
    return 'Ta aplikacja nie może modyfikować plików w $directory „$volume”.\n\nUżyj wstępnie zainstalowanego menedżera plików lub aplikacji galerii, aby przenieść elementy do innego katalogu.';
  }

  @override
  String notEnoughSpaceDialogMessage(String neededSize, String freeSize, String volume) {
    return 'Ta operacja wymaga $neededSize wolnego miejsca na „$volume”, aby ją ukończyć, ale pozostało tylko $freeSize.';
  }

  @override
  String get missingSystemFilePickerDialogMessage => 'Brak selektora plików systemowych lub jest on wyłączony. Włącz go i spróbuj ponownie.';

  @override
  String unsupportedTypeDialogMessage(int count, String types) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ta operacja nie jest obsługiwana dla elementów następujących typów: $types.',
      one: 'Ta operacja nie jest obsługiwana dla elementów następującego typu: $types.',
    );
    return '$_temp0';
  }

  @override
  String get nameConflictDialogSingleSourceMessage => 'Niektóre pliki w katalogu docelowym mają taką samą nazwę.';

  @override
  String get nameConflictDialogMultipleSourceMessage => 'Niektóre pliki mają tę samą nazwę.';

  @override
  String get addShortcutDialogLabel => 'Etykieta skrótu';

  @override
  String get addShortcutButtonLabel => 'DODAJ';

  @override
  String get noMatchingAppDialogMessage => 'Nie ma aplikacji, które mogłyby sobie z tym poradzić.';

  @override
  String binEntriesConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Przenieść te elementy $count do Kosza?',
      one: 'Przenieść ten element do Kosza?',
    );
    return '$_temp0';
  }

  @override
  String deleteEntriesConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Usunąć te elementy $count?',
      one: 'Usunąć ten element?',
    );
    return '$_temp0';
  }

  @override
  String get moveUndatedConfirmationDialogMessage => 'Zapisać daty elementów przed kontynuacją?';

  @override
  String get moveUndatedConfirmationDialogSetDate => 'Zapisz daty';

  @override
  String videoResumeDialogMessage(String time) {
    return 'Czy chcesz wznowić odtwarzanie od $time?';
  }

  @override
  String get videoStartOverButtonLabel => 'ZACZNIJ OD NOWA';

  @override
  String get videoResumeButtonLabel => 'WZNÓW';

  @override
  String get setCoverDialogLatest => 'Ostatni element';

  @override
  String get setCoverDialogAuto => 'Automatycznie';

  @override
  String get setCoverDialogCustom => 'Własny';

  @override
  String get hideFilterConfirmationDialogMessage => 'Pasujące zdjęcia i filmy zostaną ukryte w kolekcji. Możesz je ponownie wyświetlić w ustawieniach, w sekcji „Prywatność”.\n\nCzy na pewno chcesz je ukryć?';

  @override
  String get newAlbumDialogTitle => 'Nowy album';

  @override
  String get newAlbumDialogNameLabel => 'Nazwa albumu';

  @override
  String get newAlbumDialogAlbumAlreadyExistsHelper => 'Album już istnieje';

  @override
  String get newAlbumDialogNameLabelAlreadyExistsHelper => 'Katalog już istnieje';

  @override
  String get newAlbumDialogStorageLabel => 'Pamięć:';

  @override
  String get newDynamicAlbumDialogTitle => 'Nowy dynamiczny album';

  @override
  String get dynamicAlbumAlreadyExists => 'Dynamiczny album już istnieje';

  @override
  String get newVaultWarningDialogMessage => 'Elementy w skarbcach są dostępne tylko dla tej aplikacji i żadnej innej.\n\nJeśli odinstalujesz tę aplikację lub wyczyścisz dane tej aplikacji, stracisz wszystkie te elementy.';

  @override
  String get newVaultDialogTitle => 'Nowy Skarbiec';

  @override
  String get configureVaultDialogTitle => 'Konfiguruj Skarbiec';

  @override
  String get vaultDialogLockModeWhenScreenOff => 'Blokada po wyłączeniu ekranu';

  @override
  String get vaultDialogLockTypeLabel => 'Rodzaj blokady';

  @override
  String get patternDialogEnter => 'Ustaw wzór';

  @override
  String get patternDialogConfirm => 'Potwierdź wzór';

  @override
  String get pinDialogEnter => 'Wpisz kod PIN';

  @override
  String get pinDialogConfirm => 'Potwierdź kod PIN';

  @override
  String get passwordDialogEnter => 'Wpisz hasło';

  @override
  String get passwordDialogConfirm => 'Potwierdź hasło';

  @override
  String get authenticateToConfigureVault => 'Uwierzytelnij się, aby skonfigurować Skarbiec';

  @override
  String get authenticateToUnlockVault => 'Uwierzytelnij się, aby odblokować skarbiec';

  @override
  String get vaultBinUsageDialogMessage => 'Niektóre skarbce korzystają z kosza.';

  @override
  String get renameAlbumDialogLabel => 'Nowa nazwa';

  @override
  String get renameAlbumDialogLabelAlreadyExistsHelper => 'Katalog już istnieje';

  @override
  String get renameEntrySetPageTitle => 'Zmień nazwę';

  @override
  String get renameEntrySetPagePatternFieldLabel => 'Wzorzec nazewnictwa';

  @override
  String get renameEntrySetPageInsertTooltip => 'Wstaw pole';

  @override
  String get renameEntrySetPagePreviewSectionTitle => 'Podgląd';

  @override
  String get renameProcessorCounter => 'Licznik';

  @override
  String get renameProcessorHash => 'Skrót';

  @override
  String get renameProcessorName => 'Nazwa';

  @override
  String deleteSingleAlbumConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Usunąć ten album i jego $count elementów?',
      few: 'Usunąć ten album i jego $count elementy?',
      one: 'Usunąć ten album i jego element?',
    );
    return '$_temp0';
  }

  @override
  String deleteMultiAlbumConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Usunąć te albumy i ich $count elementów?',
      few: 'Usunąć te albumy i ich $count elementy?',
      one: 'Usunąć te albumy i ich element?',
    );
    return '$_temp0';
  }

  @override
  String get exportEntryDialogFormat => 'Format:';

  @override
  String get exportEntryDialogWidth => 'Szerokość';

  @override
  String get exportEntryDialogHeight => 'Wysokość';

  @override
  String get exportEntryDialogQuality => 'Jakość';

  @override
  String get exportEntryDialogWriteMetadata => 'Zapisz metadane';

  @override
  String get renameEntryDialogLabel => 'Nowa nazwa';

  @override
  String get editEntryDialogCopyFromItem => 'Kopiuj z innego elementu';

  @override
  String get editEntryDialogTargetFieldsHeader => 'Pola do modyfikacji';

  @override
  String get editEntryDateDialogTitle => 'Data i godzina';

  @override
  String get editEntryDateDialogSetCustom => 'Ustaw własną datę';

  @override
  String get editEntryDateDialogCopyField => 'Skopiuj z innej daty';

  @override
  String get editEntryDateDialogExtractFromTitle => 'Wydobądź z tytułu';

  @override
  String get editEntryDateDialogShift => 'Zmiana';

  @override
  String get editEntryDateDialogSourceFileModifiedDate => 'Data modyfikacji pliku';

  @override
  String get durationDialogHours => 'Godziny';

  @override
  String get durationDialogMinutes => 'Minuty';

  @override
  String get durationDialogSeconds => 'Sekundy';

  @override
  String get editEntryLocationDialogTitle => 'Pozycja';

  @override
  String get editEntryLocationDialogSetCustom => 'Ustaw własną pozycję';

  @override
  String get editEntryLocationDialogChooseOnMap => 'Wybierz z mapy';

  @override
  String get editEntryLocationDialogImportGpx => 'Importuj GPX';

  @override
  String get editEntryLocationDialogLatitude => 'Szerokość geograficzna';

  @override
  String get editEntryLocationDialogLongitude => 'Długość geograficzna';

  @override
  String get editEntryLocationDialogTimeShift => 'Przesunięcie czasowe';

  @override
  String get locationPickerUseThisLocationButton => 'Użyj tej pozycji';

  @override
  String get editEntryRatingDialogTitle => 'Ocena';

  @override
  String get removeEntryMetadataDialogTitle => 'Usuwanie metadanych';

  @override
  String get removeEntryMetadataDialogAll => 'Wszystko';

  @override
  String get removeEntryMetadataDialogMore => 'Więcej';

  @override
  String get removeEntryMetadataMotionPhotoXmpWarningDialogMessage => 'XMP jest wymagane do odtworzenia wideo wewnątrz zdjęcia.\n\nCzy na pewno chcesz go usunąć?';

  @override
  String get videoSpeedDialogLabel => 'Szybkość odtwarzania';

  @override
  String get videoStreamSelectionDialogVideo => 'Wideo';

  @override
  String get videoStreamSelectionDialogAudio => 'Audio';

  @override
  String get videoStreamSelectionDialogText => 'Napisy';

  @override
  String get videoStreamSelectionDialogOff => 'Wyłącz';

  @override
  String get videoStreamSelectionDialogTrack => 'Ścieżka';

  @override
  String get videoStreamSelectionDialogNoSelection => 'Nie ma innych ścieżek.';

  @override
  String get genericSuccessFeedback => 'Gotowe!';

  @override
  String get genericFailureFeedback => 'Niepowodzenie';

  @override
  String get genericDangerWarningDialogMessage => 'Czy na pewno?';

  @override
  String get tooManyItemsErrorDialogMessage => 'Spróbuj ponownie z mniejszą ilością elementów.';

  @override
  String get menuActionConfigureView => 'Widok';

  @override
  String get menuActionSelect => 'Zaznacz';

  @override
  String get menuActionSelectAll => 'Zaznacz wszystkie';

  @override
  String get menuActionSelectNone => 'Odznacz';

  @override
  String get menuActionMap => 'Mapa';

  @override
  String get menuActionSlideshow => 'Pokaz slajdów';

  @override
  String get menuActionStats => 'Statystyki';

  @override
  String get viewDialogSortSectionTitle => 'Sortuj';

  @override
  String get viewDialogGroupSectionTitle => 'Grupuj';

  @override
  String get viewDialogLayoutSectionTitle => 'Układ';

  @override
  String get viewDialogReverseSortOrder => 'Odwróć porządek sortowania';

  @override
  String get tileLayoutMosaic => 'Mozaika';

  @override
  String get tileLayoutGrid => 'Siatka';

  @override
  String get tileLayoutList => 'Lista';

  @override
  String get castDialogTitle => 'Urządzenia Cast';

  @override
  String get coverDialogTabCover => 'Okładka';

  @override
  String get coverDialogTabApp => 'Aplikacja';

  @override
  String get coverDialogTabColor => 'Kolor';

  @override
  String get appPickDialogTitle => 'Wybierz aplikację';

  @override
  String get appPickDialogNone => 'Brak';

  @override
  String get aboutPageTitle => 'O aplikacji';

  @override
  String get aboutLinkLicense => 'Licencje';

  @override
  String get aboutLinkPolicy => 'Polityka prywatności';

  @override
  String get aboutBugSectionTitle => 'Raport o błędach';

  @override
  String get aboutBugSaveLogInstruction => 'Zapisz dzienniki aplikacji w pliku';

  @override
  String get aboutBugCopyInfoInstruction => 'Skopiuj informację o systemie';

  @override
  String get aboutBugCopyInfoButton => 'Kopiuj';

  @override
  String get aboutBugReportInstruction => 'Zgłoś w usłudze GitHub z dziennikami i informacją o systemie';

  @override
  String get aboutBugReportButton => 'Zgłoś';

  @override
  String get aboutDataUsageSectionTitle => 'Wykorzystanie danych';

  @override
  String get aboutDataUsageData => 'Dane';

  @override
  String get aboutDataUsageCache => 'Pamięć podręczna';

  @override
  String get aboutDataUsageDatabase => 'Baza danych';

  @override
  String get aboutDataUsageMisc => 'Różne';

  @override
  String get aboutDataUsageInternal => 'Wewnętrzny';

  @override
  String get aboutDataUsageExternal => 'Zewnętrzny';

  @override
  String get aboutDataUsageClearCache => 'Wyczyść pamięć podręczną';

  @override
  String get aboutCreditsSectionTitle => 'Zasługi';

  @override
  String get aboutCreditsWorldAtlas1 => 'Ta aplikacja używa pliku TopoJSON z';

  @override
  String get aboutCreditsWorldAtlas2 => 'na licencji ISC.';

  @override
  String get aboutTranslatorsSectionTitle => 'Tłumacze';

  @override
  String get aboutLicensesSectionTitle => 'Licencje o otwartym kodzie';

  @override
  String get aboutLicensesBanner => 'Ta aplikacja używa następujących pakietów i bibliotek z otwartym kodem.';

  @override
  String get aboutLicensesAndroidLibrariesSectionTitle => 'Biblioteki systemu Android';

  @override
  String get aboutLicensesFlutterPluginsSectionTitle => 'Wtyczki Fluttera';

  @override
  String get aboutLicensesFlutterPackagesSectionTitle => 'Pakiety Fluttera';

  @override
  String get aboutLicensesDartPackagesSectionTitle => 'Pakiety Dart';

  @override
  String get aboutLicensesShowAllButtonLabel => 'Pokaż wszystkie licencje';

  @override
  String get policyPageTitle => 'Polityka prywatności';

  @override
  String get collectionPageTitle => 'Kolekcja';

  @override
  String get collectionPickPageTitle => 'Wybierz';

  @override
  String get collectionSelectPageTitle => 'Wybierz elementy';

  @override
  String get collectionActionShowTitleSearch => 'Pokaż filtr tytułu';

  @override
  String get collectionActionHideTitleSearch => 'Ukryj filtr tytułu';

  @override
  String get collectionActionAddDynamicAlbum => 'Dodaj dynamiczny album';

  @override
  String get collectionActionAddShortcut => 'Dodaj skrót';

  @override
  String get collectionActionSetHome => 'Ustaw jako stronę główną';

  @override
  String get collectionActionEmptyBin => 'Opróżnij kosz';

  @override
  String get collectionActionCopy => 'Kopiuj do albumu';

  @override
  String get collectionActionMove => 'Przenieś do albumu';

  @override
  String get collectionActionRescan => 'Przeskanuj';

  @override
  String get collectionActionEdit => 'Edytuj';

  @override
  String get collectionSearchTitlesHintText => 'Szukaj tytułów';

  @override
  String get collectionGroupAlbum => 'Według albumu';

  @override
  String get collectionGroupMonth => 'Według miesiąca';

  @override
  String get collectionGroupDay => 'Według dnia';

  @override
  String get collectionGroupNone => 'Nie grupuj';

  @override
  String get sectionUnknown => 'Nieznany';

  @override
  String get dateToday => 'Dzisiaj';

  @override
  String get dateYesterday => 'Wczoraj';

  @override
  String get dateThisMonth => 'W tym miesiącu';

  @override
  String collectionDeleteFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nie udało się usunąć $count elementów',
      one: 'Nie udało się usunąć 1 elementu',
    );
    return '$_temp0';
  }

  @override
  String collectionCopyFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nie udało się skopiować $count elementów',
      one: 'Nie udało się skopiować 1 elementu',
    );
    return '$_temp0';
  }

  @override
  String collectionMoveFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nie udało się przenieść $count elementów',
      one: 'Nie udało się przenieść 1 elementu',
    );
    return '$_temp0';
  }

  @override
  String collectionRenameFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nie udało się zmienić nazwy $count elementom',
      one: 'Nie udało się zmienić nazwy 1 elementowi',
    );
    return '$_temp0';
  }

  @override
  String collectionEditFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nie udało się wyedytować $count elementów',
      one: 'Nie udało się wyedytować 1 elementu',
    );
    return '$_temp0';
  }

  @override
  String collectionExportFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nie udało się wyeksportować$count stron',
      one: 'Nie udało się wyeksportować 1 strony',
    );
    return '$_temp0';
  }

  @override
  String collectionCopySuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Skopiowano $count elementów',
      few: 'Skopiowano $count elementy',
      one: 'Skopiowano 1 element',
    );
    return '$_temp0';
  }

  @override
  String collectionMoveSuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Przeniesiono $count elementów',
      few: 'Przeniesiono $count elementy',
      one: 'Przeniesiono 1 element',
    );
    return '$_temp0';
  }

  @override
  String collectionRenameSuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Zmieniono nazwę $count elementom',
      one: 'Zmieniono nazwę 1 elementowi',
    );
    return '$_temp0';
  }

  @override
  String collectionEditSuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Wyedytowano $count elementów',
      few: 'Wyedytowano $count elementy',
      one: 'Wyedytowano 1 element',
    );
    return '$_temp0';
  }

  @override
  String get collectionEmptyFavourites => 'Brak ulubionych';

  @override
  String get collectionEmptyVideos => 'Brak wideo';

  @override
  String get collectionEmptyImages => 'Brak obrazów';

  @override
  String get collectionEmptyGrantAccessButtonLabel => 'Przyznaj dostęp';

  @override
  String get collectionSelectSectionTooltip => 'Zaznacz sekcję';

  @override
  String get collectionDeselectSectionTooltip => 'Odznacz sekcję';

  @override
  String get drawerAboutButton => 'O programie';

  @override
  String get drawerSettingsButton => 'Ustawienia';

  @override
  String get drawerCollectionAll => 'Wszystkie kolekcje';

  @override
  String get drawerCollectionFavourites => 'Ulubione';

  @override
  String get drawerCollectionImages => 'Obrazy';

  @override
  String get drawerCollectionVideos => 'Wideo';

  @override
  String get drawerCollectionAnimated => 'Animacje';

  @override
  String get drawerCollectionMotionPhotos => 'Animowane zdjęcia';

  @override
  String get drawerCollectionPanoramas => 'Zdjęcia panoramiczne';

  @override
  String get drawerCollectionRaws => 'Nieprzetworzone zdjęcia';

  @override
  String get drawerCollectionSphericalVideos => 'Wideo 360°';

  @override
  String get drawerAlbumPage => 'Albumy';

  @override
  String get drawerCountryPage => 'Kraje';

  @override
  String get drawerPlacePage => 'Miejsca';

  @override
  String get drawerTagPage => 'Znaczniki';

  @override
  String get sortByDate => 'Według daty';

  @override
  String get sortByName => 'Według nazwy';

  @override
  String get sortByItemCount => 'Według liczby elementów';

  @override
  String get sortBySize => 'Według rozmiaru';

  @override
  String get sortByAlbumFileName => 'Według albumu i nazwy pliku';

  @override
  String get sortByRating => 'Według oceny';

  @override
  String get sortByDuration => 'Według czasu trwania';

  @override
  String get sortByPath => 'By path';

  @override
  String get sortOrderNewestFirst => 'Najpierw najnowsze';

  @override
  String get sortOrderOldestFirst => 'Najpierw najstarsze';

  @override
  String get sortOrderAtoZ => 'Od A do Z';

  @override
  String get sortOrderZtoA => 'Od Z do A';

  @override
  String get sortOrderHighestFirst => 'Najpierw najwyższe';

  @override
  String get sortOrderLowestFirst => 'Najpierw najniższe';

  @override
  String get sortOrderLargestFirst => 'Najpierw największe';

  @override
  String get sortOrderSmallestFirst => 'Najpierw najmniejsze';

  @override
  String get sortOrderShortestFirst => 'Najkrótsze najpierw';

  @override
  String get sortOrderLongestFirst => 'Najdłuższe najpierw';

  @override
  String get albumGroupTier => 'Według poziomu';

  @override
  String get albumGroupType => 'Według typu';

  @override
  String get albumGroupVolume => 'Według pojemności magazynu';

  @override
  String get albumGroupNone => 'Nie grupuj';

  @override
  String get albumMimeTypeMixed => 'Mieszane';

  @override
  String get albumPickPageTitleCopy => 'Skopiuj do albumu';

  @override
  String get albumPickPageTitleExport => 'Wyeksportuj do albumu';

  @override
  String get albumPickPageTitleMove => 'Przenieś do albumu';

  @override
  String get albumPickPageTitlePick => 'Wybierz album';

  @override
  String get albumCamera => 'Kamera';

  @override
  String get albumDownload => 'Pobrane';

  @override
  String get albumScreenshots => 'Zrzuty ekranu';

  @override
  String get albumScreenRecordings => 'Nagrania ekranu';

  @override
  String get albumVideoCaptures => 'Przechwycone wideo';

  @override
  String get albumPageTitle => 'Albumy';

  @override
  String get albumEmpty => 'Brak albumów';

  @override
  String get createAlbumButtonLabel => 'UTWÓRZ';

  @override
  String get newFilterBanner => 'nowy';

  @override
  String get countryPageTitle => 'Kraje';

  @override
  String get countryEmpty => 'Brak krajów';

  @override
  String get statePageTitle => 'Stany';

  @override
  String get stateEmpty => 'Brak stanów';

  @override
  String get placePageTitle => 'Miejsca';

  @override
  String get placeEmpty => 'Brak miejsc';

  @override
  String get tagPageTitle => 'Znaczniki';

  @override
  String get tagEmpty => 'Brak znaczników';

  @override
  String get binPageTitle => 'Kosz';

  @override
  String get explorerPageTitle => 'Przeglądarka';

  @override
  String get explorerActionSelectStorageVolume => 'Wybierz pamięć';

  @override
  String get selectStorageVolumeDialogTitle => 'Wybierz pamięć';

  @override
  String get searchCollectionFieldHint => 'Wyszukaj kolekcję';

  @override
  String get searchRecentSectionTitle => 'Ostatni';

  @override
  String get searchDateSectionTitle => 'Data';

  @override
  String get searchFormatSectionTitle => 'Formats';

  @override
  String get searchAlbumsSectionTitle => 'Albumy';

  @override
  String get searchCountriesSectionTitle => 'Kraje';

  @override
  String get searchStatesSectionTitle => 'Stany';

  @override
  String get searchPlacesSectionTitle => 'Miejsca';

  @override
  String get searchTagsSectionTitle => 'Znaczniki';

  @override
  String get searchRatingSectionTitle => 'Oceny';

  @override
  String get searchMetadataSectionTitle => 'Metadane';

  @override
  String get settingsPageTitle => 'Ustawienia';

  @override
  String get settingsSystemDefault => 'Ustawienie systemu';

  @override
  String get settingsDefault => 'Domyślne';

  @override
  String get settingsDisabled => 'Wyłączono';

  @override
  String get settingsAskEverytime => 'Zawsze pytaj';

  @override
  String get settingsModificationWarningDialogMessage => 'Pozostałe ustawienia zostaną zmodyfikowane.';

  @override
  String get settingsSearchFieldLabel => 'Wyszukaj ustawienia';

  @override
  String get settingsSearchEmpty => 'Brak pasującego ustawienia';

  @override
  String get settingsActionExport => 'Wyeksportuj';

  @override
  String get settingsActionExportDialogTitle => 'Wyeksportuj';

  @override
  String get settingsActionImport => 'Zaimportuj';

  @override
  String get settingsActionImportDialogTitle => 'Zaimportuj';

  @override
  String get appExportCovers => 'Okładki';

  @override
  String get appExportDynamicAlbums => 'Dynamiczne albumy';

  @override
  String get appExportFavourites => 'Ulubione';

  @override
  String get appExportSettings => 'Ustawienia';

  @override
  String get settingsNavigationSectionTitle => 'Nawigowanie';

  @override
  String get settingsHomeTile => 'Strona główna';

  @override
  String get settingsHomeDialogTitle => 'Strona główna';

  @override
  String get setHomeCustom => 'Własny';

  @override
  String get settingsShowBottomNavigationBar => 'Pokaż dolny pasek nawigacyjny';

  @override
  String get settingsKeepScreenOnTile => 'Pozostaw ekran włączony';

  @override
  String get settingsKeepScreenOnDialogTitle => 'Pozostaw ekran włączony';

  @override
  String get settingsDoubleBackExit => 'Dotknij dwa razy „wstecz”, aby wyjść';

  @override
  String get settingsConfirmationTile => 'Działania do potwierdzenia';

  @override
  String get settingsConfirmationDialogTitle => 'Działania do potwierdzenia';

  @override
  String get settingsConfirmationBeforeDeleteItems => 'Zapytaj, zanim usuniesz elementy na zawsze';

  @override
  String get settingsConfirmationBeforeMoveToBinItems => 'Zapytaj, zanim przeniesiesz elementy do kosza';

  @override
  String get settingsConfirmationBeforeMoveUndatedItems => 'Zapytaj, zanim przeniesiesz niedatowane elementy';

  @override
  String get settingsConfirmationAfterMoveToBinItems => 'Pokaż komunikat po przeniesieniu elementów do Kosza';

  @override
  String get settingsConfirmationVaultDataLoss => 'Pokaż ostrzeżenie o utracie danych skarbca';

  @override
  String get settingsNavigationDrawerTile => 'Menu nawigacyjne';

  @override
  String get settingsNavigationDrawerEditorPageTitle => 'Menu nawigacyjne';

  @override
  String get settingsNavigationDrawerBanner => 'Dotknij i przytrzymaj, aby przenieść i zmienić kolejność pozycji menu.';

  @override
  String get settingsNavigationDrawerTabTypes => 'Kategorie';

  @override
  String get settingsNavigationDrawerTabAlbums => 'Albumy';

  @override
  String get settingsNavigationDrawerTabPages => 'Strony';

  @override
  String get settingsNavigationDrawerAddAlbum => 'Dodaj album';

  @override
  String get settingsThumbnailSectionTitle => 'Miniatury';

  @override
  String get settingsThumbnailOverlayTile => 'Nakładka';

  @override
  String get settingsThumbnailOverlayPageTitle => 'Nakładka';

  @override
  String get settingsThumbnailShowHdrIcon => 'Pokaż ikonę HDR';

  @override
  String get settingsThumbnailShowFavouriteIcon => 'Pokaż ikonę ulubionych';

  @override
  String get settingsThumbnailShowTagIcon => 'Pokaż ikonę znacznika';

  @override
  String get settingsThumbnailShowLocationIcon => 'Pokaż ikonę położenia';

  @override
  String get settingsThumbnailShowMotionPhotoIcon => 'Pokaż ikonę zdjęcia ruchomego';

  @override
  String get settingsThumbnailShowRating => 'Pokaż ocenę';

  @override
  String get settingsThumbnailShowRawIcon => 'Pokaż ikonę RAW';

  @override
  String get settingsThumbnailShowVideoDuration => 'Pokaż czas trwania wideo';

  @override
  String get settingsCollectionQuickActionsTile => 'Szybkie działania';

  @override
  String get settingsCollectionQuickActionEditorPageTitle => 'Szybkie działania';

  @override
  String get settingsCollectionQuickActionTabBrowsing => 'Przeglądanie';

  @override
  String get settingsCollectionQuickActionTabSelecting => 'Wybieranie';

  @override
  String get settingsCollectionBrowsingQuickActionEditorBanner => 'Dotknij i przytrzymaj, aby przenieść przyciski i wybrać akcje wyświetlane podczas przeglądania elementów.';

  @override
  String get settingsCollectionSelectionQuickActionEditorBanner => 'Dotknij i przytrzymaj, aby przesuwać przyciski i wybrać akcje, które mają być wyświetlane podczas wybierania elementów.';

  @override
  String get settingsCollectionBurstPatternsTile => 'Wzory wybuchowe';

  @override
  String get settingsCollectionBurstPatternsNone => 'Brak';

  @override
  String get settingsViewerSectionTitle => 'Przeglądarka';

  @override
  String get settingsViewerGestureSideTapNext => 'Dotknij krawędzi ekranu, aby wyświetlić poprzedni / następny element';

  @override
  String get settingsViewerUseCutout => 'Użyj obszaru wycięcia';

  @override
  String get settingsViewerMaximumBrightness => 'Jasność maksymalna';

  @override
  String get settingsMotionPhotoAutoPlay => 'Automatyczne odtwarzanie ruchomych zdjęć';

  @override
  String get settingsImageBackground => 'Tło obrazu';

  @override
  String get settingsViewerQuickActionsTile => 'Szybkie działania';

  @override
  String get settingsViewerQuickActionEditorPageTitle => 'Szybkie działania';

  @override
  String get settingsViewerQuickActionEditorBanner => 'Dotknij i przytrzymaj, aby przesunąć przyciski i wybrać czynności, które mają być wyświetlane w przeglądarce.';

  @override
  String get settingsViewerQuickActionEditorDisplayedButtonsSectionTitle => 'Wyświetlane przyciski';

  @override
  String get settingsViewerQuickActionEditorAvailableButtonsSectionTitle => 'Dostępne przyciski';

  @override
  String get settingsViewerQuickActionEmpty => 'Brak przycisków';

  @override
  String get settingsViewerOverlayTile => 'Nakładka';

  @override
  String get settingsViewerOverlayPageTitle => 'Nakładka';

  @override
  String get settingsViewerShowOverlayOnOpening => 'Pokaz w momencie otwarcia';

  @override
  String get settingsViewerShowHistogram => 'Pokaż histogram';

  @override
  String get settingsViewerShowMinimap => 'Pokaż minimapę';

  @override
  String get settingsViewerShowInformation => 'Pokaż informacje';

  @override
  String get settingsViewerShowInformationSubtitle => 'Pokaż tytuł, datę, położenie itp.';

  @override
  String get settingsViewerShowRatingTags => 'Pokaż ocenę i znaczniki';

  @override
  String get settingsViewerShowShootingDetails => 'Pokaż szczegóły fotografowania';

  @override
  String get settingsViewerShowDescription => 'Pokaż opis';

  @override
  String get settingsViewerShowOverlayThumbnails => 'Pokaż miniaturki';

  @override
  String get settingsViewerEnableOverlayBlurEffect => 'Efekt rozmycia';

  @override
  String get settingsViewerSlideshowTile => 'Pokaz slajdów';

  @override
  String get settingsViewerSlideshowPageTitle => 'Pokaz slajdów';

  @override
  String get settingsSlideshowRepeat => 'Powtarzaj';

  @override
  String get settingsSlideshowShuffle => 'Mieszaj';

  @override
  String get settingsSlideshowFillScreen => 'Wypełnij ekran';

  @override
  String get settingsSlideshowAnimatedZoomEffect => 'Animowany efekt powiększenia';

  @override
  String get settingsSlideshowTransitionTile => 'Przejście';

  @override
  String get settingsSlideshowIntervalTile => 'Interwał';

  @override
  String get settingsSlideshowVideoPlaybackTile => 'Odtwarzanie wideo';

  @override
  String get settingsSlideshowVideoPlaybackDialogTitle => 'Odtwarzanie wideo';

  @override
  String get settingsVideoPageTitle => 'Ustawienia wideo';

  @override
  String get settingsVideoSectionTitle => 'Wideo';

  @override
  String get settingsVideoShowVideos => 'Pokaż wideo';

  @override
  String get settingsVideoPlaybackTile => 'Odtwarzanie';

  @override
  String get settingsVideoPlaybackPageTitle => 'Odtwarzanie';

  @override
  String get settingsVideoEnableHardwareAcceleration => 'Przyspieszenie sprzętowe';

  @override
  String get settingsVideoAutoPlay => 'Odtwarzaj automatycznie';

  @override
  String get settingsVideoLoopModeTile => 'Tryb pętli';

  @override
  String get settingsVideoLoopModeDialogTitle => 'Tryb pętli';

  @override
  String get settingsVideoResumptionModeTile => 'Wznów odtwarzanie';

  @override
  String get settingsVideoResumptionModeDialogTitle => 'Wznów odtwarzanie';

  @override
  String get settingsVideoBackgroundMode => 'Tryb tła';

  @override
  String get settingsVideoBackgroundModeDialogTitle => 'Tryb tła';

  @override
  String get settingsVideoControlsTile => 'Sterowanie';

  @override
  String get settingsVideoControlsPageTitle => 'Sterowanie';

  @override
  String get settingsVideoButtonsTile => 'Przyciski';

  @override
  String get settingsVideoGestureDoubleTapTogglePlay => 'Dotknij dwukrotnie, aby odtworzyć/wstrzymać';

  @override
  String get settingsVideoGestureSideDoubleTapSeek => 'Dotknij dwukrotnie krawędzi ekranu, aby przeszukać do tyłu / do przodu';

  @override
  String get settingsVideoGestureVerticalDragBrightnessVolume => 'Przesuń palcem w górę lub w dół, aby dostosować jasność/głośność';

  @override
  String get settingsSubtitleThemeTile => 'Napisy';

  @override
  String get settingsSubtitleThemePageTitle => 'Napisy';

  @override
  String get settingsSubtitleThemeSample => 'Przykładowy napis.';

  @override
  String get settingsSubtitleThemeTextAlignmentTile => 'Dopasowanie tekstu';

  @override
  String get settingsSubtitleThemeTextAlignmentDialogTitle => 'Dopasowanie tekstu';

  @override
  String get settingsSubtitleThemeTextPositionTile => 'Pozycja tekstu';

  @override
  String get settingsSubtitleThemeTextPositionDialogTitle => 'Pozycja tekstu';

  @override
  String get settingsSubtitleThemeTextSize => 'Rozmiar tekstu';

  @override
  String get settingsSubtitleThemeShowOutline => 'Pokaż kontur i cień';

  @override
  String get settingsSubtitleThemeTextColor => 'Kolor tekstu';

  @override
  String get settingsSubtitleThemeTextOpacity => 'Krycie tekstu';

  @override
  String get settingsSubtitleThemeBackgroundColor => 'Kolor tła';

  @override
  String get settingsSubtitleThemeBackgroundOpacity => 'Krycie tła';

  @override
  String get settingsSubtitleThemeTextAlignmentLeft => 'Lewo';

  @override
  String get settingsSubtitleThemeTextAlignmentCenter => 'Środek';

  @override
  String get settingsSubtitleThemeTextAlignmentRight => 'Prawo';

  @override
  String get settingsPrivacySectionTitle => 'Prywatność';

  @override
  String get settingsAllowInstalledAppAccess => 'Zezwól na dostęp do spisu aplikacji';

  @override
  String get settingsAllowInstalledAppAccessSubtitle => 'Używane do poprawy wyświetlania albumu';

  @override
  String get settingsAllowErrorReporting => 'Zezwól na anonimowe zgłaszanie błędów';

  @override
  String get settingsSaveSearchHistory => 'Zapisz historię wyszukiwania';

  @override
  String get settingsEnableBin => 'Używaj kosza';

  @override
  String get settingsEnableBinSubtitle => 'Zachowaj usunięte elementy przez 30 dni';

  @override
  String get settingsDisablingBinWarningDialogMessage => 'Elementy znajdujące się w koszu zostaną usunięte na zawsze.';

  @override
  String get settingsAllowMediaManagement => 'Zezwalaj na zarządzanie multimediami';

  @override
  String get settingsHiddenItemsTile => 'Ukryte elementy';

  @override
  String get settingsHiddenItemsPageTitle => 'Ukryte elementy';

  @override
  String get settingsHiddenFiltersBanner => 'Zdjęcia i wideo pasujące do ukrytych filtrów nie pojawią się w twojej kolekcji.';

  @override
  String get settingsHiddenFiltersEmpty => 'Brak ukrytych filtrów';

  @override
  String get settingsStorageAccessTile => 'Dostęp do pamięci masowej';

  @override
  String get settingsStorageAccessPageTitle => 'Dostęp do pamięci masowej';

  @override
  String get settingsStorageAccessBanner => 'Niektóre katalogi wymagają jawnego udzielenia dostępu, aby modyfikować znajdujące się w nich pliki. Możesz przejrzeć tutaj katalogi, do których wcześniej udzielono dostępu.';

  @override
  String get settingsStorageAccessEmpty => 'Brak przyznanych uprawnień';

  @override
  String get settingsStorageAccessRevokeTooltip => 'Odwołaj';

  @override
  String get settingsAccessibilitySectionTitle => 'Dostępność';

  @override
  String get settingsRemoveAnimationsTile => 'Usuń animacje';

  @override
  String get settingsRemoveAnimationsDialogTitle => 'Usuń animacje';

  @override
  String get settingsTimeToTakeActionTile => 'Czas na podjęcie działania';

  @override
  String get settingsAccessibilityShowPinchGestureAlternatives => 'Pokaż alternatywy gestów wielodotykowych';

  @override
  String get settingsDisplaySectionTitle => 'Wyświetlanie';

  @override
  String get settingsThemeBrightnessTile => 'Motyw';

  @override
  String get settingsThemeBrightnessDialogTitle => 'Motyw';

  @override
  String get settingsThemeColorHighlights => 'Podkreślenia kolorów';

  @override
  String get settingsThemeEnableDynamicColor => 'Kolor dynamiczny';

  @override
  String get settingsDisplayRefreshRateModeTile => 'Częstotliwość odświeżania ekranu';

  @override
  String get settingsDisplayRefreshRateModeDialogTitle => 'Częstotliwość odświeżania';

  @override
  String get settingsDisplayUseTvInterface => 'Interfejs Android TV';

  @override
  String get settingsLanguageSectionTitle => 'Język i formaty';

  @override
  String get settingsLanguageTile => 'Język';

  @override
  String get settingsLanguagePageTitle => 'Język';

  @override
  String get settingsCoordinateFormatTile => 'Format współrzędnych';

  @override
  String get settingsCoordinateFormatDialogTitle => 'Format współrzędnych';

  @override
  String get settingsUnitSystemTile => 'Jednostki';

  @override
  String get settingsUnitSystemDialogTitle => 'Jednostki';

  @override
  String get settingsForceWesternArabicNumeralsTile => 'Wymuszaj cyfry arabskie';

  @override
  String get settingsScreenSaverPageTitle => 'Wygaszacz ekranu';

  @override
  String get settingsWidgetPageTitle => 'Ramka zdjęcia';

  @override
  String get settingsWidgetShowOutline => 'Zarys';

  @override
  String get settingsWidgetOpenPage => 'Po dotknięciu widżetu';

  @override
  String get settingsWidgetDisplayedItem => 'Wyświetlany element';

  @override
  String get settingsCollectionTile => 'Kolekcja';

  @override
  String get statsPageTitle => 'Statystyki';

  @override
  String statsWithGps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementów z położeniem',
      few: '$count elementy z położeniem',
      one: '1 element z położeniem',
    );
    return '$_temp0';
  }

  @override
  String get statsTopCountriesSectionTitle => 'Najlepsze kraje';

  @override
  String get statsTopStatesSectionTitle => 'Najpopularniejsze stany';

  @override
  String get statsTopPlacesSectionTitle => 'Najlepsze miejsca';

  @override
  String get statsTopTagsSectionTitle => 'Najlepsze znaczniki';

  @override
  String get statsTopAlbumsSectionTitle => 'Najlepsze albumy';

  @override
  String get viewerOpenPanoramaButtonLabel => 'OTWÓRZ PANORAMĘ';

  @override
  String get viewerSetWallpaperButtonLabel => 'USTAW TAPETĘ';

  @override
  String get viewerErrorUnknown => 'Ups!';

  @override
  String get viewerErrorDoesNotExist => 'Plik już nie istnieje.';

  @override
  String get viewerInfoPageTitle => 'Informacje';

  @override
  String get viewerInfoBackToViewerTooltip => 'Wróć do przeglądarki';

  @override
  String get viewerInfoUnknown => 'Nieznany';

  @override
  String get viewerInfoLabelDescription => 'Opis';

  @override
  String get viewerInfoLabelTitle => 'Tytuł';

  @override
  String get viewerInfoLabelDate => 'Data';

  @override
  String get viewerInfoLabelResolution => 'Rozdzielczość';

  @override
  String get viewerInfoLabelSize => 'Rozmiar';

  @override
  String get viewerInfoLabelUri => 'URI';

  @override
  String get viewerInfoLabelPath => 'Ścieżka';

  @override
  String get viewerInfoLabelDuration => 'Czas trwania';

  @override
  String get viewerInfoLabelOwner => 'Właściciel';

  @override
  String get viewerInfoLabelCoordinates => 'Współrzędne';

  @override
  String get viewerInfoLabelAddress => 'Adres';

  @override
  String get mapStyleDialogTitle => 'Styl mapy';

  @override
  String get mapStyleTooltip => 'Wybierz styl mapy';

  @override
  String get mapZoomInTooltip => 'Powiększ';

  @override
  String get mapZoomOutTooltip => 'Pomniejsz';

  @override
  String get mapPointNorthUpTooltip => 'Północ u góry';

  @override
  String get mapAttributionOsmData => 'Dane mapy © [OpenStreetMap](https://www.openstreetmap.org/copyright) współtwórcy';

  @override
  String get mapAttributionOsmLiberty => 'Płytki od [OpenMapTiles](https://www.openmaptiles.org/), [CC BY](http://creativecommons.org/licenses/by/4.0) • Obsługiwane przez [OSM Americana](https://tile.ourmap.us)';

  @override
  String get mapAttributionOpenTopoMap => '[SRTM](https://www.earthdata.nasa.gov/sensors/srtm) | Kafelki od [OpenTopoMap](https://opentopomap.org/), [CC BY-SA](https://creativecommons.org/licenses/by-sa/3.0/)';

  @override
  String get mapAttributionOsmHot => 'Kafelki od [HOT](https://www.hotosm.org/) • Obsługiwany przez: [OSM France](https://openstreetmap.fr/)';

  @override
  String get mapAttributionStamen => 'Kafelki od [Stamen Design](https://stamen.com), [CC BY 3.0](https://creativecommons.org/licenses/by/3.0)';

  @override
  String get openMapPageTooltip => 'Wyświetl na mapie';

  @override
  String get mapEmptyRegion => 'Brak obrazów w tym regionie';

  @override
  String get viewerInfoOpenEmbeddedFailureFeedback => 'Nie udało się wyodrębnić osadzonych danych';

  @override
  String get viewerInfoOpenLinkText => 'Otwórz';

  @override
  String get viewerInfoViewXmlLinkText => 'Zobacz XML';

  @override
  String get viewerInfoSearchFieldLabel => 'Wyszukaj metadane';

  @override
  String get viewerInfoSearchEmpty => 'Brak pasujących kluczy';

  @override
  String get viewerInfoSearchSuggestionDate => 'Data i godzina';

  @override
  String get viewerInfoSearchSuggestionDescription => 'Opis';

  @override
  String get viewerInfoSearchSuggestionDimensions => 'Wymiary';

  @override
  String get viewerInfoSearchSuggestionResolution => 'Rozdzielczość';

  @override
  String get viewerInfoSearchSuggestionRights => 'Prawa';

  @override
  String get wallpaperUseScrollEffect => 'Używaj efektu przewijania na ekranie głównym';

  @override
  String get tagEditorPageTitle => 'Edytuj znaczniki';

  @override
  String get tagEditorPageNewTagFieldLabel => 'Nowy znacznik';

  @override
  String get tagEditorPageAddTagTooltip => 'Dodaj znacznik';

  @override
  String get tagEditorSectionRecent => 'Ostatnie';

  @override
  String get tagEditorSectionPlaceholders => 'Symbole zastępcze';

  @override
  String get tagEditorDiscardDialogMessage => 'Czy chcesz odrzucić zamiany?';

  @override
  String get tagPlaceholderCountry => 'Kraj';

  @override
  String get tagPlaceholderState => 'Stan';

  @override
  String get tagPlaceholderPlace => 'Miejsce';

  @override
  String get panoramaEnableSensorControl => 'Włącz sterowanie czujnikiem';

  @override
  String get panoramaDisableSensorControl => 'Wyłącz sterowanie czujnikiem';

  @override
  String get sourceViewerPageTitle => 'Źródło';

  @override
  String get filePickerShowHiddenFiles => 'Pokaż ukryte pliki';

  @override
  String get filePickerDoNotShowHiddenFiles => 'Nie pokazuj ukrytych plików';

  @override
  String get filePickerOpenFrom => 'Otwórz z';

  @override
  String get filePickerNoItems => 'Brak elementów';

  @override
  String get filePickerUseThisFolder => 'Użyj tego katalogu';
}
