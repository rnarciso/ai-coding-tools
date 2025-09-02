#!/bin/sh

ALIASES_FILE="$HOME/.ai_toolkit_aliases"
BASHRC_FILE="$HOME/.bashrc"
BASHRC_TAG="# AI Toolkit Alias Loader"

if [ ! -f "$BASHRC_FILE" ]; then
    echo "Warning: ~/.bashrc not found. Skipping shell auto-configuration."
    exit 0
fi

if ! grep -qF "$BASHRC_TAG" "$BASHRC_FILE"; then
    echo "Adding AI Toolkit configuration to your $BASHRC_FILE..."
    BACKUP_FILE="$BASHRC_FILE.bak.$(date +%Y%m%d%H%M%S)"
    echo "Creating a backup at $BACKUP_FILE"
    cp "$BASHRC_FILE" "$BACKUP_FILE"

    # Append the configuration block using a 'here document' for safety.
    cat <<'EOF' >> "$BASHRC_FILE"

# AI Toolkit Alias Loader
if [ -f "$HOME/.ai_toolkit_aliases" ]; then
    . "$HOME/.ai_toolkit_aliases"
fi
EOF
    echo "Success! Please run 'source $BASHRC_FILE' or open a new terminal."
else
    echo "AI Toolkit configuration already found in $BASHRC_FILE. Skipping."
fi
