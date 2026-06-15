#!/bin/bash

echo "[1/4] Generating localizations (l10n)..."
# Generated app_localizations*.dart are gitignored, so regenerate them from
# the .arb files before analyzing — otherwise analyze runs against stale output.
flutter gen-l10n

echo "[2/4] Fixing Spaces and Formatting..."
# This will actually overwrite files to fix spacing
dart format .

echo "[3/4] Checking for code issues (Depth, Complexity, Errors)..."
# This will check for linter warnings and errors
flutter analyze
if [ $? -ne 0 ]; then
    echo ""
    echo "[!] ERROR: Code analysis failed."
    echo "Please fix the warnings/errors above before you commit."
    exit 1
fi

echo "[4/4] Success! Your code is ready to be committed."
echo ""
echo "TIP: If a function was warned about complexity, consider breaking it into smaller functions."
