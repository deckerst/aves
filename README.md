![Aves logo][]

Aves is a gallery and metadata explorer app. It is built for Android, with Flutter.

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

## Project Setup
Create a file named `<app dir>/android/key.properties`. It should contain a reference to a keystore for app signing, and other necessary credentials. See `<app dir>/android/key_template.properties` for the expected keys.

[Aves logo]: https://github.com/deckerst/aves/blob/master/android/app/src/main/res/mipmap-xxhdpi/ic_launcher_round.png
