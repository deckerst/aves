// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Aves';

  @override
  String get welcomeMessage => 'Bienvenido a Aves';

  @override
  String get welcomeOptional => 'Opcional';

  @override
  String get welcomeTermsToggle => 'Acepto los términos y condiciones';

  @override
  String itemCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString elementos',
      one: '$countString elemento',
    );
    return '$_temp0';
  }

  @override
  String columnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count columnas',
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
  String get deleteButtonLabel => 'BORRAR';

  @override
  String get nextButtonLabel => 'SIGUIENTE';

  @override
  String get showButtonLabel => 'MOSTRAR';

  @override
  String get hideButtonLabel => 'OCULTAR';

  @override
  String get continueButtonLabel => 'CONTINUAR';

  @override
  String get saveCopyButtonLabel => 'GUARDAR UNA COPIA';

  @override
  String get applyTooltip => 'Aplicar';

  @override
  String get cancelTooltip => 'Cancelar';

  @override
  String get changeTooltip => 'Cambiar';

  @override
  String get clearTooltip => 'Limpiar';

  @override
  String get previousTooltip => 'Anterior';

  @override
  String get nextTooltip => 'Siguiente';

  @override
  String get showTooltip => 'Mostrar';

  @override
  String get hideTooltip => 'Ocultar';

  @override
  String get actionRemove => 'Remover';

  @override
  String get resetTooltip => 'Restablecer';

  @override
  String get saveTooltip => 'Guardar';

  @override
  String get stopTooltip => 'Parar';

  @override
  String get pickTooltip => 'Elegir';

  @override
  String get doubleBackExitMessage => 'Presione «atrás» nuevamente para salir.';

  @override
  String get doNotAskAgain => 'No preguntar nuevamente';

  @override
  String get sourceStateLoading => 'Cargando';

  @override
  String get sourceStateCataloguing => 'Catalogando';

  @override
  String get sourceStateLocatingCountries => 'Ubicando países';

  @override
  String get sourceStateLocatingPlaces => 'Ubicando lugares';

  @override
  String get chipActionDelete => 'Borrar';

  @override
  String get chipActionRemove => 'Remover';

  @override
  String get chipActionShowCollection => 'Mostrar en Colección';

  @override
  String get chipActionGoToAlbumPage => 'Mostrar en Álbumes';

  @override
  String get chipActionGoToCountryPage => 'Mostrar en Países';

  @override
  String get chipActionGoToPlacePage => 'Mostrar en lugares';

  @override
  String get chipActionGoToTagPage => 'Mostrar en Etiquetas';

  @override
  String get chipActionGoToExplorerPage => 'Mostrar en el explorador';

  @override
  String get chipActionDecompose => 'Separar';

  @override
  String get chipActionFilterOut => 'Filtrar';

  @override
  String get chipActionFilterIn => 'Filtrar en';

  @override
  String get chipActionHide => 'Esconder';

  @override
  String get chipActionLock => 'Bloquear';

  @override
  String get chipActionPin => 'Fijar';

  @override
  String get chipActionUnpin => 'Dejar de fijar';

  @override
  String get chipActionRename => 'Renombrar';

  @override
  String get chipActionSetCover => 'Elegir carátula';

  @override
  String get chipActionShowCountryStates => 'Mostrar los estados';

  @override
  String get chipActionCreateAlbum => 'Crear álbum';

  @override
  String get chipActionCreateVault => 'Crear una caja fuerte';

  @override
  String get chipActionConfigureVault => 'Configurar la caja fuerte';

  @override
  String get entryActionCopyToClipboard => 'Copiar al portapapeles';

  @override
  String get entryActionDelete => 'Borrar';

  @override
  String get entryActionConvert => 'Convertir';

  @override
  String get entryActionExport => 'Exportar';

  @override
  String get entryActionInfo => 'Información';

  @override
  String get entryActionRename => 'Renombrar';

  @override
  String get entryActionRestore => 'Restaurar';

  @override
  String get entryActionRotateCCW => 'Rotar en sentido antihorario';

  @override
  String get entryActionRotateCW => 'Rotar en sentido horario';

  @override
  String get entryActionFlip => 'Voltear horizontalmente';

  @override
  String get entryActionPrint => 'Imprimir';

  @override
  String get entryActionShare => 'Compartir';

  @override
  String get entryActionShareImageOnly => 'Compartir sólo la imagen';

  @override
  String get entryActionShareVideoOnly => 'Compartir sólo el vídeo';

  @override
  String get entryActionViewSource => 'Ver fuente';

  @override
  String get entryActionShowGeoTiffOnMap => 'Mostrar como mapa superpuesto';

  @override
  String get entryActionConvertMotionPhotoToStillImage => 'Convertir a imagen fija';

  @override
  String get entryActionViewMotionPhotoVideo => 'Abrir video';

  @override
  String get entryActionEdit => 'Editar';

  @override
  String get entryActionOpen => 'Abrir con';

  @override
  String get entryActionSetAs => 'Establecer como';

  @override
  String get entryActionCast => 'Echar';

  @override
  String get entryActionOpenMap => 'Mostrar en aplicación de mapa';

  @override
  String get entryActionRotateScreen => 'Rotar pantalla';

  @override
  String get entryActionAddFavourite => 'Agregar a favoritos';

  @override
  String get entryActionRemoveFavourite => 'Quitar de favoritos';

  @override
  String get videoActionCaptureFrame => 'Capturar fotograma';

  @override
  String get videoActionMute => 'Silenciar';

  @override
  String get videoActionUnmute => 'Dejar de silenciar';

  @override
  String get videoActionPause => 'Pausa';

  @override
  String get videoActionPlay => 'Reproducir';

  @override
  String get videoActionReplay10 => 'Retroceder 10 segundos';

  @override
  String get videoActionSkip10 => 'Adelantar 10 segundos';

  @override
  String get videoActionShowPreviousFrame => 'Mostrar fotograma anterior';

  @override
  String get videoActionShowNextFrame => 'Mostrar fotograma siguiente';

  @override
  String get videoActionSelectStreams => 'Seleccionar pistas';

  @override
  String get videoActionSetSpeed => 'Velocidad de reproducción';

  @override
  String get videoActionABRepeat => 'Repetir de A a B';

  @override
  String get videoRepeatActionSetStart => 'Fijar el inicio';

  @override
  String get videoRepeatActionSetEnd => 'Fijar el fin';

  @override
  String get viewerActionSettings => 'Ajustes';

  @override
  String get viewerActionLock => 'Bloquear visor';

  @override
  String get viewerActionUnlock => 'Desbloquear visor';

  @override
  String get slideshowActionResume => 'Reanudar';

  @override
  String get slideshowActionShowInCollection => 'Mostrar en Colección';

  @override
  String get entryInfoActionEditDate => 'Editar fecha y hora';

  @override
  String get entryInfoActionEditLocation => 'Editar ubicación';

  @override
  String get entryInfoActionEditTitleDescription => 'Editar título y descripción';

  @override
  String get entryInfoActionEditRating => 'Editar clasificación';

  @override
  String get entryInfoActionEditTags => 'Editar etiquetas';

  @override
  String get entryInfoActionRemoveMetadata => 'Eliminar metadatos';

  @override
  String get entryInfoActionExportMetadata => 'Exportar los metadatos';

  @override
  String get entryInfoActionRemoveLocation => 'Eliminar la ubicación';

  @override
  String get editorActionTransform => 'Transformar';

  @override
  String get editorTransformCrop => 'Recortar';

  @override
  String get editorTransformRotate => 'Girar';

  @override
  String get cropAspectRatioFree => 'Libre';

  @override
  String get cropAspectRatioOriginal => 'Original';

  @override
  String get cropAspectRatioSquare => 'Cuadrado';

  @override
  String get filterAspectRatioLandscapeLabel => 'Paisaje';

  @override
  String get filterAspectRatioPortraitLabel => 'Retrato';

  @override
  String get filterBinLabel => 'Cesto de basura';

  @override
  String get filterFavouriteLabel => 'Favorito';

  @override
  String get filterNoDateLabel => 'Sin fecha';

  @override
  String get filterNoAddressLabel => 'Sin dirección';

  @override
  String get filterLocatedLabel => 'Localizado';

  @override
  String get filterNoLocationLabel => 'No localizado';

  @override
  String get filterNoRatingLabel => 'Sin clasificar';

  @override
  String get filterTaggedLabel => 'Etiquetado';

  @override
  String get filterNoTagLabel => 'Sin etiquetar';

  @override
  String get filterNoTitleLabel => 'Sin título';

  @override
  String get filterOnThisDayLabel => 'De este día';

  @override
  String get filterRecentlyAddedLabel => 'Recientemente añadido';

  @override
  String get filterRatingRejectedLabel => 'Rechazado';

  @override
  String get filterTypeAnimatedLabel => 'Animado';

  @override
  String get filterTypeMotionPhotoLabel => 'Foto en movimiento';

  @override
  String get filterTypePanoramaLabel => 'Panorámica';

  @override
  String get filterTypeRawLabel => 'Raw';

  @override
  String get filterTypeSphericalVideoLabel => 'Video en 360°';

  @override
  String get filterTypeGeotiffLabel => 'GeoTIFF';

  @override
  String get filterMimeImageLabel => 'Imagen';

  @override
  String get filterMimeVideoLabel => 'Video';

  @override
  String get accessibilityAnimationsRemove => 'Prevenir efectos en pantalla';

  @override
  String get accessibilityAnimationsKeep => 'Mantener efectos en pantalla';

  @override
  String get albumTierNew => 'Nuevo';

  @override
  String get albumTierPinned => 'Fijado';

  @override
  String get albumTierSpecial => 'Común';

  @override
  String get albumTierApps => 'Aplicaciones';

  @override
  String get albumTierVaults => 'Caja fuerte';

  @override
  String get albumTierDynamic => 'Dinámico';

  @override
  String get albumTierRegular => 'Otros';

  @override
  String get coordinateFormatDms => 'GMS';

  @override
  String get coordinateFormatDdm => 'DDM';

  @override
  String get coordinateFormatDecimal => 'Grados decimales';

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
  String get displayRefreshRatePreferHighest => 'Alta tasa';

  @override
  String get displayRefreshRatePreferLowest => 'Baja tasa';

  @override
  String get keepScreenOnNever => 'Nunca';

  @override
  String get keepScreenOnVideoPlayback => 'Durante la reproducción de vídeo';

  @override
  String get keepScreenOnViewerOnly => 'Sólo en el visor';

  @override
  String get keepScreenOnAlways => 'Siempre';

  @override
  String get lengthUnitPixel => 'px';

  @override
  String get lengthUnitPercent => '%';

  @override
  String get mapStyleGoogleNormal => 'Google Maps';

  @override
  String get mapStyleGoogleHybrid => 'Google Maps (Híbrido)';

  @override
  String get mapStyleGoogleTerrain => 'Google Maps (Relieve)';

  @override
  String get mapStyleOsmLiberty => 'OSM Liberty';

  @override
  String get mapStyleOpenTopoMap => 'OpenTopoMap';

  @override
  String get mapStyleOsmHot => 'OSM Humanitario';

  @override
  String get mapStyleStamenWatercolor => 'Stamen Watercolor (Acuarela)';

  @override
  String get maxBrightnessNever => 'Nunca';

  @override
  String get maxBrightnessAlways => 'Siempre';

  @override
  String get nameConflictStrategyRename => 'Renombrar';

  @override
  String get nameConflictStrategyReplace => 'Reemplazar';

  @override
  String get nameConflictStrategySkip => 'Saltear';

  @override
  String get overlayHistogramNone => 'Ninguna';

  @override
  String get overlayHistogramRGB => 'RGB';

  @override
  String get overlayHistogramLuminance => 'Luminancia';

  @override
  String get subtitlePositionTop => 'Parte superior';

  @override
  String get subtitlePositionBottom => 'Inferior';

  @override
  String get themeBrightnessLight => 'Claro';

  @override
  String get themeBrightnessDark => 'Obscuro';

  @override
  String get themeBrightnessBlack => 'Negro';

  @override
  String get unitSystemMetric => 'Métrico';

  @override
  String get unitSystemImperial => 'Imperial';

  @override
  String get vaultLockTypePattern => 'Patrón';

  @override
  String get vaultLockTypePin => 'Pin';

  @override
  String get vaultLockTypePassword => 'Contraseña';

  @override
  String get settingsVideoEnablePip => 'Imagen-en-imagen';

  @override
  String get videoControlsPlayOutside => 'Reproducir externamente';

  @override
  String get videoLoopModeNever => 'Nunca';

  @override
  String get videoLoopModeShortOnly => 'Sólo videos cortos';

  @override
  String get videoLoopModeAlways => 'Siempre';

  @override
  String get videoPlaybackSkip => 'Saltear';

  @override
  String get videoPlaybackMuted => 'Reproducir sin sonido';

  @override
  String get videoPlaybackWithSound => 'Reproducir con sonido';

  @override
  String get videoResumptionModeNever => 'Nunca';

  @override
  String get videoResumptionModeAlways => 'Siempre';

  @override
  String get viewerTransitionSlide => 'Diapositiva';

  @override
  String get viewerTransitionParallax => 'Paralaje';

  @override
  String get viewerTransitionFade => 'Desvanecer';

  @override
  String get viewerTransitionZoomIn => 'Acercar';

  @override
  String get viewerTransitionNone => 'Ninguno';

  @override
  String get wallpaperTargetHome => 'Pantalla de inicio';

  @override
  String get wallpaperTargetLock => 'Pantalla de bloqueo';

  @override
  String get wallpaperTargetHomeLock => 'Pantallas de inicio y bloqueo';

  @override
  String get widgetDisplayedItemRandom => 'Aleatorio';

  @override
  String get widgetDisplayedItemMostRecent => 'Más reciente';

  @override
  String get widgetOpenPageHome => 'Abrir la pantalla de inicio';

  @override
  String get widgetOpenPageCollection => 'Abrir colección';

  @override
  String get widgetOpenPageViewer => 'Abrir el visor';

  @override
  String get widgetTapUpdateWidget => 'Actualizar el widget';

  @override
  String get storageVolumeDescriptionFallbackPrimary => 'Almacenamiento interno';

  @override
  String get storageVolumeDescriptionFallbackNonPrimary => 'Tarjeta de memoria';

  @override
  String get rootDirectoryDescription => 'el directorio raíz';

  @override
  String otherDirectoryDescription(String name) {
    return 'el directorio «$name»';
  }

  @override
  String storageAccessDialogMessage(String directory, String volume) {
    return 'Por favor seleccione $directory en «$volume» en la siguiente pantalla para permitir a esta aplicación tener acceso.';
  }

  @override
  String restrictedAccessDialogMessage(String directory, String volume) {
    return 'Esta aplicación no tiene permiso para modificar archivos de $directory en «$volume».\n\nPor favor use un gestor de archivos o la aplicación de galería preinstalada para mover los elementos a otro directorio.';
  }

  @override
  String notEnoughSpaceDialogMessage(String neededSize, String freeSize, String volume) {
    return 'Esta operación necesita $neededSize de espacio libre en «$volume» para completarse, pero sólo hay $freeSize disponible.';
  }

  @override
  String get missingSystemFilePickerDialogMessage => 'El selector de archivos del sistema no se encuentra disponible o fue deshabilitado. Por favor habilítelo e intente nuevamente.';

  @override
  String unsupportedTypeDialogMessage(int count, String types) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Esta operación no está disponible para elementos de los siguientes tipos: $types.',
      one: 'Esta operación no está disponible para un elemento del siguiente tipo: $types.',
    );
    return '$_temp0';
  }

  @override
  String get nameConflictDialogSingleSourceMessage => 'Algunos archivos en el directorio de destino tienen el mismo nombre.';

  @override
  String get nameConflictDialogMultipleSourceMessage => 'Algunos archivos tienen el mismo nombre.';

  @override
  String get addShortcutDialogLabel => 'Etiqueta del atajo';

  @override
  String get addShortcutButtonLabel => 'AGREGAR';

  @override
  String get noMatchingAppDialogMessage => 'No se encontraron aplicaciones para manejar esto.';

  @override
  String binEntriesConfirmationDialogMessage(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '¿Mover estos $countString elementos al cesto de basura?',
      one: '¿Mover este elemento al cesto de basura?',
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
      other: '¿Está seguro de querer borrar $countString elementos?',
      one: '¿Está seguro de borrar este elemento?',
    );
    return '$_temp0';
  }

  @override
  String get moveUndatedConfirmationDialogMessage => '¿Guardar las fechas de los elementos antes de proceder?';

  @override
  String get moveUndatedConfirmationDialogSetDate => 'Fijar fecha';

  @override
  String videoResumeDialogMessage(String time) {
    return '¿Desea reanudar la reproducción a las $time?';
  }

  @override
  String get videoStartOverButtonLabel => 'VOLVER A EMPEZAR';

  @override
  String get videoResumeButtonLabel => 'REANUDAR';

  @override
  String get setCoverDialogLatest => 'Elemento más reciente';

  @override
  String get setCoverDialogAuto => 'Automático';

  @override
  String get setCoverDialogCustom => 'Personalizado';

  @override
  String get hideFilterConfirmationDialogMessage => 'Fotos y videos que concuerden serán ocultados de su colección. Puede volver a mostrarlos desde los ajustes de «Privacidad».\n\n¿Está seguro de que desea ocultarlos?';

  @override
  String get newAlbumDialogTitle => 'Álbum nuevo';

  @override
  String get newAlbumDialogNameLabel => 'Nombre del álbum';

  @override
  String get newAlbumDialogAlbumAlreadyExistsHelper => 'El álbum ya existe';

  @override
  String get newAlbumDialogNameLabelAlreadyExistsHelper => 'El directorio ya existe';

  @override
  String get newAlbumDialogStorageLabel => 'Almacenamiento:';

  @override
  String get newDynamicAlbumDialogTitle => 'Nuevo álbum dinámico';

  @override
  String get dynamicAlbumAlreadyExists => 'El álbum dinámico ya existe';

  @override
  String get newVaultWarningDialogMessage => 'Los elementos de la caja fuerte sólo están disponibles para esta aplicación y no para otras.\n\nSi desinstalas esta aplicación o borras sus datos, perderás todos estos elementos.';

  @override
  String get newVaultDialogTitle => 'Nueva caja fuerte';

  @override
  String get configureVaultDialogTitle => 'Configurar la caja fuerte';

  @override
  String get vaultDialogLockModeWhenScreenOff => 'Bloquear al apagar la pantalla';

  @override
  String get vaultDialogLockTypeLabel => 'Tipo de bloqueo';

  @override
  String get patternDialogEnter => 'Introduzca el patrón';

  @override
  String get patternDialogConfirm => 'Confirme el patrón';

  @override
  String get pinDialogEnter => 'Introducir el código pin';

  @override
  String get pinDialogConfirm => 'Confirmar el código pin';

  @override
  String get passwordDialogEnter => 'Introducir la contraseña';

  @override
  String get passwordDialogConfirm => 'Confirmar la contraseña';

  @override
  String get authenticateToConfigureVault => 'Autenticarse para configurar la caja fuerte';

  @override
  String get authenticateToUnlockVault => 'Autentificarse para desbloquear la caja fuerte';

  @override
  String get vaultBinUsageDialogMessage => 'Algunas cajas fuertes utilizan la papelera de reciclaje.';

  @override
  String get renameAlbumDialogLabel => 'Renombrar';

  @override
  String get renameAlbumDialogLabelAlreadyExistsHelper => 'El directorio ya existe';

  @override
  String get renameEntrySetPageTitle => 'Renombrar';

  @override
  String get renameEntrySetPagePatternFieldLabel => 'Patrón de nombramiento';

  @override
  String get renameEntrySetPageInsertTooltip => 'Insertar campo';

  @override
  String get renameEntrySetPagePreviewSectionTitle => 'Vista previa';

  @override
  String get renameProcessorCounter => 'Contador';

  @override
  String get renameProcessorHash => 'Hash';

  @override
  String get renameProcessorName => 'Nombre';

  @override
  String deleteSingleAlbumConfirmationDialogMessage(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '¿Eliminar este álbum y los $countString elementos que contiene?',
      one: '¿Eliminar este álbum y el elemento que contiene?',
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
      other: '¿Eliminar estos álbumes y los $countString elementos que contienen?',
      one: '¿Eliminar estos álbumes y el elemento que contienen?',
    );
    return '$_temp0';
  }

  @override
  String get exportEntryDialogFormat => 'Formato:';

  @override
  String get exportEntryDialogWidth => 'Anchura';

  @override
  String get exportEntryDialogHeight => 'Altura';

  @override
  String get exportEntryDialogQuality => 'Calidad';

  @override
  String get exportEntryDialogWriteMetadata => 'Escribir metadatos';

  @override
  String get renameEntryDialogLabel => 'Renombrar';

  @override
  String get editEntryDialogCopyFromItem => 'Copiar de otro elemento';

  @override
  String get editEntryDialogTargetFieldsHeader => 'Campos a modificar';

  @override
  String get editEntryDateDialogTitle => 'Fecha y hora';

  @override
  String get editEntryDateDialogSetCustom => 'Establecer fecha personalizada';

  @override
  String get editEntryDateDialogCopyField => 'Copiar de otra fecha';

  @override
  String get editEntryDateDialogExtractFromTitle => 'Extraer del título';

  @override
  String get editEntryDateDialogShift => 'Cambiar';

  @override
  String get editEntryDateDialogSourceFileModifiedDate => 'Fecha de modificación del archivo';

  @override
  String get durationDialogHours => 'Horas';

  @override
  String get durationDialogMinutes => 'Minutos';

  @override
  String get durationDialogSeconds => 'Segundos';

  @override
  String get editEntryLocationDialogTitle => 'Ubicación';

  @override
  String get editEntryLocationDialogSetCustom => 'Establecer la ubicación personalizada';

  @override
  String get editEntryLocationDialogChooseOnMap => 'Elegir en el mapa';

  @override
  String get editEntryLocationDialogImportGpx => 'Importar GPX';

  @override
  String get editEntryLocationDialogLatitude => 'Latitud';

  @override
  String get editEntryLocationDialogLongitude => 'Longitud';

  @override
  String get editEntryLocationDialogTimeShift => 'Desplazamiento de tiempo';

  @override
  String get locationPickerUseThisLocationButton => 'Usar esta ubicación';

  @override
  String get editEntryRatingDialogTitle => 'Clasificación';

  @override
  String get removeEntryMetadataDialogTitle => 'Eliminación de metadatos';

  @override
  String get removeEntryMetadataDialogAll => 'Todo';

  @override
  String get removeEntryMetadataDialogMore => 'Más';

  @override
  String get removeEntryMetadataMotionPhotoXmpWarningDialogMessage => 'XMP es necesario para reproducir la animación de una foto en movimiento.\n\n¿Está seguro de que desea removerlo?';

  @override
  String get videoSpeedDialogLabel => 'Velocidad de reproducción';

  @override
  String get videoStreamSelectionDialogVideo => 'Video';

  @override
  String get videoStreamSelectionDialogAudio => 'Audio';

  @override
  String get videoStreamSelectionDialogText => 'Subtítulos';

  @override
  String get videoStreamSelectionDialogOff => 'Desactivado';

  @override
  String get videoStreamSelectionDialogTrack => 'Pista';

  @override
  String get videoStreamSelectionDialogNoSelection => 'No hay otras pistas.';

  @override
  String get genericSuccessFeedback => '¡Completado!';

  @override
  String get genericFailureFeedback => 'Falló';

  @override
  String get genericDangerWarningDialogMessage => '¿Está seguro?';

  @override
  String get tooManyItemsErrorDialogMessage => 'Vuelva a intentarlo con menos elementos.';

  @override
  String get menuActionConfigureView => 'Ver';

  @override
  String get menuActionSelect => 'Seleccionar';

  @override
  String get menuActionSelectAll => 'Seleccionar todo';

  @override
  String get menuActionSelectNone => 'Deseleccionar';

  @override
  String get menuActionMap => 'Mapa';

  @override
  String get menuActionSlideshow => 'Presentación';

  @override
  String get menuActionStats => 'Estadísticas';

  @override
  String get viewDialogSortSectionTitle => 'Ordenar';

  @override
  String get viewDialogGroupSectionTitle => 'Grupo';

  @override
  String get viewDialogLayoutSectionTitle => 'Disposición';

  @override
  String get viewDialogReverseSortOrder => 'Invertir la forma de ordenar';

  @override
  String get tileLayoutMosaic => 'Mosaico';

  @override
  String get tileLayoutGrid => 'Cuadrícula';

  @override
  String get tileLayoutList => 'Lista';

  @override
  String get castDialogTitle => 'Dispositivos Cast';

  @override
  String get coverDialogTabCover => 'Carátula';

  @override
  String get coverDialogTabApp => 'Aplicación';

  @override
  String get coverDialogTabColor => 'Color';

  @override
  String get appPickDialogTitle => 'Escoger aplicación';

  @override
  String get appPickDialogNone => 'Ninguna';

  @override
  String get aboutPageTitle => 'Acerca de';

  @override
  String get aboutLinkLicense => 'Licencia';

  @override
  String get aboutLinkPolicy => 'Política de privacidad';

  @override
  String get aboutBugSectionTitle => 'Reporte de errores';

  @override
  String get aboutBugSaveLogInstruction => 'Guardar registros de la aplicación a un archivo';

  @override
  String get aboutBugCopyInfoInstruction => 'Copiar información del sistema';

  @override
  String get aboutBugCopyInfoButton => 'Copiar';

  @override
  String get aboutBugReportInstruction => 'Reportar en GitHub con los registros y la información del sistema';

  @override
  String get aboutBugReportButton => 'Reportar';

  @override
  String get aboutDataUsageSectionTitle => 'Uso de los datos';

  @override
  String get aboutDataUsageData => 'Datos';

  @override
  String get aboutDataUsageCache => 'Cache';

  @override
  String get aboutDataUsageDatabase => 'Base de datos';

  @override
  String get aboutDataUsageMisc => 'Varios';

  @override
  String get aboutDataUsageInternal => 'Interno';

  @override
  String get aboutDataUsageExternal => 'Exterior';

  @override
  String get aboutDataUsageClearCache => 'Borrar la cache';

  @override
  String get aboutCreditsSectionTitle => 'Créditos';

  @override
  String get aboutCreditsWorldAtlas1 => 'Esta aplicación usa un archivo TopoJSON de';

  @override
  String get aboutCreditsWorldAtlas2 => 'bajo licencia ISC.';

  @override
  String get aboutTranslatorsSectionTitle => 'Traductores';

  @override
  String get aboutLicensesSectionTitle => 'Licencias de código abierto';

  @override
  String get aboutLicensesBanner => 'Esta aplicación usa los siguientes paquetes y librerías de código abierto.';

  @override
  String get aboutLicensesAndroidLibrariesSectionTitle => 'Librerías de Android';

  @override
  String get aboutLicensesFlutterPluginsSectionTitle => 'Añadidos de Flutter';

  @override
  String get aboutLicensesFlutterPackagesSectionTitle => 'Paquetes de Flutter';

  @override
  String get aboutLicensesDartPackagesSectionTitle => 'Paquetes de Dart';

  @override
  String get aboutLicensesShowAllButtonLabel => 'Mostrar todas las licencias';

  @override
  String get policyPageTitle => 'Política de privacidad';

  @override
  String get collectionPageTitle => 'Colección';

  @override
  String get collectionPickPageTitle => 'Elegir';

  @override
  String get collectionSelectPageTitle => 'Seleccionar';

  @override
  String get collectionActionShowTitleSearch => 'Mostrar filtros de títulos';

  @override
  String get collectionActionHideTitleSearch => 'Ocultar filtros de títulos';

  @override
  String get collectionActionAddDynamicAlbum => 'Añadir álbum dinámico';

  @override
  String get collectionActionAddShortcut => 'Agregar atajo';

  @override
  String get collectionActionSetHome => 'Fijar como inicio';

  @override
  String get collectionActionEmptyBin => 'Vaciar cesto';

  @override
  String get collectionActionCopy => 'Copiar a álbum';

  @override
  String get collectionActionMove => 'Mover a álbum';

  @override
  String get collectionActionRescan => 'Volver a buscar';

  @override
  String get collectionActionEdit => 'Editar';

  @override
  String get collectionSearchTitlesHintText => 'Buscar títulos';

  @override
  String get collectionGroupAlbum => 'Por álbum';

  @override
  String get collectionGroupMonth => 'Por mes';

  @override
  String get collectionGroupDay => 'Por día';

  @override
  String get collectionGroupNone => 'No agrupar';

  @override
  String get sectionUnknown => 'Desconocido';

  @override
  String get dateToday => 'Hoy';

  @override
  String get dateYesterday => 'Ayer';

  @override
  String get dateThisMonth => 'Este mes';

  @override
  String collectionDeleteFailureFeedback(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Error al borrar $countString elementos',
      one: 'Error al borrar 1 elemento',
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
      other: 'Error al copiar $countString elementos',
      one: 'Error al copiar 1 item',
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
      other: 'Error al mover $countString elementos',
      one: 'Error al mover 1 elemento',
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
      other: 'Error al renombrar $countString elementos',
      one: 'Error al renombrar 1 elemento',
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
      other: 'Error al editar $countString elementos',
      one: 'Error al editar 1 elemento',
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
      other: 'Error al exportar $countString páginas',
      one: 'Error al exportar 1 página',
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
      other: 'Copiados$countString elementos',
      one: '1 elemento copiado',
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
      one: '1 elemento movido',
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
      other: 'Renombrados $countString elementos',
      one: '1 elemento renombrado',
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
      one: '1 elemento editado',
    );
    return '$_temp0';
  }

  @override
  String get collectionEmptyFavourites => 'Sin favoritos';

  @override
  String get collectionEmptyVideos => 'Sin videos';

  @override
  String get collectionEmptyImages => 'Sin imágenes';

  @override
  String get collectionEmptyGrantAccessButtonLabel => 'Otorgar accceso';

  @override
  String get collectionSelectSectionTooltip => 'Seleccionar sección';

  @override
  String get collectionDeselectSectionTooltip => 'Deseleccionar sección';

  @override
  String get drawerAboutButton => 'Acerca de';

  @override
  String get drawerSettingsButton => 'Ajustes';

  @override
  String get drawerCollectionAll => 'Toda la colección';

  @override
  String get drawerCollectionFavourites => 'Favoritos';

  @override
  String get drawerCollectionImages => 'Imágenes';

  @override
  String get drawerCollectionVideos => 'Vídeos';

  @override
  String get drawerCollectionAnimated => 'Animaciones';

  @override
  String get drawerCollectionMotionPhotos => 'Fotos en movimiento';

  @override
  String get drawerCollectionPanoramas => 'Panorámicas';

  @override
  String get drawerCollectionRaws => 'Fotos Raw';

  @override
  String get drawerCollectionSphericalVideos => 'Videos en 360°';

  @override
  String get drawerAlbumPage => 'Álbumes';

  @override
  String get drawerCountryPage => 'Países';

  @override
  String get drawerPlacePage => 'Lugares';

  @override
  String get drawerTagPage => 'Etiquetas';

  @override
  String get sortByDate => 'Por fecha';

  @override
  String get sortByName => 'Por nombre';

  @override
  String get sortByItemCount => 'Por número de elementos';

  @override
  String get sortBySize => 'Por tamaño';

  @override
  String get sortByAlbumFileName => 'Por nombre de álbum y archivo';

  @override
  String get sortByRating => 'Por clasificación';

  @override
  String get sortByDuration => 'Por duración';

  @override
  String get sortByPath => 'By path';

  @override
  String get sortOrderNewestFirst => 'El más nuevo primero';

  @override
  String get sortOrderOldestFirst => 'El más viejo primero';

  @override
  String get sortOrderAtoZ => 'De la A a la Z';

  @override
  String get sortOrderZtoA => 'De la Z a la A';

  @override
  String get sortOrderHighestFirst => 'El más alto primero';

  @override
  String get sortOrderLowestFirst => 'El más bajo primero';

  @override
  String get sortOrderLargestFirst => 'El más grande primero';

  @override
  String get sortOrderSmallestFirst => 'El más pequeño primero';

  @override
  String get sortOrderShortestFirst => 'El más corto primero';

  @override
  String get sortOrderLongestFirst => 'El más largo primero';

  @override
  String get albumGroupTier => 'Por nivel';

  @override
  String get albumGroupType => 'Por tipo';

  @override
  String get albumGroupVolume => 'Por volumen de almacenamiento';

  @override
  String get albumGroupNone => 'No agrupar';

  @override
  String get albumMimeTypeMixed => 'Mezclado';

  @override
  String get albumPickPageTitleCopy => 'Copiar a álbum';

  @override
  String get albumPickPageTitleExport => 'Exportar a álbum';

  @override
  String get albumPickPageTitleMove => 'Mover a álbum';

  @override
  String get albumPickPageTitlePick => 'Elegir álbum';

  @override
  String get albumCamera => 'Cámara';

  @override
  String get albumDownload => 'Descargas';

  @override
  String get albumScreenshots => 'Capturas de pantalla';

  @override
  String get albumScreenRecordings => 'Grabaciones de pantalla';

  @override
  String get albumVideoCaptures => 'Capturas en video';

  @override
  String get albumPageTitle => 'Álbumes';

  @override
  String get albumEmpty => 'Sin álbumes';

  @override
  String get createAlbumButtonLabel => 'CREAR';

  @override
  String get newFilterBanner => 'nuevo';

  @override
  String get countryPageTitle => 'Países';

  @override
  String get countryEmpty => 'Sin países';

  @override
  String get statePageTitle => 'Estados';

  @override
  String get stateEmpty => 'Sin estados';

  @override
  String get placePageTitle => 'Lugares';

  @override
  String get placeEmpty => 'Ningún lugar';

  @override
  String get tagPageTitle => 'Etiquetas';

  @override
  String get tagEmpty => 'Sin etiquetas';

  @override
  String get binPageTitle => 'Cesto de basura';

  @override
  String get explorerPageTitle => 'Explorar';

  @override
  String get explorerActionSelectStorageVolume => 'Seleccionar almacenamiento';

  @override
  String get selectStorageVolumeDialogTitle => 'Seleccionar almacenamiento';

  @override
  String get searchCollectionFieldHint => 'Buscar en colección';

  @override
  String get searchRecentSectionTitle => 'Reciente';

  @override
  String get searchDateSectionTitle => 'Fecha';

  @override
  String get searchFormatSectionTitle => 'Formats';

  @override
  String get searchAlbumsSectionTitle => 'Álbumes';

  @override
  String get searchCountriesSectionTitle => 'Países';

  @override
  String get searchStatesSectionTitle => 'Estados';

  @override
  String get searchPlacesSectionTitle => 'Lugares';

  @override
  String get searchTagsSectionTitle => 'Etiquetas';

  @override
  String get searchRatingSectionTitle => 'Clasificaciones';

  @override
  String get searchMetadataSectionTitle => 'Metadatos';

  @override
  String get settingsPageTitle => 'Ajustes';

  @override
  String get settingsSystemDefault => 'Sistema';

  @override
  String get settingsDefault => 'Restablecer';

  @override
  String get settingsDisabled => 'Desactivado';

  @override
  String get settingsAskEverytime => 'Pregunta cuando quieras';

  @override
  String get settingsModificationWarningDialogMessage => 'Otras configuraciones serán modificadas.';

  @override
  String get settingsSearchFieldLabel => 'Buscar ajustes';

  @override
  String get settingsSearchEmpty => 'Sin coincidencias';

  @override
  String get settingsActionExport => 'Exportar';

  @override
  String get settingsActionExportDialogTitle => 'Exportar';

  @override
  String get settingsActionImport => 'Importar';

  @override
  String get settingsActionImportDialogTitle => 'Importar';

  @override
  String get appExportCovers => 'Carátulas';

  @override
  String get appExportDynamicAlbums => 'Álbumes dinámicos';

  @override
  String get appExportFavourites => 'Favoritos';

  @override
  String get appExportSettings => 'Ajustes';

  @override
  String get settingsNavigationSectionTitle => 'Navegación';

  @override
  String get settingsHomeTile => 'Inicio';

  @override
  String get settingsHomeDialogTitle => 'Inicio';

  @override
  String get setHomeCustom => 'Personalizado';

  @override
  String get settingsShowBottomNavigationBar => 'Mostrar barra de navegación inferior';

  @override
  String get settingsKeepScreenOnTile => 'Mantener la pantalla encendida';

  @override
  String get settingsKeepScreenOnDialogTitle => 'Mantener la pantalla encendida';

  @override
  String get settingsDoubleBackExit => 'Presione «atrás» dos veces para salir';

  @override
  String get settingsConfirmationTile => 'Diálogos de confirmación';

  @override
  String get settingsConfirmationDialogTitle => 'Diálogos de confirmación';

  @override
  String get settingsConfirmationBeforeDeleteItems => 'Preguntar antes de eliminar elementos permanentemente';

  @override
  String get settingsConfirmationBeforeMoveToBinItems => 'Preguntar antes de mover elementos al cesto de basura';

  @override
  String get settingsConfirmationBeforeMoveUndatedItems => 'Preguntar antes de mover elementos sin una fecha de metadatos';

  @override
  String get settingsConfirmationAfterMoveToBinItems => 'Mostrar mensaje después de mover elementos a la papelera de reciclaje';

  @override
  String get settingsConfirmationVaultDataLoss => 'Mostrar un aviso de pérdida de datos de la caja fuerte';

  @override
  String get settingsNavigationDrawerTile => 'Menú de navegación';

  @override
  String get settingsNavigationDrawerEditorPageTitle => 'Menú de navegación';

  @override
  String get settingsNavigationDrawerBanner => 'Toque y mantenga para mover y reordenar elementos del menú.';

  @override
  String get settingsNavigationDrawerTabTypes => 'Tipos';

  @override
  String get settingsNavigationDrawerTabAlbums => 'Álbumes';

  @override
  String get settingsNavigationDrawerTabPages => 'Páginas';

  @override
  String get settingsNavigationDrawerAddAlbum => 'Agregar álbum';

  @override
  String get settingsThumbnailSectionTitle => 'Miniaturas';

  @override
  String get settingsThumbnailOverlayTile => 'Incrustaciones';

  @override
  String get settingsThumbnailOverlayPageTitle => 'Incrustaciones';

  @override
  String get settingsThumbnailShowHdrIcon => 'Mostrar el icono del HDR';

  @override
  String get settingsThumbnailShowFavouriteIcon => 'Mostrar icono de favoritos';

  @override
  String get settingsThumbnailShowTagIcon => 'Mostrar ícono de etiqueta';

  @override
  String get settingsThumbnailShowLocationIcon => 'Mostrar icono de ubicación';

  @override
  String get settingsThumbnailShowMotionPhotoIcon => 'Mostrar icono de foto en movimiento';

  @override
  String get settingsThumbnailShowRating => 'Mostrar clasificación';

  @override
  String get settingsThumbnailShowRawIcon => 'Mostrar icono Raw';

  @override
  String get settingsThumbnailShowVideoDuration => 'Mostrar duración de video';

  @override
  String get settingsCollectionQuickActionsTile => 'Acciones rápidas';

  @override
  String get settingsCollectionQuickActionEditorPageTitle => 'Acciones rápidas';

  @override
  String get settingsCollectionQuickActionTabBrowsing => 'Búsqueda';

  @override
  String get settingsCollectionQuickActionTabSelecting => 'Selección';

  @override
  String get settingsCollectionBrowsingQuickActionEditorBanner => 'Toque y mantenga para mover botones y seleccionar cuáles acciones se muestran mientras busca elementos.';

  @override
  String get settingsCollectionSelectionQuickActionEditorBanner => 'Toque y mantenga para mover botones y seleccionar cuáles acciones se muestran mientras selecciona elementos.';

  @override
  String get settingsCollectionBurstPatternsTile => 'Modelos de ráfaga';

  @override
  String get settingsCollectionBurstPatternsNone => 'Ninguno';

  @override
  String get settingsViewerSectionTitle => 'Visor';

  @override
  String get settingsViewerGestureSideTapNext => 'Toque en los bordes de la pantalla para mostrar el elemento anterior/siguiente';

  @override
  String get settingsViewerUseCutout => 'Usar área recortada';

  @override
  String get settingsViewerMaximumBrightness => 'Brillo máximo';

  @override
  String get settingsMotionPhotoAutoPlay => 'Reproducir automáticamente fotos en movimiento';

  @override
  String get settingsImageBackground => 'Imagen de fondo';

  @override
  String get settingsViewerQuickActionsTile => 'Acciones rápidas';

  @override
  String get settingsViewerQuickActionEditorPageTitle => 'Acciones rápidas';

  @override
  String get settingsViewerQuickActionEditorBanner => 'Toque y mantenga para mover botones y seleccionar cuáles acciones se muestran en el visor.';

  @override
  String get settingsViewerQuickActionEditorDisplayedButtonsSectionTitle => 'Botones mostrados';

  @override
  String get settingsViewerQuickActionEditorAvailableButtonsSectionTitle => 'Botones disponibles';

  @override
  String get settingsViewerQuickActionEmpty => 'Sin botones';

  @override
  String get settingsViewerOverlayTile => 'Incrustaciones';

  @override
  String get settingsViewerOverlayPageTitle => 'Incrustaciones';

  @override
  String get settingsViewerShowOverlayOnOpening => 'Mostrar durante apertura';

  @override
  String get settingsViewerShowHistogram => 'Mostrar el histograma';

  @override
  String get settingsViewerShowMinimap => 'Mostrar mapa en miniatura';

  @override
  String get settingsViewerShowInformation => 'Mostrar información';

  @override
  String get settingsViewerShowInformationSubtitle => 'Mostrar título, fecha, ubicación, etc.';

  @override
  String get settingsViewerShowRatingTags => 'Mostrar la valoración y las etiquetas';

  @override
  String get settingsViewerShowShootingDetails => 'Mostrar detalles de toma';

  @override
  String get settingsViewerShowDescription => 'Mostrar la descripción';

  @override
  String get settingsViewerShowOverlayThumbnails => 'Mostrar miniaturas';

  @override
  String get settingsViewerEnableOverlayBlurEffect => 'Efecto de difuminado';

  @override
  String get settingsViewerSlideshowTile => 'Presentación';

  @override
  String get settingsViewerSlideshowPageTitle => 'Presentación';

  @override
  String get settingsSlideshowRepeat => 'Repetir';

  @override
  String get settingsSlideshowShuffle => 'Mezclar';

  @override
  String get settingsSlideshowFillScreen => 'Llenar pantalla';

  @override
  String get settingsSlideshowAnimatedZoomEffect => 'Efecto de zoom animado';

  @override
  String get settingsSlideshowTransitionTile => 'Transición';

  @override
  String get settingsSlideshowIntervalTile => 'Intervalo';

  @override
  String get settingsSlideshowVideoPlaybackTile => 'Reproducción de video';

  @override
  String get settingsSlideshowVideoPlaybackDialogTitle => 'Reproducción de video';

  @override
  String get settingsVideoPageTitle => 'Ajustes de video';

  @override
  String get settingsVideoSectionTitle => 'Video';

  @override
  String get settingsVideoShowVideos => 'Mostrar videos';

  @override
  String get settingsVideoPlaybackTile => 'Reproducción';

  @override
  String get settingsVideoPlaybackPageTitle => 'Reproducir';

  @override
  String get settingsVideoEnableHardwareAcceleration => 'Aceleración por hardware';

  @override
  String get settingsVideoAutoPlay => 'Reproducción automática';

  @override
  String get settingsVideoLoopModeTile => 'Modo bucle';

  @override
  String get settingsVideoLoopModeDialogTitle => 'Modo bucle';

  @override
  String get settingsVideoResumptionModeTile => 'Reanudar la reproducción';

  @override
  String get settingsVideoResumptionModeDialogTitle => 'Reanudar la reproducción';

  @override
  String get settingsVideoBackgroundMode => 'Reproducción de fondo';

  @override
  String get settingsVideoBackgroundModeDialogTitle => 'Reproducción de fondo';

  @override
  String get settingsVideoControlsTile => 'Controles';

  @override
  String get settingsVideoControlsPageTitle => 'Controles';

  @override
  String get settingsVideoButtonsTile => 'Botones';

  @override
  String get settingsVideoGestureDoubleTapTogglePlay => 'Doble toque para reproducir/pausar';

  @override
  String get settingsVideoGestureSideDoubleTapSeek => 'Doble toque en los bordes de la pantalla para buscar atrás/adelante';

  @override
  String get settingsVideoGestureVerticalDragBrightnessVolume => 'Deslice hacia arriba o hacia abajo para ajustar el brillo o el volumen';

  @override
  String get settingsSubtitleThemeTile => 'Subtítulos';

  @override
  String get settingsSubtitleThemePageTitle => 'Subtítulos';

  @override
  String get settingsSubtitleThemeSample => 'Esto es un ejemplo.';

  @override
  String get settingsSubtitleThemeTextAlignmentTile => 'Alineación de texto';

  @override
  String get settingsSubtitleThemeTextAlignmentDialogTitle => 'Alineación de texto';

  @override
  String get settingsSubtitleThemeTextPositionTile => 'Posición del texto';

  @override
  String get settingsSubtitleThemeTextPositionDialogTitle => 'Posición del texto';

  @override
  String get settingsSubtitleThemeTextSize => 'Tamaño de texto';

  @override
  String get settingsSubtitleThemeShowOutline => 'Mostrar contorno y sombra';

  @override
  String get settingsSubtitleThemeTextColor => 'Color de texto';

  @override
  String get settingsSubtitleThemeTextOpacity => 'Opacidad de texto';

  @override
  String get settingsSubtitleThemeBackgroundColor => 'Color de fondo';

  @override
  String get settingsSubtitleThemeBackgroundOpacity => 'Opacidad de fondo';

  @override
  String get settingsSubtitleThemeTextAlignmentLeft => 'Izquierda';

  @override
  String get settingsSubtitleThemeTextAlignmentCenter => 'Centro';

  @override
  String get settingsSubtitleThemeTextAlignmentRight => 'Derecha';

  @override
  String get settingsPrivacySectionTitle => 'Privacidad';

  @override
  String get settingsAllowInstalledAppAccess => 'Permita el acceso a lista de aplicaciones';

  @override
  String get settingsAllowInstalledAppAccessSubtitle => 'Usado para mejorar los álbumes mostrados';

  @override
  String get settingsAllowErrorReporting => 'Permitir reporte de errores anónimo';

  @override
  String get settingsSaveSearchHistory => 'Guardar historial de búsqueda';

  @override
  String get settingsEnableBin => 'Usar cesto de basura';

  @override
  String get settingsEnableBinSubtitle => 'Guardar los elementos eliminados por 30 días';

  @override
  String get settingsDisablingBinWarningDialogMessage => 'Los elementos de la papelera de reciclaje se borrarán para siempre.';

  @override
  String get settingsAllowMediaManagement => 'Permitir la gestión de medios';

  @override
  String get settingsHiddenItemsTile => 'Elementos ocultos';

  @override
  String get settingsHiddenItemsPageTitle => 'Elementos ocultos';

  @override
  String get settingsHiddenFiltersBanner => 'Fotos y videos que concuerden con los filtros no aparecerán en su colección.';

  @override
  String get settingsHiddenFiltersEmpty => 'Sin filtros';

  @override
  String get settingsStorageAccessTile => 'Acceso al almacenamiento';

  @override
  String get settingsStorageAccessPageTitle => 'Acceso al almacenamiento';

  @override
  String get settingsStorageAccessBanner => 'Algunos directorios requieren un permiso de acceso explícito para que sea posible modificar los archivos que contienen. Puede revisar los directorios con permiso aquí.';

  @override
  String get settingsStorageAccessEmpty => 'Sin permisos de acceso';

  @override
  String get settingsStorageAccessRevokeTooltip => 'Revocar';

  @override
  String get settingsAccessibilitySectionTitle => 'Accesibilidad';

  @override
  String get settingsRemoveAnimationsTile => 'Remover animaciones';

  @override
  String get settingsRemoveAnimationsDialogTitle => 'Remover animaciones';

  @override
  String get settingsTimeToTakeActionTile => 'Retraso para ejecutar una acción';

  @override
  String get settingsAccessibilityShowPinchGestureAlternatives => 'Mostrar alternativas a gestos multitáctiles';

  @override
  String get settingsDisplaySectionTitle => 'Pantalla';

  @override
  String get settingsThemeBrightnessTile => 'Tema';

  @override
  String get settingsThemeBrightnessDialogTitle => 'Tema';

  @override
  String get settingsThemeColorHighlights => 'Acentos de color';

  @override
  String get settingsThemeEnableDynamicColor => 'Color dinámico';

  @override
  String get settingsDisplayRefreshRateModeTile => 'Tasa de refresco de la pantalla';

  @override
  String get settingsDisplayRefreshRateModeDialogTitle => 'Tasa de refresco';

  @override
  String get settingsDisplayUseTvInterface => 'Interfaz de Android TV';

  @override
  String get settingsLanguageSectionTitle => 'Idioma y formatos';

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
  String get settingsWidgetShowOutline => 'Borde';

  @override
  String get settingsWidgetOpenPage => 'Al pulsar sobre el widget';

  @override
  String get settingsWidgetDisplayedItem => 'Elemento para mostrar';

  @override
  String get settingsCollectionTile => 'Colección';

  @override
  String get statsPageTitle => 'Stats';

  @override
  String statsWithGps(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString elementos con ubicación',
      one: '1 elemento con ubicación',
    );
    return '$_temp0';
  }

  @override
  String get statsTopCountriesSectionTitle => 'Países principales';

  @override
  String get statsTopStatesSectionTitle => 'Estados principales';

  @override
  String get statsTopPlacesSectionTitle => 'Lugares principales';

  @override
  String get statsTopTagsSectionTitle => 'Etiquetas principales';

  @override
  String get statsTopAlbumsSectionTitle => 'Álbumes principales';

  @override
  String get viewerOpenPanoramaButtonLabel => 'ABRIR PANORÁMICA';

  @override
  String get viewerSetWallpaperButtonLabel => 'ESTABLECER FONDO';

  @override
  String get viewerErrorUnknown => '¡Ups!';

  @override
  String get viewerErrorDoesNotExist => 'El archivo no existe.';

  @override
  String get viewerInfoPageTitle => 'Información';

  @override
  String get viewerInfoBackToViewerTooltip => 'Regresar al visor';

  @override
  String get viewerInfoUnknown => 'Desconocido';

  @override
  String get viewerInfoLabelDescription => 'Descripción';

  @override
  String get viewerInfoLabelTitle => 'Título';

  @override
  String get viewerInfoLabelDate => 'Fecha';

  @override
  String get viewerInfoLabelResolution => 'Resolución';

  @override
  String get viewerInfoLabelSize => 'Tamaño';

  @override
  String get viewerInfoLabelUri => 'URI';

  @override
  String get viewerInfoLabelPath => 'Ubicación';

  @override
  String get viewerInfoLabelDuration => 'Duración';

  @override
  String get viewerInfoLabelOwner => 'Propiedad de';

  @override
  String get viewerInfoLabelCoordinates => 'Coordinadas';

  @override
  String get viewerInfoLabelAddress => 'Dirección';

  @override
  String get mapStyleDialogTitle => 'Estilo de mapa';

  @override
  String get mapStyleTooltip => 'Selección de estilo de mapa';

  @override
  String get mapZoomInTooltip => 'Acercar';

  @override
  String get mapZoomOutTooltip => 'Alejar';

  @override
  String get mapPointNorthUpTooltip => 'Apuntar el Norte hacia arriba';

  @override
  String get mapAttributionOsmData => 'Datos de mapas © [OpenStreetMap](https://www.openstreetmap.org/copyright) contribuidores';

  @override
  String get mapAttributionOsmLiberty => 'Mosaicos por [OpenMapTiles](https://www.openmaptiles.org/), [CC BY](http://creativecommons.org/licenses/by/4.0) • Alojado por [OSM Americana](https://tile.ourmap.us)';

  @override
  String get mapAttributionOpenTopoMap => '[SRTM](https://www.earthdata.nasa.gov/sensors/srtm) | Mosaicos por [OpenTopoMap](https://opentopomap.org/), [CC BY-SA](https://creativecommons.org/licenses/by-sa/3.0/)';

  @override
  String get mapAttributionOsmHot => 'Mosaicos por [HOT](https://www.hotosm.org/) • Alojado por [OSM France](https://openstreetmap.fr/)';

  @override
  String get mapAttributionStamen => 'Mosaicos por [Stamen Design](https://stamen.com), [CC BY 3.0](https://creativecommons.org/licenses/by/3.0)';

  @override
  String get openMapPageTooltip => 'Ver en página del mapa';

  @override
  String get mapEmptyRegion => 'Sin imágenes en esta región';

  @override
  String get viewerInfoOpenEmbeddedFailureFeedback => 'Fallo al extraer datos embutidos';

  @override
  String get viewerInfoOpenLinkText => 'Abrir';

  @override
  String get viewerInfoViewXmlLinkText => 'Ver XML';

  @override
  String get viewerInfoSearchFieldLabel => 'Buscar metadatos';

  @override
  String get viewerInfoSearchEmpty => 'Sin claves concordantes';

  @override
  String get viewerInfoSearchSuggestionDate => 'Fecha y hora';

  @override
  String get viewerInfoSearchSuggestionDescription => 'Descripción';

  @override
  String get viewerInfoSearchSuggestionDimensions => 'Dimensiones';

  @override
  String get viewerInfoSearchSuggestionResolution => 'Resolución';

  @override
  String get viewerInfoSearchSuggestionRights => 'Derechos';

  @override
  String get wallpaperUseScrollEffect => 'Usar el efecto de desplazamiento en la pantalla de inicio';

  @override
  String get tagEditorPageTitle => 'Editar Etiquetas';

  @override
  String get tagEditorPageNewTagFieldLabel => 'Nueva etiqueta';

  @override
  String get tagEditorPageAddTagTooltip => 'Añadir etiqueta';

  @override
  String get tagEditorSectionRecent => 'Reciente';

  @override
  String get tagEditorSectionPlaceholders => 'Marcadores de la posición';

  @override
  String get tagEditorDiscardDialogMessage => '¿Quieres descartar los cambios?';

  @override
  String get tagPlaceholderCountry => 'País';

  @override
  String get tagPlaceholderState => 'Estado';

  @override
  String get tagPlaceholderPlace => 'Lugar';

  @override
  String get panoramaEnableSensorControl => 'Activar control de sensores';

  @override
  String get panoramaDisableSensorControl => 'Desactivar control de sensores';

  @override
  String get sourceViewerPageTitle => 'Fuente';

  @override
  String get filePickerShowHiddenFiles => 'Mostrar archivos ocultos';

  @override
  String get filePickerDoNotShowHiddenFiles => 'No mostrar archivos ocultos';

  @override
  String get filePickerOpenFrom => 'Abrir desde';

  @override
  String get filePickerNoItems => 'Sin elementos';

  @override
  String get filePickerUseThisFolder => 'Usar esta carpeta';
}
