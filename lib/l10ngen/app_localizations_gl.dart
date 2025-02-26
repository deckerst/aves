// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Galician (`gl`).
class AppLocalizationsGl extends AppLocalizations {
  AppLocalizationsGl([String locale = 'gl']) : super(locale);

  @override
  String get appName => 'Aves';

  @override
  String get welcomeMessage => 'Benvido a Aves';

  @override
  String get welcomeOptional => 'Opcional';

  @override
  String get welcomeTermsToggle => 'Acepto os termos e condicións';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementos',
      one: '$count elemento',
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
      other: '$countString columnas',
      one: '$countString columna',
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
      other: '$countString segundos',
      one: '$countString segundo',
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
      other: '$countString minutos',
      one: '$countString minuto',
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
      other: '$countString días',
      one: '$countString día',
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
  String get deleteButtonLabel => 'ELIMINAR';

  @override
  String get nextButtonLabel => 'SEGUINTE';

  @override
  String get showButtonLabel => 'AMOSAR';

  @override
  String get hideButtonLabel => 'AGOCHAR';

  @override
  String get continueButtonLabel => 'PROSEGUIR';

  @override
  String get saveCopyButtonLabel => 'GARDAR COPIA';

  @override
  String get applyTooltip => 'Aplicar';

  @override
  String get cancelTooltip => 'Cancelar';

  @override
  String get changeTooltip => 'Trocar';

  @override
  String get clearTooltip => 'Limpar';

  @override
  String get previousTooltip => 'Anterior';

  @override
  String get nextTooltip => 'Seguinte';

  @override
  String get showTooltip => 'Amosar';

  @override
  String get hideTooltip => 'Agochar';

  @override
  String get actionRemove => 'Retirar';

  @override
  String get resetTooltip => 'Restituír';

  @override
  String get saveTooltip => 'Gardar';

  @override
  String get stopTooltip => 'Deter';

  @override
  String get pickTooltip => 'Escoller';

  @override
  String get doubleBackExitMessage => 'Prema «atrás» de novo para saír.';

  @override
  String get doNotAskAgain => 'Non preguntar de novo';

  @override
  String get sourceStateLoading => 'Cargando';

  @override
  String get sourceStateCataloguing => 'Catalogando';

  @override
  String get sourceStateLocatingCountries => 'Localizando países';

  @override
  String get sourceStateLocatingPlaces => 'Localizando lugares';

  @override
  String get chipActionDelete => 'Eliminar';

  @override
  String get chipActionRemove => 'Retirar';

  @override
  String get chipActionShowCollection => 'Amosar na colección';

  @override
  String get chipActionGoToAlbumPage => 'Amosar en álbums';

  @override
  String get chipActionGoToCountryPage => 'Amosar en países';

  @override
  String get chipActionGoToPlacePage => 'Amosar en lugares';

  @override
  String get chipActionGoToTagPage => 'Amosar en etiquetas';

  @override
  String get chipActionGoToExplorerPage => 'Amosar no explorador';

  @override
  String get chipActionDecompose => 'Separar';

  @override
  String get chipActionFilterOut => 'Filtrar';

  @override
  String get chipActionFilterIn => 'Filtrar';

  @override
  String get chipActionHide => 'Agochar';

  @override
  String get chipActionLock => 'Bloquear';

  @override
  String get chipActionPin => 'Fixar na parte superior';

  @override
  String get chipActionUnpin => 'Desbloquear dende arriba';

  @override
  String get chipActionRename => 'Cambiar o nome';

  @override
  String get chipActionSetCover => 'Definir cuberta';

  @override
  String get chipActionShowCountryStates => 'Amosar estados';

  @override
  String get chipActionCreateAlbum => 'Crear álbum';

  @override
  String get chipActionCreateVault => 'Crear cofre';

  @override
  String get chipActionConfigureVault => 'Configurar cofre';

  @override
  String get entryActionCopyToClipboard => 'Copiar ao portapapeis';

  @override
  String get entryActionDelete => 'Eliminar';

  @override
  String get entryActionConvert => 'Converter';

  @override
  String get entryActionExport => 'Exportar';

  @override
  String get entryActionInfo => 'Información';

  @override
  String get entryActionRename => 'Cambiar o nome';

  @override
  String get entryActionRestore => 'Restaurar';

  @override
  String get entryActionRotateCCW => 'Xirar no sentido antihorario';

  @override
  String get entryActionRotateCW => 'Xirar no sentido horario';

  @override
  String get entryActionFlip => 'Voltear horizontalmente';

  @override
  String get entryActionPrint => 'Imprimir';

  @override
  String get entryActionShare => 'Compartir';

  @override
  String get entryActionShareImageOnly => 'Só compartir imaxe';

  @override
  String get entryActionShareVideoOnly => 'Só compartir vídeo';

  @override
  String get entryActionViewSource => 'Ver fonte';

  @override
  String get entryActionShowGeoTiffOnMap => 'Amosar como superposición de mapa';

  @override
  String get entryActionConvertMotionPhotoToStillImage => 'Converter a imaxe fixa';

  @override
  String get entryActionViewMotionPhotoVideo => 'Abrir vídeo';

  @override
  String get entryActionEdit => 'Editar';

  @override
  String get entryActionOpen => 'Abrir con';

  @override
  String get entryActionSetAs => 'Definir como';

  @override
  String get entryActionCast => 'Transmitir';

  @override
  String get entryActionOpenMap => 'Amosar na aplicación de mapas';

  @override
  String get entryActionRotateScreen => 'Rotar pantalla';

  @override
  String get entryActionAddFavourite => 'Engadir a favoritos';

  @override
  String get entryActionRemoveFavourite => 'Eliminar dos favoritos';

  @override
  String get videoActionCaptureFrame => 'Cadro de captura';

  @override
  String get videoActionMute => 'Silenciar';

  @override
  String get videoActionUnmute => 'Activar son';

  @override
  String get videoActionPause => 'Pausa';

  @override
  String get videoActionPlay => 'Reproducir';

  @override
  String get videoActionReplay10 => 'Cear 10 segundos';

  @override
  String get videoActionSkip10 => 'Avanzar 10 segundos';

  @override
  String get videoActionShowPreviousFrame => 'Amosar fotograma anterior';

  @override
  String get videoActionShowNextFrame => 'Amosar fotograma seguinte';

  @override
  String get videoActionSelectStreams => 'Seleccionar pistas';

  @override
  String get videoActionSetSpeed => 'Velocidade de reprodución';

  @override
  String get videoActionABRepeat => 'Repetir A-B';

  @override
  String get videoRepeatActionSetStart => 'Definir inicio';

  @override
  String get videoRepeatActionSetEnd => 'Definir final';

  @override
  String get viewerActionSettings => 'Configuración';

  @override
  String get viewerActionLock => 'Bloquear visor';

  @override
  String get viewerActionUnlock => 'Desbloquear visor';

  @override
  String get slideshowActionResume => 'Retomar';

  @override
  String get slideshowActionShowInCollection => 'Amosar na colección';

  @override
  String get entryInfoActionEditDate => 'Editar data e hora';

  @override
  String get entryInfoActionEditLocation => 'Editar localización';

