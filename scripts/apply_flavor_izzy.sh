#!/bin/bash
if [ ! -d "scripts" ]; then
  cd ..
fi

PUBSPEC_PATH="pubspec.yaml"

./flutterw clean

sed -i 's|plugins/aves_services_.*|plugins/aves_services_google|g' "$PUBSPEC_PATH"
sed -i 's|plugins/aves_report_.*|plugins/aves_report_console|g' "$PUBSPEC_PATH"

./flutterw pub get
