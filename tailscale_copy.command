#!/bin/bash

clear
echo "🟦 Coppy folders from MacOS to Windows"
echo "🔹 Drag a folder to this window and press Enter to start"
echo ""

read -e -p "📁 Folder: " SRC

# Remove quotes if any
SRC=${SRC%\"}
SRC=${SRC#\"}

if [ ! -d "$SRC" ]; then
  echo "❌ Invalid path. Drag a valid folder."
  read -p "Press Enter to exit"
  exit 1
fi

# Load local config if exists, otherwise use default values
# Carrega configuração local se existir, senão usa valores padrão
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config.local.sh"

if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
    echo "✅ Configuração local carregada"
else
    echo "⚠️ Arquivo config.local.sh não encontrado em: $SCRIPT_DIR"
    echo "📝 Crie o arquivo config.local.sh com suas configurações"
    echo "📋 Use o arquivo config.example.sh como modelo"
    
    # Valores padrão (exemplo)
    PUSHOVER_USER="your_pushover_user_key"
    PUSHOVER_TOKEN="your_pushover_api_token"
    DEST_USER="windows_username"
    DEST_IP="100.x.x.x"
    DEST_PATH="/c/Tailscale"
fi
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