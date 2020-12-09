extension ExtraString on String {
  static final _sentenceCaseStep1 = RegExp(r'([A-Z][a-z]|\[)');
  static final _sentenceCaseStep2 = RegExp(r'([a-z])([A-Z])');

  String toSentenceCase() {
    var s = replaceFirstMapped(RegExp('.'), (m) => m.group(0).toUpperCase());
    return s.replaceAllMapped(_sentenceCaseStep1, (m) => ' ${m.group(1)}').replaceAllMapped(_sentenceCaseStep2, (m) => '${m.group(1)} ${m.group(2)}').trim();
  }
}
