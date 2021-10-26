#!/bin/bash
PUBSPEC_PATH="../pubspec.yaml"

flutter clean

sed -i 's/aves_report_console/aves_report_crashlytics/g' "$PUBSPEC_PATH"

flutter pub get
