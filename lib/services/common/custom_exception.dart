import 'package:flutter/services.dart';

class CustomPlatformException {
  final String code;
  final String? message;
  final dynamic details;
  final String? stacktrace;

  CustomPlatformException({
    required this.code,
    this.message,
    this.details,
    this.stacktrace,
  });

  factory CustomPlatformException.fromStandard(PlatformException e) {
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
