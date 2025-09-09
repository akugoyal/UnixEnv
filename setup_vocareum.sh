#!/bin/bash
set -euo pipefail

# Resolve the directory this script lives in, no matter where it's called from
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source and destination
SRC="$SCRIPT_DIR/.vimrc"
DEST="$OLD_HOME/.vimrc"

# Safety check
if [ ! -f "$SRC" ]; then
    echo "Error: .vimrc not found in $SCRIPT_DIR"
    exit 1
fi

# Create backup if needed
if [ -f "$DEST" ]; then
    echo "Backing up existing $DEST to $DEST.bak"
    cp "$DEST" "$DEST.bak"
fi

# Copy
cp "$SRC" "$DEST"
echo "Copied $SRC → $DEST"

