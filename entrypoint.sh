#!/bin/bash
set -eu

# Debugging function
function debug_log {
  echo "[DEBUG] $1"
}

# Ensure OpenVPN configuration is provided
if [ -z "${VPN_CONFIG:-}" ]; then
  echo "Error: VPN_CONFIG environment variable is not set."
  exit 1
fi

# Ensure OpenVPN username and password are provided
if [ -z "${VPN_USERNAME:-}" ] || [ -z "${VPN_PASSWORD:-}" ]; then
  echo "Error: VPN_USERNAME and VPN_PASSWORD environment variables are not set."
  exit 1
fi

# Create OpenVPN configuration file
debug_log "Creating OpenVPN configuration file..."
echo "$VPN_CONFIG" > /etc/openvpn/config.ovpn

# Create OpenVPN auth file
debug_log "Creating OpenVPN auth file..."
echo -e "$VPN_USERNAME\n$VPN_PASSWORD" > /etc/openvpn/auth.txt
chmod 600 /etc/openvpn/auth.txt

# Specify the log file
LOG_FILE="/var/log/openvpn.log"

# Start OpenVPN in the background with specified log file and increased verbosity
debug_log "Starting OpenVPN..."
openvpn --config /etc/openvpn/config.ovpn --auth-user-pass /etc/openvpn/auth.txt --daemon --log $LOG_FILE --verb 6

# Wait for the VPN to establish
debug_log "Waiting for VPN to establish..."
sleep 30  # Adjust the sleep time if needed

# Check OpenVPN logs for the successful connection message
if grep -q "Initialization Sequence Completed" $LOG_FILE; then
  debug_log "OpenVPN connection established successfully."
else
  echo "Error: OpenVPN connection failed."
  cat $LOG_FILE  # Print the log file for debugging
  exit 1
fi

# Prepare SSH keys and rsync
SSHPATH="$HOME/.ssh"
if [ ! -d "$SSHPATH" ]; then
  debug_log "Creating SSH directory..."
  mkdir -p "$SSHPATH"
fi

debug_log "Setting up SSH key..."
echo "$DEPLOY_KEY" > "$SSHPATH/key"
chmod 600 "$SSHPATH/key"

SERVER_DEPLOY_STRING="$USERNAME@$SERVER_IP:$SERVER_DESTINATION"

# Sync files using rsync
debug_log "Starting file sync with rsync..."
sh -c "rsync $ARGS -e 'ssh -i $SSHPATH/key -o StrictHostKeyChecking=no -p $SERVER_PORT' $GITHUB_WORKSPACE/$FOLDER $SERVER_DEPLOY_STRING"

# Verify VPN connection again before exit
if pidof openvpn >/dev/null; then
  debug_log "OpenVPN connection verified."
else
  echo "Error: OpenVPN connection failed."
  exit 1
fi

debug_log "Script completed successfully."
