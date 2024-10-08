# Changelog

All notable changes to this project will be documented in this file.

## <a id="unreleased"></a>[Unreleased]

## <a id="v1.11.15"></a>[v1.11.15] - 2024-10-09

### Changed

- Enterprise: do not request `INTERACT_ACROSS_PROFILES` permission (Play Store compatibility)

## <a id="v1.11.14"></a>[v1.11.14] - 2024-10-09

### Added

- Map: OpenTopoMap raster layer
- Map: OSM Liberty vector layer (hosted by OSM Americana)
- Interoperability: receiving `geo:` URI generally opens map page at location
- Interoperability: receiving `geo:` URI when editing item location fills in coordinates
- Map basic app shortcut
- Enterprise: support for work profile switching from the drawer
- Settings: hidden path filters are merged with others and can be toggled

### Removed

- `Safe mode` basic app shortcut

### Fixed

- hanging when cataloguing some JPEG MPF images
- Apple HDR image detection

## <a id="v1.11.13"></a>[v1.11.13] - 2024-09-17

### Added

- support opening from the lock screen

### Changed

- upgraded Flutter to stable v3.24.3

### Fixed

- crash when cataloguing some malformed MP4 files
- inconsistent launch screen

## <a id="v1.11.12"></a>[v1.11.12] - 2024-09-16 [YANKED AGAIN!]

## <a id="v1.11.11"></a>[v1.11.11] - 2024-09-16 [YANKED]

## <a id="v1.11.10"></a>[v1.11.10] - 2024-09-01

### Added

- Swedish translation (thanks Shift18, Andreas Håll)

### Changed

- request notification permission when launching scanning service
- upgraded Flutter to stable v3.24.1

### Fixed

- duplicates from new item loading/refreshing

## <a id="v1.11.9"></a>[v1.11.9] - 2024-08-07

### Added

- Viewer: display more items in tag/copy/move quick action choosers
- Viewer: long descriptions are scrollable when overlay is expanded by tap
- Collection: sort by duration
- Map: open external map app from map views
- Explorer: stats

### Changed

- Accessibility: more animations and effects are suppressed when animations are disabled
- upgraded Flutter to stable v3.24.0

### Fixed

- opening app from launcher always showing home page
- collection quick actions not showing in the top bar nor the menu
- multiple widget setup after device reboot

## <a id="v1.11.8"></a>[v1.11.8] - 2024-07-19

### Added

- Explorer: set custom path as home
- Explorer: create shortcut to custom path

### Changed

- target Android 15 (API 35)
- upgraded Flutter to stable v3.22.3

### Fixed

- crash when cataloguing some PNG files

## <a id="v1.11.7"></a>[v1.11.7] - 2024-07-18 [YANKED AGAIN!]

## <a id="v1.11.6"></a>[v1.11.6] - 2024-07-17 [YANKED]

## <a id="v1.11.5"></a>[v1.11.5] - 2024-07-11

### Added

- Collection: stack RAW and JPEG with same file names
- Collection: ask to rename/replace/skip when converting items with name conflict
- Export: bulk converting motion photos to still images
- Explorer: view folder tree and filter paths

### Fixed

- switching to PiP when changing device orientation on Android >=13
- handling wallpaper intent without URI
- sizing widgets with some launchers on Android >=12

### Removed

- `huawei` app flavor

## <a id="v1.11.4"></a>[v1.11.4] - 2024-07-09 [YANKED]

## <a id="v1.11.3"></a>[v1.11.3] - 2024-06-17

### Added

- handle `MediaStore.ACTION_REVIEW` intent

## <a id="v1.11.2"></a>[v1.11.2] - 2024-06-11

### Added

- Albums / Countries / Tags: show selection in Collection
- allow shifting dates by seconds

### Changed

- opening app from launcher shows home page only when exited by back button
- Screen saver: black background, consistent with slideshow
- upgraded Flutter to stable v3.22.2

### Removed

- support for Android KitKat (API 19)

### Fixed

- crash when cataloguing large images

## <a id="v1.11.1"></a>[v1.11.1] - 2024-05-03

### Added

