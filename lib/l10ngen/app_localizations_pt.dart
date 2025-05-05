// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'Aves';

  @override
  String get welcomeMessage => 'Bem-vindo ao Aves';

  @override
  String get welcomeOptional => 'Opcional';

  @override
  String get welcomeTermsToggle => 'Eu concordo com os Termos e Condições';

  @override
  String itemCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString itens',
      one: '$countString item',
    );
    return '$_temp0';
  }

  @override
  String columnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count colunas',
      one: '$count coluna',
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
      other: '$countString dias',
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
  String get createButtonLabel => 'CREATE';

  @override
  String get deleteButtonLabel => 'EXCLUIR';

  @override
  String get nextButtonLabel => 'SEGUINTE';

  @override
  String get showButtonLabel => 'MOSTRAR';

  @override
  String get hideButtonLabel => 'OCULTAR';

  @override
  String get continueButtonLabel => 'CONTINUAR';

  @override
  String get saveCopyButtonLabel => 'SALVAR CÓPIA';

  @override
  String get applyTooltip => 'Aplicar';

  @override
  String get cancelTooltip => 'Cancelar';

  @override
  String get changeTooltip => 'Mudar';

  @override
  String get clearTooltip => 'Limpar';

  @override
  String get previousTooltip => 'Anterior';

  @override
  String get nextTooltip => 'Seguinte';

  @override
  String get showTooltip => 'Mostrar';

  @override
  String get hideTooltip => 'Ocultar';

  @override
  String get actionRemove => 'Remover';

  @override
  String get resetTooltip => 'Redefinir';

  @override
  String get saveTooltip => 'Salvar';

  @override
  String get stopTooltip => 'Parar';

  @override
  String get pickTooltip => 'Escolher';

  @override
  String get doubleBackExitMessage => 'Toque “voltar” novamente para sair.';

  @override
  String get doNotAskAgain => 'Não perguntar novamente';

  @override
  String get sourceStateLoading => 'Carregando';

  @override
  String get sourceStateCataloguing => 'Catalogando';

  @override
  String get sourceStateLocatingCountries => 'Localizando países';

  @override
  String get sourceStateLocatingPlaces => 'Localizando lugares';

  @override
  String get chipActionDelete => 'Excluir';

  @override
  String get chipActionRemove => 'Remover';

  @override
  String get chipActionShowCollection => 'Mostrar na Coleção';

  @override
  String get chipActionGoToAlbumPage => 'Mostrar nos Álbuns';

  @override
  String get chipActionGoToCountryPage => 'Mostrar nos Países';

  @override
  String get chipActionGoToPlacePage => 'Exibir em Lugares';

  @override
  String get chipActionGoToTagPage => 'Mostrar nas Etiquetas';

  @override
  String get chipActionGoToExplorerPage => 'Mostrar no Explorador';

  @override
  String get chipActionDecompose => 'Separar';

  @override
  String get chipActionFilterOut => 'Filtrar dentro';

  @override
  String get chipActionFilterIn => 'Filtrar fora';

  @override
  String get chipActionHide => 'Ocultar';

  @override
  String get chipActionLock => 'Bloquear';

  @override
  String get chipActionPin => 'Fixar no topo';

  @override
  String get chipActionUnpin => 'Desafixar do topo';

  @override
  String get chipActionGroup => 'Group';

  @override
  String get chipActionRename => 'Renomear';

  @override
  String get chipActionSetCover => 'Definir capa';

  @override
  String get chipActionShowCountryStates => 'Mostrar estados';

  @override
  String get chipActionCreateGroup => 'Create group';

  @override
  String get chipActionCreateAlbum => 'Criar álbum';

  @override
  String get chipActionCreateVault => 'Criar cofre';

  @override
  String get chipActionConfigureVault => 'Configurar cofre';

  @override
  String get entryActionCopyToClipboard => 'Copiar para área de transferência';

  @override
  String get entryActionDelete => 'Excluir';

  @override
  String get entryActionConvert => 'Converter';

  @override
  String get entryActionExport => 'Exportar';

  @override
  String get entryActionInfo => 'Informações';

  @override
  String get entryActionRename => 'Renomear';

  @override
  String get entryActionRestore => 'Restaurar';

  @override
  String get entryActionRotateCCW => 'Rotacionar para esquerda';

  @override
  String get entryActionRotateCW => 'Rotacionar para direita';

  @override
  String get entryActionFlip => 'Virar horizontalmente';

  @override
  String get entryActionPrint => 'Imprimir';

  @override
  String get entryActionShare => 'Compartilhar';

  @override
  String get entryActionShareImageOnly => 'Compartilhar apenas imagem';

  @override
  String get entryActionShareVideoOnly => 'Compartilhar apenas video';

  @override
  String get entryActionViewSource => 'Ver origem';

  @override
  String get entryActionShowGeoTiffOnMap => 'Mostrar como sobreposição de mapa';

  @override
  String get entryActionConvertMotionPhotoToStillImage => 'Converter para imagem estática';

  @override
  String get entryActionViewMotionPhotoVideo => 'Abrir vídeo';

  @override
  String get entryActionEdit => 'Editar';

  @override
  String get entryActionOpen => 'Abrir com';

  @override
  String get entryActionSetAs => 'Definir como';

  @override
  String get entryActionCast => 'Transmitir';

  @override
  String get entryActionOpenMap => 'Mostrar no aplicativo de mapa';

  @override
  String get entryActionRotateScreen => 'Girar a tela';

  @override
  String get entryActionAddFavourite => 'Adicionar aos favoritos';

  @override
  String get entryActionRemoveFavourite => 'Remova dos favoritos';

  @override
  String get videoActionCaptureFrame => 'Capturar quadro';

  @override
  String get videoActionMute => 'Mudo';

  @override
  String get videoActionUnmute => 'Ativar mudo';

  @override
  String get videoActionPause => 'Pausa';

  @override
  String get videoActionPlay => 'Toque';

  @override
  String get videoActionReplay10 => 'Retroceda 10 segundos';

  @override
  String get videoActionSkip10 => 'Avançar 10 segundos';

  @override
  String get videoActionShowPreviousFrame => 'Mostrar quadro anterior';

  @override
  String get videoActionShowNextFrame => 'Mostrar próximo quadro';

  @override
  String get videoActionSelectStreams => 'Selecione as faixas';

  @override
  String get videoActionSetSpeed => 'Velocidade de reprodução';

  @override
  String get videoActionABRepeat => 'Repetição A-B';

  @override
  String get videoRepeatActionSetStart => 'Definir início';

  @override
  String get videoRepeatActionSetEnd => 'Definir fim';

  @override
  String get viewerActionSettings => 'Configurações';

  @override
  String get viewerActionLock => 'Bloquear visualizador';

  @override
  String get viewerActionUnlock => 'Desbloquear visualizador';

  @override
  String get slideshowActionResume => 'Retomar';

  @override
  String get slideshowActionShowInCollection => 'Mostrar na Coleção';

  @override
  String get entryInfoActionEditDate => 'Editar data e hora';

  @override
  String get entryInfoActionEditLocation => 'Editar localização';

  @override
  String get entryInfoActionEditTitleDescription => 'Editar título e descrição';

  @override
  String get entryInfoActionEditRating => 'Editar classificação';

  @override
  String get entryInfoActionEditTags => 'Editar etiquetas';

  @override
  String get entryInfoActionRemoveMetadata => 'Remover metadados';

  @override
  String get entryInfoActionExportMetadata => 'Exportar metadados';

  @override
  String get entryInfoActionRemoveLocation => 'Remover localização';

  @override
  String get editorActionTransform => 'Transformar';

  @override
  String get editorTransformCrop => 'Cortar';

  @override
  String get editorTransformRotate => 'Girar';

  @override
  String get cropAspectRatioFree => 'Livre';

  @override
  String get cropAspectRatioOriginal => 'Original';

  @override
  String get cropAspectRatioSquare => 'Quadrada';

  @override
  String get filterAspectRatioLandscapeLabel => 'Paisagem';

  @override
  String get filterAspectRatioPortraitLabel => 'Retrato';

  @override
  String get filterBinLabel => 'Lixeira';

  @override
  String get filterFavouriteLabel => 'Favorito';

  @override
  String get filterNoDateLabel => 'Sem data';

  @override
  String get filterNoAddressLabel => 'Sem endereço';

  @override
  String get filterLocatedLabel => 'Localizado';

  @override
  String get filterNoLocationLabel => 'Não localizado';

  @override
  String get filterNoRatingLabel => 'Sem classificação';

  @override
  String get filterTaggedLabel => 'Marcado';

  @override
  String get filterNoTagLabel => 'Sem etiqueta';

  @override
  String get filterNoTitleLabel => 'Sem título';

  @override
  String get filterOnThisDayLabel => 'Neste dia';

  @override
  String get filterRecentlyAddedLabel => 'Adicionado recentemente';

  @override
  String get filterRatingRejectedLabel => 'Rejeitado';

  @override
  String get filterTypeAnimatedLabel => 'Animado';

  @override
  String get filterTypeMotionPhotoLabel => 'Foto em movimento';

  @override
  String get filterTypePanoramaLabel => 'Panorama';

  @override
  String get filterTypeRawLabel => 'Raw';

  @override
  String get filterTypeSphericalVideoLabel => '360° vídeo';

  @override
  String get filterTypeGeotiffLabel => 'GeoTIFF';

  @override
  String get filterMimeImageLabel => 'Imagem';

  @override
  String get filterMimeVideoLabel => 'Vídeo';

  @override
  String get accessibilityAnimationsRemove => 'Prevenir efeitos de tela';

  @override
  String get accessibilityAnimationsKeep => 'Manter efeitos de tela';

  @override
  String get albumTierNew => 'Novo';

  @override
  String get albumTierPinned => 'Fixada';

  @override
  String get albumTierGroups => 'Groups';

  @override
  String get albumTierSpecial => 'Comum';

  @override
  String get albumTierApps => 'Aplicativos';

  @override
  String get albumTierVaults => 'Cofres';

  @override
  String get albumTierDynamic => 'Dinâmico';

  @override
  String get albumTierRegular => 'Outras';

  @override
  String get coordinateFormatDms => 'DMS';

  @override
  String get coordinateFormatDdm => 'DDM';

  @override
  String get coordinateFormatDecimal => 'Graus decimais';

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
  String get displayRefreshRatePreferHighest => 'Taxa mais alta';

  @override
  String get displayRefreshRatePreferLowest => 'Taxa mais baixa';

  @override
  String get keepScreenOnNever => 'Nunca';

  @override
  String get keepScreenOnVideoPlayback => 'Durante a reprodução do video';

  @override
  String get keepScreenOnViewerOnly => 'Somente página do visualizador';

  @override
  String get keepScreenOnAlways => 'Sempre';

  @override
  String get lengthUnitPixel => 'pixels';

  @override
  String get lengthUnitPercent => '%';

  @override
  String get mapStyleGoogleNormal => 'Google Maps';

  @override
  String get mapStyleGoogleHybrid => 'Google Maps (Híbrido)';

  @override
  String get mapStyleGoogleTerrain => 'Google Maps (Terreno)';

  @override
  String get mapStyleOsmLiberty => 'OSM Liberty';

  @override
  String get mapStyleOpenTopoMap => 'OpenTopoMap';

  @override
  String get mapStyleOsmHot => 'OSM Humanitário';

  @override
  String get mapStyleStamenWatercolor => 'Stamen Watercolor (Aquarela)';

  @override
  String get maxBrightnessNever => 'Nunca';

  @override
  String get maxBrightnessAlways => 'Sempre';

  @override
  String get nameConflictStrategyRename => 'Renomear';

  @override
  String get nameConflictStrategyReplace => 'Substituir';

  @override
  String get nameConflictStrategySkip => 'Pular';

  @override
  String get overlayHistogramNone => 'Nenhum';

  @override
  String get overlayHistogramRGB => 'RGB';

  @override
  String get overlayHistogramLuminance => 'Luminância';

  @override
  String get subtitlePositionTop => 'Topo';

  @override
  String get subtitlePositionBottom => 'Fundo';

  @override
  String get themeBrightnessLight => 'Claro';

  @override
  String get themeBrightnessDark => 'Escuro';

  @override
  String get themeBrightnessBlack => 'Preto';

  @override
  String get unitSystemMetric => 'Métrica';

  @override
  String get unitSystemImperial => 'Imperial';

  @override
  String get vaultLockTypePattern => 'Padrão';

  @override
  String get vaultLockTypePin => 'PIN';

  @override
  String get vaultLockTypePassword => 'Senha';

  @override
  String get settingsVideoEnablePip => 'Picture-in-picture';

  @override
  String get videoControlsPlayOutside => 'Abrir com outro player';

  @override
  String get videoLoopModeNever => 'Nunca';

  @override
  String get videoLoopModeShortOnly => 'Apenas vídeos curtos';

  @override
  String get videoLoopModeAlways => 'Sempre';

  @override
  String get videoPlaybackSkip => 'Pular';

  @override
  String get videoPlaybackMuted => 'Reproduzir sem som';

  @override
  String get videoPlaybackWithSound => 'Reproduzir com som';

  @override
  String get videoResumptionModeNever => 'Nunca';

  @override
  String get videoResumptionModeAlways => 'Sempre';

  @override
  String get viewerTransitionSlide => 'Deslizar';

  @override
  String get viewerTransitionParallax => 'Paralaxe';

  @override
  String get viewerTransitionFade => 'Desvaneça';

  @override
  String get viewerTransitionZoomIn => 'Mais zoom';

  @override
  String get viewerTransitionNone => 'Nenhum';

  @override
  String get wallpaperTargetHome => 'Tela inicial';

  @override
  String get wallpaperTargetLock => 'Tela de bloqueio';

  @override
  String get wallpaperTargetHomeLock => 'Telas iniciais e de bloqueio';

  @override
  String get widgetDisplayedItemRandom => 'Aleatório';

  @override
  String get widgetDisplayedItemMostRecent => 'Mais recente';

  @override
  String get widgetOpenPageHome => 'Abrir inicial';

  @override
  String get widgetOpenPageCollection => 'Abrir coleção';

  @override
  String get widgetOpenPageViewer => 'Abrir visualizador';

  @override
  String get widgetTapUpdateWidget => 'Atualizar o widget';

  @override
  String get storageVolumeDescriptionFallbackPrimary => 'Armazenamento interno';

  @override
  String get storageVolumeDescriptionFallbackNonPrimary => 'cartão SD';

  @override
  String get rootDirectoryDescription => 'diretório raiz';

  @override
  String otherDirectoryDescription(String name) {
    return 'diretório “$name”';
  }

  @override
  String storageAccessDialogMessage(String directory, String volume) {
    return 'Selecione o $directory de “$volume” na próxima tela para dar acesso a este aplicativo.';
  }

  @override
  String restrictedAccessDialogMessage(String directory, String volume) {
    return 'Este aplicativo não tem permissão para modificar arquivos no $directory de “$volume”.\n\nUse um gerenciador de arquivos ou aplicativo de galeria pré-instalado para mover os itens para outro diretório.';
  }

  @override
  String notEnoughSpaceDialogMessage(String neededSize, String freeSize, String volume) {
    return 'Esta operação precisa $neededSize de espaço livre em “$volume” para completar, mas só $freeSize restantes.';
  }

  @override
  String get missingSystemFilePickerDialogMessage => 'O seletor de arquivos do sistema está ausente ou desabilitado. Por favor, habilite e tente novamente.';

  @override
  String unsupportedTypeDialogMessage(int count, String types) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Esta operação não é suportada para itens dos seguintes tipos: $types.',
      one: 'Esta operação não é suportada para itens do seguinte tipo: $types.',
    );
    return '$_temp0';
  }

  @override
  String get nameConflictDialogSingleSourceMessage => 'Alguns arquivos na pasta de destino têm o mesmo nome.';

  @override
  String get nameConflictDialogMultipleSourceMessage => 'Alguns arquivos têm o mesmo nome.';

  @override
  String get addShortcutDialogLabel => 'Rótulo de atalho';

  @override
  String get addShortcutButtonLabel => 'ADICIONAR';

  @override
  String get noMatchingAppDialogMessage => 'Não há aplicativos que possam lidar com isso.';

  @override
  String binEntriesConfirmationDialogMessage(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mova estes $countString itens para a lixeira?',
      one: 'Mover esse item para a lixeira?',
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
      other: 'Tem certeza de que deseja excluir estes $countString itens?',
      one: 'Tem certeza de que deseja excluir este item?',
    );
    return '$_temp0';
  }

  @override
  String get moveUndatedConfirmationDialogMessage => 'Salvar as datas dos itens antes de continuar?';

  @override
  String get moveUndatedConfirmationDialogSetDate => 'Definir data';

  @override
  String videoResumeDialogMessage(String time) {
    return 'Deseja continuar jogando em $time?';
  }

  @override
  String get videoStartOverButtonLabel => 'RECOMEÇAR';

  @override
  String get videoResumeButtonLabel => 'RETOMAR';

  @override
  String get setCoverDialogLatest => 'Último item';

  @override
  String get setCoverDialogAuto => 'Auto';

  @override
  String get setCoverDialogCustom => 'Personalizado';

  @override
  String get hideFilterConfirmationDialogMessage => 'Fotos e vídeos correspondentes serão ocultados da sua coleção. Você pode mostrá-los novamente nas configurações de “Privacidade”.\n\nTem certeza de que deseja ocultá-los?';

  @override
  String get newAlbumDialogTitle => 'Novo álbum';

  @override
  String get newAlbumDialogNameLabel => 'Nome do álbum';

  @override
  String get newAlbumDialogAlbumAlreadyExistsHelper => 'O álbum já existe';

  @override
  String get newAlbumDialogNameLabelAlreadyExistsHelper => 'O diretório já existe';

  @override
  String get newAlbumDialogStorageLabel => 'Armazenar:';

  @override
  String get newDynamicAlbumDialogTitle => 'Novo Álbum Dinâmico';

  @override
  String get dynamicAlbumAlreadyExists => 'O álbum dinâmico já existe';

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
  String get newVaultWarningDialogMessage => 'Os itens nos cofres estão disponíveis apenas para este aplicativo e nenhum outro.\n\nSe você desinstalar este aplicativo ou limpar os dados do aplicativo, perderá todos esses itens.';

  @override
  String get newVaultDialogTitle => 'Novo Cofre';

  @override
  String get configureVaultDialogTitle => 'Configurar Cofre';

  @override
  String get vaultDialogLockModeWhenScreenOff => 'Bloquear quando a tela desligar';

  @override
  String get vaultDialogLockTypeLabel => 'Tipo de bloqueio';

  @override
  String get patternDialogEnter => 'Inserir padrão';

  @override
  String get patternDialogConfirm => 'Confirmar padrão';

  @override
  String get pinDialogEnter => 'Digite o PIN';

  @override
  String get pinDialogConfirm => 'Confirme o PIN';

  @override
  String get passwordDialogEnter => 'Digite a senha';

  @override
  String get passwordDialogConfirm => 'Confirmar senha';

  @override
  String get authenticateToConfigureVault => 'Autentique-se para configurar o cofre';

  @override
  String get authenticateToUnlockVault => 'Autentique-se para desbloquear o cofre';

  @override
  String get vaultBinUsageDialogMessage => 'Alguns cofres estão usando a lixeira.';

  @override
  String get renameAlbumDialogLabel => 'Novo nome';

  @override
  String get renameAlbumDialogLabelAlreadyExistsHelper => 'O diretório já existe';

  @override
  String get renameEntrySetPageTitle => 'Renomear';

  @override
  String get renameEntrySetPagePatternFieldLabel => 'Padrão de nomeação';

  @override
  String get renameEntrySetPageInsertTooltip => 'Inserir campo';

  @override
  String get renameEntrySetPagePreviewSectionTitle => 'Visualizar';

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
      other: 'Tem certeza de que deseja excluir este álbum e seus $countString itens?',
      one: 'Tem certeza de que deseja excluir este álbum e seu item?',
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
      other: 'Tem certeza de que deseja excluir estes álbuns e seus $countString itens?',
      one: 'Tem certeza de que deseja excluir estes álbuns e seus itens?',
    );
    return '$_temp0';
  }

  @override
  String get exportEntryDialogFormat => 'Formato:';

  @override
  String get exportEntryDialogWidth => 'Largura';

  @override
  String get exportEntryDialogHeight => 'Altura';

  @override
  String get exportEntryDialogQuality => 'Qualidade';

  @override
  String get exportEntryDialogWriteMetadata => 'Escrever metadados';

  @override
  String get renameEntryDialogLabel => 'Novo nome';

  @override
  String get editEntryDialogCopyFromItem => 'Copiar de outro item';

  @override
  String get editEntryDialogTargetFieldsHeader => 'Campos para modificar';

  @override
  String get editEntryDateDialogTitle => 'Data e hora';

  @override
  String get editEntryDateDialogSetCustom => 'Definir data personalizada';

  @override
  String get editEntryDateDialogCopyField => 'Copiar de outra data';

  @override
  String get editEntryDateDialogExtractFromTitle => 'Extrair do título';

  @override
  String get editEntryDateDialogShift => 'Mudança';

  @override
  String get editEntryDateDialogSourceFileModifiedDate => 'Data de modificação do arquivo';

  @override
  String get durationDialogHours => 'Horas';

  @override
  String get durationDialogMinutes => 'Minutos';

  @override
  String get durationDialogSeconds => 'Segundos';

  @override
  String get editEntryLocationDialogTitle => 'Localização';

  @override
  String get editEntryLocationDialogSetCustom => 'Definir local personalizado';

  @override
  String get editEntryLocationDialogChooseOnMap => 'Escolha no mapa';

  @override
  String get editEntryLocationDialogImportGpx => 'Importar GPX';

  @override
  String get editEntryLocationDialogLatitude => 'Latitude';

  @override
  String get editEntryLocationDialogLongitude => 'Longitude';

  @override
  String get editEntryLocationDialogTimeShift => 'Salto temporal';

  @override
  String get locationPickerUseThisLocationButton => 'Usar essa localização';

  @override
  String get editEntryRatingDialogTitle => 'Avaliação';

  @override
  String get removeEntryMetadataDialogTitle => 'Remoção de metadados';

  @override
  String get removeEntryMetadataDialogAll => 'Todos';

  @override
  String get removeEntryMetadataDialogMore => 'Mais';

  @override
  String get removeEntryMetadataMotionPhotoXmpWarningDialogMessage => 'XMP é necessário para reproduzir o vídeo dentro de uma foto em movimento.\n\nTem certeza de que deseja removê-lo?';

  @override
  String get videoSpeedDialogLabel => 'Velocidade de reprodução';

  @override
  String get videoStreamSelectionDialogVideo => 'Video';

  @override
  String get videoStreamSelectionDialogAudio => 'Áudio';

  @override
  String get videoStreamSelectionDialogText => 'Legendas';

  @override
  String get videoStreamSelectionDialogOff => 'Fora';

  @override
  String get videoStreamSelectionDialogTrack => 'Acompanhar';

  @override
  String get videoStreamSelectionDialogNoSelection => 'Não há outras faixas.';

  @override
  String get genericSuccessFeedback => 'Feito!';

  @override
  String get genericFailureFeedback => 'Falhou';

  @override
  String get genericDangerWarningDialogMessage => 'Tem certeza?';

  @override
  String get tooManyItemsErrorDialogMessage => 'Tente novamente com menos itens.';

  @override
  String get menuActionConfigureView => 'Visualizar';

  @override
  String get menuActionSelect => 'Selecionar';

  @override
  String get menuActionSelectAll => 'Selecionar tudo';

  @override
  String get menuActionSelectNone => 'Selecione nenhum';

  @override
  String get menuActionMap => 'Mapa';

  @override
  String get menuActionSlideshow => 'Apresentação de slides';

  @override
  String get menuActionStats => 'Estatísticas';

  @override
  String get viewDialogSortSectionTitle => 'Organizar';

  @override
  String get viewDialogGroupSectionTitle => 'Grupo';

  @override
  String get viewDialogLayoutSectionTitle => 'Layout';

  @override
  String get viewDialogReverseSortOrder => 'Ordem de classificação inversa';

  @override
  String get tileLayoutMosaic => 'Mosaico';

  @override
  String get tileLayoutGrid => 'Rede';

  @override
  String get tileLayoutList => 'Lista';

  @override
  String get castDialogTitle => 'Dispositivos para Transmitir';

  @override
  String get coverDialogTabCover => 'Capa';

  @override
  String get coverDialogTabApp => 'Aplicativo';

  @override
  String get coverDialogTabColor => 'Cor';

  @override
  String get appPickDialogTitle => 'Escolha o aplicativo';

  @override
  String get appPickDialogNone => 'Nenhum';

  @override
  String get aboutPageTitle => 'Sobre';

  @override
  String get aboutLinkLicense => 'Licença';

  @override
  String get aboutLinkPolicy => 'Política de Privacidade';

  @override
  String get aboutBugSectionTitle => 'Relatório de erro';

  @override
  String get aboutBugSaveLogInstruction => 'Salvar registros de aplicativos em um arquivo';

  @override
  String get aboutBugCopyInfoInstruction => 'Copiar informações do sistema';

  @override
  String get aboutBugCopyInfoButton => 'Copiar';

  @override
  String get aboutBugReportInstruction => 'Relatório no GitHub com os logs e informações do sistema';

  @override
  String get aboutBugReportButton => 'Relatório';

  @override
  String get aboutDataUsageSectionTitle => 'Uso de Dados';

  @override
  String get aboutDataUsageData => 'Dados';

  @override
  String get aboutDataUsageCache => 'Cache';

  @override
  String get aboutDataUsageDatabase => 'Banco de Dados';

  @override
  String get aboutDataUsageMisc => 'Outros';

  @override
  String get aboutDataUsageInternal => 'Interno';

  @override
  String get aboutDataUsageExternal => 'Externo';

  @override
  String get aboutDataUsageClearCache => 'Limpar o cache';

  @override
  String get aboutCreditsSectionTitle => 'Créditos';

  @override
  String get aboutCreditsWorldAtlas1 => 'Este aplicativo usa um arquivo de TopoJSON';

  @override
  String get aboutCreditsWorldAtlas2 => 'sob licença ISC.';

  @override
  String get aboutTranslatorsSectionTitle => 'Tradutores';

  @override
  String get aboutLicensesSectionTitle => 'Licenças de código aberto';

  @override
  String get aboutLicensesBanner => 'Este aplicativo usa os seguintes pacotes e bibliotecas de código aberto.';

  @override
  String get aboutLicensesAndroidLibrariesSectionTitle => 'Bibliotecas Android';

  @override
  String get aboutLicensesFlutterPluginsSectionTitle => 'Plug-ins Flutter';

  @override
  String get aboutLicensesFlutterPackagesSectionTitle => 'Pacotes Flutter';

  @override
  String get aboutLicensesDartPackagesSectionTitle => 'Pacotes Dart';

  @override
  String get aboutLicensesShowAllButtonLabel => 'Mostrar todas as licenças';

  @override
  String get policyPageTitle => 'Política de Privacidade';

  @override
  String get collectionPageTitle => 'Coleção';

  @override
  String get collectionPickPageTitle => 'Escolher';

  @override
  String get collectionSelectPageTitle => 'Selecionar itens';

  @override
  String get collectionActionShowTitleSearch => 'Mostrar filtro de título';

  @override
  String get collectionActionHideTitleSearch => 'Ocultar filtro de título';

  @override
  String get collectionActionAddDynamicAlbum => 'Adicionar álbum dinâmico';

  @override
  String get collectionActionAddShortcut => 'Adicionar atalho';

  @override
  String get collectionActionSetHome => 'Definir como início';

  @override
  String get collectionActionEmptyBin => 'Caixa vazia';

  @override
  String get collectionActionCopy => 'Copiar para o álbum';

  @override
  String get collectionActionMove => 'Mover para o álbum';

  @override
  String get collectionActionRescan => 'Reexaminar';

  @override
  String get collectionActionEdit => 'Editar';

  @override
  String get collectionSearchTitlesHintText => 'Pesquisar títulos';

  @override
  String get collectionGroupAlbum => 'Por álbum';

  @override
  String get collectionGroupMonth => 'Por mês';

  @override
  String get collectionGroupDay => 'Por dia';

  @override
  String get sectionNone => 'No sections';

  @override
  String get sectionUnknown => 'Desconhecido';

  @override
  String get dateToday => 'Hoje';

  @override
  String get dateYesterday => 'Ontem';

  @override
  String get dateThisMonth => 'Este mês';

  @override
  String collectionDeleteFailureFeedback(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Falha ao excluir $countString itens',
      one: 'Falha ao excluir 1 item',
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
      other: 'Falha ao copiar $countString itens',
      one: 'Falha ao copiar 1 item',
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
      other: 'Falha ao mover $countString itens',
      one: 'Falha ao mover 1 item',
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
      other: 'Falha ao renomear $countString itens',
      one: 'Falhei em renomear 1 item',
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
      other: 'Falha ao editar $countString itens',
      one: 'Falha ao editar 1 item',
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
      other: 'Falha ao exportar $countString páginas',
      one: 'Falha ao exportar 1 página',
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
      other: 'Copiado $countString itens',
      one: '1 item copiado',
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
      other: 'Mudou-se $countString itens',
      one: '1 item movido',
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
      other: 'Renomeado $countString itens',
      one: '1 item renomeado',
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
      other: 'Editado $countString itens',
      one: 'Editado 1 item',
    );
    return '$_temp0';
  }

  @override
  String get collectionEmptyFavourites => 'Nenhum favorito';

  @override
  String get collectionEmptyVideos => 'Nenhum video';

  @override
  String get collectionEmptyImages => 'Nenhuma imagem';

  @override
  String get collectionEmptyGrantAccessButtonLabel => 'Garantir acesso';

  @override
  String get collectionSelectSectionTooltip => 'Selecionar seção';

  @override
  String get collectionDeselectSectionTooltip => 'Desmarcar seção';

  @override
  String get drawerAboutButton => 'Sobre';

  @override
  String get drawerSettingsButton => 'Configurações';

  @override
  String get drawerCollectionAll => 'Toda a coleção';

  @override
  String get drawerCollectionFavourites => 'Favoritos';

  @override
  String get drawerCollectionImages => 'Imagens';

  @override
  String get drawerCollectionVideos => 'Vídeos';

  @override
  String get drawerCollectionAnimated => 'Animado';

  @override
  String get drawerCollectionMotionPhotos => 'Fotos em movimento';

  @override
  String get drawerCollectionPanoramas => 'Panoramas';

  @override
  String get drawerCollectionRaws => 'Fotos Raw';

  @override
  String get drawerCollectionSphericalVideos => 'Vídeos 360°';

  @override
  String get drawerAlbumPage => 'Álbuns';

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
  String get sortByItemCount => 'Por contagem de itens';

  @override
  String get sortBySize => 'Por tamanho';

  @override
  String get sortByAlbumFileName => 'Por álbum e nome de arquivo';

  @override
  String get sortByRating => 'Por classificação';

  @override
  String get sortByDuration => 'Por duração';

  @override
  String get sortByPath => 'Pelo caminho';

  @override
  String get sortOrderNewestFirst => 'Os mais novos primeiro';

  @override
  String get sortOrderOldestFirst => 'Mais velhos primeiro';

  @override
  String get sortOrderAtoZ => 'A a Z';

  @override
  String get sortOrderZtoA => 'Z a A';

  @override
  String get sortOrderHighestFirst => 'Mais alto primeiro';

  @override
  String get sortOrderLowestFirst => 'Mais baixo primeiro';

  @override
  String get sortOrderLargestFirst => 'Maior primeiro';

  @override
  String get sortOrderSmallestFirst => 'Menor primeiro';

  @override
  String get sortOrderShortestFirst => 'Mais curtos primeiro';

  @override
  String get sortOrderLongestFirst => 'Mais longos primeiro';

  @override
  String get albumGroupTier => 'Por nível';

  @override
  String get albumGroupType => 'Por tipo';

  @override
  String get albumGroupVolume => 'Por volume de armazenamento';

  @override
  String get albumMimeTypeMixed => 'Misturado';

  @override
  String get albumPickPageTitleCopy => 'Copiar para o álbum';

  @override
  String get albumPickPageTitleExport => 'Exportar para o álbum';

  @override
  String get albumPickPageTitleMove => 'Mover para o álbum';

  @override
  String get albumPickPageTitlePick => 'Escolher álbum';

  @override
  String get albumCamera => 'Câmera';

  @override
  String get albumDownload => 'Download';

  @override
  String get albumScreenshots => 'Capturas de tela';

  @override
  String get albumScreenRecordings => 'Gravações de tela';

  @override
  String get albumVideoCaptures => 'Capturas de vídeo';

  @override
  String get albumPageTitle => 'Álbuns';

  @override
  String get albumEmpty => 'Nenhum álbum';

  @override
  String get createAlbumButtonLabel => 'CRIA';

  @override
  String get newFilterBanner => 'novo';

  @override
  String get countryPageTitle => 'Países';

  @override
  String get countryEmpty => 'Nenhum país';

  @override
  String get statePageTitle => 'Estados';

  @override
  String get stateEmpty => 'Nenhum estado';

  @override
  String get placePageTitle => 'Lugares';

  @override
  String get placeEmpty => 'Sem lugares';

  @override
  String get tagPageTitle => 'Etiquetas';

  @override
  String get tagEmpty => 'Sem etiquetas';

  @override
  String get binPageTitle => 'Lixeira';

  @override
  String get explorerPageTitle => 'Explorador';

  @override
  String get explorerActionSelectStorageVolume => 'Selecione o armazenamento';

  @override
  String get selectStorageVolumeDialogTitle => 'Selecione o Armazenamento';

  @override
  String get searchCollectionFieldHint => 'Pesquisar coleção';

  @override
  String get searchRecentSectionTitle => 'Recente';

  @override
  String get searchDateSectionTitle => 'Data';

  @override
  String get searchFormatSectionTitle => 'Formatos';

  @override
  String get searchAlbumsSectionTitle => 'Álbuns';

  @override
  String get searchCountriesSectionTitle => 'Países';

  @override
  String get searchStatesSectionTitle => 'Estados';

  @override
  String get searchPlacesSectionTitle => 'Locais';

  @override
  String get searchTagsSectionTitle => 'Etiquetas';

  @override
  String get searchRatingSectionTitle => 'Classificações';

  @override
  String get searchMetadataSectionTitle => 'Metadados';

  @override
  String get settingsPageTitle => 'Configurações';

  @override
  String get settingsSystemDefault => 'Sistema';

  @override
  String get settingsDefault => 'Padrão';

  @override
  String get settingsDisabled => 'Desativada';

  @override
  String get settingsAskEverytime => 'Perguntar sempre';

  @override
  String get settingsModificationWarningDialogMessage => 'Outras configurações serão modificadas.';

  @override
  String get settingsSearchFieldLabel => 'Pesquisar configuração';

  @override
  String get settingsSearchEmpty => 'Nenhuma configuração correspondente';

  @override
  String get settingsActionExport => 'Exportar';

  @override
  String get settingsActionExportDialogTitle => 'Exportar';

  @override
  String get settingsActionImport => 'Importar';

  @override
  String get settingsActionImportDialogTitle => 'Importar';

  @override
  String get appExportCovers => 'Capas';

  @override
  String get appExportDynamicAlbums => 'Álbuns dinâmicos';

  @override
  String get appExportFavourites => 'Favoritos';

  @override
  String get appExportSettings => 'Configurações';

  @override
  String get settingsNavigationSectionTitle => 'Navegação';

  @override
  String get settingsHomeTile => 'Início';

  @override
  String get settingsHomeDialogTitle => 'Início';

  @override
  String get setHomeCustom => 'Personalizada';

  @override
  String get settingsShowBottomNavigationBar => 'Mostrar barra de navegação inferior';

  @override
  String get settingsKeepScreenOnTile => 'Manter a tela ligada';

  @override
  String get settingsKeepScreenOnDialogTitle => 'Manter a tela ligada';

  @override
  String get settingsDoubleBackExit => 'Toque em “voltar” duas vezes para sair';

  @override
  String get settingsConfirmationTile => 'Caixas de diálogo de confirmação';

  @override
  String get settingsConfirmationDialogTitle => 'Caixas de diálogo de confirmação';

  @override
  String get settingsConfirmationBeforeDeleteItems => 'Pergunte antes de excluir itens para sempre';

  @override
  String get settingsConfirmationBeforeMoveToBinItems => 'Pergunte antes de mover itens para a lixeira';

  @override
  String get settingsConfirmationBeforeMoveUndatedItems => 'Pergunte antes de mover itens sem data de metadados';

  @override
  String get settingsConfirmationAfterMoveToBinItems => 'Mostrar mensagem depois de mover itens para a lixeira';

  @override
  String get settingsConfirmationVaultDataLoss => 'Mostrar aviso de perda de dados do cofre';

  @override
  String get settingsNavigationDrawerTile => 'Menu de navegação';

  @override
  String get settingsNavigationDrawerEditorPageTitle => 'Menu de navegação';

  @override
  String get settingsNavigationDrawerBanner => 'Toque e segure para mover e reordenar os itens do menu.';

  @override
  String get settingsNavigationDrawerTabTypes => 'Tipos';

  @override
  String get settingsNavigationDrawerTabAlbums => 'Álbuns';

  @override
  String get settingsNavigationDrawerTabPages => 'Páginas';

  @override
  String get settingsNavigationDrawerAddAlbum => 'Adicionar álbum';

  @override
  String get settingsThumbnailSectionTitle => 'Miniaturas';

  @override
  String get settingsThumbnailOverlayTile => 'Sobreposição';

  @override
  String get settingsThumbnailOverlayPageTitle => 'Sobreposição';

  @override
  String get settingsThumbnailShowHdrIcon => 'Mostrar ícone HDR';

  @override
  String get settingsThumbnailShowFavouriteIcon => 'Mostrar ícone favorito';

  @override
  String get settingsThumbnailShowTagIcon => 'Mostrar ícone de etiqueta';

  @override
  String get settingsThumbnailShowLocationIcon => 'Mostrar ícone de localização';

  @override
  String get settingsThumbnailShowMotionPhotoIcon => 'Mostrar ícone de foto em movimento';

  @override
  String get settingsThumbnailShowRating => 'Mostrar classificação';

  @override
  String get settingsThumbnailShowRawIcon => 'Mostrar ícone raw';

  @override
  String get settingsThumbnailShowVideoDuration => 'Mostrar duração do vídeo';

  @override
  String get settingsCollectionQuickActionsTile => 'Ações rápidas';

  @override
  String get settingsCollectionQuickActionEditorPageTitle => 'Ações rápidas';

  @override
  String get settingsCollectionQuickActionTabBrowsing => 'Navegando';

  @override
  String get settingsCollectionQuickActionTabSelecting => 'Selecionando';

  @override
  String get settingsCollectionBrowsingQuickActionEditorBanner => 'Toque e segure para mover os botões e selecionar quais ações são exibidas ao navegar pelos itens.';

  @override
  String get settingsCollectionSelectionQuickActionEditorBanner => 'Toque e segure para mover os botões e selecionar quais ações são exibidas ao selecionar itens.';

  @override
  String get settingsCollectionBurstPatternsTile => 'Padrões de explosão';

  @override
  String get settingsCollectionBurstPatternsNone => 'Nenhum';

  @override
  String get settingsViewerSectionTitle => 'Visualizador';

  @override
  String get settingsViewerGestureSideTapNext => 'Toque nas bordas da tela para mostrar anterior/seguinte';

  @override
  String get settingsViewerUseCutout => 'Usar área de recorte';

  @override
  String get settingsViewerMaximumBrightness => 'Brilho máximo';

  @override
  String get settingsMotionPhotoAutoPlay => 'Reprodução automática de fotos em movimento';

  @override
  String get settingsImageBackground => 'Plano de fundo da imagem';

  @override
  String get settingsViewerQuickActionsTile => 'Ações rápidas';

  @override
  String get settingsViewerQuickActionEditorPageTitle => 'Ações rápidas';

  @override
  String get settingsViewerQuickActionEditorBanner => 'Toque e segure para mover os botões e selecionar quais ações são exibidas no visualizador.';

  @override
  String get settingsViewerQuickActionEditorDisplayedButtonsSectionTitle => 'Botões exibidos';

  @override
  String get settingsViewerQuickActionEditorAvailableButtonsSectionTitle => 'Botões disponíveis';

  @override
  String get settingsViewerQuickActionEmpty => 'Sem botões';

  @override
  String get settingsViewerOverlayTile => 'Sobreposição';

  @override
  String get settingsViewerOverlayPageTitle => 'Sobreposição';

  @override
  String get settingsViewerShowOverlayOnOpening => 'Mostrar na abertura';

  @override
  String get settingsViewerShowHistogram => 'Mostrar histograma';

  @override
  String get settingsViewerShowMinimap => 'Mostrar minimapa';

  @override
  String get settingsViewerShowInformation => 'Mostrar informações';

  @override
  String get settingsViewerShowInformationSubtitle => 'Mostrar título, data, local, etc.';

  @override
  String get settingsViewerShowRatingTags => 'Mostrar avaliações e tags';

  @override
  String get settingsViewerShowShootingDetails => 'Mostrar detalhes de disparo';

  @override
  String get settingsViewerShowDescription => 'Mostrar descrição';

  @override
  String get settingsViewerShowOverlayThumbnails => 'Mostrar miniaturas';

  @override
  String get settingsViewerEnableOverlayBlurEffect => 'Efeito de desfoque';

  @override
  String get settingsViewerSlideshowTile => 'Apresentação de slides';

  @override
  String get settingsViewerSlideshowPageTitle => 'Apresentação de slides';

  @override
  String get settingsSlideshowRepeat => 'Repetir';

  @override
  String get settingsSlideshowShuffle => 'Embaralhar';

  @override
  String get settingsSlideshowFillScreen => 'Preencher tela';

  @override
  String get settingsSlideshowAnimatedZoomEffect => 'Efeito de zoom animado';

  @override
  String get settingsSlideshowTransitionTile => 'Transição';

  @override
  String get settingsSlideshowIntervalTile => 'Intervalo';

  @override
  String get settingsSlideshowVideoPlaybackTile => 'Reprodução de vídeo';

  @override
  String get settingsSlideshowVideoPlaybackDialogTitle => 'Reprodução de vídeo';

  @override
  String get settingsVideoPageTitle => 'Configurações de vídeo';

  @override
  String get settingsVideoSectionTitle => 'Vídeo';

  @override
  String get settingsVideoShowVideos => 'Mostrar vídeos';

  @override
  String get settingsVideoPlaybackTile => 'Reproduzir';

  @override
  String get settingsVideoPlaybackPageTitle => 'Reproduzir';

  @override
  String get settingsVideoEnableHardwareAcceleration => 'Aceleraçao do hardware';

  @override
  String get settingsVideoAutoPlay => 'Reprodução automática';

  @override
  String get settingsVideoLoopModeTile => 'Modo de loop';

  @override
  String get settingsVideoLoopModeDialogTitle => 'Modo de loop';

  @override
  String get settingsVideoResumptionModeTile => 'Retomar a reprodução';

  @override
  String get settingsVideoResumptionModeDialogTitle => 'Retomar a reprodução';

  @override
  String get settingsVideoBackgroundMode => 'Modo de fundo';

  @override
  String get settingsVideoBackgroundModeDialogTitle => 'Modo de fundo';

  @override
  String get settingsVideoControlsTile => 'Controles';

  @override
  String get settingsVideoControlsPageTitle => 'Controles';

  @override
  String get settingsVideoButtonsTile => 'Botões';

  @override
  String get settingsVideoGestureDoubleTapTogglePlay => 'Toque duas vezes para reproduzir/pausar';

  @override
  String get settingsVideoGestureSideDoubleTapSeek => 'Toque duas vezes nas bordas da tela buscar para trás/para frente';

  @override
  String get settingsVideoGestureVerticalDragBrightnessVolume => 'Deslize para cima ou para baixo para ajustar o brilho/volume';

  @override
  String get settingsSubtitleThemeTile => 'Legendas';

  @override
  String get settingsSubtitleThemePageTitle => 'Legendas';

  @override
  String get settingsSubtitleThemeSample => 'Esta é uma amostra.';

  @override
  String get settingsSubtitleThemeTextAlignmentTile => 'Alinhamento de texto';

  @override
  String get settingsSubtitleThemeTextAlignmentDialogTitle => 'Alinhamento de Texto';

  @override
  String get settingsSubtitleThemeTextPositionTile => 'Posição do texto';

  @override
  String get settingsSubtitleThemeTextPositionDialogTitle => 'Posição do Texto';

  @override
  String get settingsSubtitleThemeTextSize => 'Tamanho do texto';

  @override
  String get settingsSubtitleThemeShowOutline => 'Mostrar contorno e sombra';

  @override
  String get settingsSubtitleThemeTextColor => 'Cor do texto';

  @override
  String get settingsSubtitleThemeTextOpacity => 'Opacidade do texto';

  @override
  String get settingsSubtitleThemeBackgroundColor => 'Cor de fundo';

  @override
  String get settingsSubtitleThemeBackgroundOpacity => 'Opacidade do plano de fundo';

  @override
  String get settingsSubtitleThemeTextAlignmentLeft => 'Esquerda';

  @override
  String get settingsSubtitleThemeTextAlignmentCenter => 'Centro';

  @override
  String get settingsSubtitleThemeTextAlignmentRight => 'Direita';

  @override
  String get settingsPrivacySectionTitle => 'Privacidade';

  @override
  String get settingsAllowInstalledAppAccess => 'Permitir acesso ao inventário de aplicativos';

  @override
  String get settingsAllowInstalledAppAccessSubtitle => 'Usado para melhorar a exibição do álbum';

  @override
  String get settingsAllowErrorReporting => 'Permitir relatórios de erros anônimos';

  @override
  String get settingsSaveSearchHistory => 'Salvar histórico de pesquisa';

  @override
  String get settingsEnableBin => 'Usar lixeira';

  @override
  String get settingsEnableBinSubtitle => 'Manter itens excluídos por 30 dias';

  @override
  String get settingsDisablingBinWarningDialogMessage => 'Os itens na lixeira serão excluídos para sempre.';

  @override
  String get settingsAllowMediaManagement => 'Permitir gerenciamento de mídia';

  @override
  String get settingsHiddenItemsTile => 'Itens ocultos';

  @override
  String get settingsHiddenItemsPageTitle => 'Itens ocultos';

  @override
  String get settingsHiddenFiltersBanner => 'Fotos e vídeos que correspondem a filtros ocultos não aparecerão em sua coleção.';

  @override
  String get settingsHiddenFiltersEmpty => 'Sem filtros ocultos';

  @override
  String get settingsStorageAccessTile => 'Acesso ao armazenamento';

  @override
  String get settingsStorageAccessPageTitle => 'Acesso ao armazenamento';

  @override
  String get settingsStorageAccessBanner => 'Alguns diretórios exigem uma concessão de acesso explícito para modificar arquivos neles. Você pode revisar aqui os diretórios aos quais você deu acesso anteriormente.';

  @override
  String get settingsStorageAccessEmpty => 'Sem concessões de acesso';

  @override
  String get settingsStorageAccessRevokeTooltip => 'Revogar';

  @override
  String get settingsAccessibilitySectionTitle => 'Acessibilidade';

  @override
  String get settingsRemoveAnimationsTile => 'Remover animações';

  @override
  String get settingsRemoveAnimationsDialogTitle => 'Remover Animações';

  @override
  String get settingsTimeToTakeActionTile => 'Tempo para executar uma ação';

  @override
  String get settingsAccessibilityShowPinchGestureAlternatives => 'Mostrar alternativas de gesto multitoque';

  @override
  String get settingsDisplaySectionTitle => 'Tela';

  @override
  String get settingsThemeBrightnessTile => 'Tema';

  @override
  String get settingsThemeBrightnessDialogTitle => 'Tema';

  @override
  String get settingsThemeColorHighlights => 'Destaques de cores';

  @override
  String get settingsThemeEnableDynamicColor => 'Cor dinâmica';

  @override
  String get settingsDisplayRefreshRateModeTile => 'Taxa de atualização de exibição';

  @override
  String get settingsDisplayRefreshRateModeDialogTitle => 'Taxa de atualização';

  @override
  String get settingsDisplayUseTvInterface => 'Interface de TV Android';

  @override
  String get settingsLanguageSectionTitle => 'Idioma e Formatos';

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
  String get settingsForceWesternArabicNumeralsTile => 'Forçar numerais arábicos';

  @override
  String get settingsScreenSaverPageTitle => 'Protetor de tela';

  @override
  String get settingsWidgetPageTitle => 'Porta-retratos';

  @override
  String get settingsWidgetShowOutline => 'Contorno';

  @override
  String get settingsWidgetOpenPage => 'Ao tocar no widget';

  @override
  String get settingsWidgetDisplayedItem => 'Item exibido';

  @override
  String get settingsCollectionTile => 'Coleção';

  @override
  String get statsPageTitle => 'Estatísticas';

  @override
  String statsWithGps(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString itens com localização',
      one: '1 item com localização',
    );
    return '$_temp0';
  }

  @override
  String get statsTopCountriesSectionTitle => 'Principais Países';

  @override
  String get statsTopStatesSectionTitle => 'Principais Estados';

  @override
  String get statsTopPlacesSectionTitle => 'Principais Lugares';

  @override
  String get statsTopTagsSectionTitle => 'Principais Etiquetas';

  @override
  String get statsTopAlbumsSectionTitle => 'Principais Álbuns';

  @override
  String get viewerOpenPanoramaButtonLabel => 'ABRIR PANORAMA';

  @override
  String get viewerSetWallpaperButtonLabel => 'DEFINIR PAPEL DE PAREDE';

  @override
  String get viewerErrorUnknown => 'Algo não está certo!';

  @override
  String get viewerErrorDoesNotExist => 'O arquivo não existe mais.';

  @override
  String get viewerInfoPageTitle => 'Informações';

  @override
  String get viewerInfoBackToViewerTooltip => 'Voltar ao visualizador';

  @override
  String get viewerInfoUnknown => 'desconhecido';

  @override
  String get viewerInfoLabelDescription => 'Descrição';

  @override
  String get viewerInfoLabelTitle => 'Título';

  @override
  String get viewerInfoLabelDate => 'Data';

  @override
  String get viewerInfoLabelResolution => 'Resolução';

  @override
  String get viewerInfoLabelSize => 'Tamanho';

  @override
  String get viewerInfoLabelUri => 'URI';

  @override
  String get viewerInfoLabelPath => 'Caminho';

  @override
  String get viewerInfoLabelDuration => 'Duração';

  @override
  String get viewerInfoLabelOwner => 'Propriedade de';

  @override
  String get viewerInfoLabelCoordinates => 'Coordenadas';

  @override
  String get viewerInfoLabelAddress => 'Endereço';

  @override
  String get mapStyleDialogTitle => 'Estilo do mapa';

  @override
  String get mapStyleTooltip => 'Selecione o estilo do mapa';

  @override
  String get mapZoomInTooltip => 'Mais zoom';

  @override
  String get mapZoomOutTooltip => 'Reduzir o zoom';

  @override
  String get mapPointNorthUpTooltip => 'Aponte para o norte para cima';

  @override
  String get mapAttributionOsmData => 'Dados do mapa © [OpenStreetMap](https://www.openstreetmap.org/copyright) colaboradores';

  @override
  String get mapAttributionOsmLiberty => 'Blocos por [OpenMapTiles](https://www.openmaptiles.org/), [CC BY](http://creativecommons.org/licenses/by/4.0) • Hospedado por [OSM Americana](https://tile.ourmap.us)';

  @override
  String get mapAttributionOpenTopoMap => '[SRTM](https://www.earthdata.nasa.gov/sensors/srtm) | Blocos por [OpenTopoMap](https://opentopomap.org/), [CC BY-SA](https://creativecommons.org/licenses/by-sa/3.0/)';

  @override
  String get mapAttributionOsmHot => 'Blocos por [HOT](https://www.hotosm.org/) • Hospedado por [OSM France](https://openstreetmap.fr/)';

  @override
  String get mapAttributionStamen => 'Blocos por [Stamen Design](https://stamen.com), [CC BY 3.0](https://creativecommons.org/licenses/by/3.0)';

  @override
  String get openMapPageTooltip => 'Visualizar na página do mapa';

  @override
  String get mapEmptyRegion => 'Nenhuma imagem nesta região';

  @override
  String get viewerInfoOpenEmbeddedFailureFeedback => 'Falha ao extrair dados incorporados';

  @override
  String get viewerInfoOpenLinkText => 'Abrir';

  @override
  String get viewerInfoViewXmlLinkText => 'Visualizar XML';

  @override
  String get viewerInfoSearchFieldLabel => 'Pesquisar metadados';

  @override
  String get viewerInfoSearchEmpty => 'Nenhuma chave correspondente';

  @override
  String get viewerInfoSearchSuggestionDate => 'Data e Hora';

  @override
  String get viewerInfoSearchSuggestionDescription => 'Descrição';

  @override
  String get viewerInfoSearchSuggestionDimensions => 'Dimensões';

  @override
  String get viewerInfoSearchSuggestionResolution => 'Resolução';

  @override
  String get viewerInfoSearchSuggestionRights => 'Direitos';

  @override
  String get wallpaperUseScrollEffect => 'Use o efeito de rolagem na tela inicial';

  @override
  String get tagEditorPageTitle => 'Editar etiquetas';

  @override
  String get tagEditorPageNewTagFieldLabel => 'Nova etiqueta';

  @override
  String get tagEditorPageAddTagTooltip => 'Adicionar etiqueta';

  @override
  String get tagEditorSectionRecent => 'Recente';

  @override
  String get tagEditorSectionPlaceholders => 'Espaços reservados';

  @override
  String get tagEditorDiscardDialogMessage => 'Pretende rejeitar as alterações?';

  @override
  String get tagPlaceholderCountry => 'País';

  @override
  String get tagPlaceholderState => 'Estado';

  @override
  String get tagPlaceholderPlace => 'Lugar';

  @override
  String get panoramaEnableSensorControl => 'Ativar o controle do sensor';

  @override
  String get panoramaDisableSensorControl => 'Desabilitar o controle do sensor';

  @override
  String get sourceViewerPageTitle => 'Fonte';
}
