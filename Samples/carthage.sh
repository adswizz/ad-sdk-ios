#!/usr/bin/env bash
# carthage.sh
# Checks out and builds the AdswizzSDK binaries declared in the Cartfile.
# Usage: ./carthage.sh

set -euo pipefail

carthage update --use-xcframeworks

echo "Done. The binaries are available in ./Carthage/Build"
