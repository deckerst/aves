import 'dart:async';

import 'package:aves/services/common/services.dart';
import 'package:flutter/services.dart';

abstract class AppProfileService {
  Future<bool> canInteractAcrossProfiles();

  Future<bool> canRequestInteractAcrossProfiles();

  Future<bool> requestInteractAcrossProfiles();

  Future<String> getProfileSwitchingLabel();

  Future<void> switchProfile();

  Future<List<String>> getTargetUserProfiles();
}

class PlatformAppProfileService implements AppProfileService {
  static const _platform = MethodChannel('deckers.thibault/aves/app_profile');

  @override
  Future<bool> canInteractAcrossProfiles() async {
    try {
      final result = await _platform.invokeMethod('canInteractAcrossProfiles');
      if (result != null) return result as bool;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return false;
  }

  @override
  Future<bool> canRequestInteractAcrossProfiles() async {
    try {
      final result = await _platform.invokeMethod('canRequestInteractAcrossProfiles');
      if (result != null) return result as bool;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return false;
  }

  @override
  Future<bool> requestInteractAcrossProfiles() async {
    try {
      final result = await _platform.invokeMethod('requestInteractAcrossProfiles');
      if (result != null) return result as bool;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return false;
  }

  @override
  Future<void> switchProfile() async {
    try {
      await _platform.invokeMethod('switchProfile');
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return;
  }

  @override
  Future<String> getProfileSwitchingLabel() async {
    try {
      final result = await _platform.invokeMethod('getProfileSwitchingLabel');
      return result as String;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return '';
  }

  @override
  Future<List<String>> getTargetUserProfiles() async {
    try {
      final result = await _platform.invokeMethod('getTargetUserProfiles');
      if (result != null) {
        return (result as List).cast<String>();
      }
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return [];
  }
}
