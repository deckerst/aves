import 'package:aves/model/actions/entry_actions.dart';
import 'package:aves/model/actions/entry_set_actions.dart';
import 'package:aves/model/actions/video_actions.dart';
import 'package:aves/model/filters/favourite.dart';
import 'package:aves/model/filters/mime.dart';
import 'package:aves/model/settings/enums.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/widgets/filter_grids/albums_page.dart';
import 'package:aves/widgets/filter_grids/countries_page.dart';
import 'package:aves/widgets/filter_grids/tags_page.dart';
import 'package:flutter/material.dart';

class SettingsDefaults {
  // app
  static const hasAcceptedTerms = false;
  static const isCrashlyticsEnabled = false;
  static const mustBackTwiceToExit = true;
  static const keepScreenOn = KeepScreenOn.viewerOnly;
  static const homePage = HomePageSetting.collection;

  // drawer
  static final drawerTypeBookmarks = [
    null,
    MimeFilter.video,
    FavouriteFilter.instance,
  ];
  static const drawerPageBookmarks = [
    AlbumListPage.routeName,
    CountryListPage.routeName,
    TagListPage.routeName,
  ];

  // collection
  static const collectionSectionFactor = EntryGroupFactor.month;
  static const collectionSortFactor = EntrySortFactor.date;
  static const collectionSelectionQuickActions = [
    EntrySetAction.share,
    EntrySetAction.delete,
  ];
  static const showThumbnailLocation = true;
  static const showThumbnailRaw = true;
  static const showThumbnailVideoDuration = true;

  // filter grids
  static const albumGroupFactor = AlbumChipGroupFactor.importance;
  static const albumSortFactor = ChipSortFactor.name;
  static const countrySortFactor = ChipSortFactor.name;
  static const tagSortFactor = ChipSortFactor.name;

  // viewer
  static const viewerQuickActions = [
    EntryAction.toggleFavourite,
    EntryAction.share,
    EntryAction.rotateScreen,
  ];
  static const showOverlayMinimap = false;
  static const showOverlayInfo = true;
  static const showOverlayShootingDetails = false;
  static const enableOverlayBlurEffect = true;
  static const viewerUseCutout = true;

  // video
  static const videoQuickActions = [
    VideoAction.replay10,
    VideoAction.togglePlay,
  ];
  static const enableVideoHardwareAcceleration = true;
  static const enableVideoAutoPlay = false;
  static const videoLoopMode = VideoLoopMode.shortOnly;
  static const videoShowRawTimedText = false;

  // subtitles
  static const subtitleFontSize = 20.0;
  static const subtitleTextAlignment = TextAlign.center;
  static const subtitleShowOutline = true;
  static const subtitleTextColor = Colors.white;
  static const subtitleBackgroundColor = Colors.transparent;

  // info
  static const infoMapStyle = EntryMapStyle.stamenWatercolor;
  static const infoMapZoom = 12.0;
  static const coordinateFormat = CoordinateFormat.dms;

  // rendering
  static const imageBackground = EntryBackground.white;

  // search
  static const saveSearchHistory = true;
}
