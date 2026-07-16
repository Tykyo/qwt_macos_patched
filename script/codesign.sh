#!/bin/bash
set -e

APP="$1"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

_FILTER="Apple Development"

IDENTITY=$(security find-identity -v -p codesigning \
    | grep "$_FILTER" \
    | head -n 1 \
    | awk '{print $2}')

if [ -z "$IDENTITY" ]; then
    echo "No valid codesign identity found for $_FILTER"
    IDENTITY='-'
fi

echo "Using identity: $IDENTITY"

FRAMEWORKS="${APP}/Contents/Frameworks"

if [ -d "$FRAMEWORKS" ]; then
    for d in "$FRAMEWORKS"/*; do
        if [ -d "$d" ] || [ -f "$d" ]; then
            codesign --force \
                -s "$IDENTITY" \
                "$d"
        fi
    done
fi

codesign --force \
    -s "$IDENTITY" \
    "$APP"