- Cataloguing: identify Apple variant of HDR images
- Collection: `select all` available as quick action
- Collection: allow using hash (md5/sha1/sha256) when bulk renaming
- Info: color palette
- Video: external subtitle support (SRT)
- option to force using western arabic numerals for dates
- Persian translation (thanks امیر جهانگرد, slasb37, mimvahedi, Alireza Rashidi)

### Changed

- logo
- upgraded Flutter to stable v3.19.6

### Fixed

- rendering of SVG with large header
- stopping video playback when changing device orientation on Android >=13
- printing content orientation according to page format

## <a id="v1.11.0"></a>[v1.11.0] - 2024-05-01 [YANKED]

## <a id="v1.10.9"></a>[v1.10.9] - 2024-04-14

### Fixed

- rendering of SVG with viewbox offset
- superfluous media store reinitialization when relaunching app from launcher

## <a id="v1.10.8"></a>[v1.10.8] - 2024-04-01

### Added

- Collection: support for Fairphone burst pattern
- Collection: allow using tags/make/model when bulk renaming
- Video: A-B repeat
- Settings: hidden items can be toggled

### Changed

- opening app from launcher always show home page
- use dates with western arabic numerals for maghreb arabic locales
- album unique names are case insensitive
- upgraded Flutter to stable v3.19.5

### Fixed

- crash when decoding large region
- viewer position drift during scale
- viewer side gesture precedence (next entry by single tap vs zoom by double tap)

## <a id="v1.10.7"></a>[v1.10.7] - 2024-03-12

### Added

- Cataloguing: detect/filter HDR videos

### Changed

- check Media Store changes when resuming app
- disabling animations also applies to pop up menus
- upgraded Flutter to stable v3.19.3

### Fixed

- engine leak from analysis worker

## <a id="v1.10.6"></a>[v1.10.6] - 2024-03-11 [YANKED]

## <a id="v1.10.5"></a>[v1.10.5] - 2024-02-22

### Added

- Viewer: prompt to show newly edited item
- Widget: outline color options according to device theme
- Catalan translation (thanks Marc Amorós)

### Changed

- upgraded Flutter to stable v3.19.1

### Fixed

- untracked binned items recovery
- untracked vault items recovery

## <a id="v1.10.4"></a>[v1.10.4] - 2024-02-07

### Fixed

- motion photo detection for xml variant of google container item
- HEIF size detection for some corrupted files
- viewer transition direction & effects for RTL locales

## <a id="v1.10.3"></a>[v1.10.3] - 2024-01-29

### Added

- Viewer: optional histogram (for real this time)
- Collection: allow hiding thumbnail overlay HDR icon
- Collection: allow setting any filtered collection as home page

### Changed

- Viewer: lift format control for tiling, allowing large DNG tiling if supported
- Info: strip `unlocated` filter from context collection when editing location via map
- Slideshow: keep playing when losing focus but app is still visible (e.g. split screen)
- upgraded Flutter to stable v3.16.9

### Fixed

- crash when loading some large DNG in viewer
- searching from drawer on mobile
- resizing TIFF during conversion

## <a id="v1.10.2"></a>[v1.10.2] - 2023-12-24

### Changed

- Viewer: keep controls in the lower right corner even with RTL locales

### Fixed

- crash when loading SVG defined with large dimensions

## <a id="v1.10.1"></a>[v1.10.1] - 2023-12-21

### Added

- Cataloguing: detect/filter `Ultra HDR`
- Viewer: show JPEG MPF dependent images (except thumbnails and HDR gain maps)
- Info: show metadata from JPEG MPF
- Info: open images embedded via JPEG MPF
- Arabic translation (thanks Mohamed Zeroug)
- Belarusian translation (thanks Макар Разин)

### Changed

- upgraded Flutter to stable v3.16.5

## <a id="v1.10.0"></a>[v1.10.0] - 2023-12-02

### Added

- Viewer / Slideshow: cast images via DLNA/UPnP
- Icelandic translation (thanks Sveinn í Felli)

### Changed

- long press actions trigger haptic feedback according to OS settings
- target Android 14 (API 34)
- upgraded Flutter to stable v3.16.2

### Fixed

- temporary files remaining in the cache directory forever
- detecting motion photos with more items in the XMP Container directory
- parsing EXIF date written as epoch time

