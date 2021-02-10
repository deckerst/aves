![Version badge][Version badge]
![Build badge][Build badge]

<br />
<img src="https://raw.githubusercontent.com/deckerst/aves/develop/assets/aves_logo.svg" alt='Aves logo' width="200" />

[<img src="https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png" alt='Get it on Google Play' width="200">](https://play.google.com/store/apps/details?id=deckers.thibault.aves&pcampaignid=pcampaignidMKT-Other-global-all-co-prtnr-py-PartBadge-Mar2515-1)

Aves is a gallery and metadata explorer app. It is built for Android, with Flutter.

<img src="https://raw.githubusercontent.com/deckerst/aves/develop/extra/play/screenshots%20v1.2.1/S10/1-S10-collection.png" alt='Collection screenshot' height="400" /><img src="https://raw.githubusercontent.com/deckerst/aves/develop/extra/play/screenshots%20v1.2.1/S10/2-S10-image.png" alt='Image screenshot' height="400" /><img src="https://raw.githubusercontent.com/deckerst/aves/develop/extra/play/screenshots%20v1.2.1/S10/5-S10-stats.png" alt='Stats screenshot' height="400" />

## Features

- support raster images: JPEG, GIF, PNG, HEIC/HEIF (including multi-track, from Android Pie), WEBP, TIFF (including multi-page), BMP, WBMP, ICO
- support animated images: GIF, WEBP
- support raw images: ARW, CR2, DNG, NEF, NRW, ORF, PEF, RAF, RW2, SRW
- support vector images: SVG
- support videos: MP4, AVI, MKV, AVCHD & probably others
- identify panoramas (aka photo spheres), 360° videos, GeoTIFF files
- search and filter by country, place, XMP tag, type (animated, raster, vector…)
- favorites
- statistics
- support Android API 24 ~ 30 (Nougat ~ R)
- Android integration (app shortcuts, handle view/pick intents)

## Known Issues

- performance: image info page stutters the first time it loads a Google Maps view (cf [flutter issue #28493](https://github.com/flutter/flutter/issues/28493))
- SVG: unsupported `currentColor` (cf [flutter_svg issue #31](https://github.com/dnfield/flutter_svg/issues/31))
- SVG: unsupported out of order defs/references (cf [flutter_svg issue #102](https://github.com/dnfield/flutter_svg/issues/102))
- SVG: unsupported `<style>` (cf [flutter_svg issue #105](https://github.com/dnfield/flutter_svg/issues/105))
- SVG: limited support for `%`, `mm` or `pt` unit (cf [flutter_svg issue #110](https://github.com/dnfield/flutter_svg/issues/110))

## Test Devices

| Model       | Name                       | Android Version | API |
| ----------- | -------------------------- | --------------- | ---:|
| SM-G981N    | Samsung Galaxy S20 5G      | 11 (R)          | 30  |
| SM-G970N    | Samsung Galaxy S10e        | 11 (R)          | 30  |
| SM-P580     | Samsung Galaxy Tab A 10.1  | 8.1.0 (Oreo)    | 27  |
| SM-G930S    | Samsung Galaxy S7          | 8.0.0 (Oreo)    | 26  |

## Project Setup

Create a file named `<app dir>/android/key.properties`. It should contain a reference to a keystore for app signing, and other necessary credentials. See `<app dir>/android/key_template.properties` for the expected keys.

[Version badge]: https://img.shields.io/github/v/release/deckerst/aves?include_prereleases&sort=semver
[Build badge]: https://img.shields.io/github/workflow/status/deckerst/aves/Release%20on%20tag
