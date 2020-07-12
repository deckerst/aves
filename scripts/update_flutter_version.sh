#!/bin/bash
FILE_PATH="../lib/flutter_version.dart"
rm "$FILE_PATH"
echo "Updating flutter_version.dart:"
{
  echo "const Map<String, String> version = "
  flutter --version --machine
  echo ";"
} >> "$FILE_PATH"
cat "$FILE_PATH"
