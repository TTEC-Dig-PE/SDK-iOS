#!/bin/sh


FRAMEWORK_ARTIFACTS="${SRCROOT}/../artifacts"
mkdir -p "${FRAMEWORK_ARTIFACTS}"
cp -R "${TARGET_BUILD_DIR}/EXPERTconnect.framework" "${FRAMEWORK_ARTIFACTS}"
