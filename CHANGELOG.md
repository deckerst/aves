# Changelog

All notable changes to this project will be documented in this file.

## <a id="unreleased"></a>[Unreleased]

## <a id="v1.6.4"></a>[v1.6.4] - 2022-04-19

### Added

- Albums / Countries / Tags: allow custom app / color along cover item
- Info: improved GeoTIFF section
- Cataloguing: locating from GeoTIFF metadata (requires rescan, limited to some projections)
- Info: action to overlay GeoTIFF on map (limited to some projections)
- Info: action to convert motion photo to still image
- Italian translation (thanks glemco)
- Chinese (Simplified) translation (thanks 小默 & Aerowolf)

### Changed

- upgraded Flutter to stable v2.10.4
- snack bars are dismissible with an horizontal swipe instead of a down swipe
- Viewer: snack bars avoid quick actions and thumbnails at the bottom

### Fixed

- black screen launch when Firebase fails to initialize (Play version only)
- crash when cataloguing JPEG with large extended XMP

## <a id="v1.6.3"></a>[v1.6.3] - 2022-03-28

### Added

- Theme: light/dark/black and color highlights settings
- Collection: bulk renaming
- Video: speed and muted state indicators
- Info: option to set date from other item
- Info: improved DNG tags display
- warn and optionally set metadata date before moving undated items
- Settings: display refresh rate hint

### Changed

- Viewer: quick action defaults
- cataloguing includes date sub-second data if present (requires rescan)

### Removed

- metadata editing support for DNG

### Fixed

- app launch despite faulty storage volumes on Android 11+

## <a id="v1.6.2"></a>[v1.6.2] - 2022-03-07

### Added

- Viewer: optional thumbnail preview
- Video: optional gestures to play/seek
- Video: mute action
- Japanese translation (thanks Maki)

### Changed

- Viewer: overlay reorganization
- upgraded Flutter to stable v2.10.3

### Fixed

- storage write access for Android <11
- various bin related fixes
- Viewer: apply video settings change without leaving the viewer

## <a id="v1.6.1"></a>[v1.6.1] - 2022-02-23

### Added

- optional recycle bin to keep deleted items for 30 days
- Viewer: actions to copy/move to album
- Indonesian translation (thanks MeFinity)

### Changed

- Viewer: action menu reorganization
- Viewer: `Export` action renamed to `Convert`
- Viewer: actual size zoom level respects device pixel ratio
- Viewer: allow zooming out small items to actual size
- Collection: improved performance for sort/group by name
- load previous top items on startup
- locale independent colors for known filters
- upgraded Flutter to stable v2.10.2

### Removed

- Map: connectivity check

### Fixed

- navigating from Album page when picking an item for another app

## <a id="v1.6.0"></a>[v1.6.0] - 2022-02-22 [YANKED]

## <a id="v1.5.11"></a>[v1.5.11] - 2022-01-30

### Added

- Collection / Info: edit location of JPG/PNG/WEBP/DNG images via Exif
- Viewer: resize option when exporting
- Settings: export/import covers & favourites along with settings
- Collection: allow rescan when browsing
- support Android 12L (API 32)
- Portuguese translation (thanks Jonatas De Almeida Barros)

### Removed

- new version check

### Fixed

- loading when system locale uses non-western arabic numerals
- handling timestamps provided in 10^-8 s (18 digits)
- Viewer: SVG export
- Viewer: sending to editing app on some environments
- Map: projected center anchoring

## <a id="v1.5.10"></a>[v1.5.10] - 2022-01-07

### Added

- Collection: toggle favourites in bulk
- Info: edit ratings of JPG/GIF/PNG/TIFF images via XMP
- Info: edit date of GIF images via XMP
- Info: option to set date from other fields
- Spanish translation (thanks n-berenice)

### Changed

- editing an item orientation, rating or tags automatically sets a metadata date (from the file
  modified date), if it is missing
- Viewer: when opening an item from another app, it is now possible to scroll to other items in the
  album

### Fixed

- Exif and IPTC raw profile extraction from PNG in some cases

## <a id="v1.5.9"></a>[v1.5.9] - 2021-12-22

### Added

