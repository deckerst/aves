import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:material_symbols_icons/symbols.dart';

class AIcons {
  static const allCollection = Symbols.collections;
  static const image = Symbols.photo;
  static const video = Symbols.movie;
  static const vector = Symbols.code;

  static const accessibility = Symbols.accessibility_new;
  static const android = Symbols.android;
  static const app = Symbols.apps;
  static const apply = Symbols.done;
  static const aspectRatio = Symbols.aspect_ratio;
  static const bin = Symbols.delete;
  static const broken = Symbols.broken_image;
  static const brightnessMin = Symbols.brightness_low;
  static const brightnessMax = Symbols.brightness_high;
  static const checked = Symbols.done;
  static const circle = Symbols.fiber_manual_record;
  static final count = MdiIcons.counter;
  static const counter = Symbols.plus_one;
  static const description = Symbols.description;
  static const descriptionUntitled = Symbols.comments_disabled;
  static const display = Symbols.light_mode;
  static const duration = Symbols.timelapse;
  static const error = Symbols.error;
  static const explorer = Symbols.account_tree;
  static const folder = Symbols.folder;
  static final github = MdiIcons.github;
  static const home = Symbols.home;

  // as of Flutter v3.16.3,
  // `label_important_outlined` matches text direction but is filled
  // `label_important_outline` is outlined but does not match text direction
  static const important = IconData(labelImportantOutlineCodePoint, fontFamily: materialIconsFontFamily, matchTextDirection: true);

  static const language = Symbols.translate;
  static final legal = MdiIcons.scaleBalance;
  static const mimeType = Symbols.code;
  static const name = Symbols.match_word;
  static const newTier = Symbols.fiber_new;
  static const opacity = Symbols.opacity;
  static const palette = Symbols.palette;
  static const path = Symbols.account_tree;
  static const privacy = Symbols.shield_person;
  static const rating = Symbols.star;
  static final ratingRejected = MdiIcons.starMinusOutline;
  static final ratingUnrated = MdiIcons.starOffOutline;
  static const raw = Symbols.raw_on;
  static const sensorControlEnabled = Symbols.explore;
  static const sensorControlDisabled = Symbols.explore_off;
  static const settings = Symbols.settings;
  static const shooting = Symbols.camera;
  static const size = Symbols.data_usage;
  static const storageCard = Symbols.sd_storage;
  static const storageMain = Symbols.smartphone;
  static const streamVideo = Symbols.movie;
  static const streamAudio = Symbols.audiotrack;
  static const streamText = Symbols.closed_caption;
  static const tag = Symbols.sell;
  static final tagUntagged = MdiIcons.tagOffOutline;
  static const text = Symbols.format_quote;
  static const thumbnails = Symbols.grid_on;
  static const volumeMin = Symbols.volume_mute;
  static const volumeMax = Symbols.volume_up;

  // time/space
  static const date = Symbols.calendar_today;
  static const dateByDay = Symbols.today;
  static const dateByMonth = Symbols.calendar_month;
  static const dateRecent = Symbols.today;
  static const dateUndated = Symbols.event_busy;
  static const dateWeekday = Symbols.today;
  static const geoBounds = Symbols.public;
  static const location = Symbols.place;
  static const locationUnlocated = Symbols.location_off;
  static const country = Symbols.flag;
  static const state = Symbols.flag;
  static const place = Symbols.place;

  // view
  static const section = Symbols.subheader;
  static const layout = Symbols.grid_view;
  static const layoutMosaic = Symbols.view_comfy;
  static const layoutGrid = Symbols.view_compact;
  static const layoutList = Symbols.list;
  static const sort = Symbols.sort;
  static const sortOrder = Symbols.swap_vert;
  static const thumbnailLarge = Symbols.photo_size_select_large;
  static const thumbnailSmall = Symbols.photo_size_select_small;

