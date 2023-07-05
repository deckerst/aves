import 'dart:async';

import 'package:aves_model/aves_model.dart';

abstract class AvesVideoMetadataFetcher {
  void init();

  Future<Map> getMetadata(AvesEntryBase entry);
}
