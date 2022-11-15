#!/bin/bash
if [ ! -d "scripts" ]; then
  cd ..
fi

flutter pub get

cd plugins || exit
for plugin in $(ls -d *); do
  cd $plugin
  flutter pub get
  cd ..
done
cd ..