## <a id="v1.9.7"></a>[v1.9.7] - 2023-10-17

### Added

- Slovak translation (thanks Martin Frandel, Milan Šalka)
- Vietnamese translation (thanks ngocanhtve, Le Nhut Binh)

### Changed

- mosaic layout: clamp ratio to 32/9
- Video: disable subtitles by default
- Map: Stamen Watercolor layer (no longer hosted for free by Stamen) now hosted by Smithsonian Institution
- upgraded Flutter to stable v3.13.7

### Removed

- Map: Stamen Toner layer (no longer hosted for free by Stamen)

### Fixed

- crash when playing video on devices with hardened malloc

## <a id="v1.9.6"></a>[v1.9.6] - 2023-09-25

### Fixed

- editing some image EXIF corrupting them (by failing instead)

## <a id="v1.9.5"></a>[v1.9.5] - 2023-09-17

### Fixed

- crash when cataloguing some videos
- workflow when moving to an album with insufficient storage

## <a id="v1.9.4"></a>[v1.9.4] - 2023-09-13

### Changed

- upgraded Flutter to stable v3.13.4

### Fixed

- CVE-2023-4863 - Security vulnerability in WebP

## <a id="v1.9.3"></a>[v1.9.3] - 2023-08-28

### Changed

- target API 33 to prevent foreground service crashes with Android 14 beta 5

## <a id="v1.9.2"></a>[v1.9.2] - 2023-08-24

### Changed

- upgraded Flutter to stable v3.13.1
- building without FFmpeg `neon` libs
- building with gradle toolchain resolver plugin

## <a id="v1.9.1"></a>[v1.9.1] - 2023-08-22

### Fixed

- editing some WEBP corrupting them (by failing instead)

## <a id="v1.9.0"></a>[v1.9.0] - 2023-08-21

### Added

- Video: improved seek accuracy, HDR support, AV1 support, playback speed from x0.25 to x4
- support for animated AVIF (requires rescan)
- Collection: filtering by rating range
- Viewer: optionally show histogram on overlay
- Viewer: external export actions available as quick actions
- About: data usage

### Changed

- Accessibility: removing animations also removes the overscroll stretch effect
- target Android 14 (API 34)
- upgraded Flutter to stable v3.13.0

### Fixed

- flickering when starting videos
- editing fragmented MP4 corrupting them (by failing instead)

## <a id="v1.8.9"></a>[v1.8.9] - 2023-06-04

### Changed

- upgraded Flutter to stable v3.10.3

### Fixed

- duplicates when converting many items

## <a id="v1.8.8"></a>[v1.8.8] - 2023-05-28

### Added

- option to set the Tags page as home
- support for animated PNG (requires rescan)
- Info: added day filter with item date
- Widget: option to update image on tap
- Slideshow / Screen saver: option for random transition
- Norwegian (Nynorsk) translation (thanks tryvseu)

### Changed

- keep showing empty albums if are pinned
- remember whether to show the title filter when picking albums
- upgraded Flutter to stable v3.10.2

### Fixed

- crash when cataloguing PSD with large XMP
- crash when cataloguing large HEIF

## <a id="v1.8.7"></a>[v1.8.7] - 2023-05-26 [YANKED]

## <a id="v1.8.6"></a>[v1.8.6] - 2023-04-30

### Added

- Collection: support for Sony predictive capture as burst
- Video: option to never/always resume playback
- Display: option to set maximum brightness on all pages
- Export: set quality when converting to JPEG/WEBP
- Hungarian translation (thanks György Viktor, byPety)

### Changed

- Info: editing tags now requires explicitly tapping the save button
- upgraded Flutter to stable v3.7.12

### Fixed

- Video: switching to PiP when going home with gesture navigation
- Viewer: swiping gestures not being handled in some cases
- Viewer: multi-page context update when removing burst entries
- Info: editing tags with placeholders
- prevent editing item when Exif editing changes mime type
- parsing videos with skippable boxes in `meta` box

## <a id="v1.8.5"></a>[v1.8.5] - 2023-04-18

### Added

