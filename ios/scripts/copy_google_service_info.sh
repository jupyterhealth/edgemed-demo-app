#!/bin/sh
set -e

FLAVOR=$(echo "${CONFIGURATION}" | sed -E 's/^(Debug|Release|Profile)-?//')

if [ -z "${FLAVOR}" ]; then
  echo "warning: No flavor in CONFIGURATION=${CONFIGURATION}. Skipping GoogleService-Info.plist copy."
  exit 0
fi

SRC="${PROJECT_DIR}/config/${FLAVOR}/GoogleService-Info.plist"
DEST="${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"

if [ ! -f "${SRC}" ]; then
  echo "warning: GoogleService-Info.plist not found for flavor '${FLAVOR}' at ${SRC}. Skipping."
  exit 0
fi

cp "${SRC}" "${DEST}"
echo "Copied GoogleService-Info.plist for flavor '${FLAVOR}'."
