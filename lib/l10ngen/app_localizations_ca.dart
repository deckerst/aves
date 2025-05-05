// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Catalan Valencian (`ca`).
class AppLocalizationsCa extends AppLocalizations {
  AppLocalizationsCa([String locale = 'ca']) : super(locale);

  @override
  String get appName => 'Aves';

  @override
  String get welcomeMessage => 'Benvingut a Aves';

  @override
  String get welcomeOptional => 'Opcional';

  @override
  String get welcomeTermsToggle => 'Estic d’acord amb els termes i condicions';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elements',
      one: '$count element',
    );
    return '$_temp0';
  }

  @override
  String columnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count columnes',
      one: '$count columna',
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
      other: '$countString segons',
      one: '$countString segon',
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
      other: '$countString minuts',
      one: '$countString minut',
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
      other: '$countString dies',
      one: '$countString dia',
    );
    return '$_temp0';
  }

  @override
  String focalLength(String length) {
    return '$length mm';
  }

  @override
  String get applyButtonLabel => 'APLICAR';

  @override
  String get deleteButtonLabel => 'SUPRIMEIX';

  @override
  String get nextButtonLabel => 'SEGÜENT';

  @override
  String get showButtonLabel => 'MOSTRAR';

  @override
  String get hideButtonLabel => 'AMAGAR';

  @override
  String get continueButtonLabel => 'CONTINUAR';

  @override
  String get saveCopyButtonLabel => 'GUARDAR CÒPIA';

  @override
  String get applyTooltip => 'Aplicar';

  @override
  String get cancelTooltip => 'Canceŀlar';

  @override
  String get changeTooltip => 'Canviar';

  @override
  String get clearTooltip => 'Netejar';

  @override
  String get previousTooltip => 'Anterior';

  @override
  String get nextTooltip => 'Següent';

  @override
  String get showTooltip => 'Mostrar';

  @override
  String get hideTooltip => 'Amagar';

  @override
  String get actionRemove => 'Eliminar';

  @override
  String get resetTooltip => 'Restableix';

  @override
  String get saveTooltip => 'Desa';

  @override
  String get stopTooltip => 'Parar';

  @override
  String get pickTooltip => 'Escollir';

  @override
  String get doubleBackExitMessage => 'Torneu a tocar «enrere» per sortir.';

  @override
  String get doNotAskAgain => 'No tornis a preguntar';

  @override
  String get sourceStateLoading => 'Carregant';

  @override
  String get sourceStateCataloguing => 'Catalogant';

  @override
  String get sourceStateLocatingCountries => 'Localitzant països';

  @override
  String get sourceStateLocatingPlaces => 'Localitzant llocs';

  @override
  String get chipActionDelete => 'Suprimeix';

  @override
  String get chipActionRemove => 'Eliminar';

  @override
  String get chipActionShowCollection => 'Mostrar a Coŀlecció';

  @override
  String get chipActionGoToAlbumPage => 'Mostra als Àlbums';

  @override
  String get chipActionGoToCountryPage => 'Mostra als Països';

  @override
  String get chipActionGoToPlacePage => 'Mostra als Llocs';

  @override
  String get chipActionGoToTagPage => 'Mostra a les etiquetes';

  @override
  String get chipActionGoToExplorerPage => 'Mostrar a l’Explorador';

  @override
  String get chipActionDecompose => 'Dividir';

  @override
  String get chipActionFilterOut => 'Filtrar';

  @override
  String get chipActionFilterIn => 'Filtrar';

  @override
  String get chipActionHide => 'Amagar';

  @override
  String get chipActionLock => 'Bloquejar';

  @override
  String get chipActionPin => 'Ancora a dalt';

  @override
  String get chipActionUnpin => 'Desancora de dalt';

  @override
  String get chipActionRename => 'Canviar nom';

  @override
  String get chipActionSetCover => 'Escollir coberta';

  @override
  String get chipActionShowCountryStates => 'Mostrar estats';

  @override
  String get chipActionCreateAlbum => 'Crear àlbum';

  @override
  String get chipActionCreateVault => 'Crear una caixa forta';

  @override
  String get chipActionConfigureVault => 'Configurar caixa forta';

  @override
  String get entryActionCopyToClipboard => 'Copiar al porta-retalls';

  @override
  String get entryActionDelete => 'Esborrar';

  @override
  String get entryActionConvert => 'Convertir';

  @override
  String get entryActionExport => 'Exportar';

  @override
  String get entryActionInfo => 'Informació';

  @override
  String get entryActionRename => 'Canviar nom';

  @override
  String get entryActionRestore => 'Restaurar';

  @override
  String get entryActionRotateCCW => 'Girar en sentit antihorari';

  @override
  String get entryActionRotateCW => 'Girar en sentit horari';

  @override
  String get entryActionFlip => 'Voltar horitzontalment';

  @override
  String get entryActionPrint => 'Imprimir';

  @override
  String get entryActionShare => 'Compartir';

  @override
  String get entryActionShareImageOnly => 'Compartir només imatge';

  @override
  String get entryActionShareVideoOnly => 'Compartir només vídeo';

  @override
  String get entryActionViewSource => 'Veure font';

  @override
  String get entryActionShowGeoTiffOnMap => 'Mostra com a mapa superposat';

  @override
  String get entryActionConvertMotionPhotoToStillImage => 'Convertir a imatge fixa';

  @override
  String get entryActionViewMotionPhotoVideo => 'Obrir vídeo';

  @override
  String get entryActionEdit => 'Editar';

  @override
  String get entryActionOpen => 'Obrir amb';

  @override
  String get entryActionSetAs => 'Definir com';

  @override
  String get entryActionCast => 'Transmetre';

  @override
  String get entryActionOpenMap => 'Mostrar en aplicació de mapes';

  @override
  String get entryActionRotateScreen => 'Girar pantalla';

  @override
  String get entryActionAddFavourite => 'Afegir a preferits';

  @override
  String get entryActionRemoveFavourite => 'Treure de preferits';

  @override
  String get videoActionCaptureFrame => 'Capturar fotograma';

  @override
  String get videoActionMute => 'Silencia';

  @override
  String get videoActionUnmute => 'Activar so';

  @override
  String get videoActionPause => 'Pausa';

  @override
  String get videoActionPlay => 'Reproduir';

  @override
  String get videoActionReplay10 => 'Retrocedeix 10 segons';

  @override
  String get videoActionSkip10 => 'Avança 10 segons';

  @override
  String get videoActionShowPreviousFrame => 'Mostrar el marc anterior';

  @override
  String get videoActionShowNextFrame => 'Mostrar el següent fotograma';

  @override
  String get videoActionSelectStreams => 'Seleccionar pista';

  @override
  String get videoActionSetSpeed => 'Velocitat de reproducció';

  @override
  String get videoActionABRepeat => 'Repetir A-B';

  @override
  String get videoRepeatActionSetStart => 'Establir l’inici';

  @override
  String get videoRepeatActionSetEnd => 'Establir el final';

  @override
  String get viewerActionSettings => 'Configuració';

  @override
  String get viewerActionLock => 'Bloquejar visualitzador';

  @override
  String get viewerActionUnlock => 'Desbloquejar visualitzador';

  @override
  String get slideshowActionResume => 'Reprèn';

  @override
  String get slideshowActionShowInCollection => 'Mostrar a Coŀlecció';

  @override
  String get entryInfoActionEditDate => 'Edita la data i l’hora';

  @override
  String get entryInfoActionEditLocation => 'Editar localització';

  @override
  String get entryInfoActionEditTitleDescription => 'Editar títol i descripció';

  @override
  String get entryInfoActionEditRating => 'Editar valoració';

  @override
  String get entryInfoActionEditTags => 'Editar etiquetes';

  @override
  String get entryInfoActionRemoveMetadata => 'Esborrar metadades';

  @override
  String get entryInfoActionExportMetadata => 'Exportar metadades';

  @override
  String get entryInfoActionRemoveLocation => 'Esborrar localització';

  @override
  String get editorActionTransform => 'Transformar';

  @override
  String get editorTransformCrop => 'Retallar';

  @override
  String get editorTransformRotate => 'Girar';

  @override
  String get cropAspectRatioFree => 'Lliure';

  @override
  String get cropAspectRatioOriginal => 'Original';

  @override
  String get cropAspectRatioSquare => 'Quadrat';

  @override
  String get filterAspectRatioLandscapeLabel => 'Paisatge';

  @override
  String get filterAspectRatioPortraitLabel => 'Retrat';

  @override
  String get filterBinLabel => 'Paperera de reciclatge';

  @override
  String get filterFavouriteLabel => 'Preferida';

  @override
  String get filterNoDateLabel => 'Sense data';

  @override
  String get filterNoAddressLabel => 'Sense adreça';

  @override
  String get filterLocatedLabel => 'Localitzat';

  @override
  String get filterNoLocationLabel => 'Deslocalitzat';

  @override
  String get filterNoRatingLabel => 'Sense valoració';

  @override
  String get filterTaggedLabel => 'Etiquetat';

  @override
  String get filterNoTagLabel => 'Sense etiqueta';

  @override
  String get filterNoTitleLabel => 'Sense títol';

  @override
  String get filterOnThisDayLabel => 'D’avui';

  @override
  String get filterRecentlyAddedLabel => 'Afegit recentment';

  @override
  String get filterRatingRejectedLabel => 'Rebutjat';

  @override
  String get filterTypeAnimatedLabel => 'Animat';

  @override
  String get filterTypeMotionPhotoLabel => 'Foto en moviment';

  @override
  String get filterTypePanoramaLabel => 'Panoràmica';

  @override
  String get filterTypeRawLabel => 'Raw';

  @override
  String get filterTypeSphericalVideoLabel => '360° Vídeo';

  @override
  String get filterTypeGeotiffLabel => 'GeoTIFF';

  @override
  String get filterMimeImageLabel => 'Imatge';

  @override
  String get filterMimeVideoLabel => 'Vídeo';

  @override
  String get accessibilityAnimationsRemove => 'Evitar efectes de pantalla';

  @override
  String get accessibilityAnimationsKeep => 'Mantenir efectes de pantalla';

  @override
  String get albumTierNew => 'Nou';

  @override
  String get albumTierPinned => 'Fixat';

  @override
  String get albumTierSpecial => 'Comú';

  @override
  String get albumTierApps => 'Aplicacions';

  @override
  String get albumTierVaults => 'Caixes fortes';

  @override
  String get albumTierDynamic => 'Dinàmic';

  @override
  String get albumTierRegular => 'Altres';

  @override
  String get coordinateFormatDms => 'DMS';

  @override
  String get coordinateFormatDdm => 'DDM';

  @override
  String get coordinateFormatDecimal => 'Graus decimals';

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
  String get coordinateDmsWest => 'O';

  @override
  String get displayRefreshRatePreferHighest => 'Taxa més alta';

  @override
  String get displayRefreshRatePreferLowest => 'Taxa més baixa';

  @override
  String get keepScreenOnNever => 'Mai';

  @override
  String get keepScreenOnVideoPlayback => 'Durant la reproducció de vídeo';

  @override
  String get keepScreenOnViewerOnly => 'Només la pàgina del visualitzador';

  @override
  String get keepScreenOnAlways => 'Sempre';

  @override
  String get lengthUnitPixel => 'px';

  @override
  String get lengthUnitPercent => '%';

  @override
  String get mapStyleGoogleNormal => 'Google Maps';

  @override
  String get mapStyleGoogleHybrid => 'Google Maps (Híbrid)';

  @override
  String get mapStyleGoogleTerrain => 'Google Maps (Terreny)';

  @override
  String get mapStyleOsmLiberty => 'OSM Liberty';

  @override
  String get mapStyleOpenTopoMap => 'OpenTopoMap';

  @override
  String get mapStyleOsmHot => 'Humanitarian OSM';

  @override
  String get mapStyleStamenWatercolor => 'Stamen Watercolor';

  @override
  String get maxBrightnessNever => 'Mai';

  @override
  String get maxBrightnessAlways => 'Sempre';

  @override
  String get nameConflictStrategyRename => 'Canviar nom';

  @override
  String get nameConflictStrategyReplace => 'Substituir';

  @override
  String get nameConflictStrategySkip => 'Saltar';

  @override
  String get overlayHistogramNone => 'Cap';

  @override
  String get overlayHistogramRGB => 'RGB';

  @override
  String get overlayHistogramLuminance => 'Lluminància';

  @override
  String get subtitlePositionTop => 'A dalt';

  @override
  String get subtitlePositionBottom => 'A baix';

  @override
  String get themeBrightnessLight => 'Llum';

  @override
  String get themeBrightnessDark => 'Fosc';

  @override
  String get themeBrightnessBlack => 'Negre';

  @override
  String get unitSystemMetric => 'Mètric';

  @override
  String get unitSystemImperial => 'Imperial';

  @override
  String get vaultLockTypePattern => 'Patró';

  @override
  String get vaultLockTypePin => 'PIN';

  @override
  String get vaultLockTypePassword => 'Contrasenya';

  @override
  String get settingsVideoEnablePip => 'Imatge-en-imatge';

  @override
  String get videoControlsPlayOutside => 'Obrir amb un altre reproductor';

  @override
  String get videoLoopModeNever => 'Mai';

  @override
  String get videoLoopModeShortOnly => 'Només vídeos curts';

  @override
  String get videoLoopModeAlways => 'Sempre';

  @override
  String get videoPlaybackSkip => 'Saltar';

  @override
  String get videoPlaybackMuted => 'Reproduir sense so';

  @override
  String get videoPlaybackWithSound => 'Reproduir amb so';

  @override
  String get videoResumptionModeNever => 'Mai';

  @override
  String get videoResumptionModeAlways => 'Sempre';

  @override
  String get viewerTransitionSlide => 'Lliscar';

  @override
  String get viewerTransitionParallax => 'Paraŀlaxi';

  @override
  String get viewerTransitionFade => 'Esvair';

  @override
  String get viewerTransitionZoomIn => 'Ampliar';

  @override
  String get viewerTransitionNone => 'Cap';

  @override
  String get wallpaperTargetHome => 'Pàgina principal';

  @override
  String get wallpaperTargetLock => 'Pàgina de bloqueig';

  @override
  String get wallpaperTargetHomeLock => 'Pàgina principal i de bloqueig';

  @override
  String get widgetDisplayedItemRandom => 'Aleatori';

  @override
  String get widgetDisplayedItemMostRecent => 'Més recent';

  @override
  String get widgetOpenPageHome => 'Obrir casa';

  @override
  String get widgetOpenPageCollection => 'Obrir coŀlecció';

  @override
  String get widgetOpenPageViewer => 'Obrir visualitzador';

  @override
  String get widgetTapUpdateWidget => 'Actualitzar giny';

  @override
  String get storageVolumeDescriptionFallbackPrimary => 'Espai intern';

  @override
  String get storageVolumeDescriptionFallbackNonPrimary => 'Targeta SD';

  @override
  String get rootDirectoryDescription => 'Directori arrel';

  @override
  String otherDirectoryDescription(String name) {
    return '«$name» directori';
  }

  @override
  String storageAccessDialogMessage(String directory, String volume) {
    return 'Si us plau, selecciona el $directory a «$volume» a la següent pantalla per donar-li accés a aquesta aplicació.';
  }

  @override
  String restrictedAccessDialogMessage(String directory, String volume) {
    return 'Aquesta aplicació no té permís per modificar arxius de $directory a «$volume».\n\nSi us plau, feu servir un gestor d’arxius o l’aplicació de galeria preinstaŀlada per moure els elements a un altre directori.';
  }

  @override
  String notEnoughSpaceDialogMessage(String neededSize, String freeSize, String volume) {
    return 'Aquesta operació necessita $neededSize d’espai lliure a «$volume» per completar-se, però només hi ha $freeSize lliure.';
  }

  @override
  String get missingSystemFilePickerDialogMessage => 'Falta el selector de fitxers del sistema o està desactivat. Si us plau, activeu-lo i torneu-ho a provar.';

  @override
  String unsupportedTypeDialogMessage(int count, String types) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Aquesta operació no és compatible amb elements dels següents formats: $types.',
      one: 'Aquesta operació no és compatible amb elements del següent format: $types.',
    );
    return '$_temp0';
  }

  @override
  String get nameConflictDialogSingleSourceMessage => 'Alguns fitxers de la carpeta de destinació tenen el mateix nom.';

  @override
  String get nameConflictDialogMultipleSourceMessage => 'Alguns fitxers tenen el mateix nom.';

  @override
  String get addShortcutDialogLabel => 'Etiqueta de la drecera';

  @override
  String get addShortcutButtonLabel => 'AFEGEIX';

  @override
  String get noMatchingAppDialogMessage => 'No hi ha aplicacions que puguin gestionar-ho.';

  @override
  String binEntriesConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Moure aquests $count elements a la paperera de reciclatge?',
      one: 'Moure aquest element a la paperera de reciclatge?',
    );
    return '$_temp0';
  }

  @override
  String deleteEntriesConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Esborrar aquests $count elements?',
      one: 'Esborrar aquest element?',
    );
    return '$_temp0';
  }

  @override
  String get moveUndatedConfirmationDialogMessage => 'Desar les dates dels elements abans de continuar?';

  @override
  String get moveUndatedConfirmationDialogSetDate => 'Guardar dates';

  @override
  String videoResumeDialogMessage(String time) {
    return 'Vols continuar reproduint a $time?';
  }

  @override
  String get videoStartOverButtonLabel => 'TORNAR A COMENÇAR';

  @override
  String get videoResumeButtonLabel => 'REPRENDRE';

  @override
  String get setCoverDialogLatest => 'Últim element';

  @override
  String get setCoverDialogAuto => 'Automàtic';

  @override
  String get setCoverDialogCustom => 'Personalitzat';

  @override
  String get hideFilterConfirmationDialogMessage => 'Les fotos i els vídeos coincidents s’amagaran de la teva coŀlecció. Podeu tornar-los a mostrar des de la configuració de «Privadesa».\n\nEsteu segur que voleu amagar-los?';

  @override
  String get newAlbumDialogTitle => 'Àlbum nou';

  @override
  String get newAlbumDialogNameLabel => 'Nom de l’Àlbum';

  @override
  String get newAlbumDialogAlbumAlreadyExistsHelper => 'L’àlbum ja existeix';

  @override
  String get newAlbumDialogNameLabelAlreadyExistsHelper => 'El directori ja existeix';

  @override
  String get newAlbumDialogStorageLabel => 'Emmagatzematge:';

  @override
  String get newDynamicAlbumDialogTitle => 'Nou àlbum dinàmic';

  @override
  String get dynamicAlbumAlreadyExists => 'L’àlbum dinàmic ja existeix';

  @override
  String get newVaultWarningDialogMessage => 'Els elements en caixes fortes només son disponibles des d’aquesta aplicació.\n\nSi desinstaŀles aquesta aplicació o en borres les dades, perdràs aquests elements.';

  @override
  String get newVaultDialogTitle => 'Caixa forta nova';

  @override
  String get configureVaultDialogTitle => 'Configura caixa forta';

  @override
  String get vaultDialogLockModeWhenScreenOff => 'Bloqueja quan la pantalla s’apagui';

  @override
  String get vaultDialogLockTypeLabel => 'Tipus de bloqueig';

  @override
  String get patternDialogEnter => 'Introdueix patró';

  @override
  String get patternDialogConfirm => 'Confirma patró';

  @override
  String get pinDialogEnter => 'Introdueix PIN';

  @override
  String get pinDialogConfirm => 'Confirma PIN';

  @override
  String get passwordDialogEnter => 'Introdueix contrasenya';

  @override
  String get passwordDialogConfirm => 'Confirma contrasenya';

  @override
  String get authenticateToConfigureVault => 'Autentifica la configuració de la caixa forta';

  @override
  String get authenticateToUnlockVault => 'Autentifica per desbloquejar caixa forta';

  @override
  String get vaultBinUsageDialogMessage => 'Algunes caixes fortes fan servir la paperera de reciclatge.';

  @override
  String get renameAlbumDialogLabel => 'Nom nou';

  @override
  String get renameAlbumDialogLabelAlreadyExistsHelper => 'El directori ja existeix';

  @override
  String get renameEntrySetPageTitle => 'Canviar nom';

  @override
  String get renameEntrySetPagePatternFieldLabel => 'Patró de nomenament';

  @override
  String get renameEntrySetPageInsertTooltip => 'Insereix camp';

  @override
  String get renameEntrySetPagePreviewSectionTitle => 'Previsualitza';

  @override
  String get renameProcessorCounter => 'Comptador';

  @override
  String get renameProcessorHash => 'Hash';

  @override
  String get renameProcessorName => 'Nom';

  @override
  String deleteSingleAlbumConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Eliminar aquest àlbum i els $count elements que conté?',
      one: 'Eliminar aquest àlbum i l’element que conté?',
    );
    return '$_temp0';
  }

  @override
  String deleteMultiAlbumConfirmationDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Eliminar aquests àlbums i els $count elements que contenen?',
      one: 'Eliminar aquest àlbum i l’element que conté?',
    );
    return '$_temp0';
  }

  @override
  String get exportEntryDialogFormat => 'Format:';

  @override
  String get exportEntryDialogWidth => 'Amplada';

  @override
  String get exportEntryDialogHeight => 'Alçada';

  @override
  String get exportEntryDialogQuality => 'Qualitat';

  @override
  String get exportEntryDialogWriteMetadata => 'Escriu metadades';

  @override
  String get renameEntryDialogLabel => 'Nom nou';

  @override
  String get editEntryDialogCopyFromItem => 'Copiar d’un altre element';

  @override
  String get editEntryDialogTargetFieldsHeader => 'Camps a modificar';

  @override
  String get editEntryDateDialogTitle => 'Data i Hora';

  @override
  String get editEntryDateDialogSetCustom => 'Defineix data personalitzada';

  @override
  String get editEntryDateDialogCopyField => 'Copiar d’una altra data';

  @override
  String get editEntryDateDialogExtractFromTitle => 'Extreu del títol';

  @override
  String get editEntryDateDialogShift => 'Desplaça';

  @override
  String get editEntryDateDialogSourceFileModifiedDate => 'Data del fitxer modificat';

  @override
  String get durationDialogHours => 'Hores';

  @override
  String get durationDialogMinutes => 'Minuts';

  @override
  String get durationDialogSeconds => 'Segons';

  @override
  String get editEntryLocationDialogTitle => 'Localització';

  @override
  String get editEntryLocationDialogSetCustom => 'Defineix localització personalitzada';

  @override
  String get editEntryLocationDialogChooseOnMap => 'Escull al mapa';

  @override
  String get editEntryLocationDialogImportGpx => 'Importar GPX';

  @override
  String get editEntryLocationDialogLatitude => 'Latitud';

  @override
  String get editEntryLocationDialogLongitude => 'Longitud';

  @override
  String get editEntryLocationDialogTimeShift => 'Desplaçament de l’hora';

  @override
  String get locationPickerUseThisLocationButton => 'Utilitza aquesta localització';

  @override
  String get editEntryRatingDialogTitle => 'Valoració';

  @override
  String get removeEntryMetadataDialogTitle => 'Esborra metadades';

  @override
  String get removeEntryMetadataDialogAll => 'Tot';

  @override
  String get removeEntryMetadataDialogMore => 'Més';

  @override
  String get removeEntryMetadataMotionPhotoXmpWarningDialogMessage => 'Es necessita XMP per reproduir el vídeo dins una foto en moviment.\n\nEstàs segur que ho vols esborrar?';

  @override
  String get videoSpeedDialogLabel => 'Velocitat de reproducció';

  @override
  String get videoStreamSelectionDialogVideo => 'Vídeo';

  @override
  String get videoStreamSelectionDialogAudio => 'Àudio';

  @override
  String get videoStreamSelectionDialogText => 'Subtítols';

  @override
  String get videoStreamSelectionDialogOff => 'Desactivat';

  @override
  String get videoStreamSelectionDialogTrack => 'Pista';

  @override
  String get videoStreamSelectionDialogNoSelection => 'No hi ha altres pistes.';

  @override
  String get genericSuccessFeedback => 'Fet!';

  @override
  String get genericFailureFeedback => 'Fallit';

  @override
  String get genericDangerWarningDialogMessage => 'Estàs segur?';

  @override
  String get tooManyItemsErrorDialogMessage => 'Torna-ho a provar amb menys elements.';

  @override
  String get menuActionConfigureView => 'Vista';

  @override
  String get menuActionSelect => 'Selecciona';

  @override
  String get menuActionSelectAll => 'Selecciona tots';

  @override
  String get menuActionSelectNone => 'Selecciona’n cap';

  @override
  String get menuActionMap => 'Mapa';

  @override
  String get menuActionSlideshow => 'Presentació de diapositives';

  @override
  String get menuActionStats => 'Estadístiques';

  @override
  String get viewDialogSortSectionTitle => 'Ordena';

  @override
  String get viewDialogGroupSectionTitle => 'Agrupa';

  @override
  String get viewDialogLayoutSectionTitle => 'Disposició';

  @override
  String get viewDialogReverseSortOrder => 'Inverteix l’ordre';

  @override
  String get tileLayoutMosaic => 'Mosaic';

  @override
  String get tileLayoutGrid => 'Quadrícula';

  @override
  String get tileLayoutList => 'Llista';

  @override
  String get castDialogTitle => 'Dispositius d’emissió';

  @override
  String get coverDialogTabCover => 'Coberta';

  @override
  String get coverDialogTabApp => 'Aplicació';

  @override
  String get coverDialogTabColor => 'Color';

  @override
  String get appPickDialogTitle => 'Tria l’aplicació';

  @override
  String get appPickDialogNone => 'Cap';

  @override
  String get aboutPageTitle => 'Sobre';

  @override
  String get aboutLinkLicense => 'Llicència';

  @override
  String get aboutLinkPolicy => 'Política de Privacitat';

  @override
  String get aboutBugSectionTitle => 'Informe d’error';

  @override
  String get aboutBugSaveLogInstruction => 'Desa els registres de l’aplicació en un fitxer';

  @override
  String get aboutBugCopyInfoInstruction => 'Copia la informació del sistema';

  @override
  String get aboutBugCopyInfoButton => 'Copia';

  @override
  String get aboutBugReportInstruction => 'Reporta a GitHub amb els logs i la informació del sistema';

  @override
  String get aboutBugReportButton => 'Informe';

  @override
  String get aboutDataUsageSectionTitle => 'Ús de dades';

  @override
  String get aboutDataUsageData => 'Dades';

  @override
  String get aboutDataUsageCache => 'Cache';

  @override
  String get aboutDataUsageDatabase => 'Base de dades';

  @override
  String get aboutDataUsageMisc => 'Misc';

  @override
  String get aboutDataUsageInternal => 'Intern';

  @override
  String get aboutDataUsageExternal => 'Extern';

  @override
  String get aboutDataUsageClearCache => 'Netejar Cache';

  @override
  String get aboutCreditsSectionTitle => 'Crèdits';

  @override
  String get aboutCreditsWorldAtlas1 => 'Aquesta aplicació utilitza el format de fitxers TopoJSON';

  @override
  String get aboutCreditsWorldAtlas2 => 'sota llicència ISC.';

  @override
  String get aboutTranslatorsSectionTitle => 'Traductors';

  @override
  String get aboutLicensesSectionTitle => 'Llicències de codi obert';

  @override
  String get aboutLicensesBanner => 'Aquesta aplicació utilitza els següents paquets i biblioteques de codi obert.';

  @override
  String get aboutLicensesAndroidLibrariesSectionTitle => 'Llibreries Android';

  @override
  String get aboutLicensesFlutterPluginsSectionTitle => 'Plugins de Flutter';

  @override
  String get aboutLicensesFlutterPackagesSectionTitle => 'Paquets de Flutter';

  @override
  String get aboutLicensesDartPackagesSectionTitle => 'Paquets de Dart';

  @override
  String get aboutLicensesShowAllButtonLabel => 'Mostra Totes les Llicències';

  @override
  String get policyPageTitle => 'Política de Privacitat';

  @override
  String get collectionPageTitle => 'Coŀlecció';

  @override
  String get collectionPickPageTitle => 'Escollir';

  @override
  String get collectionSelectPageTitle => 'Escollir elements';

  @override
  String get collectionActionShowTitleSearch => 'Mostra filtres de títol';

  @override
  String get collectionActionHideTitleSearch => 'Amaga filtres de títol';

  @override
  String get collectionActionAddDynamicAlbum => 'Afegir un àlbum dinàmic';

  @override
  String get collectionActionAddShortcut => 'Afegeix drecera';

  @override
  String get collectionActionSetHome => 'Defineix com inici';

  @override
  String get collectionActionEmptyBin => 'Buidar paperera';

  @override
  String get collectionActionCopy => 'Copiar a àlbum';

  @override
  String get collectionActionMove => 'Moure a àlbum';

  @override
  String get collectionActionRescan => 'Tornar a buscar';

  @override
  String get collectionActionEdit => 'Editar';

  @override
  String get collectionSearchTitlesHintText => 'Buscar títols';

  @override
  String get collectionGroupAlbum => 'Per àlbum';

  @override
  String get collectionGroupMonth => 'Per mes';

  @override
  String get collectionGroupDay => 'Per dia';

  @override
  String get collectionGroupNone => 'No per grup';

  @override
  String get sectionUnknown => 'Desconegut';

  @override
  String get dateToday => 'Avui';

  @override
  String get dateYesterday => 'Ahir';

  @override
  String get dateThisMonth => 'Aquest mes';

  @override
  String collectionDeleteFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Error en esborrar $count elements',
      one: 'Error en esborrar 1 element',
    );
    return '$_temp0';
  }

  @override
  String collectionCopyFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Error en copiar $count elements',
      one: 'Error en copiar 1 element',
    );
    return '$_temp0';
  }

  @override
  String collectionMoveFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Error en moure $count elements',
      one: 'Error en moure 1 element',
    );
    return '$_temp0';
  }

  @override
  String collectionRenameFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Error en canviar el nom a $count elements',
      one: 'Error en canviar el nom a 1 element',
    );
    return '$_temp0';
  }

  @override
  String collectionEditFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Error en editar $count elements',
      one: 'Error en editar 1 element',
    );
    return '$_temp0';
  }

  @override
  String collectionExportFailureFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Error en exportar $count pàgines',
      one: 'Error en exportar una pàgina',
    );
    return '$_temp0';
  }

  @override
  String collectionCopySuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elements copiats',
      one: 'Un element copiat',
    );
    return '$_temp0';
  }

  @override
  String collectionMoveSuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elements moguts',
      one: 'Un element mogut',
    );
    return '$_temp0';
  }

  @override
  String collectionRenameSuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nom canviat a $count elements',
      one: 'Nom canviat a 1 element',
    );
    return '$_temp0';
  }

  @override
  String collectionEditSuccessFeedback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elements editats',
      one: 'Un element editat',
    );
    return '$_temp0';
  }

  @override
  String get collectionEmptyFavourites => 'Sense preferits';

  @override
  String get collectionEmptyVideos => 'Sense vídeos';

  @override
  String get collectionEmptyImages => 'Sense imatges';

  @override
  String get collectionEmptyGrantAccessButtonLabel => 'Donar accés';

  @override
  String get collectionSelectSectionTooltip => 'Seleccionar secció';

  @override
  String get collectionDeselectSectionTooltip => 'Desseleccionar secció';

  @override
  String get drawerAboutButton => 'Sobre';

  @override
  String get drawerSettingsButton => 'Configuració';

  @override
  String get drawerCollectionAll => 'Tota la coŀlecció';

  @override
  String get drawerCollectionFavourites => 'Preferits';

  @override
  String get drawerCollectionImages => 'Imatges';

  @override
  String get drawerCollectionVideos => 'Vídeos';

  @override
  String get drawerCollectionAnimated => 'Animacions';

  @override
  String get drawerCollectionMotionPhotos => 'Fotos en moviment';

  @override
  String get drawerCollectionPanoramas => 'Panoràmiques';

  @override
  String get drawerCollectionRaws => 'Fotos Raw';

  @override
  String get drawerCollectionSphericalVideos => 'Vídeos 360º';

  @override
  String get drawerAlbumPage => 'Àlbums';

  @override
  String get drawerCountryPage => 'Països';

  @override
  String get drawerPlacePage => 'Llocs';

  @override
  String get drawerTagPage => 'Etiquetes';

  @override
  String get sortByDate => 'Per data';

  @override
  String get sortByName => 'Per nom';

  @override
  String get sortByItemCount => 'Per nombre d’elements';

  @override
  String get sortBySize => 'Per mida';

  @override
  String get sortByAlbumFileName => 'Per àlbum i nom d’arxiu';

  @override
  String get sortByRating => 'Per valoració';

  @override
  String get sortByDuration => 'Per durada';

  @override
  String get sortByPath => 'Per ruta';

  @override
  String get sortOrderNewestFirst => 'Primer el més nou';

  @override
  String get sortOrderOldestFirst => 'Primer el més antic';

  @override
  String get sortOrderAtoZ => 'De A a Z';

  @override
  String get sortOrderZtoA => 'De Z a A';

  @override
  String get sortOrderHighestFirst => 'Primer el més alt';

  @override
  String get sortOrderLowestFirst => 'Primer el més baix';

  @override
  String get sortOrderLargestFirst => 'Primer el més gran';

  @override
  String get sortOrderSmallestFirst => 'Primer el més petit';

  @override
  String get sortOrderShortestFirst => 'El més curt primer';

  @override
  String get sortOrderLongestFirst => 'El més llarg primer';

  @override
  String get albumGroupTier => 'Per nivell';

  @override
  String get albumGroupType => 'Per tipus';

  @override
  String get albumGroupVolume => 'Per volum d’emmagatzematge';

  @override
  String get albumGroupNone => 'No agrupar';

  @override
  String get albumMimeTypeMixed => 'Barrejat';

  @override
  String get albumPickPageTitleCopy => 'Copiar a Àlbum';

  @override
  String get albumPickPageTitleExport => 'Exportar a Àlbum';

  @override
  String get albumPickPageTitleMove => 'Moure a Àlbum';

  @override
  String get albumPickPageTitlePick => 'Escollir Àlbum';

  @override
  String get albumCamera => 'Càmera';

  @override
  String get albumDownload => 'Baixades';

  @override
  String get albumScreenshots => 'Captures de pantalla';

  @override
  String get albumScreenRecordings => 'Gravacions de pantalla';

  @override
  String get albumVideoCaptures => 'Captures de Vídeo';

  @override
  String get albumPageTitle => 'Àlbums';

  @override
  String get albumEmpty => 'Sense àlbums';

  @override
  String get createAlbumButtonLabel => 'CREAR';

  @override
  String get newFilterBanner => 'nou';

  @override
  String get countryPageTitle => 'Països';

  @override
  String get countryEmpty => 'Sense països';

  @override
  String get statePageTitle => 'Estats';

  @override
  String get stateEmpty => 'Sense estats';

  @override
  String get placePageTitle => 'Llocs';

  @override
  String get placeEmpty => 'Sense llocs';

  @override
  String get tagPageTitle => 'Etiquetes';

  @override
  String get tagEmpty => 'Sense etiquetes';

  @override
  String get binPageTitle => 'Paperera de Reciclatge';

  @override
  String get explorerPageTitle => 'Explorador';

  @override
  String get explorerActionSelectStorageVolume => 'Seleccionar emmagatzematge';

  @override
  String get selectStorageVolumeDialogTitle => 'Seleccionar Emmagatzematge';

  @override
  String get searchCollectionFieldHint => 'Buscar a coŀlecció';

  @override
  String get searchRecentSectionTitle => 'Recent';

  @override
  String get searchDateSectionTitle => 'Data';

  @override
  String get searchFormatSectionTitle => 'Formats';

  @override
  String get searchAlbumsSectionTitle => 'Àlbums';

  @override
  String get searchCountriesSectionTitle => 'Països';

  @override
  String get searchStatesSectionTitle => 'Estats';

  @override
  String get searchPlacesSectionTitle => 'Llocs';

  @override
  String get searchTagsSectionTitle => 'Etiquetes';

  @override
  String get searchRatingSectionTitle => 'Valoracions';

  @override
  String get searchMetadataSectionTitle => 'Metadades';

  @override
  String get settingsPageTitle => 'Configuració';

  @override
  String get settingsSystemDefault => 'Per defecte al sistema';

  @override
  String get settingsDefault => 'Per defecte';

  @override
  String get settingsDisabled => 'Desactivat';

  @override
  String get settingsAskEverytime => 'Preguntar cada vegada';

  @override
  String get settingsModificationWarningDialogMessage => 'Altres configuracions es modificaran.';

  @override
  String get settingsSearchFieldLabel => 'Busca configuracions';

  @override
  String get settingsSearchEmpty => 'Cap coincidència';

  @override
  String get settingsActionExport => 'Exportar';

  @override
  String get settingsActionExportDialogTitle => 'Exportar';

  @override
  String get settingsActionImport => 'Importar';

  @override
  String get settingsActionImportDialogTitle => 'Importar';

  @override
  String get appExportCovers => 'Cobertes';

  @override
  String get appExportDynamicAlbums => 'Àlbums dinàmics';

  @override
  String get appExportFavourites => 'Preferits';

  @override
  String get appExportSettings => 'Configuracions';

  @override
  String get settingsNavigationSectionTitle => 'Navegació';

  @override
  String get settingsHomeTile => 'Inici';

  @override
  String get settingsHomeDialogTitle => 'Inici';

  @override
  String get setHomeCustom => 'Personalitzat';

  @override
  String get settingsShowBottomNavigationBar => 'Mostra barra de navegació inferior';

  @override
  String get settingsKeepScreenOnTile => 'Mantenir pantalla encesa';

  @override
  String get settingsKeepScreenOnDialogTitle => 'Mantenir la Pantalla Encesa';

  @override
  String get settingsDoubleBackExit => 'Toqueu «enrere» dues vegades per sortir';

  @override
  String get settingsConfirmationTile => 'Diàlegs de confirmació';

  @override
  String get settingsConfirmationDialogTitle => 'Diàlegs de Confirmació';

  @override
  String get settingsConfirmationBeforeDeleteItems => 'Pregunta abans d’esborrar elements per sempre';

  @override
  String get settingsConfirmationBeforeMoveToBinItems => 'Pregunta abans de moure elements a la paperera de reciclatge';

  @override
  String get settingsConfirmationBeforeMoveUndatedItems => 'Pregunta abans de moure elements sense data';

  @override
  String get settingsConfirmationAfterMoveToBinItems => 'Mostra missatge després de moure elements a la paperera de reciclatge';

  @override
  String get settingsConfirmationVaultDataLoss => 'Mostra l’avís de pèrdua de dades d’una caixa forta';

  @override
  String get settingsNavigationDrawerTile => 'Menú de navegació';

  @override
  String get settingsNavigationDrawerEditorPageTitle => 'Menú de Navegació';

  @override
  String get settingsNavigationDrawerBanner => 'Mantén premut per moure i reordenar els elements del menú.';

  @override
  String get settingsNavigationDrawerTabTypes => 'Tipus';

  @override
  String get settingsNavigationDrawerTabAlbums => 'Àlbums';

  @override
  String get settingsNavigationDrawerTabPages => 'Pàgines';

  @override
  String get settingsNavigationDrawerAddAlbum => 'Afegeix àlbum';

  @override
  String get settingsThumbnailSectionTitle => 'Miniatures';

  @override
  String get settingsThumbnailOverlayTile => 'Incrustacions';

  @override
  String get settingsThumbnailOverlayPageTitle => 'Incrustacions';

  @override
  String get settingsThumbnailShowHdrIcon => 'Mostra icona de HDR';

  @override
  String get settingsThumbnailShowFavouriteIcon => 'Mostra icona de preferits';

  @override
  String get settingsThumbnailShowTagIcon => 'Mostra icona d’etiqueta';

  @override
  String get settingsThumbnailShowLocationIcon => 'Mostra icona de localització';

  @override
  String get settingsThumbnailShowMotionPhotoIcon => 'Mostra icona de foto en moviment';

  @override
  String get settingsThumbnailShowRating => 'Mostra valoració';

  @override
  String get settingsThumbnailShowRawIcon => 'Mostra icona raw';

  @override
  String get settingsThumbnailShowVideoDuration => 'Mostra duració de vídeo';

  @override
  String get settingsCollectionQuickActionsTile => 'Accions ràpides';

  @override
  String get settingsCollectionQuickActionEditorPageTitle => 'Accions Ràpides';

  @override
  String get settingsCollectionQuickActionTabBrowsing => 'Navegació';

  @override
  String get settingsCollectionQuickActionTabSelecting => 'Selecció';

  @override
  String get settingsCollectionBrowsingQuickActionEditorBanner => 'Manté premut per moure botons i seleccionar quines accions es mostren en els articles de navegació.';

  @override
  String get settingsCollectionSelectionQuickActionEditorBanner => 'Manté premut per moure botons i seleccionar quines accions es mostren en seleccionar elements.';

  @override
  String get settingsCollectionBurstPatternsTile => 'Patrons de ràfega';

  @override
  String get settingsCollectionBurstPatternsNone => 'Cap';

  @override
  String get settingsViewerSectionTitle => 'Visualitzador';

  @override
  String get settingsViewerGestureSideTapNext => 'Toqueu les vores de la pantalla per mostrar l’anterior/el següent element';

  @override
  String get settingsViewerUseCutout => 'Utilitzeu l’àrea de tall';

  @override
  String get settingsViewerMaximumBrightness => 'Brillantor màxima';

  @override
  String get settingsMotionPhotoAutoPlay => 'Reprodueix automàticament fotos en moviment';

  @override
  String get settingsImageBackground => 'Fons d’imatge';

  @override
  String get settingsViewerQuickActionsTile => 'Accions ràpides';

  @override
  String get settingsViewerQuickActionEditorPageTitle => 'Accions Ràpides';

  @override
  String get settingsViewerQuickActionEditorBanner => 'Manté premut per moure botons i seleccionar quines accions es mostren al visualitzador.';

  @override
  String get settingsViewerQuickActionEditorDisplayedButtonsSectionTitle => 'Botons Mostrats';

  @override
  String get settingsViewerQuickActionEditorAvailableButtonsSectionTitle => 'Botons Disponibles';

  @override
  String get settingsViewerQuickActionEmpty => 'Sense botons';

  @override
  String get settingsViewerOverlayTile => 'Incrustacions';

  @override
  String get settingsViewerOverlayPageTitle => 'Incrustacions';

  @override
  String get settingsViewerShowOverlayOnOpening => 'Mostra a l’obrir';

  @override
  String get settingsViewerShowHistogram => 'Mostra histograma';

  @override
  String get settingsViewerShowMinimap => 'Mostra mapa en miniatura';

  @override
  String get settingsViewerShowInformation => 'Mostra informació';

  @override
  String get settingsViewerShowInformationSubtitle => 'Mostra títol, data, localització, etc.';

  @override
  String get settingsViewerShowRatingTags => 'Mostra valoració i etiquetes';

  @override
  String get settingsViewerShowShootingDetails => 'Mostra detalls de la foto';

  @override
  String get settingsViewerShowDescription => 'Mostra descripció';

  @override
  String get settingsViewerShowOverlayThumbnails => 'Mostra miniatures';

  @override
  String get settingsViewerEnableOverlayBlurEffect => 'Efecte borrós';

  @override
  String get settingsViewerSlideshowTile => 'Presentació de diapositives';

  @override
  String get settingsViewerSlideshowPageTitle => 'Presentació de diapositives';

  @override
  String get settingsSlideshowRepeat => 'Repeteix';

  @override
  String get settingsSlideshowShuffle => 'Barreja';

  @override
  String get settingsSlideshowFillScreen => 'Emplenar pantalla';

  @override
  String get settingsSlideshowAnimatedZoomEffect => 'Efecte de zoom animat';

  @override
  String get settingsSlideshowTransitionTile => 'Transició';

  @override
  String get settingsSlideshowIntervalTile => 'Interval';

  @override
  String get settingsSlideshowVideoPlaybackTile => 'Reproducció de vídeo';

  @override
  String get settingsSlideshowVideoPlaybackDialogTitle => 'Reproducció de Vídeo';

  @override
  String get settingsVideoPageTitle => 'Configuració de Vídeo';

  @override
  String get settingsVideoSectionTitle => 'Vídeo';

  @override
  String get settingsVideoShowVideos => 'Mostra vídeos';

  @override
  String get settingsVideoPlaybackTile => 'Reproducció';

  @override
  String get settingsVideoPlaybackPageTitle => 'Reproducció';

  @override
  String get settingsVideoEnableHardwareAcceleration => 'Acceleració per maquinari';

  @override
  String get settingsVideoAutoPlay => 'Reproducció automàtica';

  @override
  String get settingsVideoLoopModeTile => 'Mode en bucle';

  @override
  String get settingsVideoLoopModeDialogTitle => 'Mode en Bucle';

  @override
  String get settingsVideoResumptionModeTile => 'Reprèn reproducció';

  @override
  String get settingsVideoResumptionModeDialogTitle => 'Reprèn Reproducció';

  @override
  String get settingsVideoBackgroundMode => 'Mode de fons';

  @override
  String get settingsVideoBackgroundModeDialogTitle => 'Mode de Fons';

  @override
  String get settingsVideoControlsTile => 'Controls';

  @override
  String get settingsVideoControlsPageTitle => 'Controls';

  @override
  String get settingsVideoButtonsTile => 'Botons';

  @override
  String get settingsVideoGestureDoubleTapTogglePlay => 'Fes doble toc per reproduir/aturar';

  @override
  String get settingsVideoGestureSideDoubleTapSeek => 'Fes doble toc a la vora de la pantalla per retrocedir/avançar';

  @override
  String get settingsVideoGestureVerticalDragBrightnessVolume => 'Llisca cap amunt o cap avall per ajustar la brillantor/volum';

  @override
  String get settingsSubtitleThemeTile => 'Subtítols';

  @override
  String get settingsSubtitleThemePageTitle => 'Subtítols';

  @override
  String get settingsSubtitleThemeSample => 'Això és un exemple.';

  @override
  String get settingsSubtitleThemeTextAlignmentTile => 'Ajustament de text';

  @override
  String get settingsSubtitleThemeTextAlignmentDialogTitle => 'Ajustament de Text';

  @override
  String get settingsSubtitleThemeTextPositionTile => 'Posició de text';

  @override
  String get settingsSubtitleThemeTextPositionDialogTitle => 'Posició de Text';

  @override
  String get settingsSubtitleThemeTextSize => 'Mida del text';

  @override
  String get settingsSubtitleThemeShowOutline => 'Mostra el contorn i l’ombra';

  @override
  String get settingsSubtitleThemeTextColor => 'Color del text';

  @override
  String get settingsSubtitleThemeTextOpacity => 'Opacitat del text';

  @override
  String get settingsSubtitleThemeBackgroundColor => 'Color de fons';

  @override
  String get settingsSubtitleThemeBackgroundOpacity => 'Opacitat del fons';

  @override
  String get settingsSubtitleThemeTextAlignmentLeft => 'Esquerra';

  @override
  String get settingsSubtitleThemeTextAlignmentCenter => 'Centre';

  @override
  String get settingsSubtitleThemeTextAlignmentRight => 'Dreta';

  @override
  String get settingsPrivacySectionTitle => 'Privacitat';

  @override
  String get settingsAllowInstalledAppAccess => 'Permet accés a la llista d’aplicacions';

  @override
  String get settingsAllowInstalledAppAccessSubtitle => 'Utilitzat per millorar la visualització dels àlbums';

  @override
  String get settingsAllowErrorReporting => 'Permet enviar errors anònims';

  @override
  String get settingsSaveSearchHistory => 'Guarda historial de cerca';

  @override
  String get settingsEnableBin => 'Utilitzar paperera de reciclatge';

  @override
  String get settingsEnableBinSubtitle => 'Manté elements eliminats durant 30 dies';

  @override
  String get settingsDisablingBinWarningDialogMessage => 'Els elements de la paperera de reciclatge seran eliminats per sempre.';

  @override
  String get settingsAllowMediaManagement => 'Permet la gestió dels mitjans';

  @override
  String get settingsHiddenItemsTile => 'Elements amagats';

  @override
  String get settingsHiddenItemsPageTitle => 'Elements Amagats';

  @override
  String get settingsHiddenFiltersBanner => 'Les fotos i els vídeos que coincideixin amb filtres amagats no apareixeran a la teva coŀlecció.';

  @override
  String get settingsHiddenFiltersEmpty => 'Cap filtre amagat';

  @override
  String get settingsStorageAccessTile => 'Accés d’emmagatzematge';

  @override
  String get settingsStorageAccessPageTitle => 'Accés d’Emmagatzematge';

  @override
  String get settingsStorageAccessBanner => 'Alguns directoris requereixen permís explícit per modificar-hi fitxers. Podeu revisar aquí els directoris als quals heu donat accés anteriorment.';

  @override
  String get settingsStorageAccessEmpty => 'Cap permís d’accés';

  @override
  String get settingsStorageAccessRevokeTooltip => 'Revocar';

  @override
  String get settingsAccessibilitySectionTitle => 'Accessibilitat';

  @override
  String get settingsRemoveAnimationsTile => 'Treure animacions';

  @override
  String get settingsRemoveAnimationsDialogTitle => 'Treure Animacions';

  @override
  String get settingsTimeToTakeActionTile => 'Retard per executar una acció';

  @override
  String get settingsAccessibilityShowPinchGestureAlternatives => 'Mostra alternatives amb gestos multitàctils';

  @override
  String get settingsDisplaySectionTitle => 'Pantalla';

  @override
  String get settingsThemeBrightnessTile => 'Tema';

  @override
  String get settingsThemeBrightnessDialogTitle => 'Tema';

  @override
  String get settingsThemeColorHighlights => 'Colors per ressaltar';

  @override
  String get settingsThemeEnableDynamicColor => 'Color dinàmic';

  @override
  String get settingsDisplayRefreshRateModeTile => 'Taxa de refresc de pantalla';

  @override
  String get settingsDisplayRefreshRateModeDialogTitle => 'Taxa de refresc';

  @override
  String get settingsDisplayUseTvInterface => 'Interfície d’Android TV';

  @override
  String get settingsLanguageSectionTitle => 'Llengua i Formats';

  @override
  String get settingsLanguageTile => 'Idioma';

  @override
  String get settingsLanguagePageTitle => 'Idioma';

  @override
  String get settingsCoordinateFormatTile => 'Format de coordenades';

  @override
  String get settingsCoordinateFormatDialogTitle => 'Format de Coordenades';

  @override
  String get settingsUnitSystemTile => 'Unitats';

  @override
  String get settingsUnitSystemDialogTitle => 'Unitats';

  @override
  String get settingsForceWesternArabicNumeralsTile => 'Forçar els números aràbics';

  @override
  String get settingsScreenSaverPageTitle => 'Protector de Pantalla';

  @override
  String get settingsWidgetPageTitle => 'Marc de Foto';

  @override
  String get settingsWidgetShowOutline => 'Contorn';

  @override
  String get settingsWidgetOpenPage => 'En tocar un giny';

  @override
  String get settingsWidgetDisplayedItem => 'Element mostrat';

  @override
  String get settingsCollectionTile => 'Coŀlecció';

  @override
  String get statsPageTitle => 'Estadístiques';

  @override
  String statsWithGps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elements amb localització',
      one: '1 element amb localització',
    );
    return '$_temp0';
  }

  @override
  String get statsTopCountriesSectionTitle => 'Països Principals';

  @override
  String get statsTopStatesSectionTitle => 'Estats Principals';

  @override
  String get statsTopPlacesSectionTitle => 'Llocs Principals';

  @override
  String get statsTopTagsSectionTitle => 'Etiquetes Principals';

  @override
  String get statsTopAlbumsSectionTitle => 'Àlbums Principals';

  @override
  String get viewerOpenPanoramaButtonLabel => 'OBRIR PANORÀMICA';

  @override
  String get viewerSetWallpaperButtonLabel => 'DEFINEIX FONS DE PANTALLA';

  @override
  String get viewerErrorUnknown => 'Vaja!';

  @override
  String get viewerErrorDoesNotExist => 'El fitxer ja no existeix.';

  @override
  String get viewerInfoPageTitle => 'Informació';

  @override
  String get viewerInfoBackToViewerTooltip => 'Torna al visualitzador';

  @override
  String get viewerInfoUnknown => 'desconegut';

  @override
  String get viewerInfoLabelDescription => 'Descripció';

  @override
  String get viewerInfoLabelTitle => 'Títol';

  @override
  String get viewerInfoLabelDate => 'Data';

  @override
  String get viewerInfoLabelResolution => 'Resolució';

  @override
  String get viewerInfoLabelSize => 'Mida';

  @override
  String get viewerInfoLabelUri => 'URI';

  @override
  String get viewerInfoLabelPath => 'Ruta';

  @override
  String get viewerInfoLabelDuration => 'Duració';

  @override
  String get viewerInfoLabelOwner => 'Propietari';

  @override
  String get viewerInfoLabelCoordinates => 'Coordenades';

  @override
  String get viewerInfoLabelAddress => 'Adreça';

  @override
  String get mapStyleDialogTitle => 'Estil de mapa';

  @override
  String get mapStyleTooltip => 'Selecciona tipus de mapa';

  @override
  String get mapZoomInTooltip => 'Ampliar';

  @override
  String get mapZoomOutTooltip => 'Allunyar';

  @override
  String get mapPointNorthUpTooltip => 'Apuntar el nord cap amunt';

  @override
  String get mapAttributionOsmData => 'Dades de mapa © [OpenStreetMap](https://www.openstreetmap.org/copyright) contribuïdors';

  @override
  String get mapAttributionOsmLiberty => 'Tessel·les per [OpenMapTiles](https://www.openmaptiles.org/), [CC BY](http://creativecommons.org/licenses/by/4.0) • Hostatjat per [OSM Americana](https://tile.ourmap.us)';

  @override
  String get mapAttributionOpenTopoMap => '[SRTM](https://www.earthdata.nasa.gov/sensors/srtm) | Tesel·les per [OpenTopoMap](https://opentopomap.org/), [CC BY-SA](https://creativecommons.org/licenses/by-sa/3.0/)';

  @override
  String get mapAttributionOsmHot => 'Rajoles de [HOT](https://www.hotosm.org/) • Allotjat a [OSM France](https://openstreetmap.fr/)';

  @override
  String get mapAttributionStamen => 'Rajoles per [Stamen Design](https://stamen.com), [CC BY 3.0](https://creativecommons.org/licenses/by/3.0)';

  @override
  String get openMapPageTooltip => 'Veure a la pàgina de mapa';

  @override
  String get mapEmptyRegion => 'Sense imatges a aquesta regió';

  @override
  String get viewerInfoOpenEmbeddedFailureFeedback => 'Error en extreure les dades incrustades';

  @override
  String get viewerInfoOpenLinkText => 'Obrir';

  @override
  String get viewerInfoViewXmlLinkText => 'Veure XML';

  @override
  String get viewerInfoSearchFieldLabel => 'Buscar metadades';

  @override
  String get viewerInfoSearchEmpty => 'Sense claus coincidents';

  @override
  String get viewerInfoSearchSuggestionDate => 'Data i hora';

  @override
  String get viewerInfoSearchSuggestionDescription => 'Descripció';

  @override
  String get viewerInfoSearchSuggestionDimensions => 'Dimensions';

  @override
  String get viewerInfoSearchSuggestionResolution => 'Resolució';

  @override
  String get viewerInfoSearchSuggestionRights => 'Drets';

  @override
  String get wallpaperUseScrollEffect => 'Utilitza l’efecte de desplaçament a la pantalla d’inici';

  @override
  String get tagEditorPageTitle => 'Editar Etiquetes';

  @override
  String get tagEditorPageNewTagFieldLabel => 'Nova etiqueta';

  @override
  String get tagEditorPageAddTagTooltip => 'Afegir etiqueta';

  @override
  String get tagEditorSectionRecent => 'Recent';

  @override
  String get tagEditorSectionPlaceholders => 'Marcadors de posició';

  @override
  String get tagEditorDiscardDialogMessage => 'Vols descartar els canvis?';

  @override
  String get tagPlaceholderCountry => 'País';

  @override
  String get tagPlaceholderState => 'Estat';

  @override
  String get tagPlaceholderPlace => 'Lloc';

  @override
  String get panoramaEnableSensorControl => 'Activa el control del sensor';

  @override
  String get panoramaDisableSensorControl => 'Desactiva el control del sensor';

  @override
  String get sourceViewerPageTitle => 'Font';

  @override
  String get filePickerShowHiddenFiles => 'Mostra arxius amagats';

  @override
  String get filePickerDoNotShowHiddenFiles => 'No mostris arxius amagats';

  @override
  String get filePickerOpenFrom => 'Obrir des de';

  @override
  String get filePickerNoItems => 'Sense element';

  @override
  String get filePickerUseThisFolder => 'Utilitza aquesta carpeta';
}