- Collection: optional support for Samsung and Sony burst patterns
- Video: action to lock viewer
- Info: improved state/place display (requires rescan, limited to AU/GB/IN/US)
- Info: edit tags with state placeholder
- Info: show metadata from MP4 user data box
- Countries: show states for selected countries
- Tags: delete selected tags from all media in collection
- improved support for system font scale

### Changed

- upgraded Flutter to stable v3.7.11
- when an album becomes empty, the folder will be deleted only if it is a non-app/common album
- TV: section header focus/highlight

### Fixed

- permission confusion when removable volume changes
- Viewer: flickering on first scale animation in some cases

## <a id="v1.8.4"></a>[v1.8.4] - 2023-03-17

### Added

- TV: improved support for Licenses

### Fixed

- Viewer: playing video from app content provider
- Search: using the query bar yields a black screen

## <a id="v1.8.3"></a>[v1.8.3] - 2023-03-13

### Added

- Collection: preview button when selecting items
- Collection: item size in list layout
- Vaults: custom pattern lock
- Video: picture-in-picture
- Video: handle skip next/previous media buttons
- TV: more media controls

### Changed

- scroll to show item when navigating from Info page
- upgraded Flutter to stable v3.7.7

### Fixed

- Accessibility: using accessibility services keeping snack bar beyond countdown
- Accessibility: navigation with TalkBack
- Vaults: crash when using fingerprint on older Android versions
- Vaults: sharing multiple items

## <a id="v1.8.2"></a>[v1.8.2] - 2023-02-28

### Added

- Export: bulk converting
- Export: write metadata when converting
- Places: page & navigation entry

### Changed

- rating/tagging action icons
- upgraded Flutter to stable v3.7.5

### Fixed

- viewer pan/scale gestures interpreted as fling gestures
- replacing when moving item to vault
- exporting item to vault

## <a id="v1.8.1"></a>[v1.8.1] - 2023-02-21

### Added

- Vaults
- Viewer: overlay details expand/collapse on tap
- Viewer: export actions available as quick actions
- Slideshow: added settings quick action
- TV: improved support for Info
- Basque translation (thanks Aitor Salaberria)

### Changed

- disabling the recycle bin will delete forever items in it
- remember pin status of albums becoming empty
- allow setting dates before 1970/01/01
- upgraded Flutter to stable v3.7.3

### Fixed

- SD card access grant on Android Lollipop
- copying to SD card in some cases
- sharing SD card files referred by `file` URI

## <a id="v1.8.0"></a>[v1.8.0] - 2023-02-20 [YANKED]

## <a id="v1.7.10"></a>[v1.7.10] - 2023-01-18

### Added

- Video: optional gestures to adjust brightness/volume
- TV: improved support for Search, About, Privacy Policy

### Changed

- Viewer: do not keep max brightness when viewing info

### Fixed

- crash when media button events are triggered with no active media session

## <a id="v1.7.9"></a>[v1.7.9] - 2023-01-15

### Added

- Viewer: optionally show description on overlay
- Collection: unlocated/untagged overlay icons
- Video: stop when losing audio focus
- Video: stop when becoming noisy
- Info: Google camera portrait mode item extraction
- TV: handle overscan
- TV: improved support for Viewer, Info, Map, Stats
- TV: option to use TV layout on any device
- Czech translation (thanks vesp)
- Polish translation (thanks Piotr K, rehork)

### Changed

- editing description writes XMP `dc:description`, and clears Exif `ImageDescription`
  / `UserComment`
- in the tag editor, tapping on applied tag applies it to all items instead of removing it
- pin app bar when selecting items

### Fixed

- transition between collection and viewer when cutout area is not used
- saving video playback state when leaving viewer

## <a id="v1.7.8"></a>[v1.7.8] - 2022-12-20

### Added

- Android TV support
- Viewer: optionally show rating & tags on overlay
- Viewer: long press on copy/move/rating/tag quick action for quicker action
- Viewer: long press on share quick action to share parts of motion photo
- Search: missing address, portrait, landscape filters
- Map: edit cluster location
- Accessibility: optional alternative to pinch-to-zoom thumbnails
- Lithuanian translation (thanks Gediminas Murauskas)
- Norwegian (Bokmål) translation (thanks Allan Nordhøy)
- Chinese (Traditional) translation (thanks pemibe)
- Ukrainian translation (thanks Olexandr Mazur)

