# Changelog
All notable changes to this project will be documented in this file.

## [Unreleased]

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
Collection: identify multipage TIFF & multitrack HEIC/HEIF
Viewer: support for multipage TIFF
Viewer: support for cropped panoramas
Albums: grouping options

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