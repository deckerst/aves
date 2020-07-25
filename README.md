![Version badge][Version badge]
![Build badge][Build badge]

<br />
<img src="https://raw.githubusercontent.com/deckerst/aves/develop/assets/aves_logo.svg" alt='Aves logo' width="200" />

[<img src="https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png" alt='Get it on Google Play' width="200">](https://play.google.com/store/apps/details?id=deckers.thibault.aves&pcampaignid=pcampaignidMKT-Other-global-all-co-prtnr-py-PartBadge-Mar2515-1)

Aves is a gallery and metadata explorer app. It is built for Android, with Flutter.

<img src="https://raw.githubusercontent.com/deckerst/aves/develop/extra/play/screenshots%20v1.0.0/S10/1-S10-collection.jpg" alt='Collection screenshot' height="400" /><img src="https://raw.githubusercontent.com/deckerst/aves/develop/extra/play/screenshots%20v1.0.0/S10/2-S10-image.jpg" alt='Image screenshot' height="400" /><img src="https://raw.githubusercontent.com/deckerst/aves/develop/extra/play/screenshots%20v1.0.0/S10/5-S10-stats.jpg" alt='Stats screenshot' height="400" />

## Features

- support raster images: JPEG, PNG, GIF, WEBP, BMP, WBMP, HEIC (from Android Pie)
- support animated images: GIF, WEBP
- support vector images: SVG
- support videos: MP4, AVI & probably others
- search and filter by country, place, XMP tag, type (animated, raster, vector, video)
- bulk delete, share, copy, move
- favorites
- statistics
- handle intents to view or pick images
- support Android API 24 ~ 29 (Nougat ~ Android 10)

## Roadmap

If time permits, I intend to eventually add these:
- settings & preferences
- feature: XMP tag edition (likely with [pixymeta-android](https://github.com/dragon66/pixymeta-android))
- feature: location edition
- map view
- gesture: long press and drag thumbnails to select multiple items
- gesture: double tap and drag image to zoom in/out (aka quick scale, one finger zoom)
- support: burst groups
- support: Android R
- subsampling/tiling

## Known Issues

- privacy: cannot opt out of Crashlytics reporting (cf [flutterfire issue #1143](https://github.com/FirebaseExtended/flutterfire/issues/1143))
- gesture: double tap on image does not zoom on tapped area (cf [photo_view issue #82](https://github.com/renancaraujo/photo_view/issues/82))
- performance: image info page stutters the first time it loads a Google Maps view (cf [flutter issue #28493](https://github.com/flutter/flutter/issues/28493))
- performance: image decoding is slow

## Test Devices

| Model       | Name                       | Android Version | API |
| ----------- | -------------------------- | --------------- | ---:|
| SM-G970N    | Samsung Galaxy S10e        | 10 (Android10)  | 29  |
| SM-P580     | Samsung Galaxy Tab A 10.1  | 8.1.0 (Oreo)    | 27  |
| SM-G930S    | Samsung Galaxy S7          | 8.0.0 (Oreo)    | 26  |
| E5823       | Sony Xperia Z5 Compact     | 7.1.1 (Nougat)  | 25  |

## Project Setup

Create a file named `<app dir>/android/key.properties`. It should contain a reference to a keystore for app signing, and other necessary credentials. See `<app dir>/android/key_template.properties` for the expected keys.

[Version badge]: https://img.shields.io/github/v/release/deckerst/aves?include_prereleases&sort=semver
[Build badge]: https://img.shields.io/github/workflow/status/deckerst/aves/Release%20on%20tag
