#!/bin/bash
# process raw screenshots from test driver to generate:
# - scaled down versions for IzzyOnDroid
# - framed versions for Google Play

# expects:
# - ImageMagick 6
# - raw screenshots sized at 1080x2280 in `/screenshots/raw`

DEVICE_OVERLAY_LTR=~/code/aves_extra/screenshots/device_overlay_s10e_ltr.png
DEVICE_FRAME=~/code/aves_extra/screenshots/device_frame_s10e.png
# FRAME_SIZE: dimensions of DEVICE_FRAME
FRAME_SIZE=1142x2410
# FRAME_OFFSET: offset for content in DEVICE_FRAME
FRAME_OFFSET=31x53
# PLAY_SIZE: contain FRAME_SIZE in 9:16
PLAY_SIZE=1356x2410

cd screenshots || exit

# add Android system overlay
for source in raw/*/*; do
  if [[ -f "$source" ]]; then
    target=${source/raw/overlay}
    echo "$source -> $target"
    mkdir -p "$(dirname "$target")"
    convert "$source" $DEVICE_OVERLAY_LTR -composite "$target"
  fi
done

# izzy: scale down + fastlane folder structure
for source in overlay/*/*; do
  if [[ -f "$source" ]]; then
    target=$(echo "$source" | sed -e 's/overlay\/\(.*\)\//izzy\/\1\/images\/phoneScreenshots\//g')
    echo "$source -> $target"
    mkdir -p "$(dirname "$target")"
    convert -resize 350x "$source" "$target"
  fi
done

# play: add device frame
for source in overlay/*/*; do
  if [[ -f "$source" ]]; then
    target=${source/overlay/framed}
    echo "$source -> $target"
    mkdir -p "$(dirname "$target")"
    convert "$source" -background transparent -splice $FRAME_OFFSET -extent $FRAME_SIZE $DEVICE_FRAME -composite "$target"
  fi
done

# play: fix aspect ratio
for source in framed/*/*; do
  if [[ -f "$source" ]]; then
    target=${source/framed/play}
    echo "$source -> $target"
    mkdir -p "$(dirname "$target")"
    convert "$source" -gravity center -background transparent -extent $PLAY_SIZE "$target"
  fi
done

# readme: scale down
for source in framed/en/*; do
  if [[ -f "$source" ]]; then
    target=${source/framed/readme}
    echo "$source -> $target"
    mkdir -p "$(dirname "$target")"
    convert -resize 250x "$source" "$target"
  fi
done
