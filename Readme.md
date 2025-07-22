# tailscale_copy.command

## Overview

**tailscale_copy.command** is a shell script designed to easily copy folders from MacOS to a Windows machine over your Tailscale network. It automatically reconnects and retries if the transfer is interrupted, and sends notifications using [Pushover](https://pushover.net/) when the process completes or encounters an error.

---

## Features

- Drag-and-drop folder selection for MacOS
- Automatic reconnection and retry on failure
- Ignores `.DS_Store` files
- Sends Pushover notifications for success and error events
- Simple, interactive usage

---

## Prerequisites

- **Tailscale** installed and configured on both MacOS and Windows machines
- **rsync** installed on MacOS
- **curl** installed (usually available by default on MacOS)
- [Pushover account](https://pushover.net/) and API credentials

---

## Windows Requirements

To receive folders from MacOS using this script, your Windows machine must:

1. **Have an SSH server installed and running**
   - The easiest way is to install the built-in OpenSSH Server:
     - Go to **Settings > Apps > Optional Features**
     - Click **Add a feature** and search for "OpenSSH Server"
     - Install it, then start the service:
       ```powershell
       Start-Service sshd
       Set-Service -Name sshd -StartupType 'Automatic'
       ```
     - Make sure your Windows firewall allows inbound connections to port **22**.

2. **Have your Windows user account set up for SSH access**
   - The username should match the `DEST_USER` in the script.
   - You may need to set up SSH keys or allow password authentication.

3. **Have a writable destination folder**
   - The path set in `DEST_PATH` must exist and be writable by your Windows user.

---

## Usage

1. **Edit the script**:  
   Open `tailscale_copy.command` in a text editor and set the following variables:
   - `PUSHOVER_USER`: Your Pushover user key
   - `PUSHOVER_TOKEN`: Your Pushover API token
   - `DEST_USER`: The Windows username to connect as
   - `DEST_IP`: The Windows machine’s Tailscale IP address
   - `DEST_PATH`: The destination folder path on the Windows machine

2. **Run the script**:  
   Double-click `tailscale_copy.command` or run it in Terminal:
   ```sh
   ./tailscale_copy.command

3. **Drag and Drop**:
    Drag a folder from Finder into the Terminal window and press Enter.

4. **Automatic Transfer**:
    The script will attempt to copy the folder using rsync. If the connection fails, it will retry every 30 seconds.

5. **Notifications**:
    Upon completion or error, you’ll receive notifications via Pushover.

---

## Example Configuration
```bash
PUSHOVER_USER="your_pushover_user_key"
PUSHOVER_TOKEN="your_pushover_api_token"
DEST_USER="windows_username"
DEST_IP="100.x.x.x"
DEST_PATH="/c/Tailscale"
