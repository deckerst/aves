import 'package:flutter/services.dart';

class CustomPlatformException({
  required final String code,
  final String? message,
  final Object? details,
  final String? stacktrace,
}) {
  factory fromStandard(PlatformException e) {
    return CustomPlatformException(
      code: e.code,
      message: e.message,
      details: e.details,
      stacktrace: e.stacktrace,
    );
  }

  @override
  String toString() => '$runtimeType($code, $message, $details, $stacktrace)';
}
