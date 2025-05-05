// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bulgarian (`bg`).
class AppLocalizationsBg extends AppLocalizations {
  AppLocalizationsBg([String locale = 'bg']) : super(locale);

  @override
  String get appName => 'Aves';

  @override
  String get welcomeMessage => 'Добре дошли в Aves';

  @override
  String get welcomeOptional => 'Опционално';

  @override
  String get welcomeTermsToggle => 'Съгласявам се с правилата и условията';

  @override
  String itemCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString елемента',
      few: '$countString елемента',
      one: '$countString елемент',
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
      other: '$countString колони',
      one: '$countString колона',
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
      other: '$countString секунди',
      few: '$countString секунди',
      one: '$countString секунда',
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
      other: '$countString минути',
      few: '$countString минути',
      one: '$countString минута',
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
      other: '$countString дни',
      few: '$countString дни',
      one: '$countString ден',
    );
    return '$_temp0';
  }

  @override
  String focalLength(String length) {
    return '$length мм';
  }

  @override
  String get applyButtonLabel => 'ПРИЕМАМ';

  @override
  String get createButtonLabel => 'CREATE';

  @override
  String get deleteButtonLabel => 'ИЗТРИЙ';

  @override
  String get nextButtonLabel => 'СЛЕДВАЩ';

  @override
  String get showButtonLabel => 'ПОКАЗВАНЕ';

  @override
  String get hideButtonLabel => 'СКРИЙ';

  @override
  String get continueButtonLabel => 'ПРОДЪЛЖИ';

  @override
  String get saveCopyButtonLabel => 'ЗАПАЗВАНЕ НА КОПИЕ';

  @override
  String get applyTooltip => 'Приеми';

  @override
  String get cancelTooltip => 'Отмяна';

  @override
  String get changeTooltip => 'Промени';

  @override
  String get clearTooltip => 'Изчисти';

  @override
  String get previousTooltip => 'Предишен';

  @override
  String get nextTooltip => 'Следващ';

  @override
  String get showTooltip => 'Покажи';

  @override
  String get hideTooltip => 'Скрий';

  @override
  String get actionRemove => 'Премахване';

  @override
  String get resetTooltip => 'Нулиране';

  @override
  String get saveTooltip => 'Запишете';

  @override
  String get stopTooltip => 'Стоп';

  @override
  String get pickTooltip => 'Изберете';

  @override
  String get doubleBackExitMessage => 'Натиснете отново „Назад“, за да излезете.';

  @override
  String get doNotAskAgain => 'Не питай отново';

  @override
  String get sourceStateLoading => 'Зареждане';

  @override
  String get sourceStateCataloguing => 'Каталогизация';

  @override
  String get sourceStateLocatingCountries => 'Местоположение на държави';

  @override
  String get sourceStateLocatingPlaces => 'Местоположение на места';

  @override
  String get chipActionDelete => 'Изтрий';

  @override
  String get chipActionRemove => 'Премахване';

  @override
  String get chipActionShowCollection => 'Показване в колекцията';

  @override
  String get chipActionGoToAlbumPage => 'Покажи в албуми';

  @override
  String get chipActionGoToCountryPage => 'Показване в държави';

  @override
  String get chipActionGoToPlacePage => 'Покажи в места';

  @override
  String get chipActionGoToTagPage => 'Показване в тагове';

  @override
  String get chipActionGoToExplorerPage => 'Показване в Експлорър';

  @override
  String get chipActionDecompose => 'Раздели';

  @override
  String get chipActionFilterOut => 'Изключи';

  @override
  String get chipActionFilterIn => 'Включи';

  @override
  String get chipActionHide => 'Скрий';

  @override
  String get chipActionLock => 'Заключи';

  @override
  String get chipActionPin => 'Закачете отгоре';

  @override
  String get chipActionUnpin => 'Откачи от закачени';

  @override
  String get chipActionGroup => 'Group';

  @override
  String get chipActionRename => 'Преименувайте';

  @override
  String get chipActionSetCover => 'Задайте тапет';

  @override
  String get chipActionShowCountryStates => 'Показване на държава';

  @override
  String get chipActionCreateGroup => 'Create group';

  @override
  String get chipActionCreateAlbum => 'Създайте албум';

  @override
  String get chipActionCreateVault => 'Създаване на трезор';

  @override
  String get chipActionConfigureVault => 'Настройване на трезор';

  @override
  String get entryActionCopyToClipboard => 'Копирайте в клипборд';

  @override
  String get entryActionDelete => 'Изтриване';

  @override
  String get entryActionConvert => 'Конвертиране';

  @override
  String get entryActionExport => 'Експортиране';

  @override
  String get entryActionInfo => 'Информация';

  @override
  String get entryActionRename => 'Преименуване';

  @override
  String get entryActionRestore => 'Възстановяване';

  @override
  String get entryActionRotateCCW => 'Завъртете обратно на часовниковата стрелка';

  @override
  String get entryActionRotateCW => 'Завъртете по посока на часовниковата стрелка';

  @override
  String get entryActionFlip => 'Хоризонтално превъртане';

  @override
  String get entryActionPrint => 'Печат';

  @override
  String get entryActionShare => 'Споделяне';

  @override
  String get entryActionShareImageOnly => 'Споделете само изображение';

  @override
  String get entryActionShareVideoOnly => 'Сооделяне само на видео';

  @override
  String get entryActionViewSource => 'Вижте източника';

  @override
  String get entryActionShowGeoTiffOnMap => 'Покажи на картата';

  @override
  String get entryActionConvertMotionPhotoToStillImage => 'Конвертиране в статично изображение';

  @override
  String get entryActionViewMotionPhotoVideo => 'Отвори видео';

  @override
  String get entryActionEdit => 'Редактиране';

  @override
  String get entryActionOpen => 'Отвори с';

  @override
  String get entryActionSetAs => 'Задай като';

  @override
  String get entryActionCast => 'Излъчване';

  @override
  String get entryActionOpenMap => 'Покажи в приложение за карти';

  @override
  String get entryActionRotateScreen => 'Завъртане на екрана';

  @override
  String get entryActionAddFavourite => 'Добави в любими';

  @override
  String get entryActionRemoveFavourite => 'Премахни от любими';

  @override
  String get videoActionCaptureFrame => 'Кадър за заснемане';

  @override
  String get videoActionMute => 'Изключи звук';

  @override
  String get videoActionUnmute => 'Включи звук';

  @override
  String get videoActionPause => 'Пауза';

  @override
  String get videoActionPlay => 'Възпроизведи';

  @override
  String get videoActionReplay10 => 'Превъртане 10 секунди назад';

  @override
  String get videoActionSkip10 => 'Превъртане 10 секунди напред';

  @override
  String get videoActionShowPreviousFrame => 'Покажи предишния кадър';

  @override
  String get videoActionShowNextFrame => 'Покажи следващия кадър';

  @override
  String get videoActionSelectStreams => 'Изберете песни';

  @override
  String get videoActionSetSpeed => 'Скорост на възпроизвеждане';

  @override
  String get videoActionABRepeat => 'Повторете от А до Б';

  @override
  String get videoRepeatActionSetStart => 'Задайте начало';

  @override
  String get videoRepeatActionSetEnd => 'Задайте край';

  @override
  String get viewerActionSettings => 'Настройки';

  @override
  String get viewerActionLock => 'Блокирай визуализатора';

  @override
  String get viewerActionUnlock => 'Отблокирай визуализатора';

  @override
  String get slideshowActionResume => 'Продължи';

  @override
  String get slideshowActionShowInCollection => 'Покажи в Колекции';

  @override
  String get entryInfoActionEditDate => 'Променете дата и час';

  @override
  String get entryInfoActionEditLocation => 'Променете местоположение';

  @override
  String get entryInfoActionEditTitleDescription => 'Променете заглавието и описанието';

  @override
  String get entryInfoActionEditRating => 'Променяте рейтинга';

  @override
  String get entryInfoActionEditTags => 'Променяне на тагове';

  @override
  String get entryInfoActionRemoveMetadata => 'Изтриване на метаданни';

  @override
  String get entryInfoActionExportMetadata => 'Експортиране на метаданни';

  @override
  String get entryInfoActionRemoveLocation => 'Премахване на местоположение';

  @override
  String get editorActionTransform => 'Трансформиране';

  @override
  String get editorTransformCrop => 'Изрязване';

  @override
  String get editorTransformRotate => 'Завъртане';

  @override
  String get cropAspectRatioFree => 'Свободни';

  @override
  String get cropAspectRatioOriginal => 'Оригинал';

  @override
  String get cropAspectRatioSquare => 'Квадратно';

  @override
  String get filterAspectRatioLandscapeLabel => 'Хоризонтално';

  @override
  String get filterAspectRatioPortraitLabel => 'Вертикално';

  @override
  String get filterBinLabel => 'Кошче';

  @override
  String get filterFavouriteLabel => 'Любими';

  @override
  String get filterNoDateLabel => 'Без дата';

  @override
  String get filterNoAddressLabel => 'Без адрес';

  @override
  String get filterLocatedLabel => 'С местоположение';

  @override
  String get filterNoLocationLabel => 'Без местоположение';

  @override
  String get filterNoRatingLabel => 'Без рейтинг';

  @override
  String get filterTaggedLabel => 'С тагове';

  @override
  String get filterNoTagLabel => 'Без тагове';

  @override
  String get filterNoTitleLabel => 'Наименувани';

  @override
  String get filterOnThisDayLabel => 'Днес';

  @override
  String get filterRecentlyAddedLabel => 'Наскоро добавени';

  @override
  String get filterRatingRejectedLabel => 'Отхвърлени';

  @override
  String get filterTypeAnimatedLabel => 'Анимирани';

  @override
  String get filterTypeMotionPhotoLabel => 'Снимка с движение';

  @override
  String get filterTypePanoramaLabel => 'Панорама';

  @override
  String get filterTypeRawLabel => 'RAW';

  @override
  String get filterTypeSphericalVideoLabel => '360° Видео';

  @override
  String get filterTypeGeotiffLabel => 'GeoTIFF';

  @override
  String get filterMimeImageLabel => 'Изображение';

  @override
  String get filterMimeVideoLabel => 'Видео';

  @override
  String get accessibilityAnimationsRemove => 'Предотвратяване ефектите на екрана';

  @override
  String get accessibilityAnimationsKeep => 'Запазване на екранните ефекти';

  @override
  String get albumTierNew => 'Нови';

  @override
  String get albumTierPinned => 'Закачени';

  @override
  String get albumTierGroups => 'Groups';

  @override
  String get albumTierSpecial => 'Стандартни';

  @override
  String get albumTierApps => 'Приложения';

  @override
  String get albumTierVaults => 'Трезори';

  @override
  String get albumTierDynamic => 'Динамични';

  @override
  String get albumTierRegular => 'Други';

  @override
  String get coordinateFormatDms => 'Градуси, минути и секунди';

  @override
  String get coordinateFormatDdm => 'Градуси, десетични минути';

  @override
  String get coordinateFormatDecimal => 'Десетични градуси';

  @override
  String coordinateDms(String coordinate, String direction) {
    return '$coordinate $direction';
  }

  @override
  String get coordinateDmsNorth => 'Север';

  @override
  String get coordinateDmsSouth => 'Юг';

  @override
  String get coordinateDmsEast => 'Изток';

  @override
  String get coordinateDmsWest => 'Запад';

  @override
  String get displayRefreshRatePreferHighest => 'Висока честота';

  @override
  String get displayRefreshRatePreferLowest => 'Ниска честота';

  @override
  String get keepScreenOnNever => 'Никога';

  @override
  String get keepScreenOnVideoPlayback => 'По време на възпроизвеждане на видео';

  @override
  String get keepScreenOnViewerOnly => 'Само във визуализатора';

  @override
  String get keepScreenOnAlways => 'Винаги';

  @override
  String get lengthUnitPixel => 'Пиксели';

  @override
  String get lengthUnitPercent => '%';

  @override
  String get mapStyleGoogleNormal => 'Google Карти';

  @override
  String get mapStyleGoogleHybrid => 'Google Карти (хибрид)';

  @override
  String get mapStyleGoogleTerrain => 'Google Карти (терен)';

  @override
  String get mapStyleOsmLiberty => 'OSM Liberty';

  @override
  String get mapStyleOpenTopoMap => 'OpenTopoMap';

  @override
  String get mapStyleOsmHot => 'Humanitarian OSM';

  @override
  String get mapStyleStamenWatercolor => 'Stamen Акварел';

  @override
  String get maxBrightnessNever => 'Никога';

  @override
  String get maxBrightnessAlways => 'Винаги';

  @override
  String get nameConflictStrategyRename => 'Преименувай';

  @override
  String get nameConflictStrategyReplace => 'Замени';

  @override
  String get nameConflictStrategySkip => 'Пропусни';

  @override
  String get overlayHistogramNone => 'Нищо';

  @override
  String get overlayHistogramRGB => 'RGB';

  @override
  String get overlayHistogramLuminance => 'Яркост';

  @override
  String get subtitlePositionTop => 'Най-отгоре';

  @override
  String get subtitlePositionBottom => 'Отдолу';

  @override
  String get themeBrightnessLight => 'Светла';

  @override
  String get themeBrightnessDark => 'Тъмна';

  @override
  String get themeBrightnessBlack => 'Черна';

  @override
  String get unitSystemMetric => 'Метрични';

  @override
  String get unitSystemImperial => 'Имперски';

  @override
  String get vaultLockTypePattern => 'Графичен ключ';

  @override
  String get vaultLockTypePin => 'PIN-код';

  @override
  String get vaultLockTypePassword => 'Парола';

  @override
  String get settingsVideoEnablePip => 'Картина в картината';

  @override
  String get videoControlsPlayOutside => 'Отвори с друг видео плеър';

  @override
  String get videoLoopModeNever => 'Никога';

  @override
  String get videoLoopModeShortOnly => 'Само за кратки видеа';

  @override
  String get videoLoopModeAlways => 'Винаги';

  @override
  String get videoPlaybackSkip => 'Пропусни';

  @override
  String get videoPlaybackMuted => 'Пусни без звук';

  @override
  String get videoPlaybackWithSound => 'Пусни със звук';

  @override
  String get videoResumptionModeNever => 'Никога';

  @override
  String get videoResumptionModeAlways => 'Винаги';

  @override
  String get viewerTransitionSlide => 'Слайд';

  @override
  String get viewerTransitionParallax => 'Паралакс';

  @override
  String get viewerTransitionFade => 'Избледняване на прехода';

  @override
  String get viewerTransitionZoomIn => 'Приближения';

  @override
  String get viewerTransitionNone => 'Не';

  @override
  String get wallpaperTargetHome => 'Начален екран';

  @override
  String get wallpaperTargetLock => 'Заключен екран';

  @override
  String get wallpaperTargetHomeLock => 'Начален и заключен екран';

  @override
  String get widgetDisplayedItemRandom => 'Произволни';

  @override
  String get widgetDisplayedItemMostRecent => 'Чести';

  @override
  String get widgetOpenPageHome => 'Отвори начален екран';

  @override
  String get widgetOpenPageCollection => 'Отвори колекция';

  @override
  String get widgetOpenPageViewer => 'Преглед на текущия';

  @override
  String get widgetTapUpdateWidget => 'Обнови Уиджет';

  @override
  String get storageVolumeDescriptionFallbackPrimary => 'Вътрешна памет';

  @override
  String get storageVolumeDescriptionFallbackNonPrimary => 'SD карта';

  @override
  String get rootDirectoryDescription => 'Основна директория';

  @override
  String otherDirectoryDescription(String name) {
    return '„$name“ директория';
  }

  @override
  String storageAccessDialogMessage(String directory, String volume) {
    return 'Моля изберете $directory на „$volume“ на следващия екран за да дадете достъп на приложението до него.';
  }

  @override
  String restrictedAccessDialogMessage(String directory, String volume) {
    return 'На това приложение не се дава достъп до $directory на „$volume“.\n\nМоля използвайте системно инсталиран файлов мениджър или Галерия за преместване на елементи в друга директория.';
  }

  @override
  String notEnoughSpaceDialogMessage(String neededSize, String freeSize, String volume) {
    return 'Тази операция изисква $neededSize свободно място на „$volume“ за да завърши, но тук има само $freeSize оставащо.';
  }

  @override
  String get missingSystemFilePickerDialogMessage => 'Системното файлово приложение е изключено или липсва. Моля разрешете го и опитайте отново.';

  @override
  String unsupportedTypeDialogMessage(int count, String types) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Тази операция не се поддържа за елементи от следните типове: $types.',
      one: 'Тази операция не се поддържа за елементи от следния тип: $types.',
    );
    return '$_temp0';
  }

  @override
  String get nameConflictDialogSingleSourceMessage => 'Някои файлове в целевата папка имат същото име.';

  @override
  String get nameConflictDialogMultipleSourceMessage => 'Някои файлове имат еднакво име.';

  @override
  String get addShortcutDialogLabel => 'Етикет за пряк път';

  @override
  String get addShortcutButtonLabel => 'ДОБАВИ';

  @override
  String get noMatchingAppDialogMessage => 'Няма приложения, които да могат да се справят с това.';

  @override
  String binEntriesConfirmationDialogMessage(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Преместване на тези $countString елемента в кошчето?',
      one: 'Преместване на този елемент в кошчето?',
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
      other: 'Изтриване на тези $countString елемента?',
      one: 'Изтриване на този елемент?',
    );
    return '$_temp0';
  }

  @override
  String get moveUndatedConfirmationDialogMessage => 'Запазвам ли датите на елементите преди продължаване?';

  @override
  String get moveUndatedConfirmationDialogSetDate => 'Запазване дата';

  @override
  String videoResumeDialogMessage(String time) {
    return 'Да възобновени възпроизвеждането от $time?';
  }

  @override
  String get videoStartOverButtonLabel => 'ЗАПОЧНИ ОТНАЧАЛО';

  @override
  String get videoResumeButtonLabel => 'ПРОДЪЛЖИ';

  @override
  String get setCoverDialogLatest => 'Последен елемент';

  @override
  String get setCoverDialogAuto => 'Авто';

  @override
  String get setCoverDialogCustom => 'Персонален';

  @override
  String get hideFilterConfirmationDialogMessage => 'Съответстващите снимки и видеоклипове ще бъдат скрити от вашата колекция. Можете да ги покажете отново от настройките „Поверителност“.\n\nСигурни ли сте, че искате да ги скриете?';

  @override
  String get newAlbumDialogTitle => 'Нов албум';

  @override
  String get newAlbumDialogNameLabel => 'Име на албума';

  @override
  String get newAlbumDialogAlbumAlreadyExistsHelper => 'Албумът вече съществува';

  @override
  String get newAlbumDialogNameLabelAlreadyExistsHelper => 'Директорията вече съществува';

  @override
  String get newAlbumDialogStorageLabel => 'Хранилище:';

  @override
  String get newDynamicAlbumDialogTitle => 'Нов динамичен албум';

  @override
  String get dynamicAlbumAlreadyExists => 'Динамични албум вече съществува';

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
  String get newVaultWarningDialogMessage => 'Елементите в трезорите са достъпни само за това приложение и за никое друго.\n\nАко деинсталирате или изчистите данните на това приложение, ще загубите цялото съдържание на трезора.';

  @override
  String get newVaultDialogTitle => 'Нов трезор';

  @override
  String get configureVaultDialogTitle => 'Конфигурирайте Трезор';

  @override
  String get vaultDialogLockModeWhenScreenOff => 'Заключване при изключен екран';

  @override
  String get vaultDialogLockTypeLabel => 'Вид заключване';

  @override
  String get patternDialogEnter => 'Въведете шаблон';

  @override
  String get patternDialogConfirm => 'Потвърдете шаблон';

  @override
  String get pinDialogEnter => 'Въведете пин-код';

  @override
  String get pinDialogConfirm => 'Потвърдете PIN';

  @override
  String get passwordDialogEnter => 'Въведете парола';

  @override
  String get passwordDialogConfirm => 'Потвърдете парола';

  @override
  String get authenticateToConfigureVault => 'Удостоверете се, за да конфигурирате трезора';

  @override
  String get authenticateToUnlockVault => 'Удостоверете се, за да отключите трезора';

  @override
  String get vaultBinUsageDialogMessage => 'Някой от трезорите използват кошче.';

  @override
  String get renameAlbumDialogLabel => 'Ново име';

  @override
  String get renameAlbumDialogLabelAlreadyExistsHelper => 'Съществуваща директория';

  @override
  String get renameEntrySetPageTitle => 'Преименувай';

  @override
  String get renameEntrySetPagePatternFieldLabel => 'Шаблон наименуван';

  @override
  String get renameEntrySetPageInsertTooltip => 'Вмъкване на поле';

  @override
  String get renameEntrySetPagePreviewSectionTitle => 'Преглед';

  @override
  String get renameProcessorCounter => 'Брояч';

  @override
  String get renameProcessorHash => 'Хеш';

  @override
  String get renameProcessorName => 'Име';

  @override
  String deleteSingleAlbumConfirmationDialogMessage(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Изтриване на този албум и $countString елементите в него?',
      one: 'Изтриване на този албум и елемента в него?',
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
      other: 'Изтриване на тези албуми и $countString елементите в тях?',
      one: 'Изтриване на тези албуми и елемента в тях?',
    );
    return '$_temp0';
  }

  @override
  String get exportEntryDialogFormat => 'Формат:';

  @override
  String get exportEntryDialogWidth => 'Ширина';

  @override
  String get exportEntryDialogHeight => 'Височина';

  @override
  String get exportEntryDialogQuality => 'Качество';

  @override
  String get exportEntryDialogWriteMetadata => 'Запис на метаданни';

  @override
  String get renameEntryDialogLabel => 'Ново име';

  @override
  String get editEntryDialogCopyFromItem => 'Копиране от друг елемент';

  @override
  String get editEntryDialogTargetFieldsHeader => 'Полета за промяна';

  @override
  String get editEntryDateDialogTitle => 'Дата и час';

  @override
  String get editEntryDateDialogSetCustom => 'Задайте персонализирана дата';

  @override
  String get editEntryDateDialogCopyField => 'Копирайте от друга дата';

  @override
  String get editEntryDateDialogExtractFromTitle => 'Извличане от заглавието';

  @override
  String get editEntryDateDialogShift => 'Преместване с';

  @override
  String get editEntryDateDialogSourceFileModifiedDate => 'Дата на промяна на файла';

  @override
  String get durationDialogHours => 'Часове';

  @override
  String get durationDialogMinutes => 'Минути';

  @override
  String get durationDialogSeconds => 'Секунди';

  @override
  String get editEntryLocationDialogTitle => 'Местоположение';

  @override
  String get editEntryLocationDialogSetCustom => 'Редактиране на местоположение';

  @override
  String get editEntryLocationDialogChooseOnMap => 'Избери на картата';

  @override
  String get editEntryLocationDialogImportGpx => 'Импорт GPX';

  @override
  String get editEntryLocationDialogLatitude => 'Широчина';

  @override
  String get editEntryLocationDialogLongitude => 'Дължина';

  @override
  String get editEntryLocationDialogTimeShift => 'Изместване на времето';

  @override
  String get locationPickerUseThisLocationButton => 'Използвай това местоположение';

  @override
  String get editEntryRatingDialogTitle => 'Рейтинг';

  @override
  String get removeEntryMetadataDialogTitle => 'Премахване на метаданни';

  @override
  String get removeEntryMetadataDialogAll => 'Всички';

  @override
  String get removeEntryMetadataDialogMore => 'Още';

  @override
  String get removeEntryMetadataMotionPhotoXmpWarningDialogMessage => 'XMP е необходим за възпроизвеждане на видеоклипа в снимка с движение.\n\nСигурни ли сте, че искате да го премахнете?';

  @override
  String get videoSpeedDialogLabel => 'Скорост на възпроизвеждане';

  @override
  String get videoStreamSelectionDialogVideo => 'Видео';

  @override
  String get videoStreamSelectionDialogAudio => 'Аудио';

  @override
  String get videoStreamSelectionDialogText => 'Субтитри';

  @override
  String get videoStreamSelectionDialogOff => 'Изключено';

  @override
  String get videoStreamSelectionDialogTrack => 'Пътечка';

  @override
  String get videoStreamSelectionDialogNoSelection => 'Няма други пътечки.';

  @override
  String get genericSuccessFeedback => 'Готово!';

  @override
  String get genericFailureFeedback => 'Неуспешно';

  @override
  String get genericDangerWarningDialogMessage => 'Сигурен ли сте?';

  @override
  String get tooManyItemsErrorDialogMessage => 'Опитай отново с по-малко елементи.';

  @override
  String get menuActionConfigureView => 'Вид';

  @override
  String get menuActionSelect => 'Избери';

  @override
  String get menuActionSelectAll => 'Избери всички';

  @override
  String get menuActionSelectNone => 'Не избирай нищо';

  @override
  String get menuActionMap => 'Карта';

  @override
  String get menuActionSlideshow => 'Слайд-шоу';

  @override
  String get menuActionStats => 'Статистика';

  @override
  String get viewDialogSortSectionTitle => 'Сортиране';

  @override
  String get viewDialogGroupSectionTitle => 'Групиране';

  @override
  String get viewDialogLayoutSectionTitle => 'Оформление';

  @override
  String get viewDialogReverseSortOrder => 'Сортиране в обратен ред';

  @override
  String get tileLayoutMosaic => 'Мозайка';

  @override
  String get tileLayoutGrid => 'Решетка';

  @override
  String get tileLayoutList => 'Списък';

  @override
  String get castDialogTitle => 'Устройство за излъчване';

  @override
  String get coverDialogTabCover => 'Тапет';

  @override
  String get coverDialogTabApp => 'Приложение';

  @override
  String get coverDialogTabColor => 'Цвят';

  @override
  String get appPickDialogTitle => 'Изберете приложение';

  @override
  String get appPickDialogNone => 'Нищо';

  @override
  String get aboutPageTitle => 'За нас';

  @override
  String get aboutLinkLicense => 'Лицензи';

  @override
  String get aboutLinkPolicy => 'Политика за личните данни';

  @override
  String get aboutBugSectionTitle => 'Съобщи за грешка';

  @override
  String get aboutBugSaveLogInstruction => 'Запазете лог във файл';

  @override
  String get aboutBugCopyInfoInstruction => 'Копирай системата информация';

  @override
  String get aboutBugCopyInfoButton => 'Копирай';

  @override
  String get aboutBugReportInstruction => 'Изпратете съобщение за грешка на GitHub, заедно с лог и системна информация';

  @override
  String get aboutBugReportButton => 'Изпрати';

  @override
  String get aboutDataUsageSectionTitle => 'Използване на данни';

  @override
  String get aboutDataUsageData => 'Данни';

  @override
  String get aboutDataUsageCache => 'Кеш';

  @override
  String get aboutDataUsageDatabase => 'База данни';

  @override
  String get aboutDataUsageMisc => 'Разни';

  @override
  String get aboutDataUsageInternal => 'Вътрешни';

  @override
  String get aboutDataUsageExternal => 'Външни';

  @override
  String get aboutDataUsageClearCache => 'Изчисти кеш';

  @override
  String get aboutCreditsSectionTitle => 'Благодарности';

  @override
  String get aboutCreditsWorldAtlas1 => 'Това приложение използва файл TopoJSON от';

  @override
  String get aboutCreditsWorldAtlas2 => 'под ISC License.';

  @override
  String get aboutTranslatorsSectionTitle => 'Преводачи';

  @override
  String get aboutLicensesSectionTitle => 'Лиценз с отворен код';

  @override
  String get aboutLicensesBanner => 'Това приложение използва следните пакети и библиотеки с отворен код.';

  @override
  String get aboutLicensesAndroidLibrariesSectionTitle => 'Библиотеки Android';

  @override
  String get aboutLicensesFlutterPluginsSectionTitle => 'Flutter плъгини';

  @override
  String get aboutLicensesFlutterPackagesSectionTitle => 'Flutter пакети';

  @override
  String get aboutLicensesDartPackagesSectionTitle => 'Dart пакети';

  @override
  String get aboutLicensesShowAllButtonLabel => 'Покажи всички лицензи';

  @override
  String get policyPageTitle => 'Политика за конфиденциалност';

  @override
  String get collectionPageTitle => 'Колекция';

  @override
  String get collectionPickPageTitle => 'Избери';

  @override
  String get collectionSelectPageTitle => 'Изберете елементи';

  @override
  String get collectionActionShowTitleSearch => 'Покажи филтър на заглавията';

  @override
  String get collectionActionHideTitleSearch => 'Скрий филтъра на заглавието';

  @override
  String get collectionActionAddDynamicAlbum => 'Добави динамичен албум';

  @override
  String get collectionActionAddShortcut => 'Добави кратък път';

  @override
  String get collectionActionSetHome => 'Задай като начален';

  @override
  String get collectionActionEmptyBin => 'Изпразни кошчето';

  @override
  String get collectionActionCopy => 'Копирай в албум';

  @override
  String get collectionActionMove => 'Премести в албум';

  @override
  String get collectionActionRescan => 'Сканирай наново';

  @override
  String get collectionActionEdit => 'Промени';

  @override
  String get collectionSearchTitlesHintText => 'Търси заглавия';

  @override
  String get collectionGroupAlbum => 'По албум';

  @override
  String get collectionGroupMonth => 'По месец';

  @override
  String get collectionGroupDay => 'По дни';

  @override
  String get sectionNone => 'No sections';

  @override
  String get sectionUnknown => 'Неизвестно';

  @override
  String get dateToday => 'Днес';

  @override
  String get dateYesterday => 'Вчера';

  @override
  String get dateThisMonth => 'Този месец';

  @override
  String collectionDeleteFailureFeedback(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Неуспешно изтриване на $countString елемента',
      one: 'Неуспешно изтриване на 1 елемент',
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
      other: 'Неуспешно копиране на $countString елемента',
      one: 'Неуспешно копиране на 1 елемент',
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
      other: 'Неуспешно преместване на $countString елемента',
      one: 'Неуспешно преместване на 1 елемент',
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
      other: 'Неуспешно преименуване на $countString елемента',
      one: 'Неуспешно преименуване на 1 елемент',
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
      other: 'Неуспешно редактиране на $countString елемента',
      one: 'Неуспешно редактиране на 1 елемент',
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
      other: 'Неуспешно експортиране на $countString страници',
      one: 'Неуспешно експортиране на 1 страница',
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
      other: 'Копира $countString елемента',
      one: 'Копира 1 елемент',
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
      other: 'Преместени$countString елемента',
      one: 'Преместен 1 елемент',
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
      other: 'Преименувани $countString елемента',
      one: 'Преименуван 1 елемент',
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
      other: 'Редактирани$countString елемента',
      one: 'Редактиран 1 елемент',
    );
    return '$_temp0';
  }

  @override
  String get collectionEmptyFavourites => 'Няма любими';

  @override
  String get collectionEmptyVideos => 'Няма видеа';

  @override
  String get collectionEmptyImages => 'Няма изображения';

  @override
  String get collectionEmptyGrantAccessButtonLabel => 'Упълномощете достъп';

  @override
  String get collectionSelectSectionTooltip => 'Изберете раздел';

  @override
  String get collectionDeselectSectionTooltip => 'Премахнете избрания раздел';

  @override
  String get drawerAboutButton => 'За нас';

  @override
  String get drawerSettingsButton => 'Настройки';

  @override
  String get drawerCollectionAll => 'Цялата колекция';

  @override
  String get drawerCollectionFavourites => 'Любими';

  @override
  String get drawerCollectionImages => 'Изображения';

  @override
  String get drawerCollectionVideos => 'Видео';

  @override
  String get drawerCollectionAnimated => 'Анимиран';

  @override
  String get drawerCollectionMotionPhotos => 'Снимки с движения';

  @override
  String get drawerCollectionPanoramas => 'Панорами';

  @override
  String get drawerCollectionRaws => 'RAW';

  @override
  String get drawerCollectionSphericalVideos => '360° видео';

  @override
  String get drawerAlbumPage => 'Албуми';

  @override
  String get drawerCountryPage => 'Държави';

  @override
  String get drawerPlacePage => 'Места';

  @override
  String get drawerTagPage => 'Тагове';

  @override
  String get sortByDate => 'По дати';

  @override
  String get sortByName => 'По имена';

  @override
  String get sortByItemCount => 'По брой елементи';

  @override
  String get sortBySize => 'По размер';

  @override
  String get sortByAlbumFileName => 'По име на албум и файлови имена';

  @override
  String get sortByRating => 'По рейтинг';

  @override
  String get sortByDuration => 'По продължителност';

  @override
  String get sortByPath => 'Според пътя';

  @override
  String get sortOrderNewestFirst => 'Първо най-новите';

  @override
  String get sortOrderOldestFirst => 'Първо най-старите';

  @override
  String get sortOrderAtoZ => 'От А до Я';

  @override
  String get sortOrderZtoA => 'От Я до А';

  @override
  String get sortOrderHighestFirst => 'Първо най-високите';

  @override
  String get sortOrderLowestFirst => 'Първо най-ниските';

  @override
  String get sortOrderLargestFirst => 'Първо най-големите';

  @override
  String get sortOrderSmallestFirst => 'Първо най-малките';

  @override
  String get sortOrderShortestFirst => 'Първо най-кратките';

  @override
  String get sortOrderLongestFirst => 'Първо най-дългите';

  @override
  String get albumGroupTier => 'По нива';

  @override
  String get albumGroupType => 'По тип';

  @override
  String get albumGroupVolume => 'По обем на съхранение';

  @override
  String get albumMimeTypeMixed => 'Разни';

  @override
  String get albumPickPageTitleCopy => 'Копирай в албум';

  @override
  String get albumPickPageTitleExport => 'Експортирай в албум';

  @override
  String get albumPickPageTitleMove => 'Премести в албум';

  @override
  String get albumPickPageTitlePick => 'Избери албум';

  @override
  String get albumCamera => 'Камера';

  @override
  String get albumDownload => 'Изтеглени';

  @override
  String get albumScreenshots => 'Екранни снимки';

  @override
  String get albumScreenRecordings => 'Екранни записи';

  @override
  String get albumVideoCaptures => 'Видеозаписи';

  @override
  String get albumPageTitle => 'Албуми';

  @override
  String get albumEmpty => 'Няма албуми';

  @override
  String get createAlbumButtonLabel => 'СЪЗДАЙ';

  @override
  String get newFilterBanner => 'Нов';

  @override
  String get countryPageTitle => 'Държави';

  @override
  String get countryEmpty => 'Няма държави';

  @override
  String get statePageTitle => 'Региони';

  @override
  String get stateEmpty => 'Няма региони';

  @override
  String get placePageTitle => 'Места';

  @override
  String get placeEmpty => 'Няма места';

  @override
  String get tagPageTitle => 'Тагове';

  @override
  String get tagEmpty => 'Без тагове';

  @override
  String get binPageTitle => 'Кошче';

  @override
  String get explorerPageTitle => 'Файлов мениджър';

  @override
  String get explorerActionSelectStorageVolume => 'Избери място за съхранение';

  @override
  String get selectStorageVolumeDialogTitle => 'Избери място за съхранение';

  @override
  String get searchCollectionFieldHint => 'Търсене по колекции';

  @override
  String get searchRecentSectionTitle => 'Скорошни';

  @override
  String get searchDateSectionTitle => 'Дата';

  @override
  String get searchFormatSectionTitle => 'Формати';

  @override
  String get searchAlbumsSectionTitle => 'Албуми';

  @override
  String get searchCountriesSectionTitle => 'Държави';

  @override
  String get searchStatesSectionTitle => 'Региони';

  @override
  String get searchPlacesSectionTitle => 'Места';

  @override
  String get searchTagsSectionTitle => 'Тагове';

  @override
  String get searchRatingSectionTitle => 'Рейтинги';

  @override
  String get searchMetadataSectionTitle => 'Метаданни';

  @override
  String get settingsPageTitle => 'Настройки';

  @override
  String get settingsSystemDefault => 'По подразбиране';

  @override
  String get settingsDefault => 'По подразбиране';

  @override
  String get settingsDisabled => 'Изключено';

  @override
  String get settingsAskEverytime => 'Питай всеки път';

  @override
  String get settingsModificationWarningDialogMessage => 'Другите настройки ще бъдат модифицирани.';

  @override
  String get settingsSearchFieldLabel => 'Търсене настройки';

  @override
  String get settingsSearchEmpty => 'Не са открити настройки';

  @override
  String get settingsActionExport => 'Експортиране';

  @override
  String get settingsActionExportDialogTitle => 'Експорт';

  @override
  String get settingsActionImport => 'Импорт';

  @override
  String get settingsActionImportDialogTitle => 'Импорт';

  @override
  String get appExportCovers => 'Тапети';

  @override
  String get appExportDynamicAlbums => 'Динамични албуми';

  @override
  String get appExportFavourites => 'Любими';

  @override
  String get appExportSettings => 'Настройки';

  @override
  String get settingsNavigationSectionTitle => 'Навигация';

  @override
  String get settingsHomeTile => 'Начален екран';

  @override
  String get settingsHomeDialogTitle => 'Начален екран';

  @override
  String get setHomeCustom => 'Персонализиран';

  @override
  String get settingsShowBottomNavigationBar => 'Показване на долната лента за навигация';

  @override
  String get settingsKeepScreenOnTile => 'Запази екрана включен';

  @override
  String get settingsKeepScreenOnDialogTitle => 'Запази екрана включен';

  @override
  String get settingsDoubleBackExit => 'Два пъти „назад“ за изход';

  @override
  String get settingsConfirmationTile => 'Диалог за потвърждение';

  @override
  String get settingsConfirmationDialogTitle => 'Диалогови прозорци за потвърждение';

  @override
  String get settingsConfirmationBeforeDeleteItems => 'Попитай преди изтриване завинаги';

  @override
  String get settingsConfirmationBeforeMoveToBinItems => 'Попитай преди преместване в кошчето';

  @override
  String get settingsConfirmationBeforeMoveUndatedItems => 'Попитай, преди преместване на елементи без дата';

  @override
  String get settingsConfirmationAfterMoveToBinItems => 'Показване на съобщение след преместване на елементи в кошчето';

  @override
  String get settingsConfirmationVaultDataLoss => 'Показване на предупреждение за загуба на данни от трезора';

  @override
  String get settingsNavigationDrawerTile => 'Навигационно меню';

  @override
  String get settingsNavigationDrawerEditorPageTitle => 'Навигационно меню';

  @override
  String get settingsNavigationDrawerBanner => 'Докоснете и задръжте, за да преместите и пренаредите елементи от менюто.';

  @override
  String get settingsNavigationDrawerTabTypes => 'Типове';

  @override
  String get settingsNavigationDrawerTabAlbums => 'Албуми';

  @override
  String get settingsNavigationDrawerTabPages => 'Страници';

  @override
  String get settingsNavigationDrawerAddAlbum => 'Добави албум';

  @override
  String get settingsThumbnailSectionTitle => 'Миниатюри';

  @override
  String get settingsThumbnailOverlayTile => 'Повече информация';

  @override
  String get settingsThumbnailOverlayPageTitle => 'Повече информация';

  @override
  String get settingsThumbnailShowHdrIcon => 'Показване на HDR икона';

  @override
  String get settingsThumbnailShowFavouriteIcon => 'Показване на любима икона';

  @override
  String get settingsThumbnailShowTagIcon => 'Показване на иконата за таг';

  @override
  String get settingsThumbnailShowLocationIcon => 'Показване на иконата за местоположение';

  @override
  String get settingsThumbnailShowMotionPhotoIcon => 'Показване на иконата на снимка с движение';

  @override
  String get settingsThumbnailShowRating => 'Покажи рейтинг';

  @override
  String get settingsThumbnailShowRawIcon => 'Показване на необработена икона';

  @override
  String get settingsThumbnailShowVideoDuration => 'Показване на продължителността на видеоклипа';

  @override
  String get settingsCollectionQuickActionsTile => 'Бързи действия';

  @override
  String get settingsCollectionQuickActionEditorPageTitle => 'Бързи действия';

  @override
  String get settingsCollectionQuickActionTabBrowsing => 'Сърфиране';

  @override
  String get settingsCollectionQuickActionTabSelecting => 'Избиране';

  @override
  String get settingsCollectionBrowsingQuickActionEditorBanner => 'Докоснете и задръжте, за да преместите бутоните и избор кои действия да се показват при разглеждане на елементи.';

  @override
  String get settingsCollectionSelectionQuickActionEditorBanner => 'Докоснете и задръжте, за да преместите бутоните и да изберете кои действия да се показват при избиране на елементи.';

  @override
  String get settingsCollectionBurstPatternsTile => 'Шаблон серийни снимки';

  @override
  String get settingsCollectionBurstPatternsNone => 'Няма';

  @override
  String get settingsViewerSectionTitle => 'Визуализатор';

  @override
  String get settingsViewerGestureSideTapNext => 'Докоснете краищата на екрана, за да покажете предишен/следващ елемент';

  @override
  String get settingsViewerUseCutout => 'Използвай зоната на изрязване';

  @override
  String get settingsViewerMaximumBrightness => 'Максимална яркост';

  @override
  String get settingsMotionPhotoAutoPlay => 'Автоматично възпроизвеждане на снимки с движение';

  @override
  String get settingsImageBackground => 'Фоново изображения';

  @override
  String get settingsViewerQuickActionsTile => 'Бързи действия';

  @override
  String get settingsViewerQuickActionEditorPageTitle => 'Бързи действия';

  @override
  String get settingsViewerQuickActionEditorBanner => 'Докоснете и задръжте, за да преместите бутоните и да изберете кои действия да се показват във визуализатора.';

  @override
  String get settingsViewerQuickActionEditorDisplayedButtonsSectionTitle => 'Показани бутони';

  @override
  String get settingsViewerQuickActionEditorAvailableButtonsSectionTitle => 'Налични бутони';

  @override
  String get settingsViewerQuickActionEmpty => 'Без бутони';

  @override
  String get settingsViewerOverlayTile => 'Повече информация';

  @override
  String get settingsViewerOverlayPageTitle => 'Повече информация';

  @override
  String get settingsViewerShowOverlayOnOpening => 'Показване при отваряне';

  @override
  String get settingsViewerShowHistogram => 'Показвай хистограма';

  @override
  String get settingsViewerShowMinimap => 'Показване на миникарта';

  @override
  String get settingsViewerShowInformation => 'Показване на информация';

  @override
  String get settingsViewerShowInformationSubtitle => 'Показване на заглавие, дата, местоположение и др.';

  @override
  String get settingsViewerShowRatingTags => 'Показване на рейтинг и тагове';

  @override
  String get settingsViewerShowShootingDetails => 'Показване на подробности за снимане';

  @override
  String get settingsViewerShowDescription => 'Показване описание';

  @override
  String get settingsViewerShowOverlayThumbnails => 'Показване на миниатюри';

  @override
  String get settingsViewerEnableOverlayBlurEffect => 'Blur ефект';

  @override
  String get settingsViewerSlideshowTile => 'Слайд-шоу';

  @override
  String get settingsViewerSlideshowPageTitle => 'Слайд-шоу';

  @override
  String get settingsSlideshowRepeat => 'Повтори слайдшоу';

  @override
  String get settingsSlideshowShuffle => 'Разбъркайте';

  @override
  String get settingsSlideshowFillScreen => 'Цял екран';

  @override
  String get settingsSlideshowAnimatedZoomEffect => 'Анимиран ефект на увеличение';

  @override
  String get settingsSlideshowTransitionTile => 'Преход ефекти';

  @override
  String get settingsSlideshowIntervalTile => 'Интервал';

  @override
  String get settingsSlideshowVideoPlaybackTile => 'Възпроизвеждане на видео';

  @override
  String get settingsSlideshowVideoPlaybackDialogTitle => 'Възпроизвеждане на видео';

  @override
  String get settingsVideoPageTitle => 'Видео настройки';

  @override
  String get settingsVideoSectionTitle => 'Видео';

  @override
  String get settingsVideoShowVideos => 'Покажи видеа';

  @override
  String get settingsVideoPlaybackTile => 'Възпроизвеждане';

  @override
  String get settingsVideoPlaybackPageTitle => 'Възпроизвеждане';

  @override
  String get settingsVideoEnableHardwareAcceleration => 'Хардуерно ускорение';

  @override
  String get settingsVideoAutoPlay => 'Автоматично възпроизвеждане';

  @override
  String get settingsVideoLoopModeTile => 'Цикличен режим';

  @override
  String get settingsVideoLoopModeDialogTitle => 'Цикличен режим';

  @override
  String get settingsVideoResumptionModeTile => 'Възобновяване на възпроизвеждането';

  @override
  String get settingsVideoResumptionModeDialogTitle => 'Възобновяване на възпроизвеждането';

  @override
  String get settingsVideoBackgroundMode => 'Фонов режим';

  @override
  String get settingsVideoBackgroundModeDialogTitle => 'Фонов режим';

  @override
  String get settingsVideoControlsTile => 'Настройки видео';

  @override
  String get settingsVideoControlsPageTitle => 'Настройки видео';

  @override
  String get settingsVideoButtonsTile => 'Бутони';

  @override
  String get settingsVideoGestureDoubleTapTogglePlay => 'Докоснете два пъти за възпроизвеждане/пауза';

  @override
  String get settingsVideoGestureSideDoubleTapSeek => 'Докоснете два пъти краищата на екрана, за превъртане назад/напред';

  @override
  String get settingsVideoGestureVerticalDragBrightnessVolume => 'Плъзнете нагоре или надолу, за да регулирате яркостта/силата на звука';

  @override
  String get settingsSubtitleThemeTile => 'Субтитри';

  @override
  String get settingsSubtitleThemePageTitle => 'Субтитри';

  @override
  String get settingsSubtitleThemeSample => 'Това е примерен текст.';

  @override
  String get settingsSubtitleThemeTextAlignmentTile => 'Подравняване на текст';

  @override
  String get settingsSubtitleThemeTextAlignmentDialogTitle => 'Подравняване на текст';

  @override
  String get settingsSubtitleThemeTextPositionTile => 'Позиция на текст';

  @override
  String get settingsSubtitleThemeTextPositionDialogTitle => 'Позиция на текст';

  @override
  String get settingsSubtitleThemeTextSize => 'Размер на текст';

  @override
  String get settingsSubtitleThemeShowOutline => 'Покажете контур и сянка';

  @override
  String get settingsSubtitleThemeTextColor => 'Цвят на текст';

  @override
  String get settingsSubtitleThemeTextOpacity => 'Непрозрачност на текста';

  @override
  String get settingsSubtitleThemeBackgroundColor => 'Цвят на фона';

  @override
  String get settingsSubtitleThemeBackgroundOpacity => 'Непрозрачност на фона';

  @override
  String get settingsSubtitleThemeTextAlignmentLeft => 'Подравняване отляво';

  @override
  String get settingsSubtitleThemeTextAlignmentCenter => 'Подравняване по центъра';

  @override
  String get settingsSubtitleThemeTextAlignmentRight => 'Подравняване от дясно';

  @override
  String get settingsPrivacySectionTitle => 'Поверителност';

  @override
  String get settingsAllowInstalledAppAccess => 'Разрешете достъп до библиотеките на приложението';

  @override
  String get settingsAllowInstalledAppAccessSubtitle => 'Използва се за подобряване на показването на албума';

  @override
  String get settingsAllowErrorReporting => 'Разрешаване на анонимно докладване на грешки';

  @override
  String get settingsSaveSearchHistory => 'Запазване на историята на търсенето';

  @override
  String get settingsEnableBin => 'Използвайте кошчето';

  @override
  String get settingsEnableBinSubtitle => 'Съхранявайте изтритите елементи за 30 дни';

  @override
  String get settingsDisablingBinWarningDialogMessage => 'Елементите в кошчето ще бъдат изтрити завинаги.';

  @override
  String get settingsAllowMediaManagement => 'Разрешаване на управление на медиите';

  @override
  String get settingsHiddenItemsTile => 'Скрити елементи';

  @override
  String get settingsHiddenItemsPageTitle => 'Скрити елементи';

  @override
  String get settingsHiddenFiltersBanner => 'Снимките и видеоклиповете, съответстващи на скрити филтри, няма да се показват във вашата колекция.';

  @override
  String get settingsHiddenFiltersEmpty => 'Няма скрити филтри';

  @override
  String get settingsStorageAccessTile => 'Достъп до хранилището';

  @override
  String get settingsStorageAccessPageTitle => 'Достъп до хранилището';

  @override
  String get settingsStorageAccessBanner => 'Някои директории изискват изрично разрешение за достъп за модифициране на файлове в тях. Тук можете да прегледате директории, до които преди това сте дали достъп.';

  @override
  String get settingsStorageAccessEmpty => 'Няма права за достъп';

  @override
  String get settingsStorageAccessRevokeTooltip => 'Отмени';

  @override
  String get settingsAccessibilitySectionTitle => 'Достъпност';

  @override
  String get settingsRemoveAnimationsTile => 'Премахване анимация';

  @override
  String get settingsRemoveAnimationsDialogTitle => 'Премахване анимации';

  @override
  String get settingsTimeToTakeActionTile => 'Време на изпълнение на действието';

  @override
  String get settingsAccessibilityShowPinchGestureAlternatives => 'Показване на алтернативи за жестове с мултитъч';

  @override
  String get settingsDisplaySectionTitle => 'Изглед';

  @override
  String get settingsThemeBrightnessTile => 'Тема';

  @override
  String get settingsThemeBrightnessDialogTitle => 'Тема';

  @override
  String get settingsThemeColorHighlights => 'Цветни акценти';

  @override
  String get settingsThemeEnableDynamicColor => 'Динамични цветове';

  @override
  String get settingsDisplayRefreshRateModeTile => 'Честота на обновление на дисплея';

  @override
  String get settingsDisplayRefreshRateModeDialogTitle => 'Честота на опресняване';

  @override
  String get settingsDisplayUseTvInterface => 'Интерфейс Android TV';

  @override
  String get settingsLanguageSectionTitle => 'Език и формати';

  @override
  String get settingsLanguageTile => 'Език';

  @override
  String get settingsLanguagePageTitle => 'Език';

  @override
  String get settingsCoordinateFormatTile => 'Формат на координати';

  @override
  String get settingsCoordinateFormatDialogTitle => 'Формат на координати';

  @override
  String get settingsUnitSystemTile => 'Единици за измерване';

  @override
  String get settingsUnitSystemDialogTitle => 'Единици за измерване';

  @override
  String get settingsForceWesternArabicNumeralsTile => 'Принудителни арабски цифри';

  @override
  String get settingsScreenSaverPageTitle => 'Скрийнсейвър';

  @override
  String get settingsWidgetPageTitle => 'Фоторамка';

  @override
  String get settingsWidgetShowOutline => 'Контур';

  @override
  String get settingsWidgetOpenPage => 'При докосване на джаджата';

  @override
  String get settingsWidgetDisplayedItem => 'Показан артикул';

  @override
  String get settingsCollectionTile => 'Колекция';

  @override
  String get statsPageTitle => 'Статистика';

  @override
  String statsWithGps(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString елемента с местоположение',
      one: '1 елемент с местоположение',
    );
    return '$_temp0';
  }

  @override
  String get statsTopCountriesSectionTitle => 'Топ страни';

  @override
  String get statsTopStatesSectionTitle => 'Топ региони';

  @override
  String get statsTopPlacesSectionTitle => 'Топ локации';

  @override
  String get statsTopTagsSectionTitle => 'Топ тагове';

  @override
  String get statsTopAlbumsSectionTitle => 'Топ албуми';

  @override
  String get viewerOpenPanoramaButtonLabel => 'ОТВОРИ ПАНОРАМА';

  @override
  String get viewerSetWallpaperButtonLabel => 'ЗАДАЙ КАТО ТАПЕТ';

  @override
  String get viewerErrorUnknown => 'Опс!';

  @override
  String get viewerErrorDoesNotExist => 'Файлът не съществува.';

  @override
  String get viewerInfoPageTitle => 'Информация';

  @override
  String get viewerInfoBackToViewerTooltip => 'Обратно към визуализатор';

  @override
  String get viewerInfoUnknown => 'Неизвестен';

  @override
  String get viewerInfoLabelDescription => 'Описание';

  @override
  String get viewerInfoLabelTitle => 'Заглавие';

  @override
  String get viewerInfoLabelDate => 'Дата';

  @override
  String get viewerInfoLabelResolution => 'Резолюция';

  @override
  String get viewerInfoLabelSize => 'Размер';

  @override
  String get viewerInfoLabelUri => 'Идентификатор';

  @override
  String get viewerInfoLabelPath => 'Път';

  @override
  String get viewerInfoLabelDuration => 'Продължителност';

  @override
  String get viewerInfoLabelOwner => 'Собственик';

  @override
  String get viewerInfoLabelCoordinates => 'Координати';

  @override
  String get viewerInfoLabelAddress => 'Адрес';

  @override
  String get mapStyleDialogTitle => 'Стиль карта';

  @override
  String get mapStyleTooltip => 'Избирате стил на карта';

  @override
  String get mapZoomInTooltip => 'Увеличете мащаба';

  @override
  String get mapZoomOutTooltip => 'Намаляване';

  @override
  String get mapPointNorthUpTooltip => 'Север нагоре';

  @override
  String get mapAttributionOsmData => 'Данни карта © [OpenStreetMap](https://www.openstreetmap.org/copyright) участници';

  @override
  String get mapAttributionOsmLiberty => 'Предварително генерирани плочки от [OpenMapTiles](https://www.openmaptiles.org/), [CC BY](http://creativecommons.org/licenses/by/4.0) • • Хоствано от [OSM Americana](https://tile.ourmap.us)';

  @override
  String get mapAttributionOpenTopoMap => '[SRTM](https://www.earthdata.nasa.gov/sensors/srtm) | Плочки от [OpenTopoMap](https://opentopomap.org/), [CC BY-SA](https://creativecommons.org/licenses/by-sa/3.0/)';

  @override
  String get mapAttributionOsmHot => 'Плочки от[HOT](https://www.hotosm.org/) • Хоствано от [OSM France](https://openstreetmap.fr/)';

  @override
  String get mapAttributionStamen => 'Плочки от [Stamen Design](https://stamen.com), [CC BY 3.0](https://creativecommons.org/licenses/by/3.0)';

  @override
  String get openMapPageTooltip => 'Преглед на страницата с карта';

  @override
  String get mapEmptyRegion => 'Няма изображения в този регион';

  @override
  String get viewerInfoOpenEmbeddedFailureFeedback => 'Неуспешно извличане на вградени данни';

  @override
  String get viewerInfoOpenLinkText => 'Отвори';

  @override
  String get viewerInfoViewXmlLinkText => 'Преглед на XML';

  @override
  String get viewerInfoSearchFieldLabel => 'Търсене на метаданни';

  @override
  String get viewerInfoSearchEmpty => 'Няма съответстващи ключове';

  @override
  String get viewerInfoSearchSuggestionDate => 'Дата и час';

  @override
  String get viewerInfoSearchSuggestionDescription => 'Описание';

  @override
  String get viewerInfoSearchSuggestionDimensions => 'Размери';

  @override
  String get viewerInfoSearchSuggestionResolution => 'Резолюция';

  @override
  String get viewerInfoSearchSuggestionRights => 'Права';

  @override
  String get wallpaperUseScrollEffect => 'Използвайте ефекта на превъртане на началния екран';

  @override
  String get tagEditorPageTitle => 'Променете тагове';

  @override
  String get tagEditorPageNewTagFieldLabel => 'Нов таг';

  @override
  String get tagEditorPageAddTagTooltip => 'Добави таг';

  @override
  String get tagEditorSectionRecent => 'Скорошни';

  @override
  String get tagEditorSectionPlaceholders => 'Заместители';

  @override
  String get tagEditorDiscardDialogMessage => 'Искате ли да отхвърлите промените?';

  @override
  String get tagPlaceholderCountry => 'Държава';

  @override
  String get tagPlaceholderState => 'Регион';

  @override
  String get tagPlaceholderPlace => 'Локация';

  @override
  String get panoramaEnableSensorControl => 'Активирайте сензорния контрол';

  @override
  String get panoramaDisableSensorControl => 'Изключете сензорния контрол';

  @override
  String get sourceViewerPageTitle => 'Источник';
}
