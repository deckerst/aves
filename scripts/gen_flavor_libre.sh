#!/bin/bash
if [ ! -d "scripts" ]; then
  cd ..
fi

./flutterw clean

sed -i 's|plugins/aves_services_.*|plugins/aves_services_none|g' "pubspec.yaml"
sed -i 's|plugins/aves_report_.*|plugins/aves_report_console|g' "pubspec.yaml"

./flutterw pub get

mkdir flavors
cp pubspec.lock flavors/pubspec_libre.lock
cp pubspec.yaml flavors/pubspec_libre.yaml
