#!/bin/bash
if [ ! -d "scripts" ]; then
    cd ..
fi

SOURCE_CHANGELOG="whatsnew/whatsnew-en-US"
TARGET_CHANGELOG_DIR="fastlane/metadata/android/en-US/changelogs"

APP_VERSION_CODE=$(sed -n 's|^\s*version: \(.*\)+\(.*\)\s*$|\2|p' "pubspec.yaml")

# libre changelog
cp "$SOURCE_CHANGELOG" "$TARGET_CHANGELOG_DIR/${APP_VERSION_CODE}.txt"

# izzy changelog
# cf `android/app/build.gradle.kts` for ABI code definition and usage
for ABI_CODE in {1..4}; do
  cp "$SOURCE_CHANGELOG" "$TARGET_CHANGELOG_DIR/${APP_VERSION_CODE}0${ABI_CODE}.txt";
done

git add $TARGET_CHANGELOG_DIR
