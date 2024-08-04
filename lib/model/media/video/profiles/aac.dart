class AAC {
  static const profileMain = 0;
  static const profileLowComplexity = 1;
  static const profileScalableSampleRate = 2;
  static const profileLongTermPrediction = 3;
  static const profileHighEfficiency = 4;
  static const profileHighEfficiencyV2 = 28;
  static const profileLowDelay = 22;
  static const profileLowDelayV2 = 38;

  static String formatProfile(int profileIndex) {
    switch (profileIndex) {
      case profileMain:
        return 'Main';
      case profileLowComplexity:
        return 'LC';
      case profileLongTermPrediction:
        return 'LTP';
      case profileScalableSampleRate:
        return 'SSR';
      case profileHighEfficiency:
        return 'HE-AAC';
      case profileHighEfficiencyV2:
        return 'HE-AAC v2';
      case profileLowDelay:
        return 'LD';
      case profileLowDelayV2:
        return 'ELD';
      default:
        return '$profileIndex';
    }
  }
}
