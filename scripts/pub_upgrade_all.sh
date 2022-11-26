#!/bin/bash
if [ ! -d "scripts" ]; then
  cd ..
fi

./flutterw pub upgrade

cd plugins || exit
for plugin in $(ls -d *); do
  cd $plugin
  ../../flutterw pub upgrade
  cd ..
done
cd ..
