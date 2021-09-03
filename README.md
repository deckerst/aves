![Version badge][Version badge]
![Build badge][Build badge]

<br />
<img src="https://raw.githubusercontent.com/deckerst/aves/develop/aves_logo.svg" alt='Aves logo' width="200" />

[<img src="https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png"
      alt='Get it on Google Play'
      height="80">](https://play.google.com/store/apps/details?id=deckers.thibault.aves&pcampaignid=pcampaignidMKT-Other-global-all-co-prtnr-py-PartBadge-Mar2515-1)
[<img src="https://raw.githubusercontent.com/deckerst/common/main/assets/get-it-on-github.png"
      alt='Get it on GitHub'
      height="80">](https://github.com/deckerst/aves/releases/latest)
      
Aves is a gallery and metadata explorer app. It is built for Android, with Flutter.

<img src="https://raw.githubusercontent.com/deckerst/aves_extra/main/screenshots/S10/1-S10-collection.png" alt='Collection screenshot' height="400" /><img src="https://raw.githubusercontent.com/deckerst/aves_extra/main/screenshots/S10/2-S10-viewer.png" alt='Image screenshot' height="400" /><img src="https://raw.githubusercontent.com/deckerst/aves_extra/main/screenshots/S10/5-S10-stats.png" alt='Stats screenshot' height="400" />

## Features

Aves can handle all sorts of images and videos, including your typical JPEGs and MP4s, but also more exotic things like **multi-page TIFFs, SVGs, old AVIs and more**!

It scans your media collection to identify **motion photos**, **panoramas** (aka photo spheres), **360° videos**, as well as **GeoTIFF** files.

**Navigation and search** is an important part of Aves. The goal is for users to easily flow from albums to photos to tags to maps, etc.

Aves integrates with Android (from **API 20 to 31**, i.e. from Lollipop to S) with features such as **app shortcuts** and **global search** handling. It also works as a **media viewer and picker**.

## Permissions

Aves requires a few permissions to do its job:
- **read contents of shared storage**: the app only accesses media files, and modifying them requires explicit access grants from the user,
- **read locations from media collection**: necessary to display the media coordinates, and to group them by country (via reverse geocoding),
- **have network access**: necessary for the map view, and most likely for precise reverse geocoding too,
- **view network connections**: checking for connection states allows Aves to gracefully degrade features that depend on internet.

## Project Setup

Create a file named `<app dir>/android/key.properties`. It should contain a reference to a keystore for app signing, and other necessary credentials. See `<app dir>/android/key_template.properties` for the expected keys.

[Version badge]: https://img.shields.io/github/v/release/deckerst/aves?include_prereleases&sort=semver
[Build badge]: https://img.shields.io/github/workflow/status/deckerst/aves/Quality%20check
