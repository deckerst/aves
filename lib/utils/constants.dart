import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class Constants {
  static const storagePermissions = [
    Permission.storage,
    // for media access on Android >=13
    Permission.photos,
    Permission.videos,
  ];

  static const double colorPickerRadius = 16;

  static const embossShadows = [
    Shadow(
      color: Colors.black,
      offset: Offset(0.5, 1.0),
    )
  ];

  static const boraBoraGradientColors = [
    Color(0xff2bc0e4),
    Color(0xffeaecc6),
  ];

  static const int infoGroupMaxValueLength = 140;
}
