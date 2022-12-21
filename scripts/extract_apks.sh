#!/bin/bash
if [ ! -d "scripts" ]; then
  cd ..
fi

BUNDLE="/home/tibo/Downloads/app-play-release.aab"

# shellcheck disable=SC2001
OUTPUT=$(sed "s|\.aab|\.apks|" <<<"$BUNDLE")

KEYS_PATH="android/key.properties"
STORE_PATH=$(sed -n 's|.*storeFile=\(.*\)[\r\n]|\1|p' "$KEYS_PATH")
# shellcheck disable=SC1003
STORE_PW=$(sed -n 's|.*storePassword=\(.*\)[\r\n]|\1|p' "$KEYS_PATH" | sed 's|\\'\''|'\''|g')
KEY_ALIAS=$(sed -n 's|.*keyAlias=\(.*\)[\r\n]|\1|p' "$KEYS_PATH")
# shellcheck disable=SC1003
KEY_PW=$(sed -n 's|.*keyPassword=\(.*\)[\r\n]|\1|p' "$KEYS_PATH" | sed 's|\\'\''|'\''|g')

echo "$BUNDLE -> $OUTPUT"
bundletool build-apks --bundle="$BUNDLE" --output="$OUTPUT" \
  --ks="$STORE_PATH" --ks-pass="pass:$STORE_PW" \
  --ks-key-alias="$KEY_ALIAS" --key-pass="pass:$KEY_PW"
