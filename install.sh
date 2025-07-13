#!/usr/bin/env bash
#
# install.sh
# Example usage:
#   bash install.sh
#
# This script downloads audio2mp3 script and installs it in ~/.local/bin

set -euo pipefail

# CONFIGURATION
SCRIPT_URL="http://raw.githubusercontent.com/homelabshq/audio2mp3/refs/heads/main/audio2mp3.sh"
SCRIPT_NAME="audio2mp3"

# Choose install directory
if [ -d "$HOME/.local/bin" ]; then
    TARGET_DIR="$HOME/.local/bin"
else
    TARGET_DIR="$HOME/.local/bin"
    mkdir -p "$TARGET_DIR"
fi

TARGET_PATH="$TARGET_DIR/$SCRIPT_NAME"

# Download the script
echo "Downloading $SCRIPT_NAME from $SCRIPT_URL..."
curl -fsSL "$SCRIPT_URL" -o "$TARGET_PATH"

# Make it executable
chmod +x "$TARGET_PATH"

echo "Installed '$SCRIPT_NAME' to '$TARGET_PATH'."

# Check if TARGET_DIR is in PATH
case ":$PATH:" in
    *":$TARGET_DIR:"*)
        echo "✅ '$TARGET_DIR' is already in your PATH."
        ;;
    *)
        echo "⚠️ Note: '$TARGET_DIR' is not in your PATH."
        echo "   You can add it by running:"
        echo ""
        echo "   echo 'export PATH=\"\$PATH:$TARGET_DIR\"' >> ~/.bashrc"
        echo "   source ~/.bashrc"
        echo ""
        ;;
esac

echo "✅ Installation complete! You can run your script with:"
echo "   $SCRIPT_NAME"

