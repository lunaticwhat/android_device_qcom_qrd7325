#!/bin/bash
#
# Copyright (C) 2024 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#
# Extracts the stock vendor and odm images of the QRD7325 from a raw
# super partition dump into prebuilt/images/.
#
# Usage (from the root of the LineageOS source tree, after `. build/envsetup.sh`):
#   m lpunpack
#   device/qcom/qrd7325/extract-prebuilts.sh /path/to/super.img [a|b]
#
# The slot defaults to "a". Use the slot that was active when the super
# dump was taken (the one whose vendor partition is not empty).

set -e

SUPER="${1}"
SLOT="${2:-a}"

MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi
OUT_DIR="${MY_DIR}/prebuilt/images"

if [ -z "${SUPER}" ] || [ ! -f "${SUPER}" ]; then
    echo "Usage: ${0} /path/to/super.img [a|b]"
    exit 1
fi

LPUNPACK="$(command -v lpunpack || true)"
if [ -z "${LPUNPACK}" ] && [ -n "${ANDROID_HOST_OUT}" ] && [ -x "${ANDROID_HOST_OUT}/bin/lpunpack" ]; then
    LPUNPACK="${ANDROID_HOST_OUT}/bin/lpunpack"
fi
if [ -z "${LPUNPACK}" ]; then
    echo "lpunpack not found. Run '. build/envsetup.sh && m lpunpack' first."
    exit 1
fi

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

mkdir -p "${OUT_DIR}"
for PART in vendor odm; do
    echo "Extracting ${PART}_${SLOT} ..."
    "${LPUNPACK}" -p "${PART}_${SLOT}" "${SUPER}" "${TMP_DIR}"
    if [ ! -s "${TMP_DIR}/${PART}_${SLOT}.img" ]; then
        echo "${PART}_${SLOT} is empty in this super image. Try the other slot."
        exit 1
    fi
    mv "${TMP_DIR}/${PART}_${SLOT}.img" "${OUT_DIR}/${PART}.img"
done

echo "Done:"
ls -l "${OUT_DIR}"
