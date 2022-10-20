#!/bin/bash
if [ ! -d "scripts" ]; then
  cd ..
fi

flutter pub upgrade
cd plugins || exit
for plugin in $(ls -d *); do
  cd $plugin
  flutter pub upgrade
  cd ..
done