### Changed

- Viewer: allow setting default outside video player
- Map: fit to most recent items if all items cannot fit on screen
- upgraded Flutter to stable v3.3.10

## <a id="v1.7.7"></a>[v1.7.7] - 2022-11-27

### Added

- Romanian translation (thanks Ralea Adrian Vicențiu, Igor Sorocean)

### Changed

- build: changed version codes for `izzy`, `libre` flavors

## <a id="v1.7.6"></a>[v1.7.6] - 2022-11-26

### Changed

- build: use `flutter-wrapper`, bundle Flutter as submodule
- build: use split APKs for `libre` flavor

## <a id="v1.7.5"></a>[v1.7.5] - 2022-11-23

### Added

- Viewer: Info page editing actions available as quick actions
- Video: subtitle vertical position option
- Info: export metadata to text file
- Accessibility: apply bold font system setting
- Widget: option to show most recent item instead of random items
- `libre` app flavor (no mobile service maps, no Crashlytics)

### Changed

- Map: no default map style for `izzy` and `libre` flavors
- Viewer: allow setting default editor
- Viewer: keep manually un/muted state for following autoplayed videos
- upgraded Flutter to stable v3.3.9

### Fixed

- crash when cataloguing some MP4 files
- reading metadata for some MP4 files

## <a id="v1.7.4"></a>[v1.7.4] - 2022-11-11

### Added

- Info: edit MP4 metadata (date / location / title / description / rating / tags / rotation)
- Info: edit location by copying from other item
- Info: edit tags with dynamic placeholders for country / place
- Widget: option to open collection on tap
- optional MANAGE_MEDIA permission to modify media without asking

### Changed

- higher quality thumbnails
- upgraded Flutter to stable v3.3.8

### Fixed

- rendering of panoramas with inconsistent metadata
- failing scan of items copied to SD card on older devices
- unreplaceable covers set before v1.7.1
- inconsistent background height for multi-script subtitles
- launch crash on Android KitKat
- ExifInterface: producing invalid WebP files

## <a id="v1.7.3"></a>[v1.7.3] - 2022-11-11 [YANKED AGAIN!]

## <a id="v1.7.2"></a>[v1.7.2] - 2022-11-11 [YANKED]

## <a id="v1.7.1"></a>[v1.7.1] - 2022-10-09

### Added

- mosaic layout
- reverse filters to filter out/in
- Collection: selection edit actions available as quick actions
- Albums: group by content type
- Info: improved display for XMP
- Stats: top albums
- Stats: open full top listings
- Video: option for muted auto play
- Slideshow / Screen saver: option for no transition
- Slideshow / Screen saver: animated zoom effect
- Widget: tap action setting
- Wallpaper: scroll effect option

### Changed

- upgraded Flutter to stable v3.3.4

### Fixed

- restoring to missing Download subdir
- crash when cataloguing PNG with large chunks

## <a id="v1.7.0"></a>[v1.7.0] - 2022-09-19

### Added

- Collection: view settings allow changing the sort order (aka ascending/descending)
- Collection / Info: edit title via IPTC / XMP
- Albums / Countries / Tags: size displayed in list view details, sort by size
- Search: `undated` and `untitled` filters
- Greek translation (thanks Emmanouil Papavergis)

### Changed

- upgraded Flutter to stable v3.3.2

### Fixed

- opening viewer with directory context in some cases
- photo frame widget rendering in some cases
- exporting large images to BMP
- replacing entries during move/copy
- deleting binned item from the Download album

## <a id="v1.6.13"></a>[v1.6.13] - 2022-08-29

### Changed

- use natural order when sorting by name items, albums, tags

### Fixed

- adding duplicate items during loading in some cases
- screensaver stopping when device orientation changes

## <a id="v1.6.12"></a>[v1.6.12] - 2022-08-27

### Added

- Viewer: optional gesture to show previous/next item
- Albums / Countries / Tags: live title filter
- option to hide confirmation message after moving items to the bin
- Collection / Info: edit description via Exif / IPTC / XMP
- Info: read XMP from HEIF on Android >=11
- Collection: support HEIF motion photos on Android >=11
- Search: `recently added` filter
- Dutch translation (thanks Martijn Fabrie, Koen Koppens)

