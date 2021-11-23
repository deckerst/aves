<div align="center">

<img src="https://raw.githubusercontent.com/deckerst/aves/develop/aves_logo.svg" alt='Aves logo' width="200" />

## Aves

![Version badge][Version badge]
![Build badge][Build badge]

Aves is a gallery and metadata explorer app. It is built for Android, with Flutter.

[<img src="https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png"
      alt='Get it on Google Play'
      height="80">](https://play.google.com/store/apps/details?id=deckers.thibault.aves&pcampaignid=pcampaignidMKT-Other-global-all-co-prtnr-py-PartBadge-Mar2515-1)
[<img src="https://gitlab.com/IzzyOnDroid/repo/-/raw/master/assets/IzzyOnDroid.png"
      alt='Get it on IzzyOnDroid'
      height="80">](https://apt.izzysoft.de/fdroid/index/apk/deckers.thibault.aves)
[<img src="https://raw.githubusercontent.com/deckerst/common/main/assets/get-it-on-github.png"
      alt='Get it on GitHub'
      height="80">](https://github.com/deckerst/aves/releases/latest)
      
<div align="left">

## Features

Aves can handle all sorts of images and videos, including your typical JPEGs and MP4s, but also more exotic things like **multi-page TIFFs, SVGs, old AVIs and more**!

It scans your media collection to identify **motion photos**, **panoramas** (aka photo spheres), **360° videos**, as well as **GeoTIFF** files.

**Navigation and search** is an important part of Aves. The goal is for users to easily flow from albums to photos to tags to maps, etc.

Aves integrates with Android (from **API 20 to 31**, i.e. from Lollipop to S) with features such as **app shortcuts** and **global search** handling. It also works as a **media viewer and picker**.

## Screenshots

<img src="https://raw.githubusercontent.com/deckerst/aves_extra/main/screenshots/S10/1-S10-collection.png" alt='Collection screenshot' height="400" /><img src="https://raw.githubusercontent.com/deckerst/aves_extra/main/screenshots/S10/2-S10-viewer.png" alt='Image screenshot' height="400" /><img src="https://raw.githubusercontent.com/deckerst/aves_extra/main/screenshots/S10/5-S10-stats.png" alt='Stats screenshot' height="400" /><img src="https://raw.githubusercontent.com/deckerst/aves_extra/main/screenshots/S10/3-S10-info__basic_.png" alt='Info (basic) screenshot' height="400" /><img src="https://raw.githubusercontent.com/deckerst/aves_extra/main/screenshots/S10/4-S10-info__metadata_.png" alt='Info (metadata) screenshot' height="400" /><img src="https://raw.githubusercontent.com/deckerst/aves_extra/main/screenshots/S10/6-S10-countries.png" alt='Countries screenshot' height="400" />

## Permissions

Aves requires a few permissions to do its job:
- **read contents of shared storage**: the app only accesses media files, and modifying them requires explicit access grants from the user,
- **read locations from media collection**: necessary to display the media coordinates, and to group them by country (via reverse geocoding),
- **have network access**: necessary for the map view, and most likely for precise reverse geocoding too,
- **view network connections**: checking for connection states allows Aves to gracefully degrade features that depend on internet.

## Contributing

### Issues

[Bug reports](https://github.com/deckerst/aves/issues/new?assignees=&labels=type%3Abug&template=bug_report.md&title=) and [feature requests](https://github.com/deckerst/aves/issues/new?assignees=&labels=type%3Afeature&template=feature_request.md&title=) are welcome. Questions too, though you could also ask them in [Discussions](https://github.com/deckerst/aves/discussions).

### Code

At this stage this project does *not* accept PRs, except for translations.

### Translations

If you want to translate this app in your language and share the result, feel free to open a PR or send the translation by [email](mailto:gallery.aves@gmail.com). You can find some localization notes in [pubspec.yaml](https://github.com/deckerst/aves/blob/develop/pubspec.yaml). English, Korean and French are already handled.

### Donations

Some users have expressed the wish to financially support the project. Thanks! ❤️

[<img src="https://raw.githubusercontent.com/deckerst/common/main/assets/paypal-badge-cropped.png"
      alt='Donate with PayPal'
      height="40">](https://paypal.me/ThibaultDeckers)
[<img src="https://liberapay.com/assets/widgets/donate.svg"
      alt='Donate using Liberapay'
      height="40">](https://liberapay.com/deckerst/donate)

## Project Setup

Before running or building the app, update the dependencies for the desired flavor:
```
# (cd scripts/; ./apply_flavor_play.sh)
```

To build the project, create a file named `<app dir>/android/key.properties`. It should contain a reference to a keystore for app signing, and other necessary credentials. See [key_template.properties](https://github.com/deckerst/aves/blob/develop/android/key_template.properties) for the expected keys.

To run the app:
```
# flutter run -t lib/main_play.dart --flavor play
```

[Version badge]: https://img.shields.io/github/v/release/deckerst/aves?include_prereleases&sort=semver
[Build badge]: https://img.shields.io/github/workflow/status/deckerst/aves/Quality%20check
