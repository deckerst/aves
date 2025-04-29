// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appName => 'Aves';

  @override
  String get welcomeMessage => 'Ласкаво просимо до Aves';

  @override
  String get welcomeOptional => 'Необов\'язково';

  @override
  String get welcomeTermsToggle => 'Я погоджуюсь з умовами та положеннями';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count елементів',
      few: '$count елементи',
      one: '$count елемент',
    );
    return '$_temp0';
  }

  @override
  String columnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count стовпців',
      few: '$count стовпці',
      one: '$count стовпець',
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
      other: '$countString хвилин',
      few: '$countString хвилини',
      one: '$countString хвилина',
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
      other: '$countString днів',
      few: '$countString дні',
      one: '$countString день',
    );
    return '$_temp0';
  }

  @override
  String focalLength(String length) {
    return '$length мм';
  }

  @override
  String get applyButtonLabel => 'ЗАСТОСУВАТИ';

  @override
  String get createButtonLabel => 'CREATE';

  @override
  String get deleteButtonLabel => 'ВИДАЛИТИ';

  @override
  String get nextButtonLabel => 'ДАЛІ';

  @override
  String get showButtonLabel => 'ПОКАЗАТИ';

  @override
  String get hideButtonLabel => 'ПРИХОВАТИ';

  @override
  String get continueButtonLabel => 'ПРОДОВЖИТИ';

  @override
  String get saveCopyButtonLabel => 'ЗБЕРЕГТИ КОПІЮ';

  @override
  String get applyTooltip => 'Застосувати';

  @override
  String get cancelTooltip => 'Скасувати';

  @override
  String get changeTooltip => 'Змінити';

  @override
  String get clearTooltip => 'Очистити';

  @override
  String get previousTooltip => 'Попередній';

  @override
  String get nextTooltip => 'Далі';

  @override
  String get showTooltip => 'Показати';

  @override
  String get hideTooltip => 'Приховати';

  @override
  String get actionRemove => 'Видалити';

  @override
  String get resetTooltip => 'Скинути';

  @override
  String get saveTooltip => 'Зберегти';

  @override
  String get stopTooltip => 'Зупинити';

  @override
  String get pickTooltip => 'Вибрати';

  @override
  String get doubleBackExitMessage => 'Натисніть “назад” ще раз, щоб вийти.';

  @override
  String get doNotAskAgain => 'Не запитувати знову';

  @override
  String get sourceStateLoading => 'Завантаження';

  @override
  String get sourceStateCataloguing => 'Каталогізація';

  @override
  String get sourceStateLocatingCountries => 'Розташування країн';

  @override
  String get sourceStateLocatingPlaces => 'Розташування локацій';

  @override
  String get chipActionDelete => 'Видалити';

  @override
  String get chipActionRemove => 'видалити';

  @override
  String get chipActionShowCollection => 'Показати у Колекції';

  @override
  String get chipActionGoToAlbumPage => 'Показати в Альбомах';

  @override
  String get chipActionGoToCountryPage => 'Показати в Країнах';

  @override
  String get chipActionGoToPlacePage => 'Показати в Локаціях';

  @override
  String get chipActionGoToTagPage => 'Показати в Тегах';

  @override
  String get chipActionGoToExplorerPage => 'Показати в провіднику';

  @override
  String get chipActionDecompose => 'Розділити';

  @override
  String get chipActionFilterOut => 'Вилучити';

  @override
  String get chipActionFilterIn => 'Включити';

  @override
  String get chipActionHide => 'Приховати';

  @override
  String get chipActionLock => 'Заблокувати';

  @override
  String get chipActionPin => 'Закріпити зверху';

  @override
  String get chipActionUnpin => 'Відкріпити';

  @override
  String get chipActionGroup => 'Group';

  @override
  String get chipActionRename => 'Перейменувати';

  @override
  String get chipActionSetCover => 'Змінити обкладинку';

  @override
  String get chipActionShowCountryStates => 'Показати штати';

  @override
  String get chipActionCreateGroup => 'Create group';

  @override
  String get chipActionCreateAlbum => 'Створити альбом';

  @override
  String get chipActionCreateVault => 'Створити сховище';

  @override
  String get chipActionConfigureVault => 'Налаштувати сховище';

  @override
  String get entryActionCopyToClipboard => 'Скопіювати в буфер обміну';

  @override
  String get entryActionDelete => 'Видалити';

  @override
  String get entryActionConvert => 'Конвертувати';

  @override
  String get entryActionExport => 'Експорт';

  @override
  String get entryActionInfo => 'Інформація';

  @override
  String get entryActionRename => 'Перейменувати';

  @override
  String get entryActionRestore => 'Відновити';

  @override
  String get entryActionRotateCCW => 'Обертати проти годинникової стрілки';

  @override
  String get entryActionRotateCW => 'Обертати за годинниковою стрілкою';

  @override
  String get entryActionFlip => 'Віддзеркалити по горизонталі';

  @override
  String get entryActionPrint => 'Роздрукувати';

  @override
  String get entryActionShare => 'Поділитися';

  @override
  String get entryActionShareImageOnly => 'Поділитися тільки зображенням';

  @override
  String get entryActionShareVideoOnly => 'Поділитися тільки відео';

  @override
  String get entryActionViewSource => 'Переглянути джерело';

  @override
  String get entryActionShowGeoTiffOnMap => 'Показати як накладення на карту';

  @override
  String get entryActionConvertMotionPhotoToStillImage => 'Перетворити на нерухоме зображення';

  @override
  String get entryActionViewMotionPhotoVideo => 'Відкрити відео';

  @override
  String get entryActionEdit => 'Редагувати';

  @override
  String get entryActionOpen => 'Відкрити за допомогою';

  @override
  String get entryActionSetAs => 'Встановити як';

  @override
  String get entryActionCast => 'Трансляція';

  @override
  String get entryActionOpenMap => 'Показати в додатку карти';

  @override
  String get entryActionRotateScreen => 'Повернути екран';

  @override
  String get entryActionAddFavourite => 'Додати в обране';

  @override
  String get entryActionRemoveFavourite => 'Видалити з обраного';

  @override
  String get videoActionCaptureFrame => 'Зберегти кадр';

  @override
  String get videoActionMute => 'Вимкнути звук';

  @override
  String get videoActionUnmute => 'Увімкнути звук';

  @override
  String get videoActionPause => 'Призупинити';

  @override
  String get videoActionPlay => 'Відтворити';

  @override
  String get videoActionReplay10 => 'Перемотати на 10 секунд назад';

  @override
  String get videoActionSkip10 => 'Перемотати на 10 секунд вперед';

  @override
  String get videoActionShowPreviousFrame => 'Показати попередній кадр';

  @override
  String get videoActionShowNextFrame => 'Показати наступний кадр';

  @override
  String get videoActionSelectStreams => 'Вибрати доріжку';

  @override
  String get videoActionSetSpeed => 'Швидкість відтворення';

  @override
  String get videoActionABRepeat => 'Повторити від А до Б';

  @override
  String get videoRepeatActionSetStart => 'Змінити початок';

  @override
  String get videoRepeatActionSetEnd => 'Змінити кінець';

  @override
  String get viewerActionSettings => 'Налаштування';

  @override
  String get viewerActionLock => 'Заблокувати переглядач';

  @override
  String get viewerActionUnlock => 'Розблокувати переглядач';

  @override
  String get slideshowActionResume => 'Продовжити';

  @override
  String get slideshowActionShowInCollection => 'Показати у Колекції';

  @override
  String get entryInfoActionEditDate => 'Редагувати дату та час';

  @override
  String get entryInfoActionEditLocation => 'Редагувати місцезнаходження';

  @override
  String get entryInfoActionEditTitleDescription => 'Редагувати заголовок та опис';

  @override
  String get entryInfoActionEditRating => 'Редагувати рейтинг';

  @override
  String get entryInfoActionEditTags => 'Редагувати теги';

  @override
  String get entryInfoActionRemoveMetadata => 'Видалити метадані';

  @override
  String get entryInfoActionExportMetadata => 'Експортувати метадані';

  @override
  String get entryInfoActionRemoveLocation => 'Видалити місцезнаходження';

  @override
  String get editorActionTransform => 'Перетворити';

  @override
  String get editorTransformCrop => 'Обрізати';

  @override
  String get editorTransformRotate => 'Повернути';

  @override
  String get cropAspectRatioFree => 'Вільне';

  @override
  String get cropAspectRatioOriginal => 'Оригінал';

  @override
  String get cropAspectRatioSquare => 'Площа';

  @override
  String get filterAspectRatioLandscapeLabel => 'Горизонтально';

  @override
  String get filterAspectRatioPortraitLabel => 'Вертикально';

  @override
  String get filterBinLabel => 'Кошик';

  @override
  String get filterFavouriteLabel => 'Обране';

  @override
  String get filterNoDateLabel => 'Без дати';

  @override
  String get filterNoAddressLabel => 'Без адреси';

  @override
  String get filterLocatedLabel => 'Розташований';

  @override
  String get filterNoLocationLabel => 'Без місцезнаходження';

  @override
  String get filterNoRatingLabel => 'Без рейтингу';

  @override
  String get filterTaggedLabel => 'Позначений тегом';

  @override
  String get filterNoTagLabel => 'Без тегів';

  @override
  String get filterNoTitleLabel => 'Без назви';

  @override
  String get filterOnThisDayLabel => 'У цей день';

  @override
  String get filterRecentlyAddedLabel => 'Нещодавно додані';

  @override
  String get filterRatingRejectedLabel => 'Відхилено';

  @override
  String get filterTypeAnimatedLabel => 'Анімована';

  @override
  String get filterTypeMotionPhotoLabel => 'Фотографія з рухом';

  @override
  String get filterTypePanoramaLabel => 'Панорама';

  @override
  String get filterTypeRawLabel => 'Raw';

  @override
  String get filterTypeSphericalVideoLabel => '360° Відео';

  @override
  String get filterTypeGeotiffLabel => 'GeoTIFF';

  @override
  String get filterMimeImageLabel => 'Зображення';

  @override
  String get filterMimeVideoLabel => 'Відео';

  @override
  String get accessibilityAnimationsRemove => 'Запобігання екранним ефектам';

  @override
  String get accessibilityAnimationsKeep => 'Зберегти екранні ефекти';

  @override
  String get albumTierNew => 'Нові';

  @override
  String get albumTierPinned => 'Закріплені';

  @override
  String get albumTierGroups => 'Groups';

  @override
  String get albumTierSpecial => 'Стандартні';

  @override
  String get albumTierApps => 'Додатки';

  @override
  String get albumTierVaults => 'Сховища';

  @override
  String get albumTierDynamic => 'Динамічний';

  @override
  String get albumTierRegular => 'Інше';

  @override
  String get coordinateFormatDms => 'Градуси, мінути та секунди';

  @override
  String get coordinateFormatDdm => 'DDM';

  @override
  String get coordinateFormatDecimal => 'Десяткові градуси';

  @override
  String coordinateDms(String coordinate, String direction) {
    return '$coordinate $direction';
  }

  @override
  String get coordinateDmsNorth => 'пн. ш.';

  @override
  String get coordinateDmsSouth => 'пд. ш.';

  @override
  String get coordinateDmsEast => 'сх. д.';

  @override
  String get coordinateDmsWest => 'зх. д.';

  @override
  String get displayRefreshRatePreferHighest => 'Найвища частота';

  @override
  String get displayRefreshRatePreferLowest => 'Найнижча частота';

  @override
  String get keepScreenOnNever => 'Ніколи';

  @override
  String get keepScreenOnVideoPlayback => 'Під час відтворення відео';

  @override
  String get keepScreenOnViewerOnly => 'Тільки сторінка для перегляду';

  @override
  String get keepScreenOnAlways => 'Завжди';

  @override
  String get lengthUnitPixel => 'px';

  @override
  String get lengthUnitPercent => '%';

  @override
  String get mapStyleGoogleNormal => 'Google Карти';

  @override
  String get mapStyleGoogleHybrid => 'Google Карти (Гібрид)';

  @override
  String get mapStyleGoogleTerrain => 'Google Карти (Місцевість)';

  @override
  String get mapStyleOsmLiberty => 'OSM Liberty';

  @override
  String get mapStyleOpenTopoMap => 'OpenTopoMap';

  @override
  String get mapStyleOsmHot => 'Humanitarian OSM';

  @override
  String get mapStyleStamenWatercolor => 'Stamen Watercolor';

  @override
  String get maxBrightnessNever => 'Ніколи';

  @override
  String get maxBrightnessAlways => 'Завжди';

  @override
  String get nameConflictStrategyRename => 'Перейменувати';

  @override
  String get nameConflictStrategyReplace => 'Замінити';

  @override
  String get nameConflictStrategySkip => 'Пропустити';

  @override
  String get overlayHistogramNone => 'Нічого';

  @override
  String get overlayHistogramRGB => 'RGB';

  @override
  String get overlayHistogramLuminance => 'Яскравість';

  @override
  String get subtitlePositionTop => 'Зверху';

  @override
  String get subtitlePositionBottom => 'Знизу';

  @override
  String get themeBrightnessLight => 'Світла';

  @override
  String get themeBrightnessDark => 'Темна';

  @override
  String get themeBrightnessBlack => 'Чорна';

  @override
  String get unitSystemMetric => 'Метричні';

  @override
  String get unitSystemImperial => 'Англійські';

  @override
  String get vaultLockTypePattern => 'Шаблон';

  @override
  String get vaultLockTypePin => 'Пін-код';

  @override
  String get vaultLockTypePassword => 'Пароль';

  @override
  String get settingsVideoEnablePip => 'Картинка в картинці';

  @override
  String get videoControlsPlayOutside => 'Відкрити в іншому відеоплеєрі';

  @override
  String get videoLoopModeNever => 'Ніколи';

  @override
  String get videoLoopModeShortOnly => 'Тільки короткі відео';

  @override
  String get videoLoopModeAlways => 'Завжди';

  @override
  String get videoPlaybackSkip => 'Пропустити';

  @override
  String get videoPlaybackMuted => 'Відтворити без звуку';

  @override
  String get videoPlaybackWithSound => 'Відтворити зі звуком';

  @override
  String get videoResumptionModeNever => 'Ніколи';

  @override
  String get videoResumptionModeAlways => 'Завжди';

  @override
  String get viewerTransitionSlide => 'Ковзання';

  @override
  String get viewerTransitionParallax => 'Паралакс';

  @override
  String get viewerTransitionFade => 'Згасання';

  @override
  String get viewerTransitionZoomIn => 'Збільшити';

  @override
  String get viewerTransitionNone => 'Нічого';

  @override
  String get wallpaperTargetHome => 'Головний екран';

  @override
  String get wallpaperTargetLock => 'Екран блокування';

  @override
  String get wallpaperTargetHomeLock => 'Головний екран та екран блокування';

  @override
  String get widgetDisplayedItemRandom => 'Випадковий';

  @override
  String get widgetDisplayedItemMostRecent => 'Нещодавний';

  @override
  String get widgetOpenPageHome => 'Відкрити головну сторінку';

  @override
  String get widgetOpenPageCollection => 'Відкрити колекцію';

  @override
  String get widgetOpenPageViewer => 'Відкрити переглядач';

  @override
  String get widgetTapUpdateWidget => 'Оновити віджет';

  @override
  String get storageVolumeDescriptionFallbackPrimary => 'Внутрішня пам\'ять';

  @override
  String get storageVolumeDescriptionFallbackNonPrimary => 'SD картка';

  @override
  String get rootDirectoryDescription => 'кореневий каталог';

  @override
  String otherDirectoryDescription(String name) {
    return 'каталог «$name»';
  }

  @override
  String storageAccessDialogMessage(String directory, String volume) {
    return 'Будь ласка, виберіть $directory на накопичувачі «$volume» на наступному екрані, щоб надати цьому додатку доступ до нього.';
  }

  @override
  String restrictedAccessDialogMessage(String directory, String volume) {
    return 'Цьому додатку не дозволяється змінювати файли в каталозі $directory накопичувача «$volume».\n\nБудь ласка, використовуйте попередньо встановлений файловий менеджер або галерею, щоб перемістити об\'єкти в інший каталог.';
  }

  @override
  String notEnoughSpaceDialogMessage(String neededSize, String freeSize, String volume) {
    return 'Для завершення цієї операції потрібно $neededSize вільного місця на «$volume», але залишилося тільки $freeSize.';
  }

  @override
  String get missingSystemFilePickerDialogMessage => 'Системний додаток вибору файлів відсутній або вимкнений. Будь ласка, увімкніть його та повторіть спробу.';

  @override
  String unsupportedTypeDialogMessage(int count, String types) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ця операція не підтримується для об\'єктів таких форматів $types.',
      one: 'Ця операція не підтримується для об\'єктів такого формату: $types.',
    );
    return '$_temp0';
  }

  @override
  String get nameConflictDialogSingleSourceMessage => 'Деякі файли в теці призначення мають одну й ту саму назву.';

  @override
  String get nameConflictDialogMultipleSourceMessage => 'Деякі файли мають одну й ту саму назву.';

  @override
  String get addShortcutDialogLabel => 'Назва ярлика';

  @override
  String get addShortcutButtonLabel => 'ДОДАТИ';

  @override
  String get noMatchingAppDialogMessage => 'Не існує додатків, які могли б з цим впоратися.';

  @override
  String binEntriesConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Перемістити ці $count елементів у кошик?',
      few: 'Перемістити ці $count елементи у кошик?',
      one: 'Перемістити цей елемент у кошик?',
    );
    return '$_temp0';
  }

  @override
  String deleteEntriesConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Видалити ці $count елементів?',
      few: 'Видалити ці $count елементи?',
      one: 'Видалити цей елемент?',
    );
    return '$_temp0';
  }

  @override
  String get moveUndatedConfirmationDialogMessage => 'Зберегти дати елементів перед тим, як продовжити?';

  @override
  String get moveUndatedConfirmationDialogSetDate => 'Зберегти дати';

  @override
  String videoResumeDialogMessage(String time) {
    return 'Ви хочете продовжити відтворення з $time?';
  }

  @override
  String get videoStartOverButtonLabel => 'ВІДТВОРИТИ СПОЧАТКУ';

  @override
  String get videoResumeButtonLabel => 'ВІДНОВИТИ';

  @override
  String get setCoverDialogLatest => 'Останній елемент';

  @override
  String get setCoverDialogAuto => 'Авто';

  @override
  String get setCoverDialogCustom => 'Власний';

  @override
  String get hideFilterConfirmationDialogMessage => 'Відповідні фотографії та відео будуть приховані з вашої колекції. Ви можете показати їх знову в налаштуваннях у розділі \"Конфіденційність\".\n\nВи впевнені, що хочете їх приховати?';

  @override
  String get newAlbumDialogTitle => 'Новий альбом';

  @override
  String get newAlbumDialogNameLabel => 'Назва альбому';

  @override
  String get newAlbumDialogAlbumAlreadyExistsHelper => 'Альбом вже існує';

  @override
  String get newAlbumDialogNameLabelAlreadyExistsHelper => 'Каталог вже існує';

  @override
  String get newAlbumDialogStorageLabel => 'Накопичувач:';

  @override
  String get newDynamicAlbumDialogTitle => 'Новий динамічний альбом';

  @override
  String get dynamicAlbumAlreadyExists => 'Динамічний альбом уже існує';

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
  String get newVaultWarningDialogMessage => 'Елементи у сховищах доступні лише для цього додатка і ні для кого іншого.\n\nЯкщо ви видалите цей додаток або очистите дані додатку, ви втратите всі ці елементи.';

  @override
  String get newVaultDialogTitle => 'Нове сховище';

  @override
  String get configureVaultDialogTitle => 'Налаштування сховища';

  @override
  String get vaultDialogLockModeWhenScreenOff => 'Заблокувати, коли екран вимикається';

  @override
  String get vaultDialogLockTypeLabel => 'Тип блокування';

  @override
  String get patternDialogEnter => 'Введіть шаблон';

  @override
  String get patternDialogConfirm => 'Підтвердіть шаблон';

  @override
  String get pinDialogEnter => 'Введіть пін-код';

  @override
  String get pinDialogConfirm => 'Підтвердити пін-код';

  @override
  String get passwordDialogEnter => 'Введіть пароль';

  @override
  String get passwordDialogConfirm => 'Підтвердити пароль';

  @override
  String get authenticateToConfigureVault => 'Пройдіть автентифікацію, щоб налаштувати сховище';

  @override
  String get authenticateToUnlockVault => 'Пройдіть автентифікацію, щоб розблокувати сховище';

  @override
  String get vaultBinUsageDialogMessage => 'У деяких сховищах використовується кошик.';

  @override
  String get renameAlbumDialogLabel => 'Нова назва';

  @override
  String get renameAlbumDialogLabelAlreadyExistsHelper => 'Каталог вже існує';

  @override
  String get renameEntrySetPageTitle => 'Перейменувати';

  @override
  String get renameEntrySetPagePatternFieldLabel => 'Зразок найменування';

  @override
  String get renameEntrySetPageInsertTooltip => 'Поле для вставки';

  @override
  String get renameEntrySetPagePreviewSectionTitle => 'Попередній перегляд';

  @override
  String get renameProcessorCounter => 'Лічильник';

  @override
  String get renameProcessorHash => 'Хеш';

  @override
  String get renameProcessorName => 'Назва';

  @override
  String deleteSingleAlbumConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Видалити цей альбом і $count елементів у ньому?',
      few: 'Видалити цей альбом і $count елементи у ньому?',
      one: 'Видалити цей альбом і елемент у ньому?',
    );
    return '$_temp0';
  }

  @override
  String deleteMultiAlbumConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Видалити ці альбоми та $count елементів в них?',
      few: 'Видалити ці альбоми та $count елементи в них?',
      one: 'Видалити ці альбоми та елемент в них?',
    );
    return '$_temp0';
  }

  @override
  String get exportEntryDialogFormat => 'Формат:';

  @override
  String get exportEntryDialogWidth => 'Ширина';

  @override
  String get exportEntryDialogHeight => 'Висота';

  @override
  String get exportEntryDialogQuality => 'Якість';

  @override
  String get exportEntryDialogWriteMetadata => 'Напишіть метадані';

  @override
  String get renameEntryDialogLabel => 'Нова назва';

  @override
  String get editEntryDialogCopyFromItem => 'Скопіювати з іншого елемента';

  @override
  String get editEntryDialogTargetFieldsHeader => 'Поля для редагування';

  @override
  String get editEntryDateDialogTitle => 'Дата та час';

  @override
  String get editEntryDateDialogSetCustom => 'Встановити власну дату';

  @override
  String get editEntryDateDialogCopyField => 'Копіювати з іншої дати';

  @override
  String get editEntryDateDialogExtractFromTitle => 'Витягти з заголовку';

  @override
  String get editEntryDateDialogShift => 'Зрушення';

  @override
  String get editEntryDateDialogSourceFileModifiedDate => 'Дата внесення змін до файлу';

  @override
  String get durationDialogHours => 'Години';

  @override
  String get durationDialogMinutes => 'Хвилини';

  @override
  String get durationDialogSeconds => 'Секунди';

  @override
  String get editEntryLocationDialogTitle => 'Місцезнаходження';

  @override
  String get editEntryLocationDialogSetCustom => 'Встановити власне місцезнаходження';

  @override
  String get editEntryLocationDialogChooseOnMap => 'Вибрати на карті';

  @override
  String get editEntryLocationDialogImportGpx => 'Імпорт GPX';

  @override
  String get editEntryLocationDialogLatitude => 'Широта';

  @override
  String get editEntryLocationDialogLongitude => 'Довгота';

  @override
  String get editEntryLocationDialogTimeShift => 'Зсув часу';

  @override
  String get locationPickerUseThisLocationButton => 'Використовувать це місце';

  @override
  String get editEntryRatingDialogTitle => 'Рейтинг';

  @override
  String get removeEntryMetadataDialogTitle => 'Видалення метаданих';

  @override
  String get removeEntryMetadataDialogAll => 'Все';

  @override
  String get removeEntryMetadataDialogMore => 'Більше';

  @override
  String get removeEntryMetadataMotionPhotoXmpWarningDialogMessage => 'XMP потрібен для відтворення відео всередині фотографії з рухом.\n\nВи впевнені, що хочете його видалити?';

  @override
  String get videoSpeedDialogLabel => 'Швидкість відтворення';

  @override
  String get videoStreamSelectionDialogVideo => 'Відео';

  @override
  String get videoStreamSelectionDialogAudio => 'Аудіо';

  @override
  String get videoStreamSelectionDialogText => 'Субтитри';

  @override
  String get videoStreamSelectionDialogOff => 'Вимкнути';

  @override
  String get videoStreamSelectionDialogTrack => 'Доріжка';

  @override
  String get videoStreamSelectionDialogNoSelection => 'Інших доріжок немає.';

  @override
  String get genericSuccessFeedback => 'Готово!';

  @override
  String get genericFailureFeedback => 'Не вдалося';

  @override
  String get genericDangerWarningDialogMessage => 'Ви впевнені?';

  @override
  String get tooManyItemsErrorDialogMessage => 'Спробуйте ще раз з меншою кількістю елементів.';

  @override
  String get menuActionConfigureView => 'Вигляд';

  @override
  String get menuActionSelect => 'Вибрати';

  @override
  String get menuActionSelectAll => 'Вибрати все';

  @override
  String get menuActionSelectNone => 'Зняти виділення';

  @override
  String get menuActionMap => 'Карта';

  @override
  String get menuActionSlideshow => 'Слайд-шоу';

  @override
  String get menuActionStats => 'Статистика';

  @override
  String get viewDialogSortSectionTitle => 'Сортувати';

  @override
  String get viewDialogGroupSectionTitle => 'Групування';

  @override
  String get viewDialogLayoutSectionTitle => 'Макет';

  @override
  String get viewDialogReverseSortOrder => 'Зворотній порядок сортування';

  @override
  String get tileLayoutMosaic => 'Мозаїка';

  @override
  String get tileLayoutGrid => 'Сітка';

  @override
  String get tileLayoutList => 'Список';

  @override
  String get castDialogTitle => 'Пристрої трансляції';

  @override
  String get coverDialogTabCover => 'Обкладинка';

  @override
  String get coverDialogTabApp => 'Додаток';

  @override
  String get coverDialogTabColor => 'Колір';

  @override
  String get appPickDialogTitle => 'Вибрати додаток';

  @override
  String get appPickDialogNone => 'Нічого';

  @override
  String get aboutPageTitle => 'Про нас';

  @override
  String get aboutLinkLicense => 'Ліцензія';

  @override
  String get aboutLinkPolicy => 'Політика конфіденційності';

  @override
  String get aboutBugSectionTitle => 'Повідомити про помилку';

  @override
  String get aboutBugSaveLogInstruction => 'Зберегти логи додатка у файл';

  @override
  String get aboutBugCopyInfoInstruction => 'Копіювати системну інформацію';

  @override
  String get aboutBugCopyInfoButton => 'Копіювати';

  @override
  String get aboutBugReportInstruction => 'Надіслати звіт про помилку на GitHub разом із логами та системною інформацією';

  @override
  String get aboutBugReportButton => 'Надіслати звіт';

  @override
  String get aboutDataUsageSectionTitle => 'Використання даних';

  @override
  String get aboutDataUsageData => 'Дані';

  @override
  String get aboutDataUsageCache => 'Кеш';

  @override
  String get aboutDataUsageDatabase => 'База даних';

  @override
  String get aboutDataUsageMisc => 'Різне';

  @override
  String get aboutDataUsageInternal => 'Внутрішній';

  @override
  String get aboutDataUsageExternal => 'Зовнішній';

  @override
  String get aboutDataUsageClearCache => 'Очистити кеш';

  @override
  String get aboutCreditsSectionTitle => 'Подяки';

  @override
  String get aboutCreditsWorldAtlas1 => 'Цей додаток використовує файл TopoJSON із';

  @override
  String get aboutCreditsWorldAtlas2 => 'за ліцензією ISC.';

  @override
  String get aboutTranslatorsSectionTitle => 'Перекладачі';

  @override
  String get aboutLicensesSectionTitle => 'Ліцензії з відкритим вихідним кодом';

  @override
  String get aboutLicensesBanner => 'Цей додаток використовує наступні пакети та бібліотеки з відкритим вихідним кодом.';

  @override
  String get aboutLicensesAndroidLibrariesSectionTitle => 'Бібліотеки Android';

  @override
  String get aboutLicensesFlutterPluginsSectionTitle => 'Плагіни Flutter';

  @override
  String get aboutLicensesFlutterPackagesSectionTitle => 'Пакети Flutter';

  @override
  String get aboutLicensesDartPackagesSectionTitle => 'Пакети Dart';

  @override
  String get aboutLicensesShowAllButtonLabel => 'Показати всі ліцензії';

  @override
  String get policyPageTitle => 'Політика конфіденційності';

  @override
  String get collectionPageTitle => 'Колекція';

  @override
  String get collectionPickPageTitle => 'Вибрати';

  @override
  String get collectionSelectPageTitle => 'Виберіть елементи';

  @override
  String get collectionActionShowTitleSearch => 'Показати фільтр заголовка';

  @override
  String get collectionActionHideTitleSearch => 'Приховати фільтр заголовка';

  @override
  String get collectionActionAddDynamicAlbum => 'Додати динамічний альбом';

  @override
  String get collectionActionAddShortcut => 'Додати ярлик';

  @override
  String get collectionActionSetHome => 'Встановити як головну';

  @override
  String get collectionActionEmptyBin => 'Очистити кошик';

  @override
  String get collectionActionCopy => 'Скопіювати в альбом';

  @override
  String get collectionActionMove => 'Перемістити до альбому';

  @override
  String get collectionActionRescan => 'Повторне сканування';

  @override
  String get collectionActionEdit => 'Редагувати';

  @override
  String get collectionSearchTitlesHintText => 'Пошук заголовків';

  @override
  String get collectionGroupAlbum => 'По альбому';

  @override
  String get collectionGroupMonth => 'По місяцю';

  @override
  String get collectionGroupDay => 'По дню';

  @override
  String get sectionNone => 'No sections';

  @override
  String get sectionUnknown => 'Невідомо';

  @override
  String get dateToday => 'Сьогодні';

  @override
  String get dateYesterday => 'Вчора';

  @override
  String get dateThisMonth => 'У цьому місяці';

  @override
  String collectionDeleteFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Не вдалося видалити $count елементів',
      few: 'Не вдалося видалити $count елементи',
      one: 'Не вдалося видалити 1 елемент',
    );
    return '$_temp0';
  }

  @override
  String collectionCopyFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Не вдалося скопіювати $count елементів',
      few: 'Не вдалося скопіювати $count елементи',
      one: 'Не вдалося скопіювати 1 елемент',
    );
    return '$_temp0';
  }

  @override
  String collectionMoveFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Не вдалося перенести $count елементів',
      few: 'Не вдалося перенести $count елементи',
      one: 'Не вдалося перенести 1 елемент',
    );
    return '$_temp0';
  }

  @override
  String collectionRenameFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Не вдалося перейменувати $count елементів',
      few: 'Не вдалося перейменувати $count елементи',
      one: 'Не вдалося перейменувати 1 елемент',
    );
    return '$_temp0';
  }

  @override
  String collectionEditFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Не вдалося відредагувати $count елементів',
      few: 'Не вдалося відредагувати $count елементи',
      one: 'Не вдалося відредагувати 1 елемент',
    );
    return '$_temp0';
  }

  @override
  String collectionExportFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Не вдалося експортувати $count сторінок',
      few: 'Не вдалося експортувати $count сторіноки',
      one: 'Не вдалося експортувати 1 сторінку',
    );
    return '$_temp0';
  }

  @override
  String collectionCopySuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Скопійовано $count елементів',
      few: 'Скопійовано $count елементи',
      one: 'Скопійовано 1 елемент',
    );
    return '$_temp0';
  }

  @override
  String collectionMoveSuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Переміщено $count елементів',
      few: 'Переміщено $count елементи',
      one: 'Переміщено 1 елемент',
    );
    return '$_temp0';
  }

  @override
  String collectionRenameSuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Перейменовано $count елементів',
      few: 'Перейменовано $count елементи',
      one: 'Перейменовано 1 елемент',
    );
    return '$_temp0';
  }

  @override
  String collectionEditSuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Відредаговано $count елементів',
      few: 'Відредаговано $count елементи',
      one: 'Відредаговано 1 елемент',
    );
    return '$_temp0';
  }

  @override
  String get collectionEmptyFavourites => 'Немає обраних';

  @override
  String get collectionEmptyVideos => 'Немає відео';

  @override
  String get collectionEmptyImages => 'Немає зображень';

  @override
  String get collectionEmptyGrantAccessButtonLabel => 'Надайте доступ';

  @override
  String get collectionSelectSectionTooltip => 'Вибрати розділ';

  @override
  String get collectionDeselectSectionTooltip => 'Зняти вибір із розділу';

  @override
  String get drawerAboutButton => 'Про нас';

  @override
  String get drawerSettingsButton => 'Налаштування';

  @override
  String get drawerCollectionAll => 'Вся колекція';

  @override
  String get drawerCollectionFavourites => 'Обране';

  @override
  String get drawerCollectionImages => 'Зображення';

  @override
  String get drawerCollectionVideos => 'Відео';

  @override
  String get drawerCollectionAnimated => 'Анімації';

  @override
  String get drawerCollectionMotionPhotos => 'Фото з рухом';

  @override
  String get drawerCollectionPanoramas => 'Панорами';

  @override
  String get drawerCollectionRaws => 'Raw фотографії';

  @override
  String get drawerCollectionSphericalVideos => '360° Відео';

  @override
  String get drawerAlbumPage => 'Альбоми';

  @override
  String get drawerCountryPage => 'Країни';

  @override
  String get drawerPlacePage => 'Локації';

  @override
  String get drawerTagPage => 'Теги';

  @override
  String get sortByDate => 'За датою';

  @override
  String get sortByName => 'За назвою';

  @override
  String get sortByItemCount => 'За кількістю елементів';

  @override
  String get sortBySize => 'За розміром';

  @override
  String get sortByAlbumFileName => 'За назвою альбому та файлу';

  @override
  String get sortByRating => 'За рейтингом';

  @override
  String get sortByDuration => 'За тривалістю';

  @override
  String get sortByPath => 'За шляхом';

  @override
  String get sortOrderNewestFirst => 'Найновіші перші';

  @override
  String get sortOrderOldestFirst => 'Найстаріші перші';

  @override
  String get sortOrderAtoZ => 'Від А до Я';

  @override
  String get sortOrderZtoA => 'Від Я до А';

  @override
  String get sortOrderHighestFirst => 'Спочатку з високим';

  @override
  String get sortOrderLowestFirst => 'Спочатку з низьким';

  @override
  String get sortOrderLargestFirst => 'Спочатку великі';

  @override
  String get sortOrderSmallestFirst => 'Спочатку маленькі';

  @override
  String get sortOrderShortestFirst => 'Спершу найкоротше';

  @override
  String get sortOrderLongestFirst => 'Спершу найдовше';

  @override
  String get albumGroupTier => 'За рівнем';

  @override
  String get albumGroupType => 'За типом';

  @override
  String get albumGroupVolume => 'За накопичувачем';

  @override
  String get albumMimeTypeMixed => 'Змішані';

  @override
  String get albumPickPageTitleCopy => 'Копіювати в Альбом';

  @override
  String get albumPickPageTitleExport => 'Експортувати до Альбому';

  @override
  String get albumPickPageTitleMove => 'Перемістити до Альбому';

  @override
  String get albumPickPageTitlePick => 'Вибрати Альбом';

  @override
  String get albumCamera => 'Камера';

  @override
  String get albumDownload => 'Завантаження';

  @override
  String get albumScreenshots => 'Скріншоти';

  @override
  String get albumScreenRecordings => 'Записи екрану';

  @override
  String get albumVideoCaptures => 'Відеозаписи';

  @override
  String get albumPageTitle => 'Альбоми';

  @override
  String get albumEmpty => 'Немає альбомів';

  @override
  String get createAlbumButtonLabel => 'СТВОРИТИ';

  @override
  String get newFilterBanner => 'новий';

  @override
  String get countryPageTitle => 'Країни';

  @override
  String get countryEmpty => 'Немає країн';

  @override
  String get statePageTitle => 'Штати';

  @override
  String get stateEmpty => 'Немає штатів';

  @override
  String get placePageTitle => 'Локації';

  @override
  String get placeEmpty => 'Немає локацій';

  @override
  String get tagPageTitle => 'Теги';

  @override
  String get tagEmpty => 'Немає тегів';

  @override
  String get binPageTitle => 'Кошик';

  @override
  String get explorerPageTitle => 'Провідник';

  @override
  String get explorerActionSelectStorageVolume => 'Обрати сховище';

  @override
  String get selectStorageVolumeDialogTitle => 'Оберіть сховище';

  @override
  String get searchCollectionFieldHint => 'Пошук колекцій';

  @override
  String get searchRecentSectionTitle => 'Нещодавні';

  @override
  String get searchDateSectionTitle => 'Дата';

  @override
  String get searchFormatSectionTitle => 'Формати';

  @override
  String get searchAlbumsSectionTitle => 'Альбоми';

  @override
  String get searchCountriesSectionTitle => 'Країни';

  @override
  String get searchStatesSectionTitle => 'Штати';

  @override
  String get searchPlacesSectionTitle => 'Локації';

  @override
  String get searchTagsSectionTitle => 'Теги';

  @override
  String get searchRatingSectionTitle => 'Рейтинги';

  @override
  String get searchMetadataSectionTitle => 'Метадані';

  @override
  String get settingsPageTitle => 'Налаштування';

  @override
  String get settingsSystemDefault => 'Як у системі';

  @override
  String get settingsDefault => 'За замовчуванням';

  @override
  String get settingsDisabled => 'Вимкнено';

  @override
  String get settingsAskEverytime => 'Запитувати щоразу';

  @override
  String get settingsModificationWarningDialogMessage => 'Інші параметри будуть змінені.';

  @override
  String get settingsSearchFieldLabel => 'Пошук налаштувань';

  @override
  String get settingsSearchEmpty => 'Немає відповідного налаштування';

  @override
  String get settingsActionExport => 'Експорт';

  @override
  String get settingsActionExportDialogTitle => 'Експорт';

  @override
  String get settingsActionImport => 'Імпорт';

  @override
  String get settingsActionImportDialogTitle => 'Імпорт';

  @override
  String get appExportCovers => 'Обкладинки';

  @override
  String get appExportDynamicAlbums => 'Динамічні альбоми';

  @override
  String get appExportFavourites => 'Обране';

  @override
  String get appExportSettings => 'Налаштування';

  @override
  String get settingsNavigationSectionTitle => 'Навігація';

  @override
  String get settingsHomeTile => 'Головна';

  @override
  String get settingsHomeDialogTitle => 'Головна';

  @override
  String get setHomeCustom => 'Власне';

  @override
  String get settingsShowBottomNavigationBar => 'Показати нижню панель навігації';

  @override
  String get settingsKeepScreenOnTile => 'Тримати екран увімкненим';

  @override
  String get settingsKeepScreenOnDialogTitle => 'Тримати екран увімкненим';

  @override
  String get settingsDoubleBackExit => 'Двічі натисніть «назад», щоб вийти';

  @override
  String get settingsConfirmationTile => 'Діалоги підтвердження';

  @override
  String get settingsConfirmationDialogTitle => 'Діалоги підтвердження';

  @override
  String get settingsConfirmationBeforeDeleteItems => 'Запитати, перш ніж видаляти елементи назавжди';

  @override
  String get settingsConfirmationBeforeMoveToBinItems => 'Запитати перед тим, як переносити елементи до кошика';

  @override
  String get settingsConfirmationBeforeMoveUndatedItems => 'Запитати перед переміщенням недатованих елементів';

  @override
  String get settingsConfirmationAfterMoveToBinItems => 'Показувати повідомлення після переміщення елементів у кошик';

  @override
  String get settingsConfirmationVaultDataLoss => 'Показувати попередження про втрату даних сховища';

  @override
  String get settingsNavigationDrawerTile => 'Навігаційне меню';

  @override
  String get settingsNavigationDrawerEditorPageTitle => 'Навігаційне меню';

  @override
  String get settingsNavigationDrawerBanner => 'Натисніть і утримуйте для переміщення та зміни порядку елементів меню.';

  @override
  String get settingsNavigationDrawerTabTypes => 'Типи';

  @override
  String get settingsNavigationDrawerTabAlbums => 'Альбоми';

  @override
  String get settingsNavigationDrawerTabPages => 'Сторінки';

  @override
  String get settingsNavigationDrawerAddAlbum => 'Додати альбом';

  @override
  String get settingsThumbnailSectionTitle => 'Мініатюри';

  @override
  String get settingsThumbnailOverlayTile => 'Накладення';

  @override
  String get settingsThumbnailOverlayPageTitle => 'Накладення';

  @override
  String get settingsThumbnailShowHdrIcon => 'Показати іконку HDR';

  @override
  String get settingsThumbnailShowFavouriteIcon => 'Показати іконку обраного';

  @override
  String get settingsThumbnailShowTagIcon => 'Показати іконку тегу';

  @override
  String get settingsThumbnailShowLocationIcon => 'Показати іконку місцезнаходження';

  @override
  String get settingsThumbnailShowMotionPhotoIcon => 'Показати іконку фото з рухом';

  @override
  String get settingsThumbnailShowRating => 'Показати рейтинг';

  @override
  String get settingsThumbnailShowRawIcon => 'Показати іконку raw';

  @override
  String get settingsThumbnailShowVideoDuration => 'Показати тривалість відео';

  @override
  String get settingsCollectionQuickActionsTile => 'Швидкі дії';

  @override
  String get settingsCollectionQuickActionEditorPageTitle => 'Швидкі дії';

  @override
  String get settingsCollectionQuickActionTabBrowsing => 'Перегляд';

  @override
  String get settingsCollectionQuickActionTabSelecting => 'Вибір';

  @override
  String get settingsCollectionBrowsingQuickActionEditorBanner => 'Торкніться і утримуйте для переміщення кнопок і вибору дій, які будуть відображатися при перегляді елементів.';

  @override
  String get settingsCollectionSelectionQuickActionEditorBanner => 'Торкніться і утримуйте для переміщення кнопок і вибору дій, які будуть відображатися при виборі елементів.';

  @override
  String get settingsCollectionBurstPatternsTile => 'Вибух візерунків';

  @override
  String get settingsCollectionBurstPatternsNone => 'Нічого';

  @override
  String get settingsViewerSectionTitle => 'Переглядач';

  @override
  String get settingsViewerGestureSideTapNext => 'Торкніться країв екрану, щоб показати попередній/наступний елемент';

  @override
  String get settingsViewerUseCutout => 'Використовувати область вирізу';

  @override
  String get settingsViewerMaximumBrightness => 'Максимальна яскравість';

  @override
  String get settingsMotionPhotoAutoPlay => 'Автоматичне відтворення фотографій з рухом';

  @override
  String get settingsImageBackground => 'Фон зображення';

  @override
  String get settingsViewerQuickActionsTile => 'Швидкі дії';

  @override
  String get settingsViewerQuickActionEditorPageTitle => 'Швидкі дії';

  @override
  String get settingsViewerQuickActionEditorBanner => 'Торкніться і утримуйте для переміщення кнопок і вибору дій, які відображатимуться у переглядачі.';

  @override
  String get settingsViewerQuickActionEditorDisplayedButtonsSectionTitle => 'Відображувані кнопки';

  @override
  String get settingsViewerQuickActionEditorAvailableButtonsSectionTitle => 'Доступні кнопки';

  @override
  String get settingsViewerQuickActionEmpty => 'Немає кнопок';

  @override
  String get settingsViewerOverlayTile => 'Накладення';

  @override
  String get settingsViewerOverlayPageTitle => 'Накладення';

  @override
  String get settingsViewerShowOverlayOnOpening => 'Показати при відкритті';

  @override
  String get settingsViewerShowHistogram => 'Показати гістограму';

  @override
  String get settingsViewerShowMinimap => 'Показати міні-карту';

  @override
  String get settingsViewerShowInformation => 'Показати інформацію';

  @override
  String get settingsViewerShowInformationSubtitle => 'Показувати заголовок, дату, місцезнаходження тощо.';

  @override
  String get settingsViewerShowRatingTags => 'Показати рейтинг та теги';

  @override
  String get settingsViewerShowShootingDetails => 'Показати деталі зйомки';

  @override
  String get settingsViewerShowDescription => 'Показати опис';

  @override
  String get settingsViewerShowOverlayThumbnails => 'Показати мініатюри';

  @override
  String get settingsViewerEnableOverlayBlurEffect => 'Ефект розмиття';

  @override
  String get settingsViewerSlideshowTile => 'Слайд-шоу';

  @override
  String get settingsViewerSlideshowPageTitle => 'Слайд-шоу';

  @override
  String get settingsSlideshowRepeat => 'Повторення';

  @override
  String get settingsSlideshowShuffle => 'Перемішати';

  @override
  String get settingsSlideshowFillScreen => 'Заповнити екрану';

  @override
  String get settingsSlideshowAnimatedZoomEffect => 'Анімований ефект масштабування';

  @override
  String get settingsSlideshowTransitionTile => 'Перехід';

  @override
  String get settingsSlideshowIntervalTile => 'Інтервал';

  @override
  String get settingsSlideshowVideoPlaybackTile => 'Відтворення відео';

  @override
  String get settingsSlideshowVideoPlaybackDialogTitle => 'Відтворення відео';

  @override
  String get settingsVideoPageTitle => 'Налаштування відео';

  @override
  String get settingsVideoSectionTitle => 'Відео';

  @override
  String get settingsVideoShowVideos => 'Показувати відео';

  @override
  String get settingsVideoPlaybackTile => 'Відтворення';

  @override
  String get settingsVideoPlaybackPageTitle => 'Відтворення';

  @override
  String get settingsVideoEnableHardwareAcceleration => 'Апаратне прискорення';

  @override
  String get settingsVideoAutoPlay => 'Автоматичне відтворення';

  @override
  String get settingsVideoLoopModeTile => 'Циклічний режим';

  @override
  String get settingsVideoLoopModeDialogTitle => 'Циклічний режим';

  @override
  String get settingsVideoResumptionModeTile => 'Продовжити відтворення';

  @override
  String get settingsVideoResumptionModeDialogTitle => 'Продовжити відтворення';

  @override
  String get settingsVideoBackgroundMode => 'Фоновий режим';

  @override
  String get settingsVideoBackgroundModeDialogTitle => 'Фоновий режим';

  @override
  String get settingsVideoControlsTile => 'Елементи керування';

  @override
  String get settingsVideoControlsPageTitle => 'Елементи керування';

  @override
  String get settingsVideoButtonsTile => 'Кнопки';

  @override
  String get settingsVideoGestureDoubleTapTogglePlay => 'Подвійний дотик для відтворення/паузи';

  @override
  String get settingsVideoGestureSideDoubleTapSeek => 'Подвійне натискання на краї екрану для переходу назад/вперед';

  @override
  String get settingsVideoGestureVerticalDragBrightnessVolume => 'Проведіть пальцем угору або вниз, щоб налаштувати яскравість/гучність';

  @override
  String get settingsSubtitleThemeTile => 'Субтитри';

  @override
  String get settingsSubtitleThemePageTitle => 'Субтитри';

  @override
  String get settingsSubtitleThemeSample => 'Це зразок.';

  @override
  String get settingsSubtitleThemeTextAlignmentTile => 'Вирівнювання тексту';

  @override
  String get settingsSubtitleThemeTextAlignmentDialogTitle => 'Вирівнювання тексту';

  @override
  String get settingsSubtitleThemeTextPositionTile => 'Положення тексту';

  @override
  String get settingsSubtitleThemeTextPositionDialogTitle => 'Положення тексту';

  @override
  String get settingsSubtitleThemeTextSize => 'Розмір тексту';

  @override
  String get settingsSubtitleThemeShowOutline => 'Показати контур і тінь';

  @override
  String get settingsSubtitleThemeTextColor => 'Колір тексту';

  @override
  String get settingsSubtitleThemeTextOpacity => 'Непрозорість тексту';

  @override
  String get settingsSubtitleThemeBackgroundColor => 'Колір фону';

  @override
  String get settingsSubtitleThemeBackgroundOpacity => 'Непрозорість фону';

  @override
  String get settingsSubtitleThemeTextAlignmentLeft => 'Ліворуч';

  @override
  String get settingsSubtitleThemeTextAlignmentCenter => 'Центр';

  @override
  String get settingsSubtitleThemeTextAlignmentRight => 'Праворуч';

  @override
  String get settingsPrivacySectionTitle => 'Конфіденційність';

  @override
  String get settingsAllowInstalledAppAccess => 'Дозволити доступ до інвентарю додатків';

  @override
  String get settingsAllowInstalledAppAccessSubtitle => 'Використовується для покращення відображення альбомів';

  @override
  String get settingsAllowErrorReporting => 'Дозволити анонімну відправку повідомлень про помилки';

  @override
  String get settingsSaveSearchHistory => 'Зберігати історію пошуку';

  @override
  String get settingsEnableBin => 'Використовувати кошик';

  @override
  String get settingsEnableBinSubtitle => 'Зберігає видалені елементи протягом 30 днів';

  @override
  String get settingsDisablingBinWarningDialogMessage => 'Елементи в кошику буде видалено назавжди.';

  @override
  String get settingsAllowMediaManagement => 'Дозволити керування мультимедіа';

  @override
  String get settingsHiddenItemsTile => 'Приховані елементи';

  @override
  String get settingsHiddenItemsPageTitle => 'Приховані елементи';

  @override
  String get settingsHiddenFiltersBanner => 'Фотографії та відео, що відповідають прихованим фільтрам, не з\'являться у вашій колекції.';

  @override
  String get settingsHiddenFiltersEmpty => 'Немає прихованих фільтрів';

  @override
  String get settingsStorageAccessTile => 'Доступ до сховища';

  @override
  String get settingsStorageAccessPageTitle => 'Доступ до сховища';

  @override
  String get settingsStorageAccessBanner => 'Деякі каталоги вимагають явного надання доступу для зміни файлів в них. Ви можете переглянути тут каталоги, до яких ви раніше надавали доступ.';

  @override
  String get settingsStorageAccessEmpty => 'Доступ не наданий';

  @override
  String get settingsStorageAccessRevokeTooltip => 'Відкликати';

  @override
  String get settingsAccessibilitySectionTitle => 'Спеціальні можливості';

  @override
  String get settingsRemoveAnimationsTile => 'Видалити анімації';

  @override
  String get settingsRemoveAnimationsDialogTitle => 'Видалити анімації';

  @override
  String get settingsTimeToTakeActionTile => 'Час на виконання';

  @override
  String get settingsAccessibilityShowPinchGestureAlternatives => 'Показувати альтернативи мультисенсорним жестам';

  @override
  String get settingsDisplaySectionTitle => 'Відображення';

  @override
  String get settingsThemeBrightnessTile => 'Тема';

  @override
  String get settingsThemeBrightnessDialogTitle => 'Тема';

  @override
  String get settingsThemeColorHighlights => 'Кольорові акценти';

  @override
  String get settingsThemeEnableDynamicColor => 'Динамічний колір';

  @override
  String get settingsDisplayRefreshRateModeTile => 'Частота оновлення дисплея';

  @override
  String get settingsDisplayRefreshRateModeDialogTitle => 'Частота оновлення';

  @override
  String get settingsDisplayUseTvInterface => 'Інтерфейс Android TV';

  @override
  String get settingsLanguageSectionTitle => 'Мова та формати';

  @override
  String get settingsLanguageTile => 'Мова';

  @override
  String get settingsLanguagePageTitle => 'Мова';

  @override
  String get settingsCoordinateFormatTile => 'Формат координат';

  @override
  String get settingsCoordinateFormatDialogTitle => 'Формат координат';

  @override
  String get settingsUnitSystemTile => 'Одиниці виміру';

  @override
  String get settingsUnitSystemDialogTitle => 'Одиниці виміру';

  @override
  String get settingsForceWesternArabicNumeralsTile => 'Примусові арабські цифри';

  @override
  String get settingsScreenSaverPageTitle => 'Заставка на екран';

  @override
  String get settingsWidgetPageTitle => 'Фоторамка';

  @override
  String get settingsWidgetShowOutline => 'Виділення';

  @override
  String get settingsWidgetOpenPage => 'При натисканні на віджет';

  @override
  String get settingsWidgetDisplayedItem => 'Відображаємий елемент';

  @override
  String get settingsCollectionTile => 'Колекція';

  @override
  String get statsPageTitle => 'Статистика';

  @override
  String statsWithGps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count елементів з місцезнаходженням',
      few: '$count елементи з місцезнаходженням',
      one: '1 елемент з місцезнаходженням',
    );
    return '$_temp0';
  }

  @override
  String get statsTopCountriesSectionTitle => 'Топ Країн';

  @override
  String get statsTopStatesSectionTitle => 'Топ штатів';

  @override
  String get statsTopPlacesSectionTitle => 'Топ локацій';

  @override
  String get statsTopTagsSectionTitle => 'Топ Тегів';

  @override
  String get statsTopAlbumsSectionTitle => 'Топ альбомів';

  @override
  String get viewerOpenPanoramaButtonLabel => 'ВІДКРИТИ ПАНОРАМУ';

  @override
  String get viewerSetWallpaperButtonLabel => 'ЗМІНИТИ ШПАЛЕРИ';

  @override
  String get viewerErrorUnknown => 'Упс!';

  @override
  String get viewerErrorDoesNotExist => 'Файлу більше не існує.';

  @override
  String get viewerInfoPageTitle => 'Інформація';

  @override
  String get viewerInfoBackToViewerTooltip => 'Повернутися до перегляду';

  @override
  String get viewerInfoUnknown => 'невідомий';

  @override
  String get viewerInfoLabelDescription => 'Опис';

  @override
  String get viewerInfoLabelTitle => 'Заголовок';

  @override
  String get viewerInfoLabelDate => 'Дата';

  @override
  String get viewerInfoLabelResolution => 'Роздільна здатність';

  @override
  String get viewerInfoLabelSize => 'Розмір';

  @override
  String get viewerInfoLabelUri => 'URI';

  @override
  String get viewerInfoLabelPath => 'Шлях';

  @override
  String get viewerInfoLabelDuration => 'Тривалість';

  @override
  String get viewerInfoLabelOwner => 'Власник';

  @override
  String get viewerInfoLabelCoordinates => 'Координати';

  @override
  String get viewerInfoLabelAddress => 'Адреса';

  @override
  String get mapStyleDialogTitle => 'Стиль карти';

  @override
  String get mapStyleTooltip => 'Виберіть стиль карти';

  @override
  String get mapZoomInTooltip => 'Збільшити';

  @override
  String get mapZoomOutTooltip => 'Зменшити';

  @override
  String get mapPointNorthUpTooltip => 'Повернути на північ';

  @override
  String get mapAttributionOsmData => 'Картографічні дані © [OpenStreetMap](https://www.openstreetmap.org/copyright) помічники';

  @override
  String get mapAttributionOsmLiberty => 'Плитки від [OpenMapTiles](https://www.openmaptiles.org/), [CC BY](http://creativecommons.org/licenses/by/4.0) • Розміщено на [OSM Americana](https://tile.ourmap.us)';

  @override
  String get mapAttributionOpenTopoMap => '[SRTM](https://www.earthdata.nasa.gov/sensors/srtm) | Плитки від [OpenTopoMap](https://opentopomap.org/), [CC BY-SA](https://creativecommons.org/licenses/by-sa/3.0/)';

  @override
  String get mapAttributionOsmHot => 'Плитки [HOT](https://www.hotosm.org/) • Розміщена на [OSM France](https://openstreetmap.fr/)';

  @override
  String get mapAttributionStamen => 'Плитки [Stamen Design](https://stamen.com), [CC BY 3.0](https://creativecommons.org/licenses/by/3.0)';

  @override
  String get openMapPageTooltip => 'Переглянути на карті';

  @override
  String get mapEmptyRegion => 'Зображень у цьому регіоні немає';

  @override
  String get viewerInfoOpenEmbeddedFailureFeedback => 'Не вдалося витягти вбудовані дані';

  @override
  String get viewerInfoOpenLinkText => 'Відкрити';

  @override
  String get viewerInfoViewXmlLinkText => 'Переглянути XML';

  @override
  String get viewerInfoSearchFieldLabel => 'Пошук метаданих';

  @override
  String get viewerInfoSearchEmpty => 'Немає співпадаючих ключів';

  @override
  String get viewerInfoSearchSuggestionDate => 'Дата та час';

  @override
  String get viewerInfoSearchSuggestionDescription => 'Опис';

  @override
  String get viewerInfoSearchSuggestionDimensions => 'Розміри';

  @override
  String get viewerInfoSearchSuggestionResolution => 'Роздільна здатність';

  @override
  String get viewerInfoSearchSuggestionRights => 'Права';

  @override
  String get wallpaperUseScrollEffect => 'Використовувати ефект прокрутки на головному екрані';

  @override
  String get tagEditorPageTitle => 'Редагування тегів';

  @override
  String get tagEditorPageNewTagFieldLabel => 'Новий тег';

  @override
  String get tagEditorPageAddTagTooltip => 'Додати тег';

  @override
  String get tagEditorSectionRecent => 'Нещодавні';

  @override
  String get tagEditorSectionPlaceholders => 'Заповнювачі';

  @override
  String get tagEditorDiscardDialogMessage => 'Ви хочете відмовитися від змін?';

  @override
  String get tagPlaceholderCountry => 'Країна';

  @override
  String get tagPlaceholderState => 'Штат';

  @override
  String get tagPlaceholderPlace => 'Локація';

  @override
  String get panoramaEnableSensorControl => 'Увімкнути сенсорне керування';

  @override
  String get panoramaDisableSensorControl => 'Вимкнути сенсорне керування';

  @override
  String get sourceViewerPageTitle => 'Джерело';
}
