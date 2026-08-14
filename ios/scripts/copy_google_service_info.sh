#!/bin/sh
set -e

FLAVOR=$(echo "${CONFIGURATION}" | sed -E 's/^(Debug|Release|Profile)-?//')

if [ -z "${FLAVOR}" ]; then
  echo "error: No flavor in CONFIGURATION=${CONFIGURATION}. Cannot copy GoogleService-Info.plist."
  exit 1
fi

SRC="${PROJECT_DIR}/config/${FLAVOR}/GoogleService-Info.plist"
DEST="${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"

if [ ! -f "${SRC}" ]; then
  echo "error: GoogleService-Info.plist not found for flavor '${FLAVOR}' at ${SRC}."
  exit 1
fi

cp "${SRC}" "${DEST}"
echo "Copied GoogleService-Info.plist for flavor '${FLAVOR}'."
