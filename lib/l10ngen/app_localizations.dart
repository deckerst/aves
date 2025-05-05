import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_az.dart';
import 'app_localizations_be.dart';
import 'app_localizations_bg.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_ca.dart';
import 'app_localizations_ckb.dart';
import 'app_localizations_cs.dart';
import 'app_localizations_da.dart';
import 'app_localizations_de.dart';
import 'app_localizations_el.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_et.dart';
import 'app_localizations_eu.dart';
import 'app_localizations_fa.dart';
import 'app_localizations_fi.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_gl.dart';
import 'app_localizations_he.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_hu.dart';
import 'app_localizations_id.dart';
import 'app_localizations_is.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_kn.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_lt.dart';
import 'app_localizations_ml.dart';
import 'app_localizations_my.dart';
import 'app_localizations_nb.dart';
import 'app_localizations_ne.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_nn.dart';
import 'app_localizations_or.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ro.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_sat.dart';
import 'app_localizations_sk.dart';
import 'app_localizations_sl.dart';
import 'app_localizations_sr.dart';
import 'app_localizations_sv.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_th.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_uk.dart';
import 'app_localizations_ur.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10ngen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ar'),
    Locale('az'),
    Locale('be'),
    Locale('bg'),
    Locale('bn'),
    Locale('ca'),
    Locale('ckb'),
    Locale('cs'),
    Locale('da'),
    Locale('de'),
    Locale('el'),
    Locale.fromSubtags(languageCode: 'en', scriptCode: 'Shaw'),
    Locale('es'),
    Locale('et'),
    Locale('eu'),
    Locale('fa'),
    Locale('fi'),
    Locale('fr'),
    Locale('gl'),
    Locale('he'),
    Locale('hi'),
    Locale('hu'),
    Locale('id'),
    Locale('is'),
    Locale('it'),
    Locale('ja'),
    Locale('kn'),
    Locale('ko'),
    Locale('lt'),
    Locale('ml'),
    Locale('my'),
    Locale('nb'),
    Locale('ne'),
    Locale('nl'),
    Locale('nn'),
    Locale('or'),
    Locale('pl'),
    Locale('pt'),
    Locale('ro'),
    Locale('ru'),
    Locale('sat'),
    Locale('sk'),
    Locale('sl'),
    Locale('sr'),
    Locale('sv'),
    Locale('ta'),
    Locale('th'),
    Locale('tr'),
    Locale('uk'),
    Locale('ur'),
    Locale('vi'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Aves'**
  String get appName;

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Aves'**
  String get welcomeMessage;

  /// No description provided for @welcomeOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get welcomeOptional;

  /// No description provided for @welcomeTermsToggle.
  ///
  /// In en, this message translates to:
  /// **'I agree to the terms and conditions'**
  String get welcomeTermsToggle;

  /// No description provided for @itemCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} item} other{{count} items}}'**
  String itemCount(int count);

  /// No description provided for @columnCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} column} other{{count} columns}}'**
  String columnCount(int count);

  /// No description provided for @timeSeconds.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} second} other{{count} seconds}}'**
  String timeSeconds(int count);

  /// No description provided for @timeMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} minute} other{{count} minutes}}'**
  String timeMinutes(int count);

  /// No description provided for @timeDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} day} other{{count} days}}'**
  String timeDays(int count);

  /// No description provided for @focalLength.
  ///
  /// In en, this message translates to:
  /// **'{length} mm'**
  String focalLength(String length);

  /// No description provided for @applyButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'APPLY'**
  String get applyButtonLabel;

  /// No description provided for @createButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'CREATE'**
  String get createButtonLabel;

  /// No description provided for @deleteButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get deleteButtonLabel;

  /// No description provided for @nextButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'NEXT'**
  String get nextButtonLabel;

  /// No description provided for @showButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'SHOW'**
  String get showButtonLabel;

  /// No description provided for @hideButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'HIDE'**
  String get hideButtonLabel;

  /// No description provided for @continueButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE'**
  String get continueButtonLabel;

  /// No description provided for @saveCopyButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'SAVE COPY'**
  String get saveCopyButtonLabel;

  /// No description provided for @applyTooltip.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get applyTooltip;

  /// No description provided for @cancelTooltip.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelTooltip;

  /// No description provided for @changeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get changeTooltip;

  /// No description provided for @clearTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearTooltip;

  /// No description provided for @previousTooltip.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previousTooltip;

  /// No description provided for @nextTooltip.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextTooltip;

  /// No description provided for @showTooltip.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get showTooltip;

  /// No description provided for @hideTooltip.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get hideTooltip;

  /// No description provided for @actionRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get actionRemove;

  /// No description provided for @resetTooltip.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetTooltip;

  /// No description provided for @saveTooltip.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveTooltip;

  /// No description provided for @stopTooltip.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stopTooltip;

  /// No description provided for @pickTooltip.
  ///
  /// In en, this message translates to:
  /// **'Pick'**
  String get pickTooltip;

  /// No description provided for @doubleBackExitMessage.
  ///
  /// In en, this message translates to:
  /// **'Tap “back” again to exit.'**
  String get doubleBackExitMessage;

  /// No description provided for @doNotAskAgain.
  ///
  /// In en, this message translates to:
  /// **'Do not ask again'**
  String get doNotAskAgain;

  /// No description provided for @sourceStateLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get sourceStateLoading;

  /// No description provided for @sourceStateCataloguing.
  ///
  /// In en, this message translates to:
  /// **'Cataloguing'**
  String get sourceStateCataloguing;

  /// No description provided for @sourceStateLocatingCountries.
  ///
  /// In en, this message translates to:
  /// **'Locating countries'**
  String get sourceStateLocatingCountries;

  /// No description provided for @sourceStateLocatingPlaces.
  ///
  /// In en, this message translates to:
  /// **'Locating places'**
  String get sourceStateLocatingPlaces;

  /// No description provided for @chipActionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get chipActionDelete;

  /// No description provided for @chipActionRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get chipActionRemove;

  /// No description provided for @chipActionShowCollection.
  ///
  /// In en, this message translates to:
  /// **'Show in Collection'**
  String get chipActionShowCollection;

  /// No description provided for @chipActionGoToAlbumPage.
  ///
  /// In en, this message translates to:
  /// **'Show in Albums'**
  String get chipActionGoToAlbumPage;

  /// No description provided for @chipActionGoToCountryPage.
  ///
  /// In en, this message translates to:
  /// **'Show in Countries'**
  String get chipActionGoToCountryPage;

  /// No description provided for @chipActionGoToPlacePage.
  ///
  /// In en, this message translates to:
  /// **'Show in Places'**
  String get chipActionGoToPlacePage;

  /// No description provided for @chipActionGoToTagPage.
  ///
  /// In en, this message translates to:
  /// **'Show in Tags'**
  String get chipActionGoToTagPage;

  /// No description provided for @chipActionGoToExplorerPage.
  ///
  /// In en, this message translates to:
  /// **'Show in Explorer'**
  String get chipActionGoToExplorerPage;

  /// No description provided for @chipActionDecompose.
  ///
  /// In en, this message translates to:
  /// **'Split'**
  String get chipActionDecompose;

  /// No description provided for @chipActionFilterOut.
  ///
  /// In en, this message translates to:
  /// **'Filter out'**
  String get chipActionFilterOut;

  /// No description provided for @chipActionFilterIn.
  ///
  /// In en, this message translates to:
  /// **'Filter in'**
  String get chipActionFilterIn;

  /// No description provided for @chipActionHide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get chipActionHide;

  /// No description provided for @chipActionLock.
  ///
  /// In en, this message translates to:
  /// **'Lock'**
  String get chipActionLock;

  /// No description provided for @chipActionPin.
  ///
  /// In en, this message translates to:
  /// **'Pin to top'**
  String get chipActionPin;

  /// No description provided for @chipActionUnpin.
  ///
  /// In en, this message translates to:
  /// **'Unpin from top'**
  String get chipActionUnpin;

  /// No description provided for @chipActionGroup.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get chipActionGroup;

  /// No description provided for @chipActionRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get chipActionRename;

  /// No description provided for @chipActionSetCover.
  ///
  /// In en, this message translates to:
  /// **'Set cover'**
  String get chipActionSetCover;

  /// No description provided for @chipActionShowCountryStates.
  ///
  /// In en, this message translates to:
  /// **'Show states'**
  String get chipActionShowCountryStates;

  /// No description provided for @chipActionCreateGroup.
  ///
  /// In en, this message translates to:
  /// **'Create group'**
  String get chipActionCreateGroup;

  /// No description provided for @chipActionCreateAlbum.
  ///
  /// In en, this message translates to:
  /// **'Create album'**
  String get chipActionCreateAlbum;

  /// No description provided for @chipActionCreateVault.
  ///
  /// In en, this message translates to:
  /// **'Create vault'**
  String get chipActionCreateVault;

  /// No description provided for @chipActionConfigureVault.
  ///
  /// In en, this message translates to:
  /// **'Configure vault'**
  String get chipActionConfigureVault;

  /// No description provided for @entryActionCopyToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copy to clipboard'**
  String get entryActionCopyToClipboard;

  /// No description provided for @entryActionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get entryActionDelete;

  /// No description provided for @entryActionConvert.
  ///
  /// In en, this message translates to:
  /// **'Convert'**
  String get entryActionConvert;

  /// No description provided for @entryActionExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get entryActionExport;

  /// No description provided for @entryActionInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get entryActionInfo;

  /// No description provided for @entryActionRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get entryActionRename;

  /// No description provided for @entryActionRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get entryActionRestore;

  /// No description provided for @entryActionRotateCCW.
  ///
  /// In en, this message translates to:
  /// **'Rotate counterclockwise'**
  String get entryActionRotateCCW;

  /// No description provided for @entryActionRotateCW.
  ///
  /// In en, this message translates to:
  /// **'Rotate clockwise'**
  String get entryActionRotateCW;

  /// No description provided for @entryActionFlip.
  ///
  /// In en, this message translates to:
  /// **'Flip horizontally'**
  String get entryActionFlip;

  /// No description provided for @entryActionPrint.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get entryActionPrint;

  /// No description provided for @entryActionShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get entryActionShare;

  /// No description provided for @entryActionShareImageOnly.
  ///
  /// In en, this message translates to:
  /// **'Share image only'**
  String get entryActionShareImageOnly;

  /// No description provided for @entryActionShareVideoOnly.
  ///
  /// In en, this message translates to:
  /// **'Share video only'**
  String get entryActionShareVideoOnly;

  /// No description provided for @entryActionViewSource.
  ///
  /// In en, this message translates to:
  /// **'View source'**
  String get entryActionViewSource;

  /// No description provided for @entryActionShowGeoTiffOnMap.
  ///
  /// In en, this message translates to:
  /// **'Show as map overlay'**
  String get entryActionShowGeoTiffOnMap;

  /// No description provided for @entryActionConvertMotionPhotoToStillImage.
  ///
  /// In en, this message translates to:
  /// **'Convert to still image'**
  String get entryActionConvertMotionPhotoToStillImage;

  /// No description provided for @entryActionViewMotionPhotoVideo.
  ///
  /// In en, this message translates to:
  /// **'Open video'**
  String get entryActionViewMotionPhotoVideo;

  /// No description provided for @entryActionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get entryActionEdit;

  /// No description provided for @entryActionOpen.
  ///
  /// In en, this message translates to:
  /// **'Open with'**
  String get entryActionOpen;

  /// No description provided for @entryActionSetAs.
  ///
  /// In en, this message translates to:
  /// **'Set as'**
  String get entryActionSetAs;

  /// No description provided for @entryActionCast.
  ///
  /// In en, this message translates to:
  /// **'Cast'**
  String get entryActionCast;

  /// No description provided for @entryActionOpenMap.
  ///
  /// In en, this message translates to:
  /// **'Show in map app'**
  String get entryActionOpenMap;

  /// No description provided for @entryActionRotateScreen.
  ///
  /// In en, this message translates to:
  /// **'Rotate screen'**
  String get entryActionRotateScreen;

  /// No description provided for @entryActionAddFavourite.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get entryActionAddFavourite;

  /// No description provided for @entryActionRemoveFavourite.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get entryActionRemoveFavourite;

  /// No description provided for @videoActionCaptureFrame.
  ///
  /// In en, this message translates to:
  /// **'Capture frame'**
  String get videoActionCaptureFrame;

  /// No description provided for @videoActionMute.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get videoActionMute;

  /// No description provided for @videoActionUnmute.
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get videoActionUnmute;

  /// No description provided for @videoActionPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get videoActionPause;

  /// No description provided for @videoActionPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get videoActionPlay;

  /// No description provided for @videoActionReplay10.
  ///
  /// In en, this message translates to:
  /// **'Seek backward 10 seconds'**
  String get videoActionReplay10;

  /// No description provided for @videoActionSkip10.
  ///
  /// In en, this message translates to:
  /// **'Seek forward 10 seconds'**
  String get videoActionSkip10;

  /// No description provided for @videoActionShowPreviousFrame.
  ///
  /// In en, this message translates to:
  /// **'Show previous frame'**
  String get videoActionShowPreviousFrame;

  /// No description provided for @videoActionShowNextFrame.
  ///
  /// In en, this message translates to:
  /// **'Show next frame'**
  String get videoActionShowNextFrame;

  /// No description provided for @videoActionSelectStreams.
  ///
  /// In en, this message translates to:
  /// **'Select tracks'**
  String get videoActionSelectStreams;

  /// No description provided for @videoActionSetSpeed.
  ///
  /// In en, this message translates to:
  /// **'Playback speed'**
  String get videoActionSetSpeed;

  /// No description provided for @videoActionABRepeat.
  ///
  /// In en, this message translates to:
  /// **'A-B repeat'**
  String get videoActionABRepeat;

  /// No description provided for @videoRepeatActionSetStart.
  ///
  /// In en, this message translates to:
  /// **'Set start'**
  String get videoRepeatActionSetStart;

  /// No description provided for @videoRepeatActionSetEnd.
  ///
  /// In en, this message translates to:
  /// **'Set end'**
  String get videoRepeatActionSetEnd;

  /// No description provided for @viewerActionSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get viewerActionSettings;

  /// No description provided for @viewerActionLock.
  ///
  /// In en, this message translates to:
  /// **'Lock viewer'**
  String get viewerActionLock;

  /// No description provided for @viewerActionUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock viewer'**
  String get viewerActionUnlock;

  /// No description provided for @slideshowActionResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get slideshowActionResume;

  /// No description provided for @slideshowActionShowInCollection.
  ///
  /// In en, this message translates to:
  /// **'Show in Collection'**
  String get slideshowActionShowInCollection;

  /// No description provided for @entryInfoActionEditDate.
  ///
  /// In en, this message translates to:
  /// **'Edit date & time'**
  String get entryInfoActionEditDate;

  /// No description provided for @entryInfoActionEditLocation.
  ///
  /// In en, this message translates to:
  /// **'Edit location'**
  String get entryInfoActionEditLocation;

  /// No description provided for @entryInfoActionEditTitleDescription.
  ///
  /// In en, this message translates to:
  /// **'Edit title & description'**
  String get entryInfoActionEditTitleDescription;

  /// No description provided for @entryInfoActionEditRating.
  ///
  /// In en, this message translates to:
  /// **'Edit rating'**
  String get entryInfoActionEditRating;

  /// No description provided for @entryInfoActionEditTags.
  ///
  /// In en, this message translates to:
  /// **'Edit tags'**
  String get entryInfoActionEditTags;

  /// No description provided for @entryInfoActionRemoveMetadata.
  ///
  /// In en, this message translates to:
  /// **'Remove metadata'**
  String get entryInfoActionRemoveMetadata;

  /// No description provided for @entryInfoActionExportMetadata.
  ///
  /// In en, this message translates to:
  /// **'Export metadata'**
  String get entryInfoActionExportMetadata;

  /// No description provided for @entryInfoActionRemoveLocation.
  ///
  /// In en, this message translates to:
  /// **'Remove location'**
  String get entryInfoActionRemoveLocation;

  /// No description provided for @editorActionTransform.
  ///
  /// In en, this message translates to:
  /// **'Transform'**
  String get editorActionTransform;

  /// No description provided for @editorTransformCrop.
  ///
  /// In en, this message translates to:
  /// **'Crop'**
  String get editorTransformCrop;

  /// No description provided for @editorTransformRotate.
  ///
  /// In en, this message translates to:
  /// **'Rotate'**
  String get editorTransformRotate;

  /// No description provided for @cropAspectRatioFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get cropAspectRatioFree;

  /// No description provided for @cropAspectRatioOriginal.
  ///
  /// In en, this message translates to:
  /// **'Original'**
  String get cropAspectRatioOriginal;

  /// No description provided for @cropAspectRatioSquare.
  ///
  /// In en, this message translates to:
  /// **'Square'**
  String get cropAspectRatioSquare;

  /// No description provided for @filterAspectRatioLandscapeLabel.
  ///
  /// In en, this message translates to:
  /// **'Landscape'**
  String get filterAspectRatioLandscapeLabel;

  /// No description provided for @filterAspectRatioPortraitLabel.
  ///
  /// In en, this message translates to:
  /// **'Portrait'**
  String get filterAspectRatioPortraitLabel;

  /// No description provided for @filterBinLabel.
  ///
  /// In en, this message translates to:
  /// **'Recycle bin'**
  String get filterBinLabel;

  /// No description provided for @filterFavouriteLabel.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get filterFavouriteLabel;

  /// No description provided for @filterNoDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Undated'**
  String get filterNoDateLabel;

  /// No description provided for @filterNoAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'No address'**
  String get filterNoAddressLabel;

  /// No description provided for @filterLocatedLabel.
  ///
  /// In en, this message translates to:
  /// **'Located'**
  String get filterLocatedLabel;

  /// No description provided for @filterNoLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Unlocated'**
  String get filterNoLocationLabel;

  /// No description provided for @filterNoRatingLabel.
  ///
  /// In en, this message translates to:
  /// **'Unrated'**
  String get filterNoRatingLabel;

  /// No description provided for @filterTaggedLabel.
  ///
  /// In en, this message translates to:
  /// **'Tagged'**
  String get filterTaggedLabel;

  /// No description provided for @filterNoTagLabel.
  ///
  /// In en, this message translates to:
  /// **'Untagged'**
  String get filterNoTagLabel;

  /// No description provided for @filterNoTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get filterNoTitleLabel;

  /// No description provided for @filterOnThisDayLabel.
  ///
  /// In en, this message translates to:
  /// **'On this day'**
  String get filterOnThisDayLabel;

  /// No description provided for @filterRecentlyAddedLabel.
  ///
  /// In en, this message translates to:
  /// **'Recently added'**
  String get filterRecentlyAddedLabel;

  /// No description provided for @filterRatingRejectedLabel.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get filterRatingRejectedLabel;

  /// No description provided for @filterTypeAnimatedLabel.
  ///
  /// In en, this message translates to:
  /// **'Animated'**
  String get filterTypeAnimatedLabel;

  /// No description provided for @filterTypeMotionPhotoLabel.
  ///
  /// In en, this message translates to:
  /// **'Motion Photo'**
  String get filterTypeMotionPhotoLabel;

  /// No description provided for @filterTypePanoramaLabel.
  ///
  /// In en, this message translates to:
  /// **'Panorama'**
  String get filterTypePanoramaLabel;

  /// No description provided for @filterTypeRawLabel.
  ///
  /// In en, this message translates to:
  /// **'Raw'**
  String get filterTypeRawLabel;

  /// No description provided for @filterTypeSphericalVideoLabel.
  ///
  /// In en, this message translates to:
  /// **'360° Video'**
  String get filterTypeSphericalVideoLabel;

  /// No description provided for @filterTypeGeotiffLabel.
  ///
  /// In en, this message translates to:
  /// **'GeoTIFF'**
  String get filterTypeGeotiffLabel;

  /// No description provided for @filterMimeImageLabel.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get filterMimeImageLabel;

  /// No description provided for @filterMimeVideoLabel.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get filterMimeVideoLabel;

  /// No description provided for @accessibilityAnimationsRemove.
  ///
  /// In en, this message translates to:
  /// **'Prevent screen effects'**
  String get accessibilityAnimationsRemove;

  /// No description provided for @accessibilityAnimationsKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep screen effects'**
  String get accessibilityAnimationsKeep;

  /// No description provided for @albumTierNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get albumTierNew;

  /// No description provided for @albumTierPinned.
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get albumTierPinned;

  /// No description provided for @albumTierGroups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get albumTierGroups;

  /// No description provided for @albumTierSpecial.
  ///
  /// In en, this message translates to:
  /// **'Common'**
  String get albumTierSpecial;

  /// No description provided for @albumTierApps.
  ///
  /// In en, this message translates to:
  /// **'Apps'**
  String get albumTierApps;

  /// No description provided for @albumTierVaults.
  ///
  /// In en, this message translates to:
  /// **'Vaults'**
  String get albumTierVaults;

  /// No description provided for @albumTierDynamic.
  ///
  /// In en, this message translates to:
  /// **'Dynamic'**
  String get albumTierDynamic;

  /// No description provided for @albumTierRegular.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get albumTierRegular;

  /// No description provided for @coordinateFormatDms.
  ///
  /// In en, this message translates to:
  /// **'DMS'**
  String get coordinateFormatDms;

  /// No description provided for @coordinateFormatDdm.
  ///
  /// In en, this message translates to:
  /// **'DDM'**
  String get coordinateFormatDdm;

  /// No description provided for @coordinateFormatDecimal.
  ///
  /// In en, this message translates to:
  /// **'Decimal degrees'**
  String get coordinateFormatDecimal;

  /// No description provided for @coordinateDms.
  ///
  /// In en, this message translates to:
  /// **'{coordinate} {direction}'**
  String coordinateDms(String coordinate, String direction);

  /// No description provided for @coordinateDmsNorth.
  ///
  /// In en, this message translates to:
  /// **'N'**
  String get coordinateDmsNorth;

  /// No description provided for @coordinateDmsSouth.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get coordinateDmsSouth;

  /// No description provided for @coordinateDmsEast.
  ///
  /// In en, this message translates to:
  /// **'E'**
  String get coordinateDmsEast;

  /// No description provided for @coordinateDmsWest.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get coordinateDmsWest;

  /// No description provided for @displayRefreshRatePreferHighest.
  ///
  /// In en, this message translates to:
  /// **'Highest rate'**
  String get displayRefreshRatePreferHighest;

  /// No description provided for @displayRefreshRatePreferLowest.
  ///
  /// In en, this message translates to:
  /// **'Lowest rate'**
  String get displayRefreshRatePreferLowest;

  /// No description provided for @keepScreenOnNever.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get keepScreenOnNever;

  /// No description provided for @keepScreenOnVideoPlayback.
  ///
  /// In en, this message translates to:
  /// **'During video playback'**
  String get keepScreenOnVideoPlayback;

  /// No description provided for @keepScreenOnViewerOnly.
  ///
  /// In en, this message translates to:
  /// **'Viewer page only'**
  String get keepScreenOnViewerOnly;

  /// No description provided for @keepScreenOnAlways.
  ///
  /// In en, this message translates to:
  /// **'Always'**
  String get keepScreenOnAlways;

  /// No description provided for @lengthUnitPixel.
  ///
  /// In en, this message translates to:
  /// **'px'**
  String get lengthUnitPixel;

  /// No description provided for @lengthUnitPercent.
  ///
  /// In en, this message translates to:
  /// **'%'**
  String get lengthUnitPercent;

  /// No description provided for @mapStyleGoogleNormal.
  ///
  /// In en, this message translates to:
  /// **'Google Maps'**
  String get mapStyleGoogleNormal;

  /// No description provided for @mapStyleGoogleHybrid.
  ///
  /// In en, this message translates to:
  /// **'Google Maps (Hybrid)'**
  String get mapStyleGoogleHybrid;

  /// No description provided for @mapStyleGoogleTerrain.
  ///
  /// In en, this message translates to:
  /// **'Google Maps (Terrain)'**
  String get mapStyleGoogleTerrain;

  /// No description provided for @mapStyleOsmLiberty.
  ///
  /// In en, this message translates to:
  /// **'OSM Liberty'**
  String get mapStyleOsmLiberty;

  /// No description provided for @mapStyleOpenTopoMap.
  ///
  /// In en, this message translates to:
  /// **'OpenTopoMap'**
  String get mapStyleOpenTopoMap;

  /// No description provided for @mapStyleOsmHot.
  ///
  /// In en, this message translates to:
  /// **'Humanitarian OSM'**
  String get mapStyleOsmHot;

  /// No description provided for @mapStyleStamenWatercolor.
  ///
  /// In en, this message translates to:
  /// **'Stamen Watercolor'**
  String get mapStyleStamenWatercolor;

  /// No description provided for @maxBrightnessNever.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get maxBrightnessNever;

  /// No description provided for @maxBrightnessAlways.
  ///
  /// In en, this message translates to:
  /// **'Always'**
  String get maxBrightnessAlways;

  /// No description provided for @nameConflictStrategyRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get nameConflictStrategyRename;

  /// No description provided for @nameConflictStrategyReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get nameConflictStrategyReplace;

  /// No description provided for @nameConflictStrategySkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get nameConflictStrategySkip;

  /// No description provided for @overlayHistogramNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get overlayHistogramNone;

  /// No description provided for @overlayHistogramRGB.
  ///
  /// In en, this message translates to:
  /// **'RGB'**
  String get overlayHistogramRGB;

  /// No description provided for @overlayHistogramLuminance.
  ///
  /// In en, this message translates to:
  /// **'Luminance'**
  String get overlayHistogramLuminance;

  /// No description provided for @subtitlePositionTop.
  ///
  /// In en, this message translates to:
  /// **'Top'**
  String get subtitlePositionTop;

  /// No description provided for @subtitlePositionBottom.
  ///
  /// In en, this message translates to:
  /// **'Bottom'**
  String get subtitlePositionBottom;

  /// No description provided for @themeBrightnessLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeBrightnessLight;

  /// No description provided for @themeBrightnessDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeBrightnessDark;

  /// No description provided for @themeBrightnessBlack.
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get themeBrightnessBlack;

  /// No description provided for @unitSystemMetric.
  ///
  /// In en, this message translates to:
  /// **'Metric'**
  String get unitSystemMetric;

  /// No description provided for @unitSystemImperial.
  ///
  /// In en, this message translates to:
  /// **'Imperial'**
  String get unitSystemImperial;

  /// No description provided for @vaultLockTypePattern.
  ///
  /// In en, this message translates to:
  /// **'Pattern'**
  String get vaultLockTypePattern;

  /// No description provided for @vaultLockTypePin.
  ///
  /// In en, this message translates to:
  /// **'PIN'**
  String get vaultLockTypePin;

  /// No description provided for @vaultLockTypePassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get vaultLockTypePassword;

  /// No description provided for @settingsVideoEnablePip.
  ///
  /// In en, this message translates to:
  /// **'Picture-in-picture'**
  String get settingsVideoEnablePip;

  /// No description provided for @videoControlsPlayOutside.
  ///
  /// In en, this message translates to:
  /// **'Open with other player'**
  String get videoControlsPlayOutside;

  /// No description provided for @videoLoopModeNever.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get videoLoopModeNever;

  /// No description provided for @videoLoopModeShortOnly.
  ///
  /// In en, this message translates to:
  /// **'Short videos only'**
  String get videoLoopModeShortOnly;

  /// No description provided for @videoLoopModeAlways.
  ///
  /// In en, this message translates to:
  /// **'Always'**
  String get videoLoopModeAlways;

  /// No description provided for @videoPlaybackSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get videoPlaybackSkip;

  /// No description provided for @videoPlaybackMuted.
  ///
  /// In en, this message translates to:
  /// **'Play muted'**
  String get videoPlaybackMuted;

  /// No description provided for @videoPlaybackWithSound.
  ///
  /// In en, this message translates to:
  /// **'Play with sound'**
  String get videoPlaybackWithSound;

  /// No description provided for @videoResumptionModeNever.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get videoResumptionModeNever;

  /// No description provided for @videoResumptionModeAlways.
  ///
  /// In en, this message translates to:
  /// **'Always'**
  String get videoResumptionModeAlways;

  /// No description provided for @viewerTransitionSlide.
  ///
  /// In en, this message translates to:
  /// **'Slide'**
  String get viewerTransitionSlide;

  /// No description provided for @viewerTransitionParallax.
  ///
  /// In en, this message translates to:
  /// **'Parallax'**
  String get viewerTransitionParallax;

  /// No description provided for @viewerTransitionFade.
  ///
  /// In en, this message translates to:
  /// **'Fade'**
  String get viewerTransitionFade;

  /// No description provided for @viewerTransitionZoomIn.
  ///
  /// In en, this message translates to:
  /// **'Zoom in'**
  String get viewerTransitionZoomIn;

  /// No description provided for @viewerTransitionNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get viewerTransitionNone;

  /// No description provided for @wallpaperTargetHome.
  ///
  /// In en, this message translates to:
  /// **'Home screen'**
  String get wallpaperTargetHome;

  /// No description provided for @wallpaperTargetLock.
  ///
  /// In en, this message translates to:
  /// **'Lock screen'**
  String get wallpaperTargetLock;

  /// No description provided for @wallpaperTargetHomeLock.
  ///
  /// In en, this message translates to:
  /// **'Home and lock screens'**
  String get wallpaperTargetHomeLock;

  /// No description provided for @widgetDisplayedItemRandom.
  ///
  /// In en, this message translates to:
  /// **'Random'**
  String get widgetDisplayedItemRandom;

  /// No description provided for @widgetDisplayedItemMostRecent.
  ///
  /// In en, this message translates to:
  /// **'Most recent'**
  String get widgetDisplayedItemMostRecent;

  /// No description provided for @widgetOpenPageHome.
  ///
  /// In en, this message translates to:
  /// **'Open home'**
  String get widgetOpenPageHome;

  /// No description provided for @widgetOpenPageCollection.
  ///
  /// In en, this message translates to:
  /// **'Open collection'**
  String get widgetOpenPageCollection;

  /// No description provided for @widgetOpenPageViewer.
  ///
  /// In en, this message translates to:
  /// **'Open viewer'**
  String get widgetOpenPageViewer;

  /// No description provided for @widgetTapUpdateWidget.
  ///
  /// In en, this message translates to:
  /// **'Update widget'**
  String get widgetTapUpdateWidget;

  /// No description provided for @storageVolumeDescriptionFallbackPrimary.
  ///
  /// In en, this message translates to:
  /// **'Internal storage'**
  String get storageVolumeDescriptionFallbackPrimary;

  /// No description provided for @storageVolumeDescriptionFallbackNonPrimary.
  ///
  /// In en, this message translates to:
  /// **'SD card'**
  String get storageVolumeDescriptionFallbackNonPrimary;

  /// No description provided for @rootDirectoryDescription.
  ///
  /// In en, this message translates to:
  /// **'root directory'**
  String get rootDirectoryDescription;

  /// No description provided for @otherDirectoryDescription.
  ///
  /// In en, this message translates to:
  /// **'“{name}” directory'**
  String otherDirectoryDescription(String name);

  /// No description provided for @storageAccessDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Please select the {directory} of “{volume}” in the next screen to give this app access to it.'**
  String storageAccessDialogMessage(String directory, String volume);

  /// No description provided for @restrictedAccessDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'This app is not allowed to modify files in the {directory} of “{volume}”.\n\nPlease use a pre-installed file manager or gallery app to move the items to another directory.'**
  String restrictedAccessDialogMessage(String directory, String volume);

  /// No description provided for @notEnoughSpaceDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'This operation needs {neededSize} of free space on “{volume}” to complete, but there is only {freeSize} left.'**
  String notEnoughSpaceDialogMessage(String neededSize, String freeSize, String volume);

  /// No description provided for @missingSystemFilePickerDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'The system file picker is missing or disabled. Please enable it and try again.'**
  String get missingSystemFilePickerDialogMessage;

  /// No description provided for @unsupportedTypeDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{This operation is not supported for items of the following type: {types}.} other{This operation is not supported for items of the following types: {types}.}}'**
  String unsupportedTypeDialogMessage(int count, String types);

  /// No description provided for @nameConflictDialogSingleSourceMessage.
  ///
  /// In en, this message translates to:
  /// **'Some files in the destination folder have the same name.'**
  String get nameConflictDialogSingleSourceMessage;

  /// No description provided for @nameConflictDialogMultipleSourceMessage.
  ///
  /// In en, this message translates to:
  /// **'Some files have the same name.'**
  String get nameConflictDialogMultipleSourceMessage;

  /// No description provided for @addShortcutDialogLabel.
  ///
  /// In en, this message translates to:
  /// **'Shortcut label'**
  String get addShortcutDialogLabel;

  /// No description provided for @addShortcutButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'ADD'**
  String get addShortcutButtonLabel;

  /// No description provided for @noMatchingAppDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'There are no apps that can handle this.'**
  String get noMatchingAppDialogMessage;

  /// No description provided for @binEntriesConfirmationDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Move this item to the recycle bin?} other{Move these {count} items to the recycle bin?}}'**
  String binEntriesConfirmationDialogMessage(int count);

  /// No description provided for @deleteEntriesConfirmationDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Delete this item?} other{Delete these {count} items?}}'**
  String deleteEntriesConfirmationDialogMessage(int count);

  /// No description provided for @moveUndatedConfirmationDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Save item dates before proceeding?'**
  String get moveUndatedConfirmationDialogMessage;

  /// No description provided for @moveUndatedConfirmationDialogSetDate.
  ///
  /// In en, this message translates to:
  /// **'Save dates'**
  String get moveUndatedConfirmationDialogSetDate;

  /// No description provided for @videoResumeDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you want to resume playing at {time}?'**
  String videoResumeDialogMessage(String time);

  /// No description provided for @videoStartOverButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'START OVER'**
  String get videoStartOverButtonLabel;

  /// No description provided for @videoResumeButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'RESUME'**
  String get videoResumeButtonLabel;

  /// No description provided for @setCoverDialogLatest.
  ///
  /// In en, this message translates to:
  /// **'Latest item'**
  String get setCoverDialogLatest;

  /// No description provided for @setCoverDialogAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get setCoverDialogAuto;

  /// No description provided for @setCoverDialogCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get setCoverDialogCustom;

  /// No description provided for @hideFilterConfirmationDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Matching photos and videos will be hidden from your collection. You can show them again from the “Privacy” settings.\n\nAre you sure you want to hide them?'**
  String get hideFilterConfirmationDialogMessage;

  /// No description provided for @newAlbumDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'New Album'**
  String get newAlbumDialogTitle;

  /// No description provided for @newAlbumDialogNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Album name'**
  String get newAlbumDialogNameLabel;

  /// No description provided for @newAlbumDialogAlbumAlreadyExistsHelper.
  ///
  /// In en, this message translates to:
  /// **'Album already exists'**
  String get newAlbumDialogAlbumAlreadyExistsHelper;

  /// No description provided for @newAlbumDialogNameLabelAlreadyExistsHelper.
  ///
  /// In en, this message translates to:
  /// **'Directory already exists'**
  String get newAlbumDialogNameLabelAlreadyExistsHelper;

  /// No description provided for @newAlbumDialogStorageLabel.
  ///
  /// In en, this message translates to:
  /// **'Storage:'**
  String get newAlbumDialogStorageLabel;

  /// No description provided for @newDynamicAlbumDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'New Dynamic Album'**
  String get newDynamicAlbumDialogTitle;

  /// No description provided for @dynamicAlbumAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'Dynamic album already exists'**
  String get dynamicAlbumAlreadyExists;

  /// No description provided for @newGroupDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'New Group'**
  String get newGroupDialogTitle;

  /// No description provided for @newGroupDialogNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get newGroupDialogNameLabel;

  /// No description provided for @groupAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'Group already exists'**
  String get groupAlreadyExists;

  /// No description provided for @groupEmpty.
  ///
  /// In en, this message translates to:
  /// **'No groups'**
  String get groupEmpty;

  /// No description provided for @ungrouped.
  ///
  /// In en, this message translates to:
  /// **'Ungrouped'**
  String get ungrouped;

  /// No description provided for @groupPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick Group'**
  String get groupPickerTitle;

  /// No description provided for @groupPickerUseThisGroupButton.
  ///
  /// In en, this message translates to:
  /// **'Use this group'**
  String get groupPickerUseThisGroupButton;

  /// No description provided for @newVaultWarningDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Items in vaults are only available to this app and no others.\n\nIf you uninstall this app, or clear this app data, you will lose all these items.'**
  String get newVaultWarningDialogMessage;

  /// No description provided for @newVaultDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'New Vault'**
  String get newVaultDialogTitle;

  /// No description provided for @configureVaultDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Configure Vault'**
  String get configureVaultDialogTitle;

  /// No description provided for @vaultDialogLockModeWhenScreenOff.
  ///
  /// In en, this message translates to:
  /// **'Lock when screen turns off'**
  String get vaultDialogLockModeWhenScreenOff;

  /// No description provided for @vaultDialogLockTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Lock type'**
  String get vaultDialogLockTypeLabel;

  /// No description provided for @patternDialogEnter.
  ///
  /// In en, this message translates to:
  /// **'Enter pattern'**
  String get patternDialogEnter;

  /// No description provided for @patternDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm pattern'**
  String get patternDialogConfirm;

  /// No description provided for @pinDialogEnter.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN'**
  String get pinDialogEnter;

  /// No description provided for @pinDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get pinDialogConfirm;

  /// No description provided for @passwordDialogEnter.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get passwordDialogEnter;

  /// No description provided for @passwordDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get passwordDialogConfirm;

  /// No description provided for @authenticateToConfigureVault.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to configure vault'**
  String get authenticateToConfigureVault;

  /// No description provided for @authenticateToUnlockVault.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to unlock vault'**
  String get authenticateToUnlockVault;

  /// No description provided for @vaultBinUsageDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Some vaults are using the recycle bin.'**
  String get vaultBinUsageDialogMessage;

  /// No description provided for @renameAlbumDialogLabel.
  ///
  /// In en, this message translates to:
  /// **'New name'**
  String get renameAlbumDialogLabel;

  /// No description provided for @renameAlbumDialogLabelAlreadyExistsHelper.
  ///
  /// In en, this message translates to:
  /// **'Directory already exists'**
  String get renameAlbumDialogLabelAlreadyExistsHelper;

  /// No description provided for @renameEntrySetPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get renameEntrySetPageTitle;

  /// No description provided for @renameEntrySetPagePatternFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Naming pattern'**
  String get renameEntrySetPagePatternFieldLabel;

  /// No description provided for @renameEntrySetPageInsertTooltip.
  ///
  /// In en, this message translates to:
  /// **'Insert field'**
  String get renameEntrySetPageInsertTooltip;

  /// No description provided for @renameEntrySetPagePreviewSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get renameEntrySetPagePreviewSectionTitle;

  /// No description provided for @renameProcessorCounter.
  ///
  /// In en, this message translates to:
  /// **'Counter'**
  String get renameProcessorCounter;

  /// No description provided for @renameProcessorHash.
  ///
  /// In en, this message translates to:
  /// **'Hash'**
  String get renameProcessorHash;

  /// No description provided for @renameProcessorName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get renameProcessorName;

  /// No description provided for @deleteSingleAlbumConfirmationDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Delete this album and the item in it?} other{Delete this album and the {count} items in it?}}'**
  String deleteSingleAlbumConfirmationDialogMessage(int count);

  /// No description provided for @deleteMultiAlbumConfirmationDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Delete these albums and the item in them?} other{Delete these albums and the {count} items in them?}}'**
  String deleteMultiAlbumConfirmationDialogMessage(int count);

  /// No description provided for @exportEntryDialogFormat.
  ///
  /// In en, this message translates to:
  /// **'Format:'**
  String get exportEntryDialogFormat;

  /// No description provided for @exportEntryDialogWidth.
  ///
  /// In en, this message translates to:
  /// **'Width'**
  String get exportEntryDialogWidth;

  /// No description provided for @exportEntryDialogHeight.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get exportEntryDialogHeight;

  /// No description provided for @exportEntryDialogQuality.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get exportEntryDialogQuality;

  /// No description provided for @exportEntryDialogWriteMetadata.
  ///
  /// In en, this message translates to:
  /// **'Write metadata'**
  String get exportEntryDialogWriteMetadata;

  /// No description provided for @renameEntryDialogLabel.
  ///
  /// In en, this message translates to:
  /// **'New name'**
  String get renameEntryDialogLabel;

  /// No description provided for @editEntryDialogCopyFromItem.
  ///
  /// In en, this message translates to:
  /// **'Copy from other item'**
  String get editEntryDialogCopyFromItem;

  /// No description provided for @editEntryDialogTargetFieldsHeader.
  ///
  /// In en, this message translates to:
  /// **'Fields to modify'**
  String get editEntryDialogTargetFieldsHeader;

  /// No description provided for @editEntryDateDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get editEntryDateDialogTitle;

  /// No description provided for @editEntryDateDialogSetCustom.
  ///
  /// In en, this message translates to:
  /// **'Set custom date'**
  String get editEntryDateDialogSetCustom;

  /// No description provided for @editEntryDateDialogCopyField.
  ///
  /// In en, this message translates to:
  /// **'Copy from other date'**
  String get editEntryDateDialogCopyField;

  /// No description provided for @editEntryDateDialogExtractFromTitle.
  ///
  /// In en, this message translates to:
  /// **'Extract from title'**
  String get editEntryDateDialogExtractFromTitle;

  /// No description provided for @editEntryDateDialogShift.
  ///
  /// In en, this message translates to:
  /// **'Shift'**
  String get editEntryDateDialogShift;

  /// No description provided for @editEntryDateDialogSourceFileModifiedDate.
  ///
  /// In en, this message translates to:
  /// **'File modified date'**
  String get editEntryDateDialogSourceFileModifiedDate;

  /// No description provided for @durationDialogHours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get durationDialogHours;

  /// No description provided for @durationDialogMinutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get durationDialogMinutes;

  /// No description provided for @durationDialogSeconds.
  ///
  /// In en, this message translates to:
  /// **'Seconds'**
  String get durationDialogSeconds;

  /// No description provided for @editEntryLocationDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get editEntryLocationDialogTitle;

  /// No description provided for @editEntryLocationDialogSetCustom.
  ///
  /// In en, this message translates to:
  /// **'Set custom location'**
  String get editEntryLocationDialogSetCustom;

  /// No description provided for @editEntryLocationDialogChooseOnMap.
  ///
  /// In en, this message translates to:
  /// **'Choose on map'**
  String get editEntryLocationDialogChooseOnMap;

  /// No description provided for @editEntryLocationDialogImportGpx.
  ///
  /// In en, this message translates to:
  /// **'Import GPX'**
  String get editEntryLocationDialogImportGpx;

  /// No description provided for @editEntryLocationDialogLatitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get editEntryLocationDialogLatitude;

  /// No description provided for @editEntryLocationDialogLongitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get editEntryLocationDialogLongitude;

  /// No description provided for @editEntryLocationDialogTimeShift.
  ///
  /// In en, this message translates to:
  /// **'Time shift'**
  String get editEntryLocationDialogTimeShift;

  /// No description provided for @locationPickerUseThisLocationButton.
  ///
  /// In en, this message translates to:
  /// **'Use this location'**
  String get locationPickerUseThisLocationButton;

  /// No description provided for @editEntryRatingDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get editEntryRatingDialogTitle;

  /// No description provided for @removeEntryMetadataDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Metadata Removal'**
  String get removeEntryMetadataDialogTitle;

  /// No description provided for @removeEntryMetadataDialogAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get removeEntryMetadataDialogAll;

  /// No description provided for @removeEntryMetadataDialogMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get removeEntryMetadataDialogMore;

  /// No description provided for @removeEntryMetadataMotionPhotoXmpWarningDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'XMP is required to play the video inside a motion photo.\n\nAre you sure you want to remove it?'**
  String get removeEntryMetadataMotionPhotoXmpWarningDialogMessage;

  /// No description provided for @videoSpeedDialogLabel.
  ///
  /// In en, this message translates to:
  /// **'Playback speed'**
  String get videoSpeedDialogLabel;

  /// No description provided for @videoStreamSelectionDialogVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get videoStreamSelectionDialogVideo;

  /// No description provided for @videoStreamSelectionDialogAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get videoStreamSelectionDialogAudio;

  /// No description provided for @videoStreamSelectionDialogText.
  ///
  /// In en, this message translates to:
  /// **'Subtitles'**
  String get videoStreamSelectionDialogText;

  /// No description provided for @videoStreamSelectionDialogOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get videoStreamSelectionDialogOff;

  /// No description provided for @videoStreamSelectionDialogTrack.
  ///
  /// In en, this message translates to:
  /// **'Track'**
  String get videoStreamSelectionDialogTrack;

  /// No description provided for @videoStreamSelectionDialogNoSelection.
  ///
  /// In en, this message translates to:
  /// **'There are no other tracks.'**
  String get videoStreamSelectionDialogNoSelection;

  /// No description provided for @genericSuccessFeedback.
  ///
  /// In en, this message translates to:
  /// **'Done!'**
  String get genericSuccessFeedback;

  /// No description provided for @genericFailureFeedback.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get genericFailureFeedback;

  /// No description provided for @genericDangerWarningDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get genericDangerWarningDialogMessage;

  /// No description provided for @tooManyItemsErrorDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Try again with fewer items.'**
  String get tooManyItemsErrorDialogMessage;

  /// No description provided for @menuActionConfigureView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get menuActionConfigureView;

  /// No description provided for @menuActionSelect.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get menuActionSelect;

  /// No description provided for @menuActionSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get menuActionSelectAll;

  /// No description provided for @menuActionSelectNone.
  ///
  /// In en, this message translates to:
  /// **'Select none'**
  String get menuActionSelectNone;

  /// No description provided for @menuActionMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get menuActionMap;

  /// No description provided for @menuActionSlideshow.
  ///
  /// In en, this message translates to:
  /// **'Slideshow'**
  String get menuActionSlideshow;

  /// No description provided for @menuActionStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get menuActionStats;

  /// No description provided for @viewDialogSortSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get viewDialogSortSectionTitle;

  /// No description provided for @viewDialogGroupSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Sections'**
  String get viewDialogGroupSectionTitle;

  /// No description provided for @viewDialogLayoutSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Layout'**
  String get viewDialogLayoutSectionTitle;

  /// No description provided for @viewDialogReverseSortOrder.
  ///
  /// In en, this message translates to:
  /// **'Reverse sort order'**
  String get viewDialogReverseSortOrder;

  /// No description provided for @tileLayoutMosaic.
  ///
  /// In en, this message translates to:
  /// **'Mosaic'**
  String get tileLayoutMosaic;

  /// No description provided for @tileLayoutGrid.
  ///
  /// In en, this message translates to:
  /// **'Grid'**
  String get tileLayoutGrid;

  /// No description provided for @tileLayoutList.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get tileLayoutList;

  /// No description provided for @castDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Cast Devices'**
  String get castDialogTitle;

  /// No description provided for @coverDialogTabCover.
  ///
  /// In en, this message translates to:
  /// **'Cover'**
  String get coverDialogTabCover;

  /// No description provided for @coverDialogTabApp.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get coverDialogTabApp;

  /// No description provided for @coverDialogTabColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get coverDialogTabColor;

  /// No description provided for @appPickDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick App'**
  String get appPickDialogTitle;

  /// No description provided for @appPickDialogNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get appPickDialogNone;

  /// No description provided for @aboutPageTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutPageTitle;

  /// No description provided for @aboutLinkLicense.
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get aboutLinkLicense;

  /// No description provided for @aboutLinkPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get aboutLinkPolicy;

  /// No description provided for @aboutBugSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Bug Report'**
  String get aboutBugSectionTitle;

  /// No description provided for @aboutBugSaveLogInstruction.
  ///
  /// In en, this message translates to:
  /// **'Save app logs to a file'**
  String get aboutBugSaveLogInstruction;

  /// No description provided for @aboutBugCopyInfoInstruction.
  ///
  /// In en, this message translates to:
  /// **'Copy system information'**
  String get aboutBugCopyInfoInstruction;

  /// No description provided for @aboutBugCopyInfoButton.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get aboutBugCopyInfoButton;

  /// No description provided for @aboutBugReportInstruction.
  ///
  /// In en, this message translates to:
  /// **'Report on GitHub with the logs and system information'**
  String get aboutBugReportInstruction;

  /// No description provided for @aboutBugReportButton.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get aboutBugReportButton;

  /// No description provided for @aboutDataUsageSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Data Usage'**
  String get aboutDataUsageSectionTitle;

  /// No description provided for @aboutDataUsageData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get aboutDataUsageData;

  /// No description provided for @aboutDataUsageCache.
  ///
  /// In en, this message translates to:
  /// **'Cache'**
  String get aboutDataUsageCache;

  /// No description provided for @aboutDataUsageDatabase.
  ///
  /// In en, this message translates to:
  /// **'Database'**
  String get aboutDataUsageDatabase;

  /// No description provided for @aboutDataUsageMisc.
  ///
  /// In en, this message translates to:
  /// **'Misc'**
  String get aboutDataUsageMisc;

  /// No description provided for @aboutDataUsageInternal.
  ///
  /// In en, this message translates to:
  /// **'Internal'**
  String get aboutDataUsageInternal;

  /// No description provided for @aboutDataUsageExternal.
  ///
  /// In en, this message translates to:
  /// **'External'**
  String get aboutDataUsageExternal;

  /// No description provided for @aboutDataUsageClearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get aboutDataUsageClearCache;

  /// No description provided for @aboutCreditsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get aboutCreditsSectionTitle;

  /// No description provided for @aboutCreditsWorldAtlas1.
  ///
  /// In en, this message translates to:
  /// **'This app uses a TopoJSON file from'**
  String get aboutCreditsWorldAtlas1;

  /// No description provided for @aboutCreditsWorldAtlas2.
  ///
  /// In en, this message translates to:
  /// **'under ISC License.'**
  String get aboutCreditsWorldAtlas2;

  /// No description provided for @aboutTranslatorsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Translators'**
  String get aboutTranslatorsSectionTitle;

  /// No description provided for @aboutLicensesSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Open-Source Licenses'**
  String get aboutLicensesSectionTitle;

  /// No description provided for @aboutLicensesBanner.
  ///
  /// In en, this message translates to:
  /// **'This app uses the following open-source packages and libraries.'**
  String get aboutLicensesBanner;

  /// No description provided for @aboutLicensesAndroidLibrariesSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Android Libraries'**
  String get aboutLicensesAndroidLibrariesSectionTitle;

  /// No description provided for @aboutLicensesFlutterPluginsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Flutter Plugins'**
  String get aboutLicensesFlutterPluginsSectionTitle;

  /// No description provided for @aboutLicensesFlutterPackagesSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Flutter Packages'**
  String get aboutLicensesFlutterPackagesSectionTitle;

  /// No description provided for @aboutLicensesDartPackagesSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Dart Packages'**
  String get aboutLicensesDartPackagesSectionTitle;

  /// No description provided for @aboutLicensesShowAllButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Show All Licenses'**
  String get aboutLicensesShowAllButtonLabel;

  /// No description provided for @policyPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get policyPageTitle;

  /// No description provided for @collectionPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Collection'**
  String get collectionPageTitle;

  /// No description provided for @collectionPickPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick'**
  String get collectionPickPageTitle;

  /// No description provided for @collectionSelectPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Select items'**
  String get collectionSelectPageTitle;

  /// No description provided for @collectionActionShowTitleSearch.
  ///
  /// In en, this message translates to:
  /// **'Show title filter'**
  String get collectionActionShowTitleSearch;

  /// No description provided for @collectionActionHideTitleSearch.
  ///
  /// In en, this message translates to:
  /// **'Hide title filter'**
  String get collectionActionHideTitleSearch;

  /// No description provided for @collectionActionAddDynamicAlbum.
  ///
  /// In en, this message translates to:
  /// **'Add dynamic album'**
  String get collectionActionAddDynamicAlbum;

  /// No description provided for @collectionActionAddShortcut.
  ///
  /// In en, this message translates to:
  /// **'Add shortcut'**
  String get collectionActionAddShortcut;

  /// No description provided for @collectionActionSetHome.
  ///
  /// In en, this message translates to:
  /// **'Set as home'**
  String get collectionActionSetHome;

  /// No description provided for @collectionActionEmptyBin.
  ///
  /// In en, this message translates to:
  /// **'Empty bin'**
  String get collectionActionEmptyBin;

  /// No description provided for @collectionActionCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy to album'**
  String get collectionActionCopy;

  /// No description provided for @collectionActionMove.
  ///
  /// In en, this message translates to:
  /// **'Move to album'**
  String get collectionActionMove;

  /// No description provided for @collectionActionRescan.
  ///
  /// In en, this message translates to:
  /// **'Rescan'**
  String get collectionActionRescan;

  /// No description provided for @collectionActionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get collectionActionEdit;

  /// No description provided for @collectionSearchTitlesHintText.
  ///
  /// In en, this message translates to:
  /// **'Search titles'**
  String get collectionSearchTitlesHintText;

  /// No description provided for @collectionGroupAlbum.
  ///
  /// In en, this message translates to:
  /// **'By album'**
  String get collectionGroupAlbum;

  /// No description provided for @collectionGroupMonth.
  ///
  /// In en, this message translates to:
  /// **'By month'**
  String get collectionGroupMonth;

  /// No description provided for @collectionGroupDay.
  ///
  /// In en, this message translates to:
  /// **'By day'**
  String get collectionGroupDay;

  /// No description provided for @sectionNone.
  ///
  /// In en, this message translates to:
  /// **'No sections'**
  String get sectionNone;

  /// No description provided for @sectionUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get sectionUnknown;

  /// No description provided for @dateToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dateToday;

  /// No description provided for @dateYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get dateYesterday;

  /// No description provided for @dateThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get dateThisMonth;

  /// No description provided for @collectionDeleteFailureFeedback.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Failed to delete 1 item} other{Failed to delete {count} items}}'**
  String collectionDeleteFailureFeedback(int count);

  /// No description provided for @collectionCopyFailureFeedback.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Failed to copy 1 item} other{Failed to copy {count} items}}'**
  String collectionCopyFailureFeedback(int count);

  /// No description provided for @collectionMoveFailureFeedback.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Failed to move 1 item} other{Failed to move {count} items}}'**
  String collectionMoveFailureFeedback(int count);

  /// No description provided for @collectionRenameFailureFeedback.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Failed to rename 1 item} other{Failed to rename {count} items}}'**
  String collectionRenameFailureFeedback(int count);

  /// No description provided for @collectionEditFailureFeedback.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Failed to edit 1 item} other{Failed to edit {count} items}}'**
  String collectionEditFailureFeedback(int count);

  /// No description provided for @collectionExportFailureFeedback.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Failed to export 1 page} other{Failed to export {count} pages}}'**
  String collectionExportFailureFeedback(int count);

  /// No description provided for @collectionCopySuccessFeedback.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Copied 1 item} other{Copied {count} items}}'**
  String collectionCopySuccessFeedback(int count);

  /// No description provided for @collectionMoveSuccessFeedback.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Moved 1 item} other{Moved {count} items}}'**
  String collectionMoveSuccessFeedback(int count);

  /// No description provided for @collectionRenameSuccessFeedback.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Renamed 1 item} other{Renamed {count} items}}'**
  String collectionRenameSuccessFeedback(int count);

  /// No description provided for @collectionEditSuccessFeedback.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Edited 1 item} other{Edited {count} items}}'**
  String collectionEditSuccessFeedback(int count);

  /// No description provided for @collectionEmptyFavourites.
  ///
  /// In en, this message translates to:
  /// **'No favorites'**
  String get collectionEmptyFavourites;

  /// No description provided for @collectionEmptyVideos.
  ///
  /// In en, this message translates to:
  /// **'No videos'**
  String get collectionEmptyVideos;

  /// No description provided for @collectionEmptyImages.
  ///
  /// In en, this message translates to:
  /// **'No images'**
  String get collectionEmptyImages;

  /// No description provided for @collectionEmptyGrantAccessButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Grant access'**
  String get collectionEmptyGrantAccessButtonLabel;

  /// No description provided for @collectionSelectSectionTooltip.
  ///
  /// In en, this message translates to:
  /// **'Select section'**
  String get collectionSelectSectionTooltip;

  /// No description provided for @collectionDeselectSectionTooltip.
  ///
  /// In en, this message translates to:
  /// **'Deselect section'**
  String get collectionDeselectSectionTooltip;

  /// No description provided for @drawerAboutButton.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get drawerAboutButton;

  /// No description provided for @drawerSettingsButton.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get drawerSettingsButton;

  /// No description provided for @drawerCollectionAll.
  ///
  /// In en, this message translates to:
  /// **'All collection'**
  String get drawerCollectionAll;

  /// No description provided for @drawerCollectionFavourites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get drawerCollectionFavourites;

  /// No description provided for @drawerCollectionImages.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get drawerCollectionImages;

  /// No description provided for @drawerCollectionVideos.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get drawerCollectionVideos;

  /// No description provided for @drawerCollectionAnimated.
  ///
  /// In en, this message translates to:
  /// **'Animated'**
  String get drawerCollectionAnimated;

  /// No description provided for @drawerCollectionMotionPhotos.
  ///
  /// In en, this message translates to:
  /// **'Motion photos'**
  String get drawerCollectionMotionPhotos;

  /// No description provided for @drawerCollectionPanoramas.
  ///
  /// In en, this message translates to:
  /// **'Panoramas'**
  String get drawerCollectionPanoramas;

  /// No description provided for @drawerCollectionRaws.
  ///
  /// In en, this message translates to:
  /// **'Raw photos'**
  String get drawerCollectionRaws;

  /// No description provided for @drawerCollectionSphericalVideos.
  ///
  /// In en, this message translates to:
  /// **'360° Videos'**
  String get drawerCollectionSphericalVideos;

  /// No description provided for @drawerAlbumPage.
  ///
  /// In en, this message translates to:
  /// **'Albums'**
  String get drawerAlbumPage;

  /// No description provided for @drawerCountryPage.
  ///
  /// In en, this message translates to:
  /// **'Countries'**
  String get drawerCountryPage;

  /// No description provided for @drawerPlacePage.
  ///
  /// In en, this message translates to:
  /// **'Places'**
  String get drawerPlacePage;

  /// No description provided for @drawerTagPage.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get drawerTagPage;

  /// No description provided for @sortByDate.
  ///
  /// In en, this message translates to:
  /// **'By date'**
  String get sortByDate;

  /// No description provided for @sortByName.
  ///
  /// In en, this message translates to:
  /// **'By name'**
  String get sortByName;

  /// No description provided for @sortByItemCount.
  ///
  /// In en, this message translates to:
  /// **'By item count'**
  String get sortByItemCount;

  /// No description provided for @sortBySize.
  ///
  /// In en, this message translates to:
  /// **'By size'**
  String get sortBySize;

  /// No description provided for @sortByAlbumFileName.
  ///
  /// In en, this message translates to:
  /// **'By album & file name'**
  String get sortByAlbumFileName;

  /// No description provided for @sortByRating.
  ///
  /// In en, this message translates to:
  /// **'By rating'**
  String get sortByRating;

  /// No description provided for @sortByDuration.
  ///
  /// In en, this message translates to:
  /// **'By duration'**
  String get sortByDuration;

  /// No description provided for @sortByPath.
  ///
  /// In en, this message translates to:
  /// **'By path'**
  String get sortByPath;

  /// No description provided for @sortOrderNewestFirst.
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get sortOrderNewestFirst;

  /// No description provided for @sortOrderOldestFirst.
  ///
  /// In en, this message translates to:
  /// **'Oldest first'**
  String get sortOrderOldestFirst;

  /// No description provided for @sortOrderAtoZ.
  ///
  /// In en, this message translates to:
  /// **'A to Z'**
  String get sortOrderAtoZ;

  /// No description provided for @sortOrderZtoA.
  ///
  /// In en, this message translates to:
  /// **'Z to A'**
  String get sortOrderZtoA;

  /// No description provided for @sortOrderHighestFirst.
  ///
  /// In en, this message translates to:
  /// **'Highest first'**
  String get sortOrderHighestFirst;

  /// No description provided for @sortOrderLowestFirst.
  ///
  /// In en, this message translates to:
  /// **'Lowest first'**
  String get sortOrderLowestFirst;

  /// No description provided for @sortOrderLargestFirst.
  ///
  /// In en, this message translates to:
  /// **'Largest first'**
  String get sortOrderLargestFirst;

  /// No description provided for @sortOrderSmallestFirst.
  ///
  /// In en, this message translates to:
  /// **'Smallest first'**
  String get sortOrderSmallestFirst;

  /// No description provided for @sortOrderShortestFirst.
  ///
  /// In en, this message translates to:
  /// **'Shortest first'**
  String get sortOrderShortestFirst;

  /// No description provided for @sortOrderLongestFirst.
  ///
  /// In en, this message translates to:
  /// **'Longest first'**
  String get sortOrderLongestFirst;

  /// No description provided for @albumGroupTier.
  ///
  /// In en, this message translates to:
  /// **'By tier'**
  String get albumGroupTier;

  /// No description provided for @albumGroupType.
  ///
  /// In en, this message translates to:
  /// **'By type'**
  String get albumGroupType;

  /// No description provided for @albumGroupVolume.
  ///
  /// In en, this message translates to:
  /// **'By storage volume'**
  String get albumGroupVolume;

  /// No description provided for @albumMimeTypeMixed.
  ///
  /// In en, this message translates to:
  /// **'Mixed'**
  String get albumMimeTypeMixed;

  /// No description provided for @albumPickPageTitleCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy to Album'**
  String get albumPickPageTitleCopy;

  /// No description provided for @albumPickPageTitleExport.
  ///
  /// In en, this message translates to:
  /// **'Export to Album'**
  String get albumPickPageTitleExport;

  /// No description provided for @albumPickPageTitleMove.
  ///
  /// In en, this message translates to:
  /// **'Move to Album'**
  String get albumPickPageTitleMove;

  /// No description provided for @albumPickPageTitlePick.
  ///
  /// In en, this message translates to:
  /// **'Pick Album'**
  String get albumPickPageTitlePick;

  /// No description provided for @albumCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get albumCamera;

  /// No description provided for @albumDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get albumDownload;

  /// No description provided for @albumScreenshots.
  ///
  /// In en, this message translates to:
  /// **'Screenshots'**
  String get albumScreenshots;

  /// No description provided for @albumScreenRecordings.
  ///
  /// In en, this message translates to:
  /// **'Screen recordings'**
  String get albumScreenRecordings;

  /// No description provided for @albumVideoCaptures.
  ///
  /// In en, this message translates to:
  /// **'Video Captures'**
  String get albumVideoCaptures;

  /// No description provided for @albumPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Albums'**
  String get albumPageTitle;

  /// No description provided for @albumEmpty.
  ///
  /// In en, this message translates to:
  /// **'No albums'**
  String get albumEmpty;

  /// No description provided for @createAlbumButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'CREATE'**
  String get createAlbumButtonLabel;

  /// No description provided for @newFilterBanner.
  ///
  /// In en, this message translates to:
  /// **'new'**
  String get newFilterBanner;

  /// No description provided for @countryPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Countries'**
  String get countryPageTitle;

  /// No description provided for @countryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No countries'**
  String get countryEmpty;

  /// No description provided for @statePageTitle.
  ///
  /// In en, this message translates to:
  /// **'States'**
  String get statePageTitle;

  /// No description provided for @stateEmpty.
  ///
  /// In en, this message translates to:
  /// **'No states'**
  String get stateEmpty;

  /// No description provided for @placePageTitle.
  ///
  /// In en, this message translates to:
  /// **'Places'**
  String get placePageTitle;

  /// No description provided for @placeEmpty.
  ///
  /// In en, this message translates to:
  /// **'No places'**
  String get placeEmpty;

  /// No description provided for @tagPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tagPageTitle;

  /// No description provided for @tagEmpty.
  ///
  /// In en, this message translates to:
  /// **'No tags'**
  String get tagEmpty;

  /// No description provided for @binPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Recycle Bin'**
  String get binPageTitle;

  /// No description provided for @explorerPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Explorer'**
  String get explorerPageTitle;

  /// No description provided for @explorerActionSelectStorageVolume.
  ///
  /// In en, this message translates to:
  /// **'Select storage'**
  String get explorerActionSelectStorageVolume;

  /// No description provided for @selectStorageVolumeDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Storage'**
  String get selectStorageVolumeDialogTitle;

  /// No description provided for @searchCollectionFieldHint.
  ///
  /// In en, this message translates to:
  /// **'Search collection'**
  String get searchCollectionFieldHint;

  /// No description provided for @searchRecentSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get searchRecentSectionTitle;

  /// No description provided for @searchDateSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get searchDateSectionTitle;

  /// No description provided for @searchFormatSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Formats'**
  String get searchFormatSectionTitle;

  /// No description provided for @searchAlbumsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Albums'**
  String get searchAlbumsSectionTitle;

  /// No description provided for @searchCountriesSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Countries'**
  String get searchCountriesSectionTitle;

  /// No description provided for @searchStatesSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'States'**
  String get searchStatesSectionTitle;

  /// No description provided for @searchPlacesSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Places'**
  String get searchPlacesSectionTitle;

  /// No description provided for @searchTagsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get searchTagsSectionTitle;

  /// No description provided for @searchRatingSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Ratings'**
  String get searchRatingSectionTitle;

  /// No description provided for @searchMetadataSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Metadata'**
  String get searchMetadataSectionTitle;

  /// No description provided for @settingsPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsPageTitle;

  /// No description provided for @settingsSystemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsSystemDefault;

  /// No description provided for @settingsDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get settingsDefault;

  /// No description provided for @settingsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get settingsDisabled;

  /// No description provided for @settingsAskEverytime.
  ///
  /// In en, this message translates to:
  /// **'Ask everytime'**
  String get settingsAskEverytime;

  /// No description provided for @settingsModificationWarningDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Other settings will be modified.'**
  String get settingsModificationWarningDialogMessage;

  /// No description provided for @settingsSearchFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Search settings'**
  String get settingsSearchFieldLabel;

  /// No description provided for @settingsSearchEmpty.
  ///
  /// In en, this message translates to:
  /// **'No matching setting'**
  String get settingsSearchEmpty;

  /// No description provided for @settingsActionExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get settingsActionExport;

  /// No description provided for @settingsActionExportDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get settingsActionExportDialogTitle;

  /// No description provided for @settingsActionImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get settingsActionImport;

  /// No description provided for @settingsActionImportDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get settingsActionImportDialogTitle;

  /// No description provided for @appExportCovers.
  ///
  /// In en, this message translates to:
  /// **'Covers'**
  String get appExportCovers;

  /// No description provided for @appExportDynamicAlbums.
  ///
  /// In en, this message translates to:
  /// **'Dynamic albums'**
  String get appExportDynamicAlbums;

  /// No description provided for @appExportFavourites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get appExportFavourites;

  /// No description provided for @appExportSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get appExportSettings;

  /// No description provided for @settingsNavigationSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Navigation'**
  String get settingsNavigationSectionTitle;

  /// No description provided for @settingsHomeTile.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get settingsHomeTile;

  /// No description provided for @settingsHomeDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get settingsHomeDialogTitle;

  /// No description provided for @setHomeCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get setHomeCustom;

  /// No description provided for @settingsShowBottomNavigationBar.
  ///
  /// In en, this message translates to:
  /// **'Show bottom navigation bar'**
  String get settingsShowBottomNavigationBar;

  /// No description provided for @settingsKeepScreenOnTile.
  ///
  /// In en, this message translates to:
  /// **'Keep screen on'**
  String get settingsKeepScreenOnTile;

  /// No description provided for @settingsKeepScreenOnDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep Screen On'**
  String get settingsKeepScreenOnDialogTitle;

  /// No description provided for @settingsDoubleBackExit.
  ///
  /// In en, this message translates to:
  /// **'Tap “back” twice to exit'**
  String get settingsDoubleBackExit;

  /// No description provided for @settingsConfirmationTile.
  ///
  /// In en, this message translates to:
  /// **'Confirmation dialogs'**
  String get settingsConfirmationTile;

  /// No description provided for @settingsConfirmationDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirmation Dialogs'**
  String get settingsConfirmationDialogTitle;

  /// No description provided for @settingsConfirmationBeforeDeleteItems.
  ///
  /// In en, this message translates to:
  /// **'Ask before deleting items forever'**
  String get settingsConfirmationBeforeDeleteItems;

  /// No description provided for @settingsConfirmationBeforeMoveToBinItems.
  ///
  /// In en, this message translates to:
  /// **'Ask before moving items to the recycle bin'**
  String get settingsConfirmationBeforeMoveToBinItems;

  /// No description provided for @settingsConfirmationBeforeMoveUndatedItems.
  ///
  /// In en, this message translates to:
  /// **'Ask before moving undated items'**
  String get settingsConfirmationBeforeMoveUndatedItems;

  /// No description provided for @settingsConfirmationAfterMoveToBinItems.
  ///
  /// In en, this message translates to:
  /// **'Show message after moving items to the recycle bin'**
  String get settingsConfirmationAfterMoveToBinItems;

  /// No description provided for @settingsConfirmationVaultDataLoss.
  ///
  /// In en, this message translates to:
  /// **'Show vault data loss warning'**
  String get settingsConfirmationVaultDataLoss;

  /// No description provided for @settingsNavigationDrawerTile.
  ///
  /// In en, this message translates to:
  /// **'Navigation menu'**
  String get settingsNavigationDrawerTile;

  /// No description provided for @settingsNavigationDrawerEditorPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Navigation Menu'**
  String get settingsNavigationDrawerEditorPageTitle;

  /// No description provided for @settingsNavigationDrawerBanner.
  ///
  /// In en, this message translates to:
  /// **'Touch and hold to move and reorder menu items.'**
  String get settingsNavigationDrawerBanner;

  /// No description provided for @settingsNavigationDrawerTabTypes.
  ///
  /// In en, this message translates to:
  /// **'Types'**
  String get settingsNavigationDrawerTabTypes;

  /// No description provided for @settingsNavigationDrawerTabAlbums.
  ///
  /// In en, this message translates to:
  /// **'Albums'**
  String get settingsNavigationDrawerTabAlbums;

  /// No description provided for @settingsNavigationDrawerTabPages.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get settingsNavigationDrawerTabPages;

  /// No description provided for @settingsNavigationDrawerAddAlbum.
  ///
  /// In en, this message translates to:
  /// **'Add album'**
  String get settingsNavigationDrawerAddAlbum;

  /// No description provided for @settingsThumbnailSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Thumbnails'**
  String get settingsThumbnailSectionTitle;

  /// No description provided for @settingsThumbnailOverlayTile.
  ///
  /// In en, this message translates to:
  /// **'Overlay'**
  String get settingsThumbnailOverlayTile;

  /// No description provided for @settingsThumbnailOverlayPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Overlay'**
  String get settingsThumbnailOverlayPageTitle;

  /// No description provided for @settingsThumbnailShowHdrIcon.
  ///
  /// In en, this message translates to:
  /// **'Show HDR icon'**
  String get settingsThumbnailShowHdrIcon;

  /// No description provided for @settingsThumbnailShowFavouriteIcon.
  ///
  /// In en, this message translates to:
  /// **'Show favorite icon'**
  String get settingsThumbnailShowFavouriteIcon;

  /// No description provided for @settingsThumbnailShowTagIcon.
  ///
  /// In en, this message translates to:
  /// **'Show tag icon'**
  String get settingsThumbnailShowTagIcon;

  /// No description provided for @settingsThumbnailShowLocationIcon.
  ///
  /// In en, this message translates to:
  /// **'Show location icon'**
  String get settingsThumbnailShowLocationIcon;

  /// No description provided for @settingsThumbnailShowMotionPhotoIcon.
  ///
  /// In en, this message translates to:
  /// **'Show motion photo icon'**
  String get settingsThumbnailShowMotionPhotoIcon;

  /// No description provided for @settingsThumbnailShowRating.
  ///
  /// In en, this message translates to:
  /// **'Show rating'**
  String get settingsThumbnailShowRating;

  /// No description provided for @settingsThumbnailShowRawIcon.
  ///
  /// In en, this message translates to:
  /// **'Show raw icon'**
  String get settingsThumbnailShowRawIcon;

  /// No description provided for @settingsThumbnailShowVideoDuration.
  ///
  /// In en, this message translates to:
  /// **'Show video duration'**
  String get settingsThumbnailShowVideoDuration;

  /// No description provided for @settingsCollectionQuickActionsTile.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get settingsCollectionQuickActionsTile;

  /// No description provided for @settingsCollectionQuickActionEditorPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get settingsCollectionQuickActionEditorPageTitle;

  /// No description provided for @settingsCollectionQuickActionTabBrowsing.
  ///
  /// In en, this message translates to:
  /// **'Browsing'**
  String get settingsCollectionQuickActionTabBrowsing;

  /// No description provided for @settingsCollectionQuickActionTabSelecting.
  ///
  /// In en, this message translates to:
  /// **'Selecting'**
  String get settingsCollectionQuickActionTabSelecting;

  /// No description provided for @settingsCollectionBrowsingQuickActionEditorBanner.
  ///
  /// In en, this message translates to:
  /// **'Touch and hold to move buttons and select which actions are displayed when browsing items.'**
  String get settingsCollectionBrowsingQuickActionEditorBanner;

  /// No description provided for @settingsCollectionSelectionQuickActionEditorBanner.
  ///
  /// In en, this message translates to:
  /// **'Touch and hold to move buttons and select which actions are displayed when selecting items.'**
  String get settingsCollectionSelectionQuickActionEditorBanner;

  /// No description provided for @settingsCollectionBurstPatternsTile.
  ///
  /// In en, this message translates to:
  /// **'Burst patterns'**
  String get settingsCollectionBurstPatternsTile;

  /// No description provided for @settingsCollectionBurstPatternsNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get settingsCollectionBurstPatternsNone;

  /// No description provided for @settingsViewerSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Viewer'**
  String get settingsViewerSectionTitle;

  /// No description provided for @settingsViewerGestureSideTapNext.
  ///
  /// In en, this message translates to:
  /// **'Tap on screen edges to show previous/next item'**
  String get settingsViewerGestureSideTapNext;

  /// No description provided for @settingsViewerUseCutout.
  ///
  /// In en, this message translates to:
  /// **'Use cutout area'**
  String get settingsViewerUseCutout;

  /// No description provided for @settingsViewerMaximumBrightness.
  ///
  /// In en, this message translates to:
  /// **'Maximum brightness'**
  String get settingsViewerMaximumBrightness;

  /// No description provided for @settingsMotionPhotoAutoPlay.
  ///
  /// In en, this message translates to:
  /// **'Auto play motion photos'**
  String get settingsMotionPhotoAutoPlay;

  /// No description provided for @settingsImageBackground.
  ///
  /// In en, this message translates to:
  /// **'Image background'**
  String get settingsImageBackground;

  /// No description provided for @settingsViewerQuickActionsTile.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get settingsViewerQuickActionsTile;

  /// No description provided for @settingsViewerQuickActionEditorPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get settingsViewerQuickActionEditorPageTitle;

  /// No description provided for @settingsViewerQuickActionEditorBanner.
  ///
  /// In en, this message translates to:
  /// **'Touch and hold to move buttons and select which actions are displayed in the viewer.'**
  String get settingsViewerQuickActionEditorBanner;

  /// No description provided for @settingsViewerQuickActionEditorDisplayedButtonsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Displayed Buttons'**
  String get settingsViewerQuickActionEditorDisplayedButtonsSectionTitle;

  /// No description provided for @settingsViewerQuickActionEditorAvailableButtonsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Available Buttons'**
  String get settingsViewerQuickActionEditorAvailableButtonsSectionTitle;

  /// No description provided for @settingsViewerQuickActionEmpty.
  ///
  /// In en, this message translates to:
  /// **'No buttons'**
  String get settingsViewerQuickActionEmpty;

  /// No description provided for @settingsViewerOverlayTile.
  ///
  /// In en, this message translates to:
  /// **'Overlay'**
  String get settingsViewerOverlayTile;

  /// No description provided for @settingsViewerOverlayPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Overlay'**
  String get settingsViewerOverlayPageTitle;

  /// No description provided for @settingsViewerShowOverlayOnOpening.
  ///
  /// In en, this message translates to:
  /// **'Show on opening'**
  String get settingsViewerShowOverlayOnOpening;

  /// No description provided for @settingsViewerShowHistogram.
  ///
  /// In en, this message translates to:
  /// **'Show histogram'**
  String get settingsViewerShowHistogram;

  /// No description provided for @settingsViewerShowMinimap.
  ///
  /// In en, this message translates to:
  /// **'Show minimap'**
  String get settingsViewerShowMinimap;

  /// No description provided for @settingsViewerShowInformation.
  ///
  /// In en, this message translates to:
  /// **'Show information'**
  String get settingsViewerShowInformation;

  /// No description provided for @settingsViewerShowInformationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show title, date, location, etc.'**
  String get settingsViewerShowInformationSubtitle;

  /// No description provided for @settingsViewerShowRatingTags.
  ///
  /// In en, this message translates to:
  /// **'Show rating & tags'**
  String get settingsViewerShowRatingTags;

  /// No description provided for @settingsViewerShowShootingDetails.
  ///
  /// In en, this message translates to:
  /// **'Show shooting details'**
  String get settingsViewerShowShootingDetails;

  /// No description provided for @settingsViewerShowDescription.
  ///
  /// In en, this message translates to:
  /// **'Show description'**
  String get settingsViewerShowDescription;

  /// No description provided for @settingsViewerShowOverlayThumbnails.
  ///
  /// In en, this message translates to:
  /// **'Show thumbnails'**
  String get settingsViewerShowOverlayThumbnails;

  /// No description provided for @settingsViewerEnableOverlayBlurEffect.
  ///
  /// In en, this message translates to:
  /// **'Blur effect'**
  String get settingsViewerEnableOverlayBlurEffect;

  /// No description provided for @settingsViewerSlideshowTile.
  ///
  /// In en, this message translates to:
  /// **'Slideshow'**
  String get settingsViewerSlideshowTile;

  /// No description provided for @settingsViewerSlideshowPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Slideshow'**
  String get settingsViewerSlideshowPageTitle;

  /// No description provided for @settingsSlideshowRepeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get settingsSlideshowRepeat;

  /// No description provided for @settingsSlideshowShuffle.
  ///
  /// In en, this message translates to:
  /// **'Shuffle'**
  String get settingsSlideshowShuffle;

  /// No description provided for @settingsSlideshowFillScreen.
  ///
  /// In en, this message translates to:
  /// **'Fill screen'**
  String get settingsSlideshowFillScreen;

  /// No description provided for @settingsSlideshowAnimatedZoomEffect.
  ///
  /// In en, this message translates to:
  /// **'Animated zoom effect'**
  String get settingsSlideshowAnimatedZoomEffect;

  /// No description provided for @settingsSlideshowTransitionTile.
  ///
  /// In en, this message translates to:
  /// **'Transition'**
  String get settingsSlideshowTransitionTile;

  /// No description provided for @settingsSlideshowIntervalTile.
  ///
  /// In en, this message translates to:
  /// **'Interval'**
  String get settingsSlideshowIntervalTile;

  /// No description provided for @settingsSlideshowVideoPlaybackTile.
  ///
  /// In en, this message translates to:
  /// **'Video playback'**
  String get settingsSlideshowVideoPlaybackTile;

  /// No description provided for @settingsSlideshowVideoPlaybackDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Video Playback'**
  String get settingsSlideshowVideoPlaybackDialogTitle;

  /// No description provided for @settingsVideoPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Video Settings'**
  String get settingsVideoPageTitle;

  /// No description provided for @settingsVideoSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get settingsVideoSectionTitle;

  /// No description provided for @settingsVideoShowVideos.
  ///
  /// In en, this message translates to:
  /// **'Show videos'**
  String get settingsVideoShowVideos;

  /// No description provided for @settingsVideoPlaybackTile.
  ///
  /// In en, this message translates to:
  /// **'Playback'**
  String get settingsVideoPlaybackTile;

  /// No description provided for @settingsVideoPlaybackPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Playback'**
  String get settingsVideoPlaybackPageTitle;

  /// No description provided for @settingsVideoEnableHardwareAcceleration.
  ///
  /// In en, this message translates to:
  /// **'Hardware acceleration'**
  String get settingsVideoEnableHardwareAcceleration;

  /// No description provided for @settingsVideoAutoPlay.
  ///
  /// In en, this message translates to:
  /// **'Auto play'**
  String get settingsVideoAutoPlay;

  /// No description provided for @settingsVideoLoopModeTile.
  ///
  /// In en, this message translates to:
  /// **'Loop mode'**
  String get settingsVideoLoopModeTile;

  /// No description provided for @settingsVideoLoopModeDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Loop Mode'**
  String get settingsVideoLoopModeDialogTitle;

  /// No description provided for @settingsVideoResumptionModeTile.
  ///
  /// In en, this message translates to:
  /// **'Resume playback'**
  String get settingsVideoResumptionModeTile;

  /// No description provided for @settingsVideoResumptionModeDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Resume Playback'**
  String get settingsVideoResumptionModeDialogTitle;

  /// No description provided for @settingsVideoBackgroundMode.
  ///
  /// In en, this message translates to:
  /// **'Background mode'**
  String get settingsVideoBackgroundMode;

  /// No description provided for @settingsVideoBackgroundModeDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Background Mode'**
  String get settingsVideoBackgroundModeDialogTitle;

  /// No description provided for @settingsVideoControlsTile.
  ///
  /// In en, this message translates to:
  /// **'Controls'**
  String get settingsVideoControlsTile;

  /// No description provided for @settingsVideoControlsPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Controls'**
  String get settingsVideoControlsPageTitle;

  /// No description provided for @settingsVideoButtonsTile.
  ///
  /// In en, this message translates to:
  /// **'Buttons'**
  String get settingsVideoButtonsTile;

  /// No description provided for @settingsVideoGestureDoubleTapTogglePlay.
  ///
  /// In en, this message translates to:
  /// **'Double tap to play/pause'**
  String get settingsVideoGestureDoubleTapTogglePlay;

  /// No description provided for @settingsVideoGestureSideDoubleTapSeek.
  ///
  /// In en, this message translates to:
  /// **'Double tap on screen edges to seek backward/forward'**
  String get settingsVideoGestureSideDoubleTapSeek;

  /// No description provided for @settingsVideoGestureVerticalDragBrightnessVolume.
  ///
  /// In en, this message translates to:
  /// **'Swipe up or down to adjust brightness/volume'**
  String get settingsVideoGestureVerticalDragBrightnessVolume;

  /// No description provided for @settingsSubtitleThemeTile.
  ///
  /// In en, this message translates to:
  /// **'Subtitles'**
  String get settingsSubtitleThemeTile;

  /// No description provided for @settingsSubtitleThemePageTitle.
  ///
  /// In en, this message translates to:
  /// **'Subtitles'**
  String get settingsSubtitleThemePageTitle;

  /// No description provided for @settingsSubtitleThemeSample.
  ///
  /// In en, this message translates to:
  /// **'This is a sample.'**
  String get settingsSubtitleThemeSample;

  /// No description provided for @settingsSubtitleThemeTextAlignmentTile.
  ///
  /// In en, this message translates to:
  /// **'Text alignment'**
  String get settingsSubtitleThemeTextAlignmentTile;

  /// No description provided for @settingsSubtitleThemeTextAlignmentDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Text Alignment'**
  String get settingsSubtitleThemeTextAlignmentDialogTitle;

  /// No description provided for @settingsSubtitleThemeTextPositionTile.
  ///
  /// In en, this message translates to:
  /// **'Text position'**
  String get settingsSubtitleThemeTextPositionTile;

  /// No description provided for @settingsSubtitleThemeTextPositionDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Text Position'**
  String get settingsSubtitleThemeTextPositionDialogTitle;

  /// No description provided for @settingsSubtitleThemeTextSize.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get settingsSubtitleThemeTextSize;

  /// No description provided for @settingsSubtitleThemeShowOutline.
  ///
  /// In en, this message translates to:
  /// **'Show outline and shadow'**
  String get settingsSubtitleThemeShowOutline;

  /// No description provided for @settingsSubtitleThemeTextColor.
  ///
  /// In en, this message translates to:
  /// **'Text color'**
  String get settingsSubtitleThemeTextColor;

  /// No description provided for @settingsSubtitleThemeTextOpacity.
  ///
  /// In en, this message translates to:
  /// **'Text opacity'**
  String get settingsSubtitleThemeTextOpacity;

  /// No description provided for @settingsSubtitleThemeBackgroundColor.
  ///
  /// In en, this message translates to:
  /// **'Background color'**
  String get settingsSubtitleThemeBackgroundColor;

  /// No description provided for @settingsSubtitleThemeBackgroundOpacity.
  ///
  /// In en, this message translates to:
  /// **'Background opacity'**
  String get settingsSubtitleThemeBackgroundOpacity;

  /// No description provided for @settingsSubtitleThemeTextAlignmentLeft.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get settingsSubtitleThemeTextAlignmentLeft;

  /// No description provided for @settingsSubtitleThemeTextAlignmentCenter.
  ///
  /// In en, this message translates to:
  /// **'Center'**
  String get settingsSubtitleThemeTextAlignmentCenter;

  /// No description provided for @settingsSubtitleThemeTextAlignmentRight.
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get settingsSubtitleThemeTextAlignmentRight;

  /// No description provided for @settingsPrivacySectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get settingsPrivacySectionTitle;

  /// No description provided for @settingsAllowInstalledAppAccess.
  ///
  /// In en, this message translates to:
  /// **'Allow access to app inventory'**
  String get settingsAllowInstalledAppAccess;

  /// No description provided for @settingsAllowInstalledAppAccessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Used to improve album display'**
  String get settingsAllowInstalledAppAccessSubtitle;

  /// No description provided for @settingsAllowErrorReporting.
  ///
  /// In en, this message translates to:
  /// **'Allow anonymous error reporting'**
  String get settingsAllowErrorReporting;

  /// No description provided for @settingsSaveSearchHistory.
  ///
  /// In en, this message translates to:
  /// **'Save search history'**
  String get settingsSaveSearchHistory;

  /// No description provided for @settingsEnableBin.
  ///
  /// In en, this message translates to:
  /// **'Use recycle bin'**
  String get settingsEnableBin;

  /// No description provided for @settingsEnableBinSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep deleted items for 30 days'**
  String get settingsEnableBinSubtitle;

  /// No description provided for @settingsDisablingBinWarningDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Items in the recycle bin will be deleted forever.'**
  String get settingsDisablingBinWarningDialogMessage;

  /// No description provided for @settingsAllowMediaManagement.
  ///
  /// In en, this message translates to:
  /// **'Allow media management'**
  String get settingsAllowMediaManagement;

  /// No description provided for @settingsHiddenItemsTile.
  ///
  /// In en, this message translates to:
  /// **'Hidden items'**
  String get settingsHiddenItemsTile;

  /// No description provided for @settingsHiddenItemsPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Hidden Items'**
  String get settingsHiddenItemsPageTitle;

  /// No description provided for @settingsHiddenFiltersBanner.
  ///
  /// In en, this message translates to:
  /// **'Photos and videos matching hidden filters will not appear in your collection.'**
  String get settingsHiddenFiltersBanner;

  /// No description provided for @settingsHiddenFiltersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No hidden filters'**
  String get settingsHiddenFiltersEmpty;

  /// No description provided for @settingsStorageAccessTile.
  ///
  /// In en, this message translates to:
  /// **'Storage access'**
  String get settingsStorageAccessTile;

  /// No description provided for @settingsStorageAccessPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Storage Access'**
  String get settingsStorageAccessPageTitle;

  /// No description provided for @settingsStorageAccessBanner.
  ///
  /// In en, this message translates to:
  /// **'Some directories require an explicit access grant to modify files in them. You can review here directories to which you previously gave access.'**
  String get settingsStorageAccessBanner;

  /// No description provided for @settingsStorageAccessEmpty.
  ///
  /// In en, this message translates to:
  /// **'No access grants'**
  String get settingsStorageAccessEmpty;

  /// No description provided for @settingsStorageAccessRevokeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Revoke'**
  String get settingsStorageAccessRevokeTooltip;

  /// No description provided for @settingsAccessibilitySectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get settingsAccessibilitySectionTitle;

  /// No description provided for @settingsRemoveAnimationsTile.
  ///
  /// In en, this message translates to:
  /// **'Remove animations'**
  String get settingsRemoveAnimationsTile;

  /// No description provided for @settingsRemoveAnimationsDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Animations'**
  String get settingsRemoveAnimationsDialogTitle;

  /// No description provided for @settingsTimeToTakeActionTile.
  ///
  /// In en, this message translates to:
  /// **'Time to take action'**
  String get settingsTimeToTakeActionTile;

  /// No description provided for @settingsAccessibilityShowPinchGestureAlternatives.
  ///
  /// In en, this message translates to:
  /// **'Show multi-touch gesture alternatives'**
  String get settingsAccessibilityShowPinchGestureAlternatives;

  /// No description provided for @settingsDisplaySectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get settingsDisplaySectionTitle;

  /// No description provided for @settingsThemeBrightnessTile.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsThemeBrightnessTile;

  /// No description provided for @settingsThemeBrightnessDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsThemeBrightnessDialogTitle;

  /// No description provided for @settingsThemeColorHighlights.
  ///
  /// In en, this message translates to:
  /// **'Color highlights'**
  String get settingsThemeColorHighlights;

  /// No description provided for @settingsThemeEnableDynamicColor.
  ///
  /// In en, this message translates to:
  /// **'Dynamic color'**
  String get settingsThemeEnableDynamicColor;

  /// No description provided for @settingsDisplayRefreshRateModeTile.
  ///
  /// In en, this message translates to:
  /// **'Display refresh rate'**
  String get settingsDisplayRefreshRateModeTile;

  /// No description provided for @settingsDisplayRefreshRateModeDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Refresh Rate'**
  String get settingsDisplayRefreshRateModeDialogTitle;

  /// No description provided for @settingsDisplayUseTvInterface.
  ///
  /// In en, this message translates to:
  /// **'Android TV interface'**
  String get settingsDisplayUseTvInterface;

  /// No description provided for @settingsLanguageSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Language & Formats'**
  String get settingsLanguageSectionTitle;

  /// No description provided for @settingsLanguageTile.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageTile;

  /// No description provided for @settingsLanguagePageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguagePageTitle;

  /// No description provided for @settingsCoordinateFormatTile.
  ///
  /// In en, this message translates to:
  /// **'Coordinate format'**
  String get settingsCoordinateFormatTile;

  /// No description provided for @settingsCoordinateFormatDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Coordinate Format'**
  String get settingsCoordinateFormatDialogTitle;

  /// No description provided for @settingsUnitSystemTile.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get settingsUnitSystemTile;

  /// No description provided for @settingsUnitSystemDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get settingsUnitSystemDialogTitle;

  /// No description provided for @settingsForceWesternArabicNumeralsTile.
  ///
  /// In en, this message translates to:
  /// **'Force Arabic numerals'**
  String get settingsForceWesternArabicNumeralsTile;

  /// No description provided for @settingsScreenSaverPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Screen Saver'**
  String get settingsScreenSaverPageTitle;

  /// No description provided for @settingsWidgetPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Photo Frame'**
  String get settingsWidgetPageTitle;

  /// No description provided for @settingsWidgetShowOutline.
  ///
  /// In en, this message translates to:
  /// **'Outline'**
  String get settingsWidgetShowOutline;

  /// No description provided for @settingsWidgetOpenPage.
  ///
  /// In en, this message translates to:
  /// **'When tapping on the widget'**
  String get settingsWidgetOpenPage;

  /// No description provided for @settingsWidgetDisplayedItem.
  ///
  /// In en, this message translates to:
  /// **'Displayed item'**
  String get settingsWidgetDisplayedItem;

  /// No description provided for @settingsCollectionTile.
  ///
  /// In en, this message translates to:
  /// **'Collection'**
  String get settingsCollectionTile;

  /// No description provided for @statsPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get statsPageTitle;

  /// No description provided for @statsWithGps.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item with location} other{{count} items with location}}'**
  String statsWithGps(int count);

  /// No description provided for @statsTopCountriesSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Top Countries'**
  String get statsTopCountriesSectionTitle;

  /// No description provided for @statsTopStatesSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Top States'**
  String get statsTopStatesSectionTitle;

  /// No description provided for @statsTopPlacesSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Top Places'**
  String get statsTopPlacesSectionTitle;

  /// No description provided for @statsTopTagsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Top Tags'**
  String get statsTopTagsSectionTitle;

  /// No description provided for @statsTopAlbumsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Top Albums'**
  String get statsTopAlbumsSectionTitle;

  /// No description provided for @viewerOpenPanoramaButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'OPEN PANORAMA'**
  String get viewerOpenPanoramaButtonLabel;

  /// No description provided for @viewerSetWallpaperButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'SET WALLPAPER'**
  String get viewerSetWallpaperButtonLabel;

  /// No description provided for @viewerErrorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Oops!'**
  String get viewerErrorUnknown;

  /// No description provided for @viewerErrorDoesNotExist.
  ///
  /// In en, this message translates to:
  /// **'The file no longer exists.'**
  String get viewerErrorDoesNotExist;

  /// No description provided for @viewerInfoPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get viewerInfoPageTitle;

  /// No description provided for @viewerInfoBackToViewerTooltip.
  ///
  /// In en, this message translates to:
  /// **'Back to viewer'**
  String get viewerInfoBackToViewerTooltip;

  /// No description provided for @viewerInfoUnknown.
  ///
  /// In en, this message translates to:
  /// **'unknown'**
  String get viewerInfoUnknown;

  /// No description provided for @viewerInfoLabelDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get viewerInfoLabelDescription;

  /// No description provided for @viewerInfoLabelTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get viewerInfoLabelTitle;

  /// No description provided for @viewerInfoLabelDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get viewerInfoLabelDate;

  /// No description provided for @viewerInfoLabelResolution.
  ///
  /// In en, this message translates to:
  /// **'Resolution'**
  String get viewerInfoLabelResolution;

  /// No description provided for @viewerInfoLabelSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get viewerInfoLabelSize;

  /// No description provided for @viewerInfoLabelUri.
  ///
  /// In en, this message translates to:
  /// **'URI'**
  String get viewerInfoLabelUri;

  /// No description provided for @viewerInfoLabelPath.
  ///
  /// In en, this message translates to:
  /// **'Path'**
  String get viewerInfoLabelPath;

  /// No description provided for @viewerInfoLabelDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get viewerInfoLabelDuration;

  /// No description provided for @viewerInfoLabelOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get viewerInfoLabelOwner;

  /// No description provided for @viewerInfoLabelCoordinates.
  ///
  /// In en, this message translates to:
  /// **'Coordinates'**
  String get viewerInfoLabelCoordinates;

  /// No description provided for @viewerInfoLabelAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get viewerInfoLabelAddress;

  /// No description provided for @mapStyleDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Map Style'**
  String get mapStyleDialogTitle;

  /// No description provided for @mapStyleTooltip.
  ///
  /// In en, this message translates to:
  /// **'Select map style'**
  String get mapStyleTooltip;

  /// No description provided for @mapZoomInTooltip.
  ///
  /// In en, this message translates to:
  /// **'Zoom in'**
  String get mapZoomInTooltip;

  /// No description provided for @mapZoomOutTooltip.
  ///
  /// In en, this message translates to:
  /// **'Zoom out'**
  String get mapZoomOutTooltip;

  /// No description provided for @mapPointNorthUpTooltip.
  ///
  /// In en, this message translates to:
  /// **'Point north up'**
  String get mapPointNorthUpTooltip;

  /// No description provided for @mapAttributionOsmData.
  ///
  /// In en, this message translates to:
  /// **'Map data © [OpenStreetMap](https://www.openstreetmap.org/copyright) contributors'**
  String get mapAttributionOsmData;

  /// No description provided for @mapAttributionOsmLiberty.
  ///
  /// In en, this message translates to:
  /// **'Tiles by [OpenMapTiles](https://www.openmaptiles.org/), [CC BY](http://creativecommons.org/licenses/by/4.0) • Hosted by [OSM Americana](https://tile.ourmap.us)'**
  String get mapAttributionOsmLiberty;

  /// No description provided for @mapAttributionOpenTopoMap.
  ///
  /// In en, this message translates to:
  /// **'[SRTM](https://www.earthdata.nasa.gov/sensors/srtm) | Tiles by [OpenTopoMap](https://opentopomap.org/), [CC BY-SA](https://creativecommons.org/licenses/by-sa/3.0/)'**
  String get mapAttributionOpenTopoMap;

  /// No description provided for @mapAttributionOsmHot.
  ///
  /// In en, this message translates to:
  /// **'Tiles by [HOT](https://www.hotosm.org/) • Hosted by [OSM France](https://openstreetmap.fr/)'**
  String get mapAttributionOsmHot;

  /// No description provided for @mapAttributionStamen.
  ///
  /// In en, this message translates to:
  /// **'Tiles by [Stamen Design](https://stamen.com), [CC BY 3.0](https://creativecommons.org/licenses/by/3.0)'**
  String get mapAttributionStamen;

  /// No description provided for @openMapPageTooltip.
  ///
  /// In en, this message translates to:
  /// **'View on Map page'**
  String get openMapPageTooltip;

  /// No description provided for @mapEmptyRegion.
  ///
  /// In en, this message translates to:
  /// **'No images in this region'**
  String get mapEmptyRegion;

  /// No description provided for @viewerInfoOpenEmbeddedFailureFeedback.
  ///
  /// In en, this message translates to:
  /// **'Failed to extract embedded data'**
  String get viewerInfoOpenEmbeddedFailureFeedback;

  /// No description provided for @viewerInfoOpenLinkText.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get viewerInfoOpenLinkText;

  /// No description provided for @viewerInfoViewXmlLinkText.
  ///
  /// In en, this message translates to:
  /// **'View XML'**
  String get viewerInfoViewXmlLinkText;

  /// No description provided for @viewerInfoSearchFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Search metadata'**
  String get viewerInfoSearchFieldLabel;

  /// No description provided for @viewerInfoSearchEmpty.
  ///
  /// In en, this message translates to:
  /// **'No matching keys'**
  String get viewerInfoSearchEmpty;

  /// No description provided for @viewerInfoSearchSuggestionDate.
  ///
  /// In en, this message translates to:
  /// **'Date & time'**
  String get viewerInfoSearchSuggestionDate;

  /// No description provided for @viewerInfoSearchSuggestionDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get viewerInfoSearchSuggestionDescription;

  /// No description provided for @viewerInfoSearchSuggestionDimensions.
  ///
  /// In en, this message translates to:
  /// **'Dimensions'**
  String get viewerInfoSearchSuggestionDimensions;

  /// No description provided for @viewerInfoSearchSuggestionResolution.
  ///
  /// In en, this message translates to:
  /// **'Resolution'**
  String get viewerInfoSearchSuggestionResolution;

  /// No description provided for @viewerInfoSearchSuggestionRights.
  ///
  /// In en, this message translates to:
  /// **'Rights'**
  String get viewerInfoSearchSuggestionRights;

  /// No description provided for @wallpaperUseScrollEffect.
  ///
  /// In en, this message translates to:
  /// **'Use scroll effect on home screen'**
  String get wallpaperUseScrollEffect;

  /// No description provided for @tagEditorPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Tags'**
  String get tagEditorPageTitle;

  /// No description provided for @tagEditorPageNewTagFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'New tag'**
  String get tagEditorPageNewTagFieldLabel;

  /// No description provided for @tagEditorPageAddTagTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add tag'**
  String get tagEditorPageAddTagTooltip;

  /// No description provided for @tagEditorSectionRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get tagEditorSectionRecent;

  /// No description provided for @tagEditorSectionPlaceholders.
  ///
  /// In en, this message translates to:
  /// **'Placeholders'**
  String get tagEditorSectionPlaceholders;

  /// No description provided for @tagEditorDiscardDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you want to discard changes?'**
  String get tagEditorDiscardDialogMessage;

  /// No description provided for @tagPlaceholderCountry.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get tagPlaceholderCountry;

  /// No description provided for @tagPlaceholderState.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get tagPlaceholderState;

  /// No description provided for @tagPlaceholderPlace.
  ///
  /// In en, this message translates to:
  /// **'Place'**
  String get tagPlaceholderPlace;

  /// No description provided for @panoramaEnableSensorControl.
  ///
  /// In en, this message translates to:
  /// **'Enable sensor control'**
  String get panoramaEnableSensorControl;

  /// No description provided for @panoramaDisableSensorControl.
  ///
  /// In en, this message translates to:
  /// **'Disable sensor control'**
  String get panoramaDisableSensorControl;

  /// No description provided for @sourceViewerPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get sourceViewerPageTitle;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'az', 'be', 'bg', 'bn', 'ca', 'ckb', 'cs', 'da', 'de', 'el', 'en', 'es', 'et', 'eu', 'fa', 'fi', 'fr', 'gl', 'he', 'hi', 'hu', 'id', 'is', 'it', 'ja', 'kn', 'ko', 'lt', 'ml', 'my', 'nb', 'ne', 'nl', 'nn', 'or', 'pl', 'pt', 'ro', 'ru', 'sat', 'sk', 'sl', 'sr', 'sv', 'ta', 'th', 'tr', 'uk', 'ur', 'vi', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {

  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'en': {
  switch (locale.scriptCode) {
    case 'Shaw': return AppLocalizationsEnShaw();
   }
  break;
   }
      case 'zh': {
  switch (locale.scriptCode) {
    case 'Hant': return AppLocalizationsZhHant();
   }
  break;
   }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'az': return AppLocalizationsAz();
    case 'be': return AppLocalizationsBe();
    case 'bg': return AppLocalizationsBg();
    case 'bn': return AppLocalizationsBn();
    case 'ca': return AppLocalizationsCa();
    case 'ckb': return AppLocalizationsCkb();
    case 'cs': return AppLocalizationsCs();
    case 'da': return AppLocalizationsDa();
    case 'de': return AppLocalizationsDe();
    case 'el': return AppLocalizationsEl();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'et': return AppLocalizationsEt();
    case 'eu': return AppLocalizationsEu();
    case 'fa': return AppLocalizationsFa();
    case 'fi': return AppLocalizationsFi();
    case 'fr': return AppLocalizationsFr();
    case 'gl': return AppLocalizationsGl();
    case 'he': return AppLocalizationsHe();
    case 'hi': return AppLocalizationsHi();
    case 'hu': return AppLocalizationsHu();
    case 'id': return AppLocalizationsId();
    case 'is': return AppLocalizationsIs();
    case 'it': return AppLocalizationsIt();
    case 'ja': return AppLocalizationsJa();
    case 'kn': return AppLocalizationsKn();
    case 'ko': return AppLocalizationsKo();
    case 'lt': return AppLocalizationsLt();
    case 'ml': return AppLocalizationsMl();
    case 'my': return AppLocalizationsMy();
    case 'nb': return AppLocalizationsNb();
    case 'ne': return AppLocalizationsNe();
    case 'nl': return AppLocalizationsNl();
    case 'nn': return AppLocalizationsNn();
    case 'or': return AppLocalizationsOr();
    case 'pl': return AppLocalizationsPl();
    case 'pt': return AppLocalizationsPt();
    case 'ro': return AppLocalizationsRo();
    case 'ru': return AppLocalizationsRu();
    case 'sat': return AppLocalizationsSat();
    case 'sk': return AppLocalizationsSk();
    case 'sl': return AppLocalizationsSl();
    case 'sr': return AppLocalizationsSr();
    case 'sv': return AppLocalizationsSv();
    case 'ta': return AppLocalizationsTa();
    case 'th': return AppLocalizationsTh();
    case 'tr': return AppLocalizationsTr();
    case 'uk': return AppLocalizationsUk();
    case 'ur': return AppLocalizationsUr();
    case 'vi': return AppLocalizationsVi();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
