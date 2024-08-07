class H264 {
  static const profileConstrained = 1 << 9;
  static const profileIntra = 1 << 11;

  static const profileBaseline = 66;
  static const profileConstrainedBaseline = 66 | profileConstrained;
  static const profileMain = 77;
  static const profileExtended = 88;
  static const profileHigh = 100;
  static const profileHigh10 = 110;
  static const profileHigh422 = 122;
  static const profileHigh444 = 144;
  static const profileHigh444Predictive = 244;

  // intra
  static const profileHigh10Intra = 110 | profileIntra;
  static const profileHigh422Intra = 122 | profileIntra;
  static const profileHigh444Intra = 244 | profileIntra;
  static const profileCAVLC444 = 44;

  // multiview
  static const profileMultiviewHigh = 118;
  static const profileStereoHigh = 128;
  static const profileMultiviewDepthHigh = 138;

  static String formatProfile(int profileIndex, int levelIndex) {
    String profile;
    switch (profileIndex) {
      case profileBaseline:
        profile = 'Baseline';
      case profileConstrainedBaseline:
        profile = 'Constrained Baseline';
      case profileMain:
        profile = 'Main';
      case profileExtended:
        profile = 'Extended';
      case profileHigh:
        profile = 'High';
      case profileHigh10:
        profile = 'High 10';
      case profileHigh10Intra:
        profile = 'High 10 Intra';
      case profileHigh422:
        profile = 'High 4:2:2';
      case profileHigh422Intra:
        profile = 'High 4:2:2 Intra';
      case profileHigh444:
        profile = 'High 4:4:4';
      case profileHigh444Predictive:
        profile = 'High 4:4:4 Predictive';
      case profileHigh444Intra:
        profile = 'High 4:4:4 Intra';
      case profileCAVLC444:
        profile = 'CAVLC 4:4:4';
      default:
        return '$profileIndex';
    }
    if (levelIndex <= 0) return profile;
    final level = (levelIndex / 10.0).toStringAsFixed(levelIndex % 10 != 0 ? 1 : 0);
    return '$profile Profile, Level $level';
  }
}