  @override
  String get entryInfoActionEditTitleDescription => 'Editar título e descrición';

  @override
  String get entryInfoActionEditRating => 'Editar valoración';

  @override
  String get entryInfoActionEditTags => 'Editar etiquetas';

  @override
  String get entryInfoActionRemoveMetadata => 'Eliminar metadatos';

  @override
  String get entryInfoActionExportMetadata => 'Exportar metadatos';

  @override
  String get entryInfoActionRemoveLocation => 'Retirar localización';

  @override
  String get editorActionTransform => 'Transformar';

  @override
  String get editorTransformCrop => 'Recortar';

  @override
  String get editorTransformRotate => 'Xirar';

  @override
  String get cropAspectRatioFree => 'Libre';

  @override
  String get cropAspectRatioOriginal => 'Orixinal';

  @override
  String get cropAspectRatioSquare => 'Cadrado';

  @override
  String get filterAspectRatioLandscapeLabel => 'Paisaxe';

  @override
  String get filterAspectRatioPortraitLabel => 'Retrato';

  @override
  String get filterBinLabel => 'Lixo';

  @override
  String get filterFavouriteLabel => 'Favorito';

  @override
  String get filterNoDateLabel => 'Sen data';

  @override
  String get filterNoAddressLabel => 'Sen enderezo';

  @override
  String get filterLocatedLabel => 'Localizado';

  @override
  String get filterNoLocationLabel => 'Sen localizar';

  @override
  String get filterNoRatingLabel => 'Sen clasificar';

  @override
  String get filterTaggedLabel => 'Etiquetado';

  @override
  String get filterNoTagLabel => 'Sen etiquetar';

  @override
  String get filterNoTitleLabel => 'Sen título';

  @override
  String get filterOnThisDayLabel => 'Neste día';

  @override
  String get filterRecentlyAddedLabel => 'Engadido recentemente';

  @override
  String get filterRatingRejectedLabel => 'Rexeitado';

  @override
  String get filterTypeAnimatedLabel => 'Animado';

  @override
  String get filterTypeMotionPhotoLabel => 'Foto en movemento';

  @override
  String get filterTypePanoramaLabel => 'Panorama';

  @override
  String get filterTypeRawLabel => 'Raw';

  @override
  String get filterTypeSphericalVideoLabel => 'Vídeo 360°';

  @override
  String get filterTypeGeotiffLabel => 'GeoTIFF';

  @override
  String get filterMimeImageLabel => 'Imaxe';

  @override
  String get filterMimeVideoLabel => 'Vídeo';

  @override
  String get accessibilityAnimationsRemove => 'Evitar efectos de pantalla';

  @override
  String get accessibilityAnimationsKeep => 'Manter efectos de pantalla';

  @override
  String get albumTierNew => 'Novo';

  @override
  String get albumTierPinned => 'Fixado';

  @override
  String get albumTierSpecial => 'Común';

  @override
  String get albumTierApps => 'Aplicacións';

  @override
  String get albumTierVaults => 'Cofres';

  @override
  String get albumTierDynamic => 'Dinámico';

  @override
  String get albumTierRegular => 'Outros';

  @override
  String get coordinateFormatDms => 'DMS';

  @override
  String get coordinateFormatDdm => 'DDM';

  @override
  String get coordinateFormatDecimal => 'Graos decimais';

  @override
  String coordinateDms(String coordinate, String direction) {
    return '$coordinate $direction';
  }

  @override
  String get coordinateDmsNorth => 'N';

  @override
  String get coordinateDmsSouth => 'S';

  @override
  String get coordinateDmsEast => 'L';

  @override
  String get coordinateDmsWest => 'O';

  @override
  String get displayRefreshRatePreferHighest => 'Taxa máis alta';

  @override
  String get displayRefreshRatePreferLowest => 'Taxa máis baixa';

  @override
  String get keepScreenOnNever => 'Nunca';

  @override
  String get keepScreenOnVideoPlayback => 'Durante a reproducción de vídeo';

  @override
  String get keepScreenOnViewerOnly => 'Só páxina do visualizador';

  @override
  String get keepScreenOnAlways => 'Sempre';

  @override
  String get lengthUnitPixel => 'px';

  @override
  String get lengthUnitPercent => '%';

  @override
  String get mapStyleGoogleNormal => 'Google Maps';

  @override
  String get mapStyleGoogleHybrid => 'Google Maps (Híbrido)';

  @override
  String get mapStyleGoogleTerrain => 'Google Maps (Terreo)';

  @override
  String get mapStyleOsmLiberty => 'OSM Liberty';

  @override
  String get mapStyleOpenTopoMap => 'OpenTopoMap';

  @override
  String get mapStyleOsmHot => 'Humanitarian OSM';

  @override
  String get mapStyleStamenWatercolor => 'Stamen Watercolor (acuarela)';

  @override
  String get maxBrightnessNever => 'Nunca';

  @override
  String get maxBrightnessAlways => 'Sempre';

  @override
  String get nameConflictStrategyRename => 'Trocar nome';

  @override
  String get nameConflictStrategyReplace => 'Trocar';

  @override
  String get nameConflictStrategySkip => 'Saltar';

  @override
  String get overlayHistogramNone => 'Ningún';

  @override
  String get overlayHistogramRGB => 'RGB';

  @override
  String get overlayHistogramLuminance => 'Luminancia';

  @override
  String get subtitlePositionTop => 'Parte superior';

  @override
  String get subtitlePositionBottom => 'Fondo';

  @override
  String get themeBrightnessLight => 'Claro';

  @override
  String get themeBrightnessDark => 'Escuro';

  @override
  String get themeBrightnessBlack => 'Negro';

  @override
  String get unitSystemMetric => 'Métrico';

  @override
  String get unitSystemImperial => 'Imperial';

  @override
  String get vaultLockTypePattern => 'Padrón';

  @override
  String get vaultLockTypePin => 'PIN';

  @override
  String get vaultLockTypePassword => 'Contrasinal';

  @override
  String get settingsVideoEnablePip => 'Imaxe-en-imaxe';

  @override
  String get videoControlsPlayOutside => 'Abrir con outro reproductor';

  @override
  String get videoLoopModeNever => 'Nunca';

  @override
  String get videoLoopModeShortOnly => 'Só vídeos curtos';

  @override
  String get videoLoopModeAlways => 'Sempre';

  @override
  String get videoPlaybackSkip => 'Saltar';

  @override
  String get videoPlaybackMuted => 'Reproducir sen son';

  @override
  String get videoPlaybackWithSound => 'Reproducir con son';

  @override
  String get videoResumptionModeNever => 'Nunca';

  @override
  String get videoResumptionModeAlways => 'Sempre';

  @override
  String get viewerTransitionSlide => 'Diapositiva';

  @override
  String get viewerTransitionParallax => 'Paralaxe';

  @override
  String get viewerTransitionFade => 'Esvaecer';

  @override
  String get viewerTransitionZoomIn => 'Achegar';

  @override
  String get viewerTransitionNone => 'Ningún';

  @override
  String get wallpaperTargetHome => 'Pantalla de inicio';

