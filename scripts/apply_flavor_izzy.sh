#!/bin/bash
PUBSPEC_PATH="../pubspec.yaml"

flutter clean

sed -i 's/aves_services_huawei/aves_services_google/g' "$PUBSPEC_PATH"
sed -i 's/aves_report_crashlytics/aves_report_console/g' "$PUBSPEC_PATH"

flutter pub get
