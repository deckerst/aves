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
      one: '$count elementos',
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
  String get doubleBackExitMessage => 'Prema \"atrás\" de novo para saír.';

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
  String get filterTypePanoramaLabel => 'Panorámica';

  @override
  String get filterTypeRawLabel => 'Raw (Formato do ficheiro)';

  @override
  String get filterTypeSphericalVideoLabel => 'Vídeo 360°';

  @override
  String get filterTypeGeotiffLabel => 'GeoTIFF (Formato de ficheiro)';

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
  String get coordinateFormatDms => 'DMS (Sistema de xestión documental)';

  @override
  String get coordinateFormatDdm => 'DDM';

  @override
  String get coordinateFormatDecimal => 'Graos decimais';

  @override
  String coordinateDms(String coordinate, String direction) {
    return '$coordinate $direction';
  }

  @override
  String get coordinateDmsNorth => 'Norte';

  @override
  String get coordinateDmsSouth => 'Sur';

  @override
  String get coordinateDmsEast => 'Leste';

  @override
  String get coordinateDmsWest => 'Oeste';

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
  String get mapStyleOsmHot => 'Humanitarian OpenStreetMap Team';

  @override
  String get mapStyleStamenWatercolor => 'Stamen Watercolor (con sombreamento e cores)';

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
  String get newVaultWarningDialogMessage => 'Os elementos en cofres só están dispoñibles para esta aplicación.\n\nPerderanse se se desinstala ou se borran os seus datos.';

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
  String get removeEntryMetadataMotionPhotoXmpWarningDialogMessage => 'XMP is required to play the video inside a motion photo.\n\nAre you sure you want to remove it?';

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
      other: 'Failed to delete $countString items',
      one: 'Failed to delete 1 item',
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
      other: 'Failed to copy $countString items',
      one: 'Failed to copy 1 item',
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
      other: 'Failed to move $countString items',
      one: 'Failed to move 1 item',
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
      other: 'Failed to rename $countString items',
      one: 'Failed to rename 1 item',
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
      other: 'Failed to edit $countString items',
      one: 'Failed to edit 1 item',
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
      other: 'Failed to export $countString pages',
      one: 'Failed to export 1 page',
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
      other: 'Copied $countString items',
      one: 'Copied 1 item',
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
      other: 'Moved $countString items',
      one: 'Moved 1 item',
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
      other: 'Renamed $countString items',
      one: 'Renamed 1 item',
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
      other: 'Edited $countString items',
      one: 'Edited 1 item',
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
  String get settingsModificationWarningDialogMessage => 'Other settings will be modified.';

  @override
  String get settingsSearchFieldLabel => 'Search settings';

  @override
  String get settingsSearchEmpty => 'No matching setting';

  @override
  String get settingsActionExport => 'Export';

  @override
  String get settingsActionExportDialogTitle => 'Export';

  @override
  String get settingsActionImport => 'Import';

  @override
  String get settingsActionImportDialogTitle => 'Import';

  @override
  String get appExportCovers => 'Covers';

  @override
  String get appExportDynamicAlbums => 'Dynamic albums';

  @override
  String get appExportFavourites => 'Favorites';

  @override
  String get appExportSettings => 'Settings';

  @override
  String get settingsNavigationSectionTitle => 'Navigation';

  @override
  String get settingsHomeTile => 'Home';

  @override
  String get settingsHomeDialogTitle => 'Home';

  @override
  String get setHomeCustom => 'Custom';

  @override
  String get settingsShowBottomNavigationBar => 'Show bottom navigation bar';

  @override
  String get settingsKeepScreenOnTile => 'Keep screen on';

  @override
  String get settingsKeepScreenOnDialogTitle => 'Keep Screen On';

  @override
  String get settingsDoubleBackExit => 'Tap “back” twice to exit';

  @override
  String get settingsConfirmationTile => 'Confirmation dialogs';

  @override
  String get settingsConfirmationDialogTitle => 'Confirmation Dialogs';

  @override
  String get settingsConfirmationBeforeDeleteItems => 'Ask before deleting items forever';

  @override
  String get settingsConfirmationBeforeMoveToBinItems => 'Ask before moving items to the recycle bin';

  @override
  String get settingsConfirmationBeforeMoveUndatedItems => 'Ask before moving undated items';

  @override
  String get settingsConfirmationAfterMoveToBinItems => 'Show message after moving items to the recycle bin';

  @override
  String get settingsConfirmationVaultDataLoss => 'Show vault data loss warning';

  @override
  String get settingsNavigationDrawerTile => 'Navigation menu';

  @override
  String get settingsNavigationDrawerEditorPageTitle => 'Navigation Menu';

  @override
  String get settingsNavigationDrawerBanner => 'Touch and hold to move and reorder menu items.';

  @override
  String get settingsNavigationDrawerTabTypes => 'Types';

  @override
  String get settingsNavigationDrawerTabAlbums => 'Albums';

  @override
  String get settingsNavigationDrawerTabPages => 'Pages';

  @override
  String get settingsNavigationDrawerAddAlbum => 'Add album';

  @override
  String get settingsThumbnailSectionTitle => 'Thumbnails';

  @override
  String get settingsThumbnailOverlayTile => 'Overlay';

  @override
  String get settingsThumbnailOverlayPageTitle => 'Overlay';

  @override
  String get settingsThumbnailShowHdrIcon => 'Show HDR icon';

  @override
  String get settingsThumbnailShowFavouriteIcon => 'Show favorite icon';

  @override
  String get settingsThumbnailShowTagIcon => 'Show tag icon';

  @override
  String get settingsThumbnailShowLocationIcon => 'Show location icon';

  @override
  String get settingsThumbnailShowMotionPhotoIcon => 'Show motion photo icon';

  @override
  String get settingsThumbnailShowRating => 'Show rating';

  @override
  String get settingsThumbnailShowRawIcon => 'Show raw icon';

  @override
  String get settingsThumbnailShowVideoDuration => 'Show video duration';

  @override
  String get settingsCollectionQuickActionsTile => 'Quick actions';

  @override
  String get settingsCollectionQuickActionEditorPageTitle => 'Quick Actions';

  @override
  String get settingsCollectionQuickActionTabBrowsing => 'Browsing';

  @override
  String get settingsCollectionQuickActionTabSelecting => 'Selecting';

  @override
  String get settingsCollectionBrowsingQuickActionEditorBanner => 'Touch and hold to move buttons and select which actions are displayed when browsing items.';

  @override
  String get settingsCollectionSelectionQuickActionEditorBanner => 'Touch and hold to move buttons and select which actions are displayed when selecting items.';

  @override
  String get settingsCollectionBurstPatternsTile => 'Burst patterns';

  @override
  String get settingsCollectionBurstPatternsNone => 'None';

  @override
  String get settingsViewerSectionTitle => 'Viewer';

  @override
  String get settingsViewerGestureSideTapNext => 'Tap on screen edges to show previous/next item';

  @override
  String get settingsViewerUseCutout => 'Use cutout area';

  @override
  String get settingsViewerMaximumBrightness => 'Maximum brightness';

  @override
  String get settingsMotionPhotoAutoPlay => 'Auto play motion photos';

  @override
  String get settingsImageBackground => 'Image background';

  @override
  String get settingsViewerQuickActionsTile => 'Quick actions';

  @override
  String get settingsViewerQuickActionEditorPageTitle => 'Quick Actions';

  @override
  String get settingsViewerQuickActionEditorBanner => 'Touch and hold to move buttons and select which actions are displayed in the viewer.';

  @override
  String get settingsViewerQuickActionEditorDisplayedButtonsSectionTitle => 'Displayed Buttons';

  @override
  String get settingsViewerQuickActionEditorAvailableButtonsSectionTitle => 'Available Buttons';

  @override
  String get settingsViewerQuickActionEmpty => 'No buttons';

  @override
  String get settingsViewerOverlayTile => 'Overlay';

  @override
  String get settingsViewerOverlayPageTitle => 'Overlay';

  @override
  String get settingsViewerShowOverlayOnOpening => 'Show on opening';

  @override
  String get settingsViewerShowHistogram => 'Show histogram';

  @override
  String get settingsViewerShowMinimap => 'Show minimap';

  @override
  String get settingsViewerShowInformation => 'Show information';

  @override
  String get settingsViewerShowInformationSubtitle => 'Show title, date, location, etc.';

  @override
  String get settingsViewerShowRatingTags => 'Show rating & tags';

  @override
  String get settingsViewerShowShootingDetails => 'Show shooting details';

  @override
  String get settingsViewerShowDescription => 'Show description';

  @override
  String get settingsViewerShowOverlayThumbnails => 'Show thumbnails';

  @override
  String get settingsViewerEnableOverlayBlurEffect => 'Blur effect';

  @override
  String get settingsViewerSlideshowTile => 'Slideshow';

  @override
  String get settingsViewerSlideshowPageTitle => 'Slideshow';

  @override
  String get settingsSlideshowRepeat => 'Repeat';

  @override
  String get settingsSlideshowShuffle => 'Shuffle';

  @override
  String get settingsSlideshowFillScreen => 'Fill screen';

  @override
  String get settingsSlideshowAnimatedZoomEffect => 'Animated zoom effect';

  @override
  String get settingsSlideshowTransitionTile => 'Transition';

  @override
  String get settingsSlideshowIntervalTile => 'Interval';

  @override
  String get settingsSlideshowVideoPlaybackTile => 'Video playback';

  @override
  String get settingsSlideshowVideoPlaybackDialogTitle => 'Video Playback';

  @override
  String get settingsVideoPageTitle => 'Video Settings';

  @override
  String get settingsVideoSectionTitle => 'Video';

  @override
  String get settingsVideoShowVideos => 'Show videos';

  @override
  String get settingsVideoPlaybackTile => 'Playback';

  @override
  String get settingsVideoPlaybackPageTitle => 'Playback';

  @override
  String get settingsVideoEnableHardwareAcceleration => 'Hardware acceleration';

  @override
  String get settingsVideoAutoPlay => 'Auto play';

  @override
  String get settingsVideoLoopModeTile => 'Loop mode';

  @override
  String get settingsVideoLoopModeDialogTitle => 'Loop Mode';

  @override
  String get settingsVideoResumptionModeTile => 'Resume playback';

  @override
  String get settingsVideoResumptionModeDialogTitle => 'Resume Playback';

  @override
  String get settingsVideoBackgroundMode => 'Background mode';

  @override
  String get settingsVideoBackgroundModeDialogTitle => 'Background Mode';

  @override
  String get settingsVideoControlsTile => 'Controls';

  @override
  String get settingsVideoControlsPageTitle => 'Controls';

  @override
  String get settingsVideoButtonsTile => 'Buttons';

  @override
  String get settingsVideoGestureDoubleTapTogglePlay => 'Double tap to play/pause';

  @override
  String get settingsVideoGestureSideDoubleTapSeek => 'Double tap on screen edges to seek backward/forward';

  @override
  String get settingsVideoGestureVerticalDragBrightnessVolume => 'Swipe up or down to adjust brightness/volume';

  @override
  String get settingsSubtitleThemeTile => 'Subtitles';

  @override
  String get settingsSubtitleThemePageTitle => 'Subtitles';

  @override
  String get settingsSubtitleThemeSample => 'This is a sample.';

  @override
  String get settingsSubtitleThemeTextAlignmentTile => 'Text alignment';

  @override
  String get settingsSubtitleThemeTextAlignmentDialogTitle => 'Text Alignment';

  @override
  String get settingsSubtitleThemeTextPositionTile => 'Text position';

  @override
  String get settingsSubtitleThemeTextPositionDialogTitle => 'Text Position';

  @override
  String get settingsSubtitleThemeTextSize => 'Text size';

  @override
  String get settingsSubtitleThemeShowOutline => 'Show outline and shadow';

  @override
  String get settingsSubtitleThemeTextColor => 'Text color';

  @override
  String get settingsSubtitleThemeTextOpacity => 'Text opacity';

  @override
  String get settingsSubtitleThemeBackgroundColor => 'Background color';

  @override
  String get settingsSubtitleThemeBackgroundOpacity => 'Background opacity';

  @override
  String get settingsSubtitleThemeTextAlignmentLeft => 'Left';

  @override
  String get settingsSubtitleThemeTextAlignmentCenter => 'Center';

  @override
  String get settingsSubtitleThemeTextAlignmentRight => 'Right';

  @override
  String get settingsPrivacySectionTitle => 'Privacy';

  @override
  String get settingsAllowInstalledAppAccess => 'Allow access to app inventory';

  @override
  String get settingsAllowInstalledAppAccessSubtitle => 'Used to improve album display';

  @override
  String get settingsAllowErrorReporting => 'Allow anonymous error reporting';

  @override
  String get settingsSaveSearchHistory => 'Save search history';

  @override
  String get settingsEnableBin => 'Use recycle bin';

  @override
  String get settingsEnableBinSubtitle => 'Keep deleted items for 30 days';

  @override
  String get settingsDisablingBinWarningDialogMessage => 'Items in the recycle bin will be deleted forever.';

  @override
  String get settingsAllowMediaManagement => 'Allow media management';

  @override
  String get settingsHiddenItemsTile => 'Hidden items';

  @override
  String get settingsHiddenItemsPageTitle => 'Hidden Items';

  @override
  String get settingsHiddenFiltersBanner => 'Photos and videos matching hidden filters will not appear in your collection.';

  @override
  String get settingsHiddenFiltersEmpty => 'No hidden filters';

  @override
  String get settingsStorageAccessTile => 'Storage access';

  @override
  String get settingsStorageAccessPageTitle => 'Storage Access';

  @override
  String get settingsStorageAccessBanner => 'Some directories require an explicit access grant to modify files in them. You can review here directories to which you previously gave access.';

  @override
  String get settingsStorageAccessEmpty => 'No access grants';

  @override
  String get settingsStorageAccessRevokeTooltip => 'Revoke';

  @override
  String get settingsAccessibilitySectionTitle => 'Accessibility';

  @override
  String get settingsRemoveAnimationsTile => 'Remove animations';

  @override
  String get settingsRemoveAnimationsDialogTitle => 'Remove Animations';

  @override
  String get settingsTimeToTakeActionTile => 'Time to take action';

  @override
  String get settingsAccessibilityShowPinchGestureAlternatives => 'Show multi-touch gesture alternatives';

  @override
  String get settingsDisplaySectionTitle => 'Display';

  @override
  String get settingsThemeBrightnessTile => 'Theme';

  @override
  String get settingsThemeBrightnessDialogTitle => 'Theme';

  @override
  String get settingsThemeColorHighlights => 'Color highlights';

  @override
  String get settingsThemeEnableDynamicColor => 'Dynamic color';

  @override
  String get settingsDisplayRefreshRateModeTile => 'Display refresh rate';

  @override
  String get settingsDisplayRefreshRateModeDialogTitle => 'Refresh Rate';

  @override
  String get settingsDisplayUseTvInterface => 'Android TV interface';

  @override
  String get settingsLanguageSectionTitle => 'Language & Formats';

  @override
  String get settingsLanguageTile => 'Language';

  @override
  String get settingsLanguagePageTitle => 'Language';

  @override
  String get settingsCoordinateFormatTile => 'Coordinate format';

  @override
  String get settingsCoordinateFormatDialogTitle => 'Coordinate Format';

  @override
  String get settingsUnitSystemTile => 'Units';

  @override
  String get settingsUnitSystemDialogTitle => 'Units';

  @override
  String get settingsForceWesternArabicNumeralsTile => 'Force Arabic numerals';

  @override
  String get settingsScreenSaverPageTitle => 'Screen Saver';

  @override
  String get settingsWidgetPageTitle => 'Photo Frame';

  @override
  String get settingsWidgetShowOutline => 'Outline';

  @override
  String get settingsWidgetOpenPage => 'When tapping on the widget';

  @override
  String get settingsWidgetDisplayedItem => 'Displayed item';

  @override
  String get settingsCollectionTile => 'Collection';

  @override
  String get statsPageTitle => 'Stats';

  @override
  String statsWithGps(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString items with location',
      one: '1 item with location',
    );
    return '$_temp0';
  }

  @override
  String get statsTopCountriesSectionTitle => 'Top Countries';

  @override
  String get statsTopStatesSectionTitle => 'Top States';

  @override
  String get statsTopPlacesSectionTitle => 'Top Places';

  @override
  String get statsTopTagsSectionTitle => 'Top Tags';

  @override
  String get statsTopAlbumsSectionTitle => 'Top Albums';

  @override
  String get viewerOpenPanoramaButtonLabel => 'OPEN PANORAMA';

  @override
  String get viewerSetWallpaperButtonLabel => 'SET WALLPAPER';

  @override
  String get viewerErrorUnknown => 'Oops!';

  @override
  String get viewerErrorDoesNotExist => 'The file no longer exists.';

  @override
  String get viewerInfoPageTitle => 'Info';

  @override
  String get viewerInfoBackToViewerTooltip => 'Back to viewer';

  @override
  String get viewerInfoUnknown => 'unknown';

  @override
  String get viewerInfoLabelDescription => 'Description';

  @override
  String get viewerInfoLabelTitle => 'Title';

  @override
  String get viewerInfoLabelDate => 'Date';

  @override
  String get viewerInfoLabelResolution => 'Resolution';

  @override
  String get viewerInfoLabelSize => 'Size';

  @override
  String get viewerInfoLabelUri => 'URI';

  @override
  String get viewerInfoLabelPath => 'Path';

  @override
  String get viewerInfoLabelDuration => 'Duration';

  @override
  String get viewerInfoLabelOwner => 'Owner';

  @override
  String get viewerInfoLabelCoordinates => 'Coordinates';

  @override
  String get viewerInfoLabelAddress => 'Address';

  @override
  String get mapStyleDialogTitle => 'Map Style';

  @override
  String get mapStyleTooltip => 'Select map style';

  @override
  String get mapZoomInTooltip => 'Zoom in';

  @override
  String get mapZoomOutTooltip => 'Zoom out';

  @override
  String get mapPointNorthUpTooltip => 'Point north up';

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
  String get openMapPageTooltip => 'View on Map page';

  @override
  String get mapEmptyRegion => 'No images in this region';

  @override
  String get viewerInfoOpenEmbeddedFailureFeedback => 'Failed to extract embedded data';

  @override
  String get viewerInfoOpenLinkText => 'Open';

  @override
  String get viewerInfoViewXmlLinkText => 'View XML';

  @override
  String get viewerInfoSearchFieldLabel => 'Search metadata';

  @override
  String get viewerInfoSearchEmpty => 'No matching keys';

  @override
  String get viewerInfoSearchSuggestionDate => 'Date & time';

  @override
  String get viewerInfoSearchSuggestionDescription => 'Description';

  @override
  String get viewerInfoSearchSuggestionDimensions => 'Dimensions';

  @override
  String get viewerInfoSearchSuggestionResolution => 'Resolution';

  @override
  String get viewerInfoSearchSuggestionRights => 'Rights';

  @override
  String get wallpaperUseScrollEffect => 'Use scroll effect on home screen';

  @override
  String get tagEditorPageTitle => 'Edit Tags';

  @override
  String get tagEditorPageNewTagFieldLabel => 'New tag';

  @override
  String get tagEditorPageAddTagTooltip => 'Add tag';

  @override
  String get tagEditorSectionRecent => 'Recent';

  @override
  String get tagEditorSectionPlaceholders => 'Placeholders';

  @override
  String get tagEditorDiscardDialogMessage => 'Do you want to discard changes?';

  @override
  String get tagPlaceholderCountry => 'Country';

  @override
  String get tagPlaceholderState => 'State';

  @override
  String get tagPlaceholderPlace => 'Place';

  @override
  String get panoramaEnableSensorControl => 'Enable sensor control';

  @override
  String get panoramaDisableSensorControl => 'Disable sensor control';

  @override
  String get sourceViewerPageTitle => 'Source';

  @override
  String get filePickerShowHiddenFiles => 'Show hidden files';

  @override
  String get filePickerDoNotShowHiddenFiles => 'Don’t show hidden files';

  @override
  String get filePickerOpenFrom => 'Open from';

  @override
  String get filePickerNoItems => 'No items';

  @override
  String get filePickerUseThisFolder => 'Use this folder';
}
