import 'package:aves/services/media/enums.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/view/src/metadata/credentials.dart';
import 'package:aves/widgets/common/identity/icons/overlay.dart';
import 'package:material_ui/material_ui.dart';

class const AnimatedImageIcon({super.key}) extends StatelessWidget {
  static const double scale = .75;

  @override
  Widget build(BuildContext context) {
    return const OverlayIcon(
      icon: AIcons.animated,
      iconScale: scale,
    );
  }
}

class const CredentialValidityIcon({
  super.key,
  required final C2paValidity validity,
}) extends StatelessWidget {
  static const double scale = .95;

  @override
  Widget build(BuildContext context) {
    return OverlayIcon(
      icon: validity.getIconData(),
      iconScale: scale,
    );
  }
}

class const FavouriteIcon({super.key}) extends StatelessWidget {
  static const double scale = .9;

  @override
  Widget build(BuildContext context) {
    return const OverlayIcon(
      icon: AIcons.favourite,
      iconScale: scale,
      relativeOffset: Offset(0, .05),
    );
  }
}

class const GeoTiffIcon({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const OverlayIcon(
      icon: AIcons.geo,
    );
  }
}

class const HdrIcon({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const OverlayIcon(
      icon: AIcons.hdr,
    );
  }
}

class const LocationIcon._private({required final IconData icon}) extends StatelessWidget {
  factory located() => const LocationIcon._private(icon: AIcons.location);

  factory unlocated() => const LocationIcon._private(icon: AIcons.locationUnlocated);

  @override
  Widget build(BuildContext context) {
    return OverlayIcon(
      icon: icon,
    );
  }
}

class const MotionPhotoIcon({super.key}) extends StatelessWidget {
  static const double scale = .85;

  @override
  Widget build(BuildContext context) {
    return const OverlayIcon(
      icon: AIcons.motionPhoto,
      iconScale: scale,
    );
  }
}

class const PanoramaIcon({super.key}) extends StatelessWidget {
  static const double scale = .8;

  @override
  Widget build(BuildContext context) {
    return const OverlayIcon(
      icon: AIcons.panorama,
      iconScale: scale,
    );
  }
}

class const RawIcon({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const OverlayIcon(
      icon: AIcons.raw,
    );
  }
}

class const TagIcon._private({required final IconData icon}) extends StatelessWidget {
  factory tagged() => const TagIcon._private(icon: AIcons.tag);

  factory untagged() => const TagIcon._private(icon: AIcons.tagUntagged);

  static const double scale = .9;

  @override
  Widget build(BuildContext context) {
    return OverlayIcon(
      icon: icon,
      iconScale: scale,
      relativeOffset: const Offset(.05, .05),
    );
  }
}
