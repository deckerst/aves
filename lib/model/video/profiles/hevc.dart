class Hevc {
  static const profileMain = 1;
  static const profileMain10 = 2;
  static const profileMainStillPicture = 3;
  static const profileRExt = 4;

  static String formatProfile(int profileIndex, int levelIndex) {
    String profile;
    switch (profileIndex) {
      case profileMain:
        profile = 'Main';
        break;
      case profileMain10:
        profile = 'Main 10';
        break;
      case profileMainStillPicture:
        profile = 'Main Still Picture';
        break;
      case profileRExt:
        profile = 'Format Range';
        break;
      default:
        return '$profileIndex';
    }
    if (levelIndex <= 0) return profile;
    final level = (levelIndex / 30.0).toStringAsFixed(levelIndex % 10 != 0 ? 1 : 0);
    return '$profile Profile, Level $level';
  }
}
