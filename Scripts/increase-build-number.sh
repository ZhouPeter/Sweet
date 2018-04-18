#!/usr/bin/env bash

# xcode-build-bump.sh
# @desc Auto-increment the build number every time the project is run. 
# @usage
# 1. Select: your Target in Xcode
# 2. Select: Build Phases Tab
# 3. Select: Add Build Phase -> Add Run Script
# 4. Paste code below in to new "Run Script" section
# 5. Drag the "Run Script" below "Link Binaries With Libraries"
# 6. Insure that your starting build number is set to a whole integer and not a float (e.g. 1, not 1.0)

INFOPLIST_PATH="../Sweet/Info.plist"
DEV_INFOPLIST_PATH="../Sweet/Sweet Dev-Info.plist"

buildNumber=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "${INFOPLIST_PATH}")
buildNumber=$(($buildNumber + 1))
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildNumber" "${INFOPLIST_PATH}"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildNumber" "${DEV_INFOPLIST_PATH}"