### Changed

- status and navigation bar transparency
- default snack bar timeout to 3s
- upgraded Flutter to beta v3.3.0-0.5.pre

### Fixed

- storage volume setup despite faulty volume on Android <11
- storage volume setup when launched right after device boot
- tiling PNG images
- widget image sizing in some cases

## <a id="v1.6.11"></a>[v1.6.11] - 2022-07-26

### Added

- Search: `on this day` and month filters in date filter section
- Stats: histogram and contextual date filters
- Screen saver
- Widget: photo frame

### Changed

- viewer: black background when overlay is disabled with light theme
- filter chip long press menu shows full label
- upgraded Flutter to beta v3.3.0-0.0.pre

### Fixed

- analysis service stuck when storage has ambiguous directories

## <a id="v1.6.10"></a>[v1.6.10] - 2022-07-24 [YANKED]

## <a id="v1.6.9"></a>[v1.6.9] - 2022-06-18

### Added

- slideshow
- set wallpaper from any media
- optional dynamic accent color on Android >=12
- Search: date/dimension/size field equality (undocumented)
- support Android 13 (API 33)
- Turkish translation (thanks metezd)

### Changed

- do not force quit on storage permission denial
- upgraded Flutter to stable v3.0.2

### Fixed

- merge ambiguously cased directories

## <a id="v1.6.8"></a>[v1.6.8] - 2022-05-27

### Fixed

- wrong window metrics on startup in some cases
- home albums not updated on startup in some cases
- crash when cataloguing large TIFF

## <a id="v1.6.7"></a>[v1.6.7] - 2022-05-25

### Added

- Bottom navigation bar
- Collection: thumbnail overlay tag icon
- Collection: fast-scrolling shows breadcrumbs from groups
- Settings: search
- Pick: allow selecting multiple items according to request intent
- `huawei` app flavor (Petal Maps, no Crashlytics)

### Changed

- upgraded Flutter to stable v3.0.1
- stretching overscroll effect
- disabled Google Maps layer on Android Lollipop

### Fixed

- grey Google Map layer when size changed
- Android scrolling screenshot support
- Voice Access scrolling support

## <a id="v1.6.6"></a>[v1.6.6] - 2022-05-25 [YANKED AGAIN!]

## <a id="v1.6.5"></a>[v1.6.5] - 2022-05-25 [YANKED]

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

- app launch despite faulty storage volumes on Android >=11

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
- Support modifying files in the Download folder on Android >=11

### Changed

- upgraded Flutter to stable v2.5.3
- use build flavors to generate universal or split APKs

### Fixed

- hide root album of hidden path
- gesture & spacing handling for Android >=10 navigation gestures
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
- accessing files in `Download` directory when not using reference case

## [v1.4.9] - 2021-08-20

### Added

- Map & Stats from selection
- Map: item browsing, rotation control
- Navigation menu customization
- shortcut support on older devices (API <26)
- support Android 12/S (API 31)

## [v1.4.8] - 2021-08-08

### Added

- Map
- Viewer: action to copy to clipboard
- integration with Android global search (Samsung Finder etc.)

### Fixed

- auto album identification and naming
- opening HEIF images from downloads content URI on Android >=11

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
- Viewer: play videos in multi-track HEIF
- Handle share intent

### Changed

- Upgraded Flutter to beta v2.2.0-10.1.pre

### Fixed

- crash when cataloguing large MP4/PSD
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
- Info: show owner app (Android >=10)
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

Collection: identify multipage TIFF & multitrack HEIF Viewer: support for multipage TIFF
Viewer: support for cropped panoramas Albums: grouping options

### Changed

upgraded libtiff to 4.2.0 for TIFF decoding

### Fixed

- prevent scrolling when using Android 10 style gesture navigation

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
- Info: prevent reporting a "Media" section for images other than HEIF
- Fixed opening items shared via a "file" media content URI

### Removed

- Dependencies: removed Guava as a direct dependency in Android

## [v1.2.4] - 2020-11-01 [YANKED]

## [v1.2.3] - 2020-10-22

...
