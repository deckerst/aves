#!/bin/bash
if [ ! -d "scripts" ]; then
  cd ..
fi

PUBSPEC_PATH="../pubspec.yaml"

flutter clean

sed -i 's/aves_services_huawei/aves_services_google/g' "$PUBSPEC_PATH"
sed -i 's/aves_report_console/aves_report_crashlytics/g' "$PUBSPEC_PATH"

flutter pub get