- Collection / Albums / Countries / Tags: list view (scalable like the grid view)
- moving, editing or deleting multiple items can be cancelled
- Viewer: option to auto play motion photos (after a small delay to show first the high-res photo)
- German translation (thanks JanWaldhorn)

### Changed

- upgraded Flutter to stable v2.8.1

### Fixed

- Collection: more consistent scroll bar thumb position to match the viewport
- Settings: fixed file selection to import settings on older devices
- Viewer: UI mode switch for Android <10

## <a id="v1.5.8"></a>[v1.5.8] - 2021-12-22 [YANKED]

## <a id="v1.5.7"></a>[v1.5.7] - 2021-12-01

### Added

- add and remove tags to JPEG/GIF/PNG/TIFF images
- French translation
- support for Android KitKat (without Google Maps)
- Viewer: maximum brightness option

### Changed

- Settings: select hidden path directory with a custom file picker instead of the native SAF one
- Viewer: video cover (before playing the video) is now loaded at original resolution and can be
  zoomed

### Fixed

- pinch-to-zoom gesture on thumbnails was difficult to trigger
- double-tap gesture in the viewer was ignored in some cases
- copied items had the wrong date

## <a id="v1.5.6"></a>[v1.5.6] - 2021-11-12

### Added

- Viewer: action to add shortcut to media item

### Changed

- Albums / Countries / Tags: use a 3 column layout by default

### Fixed

- video playback was not using hardware-accelerated codecs on recent devices
- partial fix to deleting/moving file in a clean way on some devices

## [v1.5.5] - 2021-11-08

### Added

- Russian translation (thanks D3ZOXY)
- Info: set date from title
- Collection: bulk editing (rotation, date setting, metadata removal)
- Collection: custom quick actions for item browsing
- Collection: live title filter
- About: link to privacy policy
- Video: quick action to play video in other app
- Video: resume playback

### Changed

- use build flavors to match distribution channels: `play` (same as original) and `izzy` (no
  Crashlytics)
- use 12/24 hour format settings from device to display times
- Privacy: consent request on first launch for installed app inventory access
- use File API to rename and delete items, when possible (primary storage, Android <11)
- Video: changed video thumbnail strategy

## [v1.5.4] - 2021-10-21

### Added

- Collection: use a foreground service when scanning many items
- Collection: ask to rename/replace/skip when moving items with name conflict
- Map: filter to view items from a specific region in the Collection page
- Viewer: option to show/hide overlay on opening
- Info: improved display for PNG text metadata, XMP and others
- Export: output format selection
- Search: added raw filter
- Support modifying files in the Download folder on Android 11+

### Changed

- upgraded Flutter to stable v2.5.3
- use build flavors to generate universal or split APKs

### Fixed

- hide root album of hidden path
- gesture & spacing handling for Android 10+ navigation gestures
- renaming was leaving behind obsolete items in some cases
- speeding up videos on Xiaomi devices

## [v1.5.3] - 2021-09-30

### Added

- Map: show items for bounds, open items in viewer, tap gesture to toggle fullscreen
- Info: remove metadata (Exif, XMP, etc.)
- Accessibility: support "time to take action" and "remove animations" settings

### Changed

- upgraded Flutter to stable v2.5.1
- faster collection loading when launching the app
- Collection: changed color & scale of thumbnail icons to match text
- Albums / Countries / Tags: changed layout, with label below cover

### Fixed

- album bookmarks & pins were reset when rescanning items

## [v1.5.2] - 2021-09-29 [YANKED]

## [v1.5.1] - 2021-09-08

### Added

- About: bug reporting instructions

### Changed

- Collection: improved video date detection

### Fixed

- fixed hanging app when loading thumbnails for some video formats on some devices

## [v1.5.0] - 2021-09-02

### Added

- Info: edit Exif dates (setting, shifting, deleting)
- Collection: custom quick actions for item selection
- Collection: video date detection for more formats

### Changed

- faster collection loading when launching the app

### Fixed

- app launching on some devices
- corrupting motion photo exif editing (e.g. rotation)

## [v1.4.9] - 2021-08-20

### Added

