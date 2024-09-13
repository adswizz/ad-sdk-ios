# !/usr/bin/env bash
# carthage.sh
# Usage example: ./carthage_with_flags.sh CustomFlags.xcconfig

if [ "$#" -ne 1 ]; then
   echo "Usage example: ./carthage_with_flags.sh CustomFlags.xcconfig"
   exit -1
fi

customConfigFilename=$1

if [ -e $1 ]
then
    echo "Found file named ${customConfigFilename}."
else
    echo "File ${customConfigFilename} does not exist!"
    exit -2
fi

set -euo pipefail
xcconfig=$(mktemp /tmp/static.xcconfig.XXXXXX)
trap 'rm -f "$xcconfig"' INT TERM HUP EXIT
# For Xcode 12 make sure EXCLUDED_ARCHS is set to arm architectures otherwise
# the build will fail on lipo due to duplicate architectures.
echo 'EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_simulator__NATIVE_ARCH_64_BIT_x86_64__XCODE_1200 = arm64 arm64e armv7 armv7s armv6 armv8' >> $xcconfig
echo 'EXCLUDED_ARCHS = $(inherited) $(EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_$(EFFECTIVE_PLATFORM_SUFFIX)__NATIVE_ARCH_64_BIT_$(NATIVE_ARCH_64_BIT)__XCODE_$(XCODE_VERSION_MAJOR))' > $xcconfig

export XCODE_XCCONFIG_FILE="$xcconfig"
carthage update --no-build --use-netrc # checkout

cp -f $customConfigFilename "Carthage/Checkouts/ad-sdk-ios-privacydata/AdswizzSDKPrivacyData/CustomConfig.xcconfig"
echo "" > "Carthage/Checkouts/ad-sdk-ios-privacydata/AdswizzSDKPrivacyData/AdswizzSDKPrivacyData/CreateCustomConfig.sh"

carthage build --use-netrc --use-xcframeworks
