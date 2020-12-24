# Changelog
All notable changes to this project will be documented in this file.

## [Unreleased]
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
- check free space before moving entries
- SVG source viewer

### Changed
- Navigation: changed page history handling
- Info: improved layout, especially for XMP
- About: improved layout
- faster locating of new entries

## [v1.2.7] - 2020-11-15
### Added
- Support for TIFF images (single page)
- Viewer overlay: minimap (optional)

### Changed
- Upgraded Flutter to stable v1.22.4
- Viewer: use subsampling and tiling to display large images

### Fixed
- Fixed finding dimensions of entries with incorrect EXIF

## [v1.2.6] - 2020-11-15 [YANKED]

## [v1.2.5] - 2020-11-01
### Added
- Search: show recently used filters (optional)
- Search: show filter for entries with no XMP tags
- Search: show filter for entries with no location information
- Analytics: use Firebase Analytics (along Firebase Crashlytics)

### Changed
- Upgraded Flutter to stable v1.22.3
- Viewer overlay: showing shooting details is now optional

### Fixed
- Viewer: leave when the loaded entry is deleted and it is the last one
- Viewer: refresh the viewer overlay and info page when the loaded image is modified
- Info: prevent reporting a "Media" section for images other than HEIC/HEIF
- Fixed opening entries shared via a "file" media content URI

### Removed
- Dependencies: removed Guava as a direct dependency in Android

## [v1.2.4] - 2020-11-01 [YANKED]

## [v1.2.3] - 2020-10-22
...