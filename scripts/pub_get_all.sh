#!/bin/bash
if [ ! -d "scripts" ]; then
  cd ..
fi

./flutterw pub get

cd plugins || exit
for plugin in $(ls -d *); do
  cd $plugin
  ../../flutterw pub get
  cd ..
done
cd ..
