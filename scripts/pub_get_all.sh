#!/bin/bash
cd ..
flutter pub get
cd plugins
for plugin in $(ls -d *); do
  cd $plugin
  flutter pub get
  cd ..
done

