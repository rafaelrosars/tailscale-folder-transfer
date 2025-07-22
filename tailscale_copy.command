#!/bin/bash

clear
echo "🟦 Coppy folders from MacOS to Windows"
echo "🔹 Drag a folder to this window and press Enter to start"
echo ""

read -e -p "📁 Pasta: " SRC

# Remove quotes if any
SRC=${SRC%\"}
SRC=${SRC#\"}

if [ ! -d "$SRC" ]; then
  echo "❌ Invalid path. Drag a valid folder."
  read -p "Press Enter to exit"
  exit 1
fi

# Replace with your Pushover keys
PUSHOVER_USER="xxx"
PUSHOVER_TOKEN="xxx"

DEST_USER="xxx" # Windows user
DEST_IP="xxx.xxx.xxx.xxx" # Windows IP from tailscale
DEST_PATH="xxx" # Windows path
PASTA_NOME=$(basename "$SRC") # Folder name

echo ""
echo "🔁 Starting copy with automatic reconnection in case of failure"
echo "📂 Source: $SRC"
echo "📍 Destination: ${DEST_USER}@${DEST_IP}:${DEST_PATH}/${PASTA_NOME}"
echo "📦 Ignoring files: .DS_Store"
echo "-----------------------------------------------"
echo ""

# Loop until rsync returns successfully
while true; do
  rsync -avh --progress --partial --inplace --exclude='.DS_Store' "$SRC" "${DEST_USER}@${DEST_IP}:${DEST_PATH}/"
  STATUS=$?

  if [ $STATUS -eq 0 ]; then
    echo ""
    echo "✅ Copy completed successfully!"

    # Send Pushover notification
    curl -s \
      -F "token=$PUSHOVER_TOKEN" \
      -F "user=$PUSHOVER_USER" \
      -F "title=✅ Copy completed" \
      -F "message=Copy completed to:"$'\n'"$PASTA_NOME" \
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
      -F "message=Failed to send: $PASTA_NOME"$'\n'"Status: $STATUS"$'\n'"Trying again in 30s..." \
      https://api.pushover.net/1/messages.json

    sleep 30
  fi
done

read -p "Press Enter to exit"