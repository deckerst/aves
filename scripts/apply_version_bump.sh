#!/bin/bash
if [ ! -d "scripts" ]; then
    cd ..
fi

scripts/gen_changelogs.sh
scripts/gen_flavors.sh