- Map & Stats from selection
- Map: item browsing, rotation control
- Navigation menu customization
- shortcut support on older devices (API < 26)
- support Android 12/S (API 31)

## [v1.4.8] - 2021-08-08

### Added

- Map
- Viewer: action to copy to clipboard
- integration with Android global search (Samsung Finder etc.)

### Fixed

- auto album identification and naming
- opening HEIC images from downloads content URI on Android R+

## [v1.4.7] - 2021-08-06 [YANKED]

## [v1.4.6] - 2021-07-22

### Added

- Albums / Countries / Tags: multiple selection
- Albums: action to create empty albums
- Collection: burst shot grouping (Samsung naming pattern)
- Collection: support motion photos defined by XMP Container namespace
- Settings: hidden paths to exclude folders and their subfolders
- Settings: option to disable viewer overlay blur effect (for older/slower devices)
- Settings: option to exclude cutout area in viewer

### Changed

- Video: restored overlay hiding when pressing play button

### Fixed

- Viewer: fixed manual screen rotation to follow sensor

## [v1.4.5] - 2021-07-08

### Added

- Video: added OGV/Theora/Vorbis support
- Viewer: action to rotate screen when device has locked rotation
- Settings: import/export

### Changed

- improved SVG support with a different rendering engine
- changed logo
- upgraded Flutter to stable v2.2.3
- migrated to sound null safety
- viewer: parallax effect when scrolling

### Removed

- Analytics: removed Firebase Analytics (kept Firebase Crashlytics)

## [v1.4.4] - 2021-06-25

### Added

- Video: speed control, track selection, frame capture
- Video: embedded subtitle support
- Settings: custom video quick actions
- Settings: subtitle theme

### Changed

- upgraded Flutter to stable v2.2.2

### Fixed

- fixed opening SVGs from other apps
- stop video playback when leaving the app in some cases
- fixed crash when ACCESS_MEDIA_LOCATION permission is revoked

## [v1.4.3] - 2021-06-12

### Added

- Collection: snack bar action to show moved/copied/exported entries
- Collection / Albums / Countries / Tags: when switching device orientation, keep items in view
- Collection: when leaving entry from Viewer, make entry visible in collection
- Viewer: fixed layout & minimap for videos with non-square pixels

### Changed

- upgraded Flutter to stable v2.2.1
- migrated to unsound null safety
- Collection / Viewer: improved performance, memory usage
- Collection: thumbnail layout change

### Removed

- no support for Android KitKat (API 19), unsupported by Google Maps package

### Fixed

- fixed opening files shared via content URI with incorrect MIME type
- refresh collection when entries modified in Viewer no longer match collection filters

## [v1.4.2] - 2021-06-10 [YANKED]

## [v1.4.1] - 2021-04-29

### Added

- Motion photo support
- Viewer: play videos in multi-track HEIC
- Handle share intent

### Changed

- Upgraded Flutter to beta v2.2.0-10.1.pre

### Fixed

- fixed crash when cataloguing large MP4/PSD
- prevent videos playing in the background when quickly switching entries

## [v1.4.0] - 2021-04-16

### Added

- Viewer: support for videos with EAC3/FLAC/OPUS audio
- Info: more consistent and comprehensive info for videos and streams
- Settings: more video options (auto play, loop, hardware acceleration)

### Changed

- Info: present video cover like XMP embedded images

### Removed

- locale name package (-3 MB)

### Fixed

- Albums: auto naming for folders on SD card
- Viewer: display of videos with unusual SAR

## [v1.3.7] - 2021-04-02

### Added

- Collection / Albums / Countries / Tags: added label when dragging scrollbar thumb
- Albums: localized common album names
- Collection: select shortcut icon image
- Settings: custom viewer quick actions
- Settings: option to hide videos from collection

### Changed

- Upgraded Flutter to beta v2.1.0-12.2.pre

### Fixed

- opening media shared by other apps as file media content
- navigation stack when opening media shared by other apps

## [v1.3.6] - 2021-03-18

### Added

- Korean translation
- cover selection for albums / countries / tags

### Changed

- Upgraded Flutter to dev v2.1.0-12.1.pre

### Fixed

- various TIFF decoding fixes

## [v1.3.5] - 2021-02-26

