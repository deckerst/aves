// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Aves';

  @override
  String get welcomeMessage => 'Добро пожаловать в Aves';

  @override
  String get welcomeOptional => 'Опционально';

  @override
  String get welcomeTermsToggle => 'Я согласен с условиями и положениями';

  @override
  String itemCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString объектов',
      few: '$countString объекта',
      one: '$countString объект',
    );
    return '$_temp0';
  }

  @override
  String columnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count столбцов',
      few: '$count столбца',
      one: '$count столбец',
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
      other: '$countString секунд',
      few: '$countString секунды',
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
      other: '$countString минут',
      few: '$countString минуты',
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
      other: '$countString дней',
      few: '$countString дня',
      one: '$countString день',
    );
    return '$_temp0';
  }

  @override
  String focalLength(String length) {
    return '$length mm';
  }

  @override
  String get applyButtonLabel => 'ПРИМЕНИТЬ';

  @override
  String get deleteButtonLabel => 'УДАЛИТЬ';

  @override
  String get nextButtonLabel => 'ДАЛЕЕ';

  @override
  String get showButtonLabel => 'ПОКАЗАТЬ';

  @override
  String get hideButtonLabel => 'СКРЫТЬ';

  @override
  String get continueButtonLabel => 'ПРОДОЛЖИТЬ';

  @override
  String get saveCopyButtonLabel => 'СОХРАНИТЬ КОПИЮ';

  @override
  String get applyTooltip => 'Применить';

  @override
  String get cancelTooltip => 'Отмена';

  @override
  String get changeTooltip => 'Изменить';

  @override
  String get clearTooltip => 'Очистить';

  @override
  String get previousTooltip => 'Предыдущий';

  @override
  String get nextTooltip => 'Следующий';

  @override
  String get showTooltip => 'Показать';

  @override
  String get hideTooltip => 'Скрыть';

  @override
  String get actionRemove => 'Удалить';

  @override
  String get resetTooltip => 'Сбросить';

  @override
  String get saveTooltip => 'Сохранить';

  @override
  String get stopTooltip => 'Остановить';

  @override
  String get pickTooltip => 'Выбрать';

  @override
  String get doubleBackExitMessage => 'Нажмите «Назад» еще раз, чтобы выйти.';

  @override
  String get doNotAskAgain => 'Больше не спрашивать';

  @override
  String get sourceStateLoading => 'Загрузка';

  @override
  String get sourceStateCataloguing => 'Каталогизация';

  @override
  String get sourceStateLocatingCountries => 'Расположение стран';

  @override
  String get sourceStateLocatingPlaces => 'Расположение локаций';

  @override
  String get chipActionDelete => 'Удалить';

  @override
  String get chipActionRemove => 'Удалить';

  @override
  String get chipActionShowCollection => 'Показать в Коллекции';

  @override
  String get chipActionGoToAlbumPage => 'Показать в Альбомах';

  @override
  String get chipActionGoToCountryPage => 'Показать в Странах';

  @override
  String get chipActionGoToPlacePage => 'Показать в локациях';

  @override
  String get chipActionGoToTagPage => 'Показать в тегах';

  @override
  String get chipActionGoToExplorerPage => 'Показать в проводнике';

  @override
  String get chipActionDecompose => 'Раздел';

  @override
  String get chipActionFilterOut => 'Исключить';

  @override
  String get chipActionFilterIn => 'Включить';

  @override
  String get chipActionHide => 'Скрыть';

  @override
  String get chipActionLock => 'Заблокировать';

  @override
  String get chipActionPin => 'Закрепить';

  @override
  String get chipActionUnpin => 'Открепить';

  @override
  String get chipActionRename => 'Переименовать';

  @override
  String get chipActionSetCover => 'Установить обложку';

  @override
  String get chipActionShowCountryStates => 'Показать государства';

  @override
  String get chipActionCreateAlbum => 'Создать альбом';

  @override
  String get chipActionCreateVault => 'Создать хранилище';

  @override
  String get chipActionConfigureVault => 'Настроить хранилище';

  @override
  String get entryActionCopyToClipboard => 'Скопировать в буфер обмена';

  @override
  String get entryActionDelete => 'Удалить';

  @override
  String get entryActionConvert => 'Конвертировать';

  @override
  String get entryActionExport => 'Экспорт';

  @override
  String get entryActionInfo => 'Информация';

  @override
  String get entryActionRename => 'Переименовать';

  @override
  String get entryActionRestore => 'Восстановить';

  @override
  String get entryActionRotateCCW => 'Повернуть против часовой стрелки';

  @override
  String get entryActionRotateCW => 'Повернуть по часовой стрелки';

  @override
  String get entryActionFlip => 'Отразить по горизонтали';

  @override
  String get entryActionPrint => 'Печать';

  @override
  String get entryActionShare => 'Поделиться';

  @override
  String get entryActionShareImageOnly => 'Поделиться только изображением';

  @override
  String get entryActionShareVideoOnly => 'Поделиться только видео';

  @override
  String get entryActionViewSource => 'Посмотреть источник';

  @override
  String get entryActionShowGeoTiffOnMap => 'Показать на карте';

  @override
  String get entryActionConvertMotionPhotoToStillImage => 'Конвертировать в статичное изображение';

  @override
  String get entryActionViewMotionPhotoVideo => 'Открыть видео';

  @override
  String get entryActionEdit => 'Изменить';

  @override
  String get entryActionOpen => 'Открыть с помощью';

  @override
  String get entryActionSetAs => 'Установить как';

  @override
  String get entryActionCast => 'Трансляция';

  @override
  String get entryActionOpenMap => 'Показать на карте';

  @override
  String get entryActionRotateScreen => 'Повернуть экран';

  @override
  String get entryActionAddFavourite => 'Добавить в избранное';

  @override
  String get entryActionRemoveFavourite => 'Удалить из избранного';

  @override
  String get videoActionCaptureFrame => 'Сохранить кадр';

  @override
  String get videoActionMute => 'Выключить звук';

  @override
  String get videoActionUnmute => 'Включить звук';

  @override
  String get videoActionPause => 'Стоп';

  @override
  String get videoActionPlay => 'Играть';

  @override
  String get videoActionReplay10 => 'Перемотка на 10 секунд назад';

  @override
  String get videoActionSkip10 => 'Перемотка на 10 секунд вперёд';

  @override
  String get videoActionShowPreviousFrame => 'Показать предыдущий кадр';

  @override
  String get videoActionShowNextFrame => 'Показать следующий кадр';

  @override
  String get videoActionSelectStreams => 'Выбрать дорожку';

  @override
  String get videoActionSetSpeed => 'Скорость воспроизведения';

  @override
  String get videoActionABRepeat => 'Повторить от А до Б';

  @override
  String get videoRepeatActionSetStart => 'Установить начало';

  @override
  String get videoRepeatActionSetEnd => 'Установить конец';

  @override
  String get viewerActionSettings => 'Настройки';

  @override
  String get viewerActionLock => 'Заблокировать просмотрщик';

  @override
  String get viewerActionUnlock => 'Разблокировать просмотрщик';

  @override
  String get slideshowActionResume => 'Продолжить';

  @override
  String get slideshowActionShowInCollection => 'Показать в Коллекции';

  @override
  String get entryInfoActionEditDate => 'Изменить дату и время';

  @override
  String get entryInfoActionEditLocation => 'Изменить местоположение';

  @override
  String get entryInfoActionEditTitleDescription => 'Изменить название и описание';

  @override
  String get entryInfoActionEditRating => 'Изменить рейтинг';

  @override
  String get entryInfoActionEditTags => 'Изменить теги';

  @override
  String get entryInfoActionRemoveMetadata => 'Удалить метаданные';

  @override
  String get entryInfoActionExportMetadata => 'Экспорт метаданных';

  @override
  String get entryInfoActionRemoveLocation => 'Удалить местоположение';

  @override
  String get editorActionTransform => 'Изменить';

  @override
  String get editorTransformCrop => 'Обрезать';

  @override
  String get editorTransformRotate => 'Повернуть';

  @override
  String get cropAspectRatioFree => 'Свободное';

  @override
  String get cropAspectRatioOriginal => 'Изначальное';

  @override
  String get cropAspectRatioSquare => 'Квадратное';

  @override
  String get filterAspectRatioLandscapeLabel => 'Горизонтально';

  @override
  String get filterAspectRatioPortraitLabel => 'Вертикально';

  @override
  String get filterBinLabel => 'Корзина';

  @override
  String get filterFavouriteLabel => 'Избранное';

  @override
  String get filterNoDateLabel => 'Без даты';

  @override
  String get filterNoAddressLabel => 'Без адреса';

  @override
  String get filterLocatedLabel => 'С местоположением';

  @override
  String get filterNoLocationLabel => 'Без местоположения';

  @override
  String get filterNoRatingLabel => 'Без рейтинга';

  @override
  String get filterTaggedLabel => 'С тэгами';

  @override
  String get filterNoTagLabel => 'Без тегов';

  @override
  String get filterNoTitleLabel => 'Без названия';

  @override
  String get filterOnThisDayLabel => 'В этот день';

  @override
  String get filterRecentlyAddedLabel => 'Недавно добавленные';

  @override
  String get filterRatingRejectedLabel => 'Отклонённое';

  @override
  String get filterTypeAnimatedLabel => 'GIF';

  @override
  String get filterTypeMotionPhotoLabel => 'Живое фото';

  @override
  String get filterTypePanoramaLabel => 'Панорама';

  @override
  String get filterTypeRawLabel => 'RAW';

  @override
  String get filterTypeSphericalVideoLabel => '360° видео';

  @override
  String get filterTypeGeotiffLabel => 'GeoTIFF';

  @override
  String get filterMimeImageLabel => 'Изображение';

  @override
  String get filterMimeVideoLabel => 'Видео';

  @override
  String get accessibilityAnimationsRemove => 'Предотвратить экранные эффекты';

  @override
  String get accessibilityAnimationsKeep => 'Сохранить экранные эффекты';

  @override
  String get albumTierNew => 'Новые';

  @override
  String get albumTierPinned => 'Закрепленные';

  @override
  String get albumTierSpecial => 'Стандартные';

  @override
  String get albumTierApps => 'Приложения';

  @override
  String get albumTierVaults => 'Хранилища';

  @override
  String get albumTierDynamic => 'Динамический';

  @override
  String get albumTierRegular => 'Другие';

  @override
  String get coordinateFormatDms => 'Градусы, минуты и секунды';

  @override
  String get coordinateFormatDdm => 'DDM';

  @override
  String get coordinateFormatDecimal => 'Десятичные градусы';

  @override
  String coordinateDms(String coordinate, String direction) {
    return '$coordinate $direction';
  }

  @override
  String get coordinateDmsNorth => 'с. ш.';

  @override
  String get coordinateDmsSouth => 'ю. ш.';

  @override
  String get coordinateDmsEast => 'в. д.';

  @override
  String get coordinateDmsWest => 'з. д.';

  @override
  String get displayRefreshRatePreferHighest => 'Наивысшая частота';

  @override
  String get displayRefreshRatePreferLowest => 'Наименьшая частота';

  @override
  String get keepScreenOnNever => 'Никогда';

  @override
  String get keepScreenOnVideoPlayback => 'Во время воспроизведения видео';

  @override
  String get keepScreenOnViewerOnly => 'Только в просмотрщике';

  @override
  String get keepScreenOnAlways => 'Всегда';

  @override
  String get lengthUnitPixel => 'пикс.';

  @override
  String get lengthUnitPercent => '%';

  @override
  String get mapStyleGoogleNormal => 'Google Карты';

  @override
  String get mapStyleGoogleHybrid => 'Google Карты (Гибридный)';

  @override
  String get mapStyleGoogleTerrain => 'Google Карты (Местность)';

  @override
  String get mapStyleOsmLiberty => 'OSM Liberty';

  @override
  String get mapStyleOpenTopoMap => 'OpenTopoMap';

  @override
  String get mapStyleOsmHot => 'Humanitarian OSM';

  @override
  String get mapStyleStamenWatercolor => 'Stamen Акварель';

  @override
  String get maxBrightnessNever => 'Никогда';

  @override
  String get maxBrightnessAlways => 'Всегда';

  @override
  String get nameConflictStrategyRename => 'Переименовать';

  @override
  String get nameConflictStrategyReplace => 'Заменить';

  @override
  String get nameConflictStrategySkip => 'Пропустить';

  @override
  String get overlayHistogramNone => 'Откл.';

  @override
  String get overlayHistogramRGB => 'RGB';

  @override
  String get overlayHistogramLuminance => 'Яркость';

  @override
  String get subtitlePositionTop => 'Наверху';

  @override
  String get subtitlePositionBottom => 'Внизу';

  @override
  String get themeBrightnessLight => 'Светлая';

  @override
  String get themeBrightnessDark => 'Тёмная';

  @override
  String get themeBrightnessBlack => 'Чёрная';

  @override
  String get unitSystemMetric => 'Метрические';

  @override
  String get unitSystemImperial => 'Имперские';

  @override
  String get vaultLockTypePattern => 'Графический ключ';

  @override
  String get vaultLockTypePin => 'Пин-код';

  @override
  String get vaultLockTypePassword => 'Пароль';

  @override
  String get settingsVideoEnablePip => 'Картинка в картинке';

  @override
  String get videoControlsPlayOutside => 'Открыть в другом видеоплеере';

  @override
  String get videoLoopModeNever => 'Никогда';

  @override
  String get videoLoopModeShortOnly => 'Только для коротких видео';

  @override
  String get videoLoopModeAlways => 'Всегда';

  @override
  String get videoPlaybackSkip => 'Пропустить';

  @override
  String get videoPlaybackMuted => 'Играть без звука';

  @override
  String get videoPlaybackWithSound => 'Играть со звуком';

  @override
  String get videoResumptionModeNever => 'Никогда';

  @override
  String get videoResumptionModeAlways => 'Всегда';

  @override
  String get viewerTransitionSlide => 'Скольжение';

  @override
  String get viewerTransitionParallax => 'Параллакс';

  @override
  String get viewerTransitionFade => 'Затухание';

  @override
  String get viewerTransitionZoomIn => 'Приближение';

  @override
  String get viewerTransitionNone => 'Нет';

  @override
  String get wallpaperTargetHome => 'Домашний экран';

  @override
  String get wallpaperTargetLock => 'Экран блокировки';

  @override
  String get wallpaperTargetHomeLock => 'Домашний экран и экран блокировки';

  @override
  String get widgetDisplayedItemRandom => 'Произвольные';

  @override
  String get widgetDisplayedItemMostRecent => 'Недавние';

  @override
  String get widgetOpenPageHome => 'Открыть главную страницу';

  @override
  String get widgetOpenPageCollection => 'Открыть коллекцию';

  @override
  String get widgetOpenPageViewer => 'Просмотр текущего';

  @override
  String get widgetTapUpdateWidget => 'Обновить виджет';

  @override
  String get storageVolumeDescriptionFallbackPrimary => 'Внутренняя память';

  @override
  String get storageVolumeDescriptionFallbackNonPrimary => 'SD-карта';

  @override
  String get rootDirectoryDescription => 'корневой каталог';

  @override
  String otherDirectoryDescription(String name) {
    return 'каталог «$name»';
  }

  @override
  String storageAccessDialogMessage(String directory, String volume) {
    return 'Пожалуйста, выберите $directory на накопителе «$volume» на следующем экране, чтобы предоставить этому приложению доступ к нему.';
  }

  @override
  String restrictedAccessDialogMessage(String directory, String volume) {
    return 'Этому приложению не разрешается изменять файлы в каталоге $directory накопителя «$volume».\n\nПожалуйста, используйте предустановленный файловый менеджер или галерею, чтобы переместить объекты в другой каталог.';
  }

  @override
  String notEnoughSpaceDialogMessage(String neededSize, String freeSize, String volume) {
    return 'Для завершения этой операции требуется $neededSize свободного места на «$volume», но осталось только $freeSize.';
  }

  @override
  String get missingSystemFilePickerDialogMessage => 'Системное приложение выбора файлов отсутствует или отключено. Пожалуйста, включите его и повторите попытку.';

  @override
  String unsupportedTypeDialogMessage(int count, String types) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Эта операция не поддерживается для объектов следующих форматов: $types.',
      one: 'Эта операция не поддерживается для объектов следующего формата: $types.',
    );
    return '$_temp0';
  }

  @override
  String get nameConflictDialogSingleSourceMessage => 'Некоторые файлы в папке назначения имеют одно и то же имя.';

  @override
  String get nameConflictDialogMultipleSourceMessage => 'Некоторые файлы имеют одно и то же имя.';

  @override
  String get addShortcutDialogLabel => 'Название ярлыка';

  @override
  String get addShortcutButtonLabel => 'СОЗДАТЬ';

  @override
  String get noMatchingAppDialogMessage => 'Нет приложений, которые могли бы с этим справиться.';

  @override
  String binEntriesConfirmationDialogMessage(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Переместить эти $countString объектов в корзину?',
      few: 'Переместить эти $countString объекта в корзину?',
      one: 'Переместить этот объект в корзину?',
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
      other: 'Вы уверены, что хотите удалить эти $countString объектов?',
      few: 'Вы уверены, что хотите удалить эти $countString объекта?',
      one: 'Вы уверены, что хотите удалить этот объект?',
    );
    return '$_temp0';
  }

  @override
  String get moveUndatedConfirmationDialogMessage => 'Сохранить даты элементов, прежде чем продолжить?';

  @override
  String get moveUndatedConfirmationDialogSetDate => 'Установить дату';

  @override
  String videoResumeDialogMessage(String time) {
    return 'Хотите ли вы возобновить воспроизведение на $time?';
  }

  @override
  String get videoStartOverButtonLabel => 'ВОСПРОИЗВЕСТИ СНАЧАЛА';

  @override
  String get videoResumeButtonLabel => 'ПРОДОЛЖИТЬ';

  @override
  String get setCoverDialogLatest => 'Последний объект';

  @override
  String get setCoverDialogAuto => 'Авто';

  @override
  String get setCoverDialogCustom => 'Собственная';

  @override
  String get hideFilterConfirmationDialogMessage => 'Соответствующие фотографии и видео будут скрыты из вашей коллекции. Вы можете показать их снова в настройках в разделе «Конфиденциальность».\n\nВы уверены, что хотите их скрыть?';

  @override
  String get newAlbumDialogTitle => 'Новый альбом';

  @override
  String get newAlbumDialogNameLabel => 'Название альбома';

  @override
  String get newAlbumDialogAlbumAlreadyExistsHelper => 'Альбом уже существует';

  @override
  String get newAlbumDialogNameLabelAlreadyExistsHelper => 'Каталог уже существует';

  @override
  String get newAlbumDialogStorageLabel => 'Накопитель:';

  @override
  String get newDynamicAlbumDialogTitle => 'Новый динамический альбом';

  @override
  String get dynamicAlbumAlreadyExists => 'Динамический альбом уже существует';

  @override
  String get newVaultWarningDialogMessage => 'Элементы внутри хранилищ доступны только для этого приложения, и никакого другого.\n\nЕсли вы удалите приложение или очистите его данные, то вы потеряете все содержимое внутри хранилищ.';

  @override
  String get newVaultDialogTitle => 'Новое хранилище';

  @override
  String get configureVaultDialogTitle => 'Настроить хранилище';

  @override
  String get vaultDialogLockModeWhenScreenOff => 'Блокировать при выключении экрана';

  @override
  String get vaultDialogLockTypeLabel => 'Тип защиты';

  @override
  String get patternDialogEnter => 'Введите ключ';

  @override
  String get patternDialogConfirm => 'Подтвердите ключ';

  @override
  String get pinDialogEnter => 'Введите пин-код';

  @override
  String get pinDialogConfirm => 'Подтвердите пин-код';

  @override
  String get passwordDialogEnter => 'Введите пароль';

  @override
  String get passwordDialogConfirm => 'Подтвердите пароль';

  @override
  String get authenticateToConfigureVault => 'Аутентифицируйтесь чтобы настроить хранилище';

  @override
  String get authenticateToUnlockVault => 'Аутентифицируйтесь чтобы разблокировать хранилище';

  @override
  String get vaultBinUsageDialogMessage => 'Некоторые из хранилищ используют корзину.';

  @override
  String get renameAlbumDialogLabel => 'Новое название';

  @override
  String get renameAlbumDialogLabelAlreadyExistsHelper => 'Каталог уже существует';

  @override
  String get renameEntrySetPageTitle => 'Переименовать';

  @override
  String get renameEntrySetPagePatternFieldLabel => 'Образец наименования';

  @override
  String get renameEntrySetPageInsertTooltip => 'Вставить поле';

  @override
  String get renameEntrySetPagePreviewSectionTitle => 'Предпросмотр';

  @override
  String get renameProcessorCounter => 'Счётчик';

  @override
  String get renameProcessorHash => 'Хэш';

  @override
  String get renameProcessorName => 'Название';

  @override
  String deleteSingleAlbumConfirmationDialogMessage(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Удалить этот альбом и $countString элементов в нем?',
      one: 'Удалить этот альбом и элемент в нем?',
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
      other: 'Удалить эти альбомы и $countString элементов в них?',
      one: 'Удалить эти альбомы и элемент в них?',
    );
    return '$_temp0';
  }

  @override
  String get exportEntryDialogFormat => 'Формат:';

  @override
  String get exportEntryDialogWidth => 'Ширина';

  @override
  String get exportEntryDialogHeight => 'Высота';

  @override
  String get exportEntryDialogQuality => 'Качество';

  @override
  String get exportEntryDialogWriteMetadata => 'Запись метаданных';

  @override
  String get renameEntryDialogLabel => 'Новое название';

  @override
  String get editEntryDialogCopyFromItem => 'Скопировать из другого объекта';

  @override
  String get editEntryDialogTargetFieldsHeader => 'Поля для изменения';

  @override
  String get editEntryDateDialogTitle => 'Дата и время';

  @override
  String get editEntryDateDialogSetCustom => 'Установить дату';

  @override
  String get editEntryDateDialogCopyField => 'Копировать с другой даты';

  @override
  String get editEntryDateDialogExtractFromTitle => 'Извлечь из названия';

  @override
  String get editEntryDateDialogShift => 'Сдвиг';

  @override
  String get editEntryDateDialogSourceFileModifiedDate => 'Дата изменения файла';

  @override
  String get durationDialogHours => 'Часов';

  @override
  String get durationDialogMinutes => 'Минут';

  @override
  String get durationDialogSeconds => 'Секунд';

  @override
  String get editEntryLocationDialogTitle => 'Местоположение';

  @override
  String get editEntryLocationDialogSetCustom => 'Редактировать местоположение';

  @override
  String get editEntryLocationDialogChooseOnMap => 'Выбрать на карте';

  @override
  String get editEntryLocationDialogImportGpx => 'Импорт GPX';

  @override
  String get editEntryLocationDialogLatitude => 'Широта';

  @override
  String get editEntryLocationDialogLongitude => 'Долгота';

  @override
  String get editEntryLocationDialogTimeShift => 'Сдвиг времени';

  @override
  String get locationPickerUseThisLocationButton => 'Использовать это местоположение';

  @override
  String get editEntryRatingDialogTitle => 'Рейтинг';

  @override
  String get removeEntryMetadataDialogTitle => 'Удаление метаданных';

  @override
  String get removeEntryMetadataDialogAll => 'Все';

  @override
  String get removeEntryMetadataDialogMore => 'Дополнительно';

  @override
  String get removeEntryMetadataMotionPhotoXmpWarningDialogMessage => 'Для воспроизведения видео внутри этой живой фотографии требуется XMP профиль.\n\nВы уверены, что хотите удалить его?';

  @override
  String get videoSpeedDialogLabel => 'Скорость воспроизведения';

  @override
  String get videoStreamSelectionDialogVideo => 'Видео';

  @override
  String get videoStreamSelectionDialogAudio => 'Аудио';

  @override
  String get videoStreamSelectionDialogText => 'Субтитры';

  @override
  String get videoStreamSelectionDialogOff => 'Отключено';

  @override
  String get videoStreamSelectionDialogTrack => 'Дорожка';

  @override
  String get videoStreamSelectionDialogNoSelection => 'Других дорожек нет.';

  @override
  String get genericSuccessFeedback => 'Выполнено!';

  @override
  String get genericFailureFeedback => 'Не удалось';

  @override
  String get genericDangerWarningDialogMessage => 'Вы уверены?';

  @override
  String get tooManyItemsErrorDialogMessage => 'Попробуйте снова с меньшим числом элементов.';

  @override
  String get menuActionConfigureView => 'Вид';

  @override
  String get menuActionSelect => 'Выбрать';

  @override
  String get menuActionSelectAll => 'Выбрать все';

  @override
  String get menuActionSelectNone => 'Снять выделение';

  @override
  String get menuActionMap => 'Карта';

  @override
  String get menuActionSlideshow => 'Слайд-шоу';

  @override
  String get menuActionStats => 'Статистика';

  @override
  String get viewDialogSortSectionTitle => 'Сортировка';

  @override
  String get viewDialogGroupSectionTitle => 'Группировка';

  @override
  String get viewDialogLayoutSectionTitle => 'Макет';

  @override
  String get viewDialogReverseSortOrder => 'Обратный порядок сортировки';

  @override
  String get tileLayoutMosaic => 'Мозайка';

  @override
  String get tileLayoutGrid => 'Сетка';

  @override
  String get tileLayoutList => 'Список';

  @override
  String get castDialogTitle => 'Устройства трансляции';

  @override
  String get coverDialogTabCover => 'Обложка';

  @override
  String get coverDialogTabApp => 'Приложение';

  @override
  String get coverDialogTabColor => 'Цвет';

  @override
  String get appPickDialogTitle => 'Выберите приложение';

  @override
  String get appPickDialogNone => 'Ничего';

  @override
  String get aboutPageTitle => 'О нас';

  @override
  String get aboutLinkLicense => 'Лицензия';

  @override
  String get aboutLinkPolicy => 'Политика конфиденциальности';

  @override
  String get aboutBugSectionTitle => 'Сообщить об ошибке';

  @override
  String get aboutBugSaveLogInstruction => 'Сохраните логи приложения в файл';

  @override
  String get aboutBugCopyInfoInstruction => 'Скопируйте системную информацию';

  @override
  String get aboutBugCopyInfoButton => 'Скопировать';

  @override
  String get aboutBugReportInstruction => 'Отправьте отчёт об ошибке на GitHub вместе с логами и системной информацией';

  @override
  String get aboutBugReportButton => 'Отправить';

  @override
  String get aboutDataUsageSectionTitle => 'Использование данных';

  @override
  String get aboutDataUsageData => 'Данные';

  @override
  String get aboutDataUsageCache => 'Кэш';

  @override
  String get aboutDataUsageDatabase => 'База данных';

  @override
  String get aboutDataUsageMisc => 'Разнообразное';

  @override
  String get aboutDataUsageInternal => 'Внутреннее';

  @override
  String get aboutDataUsageExternal => 'Внешнее';

  @override
  String get aboutDataUsageClearCache => 'Очистить кэш';

  @override
  String get aboutCreditsSectionTitle => 'Благодарности';

  @override
  String get aboutCreditsWorldAtlas1 => 'Это приложение использует файл TopoJSON из';

  @override
  String get aboutCreditsWorldAtlas2 => 'под лицензией ISC.';

  @override
  String get aboutTranslatorsSectionTitle => 'Переводчики';

  @override
  String get aboutLicensesSectionTitle => 'Лицензии с открытым исходным кодом';

  @override
  String get aboutLicensesBanner => 'Это приложение использует следующие пакеты и библиотеки с открытым исходным кодом.';

  @override
  String get aboutLicensesAndroidLibrariesSectionTitle => 'Библиотеки Android';

  @override
  String get aboutLicensesFlutterPluginsSectionTitle => 'Плагины Flutter';

  @override
  String get aboutLicensesFlutterPackagesSectionTitle => 'Пакеты Flutter';

  @override
  String get aboutLicensesDartPackagesSectionTitle => 'Пакеты Dart';

  @override
  String get aboutLicensesShowAllButtonLabel => 'Показать все лицензии';

  @override
  String get policyPageTitle => 'Политика конфиденциальности';

  @override
  String get collectionPageTitle => 'Коллекция';

  @override
  String get collectionPickPageTitle => 'Выбрать';

  @override
  String get collectionSelectPageTitle => 'Выберите объекты';

  @override
  String get collectionActionShowTitleSearch => 'Показать фильтр заголовка';

  @override
  String get collectionActionHideTitleSearch => 'Скрыть фильтр заголовка';

  @override
  String get collectionActionAddDynamicAlbum => 'Добавить динамический альбом';

  @override
  String get collectionActionAddShortcut => 'Добавить ярлык';

  @override
  String get collectionActionSetHome => 'Установить как главную';

  @override
  String get collectionActionEmptyBin => 'Очистить корзину';

  @override
  String get collectionActionCopy => 'Скопировать в альбом';

  @override
  String get collectionActionMove => 'Переместить в альбом';

  @override
  String get collectionActionRescan => 'Пересканировать';

  @override
  String get collectionActionEdit => 'Изменить';

  @override
  String get collectionSearchTitlesHintText => 'Поиск заголовков';

  @override
  String get collectionGroupAlbum => 'По альбому';

  @override
  String get collectionGroupMonth => 'По месяцу';

  @override
  String get collectionGroupDay => 'По дню';

  @override
  String get collectionGroupNone => 'Не группировать';

  @override
  String get sectionUnknown => 'Неизвестно';

  @override
  String get dateToday => 'Сегодня';

  @override
  String get dateYesterday => 'Вчера';

  @override
  String get dateThisMonth => 'В этом месяце';

  @override
  String collectionDeleteFailureFeedback(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Не удалось удалить $countString объектов',
      few: 'Не удалось удалить $countString объекта',
      one: 'Не удалось удалить 1 объект',
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
      other: 'Не удалось скопировать $countString объектов',
      few: 'Не удалось скопировать $countString объекта',
      one: 'Не удалось скопировать 1 объект',
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
      other: 'Не удалось переместить $countString объектов',
      few: 'Не удалось переместить $countString объекта',
      one: 'Не удалось переместить 1 объект',
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
      other: 'Не удалось переименовать $countString объектов',
      few: 'Не удалось переименовать $countString объекта',
      one: 'Не удалось переименовать 1 объект',
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
      other: 'Не удалось изменить $countString объектов',
      few: 'Не удалось изменить $countString объекта',
      one: 'Не удалось изменить 1 объект',
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
      other: 'Не удалось экспортировать $countString страниц',
      few: 'Не удалось экспортировать $countString страницы',
      one: 'Не удалось экспортировать 1 страницу',
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
      other: 'Скопировано $countString объектов',
      few: 'Скопировано $countString объекта',
      one: 'Скопирован 1 объект',
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
      other: 'Перемещено $countString объектов',
      few: 'Перемещено $countString объекта',
      one: 'Перемещён 1 объект',
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
      other: 'Переименовано $countString объектов',
      few: 'Переименовано $countString объекта',
      one: 'Переименован 1 объект',
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
      other: 'Изменено $countString объектов',
      few: 'Изменено $countString объекта',
      one: 'Изменён 1 объект',
    );
    return '$_temp0';
  }

  @override
  String get collectionEmptyFavourites => 'Нет избранных';

  @override
  String get collectionEmptyVideos => 'Нет видео';

  @override
  String get collectionEmptyImages => 'Нет изображений';

  @override
  String get collectionEmptyGrantAccessButtonLabel => 'Предоставить доступ';

  @override
  String get collectionSelectSectionTooltip => 'Выбрать раздел';

  @override
  String get collectionDeselectSectionTooltip => 'Снять выбор с раздела';

  @override
  String get drawerAboutButton => 'О нас';

  @override
  String get drawerSettingsButton => 'Настройки';

  @override
  String get drawerCollectionAll => 'Вся коллекция';

  @override
  String get drawerCollectionFavourites => 'Избранное';

  @override
  String get drawerCollectionImages => 'Изображения';

  @override
  String get drawerCollectionVideos => 'Видео';

  @override
  String get drawerCollectionAnimated => 'GIF';

  @override
  String get drawerCollectionMotionPhotos => 'Живые фото';

  @override
  String get drawerCollectionPanoramas => 'Панорамы';

  @override
  String get drawerCollectionRaws => 'RAW';

  @override
  String get drawerCollectionSphericalVideos => '360° видео';

  @override
  String get drawerAlbumPage => 'Альбомы';

  @override
  String get drawerCountryPage => 'Страны';

  @override
  String get drawerPlacePage => 'Локации';

  @override
  String get drawerTagPage => 'Теги';

  @override
  String get sortByDate => 'По дате';

  @override
  String get sortByName => 'По названию';

  @override
  String get sortByItemCount => 'По количеству объектов';

  @override
  String get sortBySize => 'По размеру';

  @override
  String get sortByAlbumFileName => 'По имени альбома и файла';

  @override
  String get sortByRating => 'По рейтингу';

  @override
  String get sortByDuration => 'По продолжительности';

  @override
  String get sortOrderNewestFirst => 'Сначала новые';

  @override
  String get sortOrderOldestFirst => 'Сначала старые';

  @override
  String get sortOrderAtoZ => 'От А до Я';

  @override
  String get sortOrderZtoA => 'От Я до А';

  @override
  String get sortOrderHighestFirst => 'Сначала с высоким';

  @override
  String get sortOrderLowestFirst => 'Сначала с низким';

  @override
  String get sortOrderLargestFirst => 'Сначала большие';

  @override
  String get sortOrderSmallestFirst => 'Сначала маленькие';

  @override
  String get sortOrderShortestFirst => 'Сначала самый короткий';

  @override
  String get sortOrderLongestFirst => 'Сначала самый длинный';

  @override
  String get albumGroupTier => 'По уровню';

  @override
  String get albumGroupType => 'По типу';

  @override
  String get albumGroupVolume => 'По накопителю';

  @override
  String get albumGroupNone => 'Не группировать';

  @override
  String get albumMimeTypeMixed => 'Разное';

  @override
  String get albumPickPageTitleCopy => 'Копировать в альбом';

  @override
  String get albumPickPageTitleExport => 'Экспорт в альбом';

  @override
  String get albumPickPageTitleMove => 'Переместить в альбом';

  @override
  String get albumPickPageTitlePick => 'Выберите альбом';

  @override
  String get albumCamera => 'Камера';

  @override
  String get albumDownload => 'Загрузки';

  @override
  String get albumScreenshots => 'Скриншоты';

  @override
  String get albumScreenRecordings => 'Записи экрана';

  @override
  String get albumVideoCaptures => 'Видеозаписи';

  @override
  String get albumPageTitle => 'Альбомы';

  @override
  String get albumEmpty => 'Нет альбомов';

  @override
  String get createAlbumButtonLabel => 'СОЗДАТЬ';

  @override
  String get newFilterBanner => 'новый';

  @override
  String get countryPageTitle => 'Страны';

  @override
  String get countryEmpty => 'Нет стран';

  @override
  String get statePageTitle => 'Регионы';

  @override
  String get stateEmpty => 'Нет регионов';

  @override
  String get placePageTitle => 'Локации';

  @override
  String get placeEmpty => 'Нет локаций';

  @override
  String get tagPageTitle => 'Теги';

  @override
  String get tagEmpty => 'Нет тегов';

  @override
  String get binPageTitle => 'Корзина';

  @override
  String get explorerPageTitle => 'Проводник';

  @override
  String get explorerActionSelectStorageVolume => 'Выбрать хранилище';

  @override
  String get selectStorageVolumeDialogTitle => 'Выбрать хранилище';

  @override
  String get searchCollectionFieldHint => 'Поиск по коллекции';

  @override
  String get searchRecentSectionTitle => 'Недавние';

  @override
  String get searchDateSectionTitle => 'Дата';

  @override
  String get searchAlbumsSectionTitle => 'Альбомы';

  @override
  String get searchCountriesSectionTitle => 'Страны';

  @override
  String get searchStatesSectionTitle => 'Регионы';

  @override
  String get searchPlacesSectionTitle => 'Локации';

  @override
  String get searchTagsSectionTitle => 'Теги';

  @override
  String get searchRatingSectionTitle => 'Рейтинги';

  @override
  String get searchMetadataSectionTitle => 'Метаданные';

  @override
  String get settingsPageTitle => 'Настройки';

  @override
  String get settingsSystemDefault => 'Как в системе';

  @override
  String get settingsDefault => 'По умолчанию';

  @override
  String get settingsDisabled => 'Выключено';

  @override
  String get settingsAskEverytime => 'Спрашивать каждый раз';

  @override
  String get settingsModificationWarningDialogMessage => 'Другие настройки будут изменены.';

  @override
  String get settingsSearchFieldLabel => 'Поиск настроек';

  @override
  String get settingsSearchEmpty => 'Нет соответствующих настроек';

  @override
  String get settingsActionExport => 'Экспорт';

  @override
  String get settingsActionExportDialogTitle => 'Экспорт';

  @override
  String get settingsActionImport => 'Импорт';

  @override
  String get settingsActionImportDialogTitle => 'Импорт';

  @override
  String get appExportCovers => 'Обложки';

  @override
  String get appExportDynamicAlbums => 'Динамические альбомы';

  @override
  String get appExportFavourites => 'Избранное';

  @override
  String get appExportSettings => 'Настройки';

  @override
  String get settingsNavigationSectionTitle => 'Навигация';

  @override
  String get settingsHomeTile => 'Домашний каталог';

  @override
  String get settingsHomeDialogTitle => 'Домашний каталог';

  @override
  String get setHomeCustom => 'По своему';

  @override
  String get settingsShowBottomNavigationBar => 'Показать нижнюю панель навигации';

  @override
  String get settingsKeepScreenOnTile => 'Держать экран включенным';

  @override
  String get settingsKeepScreenOnDialogTitle => 'Держать экран включенным';

  @override
  String get settingsDoubleBackExit => 'Дважды нажмите «Назад», чтобы выйти';

  @override
  String get settingsConfirmationTile => 'Диалоги подтверждения';

  @override
  String get settingsConfirmationDialogTitle => 'Диалоги подтверждения';

  @override
  String get settingsConfirmationBeforeDeleteItems => 'Спросить, прежде чем удалять объекты навсегда';

  @override
  String get settingsConfirmationBeforeMoveToBinItems => 'Спросить, прежде чем перемещать объекты в корзину';

  @override
  String get settingsConfirmationBeforeMoveUndatedItems => 'Спросить, прежде чем перемещать объекты без даты в метаданных';

  @override
  String get settingsConfirmationAfterMoveToBinItems => 'Показывать сообщение после перемещения в корзину';

  @override
  String get settingsConfirmationVaultDataLoss => 'Показывать предупреждение при утере данных хранилища';

  @override
  String get settingsNavigationDrawerTile => 'Навигационное меню';

  @override
  String get settingsNavigationDrawerEditorPageTitle => 'Навигационное меню';

  @override
  String get settingsNavigationDrawerBanner => 'Нажмите и удерживайте, чтобы переместить и изменить порядок пунктов меню.';

  @override
  String get settingsNavigationDrawerTabTypes => 'Типы';

  @override
  String get settingsNavigationDrawerTabAlbums => 'Альбомы';

  @override
  String get settingsNavigationDrawerTabPages => 'Страницы';

  @override
  String get settingsNavigationDrawerAddAlbum => 'Добавить альбом';

  @override
  String get settingsThumbnailSectionTitle => 'Эскизы';

  @override
  String get settingsThumbnailOverlayTile => 'Наложение';

  @override
  String get settingsThumbnailOverlayPageTitle => 'Наложение';

  @override
  String get settingsThumbnailShowHdrIcon => 'Показать значок HDR';

  @override
  String get settingsThumbnailShowFavouriteIcon => 'Показать значок избранного';

  @override
  String get settingsThumbnailShowTagIcon => 'Показать значок тега';

  @override
  String get settingsThumbnailShowLocationIcon => 'Показать значок местоположения';

  @override
  String get settingsThumbnailShowMotionPhotoIcon => 'Показать значок «живого фото»';

  @override
  String get settingsThumbnailShowRating => 'Показать рейтинг';

  @override
  String get settingsThumbnailShowRawIcon => 'Показать значок RAW-файла';

  @override
  String get settingsThumbnailShowVideoDuration => 'Показать продолжительность видео';

  @override
  String get settingsCollectionQuickActionsTile => 'Быстрые действия';

  @override
  String get settingsCollectionQuickActionEditorPageTitle => 'Быстрые действия';

  @override
  String get settingsCollectionQuickActionTabBrowsing => 'Просмотр';

  @override
  String get settingsCollectionQuickActionTabSelecting => 'Выбор';

  @override
  String get settingsCollectionBrowsingQuickActionEditorBanner => 'Нажмите и удерживайте для перемещения кнопок и выбора действий, отображаемых при просмотре объектов.';

  @override
  String get settingsCollectionSelectionQuickActionEditorBanner => 'Нажмите и удерживайте, чтобы переместить кнопки и выбрать, какие действия будут отображаться при выборе элементов.';

  @override
  String get settingsCollectionBurstPatternsTile => 'Шаблоны вспышки';

  @override
  String get settingsCollectionBurstPatternsNone => 'Без вспышки';

  @override
  String get settingsViewerSectionTitle => 'Просмотрщик';

  @override
  String get settingsViewerGestureSideTapNext => 'Нажатие на край экрана для перехода назад/вперед';

  @override
  String get settingsViewerUseCutout => 'Использовать область выреза';

  @override
  String get settingsViewerMaximumBrightness => 'Максимальная яркость';

  @override
  String get settingsMotionPhotoAutoPlay => 'Автовоспроизведение «живых фото»';

  @override
  String get settingsImageBackground => 'Фон изображения';

  @override
  String get settingsViewerQuickActionsTile => 'Быстрые действия';

  @override
  String get settingsViewerQuickActionEditorPageTitle => 'Быстрые действия';

  @override
  String get settingsViewerQuickActionEditorBanner => 'Нажмите и удерживайте для перемещения кнопок и выбора действий, отображаемых в просмотрщике.';

  @override
  String get settingsViewerQuickActionEditorDisplayedButtonsSectionTitle => 'Отображаемые кнопки';

  @override
  String get settingsViewerQuickActionEditorAvailableButtonsSectionTitle => 'Доступные кнопки';

  @override
  String get settingsViewerQuickActionEmpty => 'Нет кнопок';

  @override
  String get settingsViewerOverlayTile => 'Наложение';

  @override
  String get settingsViewerOverlayPageTitle => 'Наложение';

  @override
  String get settingsViewerShowOverlayOnOpening => 'Показать наложение при открытии';

  @override
  String get settingsViewerShowHistogram => 'Показать гистограмму';

  @override
  String get settingsViewerShowMinimap => 'Показать миникарту';

  @override
  String get settingsViewerShowInformation => 'Показать информацию';

  @override
  String get settingsViewerShowInformationSubtitle => 'Показать название, дату, местоположение и т.д.';

  @override
  String get settingsViewerShowRatingTags => 'Показать рейтинг и теги';

  @override
  String get settingsViewerShowShootingDetails => 'Показать детали съёмки';

  @override
  String get settingsViewerShowDescription => 'Показать описание';

  @override
  String get settingsViewerShowOverlayThumbnails => 'Показать эскизы';

  @override
  String get settingsViewerEnableOverlayBlurEffect => 'Наложение эффекта размытия';

  @override
  String get settingsViewerSlideshowTile => 'Слайд-шоу';

  @override
  String get settingsViewerSlideshowPageTitle => 'Слайд-шоу';

  @override
  String get settingsSlideshowRepeat => 'Повтор';

  @override
  String get settingsSlideshowShuffle => 'Вперемешку';

  @override
  String get settingsSlideshowFillScreen => 'Полный экран';

  @override
  String get settingsSlideshowAnimatedZoomEffect => 'Анимация зум эффекта';

  @override
  String get settingsSlideshowTransitionTile => 'Эффект перехода';

  @override
  String get settingsSlideshowIntervalTile => 'Интервал';

  @override
  String get settingsSlideshowVideoPlaybackTile => 'Проигрывание видео';

  @override
  String get settingsSlideshowVideoPlaybackDialogTitle => 'Проигрывание Видео';

  @override
  String get settingsVideoPageTitle => 'Настройки видео';

  @override
  String get settingsVideoSectionTitle => 'Видео';

  @override
  String get settingsVideoShowVideos => 'Показать видео';

  @override
  String get settingsVideoPlaybackTile => 'Воспроизведение видео';

  @override
  String get settingsVideoPlaybackPageTitle => 'Воспроизведение видео';

  @override
  String get settingsVideoEnableHardwareAcceleration => 'Аппаратное ускорение';

  @override
  String get settingsVideoAutoPlay => 'Автозапуск воспроизведения';

  @override
  String get settingsVideoLoopModeTile => 'Циклический режим';

  @override
  String get settingsVideoLoopModeDialogTitle => 'Цикличный режим';

  @override
  String get settingsVideoResumptionModeTile => 'Возобновить воспроизведение';

  @override
  String get settingsVideoResumptionModeDialogTitle => 'Возобновить воспроизведение';

  @override
  String get settingsVideoBackgroundMode => 'Фоновый режим';

  @override
  String get settingsVideoBackgroundModeDialogTitle => 'Фоновый режим';

  @override
  String get settingsVideoControlsTile => 'Элементы управления';

  @override
  String get settingsVideoControlsPageTitle => 'Элементы управления';

  @override
  String get settingsVideoButtonsTile => 'Кнопки';

  @override
  String get settingsVideoGestureDoubleTapTogglePlay => 'Двойное нажатие для воспроизведения/паузы';

  @override
  String get settingsVideoGestureSideDoubleTapSeek => 'Двойное нажатие на края экрана для перехода назад/вперёд';

  @override
  String get settingsVideoGestureVerticalDragBrightnessVolume => 'Проведите пальцем вверх или вниз чтобы изменить яркость/громкость';

  @override
  String get settingsSubtitleThemeTile => 'Субтитры';

  @override
  String get settingsSubtitleThemePageTitle => 'Субтитры';

  @override
  String get settingsSubtitleThemeSample => 'Образец.';

  @override
  String get settingsSubtitleThemeTextAlignmentTile => 'Выравнивание текста';

  @override
  String get settingsSubtitleThemeTextAlignmentDialogTitle => 'Выравнивание текста';

  @override
  String get settingsSubtitleThemeTextPositionTile => 'Положение текста';

  @override
  String get settingsSubtitleThemeTextPositionDialogTitle => 'Положение текста';

  @override
  String get settingsSubtitleThemeTextSize => 'Размер текста';

  @override
  String get settingsSubtitleThemeShowOutline => 'Показать контур и тень';

  @override
  String get settingsSubtitleThemeTextColor => 'Цвет текста';

  @override
  String get settingsSubtitleThemeTextOpacity => 'Непрозрачность текста';

  @override
  String get settingsSubtitleThemeBackgroundColor => 'Цвет фона';

  @override
  String get settingsSubtitleThemeBackgroundOpacity => 'Непрозрачность фона';

  @override
  String get settingsSubtitleThemeTextAlignmentLeft => 'По левой стороне';

  @override
  String get settingsSubtitleThemeTextAlignmentCenter => 'По центру';

  @override
  String get settingsSubtitleThemeTextAlignmentRight => 'По правой стороне';

  @override
  String get settingsPrivacySectionTitle => 'Конфиденциальность';

  @override
  String get settingsAllowInstalledAppAccess => 'Разрешить доступ к библиотеке приложения';

  @override
  String get settingsAllowInstalledAppAccessSubtitle => 'Используется для улучшения отображения альбомов';

  @override
  String get settingsAllowErrorReporting => 'Разрешить анонимную отправку логов';

  @override
  String get settingsSaveSearchHistory => 'Сохранять историю поиска';

  @override
  String get settingsEnableBin => 'Использовать корзину';

  @override
  String get settingsEnableBinSubtitle => 'Хранить удалённые объекты в течение 30 дней';

  @override
  String get settingsDisablingBinWarningDialogMessage => 'Элементы в корзине будут удалены навсегда.';

  @override
  String get settingsAllowMediaManagement => 'Разрешить управление медиа';

  @override
  String get settingsHiddenItemsTile => 'Скрытые объекты';

  @override
  String get settingsHiddenItemsPageTitle => 'Скрытые объекты';

  @override
  String get settingsHiddenFiltersBanner => 'Фотографии и видео, соответствующие скрытым фильтрам, не появятся в вашей коллекции.';

  @override
  String get settingsHiddenFiltersEmpty => 'Нет скрытых фильтров';

  @override
  String get settingsStorageAccessTile => 'Доступ к хранилищу';

  @override
  String get settingsStorageAccessPageTitle => 'Доступ к хранилищу';

  @override
  String get settingsStorageAccessBanner => 'Некоторые каталоги требуют обязательного предоставления доступа для изменения файлов в них. Вы можете просмотреть здесь каталоги, к которым вы ранее предоставили доступ.';

  @override
  String get settingsStorageAccessEmpty => 'Нет прав доступа';

  @override
  String get settingsStorageAccessRevokeTooltip => 'Отменить';

  @override
  String get settingsAccessibilitySectionTitle => 'Специальные возможности';

  @override
  String get settingsRemoveAnimationsTile => 'Удалить анимацию';

  @override
  String get settingsRemoveAnimationsDialogTitle => 'Удалить анимацию';

  @override
  String get settingsTimeToTakeActionTile => 'Время на выполнение действия';

  @override
  String get settingsAccessibilityShowPinchGestureAlternatives => 'Показать альтернативные жесты щипка';

  @override
  String get settingsDisplaySectionTitle => 'Отображение';

  @override
  String get settingsThemeBrightnessTile => 'Тема';

  @override
  String get settingsThemeBrightnessDialogTitle => 'Тема';

  @override
  String get settingsThemeColorHighlights => 'Цветовые акценты';

  @override
  String get settingsThemeEnableDynamicColor => 'Динамический цвет';

  @override
  String get settingsDisplayRefreshRateModeTile => 'Частота обновления экрана';

  @override
  String get settingsDisplayRefreshRateModeDialogTitle => 'Частота обновления';

  @override
  String get settingsDisplayUseTvInterface => 'Интерфейс Android TV';

  @override
  String get settingsLanguageSectionTitle => 'Язык и форматы';

  @override
  String get settingsLanguageTile => 'Язык';

  @override
  String get settingsLanguagePageTitle => 'Язык';

  @override
  String get settingsCoordinateFormatTile => 'Формат координат';

  @override
  String get settingsCoordinateFormatDialogTitle => 'Формат координат';

  @override
  String get settingsUnitSystemTile => 'Единицы измерения';

  @override
  String get settingsUnitSystemDialogTitle => 'Единицы измерения';

  @override
  String get settingsForceWesternArabicNumeralsTile => 'Принудительные арабские цифры';

  @override
  String get settingsScreenSaverPageTitle => 'Скринсейвер';

  @override
  String get settingsWidgetPageTitle => 'Фоторамка';

  @override
  String get settingsWidgetShowOutline => 'Выделение';

  @override
  String get settingsWidgetOpenPage => 'При нажатии на виджет';

  @override
  String get settingsWidgetDisplayedItem => 'Показывать';

  @override
  String get settingsCollectionTile => 'Коллекция';

  @override
  String get statsPageTitle => 'Статистика';

  @override
  String statsWithGps(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString объектов с местоположением',
      few: '$countString объекта с местоположением',
      one: '1 объект с местоположением',
    );
    return '$_temp0';
  }

  @override
  String get statsTopCountriesSectionTitle => 'Топ стран';

  @override
  String get statsTopStatesSectionTitle => 'Топ регионов';

  @override
  String get statsTopPlacesSectionTitle => 'Топ локаций';

  @override
  String get statsTopTagsSectionTitle => 'Топ тегов';

  @override
  String get statsTopAlbumsSectionTitle => 'Топ альбомов';

  @override
  String get viewerOpenPanoramaButtonLabel => 'ОТКРЫТЬ ПАНОРАМУ';

  @override
  String get viewerSetWallpaperButtonLabel => 'УСТАНОВИТЬ КАК ОБОИ';

  @override
  String get viewerErrorUnknown => 'Упс!';

  @override
  String get viewerErrorDoesNotExist => 'Файл больше не существует.';

  @override
  String get viewerInfoPageTitle => 'Информация';

  @override
  String get viewerInfoBackToViewerTooltip => 'Вернуться к просмотрщику';

  @override
  String get viewerInfoUnknown => 'неизвестный';

  @override
  String get viewerInfoLabelDescription => 'Описание';

  @override
  String get viewerInfoLabelTitle => 'Название';

  @override
  String get viewerInfoLabelDate => 'Дата';

  @override
  String get viewerInfoLabelResolution => 'Разрешение';

  @override
  String get viewerInfoLabelSize => 'Размер';

  @override
  String get viewerInfoLabelUri => 'Идентификатор';

  @override
  String get viewerInfoLabelPath => 'Расположение';

  @override
  String get viewerInfoLabelDuration => 'Продолжительность';

  @override
  String get viewerInfoLabelOwner => 'Владелец';

  @override
  String get viewerInfoLabelCoordinates => 'Координаты';

  @override
  String get viewerInfoLabelAddress => 'Адрес';

  @override
  String get mapStyleDialogTitle => 'Стиль карты';

  @override
  String get mapStyleTooltip => 'Выберите стиль карты';

  @override
  String get mapZoomInTooltip => 'Увеличить';

  @override
  String get mapZoomOutTooltip => 'Уменьшить';

  @override
  String get mapPointNorthUpTooltip => 'Повернуть на север';

  @override
  String get mapAttributionOsmData => 'Данные карты © [openstreetmap](https://www.openstreetmap.org/copyright) участники';

  @override
  String get mapAttributionOsmLiberty => 'Плитки от [OpenMapTiles](https://www.openmaptiles.org/), [CC BY](http://creativecommons.org/licenses/by/4.0) • Размещено на [OSM Americana](https://tile.ourmap.us)';

  @override
  String get mapAttributionOpenTopoMap => '[SRTM](https://www.earthdata.nasa.gov/sensors/srtm) | Плитки от [OpenTopoMap](https://opentopomap.org/), [CC BY-SA](https://creativecommons.org/licenses/by-sa/3.0/)';

  @override
  String get mapAttributionOsmHot => 'Плитки [HOT](https://www.hotosm.org/) • Размещена на [OSM France](https://openstreetmap.fr/)';

  @override
  String get mapAttributionStamen => 'Плитки [Stamen Design](https://stamen.com), [CC BY 3.0](https://creativecommons.org/licenses/by/3.0)';

  @override
  String get openMapPageTooltip => 'Просмотреть на странице карты';

  @override
  String get mapEmptyRegion => 'Нет изображений в этом регионе';

  @override
  String get viewerInfoOpenEmbeddedFailureFeedback => 'Не удалось извлечь встроенные данные';

  @override
  String get viewerInfoOpenLinkText => 'Открыть';

  @override
  String get viewerInfoViewXmlLinkText => 'Просмотр XML';

  @override
  String get viewerInfoSearchFieldLabel => 'Поиск метаданных';

  @override
  String get viewerInfoSearchEmpty => 'Нет подходящих ключей';

  @override
  String get viewerInfoSearchSuggestionDate => 'Дата и время';

  @override
  String get viewerInfoSearchSuggestionDescription => 'Описание';

  @override
  String get viewerInfoSearchSuggestionDimensions => 'Измерения';

  @override
  String get viewerInfoSearchSuggestionResolution => 'Разрешение';

  @override
  String get viewerInfoSearchSuggestionRights => 'Права';

  @override
  String get wallpaperUseScrollEffect => 'Эффект прокрутки на домашнем экране';

  @override
  String get tagEditorPageTitle => 'Изменить теги';

  @override
  String get tagEditorPageNewTagFieldLabel => 'Новый тег';

  @override
  String get tagEditorPageAddTagTooltip => 'Добавить тег';

  @override
  String get tagEditorSectionRecent => 'Недавние';

  @override
  String get tagEditorSectionPlaceholders => 'Закладки';

  @override
  String get tagEditorDiscardDialogMessage => 'Отменить изменения?';

  @override
  String get tagPlaceholderCountry => 'Страна';

  @override
  String get tagPlaceholderState => 'Регион';

  @override
  String get tagPlaceholderPlace => 'Локация';

  @override
  String get panoramaEnableSensorControl => 'Включить сенсорное управление';

  @override
  String get panoramaDisableSensorControl => 'Отключить сенсорное управление';

  @override
  String get sourceViewerPageTitle => 'Источник';

  @override
  String get filePickerShowHiddenFiles => 'Показывать скрытые файлы';

  @override
  String get filePickerDoNotShowHiddenFiles => 'Не показывать скрытые файлы';

  @override
  String get filePickerOpenFrom => 'Открыть';

  @override
  String get filePickerNoItems => 'Ничего нет';

  @override
  String get filePickerUseThisFolder => 'Использовать эту папку';
}
