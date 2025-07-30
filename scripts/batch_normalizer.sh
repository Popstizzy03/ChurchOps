#!/bin/bash

# === COMPATIBILITY WRAPPER ===
# This script maintains backward compatibility while redirecting to the new unified system

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAIN_SCRIPT="$SCRIPT_DIR/../church_media_ops.sh"

echo "🔄 Redirecting to unified Church Media Ops system..."
echo ""

# Check if main script exists
if [[ ! -f "$MAIN_SCRIPT" ]]; then
    echo "❌ Main script not found: $MAIN_SCRIPT"
    echo "Please ensure church_media_ops.sh is in the ChurchOps root directory"
    exit 1
fi

# Execute main script with all arguments
exec "$MAIN_SCRIPT" "$@"
