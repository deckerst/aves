class SettingKeys {
  static bool isInternalKey(String key) => _internalKeys.contains(key) || key.startsWith(_widgetKeyPrefix);

  static const Set<String> _internalKeys = {
    hasAcceptedTermsKey,
    catalogTimeZoneRawOffsetMillisKey,
    searchHistoryKey,
    platformAccelerometerRotationKey,
    platformTransitionAnimationScaleKey,
    topEntryIdsKey,
    recentDestinationAlbumsKey,
    recentTagsKey,
  };

  static const _widgetKeyPrefix = 'widget_';

  // app
  static const hasAcceptedTermsKey = 'has_accepted_terms';
  static const canUseAnalysisServiceKey = 'can_use_analysis_service';
  static const isInstalledAppAccessAllowedKey = 'is_installed_app_access_allowed';
  static const isErrorReportingAllowedKey = 'is_crashlytics_enabled';
  static const localeKey = 'locale';
  static const catalogTimeZoneRawOffsetMillisKey = 'catalog_time_zone_raw_offset_millis';
  static const tileExtentPrefixKey = 'tile_extent_';
  static const tileLayoutPrefixKey = 'tile_layout_';
  static const entryRenamingPatternKey = 'entry_renaming_pattern';
  static const topEntryIdsKey = 'top_entry_ids';
  static const recentDestinationAlbumsKey = 'recent_destination_albums';
  static const recentTagsKey = 'recent_tags';

  // display
  static const displayRefreshRateModeKey = 'display_refresh_rate_mode';
  static const themeBrightnessKey = 'theme_brightness';
  static const themeColorModeKey = 'theme_color_mode';
  static const enableDynamicColorKey = 'dynamic_color';
  static const enableBlurEffectKey = 'enable_overlay_blur_effect';
  static const maxBrightnessKey = 'max_brightness';
  static const forceTvLayoutKey = 'force_tv_layout';

  // navigation
  static const mustBackTwiceToExitKey = 'must_back_twice_to_exit';
  static const keepScreenOnKey = 'keep_screen_on';
  static const homePageKey = 'home_page';
  static const enableBottomNavigationBarKey = 'show_bottom_navigation_bar';
  static const confirmCreateVaultKey = 'confirm_create_vault';
  static const confirmDeleteForeverKey = 'confirm_delete_forever';
  static const confirmMoveToBinKey = 'confirm_move_to_bin';
  static const confirmMoveUndatedItemsKey = 'confirm_move_undated_items';
  static const confirmAfterMoveToBinKey = 'confirm_after_move_to_bin';
  static const setMetadataDateBeforeFileOpKey = 'set_metadata_date_before_file_op';
  static const drawerTypeBookmarksKey = 'drawer_type_bookmarks';
  static const drawerAlbumBookmarksKey = 'drawer_album_bookmarks';
  static const drawerPageBookmarksKey = 'drawer_page_bookmarks';

  // collection
  static const collectionBurstPatternsKey = 'collection_burst_patterns';
  static const collectionGroupFactorKey = 'collection_group_factor';
  static const collectionSortFactorKey = 'collection_sort_factor';
  static const collectionSortReverseKey = 'collection_sort_reverse';
  static const collectionBrowsingQuickActionsKey = 'collection_browsing_quick_actions';
  static const collectionSelectionQuickActionsKey = 'collection_selection_quick_actions';
  static const showThumbnailFavouriteKey = 'show_thumbnail_favourite';
  static const thumbnailLocationIconKey = 'thumbnail_location_icon';
  static const thumbnailTagIconKey = 'thumbnail_tag_icon';
  static const showThumbnailMotionPhotoKey = 'show_thumbnail_motion_photo';
  static const showThumbnailRatingKey = 'show_thumbnail_rating';
  static const showThumbnailRawKey = 'show_thumbnail_raw';
  static const showThumbnailVideoDurationKey = 'show_thumbnail_video_duration';

  // filter grids
  static const albumGroupFactorKey = 'album_group_factor';
  static const albumSortFactorKey = 'album_sort_factor';
  static const countrySortFactorKey = 'country_sort_factor';
  static const stateSortFactorKey = 'state_sort_factor';
  static const placeSortFactorKey = 'place_sort_factor';
  static const tagSortFactorKey = 'tag_sort_factor';
  static const albumSortReverseKey = 'album_sort_reverse';
  static const countrySortReverseKey = 'country_sort_reverse';
  static const stateSortReverseKey = 'state_sort_reverse';
  static const placeSortReverseKey = 'place_sort_reverse';
  static const tagSortReverseKey = 'tag_sort_reverse';
  static const pinnedFiltersKey = 'pinned_filters';
  static const hiddenFiltersKey = 'hidden_filters';
  static const showAlbumPickQueryKey = 'show_album_pick_query';

  // viewer
  static const viewerQuickActionsKey = 'viewer_quick_actions';
  static const showOverlayOnOpeningKey = 'show_overlay_on_opening';
  static const showOverlayMinimapKey = 'show_overlay_minimap';
  static const overlayHistogramStyleKey = 'show_overlay_histogram';
  static const showOverlayInfoKey = 'show_overlay_info';
  static const showOverlayDescriptionKey = 'show_overlay_description';
  static const showOverlayRatingTagsKey = 'show_overlay_rating_tags';
  static const showOverlayShootingDetailsKey = 'show_overlay_shooting_details';
  static const showOverlayThumbnailPreviewKey = 'show_overlay_thumbnail_preview';
  static const viewerGestureSideTapNextKey = 'viewer_gesture_side_tap_next';
  static const viewerUseCutoutKey = 'viewer_use_cutout';
  static const enableMotionPhotoAutoPlayKey = 'motion_photo_auto_play';
  static const imageBackgroundKey = 'image_background';

  // video
  static const enableVideoHardwareAccelerationKey = 'video_hwaccel_mediacodec';
  static const videoBackgroundModeKey = 'video_background_mode';
  static const videoAutoPlayModeKey = 'video_auto_play_mode';
  static const videoLoopModeKey = 'video_loop';
  static const videoResumptionModeKey = 'video_resumption_mode';
  static const videoControlsKey = 'video_controls';
  static const videoGestureDoubleTapTogglePlayKey = 'video_gesture_double_tap_toggle_play';
  static const videoGestureSideDoubleTapSeekKey = 'video_gesture_side_double_tap_skip';
  static const videoGestureVerticalDragBrightnessVolumeKey = 'video_gesture_vertical_drag_brightness_volume';

  // subtitles
  static const subtitleFontSizeKey = 'subtitle_font_size';
  static const subtitleTextAlignmentKey = 'subtitle_text_alignment';
  static const subtitleTextPositionKey = 'subtitle_text_position';
  static const subtitleShowOutlineKey = 'subtitle_show_outline';
  static const subtitleTextColorKey = 'subtitle_text_color';
  static const subtitleBackgroundColorKey = 'subtitle_background_color';

  // info
  static const infoMapZoomKey = 'info_map_zoom';
  static const coordinateFormatKey = 'coordinates_format';
  static const unitSystemKey = 'unit_system';

  // tag editor

  static const tagEditorCurrentFilterSectionExpandedKey = 'tag_editor_current_filter_section_expanded';
  static const tagEditorExpandedSectionKey = 'tag_editor_expanded_section';

  // converter

  static const convertMimeTypeKey = 'convert_mime_type';
  static const convertQualityKey = 'convert_quality';
  static const convertWriteMetadataKey = 'convert_write_metadata';

  // map
  static const mapStyleKey = 'info_map_style';
  static const mapDefaultCenterKey = 'map_default_center';

  // search
  static const saveSearchHistoryKey = 'save_search_history';
  static const searchHistoryKey = 'search_history';

  // bin
  static const enableBinKey = 'enable_bin';

  // accessibility
  static const showPinchGestureAlternativesKey = 'show_pinch_gesture_alternatives';
  static const accessibilityAnimationsKey = 'accessibility_animations';
  static const timeToTakeActionKey = 'time_to_take_action';

  // file picker
  static const filePickerShowHiddenFilesKey = 'file_picker_show_hidden_files';

  // screen saver
  static const screenSaverFillScreenKey = 'screen_saver_fill_screen';
  static const screenSaverAnimatedZoomEffectKey = 'screen_saver_animated_zoom_effect';
  static const screenSaverTransitionKey = 'screen_saver_transition';
  static const screenSaverVideoPlaybackKey = 'screen_saver_video_playback';
  static const screenSaverIntervalKey = 'screen_saver_interval';
  static const screenSaverCollectionFiltersKey = 'screen_saver_collection_filters';

  // slideshow
  static const slideshowRepeatKey = 'slideshow_loop';
  static const slideshowShuffleKey = 'slideshow_shuffle';
  static const slideshowFillScreenKey = 'slideshow_fill_screen';
  static const slideshowAnimatedZoomEffectKey = 'slideshow_animated_zoom_effect';
  static const slideshowTransitionKey = 'slideshow_transition';
  static const slideshowVideoPlaybackKey = 'slideshow_video_playback';
  static const slideshowIntervalKey = 'slideshow_interval';

  // widget
  static const widgetOutlinePrefixKey = '${_widgetKeyPrefix}outline_';
  static const widgetShapePrefixKey = '${_widgetKeyPrefix}shape_';
  static const widgetCollectionFiltersPrefixKey = '${_widgetKeyPrefix}collection_filters_';
  static const widgetOpenPagePrefixKey = '${_widgetKeyPrefix}open_page_';
  static const widgetDisplayedItemPrefixKey = '${_widgetKeyPrefix}displayed_item_';
  static const widgetUriPrefixKey = '${_widgetKeyPrefix}uri_';

  // platform settings
  // cf Android `Settings.System.ACCELEROMETER_ROTATION`
  static const platformAccelerometerRotationKey = 'accelerometer_rotation';

  // cf Android `Settings.Global.TRANSITION_ANIMATION_SCALE`
  static const platformTransitionAnimationScaleKey = 'transition_animation_scale';
}
