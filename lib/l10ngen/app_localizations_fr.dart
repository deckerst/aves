// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Aves';

  @override
  String get welcomeMessage => 'Bienvenue';

  @override
  String get welcomeOptional => 'Option';

  @override
  String get welcomeTermsToggle => 'J’accepte les conditions d’utilisation';

  @override
  String itemCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString éléments',
      one: '$countString élément',
    );
    return '$_temp0';
  }

  @override
  String columnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count colonnes',
      one: '$count colonne',
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
      other: '$countString secondes',
      one: '$countString seconde',
      zero: '$countString seconde',
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
      other: '$countString minutes',
      one: '$countString minute',
      zero: '$countString minute',
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
      other: '$countString jours',
      one: '$countString jour',
      zero: '$countString jour',
    );
    return '$_temp0';
  }

  @override
  String focalLength(String length) {
    return '$length mm';
  }

  @override
  String get applyButtonLabel => 'APPLIQUER';

  @override
  String get deleteButtonLabel => 'SUPPRIMER';

  @override
  String get nextButtonLabel => 'SUIVANT';

  @override
  String get showButtonLabel => 'AFFICHER';

  @override
  String get hideButtonLabel => 'MASQUER';

  @override
  String get continueButtonLabel => 'CONTINUER';

  @override
  String get saveCopyButtonLabel => 'ENREGISTRER UNE COPIE';

  @override
  String get applyTooltip => 'Appliquer';

  @override
  String get cancelTooltip => 'Annuler';

  @override
  String get changeTooltip => 'Modifier';

  @override
  String get clearTooltip => 'Effacer';

  @override
  String get previousTooltip => 'Précédent';

  @override
  String get nextTooltip => 'Suivant';

  @override
  String get showTooltip => 'Afficher';

  @override
  String get hideTooltip => 'Masquer';

  @override
  String get actionRemove => 'Supprimer';

  @override
  String get resetTooltip => 'Réinitialiser';

  @override
  String get saveTooltip => 'Sauvegarder';

  @override
  String get stopTooltip => 'Arrêter';

  @override
  String get pickTooltip => 'Sélectionner';

  @override
  String get doubleBackExitMessage => 'Pressez « retour » à nouveau pour quitter.';

  @override
  String get doNotAskAgain => 'Ne pas demander de nouveau';

  @override
  String get sourceStateLoading => 'Chargement';

  @override
  String get sourceStateCataloguing => 'Classification';

  @override
  String get sourceStateLocatingCountries => 'Identification des pays';

  @override
  String get sourceStateLocatingPlaces => 'Identification des lieux';

  @override
  String get chipActionDelete => 'Supprimer';

  @override
  String get chipActionRemove => 'Retirer';

  @override
  String get chipActionShowCollection => 'Afficher dans Collection';

  @override
  String get chipActionGoToAlbumPage => 'Afficher dans Albums';

  @override
  String get chipActionGoToCountryPage => 'Afficher dans Pays';

  @override
  String get chipActionGoToPlacePage => 'Afficher dans Lieux';

  @override
  String get chipActionGoToTagPage => 'Afficher dans Étiquettes';

  @override
  String get chipActionGoToExplorerPage => 'Afficher dans Explorateur';

  @override
  String get chipActionDecompose => 'Scinder';

  @override
  String get chipActionFilterOut => 'Exclure';

  @override
  String get chipActionFilterIn => 'Inclure';

  @override
  String get chipActionHide => 'Masquer';

  @override
  String get chipActionLock => 'Verrouiller';

  @override
  String get chipActionPin => 'Épingler';

  @override
  String get chipActionUnpin => 'Retirer';

  @override
  String get chipActionRename => 'Renommer';

  @override
  String get chipActionSetCover => 'Modifier la couverture';

  @override
  String get chipActionShowCountryStates => 'Afficher les États';

  @override
  String get chipActionCreateAlbum => 'Créer un album';

  @override
  String get chipActionCreateVault => 'Créer un coffre-fort';

  @override
  String get chipActionConfigureVault => 'Configurer le coffre-fort';

  @override
  String get entryActionCopyToClipboard => 'Copier dans presse-papier';

  @override
  String get entryActionDelete => 'Supprimer';

  @override
  String get entryActionConvert => 'Convertir';

  @override
  String get entryActionExport => 'Exporter';

  @override
  String get entryActionInfo => 'Détails';

  @override
  String get entryActionRename => 'Renommer';

  @override
  String get entryActionRestore => 'Restaurer';

  @override
  String get entryActionRotateCCW => 'Pivoter à gauche';

  @override
  String get entryActionRotateCW => 'Pivoter à droite';

  @override
  String get entryActionFlip => 'Retourner horizontalement';

  @override
  String get entryActionPrint => 'Imprimer';

  @override
  String get entryActionShare => 'Partager';

  @override
  String get entryActionShareImageOnly => 'Partager l’image seulement';

  @override
  String get entryActionShareVideoOnly => 'Partager la vidéo seulement';

  @override
  String get entryActionViewSource => 'Voir le code';

  @override
  String get entryActionShowGeoTiffOnMap => 'Superposer sur la carte';

  @override
  String get entryActionConvertMotionPhotoToStillImage => 'Convertir en image fixe';

  @override
  String get entryActionViewMotionPhotoVideo => 'Ouvrir la vidéo';

  @override
  String get entryActionEdit => 'Modifier';

  @override
  String get entryActionOpen => 'Ouvrir avec';

  @override
  String get entryActionSetAs => 'Utiliser comme';

  @override
  String get entryActionCast => 'Caster';

  @override
  String get entryActionOpenMap => 'Localiser avec';

  @override
  String get entryActionRotateScreen => 'Pivoter l’écran';

  @override
  String get entryActionAddFavourite => 'Ajouter aux favoris';

  @override
  String get entryActionRemoveFavourite => 'Retirer des favoris';

  @override
  String get videoActionCaptureFrame => 'Capturer l’image';

  @override
  String get videoActionMute => 'Couper le son';

  @override
  String get videoActionUnmute => 'Rétablir le son';

  @override
  String get videoActionPause => 'Pause';

  @override
  String get videoActionPlay => 'Lire';

  @override
  String get videoActionReplay10 => 'Reculer de 10 secondes';

  @override
  String get videoActionSkip10 => 'Avancer de 10 secondes';

  @override
  String get videoActionShowPreviousFrame => 'Montrer l’image précédente';

  @override
  String get videoActionShowNextFrame => 'Montrer l’image suivante';

  @override
  String get videoActionSelectStreams => 'Choisir les pistes';

  @override
  String get videoActionSetSpeed => 'Vitesse de lecture';

  @override
  String get videoActionABRepeat => 'Lecture répétée A-B';

  @override
  String get videoRepeatActionSetStart => 'Définir le début';

  @override
  String get videoRepeatActionSetEnd => 'Définir la fin';

  @override
  String get viewerActionSettings => 'Préférences';

  @override
  String get viewerActionLock => 'Verrouiller la visionneuse';

  @override
  String get viewerActionUnlock => 'Déverrouiller la visionneuse';

  @override
  String get slideshowActionResume => 'Reprendre';

  @override
  String get slideshowActionShowInCollection => 'Afficher dans Collection';

  @override
  String get entryInfoActionEditDate => 'Modifier la date';

  @override
  String get entryInfoActionEditLocation => 'Modifier le lieu';

  @override
  String get entryInfoActionEditTitleDescription => 'Modifier titre et description';

  @override
  String get entryInfoActionEditRating => 'Modifier la notation';

  @override
  String get entryInfoActionEditTags => 'Modifier les étiquettes';

  @override
  String get entryInfoActionRemoveMetadata => 'Retirer les métadonnées';

  @override
  String get entryInfoActionExportMetadata => 'Exporter les métadonnées';

  @override
  String get entryInfoActionRemoveLocation => 'Retirer le lieu';

  @override
  String get editorActionTransform => 'Transformation';

  @override
  String get editorTransformCrop => 'Recadrage';

  @override
  String get editorTransformRotate => 'Rotation';

  @override
  String get cropAspectRatioFree => 'Personnalisé';

  @override
  String get cropAspectRatioOriginal => 'Photo d’origine';

  @override
  String get cropAspectRatioSquare => 'Carré';

  @override
  String get filterAspectRatioLandscapeLabel => 'Paysage';

  @override
  String get filterAspectRatioPortraitLabel => 'Portrait';

  @override
  String get filterBinLabel => 'Corbeille';

  @override
  String get filterFavouriteLabel => 'Favori';

  @override
  String get filterNoDateLabel => 'Sans date';

  @override
  String get filterNoAddressLabel => 'Sans adresse';

  @override
  String get filterLocatedLabel => 'Localisé';

  @override
  String get filterNoLocationLabel => 'Sans lieu';

  @override
  String get filterNoRatingLabel => 'Sans notation';

  @override
  String get filterTaggedLabel => 'Étiqueté';

  @override
  String get filterNoTagLabel => 'Sans étiquette';

  @override
  String get filterNoTitleLabel => 'Sans titre';

  @override
  String get filterOnThisDayLabel => 'Ce jour-là';

  @override
  String get filterRecentlyAddedLabel => 'Ajouté récemment';

  @override
  String get filterRatingRejectedLabel => 'Rejeté';

  @override
  String get filterTypeAnimatedLabel => 'Animation';

  @override
  String get filterTypeMotionPhotoLabel => 'Photo animée';

  @override
  String get filterTypePanoramaLabel => 'Panorama';

  @override
  String get filterTypeRawLabel => 'Raw';

  @override
  String get filterTypeSphericalVideoLabel => 'Vidéo à 360°';

  @override
  String get filterTypeGeotiffLabel => 'GeoTIFF';

  @override
  String get filterMimeImageLabel => 'Image';

  @override
  String get filterMimeVideoLabel => 'Vidéo';

  @override
  String get accessibilityAnimationsRemove => 'Empêchez certains effets de l’écran';

  @override
  String get accessibilityAnimationsKeep => 'Conserver les effets de l’écran';

  @override
  String get albumTierNew => 'Nouveaux';

  @override
  String get albumTierPinned => 'Épinglés';

  @override
  String get albumTierSpecial => 'Standards';

  @override
  String get albumTierApps => 'Apps';

  @override
  String get albumTierVaults => 'Coffres-forts';

  @override
  String get albumTierDynamic => 'Dynamique';

  @override
  String get albumTierRegular => 'Autres';

  @override
  String get coordinateFormatDms => 'DMS';

  @override
  String get coordinateFormatDdm => 'DDM';

  @override
  String get coordinateFormatDecimal => 'Degrés décimaux';

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
  String get displayRefreshRatePreferHighest => 'Fréquence maximale';

  @override
  String get displayRefreshRatePreferLowest => 'Fréquence minimale';

  @override
  String get keepScreenOnNever => 'Jamais';

  @override
  String get keepScreenOnVideoPlayback => 'Pendant la lecture de vidéos';

  @override
  String get keepScreenOnViewerOnly => 'Visionneuse seulement';

  @override
  String get keepScreenOnAlways => 'Toujours';

  @override
  String get lengthUnitPixel => 'px';

  @override
  String get lengthUnitPercent => '%';

  @override
  String get mapStyleGoogleNormal => 'Google Maps';

  @override
  String get mapStyleGoogleHybrid => 'Google Maps (Satellite)';

  @override
  String get mapStyleGoogleTerrain => 'Google Maps (Relief)';

  @override
  String get mapStyleOsmLiberty => 'OSM Liberty';

  @override
  String get mapStyleOpenTopoMap => 'OpenTopoMap';

  @override
  String get mapStyleOsmHot => 'OSM Humanitaire';

  @override
  String get mapStyleStamenWatercolor => 'Stamen Watercolor (Aquarelle)';

  @override
  String get maxBrightnessNever => 'Jamais';

  @override
  String get maxBrightnessAlways => 'Toujours';

  @override
  String get nameConflictStrategyRename => 'Renommer';

  @override
  String get nameConflictStrategyReplace => 'Remplacer';

  @override
  String get nameConflictStrategySkip => 'Ignorer';

  @override
  String get overlayHistogramNone => 'Aucun';

  @override
  String get overlayHistogramRGB => 'RVB';

  @override
  String get overlayHistogramLuminance => 'Luminance';

  @override
  String get subtitlePositionTop => 'Haut';

  @override
  String get subtitlePositionBottom => 'Bas';

  @override
  String get themeBrightnessLight => 'Clair';

  @override
  String get themeBrightnessDark => 'Sombre';

  @override
  String get themeBrightnessBlack => 'Noir';

  @override
  String get unitSystemMetric => 'SI';

  @override
  String get unitSystemImperial => 'anglo-saxonnes';

  @override
  String get vaultLockTypePattern => 'Modèle';

  @override
  String get vaultLockTypePin => 'Code PIN';

  @override
  String get vaultLockTypePassword => 'Mot de passe';

  @override
  String get settingsVideoEnablePip => 'Picture-in-picture';

  @override
  String get videoControlsPlayOutside => 'Ouvrir avec un autre lecteur';

  @override
  String get videoLoopModeNever => 'Jamais';

  @override
  String get videoLoopModeShortOnly => 'Courtes vidéos seulement';

  @override
  String get videoLoopModeAlways => 'Toujours';

  @override
  String get videoPlaybackSkip => 'Passer';

  @override
  String get videoPlaybackMuted => 'Jouer sans son';

  @override
  String get videoPlaybackWithSound => 'Jouer avec son';

  @override
  String get videoResumptionModeNever => 'Jamais';

  @override
  String get videoResumptionModeAlways => 'Toujours';

  @override
  String get viewerTransitionSlide => 'Défilement';

  @override
  String get viewerTransitionParallax => 'Parallaxe';

  @override
  String get viewerTransitionFade => 'Fondu';

  @override
  String get viewerTransitionZoomIn => 'Zoom';

  @override
  String get viewerTransitionNone => 'Aucune';

  @override
  String get wallpaperTargetHome => 'Écran d’accueil';

  @override
  String get wallpaperTargetLock => 'Écran de verrouillage';

  @override
  String get wallpaperTargetHomeLock => 'Écrans accueil et verrouillage';

  @override
  String get widgetDisplayedItemRandom => 'Aléatoire';

  @override
  String get widgetDisplayedItemMostRecent => 'Le plus récent';

  @override
  String get widgetOpenPageHome => 'Ouvrir la page d’accueil';

  @override
  String get widgetOpenPageCollection => 'Ouvrir la collection';

  @override
  String get widgetOpenPageViewer => 'Ouvrir la visionneuse';

  @override
  String get widgetTapUpdateWidget => 'Mettre à jour le widget';

  @override
  String get storageVolumeDescriptionFallbackPrimary => 'Stockage interne';

  @override
  String get storageVolumeDescriptionFallbackNonPrimary => 'Carte SD';

  @override
  String get rootDirectoryDescription => 'dossier racine';

  @override
  String otherDirectoryDescription(String name) {
    return 'dossier « $name »';
  }

  @override
  String storageAccessDialogMessage(String directory, String volume) {
    return 'Veuillez sélectionner le $directory de « $volume » à l’écran suivant, pour que l’app puisse modifier son contenu.';
  }

  @override
  String restrictedAccessDialogMessage(String directory, String volume) {
    return 'Cette app ne peut pas modifier les fichiers du $directory de « $volume ».\n\nVeuillez utiliser une app pré-installée pour déplacer les fichiers vers un autre dossier.';
  }

  @override
  String notEnoughSpaceDialogMessage(String neededSize, String freeSize, String volume) {
    return 'Cette opération nécessite $neededSize d’espace disponible sur « $volume », mais il ne reste que $freeSize.';
  }

  @override
  String get missingSystemFilePickerDialogMessage => 'Le sélecteur de fichiers du système est absent ou désactivé. Veuillez le réactiver et réessayer.';

  @override
  String unsupportedTypeDialogMessage(int count, String types) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cette opération n’est pas disponible pour les fichiers aux formats suivants : $types.',
      one: 'Cette opération n’est pas disponible pour les fichiers au format suivant : $types.',
    );
    return '$_temp0';
  }

  @override
  String get nameConflictDialogSingleSourceMessage => 'Certains fichiers dans le dossier de destination ont le même nom.';

  @override
  String get nameConflictDialogMultipleSourceMessage => 'Certains fichiers ont le même nom.';

  @override
  String get addShortcutDialogLabel => 'Nom du raccourci';

  @override
  String get addShortcutButtonLabel => 'AJOUTER';

  @override
  String get noMatchingAppDialogMessage => 'Aucune app ne peut effectuer cette opération.';

  @override
  String binEntriesConfirmationDialogMessage(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mettre ces $countString éléments à la corbeille ?',
      one: 'Mettre cet élément à la corbeille ?',
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
      other: 'Supprimer ces $countString éléments ?',
      one: 'Supprimer cet élément ?',
    );
    return '$_temp0';
  }

  @override
  String get moveUndatedConfirmationDialogMessage => 'Sauvegarder les dates des éléments avant de continuer ?';

  @override
  String get moveUndatedConfirmationDialogSetDate => 'Sauvegarder les dates';

  @override
  String videoResumeDialogMessage(String time) {
    return 'Voulez-vous reprendre la lecture à $time ?';
  }

  @override
  String get videoStartOverButtonLabel => 'RECOMMENCER';

  @override
  String get videoResumeButtonLabel => 'REPRENDRE';

  @override
  String get setCoverDialogLatest => 'dernier élément';

  @override
  String get setCoverDialogAuto => 'automatique';

  @override
  String get setCoverDialogCustom => 'personnalisé';

  @override
  String get hideFilterConfirmationDialogMessage => 'Les images et vidéos correspondantes n’apparaîtront plus dans votre collection. Vous pouvez les montrer à nouveau via les réglages de « Confidentialité ».\n\nVoulez-vous vraiment les masquer ?';

  @override
  String get newAlbumDialogTitle => 'Nouvel album';

  @override
  String get newAlbumDialogNameLabel => 'Nom de l’album';

  @override
  String get newAlbumDialogAlbumAlreadyExistsHelper => 'L’album existe déjà';

  @override
  String get newAlbumDialogNameLabelAlreadyExistsHelper => 'Le dossier existe déjà';

  @override
  String get newAlbumDialogStorageLabel => 'Volume de stockage :';

  @override
  String get newDynamicAlbumDialogTitle => 'Nouvel album dynamique';

  @override
  String get dynamicAlbumAlreadyExists => 'L’album dynamique existe déjà';

  @override
  String get newVaultWarningDialogMessage => 'Les éléments dans les coffres-forts ne sont visibles que dans cette app et nulle autre.\n\nSi vous désinstallez cette app, ou que vous supprimez ses données, vous perdrez tous ces éléments.';

  @override
  String get newVaultDialogTitle => 'Nouveau coffre-fort';

  @override
  String get configureVaultDialogTitle => 'Configuration du coffre-fort';

  @override
  String get vaultDialogLockModeWhenScreenOff => 'Verrouiller quand l’écran s’éteint';

  @override
  String get vaultDialogLockTypeLabel => 'Verrouillage';

  @override
  String get patternDialogEnter => 'Entrez votre modèle';

  @override
  String get patternDialogConfirm => 'Confirmez votre modèle';

  @override
  String get pinDialogEnter => 'Entrez votre code PIN';

  @override
  String get pinDialogConfirm => 'Confirmez votre code PIN';

  @override
  String get passwordDialogEnter => 'Entrez votre mot de passe';

  @override
  String get passwordDialogConfirm => 'Confirmez votre mot de passe';

  @override
  String get authenticateToConfigureVault => 'Authentification pour configurer le coffre-fort';

  @override
  String get authenticateToUnlockVault => 'Authentification pour déverrouiller le coffre-fort';

  @override
  String get vaultBinUsageDialogMessage => 'Des coffres-forts utilisent la corbeille.';

  @override
  String get renameAlbumDialogLabel => 'Nouveau nom';

  @override
  String get renameAlbumDialogLabelAlreadyExistsHelper => 'Le dossier existe déjà';

  @override
  String get renameEntrySetPageTitle => 'Renommage';

  @override
  String get renameEntrySetPagePatternFieldLabel => 'Modèle de nommage';

  @override
  String get renameEntrySetPageInsertTooltip => 'Ajouter un champ';

  @override
  String get renameEntrySetPagePreviewSectionTitle => 'Aperçu';

  @override
  String get renameProcessorCounter => 'Compteur';

  @override
  String get renameProcessorHash => 'Hash';

  @override
  String get renameProcessorName => 'Nom';

  @override
  String deleteSingleAlbumConfirmationDialogMessage(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Supprimer cet album et les $countString éléments dedans ?',
      one: 'Supprimer cet album et l’élément dedans ?',
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
      other: 'Supprimer ces albums et les $countString éléments dedans ?',
      one: 'Supprimer ces albums et l’élément dedans ?',
    );
    return '$_temp0';
  }

  @override
  String get exportEntryDialogFormat => 'Format :';

  @override
  String get exportEntryDialogWidth => 'Largeur';

  @override
  String get exportEntryDialogHeight => 'Hauteur';

  @override
  String get exportEntryDialogQuality => 'Qualité';

  @override
  String get exportEntryDialogWriteMetadata => 'Écrire les métadonnées';

  @override
  String get renameEntryDialogLabel => 'Nouveau nom';

  @override
  String get editEntryDialogCopyFromItem => 'Copier d’un autre élément';

  @override
  String get editEntryDialogTargetFieldsHeader => 'Champs à modifier';

  @override
  String get editEntryDateDialogTitle => 'Date & Heure';

  @override
  String get editEntryDateDialogSetCustom => 'Régler une date personnalisée';

  @override
  String get editEntryDateDialogCopyField => 'Copier d’une autre date';

  @override
  String get editEntryDateDialogExtractFromTitle => 'Extraire du titre';

  @override
  String get editEntryDateDialogShift => 'Décaler';

  @override
  String get editEntryDateDialogSourceFileModifiedDate => 'Date de modification du fichier';

  @override
  String get durationDialogHours => 'Heures';

  @override
  String get durationDialogMinutes => 'Minutes';

  @override
  String get durationDialogSeconds => 'Secondes';

  @override
  String get editEntryLocationDialogTitle => 'Lieu';

  @override
  String get editEntryLocationDialogSetCustom => 'Définir un lieu personnalisé';

  @override
  String get editEntryLocationDialogChooseOnMap => 'Sélectionner sur la carte';

  @override
  String get editEntryLocationDialogImportGpx => 'Importer un fichier GPX';

  @override
  String get editEntryLocationDialogLatitude => 'Latitude';

  @override
  String get editEntryLocationDialogLongitude => 'Longitude';

  @override
  String get editEntryLocationDialogTimeShift => 'Décalage temporel';

  @override
  String get locationPickerUseThisLocationButton => 'Utiliser ce lieu';

  @override
  String get editEntryRatingDialogTitle => 'Notation';

  @override
  String get removeEntryMetadataDialogTitle => 'Retrait de métadonnées';

  @override
  String get removeEntryMetadataDialogAll => 'Tout';

  @override
  String get removeEntryMetadataDialogMore => 'Voir plus';

  @override
  String get removeEntryMetadataMotionPhotoXmpWarningDialogMessage => 'Les métadonnées XMP sont nécessaires pour lire la vidéo d’une photo animée.\n\nVoulez-vous vraiment les supprimer ?';

  @override
  String get videoSpeedDialogLabel => 'Vitesse de lecture';

  @override
  String get videoStreamSelectionDialogVideo => 'Vidéo';

  @override
  String get videoStreamSelectionDialogAudio => 'Audio';

  @override
  String get videoStreamSelectionDialogText => 'Sous-titres';

  @override
  String get videoStreamSelectionDialogOff => 'Désactivé';

  @override
  String get videoStreamSelectionDialogTrack => 'Piste';

  @override
  String get videoStreamSelectionDialogNoSelection => 'Il n’y a pas d’autre piste.';

  @override
  String get genericSuccessFeedback => 'Succès !';

  @override
  String get genericFailureFeedback => 'Échec';

  @override
  String get genericDangerWarningDialogMessage => 'Êtes-vous sûr ?';

  @override
  String get tooManyItemsErrorDialogMessage => 'Réessayez avec moins d’éléments.';

  @override
  String get menuActionConfigureView => 'Vue';

  @override
  String get menuActionSelect => 'Sélectionner';

  @override
  String get menuActionSelectAll => 'Tout sélectionner';

  @override
  String get menuActionSelectNone => 'Tout désélectionner';

  @override
  String get menuActionMap => 'Carte';

  @override
  String get menuActionSlideshow => 'Diaporama';

  @override
  String get menuActionStats => 'Statistiques';

  @override
  String get viewDialogSortSectionTitle => 'Tri';

  @override
  String get viewDialogGroupSectionTitle => 'Groupes';

  @override
  String get viewDialogLayoutSectionTitle => 'Vue';

  @override
  String get viewDialogReverseSortOrder => 'Inverser l’ordre';

  @override
  String get tileLayoutMosaic => 'Mosaïque';

  @override
  String get tileLayoutGrid => 'Grille';

  @override
  String get tileLayoutList => 'Liste';

  @override
  String get castDialogTitle => 'Appareils';

  @override
  String get coverDialogTabCover => 'Image';

  @override
  String get coverDialogTabApp => 'App';

  @override
  String get coverDialogTabColor => 'Couleur';

  @override
  String get appPickDialogTitle => 'Sélection';

  @override
  String get appPickDialogNone => 'Aucune';

  @override
  String get aboutPageTitle => 'À propos';

  @override
  String get aboutLinkLicense => 'Licence';

  @override
  String get aboutLinkPolicy => 'Politique de confidentialité';

  @override
  String get aboutBugSectionTitle => 'Rapports d’erreur';

  @override
  String get aboutBugSaveLogInstruction => 'Sauvegarder les logs de l’app vers un fichier';

  @override
  String get aboutBugCopyInfoInstruction => 'Copier les informations d’environnement';

  @override
  String get aboutBugCopyInfoButton => 'Copier';

  @override
  String get aboutBugReportInstruction => 'Créer une « issue » sur GitHub en attachant les logs et informations d’environnement';

  @override
  String get aboutBugReportButton => 'Créer';

  @override
  String get aboutDataUsageSectionTitle => 'Espace utilisé';

  @override
  String get aboutDataUsageData => 'Données';

  @override
  String get aboutDataUsageCache => 'Cache';

  @override
  String get aboutDataUsageDatabase => 'Base de données';

  @override
  String get aboutDataUsageMisc => 'Divers';

  @override
  String get aboutDataUsageInternal => 'Interne';

  @override
  String get aboutDataUsageExternal => 'Externe';

  @override
  String get aboutDataUsageClearCache => 'Vider le cache';

  @override
  String get aboutCreditsSectionTitle => 'Remerciements';

  @override
  String get aboutCreditsWorldAtlas1 => 'Cette app utilise un fichier TopoJSON de';

  @override
  String get aboutCreditsWorldAtlas2 => 'sous licence ISC.';

  @override
  String get aboutTranslatorsSectionTitle => 'Traducteurs';

  @override
  String get aboutLicensesSectionTitle => 'Licences open-source';

  @override
  String get aboutLicensesBanner => 'Cette app utilise ces librairies et packages open-source.';

  @override
  String get aboutLicensesAndroidLibrariesSectionTitle => 'Librairies Android';

  @override
  String get aboutLicensesFlutterPluginsSectionTitle => 'Plugins Flutter';

  @override
  String get aboutLicensesFlutterPackagesSectionTitle => 'Packages Flutter';

  @override
  String get aboutLicensesDartPackagesSectionTitle => 'Packages Dart';

  @override
  String get aboutLicensesShowAllButtonLabel => 'Afficher toutes les licences';

  @override
  String get policyPageTitle => 'Politique de confidentialité';

  @override
  String get collectionPageTitle => 'Collection';

  @override
  String get collectionPickPageTitle => 'Sélection';

  @override
  String get collectionSelectPageTitle => 'Sélection';

  @override
  String get collectionActionShowTitleSearch => 'Filtrer les titres';

  @override
  String get collectionActionHideTitleSearch => 'Masquer le filtre';

  @override
  String get collectionActionAddDynamicAlbum => 'Ajouter un album dynamique';

  @override
  String get collectionActionAddShortcut => 'Créer un raccourci';

  @override
  String get collectionActionSetHome => 'Définir comme page d’accueil';

  @override
  String get collectionActionEmptyBin => 'Vider la corbeille';

  @override
  String get collectionActionCopy => 'Copier vers l’album';

  @override
  String get collectionActionMove => 'Déplacer vers l’album';

  @override
  String get collectionActionRescan => 'Réanalyser';

  @override
  String get collectionActionEdit => 'Modifier';

  @override
  String get collectionSearchTitlesHintText => 'Recherche de titres';

  @override
  String get collectionGroupAlbum => 'par album';

  @override
  String get collectionGroupMonth => 'par mois';

  @override
  String get collectionGroupDay => 'par jour';

  @override
  String get collectionGroupNone => 'ne pas grouper';

  @override
  String get sectionUnknown => 'Inconnu';

  @override
  String get dateToday => 'Aujourd’hui';

  @override
  String get dateYesterday => 'Hier';

  @override
  String get dateThisMonth => 'Ce mois-ci';

  @override
  String collectionDeleteFailureFeedback(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Échec de la suppression de $countString éléments',
      one: 'Échec de la suppression d’1 élément',
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
      other: 'Échec de la copie de $countString éléments',
      one: 'Échec de la copie d’1 élément',
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
      other: 'Échec du déplacement de $countString éléments',
      one: 'Échec du déplacement d’1 élément',
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
      other: 'Échec du renommage de $countString éléments',
      one: 'Échec du renommage d’1 élément',
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
      other: 'Échec de la modification de $countString éléments',
      one: 'Échec de la modification d’1 élément',
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
      other: 'Échec de l’export de $countString pages',
      one: 'Échec de l’export d’1 page',
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
      other: '$countString éléments copiés',
      one: '1 élément copié',
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
      other: '$countString éléments déplacés',
      one: '1 élément déplacé',
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
      other: '$countString éléments renommés',
      one: '1 élément renommé',
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
      other: '$countString éléments modifiés',
      one: '1 élément modifié',
    );
    return '$_temp0';
  }

  @override
  String get collectionEmptyFavourites => 'Aucun favori';

  @override
  String get collectionEmptyVideos => 'Aucune vidéo';

  @override
  String get collectionEmptyImages => 'Aucune image';

  @override
  String get collectionEmptyGrantAccessButtonLabel => 'Autoriser l’accès';

  @override
  String get collectionSelectSectionTooltip => 'Sélectionner la section';

  @override
  String get collectionDeselectSectionTooltip => 'Désélectionner la section';

  @override
  String get drawerAboutButton => 'À propos';

  @override
  String get drawerSettingsButton => 'Réglages';

  @override
  String get drawerCollectionAll => 'Toute la collection';

  @override
  String get drawerCollectionFavourites => 'Favoris';

  @override
  String get drawerCollectionImages => 'Images';

  @override
  String get drawerCollectionVideos => 'Vidéos';

  @override
  String get drawerCollectionAnimated => 'Animations';

  @override
  String get drawerCollectionMotionPhotos => 'Photos animées';

  @override
  String get drawerCollectionPanoramas => 'Panoramas';

  @override
  String get drawerCollectionRaws => 'Photos Raw';

  @override
  String get drawerCollectionSphericalVideos => 'Vidéos à 360°';

  @override
  String get drawerAlbumPage => 'Albums';

  @override
  String get drawerCountryPage => 'Pays';

  @override
  String get drawerPlacePage => 'Lieux';

  @override
  String get drawerTagPage => 'Étiquettes';

  @override
  String get sortByDate => 'par date';

  @override
  String get sortByName => 'alphabétique';

  @override
  String get sortByItemCount => 'par nombre d’éléments';

  @override
  String get sortBySize => 'par taille';

  @override
  String get sortByAlbumFileName => 'alphabétique';

  @override
  String get sortByRating => 'par notation';

  @override
  String get sortByDuration => 'par durée';

  @override
  String get sortOrderNewestFirst => 'Plus récents d’abord';

  @override
  String get sortOrderOldestFirst => 'Plus anciens d’abord';

  @override
  String get sortOrderAtoZ => 'De A à Z';

  @override
  String get sortOrderZtoA => 'De Z à A';

  @override
  String get sortOrderHighestFirst => 'Meilleurs d’abord';

  @override
  String get sortOrderLowestFirst => 'Moins bons d’abord';

  @override
  String get sortOrderLargestFirst => 'Plus larges d’abord';

  @override
  String get sortOrderSmallestFirst => 'Moins larges d’abord';

  @override
  String get sortOrderShortestFirst => 'Plus courts d’abord';

  @override
  String get sortOrderLongestFirst => 'Plus longs d’abord';

  @override
  String get albumGroupTier => 'par importance';

  @override
  String get albumGroupType => 'par type';

  @override
  String get albumGroupVolume => 'par volume de stockage';

  @override
  String get albumGroupNone => 'ne pas grouper';

  @override
  String get albumMimeTypeMixed => 'Mixte';

  @override
  String get albumPickPageTitleCopy => 'Copie';

  @override
  String get albumPickPageTitleExport => 'Export';

  @override
  String get albumPickPageTitleMove => 'Déplacement';

  @override
  String get albumPickPageTitlePick => 'Sélection';

  @override
  String get albumCamera => 'Appareil photo';

  @override
  String get albumDownload => 'Téléchargements';

  @override
  String get albumScreenshots => 'Captures d’écran';

  @override
  String get albumScreenRecordings => 'Enregistrements d’écran';

  @override
  String get albumVideoCaptures => 'Captures de vidéo';

  @override
  String get albumPageTitle => 'Albums';

  @override
  String get albumEmpty => 'Aucun album';

  @override
  String get createAlbumButtonLabel => 'CRÉER';

  @override
  String get newFilterBanner => 'nouveau';

  @override
  String get countryPageTitle => 'Pays';

  @override
  String get countryEmpty => 'Aucun pays';

  @override
  String get statePageTitle => 'États';

  @override
  String get stateEmpty => 'Aucun État';

  @override
  String get placePageTitle => 'Lieux';

  @override
  String get placeEmpty => 'Aucun lieu';

  @override
  String get tagPageTitle => 'Étiquettes';

  @override
  String get tagEmpty => 'Aucune étiquette';

  @override
  String get binPageTitle => 'Corbeille';

  @override
  String get explorerPageTitle => 'Explorateur';

  @override
  String get explorerActionSelectStorageVolume => 'Choisir le stockage';

  @override
  String get selectStorageVolumeDialogTitle => 'Volumes de stockage';

  @override
  String get searchCollectionFieldHint => 'Recherche';

  @override
  String get searchRecentSectionTitle => 'Historique';

  @override
  String get searchDateSectionTitle => 'Date';

  @override
  String get searchAlbumsSectionTitle => 'Albums';

  @override
  String get searchCountriesSectionTitle => 'Pays';

  @override
  String get searchStatesSectionTitle => 'États';

  @override
  String get searchPlacesSectionTitle => 'Lieux';

  @override
  String get searchTagsSectionTitle => 'Étiquettes';

  @override
  String get searchRatingSectionTitle => 'Notations';

  @override
  String get searchMetadataSectionTitle => 'Métadonnées';

  @override
  String get settingsPageTitle => 'Réglages';

  @override
  String get settingsSystemDefault => 'Système';

  @override
  String get settingsDefault => 'Par défaut';

  @override
  String get settingsDisabled => 'Désactivé';

  @override
  String get settingsAskEverytime => 'Demander chaque fois';

  @override
  String get settingsModificationWarningDialogMessage => 'D’autres réglages seront modifiés.';

  @override
  String get settingsSearchFieldLabel => 'Recherche de réglages';

  @override
  String get settingsSearchEmpty => 'Aucun réglage correspondant';

  @override
  String get settingsActionExport => 'Exporter';

  @override
  String get settingsActionExportDialogTitle => 'Exporter';

  @override
  String get settingsActionImport => 'Importer';

  @override
  String get settingsActionImportDialogTitle => 'Importer';

  @override
  String get appExportCovers => 'Couvertures';

  @override
  String get appExportDynamicAlbums => 'Albums dynamiques';

  @override
  String get appExportFavourites => 'Favoris';

  @override
  String get appExportSettings => 'Réglages';

  @override
  String get settingsNavigationSectionTitle => 'Navigation';

  @override
  String get settingsHomeTile => 'Page d’accueil';

  @override
  String get settingsHomeDialogTitle => 'Page d’accueil';

  @override
  String get setHomeCustom => 'Personnalisé';

  @override
  String get settingsShowBottomNavigationBar => 'Afficher la barre de navigation';

  @override
  String get settingsKeepScreenOnTile => 'Maintenir l’écran allumé';

  @override
  String get settingsKeepScreenOnDialogTitle => 'Allumage de l’écran';

  @override
  String get settingsDoubleBackExit => 'Presser « retour » 2 fois pour quitter';

  @override
  String get settingsConfirmationTile => 'Demandes de confirmation';

  @override
  String get settingsConfirmationDialogTitle => 'Demandes de confirmation';

  @override
  String get settingsConfirmationBeforeDeleteItems => 'Suppression définitive d’éléments';

  @override
  String get settingsConfirmationBeforeMoveToBinItems => 'Mise d’éléments à la corbeille';

  @override
  String get settingsConfirmationBeforeMoveUndatedItems => 'Déplacement d’éléments non datés';

  @override
  String get settingsConfirmationAfterMoveToBinItems => 'Confirmation après mise d’éléments à la corbeille';

  @override
  String get settingsConfirmationVaultDataLoss => 'Afficher l’avertissement sur la perte de données avec les coffres-forts';

  @override
  String get settingsNavigationDrawerTile => 'Menu de navigation';

  @override
  String get settingsNavigationDrawerEditorPageTitle => 'Menu de navigation';

  @override
  String get settingsNavigationDrawerBanner => 'Maintenez votre doigt appuyé pour déplacer et réorganiser les éléments de menu.';

  @override
  String get settingsNavigationDrawerTabTypes => 'Types';

  @override
  String get settingsNavigationDrawerTabAlbums => 'Albums';

  @override
  String get settingsNavigationDrawerTabPages => 'Pages';

  @override
  String get settingsNavigationDrawerAddAlbum => 'Ajouter un album';

  @override
  String get settingsThumbnailSectionTitle => 'Vignettes';

  @override
  String get settingsThumbnailOverlayTile => 'Incrustations';

  @override
  String get settingsThumbnailOverlayPageTitle => 'Incrustations';

  @override
  String get settingsThumbnailShowHdrIcon => 'Afficher l’icône HDR';

  @override
  String get settingsThumbnailShowFavouriteIcon => 'Afficher l’icône de favori';

  @override
  String get settingsThumbnailShowTagIcon => 'Afficher l’icône d’étiquette';

  @override
  String get settingsThumbnailShowLocationIcon => 'Afficher l’icône de lieu';

  @override
  String get settingsThumbnailShowMotionPhotoIcon => 'Afficher l’icône de photo animée';

  @override
  String get settingsThumbnailShowRating => 'Afficher la notation';

  @override
  String get settingsThumbnailShowRawIcon => 'Afficher l’icône de photo raw';

  @override
  String get settingsThumbnailShowVideoDuration => 'Afficher la durée de la vidéo';

  @override
  String get settingsCollectionQuickActionsTile => 'Actions rapides';

  @override
  String get settingsCollectionQuickActionEditorPageTitle => 'Actions rapides';

  @override
  String get settingsCollectionQuickActionTabBrowsing => 'Navigation';

  @override
  String get settingsCollectionQuickActionTabSelecting => 'Sélection';

  @override
  String get settingsCollectionBrowsingQuickActionEditorBanner => 'Maintenez votre doigt appuyé pour déplacer les boutons et choisir les actions affichées lors de la navigation.';

  @override
  String get settingsCollectionSelectionQuickActionEditorBanner => 'Maintenez votre doigt appuyé pour déplacer les boutons et choisir les actions affichées lors de la sélection d’éléments.';

  @override
  String get settingsCollectionBurstPatternsTile => 'Modèles de rafale';

  @override
  String get settingsCollectionBurstPatternsNone => 'Aucun';

  @override
  String get settingsViewerSectionTitle => 'Visionneuse';

  @override
  String get settingsViewerGestureSideTapNext => 'Appuyer sur les bords de l’écran pour passer à l’élément précédent/suivant';

  @override
  String get settingsViewerUseCutout => 'Utiliser la zone d’encoche';

  @override
  String get settingsViewerMaximumBrightness => 'Luminosité maximale';

  @override
  String get settingsMotionPhotoAutoPlay => 'Lecture automatique des photos animées';

  @override
  String get settingsImageBackground => 'Arrière-plan de l’image';

  @override
  String get settingsViewerQuickActionsTile => 'Actions rapides';

  @override
  String get settingsViewerQuickActionEditorPageTitle => 'Actions rapides';

  @override
  String get settingsViewerQuickActionEditorBanner => 'Maintenez votre doigt appuyé pour déplacer les boutons et choisir les actions affichées sur la visionneuse.';

  @override
  String get settingsViewerQuickActionEditorDisplayedButtonsSectionTitle => 'Boutons affichés';

  @override
  String get settingsViewerQuickActionEditorAvailableButtonsSectionTitle => 'Boutons disponibles';

  @override
  String get settingsViewerQuickActionEmpty => 'Aucun bouton';

  @override
  String get settingsViewerOverlayTile => 'Incrustations';

  @override
  String get settingsViewerOverlayPageTitle => 'Incrustations';

  @override
  String get settingsViewerShowOverlayOnOpening => 'Afficher à l’ouverture';

  @override
  String get settingsViewerShowHistogram => 'Afficher l\'histogramme';

  @override
  String get settingsViewerShowMinimap => 'Afficher la mini-carte';

  @override
  String get settingsViewerShowInformation => 'Afficher les détails';

  @override
  String get settingsViewerShowInformationSubtitle => 'Afficher les titre, date, lieu, etc.';

  @override
  String get settingsViewerShowRatingTags => 'Afficher la notation et les étiquettes';

  @override
  String get settingsViewerShowShootingDetails => 'Afficher les détails de prise de vue';

  @override
  String get settingsViewerShowDescription => 'Afficher la description';

  @override
  String get settingsViewerShowOverlayThumbnails => 'Afficher les vignettes';

  @override
  String get settingsViewerEnableOverlayBlurEffect => 'Effets de flou';

  @override
  String get settingsViewerSlideshowTile => 'Diaporama';

  @override
  String get settingsViewerSlideshowPageTitle => 'Diaporama';

  @override
  String get settingsSlideshowRepeat => 'Répéter';

  @override
  String get settingsSlideshowShuffle => 'Aléatoire';

  @override
  String get settingsSlideshowFillScreen => 'Remplir l’écran';

  @override
  String get settingsSlideshowAnimatedZoomEffect => 'Effet de zoom animé';

  @override
  String get settingsSlideshowTransitionTile => 'Transition';

  @override
  String get settingsSlideshowIntervalTile => 'Intervalle';

  @override
  String get settingsSlideshowVideoPlaybackTile => 'Lecture de vidéos';

  @override
  String get settingsSlideshowVideoPlaybackDialogTitle => 'Lecture de vidéos';

  @override
  String get settingsVideoPageTitle => 'Réglages vidéo';

  @override
  String get settingsVideoSectionTitle => 'Vidéo';

  @override
  String get settingsVideoShowVideos => 'Afficher les vidéos';

  @override
  String get settingsVideoPlaybackTile => 'Lecture';

  @override
  String get settingsVideoPlaybackPageTitle => 'Lecture';

  @override
  String get settingsVideoEnableHardwareAcceleration => 'Accélération matérielle';

  @override
  String get settingsVideoAutoPlay => 'Lecture automatique';

  @override
  String get settingsVideoLoopModeTile => 'Lecture répétée';

  @override
  String get settingsVideoLoopModeDialogTitle => 'Lecture répétée';

  @override
  String get settingsVideoResumptionModeTile => 'Reprise de lecture';

  @override
  String get settingsVideoResumptionModeDialogTitle => 'Reprise de lecture';

  @override
  String get settingsVideoBackgroundMode => 'Lecture en arrière-plan';

  @override
  String get settingsVideoBackgroundModeDialogTitle => 'Arrière-plan';

  @override
  String get settingsVideoControlsTile => 'Contrôles';

  @override
  String get settingsVideoControlsPageTitle => 'Contrôles';

  @override
  String get settingsVideoButtonsTile => 'Boutons';

  @override
  String get settingsVideoGestureDoubleTapTogglePlay => 'Appuyer deux fois pour lire ou mettre en pause';

  @override
  String get settingsVideoGestureSideDoubleTapSeek => 'Appuyer deux fois sur les bords de l’écran pour reculer ou avancer';

  @override
  String get settingsVideoGestureVerticalDragBrightnessVolume => 'Balayer verticalement pour ajuster la luminosité et le volume';

  @override
  String get settingsSubtitleThemeTile => 'Sous-titres';

  @override
  String get settingsSubtitleThemePageTitle => 'Sous-titres';

  @override
  String get settingsSubtitleThemeSample => 'Ceci est un exemple.';

  @override
  String get settingsSubtitleThemeTextAlignmentTile => 'Alignement du texte';

  @override
  String get settingsSubtitleThemeTextAlignmentDialogTitle => 'Alignement du texte';

  @override
  String get settingsSubtitleThemeTextPositionTile => 'Position du texte';

  @override
  String get settingsSubtitleThemeTextPositionDialogTitle => 'Position du texte';

  @override
  String get settingsSubtitleThemeTextSize => 'Taille du texte';

  @override
  String get settingsSubtitleThemeShowOutline => 'Afficher les contours et ombres';

  @override
  String get settingsSubtitleThemeTextColor => 'Couleur du texte';

  @override
  String get settingsSubtitleThemeTextOpacity => 'Transparence du texte';

  @override
  String get settingsSubtitleThemeBackgroundColor => 'Couleur d’arrière-plan';

  @override
  String get settingsSubtitleThemeBackgroundOpacity => 'Transparence de l’arrière-plan';

  @override
  String get settingsSubtitleThemeTextAlignmentLeft => 'gauche';

  @override
  String get settingsSubtitleThemeTextAlignmentCenter => 'centré';

  @override
  String get settingsSubtitleThemeTextAlignmentRight => 'droite';

  @override
  String get settingsPrivacySectionTitle => 'Confidentialité';

  @override
  String get settingsAllowInstalledAppAccess => 'Autoriser l’accès à l’inventaire des apps';

  @override
  String get settingsAllowInstalledAppAccessSubtitle => 'Pour un affichage amélioré des albums';

  @override
  String get settingsAllowErrorReporting => 'Autoriser l’envoi de rapports d’erreur';

  @override
  String get settingsSaveSearchHistory => 'Maintenir un historique des recherches';

  @override
  String get settingsEnableBin => 'Utiliser la corbeille';

  @override
  String get settingsEnableBinSubtitle => 'Conserver les éléments supprimés pendant 30 jours';

  @override
  String get settingsDisablingBinWarningDialogMessage => 'Les éléments dans la corbeille seront supprimés définitivement.';

  @override
  String get settingsAllowMediaManagement => 'Autoriser la gestion des médias';

  @override
  String get settingsHiddenItemsTile => 'Éléments masqués';

  @override
  String get settingsHiddenItemsPageTitle => 'Éléments masqués';

  @override
  String get settingsHiddenFiltersBanner => 'Les images et vidéos correspondantes aux filtres masqués n’apparaîtront pas dans votre collection.';

  @override
  String get settingsHiddenFiltersEmpty => 'Aucun filtre masqué';

  @override
  String get settingsStorageAccessTile => 'Accès au stockage';

  @override
  String get settingsStorageAccessPageTitle => 'Accès au stockage';

  @override
  String get settingsStorageAccessBanner => 'Une autorisation d’accès au stockage est nécessaire pour modifier le contenu de certains dossiers. Voici la liste des autorisations couramment en vigueur.';

  @override
  String get settingsStorageAccessEmpty => 'Aucune autorisation d’accès';

  @override
  String get settingsStorageAccessRevokeTooltip => 'Retirer';

  @override
  String get settingsAccessibilitySectionTitle => 'Accessibilité';

  @override
  String get settingsRemoveAnimationsTile => 'Suppression des animations';

  @override
  String get settingsRemoveAnimationsDialogTitle => 'Suppression des animations';

  @override
  String get settingsTimeToTakeActionTile => 'Délai pour effectuer une action';

  @override
  String get settingsAccessibilityShowPinchGestureAlternatives => 'Afficher des alternatives aux interactions multitactiles';

  @override
  String get settingsDisplaySectionTitle => 'Affichage';

  @override
  String get settingsThemeBrightnessTile => 'Thème';

  @override
  String get settingsThemeBrightnessDialogTitle => 'Thème';

  @override
  String get settingsThemeColorHighlights => 'Surlignages colorés';

  @override
  String get settingsThemeEnableDynamicColor => 'Couleur dynamique';

  @override
  String get settingsDisplayRefreshRateModeTile => 'Fréquence d’actualisation de l’écran';

  @override
  String get settingsDisplayRefreshRateModeDialogTitle => 'Fréquence d’actualisation';

  @override
  String get settingsDisplayUseTvInterface => 'Interface Android TV';

  @override
  String get settingsLanguageSectionTitle => 'Langue & Formats';

  @override
  String get settingsLanguageTile => 'Langue';

  @override
  String get settingsLanguagePageTitle => 'Langue';

  @override
  String get settingsCoordinateFormatTile => 'Format de coordonnées';

  @override
  String get settingsCoordinateFormatDialogTitle => 'Format de coordonnées';

  @override
  String get settingsUnitSystemTile => 'Unités';

  @override
  String get settingsUnitSystemDialogTitle => 'Unités';

  @override
  String get settingsForceWesternArabicNumeralsTile => 'Toujours utiliser les chiffres arabes';

  @override
  String get settingsScreenSaverPageTitle => 'Économiseur d’écran';

  @override
  String get settingsWidgetPageTitle => 'Cadre photo';

  @override
  String get settingsWidgetShowOutline => 'Contours';

  @override
  String get settingsWidgetOpenPage => 'Quand vous appuyez sur le widget';

  @override
  String get settingsWidgetDisplayedItem => 'Élément affiché';

  @override
  String get settingsCollectionTile => 'Collection';

  @override
  String get statsPageTitle => 'Statistiques';

  @override
  String statsWithGps(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString éléments localisés',
      one: '1 élément localisé',
    );
    return '$_temp0';
  }

  @override
  String get statsTopCountriesSectionTitle => 'Top pays';

  @override
  String get statsTopStatesSectionTitle => 'Top États';

  @override
  String get statsTopPlacesSectionTitle => 'Top lieux';

  @override
  String get statsTopTagsSectionTitle => 'Top étiquettes';

  @override
  String get statsTopAlbumsSectionTitle => 'Top albums';

  @override
  String get viewerOpenPanoramaButtonLabel => 'OUVRIR LE PANORAMA';

  @override
  String get viewerSetWallpaperButtonLabel => 'APPLIQUER';

  @override
  String get viewerErrorUnknown => 'Zut !';

  @override
  String get viewerErrorDoesNotExist => 'Le fichier n’existe plus.';

  @override
  String get viewerInfoPageTitle => 'Détails';

  @override
  String get viewerInfoBackToViewerTooltip => 'Retour à la visionneuse';

  @override
  String get viewerInfoUnknown => 'inconnu';

  @override
  String get viewerInfoLabelDescription => 'Description';

  @override
  String get viewerInfoLabelTitle => 'Titre';

  @override
  String get viewerInfoLabelDate => 'Date';

  @override
  String get viewerInfoLabelResolution => 'Résolution';

  @override
  String get viewerInfoLabelSize => 'Taille';

  @override
  String get viewerInfoLabelUri => 'URI';

  @override
  String get viewerInfoLabelPath => 'Chemin';

  @override
  String get viewerInfoLabelDuration => 'Durée';

  @override
  String get viewerInfoLabelOwner => 'Propriétaire';

  @override
  String get viewerInfoLabelCoordinates => 'Coordonnées';

  @override
  String get viewerInfoLabelAddress => 'Adresse';

  @override
  String get mapStyleDialogTitle => 'Type de carte';

  @override
  String get mapStyleTooltip => 'Sélectionner le type de carte';

  @override
  String get mapZoomInTooltip => 'Zoomer';

  @override
  String get mapZoomOutTooltip => 'Dézoomer';

  @override
  String get mapPointNorthUpTooltip => 'Placer le nord en haut';

  @override
  String get mapAttributionOsmData => 'Données © les contributeurs d’[OpenStreetMap](https://www.openstreetmap.org/copyright)';

  @override
  String get mapAttributionOsmLiberty => 'Fond de carte par [OpenMapTiles](https://www.openmaptiles.org/), [CC BY](http://creativecommons.org/licenses/by/4.0) • Hébergé par [OSM Americana](https://tile.ourmap.us)';

  @override
  String get mapAttributionOpenTopoMap => '[SRTM](https://www.earthdata.nasa.gov/sensors/srtm) | Fond de carte par [OpenTopoMap](https://opentopomap.org/), [CC BY-SA](https://creativecommons.org/licenses/by-sa/3.0/)';

  @override
  String get mapAttributionOsmHot => 'Fond de carte par [HOT](https://www.hotosm.org/) • Hébergé par [OSM France](https://openstreetmap.fr/)';

  @override
  String get mapAttributionStamen => 'Fond de carte par [Stamen Design](https://stamen.com), [CC BY 3.0](https://creativecommons.org/licenses/by/3.0)';

  @override
  String get openMapPageTooltip => 'Ouvrir la page Carte';

  @override
  String get mapEmptyRegion => 'Aucune image dans cette région';

  @override
  String get viewerInfoOpenEmbeddedFailureFeedback => 'Échec de l’extraction des données';

  @override
  String get viewerInfoOpenLinkText => 'Ouvrir';

  @override
  String get viewerInfoViewXmlLinkText => 'Afficher le XML';

  @override
  String get viewerInfoSearchFieldLabel => 'Recherche de métadonnées';

  @override
  String get viewerInfoSearchEmpty => 'Aucune clé correspondante';

  @override
  String get viewerInfoSearchSuggestionDate => 'Date & heure';

  @override
  String get viewerInfoSearchSuggestionDescription => 'Description';

  @override
  String get viewerInfoSearchSuggestionDimensions => 'Dimensions';

  @override
  String get viewerInfoSearchSuggestionResolution => 'Résolution';

  @override
  String get viewerInfoSearchSuggestionRights => 'Droits';

  @override
  String get wallpaperUseScrollEffect => 'Utiliser l’effet de défilement sur l’écran d’accueil';

  @override
  String get tagEditorPageTitle => 'Modifier les étiquettes';

  @override
  String get tagEditorPageNewTagFieldLabel => 'Nouvelle étiquette';

  @override
  String get tagEditorPageAddTagTooltip => 'Ajouter l’étiquette';

  @override
  String get tagEditorSectionRecent => 'Ajouts récents';

  @override
  String get tagEditorSectionPlaceholders => 'Étiquettes de substitution';

  @override
  String get tagEditorDiscardDialogMessage => 'Voulez-vous ignorer les changements ?';

  @override
  String get tagPlaceholderCountry => 'Pays';

  @override
  String get tagPlaceholderState => 'État';

  @override
  String get tagPlaceholderPlace => 'Lieu';

  @override
  String get panoramaEnableSensorControl => 'Activer le contrôle par capteurs';

  @override
  String get panoramaDisableSensorControl => 'Désactiver le contrôle par capteurs';

  @override
  String get sourceViewerPageTitle => 'Code source';

  @override
  String get filePickerShowHiddenFiles => 'Afficher les fichiers masqués';

  @override
  String get filePickerDoNotShowHiddenFiles => 'Ne pas afficher les fichiers masqués';

  @override
  String get filePickerOpenFrom => 'Ouvrir à partir de';

  @override
  String get filePickerNoItems => 'Aucun élément';

  @override
  String get filePickerUseThisFolder => 'Utiliser ce dossier';
}
