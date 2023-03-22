class BurstPatterns {
  static const samsung = r'^(\d{8}_\d{6})_(\d+)$';
  static const sony = r'^DSC_\d+_BURST(\d{17})(_COVER)?$';

  static final options = [
    BurstPatterns.samsung,
    BurstPatterns.sony,
  ];

  static String getName(String pattern) {
    switch (pattern) {
      case samsung:
        return 'Samsung';
      case sony:
        return 'Sony';
      default:
        return pattern;
    }
  }

  static String getExample(String pattern) {
    switch (pattern) {
      case samsung:
        return '20151021_072800_007';
      case sony:
        return 'DSC_0007_BURST20151021072800123';
      default:
        return '?';
    }
  }

  static const byManufacturer = {
    _Manufacturers.samsung: samsung,
    _Manufacturers.sony: sony,
  };
}

// values as returned by `DeviceInfoPlugin().androidInfo`
class _Manufacturers {
  static const samsung = 'samsung';
  static const sony = 'sony';
}
