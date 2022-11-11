#!/bin/bash
if [ ! -d "scripts" ]; then
  cd ..
fi

flutter pub upgrade

cd packages || exit
for package in $(ls -d *); do
  cd $package
  flutter pub upgrade
  cd ..
done
cd ..

cd plugins || exit
for plugin in $(ls -d *); do
  cd $plugin
  flutter pub upgrade
  cd ..
done
cd ..
