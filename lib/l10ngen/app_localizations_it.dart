// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appName => 'Aves';

  @override
  String get welcomeMessage => 'Benvenuto in Aves';

  @override
  String get welcomeOptional => 'Opzionale';

  @override
  String get welcomeTermsToggle => 'Accetto i termini e le condizioni';

  @override
  String itemCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString elementi',
      one: '$countString elemento',
    );
    return '$_temp0';
  }

  @override
  String columnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count colonne',
      one: '$count colonna',
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
      other: '$countString secondi',
      one: '$countString secondo',
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
      other: '$countString minuti',
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
      other: '$countString giorni',
      one: '$countString giorno',
    );
    return '$_temp0';
  }

  @override
  String focalLength(String length) {
    return '$length mm';
  }

  @override
  String get applyButtonLabel => 'APPLICA';

  @override
  String get deleteButtonLabel => 'ELIMINA';

  @override
  String get nextButtonLabel => 'AVANTI';

  @override
  String get showButtonLabel => 'VISUALIZZA';

  @override
  String get hideButtonLabel => 'NASCONDI';

  @override
  String get continueButtonLabel => 'CONTINUA';

  @override
  String get saveCopyButtonLabel => 'SALVA COPIA';

  @override
  String get applyTooltip => 'Applica';

  @override
  String get cancelTooltip => 'Annulla';

  @override
  String get changeTooltip => 'Cambia';

  @override
  String get clearTooltip => 'Cancella';

  @override
  String get previousTooltip => 'Precedente';

  @override
  String get nextTooltip => 'Successivo';

  @override
  String get showTooltip => 'Visualizza';

  @override
  String get hideTooltip => 'Nascondi';

  @override
  String get actionRemove => 'Rimuovi';

  @override
  String get resetTooltip => 'Ripristina';

  @override
  String get saveTooltip => 'Salva';

  @override
  String get stopTooltip => 'Ferma';

  @override
  String get pickTooltip => 'Seleziona';

  @override
  String get doubleBackExitMessage => 'Tocca di nuovo «indietro» per uscire.';

  @override
  String get doNotAskAgain => 'Non chiedere di nuovo';

  @override
  String get sourceStateLoading => 'Caricamento';

  @override
  String get sourceStateCataloguing => 'Catalogazione';

  @override
  String get sourceStateLocatingCountries => 'Individuazione paesi';

  @override
  String get sourceStateLocatingPlaces => 'Individuazione luoghi';

  @override
  String get chipActionDelete => 'Elimina';

  @override
  String get chipActionRemove => 'Rimuovi';

  @override
  String get chipActionShowCollection => 'Visualizza nella Collezione';

  @override
  String get chipActionGoToAlbumPage => 'Visualizza negli Album';

  @override
  String get chipActionGoToCountryPage => 'Mostra nei Paesi';

  @override
  String get chipActionGoToPlacePage => 'Visualizza nei Luoghi';

  @override
  String get chipActionGoToTagPage => 'Visualizza nelle Etichette';

  @override
  String get chipActionGoToExplorerPage => 'Mostra in Gestione file';

  @override
  String get chipActionDecompose => 'Dividi';

  @override
  String get chipActionFilterOut => 'Escludi';

  @override
  String get chipActionFilterIn => 'Includi';

  @override
  String get chipActionHide => 'Nascondi';

  @override
  String get chipActionLock => 'Proteggi';

  @override
  String get chipActionPin => 'Aggancia in alto';

  @override
  String get chipActionUnpin => 'Rimuovi dall’alto';

  @override
  String get chipActionRename => 'Rinomina';

  @override
  String get chipActionSetCover => 'Imposta copertina';

  @override
  String get chipActionShowCountryStates => 'Visualizza stati';

  @override
  String get chipActionCreateAlbum => 'Crea album';

  @override
  String get chipActionCreateVault => 'Crea cassaforte';

  @override
  String get chipActionConfigureVault => 'Configura cassaforte';

  @override
  String get entryActionCopyToClipboard => 'Copia negli appunti';

  @override
  String get entryActionDelete => 'Elimina';

  @override
  String get entryActionConvert => 'Converti';

  @override
  String get entryActionExport => 'Esporta';

  @override
  String get entryActionInfo => 'Info';

  @override
  String get entryActionRename => 'Rinomina';

  @override
  String get entryActionRestore => 'Ripristina';

  @override
  String get entryActionRotateCCW => 'Ruota in senso antiorario';

  @override
  String get entryActionRotateCW => 'Ruota in senso orario';

  @override
  String get entryActionFlip => 'Capovolgi orizzontalmente';

  @override
  String get entryActionPrint => 'Stampa';

  @override
  String get entryActionShare => 'Condividi';

  @override
  String get entryActionShareImageOnly => 'Condividi solo immagine';

  @override
  String get entryActionShareVideoOnly => 'Condividi solo video';

  @override
  String get entryActionViewSource => 'Visualizza sorgente';

  @override
  String get entryActionShowGeoTiffOnMap => 'Visualizza sopra la mappa';

  @override
  String get entryActionConvertMotionPhotoToStillImage => 'Converti in immagine fissa';

  @override
  String get entryActionViewMotionPhotoVideo => 'Apri video';

  @override
  String get entryActionEdit => 'Modifica';

  @override
  String get entryActionOpen => 'Apri con';

  @override
  String get entryActionSetAs => 'Imposta come';

  @override
  String get entryActionCast => 'Cast';

  @override
  String get entryActionOpenMap => 'Visualizza in app mappa';

  @override
  String get entryActionRotateScreen => 'Ruota schermo';

  @override
  String get entryActionAddFavourite => 'Aggiungi ai preferiti';

  @override
  String get entryActionRemoveFavourite => 'Rimuovi dai preferiti';

  @override
  String get videoActionCaptureFrame => 'Cattura fotogramma';

  @override
  String get videoActionMute => 'Disattiva audio';

  @override
  String get videoActionUnmute => 'Attiva audio';

  @override
  String get videoActionPause => 'Pausa';

  @override
  String get videoActionPlay => 'Riproduci';

  @override
  String get videoActionReplay10 => 'Cerca indietro di 10 secondi';

  @override
  String get videoActionSkip10 => 'Cerca in avanti di 10 secondi';

  @override
  String get videoActionShowPreviousFrame => 'Visualizza fotogramma precedente';

  @override
  String get videoActionShowNextFrame => 'Visualizza fotogramma successivo';

  @override
  String get videoActionSelectStreams => 'Seleziona tracce';

  @override
  String get videoActionSetSpeed => 'Velocità riproduzione';

  @override
  String get videoActionABRepeat => 'Ripeti A-B';

  @override
  String get videoRepeatActionSetStart => 'Imposta inizio';

  @override
  String get videoRepeatActionSetEnd => 'Imposta fine';

  @override
  String get viewerActionSettings => 'Impostazioni';

  @override
  String get viewerActionLock => 'Blocca visualizzazione';

  @override
  String get viewerActionUnlock => 'Sblocca visualizzazione';

  @override
  String get slideshowActionResume => 'Riprendi';

  @override
  String get slideshowActionShowInCollection => 'Visualizza nella Collezione';

  @override
  String get entryInfoActionEditDate => 'Modifica data e ora';

  @override
  String get entryInfoActionEditLocation => 'Modifica posizione';

  @override
  String get entryInfoActionEditTitleDescription => 'Modifica titolo e descrizione';

  @override
  String get entryInfoActionEditRating => 'Modifica valutazione';

  @override
  String get entryInfoActionEditTags => 'Modifica etichette';

  @override
  String get entryInfoActionRemoveMetadata => 'Rimuovi metadati';

  @override
  String get entryInfoActionExportMetadata => 'Esporta metadati';

  @override
  String get entryInfoActionRemoveLocation => 'Rimuovi posizione';

  @override
  String get editorActionTransform => 'Trasforma';

  @override
  String get editorTransformCrop => 'Ritaglia';

  @override
  String get editorTransformRotate => 'Ruota';

  @override
  String get cropAspectRatioFree => 'Liberi';

  @override
  String get cropAspectRatioOriginal => 'Originale';

  @override
  String get cropAspectRatioSquare => 'Quadrato';

  @override
  String get filterAspectRatioLandscapeLabel => 'Orizzontale';

  @override
  String get filterAspectRatioPortraitLabel => 'Verticale';

  @override
  String get filterBinLabel => 'Cestino';

  @override
  String get filterFavouriteLabel => 'Preferito';

  @override
  String get filterNoDateLabel => 'Senza data';

  @override
  String get filterNoAddressLabel => 'Senza indirizzo';

  @override
  String get filterLocatedLabel => 'Posizionato';

  @override
  String get filterNoLocationLabel => 'Senza posizione';

  @override
  String get filterNoRatingLabel => 'Non valutato';

  @override
  String get filterTaggedLabel => 'Etichettato';

  @override
  String get filterNoTagLabel => 'Senza etichetta';

  @override
  String get filterNoTitleLabel => 'Senza titolo';

  @override
  String get filterOnThisDayLabel => 'In questo giorno';

  @override
  String get filterRecentlyAddedLabel => 'Aggiunto di recente';

  @override
  String get filterRatingRejectedLabel => 'Rifiutato';

  @override
  String get filterTypeAnimatedLabel => 'Animato';

  @override
  String get filterTypeMotionPhotoLabel => 'Foto in movimento';

  @override
  String get filterTypePanoramaLabel => 'Panorama';

  @override
  String get filterTypeRawLabel => 'Raw';

  @override
  String get filterTypeSphericalVideoLabel => 'Video a 360°';

  @override
  String get filterTypeGeotiffLabel => 'GeoTIFF';

  @override
  String get filterMimeImageLabel => 'Immagine';

  @override
  String get filterMimeVideoLabel => 'Video';

  @override
  String get accessibilityAnimationsRemove => 'Evita effetti schermo';

  @override
  String get accessibilityAnimationsKeep => 'Mantieni effetti schermo';

  @override
  String get albumTierNew => 'Nuovo';

  @override
  String get albumTierPinned => 'Fissati';

  @override
  String get albumTierSpecial => 'Frequenti';

  @override
  String get albumTierApps => 'Applicazioni';

  @override
  String get albumTierVaults => 'Casseforti';

  @override
  String get albumTierDynamic => 'Dinamico';

  @override
  String get albumTierRegular => 'Altri';

  @override
  String get coordinateFormatDms => 'DMS';

  @override
  String get coordinateFormatDdm => 'DDM';

  @override
  String get coordinateFormatDecimal => 'Gradi decimali';

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
  String get displayRefreshRatePreferHighest => 'Frequenza massima';

  @override
  String get displayRefreshRatePreferLowest => 'Frequenza minima';

  @override
  String get keepScreenOnNever => 'Mai';

  @override
  String get keepScreenOnVideoPlayback => 'Durante riproduzione video';

  @override
  String get keepScreenOnViewerOnly => 'Solo pagina visualizzazione';

  @override
  String get keepScreenOnAlways => 'Sempre';

  @override
  String get lengthUnitPixel => 'px';

  @override
  String get lengthUnitPercent => '%';

  @override
  String get mapStyleGoogleNormal => 'Google Maps';

  @override
  String get mapStyleGoogleHybrid => 'Google Maps (Ibrido)';

  @override
  String get mapStyleGoogleTerrain => 'Google Maps (Terreno)';

  @override
  String get mapStyleOsmLiberty => 'OSM Liberty';

  @override
  String get mapStyleOpenTopoMap => 'OpenTopoMap';

  @override
  String get mapStyleOsmHot => 'OSM umanitario';

  @override
  String get mapStyleStamenWatercolor => 'Stamen Watercolor (Acquerello)';

  @override
  String get maxBrightnessNever => 'Mai';

  @override
  String get maxBrightnessAlways => 'Sempre';

  @override
  String get nameConflictStrategyRename => 'Rinomina';

  @override
  String get nameConflictStrategyReplace => 'Sostituisci';

  @override
  String get nameConflictStrategySkip => 'Salta';

  @override
  String get overlayHistogramNone => 'Nessuno';

  @override
  String get overlayHistogramRGB => 'RGB';

  @override
  String get overlayHistogramLuminance => 'Luminanza';

  @override
  String get subtitlePositionTop => 'In alto';

  @override
  String get subtitlePositionBottom => 'In basso';

  @override
  String get themeBrightnessLight => 'Chiaro';

  @override
  String get themeBrightnessDark => 'Scuro';

  @override
  String get themeBrightnessBlack => 'Nero';

  @override
  String get unitSystemMetric => 'Metrico';

  @override
  String get unitSystemImperial => 'Imperiale';

  @override
  String get vaultLockTypePattern => 'Sequenza';

  @override
  String get vaultLockTypePin => 'PIN';

  @override
  String get vaultLockTypePassword => 'Password';

  @override
  String get settingsVideoEnablePip => 'Picture-in-picture';

  @override
  String get videoControlsPlayOutside => 'Apri con un altro lettore';

  @override
  String get videoLoopModeNever => 'Mai';

  @override
  String get videoLoopModeShortOnly => 'Solo video brevi';

  @override
  String get videoLoopModeAlways => 'Sempre';

  @override
  String get videoPlaybackSkip => 'Salta';

  @override
  String get videoPlaybackMuted => 'Riproduci senza audio';

  @override
  String get videoPlaybackWithSound => 'Riproduci con audio';

  @override
  String get videoResumptionModeNever => 'Mai';

  @override
  String get videoResumptionModeAlways => 'Sempre';

  @override
  String get viewerTransitionSlide => 'Diapositiva';

  @override
  String get viewerTransitionParallax => 'Parallasse';

  @override
  String get viewerTransitionFade => 'Dissolvenza';

  @override
  String get viewerTransitionZoomIn => 'Ingrandisci';

  @override
  String get viewerTransitionNone => 'Nessuna';

  @override
  String get wallpaperTargetHome => 'Schermata iniziale';

  @override
  String get wallpaperTargetLock => 'Schermata di blocco';

  @override
  String get wallpaperTargetHomeLock => 'Schermata iniziale e di blocco';

  @override
  String get widgetDisplayedItemRandom => 'Casuale';

  @override
  String get widgetDisplayedItemMostRecent => 'Più recente';

  @override
  String get widgetOpenPageHome => 'Apri pagina iniziale';

  @override
  String get widgetOpenPageCollection => 'Apri collezione';

  @override
  String get widgetOpenPageViewer => 'Apri visualizzazione';

  @override
  String get widgetTapUpdateWidget => 'Aggiorna widget';

  @override
  String get storageVolumeDescriptionFallbackPrimary => 'Archiviazione interna';

  @override
  String get storageVolumeDescriptionFallbackNonPrimary => 'Scheda SD';

  @override
  String get rootDirectoryDescription => 'cartella root';

  @override
  String otherDirectoryDescription(String name) {
    return 'cartella «$name»';
  }

  @override
  String storageAccessDialogMessage(String directory, String volume) {
    return 'Per dare accesso a questa applicazione nella prossima schermata seleziona la $directory di «$volume».';
  }

  @override
  String restrictedAccessDialogMessage(String directory, String volume) {
    return 'Questa applicazione non è autorizzata a modificare i file nella $directory di «$volume».\n\nPer spostare gli elementi in un’altra cartella usa un gestore file o un’app galleria preinstallata.';
  }

  @override
  String notEnoughSpaceDialogMessage(String neededSize, String freeSize, String volume) {
    return 'Per essere completata questa operazione ha bisogno di $neededSize di spazio libero in «$volume», ma sono rimasti solo $freeSize.';
  }

  @override
  String get missingSystemFilePickerDialogMessage => 'Il selezionatore file di sistema è mancante o disabilitato. Abilitalo e riprova.';

  @override
  String unsupportedTypeDialogMessage(int count, String types) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Questa operazione non è supportata per elementi dei seguenti tipi: $types.',
      one: 'Questa operazione non è supportata per elementi del seguente tipo: $types.',
    );
    return '$_temp0';
  }

  @override
  String get nameConflictDialogSingleSourceMessage => 'Alcuni file nella cartella destinazione hanno lo stesso nome.';

  @override
  String get nameConflictDialogMultipleSourceMessage => 'Alcuni file hanno lo stesso nome.';

  @override
  String get addShortcutDialogLabel => 'Etichetta scorciatoia';

  @override
  String get addShortcutButtonLabel => 'AGGIUNGI';

  @override
  String get noMatchingAppDialogMessage => 'Non ci sono app che possono gestire questo.';

  @override
  String binEntriesConfirmationDialogMessage(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vuoi spostare questi $countString elementi nel cestino?',
      one: 'Vuoi sposta questo elemento nel cestino?',
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
      other: 'Vuoi eliminare questi $countString elementi?',
      one: 'Vuoi eliminare questo elemento?',
    );
    return '$_temp0';
  }

  @override
  String get moveUndatedConfirmationDialogMessage => 'Prima di procedere vuoi salvare le date degli elementi?';

  @override
  String get moveUndatedConfirmationDialogSetDate => 'Salva date';

  @override
  String videoResumeDialogMessage(String time) {
    return 'Vuoi riprendere la riproduzione a $time?';
  }

  @override
  String get videoStartOverButtonLabel => 'RICOMINCIA';

  @override
  String get videoResumeButtonLabel => 'RIPRENDI';

  @override
  String get setCoverDialogLatest => 'Ultimo elemento';

  @override
  String get setCoverDialogAuto => 'Automatico';

  @override
  String get setCoverDialogCustom => 'Personalizzato';

  @override
  String get hideFilterConfirmationDialogMessage => 'Le foto e i video corrispondenti saranno nascosti dalla collezione. Puoi visualizarli di nuovo dalle impostazioni della «Privacy».\n\nVuoi nascondere le foto e i video corrispodenti?';

  @override
  String get newAlbumDialogTitle => 'Nuovo album';

  @override
  String get newAlbumDialogNameLabel => 'Nome album';

  @override
  String get newAlbumDialogAlbumAlreadyExistsHelper => 'Album già esistente';

  @override
  String get newAlbumDialogNameLabelAlreadyExistsHelper => 'La cartella esiste già';

  @override
  String get newAlbumDialogStorageLabel => 'Archiviazione:';

  @override
  String get newDynamicAlbumDialogTitle => 'Nuovo album dinamico';

  @override
  String get dynamicAlbumAlreadyExists => 'Album dinamico già esistente';

  @override
  String get newVaultWarningDialogMessage => 'Gli elementi nelle cassaforti sono disponibili solo per questa app e non per altre.\n\nSe disinstalli l’app o cancelli i relativi dati, perderai tutti questi elementi.';

  @override
  String get newVaultDialogTitle => 'Nuova Cassaforte';

  @override
  String get configureVaultDialogTitle => 'Configura Cassaforte';

  @override
  String get vaultDialogLockModeWhenScreenOff => 'Blocca allo spegnimento dello schermo';

  @override
  String get vaultDialogLockTypeLabel => 'Tipo di protezione';

  @override
  String get patternDialogEnter => 'Inserisci sequenza';

  @override
  String get patternDialogConfirm => 'Conferma sequenza';

  @override
  String get pinDialogEnter => 'Inserisci PIN';

  @override
  String get pinDialogConfirm => 'Conferma PIN';

  @override
  String get passwordDialogEnter => 'Inserisci password';

  @override
  String get passwordDialogConfirm => 'Conferma password';

  @override
  String get authenticateToConfigureVault => 'Accedi per configurare la cassaforte';

  @override
  String get authenticateToUnlockVault => 'Accedi per sbloccare la cassaforte';

  @override
  String get vaultBinUsageDialogMessage => 'Alcune casseforti stanno usando il cestino.';

  @override
  String get renameAlbumDialogLabel => 'Nuovo nome';

  @override
  String get renameAlbumDialogLabelAlreadyExistsHelper => 'La cartella esiste già';

  @override
  String get renameEntrySetPageTitle => 'Rinomina';

  @override
  String get renameEntrySetPagePatternFieldLabel => 'Schema nomi';

  @override
  String get renameEntrySetPageInsertTooltip => 'Inserisci campo';

  @override
  String get renameEntrySetPagePreviewSectionTitle => 'Anteprima';

  @override
  String get renameProcessorCounter => 'Contatore';

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
      other: 'Vuoi eliminare questo album e i relativi $countString elementi?',
      one: 'Vuoi eliminare questo album e il relativo elemento?',
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
      other: 'Vuoi eliminare questi album e i relativi $countString elementi?',
      one: 'Vuoi eliminare questi album e il relativo elemento?',
    );
    return '$_temp0';
  }

  @override
  String get exportEntryDialogFormat => 'Formato:';

  @override
  String get exportEntryDialogWidth => 'Larghezza';

  @override
  String get exportEntryDialogHeight => 'Altezza';

  @override
  String get exportEntryDialogQuality => 'Qualità';

  @override
  String get exportEntryDialogWriteMetadata => 'Scrivi metadati';

  @override
  String get renameEntryDialogLabel => 'Nuovo nome';

  @override
  String get editEntryDialogCopyFromItem => 'Copia da un altro elemento';

  @override
  String get editEntryDialogTargetFieldsHeader => 'Campi da modificare';

  @override
  String get editEntryDateDialogTitle => 'Data e ora';

  @override
  String get editEntryDateDialogSetCustom => 'Imposta data personalizzata';

  @override
  String get editEntryDateDialogCopyField => 'Copia da un’altra data';

  @override
  String get editEntryDateDialogExtractFromTitle => 'Estrai dal titolo';

  @override
  String get editEntryDateDialogShift => 'Sfasamento';

  @override
  String get editEntryDateDialogSourceFileModifiedDate => 'Data modifica file';

  @override
  String get durationDialogHours => 'Ore';

  @override
  String get durationDialogMinutes => 'Minuti';

  @override
  String get durationDialogSeconds => 'Secondi';

  @override
  String get editEntryLocationDialogTitle => 'Posizione';

  @override
  String get editEntryLocationDialogSetCustom => 'Imposta posizione personalizzata';

  @override
  String get editEntryLocationDialogChooseOnMap => 'Scegli sulla mappa';

  @override
  String get editEntryLocationDialogImportGpx => 'Importa GPX';

  @override
  String get editEntryLocationDialogLatitude => 'Latitudine';

  @override
  String get editEntryLocationDialogLongitude => 'Longitudine';

  @override
  String get editEntryLocationDialogTimeShift => 'Scostamento tempo';

  @override
  String get locationPickerUseThisLocationButton => 'Usa questa posizione';

  @override
  String get editEntryRatingDialogTitle => 'Valutazione';

  @override
  String get removeEntryMetadataDialogTitle => 'Rimozione metadati';

  @override
  String get removeEntryMetadataDialogAll => 'All';

  @override
  String get removeEntryMetadataDialogMore => 'Altro';

  @override
  String get removeEntryMetadataMotionPhotoXmpWarningDialogMessage => 'Per riprodurre il video all’interno di una foto in movimento è richiesto XMP .\n\nSei sicuro di volerlo rimuovere?';

  @override
  String get videoSpeedDialogLabel => 'Velocità riproduzione';

  @override
  String get videoStreamSelectionDialogVideo => 'Video';

  @override
  String get videoStreamSelectionDialogAudio => 'Audio';

  @override
  String get videoStreamSelectionDialogText => 'Sottotitoli';

  @override
  String get videoStreamSelectionDialogOff => 'Spento';

  @override
  String get videoStreamSelectionDialogTrack => 'Traccia';

  @override
  String get videoStreamSelectionDialogNoSelection => 'Non ci sono altre tracce.';

  @override
  String get genericSuccessFeedback => 'Fatto!';

  @override
  String get genericFailureFeedback => 'Fallito';

  @override
  String get genericDangerWarningDialogMessage => 'Sei sicuro?';

  @override
  String get tooManyItemsErrorDialogMessage => 'Riprova con meno elementi.';

  @override
  String get menuActionConfigureView => 'Vista';

  @override
  String get menuActionSelect => 'Seleziona';

  @override
  String get menuActionSelectAll => 'Seleziona tutto';

  @override
  String get menuActionSelectNone => 'Deseleziona tutto';

  @override
  String get menuActionMap => 'Mappa';

  @override
  String get menuActionSlideshow => 'Presentazione';

  @override
  String get menuActionStats => 'Statistiche';

  @override
  String get viewDialogSortSectionTitle => 'Ordina';

  @override
  String get viewDialogGroupSectionTitle => 'Raggruppa';

  @override
  String get viewDialogLayoutSectionTitle => 'Layout';

  @override
  String get viewDialogReverseSortOrder => 'Inverti ordinamento';

  @override
  String get tileLayoutMosaic => 'Mosaico';

  @override
  String get tileLayoutGrid => 'Griglia';

  @override
  String get tileLayoutList => 'Elenco';

  @override
  String get castDialogTitle => 'Dispositivi Cast';

  @override
  String get coverDialogTabCover => 'Copertina';

  @override
  String get coverDialogTabApp => 'App';

  @override
  String get coverDialogTabColor => 'Colore';

  @override
  String get appPickDialogTitle => 'Seleziona app';

  @override
  String get appPickDialogNone => 'Nessuna';

  @override
  String get aboutPageTitle => 'Informazioni';

  @override
  String get aboutLinkLicense => 'Licenza';

  @override
  String get aboutLinkPolicy => 'Informativa sulla privacy';

  @override
  String get aboutBugSectionTitle => 'Segnalazione bug';

  @override
  String get aboutBugSaveLogInstruction => 'Salva registri app in un file';

  @override
  String get aboutBugCopyInfoInstruction => 'Copia informazioni sistema';

  @override
  String get aboutBugCopyInfoButton => 'Copia';

  @override
  String get aboutBugReportInstruction => 'Segnala su GitHub con i registri e le info di sistema';

  @override
  String get aboutBugReportButton => 'Segnala';

  @override
  String get aboutDataUsageSectionTitle => 'Uso dati';

  @override
  String get aboutDataUsageData => 'Dati';

  @override
  String get aboutDataUsageCache => 'Cache';

  @override
  String get aboutDataUsageDatabase => 'Database';

  @override
  String get aboutDataUsageMisc => 'Varie';

  @override
  String get aboutDataUsageInternal => 'Interno';

  @override
  String get aboutDataUsageExternal => 'Esterno';

  @override
  String get aboutDataUsageClearCache => 'Svuota cache';

  @override
  String get aboutCreditsSectionTitle => 'Ringraziamenti';

  @override
  String get aboutCreditsWorldAtlas1 => 'Questa applicazione usa un file TopoJSON di';

  @override
  String get aboutCreditsWorldAtlas2 => 'sotto licenza ISC.';

  @override
  String get aboutTranslatorsSectionTitle => 'Traduttori';

  @override
  String get aboutLicensesSectionTitle => 'Licenze open-source';

  @override
  String get aboutLicensesBanner => 'Questa applicazione usa i seguenti pacchetti e librerie open-source.';

  @override
  String get aboutLicensesAndroidLibrariesSectionTitle => 'Librerie Android';

  @override
  String get aboutLicensesFlutterPluginsSectionTitle => 'Plugin Flutter';

  @override
  String get aboutLicensesFlutterPackagesSectionTitle => 'Pacchetti Flutter';

  @override
  String get aboutLicensesDartPackagesSectionTitle => 'Pacchetti Dart';

  @override
  String get aboutLicensesShowAllButtonLabel => 'Visualizza tutte le licenze';

  @override
  String get policyPageTitle => 'Informativa sulla privacy';

  @override
  String get collectionPageTitle => 'Collezione';

  @override
  String get collectionPickPageTitle => 'Seleziona';

  @override
  String get collectionSelectPageTitle => 'Seleziona elementi';

  @override
  String get collectionActionShowTitleSearch => 'Visualizza filtro titoli';

  @override
  String get collectionActionHideTitleSearch => 'Nascondi filtro titoli';

  @override
  String get collectionActionAddDynamicAlbum => 'Aggiungi album dinamico';

  @override
  String get collectionActionAddShortcut => 'Aggiungi collegamento';

  @override
  String get collectionActionSetHome => 'Imposta come pagina iniziale';

  @override
  String get collectionActionEmptyBin => 'Svuota cestino';

  @override
  String get collectionActionCopy => 'Copia nell’album';

  @override
  String get collectionActionMove => 'Sposta nell’album';

  @override
  String get collectionActionRescan => 'Riscansiona';

  @override
  String get collectionActionEdit => 'Modifica';

  @override
  String get collectionSearchTitlesHintText => 'Cerca titoli';

  @override
  String get collectionGroupAlbum => 'Per album';

  @override
  String get collectionGroupMonth => 'Per mese';

  @override
  String get collectionGroupDay => 'Per giorno';

  @override
  String get collectionGroupNone => 'Non raggruppare';

  @override
  String get sectionUnknown => 'Sconosciuto';

  @override
  String get dateToday => 'Oggi';

  @override
  String get dateYesterday => 'Ieri';

  @override
  String get dateThisMonth => 'Questo mese';

  @override
  String collectionDeleteFailureFeedback(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Impossibile eliminare $countString elementi',
      one: 'Impossibile eliminare 1 elemento',
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
      other: 'Impossibile copiare $countString elementi',
      one: 'Impossibile copiare 1 elemento',
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
      other: 'Impossibile spostare $countString elementi',
      one: 'Impossibile spostare 1 elemento',
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
      other: 'Impossibile rinominare $countString elementi',
      one: 'Impossibile rinominare 1 elemento',
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
      other: 'Impossibile modificare $countString elementi',
      one: 'Impossibile modificare 1 elemento',
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
      other: 'Impossibile esportare $countString elementi',
      one: 'Impossibile esportare 1 elemento',
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
      other: 'Copiati $countString elementi',
      one: 'Copiato 1 elemento',
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
      other: 'Spostati $countString elementi',
      one: 'Spostato 1 elemento',
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
      other: 'Rinominati $countString elementi',
      one: 'Rinominato 1 elemento',
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
      other: 'Modificati $countString elementi',
      one: 'Modificato 1 elemento',
    );
    return '$_temp0';
  }

  @override
  String get collectionEmptyFavourites => 'Nessun preferito';

  @override
  String get collectionEmptyVideos => 'Nessun video';

  @override
  String get collectionEmptyImages => 'Nessuna immagine';

  @override
  String get collectionEmptyGrantAccessButtonLabel => 'Consenti accesso';

  @override
  String get collectionSelectSectionTooltip => 'Seleziona sezione';

  @override
  String get collectionDeselectSectionTooltip => 'Deseleziona sezione';

  @override
  String get drawerAboutButton => 'Info';

  @override
  String get drawerSettingsButton => 'Impostazioni';

  @override
  String get drawerCollectionAll => 'Tutte le collezioni';

  @override
  String get drawerCollectionFavourites => 'Preferiti';

  @override
  String get drawerCollectionImages => 'Immagini';

  @override
  String get drawerCollectionVideos => 'Video';

  @override
  String get drawerCollectionAnimated => 'Animazioni';

  @override
  String get drawerCollectionMotionPhotos => 'Foto in movimento';

  @override
  String get drawerCollectionPanoramas => 'Panorami';

  @override
  String get drawerCollectionRaws => 'Foto raw';

  @override
  String get drawerCollectionSphericalVideos => 'Video a 360°';

  @override
  String get drawerAlbumPage => 'Album';

  @override
  String get drawerCountryPage => 'Paesi';

  @override
  String get drawerPlacePage => 'Luoghi';

  @override
  String get drawerTagPage => 'Etichette';

  @override
  String get sortByDate => 'Per data';

  @override
  String get sortByName => 'Per nome';

  @override
  String get sortByItemCount => 'Per numero elementi';

  @override
  String get sortBySize => 'Per dimensione';

  @override
  String get sortByAlbumFileName => 'Per album e nome file';

  @override
  String get sortByRating => 'Per valutazione';

  @override
  String get sortByDuration => 'Per durata';

  @override
  String get sortByPath => 'By path';

  @override
  String get sortOrderNewestFirst => 'Dal più nuovo';

  @override
  String get sortOrderOldestFirst => 'Dal più vecchio';

  @override
  String get sortOrderAtoZ => 'Dalla A alla Z';

  @override
  String get sortOrderZtoA => 'Dalla Z alla A';

  @override
  String get sortOrderHighestFirst => 'Dalla più alta';

  @override
  String get sortOrderLowestFirst => 'Dalla più bassa';

  @override
  String get sortOrderLargestFirst => 'Dal più grande';

  @override
  String get sortOrderSmallestFirst => 'Dal più piccolo';

  @override
  String get sortOrderShortestFirst => 'Dal più corto';

  @override
  String get sortOrderLongestFirst => 'Dal più lungo';

  @override
  String get albumGroupTier => 'Per importanza';

  @override
  String get albumGroupType => 'Per tipo';

  @override
  String get albumGroupVolume => 'Per volume archiviazione';

  @override
  String get albumGroupNone => 'Non raggruppare';

  @override
  String get albumMimeTypeMixed => 'Misto';

  @override
  String get albumPickPageTitleCopy => 'Copia nell’album';

  @override
  String get albumPickPageTitleExport => 'Esporta nell’album';

  @override
  String get albumPickPageTitleMove => 'Sposta nell’album';

  @override
  String get albumPickPageTitlePick => 'Seleziona album';

  @override
  String get albumCamera => 'Fotocamera';

  @override
  String get albumDownload => 'Scaricati';

  @override
  String get albumScreenshots => 'Schermate';

  @override
  String get albumScreenRecordings => 'Registrazioni schermo';

  @override
  String get albumVideoCaptures => 'Catture video';

  @override
  String get albumPageTitle => 'Album';

  @override
  String get albumEmpty => 'Nessun album';

  @override
  String get createAlbumButtonLabel => 'CREA';

  @override
  String get newFilterBanner => 'nuovo';

  @override
  String get countryPageTitle => 'Paesi';

  @override
  String get countryEmpty => 'Nessun paese';

  @override
  String get statePageTitle => 'Stati';

  @override
  String get stateEmpty => 'Nessuno stato';

  @override
  String get placePageTitle => 'Luoghi';

  @override
  String get placeEmpty => 'Nessun luogo';

  @override
  String get tagPageTitle => 'Etichette';

  @override
  String get tagEmpty => 'Nessuna etichetta';

  @override
  String get binPageTitle => 'Cestino';

  @override
  String get explorerPageTitle => 'Gestione file';

  @override
  String get explorerActionSelectStorageVolume => 'Seleziona supporto';

  @override
  String get selectStorageVolumeDialogTitle => 'Seleziona supporto';

  @override
  String get searchCollectionFieldHint => 'Cerca collezione';

  @override
  String get searchRecentSectionTitle => 'Recenti';

  @override
  String get searchDateSectionTitle => 'Data';

  @override
  String get searchFormatSectionTitle => 'Formats';

  @override
  String get searchAlbumsSectionTitle => 'Album';

  @override
  String get searchCountriesSectionTitle => 'Paesi';

  @override
  String get searchStatesSectionTitle => 'Stati';

  @override
  String get searchPlacesSectionTitle => 'Luoghi';

  @override
  String get searchTagsSectionTitle => 'Etichette';

  @override
  String get searchRatingSectionTitle => 'Valutazioni';

  @override
  String get searchMetadataSectionTitle => 'Metadati';

  @override
  String get settingsPageTitle => 'Impostazioni';

  @override
  String get settingsSystemDefault => 'Predefinito sistema';

  @override
  String get settingsDefault => 'Predefinito';

  @override
  String get settingsDisabled => 'Disabilitato';

  @override
  String get settingsAskEverytime => 'Chiedi sempre';

  @override
  String get settingsModificationWarningDialogMessage => 'Saranno modificate le altre impostazioni.';

  @override
  String get settingsSearchFieldLabel => 'Ricerca impostazioni';

  @override
  String get settingsSearchEmpty => 'Nessuna impostazione corrispondente';

  @override
  String get settingsActionExport => 'Esporta';

  @override
  String get settingsActionExportDialogTitle => 'Esporta';

  @override
  String get settingsActionImport => 'Importa';

  @override
  String get settingsActionImportDialogTitle => 'Importa';

  @override
  String get appExportCovers => 'Copertine';

  @override
  String get appExportDynamicAlbums => 'Album dinamici';

  @override
  String get appExportFavourites => 'Preferiti';

  @override
  String get appExportSettings => 'Impostazioni';

  @override
  String get settingsNavigationSectionTitle => 'Navigazione';

  @override
  String get settingsHomeTile => 'Pagina iniziale';

  @override
  String get settingsHomeDialogTitle => 'Pagina iniziale';

  @override
  String get setHomeCustom => 'Personalizzato';

  @override
  String get settingsShowBottomNavigationBar => 'Visualizza barra navigazione in basso';

  @override
  String get settingsKeepScreenOnTile => 'Mantieni acceso lo schermo';

  @override
  String get settingsKeepScreenOnDialogTitle => 'Mantieni schermo acceso';

  @override
  String get settingsDoubleBackExit => 'Tocca «indietro» due volte per uscire';

  @override
  String get settingsConfirmationTile => 'Richieste conferma';

  @override
  String get settingsConfirmationDialogTitle => 'Richieste conferma';

  @override
  String get settingsConfirmationBeforeDeleteItems => 'Chiedi prima di eliminare gli elementi definitivamente';

  @override
  String get settingsConfirmationBeforeMoveToBinItems => 'Chiedi prima di spostare gli elementi nel cestino';

  @override
  String get settingsConfirmationBeforeMoveUndatedItems => 'Chiedi prima di spostare gli elementi senza data';

  @override
  String get settingsConfirmationAfterMoveToBinItems => 'Visualizza un messaggio dopo aver spostato gli elementi nel cestino';

  @override
  String get settingsConfirmationVaultDataLoss => 'Visualizza avviso perdita dati delle casseforti';

  @override
  String get settingsNavigationDrawerTile => 'Menu navigazione';

  @override
  String get settingsNavigationDrawerEditorPageTitle => 'Menu navigazione';

  @override
  String get settingsNavigationDrawerBanner => 'Tocca e tieni premuto per spostare e riordinare gli elementi del menu.';

  @override
  String get settingsNavigationDrawerTabTypes => 'Tipi';

  @override
  String get settingsNavigationDrawerTabAlbums => 'Album';

  @override
  String get settingsNavigationDrawerTabPages => 'Pagine';

  @override
  String get settingsNavigationDrawerAddAlbum => 'Aggiungi album';

  @override
  String get settingsThumbnailSectionTitle => 'Miniature';

  @override
  String get settingsThumbnailOverlayTile => 'Sovrapposizione';

  @override
  String get settingsThumbnailOverlayPageTitle => 'Sovrapposizione';

  @override
  String get settingsThumbnailShowHdrIcon => 'Visualizza icona HDR';

  @override
  String get settingsThumbnailShowFavouriteIcon => 'Visualizza icona Preferiti';

  @override
  String get settingsThumbnailShowTagIcon => 'Visualizza icona Etichetta';

  @override
  String get settingsThumbnailShowLocationIcon => 'Visualizza icona Posizione';

  @override
  String get settingsThumbnailShowMotionPhotoIcon => 'Viusalizza icona Foto in movimento';

  @override
  String get settingsThumbnailShowRating => 'Visualizza Valutazione';

  @override
  String get settingsThumbnailShowRawIcon => 'Visualizza icona Raw';

  @override
  String get settingsThumbnailShowVideoDuration => 'Visualizza durata video';

  @override
  String get settingsCollectionQuickActionsTile => 'Azioni rapide';

  @override
  String get settingsCollectionQuickActionEditorPageTitle => 'Azioni rapide';

  @override
  String get settingsCollectionQuickActionTabBrowsing => 'Navigazione';

  @override
  String get settingsCollectionQuickActionTabSelecting => 'Selezione';

  @override
  String get settingsCollectionBrowsingQuickActionEditorBanner => 'Tocca e tieni premuto per spostare i pulsanti e selezionare quali azioni vengono visualizzate durante la navigazione degli elementi.';

  @override
  String get settingsCollectionSelectionQuickActionEditorBanner => 'Tocca e tieni premuto per spostare i pulsanti e selezionare quali azioni vengono visualizzate quando si selezionano gli elementi.';

  @override
  String get settingsCollectionBurstPatternsTile => 'Modelli burst';

  @override
  String get settingsCollectionBurstPatternsNone => 'Nessuno';

  @override
  String get settingsViewerSectionTitle => 'Visualizzazione';

  @override
  String get settingsViewerGestureSideTapNext => 'Tocca i bordi dello schermo per visualizzare l’elemento precedente/successivo';

  @override
  String get settingsViewerUseCutout => 'Usa area ritagliata';

  @override
  String get settingsViewerMaximumBrightness => 'Luminosità massima';

  @override
  String get settingsMotionPhotoAutoPlay => 'Riproduzione automatica foto in movimento';

  @override
  String get settingsImageBackground => 'Sfondo immagine';

  @override
  String get settingsViewerQuickActionsTile => 'Azioni rapide';

  @override
  String get settingsViewerQuickActionEditorPageTitle => 'Azioni rapide';

  @override
  String get settingsViewerQuickActionEditorBanner => 'Tocca e tieni premuto per spostare i pulsanti e selezionare quali azioni vengono visualizzate nel visualizzatore.';

  @override
  String get settingsViewerQuickActionEditorDisplayedButtonsSectionTitle => 'Pulsanti visualizzati';

  @override
  String get settingsViewerQuickActionEditorAvailableButtonsSectionTitle => 'Pulsanti disponibili';

  @override
  String get settingsViewerQuickActionEmpty => 'Nessun pulsante';

  @override
  String get settingsViewerOverlayTile => 'Sovrapposizione';

  @override
  String get settingsViewerOverlayPageTitle => 'Sovrapposizione';

  @override
  String get settingsViewerShowOverlayOnOpening => 'Visualizza all’apertura';

  @override
  String get settingsViewerShowHistogram => 'Visualizza istogramma';

  @override
  String get settingsViewerShowMinimap => 'Visualizza minimappa';

  @override
  String get settingsViewerShowInformation => 'Visualizza informazioni';

  @override
  String get settingsViewerShowInformationSubtitle => 'Visualizza titolo, data, posizione, ecc.';

  @override
  String get settingsViewerShowRatingTags => 'Visualizza valutazione e etichette';

  @override
  String get settingsViewerShowShootingDetails => 'Visualizza dettagli scatto';

  @override
  String get settingsViewerShowDescription => 'Visualizza descrizione';

  @override
  String get settingsViewerShowOverlayThumbnails => 'Visualizza miniature';

  @override
  String get settingsViewerEnableOverlayBlurEffect => 'Effetto sfocatura';

  @override
  String get settingsViewerSlideshowTile => 'Presentazione';

  @override
  String get settingsViewerSlideshowPageTitle => 'Presentazione';

  @override
  String get settingsSlideshowRepeat => 'Ripeti';

  @override
  String get settingsSlideshowShuffle => 'Ordine casuale';

  @override
  String get settingsSlideshowFillScreen => 'Riempi schermo';

  @override
  String get settingsSlideshowAnimatedZoomEffect => 'Effetto ingrandimento animato';

  @override
  String get settingsSlideshowTransitionTile => 'Transizione';

  @override
  String get settingsSlideshowIntervalTile => 'Intervallo';

  @override
  String get settingsSlideshowVideoPlaybackTile => 'Riproduzione video';

  @override
  String get settingsSlideshowVideoPlaybackDialogTitle => 'Riproduzione video';

  @override
  String get settingsVideoPageTitle => 'Impostazioni video';

  @override
  String get settingsVideoSectionTitle => 'Video';

  @override
  String get settingsVideoShowVideos => 'Visualizza video';

  @override
  String get settingsVideoPlaybackTile => 'Riproduzione';

  @override
  String get settingsVideoPlaybackPageTitle => 'Riproduzione';

  @override
  String get settingsVideoEnableHardwareAcceleration => 'Accelerazione hardware';

  @override
  String get settingsVideoAutoPlay => 'Riproduzione automatica';

  @override
  String get settingsVideoLoopModeTile => 'Modalità loop';

  @override
  String get settingsVideoLoopModeDialogTitle => 'Modalità loop';

  @override
  String get settingsVideoResumptionModeTile => 'Riprendi riproduzione';

  @override
  String get settingsVideoResumptionModeDialogTitle => 'Riprendi riproduzione';

  @override
  String get settingsVideoBackgroundMode => 'Modalità sottofondo';

  @override
  String get settingsVideoBackgroundModeDialogTitle => 'Modalità sottofondo';

  @override
  String get settingsVideoControlsTile => 'Controlli';

  @override
  String get settingsVideoControlsPageTitle => 'Controlli';

  @override
  String get settingsVideoButtonsTile => 'Pulsanti';

  @override
  String get settingsVideoGestureDoubleTapTogglePlay => 'Doppio tocco riproduci/pausa';

  @override
  String get settingsVideoGestureSideDoubleTapSeek => 'Doppio tocco sui bordi dello schermo per cercare avanti/indietro';

  @override
  String get settingsVideoGestureVerticalDragBrightnessVolume => 'Trascina su o giù per regolare luminosità/volume';

  @override
  String get settingsSubtitleThemeTile => 'Sottotitoli';

  @override
  String get settingsSubtitleThemePageTitle => 'Sottotitoli';

  @override
  String get settingsSubtitleThemeSample => 'Questo è un campione.';

  @override
  String get settingsSubtitleThemeTextAlignmentTile => 'Allineamento testo';

  @override
  String get settingsSubtitleThemeTextAlignmentDialogTitle => 'Allineamento testo';

  @override
  String get settingsSubtitleThemeTextPositionTile => 'Posizione testo';

  @override
  String get settingsSubtitleThemeTextPositionDialogTitle => 'Posizione testo';

  @override
  String get settingsSubtitleThemeTextSize => 'Dimensione testo';

  @override
  String get settingsSubtitleThemeShowOutline => 'Visualizza contorno e ombra';

  @override
  String get settingsSubtitleThemeTextColor => 'Colore testo';

  @override
  String get settingsSubtitleThemeTextOpacity => 'Opacità testo';

  @override
  String get settingsSubtitleThemeBackgroundColor => 'Colore sfondo';

  @override
  String get settingsSubtitleThemeBackgroundOpacity => 'Opacità sfondo';

  @override
  String get settingsSubtitleThemeTextAlignmentLeft => 'Sinistra';

  @override
  String get settingsSubtitleThemeTextAlignmentCenter => 'Centro';

  @override
  String get settingsSubtitleThemeTextAlignmentRight => 'Destra';

  @override
  String get settingsPrivacySectionTitle => 'Privacy';

  @override
  String get settingsAllowInstalledAppAccess => 'Consenti l’accesso all’inventario app';

  @override
  String get settingsAllowInstalledAppAccessSubtitle => 'Usato per migliorare la visualizzazione album';

  @override
  String get settingsAllowErrorReporting => 'Consenti segnalazione anonima errori';

  @override
  String get settingsSaveSearchHistory => 'Salva cronologia ricerche';

  @override
  String get settingsEnableBin => 'Usa cestino';

  @override
  String get settingsEnableBinSubtitle => 'Conserva elementi eliminati per 30 giorni';

  @override
  String get settingsDisablingBinWarningDialogMessage => 'Gli elementi nel cestino verranno eliminati permanentemente.';

  @override
  String get settingsAllowMediaManagement => 'Consenti gestione media';

  @override
  String get settingsHiddenItemsTile => 'Elementi nascosti';

  @override
  String get settingsHiddenItemsPageTitle => 'Elementi nascosti';

  @override
  String get settingsHiddenFiltersBanner => 'Le foto e i video che corrispondono ai filtri nascosti non appariranno nella collezione.';

  @override
  String get settingsHiddenFiltersEmpty => 'Nessun filtro nascosto';

  @override
  String get settingsStorageAccessTile => 'Accesso a tutti i file';

  @override
  String get settingsStorageAccessPageTitle => 'Accesso a tutti i file';

  @override
  String get settingsStorageAccessBanner => 'Alcune cartelle per modificare i file al loro interno richiedono una concessione di accesso esplicita. Puoi rivedere qui le cartelle a cui hai dato accesso in precedenza.';

  @override
  String get settingsStorageAccessEmpty => 'Nessuna autorizzazione concessa';

  @override
  String get settingsStorageAccessRevokeTooltip => 'Rifiuta autorizzazione';

  @override
  String get settingsAccessibilitySectionTitle => 'Accessibilità';

  @override
  String get settingsRemoveAnimationsTile => 'Rimuovi animazioni';

  @override
  String get settingsRemoveAnimationsDialogTitle => 'Rimuovi animazioni';

  @override
  String get settingsTimeToTakeActionTile => 'Tempo reazione';

  @override
  String get settingsAccessibilityShowPinchGestureAlternatives => 'Visualizza gesti multi touch alternativi';

  @override
  String get settingsDisplaySectionTitle => 'Schermo';

  @override
  String get settingsThemeBrightnessTile => 'Tema';

  @override
  String get settingsThemeBrightnessDialogTitle => 'Tema';

  @override
  String get settingsThemeColorHighlights => 'Colori evidenziati';

  @override
  String get settingsThemeEnableDynamicColor => 'Colori dinamici';

  @override
  String get settingsDisplayRefreshRateModeTile => 'Frequenza aggiornamento schermo';

  @override
  String get settingsDisplayRefreshRateModeDialogTitle => 'Frequenza aggiornamento';

  @override
  String get settingsDisplayUseTvInterface => 'Interfaccia Android TV';

  @override
  String get settingsLanguageSectionTitle => 'Lingua e formati';

  @override
  String get settingsLanguageTile => 'Lingua';

  @override
  String get settingsLanguagePageTitle => 'Lingua';

  @override
  String get settingsCoordinateFormatTile => 'Formato coordinate';

  @override
  String get settingsCoordinateFormatDialogTitle => 'Formato coordinate';

  @override
  String get settingsUnitSystemTile => 'Unità';

  @override
  String get settingsUnitSystemDialogTitle => 'Unità';

  @override
  String get settingsForceWesternArabicNumeralsTile => 'Forza numeri arabi';

  @override
  String get settingsScreenSaverPageTitle => 'Salvaschermo';

  @override
  String get settingsWidgetPageTitle => 'Cornice foto';

  @override
  String get settingsWidgetShowOutline => 'Contorno';

  @override
  String get settingsWidgetOpenPage => 'Quando tocchi il widget';

  @override
  String get settingsWidgetDisplayedItem => 'Elemento visualizzato';

  @override
  String get settingsCollectionTile => 'Collezione';

  @override
  String get statsPageTitle => 'Statistiche';

  @override
  String statsWithGps(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString elementi con posizione',
      one: '1 elemento con posizione',
    );
    return '$_temp0';
  }

  @override
  String get statsTopCountriesSectionTitle => 'Paesi più frequenti';

  @override
  String get statsTopStatesSectionTitle => 'Stati più frequenti';

  @override
  String get statsTopPlacesSectionTitle => 'Luoghi più frequenti';

  @override
  String get statsTopTagsSectionTitle => 'Etichette più frequenti';

  @override
  String get statsTopAlbumsSectionTitle => 'Album più frequenti';

  @override
  String get viewerOpenPanoramaButtonLabel => 'APRI PANORAMA';

  @override
  String get viewerSetWallpaperButtonLabel => 'IMPOSTA SFONDO';

  @override
  String get viewerErrorUnknown => 'Ops!';

  @override
  String get viewerErrorDoesNotExist => 'Il file non esiste più.';

  @override
  String get viewerInfoPageTitle => 'Info';

  @override
  String get viewerInfoBackToViewerTooltip => 'Torna alla visualizzazione';

  @override
  String get viewerInfoUnknown => 'sconosciuto';

  @override
  String get viewerInfoLabelDescription => 'Descrizione';

  @override
  String get viewerInfoLabelTitle => 'Titolo';

  @override
  String get viewerInfoLabelDate => 'Data';

  @override
  String get viewerInfoLabelResolution => 'Risoluzione';

  @override
  String get viewerInfoLabelSize => 'Dimensione';

  @override
  String get viewerInfoLabelUri => 'URI';

  @override
  String get viewerInfoLabelPath => 'Percorso';

  @override
  String get viewerInfoLabelDuration => 'Durata';

  @override
  String get viewerInfoLabelOwner => 'Proprietario';

  @override
  String get viewerInfoLabelCoordinates => 'Coordinate';

  @override
  String get viewerInfoLabelAddress => 'Indirizzo';

  @override
  String get mapStyleDialogTitle => 'Stile mappa';

  @override
  String get mapStyleTooltip => 'Seleziona stile mappa';

  @override
  String get mapZoomInTooltip => 'Ingrandisci';

  @override
  String get mapZoomOutTooltip => 'Riduci';

  @override
  String get mapPointNorthUpTooltip => 'Punta a nord verso l’alto';

  @override
  String get mapAttributionOsmData => 'Dati della mappa © collaboratori di [OpenStreetMap](https://www.openstreetmap.org/copyright)';

  @override
  String get mapAttributionOsmLiberty => 'Tasselli di [OpenMapTiles](https://www.openmaptiles.org/), [CC BY](http://creativecommons.org/licenses/by/4.0) • Ospitato da [OSM Americana](https://tile.ourmap.us)';

  @override
  String get mapAttributionOpenTopoMap => '[SRTM](https://www.earthdata.nasa.gov/sensors/srtm) | Tasselli di [OpenTopoMap](https://opentopomap.org/), [CC BY-SA](https://creativecommons.org/licenses/by-sa/3.0/)';

  @override
  String get mapAttributionOsmHot => 'Tasselli di [HOT](https://www.hotosm.org/) • Ospitato da [OSM France](https://openstreetmap.fr/)';

  @override
  String get mapAttributionStamen => 'Titoli di [Stamen Design](https://stamen.com), [CC BY 3.0](https://creativecommons.org/licenses/by/3.0)';

  @override
  String get openMapPageTooltip => 'Visualizza nella pagina della mappa';

  @override
  String get mapEmptyRegion => 'Nessuna immagine in questa regione';

  @override
  String get viewerInfoOpenEmbeddedFailureFeedback => 'Estrazione dati incorporati fallita';

  @override
  String get viewerInfoOpenLinkText => 'Apri';

  @override
  String get viewerInfoViewXmlLinkText => 'Visualizza XML';

  @override
  String get viewerInfoSearchFieldLabel => 'Ricerca metadati';

  @override
  String get viewerInfoSearchEmpty => 'Nessuna chiave corrispondente';

  @override
  String get viewerInfoSearchSuggestionDate => 'Data e ora';

  @override
  String get viewerInfoSearchSuggestionDescription => 'Descrizione';

  @override
  String get viewerInfoSearchSuggestionDimensions => 'Dimensioni';

  @override
  String get viewerInfoSearchSuggestionResolution => 'Risoluzione';

  @override
  String get viewerInfoSearchSuggestionRights => 'Diritti';

  @override
  String get wallpaperUseScrollEffect => 'Usa effetto di scorrimento nella schermata iniziale';

  @override
  String get tagEditorPageTitle => 'Modifica etichette';

  @override
  String get tagEditorPageNewTagFieldLabel => 'Nuova etichetta';

  @override
  String get tagEditorPageAddTagTooltip => 'Aggiungi etichetta';

  @override
  String get tagEditorSectionRecent => 'Recenti';

  @override
  String get tagEditorSectionPlaceholders => 'Segnaposti';

  @override
  String get tagEditorDiscardDialogMessage => 'Vuoi scartare le modifiche?';

  @override
  String get tagPlaceholderCountry => 'Paese';

  @override
  String get tagPlaceholderState => 'Stato';

  @override
  String get tagPlaceholderPlace => 'Luogo';

  @override
  String get panoramaEnableSensorControl => 'Abilita controllo sensore';

  @override
  String get panoramaDisableSensorControl => 'Disabilita controllo sensore';

  @override
  String get sourceViewerPageTitle => 'Codice sorgente';

  @override
  String get filePickerShowHiddenFiles => 'Visualizza file nascosti';

  @override
  String get filePickerDoNotShowHiddenFiles => 'Non visualizzare i file nascosti';

  @override
  String get filePickerOpenFrom => 'Apri da';

  @override
  String get filePickerNoItems => 'Nessun elemento';

  @override
  String get filePickerUseThisFolder => 'Usa questa cartella';
}
