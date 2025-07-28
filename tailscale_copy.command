#!/bin/bash

clear
echo "🟦 Mac to Win Tailscale Copy"
echo "🔹 Drag a FOLDER into this window and press Enter to start"
echo ""

read -e -p "📁 Folder: " SRC

# Remove quotes if any
SRC=${SRC%\"}
SRC=${SRC#\"}

if [ ! -d "$SRC" ]; then
  echo "❌ Invalid path. Drag a valid FOLDER."
  read -p "Press Enter to exit"
  exit 1
fi

# Load local config - mandatory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config.local.sh"

if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
    echo "✅ Local configuration loaded"
else
    echo "⚠️ config.local.sh file not found"
    echo "📝 Creating config.local.sh with default settings..."
    
    # Create config.local.sh with default content
    cat > "$CONFIG_FILE" << 'EOF'
#!/bin/bash

# EXAMPLE CONFIGURATION

# Pushover (notifications)
PUSHOVER_USER="your_pushover_user_key_here"
PUSHOVER_TOKEN="your_pushover_api_token_here"

# Destination (Windows machine via SSH)
DEST_USER="your_windows_username"
DEST_HOST="100.x.x.x"  # Windows machine IP via Tailscale
DEST_PATH="/c/Tailscale"  # Destination path on Windows
SSH_KEY="~/.ssh/winsshtailcopy"  # SSH key for authentication

# Optional settings
# If you don't use Pushover, leave the keys empty
# PUSHOVER_USER=""
# PUSHOVER_TOKEN=""
EOF

    echo "✅ config.local.sh created successfully"
    echo ""
    echo "📋 Please edit the file with your real settings:"
    echo "   $CONFIG_FILE"
    echo ""
    echo "📝 You need to configure:"
    echo "   1. PUSHOVER_USER and PUSHOVER_TOKEN (for notifications)"
    echo "   2. DEST_USER (your Windows username)"
    echo "   3. DEST_HOST (your Windows IP via Tailscale)"
    echo "   4. DEST_PATH (destination path on Windows)"
    echo "   5. SSH_KEY (path to your SSH key)"
    echo ""
    echo "🔧 After editing the file, run this script again."
    read -p "Press Enter to exit"
    exit 1
fi

FOLDER_NAME=$(basename "$SRC")

echo ""
echo "🔁 Starting copy with automatic reconnection in case of failure"
echo "📂 Source: $SRC"
echo "📍 Destination: ${DEST_USER}@${DEST_HOST}:${DEST_PATH}/${FOLDER_NAME}"
echo "📦 Ignoring files: .DS_Store"
echo "-----------------------------------------------"
echo ""

# Loop until rsync returns successfully
while true; do
  rsync -avh --progress --partial --inplace --exclude='.DS_Store' \
    -e "ssh -i $SSH_KEY" \
    "$SRC" "${DEST_USER}@${DEST_HOST}:${DEST_PATH}/"
  STATUS=$?

  if [ $STATUS -eq 0 ]; then
    echo ""
    echo "✅ Copy completed successfully!"

    # Send Pushover notification
    curl -s \
      -F "token=$PUSHOVER_TOKEN" \
      -F "user=$PUSHOVER_USER" \
      -F "title=✅ Copy completed" \
      -F "message=Copy completed to:"$'\n'"$FOLDER_NAME" \
      https://api.pushover.net/1/messages.json

    break
  else
    echo ""
    echo "⚠️ Connection failed or was interrupted (status $STATUS). Trying again in 30 seconds..."

    # Send error notification via Pushover
    curl -s \
      -F "token=$PUSHOVER_TOKEN" \
      -F "user=$PUSHOVER_USER" \
      -F "title=⚠️ Connection error" \
      -F "message=Failed to send: $FOLDER_NAME"$'\n'"Status: $STATUS"$'\n'"Trying again in 30s..." \
      https://api.pushover.net/1/messages.json

    sleep 30
  fi
done

read -p "Press Enter to exit"