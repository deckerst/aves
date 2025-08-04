class BurstPatterns {
  static const _keyGroupName = 'key';

  static const fairphoneMotorola = r'^IMG_(?<key>\d{8}_\d{6,9})_BURST(\d+)(_COVER)?$';
  static const samsung = r'^(?<key>\d{8}_\d{6})_(\d+)$';
  static const sony = r'^DSC(PDC)?_\d+_BURST(?<key>\d{17})(_COVER)?$';

  static final options = [
    BurstPatterns.fairphoneMotorola,
    BurstPatterns.samsung,
    BurstPatterns.sony,
  ];

  static String getName(String pattern) {
    return switch (pattern) {
      fairphoneMotorola => 'Fairphone, Motorola',
      samsung => 'Samsung',
      sony => 'Sony',
      _ => pattern,
    };
  }

  static String getExample(String pattern) {
    return switch (pattern) {
      fairphoneMotorola => 'IMG_20151021_072800_BURST007',
      samsung => '20151021_072800_007',
      sony => 'DSC_0007_BURST20151021072800123',
      _ => '?',
    };
  }

  static const byManufacturer = {
    _Manufacturers.fairphone: fairphoneMotorola,
    _Manufacturers.motorola: fairphoneMotorola,
    _Manufacturers.samsung: samsung,
    _Manufacturers.sony: sony,
  };

  static String? getKeyForName(String? filename, List<String> patterns) {
    if (filename != null) {
      for (final pattern in patterns) {
        final match = RegExp(pattern).firstMatch(filename);
        if (match != null) {
          if (match.groupNames.contains(_keyGroupName)) {
            return match.namedGroup(_keyGroupName);
          }
          // fallback to fetching group by index for backward compatibility
          return match.group(1);
        }
      }
    }
    return null;
  }
}

// values as returned by `DeviceInfoPlugin().androidInfo` (lower-cased)
class _Manufacturers {
  static const fairphone = 'fairphone';
  static const motorola = 'motorola';
  static const samsung = 'samsung';
  static const sony = 'sony';
}
