// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Belarusian (`be`).
class AppLocalizationsBe extends AppLocalizations {
  AppLocalizationsBe([String locale = 'be']) : super(locale);

  @override
  String get appName => 'Aves';

  @override
  String get welcomeMessage => 'Сардэчна запрашаем у Aves';

  @override
  String get welcomeOptional => 'Неабавязковыя';

  @override
  String get welcomeTermsToggle => 'Я згодны з умовамі';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count элементаў',
      one: '$count элемент',
    );
    return '$_temp0';
  }

  @override
  String columnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count слупкоў',
      few: '$count слупкі',
      one: '$count слупок',
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
      other: '$countString хвілін',
      few: '$countString хвіліны',
      one: '$countString хвіліна',
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
      other: '$countString дзён',
      few: '$countString дні',
      one: '$countString дзень',
    );
    return '$_temp0';
  }

  @override
  String focalLength(String length) {
    return '$length мм';
  }

  @override
  String get applyButtonLabel => 'УЖЫВАЦЬ';

  @override
  String get deleteButtonLabel => 'ВЫДАЛІЦЬ';

  @override
  String get nextButtonLabel => 'ДАЛЕЙ';

  @override
  String get showButtonLabel => 'ПАКАЗАЦЬ';

  @override
  String get hideButtonLabel => 'ХАВАЦЬ';

  @override
  String get continueButtonLabel => 'ПРАЦЯГВАЦЬ';

  @override
  String get saveCopyButtonLabel => 'ЗАХАВАЦЬ КОПІЮ';

  @override
  String get applyTooltip => 'Ужыць';

  @override
  String get cancelTooltip => 'Адмена';

  @override
  String get changeTooltip => 'Змяніць';

  @override
  String get clearTooltip => 'Ачысціць';

  @override
  String get previousTooltip => 'Папярэдні';

  @override
  String get nextTooltip => 'Наступны';

  @override
  String get showTooltip => 'Паказаць';

  @override
  String get hideTooltip => 'Схаваць';

  @override
  String get actionRemove => 'Выдаліць';

  @override
  String get resetTooltip => 'Скінуць';

  @override
  String get saveTooltip => 'Захаваць';

  @override
  String get stopTooltip => 'Спыніць';

  @override
  String get pickTooltip => 'Выбраць';

  @override
  String get doubleBackExitMessage => 'Яшчэ раз націсніце «назад», каб выйсці.';

  @override
  String get doNotAskAgain => 'Больш не пытайся';

  @override
  String get sourceStateLoading => 'Загрузка';

  @override
  String get sourceStateCataloguing => 'Каталагізацыя';

  @override
  String get sourceStateLocatingCountries => 'Размяшчэнне краін';

  @override
  String get sourceStateLocatingPlaces => 'Размяшчэнне месцаў';

  @override
  String get chipActionDelete => 'Выдаліць';

  @override
  String get chipActionRemove => 'Remove';

  @override
  String get chipActionShowCollection => 'Паказаць у Калекцыі';

  @override
  String get chipActionGoToAlbumPage => 'Паказаць у Альбомах';

  @override
  String get chipActionGoToCountryPage => 'Паказаць у Краінах';

  @override
  String get chipActionGoToPlacePage => 'Паказаць у Лакацыях';

  @override
  String get chipActionGoToTagPage => 'Паказаць у Тэгах';

  @override
  String get chipActionGoToExplorerPage => 'Паказаць у Правадыру';

  @override
  String get chipActionDecompose => 'Split';

  @override
  String get chipActionFilterOut => 'Адфільтраваць';

  @override
  String get chipActionFilterIn => 'Фільтраваць';

  @override
  String get chipActionHide => 'Схаваць';

  @override
  String get chipActionLock => 'Заблакаваць';

  @override
  String get chipActionPin => 'Прышпіліць да вяршыні';

  @override
  String get chipActionUnpin => 'Адмацаваць зверху';

  @override
  String get chipActionRename => 'Перайменаваць';

  @override
  String get chipActionSetCover => 'Усталяваць вокладку';

  @override
  String get chipActionShowCountryStates => 'Паказаць дзяржавы';

  @override
  String get chipActionCreateAlbum => 'Стварыць альбом';

  @override
  String get chipActionCreateVault => 'Стварыце сховішча';

  @override
  String get chipActionConfigureVault => 'Наладзіць сховішча';

  @override
  String get entryActionCopyToClipboard => 'Скапіяваць у буфер абмену';

  @override
  String get entryActionDelete => 'Выдаліць';

  @override
  String get entryActionConvert => 'Канвертаваць';

  @override
  String get entryActionExport => 'Экспарт';

  @override
  String get entryActionInfo => 'Інфармацыя';

  @override
  String get entryActionRename => 'Перайменаваць';

  @override
  String get entryActionRestore => 'Аднавіць';

  @override
  String get entryActionRotateCCW => 'Круціць супраць гадзінны стрэлкі';

  @override
  String get entryActionRotateCW => 'Круціць па гадзіннікавай стрэлцы';

  @override
  String get entryActionFlip => 'Перавярнуць па гарызанталі';

  @override
  String get entryActionPrint => 'Друк';

  @override
  String get entryActionShare => 'Падзяліцца';

  @override
  String get entryActionShareImageOnly => 'Падзяліцца толькі выявай';

  @override
  String get entryActionShareVideoOnly => 'Падзяліцца толькі відэа';

  @override
  String get entryActionViewSource => 'Паглядзець крыніцу';

  @override
  String get entryActionShowGeoTiffOnMap => 'Паказаць як накладанне на карту';

  @override
  String get entryActionConvertMotionPhotoToStillImage => 'Канвертаваць у статычны малюнак';

  @override
  String get entryActionViewMotionPhotoVideo => 'Адкрыць відэа';

  @override
  String get entryActionEdit => 'Рэдагаваць';

  @override
  String get entryActionOpen => 'Адкрыць з дапамогай';

  @override
  String get entryActionSetAs => 'Усталяваць як';

  @override
  String get entryActionCast => 'Трансляцыя';

  @override
  String get entryActionOpenMap => 'Паказаць у праграме карты';

  @override
  String get entryActionRotateScreen => 'Паварот экрана';

  @override
  String get entryActionAddFavourite => 'Дадаць у абранае';

  @override
  String get entryActionRemoveFavourite => 'Выдаліць з абранага';

  @override
  String get videoActionCaptureFrame => 'Захоп кадра';

  @override
  String get videoActionMute => 'Адключыць гук';

  @override
  String get videoActionUnmute => 'Уключыць гук';

  @override
  String get videoActionPause => 'Паўза';

  @override
  String get videoActionPlay => 'Прайграць';

  @override
  String get videoActionReplay10 => 'Перамотка назад на 10 секунд';

  @override
  String get videoActionSkip10 => 'Перамотка наперад на 10 секунд';

  @override
  String get videoActionShowPreviousFrame => 'Show previous frame';

  @override
  String get videoActionShowNextFrame => 'Show next frame';

  @override
  String get videoActionSelectStreams => 'Выберыце трэкі';

  @override
  String get videoActionSetSpeed => 'Хуткасць прайгравання';

  @override
  String get videoActionABRepeat => 'Паўтарыць ад А да Б';

  @override
  String get videoRepeatActionSetStart => 'Усталяваць пачатак';

  @override
  String get videoRepeatActionSetEnd => 'Усталяваць канец';

  @override
  String get viewerActionSettings => 'Налады';

  @override
  String get viewerActionLock => 'Блакіроўка прагляду';

  @override
  String get viewerActionUnlock => 'Разблакіроўка прагляду';

  @override
  String get slideshowActionResume => 'Аднавіць';

  @override
  String get slideshowActionShowInCollection => 'Паказаць у Калекцыі';

  @override
  String get entryInfoActionEditDate => 'Рэдагаваць дату і час';

  @override
  String get entryInfoActionEditLocation => 'Рэдагаваць месцазнаходжанне';

  @override
  String get entryInfoActionEditTitleDescription => 'Рэдагаваць назву і апісанне';

  @override
  String get entryInfoActionEditRating => 'Рэдагаваць рэйтынг';

  @override
  String get entryInfoActionEditTags => 'Рэдагаваць тэгі';

  @override
  String get entryInfoActionRemoveMetadata => 'Выдаліць метададзеныя';

  @override
  String get entryInfoActionExportMetadata => 'Экспарт метададзеных';

  @override
  String get entryInfoActionRemoveLocation => 'Выдаліць месцазнаходжанне';

  @override
  String get editorActionTransform => 'Трансфармаваць';

  @override
  String get editorTransformCrop => 'Абрэзаць';

  @override
  String get editorTransformRotate => 'Павярнуць';

  @override
  String get cropAspectRatioFree => 'Свабодныя';

  @override
  String get cropAspectRatioOriginal => 'Першапачатковае';

  @override
  String get cropAspectRatioSquare => 'Квадратнае';

  @override
  String get filterAspectRatioLandscapeLabel => 'Ландшафтныя';

  @override
  String get filterAspectRatioPortraitLabel => 'Партрэтныя';

  @override
  String get filterBinLabel => 'Сметніца';

  @override
  String get filterFavouriteLabel => 'Выбранае';

  @override
  String get filterNoDateLabel => 'Без даты';

  @override
  String get filterNoAddressLabel => 'Без адрасу';

  @override
  String get filterLocatedLabel => 'Размешчаны';

  @override
  String get filterNoLocationLabel => 'Без месцазнаходжання';

  @override
  String get filterNoRatingLabel => 'Без рэйтынгу';

  @override
  String get filterTaggedLabel => 'З тэгамі';

  @override
  String get filterNoTagLabel => 'Без тэгаў';

  @override
  String get filterNoTitleLabel => 'Без назвы';

  @override
  String get filterOnThisDayLabel => 'У гэты дзень';

  @override
  String get filterRecentlyAddedLabel => 'Нядаўна дададзены';

  @override
  String get filterRatingRejectedLabel => 'Адхілена';

  @override
  String get filterTypeAnimatedLabel => 'Аніміраваныя';

  @override
  String get filterTypeMotionPhotoLabel => 'Фота з рухам';

  @override
  String get filterTypePanoramaLabel => 'Панарама';

  @override
  String get filterTypeRawLabel => 'Raw';

  @override
  String get filterTypeSphericalVideoLabel => 'Відэа 360°';

  @override
  String get filterTypeGeotiffLabel => 'GeoTIFF';

  @override
  String get filterMimeImageLabel => 'Малюнак';

  @override
  String get filterMimeVideoLabel => 'Відэа';

  @override
  String get accessibilityAnimationsRemove => 'Прадухіленне экранных эфектаў';

  @override
  String get accessibilityAnimationsKeep => 'Захаваць экранныя эфекты';

  @override
  String get albumTierNew => 'Новы';

  @override
  String get albumTierPinned => 'Замацаваны';

  @override
  String get albumTierSpecial => 'Стандартныя';

  @override
  String get albumTierApps => 'Праграмы';

  @override
  String get albumTierVaults => 'Сховішчы';

  @override
  String get albumTierDynamic => 'Dynamic';

  @override
  String get albumTierRegular => 'Іншыя';

  @override
  String get coordinateFormatDms => 'Градусы, хвіліны і секунды';

  @override
  String get coordinateFormatDdm => 'DDM';

  @override
  String get coordinateFormatDecimal => 'Дзесятковы градус';

  @override
  String coordinateDms(String coordinate, String direction) {
    return '$coordinate $direction';
  }

  @override
  String get coordinateDmsNorth => 'Пн';

  @override
  String get coordinateDmsSouth => 'Пд';

  @override
  String get coordinateDmsEast => 'У';

  @override
  String get coordinateDmsWest => 'З';

  @override
  String get displayRefreshRatePreferHighest => 'Найвышэйшая частата';

  @override
  String get displayRefreshRatePreferLowest => 'Найменшая частата';

  @override
  String get keepScreenOnNever => 'Ніколі';

  @override
  String get keepScreenOnVideoPlayback => 'Падчас прайгравання відэа';

  @override
  String get keepScreenOnViewerOnly => 'Толькі ў праглядніку';

  @override
  String get keepScreenOnAlways => 'Заўсёды';

  @override
  String get lengthUnitPixel => 'px';

  @override
  String get lengthUnitPercent => '%';

  @override
  String get mapStyleGoogleNormal => 'Карты Google';

  @override
  String get mapStyleGoogleHybrid => 'Карты Google (гібрыд)';

  @override
  String get mapStyleGoogleTerrain => 'Карты Google (Рэльеф мясцовасці)';

  @override
  String get mapStyleOsmLiberty => 'OSM Liberty';

  @override
  String get mapStyleOpenTopoMap => 'OpenTopoMap';

  @override
  String get mapStyleOsmHot => 'Гуманітарная ОСМ';

  @override
  String get mapStyleStamenWatercolor => 'Тычынка Акварэль';

  @override
  String get maxBrightnessNever => 'Ніколі';

  @override
  String get maxBrightnessAlways => 'Заўсёды';

  @override
  String get nameConflictStrategyRename => 'Перайменаваць';

  @override
  String get nameConflictStrategyReplace => 'Замяніць';

  @override
  String get nameConflictStrategySkip => 'Прапусціць';

  @override
  String get overlayHistogramNone => 'Не';

  @override
  String get overlayHistogramRGB => 'RGB';

  @override
  String get overlayHistogramLuminance => 'Яркасць';

  @override
  String get subtitlePositionTop => 'Верх';

  @override
  String get subtitlePositionBottom => 'Ніз';

  @override
  String get themeBrightnessLight => 'Светлая';

  @override
  String get themeBrightnessDark => 'Цёмная';

  @override
  String get themeBrightnessBlack => 'Чорная';

  @override
  String get unitSystemMetric => 'Метрычныя';

  @override
  String get unitSystemImperial => 'Англійскія';

  @override
  String get vaultLockTypePattern => 'Шаблон';

  @override
  String get vaultLockTypePin => 'PIN-код';

  @override
  String get vaultLockTypePassword => 'Пароль';

  @override
  String get settingsVideoEnablePip => 'Карцінка ў карцінцы';

  @override
  String get videoControlsPlayOutside => 'Адкрыць у іншым прайгравальніку';

  @override
  String get videoLoopModeNever => 'Ніколі';

  @override
  String get videoLoopModeShortOnly => 'Толькі для кароткіх відэа';

  @override
  String get videoLoopModeAlways => 'Заўсёды';

  @override
  String get videoPlaybackSkip => 'Прапусціць';

  @override
  String get videoPlaybackMuted => 'Прайграваць без гуку';

  @override
  String get videoPlaybackWithSound => 'Прайграваць з гукам';

  @override
  String get videoResumptionModeNever => 'Ніколі';

  @override
  String get videoResumptionModeAlways => 'Заўсёды';

  @override
  String get viewerTransitionSlide => 'Слізгаценне';

  @override
  String get viewerTransitionParallax => 'Паралакс';

  @override
  String get viewerTransitionFade => 'Згасанне';

  @override
  String get viewerTransitionZoomIn => 'Павялічыць';

  @override
  String get viewerTransitionNone => 'Нічога';

  @override
  String get wallpaperTargetHome => 'Галоўны экран';

  @override
  String get wallpaperTargetLock => 'Экран блакіроўкі';

  @override
  String get wallpaperTargetHomeLock => 'На абодва экраны';

  @override
  String get widgetDisplayedItemRandom => 'Выпадковы';

  @override
  String get widgetDisplayedItemMostRecent => 'Самы апошні';

  @override
  String get widgetOpenPageHome => 'Адкрыйце галоўную старонку';

  @override
  String get widgetOpenPageCollection => 'Адкрыць калекцыю';

  @override
  String get widgetOpenPageViewer => 'Адкрыйце аглядальнік';

  @override
  String get widgetTapUpdateWidget => 'Абнавіць віджэт';

  @override
  String get storageVolumeDescriptionFallbackPrimary => 'Унутраная памяць';

  @override
  String get storageVolumeDescriptionFallbackNonPrimary => 'SD-карта';

  @override
  String get rootDirectoryDescription => 'каранёвы каталог';

  @override
  String otherDirectoryDescription(String name) {
    return 'Каталог «$name»';
  }

  @override
  String storageAccessDialogMessage(String directory, String volume) {
    return 'Калі ласка, выберыце $directory «$volume» на наступным экране, каб даць гэтай праграме доступ да яго.';
  }

  @override
  String restrictedAccessDialogMessage(String directory, String volume) {
    return 'Гэтай праграме забаронена змяняць файлы ў $directory «$volume».\n\nКаб перамясціць элементы ў іншую дырэкторыю, выкарыстоўвайце папярэдне ўсталяваны дыспетчар файлаў або праграму галерэі.';
  }

  @override
  String notEnoughSpaceDialogMessage(String neededSize, String freeSize, String volume) {
    return 'Для завяршэння гэтай аперацыі патрабуецца $neededSize вольнага месца на «$volume», але засталося толькі $freeSize.';
  }

  @override
  String get missingSystemFilePickerDialogMessage => 'Сістэмная праграма выбару файлаў адсутнічае ці адключана. Калі ласка, уключыце яе і паспрабуйце яшчэ раз.';

  @override
  String unsupportedTypeDialogMessage(int count, String types) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Гэта аперацыя не падтрымліваецца для элементаў наступных тыпаў: $types.',
      one: 'Гэта аперацыя не падтрымліваецца для элементаў наступнага тыпу: $types.',
    );
    return '$_temp0';
  }

  @override
  String get nameConflictDialogSingleSourceMessage => 'Некаторыя файлы ў тэчцы прызначэння маюць аднолькавыя назвы.';

  @override
  String get nameConflictDialogMultipleSourceMessage => 'Некаторыя файлы маюць аднолькавыя назвы.';

  @override
  String get addShortcutDialogLabel => 'Назва ярлыка';

  @override
  String get addShortcutButtonLabel => 'ДАДАЦЬ';

  @override
  String get noMatchingAppDialogMessage => 'Няма праграм, якія б з гэтым справіліся.';

  @override
  String binEntriesConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Перамясціць гэтыя $count элементаў у сметніцу?',
      few: 'Перамясціць гэтыя $count элемента ў сметніцу?',
      one: 'Перамясціць гэты элемент у сметніцу?',
    );
    return '$_temp0';
  }

  @override
  String deleteEntriesConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Выдаліць гэтыя $count элементаў?',
      few: 'Выдаліць гэтыя $count элемента?',
      one: 'Выдаліць гэты элемент?',
    );
    return '$_temp0';
  }

  @override
  String get moveUndatedConfirmationDialogMessage => 'Захаваць даты элементаў, перш чым працягнуць?';

  @override
  String get moveUndatedConfirmationDialogSetDate => 'Захаваць даты';

  @override
  String videoResumeDialogMessage(String time) {
    return 'Вы хочаце аднавіць прайграванне на $time?';
  }

  @override
  String get videoStartOverButtonLabel => 'ПАЧАЦЬ НАНАВА';

  @override
  String get videoResumeButtonLabel => 'АДНАВІЦЬ';

  @override
  String get setCoverDialogLatest => 'Апошні элемент';

  @override
  String get setCoverDialogAuto => 'Аўто';

  @override
  String get setCoverDialogCustom => 'Свая';

  @override
  String get hideFilterConfirmationDialogMessage => 'Адпаведныя фота і відэа будуць схаваны з вашай калекцыі. Вы можаце паказаць іх зноў у наладах «Прыватнасць».\n\nВы ўпэўнены, што хочаце іх схаваць?';

  @override
  String get newAlbumDialogTitle => 'Новы альбом';

  @override
  String get newAlbumDialogNameLabel => 'Назва альбома';

  @override
  String get newAlbumDialogAlbumAlreadyExistsHelper => 'Album already exists';

  @override
  String get newAlbumDialogNameLabelAlreadyExistsHelper => 'Каталог ўжо існуе';

  @override
  String get newAlbumDialogStorageLabel => 'Захоўванне:';

  @override
  String get newDynamicAlbumDialogTitle => 'New Dynamic Album';

  @override
  String get dynamicAlbumAlreadyExists => 'Dynamic album already exists';

  @override
  String get newVaultWarningDialogMessage => 'Элементы ў сховішчах даступныя толькі гэтай праграме і нікому больш.\n\nКалі вы выдаліце гэту праграму або ачысціце даныя праграмы, вы страціце ўсе гэтыя элементы.';

  @override
  String get newVaultDialogTitle => 'Новае сховішча';

  @override
  String get configureVaultDialogTitle => 'Наладзьце сховішча';

  @override
  String get vaultDialogLockModeWhenScreenOff => 'Блакіроўка пры выключэнні экрана';

  @override
  String get vaultDialogLockTypeLabel => 'Тып блакіроўкі';

  @override
  String get patternDialogEnter => 'Увядзіце ключ';

  @override
  String get patternDialogConfirm => 'Пацвердзіце графічны ключ';

  @override
  String get pinDialogEnter => 'Увядзіце PIN-код';

  @override
  String get pinDialogConfirm => 'Пацвердзіце PIN-код';

  @override
  String get passwordDialogEnter => 'Увядзіце пароль';

  @override
  String get passwordDialogConfirm => 'Пацвердзіце пароль';

  @override
  String get authenticateToConfigureVault => 'Прайдзіце аўтэнтыфікацыю, каб наладзіць сховішча';

  @override
  String get authenticateToUnlockVault => 'Прайдзіце аўтэнтыфікацыю, каб разблакіраваць сховішча';

  @override
  String get vaultBinUsageDialogMessage => 'Некаторыя сховішчы выкарыстоўваюць сметніцу.';

  @override
  String get renameAlbumDialogLabel => 'Новая назва';

  @override
  String get renameAlbumDialogLabelAlreadyExistsHelper => 'Каталог ужо існуе';

  @override
  String get renameEntrySetPageTitle => 'Перайменаваць';

  @override
  String get renameEntrySetPagePatternFieldLabel => 'Шаблон наймення';

  @override
  String get renameEntrySetPageInsertTooltip => 'Поле для ўстаўкі';

  @override
  String get renameEntrySetPagePreviewSectionTitle => 'Папярэдні прагляд';

  @override
  String get renameProcessorCounter => 'Лічыльнік';

  @override
  String get renameProcessorHash => 'Хэш';

  @override
  String get renameProcessorName => 'Імя';

  @override
  String deleteSingleAlbumConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Выдаліць гэты альбом і $count элементаў у ім?',
      few: 'Выдаліць гэты альбом і $count элементы ў ім?',
      one: 'Выдаліць гэты альбом і элемент у ім?',
    );
    return '$_temp0';
  }

  @override
  String deleteMultiAlbumConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Выдаліць гэтыя альбомы і $count элементаў у іх?',
      few: 'Выдаліць гэтыя альбомы і $count элементы ў іх?',
      one: 'Выдаліць гэтыя альбомы і элемент у іх?',
    );
    return '$_temp0';
  }

  @override
  String get exportEntryDialogFormat => 'Фармат:';

  @override
  String get exportEntryDialogWidth => 'Шырыня';

  @override
  String get exportEntryDialogHeight => 'Вышыня';

  @override
  String get exportEntryDialogQuality => 'Якасць';

  @override
  String get exportEntryDialogWriteMetadata => 'Запісаць метададзеныя';

  @override
  String get renameEntryDialogLabel => 'Новая назва';

  @override
  String get editEntryDialogCopyFromItem => 'Скапіяваць з іншага элемента';

  @override
  String get editEntryDialogTargetFieldsHeader => 'Поля для рэдагавання';

  @override
  String get editEntryDateDialogTitle => 'Дата і час';

  @override
  String get editEntryDateDialogSetCustom => 'Устанавіць дату';

  @override
  String get editEntryDateDialogCopyField => 'Скапіяваць з іншай даты';

  @override
  String get editEntryDateDialogExtractFromTitle => 'Выняць з назвы';

  @override
  String get editEntryDateDialogShift => 'Зрух';

  @override
  String get editEntryDateDialogSourceFileModifiedDate => 'Дата змены файла';

  @override
  String get durationDialogHours => 'Гадзіны';

  @override
  String get durationDialogMinutes => 'Хвіліны';

  @override
  String get durationDialogSeconds => 'Секунды';

  @override
  String get editEntryLocationDialogTitle => 'Месцазнаходжанне';

  @override
  String get editEntryLocationDialogSetCustom => 'Рэдагаваць месцазнаходжанне';

  @override
  String get editEntryLocationDialogChooseOnMap => 'Выбраць на карце';

  @override
  String get editEntryLocationDialogImportGpx => 'Import GPX';

  @override
  String get editEntryLocationDialogLatitude => 'Шырата';

  @override
  String get editEntryLocationDialogLongitude => 'Даўгата';

  @override
  String get editEntryLocationDialogTimeShift => 'Time shift';

  @override
  String get locationPickerUseThisLocationButton => 'Выкарыстоўваць гэтае месцазнаходжанне';

  @override
  String get editEntryRatingDialogTitle => 'Рэйтынг';

  @override
  String get removeEntryMetadataDialogTitle => 'Выдаленне метададзеных';

  @override
  String get removeEntryMetadataDialogAll => 'All';

  @override
  String get removeEntryMetadataDialogMore => 'Больш';

  @override
  String get removeEntryMetadataMotionPhotoXmpWarningDialogMessage => 'XMP патрабуецца для прайгравання відэа ўнутры фота з рухам.\n\nВы ўпэўнены, што хочаце выдаліць яго?';

  @override
  String get videoSpeedDialogLabel => 'Хуткасць прайгравання';

  @override
  String get videoStreamSelectionDialogVideo => 'Відэа';

  @override
  String get videoStreamSelectionDialogAudio => 'Аўдыё';

  @override
  String get videoStreamSelectionDialogText => 'Субтытры';

  @override
  String get videoStreamSelectionDialogOff => 'Адкл.';

  @override
  String get videoStreamSelectionDialogTrack => 'Трэк';

  @override
  String get videoStreamSelectionDialogNoSelection => 'Іншых трэкаў няма.';

  @override
  String get genericSuccessFeedback => 'Гатова!';

  @override
  String get genericFailureFeedback => 'Не атрымалася';

  @override
  String get genericDangerWarningDialogMessage => 'Вы ўпэўнены?';

  @override
  String get tooManyItemsErrorDialogMessage => 'Паўтарыце спробу з меншай колькасцю элементаў.';

  @override
  String get menuActionConfigureView => 'Выгляд';

  @override
  String get menuActionSelect => 'Выбраць';

  @override
  String get menuActionSelectAll => 'Выбраць усе';

  @override
  String get menuActionSelectNone => 'Зняць вылучэнне';

  @override
  String get menuActionMap => 'Карта';

  @override
  String get menuActionSlideshow => 'Слайд-шоў';

  @override
  String get menuActionStats => 'Статыстыка';

  @override
  String get viewDialogSortSectionTitle => 'Сартаваць';

  @override
  String get viewDialogGroupSectionTitle => 'Групоўка';

  @override
  String get viewDialogLayoutSectionTitle => 'Макет';

  @override
  String get viewDialogReverseSortOrder => 'Адваротны парадак сартавання';

  @override
  String get tileLayoutMosaic => 'Мазаіка';

  @override
  String get tileLayoutGrid => 'Сетка';

  @override
  String get tileLayoutList => 'Спіс';

  @override
  String get castDialogTitle => 'Прылады трансляцыі';

  @override
  String get coverDialogTabCover => 'Вокладка';

  @override
  String get coverDialogTabApp => 'Праграма';

  @override
  String get coverDialogTabColor => 'Колер';

  @override
  String get appPickDialogTitle => 'Выбраць праграму';

  @override
  String get appPickDialogNone => 'Нічога';

  @override
  String get aboutPageTitle => 'Пра нас';

  @override
  String get aboutLinkLicense => 'Ліцэнзія';

  @override
  String get aboutLinkPolicy => 'Палітыка канфідэнцыяльнасці';

  @override
  String get aboutBugSectionTitle => 'Паведаміць пра памылку';

  @override
  String get aboutBugSaveLogInstruction => 'Захавайце логі праграмы ў файл';

  @override
  String get aboutBugCopyInfoInstruction => 'Скапіяваць сістэмную інфармацыю';

  @override
  String get aboutBugCopyInfoButton => 'Скапіяваць';

  @override
  String get aboutBugReportInstruction => 'Адправіць справаздачу аб памылцы на GitHub разам з журналамі і сістэмнай інфармацыяй';

  @override
  String get aboutBugReportButton => 'Адправіць справаздачу';

  @override
  String get aboutDataUsageSectionTitle => 'Выкарыстанне дадзеных';

  @override
  String get aboutDataUsageData => 'Дадзеныя';

  @override
  String get aboutDataUsageCache => 'Кэш';

  @override
  String get aboutDataUsageDatabase => 'База дадзеных';

  @override
  String get aboutDataUsageMisc => 'Розныя';

  @override
  String get aboutDataUsageInternal => 'Унутранае';

  @override
  String get aboutDataUsageExternal => 'Знешні';

  @override
  String get aboutDataUsageClearCache => 'Ачысціць кэш';

  @override
  String get aboutCreditsSectionTitle => 'Падзякі';

  @override
  String get aboutCreditsWorldAtlas1 => 'Гэта праграма выкарыстоўвае файл TopoJSON з';

  @override
  String get aboutCreditsWorldAtlas2 => 'пад ліцэнзіяй ISC.';

  @override
  String get aboutTranslatorsSectionTitle => 'Перакладчыкі';

  @override
  String get aboutLicensesSectionTitle => 'Ліцэнзіі з адкрытым зыходным кодам';

  @override
  String get aboutLicensesBanner => 'Гэта праграма выкарыстоўвае наступныя пакеты і бібліятэкі з адкрытым зыходным кодам.';

  @override
  String get aboutLicensesAndroidLibrariesSectionTitle => 'Бібліятэкі Android';

  @override
  String get aboutLicensesFlutterPluginsSectionTitle => 'Плагіны Flutter';

  @override
  String get aboutLicensesFlutterPackagesSectionTitle => 'Пакеты Flutter';

  @override
  String get aboutLicensesDartPackagesSectionTitle => 'Пакеты Dart';

  @override
  String get aboutLicensesShowAllButtonLabel => 'Паказаць усе ліцэнзіі';

  @override
  String get policyPageTitle => 'Палітыка канфідэнцыяльнасці';

  @override
  String get collectionPageTitle => 'Калекцыя';

  @override
  String get collectionPickPageTitle => 'Выбраць';

  @override
  String get collectionSelectPageTitle => 'Выбраць элементы';

  @override
  String get collectionActionShowTitleSearch => 'Паказаць фільтр загалоўка';

  @override
  String get collectionActionHideTitleSearch => 'Схаваць фільтр загалоўка';

  @override
  String get collectionActionAddDynamicAlbum => 'Add dynamic album';

  @override
  String get collectionActionAddShortcut => 'Дадаць ярлык';

  @override
  String get collectionActionSetHome => 'Усталяваць як галоўную';

  @override
  String get collectionActionEmptyBin => 'Ачысціць сметніцу';

  @override
  String get collectionActionCopy => 'Скапіяваць у альбом';

  @override
  String get collectionActionMove => 'Перамясціць у альбом';

  @override
  String get collectionActionRescan => 'Паўторнае сканаванне';

  @override
  String get collectionActionEdit => 'Рэдагаваць';

  @override
  String get collectionSearchTitlesHintText => 'Пошук загалоўкаў';

  @override
  String get collectionGroupAlbum => 'Па альбоме';

  @override
  String get collectionGroupMonth => 'Па месяцу';

  @override
  String get collectionGroupDay => 'Па днях';

  @override
  String get collectionGroupNone => 'Не групаваць';

  @override
  String get sectionUnknown => 'Невядома';

  @override
  String get dateToday => 'Сёння';

  @override
  String get dateYesterday => 'Учора';

  @override
  String get dateThisMonth => 'У гэтым месяцы';

  @override
  String collectionDeleteFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Не атрымалася выдаліць $count элементаў',
      few: 'Не атрымалася выдаліць $count элементы',
      one: 'Не атрымалася выдаліць 1 элемент',
    );
    return '$_temp0';
  }

  @override
  String collectionCopyFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Не атрымалася скапіюваць $count элементаў',
      few: 'Не атрымалася скапіюваць $count элементы',
      one: 'Не атрымалася скапіюваць 1 элемент',
    );
    return '$_temp0';
  }

  @override
  String collectionMoveFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Немагчыма перанесці $count элементаў',
      few: 'Немагчыма перанесці $count элементы',
      one: 'Немагчыма перанесці 1 элемент',
    );
    return '$_temp0';
  }

  @override
  String collectionRenameFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Не атрымалася перайменаваць $count элементаў',
      few: 'Не атрымалася перайменаваць $count элементы',
      one: 'Не атрымалася перайменаваць 1 элемент',
    );
    return '$_temp0';
  }

  @override
  String collectionEditFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Немагчыма адрэдагаваць $count элементаў',
      few: 'Немагчыма адрэдагаваць $count элементы',
      one: 'Немагчыма адрэдагаваць 1 элемент',
    );
    return '$_temp0';
  }

  @override
  String collectionExportFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Не атрымалася экспартаваць $count старонак',
      few: 'Не атрымалася экспартаваць $count старонкі',
      one: 'Не атрымалася экспартаваць 1 старонку',
    );
    return '$_temp0';
  }

  @override
  String collectionCopySuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count элементаў скапіявана',
      few: '$count элементы скапіявана',
      one: '1 элемент скапіяваны',
    );
    return '$_temp0';
  }

  @override
  String collectionMoveSuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Перамяшчаны $count элементаў',
      few: 'Перамяшчаны $count элементы',
      one: 'Перамяшчаны 1 элемент',
    );
    return '$_temp0';
  }

  @override
  String collectionRenameSuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Перайменаваны $count элементаў',
      few: 'Перайменаваны $count элементы',
      one: 'Перайменаваны 1 элемент',
    );
    return '$_temp0';
  }

  @override
  String collectionEditSuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count элементаў адрэдагаваны',
      few: '$count элементы адрэдагаваны',
      one: '1 элемент адрэдагаваны',
    );
    return '$_temp0';
  }

  @override
  String get collectionEmptyFavourites => 'Няма абраных';

  @override
  String get collectionEmptyVideos => 'Няма відэа';

  @override
  String get collectionEmptyImages => 'Няма выяў';

  @override
  String get collectionEmptyGrantAccessButtonLabel => 'Даць доступ';

  @override
  String get collectionSelectSectionTooltip => 'Выбраць раздзел';

  @override
  String get collectionDeselectSectionTooltip => 'Адмяніць выбар раздзела';

  @override
  String get drawerAboutButton => 'Пра нас';

  @override
  String get drawerSettingsButton => 'Налады';

  @override
  String get drawerCollectionAll => 'Уся калекцыя';

  @override
  String get drawerCollectionFavourites => 'Абраныя';

  @override
  String get drawerCollectionImages => 'Выявы';

  @override
  String get drawerCollectionVideos => 'Відэа';

  @override
  String get drawerCollectionAnimated => 'Анімацыі';

  @override
  String get drawerCollectionMotionPhotos => 'Фота з рухам';

  @override
  String get drawerCollectionPanoramas => 'Панарамы';

  @override
  String get drawerCollectionRaws => 'Raw фатаграфіі';

  @override
  String get drawerCollectionSphericalVideos => '360° Відэа';

  @override
  String get drawerAlbumPage => 'Альбомы';

  @override
  String get drawerCountryPage => 'Краіны';

  @override
  String get drawerPlacePage => 'Месцы';

  @override
  String get drawerTagPage => 'Тэгі';

  @override
  String get sortByDate => 'Па даце';

  @override
  String get sortByName => 'Па назве';

  @override
  String get sortByItemCount => 'Па колькасці элементаў';

  @override
  String get sortBySize => 'Па памеры';

  @override
  String get sortByAlbumFileName => 'Па назве альбома і файла';

  @override
  String get sortByRating => 'Па рэйтынгу';

  @override
  String get sortByDuration => 'Па працягласці';

  @override
  String get sortOrderNewestFirst => 'Спачатку самае новае';

  @override
  String get sortOrderOldestFirst => 'Спачатку самы стары';

  @override
  String get sortOrderAtoZ => 'Ад А да Я';

  @override
  String get sortOrderZtoA => 'Ад Я да А';

  @override
  String get sortOrderHighestFirst => 'Спачатку з высокім';

  @override
  String get sortOrderLowestFirst => 'Спачатку з нізкім';

  @override
  String get sortOrderLargestFirst => 'Спачатку вялікія';

  @override
  String get sortOrderSmallestFirst => 'Спачатку маленькі';

  @override
  String get sortOrderShortestFirst => 'Спачатку самы кароткі';

  @override
  String get sortOrderLongestFirst => 'Спачатку самы доўгі';

  @override
  String get albumGroupTier => 'Па ўзроўні';

  @override
  String get albumGroupType => 'Па тыпу';

  @override
  String get albumGroupVolume => 'Па аб\'ёме захоўвання';

  @override
  String get albumGroupNone => 'Не групаваць';

  @override
  String get albumMimeTypeMixed => 'Змешаны';

  @override
  String get albumPickPageTitleCopy => 'Капіяваць у альбом';

  @override
  String get albumPickPageTitleExport => 'Экспарт у альбом';

  @override
  String get albumPickPageTitleMove => 'Перамясціць у альбом';

  @override
  String get albumPickPageTitlePick => 'Выбраць Альбом';

  @override
  String get albumCamera => 'Камера';

  @override
  String get albumDownload => 'Загрузкі';

  @override
  String get albumScreenshots => 'Скрыншоты';

  @override
  String get albumScreenRecordings => 'Запісы экрана';

  @override
  String get albumVideoCaptures => 'Відэазапісы';

  @override
  String get albumPageTitle => 'Альбомы';

  @override
  String get albumEmpty => 'Няма альбомаў';

  @override
  String get createAlbumButtonLabel => 'СТВАРЫЦЬ';

  @override
  String get newFilterBanner => 'новы';

  @override
  String get countryPageTitle => 'Краіны';

  @override
  String get countryEmpty => 'Няма краін';

  @override
  String get statePageTitle => 'Штаты';

  @override
  String get stateEmpty => 'Няма штатаў';

  @override
  String get placePageTitle => 'Месцы';

  @override
  String get placeEmpty => 'Няма месцаў';

  @override
  String get tagPageTitle => 'Тэгі';

  @override
  String get tagEmpty => 'Няма тэгаў';

  @override
  String get binPageTitle => 'Сметніца';

  @override
  String get explorerPageTitle => 'Правадыр';

  @override
  String get explorerActionSelectStorageVolume => 'Выбраць сховішча';

  @override
  String get selectStorageVolumeDialogTitle => 'Выбраць сховішча';

  @override
  String get searchCollectionFieldHint => 'Пошук калекцый';

  @override
  String get searchRecentSectionTitle => 'Апошнія';

  @override
  String get searchDateSectionTitle => 'Дата';

  @override
  String get searchAlbumsSectionTitle => 'Альбомы';

  @override
  String get searchCountriesSectionTitle => 'Краіны';

  @override
  String get searchStatesSectionTitle => 'Штаты';

  @override
  String get searchPlacesSectionTitle => 'Месцы';

  @override
  String get searchTagsSectionTitle => 'Тэгі';

  @override
  String get searchRatingSectionTitle => 'Рэйтынгі';

  @override
  String get searchMetadataSectionTitle => 'Метададзеныя';

  @override
  String get settingsPageTitle => 'Налады';

  @override
  String get settingsSystemDefault => 'Як ў сістэме';

  @override
  String get settingsDefault => 'Па змаўчанні';

  @override
  String get settingsDisabled => 'Адкл.';

  @override
  String get settingsAskEverytime => 'Пытацца кожны раз';

  @override
  String get settingsModificationWarningDialogMessage => 'Іншыя налады будуць зменены.';

  @override
  String get settingsSearchFieldLabel => 'Пошук налад';

  @override
  String get settingsSearchEmpty => 'Няма адпаведнай налады';

  @override
  String get settingsActionExport => 'Экспарт';

  @override
  String get settingsActionExportDialogTitle => 'Экспарт';

  @override
  String get settingsActionImport => 'Імпарт';

  @override
  String get settingsActionImportDialogTitle => 'Імпарт';

  @override
  String get appExportCovers => 'Вокладкі';

  @override
  String get appExportDynamicAlbums => 'Dynamic albums';

  @override
  String get appExportFavourites => 'Абранае';

  @override
  String get appExportSettings => 'Налады';

  @override
  String get settingsNavigationSectionTitle => 'Навігацыя';

  @override
  String get settingsHomeTile => 'Галоўная';

  @override
  String get settingsHomeDialogTitle => 'Галоўная';

  @override
  String get setHomeCustom => 'Па-свойму';

  @override
  String get settingsShowBottomNavigationBar => 'Паказаць ніжнюю панэль навігацыі';

  @override
  String get settingsKeepScreenOnTile => 'Трымаць экран уключаным';

  @override
  String get settingsKeepScreenOnDialogTitle => 'Трымаць экран уключаным';

  @override
  String get settingsDoubleBackExit => 'Двойчы націсніце «назад», каб выйсці';

  @override
  String get settingsConfirmationTile => 'Дыялогі пацверджання';

  @override
  String get settingsConfirmationDialogTitle => 'Дыялогі пацверджання';

  @override
  String get settingsConfirmationBeforeDeleteItems => 'Спытаць, перш чым выдаляць элементы назаўжды';

  @override
  String get settingsConfirmationBeforeMoveToBinItems => 'Спытаць перад тым, як пераносіць элементы ў сметніцу';

  @override
  String get settingsConfirmationBeforeMoveUndatedItems => 'Спытаць, перш чым перамяшчаць прадметы без даты';

  @override
  String get settingsConfirmationAfterMoveToBinItems => 'Паказваць паведамленне пасля перамяшчэння элементаў у сметніцу';

  @override
  String get settingsConfirmationVaultDataLoss => 'Паказаць папярэджанне аб страце даных сховішча';

  @override
  String get settingsNavigationDrawerTile => 'Меню навігацыі';

  @override
  String get settingsNavigationDrawerEditorPageTitle => 'Меню навігацыі';

  @override
  String get settingsNavigationDrawerBanner => 'Націсніце і ўтрымлівайце для перамяшчэння і змены парадку пунктаў меню.';

  @override
  String get settingsNavigationDrawerTabTypes => 'Тыпы';

  @override
  String get settingsNavigationDrawerTabAlbums => 'Альбомы';

  @override
  String get settingsNavigationDrawerTabPages => 'Старонкі';

  @override
  String get settingsNavigationDrawerAddAlbum => 'Дадаць альбом';

  @override
  String get settingsThumbnailSectionTitle => 'Мініяцюры';

  @override
  String get settingsThumbnailOverlayTile => 'Навязванне';

  @override
  String get settingsThumbnailOverlayPageTitle => 'Навязванне';

  @override
  String get settingsThumbnailShowHdrIcon => 'Паказаць значок HDR';

  @override
  String get settingsThumbnailShowFavouriteIcon => 'Паказаць значок абранага';

  @override
  String get settingsThumbnailShowTagIcon => 'Паказаць значок тэга';

  @override
  String get settingsThumbnailShowLocationIcon => 'Паказаць значок месцазнаходжання';

  @override
  String get settingsThumbnailShowMotionPhotoIcon => 'Паказаць значок фота з рухам';

  @override
  String get settingsThumbnailShowRating => 'Паказаць рэйтынг';

  @override
  String get settingsThumbnailShowRawIcon => 'Паказаць значок raw';

  @override
  String get settingsThumbnailShowVideoDuration => 'Паказаць працягласць відэа';

  @override
  String get settingsCollectionQuickActionsTile => 'Хуткія дзеянні';

  @override
  String get settingsCollectionQuickActionEditorPageTitle => 'Хуткія дзеянні';

  @override
  String get settingsCollectionQuickActionTabBrowsing => 'Прагляд';

  @override
  String get settingsCollectionQuickActionTabSelecting => 'Выбар';

  @override
  String get settingsCollectionBrowsingQuickActionEditorBanner => 'Націсніце і ўтрымлівайце, каб перамясціць кнопкі і выбраць дзеянні, якія будуць адлюстроўвацца пры праглядзе элементаў.';

  @override
  String get settingsCollectionSelectionQuickActionEditorBanner => 'Націсніце і ўтрымлівайце, каб перамясціць кнопкі і выбраць дзеянні, якія будуць адлюстроўвацца пры выбары элементаў.';

  @override
  String get settingsCollectionBurstPatternsTile => 'Шаблоны ўспышкі';

  @override
  String get settingsCollectionBurstPatternsNone => 'Без ўспышкі';

  @override
  String get settingsViewerSectionTitle => 'Прагляднік';

  @override
  String get settingsViewerGestureSideTapNext => 'Дакраніцеся да краёў экрана, каб паказаць папярэдні/наступны элемент';

  @override
  String get settingsViewerUseCutout => 'Выкарыстоўваць вобласць выраза';

  @override
  String get settingsViewerMaximumBrightness => 'Максімальная яркасць';

  @override
  String get settingsMotionPhotoAutoPlay => 'Аўтаматычнае прайграванне фатаграфій з рухам';

  @override
  String get settingsImageBackground => 'Фон выявы';

  @override
  String get settingsViewerQuickActionsTile => 'Хуткія дзеянні';

  @override
  String get settingsViewerQuickActionEditorPageTitle => 'Хуткія дзеянні';

  @override
  String get settingsViewerQuickActionEditorBanner => 'Націсніце і ўтрымлівайце, каб перамяшчаць кнопкі і выбіраць дзеянні для адлюстравання ў праглядніку.';

  @override
  String get settingsViewerQuickActionEditorDisplayedButtonsSectionTitle => 'Адлюстраваныя кнопкі';

  @override
  String get settingsViewerQuickActionEditorAvailableButtonsSectionTitle => 'Даступныя кнопкі';

  @override
  String get settingsViewerQuickActionEmpty => 'Няма кнопак';

  @override
  String get settingsViewerOverlayTile => 'Навязванне';

  @override
  String get settingsViewerOverlayPageTitle => 'Навязванне';

  @override
  String get settingsViewerShowOverlayOnOpening => 'Паказаць на адкрыцці';

  @override
  String get settingsViewerShowHistogram => 'Паказаць гістаграму';

  @override
  String get settingsViewerShowMinimap => 'Паказаць мінікарту';

  @override
  String get settingsViewerShowInformation => 'Паказаць інфармацыю';

  @override
  String get settingsViewerShowInformationSubtitle => 'Паказаць назву, дату, месцазнаходжанне і г.д.';

  @override
  String get settingsViewerShowRatingTags => 'Паказаць рэйтынг і тэгі';

  @override
  String get settingsViewerShowShootingDetails => 'Паказаць дэталі здымкі';

  @override
  String get settingsViewerShowDescription => 'Паказаць апісанне';

  @override
  String get settingsViewerShowOverlayThumbnails => 'Паказаць мініяцюры';

  @override
  String get settingsViewerEnableOverlayBlurEffect => 'Эфект размыцця';

  @override
  String get settingsViewerSlideshowTile => 'Слайд-шоў';

  @override
  String get settingsViewerSlideshowPageTitle => 'Слайд-шоў';

  @override
  String get settingsSlideshowRepeat => 'Паўтарэнне';

  @override
  String get settingsSlideshowShuffle => 'Ператасаваць';

  @override
  String get settingsSlideshowFillScreen => 'Запоўніць экран';

  @override
  String get settingsSlideshowAnimatedZoomEffect => 'Аніміраваны эфект маштабавання';

  @override
  String get settingsSlideshowTransitionTile => 'Пераход';

  @override
  String get settingsSlideshowIntervalTile => 'Інтэрвал';

  @override
  String get settingsSlideshowVideoPlaybackTile => 'Прайграванне відэа';

  @override
  String get settingsSlideshowVideoPlaybackDialogTitle => 'Прайграванне відэа';

  @override
  String get settingsVideoPageTitle => 'Налады відэа';

  @override
  String get settingsVideoSectionTitle => 'Відэа';

  @override
  String get settingsVideoShowVideos => 'Паказаць відэа';

  @override
  String get settingsVideoPlaybackTile => 'Прайграванне';

  @override
  String get settingsVideoPlaybackPageTitle => 'Прайграванне';

  @override
  String get settingsVideoEnableHardwareAcceleration => 'Апаратнае паскарэнне';

  @override
  String get settingsVideoAutoPlay => 'Аўтапрайграванне';

  @override
  String get settingsVideoLoopModeTile => 'Цыклічны рэжым';

  @override
  String get settingsVideoLoopModeDialogTitle => 'Цыклічны рэжым';

  @override
  String get settingsVideoResumptionModeTile => 'Працягнуць прайграванне';

  @override
  String get settingsVideoResumptionModeDialogTitle => 'Працягнуць прайграванне';

  @override
  String get settingsVideoBackgroundMode => 'Фонавы рэжым';

  @override
  String get settingsVideoBackgroundModeDialogTitle => 'Фонавы рэжым';

  @override
  String get settingsVideoControlsTile => 'Элементы кіравання';

  @override
  String get settingsVideoControlsPageTitle => 'Элементы кіравання';

  @override
  String get settingsVideoButtonsTile => 'Кнопкі';

  @override
  String get settingsVideoGestureDoubleTapTogglePlay => 'Двойчы націсніце, каб прайграць/прыпыніць';

  @override
  String get settingsVideoGestureSideDoubleTapSeek => 'Двойчы націсніце на край экрана, каб перайсці назад/наперад';

  @override
  String get settingsVideoGestureVerticalDragBrightnessVolume => 'Правядзіце пальцам уверх ці ўніз, каб наладзіць яркасць/гучнасць';

  @override
  String get settingsSubtitleThemeTile => 'Субтытры';

  @override
  String get settingsSubtitleThemePageTitle => 'Субтытры';

  @override
  String get settingsSubtitleThemeSample => 'Гэта ўзор.';

  @override
  String get settingsSubtitleThemeTextAlignmentTile => 'Выраўноўванне тэксту';

  @override
  String get settingsSubtitleThemeTextAlignmentDialogTitle => 'Выраўноўванне тэксту';

  @override
  String get settingsSubtitleThemeTextPositionTile => 'Палажэнне тэксту';

  @override
  String get settingsSubtitleThemeTextPositionDialogTitle => 'Палажэнне тэксту';

  @override
  String get settingsSubtitleThemeTextSize => 'Памер тэксту';

  @override
  String get settingsSubtitleThemeShowOutline => 'Паказаць контур і цень';

  @override
  String get settingsSubtitleThemeTextColor => 'Колер тэксту';

  @override
  String get settingsSubtitleThemeTextOpacity => 'Непразрыстасць тэксту';

  @override
  String get settingsSubtitleThemeBackgroundColor => 'Колер фону';

  @override
  String get settingsSubtitleThemeBackgroundOpacity => 'Непразрыстасць фону';

  @override
  String get settingsSubtitleThemeTextAlignmentLeft => 'Злева';

  @override
  String get settingsSubtitleThemeTextAlignmentCenter => 'Па цэнтры';

  @override
  String get settingsSubtitleThemeTextAlignmentRight => 'Справа';

  @override
  String get settingsPrivacySectionTitle => 'Канфідэнцыяльнасць';

  @override
  String get settingsAllowInstalledAppAccess => 'Дазволіць доступ да інвентара праграм';

  @override
  String get settingsAllowInstalledAppAccessSubtitle => 'Выкарыстоўваецца для паляпшэння адлюстравання альбомаў';

  @override
  String get settingsAllowErrorReporting => 'Дазволіць ананімнае паведамленне пра памылкі';

  @override
  String get settingsSaveSearchHistory => 'Захаваць гісторыю пошуку';

  @override
  String get settingsEnableBin => 'Выкарыстоўваць сметніцу';

  @override
  String get settingsEnableBinSubtitle => 'Захоўвае выдаленыя элементы на працягу 30 дзён';

  @override
  String get settingsDisablingBinWarningDialogMessage => 'Элементы ў сметніцы будуць выдалены назаўсёды.';

  @override
  String get settingsAllowMediaManagement => 'Дазволіць кіраванне мультымедыя';

  @override
  String get settingsHiddenItemsTile => 'Схаваныя элементы';

  @override
  String get settingsHiddenItemsPageTitle => 'Схаваныя элементы';

  @override
  String get settingsHiddenFiltersBanner => 'Фота і відэа, якія адпавядаюць схаваным фільтрам, не будуць адлюстроўвацца ў вашай калекцыі.';

  @override
  String get settingsHiddenFiltersEmpty => 'Няма схаваных фільтраў';

  @override
  String get settingsStorageAccessTile => 'Доступ да сховішча';

  @override
  String get settingsStorageAccessPageTitle => 'Доступ да сховішча';

  @override
  String get settingsStorageAccessBanner => 'Некаторыя каталогі патрабуюць відавочнага дазволу на змяненне файлаў у іх. Тут вы можаце прагледзець каталогі, да якіх вы раней далі доступ.';

  @override
  String get settingsStorageAccessEmpty => 'Доступ не прадстаўлены';

  @override
  String get settingsStorageAccessRevokeTooltip => 'Адклікаць';

  @override
  String get settingsAccessibilitySectionTitle => 'Спецыяльныя магчымасці';

  @override
  String get settingsRemoveAnimationsTile => 'Выдаліць анімацыі';

  @override
  String get settingsRemoveAnimationsDialogTitle => 'Выдаліць анімацыі';

  @override
  String get settingsTimeToTakeActionTile => 'Час выканання';

  @override
  String get settingsAccessibilityShowPinchGestureAlternatives => 'Паказваць альтэрнатывы мультисенсорным жэстам';

  @override
  String get settingsDisplaySectionTitle => 'Адлюстраванне';

  @override
  String get settingsThemeBrightnessTile => 'Тэма';

  @override
  String get settingsThemeBrightnessDialogTitle => 'Тэма';

  @override
  String get settingsThemeColorHighlights => 'Каляровыя акцэнты';

  @override
  String get settingsThemeEnableDynamicColor => 'Дынамічны колер';

  @override
  String get settingsDisplayRefreshRateModeTile => 'Частата абнаўлення экрана';

  @override
  String get settingsDisplayRefreshRateModeDialogTitle => 'Частата абнаўлення';

  @override
  String get settingsDisplayUseTvInterface => 'Інтэрфейс Android TV';

  @override
  String get settingsLanguageSectionTitle => 'Мова і фарматы';

  @override
  String get settingsLanguageTile => 'Мова';

  @override
  String get settingsLanguagePageTitle => 'Мова';

  @override
  String get settingsCoordinateFormatTile => 'Фармат каардынат';

  @override
  String get settingsCoordinateFormatDialogTitle => 'Фармат каардынат';

  @override
  String get settingsUnitSystemTile => 'Адзінкі вымярэння';

  @override
  String get settingsUnitSystemDialogTitle => 'Адзінкі вымярэння';

  @override
  String get settingsForceWesternArabicNumeralsTile => 'Прымусовыя арабскія лічбы';

  @override
  String get settingsScreenSaverPageTitle => 'Застаўка на экран';

  @override
  String get settingsWidgetPageTitle => 'Фотарамка';

  @override
  String get settingsWidgetShowOutline => 'Вылучэнне';

  @override
  String get settingsWidgetOpenPage => 'Пры націску на віджэт';

  @override
  String get settingsWidgetDisplayedItem => 'Адлюстраваны элемент';

  @override
  String get settingsCollectionTile => 'Калекцыя';

  @override
  String get statsPageTitle => 'Статыстыка';

  @override
  String statsWithGps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count элементаў з месцазнаходжаннем',
      few: '$count элементы з месцазнаходжаннем',
      one: '1 элемент з месцазнаходжаннем',
    );
    return '$_temp0';
  }

  @override
  String get statsTopCountriesSectionTitle => 'Топ Краін';

  @override
  String get statsTopStatesSectionTitle => 'Топ краін';

  @override
  String get statsTopPlacesSectionTitle => 'Лепшыя месцы';

  @override
  String get statsTopTagsSectionTitle => 'Лепшыя тэгі';

  @override
  String get statsTopAlbumsSectionTitle => 'Лепшыя альбомы';

  @override
  String get viewerOpenPanoramaButtonLabel => 'АДКРЫЦЬ ПАНАРАМУ';

  @override
  String get viewerSetWallpaperButtonLabel => 'УСТАНАВІЦЬ ШПАЛЕРЫ';

  @override
  String get viewerErrorUnknown => 'Ой!';

  @override
  String get viewerErrorDoesNotExist => 'Файл больш не існуе.';

  @override
  String get viewerInfoPageTitle => 'Інфармацыя';

  @override
  String get viewerInfoBackToViewerTooltip => 'Вярнуцца да аглядальніка';

  @override
  String get viewerInfoUnknown => 'невядома';

  @override
  String get viewerInfoLabelDescription => 'Апісанне';

  @override
  String get viewerInfoLabelTitle => 'Назва';

  @override
  String get viewerInfoLabelDate => 'Дата';

  @override
  String get viewerInfoLabelResolution => 'Разрозненне';

  @override
  String get viewerInfoLabelSize => 'Памер';

  @override
  String get viewerInfoLabelUri => 'URI';

  @override
  String get viewerInfoLabelPath => 'Шлях';

  @override
  String get viewerInfoLabelDuration => 'Працягласць';

  @override
  String get viewerInfoLabelOwner => 'Уладальнік';

  @override
  String get viewerInfoLabelCoordinates => 'Каардынаты';

  @override
  String get viewerInfoLabelAddress => 'Адрас';

  @override
  String get mapStyleDialogTitle => 'Стыль карты';

  @override
  String get mapStyleTooltip => 'Выберыце стыль карты';

  @override
  String get mapZoomInTooltip => 'Павелічэнне';

  @override
  String get mapZoomOutTooltip => 'Змяншэння';

  @override
  String get mapPointNorthUpTooltip => 'Пакажыце поўнач уверх';

  @override
  String get mapAttributionOsmData => 'Даныя карты © [OpenStreetMap](https://www.openstreetmap.org/copyright) удзельнікі';

  @override
  String get mapAttributionOsmLiberty => 'Tiles by [OpenMapTiles](https://www.openmaptiles.org/), [CC BY](http://creativecommons.org/licenses/by/4.0) • Hosted by [OSM Americana](https://tile.ourmap.us)';

  @override
  String get mapAttributionOpenTopoMap => '[SRTM](https://www.earthdata.nasa.gov/sensors/srtm) | Пліткі ад [OpenTopoMap](https://opentopomap.org/), [CC BY-SA](https://creativecommons.org/licenses/by-sa/3.0/)';

  @override
  String get mapAttributionOsmHot => 'Пліткі ад [HOT](https://www.hotosm.org/) • Арганізаваны [OSM France](https://openstreetmap.fr/)';

  @override
  String get mapAttributionStamen => 'Пліткі ад [Stamen Design](https://stamen.com), [CC BY 3.0](https://creativecommons.org/licenses/by/3.0)';

  @override
  String get openMapPageTooltip => 'Паглядзець на старонцы карты';

  @override
  String get mapEmptyRegion => 'Няма малюнкаў у гэтым рэгіёне';

  @override
  String get viewerInfoOpenEmbeddedFailureFeedback => 'Не ўдалося атрымаць убудаваныя даныя';

  @override
  String get viewerInfoOpenLinkText => 'Адкрыць';

  @override
  String get viewerInfoViewXmlLinkText => 'Прагляд XML';

  @override
  String get viewerInfoSearchFieldLabel => 'Пошук метададзеных';

  @override
  String get viewerInfoSearchEmpty => 'Няма адпаведных ключоў';

  @override
  String get viewerInfoSearchSuggestionDate => 'Дата і час';

  @override
  String get viewerInfoSearchSuggestionDescription => 'Апісанне';

  @override
  String get viewerInfoSearchSuggestionDimensions => 'Памеры';

  @override
  String get viewerInfoSearchSuggestionResolution => 'Разрозненне';

  @override
  String get viewerInfoSearchSuggestionRights => 'Правы';

  @override
  String get wallpaperUseScrollEffect => 'Выкарыстоўвайце эфект пракруткі на галоўным экране';

  @override
  String get tagEditorPageTitle => 'Рэдагаваць тэгі';

  @override
  String get tagEditorPageNewTagFieldLabel => 'Новы тэг';

  @override
  String get tagEditorPageAddTagTooltip => 'Дадаць тэг';

  @override
  String get tagEditorSectionRecent => 'Апошнія';

  @override
  String get tagEditorSectionPlaceholders => 'Запаўняльнікі';

  @override
  String get tagEditorDiscardDialogMessage => 'Вы хочаце адмяніць змены?';

  @override
  String get tagPlaceholderCountry => 'Краіна';

  @override
  String get tagPlaceholderState => 'Дзяржава';

  @override
  String get tagPlaceholderPlace => 'Месца';

  @override
  String get panoramaEnableSensorControl => 'Уключыць сэнсарнае кіраванне';

  @override
  String get panoramaDisableSensorControl => 'Адключыць сэнсарнае кіраванне';

  @override
  String get sourceViewerPageTitle => 'Крыніца';

  @override
  String get filePickerShowHiddenFiles => 'Паказаць схаваныя файлы';

  @override
  String get filePickerDoNotShowHiddenFiles => 'Не паказваць схаваныя файлы';

  @override
  String get filePickerOpenFrom => 'Адкрыць з';

  @override
  String get filePickerNoItems => 'Няма элементаў';

  @override
  String get filePickerUseThisFolder => 'Выкарыстоўваць гэтую тэчку';
}