  // actions
  static const add = Symbols.add_circle;
  static const addShortcut = Symbols.add_to_home_screen;
  static const cancel = Symbols.cancel;
  static const cast = Symbols.cast;
  static const clear = Symbols.clear;
  static const clipboard = Symbols.content_copy;
  static const convert = Symbols.transform;
  static final convertToStillImage = MdiIcons.movieRemoveOutline;
  static const copy = Symbols.file_copy;
  static const debug = Symbols.mode_heat;
  static const delete = Symbols.delete;
  static const edit = Symbols.edit;
  static const emptyBin = Symbols.delete_sweep;
  static const export = Symbols.open_with;
  static final fileExport = MdiIcons.fileExportOutline;
  static final fileImport = MdiIcons.fileImportOutline;
  static const flip = Symbols.flip;
  static const favourite = Symbols.favorite;
  static const filter = Symbols.filter_alt;
  static const filterOff = Symbols.filter_alt_off;
  static const goUp = Symbols.arrow_upward;
  static const group = Symbols.stack_group;
  static const hide = Symbols.visibility_off;
  static const info = Symbols.info;
  static const layers = Symbols.layers;
  static const map = Symbols.map;
  static const more = Symbols.more_horiz;
  static final move = MdiIcons.fileMoveOutline;
  static const rename = Symbols.match_word;
  static const openOutside = Symbols.open_in_new;
  static final openVideoPart = MdiIcons.moviePlayOutline;
  static const pin = Symbols.keep;
  static const unpin = Symbols.keep_off;
  static const print = Symbols.print;
  static const refresh = Symbols.refresh;
  static const remove = Symbols.remove;
  static final resetBounds = MdiIcons.rayStartEnd;
  static const reverse = Symbols.invert_colors;
  static const reset = Symbols.restart_alt;
  static const restore = Symbols.restore;
  static const rotateLeft = Symbols.rotate_left;
  static const rotateRight = Symbols.rotate_right;
  static const rotateScreen = Symbols.screen_rotation;
  static const search = Symbols.search;
  static const select = Symbols.select_all;
  static const setAs = Symbols.wallpaper;
  static final setBoundEnd = MdiIcons.rayEnd;
  static final setBoundStart = MdiIcons.rayStart;
  static final setCover = MdiIcons.imageEditOutline;
  static const share = Symbols.share;
  static const show = Symbols.visibility;
  static const showFullscreenArrows = Symbols.open_in_full;
  static const showFullscreenCorners = Symbols.fullscreen;
  static const slideshow = Symbols.slideshow;
  static const split = Symbols.call_split;
  static const stats = Symbols.donut_small;
  static const vaultLock = Symbols.lock;
  static const vaultAdd = Symbols.enhanced_encryption;
  static final vaultConfigure = MdiIcons.shieldLockOutline;
  static const view = Symbols.grid_view;
  static const viewerLock = Symbols.lock;
  static const viewerUnlock = Symbols.lock_open;
  static const zoomIn = Symbols.add;
  static const zoomOut = Symbols.remove;
  static const collapse = Symbols.expand_less;
  static const expand = Symbols.expand_more;
  static const up = Symbols.keyboard_arrow_up;
  static const down = Symbols.keyboard_arrow_down;
  static const previous = Symbols.chevron_left;
  static const next = Symbols.chevron_right;

  // video actions
  // `play` and `pause` icon should be consistent with `AnimatedIcons.play_pause`
  static const play = Symbols.play_arrow;
  static const pause = Symbols.pause;
  static const previousFrame = Symbols.skip_previous;
  static const nextFrame = Symbols.skip_next;
  static const replay10 = Symbols.replay_10;
  static const skip10 = Symbols.forward_10;
  static const mute = Symbols.volume_off;
  static const unmute = Symbols.volume_up;
  static const captureFrame = Symbols.screenshot;
  static const repeat = Symbols.repeat;
  static final repeatOff = MdiIcons.repeatOff;
  static const selectStreams = Symbols.translate;
  static const setSpeed = Symbols.speed;
  static const videoSettings = Symbols.video_settings;

  // editor
  static const transform = Symbols.crop_rotate;
  static const aspectRatioFree = Symbols.crop_free;
  static const aspectRatioOriginal = Symbols.crop_original;
  static const aspectRatioSquare = Symbols.crop_square;
  static const aspectRatio_16_9 = Symbols.crop_16_9;
  static const aspectRatio_4_3 = Symbols.crop_landscape;

  // albums
  static const album = Symbols.photo_album;
  static const dynamicAlbum = Symbols.image_search;
  static const cameraAlbum = Symbols.photo_camera;
  static const downloadAlbum = Symbols.file_download;
  static const screenshotAlbum = Symbols.screenshot;
  static const recordingAlbum = Symbols.smartphone;
  static const locked = Symbols.lock;
  static const unlocked = Symbols.lock_open;

  // thumbnail overlay
  static const animated = Symbols.animated_images;
  static const geo = Symbols.language;
  static const hdr = Symbols.hdr_on;
  static const motionPhoto = Symbols.motion_photos_on;
  static const multiPage = Symbols.burst_mode;
  static const panorama = Symbols.vrpano;
  static const sphericalVideo = Symbols.threesixty;
  static const videoPlay = Symbols.play_circle;
  static const selected = Symbols.check_circle;
  static const unselected = Symbols.radio_button_unchecked;

  // Material Icons references to make constant instances of `IconData`
  // as non-constant instances of `IconData` prevent icon font tree shaking
  static const labelImportantOutlineCodePoint = 0xe362;
  static const materialIconsFontFamily = 'MaterialIcons';
}
