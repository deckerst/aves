#!/bin/bash
if [ ! -d "scripts" ]; then
  cd ..
fi

scripts/gen_flavor_izzy.sh
scripts/gen_flavor_libre.sh
scripts/gen_flavor_play.sh