### Added

- support Android KitKat, Lollipop & Marshmallow (API 19 ~ 23)
- quick country reverse geocoding without Play Services
- menu option to hide any filter
- menu option to navigate to the album / country / tag page from filter

### Changed

- analytics are opt-in

### Removed

- removed custom font used in titles and info page

## [v1.3.4] - 2021-02-10

### Added

- hide album / country / tag from collection
- new version check

### Changed

- Viewer: improved multipage item overlay and thumbnail loading
- deactivate geocoding and Google maps when Play Services are unavailable

### Fixed

- refreshing items externally added/moved/removed
- loading items at the root of volumes
- loading items when opening a shortcut with a location filter
- various thumbnail hero animation fixes

## [v1.3.3] - 2021-01-31

### Added

- Viewer: support for multi-track HEIF
- Viewer: export image (including multipage TIFF/HEIF and images embedded in XMP)
- Info: show owner app (Android Q and up)
- listen to Media Store changes

### Changed

- upgraded Flutter to stable v1.22.6
- check connectivity before using features that need it

### Fixed

- checkerboard background performance
- deleting files that no longer exist but are still registered in the Media Store
- insets handling on Android 11

## [v1.3.2] - 2021-01-17

### Added

Collection: identify multipage TIFF & multitrack HEIC/HEIF Viewer: support for multipage TIFF
Viewer: support for cropped panoramas Albums: grouping options

### Changed

upgraded libtiff to 4.2.0 for TIFF decoding

### Fixed

- prevent scrolling when using Android Q style gesture navigation

## [v1.3.1] - 2021-01-04

### Added

- Collection: long press and move to select/deselect multiple items
- Info: show Spherical Video V1 metadata
- Info: metadata search

### Fixed

- Viewer: fixed panning inertia following double-tap scaling
- Collection: fixed crash when loading TIFF files on Android 11

## [v1.3.0] - 2020-12-26

### Added

- Viewer: quick scale (aka one finger zoom)
- Viewer: optional checkered background for transparent images

### Changed

- Viewer: changed panning inertia

### Fixed

- Viewer: fixed scaling focus when zooming by double-tap or pinch
- Viewer: fixed panning during scaling

## [v1.2.9] - 2020-12-12

### Added

- Collection: identify 360 photos/videos, GeoTIFF
- Viewer: open panoramas (360 photos)
- Info: open GImage/GAudio/GDepth media and thumbnails embedded in XMP
- Info: SVG metadata

### Changed

- Upgraded Flutter to stable v1.22.5
- Viewer: TIFF subsampling & tiling
- Info: improved XMP layout

### Fixed

- Fixed large TIFF handling

## [v1.2.8] - 2020-11-27

### Added

- Albums / Countries / Tags: pinch to change tile size
- Album picker: added a field to filter by name
- check free space before moving items
- SVG source viewer

### Changed

- Navigation: changed page history handling
- Info: improved layout, especially for XMP
- About: improved layout
- faster locating of new items

## [v1.2.7] - 2020-11-15

### Added

- Support for TIFF images (single page)
- Viewer overlay: minimap (optional)

### Changed

- Upgraded Flutter to stable v1.22.4
- Viewer: use subsampling and tiling to display large images

### Fixed

- Fixed finding dimensions of items with incorrect EXIF

## [v1.2.6] - 2020-11-15 [YANKED]

## [v1.2.5] - 2020-11-01

### Added

- Search: show recently used filters (optional)
- Search: show filter for items with no XMP tags
- Search: show filter for items with no location information
- Analytics: use Firebase Analytics (along Firebase Crashlytics)

### Changed

- Upgraded Flutter to stable v1.22.3
- Viewer overlay: showing shooting details is now optional

### Fixed

- Viewer: leave when the loaded item is deleted and it is the last one
- Viewer: refresh the viewer overlay and info page when the loaded image is modified
- Info: prevent reporting a "Media" section for images other than HEIC/HEIF
- Fixed opening items shared via a "file" media content URI

### Removed

- Dependencies: removed Guava as a direct dependency in Android

## [v1.2.4] - 2020-11-01 [YANKED]

## [v1.2.3] - 2020-10-22

...
