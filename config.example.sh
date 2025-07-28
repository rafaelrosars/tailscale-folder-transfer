#!/bin/bash

# EXAMPLE CONFIGURATION

# Pushover (notificações)
PUSHOVER_USER="sua_pushover_user_key_aqui"
PUSHOVER_TOKEN="sua_pushover_api_token_aqui"

# Destination (Windows machine)
DEST_USER="your_windows_username"
DEST_IP="100.x.x.x"  # Windows IP from tailscale
DEST_PATH="/c/Tailscale"  # Windows path

# Optional settings
SSH_PORT="22"  # SSH port (default: 22)