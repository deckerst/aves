import 'dart:ui' as ui;

import 'package:aves/ref/locale/iso639_1.dart';
import 'package:country_code/country_code.dart';

// time components hours/minutes/seconds are always displayed in that order
const ui.TextDirection kTimeComponentsDirection = .ltr;

// represents direction of tape being played, not direction of time
const ui.TextDirection kVideoPlaybackDirection = .ltr;

final rootLocale = ui.Locale(LanguageCodesIso639_1.english, CountryCode.US.alpha2);