  @override
  String get wallpaperTargetLock => 'Pantalla de bloqueo';

  @override
  String get wallpaperTargetHomeLock => 'Pantallas de inicio e bloqueo';

  @override
  String get widgetDisplayedItemRandom => 'Aleatorio';

  @override
  String get widgetDisplayedItemMostRecent => 'Máis recente';

  @override
  String get widgetOpenPageHome => 'Abrir inicio';

  @override
  String get widgetOpenPageCollection => 'Abrir colección';

  @override
  String get widgetOpenPageViewer => 'Abrir visor';

  @override
  String get widgetTapUpdateWidget => 'Actualizar widget';

  @override
  String get storageVolumeDescriptionFallbackPrimary => 'Almacenaxe interna';

  @override
  String get storageVolumeDescriptionFallbackNonPrimary => 'Tarxeta SD';

  @override
  String get rootDirectoryDescription => 'directorio raiz';

  @override
  String otherDirectoryDescription(String name) {
    return 'directorio «$name»';
  }

  @override
  String storageAccessDialogMessage(String directory, String volume) {
    return 'Por favor, seleccione o $directory de «$volume» na seguinte pantalla para lle fornecer acceso a esta aplicación.';
  }

  @override
  String restrictedAccessDialogMessage(String directory, String volume) {
    return 'Esta apliación non ten permiso para modificar arquivos no $directory de «$volume».\n\nPor favor, empregue un xestor de arquivos ou galería preinstalados para mover os elementos a outro directorio.';
  }

  @override
  String notEnoughSpaceDialogMessage(String neededSize, String freeSize, String volume) {
    return 'Esta operación precisa $neededSize de espazo libre en «$volume» para se completar, pero só hai $freeSize dispoñible.';
  }

  @override
  String get missingSystemFilePickerDialogMessage => 'O selector de arquivos falta ou está desactivado. Por favor, actíveo e tente de novo.';

