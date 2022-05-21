#!/bin/bash
cd ..
flutter pub upgrade
cd plugins
for plugin in $(ls -d *); do
  cd $plugin
  flutter pub upgrade
  cd ..
done