  @override
  String unsupportedTypeDialogMessage(int count, String types) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Operación non soportada para elementos destes tipos: $types.',
      one: 'Operación non soportada para elementos deste tipo: $types.',
    );
    return '$_temp0';
  }

  @override
  String get nameConflictDialogSingleSourceMessage => 'Algúns arquivos do directorio de destiño teñen o mesmo nome.';

  @override
  String get nameConflictDialogMultipleSourceMessage => 'Algúns arquivos teñen o mesmo nome.';

  @override
  String get addShortcutDialogLabel => 'Etiqueta do atallo';

  @override
  String get addShortcutButtonLabel => 'ENGADIR';

  @override
  String get noMatchingAppDialogMessage => 'Non hai aplicacións que poidan manexar isto.';

  @override
  String binEntriesConfirmationDialogMessage(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mover estes $countString elementos ao lixo?',
      one: 'Mover este elemento ao lixo?',
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
      other: 'Borrar estes $countString elementos?',
      one: 'Borrar este elemento?',
    );
    return '$_temp0';
  }

  @override
  String get moveUndatedConfirmationDialogMessage => 'Gardar as datas dos elementos antes de continuar?';

  @override
  String get moveUndatedConfirmationDialogSetDate => 'Gardar datas';

  @override
  String videoResumeDialogMessage(String time) {
    return 'Desexa continuar a reproducción dende $time?';
  }

  @override
  String get videoStartOverButtonLabel => 'RECOMEZAR';

  @override
  String get videoResumeButtonLabel => 'RETOMAR';

  @override
  String get setCoverDialogLatest => 'Último elemento';

  @override
  String get setCoverDialogAuto => 'Auto';

  @override
  String get setCoverDialogCustom => 'Personalizado';

  @override
  String get hideFilterConfirmationDialogMessage => 'Agocharánse da súa colección as fotos e vídeos que concorden. Pódense amosar de novo dende os axustes de «Privacidade».\n\nEstá certo de querer agochalos?';

  @override
  String get newAlbumDialogTitle => 'Novo álbum';

  @override
  String get newAlbumDialogNameLabel => 'Nome do álbum';

  @override
  String get newAlbumDialogAlbumAlreadyExistsHelper => 'Xa existe o álbum';

  @override
  String get newAlbumDialogNameLabelAlreadyExistsHelper => 'Xa existe o directorio';

  @override
  String get newAlbumDialogStorageLabel => 'Almacenaxe:';

  @override
  String get newDynamicAlbumDialogTitle => 'Novo álbum dinámico';

  @override
  String get dynamicAlbumAlreadyExists => 'Xa existe o álbum dinámico';

  @override
  String get newVaultWarningDialogMessage => 'Os elementos en cofres só están dispoñibles para esta aplicación.\n\nPerderanse ao desinstalala ou ao borrar os seus datos.';

  @override
  String get newVaultDialogTitle => 'Novo cofre';

  @override
  String get configureVaultDialogTitle => 'Configurar cofre';

  @override
  String get vaultDialogLockModeWhenScreenOff => 'Bloquear ao se apagar a pantalla';

  @override
  String get vaultDialogLockTypeLabel => 'Tipo de bloqueo';

  @override
  String get patternDialogEnter => 'Inserir padrón';

  @override
  String get patternDialogConfirm => 'Confirmar padrón';

  @override
  String get pinDialogEnter => 'Inserir PIN';

  @override
  String get pinDialogConfirm => 'Confirmar PIN';

  @override
  String get passwordDialogEnter => 'Inserir contrasinal';

  @override
  String get passwordDialogConfirm => 'Confirmar contrasinal';

  @override
  String get authenticateToConfigureVault => 'Autenticarse para configurar o cofre';

  @override
  String get authenticateToUnlockVault => 'Autenticarse para despechar cofre';

  @override
  String get vaultBinUsageDialogMessage => 'Algúns cofres están a utilizar o lixo.';

  @override
  String get renameAlbumDialogLabel => 'Nome novo';

  @override
  String get renameAlbumDialogLabelAlreadyExistsHelper => 'Xa existe o directorio';

  @override
  String get renameEntrySetPageTitle => 'Trocar nome';

  @override
  String get renameEntrySetPagePatternFieldLabel => 'Padrón de nomeamento';

  @override
  String get renameEntrySetPageInsertTooltip => 'Inserir campo';

  @override
  String get renameEntrySetPagePreviewSectionTitle => 'Vista previa';

  @override
  String get renameProcessorCounter => 'Contador';

  @override
  String get renameProcessorHash => 'Hash';

  @override
  String get renameProcessorName => 'Nome';

  @override
  String deleteSingleAlbumConfirmationDialogMessage(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Eliminar este álbum e os seus $countString elementos?',
      one: 'Eliminar este álbum e o seu elemento?',
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
      other: 'Eliminar estes álbums e os seus $countString elementos?',
      one: 'Eliminar estes álbums e os seus elementos?',
    );
    return '$_temp0';
  }

  @override
  String get exportEntryDialogFormat => 'Formato:';

  @override
  String get exportEntryDialogWidth => 'Largo';

  @override
  String get exportEntryDialogHeight => 'Alto';

  @override
  String get exportEntryDialogQuality => 'Calidade';

  @override
  String get exportEntryDialogWriteMetadata => 'Escribir metadatos';

  @override
  String get renameEntryDialogLabel => 'Nome novo';

  @override
  String get editEntryDialogCopyFromItem => 'Copiar dende outro elemento';

  @override
  String get editEntryDialogTargetFieldsHeader => 'Campos a modificar';

  @override
  String get editEntryDateDialogTitle => 'Data e hora';

  @override
  String get editEntryDateDialogSetCustom => 'Definir data personalizada';

  @override
  String get editEntryDateDialogCopyField => 'Copiar dende outra data';

  @override
  String get editEntryDateDialogExtractFromTitle => 'Extraer do título';

  @override
  String get editEntryDateDialogShift => 'Mover';

  @override
  String get editEntryDateDialogSourceFileModifiedDate => 'Data de modificación do arquivo';

  @override
  String get durationDialogHours => 'Horas';

  @override
  String get durationDialogMinutes => 'Minutos';

  @override
  String get durationDialogSeconds => 'Segundos';

  @override
  String get editEntryLocationDialogTitle => 'Localización';

  @override
  String get editEntryLocationDialogSetCustom => 'Establecer localización personalizada';

  @override
  String get editEntryLocationDialogChooseOnMap => 'Escoller no mapa';

  @override
  String get editEntryLocationDialogImportGpx => 'Importar GPX';

  @override
  String get editEntryLocationDialogLatitude => 'Latitude';

  @override
  String get editEntryLocationDialogLongitude => 'Lonxitude';

  @override
  String get editEntryLocationDialogTimeShift => 'Cambio de tempo';

  @override
  String get locationPickerUseThisLocationButton => 'Usar esta localización';

  @override
  String get editEntryRatingDialogTitle => 'Valoración';

  @override
  String get removeEntryMetadataDialogTitle => 'Supresión de metadatos';

  @override
  String get removeEntryMetadataDialogAll => 'Todo';

  @override
  String get removeEntryMetadataDialogMore => 'Máis';

  @override
  String get removeEntryMetadataMotionPhotoXmpWarningDialogMessage => 'Precísase XMP para reproducir a animación dunha foto en movemento.\n\nEstá certo de querer eliminalo?';

  @override
  String get videoSpeedDialogLabel => 'Velocidade de reproducción';

  @override
  String get videoStreamSelectionDialogVideo => 'Vídeo';

  @override
  String get videoStreamSelectionDialogAudio => 'Audio';

  @override
  String get videoStreamSelectionDialogText => 'Subtítulos';

  @override
  String get videoStreamSelectionDialogOff => 'Desactivado';

  @override
  String get videoStreamSelectionDialogTrack => 'Pista';

  @override
  String get videoStreamSelectionDialogNoSelection => 'Non hai outras pistas.';

  @override
  String get genericSuccessFeedback => 'Feito!';

  @override
  String get genericFailureFeedback => 'Fallou';

  @override
  String get genericDangerWarningDialogMessage => 'Está certo?';

  @override
  String get tooManyItemsErrorDialogMessage => 'Tente de novo con menos elementos.';

  @override
  String get menuActionConfigureView => 'Vista';

  @override
  String get menuActionSelect => 'Escolmar';

  @override
  String get menuActionSelectAll => 'Escolmar todo';

  @override
  String get menuActionSelectNone => 'Non escolmar ningún';

  @override
  String get menuActionMap => 'Mapa';

  @override
  String get menuActionSlideshow => 'Presentación';

  @override
  String get menuActionStats => 'Estadísticas';

  @override
  String get viewDialogSortSectionTitle => 'Ordenar';

  @override
  String get viewDialogGroupSectionTitle => 'Agrupar';

  @override
  String get viewDialogLayoutSectionTitle => 'Disposición';

  @override
  String get viewDialogReverseSortOrder => 'Invertir ordenación';

  @override
  String get tileLayoutMosaic => 'Mosaico';

  @override
  String get tileLayoutGrid => 'Cuadrícula';

  @override
  String get tileLayoutList => 'Lista';

  @override
  String get castDialogTitle => 'Dispositivos de emisión';

  @override
  String get coverDialogTabCover => 'Cuberta';

  @override
  String get coverDialogTabApp => 'Aplicación';

  @override
  String get coverDialogTabColor => 'Cor';

  @override
  String get appPickDialogTitle => 'Escoller aplicación';

  @override
  String get appPickDialogNone => 'Ningún';

  @override
  String get aboutPageTitle => 'Verbo de';

  @override
  String get aboutLinkLicense => 'Licenza';

  @override
  String get aboutLinkPolicy => 'Política de privacidade';

  @override
  String get aboutBugSectionTitle => 'Informe de erros';

  @override
  String get aboutBugSaveLogInstruction => 'Gardar rexistros da aplicación nun arquivo';

  @override
  String get aboutBugCopyInfoInstruction => 'Copiar a información do sistema';

  @override
  String get aboutBugCopyInfoButton => 'Copiar';

  @override
  String get aboutBugReportInstruction => 'Informar en GitHub cos rexistros e información do sistema';

  @override
  String get aboutBugReportButton => 'Informar';

  @override
  String get aboutDataUsageSectionTitle => 'Uso de datos';

  @override
  String get aboutDataUsageData => 'Datos';

  @override
  String get aboutDataUsageCache => 'Caché';

  @override
  String get aboutDataUsageDatabase => 'Base de datos';

  @override
  String get aboutDataUsageMisc => 'Varios';

  @override
  String get aboutDataUsageInternal => 'Interno';

  @override
  String get aboutDataUsageExternal => 'Externo';

  @override
  String get aboutDataUsageClearCache => 'Limpar caché';

  @override
  String get aboutCreditsSectionTitle => 'Créditos';

  @override
  String get aboutCreditsWorldAtlas1 => 'Esta apliación usa un arquivo TopoJSON de';

  @override
  String get aboutCreditsWorldAtlas2 => 'baixo licenza ISC.';

  @override
  String get aboutTranslatorsSectionTitle => 'Tradutores';

  @override
  String get aboutLicensesSectionTitle => 'Licenzas de código aberto';

  @override
  String get aboutLicensesBanner => 'Esta aplicación usa os paquetes e bibliotecas de código aberto que seguen.';

  @override
  String get aboutLicensesAndroidLibrariesSectionTitle => 'Bibliotecas de Android';

  @override
  String get aboutLicensesFlutterPluginsSectionTitle => 'Plugins de Flutter';

  @override
  String get aboutLicensesFlutterPackagesSectionTitle => 'Paquetes de Flutter';

  @override
  String get aboutLicensesDartPackagesSectionTitle => 'Paquetes de Dart';

  @override
  String get aboutLicensesShowAllButtonLabel => 'Amosar todas as licenzas';

  @override
  String get policyPageTitle => 'Política de privacidade';

  @override
  String get collectionPageTitle => 'Colección';

  @override
  String get collectionPickPageTitle => 'Escolmar';

  @override
  String get collectionSelectPageTitle => 'Escolmar elementos';

  @override
  String get collectionActionShowTitleSearch => 'Amosar filtro de título';

  @override
  String get collectionActionHideTitleSearch => 'Agochar filtro de título';

  @override
  String get collectionActionAddDynamicAlbum => 'Engadir álbum dinámico';

  @override
  String get collectionActionAddShortcut => 'Engadir atallo';

  @override
  String get collectionActionSetHome => 'Fixar como inicio';

  @override
  String get collectionActionEmptyBin => 'Baleirar lixo';

  @override
  String get collectionActionCopy => 'Copiar a álbum';

  @override
  String get collectionActionMove => 'Mover a álbum';

  @override
  String get collectionActionRescan => 'Ler de novo';

  @override
  String get collectionActionEdit => 'Editar';

  @override
  String get collectionSearchTitlesHintText => 'Procurar títulos';

  @override
  String get collectionGroupAlbum => 'Por álbum';

  @override
  String get collectionGroupMonth => 'Por mes';

  @override
  String get collectionGroupDay => 'Por día';

  @override
  String get collectionGroupNone => 'Non agrupar';

  @override
  String get sectionUnknown => 'Descoñecido';

  @override
  String get dateToday => 'Hoxe';

  @override
  String get dateYesterday => 'Onte';

  @override
  String get dateThisMonth => 'Este mes';

  @override
  String collectionDeleteFailureFeedback(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Erro ao borrar $countString elementos',
      one: 'Erro ao borrar un elemento',
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
      other: 'Erro ao copiar $countString elementos',
      one: 'Erro ao copiar un elemento',
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
      other: 'Erro ao mover $countString elementos',
      one: 'Erro ao mover un elemento',
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
      other: 'Erro ao trocar o nome de $countString elementos',
      one: 'Erro ao trocar o nome dun elemento',
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
      other: 'Erro ao editar $countString elementos',
      one: 'Erro ao editar un elemento',
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
      other: 'Erro ao exportar $countString páxinas',
      one: 'Erro ao exportar unha páxina',
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
      other: 'Copiados $countString elementos',
      one: 'Copiado un elemento',
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
      other: 'Movidos $countString elementos',
      one: 'Movido un elemento',
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
      other: 'Trocado o nome de $countString elementos',
      one: 'Trocado o nome dun elemento',
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
      other: 'Editados $countString elementos',
      one: 'Editado un elemento',
    );
    return '$_temp0';
  }

  @override
  String get collectionEmptyFavourites => 'Sen favoritos';

  @override
  String get collectionEmptyVideos => 'Sen vídeos';

  @override
  String get collectionEmptyImages => 'Sen imaxes';

  @override
  String get collectionEmptyGrantAccessButtonLabel => 'Dar acceso';

  @override
  String get collectionSelectSectionTooltip => 'Escolmar sección';

  @override
  String get collectionDeselectSectionTooltip => 'Desescolmar sección';

  @override
  String get drawerAboutButton => 'Verbo de';

  @override
  String get drawerSettingsButton => 'Axustes';

  @override
  String get drawerCollectionAll => 'Toda a colección';

  @override
  String get drawerCollectionFavourites => 'Favoritos';

  @override
  String get drawerCollectionImages => 'Imaxes';

  @override
  String get drawerCollectionVideos => 'Vídeos';

  @override
  String get drawerCollectionAnimated => 'Animacións';

  @override
  String get drawerCollectionMotionPhotos => 'Fotos en movemento';

  @override
  String get drawerCollectionPanoramas => 'Panoramas';

  @override
  String get drawerCollectionRaws => 'Fotos Raw';

  @override
  String get drawerCollectionSphericalVideos => 'Vídeos 360°';

  @override
  String get drawerAlbumPage => 'Álbums';

  @override
  String get drawerCountryPage => 'Países';

  @override
  String get drawerPlacePage => 'Lugares';

  @override
  String get drawerTagPage => 'Etiquetas';

  @override
  String get sortByDate => 'Por data';

  @override
  String get sortByName => 'Por nome';

  @override
  String get sortByItemCount => 'Por número de elementos';

  @override
  String get sortBySize => 'Por tamaño';

  @override
  String get sortByAlbumFileName => 'Por nome de álbum e arquivo';

  @override
  String get sortByRating => 'Por valoración';

  @override
  String get sortByDuration => 'Por duración';

  @override
  String get sortOrderNewestFirst => 'Novos primeiro';

  @override
  String get sortOrderOldestFirst => 'Vellos primeiro';

  @override
  String get sortOrderAtoZ => 'A ao Z';

  @override
  String get sortOrderZtoA => 'Z ao A';

  @override
  String get sortOrderHighestFirst => 'Máis altos primeiro';

  @override
  String get sortOrderLowestFirst => 'Máis baixos primeiro';

  @override
  String get sortOrderLargestFirst => 'Máis grandes primeiro';

  @override
  String get sortOrderSmallestFirst => 'Máis pequenos primeiro';

  @override
  String get sortOrderShortestFirst => 'Máis curtos primeiro';

  @override
  String get sortOrderLongestFirst => 'Máis longos primeiro';

  @override
  String get albumGroupTier => 'Por nivel';

  @override
  String get albumGroupType => 'Por tipo';

  @override
  String get albumGroupVolume => 'Por volume de almacenaxe';

  @override
  String get albumGroupNone => 'Non agrupar';

  @override
  String get albumMimeTypeMixed => 'Mesturado';

  @override
  String get albumPickPageTitleCopy => 'Copiar a álbum';

  @override
  String get albumPickPageTitleExport => 'Exportar a álbum';

  @override
  String get albumPickPageTitleMove => 'Mover a álbum';

  @override
  String get albumPickPageTitlePick => 'Escolmar álbum';

  @override
  String get albumCamera => 'Cámara';

  @override
  String get albumDownload => 'Descargar';

  @override
  String get albumScreenshots => 'Capturas de pantalla';

  @override
  String get albumScreenRecordings => 'Gravacións de pantalla';

  @override
  String get albumVideoCaptures => 'Capturas de vídeo';

  @override
  String get albumPageTitle => 'Álbums';

  @override
  String get albumEmpty => 'Sen álbums';

  @override
  String get createAlbumButtonLabel => 'CREAR';

  @override
  String get newFilterBanner => 'novo';

  @override
  String get countryPageTitle => 'Países';

  @override
  String get countryEmpty => 'Sen países';

  @override
  String get statePageTitle => 'Estados';

  @override
  String get stateEmpty => 'Sen estados';

  @override
  String get placePageTitle => 'Lugares';

  @override
  String get placeEmpty => 'Sen lugares';

  @override
  String get tagPageTitle => 'Etiquetas';

  @override
  String get tagEmpty => 'Sen etiquetas';

  @override
  String get binPageTitle => 'Lixo';

  @override
  String get explorerPageTitle => 'Explorador';

  @override
  String get explorerActionSelectStorageVolume => 'Escolmar almacenaxe';

  @override
  String get selectStorageVolumeDialogTitle => 'Escolmar almacenaxe';

  @override
  String get searchCollectionFieldHint => 'Procurar en colección';

  @override
  String get searchRecentSectionTitle => 'Recente';

  @override
  String get searchDateSectionTitle => 'Data';

  @override
  String get searchAlbumsSectionTitle => 'Álbums';

  @override
  String get searchCountriesSectionTitle => 'Países';

  @override
  String get searchStatesSectionTitle => 'Estados';

  @override
  String get searchPlacesSectionTitle => 'Lugares';

  @override
  String get searchTagsSectionTitle => 'Etiquetas';

  @override
  String get searchRatingSectionTitle => 'Valoracións';

  @override
  String get searchMetadataSectionTitle => 'Metadatos';

  @override
  String get settingsPageTitle => 'Axustes';

  @override
  String get settingsSystemDefault => 'Sistema';

  @override
  String get settingsDefault => 'Por defecto';

  @override
  String get settingsDisabled => 'Desactivado';

  @override
  String get settingsAskEverytime => 'Preguntar sempre';

  @override
  String get settingsModificationWarningDialogMessage => 'Modificaranse outros axustes.';

  @override
  String get settingsSearchFieldLabel => 'Procurar axustes';

  @override
  String get settingsSearchEmpty => 'Sen coincidencia';

  @override
  String get settingsActionExport => 'Exportar';

  @override
  String get settingsActionExportDialogTitle => 'Exportar';

  @override
  String get settingsActionImport => 'Importar';

  @override
  String get settingsActionImportDialogTitle => 'Importar';

  @override
  String get appExportCovers => 'Cubertas';

  @override
  String get appExportDynamicAlbums => 'Álbums dinámicos';

  @override
  String get appExportFavourites => 'Favoritos';

  @override
  String get appExportSettings => 'Axustes';

  @override
  String get settingsNavigationSectionTitle => 'Navegación';

  @override
  String get settingsHomeTile => 'Inicio';

  @override
  String get settingsHomeDialogTitle => 'Inicio';

  @override
  String get setHomeCustom => 'Personalizado';

  @override
  String get settingsShowBottomNavigationBar => 'Amosar barra de navegación inferior';

  @override
  String get settingsKeepScreenOnTile => 'Manter pantalla acesa';

  @override
  String get settingsKeepScreenOnDialogTitle => 'Manter pantalla acesa';

  @override
  String get settingsDoubleBackExit => 'Premer «atrás» dúas veces para saír';

  @override
  String get settingsConfirmationTile => 'Diálogos de confirmación';

  @override
  String get settingsConfirmationDialogTitle => 'Diálogos de confirmación';

  @override
  String get settingsConfirmationBeforeDeleteItems => 'Preguntar antes de borrar elementos para sempre';

  @override
  String get settingsConfirmationBeforeMoveToBinItems => 'Preguntar antes de enviar elementos ao lixo';

  @override
  String get settingsConfirmationBeforeMoveUndatedItems => 'Preguntar antes de mover elementos sen data';

  @override
  String get settingsConfirmationAfterMoveToBinItems => 'Amosar mensaxe tras mover elementos ao lixo';

  @override
  String get settingsConfirmationVaultDataLoss => 'Amosar aviso de perda de datos en cofre';

  @override
  String get settingsNavigationDrawerTile => 'Menú de navegación';

  @override
  String get settingsNavigationDrawerEditorPageTitle => 'Menú de navegación';

  @override
  String get settingsNavigationDrawerBanner => 'Premer e manter para mover e reordenar elementos do menú.';

  @override
  String get settingsNavigationDrawerTabTypes => 'Tipos';

  @override
  String get settingsNavigationDrawerTabAlbums => 'Álbums';

  @override
  String get settingsNavigationDrawerTabPages => 'Páxinas';

  @override
  String get settingsNavigationDrawerAddAlbum => 'Engadir álbum';

  @override
  String get settingsThumbnailSectionTitle => 'Miniaturas';

  @override
  String get settingsThumbnailOverlayTile => 'Superposición';

  @override
  String get settingsThumbnailOverlayPageTitle => 'Superposición';

  @override
  String get settingsThumbnailShowHdrIcon => 'Amosar icona de HDR';

  @override
  String get settingsThumbnailShowFavouriteIcon => 'Amosar icona de favorito';

  @override
  String get settingsThumbnailShowTagIcon => 'Amosar icona de etiqueta';

  @override
  String get settingsThumbnailShowLocationIcon => 'Amosar icona de localización';

  @override
  String get settingsThumbnailShowMotionPhotoIcon => 'Amosar icona de foto en movemento';

  @override
  String get settingsThumbnailShowRating => 'Amosar valoración';

  @override
  String get settingsThumbnailShowRawIcon => 'Amosar icona de RAW';

  @override
  String get settingsThumbnailShowVideoDuration => 'Amosar duración de vídeo';

  @override
  String get settingsCollectionQuickActionsTile => 'Accións rápidas';

  @override
  String get settingsCollectionQuickActionEditorPageTitle => 'Accións rápidas';

  @override
  String get settingsCollectionQuickActionTabBrowsing => 'Navegando';

  @override
  String get settingsCollectionQuickActionTabSelecting => 'Escolmando';

  @override
  String get settingsCollectionBrowsingQuickActionEditorBanner => 'Prema e manteña para mover botóns e escoller que accións se amosarán ao navegar polo elementos.';

  @override
  String get settingsCollectionSelectionQuickActionEditorBanner => 'Prema e manteña para mover botóns e escoller que accións se amosarán ao navegar polos elementos.';

  @override
  String get settingsCollectionBurstPatternsTile => 'Patróns de refacho';

  @override
  String get settingsCollectionBurstPatternsNone => 'Ningún';

  @override
  String get settingsViewerSectionTitle => 'Visor';

  @override
  String get settingsViewerGestureSideTapNext => 'Toque nos bordes da pantalla para amosar o elemento anterior/seguinte';

  @override
  String get settingsViewerUseCutout => 'Usar a área recortada';

  @override
  String get settingsViewerMaximumBrightness => 'Brillo máximo';

  @override
  String get settingsMotionPhotoAutoPlay => 'Reproducir automáticamente fotos en movemento';

  @override
  String get settingsImageBackground => 'Fondo de imaxe';

  @override
  String get settingsViewerQuickActionsTile => 'Accións rápidas';

  @override
  String get settingsViewerQuickActionEditorPageTitle => 'Accións rápidas';

  @override
  String get settingsViewerQuickActionEditorBanner => 'Prema e manteña para mover botóns e escoller que accións se amosarán no visor.';

  @override
  String get settingsViewerQuickActionEditorDisplayedButtonsSectionTitle => 'Botóns amosados';

  @override
  String get settingsViewerQuickActionEditorAvailableButtonsSectionTitle => 'Botóns dispoñibles';

  @override
  String get settingsViewerQuickActionEmpty => 'Sen botóns';

  @override
  String get settingsViewerOverlayTile => 'Superposición';

  @override
  String get settingsViewerOverlayPageTitle => 'Superposición';

  @override
  String get settingsViewerShowOverlayOnOpening => 'Amosar ao abrir';

  @override
  String get settingsViewerShowHistogram => 'Amosar histograma';

  @override
  String get settingsViewerShowMinimap => 'Amosar minimapa';

  @override
  String get settingsViewerShowInformation => 'Amosar información';

  @override
  String get settingsViewerShowInformationSubtitle => 'Amosar título, data, localización, etc.';

  @override
  String get settingsViewerShowRatingTags => 'Amosar valoración e etiquetas';

  @override
  String get settingsViewerShowShootingDetails => 'Amosar detalles da toma';

  @override
  String get settingsViewerShowDescription => 'Amosar descrición';

  @override
  String get settingsViewerShowOverlayThumbnails => 'Amosar miniaturas';

  @override
  String get settingsViewerEnableOverlayBlurEffect => 'Efecto de desenfoque';

  @override
  String get settingsViewerSlideshowTile => 'Presentación';

  @override
  String get settingsViewerSlideshowPageTitle => 'Presentación';

  @override
  String get settingsSlideshowRepeat => 'Repetir';

  @override
  String get settingsSlideshowShuffle => 'Barallar';

  @override
  String get settingsSlideshowFillScreen => 'Encher pantalla';

  @override
  String get settingsSlideshowAnimatedZoomEffect => 'Efecto de zoom animado';

  @override
  String get settingsSlideshowTransitionTile => 'Transición';

  @override
  String get settingsSlideshowIntervalTile => 'Intervalo';

  @override
  String get settingsSlideshowVideoPlaybackTile => 'Reprodución de vídeo';

  @override
  String get settingsSlideshowVideoPlaybackDialogTitle => 'Reprodución de vídeo';

  @override
  String get settingsVideoPageTitle => 'Axustes de vídeo';

  @override
  String get settingsVideoSectionTitle => 'Vídeo';

  @override
  String get settingsVideoShowVideos => 'Amosar vídeos';

  @override
  String get settingsVideoPlaybackTile => 'Reprodución';

  @override
  String get settingsVideoPlaybackPageTitle => 'Reprodución';

  @override
  String get settingsVideoEnableHardwareAcceleration => 'Aceleración por hardware';

  @override
  String get settingsVideoAutoPlay => 'Reprodución automática';

  @override
  String get settingsVideoLoopModeTile => 'Modo bucle';

  @override
  String get settingsVideoLoopModeDialogTitle => 'Modo bucle';

  @override
  String get settingsVideoResumptionModeTile => 'Retomar reprodución';

  @override
  String get settingsVideoResumptionModeDialogTitle => 'Retomar reprodución';

  @override
  String get settingsVideoBackgroundMode => 'Modo do fondo';

  @override
  String get settingsVideoBackgroundModeDialogTitle => 'Modo do fondo';

  @override
  String get settingsVideoControlsTile => 'Controis';

  @override
  String get settingsVideoControlsPageTitle => 'Controis';

  @override
  String get settingsVideoButtonsTile => 'Botóns';

  @override
  String get settingsVideoGestureDoubleTapTogglePlay => 'Dobre toque para reproducir/pausar';

  @override
  String get settingsVideoGestureSideDoubleTapSeek => 'Dobre toque nos bordes da pantalla para buscar atrás/adiante';

  @override
  String get settingsVideoGestureVerticalDragBrightnessVolume => 'Esvare para riba ou para abaixo para axustar brillo/volume';

  @override
  String get settingsSubtitleThemeTile => 'Subtítulos';

  @override
  String get settingsSubtitleThemePageTitle => 'Subtítulos';

  @override
  String get settingsSubtitleThemeSample => 'Este é un exemplo.';

  @override
  String get settingsSubtitleThemeTextAlignmentTile => 'Aliñamento do texto';

  @override
  String get settingsSubtitleThemeTextAlignmentDialogTitle => 'Aliñamento do texto';

  @override
  String get settingsSubtitleThemeTextPositionTile => 'Posición do texto';

  @override
  String get settingsSubtitleThemeTextPositionDialogTitle => 'Posición do texto';

  @override
  String get settingsSubtitleThemeTextSize => 'Tamaño do texto';

  @override
  String get settingsSubtitleThemeShowOutline => 'Amosar contorno e sombra';

  @override
  String get settingsSubtitleThemeTextColor => 'Cor do texto';

  @override
  String get settingsSubtitleThemeTextOpacity => 'Opacidade do texto';

  @override
  String get settingsSubtitleThemeBackgroundColor => 'Cor de fondo';

  @override
  String get settingsSubtitleThemeBackgroundOpacity => 'Opacidade do fondo';

  @override
  String get settingsSubtitleThemeTextAlignmentLeft => 'Esquerda';

  @override
  String get settingsSubtitleThemeTextAlignmentCenter => 'Centro';

  @override
  String get settingsSubtitleThemeTextAlignmentRight => 'Dereita';

  @override
  String get settingsPrivacySectionTitle => 'Privacidade';

  @override
  String get settingsAllowInstalledAppAccess => 'Permitir acceso á lista de aplicacións';

  @override
  String get settingsAllowInstalledAppAccessSubtitle => 'Usado para mellorar a visualización dos álbums';

  @override
  String get settingsAllowErrorReporting => 'Permitir informes de erros anónimos';

  @override
  String get settingsSaveSearchHistory => 'Gardar historial de procura';

  @override
  String get settingsEnableBin => 'Usar lixo';

  @override
  String get settingsEnableBinSubtitle => 'Mantén os elementos borrados por 30 días';

  @override
  String get settingsDisablingBinWarningDialogMessage => 'Os elementos no lixo borraranse para sempre.';

  @override
  String get settingsAllowMediaManagement => 'Permitir xestión de medios';

  @override
  String get settingsHiddenItemsTile => 'Elementos ocultos';

  @override
  String get settingsHiddenItemsPageTitle => 'Elementos ocultos';

  @override
  String get settingsHiddenFiltersBanner => 'As fotos e vídeos que cadren cos filtros ocultos non se amosarán na súa colección.';

  @override
  String get settingsHiddenFiltersEmpty => 'Sen filtros ocultos';

  @override
  String get settingsStorageAccessTile => 'Acceso á almacenaxe';

  @override
  String get settingsStorageAccessPageTitle => 'Acceso á almacenaxe';

  @override
  String get settingsStorageAccessBanner => 'Algúns directorios precisan permiso explícito de acceso para modificar os arquivos que conteñen. Aquí pode revisar a que directorios lles tera dado acceso.';

  @override
  String get settingsStorageAccessEmpty => 'Sen permisos de acceso';

  @override
  String get settingsStorageAccessRevokeTooltip => 'Revogar';

  @override
  String get settingsAccessibilitySectionTitle => 'Accesibilidade';

  @override
  String get settingsRemoveAnimationsTile => 'Eliminar animacións';

  @override
  String get settingsRemoveAnimationsDialogTitle => 'Eliminar animacións';

  @override
  String get settingsTimeToTakeActionTile => 'Retardo para executar unha acción';

  @override
  String get settingsAccessibilityShowPinchGestureAlternatives => 'Amosar alternativas de xestos multitoque';

  @override
  String get settingsDisplaySectionTitle => 'Pantalla';

  @override
  String get settingsThemeBrightnessTile => 'Tema';

  @override
  String get settingsThemeBrightnessDialogTitle => 'Tema';

  @override
  String get settingsThemeColorHighlights => 'Realces de cor';

  @override
  String get settingsThemeEnableDynamicColor => 'Cor dinámica';

  @override
  String get settingsDisplayRefreshRateModeTile => 'Taxa de refresco da pantalla';

  @override
  String get settingsDisplayRefreshRateModeDialogTitle => 'Taxa de refresco';

  @override
  String get settingsDisplayUseTvInterface => 'Interface Android TV';

  @override
  String get settingsLanguageSectionTitle => 'Idioma e formatos';

  @override
  String get settingsLanguageTile => 'Idioma';

  @override
  String get settingsLanguagePageTitle => 'Idioma';

  @override
  String get settingsCoordinateFormatTile => 'Formato de coordenadas';

  @override
  String get settingsCoordinateFormatDialogTitle => 'Formato de coordenadas';

  @override
  String get settingsUnitSystemTile => 'Unidades';

  @override
  String get settingsUnitSystemDialogTitle => 'Unidades';

  @override
  String get settingsForceWesternArabicNumeralsTile => 'Forzar números arábigos';

  @override
  String get settingsScreenSaverPageTitle => 'Protector de pantalla';

  @override
  String get settingsWidgetPageTitle => 'Marco de foto';

  @override
  String get settingsWidgetShowOutline => 'Contorno';

  @override
  String get settingsWidgetOpenPage => 'Ao tocar no widget';

  @override
  String get settingsWidgetDisplayedItem => 'Elemento amosado';

  @override
  String get settingsCollectionTile => 'Colección';

  @override
  String get statsPageTitle => 'Estadísticas';

  @override
  String statsWithGps(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString elementos con localización',
      one: '1 elemento con localización',
    );
    return '$_temp0';
  }

  @override
  String get statsTopCountriesSectionTitle => 'Países principais';

  @override
  String get statsTopStatesSectionTitle => 'Estados principais';

  @override
  String get statsTopPlacesSectionTitle => 'Lugares principais';

  @override
  String get statsTopTagsSectionTitle => 'Etiquetas principais';

  @override
  String get statsTopAlbumsSectionTitle => 'Álbums principais';

  @override
  String get viewerOpenPanoramaButtonLabel => 'ABRIR PANORAMA';

  @override
  String get viewerSetWallpaperButtonLabel => 'DEFINIR FONDO';

  @override
  String get viewerErrorUnknown => 'Epa!';

  @override
  String get viewerErrorDoesNotExist => 'Xa non existe o arquivo.';

  @override
  String get viewerInfoPageTitle => 'Información';

  @override
  String get viewerInfoBackToViewerTooltip => 'Tornar ao visor';

  @override
  String get viewerInfoUnknown => 'descoñecido';

  @override
  String get viewerInfoLabelDescription => 'Descrición';

  @override
  String get viewerInfoLabelTitle => 'Título';

  @override
  String get viewerInfoLabelDate => 'Data';

  @override
  String get viewerInfoLabelResolution => 'Resolución';

  @override
  String get viewerInfoLabelSize => 'Tamaño';

  @override
  String get viewerInfoLabelUri => 'URI';

  @override
  String get viewerInfoLabelPath => 'Ruta';

  @override
  String get viewerInfoLabelDuration => 'Duración';

  @override
  String get viewerInfoLabelOwner => 'Propietario';

  @override
  String get viewerInfoLabelCoordinates => 'Coordenadas';

  @override
  String get viewerInfoLabelAddress => 'Enderezo';

  @override
  String get mapStyleDialogTitle => 'Estilo do mapa';

  @override
  String get mapStyleTooltip => 'Seleccione estilo do mapa';

  @override
  String get mapZoomInTooltip => 'Achegar';

  @override
  String get mapZoomOutTooltip => 'Afastar';

  @override
  String get mapPointNorthUpTooltip => 'Apuntar o norte cara arriba';

  @override
  String get mapAttributionOsmData => 'Datos de mapa © os colaboradores de [OpenStreetMap](https://www.openstreetmap.org/copyright)';

  @override
  String get mapAttributionOsmLiberty => 'Mosaicos de [OpenMapTiles](https://www.openmaptiles.org/), [CC BY](http://creativecommons.org/licenses/by/4.0) • Hospedado por [OSM Americana](https://tile.ourmap.us)';

  @override
  String get mapAttributionOpenTopoMap => '[SRTM](https://www.earthdata.nasa.gov/sensors/srtm) | Mosaicos de [OpenTopoMap](https://opentopomap.org/), [CC BY-SA](https://creativecommons.org/licenses/by-sa/3.0/)';

  @override
  String get mapAttributionOsmHot => 'Mosaicos de [HOT](https://www.hotosm.org/) • Hosted by [OSM France](https://openstreetmap.fr/)';

  @override
  String get mapAttributionStamen => 'Mosaicos de [Stamen Design](https://stamen.com), [CC BY 3.0](https://creativecommons.org/licenses/by/3.0)';

  @override
  String get openMapPageTooltip => 'Ver na páxina do mapa';

  @override
  String get mapEmptyRegion => 'Sen imaxes nesta rexión';

  @override
  String get viewerInfoOpenEmbeddedFailureFeedback => 'Fallo ao extraer datos incrustados';

  @override
  String get viewerInfoOpenLinkText => 'Abrir';

  @override
  String get viewerInfoViewXmlLinkText => 'Ver XML';

  @override
  String get viewerInfoSearchFieldLabel => 'Procurar metadatos';

  @override
  String get viewerInfoSearchEmpty => 'Sen claves concordantes';

  @override
  String get viewerInfoSearchSuggestionDate => 'Data e hora';

  @override
  String get viewerInfoSearchSuggestionDescription => 'Descrición';

  @override
  String get viewerInfoSearchSuggestionDimensions => 'Dimensións';

  @override
  String get viewerInfoSearchSuggestionResolution => 'Resolución';

  @override
  String get viewerInfoSearchSuggestionRights => 'Dereitos';

  @override
  String get wallpaperUseScrollEffect => 'Usar efecto de desprazamento en pantalla de inicio';

  @override
  String get tagEditorPageTitle => 'Editar etiquetas';

  @override
  String get tagEditorPageNewTagFieldLabel => 'Nova etiqueta';

  @override
  String get tagEditorPageAddTagTooltip => 'Engadir etiqueta';

  @override
  String get tagEditorSectionRecent => 'Recente';

  @override
  String get tagEditorSectionPlaceholders => 'Marcadores de posición';

  @override
  String get tagEditorDiscardDialogMessage => 'Quere descartar os cambios?';

  @override
  String get tagPlaceholderCountry => 'País';

  @override
  String get tagPlaceholderState => 'Estado';

  @override
  String get tagPlaceholderPlace => 'Lugar';

  @override
  String get panoramaEnableSensorControl => 'Activar control do sensor';

  @override
  String get panoramaDisableSensorControl => 'Desactivar control do sensor';

  @override
  String get sourceViewerPageTitle => 'Fonte';

  @override
  String get filePickerShowHiddenFiles => 'Amosar arquivos agochados';

  @override
  String get filePickerDoNotShowHiddenFiles => 'Non amosar arquivos agochados';

  @override
  String get filePickerOpenFrom => 'Abrir dende';

  @override
  String get filePickerNoItems => 'Sen elementos';

  @override
  String get filePickerUseThisFolder => 'Usar este cartafol';
}
